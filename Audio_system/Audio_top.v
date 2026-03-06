`timescale 1ns / 1ps

module Audio_top(
    // System Clock and Reset
    input CLOCK_50, 
    input CLOCK2_50, 
    input [0:0] KEY, 
    
    // I2C Interface for Configuration
    output FPGA_I2C_SCLK, 
    inout  FPGA_I2C_SDAT, 
    
    // Physical Audio CODEC Pins
    output AUD_XCK, 
    input  AUD_ADCLRCK, 
    input  AUD_BCLK, 
    input  AUD_ADCDAT,

    // --- NEW PORTS FOR EXTERNAL CONNECTION ---
    input  read,              // Signal FROM FFT/Project Top to request a sample
    output read_ready,        // Signal TO FFT/Project Top that a sample is available
    output [19:0] readdata_left // 20-bit Audio Data for FFT
);

    // Internal reset logic
    wire reset = ~KEY[0];
    
    //------------------- Internal Module Instantiations -----------------

    // 1. Generates the 12.288 MHz Master Clock for the Wolfson Codec
    clock_generator my_clock_gen(
        .clk      (CLOCK2_50), // 50MHz input
        .reset    (reset),
        .AUD_XCK  (AUD_XCK)    // 12.288MHz output
    );
    
    // 2. I2C Configurator: Sets registers (Vol, Bit-depth, Sample Rate)
    audio_and_video_config cfg(
        .clk      (CLOCK_50),
        .reset    (reset),
        .I2C_SDAT (FPGA_I2C_SDAT),
        .I2C_SCLK (FPGA_I2C_SCLK)
    );

    // 3. Audio Codec Controller: Handles Serial-to-Parallel and FIFO
    audio_codec codec(
        .clk           (CLOCK_50),
        .reset         (reset),
        
        // Handshaking connected to the top-level ports
        .read          (read),          // Input from outside
        .read_ready    (read_ready),    // Output to outside
        
        // Data connected to the top-level ports
        .readdata_left (readdata_left),
        .readdata_right(readdata_right),

        // Physical I/O
        .AUD_ADCDAT    (AUD_ADCDAT),
        .AUD_BCLK      (AUD_BCLK),
        .AUD_ADCLRCK   (AUD_ADCLRCK)
    );    

endmodule