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

`include "params.vh"

module NTT(
    input clk,
//    input clk_p,  //
//    input clk_n,   // 200M differential input
    input [1:0] sel_nxt,                  
    output [`WIDTH+1:0] o_u_reg,
    output [`WIDTH+1:0] o_v_reg,
    output done
    );
    
//    wire clk;

//   IBUFDS #(
//   .DIFF_TERM("FALSE"),       // Differential Termination
//   .IBUF_LOW_PWR("TRUE"),     // Low power="TRUE", Highest performance="FALSE" 
//   .IOSTANDARD("DEFAULT")     // Specify the input I/O standard
//) IBUFDS_inst (
//   .O(clk),  // Buffer output
//   .I(clk_p),  // Diff_p buffer input (connect directly to top-level port)
//   .IB(clk_n) // Diff_n buffer input (connect directly to top-level port)
//);
    
    wire [9:0]  addr_s0_u   ;
    wire [9:0]  addr_s0_v   ;
    wire [9:0]  addr_s0_bp_u;
    wire [9:0]  addr_s0_bp_v;
    wire [9:0]  addr_s1_u   ;   
    wire [9:0]  addr_s1_v   ;   
    wire [9:0]  addr_s1_bp_u;
    wire [9:0]  addr_s1_bp_v;
    wire [11:0] addr_rom    ;    
    wire        we_s0      ;            
    wire        we_s0_bp   ;         
    wire        we_s1      ;            
    wire        we_s1_bp   ;
    
    reg  [`WIDTH+1:0] i_u_wire;
    reg  [`WIDTH+1:0] i_v_wire;
    wire [`WIDTH+1:0] s0_u_dout;
    wire [`WIDTH+1:0] s0_v_dout;
    wire [`WIDTH+1:0] s0_bp_u_dout;
    wire [`WIDTH+1:0] s0_bp_v_dout;
    wire [`WIDTH+1:0] s1_u_dout;
    wire [`WIDTH+1:0] s1_v_dout;
    wire [`WIDTH+1:0] s1_bp_u_dout;
    wire [`WIDTH+1:0] s1_bp_v_dout;
    wire [`WIDTH-1:0] psi_omega;
    
    wire      sel;
    reg       sel_delay1;                         
    reg       sel_delay2;                         
    reg       sel_delay3;                         
    reg       sel_delay4;                         
    reg       sel_delay5;                         
    reg       sel_delay6;                         
    reg       sel_delay7;                         
    reg       sel_delay8;                         
    reg       sel_delay9;                         
    reg       sel_delay10;    
//    reg       sel_delay11;    

    reg we_s0_delay1   ;   
    reg we_s0_delay2   ;   
//    reg we_s0_delay3   ;   
    reg we_s0_bp_delay1;
    reg we_s0_bp_delay2;
//    reg we_s0_bp_delay3;
    reg we_s1_delay1   ;   
    reg we_s1_delay2   ;   
//    reg we_s1_delay3   ;   
    reg we_s1_bp_delay1;
    reg we_s1_bp_delay2;
//    reg we_s1_bp_delay3;

    always @(*) begin
        case({we_s0_delay2,we_s0_bp_delay2,we_s1_delay2,we_s1_bp_delay2})
//        case({we_s0_delay3,we_s0_bp_delay3,we_s1_delay3,we_s1_bp_delay3})
        4'b0111:begin
            i_u_wire = s0_u_dout;
            i_v_wire = s0_v_dout;
        end
        4'b1011:begin
            i_u_wire = s0_bp_u_dout;
            i_v_wire = s0_bp_v_dout;
        end
        4'b1101:begin
            i_u_wire = s1_u_dout;
            i_v_wire = s1_v_dout;
        end             
        4'b1110:begin   
            i_u_wire = s1_bp_u_dout;
            i_v_wire = s1_bp_v_dout;
        end
        default begin
            i_u_wire = s0_u_dout;
            i_v_wire = s0_v_dout;
        end
        endcase
    end    
        
    always @(posedge clk) begin
        sel_delay1     <= sel ; 
        sel_delay2     <= sel_delay1 ; 
        sel_delay3     <= sel_delay2 ; 
        sel_delay4     <= sel_delay3 ; 
        sel_delay5     <= sel_delay4 ; 
        sel_delay6     <= sel_delay5 ; 
        sel_delay7     <= sel_delay6 ; 
        sel_delay8     <= sel_delay7 ; 
        sel_delay9     <= sel_delay8 ; 
        sel_delay10    <= sel_delay9 ; 
