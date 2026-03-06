`timescale 1ns / 1ps

module input_int_buffer ( clock, reset, read, startin, write_to_int, startFSM, realin, imagin, read_addr0, read_addr1, read_addr2, read_addr3, read_addr4, read_addr5, read_addr6, read_addr7, r_data0, r_data1, r_data2, r_data3, r_data4, r_data5, r_data6, r_data7, i_data0, i_data1, i_data2, i_data3, i_data4, i_data5, i_data6, i_data7, rin0, rin1, rin2, rin3, rin4, rin5, rin6, rin7, iin0, iin1, iin2, iin3, iin4, iin5, iin6, iin7, w_addr0, w_addr1, w_addr2, w_addr3, w_addr4, w_addr5, w_addr6, w_addr7);

input clock, reset, read, startin, write_to_int;

input signed [19:0] realin, imagin;
input signed [29:0] rin0, rin1, rin2, rin3, rin4, rin5, rin6, rin7, iin0, iin1, iin2, iin3, iin4, iin5, iin6, iin7;

input [7:0] read_addr0, read_addr1, read_addr2, read_addr3, read_addr4, read_addr5, read_addr6, read_addr7;
input [7:0] w_addr0, w_addr1, w_addr2, w_addr3, w_addr4, w_addr5, w_addr6, w_addr7;

output signed [29:0] r_data0, r_data1, r_data2, r_data3, r_data4, r_data5, r_data6, r_data7, i_data0, i_data1, i_data2, i_data3, i_data4, i_data5, i_data6, i_data7;
output startFSM;

wire [7:0] address;
wire write, _start_FSM;

assign startFSM = _start_FSM;

bit_reversal BR (.reset(reset), .clock(clock), .startin(startin), .address(address), .write(write));

buffer BUF (.clock(clock), .reset(reset), .realin(realin), .imagin(imagin), .address(address), .write_to_input_buffer(write), 
.read_to_intermediate_buffer(read), .read_addr0(read_addr0), .read_addr1(read_addr1), .read_addr2(read_addr2), .read_addr3(read_addr3),
 .read_addr4(read_addr4), .read_addr5(read_addr5), .read_addr6(read_addr6), .read_addr7(read_addr7), .r_data0(r_data0), .r_data1(r_data1), 
 .r_data2(r_data2), .r_data3(r_data3), .r_data4(r_data4), .r_data5(r_data5), .r_data6(r_data6), .r_data7(r_data7), .i_data0(i_data0), 
 .i_data1(i_data1), .i_data2(i_data2), .i_data3(i_data3), .i_data4(i_data4), .i_data5(i_data5), .i_data6(i_data6), .i_data7(i_data7), 
 .start_FSM(_start_FSM), .write_from_FSM(write_to_int), .real_in0(rin0), .real_in1(rin1), .real_in2(rin2), .real_in3(rin3), .real_in4(rin4), 
 .real_in5(rin5), .real_in6(rin6), .real_in7(rin7), .imag_in0(iin0), .imag_in1(iin1), .imag_in2(iin2), .imag_in3(iin3), .imag_in4(iin4), 
 .imag_in5(iin5), .imag_in6(iin6), .imag_in7(iin7), .write_addr0(w_addr0), .write_addr1(w_addr1), .write_addr2(w_addr2), .write_addr3(w_addr3), 
 .write_addr4(w_addr4), .write_addr5(w_addr5), .write_addr6(w_addr6), .write_addr7(w_addr7));




endmodule
