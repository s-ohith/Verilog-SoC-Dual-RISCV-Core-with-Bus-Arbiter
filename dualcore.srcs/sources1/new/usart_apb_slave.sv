module usart_apb_slave (
    input  logic        clk,
    input  logic        rst_n,

    // APB interface
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [11:0] PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,

    // USART physical lines
    output logic        TXD,
    output logic        SCLK
);

    // Wires to driver
    logic        start_tx;
    logic [7:0]  tx_data;
    logic        parity;
    logic        busy;

    // APB Registers:
    // 0x00 - TXDATA (write)
    // 0x04 - STATUS (read)

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data  <= 8'h00;
            parity   <= 1'b0;
            start_tx <= 1'b0;
        end else begin
            start_tx <= 1'b0; // single-cycle pulse

            if (PSEL && PENABLE && PWRITE) begin
                case (PADDR[3:0])
                    4'h0: begin
                        tx_data  <= PWDATA[7:0];
                        parity   <= PWDATA[8];     // Bit 8 = parity bit
                        start_tx <= 1'b1;
                    end
                endcase
            end
        end
    end

    // Read path: 0x04 returns busy status
    always_comb begin
        PRDATA = 32'h0;
        if (PSEL && PENABLE && !PWRITE) begin
            case (PADDR[3:0])
                4'h4: PRDATA = {31'b0, busy};
                default: PRDATA = 32'hBADB_CAFE;
            endcase
        end
    end

    // Instantiate USART driver
    usart_driver usart_core (
        .clk(clk),
        .rst_n(rst_n),
        .start_tx(start_tx),
        .data(tx_data),
        .parity(parity),
        .TXD(TXD),
        .SCLK(SCLK),
        .busy(busy)
    );

endmodule
