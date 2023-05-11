`timescale 1 ps / 1 ps

module tb();
reg clk;
reg rst;
	
	
	
	
	
	integer i;
	parameter simdelay = 10;
	
	cpu_ctrl DUT(
		.clk (clk),
		.rst (rst)
	);
										
	initial
	begin
	
		#(simdelay) rst = 1'b1; clk = 1'b0;
		#(simdelay) rst = 1'b0;

		#(simdelay) clk = 1'b1;
		#(simdelay) clk = 1'b0;
		#(simdelay) clk = 1'b1;
		#(simdelay) clk = 1'b0;
		#(simdelay) clk = 1'b1;
		#(simdelay) clk = 1'b0;
		#(simdelay) clk = 1'b1;
		#(simdelay) clk = 1'b0;
		#(simdelay) clk = 1'b1;
		#(simdelay) clk = 1'b0;
		#(simdelay) clk = 1'b1;
		#(simdelay) clk = 1'b0;
		#(simdelay) clk = 1'b1;
		#(simdelay) clk = 1'b0;
		#(simdelay) clk = 1'b1;
		#(simdelay) clk = 1'b0;
		#100;
	
	end
endmodule



										