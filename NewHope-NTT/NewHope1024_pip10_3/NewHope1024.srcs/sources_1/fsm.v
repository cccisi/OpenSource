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
// Pipline
// base stage: sel_nxt
// delay1: i,j,logm,logt,done,sel_delay1
// delay2: j_delay1,j_First,j_Last,sel_delay2
// delay3: addr_su_rd,addr_sv_rd,addr_rom
// delay14: addr_su_wt,addr_sv_wt,wea
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
    input [1:0] sel_nxt,                          // input sel
    output wire sel,                             // sel delay 3+11 cycles, 0:NTT/INTT 1:PWM
    output reg [9:0] addr_s0_u,                  // delay 3 cycles, syn with sel, address of U
    output reg [9:0] addr_s0_v,                  // delay 3 cycles, syn with sel, address of V
    output reg [9:0] addr_s0_bp_u,               // delay 3 cycles, syn with sel, address of U
    output reg [9:0] addr_s0_bp_v,               // delay 3 cycles, syn with sel, address of V
    output reg [9:0] addr_s1_u,                  // delay 3 cycles
    output reg [9:0] addr_s1_v,                  // delay 3 cycles
    output reg [9:0] addr_s1_bp_u,               // delay 3 cycles
    output reg [9:0] addr_s1_bp_v,               // delay 3 cycles
    output wire [11:0] addr_rom,                 // delay 3 cycles, syn with sel, wire
    output reg done,                             // delay 1 cycle
    output reg we_s0,                            // delay 3 cycles, syn with sel，syn with addr_s
    output reg we_s0_bp,                         // delay 3 cycles, syn with sel，syn with addr_s
    output reg we_s1,                            // delay 3 cycles, syn with sel，syn with addr_s
    output reg we_s1_bp                          // delay 3 cycles, syn with sel，syn with addr_s
    );

    //state assignment
    localparam  // instrument
                NTT          =   4'b00,
                INTT         =   4'b01,
                PWM          =   4'b10,
                IDLE         =   4'b11;
                               
    // Delay chain
//    reg [1:0] sel_this;                             // sel
    reg [1:0] sel_delay1;                           // sel
    reg [1:0] sel_delay2; 
    reg       sel_delay3;                       
    
//    reg [9:0] addr_su_rd;                           // addr_su_rd
    reg [9:0] addr_su_rd_delay1;
    reg [9:0] addr_su_rd_delay2;
    reg [9:0] addr_su_rd_delay3;
    reg [9:0] addr_su_rd_delay4;
    reg [9:0] addr_su_rd_delay5;
    reg [9:0] addr_su_rd_delay6;
    reg [9:0] addr_su_rd_delay7;
    reg [9:0] addr_su_rd_delay8;
    reg [9:0] addr_su_rd_delay9;
    reg [9:0] addr_su_rd_delay10;
//    reg [9:0] addr_su_rd_delay11;
//    reg [9:0] addr_su_rd_delay12;                   // addr_su_wt

//    reg [9:0] addr_sv_rd;                           // addr_sv_rd
    reg [9:0] addr_sv_rd_delay1;
    reg [9:0] addr_sv_rd_delay2;
    reg [9:0] addr_sv_rd_delay3;
    reg [9:0] addr_sv_rd_delay4;
    reg [9:0] addr_sv_rd_delay5;
    reg [9:0] addr_sv_rd_delay6;
    reg [9:0] addr_sv_rd_delay7;
    reg [9:0] addr_sv_rd_delay8;
    reg [9:0] addr_sv_rd_delay9;
    reg [9:0] addr_sv_rd_delay10;
//    reg [9:0] addr_sv_rd_delay11;
//    reg [9:0] addr_sv_rd_delay12;                   // addr_sv_wt

