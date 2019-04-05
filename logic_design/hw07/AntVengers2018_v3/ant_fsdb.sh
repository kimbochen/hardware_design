#!/bin/sh
ncverilog \
  header.v \
  header_maze10x11.v \
  AntVengers.v \
  maze_universe.v \
  ant_suit.v \
  +fsdbfile=maze10x11.fsdb \
  +debug=1 \
  +access+r
