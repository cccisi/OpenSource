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
module reduce( //barrett reduce module
//    input [26:0] i_data,
//    output [12:0] o_data
//    );
    input clk,
    input [26:0] i_data,
    output reg [`WIDTH-1:0] o_data
    );
    
    reg [26:0] i_data_reg;
    
    /* comb implement */
    wire [32:0] temp1;
    wire [36:0] temp2;
    wire [40:0] temp3;
    wire [40:0] temp4;
    reg  [13:0] temp5;
    wire [26:0] temp6;
    wire [22:0] temp7;
    reg  [13:0] temp8;
    wire [26:0] temp9;
    wire [12:0] sub;
    
    assign temp1 = i_data<<6;
    assign temp2 = i_data<<10;
    assign temp3 = i_data<<14;
    assign temp4 = i_data+temp1+temp2+temp3;
//    assign temp5 = temp4>>27;
    assign temp6 = temp5<<13;
    assign temp7 = temp5<<9;
    assign temp9 = temp6 - temp7 + temp5;
    
    assign sub = temp8>`Q? `Q:0;
//    assign o_data = temp8 - sub;
    
    always @(posedge clk) begin
        temp5 <= temp4>>27;
        i_data_reg <= i_data;
        temp8 <= i_data_reg - temp9;
        o_data <= temp8 - sub;
    end
    
endmodule
