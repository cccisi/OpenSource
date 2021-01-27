`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/04 13:59:09
// Design Name: 
// Module Name: mlwe
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


module mlwe(
    input clk,
    input [3:0] sel,
    input [12:0] data_i,
    output [25:0] ram_data_o,
    output done
    );
    
    wire wea_s;
    wire [7:0] addr_sa;
    wire [7:0] addr_sb;
    wire [8:0] addr_ab;
    wire [8:0] addr_eb;
    wire [25:0] ram_data_s;
    wire [25:0] ram_data_a;
    wire [12:0] ram_data_e;
    
    core core(
    .clk(clk),
    .sel_nxt(sel),
    .data_i(data_i),
    .ram_data_s(ram_data_s),
    .ram_data_a(ram_data_a),
    .ram_data_e(ram_data_e),
    .addr_sa(addr_sa),
    .addr_sb(addr_sb),
    .addr_ab(addr_ab),
    .addr_eb(addr_eb),
    .ram_data_o(ram_data_o),
    .done(done),
    .wea_s(wea_s)
    );
    
    BRAM_A bram_a(
    .clka(clk),
    .addra(0),
    .dina(0),
    .wea(0),
    .clkb(clk),
    .addrb(addr_ab),
    .doutb(ram_data_a)
    );
    
    BRAM_s bram_s(
    .clka(clk),
    .wea(wea_s),
    .addra(addr_sa),
    .dina(ram_data_o),
    .clkb(clk),
    .addrb(addr_sb),
    .doutb(ram_data_s)
    );
    
    BRAM_e bram_e(
    .clka(clk),
    .addra(0),
    .dina(0),
    .wea(0),
    .clkb(clk),
    .addrb(addr_eb),
    .doutb(ram_data_e)
    );
endmodule
