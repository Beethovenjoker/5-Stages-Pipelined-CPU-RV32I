module Reg_W(
    input clk,
    input rst,
    input [31:0] M_alu_out,
    input [31:0] M_ld_data,
    output reg [31:0] W_alu_out,
    output reg [31:0] W_ld_data
);
    //W_alu_out
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            W_alu_out <= 32'd0;
        end
        else begin
            W_alu_out <= M_alu_out;
        end
    end

    //W_ld_data
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            W_ld_data <= 32'd0;
        end
        else begin
            W_ld_data <= M_ld_data;
        end
    end
endmodule