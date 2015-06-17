`timescale 1ns / 1ps

module VGAcontroller (
	input wire iClk25M,
	input wire iMasterReset,
	input wire [2:0] iRAMColors,
	output wire oHSYNC,oVSYNC,
	output wire oVGA_R,oVGA_G,oVGA_B,
	output wire [15:0] oReadRAMAddress
	);
	parameter X0_POS = 16'd414, 
			  X1_POS = 16'd514,
			  Y0_POS = 16'd221,
			  Y1_POS = 16'd321;
			  
	wire [15:0] wCurrentCol,wCurrentRow;
	wire wColReset,wRowReset;
	
	//Column Counter
	UPCOUNTER_POSEDGE #(16) ColCount(
		.Clock( iClk25M ), 
		.Reset( iMasterReset | wColReset ),
		.Initial( 16'b0 ),
		.Enable( 1'b1 ),
		.Q( wCurrentCol)
	);
	
	//New Line Logic
	assign wColReset = (wCurrentCol == 16'd799)? 1'b1:1'b0; //800 cycles
	assign oHSYNC = (wCurrentCol < 16'd96)? 1'b0:1'b1; //Pulse width: 96 cycles
	
	//Row Counter
	UPCOUNTER_POSEDGE #(16) RowCount(
		.Clock( iClk25M ), 
		.Reset( iMasterReset | wRowReset ),
		.Initial( 16'b0 ),
		.Enable( wColReset ),
		.Q( wCurrentRow)
	);
	
	//"New Page" Logic
	assign wRowReset = (wCurrentRow == 16'd520 && wColReset)? 1'b1:1'b0; //521 lines
	assign oVSYNC = (wCurrentRow < 16'd2)? 1'b0:1'b1; //Pulse width: 2 lines
	
	//Read color display from RAM
	//100x100 pixels centered in between columns 144 and 784 and between rows 31 and 511
	`ifdef OPTIMAL
		assign oReadRAMAddress = (wCurrentRow-Y0_POS)*100+(wCurrentCol-X0_POS);  
	`else
		assign oReadRAMAddress = ( wCurrentCol > X0_POS-1 && wCurrentCol < X1_POS && wCurrentRow > Y0_POS-1 && wCurrentRow < Y1_POS)? (wCurrentRow-Y0_POS)*100+(wCurrentCol-X0_POS):16'd0;  
	`endif	
	
	//Display a black background
	assign {oVGA_R,oVGA_G,oVGA_B} = (wCurrentCol < X0_POS || wCurrentCol > X1_POS-1 || wCurrentRow < Y0_POS || wCurrentRow > Y1_POS-1)?{1'b0,1'b0,1'b0}:iRAMColors;
	
endmodule

//To test VGA Controller compile this archive with the "-D TEST_VGA" option
`ifdef TEST_VGA 
`define TEST_VGA
/*---------------------------------------------------------------------
			Counter
-----------------------------------------------------------------------*/
module UPCOUNTER_POSEDGE # (parameter SIZE=16)
	(
	input wire Clock, Reset,
	input wire [SIZE-1:0] Initial,
	input wire Enable,
	output reg [SIZE-1:0] Q
	);

  always @(posedge Clock )
  begin
      if (Reset)
        Q = Initial;
      else
		begin
		if (Enable)
			Q = Q + 1;
			
		end			
  end

/*---------------------------------------------------------------------
			Test VGA Controller
-----------------------------------------------------------------------*/
endmodule
module Test;
	reg Clk25M, MasterReset;
	reg [2:0] RAMColors;
	wire [15:0] ReadRAMAddress; 
	wire wHsync,wVsync,wR,wG,wB;
	
	VGAcontroller vgac(
		.iClk25M(Clk25M),
		.iMasterReset(MasterReset),
		.iRAMColors(RAMColors),
		.oHSYNC(wHsync),
		.oVSYNC(wVsync),
		.oVGA_R(wR),
		.oVGA_G(wG),
		.oVGA_B(wB),
		.oReadRAMAddress(ReadRAMAddress)
	);

	initial begin
		Clk25M = 0;
		MasterReset = 0;
		RAMColors = 0;
		
		
		$dumpfile("senales.vcd");
		$dumpvars;
		
		#60 MasterReset = 1;
		#60 MasterReset = 0;
		#20000000;
        $finish;
	end
	
	always@(ReadRAMAddress) begin
		RAMColors = RAMColors +1; 
	end
	
	always begin
		#20 Clk25M = ~Clk25M;
	end
	
endmodule
`endif
