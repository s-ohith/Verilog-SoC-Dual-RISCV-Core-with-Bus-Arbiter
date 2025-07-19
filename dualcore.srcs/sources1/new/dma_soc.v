module dma_controller (
    input clk,
    input reset,

    // Control interface (memory-mapped from SoC)
    input        start,
    input [7:0]  length,
    input [31:0] src_base_addr,
    input [7:0]  dst_base_addr,

    // Interface with system bus (as memory master)
    output reg        dma_req,
    output            dma_we,         // Always 0 (read only)
    output reg [31:0] dma_addr,
    output [31:0]     dma_wdata,      // Not used, write disable
    input      [31:0] dma_rdata,      // Data read from system bus
    input             dma_ack,        // Acknowledge from bus

    // Internal instruction memory interface
    output reg [7:0]  internal_mem_addr,
    output reg [31:0] internal_mem_data,
    output reg        internal_mem_write,

    output reg done
);

    reg [7:0] count;
    reg active;
  
    reg first_time = 1'b1;

    assign dma_we = 0;
    assign dma_wdata = 32'b0;

  always @(posedge clk) begin
    if (first_time) begin
        active <= 0;
        dma_req <= 0;
        done <= 0;
        count <= 0;
        internal_mem_write <= 0;
        internal_mem_addr <= 0;

        first_time <= 0;  // Clear the flag so it doesn't run again
    end else begin
      
    
            if (start && !active) begin
                active <= 1;
                done <= 0;
                count <= 0;
                dma_addr <= src_base_addr;
                internal_mem_addr <= dst_base_addr;
                dma_req <= 1;
              
            end
            else if (active) begin
                if (dma_ack) begin
                    // On ack from bus, write data to internal mem
                    internal_mem_data <= dma_rdata;
                    internal_mem_write <= 1;

                    // Prepare for next transfer
                    count <= count + 1;
                    dma_addr <= dma_addr + 4;
                    internal_mem_addr <= internal_mem_addr + 1;

                    if (count + 1 >= length) begin
                        active <= 0;
                        done <= 0;
                        dma_req <= 1;
                    end
                end else begin
                    internal_mem_write <= 0;
                    dma_req <= 1;  // Keep requesting until ack is received
                end
            end else begin
                dma_req <= 0;
                internal_mem_write <= 0;
                done <= 0;
            end
        end
    end

endmodule
