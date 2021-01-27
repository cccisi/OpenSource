`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2019/04/03 14:01:48
// Design Name:
// Module Name: fsm
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
// next state only depend on input sel_nxt, stateoutput only depend on current state
// So, part of the combinantial logic of state output move to the "core" module
// IDLE: 
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

`include "params.vh"
module fsm(
    input clk,
    input [3:0] sel_nxt,        /* input */
    output reg [4:0] sel,       // sel delay 2 cycles
    output reg [7:0] addr_sa,   // delay 4 cycle
    output reg [7:0] addr_sb,   // delay 2 cycles, syn with sel, wire
    output reg [8:0] addr_ab,   // delay 2 cycles, syn with sel
    output reg [8:0] addr_eb,   // delay 2 cycles, syn with sel
    output reg [8:0] addr_rom,  // delay 2 cycles, syn with sel, wire
    output reg done,            // delay 1 cycle
    output reg wea_s            // syn with addr_sa
    );

    //state assignment
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

    // Delay chain
    reg [7:0] addr_sa_delay1;
    reg [7:0] addr_sa_delay2;
    reg [7:0] addr_sa_delay3;
    reg [7:0] addr_sa_delay4;
    reg [7:0] addr_sa_delay5;
    reg [7:0] addr_sa_delay6;
    reg [7:0] addr_sb_u;    // delay2 ,i,j,m,t are delay1
    reg [7:0] addr_sb_v;    // delay2
    reg [7:0] addr_sb_delay1;
    reg [7:0] addr_sb_delay2;
    reg [8:0] addr_ab_delay1;
    reg [8:0] addr_eb_delay1;
    
    reg [3:0] sel_delay1;
    
    reg wea_s_syn_fsm_o; //wea_s_syn_fsm_o = done_delay2
    reg wea_s_delay1;
    reg wea_s_delay2;
    reg wea_s_delay3;
    reg wea_s_delay4;
    reg wea_s_delay5;
    reg wea_s_delay6;
    
    // for address
    wire [7:0] jF_rev;
    wire [7:0] jL_rev;
   
    // For NTT state reg
    reg [3:0] logm; // m是蝶群数量,第几个stage 7 width， logm 4位宽
    reg [3:0] logt; // t是蝶距，蝶距logt，4位宽
    reg [7:0] i; // 第几个蝶群
    reg [7:0] j; // 群中第几个蝶形

    wire [8:0] m;
    wire [8:0] t;
    wire [7:0] jFirst;
    wire [7:0] jLast;
    wire [7:0] jF;
    wire [7:0] jL;
    
    assign m = 1<<logm;
    assign t = 1<<logt;
    assign jFirst = i<<(logt+1);
    assign jLast = jFirst + t;
    assign jF = j+jFirst;
    assign jL = j+jLast;
    
    // for PV_MACC
    wire macc_div4_done;
    
    assign macc_div4_done = addr_ab_delay1[8]; //div4 for PV_MACC
    
    //状态寄存器转换
    always @ (posedge clk) begin
        sel_delay1 <= sel_nxt;
    end

    // done-sel protecol（不需要握手，不同于ready-valid，这里done不用外部控制）
    // done信号在最后一个有效信号的下一拍拉高
    // done信号保持1逻辑，一个时钟后本sel 的state会将done清0，但这一拍done为1即wea=1，因此无效
    // done清0后即开始有效运算
    //      对于双拍运算（即每两拍变更状态），例如PV_MADD,PV_NTT可以借助div2信号sel[0]==0,不影响结果正确
    //      对于单拍信号（即每拍都变更状态），例如POLY_MADD，可以根据done信号判断,done=1时拉低，不做其他运算，也不影响结果正确
    // done信号，只维持1个时钟宽度
    // done信号不维持，所以需要结合IDLE状态控制，IDLE状态done常为0.
    always @ (posedge clk) begin
        if(done) begin
            sel[0] <= 1'b0;  //init
        end
        else begin
            sel[0] <= ~sel[0];
        end
    end
    
    // MAIN，子状态变量更新
    // state include: NTT(logm,logt,i.j),sel[0],addr_sb_delay1,addr_ab_delay1,addr_eb_delay1,macc_div4_done,done
    always @ (posedge clk) begin
        case(sel_nxt)
        PM_PWM:begin//addr_sb_delay1==255->done; addr_ab_delay1[8]->div4
            case(sel[0])
                0:begin
                    done <= 1'b0; // init not done
                end
                1:begin
                    case(addr_sb_delay1 == (`N-1))
                    0:begin
                        addr_ab_delay1[8] <= ~addr_ab_delay1[8];
                        case(addr_ab_delay1[8])
                            1:begin
                                addr_sb_delay1 <= addr_sb_delay1+1;
                                addr_ab_delay1[7:0] <= addr_ab_delay1[7:0]+1;
                            end
                        endcase
                    end
                    1:begin 
                        case(addr_ab_delay1[8])
                        0:addr_ab_delay1[8] <= ~addr_ab_delay1[8];
                        1:begin //done
                            done <= 1'b1;
                            addr_sb_delay1 <= 8'b0;
                            addr_ab_delay1 <= 9'b0;
                        end
                        endcase
                    end
                    endcase
                end
            endcase
        end
        //      for(m = 1; m < KYBER_N; m= m*2)
        //      {
        //        t = t/2;
        //        for(i = 0; i < m; i++)
        //        {
        //          jFirst = 2*i*t;
        //          jLast = 2*i*t+t;
        //          for(j = 0 ; j < t ; j++)  {...}
        //        }
        //      }
        PV_NTT:begin
            case (sel[0]== 1'b1)
            0:begin
                done <= 1'b0; // init not done
            end
            1:begin
                case (logm == 7)
                0:begin
                    case (i == m-1)
                    0:begin
                        case (j == t-1)
                        0:begin
                            j <= j+1;
                        end
                        1:begin
                            i <= i+1;
                            j <= 0;
                        end
                        endcase
                    end
                    1:begin
                        case (j == t-1)
                        0:begin 
                            j <= j+1;
                        end
                        1:begin
                            logm <= logm+1;
                            logt <= logt-1;
                            i <= 0;
                            j <= 0;
                        end
                        endcase
                    end
                    endcase
                end
                1:begin 
                    case (i == m-1)
                    0:begin
                        case (j == t-1)
                        0:begin
                            j <= j+1;
                        end
                        1:begin
                            i <= i+1;
                            j <= 0;
                        end
                        endcase
                    end
                    1:begin
                        case (j == t-1)
                        0:begin 
                            j <= j+1;
                        end
                        1:begin // done
                            done <= 1'b1;
                            // init state reg
                            logm <= 0;
                            logt <= 7;
                            i <= 0;
                            j <= 0;
                        end
                        endcase
                    end
                    endcase
                end
                endcase
            end
            endcase 
        end
        PV_INTT:begin
            case (sel[0]== 1'b1)
            0:begin
                done <= 1'b0; // init not done
            end
            1:begin
                case (logm == 7)
                0:begin
                    case (i == m-1)
                    0:begin
                        case (j == t-1)
                        0:begin
                            j <= j+1;
                        end
                        1:begin
                            i <= i+1;
                            j <= 0;
                        end
                        endcase
                    end
                    1:begin
                        case (j == t-1)
                        0:begin 
                            j <= j+1;
                        end
                        1:begin
                            logm <= logm+1;
                            logt <= logt-1;
                            i <= 0;
                            j <= 0;
                        end
                        endcase
                    end
                    endcase
                end
                1:begin 
                    case (i == m-1)
                    0:begin
                        case (j == t-1)
                        0:begin
                            j <= j+1;
                        end
                        1:begin
                            i <= i+1;
                            j <= 0;
                        end
                        endcase
                    end
                    1:begin
                        case (j == t-1)
                        0:begin 
                            j <= j+1;
                        end
                        1:begin // done
                            done <= 1'b1;
                            // init state reg
                            logm <= 0;
                            logt <= 7;
                            i <= 0;
                            j <= 0;
                        end
                        endcase
                    end
                    endcase
                end
                endcase
            end
            endcase
        end
        PV_PWM:begin//addr_sb_delay1==255->done;
            case(sel[0])
                0:begin
                    done <= 1'b0; // init not done
                end
                1:begin
                    case(addr_sb_delay1==(`N-1))
                    0:begin
                        addr_sb_delay1 <= addr_sb_delay1+1;
                        addr_ab_delay1[7:0] <= addr_ab_delay1[7:0]+1;
                    end
                    1:begin
                        done <= 1'b1;
                        addr_sb_delay1 <= 8'b0;
                        addr_ab_delay1 <= 9'b0;
                    end
                    endcase
                end
            endcase
        end
        PV_MADD:begin
            case(sel[0])
            0:begin
                done <= 1'b0; // init not done
            end
            1:begin
                case(addr_sb_delay1==(`N-1))
                0:begin
                    addr_sb_delay1 <= addr_sb_delay1+1;
                    addr_eb_delay1 <= addr_eb_delay1+1;
                end
                1:begin
                    done <= 1'b1;
                    addr_sb_delay1 <= 8'b0;
                    addr_eb_delay1 <= 9'b0;
                end
                endcase
            end
            endcase
        end
        POLY_MADD:begin
            case(addr_sb_delay1==(`N-1))
                0:begin
                    if(done) done <= 1'b0; // init not done
                    else begin
                        addr_sb_delay1 <= addr_sb_delay1+1;
                        addr_eb_delay1 <= addr_eb_delay1+1;
                    end
                end
                1:begin
                    done <= 1'b1;
                    addr_sb_delay1 <= 8'b0;
                    addr_eb_delay1 <= 9'b0;
                end
            endcase
        end
        POLY_MSUB:begin
            case(addr_sb_delay1==(`N-1))
                0:begin
                    if(done) done <= 1'b0; // init not done
                    else begin
                        addr_sb_delay1 <= addr_sb_delay1+1;
                        addr_eb_delay1 <= addr_eb_delay1+1;
                    end
                end
                1:begin
                    done <= 1'b1;
                    addr_sb_delay1 <= 8'b0;
                    addr_eb_delay1 <= 9'b0;
                end
            endcase
        end
        POLY_MADD_ADD:begin
            case(addr_sb_delay1==(`N-1))
                0:begin
                    if(done) done <= 1'b0; // init not done
                    else begin
                        addr_sb_delay1 <= addr_sb_delay1+1;
                        addr_eb_delay1 <= addr_eb_delay1+1;
                    end
                end
                1:begin
                    done <= 1'b1;
                    addr_sb_delay1 <= 8'b0;
                    addr_eb_delay1 <= 9'b0;
                end
            endcase
        end
        IDLE:begin
            // NTT/INTT state
            logm <= 0;
            logt <= 7;
            i <= 0;
            j <= 0;
            // other state
            addr_sb_delay1 <= 0;
            addr_ab_delay1 <= 0;
            addr_eb_delay1 <= 0;
            if(done) begin
                done <= 1'b0;
            end else begin
                done <= 1'b1;
            end
        end
        default:begin
        end
        endcase
    end
    
    //状态输出
    //////////////////////////////////////////////////////////////////////////////////
    //    void eff_ntt_CT_intt_GS(uint16_t *a, int index)
    //    {
    //      int i, j, k, m, t, addr, jFirst, jLast;
    //      uint16_t omega;
    //      uint32_t U, V;
        
    //      t = KYBER_N;
    //      for(m = 1; m < KYBER_N; m= m*2)
    //      {
    //        t = t/2;
    //        for(i = 0; i < m; i++)
    //        {//pip j,jFirst,jLast
    //          jFirst = 2*i*t;
    //          jLast = 2*i*t+t;
    //          for(j = 0 ; j < t ; j++)
    //          {
    //              if(index == 0){
    //              addr = m+i; omega = bvpsi_7681_256[addr];
    //              U = a[j+jFirst];
    //              V = (a[j+jLast] * (uint32_t)omega) % 7681;
    //              a[j+jFirst] = (U + V) % 7681;
    //              if(U>V)
    //                a[j+jLast] = (U - V) % 7681;
    //              else
    //                a[j+jLast] = (7681- V + U) % 7681;
    //              }else{
    //              addr = ((j<<1)+1)*m; omega = invpsi_7681_256[addr];
    //              U = a[reverse(j+jFirst)];
    //              V = a[reverse(j+jLast)];
    //              a[reverse(j+jFirst)] = (U + V) % 7681;
    //              if(U>V)
    //                a[reverse(j+jLast)] = ((U - V) * (uint32_t)omega) % 7681;
    //              else
    //                a[reverse(j+jLast)] = ((7681- V + U) * (uint32_t)omega) % 7681;
    //              }
    //          }
    //        }
    //      }
    //    }
    //////////////////////////////////////////////////////////////////////////////////
    //组合逻辑
    always@(*) begin
        case(sel_delay1)