//    reg [9:0] addr_s_delay1;                     // for PWM
        
    // for address
    wire [9:0] u_wire;                           // delay 2 cycles,
    wire [9:0] v_wire;
    wire [9:0] u_wire_rev;
    wire [9:0] v_wire_rev;

    reg [9:0] addr_su_rd;                        // delay 3 cycles, syn with sel, address of U
    reg [9:0] addr_sv_rd;                        // delay 3 cycles, syn with sel, address of V
    wire [9:0] addr_su_wt;                       // delay 3+11 cycle                          
    wire [9:0] addr_sv_wt;                       // delay 3+11 cycle           
    
    reg [11:0] addr_rom_delay1;                  // same as addr_s_delay1 for PWM
    reg [11:0] addr_rom_delay2;
    reg [11:0] addr_rom_delay3;
    
    reg logt0_delay2;                            // logt0 indecates wea_s1, syn with sel_delay2
    reg logt0_delay3;
    reg we_s1_delay1;
    reg we_s1_delay2;
    reg we_s1_delay3;
    reg we_s1_delay4;
    reg we_s1_delay5;
    reg we_s1_delay6;
    reg we_s1_delay7;
    reg we_s1_delay8;
    reg we_s1_delay9;
    reg we_s1_delay10;
//    reg we_s1_delay11;
//    reg we_s1_delay12;
   
    // For NTT state reg
    // 不用log标示
//    reg [10:0] m;                                   // m是蝶群数量,第几个stage
//    reg [10:0] t;                                   // t是蝶距
//    reg [3:0]  logt;                                // t是蝶距，蝶距logt，4位宽

//    always @(*) begin
//        case(1)
//        t[1]: logt = 1;
//        t[2]: logt = 2;
//        t[3]: logt = 3;
//        t[4]: logt = 4;
//        t[5]: logt = 5;
//        t[6]: logt = 6;
//        t[7]: logt = 7;
//        t[8]: logt = 8;
//        t[9]: logt = 9;
//        default : logt = 0;
//        endcase
//    end

    // 全用log标示
    reg [3:0]  logm;                                // m是蝶群数量
    reg [3:0]  logt;                                // t是蝶距，蝶距logt，4位宽
    reg [10:0] i;                                   // syn with sel_delay1第几个蝶群(分治)
    reg [10:0] j;                                   // syn with sel_delay1蝶群中第几个蝶形

    // fsm pip3 version
    wire [10:0] m;
    wire [10:0] t;
    reg [10:0] jFirst;                              // sel_delay2同步
    reg [10:0] jLast_jt;                            // sel_delay2同步
    reg [10:0] j_delay1;                            // sel_delay2同步
    
    assign m = 1<<logm;
    assign t = 1<<logt;
//    jFirst <= {i,1'b0} << logt;
//    jLast_jt <= j + t;
    assign u_wire = j_delay1+jFirst;
    assign v_wire = jFirst + jLast_jt;
    // output assignment
    assign sel = sel_delay3;
    assign addr_su_wt = addr_su_rd_delay10;
    assign addr_sv_wt = addr_sv_rd_delay10;
    assign addr_rom = addr_rom_delay3;
     
    // fsm pip2 version
//    wire [10:0] jFirst;
//    wire [10:0] jLast;
    
//    assign t = 1<<logt;
//    assign jFirst = {i,1'b0} << logt;
//    assign jLast = jFirst + t;
//    assign u_wire = j+jFirst;
//    assign v_wire = j+jLast;
        
    //状态寄存器转换
    always @ (posedge clk) begin
//        sel_this <= sel_nxt;
        sel_delay1 <= sel_nxt;
    end

    // MAIN，子状态变量更新
    // state include: NTT(m,logt,i.j),done
