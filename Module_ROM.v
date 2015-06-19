
`timescale 1ns / 1ps
`include "Defintions.v"
`define COLS		8'b0 
`define ROWS 		8'b1 
`define ONE 		8'd2 
`define COLS_SIZE 8'd3 
`define ROWS_SIZE	8'd4 
`define STRIPE_SIZE  8'd5 

`define GREENLOOP 8'd6 
`define INFLOOP	8'd11
`define RESCOL 	8'd5

`define REDLOOP 8'd15 
`define WHITELOOP 8'd23 
`define BLUELOOP 8'd31 

module ROM
(
	input  wire[15:0]  		iAddress,
	output reg [27:0] 		oInstruction
);	
always @ ( iAddress )
begin
	case (iAddress)
	//LCD Program
	0: oInstruction = { `NOP , 24'd0 };
	1: oInstruction = { `BBU , 8'd1, 16'd0 };
	2: oInstruction = { `LCD , 8'b0, `LOAD,`SDR1};
	3: oInstruction = { `NOP , 24'd0 };
	4: oInstruction = { `BBU , 8'd1, 16'd3 };
	
	//LCD "Hello World"
	5: oInstruction = { `LCD , 8'b0, `WRITE,`H};
	6: oInstruction = { `NOP , 24'd0 };
	7: oInstruction = { `BBU , 8'd1, 16'd6 };
	8: oInstruction = { `LCD , 8'b0, `WRITE,`E};
	9: oInstruction = { `NOP , 24'd0 };
	10: oInstruction = { `BBU , 8'd1, 16'd9 };
	11: oInstruction = { `LCD , 8'b0, `WRITE,`L};
	12: oInstruction = { `NOP , 24'd0 };
	13: oInstruction = { `BBU , 8'd1, 16'd12 };
	14: oInstruction = { `LCD , 8'b0, `WRITE,`L};
	15: oInstruction = { `NOP , 24'd0 };
	16: oInstruction = { `BBU , 8'd1, 16'd15 };
	17: oInstruction = { `LCD , 8'b0, `WRITE,`O};
	18: oInstruction = { `NOP , 24'd0 };
	19: oInstruction = { `BBU , 8'd1, 16'd18 };
	20: oInstruction = { `LCD , 8'b0, `WRITE,`SPACE};
	21: oInstruction = { `NOP , 24'd0 };
	22: oInstruction = { `BBU , 8'd1, 16'd21 };
	23: oInstruction = { `LCD , 8'b0, `WRITE,`W};
	24: oInstruction = { `NOP , 24'd0 };
	25: oInstruction = { `BBU , 8'd1, 16'd24 };
	26: oInstruction = { `LCD , 8'b0, `WRITE,`O};
	27: oInstruction = { `NOP , 24'd0 };
	28: oInstruction = { `BBU , 8'd1, 16'd27 };
	29: oInstruction = { `LCD , 8'b0, `WRITE,`R};
	30: oInstruction = { `NOP , 24'd0 };
	31: oInstruction = { `BBU , 8'd1, 16'd30 };
	32: oInstruction = { `LCD , 8'b0, `WRITE,`L};
	33: oInstruction = { `NOP , 24'd0 };
	34: oInstruction = { `BBU , 8'd1, 16'd33 };
	35: oInstruction = { `LCD , 8'b0, `WRITE,`D};
		
	/*//VGA Test Program
	0: oInstruction = { `NOP ,	24'd4000	};
	1: oInstruction = { `STO , `COLS_SIZE, 16'd99};
	2: oInstruction = { `STO , `ROWS_SIZE, 16'd99};
	3: oInstruction = { `STO , `ONE, 16'b1};
	4: oInstruction = { `STO , `ROWS, 16'b0};
	
	//Reset columns counter
	5: oInstruction = { `STO , `COLS, 16'b0};
	
	//green loop
	6: oInstruction = { `VGA  ,5'b0,`COLOR_GREEN , `ROWS, `COLS };
	7: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	8: oInstruction = { `BLE , `GREENLOOP, `COLS, `COLS_SIZE};
	
	9: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	10: oInstruction = { `BLE , `RESCOL, `ROWS, `ROWS_SIZE};
	
	//infinite loop
	11: oInstruction = { `NOP ,	24'd4000	};
	12: oInstruction = { `JMP , `INFLOOP, 16'b0};
	*/
	
	/*//Professor program
	1: oInstruction = { `STO , `COLS, 16'b0};
	2: oInstruction = { `STO , `ROWS, 16'b0};
	3: oInstruction = { `STO , `ONE, 16'b1};
	4: oInstruction = { `STO , `COLS_SIZE, 16'd100};
	5: oInstruction = { `STO , `ROWS_SIZE, 16'd25};
	6: oInstruction = { `STO , `STRIPE_SIZE, 16'd25};
	7: oInstruction = { `NOP ,	24'd4000	};
	8: oInstruction = { `VGA  ,5'b0,`COLOR_GREEN , `COLS, `ROWS  };
	9: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	10: oInstruction = { `BLE , `GREENLOOP, `COLS, `COLS_SIZE};
	11: oInstruction = { `STO , `COLS, 16'b0};
	12: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	13: oInstruction = { `BLE , `GREENLOOP, `ROWS, `ROWS_SIZE};
	14: oInstruction = { `ADD , `ROWS_SIZE, `ROWS_SIZE, `STRIPE_SIZE};
	15: oInstruction = { `NOP ,	24'd4000	};
	16: oInstruction = { `VGA  ,5'b0,`COLOR_RED , `COLS, `ROWS  };
	17: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	18: oInstruction = { `BLE , `REDLOOP, `COLS, `COLS_SIZE};
	19: oInstruction = { `STO , `COLS, 16'b0};
	20: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	21: oInstruction = { `BLE , `REDLOOP, `ROWS, `ROWS_SIZE};
	22: oInstruction = { `ADD , `ROWS_SIZE, `ROWS_SIZE, `STRIPE_SIZE};
	23: oInstruction = { `NOP ,	24'd4000	};
	24: oInstruction = { `VGA  ,5'b0,`COLOR_RED , `COLS, `ROWS  };
	25: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	26: oInstruction = { `BLE , `WHITELOOP, `COLS, `COLS_SIZE};
	27: oInstruction = { `STO , `COLS, 16'b0};
	28: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	29: oInstruction = { `BLE , `WHITELOOP, `ROWS, `ROWS_SIZE};
	30: oInstruction = { `ADD , `ROWS_SIZE, `ROWS_SIZE, `STRIPE_SIZE};
	31: oInstruction = { `NOP ,	24'd4000	};
	32: oInstruction = { `VGA  ,5'b0,`COLOR_RED , `COLS, `ROWS  };
	33: oInstruction = { `ADD , `COLS, `COLS, `ONE};
	34: oInstruction = { `BLE , `BLUELOOP, `COLS, `COLS_SIZE};
	35: oInstruction = { `STO , `COLS, 16'b0};
	36: oInstruction = { `ADD , `ROWS, `ROWS, `ONE};
	37: oInstruction = { `BLE , `BLUELOOP, `ROWS, 8'd255};
	38: oInstruction = { `NOP ,	24'd4000	};
	39: oInstruction = { `JMP , 8'd38, 16'b0 };*/


	default:
		oInstruction = { `LED ,  24'b10101010 };		//NOP
	endcase	
end
	
endmodule