//        sel_delay11    <= sel_delay10; 
//        sel_delay12    <= sel_delay11; 
        
        we_s0_delay1   <= we_s0;
        we_s0_delay2   <= we_s0_delay1;
//        we_s0_delay3   <= we_s0_delay2;
        we_s0_bp_delay1<= we_s0_bp;
        we_s0_bp_delay2<= we_s0_bp_delay1;
//        we_s0_bp_delay3<= we_s0_bp_delay2;
        we_s1_delay1   <= we_s1;
        we_s1_delay2   <= we_s1_delay1;
//        we_s1_delay3   <= we_s1_delay2;
        we_s1_bp_delay1<= we_s1_bp;
        we_s1_bp_delay2<= we_s1_bp_delay1;
//        we_s1_bp_delay3<= we_s1_bp_delay2;
    end
    
    fsm fsm(
        .clk            (clk         ),
        .sel_nxt        (sel_nxt     ),                   // input sel
        .sel            (sel         ),                   // sel delay 3+11 cycles, 0:NTT/INTT 1:PWM
        .addr_s0_u      (addr_s0_u   ),                   
        .addr_s0_v      (addr_s0_v   ),                   
        .addr_s0_bp_u   (addr_s0_bp_u),                   
        .addr_s0_bp_v   (addr_s0_bp_v),                   
        .addr_s1_u      (addr_s1_u   ),                   
        .addr_s1_v      (addr_s1_v   ),                   
        .addr_s1_bp_u   (addr_s1_bp_u),                  
        .addr_s1_bp_v   (addr_s1_bp_v),                  
        .addr_rom       (addr_rom    ),                  
        .done           (done        ),                  
        .we_s0          (we_s0       ),                   
        .we_s0_bp       (we_s0_bp    ),                   
        .we_s1          (we_s1       ),                   
        .we_s1_bp       (we_s1_bp    )                    
        );

    rom_psi rom_psi_2560_16(
        .clka(clk),
        .addra(addr_rom),
        .douta(psi_omega)
    );
            
    butterfly PE(
        .clk        (clk        ),
        .sel        (sel_delay9 ),          //sel_delay
        .i_u_wire   (i_u_wire   ),
        .i_v_wire   (i_v_wire   ),
        .psi_omega  (psi_omega  ),
        .o_u_reg    (o_u_reg    ),
        .o_v_reg    (o_v_reg    )
        );
    
    bram_s0 bram_s0_1024_16(
    .clka(clk),
    .wea(we_s0),
    .addra(addr_s0_u),
    .dina(o_u_reg),
    .douta(s0_u_dout),
    .clkb(clk),
    .web(we_s0),
    .addrb(addr_s0_v),
    .dinb(o_v_reg),
    .doutb(s0_v_dout)
    );
    
    bram_s0 bram_s0_bp_1024_16(
    .clka(clk),
    .wea(we_s0_bp),
    .addra(addr_s0_bp_u),
    .dina(o_u_reg),
    .douta(s0_bp_u_dout),
    .clkb(clk),
    .web(we_s0_bp),
    .addrb(addr_s0_bp_v),
    .dinb(o_v_reg),
    .doutb(s0_bp_v_dout)
    );
    
    bram_s1 bram_s1_1024_16(
    .clka(clk),
    .wea(sel_delay10? 1'b0:we_s1),
    .addra(addr_s1_u),
    .dina(o_u_reg),
    .douta(s1_u_dout),
    .clkb(clk),
    .web(we_s1),
    .addrb(addr_s1_v),
    .dinb(o_v_reg),
    .doutb(s1_v_dout)
    );
    
    bram_s1 bram_s1_bp_1024_16(
    .clka(clk),
    .wea(we_s1_bp),
    .addra(addr_s1_bp_u),
    .dina(o_u_reg),
    .douta(s1_bp_u_dout),
    .clkb(clk),
    .web(we_s1_bp),
    .addrb(addr_s1_bp_v),
    .dinb(o_v_reg),
    .doutb(s1_bp_v_dout)
    );
endmodule
