module display(
input [3:0]num2disp,
output reg [6:0]seg7code
);
/*
	Takes in a 4 bit number and converts it to 0-f on a seven segment
*/


always @(*)
begin

case (num2disp)
	4'b0000: seg7code = 7'b1000000;// 0
	4'b0001: seg7code = 7'b1111001;
	4'b0010: seg7code = 7'b0100100;
	4'b0011: seg7code = 7'b0110000;
	4'b0100: seg7code = 7'b0011001;// 4
	4'b0101: seg7code = 7'b0010010;
	4'b0110: seg7code = 7'b0000010;
	4'b0111: seg7code = 7'b1111000;
	4'b1000: seg7code = 7'b0000000;// 8
	4'b1001: seg7code = 7'b0011000;
	4'b1010: seg7code = 7'b0001000;
	4'b1011: seg7code = 7'b0000011;
	4'b1100: seg7code = 7'b0100111;// 12(c)
	4'b1101: seg7code = 7'b0100001;
	4'b1110: seg7code = 7'b0000100;
	4'b1111: seg7code = 7'b0001110;
	endcase
end
endmodule
