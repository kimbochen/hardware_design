module maze_universe (
  input wire clk,
  input wire rst_n,
  input wire [1:0] move,
  output reg ant_r = 0,
  output reg ant_l = 0,
  output reg hit = 0,
  output reg escape = 0
);

  // parameters: action
  parameter [1:0] halt       = `HALT;
  parameter [1:0] turn_right = `RIGHT;
  parameter [1:0] turn_left  = `LEFT;
  parameter [1:0] forward    = `FORWARD;
  // parameters: direction
  parameter [`DIR_WIDTH - 1:0] north = `NORTH;
  parameter [`DIR_WIDTH - 1:0] east  = `EAST;
  parameter [`DIR_WIDTH - 1:0] south = `SOUTH;
  parameter [`DIR_WIDTH - 1:0] west  = `WEST;
  
  reg [`MAZE_ELE_WIDTH - 1:0] maze [0:`MAZE_WIDTH - 1][0:`MAZE_HEIGHT - 1];
  reg [`POS_WIDTH - 1:0] current_x = `INIT_X;
  reg [`POS_WIDTH - 1:0] current_y = `INIT_Y;
  reg [`DIR_WIDTH - 1:0] current_dir = `INIT_DIR;
  reg [`POS_WIDTH - 1:0] exit_x;
  reg [`POS_WIDTH - 1:0] exit_y;
  reg [8 * `STRING - 1:0] maze_description, inputfile, fsdbfile;
  reg [`MAZE_ELE_WIDTH - 1:0] ele_ahead, ele_left, ele_right; // for sensing
  integer i, j;                 // indexes 
  integer fd, status;               // file handler
  integer debug;                // debug flag
  integer step = 0;             // step count

  // Initialization: loading the maze and setting the position
  initial begin
    if ($value$plusargs("debug=%d", debug)) begin
      $display(">>> Debug level = %d", debug);
    end else begin
      debug = 0;
    end
//    if ($value$plusargs("maze=%s", inputfile)) begin
//      maze_description = inputfile;
//    end else begin
//      maze_description = `DEFAULT_MAZE;
//    end
    if ($value$plusargs("fsdbfile=%s", fsdbfile)) begin
      if (debug >= 1)
        $display(">>> Dumping the wafeform to [%s]", fsdbfile);
      $fsdbDumpfile(fsdbfile);
      $fsdbDumpvars;
    end

//    if (debug >= 1)
//      $display(">>> Opening the maze [%s]", maze_description);
    maze_description = `DEFAULT_MAZE;
    fd = $fopen(maze_description, "r");

    for (j = 0; j < `MAZE_HEIGHT; j = j + 1) begin
      for (i = 0; i < `MAZE_WIDTH; i = i + 1) begin
        status = $fscanf(fd, "%1d", maze[i][j]);
        if (maze[i][j] == `EXIT) begin
          exit_x = i;
          exit_y = j;
        end
      end
    end
    if (debug >= 1) begin
      display_maze_initial;
    end
    if (debug == 3) display_maze_elements;

    $fclose(fd);
  end

  // cycle-based position update
  always @(posedge clk, negedge rst_n) begin
    if (rst_n == 0) begin
      step = 0;
      current_x = `INIT_X;
      current_y = `INIT_Y;
      current_dir = `INIT_DIR;

      update_sensor;

      hit = 0;
      escape = 0;

      //display_ant_position;
    end else if (move !== 2'bxx && escape != 1) begin

      step = step + 1;
      hit = 0;
      // make your move 
      casex (move)
        halt: begin
        end
        forward: begin
          case (current_dir)
            north: begin  
              if (maze[current_x][current_y - 1] == `WALL)
                hit = 1;
              else
                current_y = current_y - 1;
            end
            east: begin
              if (maze[current_x + 1][current_y] == `WALL)
                hit = 1;
              else
                current_x = current_x + 1;
            end
            south: begin
              if (maze[current_x][current_y + 1] == `WALL)
                hit = 1;
              else
                current_y = current_y + 1;
            end
            west: begin
              if (maze[current_x - 1][current_y] == `WALL)
                hit = 1;
              else
                current_x = current_x - 1;
            end
            default: $write("Undefined direction: [%d]!!", current_dir);
          endcase
        end
        turn_right: begin
          current_dir = {current_dir[0], current_dir[3:1]};
        end
        turn_left: begin
          current_dir = {current_dir[2:0], current_dir[3]};
        end
      endcase

      // check if escape
      if (current_x == exit_x && current_y == exit_y)
        escape = 1;

      // update sensor
      update_sensor;

      if (debug >= 1) display_ant_position;
      if (debug >= 2) display_maze;
    end
  end

  task update_sensor;
    begin
      case (current_dir)
        north: begin
          ele_ahead = maze[current_x][current_y - 1];
          ele_left  = maze[current_x - 1][current_y];
          ele_right = maze[current_x + 1][current_y];
        end
        east: begin
          ele_ahead = maze[current_x + 1][current_y];
          ele_left  = maze[current_x][current_y - 1];
          ele_right = maze[current_x][current_y + 1];
        end
        south: begin
          ele_ahead = maze[current_x][current_y + 1];
          ele_left  = maze[current_x + 1][current_y];
          ele_right = maze[current_x - 1][current_y];
        end
        west: begin
          ele_ahead = maze[current_x - 1][current_y];
          ele_left  = maze[current_x][current_y + 1];
          ele_right = maze[current_x][current_y - 1];
        end
      endcase

      {ant_l, ant_r} = 2'b00;
      if (escape == 0)      // sense nothing when escaped
        if (ele_ahead == `WALL) begin
          {ant_l, ant_r} = 2'b11;
        end else if (ele_left == `WALL && ele_right < `WALL) begin
          {ant_l, ant_r} = 2'b10;
        end else if (ele_left < `WALL && ele_right == `WALL) begin
          {ant_l, ant_r} = 2'b01;
        end else if (ele_left == `WALL && ele_right == `WALL) begin
          {ant_l, ant_r} = 2'b11;
        end else begin
          {ant_l, ant_r} = 2'b00;
        end
    end
  endtask

  task display_ant_position;
    begin
      $write("[Step %4d] ", step);
      case (move)
        halt:       $write("Halt         ");
        turn_right: $write("Turn Right   ");
        turn_left:  $write("Turn Left    ");
        forward:    $write("Move Forward ");
        default:    $write("Undefined move [%b] ", move);
      endcase
      $write("Position (%2d, %2d) ", current_x, current_y);
      case (current_dir)
        north:   $write("North ");
        east:    $write("East  ");
        south:   $write("South ");
        west:    $write("West  ");
        default: $write("Undefined dir [%b] ", current_dir);
      endcase
      $write(" LR=%1d%1d ", ant_l, ant_r);
      if (hit == 1) $write(" <Hit The Wall!> ");
      if (escape == 1) begin
        $display(" <You Made It!!>");
        $display("");
        $display("<<< Total steps used: %d >>>", step);
        $display(">>> MAZE ESCAPED!!!");
      end
      $display("");

      if (debug == 3)
        $display("ele_ahead, ele_left, ele_right = (%b, %b, %b)",
          ele_ahead, ele_left, ele_right);
    end
  endtask

  task display_maze_initial;
    begin
      $display({`MAZE_WIDTH{"-"}});
      $display("Initial position: (%2d, %2d)", `INIT_X, `INIT_Y);
      $write("Initial direction: ");
      case (`INIT_DIR)
        `NORTH  : $display("North");
        `EAST   : $display("East");
        `SOUTH  : $display("South");
        `WEST   : $display("West");
        default : $display("Undefined direction!");
      endcase
      $display("Maze Exit: (%2d, %2d)", exit_x, exit_y);
      $display("\n");
      $display("Maze Universe:");
      $display({`MAZE_WIDTH{"-"}});
      for (j = 0; j < `MAZE_HEIGHT; j = j + 1) begin
        for (i = 0; i < `MAZE_WIDTH; i = i + 1) begin
          if (i == `INIT_X && j == `INIT_Y && maze[i][j] == 0) begin
            case (`INIT_DIR)
              north: $write("N");
              east: $write("E");
              south: $write("S");
              west: $write("W");
              default: $write("<Direction Not Defined!!>");
            endcase
          end else begin
            if (maze[i][j] == `WALL) $write("%1d", `WALL);
            else if (maze[i][j] == 0) $write(" ");
            else if (maze[i][j] == `EXIT) $write("*");
            else if (maze[i][j] <= 9) $write("%1d", maze[i][j]);
            else $write("X");
          end
        end
        $display("");
      end
      $display("Current (x, y) = (%2d, %2d)", current_x, current_y);
    end
  endtask

  task display_maze;
    begin
      $display("\n");
      $display("Maze Universe:");
      $display({`MAZE_WIDTH{"-"}});
      for (j = 0; j < `MAZE_HEIGHT; j = j + 1) begin
        for (i = 0; i < `MAZE_WIDTH; i = i + 1) begin
          if (i == current_x && j == current_y) begin
            case (`INIT_DIR)
              north: $write("N");
              east: $write("E");
              south: $write("S");
              west: $write("W");
              default: $write("<Direction Not Defined!!>");
            endcase
          end else begin
            if (maze[i][j] == `WALL) $write("%1d", `WALL);
            else if (maze[i][j] == 0) $write(" ");
            else if (maze[i][j] == `EXIT) $write("*");
            else if (maze[i][j] <= 9) $write("%1d", maze[i][j]);
            else $write("X");
          end
        end
        $display("");
      end
      $display("Current (x, y) = (%2d, %2d)", current_x, current_y);
    end
  endtask

  task display_maze_elements;
    begin
      for (j = 0; j < `MAZE_HEIGHT; j = j + 1) begin
        for (i = 0; i < `MAZE_WIDTH; i = i + 1) begin
          $display("maze[%2d][%2d] = %1d", i, j, maze[i][j]);
        end
      end
    end
  endtask

endmodule