//    always @ (posedge clk) begin
//        m_switch <= m[9] == 1;
//        i_switch <= i == m-1;
//        j_switch <= j == t-1;
//    end
    // state include: NTT(m,logt,i.j),done
    always @ (posedge clk) begin
        case(sel_delay1)
        NTT:begin
            case (m[9] == 1) // m == 1024
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
//                        m <= m<<1;
//                        t <= t>>1;
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
//                        m <= 1;
//                        t <= 512;
                        logm <= 0;
                        logt <= 9;
                        i <= 0;
                        j <= 0;
                    end
                    endcase
                end
                endcase
            end
            endcase
        end
        INTT:begin
            case (m[9] == 1) // m == 1024
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
//                        m <= m<<1;
//                        t <= t>>1;
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
//                        m <= 1;
//                        t <= 512;
                        logm <= 0;
                        logt <= 9;
                        i <= 0;
                        j <= 0;
                    end
                    endcase
                end
                endcase
            end
            endcase
        end
        PWM:begin//addr_sv_delay1==255->done;
            case(addr_rom_delay1==(`N-1))
            0:begin
                addr_rom_delay1 <= addr_rom_delay1+1;
            end
            1:begin
                done <= 1'b1;
                addr_rom_delay1 <= 10'b0;
            end
            endcase
        end
        IDLE:begin
            // NTT/INTT state
//            m <= 1;
//            t <= 512;
            logm <= 0;
            logt <= 9;
            i <= 0;
            j <= 0;
            // other state
            done <= 0;
            addr_rom_delay1 <= 0;
        end
        default:begin
        end
        endcase
    end
    
    //状态输出
    
    //组合逻辑
    //////////////////////////////////////////////////////////////////////////////////
    // Logic:
    // logt=1 we_delay11=0  => s0_bp读 
    // logt=1 we_delay11=1  => s0读 
    // logt=0 we_delay11=1  => s1_bp读 
    // logt=0 we_delay11=0  => s1读 
    // 
    //////////////////////////////////////////////////////////////////////////////////
    always@(*) begin
        case({logt0_delay3,we_s1_delay10})
            2'b00:begin // read bram_s1
                addr_s0_u    = addr_su_wt;
                addr_s0_v    = addr_sv_wt;
                we_s0        = 1'b1      ;
                addr_s0_bp_u = addr_su_wt;
                addr_s0_bp_v = addr_sv_wt;
                we_s0_bp     = 1'b1      ;
                addr_s1_u    = addr_su_rd;
                addr_s1_v    = addr_sv_rd;
                we_s1        = 1'b0      ;
//                addr_s1_bp_u = 
//                addr_s1_bp_v = 
                we_s1_bp     = 1'b1      ;

            end
            2'b01:begin
//                addr_s0_u    = addr_su_wt;
//                addr_s0_v    = addr_sv_wt;
                we_s0        = 1'b1      ;
//                addr_s0_bp_u = addr_su_wt;
//                addr_s0_bp_v = addr_sv_wt;
                we_s0_bp     = 1'b1      ;
                addr_s1_u    = addr_su_wt;
                addr_s1_v    = addr_sv_wt;
                we_s1        = 1'b1      ;
                addr_s1_bp_u = addr_su_rd;
                addr_s1_bp_v = addr_sv_rd;
                we_s1_bp     = 1'b0      ;
            end
            2'b10:begin
                addr_s0_u    = addr_su_wt;
                addr_s0_v    = addr_sv_wt;
                we_s0        = 1'b1      ;
                addr_s0_bp_u = addr_su_rd;
                addr_s0_bp_v = addr_sv_rd;
                we_s0_bp     = 1'b0      ;
//                addr_s1_u    = addr_su_wt;
//                addr_s1_v    = addr_sv_wt;
                we_s1        = 1'b1      ;
//                addr_s1_bp_u = addr_su_rd;
//                addr_s1_bp_v = addr_sv_rd;
                we_s1_bp     = 1'b1      ;
            end
            2'b11:begin
                addr_s0_u    = addr_su_rd;
                addr_s0_v    = addr_sv_rd;
                we_s0        = 1'b0      ;
//                addr_s0_bp_u = addr_su_wt;
//                addr_s0_bp_v = addr_sv_wt;
                we_s0_bp     = 1'b1      ;
                addr_s1_u    = addr_su_wt;
                addr_s1_v    = addr_sv_wt;
                we_s1        = 1'b1      ;
                addr_s1_bp_u = addr_su_wt;
                addr_s1_bp_v = addr_sv_wt;
                we_s1_bp     = 1'b1      ;
            end
            default:begin
            end
        endcase
    end
    
    //////////////////////////////////////////////////////////////////////////////////
    // Logic:
    //                                 NTT ->u_wire
    //          logt0==1->addr_sv_rd;  INTT->u_wire_rev
    // addr_s0_u                       PWM ->addr_rom_delay2
    //          logt0==0->addr_su_wt
    // 
    //////////////////////////////////////////////////////////////////////////////////
    
    //时序状态输出
    always @ (posedge clk) begin
        // other state signal
        addr_rom_delay3 <= addr_rom_delay2;
        case(sel_delay1)
            NTT:begin
                addr_rom_delay2 <= m+i;
            end
            INTT:begin
                addr_rom_delay2[11:10] <= 2'b10;
                addr_rom_delay2[9:0] <= i;
            end
            PWM:begin
                addr_rom_delay2[11:10] <= 2'b01;
                addr_rom_delay2[9:0] <= addr_rom_delay1;
            end
            default:begin
                addr_rom_delay2[9:0] <= addr_rom_delay1;
            end
        endcase
        case(sel_delay2)
            NTT:begin
                addr_su_rd <= u_wire;
                addr_sv_rd <= v_wire;
            end
            INTT:begin
                addr_su_rd <= u_wire_rev;
                addr_sv_rd <= v_wire_rev;
            end
            PWM:begin
                addr_sv_rd <= addr_rom_delay2;
            end
            default:begin
                addr_sv_rd <= addr_rom_delay2;
            end
        endcase
    end
    
    // 时序输出延时，delay chain for addr_su and we_s
    always@(posedge clk) begin
        sel_delay2    <= sel_delay1; 
        sel_delay3    <= sel_delay2[1]; 
        
        jFirst        <= {i,1'b0} << logt;      // syn sel_delay2
        jLast_jt      <= j + t;                 // syn sel_delay2
        j_delay1      <= j;                     // syn sel_delay2
        
        addr_su_rd_delay1  <= addr_su_rd;
        addr_su_rd_delay2  <= addr_su_rd_delay1;
        addr_su_rd_delay3  <= addr_su_rd_delay2;
        addr_su_rd_delay4  <= addr_su_rd_delay3;
        addr_su_rd_delay5  <= addr_su_rd_delay4;
        addr_su_rd_delay6  <= addr_su_rd_delay5;
        addr_su_rd_delay7  <= addr_su_rd_delay6;
        addr_su_rd_delay8  <= addr_su_rd_delay7;
        addr_su_rd_delay9  <= addr_su_rd_delay8;
        addr_su_rd_delay10 <= addr_su_rd_delay9;
//        addr_su_rd_delay11 <= addr_su_rd_delay10;
//        addr_su_rd_delay12 <= addr_su_rd_delay11;
        
        addr_sv_rd_delay1  <= addr_sv_rd;
        addr_sv_rd_delay2  <= addr_sv_rd_delay1;
        addr_sv_rd_delay3  <= addr_sv_rd_delay2;
        addr_sv_rd_delay4  <= addr_sv_rd_delay3;
        addr_sv_rd_delay5  <= addr_sv_rd_delay4;
        addr_sv_rd_delay6  <= addr_sv_rd_delay5;
        addr_sv_rd_delay7  <= addr_sv_rd_delay6;
        addr_sv_rd_delay8  <= addr_sv_rd_delay7;
        addr_sv_rd_delay9  <= addr_sv_rd_delay8;
        addr_sv_rd_delay10 <= addr_sv_rd_delay9;
//        addr_sv_rd_delay11 <= addr_sv_rd_delay10;
//        addr_sv_rd_delay12 <= addr_sv_rd_delay11;
        
        logt0_delay2  <= logt[0];
        logt0_delay3  <= logt0_delay2;
        we_s1_delay1  <= logt0_delay3;
        we_s1_delay2  <= we_s1_delay1;
        we_s1_delay3  <= we_s1_delay2;
        we_s1_delay4  <= we_s1_delay3;
        we_s1_delay5  <= we_s1_delay4;
        we_s1_delay6  <= we_s1_delay5;
        we_s1_delay7  <= we_s1_delay6;
        we_s1_delay8  <= we_s1_delay7;
        we_s1_delay9  <= we_s1_delay8;
        we_s1_delay10 <= we_s1_delay9;
//        we_s1_delay11 <= we_s1_delay10;
//        we_s1_delay12 <= we_s1_delay11;
    end
    
    bitrev bv_u(
    .i_addr(u_wire),
    .o_addr_rev(u_wire_rev)
    );
    
    bitrev bv_v(
    .i_addr(v_wire),
    .o_addr_rev(v_wire_rev)
    );
endmodule