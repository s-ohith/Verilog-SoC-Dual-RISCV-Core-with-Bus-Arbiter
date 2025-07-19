`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.06.2025 06:45:25
// Design Name: 
// Module Name: coverage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module coverage1;
  bit [0:2] y; // 3-bit variable (bits indexed from 0 to 2)
  bit [0:2] values[$] = '{3,5,6}; // Dynamic array with values to test (3-bit values)

  covergroup cg;
    cover_point_y : coverpoint y;
  endgroup

  cg cg_inst = new(); // Create an instance of the covergroup

  initial
    foreach(values[i]) begin
      y = values[i];         // Assign each value to y
      cg_inst.sample();      // Sample y for coverage
    end
endmodule

