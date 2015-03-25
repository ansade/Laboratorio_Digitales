`timescale 1ns / 1ps

module sumador (

	input  wOpA,
	input  wOpB,
	input  wCarry0,
	output wResult,
	output wCarry
);

	assign {wCarry, wResult}= wOpA + wOpB + wCarry0;	

endmodule
