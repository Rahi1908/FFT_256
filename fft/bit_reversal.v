`timescale 1ns / 1ps

module bit_reversal (reset, clock, startin, address, write);

input reset,clock,startin;
output reg [7:0]address; 
output reg write;

reg [7:0] counter;

always@(posedge clock or posedge reset)
begin
	if(reset) begin
		counter<= #1 8'b0;
	end 
	else if (startin) begin
		counter<= #1 8'b00000001;
	end 
	else if (counter > 0 && counter <= 255) begin
		counter<= #1 counter+1;
	end 
	else begin
		counter <= #1 8'b0;
	end

end

always @ (*) begin
	
	address={counter[0],counter[1],counter[2],counter[3],counter[4],counter[5],counter[6],counter[7]};

	if ((startin == 1)) begin
		write = 1;
	end 
	else if (counter != 0 ) begin
		write =1;
	end 
	else begin
		write = 0;
	end
end

endmodule