`timescale 1ns / 1ps

module SYNC_FIFO(
clk,
reset,
write_en,
write_data,
read_en,
fifo_is_empty,
fifo_is_full,
words_used,
read_data
    );
    
//-----------------------parameters declaration-------------------
    
parameter	DATA_WIDTH	= 40;   // Keeps 20-bit Left + 20-bit Right
parameter	DATA_DEPTH	= 512;  // Increased to handle 256-point FFT frames
parameter	ADDR_WIDTH	= 9;    // 2^9 = 512

//----------------------ports declaration----------------------

// Inputs
input clk;
input reset;
input write_en;
input [DATA_WIDTH:1] write_data;
input read_en;

// Outputs
output fifo_is_empty;
output fifo_is_full;
output [ADDR_WIDTH:1] words_used;
output [DATA_WIDTH:1] read_data;

//------------------Internal module-------------------
scfifo	Sync_FIFO (
	// Inputs
	.clock			(clk),
	.sclr			(reset),

	.data			(write_data),
	.wrreq			(write_en),

	.rdreq			(read_en),

	// Bidirectionals

	// Outputs
	.empty			(fifo_is_empty),
	.full			(fifo_is_full),
	.usedw			(words_used),
	
	.q				(read_data)

	// Unused
	// synopsys translate_off
	,
	.aclr			(),
	.almost_empty	(),
	.almost_full	()
	// synopsys translate_on
);
defparam
	Sync_FIFO.add_ram_output_register	= "OFF",
	Sync_FIFO.intended_device_family	= "Cyclone II",
	Sync_FIFO.lpm_numwords				= DATA_DEPTH,
	Sync_FIFO.lpm_showahead				= "ON",
	Sync_FIFO.lpm_type					= "scfifo",
	Sync_FIFO.lpm_width					= DATA_WIDTH,
	Sync_FIFO.lpm_widthu				= ADDR_WIDTH,
	Sync_FIFO.overflow_checking			= "OFF",
	Sync_FIFO.underflow_checking		= "OFF",
	Sync_FIFO.use_eab					= "ON";
	
endmodule