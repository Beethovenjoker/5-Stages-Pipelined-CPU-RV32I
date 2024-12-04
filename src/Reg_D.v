`define nop 32'b00000000000000000000000000010011
module Reg_D(
    input clk,
    input rst,
    input stall,
    input jb,
    input [31:0] F_inst,
    input [31:0] F_pc,
    output reg [31:0] D_pc,
    output reg [31:0] D_inst
);
    //D_pc
    always @(posedge clk, posedge rst)begin
        if(rst || !jb)begin
            D_pc <= 32'd0;
        end
        else if(stall) begin
            D_pc <= D_pc;
        end
        else begin
            D_pc <= F_pc;
        end
    end

    //D_inst
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            D_inst <= 32'd0;
        end
        else if(stall)begin
            D_inst <= D_inst;
        end
        else if(!jb)begin
            D_inst <= `nop;
        end
        else begin
            D_inst <= F_inst;
        end
    end

endmodule