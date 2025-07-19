`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.05.2025 17:48:01
// Design Name: 
// Module Name: mux_pc
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


module mux_pc (
    input        branch_taken,       // Control signal (whether branch is taken)
    input [31:0] pc_next,           // Next PC address (PC + 4)
    input [31:0] branch_addr,       // Branch target address
    output reg   [31:0] pc_out      // Output address for PC
);

    always @(*) begin
        if (branch_taken)
            pc_out = branch_addr;    // Select branch target address if branch is taken
        else
            pc_out = pc_next;        // Otherwise, select next PC (PC + 4)
    end
endmodule
