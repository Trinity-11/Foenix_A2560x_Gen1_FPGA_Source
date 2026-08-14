module VICKY_III_Channel_A_Top(

// Reset
input		wire					Reset_i,
// Clocks
input		wire					CPU_Clk_i,				// CPU Clock - Could be 16/20/25/33/40/66/75
input		wire					Clk14_318Mhz_i,
input		wire					Clk40_000Mhz_i,
input		wire					Clk65_000Mhz_i,

input		wire					Clk100M_i,
input		wire					Clk200M_i,
input		wire					Video_Clk_A_i,
// DIP Switch
input		wire					DP_HIRES_i,
input		wire					DP_GAMMA_i,
// Buses
input		wire		[31:0]	iBUS_A_i,
input		wire					iBUS_A_Valid_i,
input		wire		[7:0]		iBUS_D8_i,
input		wire		[15:0]	iBUS_D16_i,
input		wire		[31:0]	iBUS_D32_i,
input		wire		[1:0]		iBUS_D_Siz_i,

output	wire					iBUS_D_Valid_o,
input		wire					iBUS_RWn_i,
input		wire		[3:0]		iBUS_BE_i,
input		wire					iBUS_WE_i,

input		wire					CS_TextMemory_i,			// Text DP memory ChipSelect
input		wire					CS_ColorMemory_i,			// Color DP Memory ChipSelect
input		wire					CS_FG_CLUT_i,	
input		wire					CS_BG_CLUT_i,
input		wire					CS_Vicky_Registers_i,
input		wire					CS_Mouse_Ptr_A_Graphics_i,
input		wire					CS_Mouse_Ptr_A_Registers_i,
input		wire					CS_FONT_i,
// General
input		wire					CS_GAMMA_B_i,
input		wire					CS_GAMMA_G_i,
input		wire					CS_GAMMA_R_i,

output	wire		[31:0]	iBUS_Text_Memory_D_o,
output	wire		[31:0]	iBUS_Color_Memory_D_o,
output	wire		[31:0]	iBUS_VICKYIII_Reg_D_o,
output	wire		[31:0]	DataOut_A_Mouse_Regs_o,
// General
output	wire		[31:0]	GAMMA_B_Dout_o,
output	wire		[31:0]	GAMMA_G_Dout_o,
output	wire		[31:0]   GAMMA_R_Dout_o,

// Video DAC Output A
output	wire					VID_A_RSTn_o,
output	wire					VID_A_CLK_P_o,
output	wire					VID_A_DE_o,
output	wire					VID_A_HSYNC_o,
output	wire					VID_A_VSYNC_o,
output	wire		[11:0]	VID_A_PIX_o,

output	wire					SOF_Channel_A_o,
output	wire		[5:0]		VKY_III_Channel_A_IRQ_o,

output	wire		[1:0]		VID_A_VideoModeClk_o
);



assign  VKY_III_Channel_A_IRQ_o[0] = !SOF;				// Start of Frame 60Hz Interrupt
assign  VKY_III_Channel_A_IRQ_o[1] = 1'b0;				// Line Interrupt (Programmable)
assign  VKY_III_Channel_A_IRQ_o[2] = 1'b0;
assign  VKY_III_Channel_A_IRQ_o[3] = 1'b0;
assign  VKY_III_Channel_A_IRQ_o[4] = 1'b0;
assign  VKY_III_Channel_A_IRQ_o[5] = 1'b0;

assign iBUS_D_Valid_o = 1'b0;

assign VID_A_VideoModeClk_o = Mstr_Ctrl_Video_Mode;

// Video DAC Output A
assign VID_A_RSTn_o 		= 1'b1;

wire PLL_Locked_A;

