module Reg_M(
    input clk,
    input rst,
    input [31:0] E_alu_out,
    input [31:0] E_rs2_data,
    output reg [31:0] M_alu_out,
    output reg [31:0] M_rs2_data
);
    //M_alu_out
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            M_alu_out <= 32'd0;
        end
        else begin
            M_alu_out <= E_alu_out;
        end
    end

    //M_rs2_data
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            M_rs2_data <= 32'd0;
        end
        else begin
            M_rs2_data <= E_rs2_data;
        end
    end
endmodule