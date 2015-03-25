`timescale 1ns / 1ps
module testbench1;
	
	//Inputs
	reg OpA,OpB,OpC,OpD,carry0;
	//Outputs
	wire [3:0]result, carry;
	
	//Se intancia el modulo
	sumador sum1 (
	.wOpA(OpA),
	.wOpB(OpB),
	.wResult(result),
	.wCarry(carry),
	.wCarry0(carry0)	
	);

	sumador sum2 (
	.wOpA(OpA),
	.wOpB(OpB),
	.wResult(result),
	.wCarry(carry),
	.wCarry0(carry0)
	);

	sumador sum3 (
	.wOpA(OpA),
	.wOpB(OpB),
	.wResult(result),
	.wCarry(carry),
	.wCarry0(carry0)
	);



	//Se pŕueba
	initial begin
		OpA=1;
		OpB=1;
		OpC=1;
		OpD=1;
		carry0=0;
	end
endmodule

