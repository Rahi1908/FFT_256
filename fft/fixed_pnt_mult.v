`timescale 1ns / 1ps

module fixed_pnt_mult (
    input  signed [29:0] data_in,
    input  signed [21:0] twiddle_in,
    input  clock, reset,
    output signed [29:0] product_30bit
);

    wire signed [51:0] full_prod;

    mult_4_stages inner_mult (
        .clk(clock),
        .reset(reset),
        .data_in(data_in),
        .twiddle_in(twiddle_in),
        .product_out(full_prod)
    );

    // Scaling/Truncation logic:
    // Twiddle is 1.21 format (20 fractional bits + 1 sign + 1 integer bit)
    // To maintain decimal alignment, we shift right by 20.
    assign product_30bit = full_prod[49:20]; 

endmodule
