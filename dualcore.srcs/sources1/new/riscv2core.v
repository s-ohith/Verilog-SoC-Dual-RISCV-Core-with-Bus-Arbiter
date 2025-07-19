`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2025 18:43:45
// Design Name: 
// Module Name: riscv2core
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


module riscv2core(


    input clk,
    input reset,
    
    // === Output ports for debug ===
    output [31:0] pc_out,
    output [31:0] instruction_out,
    output [31:0] alu_result_out,
    output [31:0] reg_data1_out,
    output [31:0] reg_data2_out,
    output [31:0] write_data_out,
    output [31:0] mem_read_data_out,
    output[2:0]alu_op,
       output[3:0]alu_ctrl,
       output[4:0]rs_1,
       output [4:0]rs_2,
       output [31:0] imm_out1
     
);


    
    // Delayed write enable to skip write back in the first cycle
 
    // === Program Counter ===
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4 = pc_current + 4;

    pc PC (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_plus_4),
        .pc(pc_current)
    );

    // === Instruction Memory ===
    wire [31:0] instruction;

    instr1mem IMEM (
        .pc(pc_current),
        .instruction(instruction)
    );
    
      wire [31:0] imm_out;

    imm_gen IMM (
        .instruction(instruction),
        .imm_out(imm_out)
    );


    // === Decode Fields ===
    wire [6:0] opcode  = instruction[6:0];
    wire [4:0] rd      = instruction[11:7];
    wire [2:0] funct3  = instruction[14:12];
    wire [4:0] rs1     = instruction[19:15];
    wire [4:0] rs2     = instruction[24:20];
    wire [6:0] funct7  = instruction[31:25];

    // === Control Unit ===
    wire reg_write, alu_src, mem_to_reg, mem_read, mem_write, branch;
 

    control_unit CU (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .alu_op(alu_op)
    );

    // === Register File ===
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] write_data;
  
     reg write_enable_delay;

    always @(posedge clk or posedge reset) begin
        if (reset)
            write_enable_delay <= 0;
        else
            write_enable_delay <= reg_write;
    end

   
    
    reg_file RF (
       
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .reg_write(write_enable_delay),
        .write_data(write_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    // === Immediate Generator ===
  
    // === ALU Control ===


    alu_cu ALU_CU (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_ctrl(alu_ctrl)
    );

    // === ALU Operand MUX ===
    wire [31:0] alu_input2;

    assign alu_input2 = (alu_src) ? imm_out : reg_data2;
    
 

    // === ALU ===
    wire [31:0] alu_result;
    wire        zero;

    alu ALU (
        .instruction1(instruction),
        .in1(reg_data1),
        .in2(alu_input2),
        .sel(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );

    // === Data Memory ===
    wire [31:0] mem_read_data;

    data_memm DMEM (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(reg_data2),
        .read_data(mem_read_data)
    );

    // === MUX for Write-back to Register File ===
    Mux M1(alu_result,mem_read_data,mem_to_reg,write_data);

    // === PC Branch Logic ===
    wire branch_taken = branch & zero;
    wire [31:0] branch_target = pc_current + imm_out;

    assign pc_next = (branch_taken) ? branch_target : pc_plus_4;

    // === Output assignments ===
    assign pc_out            = pc_current;
    assign instruction_out   = instruction;
    assign alu_result_out    = alu_result;
    assign reg_data1_out     = reg_data1;
    assign reg_data2_out     = reg_data2;
    assign write_data_out    = write_data;
    assign mem_read_data_out = mem_read_data;
    assign rs_1 = rs1;
    assign rs_2= rs2;
    assign  imm_out1=imm_out;
endmodule
 