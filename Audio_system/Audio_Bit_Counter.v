`timescale 1ns / 1ps

module Audio_Bit_Counter(
input clk,
input reset,
input bit_clk_rising_edge,
input bit_clk_falling_edge,
input left_right_clk_rising_edge,
input left_right_clk_falling_edge,
output reg counting
    );
    
    parameter BIT_COUNTER_INIT	= 5'h13;  //If you want 16 bit audio output then 5'h0F for 20 bits 5'h13
    
    wire reset_bit_counter;
    reg	 [4:0] bit_counter;
    
 //---------------------sequential logic----------------------   
 
always @(posedge clk)
begin
	if (reset == 1'b1)
		bit_counter <= 5'h00;
	else if (reset_bit_counter == 1'b1)
		bit_counter <= BIT_COUNTER_INIT;
	else if ((bit_clk_falling_edge == 1'b1) && (bit_counter != 5'h00))
		bit_counter <= bit_counter - 5'h01;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		counting <= 1'b0;
	else if (reset_bit_counter == 1'b1)
		counting <= 1'b1;
	else if ((bit_clk_falling_edge == 1'b1) && (bit_counter == 5'h00))
		counting <= 1'b0;
end

//----------------------------combinational logic-------------------------

assign reset_bit_counter = left_right_clk_rising_edge | 
							left_right_clk_falling_edge;
							
    
endmodule
