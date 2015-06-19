`timescale 1ns / 1ps
`default_nettype none

`define RESET 	3'd0
`define WAIT 	3'd1
`define WRITE 	3'd2
`define LOAD	3'd3
`define NOP		3'd4
`define IDLE    3'd5

`define LOOP 	6'd13

//Common wait times
`define TAI 20'd20//d2000
`define TBI 20'd50

module LCD_Controller (
	input wire iRequest,
	input wire Clock,
	input wire Reset,
	input wire [26:0] iROMdata,
	output reg oLCD_Enabled, /////////////////////////////////////////////
	output reg oLCD_RegisterSelect, //0=Command, 1=Data
	output wire oLCD_StrataFlashControl,
	output wire oLCD_ReadWrite,
	output reg[3:0] oLCD_Data,
	output reg [5:0] oROMaddress,
	output reg oBusy
	);
	
	reg rWrite_Enabled;
	assign oLCD_ReadWrite = 0; //I only Write to the LCD display, never Read from it
	assign oLCD_StrataFlashControl = 1; //StrataFlash disabled. Full read/write access to LCD
	
	reg [2:0] rCurrentState,rNextState;
	reg [31:0] rTimeCount;
	reg rTimeCountReset;
	
	
	wire [19:0] wT;
	wire [2:0] wNxtInstr;
	wire [3:0] wData;
	
	//Wait Previous Time, Data/Command, Next Instruction are provided by the ROM
	assign wT = iROMdata[19:0];
	assign wData = iROMdata[23:20];
	assign wNxtInstr = iROMdata[26:24]; 
		
//----------------------------------------------
//Next State and delay logic
	always @ ( posedge Clock )

		if (Reset)
		begin
			rCurrentState = `RESET;
			rTimeCount <= 32'b0;
		end
		
		else
		begin
			if (rTimeCountReset)
				rTimeCount <= 32'b0;
			else
				rTimeCount <= rTimeCount + 32'b1;
			
			rCurrentState <= rNextState;

		end
