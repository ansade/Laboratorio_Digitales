`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:38:55 04/08/2015 
// Design Name: 
// Module Name:    fila 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module fila(
    input wSum1,
    input wSum2,
    input wSum3,
    input wSum4,
    input wSum5,
    input wSum6,
    input wSum7,
    input wSum8,
    
	 input wCarry_In,
    
	 output wCarry_Out,
    output wResult1,
    output wResult2,
    output wResult3,
    output wResult4
    );

	//Cables Internos
	wire carry1, carry2, carry3;


	sumador sum1 (
		.wOpA(wSum1),
		.wOpB(wSum2),
		.wResult(wResult1),
		.wCarry(carry1),
		.wCarry0(wCarry_In)	
		);
	
	sumador sum2 (
		.wOpA(wSum3),
		.wOpB(wSum4),
		.wResult(wResult2),
		.wCarry(carry2),
		.wCarry0(carry1)	
	);

	sumador sum3 (
		.wOpA(wSum5),
		.wOpB(wSum6),
		.wResult(wResult3),
		.wCarry(carry3),
		.wCarry0(carry2)	
	);

	sumador sum4 (
		.wOpA(wSum7),
		.wOpB(wSum8),
		.wResult(wResult4),
		.wCarry(wCarry_Out),
		.wCarry0(carry3)	
	);
endmodule
