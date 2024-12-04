`define R_type  5'b01100
`define I_load  5'b00000
`define I_arth  5'b00100
`define JALR    5'b11001
`define I_type  `I_load, `I_arth, `JALR
`define S_type  5'b01000
`define B_type  5'b11000
`define LUI     5'b01101
`define AUIPC   5'b00101
`define U_type  `LUI, `AUIPC
`define J_type  5'b11011


module Imm_Ext(
    input [31:0] inst,
    output reg [31:0] imm_ext_out
);
    always @(*) begin
        casex(inst[6:2])
            `R_type:    imm_ext_out <= 32'b0;
            `I_type:    imm_ext_out <= {{20{inst[31]}}, inst[31:20]};
            `S_type:    imm_ext_out <= {{20{inst[31]}}, inst[31:25], inst[11:7]};
            `B_type:    imm_ext_out <= {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            `U_type:    imm_ext_out <= {inst[31:12], 12'b0};
            `J_type:    imm_ext_out <= {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            default:    imm_ext_out <= 32'bx;
        endcase
    end
endmodule
