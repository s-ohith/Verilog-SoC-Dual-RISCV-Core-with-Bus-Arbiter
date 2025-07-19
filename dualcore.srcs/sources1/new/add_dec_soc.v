`timescale 1ns / 1ps

module add_dec_soc(
    input  [31:0] addr,        // Address from RISC-V core
    output        mem_sel,     // Select signal for memory
    output        gpio_sel,    // Select signal for GPIO
    output        uart_sel,    // Select signal for UART
    output        timer_sel,   // Select signal for Timer
    output        dma_sel      // Select signal for DMA
);

// === Memory Map Definitions ===
parameter MEM_BASE   = 32'h00000000;
parameter MEM_MASK   = 32'hFFFF0000;

parameter GPIO_BASE  = 32'h10000000;
parameter GPIO_MASK  = 32'hFFFF0000;

parameter UART_BASE  = 32'h20000000;
parameter UART_MASK  = 32'hFFFF0000;

parameter TIMER_BASE = 32'h30000000;
parameter TIMER_MASK = 32'hFFFF0000;

parameter DMA_BASE   = 32'h40000000;
parameter DMA_MASK   = 32'hFFFF0000;

// === Address Decoding ===
assign mem_sel   = ((addr & MEM_MASK)   == MEM_BASE);
assign gpio_sel  = ((addr & GPIO_MASK)  == GPIO_BASE);
assign uart_sel  = ((addr & UART_MASK)  == UART_BASE);
assign timer_sel = ((addr & TIMER_MASK) == TIMER_BASE);
assign dma_sel   = ((addr & DMA_MASK)   == DMA_BASE);

endmodule
