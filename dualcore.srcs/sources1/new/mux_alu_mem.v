`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.05.2025 17:46:11
// Design Name: 
// Module Name: mux_alu_mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
 module mux_alu_mem (
    input        alu_result,         // ALU result
    input        mem_data,           // Data read from memory
    input        mem_to_reg,         // Control signal to select between ALU or Mem data
    output reg   write_data          // Data to be written to register file
);

    always @(*) begin
        if (mem_to_reg)
            write_data = mem_data;  // Select memory data if `mem_to_reg` is high
        else
            write_data = alu_result;  // Otherwise, select ALU result
    end
endmodule

