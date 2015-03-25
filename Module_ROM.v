`timescale 1ns / 1ps
`include "Defintions.v"

`define LOOP1 8'd8
`define LOOP2 8'd5
module ROM
(
	input  wire[15:0]  		iAddress,
	output reg [27:0] 		oInstruction
);	
always @ ( iAddress )
begin
	case (iAddress)	

	0: oInstruction =  { `NOP ,24'd4000    };
	1: oInstruction =  { `STO ,`R1,16'hfffe };
	2: oInstruction =  { `STO ,`R2,16'h2     }; 
	3: oInstruction =  { `SMUL,`R3,`R1,`R2    };
	4: oInstruction =  { `LED ,8'b0,`R3,8'b0 };
	5: oInstruction =  { `JMP ,8'd1,16'b0   };	
	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