//            PM_PWM:begin
//            end
            PV_NTT:begin
                addr_sb = sel[0]? addr_sb_u:addr_sb_v;
            end
            PV_INTT:begin
                addr_sb = sel[0]? addr_sb_u:addr_sb_v;
            end
//            PV_PWM:begin
//            end
//            PV_MADD:begin
//            end
//            POLY_MADD:begin
//            end
//            POLY_MSUB:begin
//            end
//            POLY_MADD_ADD:begin
//            end
            default:begin
                addr_sb = addr_sb_delay2;
            end
        endcase
    end
    
    //时序状态输出
    always @ (posedge clk) begin
        sel[4:1] <= sel_delay1;
        addr_sb_delay2 <= addr_sb_delay1;
        addr_ab <= addr_ab_delay1;
        addr_eb <= addr_eb_delay1;
        // other state signal
        case(sel_delay1)
//            PM_PWM:begin
//            end
            PV_NTT:begin
                addr_sb_u <= jF;
                addr_sb_v <= jL;
                addr_rom <= m+i;
            end
            PV_INTT:begin
                addr_sb_u <= jF_rev;
                addr_sb_v <= jL_rev;
                addr_rom[8] <= 1'b1;
                addr_rom[7:0] <= ((j<<1)+1)<<logm;
            end
