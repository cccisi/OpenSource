`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/03 14:19:38
// Design Name: 
// Module Name: bitrev
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


module bitrev(
    input  [9:0] i_addr,
    output [9:0] o_addr_rev
    );
    assign o_addr_rev[9] = i_addr[0];
    assign o_addr_rev[8] = i_addr[1];
    assign o_addr_rev[7] = i_addr[2];
    assign o_addr_rev[6] = i_addr[3];
    assign o_addr_rev[5] = i_addr[4];
    assign o_addr_rev[4] = i_addr[5];
    assign o_addr_rev[3] = i_addr[6];
    assign o_addr_rev[2] = i_addr[7];
    assign o_addr_rev[1] = i_addr[8];
    assign o_addr_rev[0] = i_addr[9];
endmodule