//----------------------------------------------
//Current state and output logic
	always @ (rCurrentState or rNextState or rTimeCountReset or rTimeCount or iRequest)
	begin
		case (rCurrentState)

		//------------------------------------------
		`RESET:
		begin
			rWrite_Enabled = 1'b0;
			oLCD_Data= 4'h0;
			oLCD_RegisterSelect = 1'b0;
			oLCD_Enabled = 0;
			oBusy = 1'b1;
			rTimeCountReset = 1'b0;
			
			rNextState = `WAIT;
			
			//Initialize ROM
			oROMaddress <= 0;
		end
		//-------------------------------------------------------------
		//Wait wT nanoseconds
		`WAIT:
		begin
			rWrite_Enabled = 1'b0;
			oLCD_RegisterSelect = 1'b0; //these are commands
			oLCD_Data = 4'h0;
			oLCD_Enabled = 0;
			oBusy = 1'b1;
			
			if (rTimeCount > wT )
			begin
				rTimeCountReset <= 1'b1;
				rNextState = wNxtInstr;
			end
			
			else
			begin
				rTimeCountReset = 1'b0;
				rNextState = `WAIT;
			end
		end
		//--------------------------------------------------------------
		//Enable LCD to send Data
		`WRITE:
		begin
			rWrite_Enabled = 1'b1;
			oLCD_RegisterSelect = 1'b1; //this is data
			oLCD_Data = wData;
			oBusy = 1'b1;
			
			//Wait 14 ns for state change
			if (rTimeCount > 32'd13 )
			begin
				oLCD_Enabled = 1'b0;
				rTimeCountReset = 1'b1;
				//always wait after every instruction
				rNextState = `WAIT;
				
				//Update Next Opperation
				oROMaddress = oROMaddress + 6'd1;
			end

			else
			begin
				//Wait 2 ns for enabling pulse
				if (rTimeCount > 32'd2)
					oLCD_Enabled = 1'b1;
				//Keep COUNTING
				rTimeCountReset = 1'b0;
				rNextState = `WRITE;
			end
		end
		
		//--------------------------------------------------------------
		//Send commands to LCD
		`LOAD:
		begin
			rWrite_Enabled = 1'b0;
			oLCD_RegisterSelect = 1'b0; //these are commands
			oLCD_Enabled = 0;
			oLCD_Data = wData;
			oBusy = 1'b1;
			
			//Wait 12 ns for next state change
			if (rTimeCount > 32'd11 )
			begin
				rTimeCountReset = 1'b1;
				//Always wait after every instruction
				rNextState = `WAIT;
				
				//Update Next Opperation
				oROMaddress = oROMaddress + 6'd1;
			end

			else
			begin
				//Keep counting
				rTimeCountReset = 1'b0;
				rNextState = `LOAD;
			end
		end
		
		//--------------------------------------------------------------
		//Wait for Mini Alu instructions
		`IDLE:
		begin
			rWrite_Enabled = 1'b0;
			oLCD_RegisterSelect = 1'b0; //these are commands
			oLCD_Data = wData;
			oLCD_Enabled = 0;	
			oBusy = 1'b0; //not busy
			
			if(iRequest)
			begin
				oBusy =1'b1;//busy
				rNextState = `WAIT;
				oROMaddress = `LOOP;
			end
			
			else	
				rNextState = `IDLE;

		end
		
		//--------------------------------------------------------------
		//Dont do anything until reset
		`NOP:
		begin
			rWrite_Enabled = 1'b0;
			oLCD_RegisterSelect = 1'b0; //these are commands
			oLCD_Data = wData;
			oLCD_Enabled = 0;
			oBusy = 1'b0;
			
			rNextState = `NOP;

		end
			
		//-------------------------------------------------------------

		default:
		begin
			rWrite_Enabled = 1'b0;
			oLCD_Data = 4'h0;
			oLCD_RegisterSelect = 1'b0;
			oLCD_Enabled = 0;
			oBusy = 1'b1;
			rTimeCountReset = 1'b0;
			rNextState = `RESET;
		end
		//------------------------------------------
		endcase
	end
	
endmodule

module LCD_ROM(
	input wire iRequest,
	input wire [15:0] iALUinstruct,
	input  wire[5:0]  		iAddress,
	output reg [26:0] 		oInstruction
	);
	
	//Instuction from ALU
	reg [2:0] wOp;
	reg [3:0] wUN; //Upper nibble
	reg [3:0] wLN; //Lower nibble
	
	//Upon request update instruction registers
	//always@(posedge iRequest)
	{wOp,wUN,wLN} = iALUinstruct[10:0];
		
	
	//ROM	
	always @ ( iAddress )
	begin
		case (iAddress)
		
		//Initialization----------------------------------------------------	
			//High LCD_E pulses 
			//0x3
			0: oInstruction = { `WRITE ,4'h3,20'd10};//750000}; //{Next Instruction, Data/Command, Previous wait (15ms=750 000)} 
			1: oInstruction = { `WRITE ,4'h3,20'd10};//205000 }; //205 000 cycles
			2: oInstruction = { `WRITE ,4'h3,20'd10};//5000 };//5 000 cycles
			//0x2
			3: oInstruction = { `WRITE ,4'h2,`TAI };
			
		//Configuration-----------------------------------------------------	
			//Function Set: Load 0x28
			4: oInstruction = { `LOAD  ,4'h2,`TAI }; 
			5: oInstruction = { `LOAD  ,4'h8,`TBI };
			//Entry Mode Set: Load 0x06 
			6: oInstruction = { `LOAD  ,4'h0,`TAI };  	
			7: oInstruction = { `LOAD  ,4'h6,`TBI }; 
			//Display On/Off: Load 0x0C
			8: oInstruction = { `LOAD  ,4'h0,`TAI  };  
			9: oInstruction = { `LOAD  ,4'hC,`TBI  };  
			//Clear: Load 0x01
			10: oInstruction = { `LOAD  ,4'h0,`TAI };  
			11: oInstruction = { `LOAD  ,4'h1,`TBI };	
			
		//IDDLE	
			
			12: oInstruction = { `IDLE ,4'h0,20'd10};//82000}; 
		
		//Mini Alu instructions	
		//Loop 
			13: oInstruction = { wOp ,wUN,20'd0 };
			14: oInstruction = { wOp ,wLN,`TBI };
		
		//Go back to iddle 	
			15: oInstruction = { `IDLE ,4'h0,`TAI}; 
			
			/*
			//Set DD-RAM: 0x80
			12: oInstruction = { `LOAD  ,4'h8,20'd82000}; 
			13: oInstruction = { `LOAD  ,4'h0,20'd50   };
			
			//Write H: 0x48
			14: oInstruction = { `WRITE ,4'h4,20'd2000 };
			15: oInstruction = { `WRITE ,4'h8,20'd50   };
			//Write E: 0x45
			16: oInstruction = { `WRITE ,4'h4,20'd2000 };
			17: oInstruction = { `WRITE ,4'h5,20'd50   };
			//Write L: 0x4C
			18: oInstruction = { `WRITE ,4'h4,20'd2000 };
			19: oInstruction = { `WRITE ,4'hC,20'd50   };
			//Write L: 0x4C
			20: oInstruction = { `WRITE ,4'h4,20'd2000 };
			21: oInstruction = { `WRITE ,4'hC,20'd50   };
			//Write O: 0x4F
			22: oInstruction = { `WRITE ,4'h4,20'd2000 };
			23: oInstruction = { `WRITE ,4'hF,20'd50   };
			//Write SPACE: 0x20
			24: oInstruction = { `WRITE ,4'h2,20'd2000 };
			25: oInstruction = { `WRITE ,4'h0,20'd50   };
			//Write W: 0x57
			26: oInstruction = { `WRITE ,4'h5,20'd2000 };
			27: oInstruction = { `WRITE ,4'h7,20'd50   };
			//Write O: 0x4F
			28: oInstruction = { `WRITE ,4'h4,20'd2000 };
			29: oInstruction = { `WRITE ,4'hF,20'd50   };
			//Write R: 0x52
			30: oInstruction = { `WRITE ,4'h5,20'd2000 };
			31: oInstruction = { `WRITE ,4'h2,20'd50   };
			//Write L: 0x4C
			32: oInstruction = { `WRITE ,4'h4,20'd2000 };
			33: oInstruction = { `WRITE ,4'hC,20'd50   };	
			//Write D: 0x44
			34: oInstruction = { `WRITE ,4'h4,20'd2000 };
			35: oInstruction = { `WRITE ,4'h4,20'd50   };
			
			//Infinite Loop
			36: oInstruction = { `NOP   ,24'd0};*/
			 
			default:
				oInstruction = { `RESET ,  24'b0 };		//RESET
		endcase	
	end
	
endmodule
