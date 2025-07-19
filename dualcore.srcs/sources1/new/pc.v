`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.05.2025 19:38:39
// Design Name: 
// Module Name: pc
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


module pc(

input clk,
input reset, 
input [31:0]pc_next,
output reg [31:0] pc

    );
    
    always@(posedge clk or posedge reset)
    begin
    if(reset)
    pc<=32'b0;
    
    else 
    
    pc<=pc_next;
    
    end
endmodule
