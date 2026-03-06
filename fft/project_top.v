`timescale 1ns / 1ps

module project_top(
    // Clocks and Reset
    input CLOCK_50, 
    input CLOCK2_50, 
    input [0:0] KEY, 
    
    // I2C Interface
    output FPGA_I2C_SCLK, 
    inout  FPGA_I2C_SDAT, 
    
    // Audio CODEC Physical Pins
    output AUD_XCK, 
    input  AUD_ADCLRCK, 
    input  AUD_BCLK, 
    input  AUD_ADCDAT,
    
    // FFT Results (Exported for Testbench/MATLAB)
    output [19:0] fft_real_out,
    output [19:0] fft_imag_out,
    output fft_valid_pulse
);

    // Internal Reset
    wire reset = ~KEY[0];

    // Interconnect Wires
    wire [19:0] audio_bus;    // 20-bit audio data
    wire audio_ready;         // High when codec has a sample
    wire fft_read_ack;        // High when FFT consumes a sample

    // ---------------------------------------------------------
    // 1. Audio System Instance
    // ---------------------------------------------------------
    // This module handles I2C config, I2S deserializing, and FIFO
    Audio_top audio_subsystem (
        .CLOCK_50       (CLOCK_50),
        .CLOCK2_50      (CLOCK2_50),
        .KEY            (KEY),
        .FPGA_I2C_SCLK  (FPGA_I2C_SCLK),
        .FPGA_I2C_SDAT  (FPGA_I2C_SDAT),
        .AUD_XCK        (AUD_XCK),
        .AUD_ADCLRCK    (AUD_ADCLRCK),
        .AUD_BCLK       (AUD_BCLK),
        .AUD_ADCDAT     (AUD_ADCDAT),
        
        // Connect to the bridge
        .read_ready     (audio_ready),   // Output: "Sample is ready"
        .read           (fft_read_ack),  // Input: "FFT is taking it"
        .readdata_left  (audio_bus)     // 20-bit sample
    );

    // ---------------------------------------------------------
    // 2. The Bridge Logic
    // ---------------------------------------------------------
    // In many I2S-to-FFT designs, we simply 'read' whenever data is 'ready'.
    // This pops the sample from the FIFO and sends it into the FFT buffer.
    assign fft_read_ack = audio_ready;

    // ---------------------------------------------------------
    // 3. FFT Processor Instance
    // ---------------------------------------------------------
    fft_top my_fft_processor (
        .clk      (CLOCK_50),
        .reset    (reset),
        
        // Inputs from Audio_top
        .realin   (audio_bus),     // 20-bit signed audio
        .imagin   (20'd0),         // Real audio has no imaginary part
        .startin  (audio_ready),   // FFT captures when data is ready
        
        // Outputs to Top-Level
        .realout  (fft_real_out),
        .imagout  (fft_imag_out),
        .startout (fft_valid_pulse) // High when FFT results are ready
    );

endmodule