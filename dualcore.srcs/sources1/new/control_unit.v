module control_unit (
    input  [6:0] opcode,
    output reg       reg_write,
    output reg       alu_src,
    output reg       mem_to_reg,
    output reg       mem_read,
    output reg       mem_write,
    output reg       branch,
    output reg [2:0] alu_op
);

    always @(*) begin
        // Default values
        reg_write   = 0;
        alu_src     = 0;
        mem_to_reg  = 0;
        mem_read    = 0;
        mem_write   = 0;
        branch      = 0;
        alu_op      = 3'b000;

        case (opcode)
            7'b0110011: begin // R-type (add, sub, and, or, etc.)
                reg_write  = 1;
                alu_src    = 0;
                alu_op     = 3'b010;
            end

            7'b0010011: begin // I-type (addi, andi, ori)
                reg_write  = 1;
                alu_src    = 1;
                alu_op     = 3'b011;
            end

            7'b0000011: begin // Load (lw)
                reg_write  = 1;
                alu_src    = 1;
                mem_to_reg = 1;
                mem_read   = 1;
                alu_op     = 3'b000;
            end

            7'b0100011: begin // Store (sw)
                alu_src    = 1;
                mem_write  = 1;
                alu_op     = 3'b000;
            end

            7'b1100011: begin // Branch (beq, bne)
                branch     = 1;
                alu_op     = 3'b001;
            end
            
               7'b0110111: begin // LUI
                reg_write  = 1;
                alu_src    = 1;
                alu_op     = 3'b110;  // or a custom code like 2'b10 if needed
            end

            default: begin
                // NOP or unrecognized instruction
                reg_write  = 0;
            end
        endcase
    end

endmodule
