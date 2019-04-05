#lab5.xdc

#clk
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} -add [get_ports clk]
set_property IOSTANDARD  LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN W5       [get_ports clk]

#button five
set_property IOSTANDARD  LVCMOS33 [get_ports { button[0] }]
set_property PACKAGE_PIN W19	  [get_ports { button[0] }]

#button ten
set_property IOSTANDARD  LVCMOS33 [get_ports { button[1] }]
set_property PACKAGE_PIN U18	  [get_ports { button[1] }]

#button fifty
set_property IOSTANDARD  LVCMOS33 [get_ports { button[2] }]
set_property PACKAGE_PIN T17	  [get_ports { button[2] }]

#button reset
set_property IOSTANDARD  LVCMOS33 [get_ports { button[3] }]
set_property PACKAGE_PIN T18	  [get_ports { button[3] }]

#button cancel
set_property IOSTANDARD  LVCMOS33 [get_ports { button[4] }]
set_property PACKAGE_PIN U17	  [get_ports { button[4] }]

#PS2 clk
set_property IOSTANDARD  LVCMOS33 [get_ports { PS2_CLK }]
set_property PACKAGE_PIN C17      [get_ports { PS2_CLK }]

#PS2 data
set_property IOSTANDARD  LVCMOS33 [get_ports { PS2_DATA }]
set_property PACKAGE_PIN B17      [get_ports { PS2_DATA }]

#AN
set_property IOSTANDARD LVCMOS33 [get_ports {  AN[3] } ]
set_property IOSTANDARD LVCMOS33 [get_ports {  AN[2] } ]
set_property IOSTANDARD LVCMOS33 [get_ports {  AN[1] } ]
set_property IOSTANDARD LVCMOS33 [get_ports {  AN[0] } ]
set_property PACKAGE_PIN W4  [get_ports {  AN[3] } ]
set_property PACKAGE_PIN V4  [get_ports {  AN[2] } ]
set_property PACKAGE_PIN U4  [get_ports {  AN[1] } ]
set_property PACKAGE_PIN U2  [get_ports {  AN[0] } ]

#LED coffee
set_property IOSTANDARD  LVCMOS33 [get_ports { LED[0] }]
set_property PACKAGE_PIN V19      [get_ports { LED[0] }]

#LED coke
set_property IOSTANDARD  LVCMOS33 [get_ports { LED[1] }]
set_property PACKAGE_PIN U19      [get_ports { LED[1] }]

#LED oolong
set_property IOSTANDARD  LVCMOS33 [get_ports { LED[2] }]
set_property PACKAGE_PIN E19      [get_ports { LED[2] }]

#LED water
set_property IOSTANDARD  LVCMOS33 [get_ports { LED[3] }]
set_property PACKAGE_PIN U16      [get_ports { LED[3] }]

#SEG
set_property IOSTANDARD LVCMOS33 [get_ports { SEG[6] } ]
set_property IOSTANDARD LVCMOS33 [get_ports { SEG[5] } ]
set_property IOSTANDARD LVCMOS33 [get_ports { SEG[4] } ]
set_property IOSTANDARD LVCMOS33 [get_ports { SEG[3] } ]
set_property IOSTANDARD LVCMOS33 [get_ports { SEG[2] } ]
set_property IOSTANDARD LVCMOS33 [get_ports { SEG[1] } ]
set_property IOSTANDARD LVCMOS33 [get_ports { SEG[0] } ]
set_property PACKAGE_PIN W7  [get_ports { SEG[0] } ]
set_property PACKAGE_PIN W6  [get_ports { SEG[1] } ]
set_property PACKAGE_PIN U8  [get_ports { SEG[2] } ]
set_property PACKAGE_PIN V8  [get_ports { SEG[3] } ]
set_property PACKAGE_PIN U5  [get_ports { SEG[4] } ]
set_property PACKAGE_PIN V5  [get_ports { SEG[5] } ]
set_property PACKAGE_PIN U7  [get_ports { SEG[6] } ]

#dot
set_property IOSTANDARD  LVCMOS33 [get_ports dot]
set_property PACKAGE_PIN V7  	  [get_ports dot]

