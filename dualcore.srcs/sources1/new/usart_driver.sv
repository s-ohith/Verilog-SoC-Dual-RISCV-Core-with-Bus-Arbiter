module usart_driver (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start_tx,  
    input  logic [7:0]   data,
    input  logic         parity,
    output logic         TXD,
    output logic         SCLK,
    output logic         busy
);

    typedef struct packed {
        logic [7:0] data;
        logic       parity;
    } usart_transaction;

    typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP} state_t;
    state_t state;

    logic [3:0] bit_idx;
    logic [7:0] shift_reg;
    logic       parity_bit;

    int SCLK_HALF = 10;  // Time units to simulate baud rate

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            TXD       <= 1'b1;
            SCLK      <= 0;
            busy      <= 0;
            state     <= IDLE;
            bit_idx   <= 0;
        end else begin
            case (state)
                IDLE: if (start_tx) begin
                    shift_reg   <= data;
                    parity_bit  <= parity;
                    state       <= START;
                    TXD         <= 1'b0;
                    busy        <= 1;
                    SCLK        <= 0;
                end

                START: begin
                    #(SCLK_HALF) SCLK = 1;
                    #(SCLK_HALF) SCLK = 0;
                    state <= DATA;
                    bit_idx <= 0;
                end

                DATA: begin
                    TXD <= shift_reg[bit_idx];
                    #(SCLK_HALF) SCLK = 1;
                    #(SCLK_HALF) SCLK = 0;
                    if (bit_idx == 7)
                        state <= PARITY;
                    else
                        bit_idx++;
                end

                PARITY: begin
                    TXD <= parity_bit;
                    #(SCLK_HALF) SCLK = 1;
                    #(SCLK_HALF) SCLK = 0;
                    state <= STOP;
                end

                STOP: begin
                    TXD <= 1'b1;
                    #(SCLK_HALF) SCLK = 1;
                    #(SCLK_HALF) SCLK = 0;
                    state <= IDLE;
                    busy  <= 0;
                end
            endcase
        end
    end
endmodule
