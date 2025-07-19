module system_bus (
    input clk,
    input reset,

    // CPU Interface
    input        cpu_req,
    input        cpu_we,
    input [31:0] cpu_addr,
    input [31:0] cpu_wdata,
    output       cpu_ack,
    output [31:0] cpu_rdata,

    // DMA Interface
    input        dma_req,
    input        dma_we,
    input [31:0] dma_addr,
    input [31:0] dma_wdata,
    output       dma_ack,
    output [31:0] dma_rdata,

    // Shared Memory Interface
    output       mem_we,
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    input [31:0] mem_rdata,
    output       mem_en,
    input        mem_ack
);

    // Arbitration: simple priority (DMA > CPU)
    wire use_dma = dma_req;
    wire use_cpu = ~dma_req & cpu_req;

    assign mem_we     = use_dma ? dma_we    : (use_cpu ? cpu_we    : 1'b0);
    assign mem_addr   = use_dma ? dma_addr  : (use_cpu ? cpu_addr  : 32'b0);
    assign mem_wdata  = use_dma ? dma_wdata : (use_cpu ? cpu_wdata : 32'b0);
    assign mem_en     = use_dma | use_cpu;

    assign dma_rdata  = mem_rdata;
    assign dma_ack    = use_dma ? mem_ack : 1'b0;

    assign cpu_rdata  = mem_rdata;
    assign cpu_ack    = use_cpu ? mem_ack : 1'b0;

endmodule
