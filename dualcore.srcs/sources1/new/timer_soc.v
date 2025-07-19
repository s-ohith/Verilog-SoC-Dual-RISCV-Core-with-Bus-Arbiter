`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.05.2025 22:40:09
// Design Name: 
// Module Name: timer_soc
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


module timer_soc (
    input clk,
    input reset,
    input [3:0] addr,
    input [31:0] data_in,
    output reg [31:0] data_out,
    input write_en
);
    // Dummy timer register
    reg [31:0] timer_reg;

    always @(posedge clk or posedge reset) begin
        if (reset)
            timer_reg <= 32'b0;
        else if (write_en)
            timer_reg <= data_in;
    end

    always @(*) begin
        data_out = timer_reg;
    end
endmodule
