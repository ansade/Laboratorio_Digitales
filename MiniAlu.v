
`timescale 1ns / 1ps
`include "Defintions.v"
`default_nettype none


module MiniAlu
(
 input wire Clock,
 input wire Reset,
 input wire Reset2,
 output wire [7:0] oLed,
 output wire VGA_HSYNC, 
 output wire VGA_VSYNC, 
 output wire VGA_RED, 
 output wire VGA_GREEN, 
 output wire VGA_BLUE,
 output wire LCD_E,
 output wire LCD_RS,
 output wire LCD_RW,
 output wire SF_CE0,
 output wire SF_D<8>,
 output wire SF_D<9>,
 output wire SF_D<10>,
 output wire SF_D<11>, 
);

wire [15:0]  wIP,wIP_temp,wIP_Return,wreturn_routine;
reg  rWriteEnable,rVGAWriteEnable,rBranchTaken,rSubrutineCall,rRTS,rRequest;
wire [15:0] wReadRAMAddress,wVGAWriteAddress ;
wire [27:0] wInstruction;
wire [3:0]  wOperation;
reg [15:0]   rResult;
wire [7:0]  wSourceAddr0,wSourceAddr1,wDestination;
wire signed [15:0] wSourceData0,wSourceData1,wIPInitialValue,wImmediateValue;

//VGA wires
wire wClk25,wVGA_R,wVGA_G,wVGA_B;

//LCD wires
wire [26:0] wROMlcd;
wire [3:0] wLCD_Data;
wire [5:0] wLCDAdd;
wire wBusy;
wire [15:0] wLCDinstruction;


ROM InstructionRom 
(
	.iAddress(     wIP          ),
	.oInstruction( wInstruction )
);

RAM_DUAL_READ_PORT DataRam
(
	.Clock(         Clock        ),
	.iWriteEnable(  rWriteEnable ),
	.iReadAddress0( wInstruction[7:0] ),
	.iReadAddress1( wInstruction[15:8] ),
	.iWriteAddress( wDestination ),
	.iDataIn(       rResult      ),
	.oDataOut0(     wSourceData0 ),
	.oDataOut1(     wSourceData1 )
);

assign wreturn_routine = (rRTS)? wIP_Return : wDestination;
assign wIP = (rBranchTaken) ?   wIPInitialValue : wIP_temp;

assign wIPInitialValue = (Reset) ? 8'b0 : wreturn_routine;
UPCOUNTER_POSEDGE IP
(
.Clock(   Clock                ), 
.Reset(   Reset | rBranchTaken ),
.Initial( wIPInitialValue + 1  ),
.Enable(  1'b1                 ),
.Q(       wIP_temp             )
);

//Clock de 25 MHz 
UPCOUNTER_POSEDGE # (1) Clk25(
	.Clock(Clock ), 
	.Reset(Reset2),
	.Initial(1'b0),
	.Enable(1'b1 ),
	.Q (wClk25   )
);


//Ram de video
RAM_SINGLE_READ_PORT # (.DATA_WIDTH(3),.ADDR_WIDTH(16),.MEM_SIZE(16384)) VideoMemory(
	.Clock( Clock ),
	.iWriteEnable( rVGAWriteEnable ),
	.iReadAddress( wReadRAMAddress),
	.iWriteAddress( wVGAWriteAddress ),//wSourceData0 ),
	.iDataIn( wDestination[2:0] ),
	.oDataOut( {wVGA_R,wVGA_G,wVGA_B} )
);

//
assign wVGAWriteAddress = wSourceData1*100 + wSourceData0;

//VGA controller

VGAcontroller vgac(
		.iClk25M(wClk25),
		.iMasterReset(Reset),
		.iRAMColors({wVGA_R,wVGA_G,wVGA_B}),
		.oHSYNC(VGA_HSYNC),
		.oVSYNC(VGA_VSYNC),
		.oVGA_R(VGA_RED),
		.oVGA_G(VGA_GREEN),
		.oVGA_B(VGA_BLUE),
		.oReadRAMAddress(wReadRAMAddress)
	);

//LCD Controller and its ROM

LCD_Controller lcd_control(
		.iRequest(rRequest),
		.Clock(Clock),
		.Reset(Reset),
		.iROMdata(wROMlcd),
		.oLCD_Enabled(LCD_E),
		.oLCD_RegisterSelect(LCD_RS), 
		.oLCD_StrataFlashControl(SF_CE0),
		.oLCD_ReadWrite(LCD_RW),
		.oLCD_Data(wLCD_Data),
		.oROMaddress(wLCDAdd),
		.oBusy(wBusy)
	);
	
LCD_ROM lcd_rom(
		.iRequest(rRequest),
		.iAddress(wLCDAdd),
		.iALUinstruct(wLCDinstruction),
		.oInstruction(wROMlcd)
	);

assign {SF_D<11>,SF_D<10>,SF_D<9>,SF_D<8>} = wLCD_Data;	

FFD_POSEDGE_SYNCRONOUS_RESET # ( 16 ) FF_LCD
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(rRequest),
	.D(wImmediateValue),
	.Q(wLCDinstruction)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD1 
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[27:24]),
	.Q(wOperation)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD2
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[7:0]),
	.Q(wSourceAddr0)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD3
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[15:8]),
	.Q(wSourceAddr1)
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FFD4
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(1'b1),
	.D(wInstruction[23:16]),
	.Q(wDestination)
);


reg rFFLedEN;
FFD_POSEDGE_SYNCRONOUS_RESET # ( 8 ) FF_LEDS
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable( rFFLedEN ),
	.D( wSourceData1 ),
	.Q( oLed    )
);

//Flip-flop para subrutinas
FFD_POSEDGE_SYNCRONOUS_RESET # ( 16 ) FF_SR
(
	.Clock(Clock),
	.Reset(Reset),
	.Enable(rSubrutineCall),
	.D(wIP_temp),
	.Q(wIP_Return)
);

assign wImmediateValue = {wSourceAddr1,wSourceAddr0};

always @ ( * )
begin
	case (wOperation)
	//-------------------------------------
	`NOP:
	begin
		rFFLedEN       <= 1'b0;
		rBranchTaken   <= 1'b0;
		rWriteEnable   <= 1'b0;
		rResult        <= 0;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	//-------------------------------------
	`ADD:
	begin
		rFFLedEN       <= 1'b0;
		rBranchTaken   <= 1'b0;
		rWriteEnable   <= 1'b1;
		rResult        <= wSourceData1 + wSourceData0;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	//-------------------------------------
	`SUB:
	begin
		rFFLedEN       <= 1'b0;
		rBranchTaken   <= 1'b0;
		rWriteEnable   <= 1'b1;
		rResult        <= wSourceData1 - wSourceData0;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	//-------------------------------------
	`SMUL:
	begin
		rFFLedEN       <= 1'b0;
		rBranchTaken   <= 1'b0;
		rWriteEnable   <= 1'b1;
		rResult        <= wSourceData1 * wSourceData0;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	//-------------------------------------	
	`STO:
	begin
		rFFLedEN       <= 1'b0;
		rWriteEnable   <= 1'b1;
		rBranchTaken   <= 1'b0;
		rResult        <= wImmediateValue;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	//-------------------------------------
	`BLE:
	begin
		rFFLedEN        <= 1'b0;
		rWriteEnable    <= 1'b0;
		rResult         <= 0;
		if (wSourceData1 <= wSourceData0 )
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;
		rSubrutineCall  <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	//-------------------------------------	
	`JMP:
	begin
		rFFLedEN       <= 1'b0;
		rWriteEnable   <= 1'b0;
		rResult        <= 0;
		rBranchTaken   <= 1'b1;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	//-------------------------------------	
	`SHL:
	begin
		rFFLedEN       <= 1'b0;
		rWriteEnable   <= 1'b1;
		rBranchTaken   <= 1'b0;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rResult        <= wSourceData1 << wInstruction[7:0];
		//rResult        <= wSourceData1 << 4;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	
	//-------------------------------------
	`CALL:
	begin
		rFFLedEN       <= 1'b0;
		rWriteEnable   <= 1'b0;
		rResult        <= 0;
		rBranchTaken   <= 1'b1;
		rSubrutineCall <= 1'b1;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	//-------------------------------------
	`RET:
	begin
		rFFLedEN       <= 1'b0;
		rWriteEnable   <= 1'b0;
		rResult        <= 0;
		rBranchTaken   <= 1'b1;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b1;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	
	//-------------------------------------	
	`LED:
	begin
		rFFLedEN       <= 1'b1;
		rWriteEnable   <= 1'b0;
		rResult        <= 0;
		rBranchTaken   <= 1'b0;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	//-------------------------------------	
	`VGA:
	begin
		rFFLedEN       <= 1'b0;
		rWriteEnable   <= 1'b0;
		rResult        <= 0;
		rBranchTaken   <= 1'b0;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b1;
		rRequest       <= 1'b0;
	end
	//-------------------------------------
	`LCD:
	begin
		rFFLedEN       <= 1'b0;
		rWriteEnable   <= 1'b0;
		rBranchTaken   <= 1'b0;
		rResult        <= 0;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b1;
	end
	//-------------------------------------
	`BBU: //Branch if Busy 
	begin
		rFFLedEN        <= 1'b0;
		rWriteEnable    <= 1'b0;
		rResult         <= 0;
		if (wBusy)
			rBranchTaken <= 1'b1;
		else
			rBranchTaken <= 1'b0;
		rSubrutineCall  <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end
	//-------------------------------------
	default:
	begin
		rFFLedEN       <= 1'b1;
		rWriteEnable   <= 1'b0;
		rResult        <= 0;
		rBranchTaken   <= 1'b0;
		rSubrutineCall <= 1'b0;
		rRTS           <= 1'b0;
		rVGAWriteEnable <= 1'b0;
		rRequest       <= 1'b0;
	end	
	//-------------------------------------	
	endcase	
end


endmodule
