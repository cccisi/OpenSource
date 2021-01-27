`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/03 13:36:03
// Design Name: 
// Module Name: modular_add
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
module modular_add(
//    input clk,
    input [`WIDTH-1:0] u,
    input [`WIDTH-1:0] v,
    output [`WIDTH-1:0] add_o
    );
    
    wire [`WIDTH:0] add_result;
    wire [`WIDTH-1:0] add_result_Q;
        
    assign add_result = u + v; 
    assign add_result_Q = add_result - `Q;
    assign add_o = 
        add_result>7681? add_result_Q:add_result;
        
endmodule
