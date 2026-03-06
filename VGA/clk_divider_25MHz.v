`timescale 1ns / 1ps


module clk_divider_25MHz(
    input clk,    // 50MHz Input
    input rst,
    output clk_25MHZ
    );
    
    reg clk_temp;
    
    assign clk_25MHZ = clk_temp;
    
    always @ (posedge clk or posedge rst)
    begin
        if (rst) 
        begin
            clk_temp <= 0; 
        end
        else
        begin
            // Toggling every clock cycle divides the frequency by 2
            clk_temp <= ~clk_temp;
        end
    end
endmodule