// Video Channel A
wire 				HSync;
wire				VSync;
wire				HBlanking;
wire				VBlanking;
wire	[11:0]	HPixelCount;
wire	[11:0]	HLineCount;
wire				VGE_VBlanking;
wire				SOF;
wire				HBlanking_Latency;
wire				HBlanking_VGE_Lat;
wire	[11:0]	HPixelCount_Aux;
wire	[11:0]	HLineCount_Aux;
wire 	[11:0]	Total_Pixel_Per_Line_Value;
wire	[11:0]	Total_Line_Per_Image_Value;
wire	[11:0]	H_Blanking_Value;
wire	[11:0]	V_Blanking_Value;
wire	[11:0]	Visible_Pixel_Per_Line_Value;
wire	[11:0]	Visible_Line_Per_Line_Value;
wire				VideoModeReset;
wire				Horizontal_Precharge;
// Border Color
wire	[7:0]		Border_Blue;
wire	[7:0]		Border_Green;
wire	[7:0]		Border_Red;
wire				Vertical_Border;
wire				Horizontal_Border;
// Background Color
wire	[7:0]		Background_Blue;
wire	[7:0]		Background_Green;
wire	[7:0]		Background_Red;
// FONT Color
wire	[7:0]		FONT_Blue;
wire	[7:0]		FONT_Green;
wire	[7:0]		FONT_Red;
wire				Pixel_Mono_FONT_Out;

wire 				HSync_Pol;
wire				VSync_Pol;

// Reset Signals
wire				Reset_100Mhz;
wire				Reset_200Mhz;
wire				Reset_VideoClkOut;
wire				Reset_VideoClk_Full_Resolution;
wire				VideoModeReset_100Mhz;
wire				VideoModeReset_200Mhz;
// Cursor
wire 	[15:0]	Cursor_X_Position;
wire	[15:0]	Cursor_Y_Position;
wire	[7:0]		Cursor_Control_Reg;
wire	[7:0]		Cursor_Character_Reg;
wire	[7:0]		Cursor_Color_Reg;
wire	[7:0]		Border_Control_Reg;
wire	[23:0]	Border_Color_Reg;
wire  [7:0]		Reg_Text_Ptr_Offset;
wire	[2:0]		Border_X_Scroll;
wire	[5:0]		Border_X_Size;
wire	[5:0] 	Border_Y_Size;
wire				Border_Enable;
// Master Control
wire 				Mstr_Ctrl_Text_Mode_Enable;
wire 				Mstr_Ctrl_Text_Mode_Overlay;
wire 				Mstr_Ctrl_Graphic_Mode_Enable;
wire 				Mstr_Ctrl_Bitmap_Enable;
wire 				Mstr_Ctrl_TileMap_Enable;
wire 				Mstr_Ctrl_Sprite_Enable;
wire 				Mstr_Ctrl_GAMMA_Enable;
wire				Mstr_Ctrl_Turn_Off_Sync;
wire 				Mstr_Ctrl_Disable_Video;
wire	[1:0]		Mstr_Ctrl_Video_Mode;
wire	[1:0]		Mstr_Ctrl_Video_Mode_100Mhz;
wire				Mstr_Ctrl_Doubling_Pixel;
wire				Mstr_Ctrl_Doubling_Pixel_100Mhz;
wire	[1:0]		Mstr_Ctrl_Video_Mode_CPU;

wire 				Mstr_Ctrl_Reset;
wire 	[1:0] 	Mstr_Ctrl_Video_Mode_PLL;
wire				PLL_Active_Clock;
wire	[15:0]	LineInterrupt_Reg0;
wire	[15:0]	LineInterrupt_Reg1;
wire	[15:0]	LineInterrupt_Reg2;
wire	[15:0]	LineInterrupt_Reg3;
wire 	[31:0] 	MouserPointer_Full_ARGB;
wire 	[15:0] 	HBLANK_START;
wire 	[15:0] 	HBLANK_STOP;

wire	[7:0]  	FONT_Container_Size_X;
wire 	[7:0]  	FONT_Container_Size_Y;
wire	[7:0]  	FONT_Size_X;
wire 	[7:0]  	FONT_Size_Y;
wire 	[7:0]  	FONT_Horizontal_Num_Char;
wire 	[7:0]  	FONT_Vertical_Num_Line;	

assign SOF_Channel_A_o = SOF;
wire				VideoClk_Full_Resolution;
wire				VideoClk_Half_Resolution;
wire 				VideoClkOut;


