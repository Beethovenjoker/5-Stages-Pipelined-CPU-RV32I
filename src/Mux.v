module Mux(
    input [31:0] input0,
    input [31:0] input1,
    input select,
    output [31:0] result
);
    assign result = select? input1 : input0;
endmodule