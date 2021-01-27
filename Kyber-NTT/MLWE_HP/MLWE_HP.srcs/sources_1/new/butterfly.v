`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/24 23:51:16
// Design Name: 
// Module Name: butterfly
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
module butterfly(
    input clk,
    input bf_sel_0,
    input bf_sel_1,
    input [1:0] dsp_sel,
    input [`WIDTH-1:0] i_bf_a,
    input [`WIDTH-1:0] i_bf_b,
    input [`WIDTH-1:0] i_bf_c,
    input [`WIDTH-1:0] i_bf_d,
    output reg [`WIDTH-1:0] o_bf_u,
    output reg [`WIDTH-1:0] o_bf_v 
    );
    
    //state assignment
    localparam  //bf_sel
                BF_NTT       =   1'b0,
                BF_INTT      =   1'b1,
                //dsp_sel
                DSP_MUL      =   2'b00,
                DSP_SUBM     =   2'b01,
                DSP_MACC     =   2'b10,
                DSP_MADD     =   2'b11;
    
    //delay_d
    reg [`WIDTH-1:0] i_bf_d_delay1;
    reg [`WIDTH-1:0] i_bf_d_delay2;
    reg [`WIDTH-1:0] i_bf_d_delay3;
    reg [`WIDTH-1:0] i_bf_d_delay4;
    reg [`WIDTH-1:0] i_bf_d_delay5;
    reg [`WIDTH-1:0] i_bf_d_delay6;
    
    //mux1 mux_a
    reg [`WIDTH-1:0] i_bf_a_delay1;
    reg [`WIDTH-1:0] i_bf_a_delay2;
    reg [`WIDTH-1:0] i_bf_a_delay3;
    reg [`WIDTH-1:0] i_bf_a_delay4;
    reg [`WIDTH-1:0] i_bf_a_delay5;
    reg [`WIDTH-1:0] i_bf_a_delay6;
    reg [`WIDTH-1:0] mux_a; //syn to wire
    
    //mux2 mux_v
    wire [`WIDTH-1:0] sub_o;
    wire [`WIDTH-1:0] add_o;
    reg [`WIDTH-1:0] mux_v;//syn to wire
    
    //dsp wire
    wire [`WIDTH:0] dsp_d; //14-bit net
    wire [2*`WIDTH:0] dsp_o;  //MACC max 27 bit
    
    //reduce
    wire [`WIDTH-1:0] reduce_o;
    
    assign dsp_d = (i_bf_d>=i_bf_a)? i_bf_d:i_bf_d+`Q;
    
    //mux_a
    always@(*) begin
        case(bf_sel_0)
        BF_NTT:begin
            mux_a = reduce_o;
        end
        BF_INTT:begin
            mux_a = i_bf_a_delay6;
        end
        endcase
    end
    
    //mux_v
    always@(*) begin
        case(bf_sel_1)
        BF_NTT:begin
            mux_v = sub_o;
        end
        BF_INTT:begin
            mux_v = reduce_o;
        end
        endcase
    end
    
    always@(posedge clk) begin
        i_bf_a_delay1 <= i_bf_a;
        i_bf_a_delay2 <= i_bf_a_delay1;
        i_bf_a_delay3 <= i_bf_a_delay2;
        i_bf_a_delay4 <= i_bf_a_delay3;
        i_bf_a_delay5 <= i_bf_a_delay4;
        i_bf_a_delay6 <= i_bf_a_delay5;
        
        i_bf_d_delay1 <= i_bf_d;
        i_bf_d_delay2 <= i_bf_d_delay1;
        i_bf_d_delay3 <= i_bf_d_delay2;
        i_bf_d_delay4 <= i_bf_d_delay3;
        i_bf_d_delay5 <= i_bf_d_delay4;
        i_bf_d_delay6 <= i_bf_d_delay5;
        
        //output
        o_bf_u <= add_o;
        o_bf_v <= mux_v;
    end
    
    DSP dsp(
    .CLK(clk),
    .SEL(dsp_sel),
    .A({1'b0,i_bf_a}),
    .B({1'b0,i_bf_b}),
    .C({1'b0,i_bf_c}),
    .D({1'b0,dsp_d}),
    .P(dsp_o)
    );
    
    reduce barret(
    .clk(clk),
    .i_data(dsp_o),
    .o_data(reduce_o)
    );

    modular_add adder(
//    .clk(clk),
    .u(i_bf_d_delay6),
    .v(mux_a),
    .add_o(add_o)
    );
    
    modular_sub suber(
//    .clk(clk),
    .u(i_bf_d_delay6),
    .v(mux_a),
    .sub_o(sub_o)
    );

endmodule