VIDEO_PLL	VIDEO_PLL_A (
	.inclk0 ( Clk40_000Mhz_i ),
	.inclk1 ( Clk65_000Mhz_i ),
	.clkswitch( Mstr_Ctrl_Video_Mode_PLL_Aux ),
	.c0 ( VideoClk_Full_Resolution ),
	.c1 ( VideoClk_Half_Resolution ),
	.c2 ( VID_A_CLK_P_o ),
	.locked ( PLL_Locked_A ),
	.activeclock( PLL_Active_Clock )
	);
//assign PLL_Locked_A = 1'b1;
	
Clk_Switch u0 (
	.clkselect ( Mstr_Ctrl_Doubling_Pixel ), //                  .clkselect	
	.inclk0x   ( VideoClk_Full_Resolution ),   //  	
	.inclk1x   ( VideoClk_Half_Resolution ),   //  altclkctrl_input.inclk1x
	.outclk    ( VideoClkOut )     // altclkctrl_output.outclk
);	
//assign VID_A_CLK_P_o = Clk40_000Mhz_i;
//assign PLL_Locked_A = 1'b1;	

VICKY_III_Reset_Module Channel_A_Reset(
	.Ext_Reset_i( Reset_i ),
	.Clk_100M_i( Clk100M_i ),
	.Clk_200M_i( Clk200M_i ),
	.VideoClk_i( VideoClkOut ),
	.VideoClk_Full_Resolution_i( VideoClk_Full_Resolution ),
	
	.VideoModeReset_i( VideoModeReset ),

	.Reset_100Mhz_o( Reset_100Mhz ),
	.Reset_200Mhz_o( Reset_200Mhz ),
	.Reset_VideoClkOut_o( Reset_VideoClkOut ),
	.Reset_VideoClk_Full_Resolution_o( Reset_VideoClk_Full_Resolution ),			// To be adjusted
	.VideoModeReset_100Mhz_o( VideoModeReset_100Mhz ),
	.VideoModeReset_200Mhz_o( VideoModeReset_200Mhz )
);


