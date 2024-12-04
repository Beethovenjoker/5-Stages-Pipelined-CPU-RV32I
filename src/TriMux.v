module TriMux(
    input [31:0] input0,
    input [31:0] input1,
    input [31:0] input2,
    input [1:0] select,
    output [31:0] result
);
    assign result = select[1]? input2 : (select[0]? input1 : input0);
endmodule