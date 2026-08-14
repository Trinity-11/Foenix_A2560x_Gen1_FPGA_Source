`timescale 1ns/1ns

module VIII_Text_Block_A 
(
input		wire				VideoClk_i,
input		wire				VideoRst_i,
input		wire	[11:0]	HLineCount_i,
input		wire	[11:0]	HPixelCount_i,
input		wire				Vsync_i,
input							VBlanking_i,
input		wire				HBlanking_i,

input		wire	[11:0]	Total_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Total_Line_Per_Image_Value_i,
input		wire	[11:0]	H_Blanking_Value_i,
input		wire	[11:0]	V_Blanking_Value_i,
input		wire	[11:0]	Visible_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Visible_Line_Per_Line_Value_i,

input		wire				VideoModeReset_i,
input		wire				SOF_i,

input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,
input		wire				VideoMode_Double_i,

input		wire	[23:0]	Reg_Border_Color_i,
// Cursor Parameters
input		wire	[15:0] 	Cursor_X_Position_i,
input		wire	[15:0] 	Cursor_Y_Position_i,
input		wire 	[7:0] 	Cursor_Control_Reg_i,
input		wire	[7:0]		Cursor_Character_Reg_i,
input		wire	[7:0]		Cursor_Color_Reg_i,
// FONT Parameters
input		wire	[7:0]		FONT_Container_Size_X_i,
input		wire	[7:0]		FONT_Container_Size_Y_i,
input		wire	[7:0]		FONT_Size_X_i,
input		wire	[7:0]		FONT_Size_Y_i,
input		wire	[7:0]		FONT_Horizontal_Num_Char_i,
input		wire	[7:0]		FONT_Vertical_Num_Line_i,

output	wire	[7:0]		Border_Blue_o,
output	wire	[7:0]		Border_Green_o,
output	wire	[7:0]		Border_Red_o,
output	reg				Horizontal_Border_o,
output   reg				Vertical_Border_o,
output	wire				Horizontal_Precharge_o,
input		wire				TextMode_Enable_i,
input		wire	[7:0]		Reg_Text_Ptr_Offset_i,
input		wire				Border_Enable_i,
input		wire	[2:0]		Border_X_Scroll_i,
input		wire	[5:0]		Border_X_Size_i,
input		wire	[5:0]		Border_Y_Size_i,
output	wire				Mono_Font_Output,
output	wire	[7:0]		Color_Font_Blue,
output	wire	[7:0]		Color_Font_Green,
output	wire	[7:0]		Color_Font_Red,

// CPU Interface
input		wire				CPU_Clk_i,
input		wire	[31:0]	iBUS_A_i,
input		wire				iBUS_A_Valid_i,

input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]	iBUS_D16_i,
input		wire	[31:0]	iBUS_D32_i,
input		wire	[1:0]		iBUS_D_Siz_i,
input		wire				iBUS_RWn_i,
input		wire	[3:0]		iBUS_BE_i,

output	wire	[31:0]	iBUS_Text_Memory_D_o,
output	wire	[31:0]	iBUS_Color_Memory_D_o,

input		wire				CS_TextMemory_i,
input		wire				CS_ColorMemory_i,
input		wire				CS_FOREGROUND_CLUT_i,		// High Part of the Color
input		wire				CS_BACKGROUND_CLUT_i,
input		wire				CS_FONT_Memory_i


// This is the Interface from Exterior Mem to Dual Port
/*
input		wire	[5:0]		TextMode_Mem_Addy_i,
input		wire	[15:0]	TextMode_Mem_Dat_i,
input		wire				TextMode_Mem_Clk_i,
input		wire				TextMode_Mem_WriteEnable_i,
input		wire				TextColor_Mem_WriteEnable_i,
*/
// This is the Command Port to the Exterior Mem Controller to Request Data
//input		wire				MemCtrl_CMD_Read_i,
//output	wire	[31:0]	MemCtrl_CMD_o,
//output	wire				MemCtrl_CMD_Rd_Empty_o,

// External BUS Access - For Look Up Table and Control Registers
/*
input 	wire				Bus_Clk_i,
input 	wire	[23:0]	Bus_A_i,
input		wire  [7:0]		Bus_D_i,
input		wire				Bus_RW_i,
input		wire				CS_Txt_Foreground_Plt_i,
input		wire				CS_Txt_Background_Plt_i,
input		wire				CS_FONT_Memory_i,
input    wire				CS_VID_Txt_Char_i,
input    wire				CS_VID_Clr_Char_i,
// 
output 	wire	[7:0]		Txt_Data_Read_o,
output	wire	[7:0]		Clr_Data_Read_o,
output	wire	[7:0]		FONT_Memory_o,
output	wire	[7:0]		LUT_FG_Data_Read_o,
output	wire	[7:0]		LUT_BG_Data_Read_o
*/
);


wire 		[7:0]		Font_Line_Data;
wire		[11:0]	Font_Line_Addy;


reg					Horizontal_Precharge;
reg		[31:0]	TM_Mem_Req_CMD;
reg					TM_Mem_Req_Write;
//WIRES:
wire		[7:0]		ASCII_Text_Data;
wire		[7:0]		COLOR_Text_Data;
wire					TM_Mem_Req_CMD_Full;
wire		[31:0]	TextMode_Mem_Req_CMD;
wire					TextMode_Mem_Req_Write;

wire		[31:0]	Foreground_Color_Out;
wire		[31:0]	Background_Color_Out;

//assign 	Border_Enable 	= Horizontal_Border_o | Vertical_Border_o;
assign 	Border_Blue_o 				= Reg_Border_Color_i[7:0];
assign	Border_Green_o 			= Reg_Border_Color_i[15:8];
assign	Border_Red_o 				= Reg_Border_Color_i[23:16];
assign   Horizontal_Precharge_o 	= Horizontal_Precharge;

//Color Mode
assign Color_Font_Blue = 	Mono_Font_Output ? Foreground_Color_Out[7:0] : Background_Color_Out[7:0];
assign Color_Font_Green = 	Mono_Font_Output ? Foreground_Color_Out[15:8] : Background_Color_Out[15:8];
assign Color_Font_Red = 	Mono_Font_Output ? Foreground_Color_Out[23:16] : Background_Color_Out[23:16];

//parameter	PRECHARGE_X0_BORDER		=	H_BLANKING + 32 - 10,	// Minus -9
//parameter	X0_BORDER					=	H_BLANKING + 32 - 1,
//parameter	X1_BORDER					=  H_BLANKING + 32 + X_TEXT_RESOLUTION - 2,
//parameter	Y0_BORDER					=  V_BLANKING + 32,
//parameter	Y1_BORDER					=  V_BLANKING + 32 + Y_TEXT_RESULUTION - 1
reg		[15:0]	Border_X0_PreCharge;
reg		[15:0]	Border_X0;
reg		[15:0]	Border_X1;
reg		[15:0]	Border_Y0;
reg		[15:0]	Border_Y1;
wire		[15:0]	Blanking_H_PreCharge;
wire		[15:0]	Blanking_H;
wire		[15:0]	Blanking_V;
wire		[15:0]	Latency;
wire		[15:0]	PreCharge;
wire		[15:0]	Border_SizeX;
wire		[15:0]	Border_SizeY;
wire		[15:0]	Border_Scroll_X;


/*
wire [15:0] Sources;
wire [7:0] Probes;

	Sources_Probes u0 (
		.source (Sources), // sources.source
		.probe  (Probes)   //  probes.probe
	);
*/

assign Latency						= VideoMode_Double_i ? 16'h0012 : 16'h0009 ;	// changed from 0009 to 0008

assign PreCharge					= VideoMode_Double_i ? 16'h0002 : 16'h0002 ;
//assign PreCharge = Probes;

assign Blanking_H_PreCharge	= H_Blanking_Value_i - PreCharge - Latency;
assign Blanking_H					= H_Blanking_Value_i - PreCharge;
assign Blanking_V					= V_Blanking_Value_i;

assign Border_SizeX				= VideoMode_Double_i ? {9'b00_0000_0000, Border_X_Size_i, 1'b0}  		: {10'b00_0000_0000, Border_X_Size_i};
assign Border_SizeY				= VideoMode_Double_i ? {9'b00_0000_0000, Border_Y_Size_i, 1'b0}  		: {10'b00_0000_0000, Border_Y_Size_i};
assign Border_Scroll_X			= VideoMode_Double_i ? {12'b0_0000_0000_0000, Border_X_Scroll_i, 1'b0} : {13'b0_0000_0000_0000, Border_X_Scroll_i};

// Signal To begin 
// everything is in 16bits now
always @ (posedge VideoClk_i)
begin
	if (VideoRst_i | VideoModeReset_i) begin
		Border_X0_PreCharge <= Blanking_H_PreCharge + 12'd32;		// Latency (9 Dot Clock)
		Border_X0 <= Blanking_H + 16'd32;
		Border_X1 <= Blanking_H + 16'd32 + {4'b0000, Visible_Pixel_Per_Line_Value_i};
		Border_Y0 <= Blanking_V + 16'd32;
		Border_Y1 <= Blanking_V + 16'd32 + {4'b0000, Visible_Line_Per_Line_Value_i};
	end
	else begin
		if (SOF_i) begin
			if (Border_Enable_i) begin
				Border_X0_PreCharge <= Blanking_H_PreCharge + Border_SizeX - Border_Scroll_X;		// - 9 (Precharge - 2(Latency)
				// X Border
				Border_X0 <= Blanking_H +  Border_SizeX;
				Border_X1 <= Blanking_H + {4'b0000, Visible_Pixel_Per_Line_Value_i} - Border_SizeX;
				// Y Border
				Border_Y0 <= Blanking_V + Border_SizeY;
				Border_Y1 <= Blanking_V + {4'b0000, Visible_Line_Per_Line_Value_i} - Border_SizeY;
			end
			else begin
				Border_X0_PreCharge <= Blanking_H_PreCharge - Border_Scroll_X;		// - 9 (Precharge - 2(Latency)
				// X Border
				Border_X0 <= Blanking_H;
				Border_X1 <= Blanking_H + {4'b0000, Visible_Pixel_Per_Line_Value_i};
				// Y Border
				Border_Y0 <= Blanking_V;
				Border_Y1 <= Blanking_V + {4'b0000, Visible_Line_Per_Line_Value_i};
			end
		end
	end
end

/*
always @ (*)
begin
		if (( HLineCount_i < Border_Y0[11:0] ) || (HLineCount_i >= Border_Y1[11:0]))
			Vertical_Border_o = 1'b1;
		else
			Vertical_Border_o = 1'b0;
			
		if ((HPixelCount_i < Border_X0[11:0]) || (HPixelCount_i >= Border_X1[11:0]))
			Horizontal_Border_o = 1'b1;
		else
			Horizontal_Border_o = 1'b0;
	
		if ((HPixelCount_i < Border_X0_PreCharge[11:0]) || (HPixelCount_i >= Border_X1[11:0]))
			Horizontal_Precharge = 1'b0;
		else
			Horizontal_Precharge = 1'b1;	
end
*/
always @ (posedge VideoClk_i)
begin
		if (( HLineCount_i < Border_Y0[11:0] ) || (HLineCount_i >= Border_Y1[11:0]))
			Vertical_Border_o <= 1'b1;
		else
			Vertical_Border_o <= 1'b0;
end

always @ (posedge VideoClk_i)
begin
		if ((HPixelCount_i < Border_X0[11:0]) || (HPixelCount_i >= Border_X1[11:0]))
			Horizontal_Border_o <= 1'b1;
		else
			Horizontal_Border_o <= 1'b0;
end

always @ (posedge VideoClk_i)
begin
		if ((HPixelCount_i < Border_X0_PreCharge[11:0]) || (HPixelCount_i >= Border_X1[11:0]))
			Horizontal_Precharge <= 1'b0;
		else
			Horizontal_Precharge <= 1'b1;
end


wire	[13:0]	ASCII_Text_Addy;
reg	[1:0]		Vsync_EDGE;
reg	[1:0]		de_EDGE;

always @ (posedge VideoClk_i)
begin
	if ( VideoRst_i ) begin
		Vsync_EDGE 	<= 2'b00;
		de_EDGE		<= 2'b00;
	end
	else begin
			Vsync_EDGE[0]  <= !Vertical_Border_o;
			Vsync_EDGE[1]  <= Vsync_EDGE[0];
			de_EDGE[0]		<= !Vertical_Border_o & !Horizontal_Border_o;
			de_EDGE[1]		<= de_EDGE[0];
	end
end



	
VIII_Text_FONT_StateMachine Monochrome_Text_SM(
//Clock and reset
	.video_clk( VideoClk_i ),
	.video_rst( VideoRst_i ),
	.TextMode_Enable_i( TextMode_Enable_i ),

	.FONT_Block_Enable( 1'b1 ),
	.FONT_Height_Constant( FONT_Container_Size_Y_i ),				// 8 or 16 (input [5:0])
	.FONT_Bank( 2'b00 ),								// Bank 0 (Input [1:0])
	.FONT_Vertical_Num_Lines( FONT_Vertical_Num_Line_i ),
	.FONT_Horizontal_Num_Chars( FONT_Horizontal_Num_Char_i ),
	
	.VideoMode_i( Mstr_Ctrl_Video_Mode_i ),	
	.VideoMode_Double_i( VideoMode_Double_i ), 	// 
	.Vsync_EDGE( Vsync_EDGE[1:0] ),				// 2'b00
	.de_EDGE( de_EDGE[1:0] ),						// 2'b00 Blanking
	.Horizontal_Precharge( Horizontal_Precharge ),

// Text Box Active Signals
	.Vertical_Active( !Vertical_Border_o ),		// Input
	.Horizontal_Active( !Horizontal_Border_o ),	//Input
// 1 Pulse of 8 Pixel To Indicate Start of Frame (INT0)			
	.SOF_i(SOF_i),

// Text Box - Text Memory Pointer & Data
	.Text_Pointer_Offset_i( Reg_Text_Ptr_Offset_i ),
	.ASCII_Text_Data(ASCII_Text_Data),						//Input [7:0]
	.ASCII_Text_Addy(ASCII_Text_Addy),			//Output [12:0]		Buffer 4800 (8x8) (2400 (8x16)

// This is for External Interface
//	.CMD_Req_o(TextMode_Mem_Req_CMD),
//	.CMD_Req_Write_o(TextMode_Mem_Req_Write),
//	.CMD_Req_Wr_Stat_Full_i(TM_Mem_Req_CMD_Full),

	// FONT Data Out
	.Pixel_Out( Mono_Font_Output ),				//1 - Pixel on, 0- Pixel Off

// FONT Memory Address and Data.
	.Font_Line_Data(Font_Line_Data),				//Input [7:0]
	.Font_Line_Addy(Font_Line_Addy),				//Output [12:0]

	.Cursor_X_Input_i(Cursor_X_Position_i),
	.Cursor_Y_Input_i(Cursor_Y_Position_i),
	.Cursor_Control_Reg_i( Cursor_Control_Reg_i ),
	.Cursor_Character_Reg_i( Cursor_Character_Reg_i )
);

///////////////// BLOCK Interface 
//
// PORT - A -> Local Text Displa
// Port - B -> BUS Interface
//wire CS_VID_Txt_Char = 	((Bus_A_i >= 24'h800000) && (Bus_A_i < 24'h802000)) ? 1'b1 : 1'b0;
//wire CS_VID_Clr_Char = 	((Bus_A_i >= 24'h802000) && (Bus_A_i < 24'h804000)) ? 1'b1 : 1'b0;

/*
FONT_2PORT_MEM TEXT_BLOCK32(
	.wraddress( BUS_A_i ),
	.wrclock( CPU_Clk_i ),
	.wren( BUS_A_Valid_i & !BUS_RWn_i ),
	.data( BUS_D_i ),	
	.byteena_a( BUS_BE_i ),

	.rdclock( VideoClk_i ),	

	.rdaddress( ASCII_Text_Addy[12:0] ),

	.q( ASCII_Text_Data )
);
*/
/*
TEXT_MEM_BLK	TEXT_MEM_BLK_inst (
// 32bits Interface
	.clock_a ( CPU_Clk_i ),
	.address_a ( BUS_A_i ),
	.wren_a ( BUS_A_Valid_i & !BUS_RWn_i ),	
	.data_a ( BUS_D_i ),
	.q_a ( BUS_D_o ),
//8Bit	
	.clock_b ( VideoClk_i ),
	.address_b ( ASCII_Text_Addy[12:0] ),	
	.data_b ( 8'h00 ),
	.wren_b ( 1'b0 ),
	.q_b ( ASCII_Text_Data )
);
*/
/*
TEXT_MEM_TEST	TEXT_MEM_TEST_inst (
	.address ( ASCII_Text_Addy[13:0] ),
	.clock ( VideoClk_i ),
	.data ( 8'h00 ),
	.wren ( 1'b0 ),
	.q ( ASCII_Text_Data )
	);
*/

reg 	iBUS_A_Valid_Slide;
always @ (posedge CPU_Clk_i ) begin
	iBUS_A_Valid_Slide <= iBUS_A_Valid_i;
end

wire [7:0] iBUS_Text_Mem8_D;
wire [7:0] iBUS_Color_Mem8_D;

assign iBUS_Text_Memory_D_o = { iBUS_Text_Mem8_D, iBUS_Text_Mem8_D, iBUS_Text_Mem8_D, iBUS_Text_Mem8_D };
assign iBUS_Color_Memory_D_o = { iBUS_Color_Mem8_D, iBUS_Color_Mem8_D, iBUS_Color_Mem8_D, iBUS_Color_Mem8_D };

TEXT_MEM32_BLK	TEXT_MEM16_BLK (
	.clock_a ( CPU_Clk_i ),
	.address_a ( iBUS_A_i[13:0] ),
	.wren_a ( !iBUS_RWn_i & CS_TextMemory_i & ({iBUS_A_Valid_Slide, iBUS_A_Valid_i} == 2'b10)),
	.data_a ( iBUS_D8_i ),		
	.q_a ( iBUS_Text_Mem8_D ),	

	.clock_b ( VideoClk_i ),
	.address_b ( ASCII_Text_Addy[13:0] ),	
	.data_b ( 8'h00 ),
	.wren_b ( 1'b0 ),
	.q_b ( ASCII_Text_Data )
	);
	

TEXT_MEM32_BLK	COLOR_MEM16_BLK (
	.clock_a ( CPU_Clk_i ),
	.address_a ( iBUS_A_i[13:0] ),
	.wren_a ( !iBUS_RWn_i & CS_ColorMemory_i & ({iBUS_A_Valid_Slide, iBUS_A_Valid_i} == 2'b10)),
	.data_a ( iBUS_D8_i),		
	.q_a ( iBUS_Color_Mem8_D ),	

	.clock_b ( VideoClk_i ),
	.address_b ( ASCII_Text_Addy[13:0] ),	
	.data_b ( 8'h00 ),
	.wren_b ( 1'b0 ),
	.q_b ( COLOR_Text_Data )
	);	
	
wire	[31:0]	Temp_Out_BG_LUT;
wire	[31:0]	Temp_Out_FG_LUT;
//assign Temp_Out_BG_LUT = 32'h00000000;
//assign Temp_Out_FG_LUT = 32'h00FFFFFF;

TEXT_CLR_LUT	FOREGROUND_CLUT (
	.rdaddress ( COLOR_Text_Data[7:4] ),
	.rdclock ( VideoClk_i ),
	.q ( Temp_Out_FG_LUT ),
	
	.data ( iBUS_D32_i ),	
	.wraddress ( iBUS_A_i[5:2] ),
//	.byteena_a ( iBUS_BE_i[1:0] ),	
	.wrclock ( CPU_Clk_i ),
	.wren ( !iBUS_RWn_i & CS_FOREGROUND_CLUT_i  & ({iBUS_A_Valid_Slide, iBUS_A_Valid_i} == 2'b10))	
	);

TEXT_CLR_LUT	BACKGROUND_CLUT (
	.rdaddress ( COLOR_Text_Data[3:0] ),
	.rdclock ( VideoClk_i ),
	.q ( Temp_Out_BG_LUT ),
	
	.data ( iBUS_D32_i ),	
	.wraddress ( iBUS_A_i[5:2] ),
//	.byteena_a ( iBUS_BE_i[1:0] ),	
	.wrclock ( CPU_Clk_i ),
	.wren ( !iBUS_RWn_i & CS_BACKGROUND_CLUT_i  & ({iBUS_A_Valid_Slide, iBUS_A_Valid_i} == 2'b10))	
	);
/*
assign LUT_FG_Data_Read_o = 8'hFF;

TEXT_CLR_LUT	FOREGROUND_LUT (
	.rdaddress (COLOR_Text_Data[7:4] ),
	.rdclock ( VideoClk_i ),
	.q ( Temp_Out_FG_LUT ),
	
	.data ( Bus_D_i ),	
	.wraddress ( Bus_A_i[5:0] ),
	.wrclock ( !Bus_Clk_i ),
	.wren ( CS_Txt_Foreground_Plt_i & !Bus_RW_i & Bus_Clk_i )
);

assign LUT_BG_Data_Read_o = 8'hFF;

TEXT_CLR_LUT	BACKGROUND_LUT (
	.rdaddress ( COLOR_Text_Data[3:0] ),
	.rdclock ( VideoClk_i ),
	.q ( Temp_Out_BG_LUT ),
	
	.data ( Bus_D_i ),	
	.wraddress ( Bus_A_i[5:0] ),
	.wrclock ( !Bus_Clk_i ),
	.wren ( CS_Txt_Background_Plt_i & !Bus_RW_i & Bus_Clk_i )
);
*/
reg	[31:0]	Background_Color_LUT[3:0];
reg	[31:0]	Foreground_Color_LUT[3:0];
assign Background_Color_Out = Background_Color_LUT[3];
assign Foreground_Color_Out = Foreground_Color_LUT[3];
// Add Latency Color Changes too Soon
// Surprising, as I thought, they would arrive too late.
always @ (posedge VideoClk_i)
begin
	Background_Color_LUT[0] <= Temp_Out_BG_LUT;
	Background_Color_LUT[1] <= Background_Color_LUT[0];	
	Background_Color_LUT[2] <= Background_Color_LUT[1];
	Background_Color_LUT[3] <= Background_Color_LUT[2];
	
	Foreground_Color_LUT[0] <= Temp_Out_FG_LUT;
	Foreground_Color_LUT[1] <= Foreground_Color_LUT[0];	
	Foreground_Color_LUT[2] <= Foreground_Color_LUT[1];
	Foreground_Color_LUT[3] <= Foreground_Color_LUT[2];
end

FONT_DP_MEM	FONT_DP_MEM_inst (
	.data ( iBUS_D8_i ),
	.wraddress ( iBUS_A_i[11:0] ),
	.wrclock ( CPU_Clk_i ),
	.wren ( !iBUS_RWn_i & CS_FONT_Memory_i & (iBUS_D_Siz_i[1:0] == 2'b01)),
	
	.rdaddress ( Font_Line_Addy ),
	.rdclock ( VideoClk_i ),	
	.q ( Font_Line_Data )
	);


endmodule


