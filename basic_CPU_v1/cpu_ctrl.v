module cpu_ctrl(
input clk,
input advance,		// program runs at ~0.5Hz clock when on, this speed can be changed using the counter comparison statements aound lines 420-425
input rst,	
input instant,		// program runs using 50MHz clock when on
input custom_in,	// when on, enables the user to store an input to I type immediate instructions
input [11:0]SW,	// used to determine the number to store
input p2,			// manual jump to program line 128 when on
output [6:0]reg_in_disp,		// every output is a display of the values in the program
output [6:0]alu_in1_disp,
output [6:0]alu_in2_disp,
output reg [7:0]PC,
output [6:0]i_disp,			// displays time left until next instruction when using advance mode
output reg[6:0]instr_disp,
output [6:0]mem_out_disp,
output [6:0]cl7_disp,
output [6:0]data_in_disp,
output reg [4:0]alu_ctrl		// determine which alu function
);

reg [3:0]i;
reg [26:0]counter;
reg advance_temp;

/*
	Main program
		Contains the control that puts together the ALU, 32 Registers, program memory, main memory, and has logic to display various signals
		program memory is set using program.mif and uses the TINY Risc-V encoding developed: 
			https://www.csl.cornell.edu/courses/ece5745/handouts/ece5745-tinyrv-isa.txt
		The way jumps and branches may use different logic to determine jump location
			
		main memory is used for the SW and LW commands
		
		The program and memory are not byte addressable
*/


/*
display(
input [3:0]num2disp,
output reg [6:0]seg7code
);
*/
display result(
reg2desp,
reg_in_disp
);
display alu_in1_7seg(
alu_in1[3:0],
alu_in1_disp
);
display alu_in2_7seg(
alu_in2[3:0],
alu_in2_disp
);
display i_count_7seg(
i[3:0],
i_disp
);
display mem_out_7seg(
mem_out[3:0],
mem_out_disp
);
display cl7_7seg(
reg_data_out1[31:28],
cl7_disp
);
display data_in(
reg_data_in[3:0],
data_in_disp
);
reg [3:0]reg2desp;

/*
module ALU(
input [31:0]inA,
input [31:0]inB,
input [4:0]alu_control,
output reg comp,
output reg[31:0]result);
*/
ALU alu(
alu_in1,
alu_in2,
alu_ctrl,
comp,
alu_result
);
reg [31:0]alu_in1;		// from main reg @ addr 1
reg [31:0]alu_in2;		// from main reg @ addr 2 or immediate
wire comp;					// determine comparison result between alu inputs
wire [31:0]alu_result;	// regular 32bit arithmatic output

/*
module main_memory (
	address,
	clock,
	data,
	wren,
	q);
*/
main_memory main_memory(
mem_addr,
clk, 
mem_data_in,
mem_wen,
mem_out
);
reg [31:0]mem_data_in;	// used as a ram for SW and LW
reg mem_wen;
reg [7:0]mem_addr;
wire [31:0]mem_out;
/*
module program_store (
	address,
	clock,
	data,
	wren,
	q);
*/
program_store my_program(	//wen and data will be always off, as this is the memory that stores the program
PC,
clk, 
prog_data_in,
prog_wen,
instr_prog
);
reg [31:0]prog_data_in;
reg prog_wen;
wire [31:0]instr_prog;
reg [31:0]instr;
/*
module reg_file( 
 input clk,
 input rst,
 input wren,
 input [4:0]addr_in,
 input [31:0]rf_data_in,
 input [4:0]addr_out1,
 input [4:0]addr_out2,
 output reg [31:0]rf_out1,
 output reg [31:0]rf_out2
);  
*/
reg_file main_reg(
clk,
rst,
wen_prot,
reg_store_addr,
reg_data_in_prot,
reg_read_addr1,
reg_read_addr2,
reg_data_out1,
reg_data_out2
);
reg reg_wen;
reg [4:0]reg_store_addr;
reg [31:0]reg_data_in;
reg [4:0]reg_read_addr1;
reg [4:0]reg_read_addr2;
reg [31:0]reg_data_in_prot;	// used when rd == rs1 or rs2, ensures that multiple operations don't occour before the next instruction
wire [31:0]reg_data_out1;
wire [31:0]reg_data_out2;

