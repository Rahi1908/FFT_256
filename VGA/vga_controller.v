`timescale 1ns / 1ps

module vga_controller(
input clk,
input rst,
output reg [7:0] vga_r,
output reg [7:0] vga_b,
output reg [7:0] vga_g,
output reg hsync,
output reg vsync,
output vga_blank_n,     // VGA_BLANK_N (REQUIRED for DE10-Standard)
output vga_sync_n,      // VGA_SYNC_N (Usually high)
output vga_clk,         // VGA_CLK (25MHz to the DAC)
output [15:0] h_count,
output [15:0] v_count
    );
    
     /* VGA 640x480 @ 60Hz timing constants
    parameter H_VISIBLE_AREA = 640;
    parameter H_FRONT_PORCH = 16;
    parameter H_SYNC_PULSE = 96;
    parameter H_BACK_PORCH = 48;
    parameter H_TOTAL = 800;

    parameter V_VISIBLE_AREA = 480;
    parameter V_FRONT_PORCH = 10;
    parameter V_SYNC_PULSE = 2;
    parameter V_BACK_PORCH = 33;
    parameter V_TOTAL = 525; */
  
  wire clk_25MHZ;
  wire v_enable;
  reg [7:0] red;
  reg [7:0] blue;
  reg [7:0] grn;
  
  clk_divider_25MHz vga_clk_gen ( .clk(clk) , .rst(rst) , .clk_25MHZ(clk_25MHZ) );
  horizontal_counter vga_hor ( .clk(clk_25MHZ) , .rst(rst) , .v_enable(v_enable), .h_count(h_count) );
  vertical_counter vga_ver ( .clk(clk_25MHZ) , .rst(rst) , .v_enable(v_enable) , .v_count(v_count) );
   
   // Output the 25MHz clock to the DAC chip
    assign vga_clk = clk_25MHZ;
    assign vga_sync_n = 1'b1; // Not used for standard VGA
    
  // generation of hsync and vsync
  always @ (posedge clk_25MHZ or posedge rst)
   begin
   
    if(rst)
     begin
      hsync <= 1;
      vsync <= 1;
     end
    else
     begin
      if(h_count >= 655 && h_count < 751)
      hsync <= 0;
      else
      hsync <= 1;
      
      if(v_count >= 489 && v_count < 491)
      vsync <= 0;
      else
      vsync <= 1;
      
     end
   end
  
  // VGA_BLANK_N must be HIGH when in visible area, LOW otherwise.
    assign vga_blank_n = (h_count < 640 && v_count < 480);
    
  // generation of color signals
  always @ (posedge clk_25MHZ or posedge rst)
   begin
    if(rst)
     begin
      vga_r <= 8'd0;
      vga_b <= 8'd0;
      vga_g <= 8'd0;
     end
    else
     begin
      if (h_count < 640 && v_count < 480)
       begin
        vga_r <= red;
        vga_b <= blue;
        vga_g <= grn;
       end
      else
       begin
        vga_r <= 8'd0;
        vga_b <= 8'd0;
        vga_g <= 8'd0;
       end
     end
   end 
   
   always @ (*)
   begin
    red = (h_count <= 638 && v_count <=478) ? 8'hFF : 8'h0;
    blue = (h_count <= 638 && v_count <=478) ? 8'hFF : 8'h0;
    grn = (h_count <= 638 && v_count <=478) ? 8'hFF : 8'h0;
    
   end
   
   
endmodule
