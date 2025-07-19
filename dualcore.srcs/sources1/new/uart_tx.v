module uart_tx (
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,
    output reg tx,
    output tx_busy
);

parameter CLK_FREQ = 100_000_0;  // System clock frequency
parameter BAUD_RATE = 115_200;
localparam BIT_TICKS = CLK_FREQ / BAUD_RATE;
localparam BIT_COUNTER_WIDTH = $clog2(BIT_TICKS);

reg [3:0] state;
reg [BIT_COUNTER_WIDTH-1:0] bit_timer;
reg [2:0] bit_index;
reg [7:0] tx_reg;

localparam IDLE = 0;
localparam START_BIT = 1;
localparam DATA_BITS = 2;
localparam STOP_BIT = 3;

assign tx_busy = (state != IDLE);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        tx <= 1'b1;
    end else begin
        case (state)
            IDLE: begin
                tx <= 1'b1;
                if (tx_start) begin
                    tx_reg <= tx_data;
                    state <= START_BIT;
                    bit_timer <= 0;
                end
            end
            
            START_BIT: begin
                tx <= 1'b0;
                if (bit_timer == BIT_TICKS - 1) begin
                    bit_timer <= 0;
                    state <= DATA_BITS;
                    bit_index <= 0;
                end else begin
                    bit_timer <= bit_timer + 1;
                end
            end
            
            DATA_BITS: begin
                tx <= tx_reg[bit_index];
                if (bit_timer == BIT_TICKS - 1) begin
                    bit_timer <= 0;
                    if (bit_index == 7) begin
                        state <= STOP_BIT;
                    end else begin
                        bit_index <= bit_index + 1;
                    end
                end else begin
                    bit_timer <= bit_timer + 1;
                end
            end
            
            STOP_BIT: begin
                tx <= 1'b1;
                if (bit_timer == BIT_TICKS - 1) begin
                    state <= IDLE;
                end else begin
                    bit_timer <= bit_timer + 1;
                end
            end
        endcase
    end
end

endmodule
