
// Company: 
// Engineer: 
// 
// Create Date: 14.05.2025 20:16:36
// Design Name: 
// Module Name: reg_file
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


module reg_file(

input wire clk,
input wire reg_write,
input [4:0] rs1,rs2,rd,
input wire[31:0] write_data,
output wire [31:0] read_data1,
output wire [31:0] read_data2



    );
    
    reg [31:0]  reg_memory[31:0];
      integer i=0;
      
        initial
    begin
        // Bear with me for now, I tried using loops, but it won't work
        // Just duct-taping this for now
         reg_memory[0] = 32'h0;
         reg_memory[1] = 32'h1;
         reg_memory[2] = 32'h2;
         reg_memory[3] = 32'h3;
         reg_memory[4] = 32'h4;
         reg_memory[5] = 32'h5;
         reg_memory[6] = 32'h6;
         reg_memory[7] = 32'h7;
         reg_memory[8] = 32'h8;
         reg_memory[9] = 32'h9;
         reg_memory[10] = 32'h10;
         reg_memory[11] = 32'h11;
         reg_memory[12] = 32'h12;
         reg_memory[13] = 32'h13;
         reg_memory[14] = 32'h14;
         reg_memory[15] = 32'h15;
         reg_memory[16] = 32'h16;
         reg_memory[17] = 32'h17;
         reg_memory[18] = 32'h18;
         reg_memory[19] = 32'h19;
         reg_memory[20] = 32'h20;
         reg_memory[21] = 32'h21;
         reg_memory[22] = 32'h22;
         reg_memory[23] = 32'h23;
         reg_memory[24] = 32'h24;
         reg_memory[25] = 32'h25;
		 reg_memory[26] = 32'h26;
         reg_memory[27] = 32'h27;
         reg_memory[28] = 32'h28;
         reg_memory[29] = 32'h29;
         reg_memory[30] = 32'h30;
         reg_memory[31] = 32'h31;

    end
      
        assign read_data1 = (rs1 == 0) ? 32'b0 : reg_memory[rs1];  // x0 is always 0
    assign read_data2 = (rs2 == 0) ? 32'b0 : reg_memory[rs2];
    
    
     
    always@(posedge clk) begin
   
   if (reg_write && rd != 0)begin
    reg_memory[rd] <=write_data;
end
    end
   
endmodule