//            PV_PWM:begin
//            end
//            PV_MADD:begin
//            end
//            POLY_MADD:begin
//            end
//            POLY_MSUB:begin
//            end
//            POLY_MADD_ADD:begin
//            end
            default:begin
                addr_sb_u <= 8'b0;
                addr_sb_v <= 8'b0;
                addr_rom <= 9'b0;
            end
        endcase
    end
    
    // 时序输出延时，delay chain for addr_sa and wea_s
    always@(posedge clk) begin
        addr_sa_delay1 <= addr_sb;
        addr_sa_delay2 <= addr_sa_delay1;
        addr_sa_delay3 <= addr_sa_delay2;
        addr_sa_delay4 <= addr_sa_delay3;
        addr_sa_delay5 <= addr_sa_delay4;
        addr_sa_delay6 <= addr_sa_delay5;
        addr_sa <= addr_sa_delay6;
        
        wea_s_syn_fsm_o <= !done;//fsm_o delay2
        wea_s_delay1 <= wea_s_syn_fsm_o;
        wea_s_delay2 <= wea_s_delay1;// read for addr cost 2 cycles
        wea_s_delay3 <= wea_s_delay2;
        wea_s_delay4 <= wea_s_delay3;
        wea_s_delay5 <= wea_s_delay4;
        wea_s_delay6 <= wea_s_delay5;
        wea_s <= wea_s_delay6;
    end
    
    bitrev bvjF(
    .i_addr(jF),
    .o_addr_rev(jF_rev)
    );
    
    bitrev bvjL(
    .i_addr(jL),
    .o_addr_rev(jL_rev)
    );
endmodule
