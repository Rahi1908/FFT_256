`timescale 1ns / 1ps

module I2C_AV_Auto_Initialize(
input clk,
input reset,
input clear_error,
input ack,
input transfer_complete,
output reg [7:0] data_out,
output reg transfer_data,
output reg send_start_bit,
output reg	send_stop_bit,	
output auto_init_complete,
output reg	auto_init_error
    );

//--------------------parameter declarations-------------------------
    

parameter MIN_ROM_ADDRESS	= 6'h00;
parameter MAX_ROM_ADDRESS	= 6'h0A;

parameter AUD_LINE_IN_LC	= 9'h01A;
parameter AUD_LINE_IN_RC	= 9'h01A;
parameter AUD_LINE_OUT_LC	= 9'h07B;
parameter AUD_LINE_OUT_RC	= 9'h07B;
parameter AUD_ADC_PATH		= 9'h014;
parameter AUD_DAC_PATH		= 9'h008;
parameter AUD_POWER			= 9'h000;
parameter AUD_DATA_FORMAT	= 9'h005;  //001 was for 16 bits, 005 for 20 bits
parameter AUD_SAMPLE_CTRL	= 9'h000;
parameter AUD_SET_ACTIVE	= 9'h001;


    
    // States
localparam	AUTO_STATE_0_CHECK_STATUS		= 3'h0,
			AUTO_STATE_1_SEND_START_BIT		= 3'h1,
			AUTO_STATE_2_TRANSFER_BYTE_1	= 3'h2,
			AUTO_STATE_3_TRANSFER_BYTE_2	= 3'h3,
			AUTO_STATE_4_WAIT				= 3'h4,
			AUTO_STATE_5_SEND_STOP_BIT		= 3'h5,
			AUTO_STATE_6_INCREASE_COUNTER	= 3'h6,
			AUTO_STATE_7_DONE				= 3'h7;
			
	wire change_state;
	wire finished_auto_init;
	reg [5:0] rom_address_counter;
    reg [25:0] rom_data;
    reg	[2:0] ns_i2c_auto_init;
    reg	[2:0] s_i2c_auto_init;
    
//---------------------------------/FSM/-----------------------------------


always @(posedge clk)
begin
	if (reset == 1'b1)
		s_i2c_auto_init <= AUTO_STATE_0_CHECK_STATUS;
	else
		s_i2c_auto_init <= ns_i2c_auto_init;
end

always @(*)
begin
	// Defaults
	ns_i2c_auto_init = AUTO_STATE_0_CHECK_STATUS;

    case (s_i2c_auto_init)
	AUTO_STATE_0_CHECK_STATUS:
		begin
			if (finished_auto_init == 1'b1)
				ns_i2c_auto_init = AUTO_STATE_7_DONE;
			else if (rom_data[25] == 1'b1)
				ns_i2c_auto_init = AUTO_STATE_1_SEND_START_BIT;
			else
				ns_i2c_auto_init = AUTO_STATE_3_TRANSFER_BYTE_2;
		end
	AUTO_STATE_1_SEND_START_BIT:
		begin
			if (change_state == 1'b1)
				ns_i2c_auto_init = AUTO_STATE_2_TRANSFER_BYTE_1;
			else
				ns_i2c_auto_init = AUTO_STATE_1_SEND_START_BIT;
		end
	AUTO_STATE_2_TRANSFER_BYTE_1:
		begin
			if (change_state == 1'b1)
				ns_i2c_auto_init = AUTO_STATE_3_TRANSFER_BYTE_2;
			else
				ns_i2c_auto_init = AUTO_STATE_2_TRANSFER_BYTE_1;
		end
	AUTO_STATE_3_TRANSFER_BYTE_2:
		begin
			if ((change_state == 1'b1) && (rom_data[24] == 1'b1))
				ns_i2c_auto_init = AUTO_STATE_4_WAIT;
			else if (change_state == 1'b1)
				ns_i2c_auto_init = AUTO_STATE_6_INCREASE_COUNTER;
			else
				ns_i2c_auto_init = AUTO_STATE_3_TRANSFER_BYTE_2;
		end
	AUTO_STATE_4_WAIT:
		begin
			if (transfer_complete == 1'b0)
				ns_i2c_auto_init = AUTO_STATE_5_SEND_STOP_BIT;
			else
				ns_i2c_auto_init = AUTO_STATE_4_WAIT;
		end
	AUTO_STATE_5_SEND_STOP_BIT:
		begin
			if (transfer_complete == 1'b1)
				ns_i2c_auto_init = AUTO_STATE_6_INCREASE_COUNTER;
			else
				ns_i2c_auto_init = AUTO_STATE_5_SEND_STOP_BIT;
		end
	AUTO_STATE_6_INCREASE_COUNTER:
		begin
			ns_i2c_auto_init = AUTO_STATE_0_CHECK_STATUS;
		end
	AUTO_STATE_7_DONE:
		begin
			ns_i2c_auto_init = AUTO_STATE_7_DONE;
		end
	default:
		begin
			ns_i2c_auto_init = AUTO_STATE_0_CHECK_STATUS;
		end
	endcase
end

//--------------sequential logic---------------------------

// Output Registers
always @(posedge clk)
begin
	if (reset == 1'b1)
		data_out <= 8'h00;
	else if (s_i2c_auto_init == AUTO_STATE_1_SEND_START_BIT)
		data_out <= rom_data[23:16];
	else if (s_i2c_auto_init == AUTO_STATE_0_CHECK_STATUS)
		data_out <= rom_data[15: 8];
	else if (s_i2c_auto_init == AUTO_STATE_2_TRANSFER_BYTE_1)
		data_out <= rom_data[15: 8];
	else if (s_i2c_auto_init == AUTO_STATE_3_TRANSFER_BYTE_2)
		data_out <= rom_data[ 7: 0];
end

always @(posedge clk)
begin
	if (reset == 1'b1) 
		transfer_data <= 1'b0;
	else if (transfer_complete == 1'b1)
		transfer_data <= 1'b0;
	else if (s_i2c_auto_init == AUTO_STATE_1_SEND_START_BIT)
		transfer_data <= 1'b1;
	else if (s_i2c_auto_init == AUTO_STATE_2_TRANSFER_BYTE_1)
		transfer_data <= 1'b1;
	else if (s_i2c_auto_init == AUTO_STATE_3_TRANSFER_BYTE_2)
		transfer_data <= 1'b1;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		send_start_bit <= 1'b0;
	else if (transfer_complete == 1'b1)
		send_start_bit <= 1'b0;
	else if (s_i2c_auto_init == AUTO_STATE_1_SEND_START_BIT)
		send_start_bit <= 1'b1;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		send_stop_bit <= 1'b0;
	else if (transfer_complete == 1'b1)
		send_stop_bit <= 1'b0;
	else if (s_i2c_auto_init == AUTO_STATE_5_SEND_STOP_BIT)
		send_stop_bit <= 1'b1;
end

always @(posedge clk)
begin
	if (reset == 1'b1)
		auto_init_error <= 1'b0;
	else if (clear_error == 1'b1)
		auto_init_error <= 1'b0;
	else if ((s_i2c_auto_init == AUTO_STATE_6_INCREASE_COUNTER) & ack)
		auto_init_error <= 1'b1;
end

// Internal Registers
always @(posedge clk)
begin
	if (reset == 1'b1)
		rom_address_counter <= MIN_ROM_ADDRESS;
	else if (s_i2c_auto_init == AUTO_STATE_6_INCREASE_COUNTER)
		rom_address_counter <= rom_address_counter + 6'h01;
end

//-----------------------------Combinational logic------------------------------
    
// Output Assignments
assign auto_init_complete = (s_i2c_auto_init == AUTO_STATE_7_DONE);

// Internals Assignments
assign change_state	= transfer_complete & transfer_data;

assign finished_auto_init = (rom_address_counter == MAX_ROM_ADDRESS);

always @ (*)
    begin
        case (rom_address_counter)
	0		:	rom_data	<=	{10'h334, 7'h0, AUD_LINE_IN_LC};
	1		:	rom_data	<=	{10'h334, 7'h1, AUD_LINE_IN_RC};
	2		:	rom_data	<=	{10'h334, 7'h2, AUD_LINE_OUT_LC};
	3		:	rom_data	<=	{10'h334, 7'h3, AUD_LINE_OUT_RC};
	4		:	rom_data	<=	{10'h334, 7'h4, AUD_ADC_PATH};
	5		:	rom_data	<=	{10'h334, 7'h5, AUD_DAC_PATH};
	6		:	rom_data	<=	{10'h334, 7'h6, AUD_POWER};
	7		:	rom_data	<=	{10'h334, 7'h7, AUD_DATA_FORMAT};
	8		:	rom_data	<=	{10'h334, 7'h8, AUD_SAMPLE_CTRL};
	9		:	rom_data	<=	{10'h334, 7'h9, AUD_SET_ACTIVE};
	default	:	rom_data	<=	26'h1000000;
        endcase
    end

endmodule