wire Mstr_Ctrl_Video_Mode_AUX;
wire Mstr_Ctrl_Video_Mode_PLL_Aux;
///////////////////////////////////
// CHANNEL A
////////////////////////////////////
Vicky_Register_Block Vicky_Reg_Blk_A(
	.rst_i( Reset_i ),				// This is async Reset
	.Reset_VideoClkOut( Reset_VideoClkOut ),	
	.Aux_Clk_i( CPU_Clk_i ), 
	.EngineClk100Mhz_i( Clk100M_i ),
	.EngineClk200Mhz_i( Clk200M_i ),
// CPU Signals Interface
	.BUS_Clk_i( CPU_Clk_i ),
	.BUS_A_i( iBUS_A_i ),
	.BUS_A_Valid_i( iBUS_A_Valid_i ),	
	.BUS_D8_i( iBUS_D8_i ),
	.BUS_D16_i( iBUS_D16_i ),
	.BUS_D32_i( iBUS_D32_i ),
	.BUS_D_Siz_i( iBUS_D_Siz_i ),	
	.BUS_D_o( iBUS_VICKYIII_Reg_D_o ),
	.BUS_RW_i( iBUS_RWn_i ),
	.BUS_BE_i( iBUS_BE_i ),
	.BUS_WE_i( iBUS_WE_i ), 

// ChipSelect
	.CS_Vicky_Registers_i( CS_Vicky_Registers_i ),
// Video Info
	.VideoClk_i( VideoClkOut ),
	.SOF_i( SOF ),
	.DIPSwitch_GAMMA_i( DP_GAMMA_i ),
	.DIPSwitch_HiRes_i( DP_HIRES_i ),
	.PLL_Active_Clock_i( PLL_Active_Clock ),
// Cursor Register
	.Cursor_X_Position_o( Cursor_X_Position ),
	.Cursor_Y_Position_o( Cursor_Y_Position ),
	.Cursor_Control_Reg_o( Cursor_Control_Reg ),
	.Cursor_Character_Reg_o( Cursor_Character_Reg ),
	.Cursor_Color_Reg_o( Cursor_Color_Reg ),
// FONT
	.FONT_Container_Size_X_o( FONT_Container_Size_X ),
	.FONT_Container_Size_Y_o( FONT_Container_Size_Y ),
	.FONT_Size_X_o( FONT_Size_X ),
	.FONT_Size_Y_o( FONT_Size_Y ),
	.FONT_Horizontal_Num_Char_o( FONT_Horizontal_Num_Char ),
	.FONT_Vertical_Num_Line_o( FONT_Vertical_Num_Line ),
	
// Border Control
	.Border_Color_Reg_o( Border_Color_Reg  ),
	.Reg_Text_Ptr_Offset_o( Reg_Text_Ptr_Offset ),
	.Border_Enable_o( Border_Enable ),

	.Border_X_Scroll_o( Border_X_Scroll ),
	.Border_X_Size_o( Border_X_Size ),
	.Border_Y_Size_o( Border_Y_Size ),
// Background Color
	.Background_Blue_o( Background_Blue ),
	.Background_Green_o( Background_Green ),
	.Background_Red_o( Background_Red ),
	
// Vicky Master Control
	.Mstr_Ctrl_Text_Mode_Enable_o( Mstr_Ctrl_Text_Mode_Enable ),
	.Mstr_Ctrl_Text_Mode_Overlay_o( Mstr_Ctrl_Text_Mode_Overlay ),
	.Mstr_Ctrl_Graphic_Mode_Enable_o( Mstr_Ctrl_Graphic_Mode_Enable ),
	.Mstr_Ctrl_Bitmap_Enable_o( Mstr_Ctrl_Bitmap_Enable ),
	.Mstr_Ctrl_TileMap_Enable_o( Mstr_Ctrl_TileMap_Enable ),
	.Mstr_Ctrl_Sprite_Enable_o( Mstr_Ctrl_Sprite_Enable ),
	.Mstr_Ctrl_GAMMA_Enable_o( Mstr_Ctrl_GAMMA_Enable ),
	.Mstr_Ctrl_Turn_Off_Sync_o( Mstr_Ctrl_Turn_Off_Sync ), 
	.Mstr_Ctrl_Disable_Video_o( Mstr_Ctrl_Disable_Video ),
	.Mstr_Ctrl_Doubling_Pixel_o( Mstr_Ctrl_Doubling_Pixel ),
	
	.Mstr_Ctrl_Video_Mode_AUX_o( Mstr_Ctrl_Video_Mode_AUX ), 	// Channel A

	.Mstr_Ctrl_Video_Mode_o( Mstr_Ctrl_Video_Mode ),	// 25/40Mhz
	.Mstr_Ctrl_Video_Mode_100MhzReSynced_o( Mstr_Ctrl_Video_Mode_100Mhz ), //100Mhz
	.Mstr_Ctrl_Doubling_Pixel_100MhzResynced_o( Mstr_Ctrl_Doubling_Pixel_100Mhz ), 	
	.Mstr_Ctrl_Video_Mode_PLL_Aux_o( Mstr_Ctrl_Video_Mode_PLL_Aux ), 
	
	
   .Mstr_Ctrl_Reset_Pll_o(  ),
	.Mstr_Ctrl_Video_Mode_PLL_o(  ),
	
	.Mstr_Ctrl_Video_Mode_CPU_o( Mstr_Ctrl_Video_Mode_CPU ),
	
	.LineInterrupt_Reg0_o( LineInterrupt_Reg0 ),
	.LineInterrupt_Reg1_o( LineInterrupt_Reg1 ),
	.LineInterrupt_Reg2_o( LineInterrupt_Reg2 ),
	.LineInterrupt_Reg3_o( LineInterrupt_Reg3 )
	
);
// Next to the Ethernet Connector
GraphicOutputMixer PixelMixer_Channel_A(
// CPU Interface
	.CPU_Clk_i( CPU_Clk_i ),
	.CPU_D8_i( iBUS_D8_i ),
	.CPU_D16_i( iBUS_D16_i ),
	.CPU_D32_i( iBUS_D32_i ),
	.CPU_D_Siz_i( iBUS_D_Siz_i ),
	.CPU_Addy_i( iBUS_A_i ),
	.CPU_RWn_i( iBUS_RWn_i ),
	.CPU_BE_i( iBUS_BE_i ),
	.CPU_WE_i( iBUS_WE_i ), 
	.CS_GAMMA_B_i( CS_GAMMA_B_i ),
	.CS_GAMMA_G_i( CS_GAMMA_G_i ),
	.CS_GAMMA_R_i( CS_GAMMA_R_i ),
	
	.GAMMA_Enable_i( Mstr_Ctrl_GAMMA_Enable ),
	.Text_Mode_Enable_i( Mstr_Ctrl_Text_Mode_Enable ),
	.Text_Overlay_Enable_i( Mstr_Ctrl_Text_Mode_Overlay ),
	.Graphic_Mode_Enable_i( Mstr_Ctrl_Graphic_Mode_Enable ),
	.DataOut_GAMMA_B_o( GAMMA_B_Dout_o ),
	.DataOut_GAMMA_G_o( GAMMA_G_Dout_o ),
	.DataOut_GAMMA_R_o( GAMMA_R_Dout_o ),
	.Turn_Off_Sync_i( Mstr_Ctrl_Turn_Off_Sync ),
	
// Video Interface
	.Video_Clk_i( VideoClk_Full_Resolution ),

// Border Color
	.Border_Blue_i( Border_Blue ),
	.Border_Green_i( Border_Green ),
	.Border_Red_i( Border_Red ),

	.Border_Horizontal_i( Horizontal_Border ),
	.Border_Vertical_i( Vertical_Border ),

// FONT Color
	.FONT_Mono_i( Pixel_Mono_FONT_Out ),
	.FONT_Blue_i( FONT_Blue ),
	.FONT_Green_i( FONT_Green ),
	.FONT_Red_i( FONT_Red ),

// Mouse Color
	.Mouse_Full_RGB_i( MouserPointer_Full_ARGB ),

// VGE Color
	.VGE_Blue_i( 8'hFF ),
	.VGE_Green_i( 8'h00 ),
	.VGE_Red_i( 8'hFF ),

// Timing Generator
	.HSync_i( HSync ),
	.VSync_i( VSync ),
	.HSync_Pol_i( HSync_Pol ),
	.VSync_Pol_i( VSync_Pol ),	
	.HBlanking_i( HBlanking ),
	.VBlanking_i( VBlanking ),

// DAC Output Signals
	.VID_PIXEL_o( VID_A_PIX_o ),
	.VID_DE_o( VID_A_DE_o ),
	.VID_HSYNC_o( VID_A_HSYNC_o ),
	.VID_VSYNC_o( VID_A_VSYNC_o )
);

VideoTimingGenerator_A VideoTimingGen_A(
	.Reset_VideoClk_Full_Resolution( Reset_VideoClkOut ),
	.VideoClk_i( VideoClkOut ),								//40Mhz (640 x 480) inside 800 x 600
	.EngineClk100Mhz_i( Clk100M_i ),
	.EngineClk200Mhz_i( Clk200M_i ),
	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode_AUX ),
	.Mstr_Ctrl_Doubling_Pixel_i( Mstr_Ctrl_Doubling_Pixel ),
	.HSYNC_o( HSync ),					//HD
	.VSYNC_o( VSync ),					//VD
	
	.HSync_Pol_o( HSync_Pol ),
	.VSync_Pol_o( VSync_Pol ),
	
	.HPixelCount_o( HPixelCount ),
	.HLineCount_o( HLineCount ),

	.HBlanking_Latency_o( HBlanking_Latency ),	// Early HBlanking Signal to Account for the Latency of the different memory Buffers
	.HBlanking_o( HBlanking ),
	.VBlanking_o( VBlanking ),
	.SOF_o( SOF ),
	
	.HBLANK_START_o( HBLANK_START ),
	.HBLANK_STOP_o( HBLANK_STOP )
);



VideoModeTimingInfo_Channel_A VideoMode_Info_A(
	.VideoRst_i( Reset_VideoClkOut ),
	.PLL_Locked( PLL_Locked_A ),
	.Video_Clk_i( VideoClkOut ),
	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode_AUX ),

	.Total_Pixel_Per_Line_Value_o( Total_Pixel_Per_Line_Value ),
	.Total_Line_Per_Image_Value_o( Total_Line_Per_Image_Value ),
	.H_Blanking_Value_o( H_Blanking_Value ),
	.V_Blanking_Value_o( V_Blanking_Value ),
	.Visible_Pixel_Per_Line_Value_o( Visible_Pixel_Per_Line_Value ),
	.Visible_Line_Per_Line_Value_o( Visible_Line_Per_Line_Value ),
	.VideoModeReset_o( VideoModeReset )
);

// Channel A
VIII_Text_Block_A Text_Creation_Module_A(
	.VideoClk_i( VID_A_CLK_P_o ),
	.VideoRst_i( Reset_VideoClkOut ),
	.HLineCount_i( HLineCount ),
	.HPixelCount_i( HPixelCount ),
	.Vsync_i( VSync ),
	.VBlanking_i( VBlanking ),
	.HBlanking_i( HBlanking_Latency ), //HBlanking_Latency
	
	.Total_Pixel_Per_Line_Value_i( Total_Pixel_Per_Line_Value ),
	.Total_Line_Per_Image_Value_i( Total_Line_Per_Image_Value ),
	.H_Blanking_Value_i( H_Blanking_Value ),
	.V_Blanking_Value_i( V_Blanking_Value ),
	.Visible_Pixel_Per_Line_Value_i( Visible_Pixel_Per_Line_Value ),
	.Visible_Line_Per_Line_Value_i( Visible_Line_Per_Line_Value ),
	.VideoModeReset_i( VideoModeReset ),
	
	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode_AUX ),
	.VideoMode_Double_i( Mstr_Ctrl_Doubling_Pixel ),
	.SOF_i( SOF ),	
	.Border_Blue_o( Border_Blue ),
	.Border_Green_o( Border_Green ),
	.Border_Red_o( Border_Red ),
	.Horizontal_Border_o( Horizontal_Border ),
	.Vertical_Border_o( Vertical_Border ),
	.Horizontal_Precharge_o( Horizontal_Precharge ),
// Border Control	
	.Reg_Text_Ptr_Offset_i( Reg_Text_Ptr_Offset ),
	.Border_Enable_i( Border_Enable ),
	//.Border_Enable_i( Border_Enable ),	
	.Reg_Border_Color_i( Border_Color_Reg ),		// Bright Orange
	.Border_X_Scroll_i( Border_X_Scroll ),	// 2:0
	.Border_X_Size_i( Border_X_Size ),							// 5:0
	.Border_Y_Size_i( Border_Y_Size ),							// 5:0
	
	.TextMode_Enable_i( Mstr_Ctrl_Text_Mode_Enable ),
// Cursor Register
	.Cursor_X_Position_i( Cursor_X_Position ),
	.Cursor_Y_Position_i( Cursor_Y_Position ),
	.Cursor_Control_Reg_i( Cursor_Control_Reg ),
	.Cursor_Character_Reg_i( Cursor_Character_Reg),
	.Cursor_Color_Reg_i( Cursor_Color_Reg ),
// FONT Parameters
	.FONT_Container_Size_X_i( FONT_Container_Size_X ),
	.FONT_Container_Size_Y_i( FONT_Container_Size_Y ),
	.FONT_Size_X_i( FONT_Size_X ),
	.FONT_Size_Y_i( FONT_Size_Y ),
	.FONT_Horizontal_Num_Char_i( FONT_Horizontal_Num_Char ),
	.FONT_Vertical_Num_Line_i( FONT_Vertical_Num_Line ),


	.Mono_Font_Output( Pixel_Mono_FONT_Out ),			// Actual FONT Pixel Output (1 Bit Per Pixel)

	.Color_Font_Blue( FONT_Blue ),
	.Color_Font_Green( FONT_Green ),
	.Color_Font_Red( FONT_Red ),

	.CPU_Clk_i( CPU_Clk_i ),
	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),
	.iBUS_D8_i( iBUS_D8_i ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),	
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_WE_i( iBUS_WE_i ), 
	
	.iBUS_Text_Memory_D_o( iBUS_Text_Memory_D_o ),
	.iBUS_Color_Memory_D_o( iBUS_Color_Memory_D_o ), 
	
	.CS_TextMemory_i( CS_TextMemory_i ),
	.CS_ColorMemory_i( CS_ColorMemory_i ),
	
	.CS_FOREGROUND_CLUT_i( CS_FG_CLUT_i ),		// High Part of the Color
	.CS_BACKGROUND_CLUT_i( CS_BG_CLUT_i ),	
	.CS_FONT_Memory_i( CS_FONT_i )
	
	/*
	

	.CS_Txt_Foreground_Plt_i( CS_Txt_Foreground_Plt_i ),
	.CS_Txt_Background_Plt_i( CS_Txt_Background_Plt_i ),
	.Txt_Data_Read_o( DataOut_TextMemory_o ),
	.Clr_Data_Read_o( DataOut_ColorMemory_o ),
	.FONT_Memory_o( DataOut_FONT_Memory_o ),
	.LUT_FG_Data_Read_o( DataOut_Txt_Clr_FG_Plt_o ),	//16 Color LUT Tables - Foreground
	.LUT_BG_Data_Read_o( DataOut_Txt_Clr_BG_Plt_o )	//16 Color LUT Tables - Background
	*/
);

