`timescale 1ns / 1ps

module Slow_Clock_Generator(
input clk,                           //Fast system clock 50MHz
input reset,                         //Clears logic
input enable_clk,                    //Enables slow clock
output reg new_clk,                  //Slow generated clock
output reg rising_edge,              //Goes HIGH exactly when new_clk rises
output reg falling_edge,             //Goes HIGH exactly when new_clk falls
output reg middle_of_high_level,     //Pulse mid HIGH
output reg middle_of_low_level       //Pulse mid LOW
   );
   
 parameter COUNTER_BITS	= 10;          //sets the clock division factor
 parameter COUNTER_INC	= 10'h001;     //controls the increment step
 
 reg [COUNTER_BITS:1] clk_counter;
 
 always @ (posedge clk)  // Counter logic
    begin
        if(reset == 1'b1)
            clk_counter <= {COUNTER_BITS{1'b0}};
        else if (enable_clk == 1'b1)
            clk_counter <= clk_counter + COUNTER_INC;
    end
   
 always @ (posedge clk)                           //50 MHz clk → counter → MSB ≈ 50 MHz / 1024 ≈ 48.8 kHz
    begin
        if (reset == 1'b1)
            new_clk <= 1'b0;
        else
            new_clk <= clk_counter[COUNTER_BITS];
    end
    
 always @(posedge clk)
    begin
	   if (reset == 1'b1)
		  rising_edge	<= 1'b0;
	   else
		  rising_edge	<= (clk_counter[COUNTER_BITS] ^ new_clk) & ~new_clk;
    end

always @(posedge clk)
    begin
	   if (reset == 1'b1)
		  falling_edge <= 1'b0;
	   else
		  falling_edge <= (clk_counter[COUNTER_BITS] ^ new_clk) & new_clk;
    end
    
always @(posedge clk)
    begin
	   if (reset == 1'b1)
		  middle_of_high_level <= 1'b0;
	   else
		  middle_of_high_level <= 
		  clk_counter[COUNTER_BITS] & 
		  ~clk_counter[(COUNTER_BITS - 1)] &
		  (&(clk_counter[(COUNTER_BITS - 2):1]));
    end

always @(posedge clk)
    begin
	   if (reset == 1'b1)
		  middle_of_low_level <= 1'b0;
	   else
		  middle_of_low_level <= 
		  ~clk_counter[COUNTER_BITS] & 
		  ~clk_counter[(COUNTER_BITS - 1)] &
		  (&(clk_counter[(COUNTER_BITS - 2):1]));
    end
 
endmodule
