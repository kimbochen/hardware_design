`timescale 1ns/100ps
`define POS_WIDTH 8         // width of x, y position pointers
`define MAZE_ELE_WIDTH 5    // capable of a 32 x 32 maze
`define DIR_WIDTH 4
`define CYC     10
`define DELAY   1
`define ABORT   500         // abort the simulation at this certain period
`define STRING  32          // file name can be `STRING chars at most
`define NORTH   4'b1000
`define EAST    4'b0100
`define SOUTH   4'b0010
`define WEST    4'b0001
`define HALT    2'b00
`define RIGHT   2'b01
`define LEFT    2'b10
`define FORWARD 2'b11

`define WALL    4'd8        // wall of the maze
`define EXIT    4'd9        // exit of the maze