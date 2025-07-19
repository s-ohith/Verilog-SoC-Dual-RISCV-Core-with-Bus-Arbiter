`timescale 1ns/1ps

module combined_dual_core_soc_tb;

    // Global clock and reset
    logic clk;
    logic rst_n;
    reg reset;

    // APB Master signals driven by the testbench
    logic [11:0] PADDR;
    logic        PWRITE;
    logic        PENABLE;
    logic [31:0] PWDATA;
    wire  [31:0] PRDATA;

    // Priority control for core selection
    reg core_priority_select; // 0 = Core1 has priority, 1 = Core2 has priority
    reg [2:0] cycle_counter;   // Counter to alternate priority every few cycles

    // ---------------- CORE 1 Signals ---------------- //
    wire [31:0] pc_1;
    wire [31:0] instr_1;
    wire [31:0] alu_out_1;
    wire [31:0] rd1_1;
    wire [31:0] rd2_1;
    wire [31:0] wd_1;
    wire [31:0] mem_out_1;
    wire [2:0]  alu_op_1;
    wire [3:0]  alu_ctrl_1;
    wire [4:0]  rs_1_1;
    wire [4:0]  rs_2_1;
    wire [31:0] imm_out_1;

    // ---------------- CORE 2 Signals ---------------- //
    wire [31:0] pc_2;
    wire [31:0] instr_2;
    wire [31:0] alu_out_2;
    wire [31:0] rd1_2;
    wire [31:0] rd2_2;
    wire [31:0] wd_2;
    wire [31:0] mem_out_2;
    wire [2:0]  alu_op_2;
    wire [3:0]  alu_ctrl_2;
    wire [4:0]  rs_1_2;
    wire [4:0]  rs_2_2;
    wire [31:0] imm_out_2;

    // Priority-based extracted values
    wire [31:0] selected_alu_result;
    wire [4:0]  selected_rs1;
    wire [31:0] selected_alu_result_secondary;
    wire [4:0]  selected_rs1_secondary;
    
    // Memory-mapped peripheral selection based on ALU output ranges
    wire [1:0] peripheral_select;
    wire [11:0] mapped_paddr;
    reg peripheral_transaction_active;
    
    // APB transaction control signals
    reg apb_auto_mode;
    reg [11:0] manual_paddr;
    reg [31:0] manual_pwdata;
    
    // Peripheral selection logic based on ALU output value
    // 0x00000000 - 0x10000000 (0 to 268435456) -> USART (00)
    // 0x10000001 - 0x20000000 (268435457 to 536870912) -> SPI (01) 
    // 0x20000001 - 0x30000000 (536870913 to 805306368) -> I2C (10)
    // Above 0x30000000 -> Default to USART (00)
    assign peripheral_select = (selected_alu_result <= 32'h10000000) ? 2'b00 :  // USART
                              (selected_alu_result <= 32'h20000000) ? 2'b01 :  // SPI
                              (selected_alu_result <= 32'h30000000) ? 2'b10 :  // I2C
                              2'b00;  // Default to USART

    // ---------------- Instance: CORE 1 ---------------- //
    riscv_core uut1 (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_1),
        .instruction_out(instr_1),
        .alu_result_out(alu_out_1),
        .reg_data1_out(rd1_1),
        .reg_data2_out(rd2_1),
        .write_data_out(wd_1),
        .mem_read_data_out(mem_out_1),
        .alu_op(alu_op_1),
        .alu_ctrl(alu_ctrl_1),
        .rs_1(rs_1_1),
        .rs_2(rs_2_1),
        .imm_out1(imm_out_1)
    );

    // ---------------- Instance: CORE 2 ---------------- //
    riscv2core uut2 (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_2),
        .instruction_out(instr_2),
        .alu_result_out(alu_out_2),
        .reg_data1_out(rd1_2),
        .reg_data2_out(rd2_2),
        .write_data_out(wd_2),
        .mem_read_data_out(mem_out_2),
        .alu_op(alu_op_2),
        .alu_ctrl(alu_ctrl_2),
        .rs_1(rs_1_2),
        .rs_2(rs_2_2),
        .imm_out1(imm_out_2)
    );

    // ---------------- SoC Top Instance ---------------- //
    soc_top dut (
        .clk(clk),
        .rst_n(rst_n),
        // Connect APB master signals
        .PADDR(PADDR),
        .PWRITE(PWRITE),
        .PENABLE(PENABLE),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        // Peripheral IOs
        .SCLK(),
        .MOSI(),
        .MISO(1'b0),
        .CS(),
        .SDA(),
        .SCL(),
        .TXD(),
        .SCLK_UART()
    );

    // ---------------- Priority Logic for Core Selection ---------------- //
    // Priority method: Alternate between cores every 4 cycles
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cycle_counter <= 0;
            core_priority_select <= 0;
        end else begin
            cycle_counter <= cycle_counter + 1;
            if (cycle_counter == 3'b011) begin // Every 4 cycles
                core_priority_select <= ~core_priority_select;
                cycle_counter <= 0;
            end
        end
    end

    // Priority-based multiplexing for primary selection
    assign selected_alu_result = core_priority_select ? alu_out_2 : alu_out_1;
    assign selected_rs1 = core_priority_select ? rs_1_2 : rs_1_1;

    // Secondary selection (opposite priority)
    assign selected_alu_result_secondary = core_priority_select ? alu_out_1 : alu_out_2;
    assign selected_rs1_secondary = core_priority_select ? rs_1_1 : rs_1_2;

    // ---------------- Memory-mapped Address Generation ---------------- //
    // Memory-mapped address assignment based on peripheral selection
    assign mapped_paddr = (peripheral_select == 2'b00) ? {7'b0, selected_rs1} + 12'h200 :  // USART base: 0x200
                         (peripheral_select == 2'b01) ? {7'b0, selected_rs1} + 12'h000 :  // SPI base: 0x000
                         (peripheral_select == 2'b10) ? {7'b0, selected_rs1} + 12'h100 :  // I2C base: 0x100
                         12'h200;  // Default to USART
    
    // ---------------- APB Signal Management ---------------- //
    // Multiplexer for APB signals - either auto mode or manual task control
    always @(*) begin
        if (apb_auto_mode) begin
            // Auto mode: use mapped peripheral address and ALU result
            manual_paddr = mapped_paddr;
            manual_pwdata = selected_alu_result;
        end
        // In manual mode, manual_paddr and manual_pwdata are controlled by tasks
    end

    // ---------------- Clock Generation ---------------- //
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    // Reset synchronization
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            reset <= 1'b1;
        else
            reset <= 1'b0;
    end

    // ---------------- APB Write Task ---------------- //
    task automatic apb_write(input [11:0] addr, input [31:0] data);
        begin
            // Disable auto mode for manual control
            apb_auto_mode = 1'b0;
            manual_paddr = addr;
            manual_pwdata = data;
            
            @(posedge clk);
            // Setup phase
            PADDR   <= manual_paddr;
            PWDATA  <= manual_pwdata;
            PWRITE  <= 1'b1;
            PENABLE <= 1'b0;
            @(posedge clk);
            // Enable phase
            PENABLE <= 1'b1;
            @(posedge clk);
            // End transaction - return to idle state
            PENABLE <= 1'b0;
            PWRITE  <= 1'b0;
            
            // Re-enable auto mode
            apb_auto_mode = 1'b1;
        end
    endtask

    // ---------------- APB Read Task ---------------- //
    task automatic apb_read(input [11:0] addr, output logic [31:0] read_data);
        begin
            // Disable auto mode for manual control
            apb_auto_mode = 1'b0;
            manual_paddr = addr;
            
            @(posedge clk);
            // Setup phase
            PADDR   <= manual_paddr;
            PWRITE  <= 1'b0;
            PENABLE <= 1'b0;
            @(posedge clk);
            // Enable phase
            PENABLE <= 1'b1;
            @(posedge clk);
            // Capture data and end transaction
            read_data = PRDATA;
            $display("Time: %0t ns | Read from 0x%0h = 0x%0h", $time, addr, read_data);
            PENABLE <= 1'b0;
            
            // Re-enable auto mode
            apb_auto_mode = 1'b1;
        end
    endtask

    // ---------------- Automatic Peripheral Selection Logic ---------------- //
    always @(posedge clk) begin
        if (!reset && !peripheral_transaction_active) begin
            // Execute transaction based on ALU result every 8 cycles (when cycle_counter == 0)
            if (cycle_counter == 3'b000) begin
                // Only execute if we have a valid ALU result (not zero)
                if (selected_alu_result != 32'h0) begin
                    peripheral_transaction_active <= 1'b1;
                    fork
                        execute_peripheral_transaction();
                    join_none
                end
            end
        end
        
        // Reset transaction flag after completion
        if (peripheral_transaction_active && cycle_counter == 3'b010) begin
            peripheral_transaction_active <= 1'b0;
        end
    end

    // ---------------- Automatic APB Signal Update ---------------- //
    always @(posedge clk) begin
        if (!reset && apb_auto_mode && !peripheral_transaction_active) begin
            // Update APB signals based on current priority core selection
            PADDR <= manual_paddr;
            PWDATA <= manual_pwdata;
        end
    end

    // ---------------- Core Value Extraction & Peripheral Selection Monitor ---------------- //
    always @(posedge clk) begin
        if (!reset) begin
            $display("=== CYCLE %0d ===", cycle_counter);
            $display("Priority Core: %s", core_priority_select ? "CORE2" : "CORE1");
            $display("Primary   - ALU: 0x%08h, RS1: 0x%02h", selected_alu_result, selected_rs1);
            $display("Secondary - ALU: 0x%08h, RS1: 0x%02h", selected_alu_result_secondary, selected_rs1_secondary);
            
            // Display selected peripheral based on ALU value
            case(peripheral_select)
                2'b00:begin $display("Peripheral: USART (ALU: 0x%08h <= 0x10000000) - Test Block: test_usart_peripheral()", selected_alu_result);
            test_usart_peripheral();
             end  
              2'b01:begin $display("Peripheral: SPI   (ALU: 0x%08h <= 0x20000000) - Test Block: test_spi_peripheral()", selected_alu_result);
            test_spi_peripheral();
                 end
                2'b10:begin $display("Peripheral: I2C   (ALU: 0x%08h <= 0x30000000) - Test Block: test_i2c_peripheral()", selected_alu_result);
           test_i2c_peripheral;    end
                default: $display("Peripheral: USART (Default) - Test Block: test_usart_peripheral()");
            endcase
            
            $display("Mapped PADDR: 0x%03h, PWDATA: 0x%08h", manual_paddr, manual_pwdata);
            
            // Show transaction status
            if (peripheral_transaction_active) begin
                $display("STATUS: Peripheral transaction in progress...");
            end else if (selected_alu_result == 32'h0) begin
                $display("STATUS: Waiting for valid ALU result (current: 0x%08h)", selected_alu_result);
            end else begin
                $display("STATUS: Ready for next transaction");
            end
            
            $display("----------------------------------------");
        end
    end

    // ---------------- Main Simulation Flow ---------------- //
    initial begin        
        // Initialize all APB signals to idle state
        PADDR   <= '0;
        PWRITE  <= 1'b0;
        PENABLE <= 1'b0;
        PWDATA  <= '0;
        peripheral_transaction_active <= 1'b0;
        apb_auto_mode <= 1'b1;
        manual_paddr <= '0;
        manual_pwdata <= '0;

        // Assert reset
        rst_n = 1'b0;
        repeat(5) @(posedge clk);

        // De-assert reset and wait
        rst_n = 1'b1;
        @(posedge clk);

        $display("\n[INFO] Memory-Mapped Dual-Core SoC Testbench Started");
        $display("[INFO] Memory Map & Test Blocks:");
        $display("[INFO]   0x00000000 - 0x10000000 -> USART (Base: 0x200) -> test_usart_peripheral()");
        $display("[INFO]   0x10000001 - 0x20000000 -> SPI   (Base: 0x000) -> test_spi_peripheral()");
        $display("[INFO]   0x20000001 - 0x30000000 -> I2C   (Base: 0x100) -> test_i2c_peripheral()");
        $display("[INFO]   Above 0x30000000        -> USART (Default)    -> test_usart_peripheral()");
        $display("[INFO] Core priority alternates every 4 cycles");
        $display("[INFO] Automatic peripheral test blocks execute based on ALU output ranges");
        $display("[INFO] Each peripheral has dedicated test sequences with proper polling");
        $display("[INFO] Test blocks will only execute when ALU result is non-zero");

        // Let the system run and automatically execute transactions
        // The peripheral selection and transactions happen automatically
        // based on the ALU output values from the priority-selected core
        repeat(200) @(posedge clk);

        $display("\n\n[SIMULATION COMPLETE]");
        $display("[INFO] Memory-mapped peripheral selection demonstrated");
        $display("[INFO] Automatic transactions executed based on ALU output ranges");
        $display("[INFO] Core priority switching and value extraction completed");
        $finish;
    end

    // ---------------- Peripheral Transaction Tasks ---------------- //
    
    // I2C Peripheral Test Block
    task automatic test_i2c_peripheral();
        begin
            logic [31:0] rdata;
            bit transaction_complete;
            
            $display("\n[TEST] Starting I2C Transaction - ALU: 0x%08h", selected_alu_result);
            transaction_complete = 0;
            
            // Start I2C write with ALU result as data
            apb_write(12'h100, {16'b0, 1'b0, 7'h2A, selected_alu_result[7:0]});
            
            $display("\n[TEST] Polling I2C busy flag...");
            for (int i = 0; i < 40; i++) begin
                apb_read(12'h104, rdata); // Read I2C status register
                if (rdata[0] == 1'b0) begin
                    $display("Time: %0t ns | I2C Transaction Complete!", $time);
                    transaction_complete = 1;
                    break;
                end
                repeat(100) @(posedge clk);
            end
            if (!transaction_complete) $display("[WARNING] I2C transaction did not complete in time.");
        end
    endtask
    
    // SPI Peripheral Test Block
    task automatic test_spi_peripheral();
        begin
            logic [31:0] rdata;
            bit transaction_complete;
            
            $display("\n[TEST] Starting SPI Transaction - ALU: 0x%08h", selected_alu_result);
            transaction_complete = 0;
            
            // Write ALU result to SPI TX register
            apb_write(12'h000, selected_alu_result);
            
            $display("\n[TEST] Polling SPI done flag...");
            for (int i = 0; i < 20; i++) begin
                apb_read(12'h004, rdata); // Read SPI status register
                if (rdata[0] == 1'b1) begin // Check 'done' bit
                    $display("Time: %0t ns | SPI Transaction Complete!", $time);
                    transaction_complete = 1;
                    break;
                end
                repeat(10) @(posedge clk);
            end
            if (!transaction_complete) $display("[WARNING] SPI transaction did not complete in time.");
            apb_read(12'h008, rdata); // Read SPI RX data
        end
    endtask
    
    // USART Peripheral Test Block
    task automatic test_usart_peripheral();
        begin
            logic [31:0] rdata;
            bit transaction_complete;
            
            $display("\n[TEST] Starting USART Transaction - ALU: 0x%08h", selected_alu_result);
            transaction_complete = 0;
            
            // Write ALU result to USART TX register with parity=1
            apb_write(12'h200, {selected_alu_result[30:0], 1'b1});
            
            $display("\n[TEST] Polling USART busy flag...");
            for (int i = 0; i < 20; i++) begin
                apb_read(12'h204, rdata); // Read USART status register
                if (rdata[0] == 1'b0) begin
                    $display("Time: %0t ns | USART Transaction Complete!", $time);
                    transaction_complete = 1;
                    break;
                end
                repeat(20) @(posedge clk);
            end
            if (!transaction_complete) $display("[WARNING] USART transaction did not complete in time.");
        end
    endtask
    
    // Main Peripheral Transaction Router
    task automatic execute_peripheral_transaction();
        begin
            case(peripheral_select)
                2'b00: test_usart_peripheral();  // USART (0x00000000 - 0x10000000)
                2'b01: test_spi_peripheral();    // SPI   (0x10000001 - 0x20000000)
                2'b10: test_i2c_peripheral();    // I2C   (0x20000001 - 0x30000000)
                default: begin
                    $display("[ERROR] Invalid peripheral selection");
                    test_usart_peripheral(); // Default to USART
                end
            endcase
        end
    endtask

endmodule