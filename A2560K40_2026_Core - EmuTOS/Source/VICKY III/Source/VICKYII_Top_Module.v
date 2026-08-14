`timescale 1 ps / 1 ps
module VICKYII_Top_Module (
input		wire				COLD_RESETn_i,
input		wire				SYS_RSTn_i,
input 	wire				Ext_Reset_i,
input		wire				PLL_BUS_CLK_i,
input		wire				BUS_CLK_i,


input		wire	[31:0]	BUS_A_In_i,
output	wire	[31:0]	BUS_A_DMA_Out_o,
input		wire	[31:0]	BUS_D_In_i,
output	wire	[31:0]	BUS_D_DMA_Out_o,
input		wire				BUS_ACKn_i,
output	wire				BUS_REQn_o,
input		wire				BUS_RWn_In_i,
output	wire				BUS_RWn_DMA_Out_o,
// CLK Inputs
input		wire				OSC_CLK_25_175Mhz_i,	// Clock Input 0
input		wire				OSC_CLK_40_000Mhz_i,	// Clock Input 1
input		wire				OSC_CLK_14_318MHZ_i,	// Original Oscillator Clock - Not Used
// DAC Outputs
output	wire				VID0_CLK_P_o,	// Clock Output
output	wire				VID0_DE_o,
output	wire				VID0_HSYNC_o,
output	wire				VID0_VSYNC_o,
output	wire	[23:0]	VID0_PIXEL_o,
output	wire				VID0_RSTn_o,
// Video Memory Bus
output	wire				VMEM_OEn_o,	
output	wire  [3:0]		VMEM_WEn_o,
output	wire	[20:0]	VMEM_A_o,
input		wire	[31:0]	VMEM_D_In_i,
output	wire	[31:0]	VMEM_D_Out_o,
// MISC Signals
output	wire	[5:0]		VKYII_INT_o,		//Interrupt Outputs
output	wire				VKY_DBG_RDY_o,
input		wire				HIGH_RES_ON_OFF_i,
input		wire				GAMMA_ON_OFF_i,

// Data Out Shit
// Data Path from the different Block
output	wire	[7:0]		DataOut_Register_Level_o,
output	wire	[7:0]		DataOut_Bitmap_Regs_o,
output	wire	[7:0] 	DataOut_Tile0_Regs_o,
output	wire	[7:0] 	DataOut_Tile1_Regs_o,
output	wire	[7:0] 	DataOut_Collisions_Regs_o,
output	wire	[7:0]		DataOut_VDMA_Controller_o,
output	wire	[7:0]		DataOut_SDMA_Controller_o,
output	wire	[7:0]		DataOut_Sprites_Regs_o,
output	wire  [7:0] 	DataOut_VMEM_2_CPU_o,
output	wire	[7:0]		DataOut_Txt_Clr_FG_Plt_o,
output	wire	[7:0]		DataOut_Txt_Clr_BG_Plt_o,
output	wire	[7:0]		DataOut_LUT_o,
output	wire	[7:0]		DataOut_GAMMA_B_o,
output	wire	[7:0]		DataOut_GAMMA_G_o,
output	wire	[7:0]		DataOut_GAMMA_R_o,
output	wire	[7:0]		DataOut_TextMemory_o,
output	wire	[7:0]		DataOut_ColorMemory_o,
output	wire	[7:0]		DataOut_FONT_Memory_o,
output	wire	[7:0]		DataOut_AttrMemory_o,
output	wire	[7:0]		DataOut_VideoMemory_o,
output	wire	[7:0]		DataOut_MousePointer_o,
output	wire	[7:0]		DataOut_Multiplier32x32_o,



);

// Write Strobe for every Dual-Port RAM in the system
wire				CS_VIDEO_RAM_i;
wire				CS_GAMMA_B_i;
wire				CS_GAMMA_G_i;
wire				CS_GAMMA_R_i;
wire 				CS_VID_Color_Char_i;
wire 				CS_VID_Text_Char_i;
wire				CS_FONT_Memory_i;
wire				CS_LUT_i;
wire				CS_Txt_Background_Plt_i;
wire				CS_Txt_Foreground_Plt_i;
wire				CS_VMEM_2_CPU_i;
wire				CS_VDMA_Controller_i;
wire				CS_SDMA_Controller_i;
wire				CS_Sprites_Registers_i;
wire				CS_Tile0_Registers_i;
wire				CS_Tile1_Registers_i;
wire				CS_Collisions_Registers_i;
wire				CS_Bitmap_Registers_i;
wire				CS_Vicky_Registers_i;
wire				CS_MousePointerMem_i;
wire				CS_MousePointerReg_i;
wire				CS_MULTIPLIER32x32_i;


assign Debug_Clk100_o = Clk100Mhz;
///////////////////////////////////////////////
// WIRES
//////////////////////////////////////////////
// PLL Output & Flags
wire 				VideoClkOut;
wire				ActiveClockOutput;
wire				VideoClockLocked;
wire				PLL_Locked;
wire				Clk50Mhz;
wire				Clk100Mhz;
wire				Clk200Mhz;
wire				BUS_14MHZ_IN;


wire				Bus_RDY_o;
// Pixel Bus
wire				HBlanking;
wire 				HBlanking_Latency;
wire				VBlanking;
wire				Horizontal_Precharge;
wire				HSync;
wire				VSync;
wire	[11:0]	HPixelCount;
wire	[11:0]	HLineCount;
wire	[11:0]	HPixelCount_Aux;
wire	[11:0]	HLineCount_Aux;
wire 	[11:0]	Total_Pixel_Per_Line_Value;
wire	[11:0]	Total_Line_Per_Image_Value;
wire	[11:0]	H_Blanking_Value;
wire	[11:0]	V_Blanking_Value;
wire	[11:0]	Visible_Pixel_Per_Line_Value;
wire	[11:0]	Visible_Line_Per_Line_Value;
wire				VideoModeReset;
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
// Misc / System Signals
wire				Ext_Reset;
wire 				VideoClk_Full_Resolution;
wire 				VideoClk_Half_Resolution;
// VGE Signals
wire				VGE_VBlanking;
wire	[31:0]	VGE_RGB_Pixel;
// VGE Signal to Memory Controller
wire	[35:0]	VGE_Command;
wire				VGE_Command_Write;
wire				VGE_Command_Full;

wire	[31:0]	VGE_DATA_2_WRITE;
wire				VGE_DATA_2_WRITE_Write;
wire				VGE_DATA_2_WRITE_Full;

wire	[31:0]	VGE_DATA_2_READ;
wire				VGE_DATA_2_READ_Read;
wire				VGE_DATA_2_READ_Empty;
wire	[7:0]		VGE_DATA_2_READ_Count;

// Master Control
wire 				Mstr_Ctrl_Text_Mode_Enable;
wire 				Mstr_Ctrl_Text_Mode_Overlay;
wire 				Mstr_Ctrl_Graphic_Mode_Enable;
wire 				Mstr_Ctrl_Bitmap_Enable;
wire 				Mstr_Ctrl_TileMap_Enable;
wire 				Mstr_Ctrl_Sprite_Enable;
wire 				Mstr_Ctrl_GAMMA_Enable;
wire 				Mstr_Ctrl_Disable_Video;
wire	[1:0]		Mstr_Ctrl_Video_Mode;
wire	[1:0]		Mstr_Ctrl_Video_Mode_100Mhz;

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

// Sequencer 
wire 				Time_Rd_Wr_Access_100Mhz;
wire 				Time_Rd_Only_Access_100Mhz;
wire 				Time_Trf_Pixels_2_Pixel_200Mhz;
wire 				Time_Erase_Pixels_Line_100Mhz;
wire 				Time_Erase_Pixels_Line_200Mhz;
wire				Time_2_Display_Line_VideoClk;
wire	[1:0]		Time_2_Charge_TileMap_Lines;

// Video System Interrupt
wire	[3:0]		Interrupt_Enable;
wire 	[11:0]	Vicky_Interrupt_LineCompare0;
wire 	[11:0]	Vicky_Interrupt_LineCompare1;
wire				SOF;
wire				SOL;

// Mouse
wire	[7:0]		MousePointer_GREY;

// VDMA
wire				VDMA_Interrupt;
wire				VDMA_Bus_RDY;


// SDMA to VGE Interface
wire				CPU_2_VCE_WriteFull_SDMA;
wire	[9:0]		CPU_2_VCE_WriteCount_SDMA;

wire				Collision_GRP_A_Interrupt;
wire				Collision_GRP_B_Interrupt;

///////////////////////////////////////////////
// Registers
//////////////////////////////////////////////



///////////////////////////////////////////////
// Assign
//////////////////////////////////////////////
assign	VMEM_A_o[20] = 1'b0;
assign 	VID_RSTn_o = 1'b1;
assign 	Bus_RDY_o  = 1'b0;
// CPU Rdy
assign 	VKY_DBG_RDY_o = Bus_RDY_o | SDMA_Rdy_o;
// Clocks
assign 	BUS_14MHZ_IN = BUS_CLK_i;

assign 	DataOut_AttrMemory_o = 8'h00;

wire		Sprite_Collision_Interrupt;
wire		Bitmap_Collision_Interrupt;
wire		Tilemap_Collision_Interrupt;

assign  VKYII_INT_o[0] = !SOF;				// Start of Frame 60Hz Interrupt
assign  VKYII_INT_o[1] = SOL;				// Line Interrupt (Programmable)
assign  VKYII_INT_o[2] = Sprite_Collision_Interrupt;				// Collision Channel A
assign  VKYII_INT_o[3] = Bitmap_Collision_Interrupt;				// Collision Channel B
assign  VKYII_INT_o[4] = VDMA_Interrupt;	// DMA 
assign  VKYII_INT_o[5] = Tilemap_Collision_Interrupt;				// TBD



///////////////////////////////////////////
/////// PLL
///////////////////////////////////////////
VIDEO_DOTCLK_PLL	VIDEO_DOTCLK_PLL_inst (
	.areset ( !COLD_RESETn_i ),
	.clkswitch ( Mstr_Ctrl_Video_Mode_PLL[0] ),
	.inclk0 ( OSC_CLK_25_175Mhz_i ),
	.inclk1 ( OSC_CLK_40_000Mhz_i ),
	.c0 ( VideoClk_Full_Resolution ),
	.c1 ( VideoClk_Half_Resolution ),
	.c2 ( VID_CLK_P_o ),
	.locked ( VideoClockLocked )
	);

VIDEO_DOTCLK_SW u0 (
	.clkselect ( Mstr_Ctrl_Video_Mode_PLL[1] ), //                  .clkselect	
	.inclk0x   (VideoClk_Full_Resolution),   //  	
	.inclk1x   (VideoClk_Half_Resolution),   //  altclkctrl_input.inclk1x
	.outclk    (VideoClkOut)     // altclkctrl_output.outclk
);

wire Clk200Mhz_Aux;
VICKYGCLK VICKYGENERALCLOCKGEN(
	//.areset( !VideoClockLocked ),
//	.inclk0( OSC_CLK_40_000Mhz_i ),
	.inclk0(	PLL_BUS_CLK_i ),
	.c0( Clk100Mhz ),	//Right now it is 98Mhz
	.c1( Clk200Mhz ), //Right Now it is 196Mhz
	.c2( Clk200Mhz_Aux ),
	.locked( PLL_Locked  )
);




//Ext_Reset_i

reg [2:0] Ext_Reset_100Mhz;

wire Reset_100Mhz;
wire Reset_200Mhz;
wire Reset_VideoClkOut;
wire Reset_VideoClk_Full_Resolution;

assign Reset_100Mhz = Ext_Reset_100Mhz[2];
assign Reset_200Mhz = Ext_Reset_200Mhz[2];
assign Reset_VideoClkOut = Ext_Reset_VideoClkOut[2];
assign Reset_VideoClk_Full_Resolution = Ext_Reset_VideoClk_Full_Resolution[2];

always @ (posedge Clk100Mhz) begin
	Ext_Reset_100Mhz[0] <= Ext_Reset_i;
	Ext_Reset_100Mhz[1] <= Ext_Reset_100Mhz[0];
	if ( Ext_Reset_100Mhz[1] == Ext_Reset_100Mhz[0] ) begin
		Ext_Reset_100Mhz[2] <= Ext_Reset_100Mhz[1];
	end
end


reg [2:0] Ext_Reset_200Mhz;
always @ (posedge Clk200Mhz) begin
	Ext_Reset_200Mhz[0] <= Ext_Reset_i;
	Ext_Reset_200Mhz[1] <= Ext_Reset_200Mhz[0];
	if ( Ext_Reset_200Mhz[1] == Ext_Reset_200Mhz[0] ) begin
		Ext_Reset_200Mhz[2] <= Ext_Reset_200Mhz[1];
	end
end

reg [2:0] Ext_Reset_VideoClkOut;
always @ (posedge VideoClkOut) begin
	Ext_Reset_VideoClkOut[0] <= Ext_Reset_i;
	Ext_Reset_VideoClkOut[1] <= Ext_Reset_VideoClkOut[0];
	if ( Ext_Reset_VideoClkOut[1] == Ext_Reset_VideoClkOut[0] ) begin
		Ext_Reset_VideoClkOut[2] <= Ext_Reset_VideoClkOut[1];
	end
end


reg [2:0] Ext_Reset_VideoClk_Full_Resolution;
always @ (posedge VideoClk_Full_Resolution) begin
	Ext_Reset_VideoClk_Full_Resolution[0] <= Ext_Reset_i;
	Ext_Reset_VideoClk_Full_Resolution[1] <= Ext_Reset_VideoClk_Full_Resolution[0];
	if ( Ext_Reset_VideoClk_Full_Resolution[1] == Ext_Reset_VideoClk_Full_Resolution[0] ) begin
		Ext_Reset_VideoClk_Full_Resolution[2] <= Ext_Reset_VideoClk_Full_Resolution[1];
	end
end



////////////////////////////////////////
////// SDMA
////////////////////////////////////////
wire SDMA_Rdy_o;

wire [9:0]	FIFO_Output_Count;
wire [9:0]	FIFO_Input_Count;
wire 			FIFO_Output_Clear;
wire	[7:0] BUS_D_DMA_In_i;

assign BUS_D_DMA_In_i = BUS_D_In_i;	// This is for clarity

wire	[7:0]	DataOut;
assign DataOut = 8'h00;

// SRAM VDMA Address Generation Circuit
C256Foenix_SMemoryInterface C256_SMEM_Interface(
	.Reset_i						( Ext_Reset_i ),
	.CPU_Clk_i					( BUS_14MHZ_IN ),
// Slave CPU Interface	
	.Bus_A_i						( BUS_A_In_i ),
	.Bus_D_Internal_VickyII_Data_i( DataOut ), 
	.Bus_D_i						( BUS_D_In_i ),
	.Bus_D_o						( DataOut_SDMA_Controller_o ),
	.Bus_RW_i					(  BUS_RWn_In_i ),
	.BUS_VPA_i					( BUS_VPA_i ),
	.BUS_VDA_i					( BUS_VDA_i ),
	.Bus_RDY_i					( 1'b1 ),
	.Bus_RDY_o					( SDMA_Rdy_o ),	
	.CS_SDMA_Controller_i	( CS_SDMA_Controller_i ),
// Master CPU Interface
	.CPU_SDMA_A_o				( BUS_A_DMA_Out_o ),				// DMA Channel Assy
	.CPU_SDMA_D_Out_o			( BUS_D_DMA_Out_o ),	// DMA Channel Data Out
	.CPU_SDMA_D_In_i			( BUS_D_DMA_In_i ),		// DMA Channel Data In
	.CPU_SDMA_Bus_RW_o		( BUS_RWn_DMA_Out_o ),	// DMA Channel Read/Writen
	.CPU_SDMA_Bus_Reqn_o		( BUS_REQn_o ),
	.CPU_SDMA_Bus_Ackn_i		( BUS_ACKn_i ),
// Input FIFO Interface from the VDMA Controller	
	.FIFO_Input_Channel_i	( VDMA_2_SDMA_Data_Channel ),
	.FIFO_Input_Read_o		( VDMA_2_SDMA_Data_Read ),
	.FIFO_Input_Count_i		( FIFO_Input_Count ), 
	.FIFO_Input_Empty_i		( VDMA_2_SDMA_Data_Empty ), 
// Output FIFO Interface to  the VDMA Controller
	.FIFO_Output_Clear_o		( FIFO_Output_Clear), 
	.FIFO_Output_Channel_o	( SDMA_2_VDMA_Data_Channel ), 
	.FIFO_Output_Write_o		( SDMA_2_VDMA_Data_Write ),
	.FIFO_Output_Count_i		( FIFO_Output_Count ), 
	.FIFO_OUtput_Full_i		( SDMA_2_VDMA_Data_Full )
);

wire 	[7:0] VDMA_2_SDMA_Data_Channel;
wire			VDMA_2_SDMA_Data_Read;
wire			VDMA_2_SDMA_Data_Empty;

wire 	[7:0] SDMA_2_VDMA_Data_Channel;
wire			SDMA_2_VDMA_Data_Write;
wire			SDMA_2_VDMA_Data_Full;

wire 			CPU_FILL_SRAM_Enable;
wire	[7:0]	CPU_FILL_Data;

wire 			CPU_FIFO_Read;
wire 			CPU_FIFO_Empty;
wire 			VDMA_Counter_Enable_FiFo_Wr_Full;
wire 			CPU_Targer_VRAM_Data_Valid;
wire 			GAMME_SELECT;
// Pixel Output
GraphicOutputMixer PixelMixer(

// CPU Interface
	.CPU_Clk_i( BUS_14MHZ_IN ),
	.CPU_Data_i( BUS_D_In_i ),
	.CPU_Addy_i( BUS_A_In_i ),
	.CPU_RWn_i( BUS_RWn_In_i ),
	.CS_GAMMA_B_i( CS_GAMMA_B_i ),
	.CS_GAMMA_G_i( CS_GAMMA_G_i ),
	.CS_GAMMA_R_i( CS_GAMMA_R_i ),

	.GAMMA_Enable_i( GAMME_SELECT ),
	.Text_Mode_Enable_i( Mstr_Ctrl_Text_Mode_Enable ),
	.Text_Overlay_Enable_i( Mstr_Ctrl_Text_Mode_Overlay ),
	.Graphic_Mode_Enable_i( Mstr_Ctrl_Graphic_Mode_Enable ),
	.Video_Mode_Select_i( Mstr_Ctrl_Video_Mode[0] ),
	.DataOut_GAMMA_B_o( DataOut_GAMMA_B_o ),
	.DataOut_GAMMA_G_o( DataOut_GAMMA_G_o ),
	.DataOut_GAMMA_R_o( DataOut_GAMMA_R_o ),
	.Turn_Off_Sync_i( TURNOFF_SYNC ),
	
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
	.Mouse_Grey_i( MousePointer_GREY ),

// VGE Color
	.VGE_Blue_i( VGE_RGB_Pixel[7:0] ),
	.VGE_Green_i( VGE_RGB_Pixel[15:8] ),
	.VGE_Red_i( VGE_RGB_Pixel[23:16] ),

// Timing Generator
	.HSync_i( HSync ),
	.VSync_i( VSync ),
	.HBlanking_i( HBlanking ),
	.VBlanking_i( VBlanking ),

// DAC Output Signals
	.VID_PIXEL_o( VID_PIXEL_o ),
	.VID_DE_o( VID_DE_o ),
	.VID_HSYNC_o( VID_HSYNC_o ),
	.VID_VSYNC_o( VID_VSYNC_o )
);

wire 			HBlanking_VGE_Lat;
wire 			Mstr_Ctrl_Reset;
wire [1:0] 	Mstr_Ctrl_Video_Mode_PLL;

////////////////////////////////////
// Generates Video Timing for the Video Output
////////////////////////////////////

VideoTimingGenerator VideoTimingGen(
	.Reset_VideoClk_Full_Resolution( Reset_VideoClk_Full_Resolution ),
	.VideoClk_i( VideoClk_Full_Resolution ),								//40Mhz (640 x 480) inside 800 x 600	
	.EngineClk100Mhz_i( Clk100Mhz ),
	.EngineClk200Mhz_i( Clk200Mhz ),
	.Mstr_Ctrl_Video_Mode_i(Mstr_Ctrl_Video_Mode[1:0]),	
	.HSYNC_o(HSync),					//HD
	.VSYNC_o(VSync),					//VD
	.HPixelCount_o(HPixelCount),
	.HLineCount_o(HLineCount),

	// Timing for 640 x 480
	.HSYNC_START_i( Mstr_Ctrl_Video_Mode[0] ? 	16'd39 		: 16'd15 ), 		// Front Porch 40
	.HSYNC_STOP_i( Mstr_Ctrl_Video_Mode[0] ? 	16'd167 		: 16'd111 ), 		// Sync 96+16
	.HBLANK_START_i( Mstr_Ctrl_Video_Mode[0] ? 	16'd255 		: 16'd159 ), 	// Enable Data Starts @ 159
	.HBLANK_STOP_i( Mstr_Ctrl_Video_Mode[0] ? 	16'd1055 	: 16'd799 ),	// Enable Data Stops @ 799
	
	.VTOTAL_i( Mstr_Ctrl_Video_Mode[0] ?  			16'd627 		: 16'd524 ), 				// In Line (525)
	.VSYNC_START( Mstr_Ctrl_Video_Mode[0] ? 		20'd1055 	: 20'd7999 ),
	.VSYNC_STOP( Mstr_Ctrl_Video_Mode[0] ?  		20'd5279 	: 20'd9599 ),
	.VBLANK_START( Mstr_Ctrl_Video_Mode[0] ? 		20'd29567 	: 20'd35999 ),
	.VBLANK_STOP( Mstr_Ctrl_Video_Mode[0] ? 		20'd663167	: 20'd419999 ),

	.HBlanking_Latency_o( HBlanking_Latency ),	// Early HBlanking Signal to Account for the Latency of the different memory Buffers
	.HBlanking_Latency_VGE_o ( HBlanking_VGE_Lat ),
	.HBlanking_o( HBlanking ),
	.VBlanking_o( VBlanking ),
	.VGE_Engine_VBlanking_o( VGE_VBlanking ),
	.SOF_o( SOF ),
	.Time_Rd_Wr_Access_100Mhz_o( Time_Rd_Wr_Access_100Mhz ),		
	.Time_Rd_Only_Access_100Mhz_o( Time_Rd_Only_Access_100Mhz ),	// 
	.Time_Trf_Pixels_2_Pixel_200Mhz_o( Time_Trf_Pixels_2_Pixel_200Mhz ),
	.Time_Erase_Pixels_Line_100Mhz_o( Time_Erase_Pixels_Line_100Mhz ),
	.Time_Erase_Pixels_Line_200Mhz_o( Time_Erase_Pixels_Line_200Mhz ),	
	.Time_2_Display_Line_VideoClk_o( Time_2_Display_Line_VideoClk ),
	.Time_2_Charge_TileMap_Lines_o( Time_2_Charge_TileMap_Lines )
);


VideoModeTimingInformation VideoMode_Info(
	.VideoRst_i( Reset_VideoClkOut ),
	.PLL_Locked( VideoClockLocked & PLL_Locked),
	.Video_Clk_i( VideoClkOut ),
	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode[1:0] ),

	.Total_Pixel_Per_Line_Value_o( Total_Pixel_Per_Line_Value ),
	.Total_Line_Per_Image_Value_o( Total_Line_Per_Image_Value ),
	.H_Blanking_Value_o( H_Blanking_Value ),
	.V_Blanking_Value_o( V_Blanking_Value ),
	.Visible_Pixel_Per_Line_Value_o( Visible_Pixel_Per_Line_Value ),
	.Visible_Line_Per_Line_Value_o( Visible_Line_Per_Line_Value ),
	.VideoModeReset_o( VideoModeReset )
);

reg [1:0]	VideoModeReset_100Mhz_Meta;
reg			VideoModeReset_100Mhz;

always @ (posedge Clk100Mhz) begin

		VideoModeReset_100Mhz_Meta[0] <= VideoModeReset;
		VideoModeReset_100Mhz_Meta[1] <= VideoModeReset_100Mhz_Meta[0];
			if ( VideoModeReset_100Mhz_Meta[1] == VideoModeReset_100Mhz_Meta[0]) 
				VideoModeReset_100Mhz <= VideoModeReset_100Mhz_Meta[1];
end

reg [1:0]	VideoModeReset_200Mhz_Meta;
reg			VideoModeReset_200Mhz;

always @ (posedge Clk200Mhz) begin

		VideoModeReset_200Mhz_Meta[0] <= VideoModeReset;
		VideoModeReset_200Mhz_Meta[1] <= VideoModeReset_200Mhz_Meta[0];
			if ( VideoModeReset_200Mhz_Meta[1] == VideoModeReset_200Mhz_Meta[0]) 
				VideoModeReset_200Mhz <= VideoModeReset_200Mhz_Meta[1];
end

////////// 
////
//// Vicky Master Control Register
////
/////////
Vicky_Register_Block Vicky_Reg_Block(
	.rst_i( Ext_Reset_i ),				// This is async Reset
	.Reset_VideoClkOut( Reset_VideoClkOut ),	
	.Aux_Clk_i( OSC_CLK_25_175Mhz_i ), 
	.EngineClk100Mhz_i( Clk100Mhz ),
	.EngineClk200Mhz_i( Clk200Mhz ),
// CPU Signals Interface
	.Bus_Clk_i( BUS_14MHZ_IN ),
	.Bus_A_i( BUS_A_In_i ),
	.Bus_D_i( BUS_D_In_i ),
	.Bus_D_o( DataOut_Register_Level_o ),
	.Bus_RW_i( BUS_RWn_In_i ),
	.Bus_RDY_i( 1'b1 ),
	.Bus_RDY_o(),
// ChipSelect
	.CS_Vicky_Registers_i( CS_Vicky_Registers_i ),
// Video Info
	.VideoClk_i( VideoClkOut ),
	.SOF_i( SOF ),
	.DIPSwitch_GAMMA_i( GAMMA_ON_OFF_i ),
	.DIPSwitch_HiRes_i( HIGH_RES_ON_OFF_i ),
	.GAMMA_Select_o( GAMME_SELECT ),
	.Turn_Off_Sync_o( TURNOFF_SYNC ),
// Cursor Register
	.Cursor_X_Position_o( Cursor_X_Position ),
	.Cursor_Y_Position_o( Cursor_Y_Position ),
	.Cursor_Control_Reg_o( Cursor_Control_Reg ),
	.Cursor_Character_Reg_o( Cursor_Character_Reg ),
	.Cursor_Color_Reg_o( Cursor_Color_Reg ),
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
	.Mstr_Ctrl_Disable_Video_o( Mstr_Ctrl_Disable_Video ),

	.Mstr_Ctrl_Video_Mode_o( Mstr_Ctrl_Video_Mode ),	// 25/40Mhz
	.Mstr_Ctrl_Video_Mode_14Mhz_o( Mstr_Ctrl_Video_Mode_14Mhz ), //14Mhz
	.Mstr_Ctrl_Video_Mode_100MhzReSynced_o( Mstr_Ctrl_Video_Mode_100Mhz ), //100Mhz
	
   .Mstr_Ctrl_Reset_Pll_o( Mstr_Ctrl_Reset ),
	.Mstr_Ctrl_Video_Mode_PLL_o( Mstr_Ctrl_Video_Mode_PLL ),
	
	.Interrupt_Enable_o( Interrupt_Enable ),
	.Vicky_Interrupt_LineCompare0_o( Vicky_Interrupt_LineCompare0 ),
	.Vicky_Interrupt_LineCompare1_o( Vicky_Interrupt_LineCompare1 )
);
wire [1:0] Mstr_Ctrl_Video_Mode_14Mhz;
////////// 
////
//// Mouse Pointer Sprite Module
////
/////////
MousePointerSpriteModule MousePointerModule
(
	.rst_i( Ext_Reset_i ),				// Cold Reset
	.Bus_Clk_i( BUS_14MHZ_IN ),
	.Bus_A_i( BUS_A_In_i ),
	.Bus_D_i( BUS_D_In_i ),
	.Bus_D_o( DataOut_MousePointer_o ),
	.Bus_RW_i( BUS_RWn_In_i ),
	.Mouse_Pointer_Mem_CS_i( CS_MousePointerMem_i ),
	.Mouse_Pointer_Reg_CS_i( CS_MousePointerReg_i ),	
	.SOF_i( SOF ),
	.VBlanking_i( VBlanking ),
	.VSync_i( VSync ),
	.HSync_i( HSync ),
	.DE_i( HBlanking & VBlanking ),
	.HBLANK_START_i( Mstr_Ctrl_Video_Mode[0] ? 	16'd255 	: 16'd159 ), 	// Enable Data Starts @ 159
	.HBLANK_STOP_i( Mstr_Ctrl_Video_Mode[0] ? 	16'd1055 : 16'd799 ),	// Enable Data Stops @ 799
	
	.VideoClk_i( VideoClkOut ),
	.VideoRst_i( Reset_VideoClkOut ),				// Warm Reset
	.VideoModeReset_i( VideoModeReset ),	// When the Resolution is changed
	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode[1:0] ),
	.Mstr_Ctrl_Video_Mode_14Mhz_i( Mstr_Ctrl_Video_Mode_14Mhz ),	
	.HLineCount_i( HLineCount ),
	.HPixelCount_i( HPixelCount ),
	.Limit_Resolution_X_i( {4'b0000, Visible_Pixel_Per_Line_Value} ),
	.Limit_Resolution_Y_i( {4'b0000, Visible_Line_Per_Line_Value } ),
	// Output Color
	.Pointer_Grey( MousePointer_GREY )
);

/////////////////////
/////
/////
///// Line Interrupt
/////
/////
/////////////////////
LineInterruptModule LineInterruptMod
(
// Video Timming Signals
	.VideoClk_i( VideoClkOut ),
	.VideoRst_i( Reset_VideoClkOut ),
	.HLineCount_i( HLineCount ),
	.HPixelCount_i( HPixelCount ),
	.VBlanking_i( VBlanking  ),
	.HBlanking_i( HBlanking ),
	.V_Blanking_Value_i( V_Blanking_Value ),
	.VideoModeReset_i( VideoModeReset ),	

	.Interrupt_Enable_i(  Interrupt_Enable ),
	.Vicky_Interrupt_LineCompare0_i( Vicky_Interrupt_LineCompare0 ),
	.Vicky_Interrupt_LineCompare1_i( Vicky_Interrupt_LineCompare1 ),

	.LineInterrupt_o( SOL )
);

////////////////////
/////
/////
///// TextBlock
/////
/////////////////////
VICKY_Monochrome_Text_Block Monochrome_FONT_Block(
	.VideoClk_i( VideoClkOut ),
	.VideoRst_i( Reset_VideoClkOut ),
	.HLineCount_i( HLineCount ),
	.HPixelCount_i( HPixelCount ),
	.Vsync_i( VSync ),
	.VBlanking_i( VBlanking ),
	//.HBlanking_i(HBlanking), //HBlanking_Latency
	.HBlanking_i( HBlanking_Latency ), //HBlanking_Latency
	
	.Total_Pixel_Per_Line_Value_i( Total_Pixel_Per_Line_Value ),
	.Total_Line_Per_Image_Value_i( Total_Line_Per_Image_Value ),
	.H_Blanking_Value_i( H_Blanking_Value ),
	.V_Blanking_Value_i( V_Blanking_Value ),
	.Visible_Pixel_Per_Line_Value_i( Visible_Pixel_Per_Line_Value ),
	.Visible_Line_Per_Line_Value_i( Visible_Line_Per_Line_Value ),
	.VideoModeReset_i( VideoModeReset ),
	
	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode[1:0] ),
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
	.Reg_Border_Color_i( Border_Color_Reg ),
	.Border_X_Scroll_i( Border_X_Scroll ),	// 2:0
	.Border_X_Size_i( Border_X_Size ),							// 5:0
	.Border_Y_Size_i( Border_Y_Size ),							// 5:0
	
	.TextMode_Enable_i( Mstr_Ctrl_Text_Mode_Enable ),
// Cursor Register
	.Cursor_X_Position_i( Cursor_X_Position ),
	.Cursor_Y_Position_i( Cursor_Y_Position ),
	.Cursor_Control_Reg_i( Cursor_Control_Reg ),
	.Cursor_Character_Reg_i( Cursor_Character_Reg ),
	.Cursor_Color_Reg_i( Cursor_Color_Reg ),

	.Mono_Font_Output( Pixel_Mono_FONT_Out ),			// Actual FONT Pixel Output (1 Bit Per Pixel)

	.Color_Font_Blue( FONT_Blue ),
	.Color_Font_Green( FONT_Green ),
	.Color_Font_Red( FONT_Red ),

	.Bus_Clk_i( BUS_14MHZ_IN ),
	.Bus_A_i( BUS_A_In_i ),
	.Bus_D_i( BUS_D_In_i ),
	.Bus_RW_i( BUS_RWn_In_i ),
	
	.CS_VID_Txt_Char_i( CS_VID_Text_Char_i ),
	.CS_VID_Clr_Char_i( CS_VID_Color_Char_i ),
	.CS_FONT_Memory_i( CS_FONT_Memory_i ),
	.CS_Txt_Foreground_Plt_i( CS_Txt_Foreground_Plt_i ),
	.CS_Txt_Background_Plt_i( CS_Txt_Background_Plt_i ),
	.Txt_Data_Read_o( DataOut_TextMemory_o ),
	.Clr_Data_Read_o( DataOut_ColorMemory_o ),
	.FONT_Memory_o( DataOut_FONT_Memory_o ),
	.LUT_FG_Data_Read_o( DataOut_Txt_Clr_FG_Plt_o ),	//16 Color LUT Tables - Foreground
	.LUT_BG_Data_Read_o( DataOut_Txt_Clr_BG_Plt_o )	//16 Color LUT Tables - Background
);


VGE_MasterController_Module VGE_MasterCTRL_Module(
	// System Reset
	.Reset_100Mhz( Reset_100Mhz ),
	.Reset_200Mhz( Reset_200Mhz ),
	.Reset_VideoClkOut( Reset_VideoClkOut ),
	.Reset_VideoClk_Full_Resolution( Reset_VideoClk_Full_Resolution ),
	.Reset_i( Ext_Reset_i  ), 
	// Video Mode Change
	.VideoModeReset_i( VideoModeReset ),
	.VideoModeReset_100Mhz_i( VideoModeReset_100Mhz ),
	.VideoModeReset_200Mhz_i( VideoModeReset_200Mhz ),
	// Clocks
	.Bus_Clk_i(BUS_14MHZ_IN),
	.EngineClk100Mhz_A_i( Clk100Mhz ),
	.EngineClk100Mhz_B_i( Clk100Mhz ),		// Memory Interface
	.EngineClk200Mhz_i( Clk200Mhz ),		// VGE Engine Speed
	.EngineClk200Mhz_Aux_i( Clk200Mhz_Aux ),		// VGE Engine Speed	
	
	.VideoClock_Full_Resolution_i(VideoClk_Full_Resolution), 
	.VideoMuxClk_i( VideoClkOut ),	
	// Registers Input Sync Video Frequency
	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode[1:0] ),
	.Mstr_Ctrl_Video_Mode100Mhz_i( Mstr_Ctrl_Video_Mode_100Mhz[1:0] ), 
	.Mstr_Ctrl_Graphic_Mode_Enable_i( Mstr_Ctrl_Graphic_Mode_Enable ),
	.Mstr_Ctrl_Bitmap_Enable_i( Mstr_Ctrl_Bitmap_Enable ),
	.Mstr_Ctrl_TileMap_Enable_i( Mstr_Ctrl_TileMap_Enable ),
	.Mstr_Ctrl_Sprite_Enable_i( Mstr_Ctrl_Sprite_Enable ),
	.Mstr_Ctrl_Disable_Video_i( Mstr_Ctrl_Disable_Video ),
	
	// Video Interface
	.SOF_i( SOF ),
	.Vsync_i( VSync ),
	.VBlanking_i( VBlanking  ),
	.VGE_VBlanking_i( VGE_VBlanking ), 
	.HBlanking_VGE_Lat_i( HBlanking_VGE_Lat ),
	.HBlanking_i( HBlanking ),
	.Horizontal_Border_i( Horizontal_Border ),
	.Vertical_Border_i( Vertical_Border ),
	.Horizontal_Precharge_i( Horizontal_Precharge ),
	// Sequencer Signals
	.Time_Rd_Wr_Access_100Mhz_i( Time_Rd_Wr_Access_100Mhz ),		
	.Time_Rd_Only_Access_100Mhz_i( Time_Rd_Only_Access_100Mhz ),	// 
	.Time_Trf_Pixels_2_Pixel_200Mhz_i( Time_Trf_Pixels_2_Pixel_200Mhz ),
	.Time_Erase_Pixels_Line_100Mhz_i( Time_Erase_Pixels_Line_100Mhz ),
	.Time_Erase_Pixels_Line_200Mhz_i( Time_Erase_Pixels_Line_200Mhz ),
	.Time_2_Display_Line_VideoClk_i( Time_2_Display_Line_VideoClk ),
	.Time_2_Charge_TileMap_Lines_i( Time_2_Charge_TileMap_Lines ),
	// Video Timmings	
	.Total_Pixel_Per_Line_Value_i( Total_Pixel_Per_Line_Value ),
	.Total_Line_Per_Image_Value_i( Total_Line_Per_Image_Value ),
	.H_Blanking_Value_i( H_Blanking_Value ),
	.V_Blanking_Value_i( V_Blanking_Value ),
	.Visible_Pixel_Per_Line_Value_i( Visible_Pixel_Per_Line_Value ),
	.Visible_Line_Per_Line_Value_i( Visible_Line_Per_Line_Value ),	

	.Background_Blue_i( Background_Blue ),
	.Background_Green_i( Background_Green ),
	.Background_Red_i( Background_Red ),	
	
	// Video Output from VGE
	.VGE_RGB_Pixel_o( VGE_RGB_Pixel ), 	
	// CPU Clock
	.Bus_A_i( BUS_A_In_i ),
	.Bus_RW_i( BUS_RWn_In_i ),
	.Bus_RDY_i( 1'b1 ),
	.Bus_D_i( BUS_D_In_i ),
	.VMEM_2_CPU_ResetFiFo_i( VMEM_2_CPU_ResetFiFo ),
	.VMEM_2_CPU_FIFO_Count_o( VMEM_2_CPU_FIFO_Count ),
	.VMEM_2_CPU_FIFO_Empty_o( VMEM_2_CPU_FIFO_Empty ),
	.VMEM_2_CPU_Data_o( VMEM_2_CPU_Data ),		
	
	// Chip Selects
	.CS_VMEM_2_CPU_i( CS_VMEM_2_CPU_i ), 
	.CS_Bitmap_Registers_i( CS_Bitmap_Registers_i ),
	.CS_Tile0_Registers_i( CS_Tile0_Registers_i ),
	.CS_Tile1_Registers_i( CS_Tile1_Registers_i ),
	.CS_Collisions_Registers_i( CS_Collisions_Registers_i ),
	.CS_Sprites_Registers_i( CS_Sprites_Registers_i ),	
	.CS_LUT0_i( CS_LUT_i ),
	.CS_VIDEO_RAM_i( CS_VIDEO_RAM_i ),
	.CS_VDMA_Controller_i( CS_VDMA_Controller_i ),
	
	// Data Output toward Data Out MUX
	.DataOut_LUT_o( DataOut_LUT_o ),
	.DataOut_VideoMemory_o( DataOut_VideoMemory_o ),
	.DataOut_VDMA_o( DataOut_VDMA_Controller_o ),
	.DataOut_Bitmap_Regs_o( DataOut_Bitmap_Regs_o ),
	.DataOut_Tile0_Regs_o( DataOut_Tile0_Regs_o ),
	.DataOut_Tile1_Regs_o( DataOut_Tile1_Regs_o ),
	.DataOut_Collisions_Regs_o( DataOut_Collisions_Regs_o ),
	.DataOut_Sprites_Regs_o( DataOut_Sprites_Regs_o ),
	// VDMA - 1 Channel
	.VDMA_Interrupt_o		( VDMA_Interrupt ),
	
	.Sprite_Collision_Interrupt_o( Sprite_Collision_Interrupt ),
	.Bitmap_Collision_Interrupt_o( Bitmap_Collision_Interrupt ),	
	.Tilemap_Collision_Interrupt_o( Tilemap_Collision_Interrupt ), 

	// New SDMA 2 VDMA Interface
// Input FIFO Interface from the VDMA Controller	
	.FIFO_Input_Channel_o( VDMA_2_SDMA_Data_Channel ),
	.FIFO_Input_Read_i( VDMA_2_SDMA_Data_Read ),
	.FIFO_Input_Count_o( FIFO_Input_Count ),	
	.FIFO_Input_Empty_o( VDMA_2_SDMA_Data_Empty ), 
// Output FIFO Interface to  the VDMA Controller
	.FIFO_Output_Clear_i( FIFO_Output_Clear ),
	.FIFO_Output_Channel_i( SDMA_2_VDMA_Data_Channel ), 
	.FIFO_Output_Write_i( SDMA_2_VDMA_Data_Write ),
	.FIFO_Output_Count_o( FIFO_Output_Count ),
	.FIFO_OUtput_Full_o( SDMA_2_VDMA_Data_Full )	,
	
// Video RAM Access Module Interface
	.VGE_Addy_o( VMEM_A_o[19:0] ),	// 1Mx32
	.VGE_VidMem_Data_i( VMEM_D_In_i ),
	.VGE_VidMem_Data_o( VMEM_D_Out_o ),
	.VGE_VidMem_Readn_o( VMEM_OEn_o ),
	.VGE_VidMem_Writen_o( VMEM_WEn_o )
);

wire VMEM_2_CPU_ResetFiFo;
wire [9:0] VMEM_2_CPU_FIFO_Count;
wire VMEM_2_CPU_FIFO_Empty;
wire [7:0] VMEM_2_CPU_Data;


Multiplier_32x32 Mult32x32(
	.rst_i( Ext_Reset_i ),				// This is async Reset
// CPU Signals Interface
	.Bus_Clk_i( BUS_14MHZ_IN ),
	.Bus_A_i( BUS_A_In_i ),
	.Bus_D_i( BUS_D_In_i ),
	.Bus_D_o( DataOut_Multiplier32x32_o ),
	.Bus_RW_i( BUS_RWn_In_i ),
	.Multiplier32x32_CS_i( CS_MULTIPLIER32x32_i )
);

VMEM2CPU_Interface VMEM2CPU_Block(
	.rst_i( Ext_Reset_i ),				// This is async Reset
// CPU Signals Interface
	.Bus_Clk_i( BUS_14MHZ_IN ),
	.Bus_A_i( BUS_A_In_i ),
	.Bus_D_i( BUS_D_In_i ),
	.Bus_D_o( DataOut_VMEM_2_CPU_o ),
	.Bus_RW_i( BUS_RWn_In_i ),
	.CS_VMEM_2_CPU_i( CS_VMEM_2_CPU_i ),

	.VMEM_2_CPU_ResetFiFo_o( VMEM_2_CPU_ResetFiFo ),
	.VMEM_2_CPU_FIFO_Count_i( VMEM_2_CPU_FIFO_Count ),
	.VMEM_2_CPU_FIFO_Empty_i( VMEM_2_CPU_FIFO_Empty ),
	.VMEM_2_CPU_Data_i( VMEM_2_CPU_Data ),

	.VMEM_2_CPU_Interrupt_o(  )
);


endmodule



