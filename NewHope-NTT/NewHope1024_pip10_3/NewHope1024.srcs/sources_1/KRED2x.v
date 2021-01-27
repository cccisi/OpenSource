`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/02/28 12:38:47
// Design Name: 
// Module Name: KRED
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

module KRED2x(
        input clk,
        input [2*`WIDTH+1:0] i_data,
        output [`WIDTH+1:0] o_data
        );
        
`ifdef AREA
        
        wire [11:0] temp0;
        wire [14:0] temp1;
        wire [11:0] temp2;
        wire [12:0] temp3;
        wire [5:0] temp4;
        wire [14:0] temp5;
        wire [15:0] temp6;//16b
        
        assign temp0 = i_data[11:0]; // C0
        assign temp1 = temp0<<3;
        assign temp2 = i_data[23:12];// C1
        assign temp3 = temp2<<1;
        assign temp4 = i_data[29:24];// C2
        assign temp5 = temp1;
        assign temp6 = temp2 + temp3 - temp0;
        
        assign o_data = temp4 + temp5 - temp6; // C2-C1+C0
        
`elsif BALANCE

        wire [11:0] temp0;
        wire [14:0] temp1;
        wire [11:0] temp2;
        wire [12:0] temp3;
        reg [5:0] temp4;
        reg [15:0] temp5;
        reg [15:0] temp6;
        reg [15:0] temp7;
        
        assign temp0 = i_data[11:0]; // C0
        assign temp1 = temp0<<3;
        assign temp2 = i_data[23:12];// C1
        assign temp3 = temp2<<1;
//        assign temp4 = i_data[29:24];// C2
//        assign temp5 = temp0 + temp1;
//        assign temp6 = temp2 + temp3;
        
        assign o_data = temp7; // C2-C1+C0
        
        always @(posedge clk) begin
            temp4 <= i_data[29:24];
            temp5 <= temp1;
            temp6 <= temp2 + temp3 - temp0;
            temp7 <= temp4 + temp5 - temp6;
        end        
`else //PERFERMANCE

        wire [11:0] temp0;
        wire [14:0] temp1;
        wire [11:0] temp2;
        wire [12:0] temp3;
        reg [5:0] temp4;
        reg [15:0] temp5;
        reg [15:0] temp6;
        reg [15:0] temp7;
        
        assign temp0 = i_data[11:0]; // C0
        assign temp1 = temp0<<3;
        assign temp2 = i_data[23:12];// C1
        assign temp3 = temp2<<1;
        
        assign o_data = temp7; // C2-C1+C0
        
        always @(posedge clk) begin
            temp4 <= i_data[29:24];
            temp5 <= temp1;
            temp6 <= temp2 + temp3 - temp0;
            temp7 <= temp4 + temp5 - temp6;
        end  
        
`endif

endmodule
