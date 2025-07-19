`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.05.2025 22:34:07
// Design Name: 
// Module Name: instruct_mem_soc
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

    
module instruct_mem_soc(input [31:0] pc,
    output [31:0] instruction
);

    reg [31:0] memory [0:255];  // 1KB of instruction memory

   initial begin
    memory[0]  = 32'h002081b3; // add x3, x1, x2
    memory[1]  = 32'h40428233; // sub x4, x5, x4
    memory[2]  = 32'h00a00393; // addi x7, x0, 10
    memory[3]  = 32'h12304813; // x8 = x0 + 0x1230 (addi used here)
    memory[4]  = 32'h00800493; // mv x9, x8 (pseudo = addi x9, x8, 0)
    memory[5]  = 32'h00001537; // lui x10, 0x1
    memory[6]  = 32'h00002517; // auipc x10, 0x2
    memory[7]  = 32'h4062c633; // and x12, x5, x6
    memory[8]  = 32'h4062e6b3; // or x13, x5, x6
    memory[9]  = 32'h4062e733; // xor x14, x5, x6
    memory[10] = 32'h0ff2f7b3; // andi x15, x5, 0xFF
    memory[11] = 32'h0012f833; // ori x16, x5, 0x01
    memory[12] = 32'h0f02f8b3; // xori x17, x5, 0xF0
    memory[13] = 32'h001292b3; // sll x5, x5, x1
    memory[14] = 32'h0012d333; // srl x6, x5, x1
    memory[15] = 32'h4012d3b3; // sra x7, x5, x1
    memory[16] = 32'h00229293; // slli x5, x5, 2
    memory[17] = 32'h0012d313; // srli x6, x5, 1
    memory[18] = 32'h4032d393; // srai x7, x5, 3
    memory[19] = 32'h00052c03; // lw x24, 0(x10)
    memory[20] = 32'h00252c83; // lh x25, 2(x10)
    memory[21] = 32'h00452d03; // lhu x26, 4(x10)
    memory[22] = 32'h00652d83; // lb x27, 6(x10)
    memory[23] = 32'h00852e03; // lbu x28, 8(x10)
    memory[24] = 32'h00c52e83; // sw x29, 12(x10)
    memory[25] = 32'h00e52f03; // sh x30, 14(x10)
    memory[26] = 32'h01052f83; // sb x31, 16(x10)
    memory[27] = 32'h00210263; // beq x2, x2, +4
    memory[28] = 32'h00412263; // bne x2, x4, +8
    memory[29] = 32'h0062c463; // blt x5, x6, +12
    memory[30] = 32'h0062d663; // bge x5, x6, +16
    memory[31] = 32'h0040006f; // jal x0, 4
end


    assign instruction = memory[pc[9:2]];  // Word-aligned (drop bottom 2 bits)

endmodule
