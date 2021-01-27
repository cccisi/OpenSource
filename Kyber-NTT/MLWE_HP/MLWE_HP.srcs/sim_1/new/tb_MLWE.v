`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/04/04 10:32:27
// Design Name: 
// Module Name: tb_MLWE
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


module tb_MLWE();

    reg clk;
    reg rst;
    reg [2:0] sel; // 0 mul£¬ 1 NTT, 2 MULACC, 3, INTT
    reg [11:0] addr;
    wire [12:0] data_i;
    reg [12:0] data_i1;
    reg [12:0] data_i2;
    wire done;
    reg [2:0] sel_reg;
    reg [2:0] sel_reg1;
    
//    reg [12:0] BRAM_A [0:1023];
    reg [12:0] BRAM_s [0:511];
    
    assign data_i = (sel == 4)? data_i2:BRAM_s[addr];
    
    initial
    begin
            /*$readmemh("file",mem_array,start_addr,stop_addr);*/
//            $readmemh("E:/Verilog/MLWE/MLWE.srcs/sim_1/new/tb_BRAM_A.txt", BRAM_A);
            $readmemh("E:/Verilog/MLWE/MLWE.srcs/sim_1/new/tb_BRAM_s.txt", BRAM_s);
            //$readmemb for a binary mode ;
    end

    initial begin
        clk = 0;
        #5
        forever
            #20
            clk = ~clk;
    end
    
    initial begin
        rst = 1;
        addr = 0;
        sel = 2'b00;
        #50 rst = 0;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            addr <= 0;
        end
        else begin
            addr <= addr + 1;
            sel_reg <= sel;
            sel_reg1 <= sel_reg;
            data_i1 <= BRAM_s[addr];
            data_i2 <= data_i1;
            if(done && sel == 3'b101) begin
                #300
                $stop;
            end
            else if(done && sel_reg == sel_reg1 && sel_reg == sel && sel == 3'b100) begin
                 addr <= 0;
                 sel <= 3'b101;
            end            
            else if(done && sel_reg == sel && sel == 3'b011) begin
                addr <= 0;
                sel <= 3'b100;
            end
            else if(done && sel_reg == sel && sel == 3'b010) begin
                addr <= 0;
                #300
                sel <= 3'b011;
            end
            else if(done && sel_reg == sel && sel == 3'b001) begin
                addr <= 0;
                sel <= 3'b010;
            end
            else if(done && sel_reg == sel && sel == 3'b000) begin
                addr <= 0;
                sel <= 3'b001;
            end
            else if(sel == 3'b000) begin
                
            end
        end
    end
    /*
            //comments are allowed
            0xab //addr 8'h00
            0xba //addr 8'h01
            @55  //jump to 8'h55
            0x55 //addr 8'h55
            0xaa //addr 8'h56
    */
    
    mlwe DUT(
        .clk(clk),
        .rst(rst),
        .sel(sel),
        .data_i(data_i),
        .done(done)
        );
endmodule


//    initial begin
//        /* INIT */
//        rst = 1;
//        addr = 0;
//        sel = 3'b000;
//        #50 rst = 0;
//        #(CLK_CYCLE * 512 + 4)
//        rst = 1;
//        /* NTT */
//        #50 rst = 0;
//        sel = 3'b001;
//        #(CLK_CYCLE * 256 * 8 + 5)
//        rst = 1;
//        /* MACC */
//        #50 rst = 0;
//        sel = 3'b010;
//        #(CLK_CYCLE * 1024 + 5)
//        rst = 1;
//        /* INTT */
//        #50 rst = 0;
//        sel = 3'b011;
//        #(CLK_CYCLE * 256 * 8)
//        rst = 1;
//        /* MADD */
//        #50 rst = 0;
//        sel = 3'b100;
//        #(CLK_CYCLE * 512)
//        rst = 1;
        
//        #500
//        $stop;
//    end