`timescale 1ns / 1ps

module vga_tb();
// Inputs
    reg clk;
    reg rst;
    // Outputs
    wire [7:0] vga_r;
    wire [7:0] vga_b;
    wire [7:0] vga_g;
    wire hsync;
    wire vsync;
    wire vga_blank_n;
    wire vga_sync_n;
    wire vga_clk;
    wire [15:0] h_count;
    wire [15:0] v_count;

    // Instantiate the Unit Under Test (UUT)
    vga_controller uut (
        .clk(clk), 
        .rst(rst), 
        .vga_r(vga_r), 
        .vga_b(vga_b), 
        .vga_g(vga_g), 
        .hsync(hsync), 
        .vsync(vsync), 
        .vga_blank_n(vga_blank_n), 
        .vga_sync_n(vga_sync_n), 
        .vga_clk(vga_clk), 
        .h_count(h_count), 
        .v_count(v_count)
    );

    // Clock generation: 50MHz (20ns period)
    initial clk = 0;
    always #10 clk = ~clk;
    
    initial begin
         rst = 1;
        #100 rst = 0; // Release reset
        
        // 3. SIMULATION TIME
        // 20ms is enough for one full VGA frame (16.7ms)
        #20000000; 
        $display("Simulation Finished");
        $stop;
    end
    
endmodule
