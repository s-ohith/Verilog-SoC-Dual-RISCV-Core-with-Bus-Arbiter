module spi_master (
    input clk,
    input reset,
    // Control Interface
    input start,
    input [7:0] tx_data,
    output reg [7:0] rx_data,
    output reg busy,
    output reg ready,
    // SPI Interface
    output reg sclk,
    output reg mosi,
    input miso,
    output reg cs
);

// SPI Mode: CPOL=0, CPHA=0 (Mode 0)
parameter CLK_DIV = 10;  // 100MHz / (2*10) = 5MHz SPI clock

reg [3:0] state;
reg [7:0] clk_counter;
reg [2:0] bit_counter;
reg [7:0] tx_reg;
reg [7:0] rx_reg;

localparam IDLE      = 4'b0001;
localparam START     = 4'b0010;
localparam TRANSFER  = 4'b0100;
localparam COMPLETE  = 4'b1000;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        sclk <= 1'b0;
        cs <= 1'b1;
        busy <= 1'b0;
        ready <= 1'b1;
        clk_counter <= 0;
        bit_counter <= 0;
        rx_data <= 0;
    end else begin
        case (state)
            IDLE: begin
                sclk <= 1'b0;
                cs <= 1'b1;
                busy <= 1'b0;
                ready <= 1'b1;
                if (start && ready) begin
                    state <= START;
                    tx_reg <= tx_data;
                    cs <= 1'b0;
                    busy <= 1'b1;
                    ready <= 1'b0;
                    clk_counter <= 0;
                end
            end
            
            START: begin
                if (clk_counter == CLK_DIV-1) begin
                    state <= TRANSFER;
                    clk_counter <= 0;
                    sclk <= 1'b0;
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end
            
            TRANSFER: begin
                if (clk_counter == CLK_DIV-1) begin
                    sclk <= ~sclk;
                    clk_counter <= 0;
                    
                    if (sclk) begin
                        // Rising edge: sample data
                        rx_reg <= {rx_reg[6:0], miso};
                        
                        if (bit_counter == 7) begin
                            state <= COMPLETE;
                        end else begin
                            bit_counter <= bit_counter + 1;
                        end
                    end else begin
                        // Falling edge: shift out data
                        mosi <= tx_reg[7];
                        tx_reg <= {tx_reg[6:0], 1'b0};
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end
            
            COMPLETE: begin
                if (clk_counter == CLK_DIV-1) begin
                    state <= IDLE;
                    rx_data <= rx_reg;
                    cs <= 1'b1;
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end
        endcase
    end
end

endmodule
