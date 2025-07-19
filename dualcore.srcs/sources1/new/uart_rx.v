module uart_rx (
    input clk,
    input reset,
    input rx,
    output reg [7:0] rx_data,
    output reg rx_done
);

parameter CLK_FREQ = 100_000_0;
parameter BAUD_RATE = 115_200;
localparam BIT_TICKS = CLK_FREQ / BAUD_RATE;
localparam BIT_COUNTER_WIDTH = $clog2(BIT_TICKS);
localparam HALF_BIT = BIT_TICKS / 2;

reg [3:0] state;
reg [BIT_COUNTER_WIDTH-1:0] bit_timer;
reg [2:0] bit_index;
reg [7:0] rx_reg;

localparam IDLE = 0;
localparam START_DETECT = 1;
localparam DATA_BITS = 2;
localparam STOP_DETECT = 3;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        rx_done <= 1'b0;
    end else begin
        rx_done <= 1'b0;
        case (state)
            IDLE: begin
                if (!rx) begin  // Start bit detected
                    state <= START_DETECT;
                    bit_timer <= 0;
                end
            end
            
            START_DETECT: begin
                if (bit_timer == HALF_BIT - 1) begin
                    if (!rx) begin  // Valid start bit
                        state <= DATA_BITS;
                        bit_timer <= 0;
                        bit_index <= 0;
                    end else begin
                        state <= IDLE;
                    end
                end else begin
                    bit_timer <= bit_timer + 1;
                end
            end
            
            DATA_BITS: begin
                if (bit_timer == BIT_TICKS - 1) begin
                    rx_reg[bit_index] <= rx;
                    bit_timer <= 0;
                    if (bit_index == 7) begin
                        state <= STOP_DETECT;
                    end else begin
                        bit_index <= bit_index + 1;
                    end
                end else begin
                    bit_timer <= bit_timer + 1;
                end
            end
            
            STOP_DETECT: begin
                if (bit_timer == BIT_TICKS - 1) begin
                    rx_data <= rx_reg;
                    rx_done <= 1'b1;
                    state <= IDLE;
                end else begin
                    bit_timer <= bit_timer + 1;
                end
            end
        endcase
    end
end

endmodule
