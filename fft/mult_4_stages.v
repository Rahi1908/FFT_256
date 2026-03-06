`timescale 1ns / 1ps

module mult_4_stages(
input  wire clk,
input  wire reset,
input  wire signed [29:0] data_in,    // 30-bit Data
input  wire signed [21:0] twiddle_in, // 22-bit Twiddle
output wire signed [51:0] product_out // 52-bit Result (30+22)
    );
    
    // Stage 1: Input Latency Registers
    reg signed [29:0] data_r1;
    reg signed [21:0] twid_r1;

    // Stage 2: Multiplication Result Register
    reg signed [51:0] mult_r2;

    // Stage 3: Pipeline Register for Timing
    reg signed [51:0] pipe_r3;

    // Stage 4: Output Register
    reg signed [51:0] out_r4;

    always @(posedge clk) begin
        if (reset) begin
            data_r1 <= 0;
            twid_r1 <= 0;
            mult_r2 <= 0;
            pipe_r3 <= 0;
            out_r4  <= 0;
        end else begin
            // STAGE 1: Capture Inputs
            data_r1 <= data_in;
            twid_r1 <= twiddle_in;

            // STAGE 2: Perform Signed Multiplication
            mult_r2 <= data_r1 * twid_r1;

            // STAGE 3: Intermediate Pipeline
            pipe_r3 <= mult_r2;

            // STAGE 4: Final Output Register
            out_r4  <= pipe_r3;
        end
    end

    assign product_out = out_r4;
endmodule
