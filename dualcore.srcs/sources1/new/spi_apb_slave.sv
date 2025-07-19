`timescale 1ns / 1ps

module spi_apb_slave (
    input  logic        clk,
    input  logic        rst_n,

    // APB Interface
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [11:0] PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,

    // SPI physical signals
    output logic        SCLK,
    output logic        MOSI,
    input  logic        MISO,
    output logic        CS
);

    // Internal signals
    logic       start_tx;
    logic [7:0] tx_data;
    logic       busy;
    logic       driver_done;       // The 1-cycle pulse from the driver
    logic       done_status_reg;   // The latched version for the status register
    logic [7:0] rx_data;

    // Address map
    // 0x00 -> TXDATA (write)
    // 0x04 -> STATUS (read) {busy, done}
    // 0x08 -> RXDATA (read)

    // APB Write Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data  <= 8'h00;
            start_tx <= 1'b0;
        end else begin
            start_tx <= 1'b0; // Default to not starting

            if (PSEL && PENABLE && PWRITE && PADDR[3:0] == 4'h0) begin
                tx_data  <= PWDATA[7:0];
                start_tx <= 1'b1; // Trigger transmission
            end
        end
    end

    // Done Flag Logic: Latch the 'done' pulse from the driver.
    // Clear the latched flag when the RXDATA register is read.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_status_reg <= 1'b0;
        end else begin
            if (driver_done) begin
                // Latch the pulse from the driver
                done_status_reg <= 1'b1;
            end else if (PSEL && !PWRITE && PENABLE && PADDR[3:0] == 4'h8) begin
                // Clear the flag when RXDATA is read
                done_status_reg <= 1'b0;
            end
        end
    end

    // APB Read Logic
    always_comb begin
        PRDATA = 32'h0;
        if (PSEL && !PWRITE && PENABLE) begin
            case (PADDR[3:0])
                4'h4: PRDATA = {30'b0, busy, done_status_reg}; // STATUS: Use the latched done flag
                4'h8: PRDATA = {24'b0, rx_data};               // RXDATA
                default: PRDATA = 32'hDEAD_BEEF;
            endcase
        end
    end

    // Instantiate the SPI driver
    spi_driver spi_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start_tx(start_tx),
        .data(tx_data),
        .busy(busy),
        .done(driver_done), // Connect to the internal wire that catches the pulse
        .MOSI(MOSI),
        .SCLK(SCLK),
        .CS(CS)
    );

    // Optional: SPI monitor to capture received data via MISO
    // This is a placeholder; you would need a real monitor for loopback tests.
    assign rx_data = 8'hAB; // For now, hardcode a value to see in the test.

endmodule
