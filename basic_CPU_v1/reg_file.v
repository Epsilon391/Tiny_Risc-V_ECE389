module reg_file( 
 input clk,
 input rst,
 input wen,
 input [4:0]addr_in,
 input [31:0]rf_data_in,
 input [4:0]addr_out1,
 input [4:0]addr_out2,
 output reg [31:0]rf_out1,
 output reg [31:0]rf_out2
);      
/*
	register file contains 32 addresses, each with 32 bits of storage each
*/
		
		
reg [31:0]  regFile [0:31]; 
integer i; 

always @ (posedge clk or negedge rst) 
begin 
	if(~rst) // reset 
	begin 
		for (i = 0; i < 32; i = i + 1) 
		begin
			regFile [i] = 32'h0; 
		end 
		rf_out1 = regFile [addr_out1]; 
		rf_out2 = regFile [addr_out2];
	end 	
	else // no reset
	begin 
		if (wen == 1'b0)
		begin 
			rf_out1 = regFile [addr_out1]; 
			rf_out2 = regFile [addr_out2];
			regFile [addr_in] <= regFile [addr_in];	// don't update value when write enable is off
		end   
		else  
		begin 
			if (addr_in == 5'b00000)
			begin
			 regFile [addr_in] = 32'h0;
			end
			else
			begin
				rf_out1 = regFile [addr_out1]; 
				rf_out2 = regFile [addr_out2]; 
				regFile [addr_in] <= rf_data_in; 
			end
		end
	end 
end
endmodule
