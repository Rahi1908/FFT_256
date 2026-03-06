`timescale 1ns / 1ps

module testbench();
// ---------------------------------------------------------
    // 1. Signal Declarations
    // ---------------------------------------------------------
    reg clk;
    reg reset;
    reg [19:0] realin, imagin;
    reg startin;

    wire [19:0] realout, imagout;
    wire startout;

    // Memories to store the hex values from MATLAB
    reg [19:0] real_mem [0:255];
    reg [19:0] imag_mem [0:255];
    
    integer i;
    integer f_real, f_imag;

    // ---------------------------------------------------------
    // 2. Unit Under Test (UUT) Instance
    // ---------------------------------------------------------
    fft DUT (
        .clk(clk),
        .reset(reset),
        .realin(realin),
        .imagin(imagin),
        .startin(startin),
        .realout(realout),
        .imagout(imagout),
        .startout(startout)
    );

    // ---------------------------------------------------------
    // 3. Clock Generation (50MHz = 20ns Period)
    // ---------------------------------------------------------
    initial clk = 0;
    always #10 clk = ~clk; // Toggle every 10ns for a 20ns cycle

    // ---------------------------------------------------------
    // 4. Stimulus Process
    // ---------------------------------------------------------
    initial begin
        // Load MATLAB generated files from the simulation directory
        $readmemh("real_in.txt", real_mem);
        $readmemh("imag_in.txt", imag_mem);

        // Prepare output files for MATLAB analysis
        f_real = $fopen("real_out.txt", "w");
        f_imag = $fopen("imag_out.txt", "w");

        // Initialize Inputs
        reset = 1;
        startin = 0;
        realin = 20'd0;
        imagin = 20'd0;

        // Reset Pulse
        #100;           // Wait 100ns
        reset = 0;      // Release reset
        #40;            // Wait 2 clock cycles
        
        $display("--- Starting Data Input ---");

        // E. Feed 256 Samples to the FFT
        // We pulse startin for the first sample and then stream data
        for (i = 0; i < 256; i = i + 1) begin
            @(posedge clk);
            startin = (i == 0); // startin is 1 only for the first sample
            realin  = real_mem[i];
            imagin  = imag_mem[i];
        end

        // F. Clean up inputs after 256 samples
        @(posedge clk);
        startin = 0;
        realin  = 20'd0;
        imagin  = 20'd0;

        // G. Wait for the FFT to finish (Wait for startout handshake)
        $display("--- Waiting for FFT Calculation ---");
        wait(startout == 1);
        $display("--- FFT Output Detected at %t ---", $time);

        // H. Capture 256 output samples into text files
        for (i = 0; i < 256; i = i + 1) begin
            @(posedge clk); // Capture data on the clock edge
            $fwrite(f_real, "%h\n", realout);
            $fwrite(f_imag, "%h\n", imagout);
        end

        // I. Close files and end simulation
        $fclose(f_real);
        $fclose(f_imag);
        $display("--- Simulation Success: Files generated ---");
        
        #200;
        $finish;
    end
    
endmodule
