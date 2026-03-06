`timescale 1ns / 1ps

module Audio_In_Deserializer(
clk,
reset,
bit_clk_rising_edge,
bit_clk_falling_edge,
left_right_clk_rising_edge,
left_right_clk_falling_edge,
done_channel_sync,
serial_audio_in_data,
read_left_audio_data_en,
read_right_audio_data_en,

// Outputs
left_audio_fifo_read_space,
right_audio_fifo_read_space,
left_channel_data,
right_channel_data
    );
    
parameter AUDIO_DATA_WIDTH	= 20;
parameter BIT_COUNTER_INIT	= 5'h13;

// Inputs
input clk;
input reset;
input bit_clk_rising_edge;
input bit_clk_falling_edge;
input left_right_clk_rising_edge;
input left_right_clk_falling_edge;
input done_channel_sync;
input serial_audio_in_data;
input read_left_audio_data_en;
input read_right_audio_data_en;

// Outputs
output	reg	[9:0]	left_audio_fifo_read_space;
output	reg	[9:0]	right_audio_fifo_read_space;
output [AUDIO_DATA_WIDTH:1] left_channel_data;
output [AUDIO_DATA_WIDTH:1]	right_channel_data;

// Internal Wires
wire valid_audio_input;

wire left_channel_fifo_is_empty;
wire right_channel_fifo_is_empty;

wire left_channel_fifo_is_full;
wire right_channel_fifo_is_full;

wire [8:0] left_channel_fifo_used;
wire [8:0] right_channel_fifo_used;

// Internal Registers
reg	[AUDIO_DATA_WIDTH:1] data_in_shift_reg;

//---------------------sequential logic--------------------------

always @(posedge clk)
begin
	if (reset == 1'b1)
		left_audio_fifo_read_space			<= 10'h00;
	else
	begin
		left_audio_fifo_read_space[9]		<= left_channel_fifo_is_full;
		left_audio_fifo_read_space[8:0]		<= left_channel_fifo_used;
	end
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		right_audio_fifo_read_space			<= 10'h00;
	else
	   right_audio_fifo_read_space <= 10'h00;  // disabled as we are using only left channel
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		data_in_shift_reg	<= {AUDIO_DATA_WIDTH{1'b0}};
	else if (bit_clk_rising_edge & valid_audio_input)
		data_in_shift_reg	<= 
			{data_in_shift_reg[(AUDIO_DATA_WIDTH - 1):1], 
			 serial_audio_in_data};
end

//---------------------------Internal modules----------------------------
Audio_Bit_Counter Audio_Out_Bit_Counter (
	// Inputs
	.clk							(clk),
	.reset							(reset),
	
	.bit_clk_rising_edge			(bit_clk_rising_edge),
	.bit_clk_falling_edge			(bit_clk_falling_edge),
	.left_right_clk_rising_edge		(left_right_clk_rising_edge),
	.left_right_clk_falling_edge	(left_right_clk_falling_edge),

	// Bidirectionals

	// Outputs
	.counting						(valid_audio_input)
);
defparam 
	Audio_Out_Bit_Counter.BIT_COUNTER_INIT	= BIT_COUNTER_INIT;

SYNC_FIFO Audio_In_Left_Channel_FIFO(
	// Inputs
	.clk			(clk),
	.reset			(reset),

	.write_en		(left_right_clk_falling_edge & ~left_channel_fifo_is_full & done_channel_sync),
	.write_data		(data_in_shift_reg),

	.read_en		(read_left_audio_data_en & ~left_channel_fifo_is_empty),
	
	// Bidirectionals

	// Outputs
	.fifo_is_empty	(left_channel_fifo_is_empty),
	.fifo_is_full	(left_channel_fifo_is_full),
	.words_used		(left_channel_fifo_used),

	.read_data		(left_channel_data)
);
defparam 
	Audio_In_Left_Channel_FIFO.DATA_WIDTH	= AUDIO_DATA_WIDTH,
	Audio_In_Left_Channel_FIFO.DATA_DEPTH	= 512,
	Audio_In_Left_Channel_FIFO.ADDR_WIDTH	= 9;


SYNC_FIFO Audio_In_Right_Channel_FIFO(
	// Inputs
	.clk			(clk),
	.reset			(reset),

	.write_en		(1'b0), //disabled
	.write_data		(data_in_shift_reg),

	.read_en		(1'b0), //disabled
	
	// Bidirectionals

	// Outputs
	.fifo_is_empty	(right_channel_fifo_is_empty),
	.fifo_is_full	(right_channel_fifo_is_full),
	.words_used		(right_channel_fifo_used),

	.read_data		(right_channel_data)
);
defparam 
	Audio_In_Right_Channel_FIFO.DATA_WIDTH	= AUDIO_DATA_WIDTH,
	Audio_In_Right_Channel_FIFO.DATA_DEPTH	= 512,
	Audio_In_Right_Channel_FIFO.ADDR_WIDTH	= 9;
	  
endmodule

