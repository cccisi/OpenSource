`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/24 23:03:03
// Design Name: 
// Module Name: modular_sub
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
module modular_sub(
//    input clk,
    input [`WIDTH-1:0] u,
    input [`WIDTH-1:0] v,
    output [`WIDTH-1:0] sub_o
    );
    
    wire [`WIDTH:0] u_Q;
    wire [`WIDTH:0] u_o;
        
    assign u_Q = u + `Q; 
    assign u_o = u>v? u:u_Q;
    assign sub_o = u_o - v;
        
endmodule
