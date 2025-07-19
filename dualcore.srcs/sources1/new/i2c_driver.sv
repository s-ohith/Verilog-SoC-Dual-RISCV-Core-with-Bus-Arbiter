`timescale 1ns / 1ps

module i2c_driver (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start_tx,
    input  logic [6:0]  addr,
    input  logic        rw,      // 0 = write, 1 = read
    input  logic [7:0]  data,
    output logic        SDA,
    output logic        SCL,
    output logic        busy
);

    // SCL clock generation.
    // For a 100MHz system clock (10ns period) and 100kHz I2C SCL, SCL_PERIOD should be 1000.
    // For simulation, a smaller value is fine to speed things up.
    localparam int SCL_PERIOD = 100; // 100 * 10ns = 1us period => 1MHz SCL
    localparam int SCL_HALF_PERIOD = SCL_PERIOD / 2;

    typedef enum logic [2:0] {
        IDLE,
        START_COND,
        SHIFT_BITS,
        WAIT_ACK,
        STOP_SETUP,
        STOP_COND
    } state_t;

    state_t state;

    logic [15:0] shift_reg;
    logic [4:0]  bit_cnt;
    logic [$clog2(SCL_PERIOD):0] clk_count;
    logic sda_out;
    logic sda_en;

    // FSM and counter logic - Rewritten for robustness
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            clk_count <= 0;
            bit_cnt   <= 0;
            shift_reg <= 0;
            busy      <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start_tx) begin
                        busy      <= 1'b1;
                        shift_reg <= {addr, rw, data};
                        bit_cnt   <= 0;
                        clk_count <= 0;
                        state     <= START_COND;
                    end
                end

                START_COND: begin
                    if (clk_count == SCL_HALF_PERIOD - 1) begin
                        clk_count <= 0;
                        state     <= SHIFT_BITS;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                SHIFT_BITS: begin
                    if (clk_count == SCL_PERIOD - 1) begin
                        clk_count <= 0;
                        // After shifting the 8th bit (addr+rw) or 16th bit (data)
                        if (bit_cnt == 7 || bit_cnt == 15) begin
                            state <= WAIT_ACK;
                        end
                        bit_cnt <= bit_cnt + 1;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                WAIT_ACK: begin
                    if (clk_count == SCL_PERIOD - 1) begin
                        clk_count <= 0;
                        // After addr ACK (bit_cnt is 8), continue shifting
                        // After data ACK (bit_cnt is 16), stop
                        if (bit_cnt < 16) begin
                            state <= SHIFT_BITS;
                        end else begin
                            state <= STOP_SETUP;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STOP_SETUP: begin
                    if (clk_count == SCL_HALF_PERIOD - 1) begin
                        clk_count <= 0;
                        state <= STOP_COND;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STOP_COND: begin
                    if (clk_count == SCL_PERIOD - 1) begin
                        busy  <= 1'b0; // Transaction finished
                        state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
            endcase
        end
    end

    // Combinational logic for driving I2C pins based on state
    always_comb begin
        // Default values for pins
        sda_out = 1'b1;
        sda_en  = 1'b1; // By default, we drive SDA
        SCL     = 1'b1;

        case (state)
            IDLE: begin
                // SDA and SCL remain high (pulled up)
            end

            START_COND: begin
                // SCL is high. SDA goes from high to low.
                sda_out = 1'b0;
            end

            SHIFT_BITS: begin
                // SCL is low for the first half, high for the second
                SCL     = (clk_count >= SCL_HALF_PERIOD);
                sda_out = shift_reg[15 - bit_cnt];
            end

            WAIT_ACK: begin
                // SCL toggles. Release SDA for slave to drive ACK.
                SCL    = (clk_count >= SCL_HALF_PERIOD);
                sda_en = 1'b0; // Let slave drive SDA
            end

            STOP_SETUP: begin
                // Drive SDA and SCL low to prepare for STOP
                sda_out = 1'b0;
                SCL     = 1'b0;
            end

            STOP_COND: begin
                // SCL is held high, while SDA transitions low-to-high
                SCL     = 1'b1;
                sda_out = (clk_count >= SCL_HALF_PERIOD);
            end
        endcase
    end

    // I2C pin drivers
    assign SDA = sda_en ? sda_out : 1'bz;

endmodule
