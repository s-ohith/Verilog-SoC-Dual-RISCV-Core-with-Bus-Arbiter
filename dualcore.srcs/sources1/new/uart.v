`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2025 19:39:46
// Design Name: 
// Module Name: uart
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


module uart (
    input clk,
    input rst,
    input [3:0] addr,
    input write_en,
    input [31:0] write_data,
    output reg [31:0] read_data,

    input rx,
    output tx,
    output reg uart_irq
);

    parameter CLK_FREQ = 50000000;     // 50 MHz system clock
    parameter BAUD_RATE = 9600;        // Baud rate

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // Memory-mapped registers
    reg [7:0] tx_data;
    reg tx_start;
    wire tx_busy;

    reg [7:0] rx_data;
    wire rx_done;
    reg rx_clear;

    // Address mapping
    // 0x0 - TX_DATA     (write)
    // 0x4 - RX_DATA     (read)
    // 0x8 - STATUS      (bit 0: TX_BUSY, bit 1: RX_DONE)

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_start <= 0;
            rx_clear <= 0;
            uart_irq <= 0;
        end else begin
            tx_start <= 0;
            rx_clear <= 0;

            if (write_en) begin
                case (addr)
                    4'h0: begin
                        tx_data <= write_data[7:0];
                        tx_start <= 1;
                    end
                endcase
            end

            if (rx_done) begin
                uart_irq <= 1;
            end else if (write_en && addr == 4'h4) begin
                uart_irq <= 0;  // clear interrupt on read
                rx_clear <= 1;
            end
        end
    end

    always @(*) begin
        case (addr)
            4'h4: read_data = {24'b0, rx_data};  // RX Data
            4'h8: read_data = {30'b0, rx_done, tx_busy}; // Status
            default: read_data = 32'hDEADBEEF;
        endcase
    end

    // Instantiate TX & RX engines
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .clear(rx_clear)
    );

endmodule
