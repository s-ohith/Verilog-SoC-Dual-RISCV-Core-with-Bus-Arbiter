`timescale 1ns/1ps

module dual_core_soc_tb;

    // Testbench signals
    reg clk;
    reg reset;

    // Instantiate the entire SoC
    dual_core_soc uut (
        .clk(clk),
        .reset(reset),
        // Peripherals are left unconnected at the top level for this test.
        .spi_sclk(),
        .spi_mosi(),
        .spi_miso(1'b0), // Tie MISO low for this test
        .spi_cs(),
        .i2c_scl(),
        .i2c_sda(),
        .usart_txd(),
        .usart_sclk()
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Setup waveform dumping
        $dumpfile("dual_core_soc.vcd");
        $dumpvars(0, dual_core_soc_tb);

        // --- Load different programs into each core's internal memory ---
        // NOTE: You may need to change 'IMEM' to the actual instance
        // name of the instruction memory inside your core designs.

        // Core 1 Program: Write data 0xAA to SPI peripheral (Address 0x000)
        // 1. addi x5, x0, 0        // Load address 0 into x5 (rs1)
        // 2. addi x6, x0, 0xAA    // Load data 0xAA into x6
        // 3. add x7, x0, x6       // ALU result becomes 0xAA
        // 4. beq x0, x0, -4       // Loop forever
        $display("Loading program into Core 1...");
        uut.uut_core1.IMEM.mem[0] = 32'h00000293; // addi x5, x0, 0
        uut.uut_core1.IMEM.mem[1] = 32'h0AA00313; // addi x6, x0, 0xAA
        uut.uut_core1.IMEM.mem[2] = 32'h006003b3; // add x7, x0, x6
        uut.uut_core1.IMEM.mem[3] = 32'hfe000ee3; // beq x0, x0, -4

        // Core 2 Program: Write data 0xBB to USART peripheral (Address 0x200)
        // 1. addi x5, x0, 512     // Load address 0x200 into x5 (rs1)
        // 2. addi x6, x0, 0xBB    // Load data 0xBB into x6
        // 3. add x7, x0, x6       // ALU result becomes 0xBB
        // 4. beq x0, x0, -4       // Loop forever
        $display("Loading program into Core 2...");
        uut.uut_core2.IMEM.mem[0] = 32'h20000293; // addi x5, x0, 512
        uut.uut_core2.IMEM.mem[1] = 32'h0BB00313; // addi x6, x0, 0xBB
        uut.uut_core2.IMEM.mem[2] = 32'h006003b3; // add x7, x0, x6
        uut.uut_core2.IMEM.mem[3] = 32'hfe000ee3; // beq x0, x0, -4

        // Initialize signals and apply reset
        clk = 0;
        reset = 1;
        #20;
        reset = 0;
        $display("Reset released. Running simulation...");

        // Let the simulation run to observe the transactions
        #5000;
        $display("Simulation finished.");
        $finish;
    end

    // =================================================================
    // Peripheral Monitors to verify correct operation
    // =================================================================

    // --- SPI Monitor ---
    initial begin
        logic [7:0] received_spi_byte;
        forever begin
            @(negedge uut.spi_cs);
            $display("[TB Monitor] SPI transaction started at time %0t ns.", $time);
            repeat (8) begin
                @(posedge uut.spi_sclk);
                received_spi_byte = {received_spi_byte[6:0], uut.spi_mosi};
            end
            $display("[TB Monitor] SPI byte received: 0x%0h", received_spi_byte);
            @(posedge uut.spi_cs);
        end
    end

    // --- USART Monitor ---
    initial begin
        logic [7:0] received_usart_byte;
        localparam BAUD_PERIOD = 1000; // Must match BAUD_DIV * 10ns from usart_driver
        localparam HALF_BAUD_PERIOD = BAUD_PERIOD / 2;
        forever begin
            @(negedge uut.usart_txd);
            $display("[TB Monitor] USART transmission started at time %0t ns.", $time);
            #(HALF_BAUD_PERIOD);
            for (int i = 0; i < 8; i++) begin
                received_usart_byte[i] = uut.usart_txd;
                #(BAUD_PERIOD);
            end
            $display("[TB Monitor] USART byte received: 0x%0h", received_usart_byte);
        end
    end

endmodule
