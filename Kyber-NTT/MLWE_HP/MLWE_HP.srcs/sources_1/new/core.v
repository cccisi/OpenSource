`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/03 10:51:43
// Design Name: 
// Module Name: core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "params.vh"
module core(
    input clk,
    input [3:0] sel_nxt,
    input [12:0] data_i,
    input [25:0] ram_data_s,
    input [25:0] ram_data_a,
    input [12:0] ram_data_e,
    output [7:0] addr_sa, //set delay in "fsm" module
    output [7:0] addr_sb,
    output [8:0] addr_ab,
    output [8:0] addr_eb,
    output reg [25:0] ram_data_o,
    output done,
    output wea_s         //set delay in "fsm" module
    );
    
    localparam  //core_sel[2:1]
                CORE_PWM        =   2'b00,
                CORE_NTT        =   2'b01,
                CORE_PV_MADD    =   2'b10,
                CORE_POLY       =   2'b11;
    
    // sel signal -> opcode
    wire [3:0] sel;
    wire [2:0] core_sel;
    wire bf_sel;
    wire [1:0] dsp_sel;
    
    // ROM psi signal
    wire [8:0] addr_rom;
    wire [`WIDTH-1:0] psi;
        
    // PE
    wire [`WIDTH-1:0] i_bf_a;
    wire [`WIDTH-1:0] i_bf_b;
    wire [`WIDTH-1:0] i_bf_c;
    wire [`WIDTH-1:0] i_bf_d;
    wire [`WIDTH-1:0] o_bf_u;
    wire [`WIDTH-1:0] o_bf_v;
    
    // buffer reg
    reg [`WIDTH-1:0] i_bf_b_reg;
    reg [`WIDTH-1:0] i_bf_c_reg;
    reg [`WIDTH-1:0] H_i_reg;
    reg [`WIDTH-1:0] L_i_reg;
    reg [`WIDTH-1:0] H_o_reg;
    reg [`WIDTH-1:0] L_o_reg;
    
    // mux wire
    reg [12:0] H_i_mux;
    reg [12:0] L_i_mux;
    reg [12:0] H_o_mux;
    reg [12:0] L_o_mux; 
    reg [12:0] i_bf_b_mux; 
    
    // core_sel delay
    reg [2:0] core_sel_delay1;
    reg [2:0] core_sel_delay2;
    reg [2:0] core_sel_delay3;
    reg [2:0] core_sel_delay4;
    reg [2:0] core_sel_delay5;
    reg [2:0] core_sel_delay6;
    reg [2:0] core_sel_delay7;
    reg [2:0] core_sel_delay8;
    reg [2:0] core_sel_delay9;
    // bf_sel delay
    reg bf_sel_delay1;
    reg bf_sel_delay2;
    reg bf_sel_delay3;
    reg bf_sel_delay4;
    reg bf_sel_delay5;
    reg bf_sel_delay6;
    reg bf_sel_delay7_0;
    reg bf_sel_delay7_1;
    // dsp_sel delay
    reg [1:0] dsp_sel_delay1;
    
    // 连接PE
    assign i_bf_a = L_i_mux;
    assign i_bf_b = i_bf_b_reg;
    assign i_bf_c = i_bf_c_reg;
    assign i_bf_d = H_i_reg;
    
    // 关键部分 - 组合选通
    // core_sel for H_i_mux,i_bf_b_mux
    always@(*) begin
        case(core_sel[2:1])
        CORE_PWM:begin
            H_i_mux = core_sel[0]? L_i_reg:ram_data_s[25:13];
            i_bf_b_mux = core_sel[0]? ram_data_a[12:0]:ram_data_a[25:13];
        end
        CORE_NTT:begin
            H_i_mux = core_sel[0]? L_i_reg:ram_data_s[25:13];
            i_bf_b_mux = psi;
        end
        CORE_PV_MADD:begin
            H_i_mux = core_sel[0]? L_i_reg:ram_data_s[25:13];
            i_bf_b_mux = 13'd7651;
        end
        CORE_POLY:begin
            H_i_mux = data_i;
            i_bf_b_mux = 13'd7651;
        end
        default begin
            H_i_mux = ram_data_s[25:13];  
            i_bf_b_mux = 13'd7651;
        end
        endcase
    end
    
    // core_sel_delay1 for L_i_mux
    always@(*) begin
        case(core_sel_delay1[2:1])
        CORE_PWM:begin
            L_i_mux = H_i_reg;
        end
        CORE_NTT:begin
            L_i_mux = core_sel_delay1[0]? L_i_reg:ram_data_s[25:13];
        end
        CORE_PV_MADD:begin
            L_i_mux = H_i_reg;
        end
        CORE_POLY:begin
            L_i_mux = L_i_reg;
        end
        default begin
            L_i_mux = L_i_reg;
        end
        endcase
    end
    
    // core_sel_delay8 for H_o_mux
    always@(*) begin
        case(core_sel_delay8[2:1])
