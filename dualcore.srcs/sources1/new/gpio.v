module gpio (
    input clk,
    input reset,
    input [31:0] addr,
    input [31:0] wdata,
    output reg [31:0] rdata,
    input write_en,
    input read_en,
    input [7:0] gpio_input,
    output reg [7:0] gpio_output,
    output reg [7:0] gpio_dir
);

    localparam ADDR_DIR   = 32'h0000_0000; // Direction Register
    localparam ADDR_OUT   = 32'h0000_0004; // Output Register
    localparam ADDR_IN    = 32'h0000_0008; // Input Register (Read Only)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            gpio_output <= 8'b0;
            gpio_dir <= 8'b0;
            rdata <= 32'b0;
        end else begin
            if (write_en) begin
                case (addr[3:0])
                    4'h0: gpio_dir   <= wdata[7:0];
                    4'h4: gpio_output <= wdata[7:0];
                    default: ;
                endcase
            end
            if (read_en) begin
                case (addr[3:0])
                    4'h0: rdata <= {24'b0, gpio_dir};
                    4'h4: rdata <= {24'b0, gpio_output};
                    4'h8: rdata <= {24'b0, gpio_input};
                    default: rdata <= 32'b0;
                endcase
            end
        end
    end

endmodule
