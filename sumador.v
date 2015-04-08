`timescale 1ns / 1ps

// Se declara un modulo


module sumador  (

input   OpA, 

input   OpB,

input carry_in, 

output  result, 

output carry_out

);

assign  {carry_out,result}=OpA+OpB;

endmodule

// Se declara una fila 

module fila ( 
	result,
	carry_out,
	Opa,
	Opb,
	carry_in
	);

output wire result,carry_out;
input wire Opa,Opb,carry_inin;

	assign result=(Opa^Opb^carry_in);
	assign carry_out=((Opa&Opb)|(Opa&carry_in)|(Opb&carry_in));

endmodule


/*


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
	
	OpA = 1;
	OpB = 0;
	OpA1 = 0;
	OpB1 = 1;
	OpA2 = 1;
	OpB2 = 1;
	OpA3 = 0;
	OpB3 = 0;
	


$monitor ($time,,"Result =%d,Result1 =%d, Result2 =%d, Result3 =%d, Carry_in=%d, Carry_out=%d,OpA=%d, OpB=%d,OpA1=%d, OpB1=%d, OpA2=%d, OpB2=%d, OpA3=%d, OpB3=%d ", result,result1,result2,result3,carry_in,carry_out3,OpA,OpB,OpA1,OpB1,OpA2,OpB2,OpA3,OpB3);

#10 $finish;


	
	end


endmodule
*/


module HA(sout,cout,a,b);
output sout,cout;
input a,b;
assign sout=a^b;
assign cout=(a&b);
endmodule

module FA(sout,cout,a,b,cin);
output sout,cout;
input a,b,cin;
assign sout=(a^b^cin);
assign cout=((a&b)|(a&cin)|(b&cin));
endmodule


module multiply4bits(product,inp1,inp2);
output [7:0]product;
input [3:0]inp1;
input [3:0]inp2;
assign product[0]=(inp1[0]&inp2[0]);
wire x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17;
HA HA1(product[1],x1,(inp1[1]&inp2[0]),(inp1[0]&inp2[1]));
FA FA1(x2,x3,inp1[1]&inp2[1],(inp1[0]&inp2[2]),x1);
FA FA2(x4,x5,(inp1[1]&inp2[2]),(inp1[0]&inp2[3]),x3);
HA HA2(x6,x7,(inp1[1]&inp2[3]),x5);
HA HA3(product[2],x15,x2,(inp1[2]&inp2[0]));
FA FA5(x14,x16,x4,(inp1[2]&inp2[1]),x15);
FA FA4(x13,x17,x6,(inp1[2]&inp2[2]),x16);
FA FA3(x9,x8,x7,(inp1[2]&inp2[3]),x17);
HA HA4(product[3],x12,x14,(inp1[3]&inp2[0]));
FA FA8(product[4],x11,x13,(inp1[3]&inp2[1]),x12);
FA FA7(product[5],x10,x9,(inp1[3]&inp2[2]),x11);
FA FA6(product[6],product[7],x8,(inp1[3]&inp2[3]),x10);
endmodule


