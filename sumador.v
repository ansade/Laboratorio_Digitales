`timescale 1ns / 1ps

module sumador  (

input   OpA, 

input   OpB,

input carry_in, 

output  result, 

output carry_out

);

assign  {carry_out,result}=OpA+OpB;

endmodule


module fila ( 

input   OpA, 
input   OpB,
input   OpA1, 
input   OpB1,
input   OpA2, 
input   OpB2,
input   OpA3, 
input   OpB3,

input carry_in,

output  result,
output  result1,
output  result2,
output  result3,

output carry_out3


);

sumador sum1 ( OpA,OpB,result,carry_in,carry_out);

sumador sum2 ( OpA1,OpB1,result1,carry_out,carry_out1);

sumador sum3 ( OpA2,OpB2,result2,carry_out1,carry_out2);

sumador sum4 ( OpA3,OpB3,result3,carry_out2,carry_out3);




endmodule



module testbench;

reg   OpA, OpB,OpA1, OpB1,OpA2, OpB2,OpA3, OpB3;

reg  carry_in;
wire result;
wire result1;
wire result2;
wire result3;

wire carry_out3;


/*reg  OpA,OpB;
wire  result;

wire carry_out;
wire carry_in;
*/


fila sum ( 
.OpA(OpA), 
.OpB(OpB),
.OpA1(OpA1), 
.OpB1(OpB1),
.OpA2(OpA2), 
.OpB2(OpB2),
.OpA3(OpA3), 
.OpB3(OpB3),

.carry_in(carry_in),

.result(result),
.result1(result1),
.result2(result2),
.result3(result3),

.carry_out3(carry_out3)
);


initial 

	begin
	
	OpA = 4'b 0010;
	OpB = 4'b 1110;
	OpA1 = 4'b 0110;
	OpB1 = 4'b 1111;
	OpA2 = 4'b 1010;
	OpB2 = 4'b 1010;
	OpA3 = 4'b 0000;
	OpB3 = 4'b 1100;
	


$monitor ($time,,"Result =%b,Result1 =%b, Result2 =%b, Result3 =%b, Carry_in=%b, Carry_out=%b,OpA=%b, OpB=%b,OpA1=%b, OpB1=%b, OpA2=%b, OpB2=%b, OpA3=%b, OpB3=%b ", result,result1,result2,result3,carry_in,carry_out3,OpA,OpB,OpA1,OpB1,OpA2,OpB2,OpA3,OpB3);

#10 $finish;


	
	end


endmodule

