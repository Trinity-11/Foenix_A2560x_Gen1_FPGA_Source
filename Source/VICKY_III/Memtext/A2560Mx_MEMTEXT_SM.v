`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/26/2025 10:19:26 PM
// Design Name: 
// Module Name: F256x_MEMTEXT_SM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module A2560Mx_MEMTEXT_SM(

input		wire				VGE_Engine_Rst_i,
input		wire				CPU_2xClk_i,
input  		wire  				Mstr_Ctrl_MemText_Enable_i,		// From Master Control Register
input  		wire   	[1:0]		Mstr_Ctrl_Video_Mode_i,			// 0 - 1280x960, 1:1280x1024
// From VMemory Interface Block
// Inputs
input		wire				VRAM_Data_Valid_i,
input		wire	[31:0]		VRAM_Data_2_MEMTEXT_i,			// used to be 32 - Now it is 16bits
input		wire				Counter_Reached_Count_i,
// Outputs
output		reg					Counter_Enable_MT_o,
output		reg					Counter_Load_MT_o,
output		wire	[31:0]		MEMTEXT_Target_Addy_Start_o,
output		wire	[31:0]		MEMTEXT_Target_Addy_Stop_o,
// CPU Interface
input       wire                iBUS_Clk_i,
input		wire	[31:0]		iBUS_A_i,        // 8192
input  		wire  				iBUS_A_Valid_i,
input  		wire  	[7:0]		iBUS_D8_i,
input 		wire  	[15:0]		iBUS_D16_i,
input 		wire  	[31:0]		iBUS_D32_i,
input   	wire    [1:0]		iBUS_D_Siz_i,
input		wire				iBUS_RWn_i,
input  		wire  	[3:0]		iBUS_BE_i,		// in the A2560Mx - BE is 4bits
input  		wire  				iBUS_WE_i,		// in the A2560Mx - WE is 1bit, in the FA25602, WE is actually 4 bits

input 		wire   				CS_VSRAM_B_i,

// Control Registers and Data Output for the Memtext Registers + LUT
input		wire				CS_MEMTEXT_i,           	// CS_MEMTEXT_o		= ( iBUS_A_i[17:12] == 6'b10_1000) & iBUS_CS_GAVIN_i; $FFB2_8000		$FFB2_8FFF	(4K) - MEMTEXT Control Registers
output	    reg  	[31:0]		DataOut_MEMTEXT_o,
// Chip Select and Dataout for the FONT Block
input       wire                CS_MEMTEXT_LUT_i,			// CS_MEMTEXT_LUT_o	= ( iBUS_A_i[17:12] == 6'b10_1001) & iBUS_CS_GAVIN_i; $FFB2_9000		$FFB2_9FFF	(4K) - MEMTEXT LUT TABLES
output      wire   [31:0]		DataOut_MEMTEXT_LUT_o,
input       wire                CS_MEMTEXT_FONT_i,			// $FFB2_A000		$FFB2_BFFF	(1K) - MEMTEXT FONT MEMORY
output      wire    [31:0]      DataOut_MEMTEXT_FONT_o,
//Video Section
input		wire				VideoClock_i,
input		wire				HBlanking_i,
input		wire				VBlanking_i,
input   	wire  				VBlanking_2LinePrecharge_i,
input		wire	[11:0]		HLineCount_i,
input		wire	[11:0]		HPixelCount_i,
input		wire				SOF_i,


output	    wire				CAPTURING_DATA_MEM_o,
output 		wire   				Wait_BufferB_TA_o,

output      wire                Mono_Font_Output_o,
output 		wire  				Mono_Cursor_Output_o,
output   	wire   				MEMTxtClrBGisZero_o,
output      wire    [31:0]      MEMTEXT_RGB_o
);

assign DataOut_MEMTEXT_LUT_o = 32'hAAAA_5555;


//parameter RES_PACKET_FETCH = 32'd256;		//Number of Char to fetch x 2 (Char + Attr) for the resolution
parameter RES_PACKET_FETCH = 32'd320;		//Number of Char to Fetch (in byte x 2) 16bits per Characters but we are fetching 2 Character at the time. (32bits)
// 1024x768 = 256 Bytes
// 1920x1080 = 480 Bytes (8bits Wide)
// 1280x960 = 320 Bytes 
// 640x480 = 160
// 320x240 = 80

// 68C816 REGS
//reg 	[7:0]   	MEMTEXT_REG[0:31];
// M68K REGS
reg 	[31:0]   	MEMTEXT_REG[0:15];

reg 	[6:0]   	TextColor_Addy_Pointer;
reg   	[31:0]		Char_Memory_Pointer;
reg   	[31:0]		Colr_Memory_Pointer;
reg   				MemText_Active;
reg  				Char_Color_Flag;

reg	    [31:0]		Background_Color_LUT[0:1];
reg		[31:0]		Foreground_Color_LUT[0:1];
reg   	[1:0]		MEMTxtClrBGisZero_Lat;
reg  				PageWrite;
reg  				MEM_TA_RDY;

// WIRE
wire   	[8:0]		CharOut_Pointer;
wire   	[15:0]		CharAttr;
wire    [15:0]  	ColorFGBG;

wire 	[31:0] 		MEMTXT_START_ADDY;
wire 	[31:0] 		MEMCLR_START_ADDY;
wire        		CS_CTRL_REG;
wire    [15:0]		CharPlusAttribute;
wire    [15:0]		EightbisColorBGFG;
wire   	[31:0]		FG_LUT_Data;
wire  	[31:0]		BG_LUT_Data;
wire  	[7:0]		FONT_Data;
wire    [12:0]		Font_Line_Addy;
wire    [7:0]		Font_Line_Data;
wire 	[3:0] 		Cursor_Height_Ptr;
reg    	[7:0]		Cursor_Graph_Data;
wire    [31:0]		Temp_Out_BG_LUT;
wire  	[31:0]		Temp_Out_FG_LUT;
wire	[31:0]		Foreground_Color_Out;
wire	[31:0]		Background_Color_Out;
wire    [7:0]		Color_Font_Blue;
wire    [7:0]		Color_Font_Green;
wire    [7:0]		Color_Font_Red;
wire  				Mono_Font_Output;
wire    [23:0]		Cursor_Color;
wire   				MEMTxtClrBGisZero;
wire   				Horizontal_Precharge;
//wire  				Horizontal_Active; // Not used

//Color Mode
assign		Color_Font_Blue   = 	Mono_Cursor_Output_o ? Cursor_Color[7:0] : ( Mono_Font_Output ? Foreground_Color_Out[7:0]   : Background_Color_Out[7:0] );
assign		Color_Font_Green  = 	Mono_Cursor_Output_o ? Cursor_Color[15:8] : ( Mono_Font_Output ? Foreground_Color_Out[15:8]  : Background_Color_Out[15:8] );
assign		Color_Font_Red    = 	Mono_Cursor_Output_o ? Cursor_Color[23:16] : ( Mono_Font_Output ? Foreground_Color_Out[23:16] : Background_Color_Out[23:16] );

assign 		MEMTXT_START_ADDY = MEMTEXT_REG[2][31:0];	// Start Address Text (within 8Meg)
assign 		MEMCLR_START_ADDY = MEMTEXT_REG[3][31:0];	// Start Address Color

assign 		MEMTEXT_RGB_o = {Color_Font_Red, Color_Font_Green, Color_Font_Blue};
assign 		Mono_Font_Output_o = Mono_Font_Output;
// Char_Color_Flag = 1'b0 -> Char+Attributes , Char_Color_Flag = 1'b1 -> Colors
assign		MEMTEXT_Target_Addy_Start_o = Char_Color_Flag ? Colr_Memory_Pointer 				: Char_Memory_Pointer;
//assign 		MEMTEXT_Target_Addy_Stop_o  = Char_Color_Flag ? (Colr_Memory_Pointer + 24'd160) 	: (Char_Memory_Pointer + 24'd160);
assign 		MEMTEXT_Target_Addy_Stop_o  = Char_Color_Flag ? (Colr_Memory_Pointer + RES_PACKET_FETCH) 	: (Char_Memory_Pointer + RES_PACKET_FETCH);

// $FFB2_8000
///////////////////////////////////////////
//// CONTROL REGISTERS
///////////////////////////////////////////
always @ (posedge iBUS_Clk_i)
begin
	if (VGE_Engine_Rst_i)
	begin
		MEMTEXT_REG[0]  <= 32'h0000_0000; 	// Memory Text Control, Cursor Register
		MEMTEXT_REG[1]  <= 32'h0000_0000;	// Cursor X, Y
		MEMTEXT_REG[2]  <= 32'h0001_0000;	// Start Address Text
		MEMTEXT_REG[3]  <= 32'h0002_0000;	// Start Address Color
		MEMTEXT_REG[4]  <= 32'h0000_2020;	// Cursor Color ARGB
		MEMTEXT_REG[5]  <= 32'h0000_0000;	// RESERVED
		MEMTEXT_REG[6]  <= 32'h0000_0000;   // RESERVED
		MEMTEXT_REG[7]  <= 32'h0000_0000;	// RESERVED

		MEMTEXT_REG[8]  <= 32'h55AA_55AA;	// CURSOR 8x8 / CURSOS 8x16
		MEMTEXT_REG[9]  <= 32'h55AA_55AA;	// CURSOR 8x8 / CURSOS 8x16
		MEMTEXT_REG[10] <= 32'h0000_0000;  	// CURSOS 8x16
		MEMTEXT_REG[11] <= 32'h0000_0000;	// CURSOS 8x16
		MEMTEXT_REG[12] <= 32'h0000_0000;	// RESERVED
		MEMTEXT_REG[13] <= 32'h0000_0000;	// RESERVED
		MEMTEXT_REG[14] <= 32'h0000_0000;   // RESERVED
		MEMTEXT_REG[15] <= 32'h0000_0000;	// RESERVED		
	end
	else
	begin
		if (CS_MEMTEXT_i && !iBUS_RWn_i && (iBUS_D_Siz_i == 2'b00) && iBUS_WE_i) begin 
				MEMTEXT_REG[iBUS_A_i[5:2]][31:0] <= iBUS_D32_i;	// Just allow Write Cycle to the first 8 Registers
		end 
	end
end

// CPU Readback
always @ ( * )
begin
		DataOut_MEMTEXT_o = MEMTEXT_REG[iBUS_A_i[5:2]][31:0];
end 

wire 			MemTextModeEnable	= MEMTEXT_REG[0][0];		// 1'b1 = Memory Text Mode Enable, 1'b0
wire 			MemTextModeSize		= MEMTEXT_REG[0][1];		// 1'b1 = 8x16, 1'b0 = 8x8
wire    [7:0]	MemTextCursorCtrl	= MEMTEXT_REG[0][15:8];		// Cursor Control Register
// Cursor Control Register
// bit[0] = Cursor Enable (8)
// bit[1] = Cursor Rate Low
// bit[2] = Cursor Rate Hi
// bit[3] = FONT Bank Low (to be moved in the attributes)
// bit[4] = FONT Bank hi (to be moved in the attributes)
// bit[5] = TBD?
// bit[6] = Font Size -> 0 - 8x8, 1 - 8x16
// bit[7] = ???
wire	[7:0]	MemTextCursorX		= MEMTEXT_REG[1][7:0];			// X Position for Cursor
wire	[7:0]	MemTextCursorY		= MEMTEXT_REG[1][15:8];			// Y Position for Cursor
assign 			Cursor_Color		= MEMTEXT_REG[4][23:0];

always @ ( * ) begin 

	case(  Cursor_Height_Ptr[3:0] )
		4'd0:	Cursor_Graph_Data <= MEMTEXT_REG[8][31:24];
		4'd1:	Cursor_Graph_Data <= MEMTEXT_REG[8][23:16];
		4'd2:	Cursor_Graph_Data <= MEMTEXT_REG[8][15:8];
		4'd3:	Cursor_Graph_Data <= MEMTEXT_REG[8][7:0];
		4'd4:	Cursor_Graph_Data <= MEMTEXT_REG[9][31:24];
		4'd5:	Cursor_Graph_Data <= MEMTEXT_REG[9][23:16];
		4'd6:	Cursor_Graph_Data <= MEMTEXT_REG[9][15:8];
		4'd7:	Cursor_Graph_Data <= MEMTEXT_REG[9][7:0];
		4'd8:	Cursor_Graph_Data <= MEMTEXT_REG[10][31:24];
		4'd9:	Cursor_Graph_Data <= MEMTEXT_REG[10][23:16];
		4'd10:	Cursor_Graph_Data <= MEMTEXT_REG[10][15:8];
		4'd11:	Cursor_Graph_Data <= MEMTEXT_REG[10][7:0];
		4'd12:	Cursor_Graph_Data <= MEMTEXT_REG[11][31:24];
		4'd13:	Cursor_Graph_Data <= MEMTEXT_REG[11][23:16];
		4'd14:	Cursor_Graph_Data <= MEMTEXT_REG[11][15:8];
		4'd15:	Cursor_Graph_Data <= MEMTEXT_REG[11][7:0];		
	endcase
end 

/////////////////////////////////
///////
/////// State Machine to Generate & Trigger the Capture of Data From memory
//////
/////////////////////////////////
reg [3:0]	SM_Addy;
localparam 			ADDY_IDLE = 4'b0000,
					ADDY_SM0  = 4'b0001,
					ADDY_SM1  = 4'b0011,
					ADDY_SM2  = 4'b0010,
					ADDY_SM3  = 4'b0110,
					ADDY_SM4  = 4'b0111,
					ADDY_SM5  = 4'b0101,
					ADDY_SM6  = 4'b0100,
					ADDY_SM7  = 4'b1100,
					ADDY_SM8  = 4'b1101,
					ADDY_SM9  = 4'b1111,
					ADDY_SM10 = 4'b1110,
					ADDY_BR0  = 4'b1010,
					ADDY_BR1  = 4'b1011,
					ADDY_BR2  = 4'b1001,
					ADDY_BR3  = 4'b1000;

// Resync Visible_Local_Line_Counter_i
reg [3:0] VisibleLineReSync0, VisibleLineReSync1, VisibleLineReSync2;
reg  	  VBlanking_ReSync0, VBlanking_ReSync1, VBlanking_ReSync2;

reg [3:0] Line_Counter;
reg [2:0] Mstr_Ctrl_Video_Mode_ReSync;

always @ ( posedge VideoClock_i ) begin 
	Mstr_Ctrl_Video_Mode_ReSync[0] <= Mstr_Ctrl_Video_Mode_i[0];
	Mstr_Ctrl_Video_Mode_ReSync[1] <= Mstr_Ctrl_Video_Mode_ReSync[0];
	if ( Mstr_Ctrl_Video_Mode_ReSync[1] == Mstr_Ctrl_Video_Mode_ReSync[0] )
		Mstr_Ctrl_Video_Mode_ReSync[2] <= Mstr_Ctrl_Video_Mode_ReSync[1];
end 


// THis counters Begins to Count 2 Lines before the First line active to let the Data to be fetched
always @ ( posedge VideoClock_i ) begin 
	if ( VBlanking_2LinePrecharge_i ) begin 
		//if (HPixelCount_i == 12'd799) 
		if (HPixelCount_i == (Mstr_Ctrl_Video_Mode_ReSync[2] ? 12'd1687 : 12'd1799)) // 0: 1280x960 1: 1280x1024 
			Line_Counter <= Line_Counter + 4'b0001;
	end 
	else begin  
		Line_Counter <= 4'b0000;
	end 
end 


// ReSync Line
always @ ( posedge CPU_2xClk_i ) begin 
	VisibleLineReSync0 <= Line_Counter[3:0];
	VisibleLineReSync1 <= VisibleLineReSync0;
	if ( VisibleLineReSync1 == VisibleLineReSync0) 
		VisibleLineReSync2 <= VisibleLineReSync1;

	VBlanking_ReSync0 <= VBlanking_2LinePrecharge_i;		// Precharge here
	VBlanking_ReSync1 <= VBlanking_ReSync0;
	if ( VBlanking_ReSync1 == VBlanking_ReSync0) 
		VBlanking_ReSync2 <= VBlanking_ReSync1;		
end 
reg [2:0]  MemTextModeSize_RESYNC;
reg [2:0]  Mstr_Ctrl_MemText_Enable_RESYNC;


always @ ( posedge CPU_2xClk_i ) begin 

	Mstr_Ctrl_MemText_Enable_RESYNC[0] <= Mstr_Ctrl_MemText_Enable_i;
	Mstr_Ctrl_MemText_Enable_RESYNC[1] <= Mstr_Ctrl_MemText_Enable_RESYNC[0];
	if ( Mstr_Ctrl_MemText_Enable_RESYNC[1] == Mstr_Ctrl_MemText_Enable_RESYNC[0] )
		Mstr_Ctrl_MemText_Enable_RESYNC[2] <= Mstr_Ctrl_MemText_Enable_RESYNC[1];


	MemTextModeSize_RESYNC[0] <= MemTextModeSize;
	MemTextModeSize_RESYNC[1] <= MemTextModeSize_RESYNC[0];
	if ( MemTextModeSize_RESYNC[1] == MemTextModeSize_RESYNC[0] )
		MemTextModeSize_RESYNC[2] <= MemTextModeSize_RESYNC[1];		
end 
/*
Chipscope1 MyDearChipscope (
	.clk(CPU_2xClk_i), // input wire clk


	.probe0(MEMTEXT_Target_Addy_Start_o[23:0]), // input wire [23:0]  probe0  
	.probe1(MEMTEXT_Target_Addy_Stop_o[23:0]), // input wire [23:0]  probe1 
	.probe2({CS_MEMTEXT_LUT_i, VisibleLineReSync2[2:0], VBlanking_ReSync2, MemText_Active, Char_Color_Flag, Counter_Reached_Count_i, Counter_Load_MT_o, Counter_Enable_MT_o, SM_Addy}), // input wire [15:0]  probe2 
	.probe3(VRAM_Data_2_MEMTEXT_i), // input wire [15:0]  probe3 
	.probe4({ Time2Count_i, VRAM_Data_Valid_i, MemTextModeEnable, Mstr_Ctrl_MemText_Enable_i, HPixelCount_i}) // input wire [15:0]  probe4
);
*/
/*
MiniScoop MyScoop (
	.clk(CPU_2xClk_i), // input wire clk

	.probe0(MEMTEXT_Target_Addy_Start_o), // input wire [23:0]  probe0  
	.probe1(MEMTEXT_Target_Addy_Stop_o), // input wire [23:0]  probe1 
	.probe2({Debug_i, VisibleLineReSync2[2:0], VBlanking_ReSync2, MemText_Active, Char_Color_Flag, Counter_Reached_Count_i, Counter_Load_MT_o, Counter_Enable_MT_o, SM_Addy}), // input wire [15:0]  probe2 
	.probe3(VRAM_Data_2_MEMTEXT_i), // input wire [15:0]  probe3 
	.probe4({4'b0000, HPixelCount_i}) // input wire [15:0]  probe4
);
*/
wire 	FONT8x8_Trigger = VisibleLineReSync2[2:0] == 3'b000;
wire 	FONT8x16_Trigger = VisibleLineReSync2[3:0] == 4'b0000;
//
assign 	CAPTURING_DATA_MEM_o 	= MemText_Active;
assign 	Wait_BufferB_TA_o 		= MEM_TA_RDY;

always @ ( posedge CPU_2xClk_i ) begin 
	if ( VGE_Engine_Rst_i ) begin 
		Counter_Enable_MT_o <= 1'b0;
		Counter_Load_MT_o 	<= 1'b0;
		Char_Memory_Pointer <= 32'h00_0000;
		Colr_Memory_Pointer <= 32'h00_0000;
		SM_Addy				<= ADDY_IDLE;
		Char_Color_Flag		<= 1'b0;
		MemText_Active		<= 1'b0;
		PageWrite			<= 1'b0;
		MEM_TA_RDY			<= 1'b0;
	end 
	else begin 

		case ( SM_Addy )

		ADDY_IDLE: begin
			if (  CS_VSRAM_B_i ) begin 
				SM_Addy	<= ADDY_BR0;
			end 
			else begin 			
				// VBlanking = 1 (Active Display), = 0 - Blanking (DMA Time)
				if (( MemTextModeSize_RESYNC[2] ? FONT8x16_Trigger : FONT8x8_Trigger ) && Mstr_Ctrl_MemText_Enable_RESYNC[2]) begin 
					if (  VBlanking_ReSync2  ) begin 
						// Go Fetch Char & Colors every 8 lines
						if ( VisibleLineReSync2[2:0] == 3'b000) begin 
							SM_Addy	<= ADDY_SM0;		// Go Request the bus
							Char_Color_Flag		<= 1'b0;
							MemText_Active		<= 1'b1;
							Counter_Load_MT_o 	<= 1'b1;
						end
					end 
					else begin 
					// DMA Time, Can't do anything
					// Init The Pointer for Char
						PageWrite <= 1'b0;
						Char_Memory_Pointer <= MEMTXT_START_ADDY;
						Colr_Memory_Pointer <= MEMCLR_START_ADDY;
						Counter_Enable_MT_o <= 1'b0;
						Counter_Load_MT_o 	<= 1'b0;
						SM_Addy	<= ADDY_IDLE;					
					end 
				end
				else begin 
					SM_Addy	<= ADDY_IDLE;
				end
			end
		end 

		// Load the Addy in the Counter
		// Text + Attribute Here
		// Char_Color_Flag == 1'b0
		ADDY_SM0: begin
			Counter_Load_MT_o 	<= 1'b0;
			SM_Addy				<= ADDY_SM1;
		end 

		ADDY_SM1: begin
			Counter_Enable_MT_o <= 1'b1;			
			SM_Addy				<= ADDY_SM2;
		end  

		// Counter Enable Here
		ADDY_SM2: begin 	
			SM_Addy				<= ADDY_SM3;
		end

		// Wait for the Char & Attributes to fill the DP Memory for the next 8 Lines
		ADDY_SM3: begin 	
			if (Counter_Reached_Count_i) begin
				Counter_Enable_MT_o <= 1'b0;			// Stops the Counters (When we are here the Starts Addy = Stop Addy)
				MemText_Active <= 1'b0;
				SM_Addy	<= ADDY_SM4;
			end
			else begin
				SM_Addy	<= ADDY_SM3;
			end
		end

		//Let's go Fetch the Color Now	
		ADDY_SM4: begin 	
			//Char_Memory_Pointer <= Char_Memory_Pointer + 24'd160; // 640x480	(80 Character Per Line)
			Char_Memory_Pointer <= Char_Memory_Pointer + RES_PACKET_FETCH;	// 1024x768 (128 Character Per Line)
			Char_Color_Flag		<= 1'b1;
			SM_Addy				<= ADDY_SM5;
		end
			
		// In Color Mode Here
		// Char_Color_Flag == 1'b1
		ADDY_SM5: begin 	
			Counter_Load_MT_o 	<= 1'b1;			
			SM_Addy				<= ADDY_SM6;
		end
			
		ADDY_SM6: begin
			Counter_Load_MT_o 	<= 1'b0;
			MemText_Active 		<= 1'b1;
			SM_Addy				<= ADDY_SM7;
		end
			
		// Start the The Counter
		ADDY_SM7: begin 	
			Counter_Enable_MT_o <= 1'b1;			
			SM_Addy				<= ADDY_SM8;
		end
			
		ADDY_SM8: begin
			if (Counter_Reached_Count_i) begin
				Counter_Enable_MT_o <= 1'b0;			// Stops the Counters (When we are here the Starts Addy = Stop Addy)
				MemText_Active <= 1'b0;
				SM_Addy	<= ADDY_SM9;
			end
			else begin
				SM_Addy	<= ADDY_SM8;
			end			
		end
			
		ADDY_SM9: begin 
			Char_Color_Flag		<= 1'b0;			
			//Colr_Memory_Pointer <= Colr_Memory_Pointer + 24'd160; // 2 Bytes Here - 640x480	(80 Character Per Line)
			Colr_Memory_Pointer <= Colr_Memory_Pointer + RES_PACKET_FETCH; 	// 2 Bytes Here - 1024x768 (128 Character Per Line)		
			SM_Addy				<= ADDY_SM10;	// Go back for the next Time we need to go fetch more data
			PageWrite			<= PageWrite ^ 1'b1; // Switch the Page So We can Start Early and not interfere with the Active line
		end

		// Wait for the line to not be 000 anymore 
		ADDY_SM10: begin 
			if ( MemTextModeSize_RESYNC[2] ? FONT8x16_Trigger : FONT8x8_Trigger )
				SM_Addy				<= ADDY_SM10;	// Go back for the next Time we need to go fetch more data
			else 
				SM_Addy				<= ADDY_IDLE;	// Go back for the next Time we need to go fetch more data			
		end 

		// Ask for the Arbiter to have access to the bus
		ADDY_BR0: begin 
			SM_Addy	<= ADDY_BR1;
		end

		// Wait for the Arbiter to Grant the bus, let's go do our business
		ADDY_BR1: begin 
			SM_Addy	<= ADDY_BR2;
			MEM_TA_RDY <= 1'b1;
		end

		// Job is over, tell the Arbiter that we are done
		ADDY_BR2: begin 
			SM_Addy	<= ADDY_BR3;
		end

		// Wait for the Arbiter to tell us the bus is not our own anymore
		ADDY_BR3: begin 
			SM_Addy	<= ADDY_IDLE;
			MEM_TA_RDY <= 1'b0;
		end

		default: begin 
			SM_Addy	<= ADDY_IDLE;
		end 
		endcase


	end 
end 
// 
always @ (posedge CPU_2xClk_i) 
begin
	if ( VGE_Engine_Rst_i ) begin
		TextColor_Addy_Pointer <= 6'd0;
	end
	else begin
		if ( MemText_Active ) begin 
			if ( VRAM_Data_Valid_i )
				TextColor_Addy_Pointer <= TextColor_Addy_Pointer + 6'd1;
		end 
		else begin 
			TextColor_Addy_Pointer <= 6'd0;
		end 
	end
end


// Quartus 13.1
MEMTEXT_DP	TEXT_MEMORY (
	.wrclock ( CPU_2xClk_i ),
	.wren ( VRAM_Data_Valid_i & !Char_Color_Flag ),
	.wraddress ( {PageWrite, TextColor_Addy_Pointer} ),
	.data ( {VRAM_Data_2_MEMTEXT_i[15:0], VRAM_Data_2_MEMTEXT_i[31:16]} ),	
// Read Side
	.rdclock ( VideoClock_i ),
	.rdaddress ( CharOut_Pointer ),
	.q ( CharAttr )
	);

MEMTEXT_DP	COLOR_MEMORY (
	.wrclock ( CPU_2xClk_i ),
	.wren ( VRAM_Data_Valid_i & Char_Color_Flag ),
	.wraddress ( {PageWrite, TextColor_Addy_Pointer} ),
	.data ( {VRAM_Data_2_MEMTEXT_i[15:0], VRAM_Data_2_MEMTEXT_i[31:16]} ),	
// Read Side
	.rdclock ( VideoClock_i ),
	.rdaddress ( CharOut_Pointer ),
	.q ( ColorFGBG )
	);


////////////////////////////////////
// TEXT LINE MEMORY - 2 Clock Cycle Latency
////////////////////////////////////
// Vivado
/*
MEMTEXT_DP TEXT_MEMORY ( 
  .clka( CPU_2xClk_i ),     					// input wire clka
  .wea( VRAM_Data_Valid_i & !Char_Color_Flag ),      // input wire [0 : 0] wea
  .addra( {PageWrite, TextColor_Addy_Pointer} ),  			// input wire [7 : 0] addra
  .dina({VRAM_Data_2_MEMTEXT_i[15:0], VRAM_Data_2_MEMTEXT_i[31:16]}),    				// input wire [15 : 0] dina
// 
  .clkb( VideoClock_i ),    					// input wire clkb
  .addrb( CharOut_Pointer ),  					// input wire [8 : 0] addrb
  .doutb( CharAttr )  							// output wire [15 : 0] doutb
);
*/
//// COLOR MEMORY - 2 Clock Cycle Latency
// Vivado
/*
MEMTEXT_DP COLOR_MEMORY ( 
  .clka( CPU_2xClk_i ),     					// input wire clka
  .wea( VRAM_Data_Valid_i & Char_Color_Flag ),     // input wire [0 : 0] wea
  .addra( {PageWrite, TextColor_Addy_Pointer} ),  			// input wire [6 : 0] addra
  .dina({VRAM_Data_2_MEMTEXT_i[15:0], VRAM_Data_2_MEMTEXT_i[31:16]}),    				// input wire [15 : 0] dina
// 
  .clkb(VideoClock_i),    						// input wire clkb
  .addrb(CharOut_Pointer ),  					// input wire [8 : 0] addrb
  .doutb( ColorFGBG )  							// output wire [15 : 0] doutb   - Color Output
);
*/


/*
MiniScoop MyScoop (
	.clk(VideoClock_i), // input wire clk

	.probe0(CharAttr), // input wire [23:0]  probe0  
	.probe1(ColorFGBG), // input wire [23:0]  probe1 
	.probe2({1'b0, CharOut_Pointer[6:0], Mono_Cursor_Output_o, Mono_Font_Output, HBlanking_i, (MemTextModeEnable & Mstr_Ctrl_MemText_Enable_i), Horizontal_Active, Horizontal_Precharge, Vsync_EDGE[1:0]}), // input wire [15:0]  probe2 
	.probe3( HLineCount_i), // input wire [15:0]  probe3 
	.probe4( HPixelCount_i) // input wire [15:0]  probe4
);
*/

reg [1:0] Vsync_EDGE;
always @ (posedge VideoClock_i) begin 
	Vsync_EDGE[0] <= VBlanking_i;			// THis is to Deliver the Information so the normal VBlanking is right
	Vsync_EDGE[1] <= Vsync_EDGE[0];			// THis is NOT to fetch the data
end 

//assign Horizontal_Precharge = (HPixelCount_i > (12'd159 - MEMTEXT_REG[7]));
// 640x480
//assign Horizontal_Precharge = (HPixelCount_i > 12'd149);		// Active - 10
//assign Horizontal_Active 	= (HPixelCount_i > 12'd159);		// HBlanking last 160 VideoClock Cycle
// 1024x768 (320 Pixel )
//assign Horizontal_Active 	= (HPixelCount_i > 12'd319);		// HBlanking last 320 VideoClock Cycle
//assign Horizontal_Precharge = (HPixelCount_i > 12'd309);		// Active - 10

//1280x960 (520 Pixel Blanking)
//assign Horizontal_Active 	= (HPixelCount_i > 12'd519);		// HBlanking last 320 VideoClock Cycle
assign Horizontal_Precharge = (HPixelCount_i > 12'd509);		// Active - 10

////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////
//// FONT Display Side
////
//// No Border 
//// 8x8 / 8x16
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

MEMText_FONT_StateMachine  MEMText_FONT_SM(
//Clock and reset
	.video_clk_i( VideoClock_i ),					//input		wire
	.video_rst_i( VGE_Engine_Rst_i ),					//input		wire

	.TextMode_Enable_i( MemTextModeEnable & Mstr_Ctrl_MemText_Enable_i),
	// 1024x768
	//.FONT_Height_Constant_i( MemTextModeSize ? 8'h10 : 8'h08 ),		//input		wire	[7:0]
	//.FONT_Vertical_Num_Lines_i( MemTextModeSize ? 8'd48 : 8'd96 ),		//input		wire	[7:0]
	// 1280x960
	.FONT_Height_Constant_i( MemTextModeSize ? 8'h10 : 8'h08 ),		//input		wire	[7:0]
	.FONT_Vertical_Num_Lines_i( MemTextModeSize ? 8'd60 : 8'd120 ),		//input		wire	[7:0]
	// 1024x768
//	.FONT_Horizontal_Num_Chars_i( 8'd128 ),	//input		wire	[7:0]
	// 1280x960
	.FONT_Horizontal_Num_Chars_i( 8'd160 ),	//input		wire	[7:0]
	.VideoMode_Double_i( 1'b0 ),		//input		wire		

	.Vsync_EDGE_i( Vsync_EDGE ),
	.Horizontal_Precharge_i(Horizontal_Precharge  ),		//input		wire - Time to Begin the Process of Fetching Data to it falls at the right time
// Text Box Active Signals
	.Horizontal_Active_i( HBlanking_i ),			// input	wire
// 1 Pulse Start Of Frame (8 Pixel Long)
	.SOF_i( SOF_i ),							// Input
// Text Box - Text Memory Pointer & Data
	.ASCII_Text_Data_i( CharAttr[7:0] ),				// input	wire	[7:0]		-
	.ASCII_Attr_Data_i( CharAttr[15:8] ),
	.ASCII_Text_Addy_o( CharOut_Pointer ),				// output	wire	[6:0]	    = X_Char_Count[6:0] 

	.Mono_Font_Output_o( Mono_Font_Output ),			// output	wire				- Char Graph Stream
	.Mono_Cursor_Output_o( Mono_Cursor_Output_o  ),			// output   wire   				- Char Graph Stream
	.Mono_Cursor_Active_o(  ),			// output   wire  				- Enable Graph Stream

// FONT Memory Address and Data.
	.Font_Line_Data_i( Font_Line_Data ),				//input		wire	[7:0]		
	.Font_Line_Addy_o( Font_Line_Addy ),				//output 	wire	[12:0]

	.Cursor_X_Input_i( MemTextCursorX ),				//input		wire	[15:0]	    
	.Cursor_Y_Input_i( MemTextCursorY ),				//input		wire	[15:0]
	.Cursor_Height_Pointer_o( Cursor_Height_Ptr ), 		//output    wire    [3:0]
	.Cursor_Graph_Data_i( Cursor_Graph_Data ),
	.Cursor_Control_Reg_i( MemTextCursorCtrl )			//input		wire 	[7:0]		
	
);

// Full DP - Artix
// 1 Clock Latency - Now 8K (2x Banks of 8x8, 1x Bank of 8x16)
wire [7:0] FONT_CPU_BUS;
/*
MEMTEXT_FONT MEM_TEXT_FONT (
    .clka( iBUS_Clk_i ),
    .wea( !iBUS_RWn_i & CS_MEMTEXT_FONT_i & ((iBUS_BE_i[1:0] == 2'b01) | (iBUS_BE_i[1:0] == 2'b10)) ),
    .addra( iBUS_A_i[12:0] ),		// 8K Bank
    .dina( iBUS_D8_i ),
    .douta( FONT_CPU_BUS ),

	// Video Side
    .clkb( VideoClock_i ),
    .web( 1'b0 ),
    .addrb( { Font_Line_Addy[12:0]} ),	// [12:0] 8K Only for now
    .dinb( 8'h00 ),
    .doutb( Font_Line_Data )
);
*/
MEMTEXT_FONT MEM_TEXT_FONT(
	.clock_a( iBUS_Clk_i ),
	.wren_a( !iBUS_RWn_i & CS_MEMTEXT_FONT_i & ((iBUS_BE_i[1:0] == 2'b01) | (iBUS_BE_i[1:0] == 2'b10)) ),	
	.address_a( iBUS_A_i[12:0] ),
	.data_a( iBUS_D8_i ),
	.q_a( FONT_CPU_BUS ),

	.clock_b( VideoClock_i ),
	.wren_b(  1'b0 ),
	.address_b( { Font_Line_Addy[12:0]} ),	
	.data_b( 8'h00 ),
	.q_b( Font_Line_Data )
);


assign DataOut_MEMTEXT_FONT_o = {4{FONT_CPU_BUS}};

// Quartus
MEMTEXT_LUT_xG	F2560L2_FG_LUT (
// Write Side
	.wrclock ( iBUS_Clk_i ),
	.wren ( ( !iBUS_RWn_i & CS_MEMTEXT_LUT_i & !iBUS_A_i[11]) ? iBUS_WE_i : 4'b0000 ),
	.wraddress (iBUS_A_i[10:2] ),
	.data ( iBUS_D32_i ),
// Read Side
	.rdclock ( VideoClock_i ),
	.rdaddress ( {CharAttr[10], ColorFGBG[15:8]} ),
	.q ( Temp_Out_FG_LUT )
	);

MEMTEXT_LUT_xG	F2560L2_BG_LUT (
// Write Side
	.wrclock ( iBUS_Clk_i ),
	.wren ( ( !iBUS_RWn_i & CS_MEMTEXT_LUT_i & iBUS_A_i[11]) ? iBUS_WE_i : 4'b0000 ),
	.wraddress (iBUS_A_i[10:2] ),
	.data ( iBUS_D32_i ),
// Read Side
	.rdclock ( VideoClock_i ),
	.rdaddress (  {CharAttr[11], ColorFGBG[7:0]} ),
	.q ( Temp_Out_BG_LUT )
	);
//512 x 32 (2x LUT of 256x32)

// Vivado
/*
MEMTEXT_LUT_xG F2560L2_BG_LUT (
  .clka( iBUS_Clk_i ),    // input wire clka
  .wea( ( !iBUS_RWn_i & CS_MEMTEXT_LUT_i & iBUS_A_i[11]) ? iBUS_WE_i : 4'b0000 ),      // input wire [3 : 0] wea
  .addra( iBUS_A_i[10:2] ),  // input wire [8 : 0] addra
  .dina( iBUS_D32_i ),    // input wire [31 : 0] dina

  .clkb( VideoClock_i ),    // input wire clkb
  .addrb( {CharAttr[11], ColorFGBG[7:0]}),  // input wire [8 : 0] addrb
  .doutb( Temp_Out_BG_LUT )  // output wire [31 : 0] doutb
);
*/
/*
// 2 Clock Latency
//512 x 32 (2x LUT of 256x32)
MEMTEXT_LUT_xG F2560L2_FG_LUT (
  .clka( iBUS_Clk_i ),    // input wire clka
  .wea( ( !iBUS_RWn_i & CS_MEMTEXT_LUT_i & !iBUS_A_i[11]) ? iBUS_WE_i : 4'b0000 ),      // input wire [3 : 0] wea
  .addra( iBUS_A_i[10:2] ),  // input wire [8 : 0] addra
  .dina( iBUS_D32_i ),    // input wire [31 : 0] dina

  .clkb( VideoClock_i ),    // input wire clkb
  .addrb( {CharAttr[10], ColorFGBG[15:8]} ),  // input wire [8 : 0] addrb
  .doutb( Temp_Out_FG_LUT )  // output wire [31 : 0] doutb
);
*/


assign MEMTxtClrBGisZero = ( ColorFGBG[3:0] == 8'b0000_0000 );   // When the Color is 0, then  TextColorBGisZero will turn on
assign Background_Color_Out = Background_Color_LUT[1];
assign Foreground_Color_Out = Foreground_Color_LUT[1];
// Add Latency Color Changes too Soon
// Surprising, as I thought, they would arrive too late.
// 4 Clock Latency
always @ ( posedge VideoClock_i )
begin
	Background_Color_LUT[0] <= Temp_Out_BG_LUT;				// 1 CLock Latency
	Background_Color_LUT[1] <= Background_Color_LUT[0];		// 1 CLock Latency
//	Background_Color_LUT[2] <= Background_Color_LUT[1];		// 1 CLock Latency
//	Background_Color_LUT[3] <= Background_Color_LUT[2];		// 1 CLock Latency
//	Background_Color_LUT[4] <= Background_Color_LUT[3];		// 1 CLock Latency
//	Background_Color_LUT[5] <= Background_Color_LUT[4];		// 1 CLock Latency		
	
	Foreground_Color_LUT[0] <= Temp_Out_FG_LUT;
	Foreground_Color_LUT[1] <= Foreground_Color_LUT[0];	
//	Foreground_Color_LUT[2] <= Foreground_Color_LUT[1];
//	Foreground_Color_LUT[3] <= Foreground_Color_LUT[2];
//	Foreground_Color_LUT[4] <= Foreground_Color_LUT[3];
//	Foreground_Color_LUT[5] <= Foreground_Color_LUT[4];		

	MEMTxtClrBGisZero_Lat[0] <= MEMTxtClrBGisZero;
	MEMTxtClrBGisZero_Lat[1] <= MEMTxtClrBGisZero_Lat[0];
//	MEMTxtClrBGisZero_Lat[2] <= MEMTxtClrBGisZero_Lat[1];
//	MEMTxtClrBGisZero_Lat[3] <= MEMTxtClrBGisZero_Lat[2];
//	MEMTxtClrBGisZero_Lat[4] <= MEMTxtClrBGisZero_Lat[3];
//	MEMTxtClrBGisZero_Lat[5] <= MEMTxtClrBGisZero_Lat[4];		
end

assign MEMTxtClrBGisZero_o = MEMTxtClrBGisZero_Lat[1];


endmodule