MousePointerSpriteModule MousePointerModule
(

	.rst_i( Reset_i ),				// This is async Reset

	.Bus_Clk_i( CPU_Clk_i ),
	.Bus_A_i( iBUS_A_i ),
	.Bus_RW_i( iBUS_RWn_i ),
	.Bus_BE_i( iBUS_BE_i  ),
	.Bus_WE_i( iBUS_WE_i ), 
	.Bus_D8_i( iBUS_D8_i ),
	.Bus_D16_i( iBUS_D16_i ),
	.Bus_D32_i( iBUS_D32_i ),
	.Bus_D_Siz_i( iBUS_D_Siz_i ),	
	.Bus_D_o( DataOut_A_Mouse_Regs_o ),

	.Mouse_Pointer_Mem_CS_i( CS_Mouse_Ptr_A_Graphics_i ),
	.Mouse_Pointer_Reg_CS_i( CS_Mouse_Ptr_A_Registers_i ),
	.SOF_i( SOF ),

	.VideoClk_i( VideoClkOut ),
	.VideoRst_i( Reset_VideoClkOut ), 
	.VideoModeReset_i( VideoModeReset ),
	.Mstr_Ctrl_Video_Mode_CPU_i( Mstr_Ctrl_Video_Mode_CPU ),
	.Mstr_Ctrl_Doubling_Pixel_i( Mstr_Ctrl_Doubling_Pixel ),
	.VSync_i( VSync ),
	.HSync_i( HSync ),
	.VBlanking_i( VBlanking ),					// 
	.DE_i( HBlanking & VBlanking ),
	.HBLANK_START_i( HBLANK_START ), 		//1
	.HBLANK_STOP_i( HBLANK_STOP ),			//256
	.HLineCount_i( HLineCount ),
	.HPixelCount_i( HPixelCount ),
	.Limit_Resolution_X_i( {4'b0000, Visible_Pixel_Per_Line_Value} ),
	.Limit_Resolution_Y_i( {4'b0000, Visible_Line_Per_Line_Value } ),
	.Pointer_RGB_o( MouserPointer_Full_ARGB )
);


endmodule

/*
reg 	[23:0] 	Channel_A_RGB;
always @ (posedge VID_A_CLK_P_o) begin

	case ( HPixelCount_A )
	
		12'd158: Channel_A_RGB <= 24'hFF_FF_FF;	// White
		12'd249: Channel_A_RGB <= 24'hFF_FF_00;	// Yellow
		12'd340: Channel_A_RGB <= 24'h00_FF_FF; 	// Cyan
		12'd431: Channel_A_RGB <= 24'h00_FF_00;	// Green
		12'd522: Channel_A_RGB <= 24'hFF_00_FF;	// Violet
		12'd613: Channel_A_RGB <= 24'hFF_00_00;	// Red
		12'd704: Channel_A_RGB <= 24'h00_00_FF;	// Blue
	endcase
end
*/


