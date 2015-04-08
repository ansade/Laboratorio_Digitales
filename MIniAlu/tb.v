`timescale 1ns / 1ps
module testbench1;
	
	//Inputs
	reg OpA,OpB,OpC,OpD,carry0;
	//Outputs
	wire result , result2, result3,result4, carry1, carry2, carry3, carry4;
	wire result5, result6, result7,result8;
	wire result9, result10, result11,result12;
	
	//Se intancia el modulo
	fila fila1(
	 .wSum1(OpA),
    .wSum2(OpB),
    .wSum3(OpB),
    .wSum4(OpB),
    .wSum5(OpB),
    .wSum6(OpB),
    .wSum7(OpC),
    .wSum8(OpB),
    .wCarry_In(carry0),
    .wCarry_Out(carry1),
    .wResult1(result),
    .wResult2(result2),
    .wResult3(result3),
    .wResult4(result4)
	);

	fila fila2(
	 .wSum1(result2),
    .wSum2(OpB),
    .wSum3(result3),
    .wSum4(OpB),
    .wSum5(result4),
    .wSum6(OpB),
    .wSum7(OpB),
    .wSum8(carry1),
    .wCarry_In(carry0),
    .wCarry_Out(carry2),
    .wResult1(result5),
    .wResult2(result6),
    .wResult3(result7),
    .wResult4(result8)
	);

	fila fila3(
	 .wSum1(result6),
    .wSum2(OpB),
    .wSum3(result7),
    .wSum4(OpB),
    .wSum5(result8),
    .wSum6(OpB),
    .wSum7(carry3),
    .wSum8(OpB),
    .wCarry_In(carry0),
    .wCarry_Out(carry4),
    .wResult1(result9),
    .wResult2(result10),
    .wResult3(result11),
    .wResult4(result12)
	);

	//Se pŕueba
	initial begin
		OpA=1;
		OpB=1;
		OpC=0;
		OpD=0;
		carry0=0;
	end
endmodule

