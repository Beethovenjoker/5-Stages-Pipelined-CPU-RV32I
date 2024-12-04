`define LUI      5'b01101
`define AUIPC    5'b00101
//`define U_type   (`is_LUI || `is_AUIPC)
`define J_type   5'b11011
`define B_type   5'b11000
`define I_load   5'b00000
`define I_arth   5'b00100
`define JALR     5'b11001
//`define I_type   (`is_I_load || `is_I_arth || `is_JALR)
`define S_type   5'b01000
`define R_type   5'b01100


module Controller(
    input               clk,
    input               rst,
    input       [4:0]   D_opcode,
    input       [2:0]   D_func3,
    input               D_func7,
    input       [4:0]   D_rd_index,
    input       [4:0]   D_rs1_index,
    input       [4:0]   D_rs2_index,
    input               E_aluOut_bit0,
    output reg          next_pc_sel,
    output              stall,
    output      [3:0]   F_im_w_en,
    output              D_rs1_data_sel,
    output              D_rs2_data_sel,
    output      [1:0]   E_rs1_data_sel,
    output      [1:0]   E_rs2_data_sel,
    output reg          E_jb_op1_sel,
    output reg          E_alu_op1_sel,
    output reg          E_alu_op2_sel,
    output reg  [4:0]   E_op,
    output reg  [2:0]   E_f3,
    output reg          E_f7,
    output reg  [3:0]   M_dm_w_en,
    output reg          W_wb_en,
    output reg  [4:0]   W_rd,
    output reg  [2:0]   W_f3,
    output reg          W_wb_data_sel
);

    reg [4:0]   E_rs1;
    reg [4:0]   E_rs2;
    reg [4:0]   E_rd;
    reg [4:0]   M_op;
    reg [2:0]   M_f3;
    reg [4:0]   M_rd;
    reg [4:0]   W_op;

    // datapath register
    // E_op
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            E_op <= 5'b0;
        end
        else if(stall || !next_pc_sel)begin
            E_op <= 5'b00100;
        end
        else begin
            E_op <= D_opcode;
        end
    end

    // E_f3
    always @(posedge clk, posedge rst)begin
        if(rst || stall || !next_pc_sel)begin
            E_f3 <= 3'b0;
        end
        else begin
            E_f3 <= D_func3;
        end
    end

    // E_rd
    always @(posedge clk, posedge rst)begin
        if(rst || stall || !next_pc_sel)begin
            E_rd <= 5'b0;
        end
        else begin
            E_rd <= D_rd_index;
        end
    end

    // E_rs1
    always @(posedge clk, posedge rst)begin
        if(rst || stall || !next_pc_sel)begin
            E_rs1 <= 5'b0;
        end
        else begin
            E_rs1 <= D_rs1_index;
        end
    end

    // E_rs2
    always @(posedge clk, posedge rst)begin
        if(rst || stall || !next_pc_sel)begin
            E_rs2 <= 5'b0;
        end
        else begin
            E_rs2 <= D_rs2_index;
        end
    end

    // E_f7
    always @(posedge clk, posedge rst)begin
        if(rst || stall || !next_pc_sel)begin
            E_f7 <= 1'b0;
        end
        else begin
            E_f7 <= D_func7;
        end
    end


    // M_op
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            M_op <= 5'b0;
        end
        else begin
            M_op <= E_op;
        end
    end

    // M_f3
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            M_f3 <= 3'b0;
        end
        else begin
            M_f3 <= E_f3;
        end
    end

    // M_rd
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            M_rd <= 5'b0;
        end
        else begin
            M_rd <= E_rd;
        end
    end

    // W_op
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            W_op <= 5'b0;
        end
        else begin
            W_op <= M_op;
        end
    end

    // W_f3
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            W_f3 <= 3'b0;
        end
        else begin
            W_f3 <= M_f3;
        end
    end

    // W_rd
    always @(posedge clk, posedge rst)begin
        if(rst)begin
            W_rd <= 5'b0;
        end
        else begin
            W_rd <= M_rd;
        end
    end

    // output logic
    assign F_im_w_en = 4'b0;

    // next_pc_sel
    always @(E_op, E_aluOut_bit0)begin
        if(E_op == `J_type || E_op == `JALR || (E_op == `B_type && E_aluOut_bit0))begin
            next_pc_sel <= 0;
        end
        else begin
            // pc == pc + 4
            next_pc_sel <= 1;
        end
    end

    // stall
    wire is_DE_overlap;
    wire is_D_rs1_E_rd_overlap;
    wire is_D_rs2_E_rd_overlap;
    wire is_D_use_rs1;
    wire is_D_use_rs2;
    assign is_D_use_rs1 = (D_opcode == `R_type || D_opcode == `I_arth || D_opcode == `I_load || D_opcode == `JALR || D_opcode == `S_type || D_opcode == `B_type);
    assign is_D_rs1_E_rd_overlap = ((is_D_use_rs1) && (D_rs1_index == E_rd) && (E_rd != 0));
    assign is_D_use_rs2 = (D_opcode == `R_type || D_opcode == `S_type || D_opcode == `B_type);
    assign is_D_rs2_E_rd_overlap = ((is_D_use_rs2) && (D_rs2_index == E_rd) && (E_rd != 0));
    assign is_DE_overlap = (is_D_rs1_E_rd_overlap || is_D_rs2_E_rd_overlap);
    assign stall = ((E_op == `I_load) && (is_DE_overlap));

    // D_rs1_data_sel
    wire is_D_rs1_W_rd_overlap;
    wire is_W_use_rd;
    assign is_W_use_rd = (W_op == `R_type || W_op == `I_arth || W_op == `I_load || W_op == `JALR || W_op == `LUI || W_op == `AUIPC || W_op == `J_type);
    assign is_D_rs1_W_rd_overlap = ((is_D_use_rs1) && (is_W_use_rd) && (D_rs1_index  == W_rd) && (W_rd != 0));
    assign D_rs1_data_sel = is_D_rs1_W_rd_overlap ? 1'd1 : 1'd0;

    // D_rs2_data_sel
    wire is_D_rs2_W_rd_overlap;
    assign is_D_rs2_W_rd_overlap = ((is_D_use_rs2) && (is_W_use_rd) && (D_rs2_index  == W_rd) && (W_rd != 0));
    assign D_rs2_data_sel = is_D_rs2_W_rd_overlap ? 1'd1 : 1'd0;

    // D_rs1_data_sel
    wire is_E_rs1_M_rd_overlap;
    wire is_E_rs1_W_rd_overlap;
    wire is_E_use_rs1;
    wire is_M_use_rd;
    assign is_E_use_rs1 = (E_op == `R_type || E_op == `I_arth || E_op == `I_load || E_op == `JALR || E_op == `S_type || E_op == `B_type);
    assign is_M_use_rd = (M_op == `R_type || M_op == `I_arth || M_op == `I_load || M_op == `JALR || M_op == `LUI || M_op == `AUIPC || M_op == `J_type);
    assign is_E_rs1_M_rd_overlap = ((is_E_use_rs1) && (is_M_use_rd) && (E_rs1 == M_rd) && (M_rd != 0));
    assign is_E_rs1_W_rd_overlap = ((is_E_use_rs1) && (is_W_use_rd) && (E_rs1 == W_rd) && (W_rd != 0));
    assign E_rs1_data_sel = is_E_rs1_M_rd_overlap ? 2'd1 : (is_E_rs1_W_rd_overlap ? 2'd0 : 2'd2);

    // D_rs2_data_sel
    wire is_E_rs2_M_rd_overlap;
    wire is_E_rs2_W_rd_overlap;
    wire is_E_use_rs2;
    assign is_E_use_rs2 = (E_op == `R_type ||  E_op == `S_type || E_op == `B_type);
    assign is_E_rs2_M_rd_overlap = ((is_E_use_rs2) && (is_M_use_rd) && (E_rs2 == M_rd) && (M_rd != 0));
    assign is_E_rs2_W_rd_overlap = ((is_E_use_rs2) && (is_W_use_rd) && (E_rs2 == W_rd) && (W_rd != 0));
    assign E_rs2_data_sel = is_E_rs2_M_rd_overlap ? 2'd1 : (is_E_rs2_W_rd_overlap ? 2'd0 : 2'd2);

    // E_jb_op1_sel
    always @(E_op)begin
        if(E_op == `JALR)begin
            // JALR
            // mux = rs1
            E_jb_op1_sel <= 0;
        end
        else begin
            // mux == pc
            E_jb_op1_sel <= 1;
        end
    end

    // E_alu_op1_sel
    always @(E_op)begin
        if(E_op == `LUI || E_op == `AUIPC || E_op == `J_type || E_op == `JALR)begin
            // U J type, JALR
            // mux = pc
            E_alu_op1_sel <= 1;
        end
        else begin
            // mux == rs1
            E_alu_op1_sel <= 0;
        end
    end

    // E_alu_op2_sel
    always @(E_op)begin
        if(E_op == `R_type || E_op == `B_type )begin
            // R B  type
            // mux == rs2
            E_alu_op2_sel <= 0;
        end
        else begin
            // mux == imme
            E_alu_op2_sel <= 1;
        end
    end

    // M_dm_w_en
    always @(M_op, M_f3)begin
        if(M_op == `S_type)begin
            M_dm_w_en[0] <= 1'b1;
            M_dm_w_en[1] <= (M_f3[0] || M_f3[1]);
            M_dm_w_en[3:2] <= {2{M_f3[1]}};
        end
        else begin
            M_dm_w_en[3:0] <= 4'b0000;
        end
    end

    // W_wb_en
    always @(W_op)begin
        if(W_op == `LUI || W_op == `AUIPC || W_op == `J_type || W_op == `I_load || W_op == `I_arth || W_op == `JALR || W_op == `R_type)begin
            // R I J U type
            // I type: I_arth, I_load, JALR
            W_wb_en <= 1'b1;
        end
        else begin
            W_wb_en <= 1'b0;
        end
    end

    // W_wb_datat_sel
    always @(W_op)begin
        if(rst)begin
            W_wb_data_sel <= 0;
        end
        else if(W_op == `I_load)begin
            // load
            // mux = ld_data_f
            W_wb_data_sel <= 1;
        end
        else begin
            // mux = alu_out
            W_wb_data_sel <= 0;
        end
    end

endmodule