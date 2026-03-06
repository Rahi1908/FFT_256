`timescale 1ns / 1ps


module audio_codec(
// Inputs
clk,
reset,
read,
AUD_ADCDAT,

// Bidirectionals
AUD_BCLK,
AUD_ADCLRCK,

// Outputs
read_ready,
readdata_left,
readdata_right
    );
    
//----------------parameters------------------
parameter AUDIO_DATA_WIDTH	= 20;
parameter BIT_COUNTER_INIT	= 5'h13;

input clk;
input reset;
input read;
input AUD_ADCDAT;
input AUD_BCLK;
input AUD_ADCLRCK;
output read_ready;
output	[AUDIO_DATA_WIDTH-1:0]	readdata_left;
output	[AUDIO_DATA_WIDTH-1:0]	readdata_right;

//------------------------Internal wires------------------------

wire bclk_rising_edge;
wire bclk_falling_edge;

wire adc_lrclk_rising_edge;
wire adc_lrclk_falling_edge;

wire [AUDIO_DATA_WIDTH:1] new_left_channel_audio;
wire [AUDIO_DATA_WIDTH:1] new_right_channel_audio;

wire [9:0] left_channel_read_available;
wire [9:0] right_channel_read_available;

// Internal Registers
reg done_adc_channel_sync;

//----------------sequential logic----------------
always @ (posedge clk)
begin
	if (reset == 1'b1)
		done_adc_channel_sync <= 1'b0;
	else if (adc_lrclk_rising_edge == 1'b1)
		done_adc_channel_sync <= 1'b1;
end

//----------------combinational logic-------------------

assign read_ready = (left_channel_read_available != 10'd0);
assign readdata_left  = new_left_channel_audio;
assign readdata_right = {AUDIO_DATA_WIDTH{1'b0}};//disabled

//---------------------Internal modules-------------------------

Clock_Edge Bit_Clock_Edges (
	// Inputs
	.clk			(clk),
	.reset		(reset),
	
	.test_clk		(AUD_BCLK),
	
	// Bidirectionals

	// Outputs
	.rising_edge	(bclk_rising_edge),
	.falling_edge	(bclk_falling_edge)
);

Clock_Edge ADC_Left_Right_Clock_Edges (
	// Inputs
	.clk			(clk),
	.reset		(reset),
	
	.test_clk		(AUD_ADCLRCK),
	
	// Bidirectionals

	// Outputs
	.rising_edge	(adc_lrclk_rising_edge),
	.falling_edge	(adc_lrclk_falling_edge)
);

Audio_In_Deserializer Audio_In_Deserializer (
	// Inputs
	.clk						(clk),
	.reset					(reset),
	
	.bit_clk_rising_edge			(bclk_rising_edge),
	.bit_clk_falling_edge			(bclk_falling_edge),
	.left_right_clk_rising_edge		(adc_lrclk_rising_edge),
	.left_right_clk_falling_edge		(adc_lrclk_falling_edge),

	.done_channel_sync			(done_adc_channel_sync),

	.serial_audio_in_data			(AUD_ADCDAT),

	.read_left_audio_data_en		(read & (left_channel_read_available != 10'd0)),
	.read_right_audio_data_en		(1'b0), //diabled

	// Bidirectionals

	// Outputs
	.left_audio_fifo_read_space		(left_channel_read_available),
	.right_audio_fifo_read_space		(right_channel_read_available),

	.left_channel_data			(new_left_channel_audio),
	.right_channel_data			(new_right_channel_audio)
);
defparam
	Audio_In_Deserializer.AUDIO_DATA_WIDTH = AUDIO_DATA_WIDTH,
	Audio_In_Deserializer.BIT_COUNTER_INIT = BIT_COUNTER_INIT;

endmodule

