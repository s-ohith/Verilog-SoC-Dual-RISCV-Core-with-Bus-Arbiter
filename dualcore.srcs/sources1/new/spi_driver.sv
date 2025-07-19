`timescale 1ns / 1ps

module spi_driver (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start_tx,
    input  logic [7:0]  data,
    output logic        MOSI,
    output logic        SCLK,
    output logic        CS,
    output logic        busy,
    output logic        done
);

    // Clock divider for SCLK generation.
    // SCLK frequency = clk / (2 * (CLK_DIV_MAX + 1))
    localparam int CLK_DIV_MAX = 4;

    typedef enum logic [1:0] {
        IDLE,
        TRANSFER,
        DONE
    } state_t;

    state_t state;

    logic [7:0] shift_reg;
    logic [2:0] bit_cnt;
    logic [$clog2(CLK_DIV_MAX):0] clk_div;
    logic sclk_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            shift_reg <= 8'h0;
            bit_cnt   <= 0;
            clk_div   <= 0;
            sclk_reg  <= 0;
            busy      <= 0;
            done      <= 0;
            CS        <= 1;
        end else begin
            // Default assignments that can be overridden by states
            done <= 1'b0; // done is a one-cycle pulse

            case (state)
                IDLE: begin
                    CS       <= 1'b1;
                    busy     <= 1'b0;
                    sclk_reg <= 1'b0;
                    if (start_tx) begin
                        busy      <= 1'b1;
                        shift_reg <= data;
                        bit_cnt   <= 7; // Start with bit 7
                        clk_div   <= 0;
                        CS        <= 1'b0; // Assert CS
                        state     <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    // SCLK Generation
                    if (clk_div == CLK_DIV_MAX) begin
                        clk_div  <= 0;
                        sclk_reg <= ~sclk_reg;

                        // Data Shifting Logic (occurs on falling edge of sclk_reg)
                        if (sclk_reg == 1'b1) begin // If sclk_reg was high, it's now low
                            if (bit_cnt == 0) begin
                                state <= DONE;
                            end else begin
                                bit_cnt <= bit_cnt - 1;
                            end
                            shift_reg <= shift_reg << 1;
                        end
                    end else begin
                        clk_div <= clk_div + 1;
                    end
                end

                DONE: begin
                    busy  <= 1'b0;
                    done  <= 1'b1;
                    CS    <= 1'b1; // De-assert CS
                    state <= IDLE;
                end
            endcase
        end
    end

    // Combinational logic for outputs
    assign SCLK = (state == TRANSFER) ? sclk_reg : 1'b0;
    assign MOSI = shift_reg[7];

endmodule
    