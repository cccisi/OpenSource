`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2019 09:53:57 PM
// Design Name: 
// Module Name: reduce
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
module reduce( //barret reduce module
//    input [26:0] i_data,
//    output [12:0] o_data
//    );
    input clk,
    input [25:0] i_data,
    output [`WIDTH-1:0] o_data
    );
    
//    reg [26:0] i_data_reg;
    
        /* comb implement */
    wire [30:0] temp1;
    wire [34:0] temp2;
    wire [38:0] temp3;
    wire [38:0] temp4;
    wire [12:0] temp5;
    wire [25:0] temp6;
    wire [21:0] temp7;
    reg  [13:0] temp8;
    wire [12:0] sub;
    
    assign temp1 = i_data<<5;
    assign temp2 = i_data<<9;
    assign temp3 = i_data<<13;
    assign temp4 = temp1+temp2+temp3;
    assign temp5 = temp4>>26;
    assign temp6 = temp5<<13;
    assign temp7 = temp5<<9;
    
//    assign val = i_data_reg - (temp6 - temp7 + temp5);
    assign sub = temp8>`Q? `Q:0;
    assign o_data = temp8 - sub;
    
    always @(posedge clk) begin
//        i_data_reg <= i_data;
        temp8 <= i_data - (temp6 - temp7 + temp5);
    end
    
endmodule
