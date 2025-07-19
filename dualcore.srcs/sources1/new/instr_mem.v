
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.05.2025 20:00:34
// Design Name: 
// Module Name: instr_mem
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


module instr_mem(
input clk,
input wire [31:0]pc,
output reg [31:0]instruction,
  input         write_en,
    input  [7:0]  write_addr,
    input  [31:0] write_data

    );
    reg [31:0] memory [0:255];
    
    initial
    begin
  memory[0]  = 32'h00100093; // addi x1, x0, 1  

memory[1]  = 32'h00000013; // nop  

memory[2]  = 32'h00200113; // addi x2, x0, 2  

memory[3]  = 32'h00000013; // nop  

memory[4]  = 32'h00308193; // addi x3, x1, 3  

memory[5]  = 32'h00000013; // nop  

memory[6]  = 32'h00408213; // addi x4, x1, 4  

memory[7]  = 32'h00000013; // nop  

memory[8]  = 32'h00510293; // addi x5, x2, 5  

memory[9]  = 32'h00000013; // nop  

memory[10] = 32'h00618313; // addi x6, x3, 6  

memory[11] = 32'h00000013; // add x9, x5, x11  

memory[12] = 32'h00000013; // nop  

memory[13] = 32'h00618313; // add x10, x5, x12  

memory[14] = 32'h00000013; // nop  

memory[15] = 32'h005324b3; // add x9, x6, x5  

memory[16] = 32'h00000013; // nop  

memory[17] = 32'h00050463; // beq x10, x0, +8  

memory[18] = 32'h00000013; // nop  

memory[19] = 32'h0002a283; // lw x5, 0(x5)  

memory[20] = 32'h00000013; // nop  

memory[21] = 32'h01000093; // sw x5, 0(x5)  

memory[22] = 32'h00000013; // nop  

memory[23] = 32'h00212023; // nop  

memory[24] = 32'h00000013; // nop  

memory[25] = 32'h00212023; // nop  

memory[26] = 32'h00000013; // nop  

memory[27] = 32'h10000793; // nop  

memory[28] = 32'h20000793; 

memory[29] = 32'h30000793;

memory[30] = 32'h40000793;

memory[31] = 32'h00800093;//dma

memory[32] = 32'h10000113;

memory[33] = 32'h11000193;

memory[34] = 32'h00102023;

memory[35] = 32'h002020A3;

memory[36] = 32'h00302123;

memory[37] = 32'h00100213;

memory[38] = 32'h400002b7;//

memory[39] = 32'h00028293;

memory[40] = 32'h00428293;

memory[41] = 32'h00828293;

memory[42] = 32'h00c28293;

memory[43] = 32'h00100393;

memory[44] = 32'h40000137;

memory[45] = 32'h40000013;//

memory[46] = 32'h00428593;

memory[47] = 32'h00428593;

memory[48] = 32'h0055a023;

memory[49] = 32'h0055a023;

memory[50] = 32'h0055a023;

memory[51] = 32'h0055a023;

memory[52] = 32'h0055a023;

memory[53] = 32'h0055a023;






// nop  

    end
    
    always @(posedge clk) begin
    if (write_en)
        memory[write_addr] <= write_data;
    end
    
    always@(*)
    begin
    instruction<=memory[pc[9:2]];
    end
endmodule
