`timescale 1ns / 1ps

module complex_mul (A_real, A_imaginary, B_real, B_imaginary, product_real, product_imaginary,clock,reset);

input signed [29:0] A_real, A_imaginary;
input signed [21:0] B_real, B_imaginary;
input clock,reset;

output signed [29:0] product_real, product_imaginary;

wire signed [29:0] A_real_B_real, A_imaginary_B_imaginary;
wire signed [29:0] A_real_B_imaginary, A_imaginary_B_real;

fixed_pnt_mult M1 (.data_in(A_real), 
	   	    .twiddle_in(B_real), 
		    .product_30bit(A_real_B_real),
		    .clock(clock),.reset(reset));

fixed_pnt_mult M2 (.data_in(A_imaginary), 
	            .twiddle_in(B_imaginary), 
		    .product_30bit(A_imaginary_B_imaginary),
		    .clock(clock),.reset(reset));

fixed_pnt_mult M3 (.data_in(A_real), 
		    .twiddle_in(B_imaginary), 
		    .product_30bit(A_real_B_imaginary),
		    .clock(clock),.reset(reset));

fixed_pnt_mult M4 (.data_in(A_imaginary), 
		    .twiddle_in(B_real), 
		    .product_30bit(A_imaginary_B_real),
		    .clock(clock),.reset(reset));

assign product_real      = A_real_B_real - A_imaginary_B_imaginary;
assign product_imaginary = A_real_B_imaginary + A_imaginary_B_real;

endmodule
