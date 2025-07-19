    `timescale 1ns / 1ps
    //////////////////////////////////////////////////////////////////////////////////
    // Company: 
    // Engineer: 
    // 
    // Create Date: 15.05.2025 18:19:59
    // Design Name: 
    // Module Name: imm_gen
    // Project Name: 
    // Target Devices: 
    // Tool Versions: 
    // Description: 
    // 
    // Dependencies: 
    // 
    // Revision:
    // Revision 0.01 - File Created
    // Additional Comments:
    // 
    //////////////////////////////////////////////////////////////////////////////////
    
    
    module imm_gen (
        input  [31:0] instruction,
        output reg [31:0] imm_out
    );
    
        wire [6:0] opcode = instruction[6:0];
    
        always @(*) begin
            case (opcode)
                7'b0000011, // I-type: lw
                7'b0010011: // I-type: addi, etc.
                    imm_out = {{20{instruction[31]}}, instruction[31:20]};
    
                7'b0100011: // S-type: sw
                    imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    
                7'b1100011: // B-type: beq, bne
                    imm_out = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    
                default:
                    imm_out = 32'b0; // Default zero if unsupported
            endcase
        end
    endmodule
    
