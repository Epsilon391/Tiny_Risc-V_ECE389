module ALU(
input [31:0]inA,
input [31:0]inB,
input [4:0]alu_control,
output reg comp,
output reg[31:0]result);

/*
	outputs:
		comp is used for true/false operations. during branch operations comp=1 when the program should jump, otherwise PC=PC+1
		result is the output of the arithmatic operation, and defaults to 0 during branch operations
*/


always @(*)
begin
		case (alu_control)
			5'b00000: 
			begin
				result = inA+inB;	//add,sub,mul
				comp = 1'b0;
			end
			5'b01000: 
			begin
				result = inA-inB;
				comp = 1'b0;
			end
			5'b10000: 
			begin
				result = inA*inB;
				comp = 1'b0;
			end
			5'b00111: 
			begin
				result = inA&inB;	//bitwise and,or,xor
				comp = 1'b0;
			end
			5'b00110: 
			begin
				result = inA|inB;
				comp = 1'b0;
			end
			5'b00100: 
			begin
				result = inA^inB;
				comp = 1'b0;
			end
			5'b00010: 								//SLT
			begin
				if (inA[31] == inB[31])		//A and B have matching signs
				begin
					if (inA<inB)
					begin
						result = 32'h1;
						comp = 1'b1;
					end
					else
					begin
						result = 32'h0;
						comp = 1'b0;
					end
				end
				else if (inA[31] > inB[31])	//A is - and B is +
				begin
					result = 32'h1;
					comp = 1'b1;
				end
				else									//A is + and B is -
				begin
					result = 32'h0;
					comp = 1'b0;
				end
			end
			5'b00011:										//SLTU
			begin
				if (inA<inB)
				begin
					result = 32'h1;
					comp = 1'b1;
				end
				else
				begin
					result = 32'h0;
					comp = 1'b0;
				end
			end
			5'b01101: 
			begin
				result = $signed(inA) >>> inB;	//SRA
				comp = 1'b0;
			end
			5'b00101: 
			begin
				result = inA >> inB;		//SRL
				comp = 1'b0;
			end
			5'b00001: 
			begin
				result = inA << inB;	//SLL
				comp = 1'b0;
			end
			5'b11000: 
			begin
				comp = (inA == inB);	//EQ
				result = 32'h0;
			end
			5'b11001: 
			begin
				comp = (inA != inB);	//NE
				result = 32'h0;
			end
			5'b11111: 
			begin
				comp = (inA >= inB);	//GEU
				result = 32'h0;
			end
			5'b11110: 
			begin
				comp = (inA < inB);		//LTU
				result = 32'h0;
			end
			5'b11101:								//GE
			begin
				if (inA[31] == inB[31])		//A and B have matching signs
				begin
					if (inA>=inB)
					begin
						comp = 1'b1;
						result = 32'h0;
					end
					else
					begin
						comp = 1'b0;
						result = 32'h0;
					end
				end
				else if (inA[31] < inB[31])	//A is + and B is -
				begin
					comp = 1'b1;
					result = 32'h0;
				end
				else									//A is - and B is +
				begin
					comp = 1'b0;
					result = 32'h0;
				end
			end
			5'b11100:								//LT
			begin
				if (inA[31] == inB[31])		//A and B have matching signs
				begin
					if (inA<inB)
					begin
						comp = 1'b1;
						result = 32'h0;
					end
					else
					begin
						comp = 1'b0;
						result = 32'h0;
					end
				end
				else if (inA[31] < inB[31])	//A is + and B is -
				begin
					comp = 1'b0;
					result = 32'h0;
				end
				else									//A is - and B is +
				begin
					comp = 1'b1;
					result = 32'h0;
				end
			end
			default:
			begin
			result = 32'h0;
			comp = 1'b0;
			end
	endcase
end
endmodule
