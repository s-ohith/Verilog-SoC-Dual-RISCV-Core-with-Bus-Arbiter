module i2c_apb_slave (
    input  logic        clk,
    input  logic        rst_n,

    // APB interface
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [11:0] PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,

    // I2C physical
    output logic        SDA,
    output logic        SCL
);

    // Signals to i2c_driver
    logic       start_tx;
    logic [6:0] addr;
    logic       rw;
    logic [7:0] data;
    logic       busy;

    // Write logic
    // A write to the control/data register at address 0x0 starts a transaction.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr     <= 7'h0;
            rw       <= 1'b0;
            data     <= 8'h0;
            start_tx <= 1'b0;
        end else begin
            start_tx <= 1'b0; // start_tx is a one-cycle pulse

            if (PSEL && PENABLE && PWRITE) begin
                // Check for write to the control/data register at address 0x0
                if (PADDR[3:0] == 4'h0) begin
                    addr     <= PWDATA[14:8];
                    rw       <= PWDATA[15];
                    data     <= PWDATA[7:0];
                    start_tx <= 1'b1; // Kick off the I2C transaction
                end
            end
        end
    end

    // Read logic
    // This is combinational as required by APB for zero-wait-state reads.
    // The logic is fully specified to avoid latches or Z outputs.
    always_comb begin
        // Default PRDATA for when this slave is not being read.
        // The top-level mux will ignore this when PSEL is low.
        PRDATA = 32'h0;
        if (PSEL && !PWRITE) begin
            // The master is reading from us. Provide data based on address.
            case (PADDR[3:0])
                // Register 0x4: Status Register
                // Bit 0: busy flag
                4'h4: PRDATA = {31'b0, busy};
                // Add other readable registers here if any
                default: PRDATA = 32'hDEADFACE; // Read from invalid address
            endcase
        end
    end

    // Instantiate I2C Driver
    i2c_driver i2c_core (
        .clk(clk),
        .rst_n(rst_n),
        .start_tx(start_tx),
        .addr(addr),
        .rw(rw),
        .data(data),
        .SDA(SDA),
        .SCL(SCL),
        .busy(busy)
    );

endmodule
