
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.05.2025 23:38:16
// Design Name: 
// Module Name: data_mem
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

 module data_mem (
    input         clk,                // Clock signal
    input         mem_read,           // Memory read signal (for load)
    input         mem_write,          // Memory write signal (for store)
    input  [31:0] address,            // Address to access memory
    input  [31:0] write_data,         // Data to write to memory
    output reg [31:0] read_data       // Data read from memory
);

    reg [31:0] memory [0:255];         // Memory array (256 x 32-bit)
    
    initial begin
        memory[0] = 32'h0;
        memory[1] = 32'h1;
        memory[2] = 32'h2;
        memory[3] = 32'h3;
        memory[4] = 32'h4;
        memory[5] = 32'h5;
        memory[6] = 32'h6;
        memory[7] = 32'h7;
        memory[8] = 32'h8;
        memory[9] = 32'h9;
        memory[10] = 32'h10;
        memory[11] = 32'h11;
        memory[12] = 32'h12;
        memory[13] = 32'h13;
        memory[14] = 32'h14;
        memory[15] = 32'h15;
        memory[16] = 32'h16;
        memory[17] = 32'h17;
        memory[18] = 32'h18;
        memory[19] = 32'h19;
        memory[20] = 32'h20;
        memory[21] = 32'h21;
        memory[22] = 32'h22;
        memory[23] = 32'h23;
        memory[24] = 32'h24;
        memory[25] = 32'h25;
        memory[26] = 32'h26;
        memory[27] = 32'h27;
        memory[28] = 32'h28;
        memory[29] = 32'h29;
        memory[30] = 32'h30;
        memory[31] = 32'h31;
    end
    
    always @(posedge clk) begin
        if (mem_write) begin
            memory[address[9:2]] <= write_data;  // Write to memory (byte-aligned)
        end
    end

    always @(posedge clk) begin
        if (mem_read) begin
            read_data = memory[address[9:2]]; // Read from memory
        end else begin
            read_data = 32'b0;  // Default to zero if not reading
        end
    end

endmodule

