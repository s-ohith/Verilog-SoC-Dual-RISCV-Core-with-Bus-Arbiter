module spi_slave (
    input clk,
    input reset,
    input [7:0] tx_data,
    output reg [7:0] rx_data,
    output reg ready,
    input sclk,
    input mosi,
    output reg miso,
    input cs
);

reg [7:0] tx_reg;
reg [7:0] rx_reg;
reg prev_sclk;
reg cs_prev;
reg [2:0] bit_counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        rx_reg <= 0;
        tx_reg <= 0;
        miso <= 1'b0;
        ready <= 1'b0;
        prev_sclk <= 0;
        cs_prev <= 1;
        bit_counter <= 0;
    end else begin
        cs_prev <= cs;
        ready <= 0;

        // Detect falling edge of CS to load data
        if (cs_prev && !cs) begin
            tx_reg <= tx_data;
            bit_counter <= 0;
            rx_reg <= 0;
        end

        if (!cs) begin
            // Rising edge of sclk - shift out data
            if (sclk && !prev_sclk) begin
                miso <= tx_reg[7];  // MSB first
                tx_reg <= {tx_reg[6:0], 1'b0};  // shift left
            end

            // Falling edge of sclk - read in data
            if (!sclk && prev_sclk) begin
                rx_reg <= {rx_reg[6:0], mosi};
                if (bit_counter == 7) begin
                    rx_data <= {rx_reg[6:0], mosi};
                    ready <= 1;
                end
                bit_counter <= bit_counter + 1;
            end
        end

        prev_sclk <= sclk;
    end
end

endmodule
