`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/03 20:17:39
// Design Name: 
// Module Name: NTT_tb
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

module NTT_tb();

    reg clk;
    reg [1:0] sel; // 0 NTT, 2 PWM
    wire [`WIDTH+1:0] o_u_reg;
    wire [`WIDTH+1:0] o_v_reg;
    wire done;
    
    initial begin
        clk = 0;
        #5
        forever
            #5
            clk = ~clk;
    end
    
    initial begin
        sel <= 2'b11;
        #300
        sel <= 2'b00; // NTT
//        sel <= 2'b01; // INTT
//        sel <= 2'b10; // PWM
    end
    
    always @(posedge clk) begin
        if(done) begin
            sel <= 2'b11;
            $stop;
        end
    end
    
    NTT DUT(
        .clk(clk),
        .sel_nxt(sel),
        .o_u_reg(o_u_reg),
        .o_v_reg(o_v_reg),
        .done(done)
        );
endmodule