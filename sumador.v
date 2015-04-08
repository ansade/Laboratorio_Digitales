`timescale 1ns / 1ps

// Se declara un modulo sumador individual

module sumador(sout,cout,a,b);
output sout,cout;
input a,b;
assign sout=a^b;
assign cout=(a&b);
endmodule

// Se declara un modulo fila	

module fila(sout,cout,a,b,cin);
output sout,cout;
input a,b,cin;
assign sout=(a^b^cin);
assign cout=((a&b)|(a&cin)|(b&cin));
endmodule

// Se declara un modulo multiplicador

module multiplicador(product,inp1,inp2);
output [7:0]product;
input [3:0]inp1;
input [3:0]inp2;
assign product[0]=(inp1[0]&inp2[0]);
wire x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17;
sumador HA1(product[1],x1,(inp1[1]&inp2[0]),(inp1[0]&inp2[1]));
fila FA1(x2,x3,inp1[1]&inp2[1],(inp1[0]&inp2[2]),x1);
fila FA2(x4,x5,(inp1[1]&inp2[2]),(inp1[0]&inp2[3]),x3);
sumador HA2(x6,x7,(inp1[1]&inp2[3]),x5);
sumador HA3(product[2],x15,x2,(inp1[2]&inp2[0]));
fila FA5(x14,x16,x4,(inp1[2]&inp2[1]),x15);
fila FA4(x13,x17,x6,(inp1[2]&inp2[2]),x16);
fila FA3(x9,x8,x7,(inp1[2]&inp2[3]),x17);
sumador HA4(product[3],x12,x14,(inp1[3]&inp2[0]));
fila FA8(product[4],x11,x13,(inp1[3]&inp2[1]),x12);
fila FA7(product[5],x10,x9,(inp1[3]&inp2[2]),x11);
fila FA6(product[6],product[7],x8,(inp1[3]&inp2[3]),x10);
endmodule




// Se realiza un módulo de prueba

module testbench;

reg  [3:0] inp1, inp2;

reg  carry_in;
wire [7:0] product;

multiplicador mul (

.product(product), 
.inp1(inp1), 
.inp2(inp2)

);



initial 

	begin

	inp1 = 15;
	inp2 = 6;



	


$monitor ($time,,"Result =%d, OpB=%d,OpA=%d, ", product,inp1,inp2);

#10 $finish;


	
	end


endmodule

