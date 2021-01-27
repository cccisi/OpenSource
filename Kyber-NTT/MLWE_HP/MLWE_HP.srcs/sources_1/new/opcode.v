`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/28 21:51:54
// Design Name: 
// Module Name: opcode
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 2 cycles delay
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module opcode(
    input clk,
    input [3:0] sel,
    output reg [2:0] core_sel,
    output reg bf_sel,
    output reg [1:0] dsp_sel
    );
    
    //state assignment
    localparam  // instrument
                PM_PWM          =   4'b0000,
                PV_NTT          =   4'b0001,
                PV_INTT         =   4'b0010,
                PV_PWM          =   4'b0011,
                PV_MADD         =   4'b0100,
                POLY_MADD       =   4'b0101,
                POLY_MSUB       =   4'b0110,
                POLY_MADD_ADD   =   4'b0111,
                IDLE            =   4'b1000;

    localparam  //core_sel[2:1]
                CORE_PWM        =   2'b00,
                CORE_NTT        =   2'b01,
                CORE_PV_MADD    =   2'b10,
                CORE_POLY       =   2'b11,
                //bf_sel
                BF_NTT          =   1'b0,
                BF_INTT         =   1'b1,
                //dsp_sel
                DSP_MUL         =   2'b00,
                DSP_SUBM        =   2'b01,
                DSP_MACC        =   2'b10,
                DSP_MADD        =   2'b11;
    
    //define sel signal
    reg [3:0] sel_delay1;
    reg [3:0] sel_delay2;
    
    always@(posedge clk) begin
        sel_delay1 <= sel;
        sel_delay2 <= sel_delay1; //delay 3 cycles : sel_delay1,sel_delay2, decode output delay
        core_sel[0] <= sel_delay2[0];
        case (sel_delay2[3:1])
        PM_PWM:begin
            core_sel[2:1] <= CORE_PWM;
            bf_sel <= BF_INTT;
            dsp_sel <= sel_delay2[0]? DSP_MACC:DSP_MUL;
        end
        PV_NTT:begin
            core_sel[2:1] <= CORE_NTT;
            bf_sel <= BF_NTT;
            dsp_sel <= DSP_MUL;
        end
        PV_INTT:begin
            core_sel[2:1] <= CORE_NTT;
            bf_sel <= BF_INTT;
            dsp_sel <= DSP_SUBM;
        end
        PV_PWM:begin
            core_sel[2:1] <= CORE_PWM;
            bf_sel <= BF_INTT;
            dsp_sel <= sel_delay2[0]? DSP_MACC:DSP_MUL;
        end
        PV_MADD:begin
            core_sel[2:1] <= CORE_PV_MADD;
            bf_sel <= BF_INTT;
            dsp_sel <= DSP_MADD;
        end
        POLY_MADD:begin
            core_sel[2:1] <= CORE_POLY;
            bf_sel <= BF_INTT;
            dsp_sel <= DSP_MADD;
        end
        POLY_MSUB:begin
            core_sel[2:1] <= CORE_POLY;
            bf_sel <= BF_NTT;
            dsp_sel <= DSP_MUL;
        end
        POLY_MADD_ADD:begin
            core_sel[2:1] <= CORE_POLY;
            bf_sel <= BF_NTT;
            dsp_sel <= DSP_MADD;
        end
        default:begin
            core_sel[2:1] <= CORE_NTT;
            bf_sel <= BF_NTT;
            dsp_sel <= DSP_MUL;
        end
        endcase
    end
endmodule
