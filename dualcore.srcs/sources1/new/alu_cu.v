module alu_cu (
    input  [2:0] alu_op,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] alu_ctrl
);

    always @(alu_op or funct3 or funct7) begin
        case (alu_op)
            3'b000: begin
            case (funct3)
                3'b000: alu_ctrl = 4'b0000; // ADD for lw/sw
                3'b111: alu_ctrl = 4'b0110; // LUI (if you encode LUI this way)
                endcase
                end
            3'b001: alu_ctrl = 4'b0001; // SUB (beq/bne)
            3'b010: begin // R-type
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: alu_ctrl = 4'b0000; // ADD
                    {7'b0100000, 3'b000}: alu_ctrl = 4'b0001; // SUB
                    {7'b0000000, 3'b111}: alu_ctrl = 4'b0010; // AND
                    {7'b0000000, 3'b110}: alu_ctrl = 4'b0011; // OR
                    {7'b0000000, 3'b100}: alu_ctrl = 4'b0100; // XOR
                        {7'b0000000, 3'b001}: alu_ctrl = 4'b0111; // SLL
        {7'b0000000, 3'b101}: alu_ctrl = 4'b1000; // SRL
        {7'b0100000, 3'b101}: alu_ctrl = 4'b1001; // SRA
                    default: alu_ctrl = 4'b1111;
                endcase
            end
            3'b011: begin // I-type
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000; // ADDI
                    3'b111: alu_ctrl = 4'b0010; // ANDI
                    3'b110: alu_ctrl = 4'b0011; // ORI
                    default: alu_ctrl = 4'b1111;
                endcase
            end
           3'b110: begin // LUI
    alu_ctrl = 4'b1010; // Let's define 1010 as 'LUI_PASS'
end
            
            default: alu_ctrl = 4'b1111;
        endcase
    end

endmodule