always @(*)
begin
	prog_wen = 1'b0;
	prog_data_in = 32'b00000000000000000000000000000000;
	instr_disp[6:0] = instr[6:0];
	if (comp)
	begin
		reg2desp = 4'h1;// 1 if comp is 1, displays 1
	end
	else
	begin
		reg2desp = alu_result[3:0];	// alu result of comp is 0, displays the 32bit result
	end
	
	if((reg_read_addr1 == reg_store_addr) & (cl7 >= 4'h3))	// stops multiple operations before next clock
	begin
		reg_data_in_prot = reg_data_out1;
	end
	else if((reg_read_addr2 == reg_store_addr) & (cl7 >= 4'h3))
	begin
		reg_data_in_prot = reg_data_out2;
	end
	else
	begin
		reg_data_in_prot = reg_data_in;	// regular operation when not writing to and input address
	end
	
	if (custom_in)		// used to input custom immediate to I type intructions
	begin
		instr[31:20] = SW;
		instr[19:0] = instr_prog[19:0];
	end
	else
	begin
		instr = instr_prog;
	end
end
// /*
always @(*)	// Control muxing
begin
	
	if (instr[6:0] == 7'b0110011)	//R-type
	begin
		reg_read_addr1 = instr[19:15];
		reg_read_addr2 = instr[24:20];
		reg_store_addr = instr[11:7];
		reg_data_in = alu_result;
		reg_wen = 1'b1;
		
		mem_wen = 1'b0;
		mem_addr = 8'h0;
		mem_data_in = 32'h0;
		
		alu_in1 = reg_data_out1;
		alu_in2 = reg_data_out2;
		alu_ctrl[2:0] = instr[14:12];
		alu_ctrl[3] = instr[30];
		alu_ctrl[4] = instr[25];
	end
	else if (instr[6:0] == 7'b0010011)	//I-type
	begin
		reg_read_addr1 = instr[19:15];
		reg_read_addr2 = 5'h0;
		reg_store_addr = instr[11:7];
		reg_data_in = alu_result;
		reg_wen = 1'b1;
		
		mem_wen = 1'b0;
		mem_addr = 8'h0;
		mem_data_in = 32'h0;
		
		alu_in1 = reg_data_out1;
		alu_ctrl[2:0] = instr[14:12];
		alu_ctrl[4] = instr[6];
		if (instr[13:12] == 2'b01)
		begin
			alu_in2[31:5] = 27'b000000000000000000000000000;
			alu_in2[4:0] = instr[24:20];
			alu_ctrl[3] = instr[30];
		end
		else
		begin
			alu_in2[31:12] = 20'b00000000000000000000;
			alu_in2[11:0] = instr[31:20];
			alu_ctrl[3] = instr[5];
		end
	end
	else if (instr[6:0] == 7'b0110111)	// LUI
	begin
		reg_read_addr1 = 5'h0;
		reg_read_addr2 = 5'h0;
		reg_store_addr = instr[11:7];
		reg_data_in[31:11] = instr[31:11];
		reg_data_in[10:0] = 11'b00000000000;
		reg_wen = 1'b1;
		
		mem_wen = 1'b0;
		mem_addr = 8'h0;
		mem_data_in = 32'h0;
		
		alu_in1 = 32'h0;
		alu_in2 = 32'h0;
		alu_ctrl[4:0] = 5'h0;
	end
	else if (instr[6:0] == 7'b0010111)	// AUIPC
	begin
		reg_read_addr1 = 5'h0;
		reg_read_addr2 = 5'h0;
		reg_store_addr = instr[11:7];
		reg_data_in[7:0] = PC;
		reg_data_in[31:11] = instr[31:11];
		reg_data_in[10:8] = 3'b000;
		reg_wen = 1'b1;
		
		mem_wen = 1'b0;
		mem_addr = 8'h0;
		mem_data_in = 32'h0;
		
		alu_in1 = 32'h0;
		alu_in2 = 32'h0;
		alu_ctrl[4:0] = 5'h0;
	end
	else if (instr[6:0] == 7'b0000011)	// LW
	begin
		reg_read_addr1 = instr[19:15];
		reg_read_addr2 = 5'h0;
		reg_store_addr = instr[11:7];
		reg_data_in = mem_out;
		reg_wen = 1'b1;
		
		mem_wen = 1'b0;
		mem_addr = alu_result[7:0];
		mem_data_in = 32'h0;
		
		alu_in1 = reg_data_out1;
		alu_in2[31:12] = 20'b00000000000000000000;
		alu_in2[11:0] = instr[31:20];
		alu_ctrl[4:0] = instr[6:2];
	end
	else if (instr[6:0] == 7'b0100011)	// SW
	begin
		reg_read_addr1 = instr[19:15];
		reg_read_addr2 = instr[24:20];
		reg_store_addr = 5'h0;
		reg_data_in = 32'h0;
		reg_wen = 1'b0;
		
		mem_wen = 1'b1;
		mem_addr = alu_result[7:0];
		mem_data_in = reg_data_out2;
		
		alu_in1 = reg_data_out1;
		alu_in2[31:12] = 20'b00000000000000000000;
		alu_in2[11:5] = instr[31:25];
		alu_in2[4:0] = instr[11:7];
		alu_ctrl[2:0] = instr[4:2];
		alu_ctrl[4] = instr[6];
		alu_ctrl[3] = instr[12];
	end
	else if (instr[6:0] == 7'b1101111)	// JAL
	begin
		reg_read_addr1 = 5'h0;
		reg_read_addr2 = 5'h0;
		reg_data_in[31:8] = 24'b000000000000000000000000;
		reg_data_in[7:0] = PC + 8'h1;
		reg_store_addr = instr[11:7];
		reg_wen = 1'b1;
		
		mem_wen = 1'b0;
		mem_addr = 8'h0;
		mem_data_in = 32'h0;
		
		alu_in1 = 32'h0;
		alu_in2 = 32'h0;
		alu_ctrl[4:0] = 5'h0;
		
		if (reg_data_in[7:0] == PC + 1'b1)	// stop writing once PC+1 is stored
		begin
			reg_wen = 1'b0;
		end
	end
	else if (instr[6:0] == 7'b1100111)	// JR/JALR
	begin
		reg_read_addr1 = instr[19:15];
		reg_read_addr2 = 5'h0;
		reg_data_in[31:8] = 24'b000000000000000000000000;
		reg_data_in[7:0] = PC + 8'h1;
		reg_store_addr = instr[11:7];
		reg_wen = 1'b1;
		
		mem_wen = 1'b0;
		mem_addr = 8'h0;
		mem_data_in = 32'h0;
		
		alu_in1 = 32'h0;
		alu_in2 = 32'h0;
		alu_ctrl[4:0] = 5'h0;
		
		if ((cl7 >= 4'd3) & (reg_data_in[7:0] == PC + 1'b1))	// stop writing once PC+1 is stored
		begin
			reg_wen = 1'b0;
		end
	end
	else if (instr[6:0] == 7'b1100011)	// comp branching
	begin
		reg_read_addr1 = instr[19:15];
		reg_read_addr2 = instr[24:20];
		reg_data_in = 32'h0;
		reg_store_addr = 5'h0;
		reg_wen = 1'b0;
		
		mem_wen = 1'b0;
		mem_addr = 8'h0;
		mem_data_in = 32'h0;
		
		alu_in1 = reg_data_out1;
		alu_in2 = reg_data_out2;
		alu_ctrl[2:0] = instr[14:12];
		alu_ctrl[4:3] = instr[1:0];
	end
	else
	begin
		reg_read_addr1 = 5'h0;
		reg_read_addr2 = 5'h0;
		reg_data_in = 32'h0;
		reg_store_addr = 5'h0;
		reg_wen = 1'b0;
		
		mem_wen = 1'b0;
		mem_addr = 8'h0;
		mem_data_in = 32'h0;
		
		alu_in1 = 32'h0;
		alu_in2 = 32'h0;
		alu_ctrl[4:0] = 5'h0;
	end
end
// */

integer j;
reg wen_prot;
reg [3:0]cl7;

always @(posedge clk, negedge rst)
begin
	if (~rst)
	begin			// reset program, reupload to reset ram
		PC <= 8'h0;
		i <= 4'h0;
		counter <= 27'h0;
		cl7 <= 4'h0;
		
	end
	else
	begin
		if (p2)
		begin
			PC <= 8'd128;	// manual jump
		end
		if (cl7 >= 4'd4)
		begin
			wen_prot <= 1'b0;	// another implementation of write protection to prevent multiple operations in slow clock mode
		end
		else
		begin
			cl7 <= cl7 + 4'h1;
			wen_prot <= reg_wen;
		end
		if (instr != 32'h0)
		begin
			counter <= counter + 27'h1;
			if(counter >= 27'd2499999)
			begin
				advance_temp <= advance;
				counter <= 27'h0;
			end
			if((advance_temp & counter >= 27'd2499999) | (instant & instr[6:0] != 7'b1111111))	// functionality for instant vs slow clocking
			begin
				i <= i + 4'h1;
				if(i > 4'he)		// updates PC when i is 15
				begin		
					if (instr[6:0] == 7'b1100011) // branch
					begin
						if (comp == 1'b0)
						begin
							PC <= PC + 1'b1;
							cl7 <= 1'b0;
						end
						else
						begin
							PC <= PC + instr[31:25];
							cl7 <= 1'b0;
						end
					end
					else if (instr[6:0] == 7'b1101111)	// JAL
					begin
						PC <= PC + $signed(instr[19:12]);
						cl7 <= 1'b0;
					end
					else if (instr[6:0] == 7'b1100111)	// JR/JALR
					begin
						if (instr[11:7] == 5'b00000)
						begin
							PC <= (reg_data_out1[7:0] + instr[27:20]);
							cl7 <= 1'b0;
						end
						else
						begin
							PC <= (reg_data_out1[7:0] + instr[27:20]);// & 8'hfe;
							cl7 <= 1'b0;
						end
					end
					else	// no jump
					begin
						PC <= PC + 1'b1;
						cl7 <= 1'b0;
					end
				end
			end
		end
		else
		begin
			PC <= PC;
		end
	end	
end

endmodule
