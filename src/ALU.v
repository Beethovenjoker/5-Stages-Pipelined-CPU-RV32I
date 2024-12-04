// opcode 
`define R_type  5'b01100
`define I_load  5'b00000
`define I_arth  5'b00100
`define JALR    5'b11001
`define I_type_without_JALR  `I_load, `I_arth
`define LUI     5'b01101
`define AUIPC   5'b00101
`define U_type  `LUI, `AUIPC
`define J_type  5'b11011
`define B_type  5'b11000
`define S_type  5'b01000

// func3  arthimetic
`define ADD_SUB 3'b000
`define SLL     3'b001
`define SLT     3'b010
`define SLTU    3'b011
`define XOR     3'b100
`define SRL_SRA 3'b101
`define OR      3'b110
`define AND     3'b111

// func3  branch
`define BEQ     3'b000
`define BNE     3'b001
`define BLT     3'b100
`define BGE     3'b101
`define BLTU    3'b110
`define BGEU    3'b111

module ALU(
    input [4:0] opcode,
    input [2:0] func3,
    input       func7,
    input [31:0] operand1,
    input [31:0] operand2,
    output reg [31:0] alu_out
);
    always @(*) begin
        case(opcode)
            `R_type, `I_arth: begin
                case (func3)
                    `ADD_SUB:   begin
                        if(opcode == `R_type)begin
                            alu_out <= (~func7) ? (operand1 + operand2) : (operand1 - operand2);
                        end
                        else if(opcode == `I_arth)begin
                            alu_out <= operand1 + operand2;
                        end
                        else begin
                            alu_out <= 32'bx;
                        end
                    end
                    `SLL:       alu_out <= operand1 << operand2[4:0];
                    `SLT:       alu_out <= {{31{1'b0}}, ($signed(operand1) < $signed(operand2))};
                    `SLTU:      alu_out <= {{31{1'b0}}, (operand1 < operand2)};
                    `XOR:       alu_out <= operand1 ^ operand2;
                    `SRL_SRA:   alu_out <= (~func7) ? ($signed(operand1) >> operand2[4:0]) : ($signed(operand1) >>> operand2[4:0]);
                    `OR:        alu_out <= operand1 | operand2;
                    `AND:       alu_out <= operand1 & operand2;
                    default:    alu_out <= 32'bx;
                endcase
            end
            `LUI:               alu_out <= operand2;
            `AUIPC:             alu_out <= operand1 + operand2;
            `I_load, `S_type:   alu_out <= operand1 + operand2;
            `J_type, `JALR:     alu_out <= operand1 + 4;
            `B_type: begin
                alu_out[31:1] <= 31'b0;
                case(func3)
                    `BEQ:       alu_out[0] <= (operand1 === operand2);
                    `BNE:       alu_out[0] <= (operand1 !== operand2);
                    `BLT:       alu_out[0] <= ($signed(operand1) < $signed(operand2));
                    `BGE:       alu_out[0] <= ($signed(operand1) >= $signed(operand2));
                    `BLTU:      alu_out[0] <= (operand1 < operand2);
                    `BGEU:      alu_out[0] <= (operand1 >= operand2);
                    default:    alu_out[0] <= 1'bx;
                endcase
            end
            default:            alu_out <= 32'bx;
        endcase
    end
endmodule