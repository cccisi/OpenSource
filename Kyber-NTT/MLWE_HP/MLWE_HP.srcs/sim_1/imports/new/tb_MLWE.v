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

    parameter CLK_CYCLE = 10;
    
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
                
    reg clk;
    reg [3:0] sel = IDLE;
    reg [3:0] last_sel = IDLE;
    reg [12:0] data_i;
    wire [25:0] ram_data_o;
    wire done;
    
    initial begin
        clk = 0;
        data_i = 1'b1;
        #5
        forever
            #(CLK_CYCLE/2)
            clk = ~clk;
    end
    
     //Test for specific sel function
    always@(posedge clk) begin
        #30
        sel <= POLY_MADD_ADD;
//        last_sel <= POLY_MADD;
        #(CLK_CYCLE * 256 * 10 + 10)
        $stop;
    end
    
//    // Test for As+e flow
//    always@(posedge clk) begin
//        case(done)
//        0:begin
////            case (last_sel) 
////            IDLE:begin
////                sel <= PV_NTT;
////                last_sel <= PV_NTT;
////            end
////            default:sel <= sel;
////            endcase
//        end
//        1:begin
//            case (last_sel) 
//            IDLE:begin
//                sel <= PV_NTT;
////                if(sel != last_sel)
//                last_sel <= PV_NTT;
//            end
//            PV_NTT:begin
//                sel <= PM_PWM;
//                last_sel <= PM_PWM;
//            end
//            PM_PWM:begin
//                sel <= PV_INTT;
//                last_sel <= PV_INTT;
//            end
//            PV_INTT:begin
//                sel <= PV_MADD;
//                last_sel <= PV_MADD;
//            end
//            PV_MADD:begin
//                sel <= IDLE;
//                last_sel <= IDLE;
//                #150 $stop;
//            end
//            default:sel <= sel;
//            endcase
//        end
//        endcase
//    end
    
    mlwe DUT(
        .clk(clk),
        .sel(sel),
        .data_i(data_i),
        .ram_data_o(ram_data_o),
        .done(done)
        );
        
        //    reg [12:0] BRAM_A [0:1023];
        //    reg [12:0] BRAM_s [0:511];    
        //    initial
        //    begin
        //            /*$readmemh("file",mem_array,start_addr,stop_addr);*/
        ////            $readmemh("E:/Verilog/MLWE/MLWE.srcs/sim_1/new/tb_BRAM_A.txt", BRAM_A);
        //            $readmemh("E:/Verilog/MLWE/MLWE.srcs/sim_1/new/tb_BRAM_s.txt", BRAM_s);
        //            //$readmemb for a binary mode ;
        //    end
endmodule