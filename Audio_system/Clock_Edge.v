`timescale 1ns / 1ps

module Clock_Edge(
// Inputs
clk,
reset,
test_clk,
// Outputs
rising_edge,
falling_edge
    );
 // Inputs
input clk;
input reset;
input test_clk;
// Outputs
output rising_edge;
output falling_edge;


// Internal Wires
wire found_edge;

// Internal Registers
reg	cur_test_clk;
reg last_test_clk;

//-------------------sequential logic----------------
always @(posedge clk)
	cur_test_clk	<= test_clk;

always @(posedge clk)
	last_test_clk	<= cur_test_clk;
	
//-----------------Combinational logic------------------

// Output Assignments
assign rising_edge	= found_edge & cur_test_clk;
assign falling_edge	= found_edge & last_test_clk;

// Internal Assignments
assign found_edge	= last_test_clk ^ cur_test_clk;


endmodule

