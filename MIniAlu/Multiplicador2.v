`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:00:27 04/08/2015 
// Design Name: 
// Module Name:    Multiplicador2 
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
module Multiplicador2(
    input  [3:0] inp1,
    input  [3:0] inp2,
    output [7:0] product
    );
		
	//Cables internos
	wire subp0,subp1,subp2,subp3,subp4,subp5,subp6,subp7,subp8;
	wire subp9,subp10,subp11,subp12,subp13,subp14,subp15;
	wire result , result2, result3,result4, carry1, carry2, carry3;
	wire result5, result6, result7,result8;
	wire result9, result10, result11,result12;
		
	//linea 1
	assign subp0 = Num1[0]& Num2[0];
	assign subp1 = Num1[0]& Num2[1];
	assign subp2 = Num1[1]& Num2[0];
	assign subp3 = Num1[2]& Num2[0];
	assign subp4 = Num1[3]& Num2[0];
	assign subp5 = Num1[2]& Num2[1];
	assign subp6 = 0;
	assign subp7 = Num1[3]& Num2[1];
	
	//linea 2
	assign subp8  = Num1[0]& Num2[2];
	assign subp9  = Num1[1]& Num2[2];
	assign subp10 = Num1[2]& Num2[2];
	assign subp11 = Num1[3]& Num2[2];
	
	//linea3
	assign subp12 = Num1[0]& Num2[3];
	assign subp13 = Num1[1]& Num2[3];
	assign subp13 = Num1[2]& Num2[3];
	assign subp15 = Num1[3]& Num2[3];
		
	
	//Se intancia el modulo
	fila fila1(
	 .wSum1(subp0),
    .wSum2(subp1),
    .wSum3(subp2),
    .wSum4(subp3),
    .wSum5(subp4),
    .wSum6(subp5),
    .wSum7(subp6),
    .wSum8(subp7),
    .wCarry_In(subp6),
    .wCarry_Out(carry1),
    .wResult1(result),
    .wResult2(result2),
    .wResult3(result3),
    .wResult4(result4)
	);

	fila fila2(
	 .wSum1(result2),
    .wSum2(subp8),
    .wSum3(result3),
    .wSum4(subp9),
    .wSum5(result4),
    .wSum6(subp10),
    .wSum7(subp11),
    .wSum8(carry1),
    .wCarry_In(subp6),
    .wCarry_Out(carry2),
    .wResult1(result5),
    .wResult2(result6),
    .wResult3(result7),
    .wResult4(result8)
	);

	fila fila3(
	 .wSum1(result6),
    .wSum2(subp12),
    .wSum3(result7),
    .wSum4(subp13),
    .wSum5(result8),
    .wSum6(subp14),
    .wSum7(carry2),
    .wSum8(subp15),
    .wCarry_In(carry0),
    .wCarry_Out(carry3),
    .wResult1(result9),
    .wResult2(result10),
    .wResult3(result11),
    .wResult4(result12)
	);

endmodule