//        CORE_PM_PWM:begin
//            H_o_mux = L_o_reg;
//        end
        CORE_NTT:begin
            H_o_mux = core_sel_delay8[0]? L_o_reg:o_bf_u;
        end
//        CORE_PV_PWM:begin
//        end
//        CORE_PV_MADD:begin
//            H_o_mux = L_o_reg;
//        end
        CORE_POLY:begin
            H_o_mux = o_bf_u;
        end
        default begin
            H_o_mux = L_o_reg;
        end
        endcase
    end
    
    // core_sel_delay9 for L_o_mux
    always@(*) begin
        case(core_sel_delay9[2:1])
        CORE_PWM:begin
            L_o_mux = core_sel_delay9[0]? L_o_reg:o_bf_v;
        end
        CORE_NTT:begin
            L_o_mux = core_sel_delay9[0]? L_o_reg:o_bf_u;
        end
//        CORE_PV_PWM:begin
//            L_o_mux = L_o_reg;
//        end
//        CORE_PV_MADD:begin
//            L_o_mux = L_o_reg;
//        end
//        CORE_POLY:begin
//            L_o_mux = L_o_reg;
//        end
        default begin   
            L_o_mux = L_o_reg;
        end
        endcase
    end
    
    // 关键部分 - 时序
    always @(posedge clk) begin
        // output
        ram_data_o <= {H_o_reg,L_o_mux};
    
        H_i_reg <= H_i_mux;
        L_i_reg <= ram_data_s[12:0];
        H_o_reg <= H_o_mux;
        L_o_reg <= o_bf_v;
        i_bf_b_reg <= i_bf_b_mux;
        i_bf_c_reg <= ram_data_e;
        // sel delay
        core_sel_delay1 <= core_sel;
        core_sel_delay2 <= core_sel_delay1;
        core_sel_delay3 <= core_sel_delay2;
        core_sel_delay4 <= core_sel_delay3;
        core_sel_delay5 <= core_sel_delay4;
        core_sel_delay6 <= core_sel_delay5;
        core_sel_delay7 <= core_sel_delay6;
        core_sel_delay8 <= core_sel_delay7;
        core_sel_delay9 <= core_sel_delay8;
        
        bf_sel_delay1 <= bf_sel;
        bf_sel_delay2 <= bf_sel_delay1;
        bf_sel_delay3 <= bf_sel_delay2;
        bf_sel_delay4 <= bf_sel_delay3;
        bf_sel_delay5 <= bf_sel_delay4;
        bf_sel_delay6 <= bf_sel_delay5;
        bf_sel_delay7_0 <= bf_sel_delay6;
        bf_sel_delay7_1 <= bf_sel_delay6; //duplicate to reduce finout
        
        dsp_sel_delay1 <= dsp_sel;
    end
    
    fsm fsm(
    .clk(clk),
    .sel_nxt(sel_nxt),
    .sel(sel),
    .addr_sa(addr_sa),
    .addr_sb(addr_sb),
    .addr_ab(addr_ab),
    .addr_eb(addr_eb),
    .addr_rom(addr_rom),
    .done(done),
    .wea_s(wea_s)
    );

    opcode opcode(
        .clk(clk),
        .sel(sel),
        .core_sel(core_sel),
        .bf_sel(bf_sel),
        .dsp_sel(dsp_sel)
    );

    ROM_psi rom(
        .clka(clk),
        .addra(addr_rom),
        .douta(psi)
    );
            
    butterfly PE(
        .clk(clk),
        .bf_sel_0(bf_sel_delay7_0),
        .bf_sel_1(bf_sel_delay7_1),
        .dsp_sel(dsp_sel_delay1),
        .i_bf_a(i_bf_a),
        .i_bf_b(i_bf_b),
        .i_bf_c(i_bf_c),
        .i_bf_d(i_bf_d),
        .o_bf_u(o_bf_u),
        .o_bf_v(o_bf_v)
    );  
    
endmodule