`define lb  3'b000
`define lh  3'b001
`define lw  3'b010
`define lbu 3'b100
`define lhu 3'b101

module LD_Filter(
    input [2:0] func3,
    input [31:0] ld_data,
    output reg [31:0] ld_data_f
);
    always @(*)begin
        case(func3)
            `lb:        ld_data_f <= {{24{ld_data[7]}}, ld_data[7:0]};
            `lh:        ld_data_f <= {{16{ld_data[15]}}, ld_data[15:0]};
            `lw:        ld_data_f <= ld_data;
            `lbu:       ld_data_f <= {24'b0, ld_data[7:0]};
            `lhu:       ld_data_f <= {16'b0, ld_data[15:0]};
            default:    ld_data_f <= 32'bx;
        endcase
    end
endmodule