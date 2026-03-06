`timescale 1ns / 1ps

module audio_and_video_config(
input clk,
input reset,
inout I2C_SDAT,  //I2C Data
output I2C_SCLK  //I2C Clock
    );

//-----------------------Parameter declaration--------------------
   
parameter I2C_BUS_MODE			= 1'b0;
parameter CFG_TYPE				= 8'h01;

parameter MIN_ROM_ADDRESS		= 6'h00;
parameter MAX_ROM_ADDRESS		= 6'h0A;

parameter AUD_LINE_IN_LC		= 9'h01A;
parameter AUD_LINE_IN_RC		= 9'h01A;
parameter AUD_LINE_OUT_LC		= 9'h07B;
parameter AUD_LINE_OUT_RC		= 9'h07B;
parameter AUD_ADC_PATH			= 9'd145; 
// change AUD_ADC_PATH to 9'd145 for using LineIn instead of Mic
parameter AUD_DAC_PATH			= 9'h008;
parameter AUD_POWER			= 9'h000;
parameter AUD_DATA_FORMAT		= 9'd69; // 73 for 16 bit, 69 for 20bits
parameter AUD_SAMPLE_CTRL		= 9'd0;
// change AUD_SAMPLE_CTRL to 9'd12 for 8kHz sampling
parameter AUD_SET_ACTIVE		= 9'h001;


// ------------------------Internal Wires------------------------

wire	clk_400KHz;
wire	start_and_stop_en;
wire	change_output_bit_en;

wire	enable_clk;

wire	send_start_bit;
wire	send_stop_bit;

wire	[7:0] auto_init_data;
wire	auto_init_transfer_data;
wire	auto_init_start_bit;
wire	auto_init_stop_bit;
wire	auto_init_complete;
wire	auto_init_error;

wire	transfer_data;
wire	transfer_complete;

wire	i2c_ack;
wire	[7:0] i2c_received_data;

// Internal Registers
reg		[7:0] data_to_transfer;
reg		[2:0] num_bits_to_transfer;

//------------------sequential logic-------------------------

always @(posedge clk)
begin
	if (reset)
	begin
		data_to_transfer		<= 8'h00;
		num_bits_to_transfer	<= 3'h0;
	end
	else
		if (auto_init_complete == 1'b0)
		begin
			data_to_transfer		<= auto_init_data;
			num_bits_to_transfer	<= 3'h7;
		end
end

//------------------------------combinational logic--------------------------

assign transfer_data = auto_init_transfer_data;

assign send_start_bit = auto_init_start_bit;

assign send_stop_bit = auto_init_stop_bit;


//------------------Module instantiation--------------------------------

Slow_Clock_Generator Clock_Generator_400KHz (
	// Inputs
	.clk (clk),
	.reset (reset),
    .enable_clk	(enable_clk),
	
	// Bidirectionals

	// Outputs
	.new_clk (clk_400KHz),
	.rising_edge (),
	.falling_edge (),
    .middle_of_high_level (start_and_stop_en),
	.middle_of_low_level (change_output_bit_en)
);

defparam
	Clock_Generator_400KHz.COUNTER_BITS	= 10, 
	Clock_Generator_400KHz.COUNTER_INC	= 10'h001; 

I2C_AV_Auto_Initialize Auto_Initialize (
	// Inputs
	.clk (clk),
	.reset (reset),
    .clear_error (1'b1),
    .ack (i2c_ack),
	.transfer_complete (transfer_complete),

	// Bidirectionals

	// Outputs
	.data_out (auto_init_data),
	.transfer_data (auto_init_transfer_data),
	.send_start_bit (auto_init_start_bit),
	.send_stop_bit (auto_init_stop_bit),
    .auto_init_complete	(auto_init_complete),
	.auto_init_error (auto_init_error)
);
defparam
	Auto_Initialize.MIN_ROM_ADDRESS	= MIN_ROM_ADDRESS,
	Auto_Initialize.MAX_ROM_ADDRESS	= MAX_ROM_ADDRESS,

	Auto_Initialize.AUD_LINE_IN_LC	= AUD_LINE_IN_LC,
	Auto_Initialize.AUD_LINE_IN_RC	= AUD_LINE_IN_RC,
	Auto_Initialize.AUD_LINE_OUT_LC	= AUD_LINE_OUT_LC,
	Auto_Initialize.AUD_LINE_OUT_RC	= AUD_LINE_OUT_RC,
	Auto_Initialize.AUD_ADC_PATH	= AUD_ADC_PATH,
	Auto_Initialize.AUD_DAC_PATH	= AUD_DAC_PATH,
	Auto_Initialize.AUD_POWER		= AUD_POWER,
	Auto_Initialize.AUD_DATA_FORMAT	= AUD_DATA_FORMAT,
	Auto_Initialize.AUD_SAMPLE_CTRL	= AUD_SAMPLE_CTRL,
	Auto_Initialize.AUD_SET_ACTIVE	= AUD_SET_ACTIVE;

	
I2C I2C_Controller (
	// Inputs
	.clk (clk),
	.reset (reset),
    .clear_ack (1'b1),
    .clk_400KHz (clk_400KHz),
	.start_and_stop_en (start_and_stop_en),
	.change_output_bit_en (change_output_bit_en),
    .send_start_bit	(send_start_bit),
	.send_stop_bit	(send_stop_bit),
    .data_in (data_to_transfer),
	.transfer_data (transfer_data),
	.read_byte (1'b0),
	.num_bits_to_transfer (num_bits_to_transfer),

	// Bidirectionals
	.i2c_sdata (I2C_SDAT),

	// Outputs
	.i2c_sclk (I2C_SCLK),
	.i2c_scen (),
    .enable_clk	(enable_clk),

	.ack (i2c_ack),
	.data_from_i2c (i2c_received_data),
	.transfer_complete (transfer_complete)
);
defparam
	I2C_Controller.I2C_BUS_MODE	= I2C_BUS_MODE;


endmodule

