module nios_small_pio(
  CLK_I ,
  RST_I ,
  BUT_I ,
  LED0_O,
  LED1_O,
  TEST_O);

  input CLK_I ;
  input RST_I ;
  input BUT_I ;
  output [4-1:0] LED0_O;
  output [4-1:0] LED1_O;
  output         TEST_O;

  wire [8-1:0] W_U_timer_CNTVAL;
  timer U_timer(
  .CLK_I   (CLK_I),
  .CNTVAL  (W_U_timer_CNTVAL));
  

  wire [8-1:0] W_U_bcnt_CNTVAL;
  button_counter U_bcnt(
    .CLK_I   (CLK_I           ),
    .BUT_I   (BUT_I           ),
    .CNTVAL  (W_U_bcnt_CNTVAL));
  
  nios_cpu U_nios ( 
  .clk_0                       (CLK_I            ),    // input            clk_0;
  .out_port_from_the_pio_0_out (LED0_O           ),    // output  [  3: 0] out_port_from_the_pio_0_out;
  .out_port_from_the_pio_1_out (LED1_O           ),    // output  [  3: 0] out_port_from_the_pio_1_out;
  .in_port_to_the_pio_2_in     (W_U_timer_CNTVAL ),    // input   [  7: 0] in_port_to_the_pio_2_in;
  .in_port_to_the_pio_3_in     (W_U_bcnt_CNTVAL  ),    // input   [  7: 0] in_port_to_the_pio_3_in;
  .reset_n                     (~RST_I           ));   // input            reset_n;


endmodule
////////////////////////////////////////////////////////////////////////////////
module button_counter(
CLK_I   ,
BUT_I   ,
CNTVAL  );
input           CLK_I, BUT_I;
output  [8-1:0] CNTVAL;
assign CNTVAL = W_U_but_cnt255_CNTVAL;
  wire W_U_but_in_out_OUT;
 
  button_in_out U_but_in_out(
  .CLK    (CLK_I                ),   // clock
  .IN     (BUT_I                ),   // input button signal
  .OUT    (W_U_but_in_out_OUT   ));  // output button signal

  wire W_U_nedge_PEDGE_O;
  get_negedge U_nedge(
  .CLK_I  (CLK_I                ),
  .IN     (W_U_but_in_out_OUT   ),
  .NEDGE_O(W_U_nedge_PEDGE_O    ));
  
  wire[8-1:0] W_U_but_cnt255_CNTVAL;
  cnt_en_0to255 U_but_cnt255(
  .CLK   (CLK_I                 ),   // clock
  .CNTVAL(W_U_but_cnt255_CNTVAL ),   // counter value
  .EN    (W_U_nedge_PEDGE_O     ),   // counter enable
  .OV    (            ));  // overflow

endmodule 

////////////////////////////////////////////////////////////////////////////////
module timer(
CLK_I   ,
CNTVAL  );
input           CLK_I   ;
output [8-1:0]  CNTVAL  ;

  assign CNTVAL = W_U_timer_cnt255_CNTVAL;
 
  wire [8-1:0] W_U_timer_cnt255_CNTVAL;
  cnt_en_0to255 U_timer_cnt255(
  .CLK   (CLK_I                     ),   // clock
  .CNTVAL(W_U_timer_cnt255_CNTVAL   ),   // counter value
  .EN    (W_U_timer_OV              ),   // counter enable
  .OV    (                          ));  // overflow

  wire W_U_timer_OV ;   

  cnt_sync U_timer(
  .CLK   (CLK_I),   // clock
  .CNTVAL(),   // counter value
  .OV    (W_U_timer_OV));  // overflow
endmodule
////////////////////////////////////////////////////////////////////////////////
module cnt_sync(
  CLK   ,   // clock
  CNTVAL,   // counter value
  OV    );  // overflow
input CLK;
output [32-1:0] CNTVAL;
output OV;
parameter MAX_VAL = 25_000_000;
reg [32-1:0] CNTVAL;
reg OV;

always @ (posedge CLK) begin
  if(CNTVAL >= MAX_VAL)
    CNTVAL <= 0;
  else
    CNTVAL <= CNTVAL + 1'b1;
end

always @ (CNTVAL) begin
  if(CNTVAL == MAX_VAL)
    OV = 1'b1;
  else
    OV = 1'b0;
end

endmodule   // module cnt_en_0to9
////////////////////////////////////////////////////////////////////////////////

module cnt_en_0to255(
  CLK   ,   // clock
  CNTVAL,   // counter value
  EN    ,
  OV    );  // overflow
