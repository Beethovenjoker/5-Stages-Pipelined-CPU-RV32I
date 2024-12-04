`include "./src/SRAM.v"
`include "./src/RegFile.v"
`include "./src/Adder.v"
`include "./src/ALU.v"
`include "./src/Controller.v"
`include "./src/Decoder.v"
`include "./src/Imm_Ext.v"
`include "./src/JB_Unit.v"
`include "./src/LD_Filter.v"
`include "./src/Mux.v"
`include "./src/Reg_PC.v"
`include "./src/Reg_D.v"
`include "./src/Reg_E.v"
`include "./src/Reg_M.v"
`include "./src/Reg_W.v"
`include "./src/TriMux.v"

module Top (
    input clk,
    input rst
);
    
    Controller controller(
        // input
        .clk(clk),
        .rst(rst),
        .D_opcode(decoder.dc_out_opcode),
        .D_func3(decoder.dc_out_func3),
        .D_func7(decoder.dc_out_func7),
        .D_rd_index(decoder.dc_out_rd_index),
        .D_rs1_index(decoder.dc_out_rs1_index),
        .D_rs2_index(decoder.dc_out_rs2_index),
        .E_aluOut_bit0(alu.alu_out[0]),
        // output
        .next_pc_sel(),
        .stall(),
        .F_im_w_en(),
        .D_rs1_data_sel(),
        .D_rs2_data_sel(),
        .E_rs1_data_sel(),
        .E_rs2_data_sel(),
        .E_jb_op1_sel(),
        .E_alu_op1_sel(),
        .E_alu_op2_sel(),
        .E_op(),
        .E_f3(),
        .E_f7(),
        .M_dm_w_en(),
        .W_wb_en(),
        .W_rd(),
        .W_f3(),
        .W_wb_data_sel()
    );

    Adder adder(
        // input
        .operand1(pc.current_pc),
        .operand2(32'd4),
        .cin(1'b0),
        // output
        .result(),
        .cout()
    );

    Mux next_pc_mux(
        // input
        .input0(jb.jb_out),
        .input1(adder.result),
        .select(controller.next_pc_sel),
        // output
        .result()
    );

    Reg_PC pc(
        // input
        .clk(clk),
        .rst(rst),
        .stall(controller.stall),
        .next_pc(next_pc_mux.result),
        // output
        .current_pc()
    );

    SRAM im(
        // input
        .clk(clk),
        .w_en(controller.F_im_w_en),
        .address(pc.current_pc[15:0]),
        .write_data(32'b0),
        // output
        .read_data()
    );

    Reg_D reg_D(
        // input
        .clk(clk),
        .rst(rst),
        .stall(controller.stall),
        .jb(controller.next_pc_sel),
        .F_inst(im.read_data),
        .F_pc(pc.current_pc),
        // output
        .D_pc(),
        .D_inst()
    );

    Decoder decoder(
        // input
        .inst(reg_D.D_inst),
        // output
        .dc_out_opcode(),
        .dc_out_func3(),
        .dc_out_func7(),
        .dc_out_rd_index(),
        .dc_out_rs1_index(),
        .dc_out_rs2_index()
    );

    Imm_Ext imm_ext(
        // input
        .inst(reg_D.D_inst),
        // output
        .imm_ext_out()
    );

    RegFile regfile(
        // input
        .clk(clk),
        .wb_en(controller.W_wb_en),
        .wb_data(wb.result),
        .rd_index(controller.W_rd),
        .rs1_index(decoder.dc_out_rs1_index),
        .rs2_index(decoder.dc_out_rs2_index),
        // output
        .rs1_data_out(),
        .rs2_data_out()
    );

    Mux regfile_rs1_data_mux(
        // input
        .input0(regfile.rs1_data_out),
        .input1(wb.result),
        .select(controller.D_rs1_data_sel),
        // output
        .result()
    );

    Mux regfile_rs2_data_mux(
        // input
        .input0(regfile.rs2_data_out),
        .input1(wb.result),
        .select(controller.D_rs2_data_sel),
        // output
        .result()
    );

    Reg_E reg_E(
        // input
        .clk(clk),
        .rst(rst),
        .stall(controller.stall),
        .jb(controller.next_pc_sel),
        .D_pc(reg_D.D_pc),
        .D_rs1_data(regfile_rs1_data_mux.result),
        .D_rs2_data(regfile_rs2_data_mux.result),
        .D_sext_imm(imm_ext.imm_ext_out),
        // output
        .E_pc(),
        .E_rs1_data(),
        .E_rs2_data(),
        .E_sext_imm()
    );

    TriMux forwarding_rs1_trimux(
        // input
        .input0(wb.result),
        .input1(reg_M.M_alu_out),
        .input2(reg_E.E_rs1_data),
        .select(controller.E_rs1_data_sel),
        // output
        .result()
    );

    TriMux forwarding_rs2_trimux(
        // input
        .input0(wb.result),
        .input1(reg_M.M_alu_out),
        .input2(reg_E.E_rs2_data),
        .select(controller.E_rs2_data_sel),
        // output
        .result()
    );


    Mux alu_op1_mux(
        // input
        .input0(forwarding_rs1_trimux.result),
        .input1(reg_E.E_pc),
        .select(controller.E_alu_op1_sel),
        // output
        .result()
    );

    Mux alu_op2_mux(
        // input
        .input0(forwarding_rs2_trimux.result),
        .input1(reg_E.E_sext_imm),
        .select(controller.E_alu_op2_sel),
        // output
        .result()
    );

    ALU alu(
        // input
        .opcode(controller.E_op),
        .func3(controller.E_f3),
        .func7(controller.E_f7),
        .operand1(alu_op1_mux.result),
        .operand2(alu_op2_mux.result),
        // output
        .alu_out()
    );

    Mux jb_op1_mux(
        // input 
        .input0(forwarding_rs1_trimux.result),
        .input1(reg_E.E_pc),
        .select(controller.E_jb_op1_sel),
        // output
        .result()
    );

    JB_Unit jb(
        // input
        .operand1(jb_op1_mux.result),
        .operand2(reg_E.E_sext_imm),
        // output
        .jb_out()
    );

    Reg_M reg_M(
        // input
        .clk(clk),
        .rst(rst),
        .E_alu_out(alu.alu_out),
        .E_rs2_data(forwarding_rs2_trimux.result),
        // output
        .M_alu_out(),
        .M_rs2_data()
    );

    SRAM dm(
        // input
        .clk(clk),
        .w_en(controller.M_dm_w_en),
        .address(reg_M.M_alu_out[15:0]),
        .write_data(reg_M.M_rs2_data),
        // output
        .read_data()
    );

    Reg_W reg_W(
        // input
        .clk(clk),
        .rst(rst),
        .M_alu_out(reg_M.M_alu_out),
        .M_ld_data(dm.read_data),
        // output
        .W_alu_out(),
        .W_ld_data()
    );  

    LD_Filter ld_filter(
        // input
        .func3(controller.W_f3),
        .ld_data(reg_W.W_ld_data),
        // output
        .ld_data_f()
    );

    Mux wb(
        // input
        .input0(reg_W.W_alu_out),
        .input1(ld_filter.ld_data_f),
        .select(controller.W_wb_data_sel),
        // output
        .result()
    );

endmodule