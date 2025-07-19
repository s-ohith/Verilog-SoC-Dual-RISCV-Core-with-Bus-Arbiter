module soc_top (
    input  logic        clk,
    input  logic        rst_n,

    // APB Master Interface
    input  logic [11:0] PADDR,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,

    // SPI lines
    output logic        SCLK,
    output logic        MOSI,
    input  logic        MISO,
    output logic        CS,

    // I2C lines
    output logic        SCL,
    output logic        SDA,

    // USART lines
    output logic        TXD,
    output logic        SCLK_UART
);

    // Internal signals
    logic PSEL_SPI, PSEL_I2C, PSEL_USART;
    logic [31:0] PRDATA_SPI, PRDATA_I2C, PRDATA_USART;

    // Simple address decoder
    always_comb begin
        PSEL_SPI   = 1'b0;
        PSEL_I2C   = 1'b0;
        PSEL_USART = 1'b0;

        unique case (PADDR[11:8])
            4'h0: PSEL_SPI   = 1'b1; // Address 0x0xx
            4'h1: PSEL_I2C   = 1'b1; // Address 0x1xx
            4'h2: PSEL_USART = 1'b1; // Address 0x2xx
        endcase
    end

    // Read data multiplexer
    always_comb begin
        case (1'b1)
            PSEL_SPI:   PRDATA = PRDATA_SPI;
            PSEL_I2C:   PRDATA = PRDATA_I2C;
            PSEL_USART: PRDATA = PRDATA_USART;
            default:    PRDATA = 32'hDEADBEEF; // No slave selected
        endcase
    end

    // SPI peripheral
    spi_apb_slave spi_inst (
        .clk(clk),
        .rst_n(rst_n),
        .PSEL(PSEL_SPI),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA_SPI),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .CS(CS)
    );

    // I2C peripheral
    i2c_apb_slave i2c_inst (
        .clk(clk),
        .rst_n(rst_n),
        .PSEL(PSEL_I2C),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA_I2C),
        .SDA(SDA),
        .SCL(SCL)
    );

    // USART peripheral
    usart_apb_slave usart_inst (
        .clk(clk),
        .rst_n(rst_n),
        .PSEL(PSEL_USART),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA_USART),
        .TXD(TXD),
        .SCLK(SCLK_UART)
    );

endmodule
