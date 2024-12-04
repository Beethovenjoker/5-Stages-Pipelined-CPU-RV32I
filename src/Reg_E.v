`define nop 32'b00000000000000000000000000010011

module Reg_E(
    input clk,
    input rst,
    input stall,
    input jb,
    input [31:0] D_pc,
    input [31:0] D_rs1_data,
    input [31:0] D_rs2_data,
    input [31:0] D_sext_imm,
    output reg [31:0] E_pc,
    output reg [31:0] E_rs1_data,
    output reg [31:0] E_rs2_data,
    output reg [31:0] E_sext_imm
);
    //E_pc
    always @(posedge clk, posedge rst)begin
        if(rst || stall || !jb)begin
            E_pc <= 32'd0;
        end
        else begin
            E_pc <= D_pc;
        end
    end

    //E_rs1_data
    always @(posedge clk, posedge rst)begin
        if(rst || stall || !jb)begin
            E_rs1_data <= 32'd0;
        end
        else begin
            E_rs1_data <= D_rs1_data;
        end
    end

    //E_rs2_data
    always @(posedge clk, posedge rst)begin
        if(rst || stall || !jb)begin
            E_rs2_data <= 32'd0;
        end
        else begin
            E_rs2_data <= D_rs2_data;
        end
    end

    //E_sext_imm
    always @(posedge clk, posedge rst)begin
        if(rst || stall || !jb)begin
            E_sext_imm <= 32'd0;
        end
        else begin
            E_sext_imm <= D_sext_imm;
        end
    end
endmodule