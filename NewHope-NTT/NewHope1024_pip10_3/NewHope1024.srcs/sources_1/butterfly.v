`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/02/14 11:19:50
// Design Name: 
// Module Name: Butterfly
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: conditional comp level
//              1.NH/qTESLA
//              2.Arch OFFICIAL/
//              3.Attribute Area / BALANCE PERFERMANCE
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`include "params.vh"

module butterfly(
    input clk,
    input sel,
    input [`WIDTH+1:0] i_u_wire,
    input [`WIDTH+1:0] i_v_wire,
    input [`WIDTH-1:0] psi_omega,
    output reg [`WIDTH+1:0] o_u_reg,
    output reg [`WIDTH+1:0] o_v_reg
    );
    
    // I/O port
    reg [`WIDTH+1:0] i_u_reg;
    reg [`WIDTH+1:0] i_v_reg;
    reg [`WIDTH-1:0] omega_reg;
    wire [`WIDTH+1:0] o_u_wire;
    wire [`WIDTH+1:0] o_v_wire;
        
    wire [`WIDTH+1:0] kred2x_o;
    
    always @(posedge clk) begin
        i_u_reg <= i_u_wire;
        i_v_reg <= i_v_wire;
        o_u_reg <= o_u_wire;
        o_v_reg <= sel? kred2x_o:o_v_wire;
        omega_reg <= psi_omega;
    end

`ifdef AREA
    
    wire dsp_o_11;
    reg [`WIDTH+1:0] o_kred_reg; 
    wire [`WIDTH:0] add_mux_o;
    wire [`WIDTH+1:0] sub_mux_o;
    wire [29:0] dsp_o;
    
    // K-RED
    wire [12:0] i_u_12L1;
    wire [`WIDTH+1:0] o_kred;
    assign i_u_12L1 = {i_u_reg[11:0],1'b0};
    assign o_kred = i_u_12L1 + i_u_reg[11:0] - i_u_reg[15:12];
    
    //addition path
    assign dsp_o_11 = dsp_o[11];
    assign add_mux_o = dsp_o_11? 1'b0 : `Q<<1;
    assign o_u_wire = o_kred_reg + kred2x_o + add_mux_o;
    always @(posedge clk) begin
        o_kred_reg <= o_kred;
    end
    
    //subtraction path
     assign sub_mux_o = dsp_o_11? `Q<<2 : `Q<<1;
     assign o_v_wire = o_kred_reg - kred2x_o + sub_mux_o;
     dsp_kred_pip1 sub_mul(
        .CLK(clk),
        .A({1'b0,i_v_reg}),
        .B({1'b0,omega_reg}),
        .P(dsp_o)
    );
    
    KRED2x my_kred2x(
        .clk(clk),
        .i_data(dsp_o),
        .o_data(kred2x_o)
        );
    
`elsif BALANCE

    wire dsp_o_11;
    reg dsp_o_11_delay;
    reg [`WIDTH+1:0] o_kred_reg; 
    reg [`WIDTH+1:0] o_kred_reg_delay2; 
    reg [`WIDTH+1:0] o_kred_reg_delay3; 
    wire [`WIDTH:0] add_mux_o;
    reg [`WIDTH:0] add_mux_o_delay;
    wire [`WIDTH+1:0] sub_mux_o;
    reg [`WIDTH+1:0] sub_mux_o_delay;
    wire [29:0] dsp_o;;
    
    // K-RED
    wire [12:0] i_u_12L1;
    wire [`WIDTH+1:0] o_kred;
    assign i_u_12L1 = {i_u_reg[11:0],1'b0};
    assign o_kred = i_u_12L1 + i_u_reg[11:0] - i_u_reg[15:12];
    
    //addition path
    assign dsp_o_11 = dsp_o[11];
    assign add_mux_o = dsp_o_11_delay? 1'b0 : `Q<<1;
    assign o_u_wire = o_kred_reg + kred2x_o + add_mux_o_delay;
    always @(posedge clk) begin
        o_kred_reg_delay3 <= o_kred;
        o_kred_reg_delay2 <= o_kred_reg_delay3;
        o_kred_reg <= o_kred_reg_delay2;
        add_mux_o_delay <= add_mux_o;
    end
    
    //subtraction path
    always @(posedge clk) begin
        dsp_o_11_delay <= dsp_o_11;
        sub_mux_o_delay <= sub_mux_o;
    end
    
     assign sub_mux_o = dsp_o_11_delay? `Q<<2 : `Q<<1;
     assign o_v_wire = o_kred_reg - kred2x_o + sub_mux_o_delay;
     dsp_kred_pip1 sub_mul(
        .CLK(clk),
        .A({1'b0,i_v_reg}),
        .B({1'b0,omega_reg}),
        .P(dsp_o)
    );
    
    KRED2x my_kred2x(
        .clk(clk),
        .i_data(dsp_o),
        .o_data(kred2x_o)
        );
        
`else //PERFORMANCE

    wire dsp_o_11;
    reg dsp_o_11_delay;
    reg [`WIDTH+1:0] o_kred_reg; 
    reg [`WIDTH+1:0] o_kred_reg_delay2; 
    reg [`WIDTH+1:0] o_kred_reg_delay3; 
    reg [`WIDTH+1:0] o_kred_reg_delay4; 
    reg [`WIDTH+1:0] o_kred_reg_delay5; 
    reg [`WIDTH+1:0] o_kred_reg_delay6; 
    wire [`WIDTH:0] add_mux_o;
    reg [`WIDTH:0] add_mux_o_delay;
    wire [`WIDTH+1:0] sub_mux_o;
    reg [`WIDTH+1:0] sub_mux_o_delay;
    wire [29:0] dsp_o;
    reg [29:0] dsp_o_delay;
    
    // K-RED
    wire [12:0] i_u_12L1;
    wire [`WIDTH+1:0] o_kred;
    assign i_u_12L1 = {i_u_reg[11:0],1'b0};
    assign o_kred = i_u_12L1 + i_u_reg[11:0] - i_u_reg[15:12];
    
    //addition path
    assign dsp_o_11 = dsp_o_delay[11];
    assign add_mux_o = dsp_o_11_delay? 1'b0 : `Q<<1;
    assign o_u_wire = o_kred_reg + kred2x_o + add_mux_o_delay;
    always @(posedge clk) begin
        o_kred_reg_delay6 <= o_kred;
        o_kred_reg_delay5 <= o_kred_reg_delay6;
        o_kred_reg_delay4 <= o_kred_reg_delay5;
        o_kred_reg_delay3 <= o_kred_reg_delay4;
        o_kred_reg_delay2 <= o_kred_reg_delay3;
        o_kred_reg <= o_kred_reg_delay2;
        add_mux_o_delay <= add_mux_o;
    end
    
    //subtraction path
    always @(posedge clk) begin
        dsp_o_delay <= dsp_o;
        dsp_o_11_delay <= dsp_o_11;
        sub_mux_o_delay <= sub_mux_o;
    end
    
     assign sub_mux_o = dsp_o_11_delay? `Q<<2 : `Q<<1;
     assign o_v_wire = o_kred_reg - kred2x_o + sub_mux_o_delay;
     dsp_kred_pip3 sub_mul(
        .CLK(clk),
        .A({1'b0,i_v_reg}),
        .B({1'b0,omega_reg}),
        .P(dsp_o)
    );
    
    KRED2x my_kred2x(
        .clk(clk),
        .i_data(dsp_o_delay),
        .o_data(kred2x_o)
        );
        
`endif //AREA PERFORMANCE for KRED3I

endmodule