input CLK;
input EN;
output [8-1:0] CNTVAL;
output OV;

reg [8-1:0] CNTVAL;
reg OV;

always @ (posedge CLK) begin
  if(EN) begin  // work enable
    if(CNTVAL >= 255)
      CNTVAL <= 0;
    else
      CNTVAL <= CNTVAL + 1'b1;
  end
  else
    CNTVAL <= CNTVAL ;  // hold same value
end

always @ (CNTVAL) begin
  if(CNTVAL == 255)
    OV = 1'b1;
  else
    OV = 1'b0;
end

endmodule   // module cnt_en_0to255

  
////////////////////////////////////////////////////////////////////////////////
//  module button_in_out()
//  功能：模块用于按键输入，带有去抖电路
//  作者：杜伟韬 
////////////////////////////////////////////////////////////////////////////////
// 按键去抖原理：使用计数器，计数器每隔20毫秒会达到最大值然后溢出，在计数器达到
// 溢出值的 8/8， 7/8, 6/8, 0/8 时刻对按键的值进行采样，如果全部采样值相同则说明
// 没有抖动发生输出采样值，否则认为发生了抖动，输出值保持不变
// 时间轴方向 ---------------------------------------------->
// 按键采样值  :v0,            v1,      v2       v3
// 计数器值    :0, 1, 2,  .... 6/8 max, 7/8 max, max
//              |<------计数器溢出时间 10ms------->|
//
// 模块的重用，根据时钟速率，合理配置计数器的溢出值，使得溢出时间为10毫秒
////////////////////////////////////////////////////////////////////////////////
module button_in_out(
  CLK       ,   // clock
  IN     ,   // input button signal
  OUT    );  // output button signal

// 50MHz clock, T = 20ns = 20*1E-6 ms
// button check time = 20*1E-6 * 2^20, about 20ms 
// set the CNT_WL with your system clock freq
parameter CNT_WL          = 20  ;               // counter word length


// 合理配置计数器溢出值，10到20毫秒溢出一次
// 当前时钟周期，20ns，溢出值为 250_000，每5毫秒溢出一次
parameter CNT_MAX         = 20'd250_000          ;  // counter max value


parameter CNT_MAX68       = (CNT_MAX >> 3) * 6  ; // 6/8 counter max value
parameter CNT_MAX78       = (CNT_MAX >> 3) * 7  ; // 7/8 counter max value

input   CLK, IN;
output  OUT;

reg     button_in_d1R, button_in_d2R;
reg     [CNT_WL-1:0] counterR;    
reg     buttonIn0R, buttonIn1R, buttonIn2R, buttonIn3R, buttonOutR;
assign  OUT = buttonOutR;
// 输入信号跨时钟域，使用2个级联的D触发器把按键信号引导进入
// FPGA的时钟域，避免采样到按键信号的跳变边沿
always @ (posedge CLK) begin
  button_in_d1R <= IN;
  button_in_d2R <= button_in_d1R;
end
// 由于本模块可以用于复位按键，故本模块的触发器均不使用复位信号
always @ (posedge CLK) begin
  if(counterR == 0)
    buttonIn0R <= button_in_d2R;
  else
    buttonIn0R <= buttonIn0R;

  if(counterR == CNT_MAX68)
    buttonIn1R <= button_in_d2R;
  else
    buttonIn1R <= buttonIn1R;

  if(counterR == CNT_MAX78)
    buttonIn2R <= button_in_d2R;
  else
    buttonIn2R <= buttonIn2R;

  if(counterR == CNT_MAX)
    buttonIn3R <= button_in_d2R;
  else
    buttonIn3R <= buttonIn3R;

end
// different values of button input buffers will start the counter 
always @(posedge CLK) begin
  if(counterR < CNT_MAX)
    counterR <= counterR + 1;
  else
    counterR <= 0;
end
always @(posedge CLK) begin
  if(buttonIn0R == buttonIn1R == buttonIn2R == buttonIn3R )
    buttonOutR <= buttonIn3R;
  else
    buttonOutR <= buttonOutR;
end

endmodule   // module button_in_out() 
////////////////////////////////////////////////////////////////////////////////  
module get_negedge(
  CLK_I  ,
  IN     ,
  NEDGE_O);
input CLK_I, IN;
output NEDGE_O;

reg R1_in, NEDGE_O;

always @ (posedge CLK_I)begin
  R1_in <= IN;
  if((IN == 1'b0) && (R1_in == 1'b1)) begin
    NEDGE_O <= 1'b1;
  end
  else begin
    NEDGE_O <= 1'b0;
  end
end

endmodule
  
  
  
