`timescale 1ns / 1ps

module testbench;

sumador sum ( 

.OpA(OpA),
.OpB(OpB),
.result(result),
.carry(carry)
);


initial 

	begin

	OpA =1;
	OpB =1;
	
	end


endmodule
