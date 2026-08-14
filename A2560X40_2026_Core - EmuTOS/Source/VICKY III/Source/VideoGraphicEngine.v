`timescale 1ns/1ns
module VideoGraphicEngine (
// System resets
input		wire				Reset_100Mhz_i,
input		wire				Reset_200Mhz_i,

input		wire				Reset_VideoClkOut_i,
input		wire				Reset_VideoClk_Full_Resolution_i,
input		wire				Reset_i,		//14Mhz Reset
// Resets when the Video Mode Changes
input		wire				VideoModeReset_i,		// Reset When the Video is Changed
input		wire				VideoModeReset_100Mhz_i,
input		wire				VideoModeReset_200Mhz_i,
// Clocks
input		wire				EngineClk100Mhz_A_i,
input		wire				EngineClk100Mhz_B_i,
input		wire				EngineClk200Mhz_i,
input		wire				EngineClk200Mhz_Aux_i,
input		wire				VideoClk_i,				// Switch Between Full and Half Resolution 25.175/40Mhz and 12.587Mhz/20Mhz to extend Pixel Size
input		wire				VideoClock_Full_Resolution_i, 	// This is always either 25.175Mhz/40.000Mhz
input		wire				Bus_Clk_i,
// Video Signals
input		wire				SOF_i,
input		wire				Vsync_i,
input		wire				VBlanking_i,
input		wire				VGE_VBlanking_i,
input		wire				HBlanking_VGE_Lat_i,
input		wire				HBlanking_i,
// Video Timming Constants
input		wire	[11:0]	Total_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Total_Line_Per_Image_Value_i,
input		wire	[11:0]	H_Blanking_Value_i,
input		wire	[11:0]	V_Blanking_Value_i,
input		wire	[11:0]	Visible_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Visible_Line_Per_Line_Value_i,
// Sequencer 
input		wire				Time_Rd_Wr_Access_100Mhz_i,		
input		wire				Time_Rd_Only_Access_100Mhz_i,	// 
input		wire				Time_Trf_Pixels_2_Pixel_200Mhz_i,
input		wire				Time_Erase_Pixels_Line_100Mhz_i,
input		wire				Time_Erase_Pixels_Line_200Mhz_i,
input		wire				Time_2_Display_Line_VideoClk_i,
input		wire	[1:0]		Time_2_Charge_TileMap_Lines_i,
// Master Control Signals
input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,
input		wire	[1:0]		Mstr_Ctrl_Video_Mode100Mhz_i,
input		wire				Mstr_Ctrl_Doubling_Pixel_i,
input		wire				Mstr_Ctrl_Doubling_Pixel_100Mhz_i,
input		wire				Mstr_Ctrl_Graphic_Mode_Enable_i,
input		wire				Mstr_Ctrl_Bitmap_Enable_i,
input		wire				Mstr_Ctrl_TileMap_Enable_i,
input		wire				Mstr_Ctrl_Sprite_Enable_i,
input    wire				VGE_Engine_Disable_VideoProcessing_i,

input		wire	[11:0]	SX0_i,
input		wire	[11:0]	SY0_i,
input		wire	[11:0]	SX1_i,
input		wire	[11:0]	SY1_i,

input		wire	[11:0]	VX0_i,
input		wire	[11:0]	VY0_i,
input		wire	[11:0]	VX1_i,
input		wire	[11:0]	VY1_i,

// Bitmaps & Collision Map
input		wire				BM0_Layer_Enable_i,
input		wire	[2:0] 	BM0_Layer_Lut_i,
input		wire	[23:0]	BM0_MapAddy_i,
input		wire	[4:0]		BM0_X_Offset_i, // + 32
input		wire	[4:0]		BM0_Y_Offset_i, // + 32
input		wire				BM0_Collision_On_i,

input		wire				BM1_Layer_Enable_i,
input		wire	[2:0]		BM1_Layer_Lut_i,
input		wire	[23:0]	BM1_MapAddy_i,
input		wire	[4:0]		BM1_X_Offset_i, // + 32
input		wire	[4:0]		BM1_Y_Offset_i, // + 32	
input		wire				BM1_Collision_On_i,
input		wire				BM1_Coll_Map_En_i,	//
input		wire				BM1_Coll_Map_Display_En_i,	

input		wire				BM3_Layer_Enable_i,
input		wire	[2:0] 	BM3_Layer_Lut_i,
input		wire	[23:0]	BM3_MapAddy_i,
input		wire	[4:0]		BM3_X_Offset_i, // + 32
input		wire	[4:0]		BM3_Y_Offset_i, // + 32
input		wire				BM3_Collision_On_i,

input		wire				COL_Layer_Enable_i,
input		wire	[23:0]	COL_MapAddy_i,
input		wire	[4:0]		COL_X_Offset_i, // + 32
input		wire	[4:0]		COL_Y_Offset_i, // + 32	
input		wire				COL_Collision_On_i, 
// Collision Stuff
output	wire	[15:0]	Collision_SpriteL0_o,
output	wire	[15:0]	Collision_SpriteL1_o,
output	wire	[15:0]	Collision_SpriteL2_o,
output	wire	[15:0]	Collision_SpriteL3_o,
output	wire	[15:0]	Collision_SpriteL4_o,
output	wire	[15:0]	Collision_SpriteL5_o,
output	wire	[15:0]	Collision_SpriteL6_o,

output	wire	[15:0]	Collision_BM0_o,
output	wire	[15:0]	Collision_BM1_o,
output	wire	[15:0]	Collision_COL_o,

output	wire	[15:0]	Collision_TL0_o,
output	wire	[15:0]	Collision_TL1_o,
output	wire	[15:0]	Collision_TL2_o,
output	wire	[15:0]	Collision_TL3_o,
// Collision Pixel
output	wire	[7:0]		Sprite_Collision_Pixel_o,
output	wire	[5:0]		Sprite_Collision_Channel_o,
output	wire	[7:0]		Bitmap_L0_Collision_Pixel_o,
output	wire	[7:0]		Bitmap_L1_Collision_Pixel_o,
output	wire	[7:0]		Bitmap_C0_Collision_Pixel_o,
output	wire	[7:0]		Tilemap_L0_Collision_Pixel_o,
output	wire	[7:0]		Tilemap_L1_Collision_Pixel_o,
output	wire	[7:0]		Tilemap_L2_Collision_Pixel_o,
output	wire	[7:0]		Tilemap_L3_Collision_Pixel_o,
//Coordinate of the Collision
output	wire	[15:0]	Collision_Sprite_X_Location_o,
output	wire	[15:0]	Collision_Bitmap_X_Location_o,
output	wire	[15:0]	Collision_Tiles_X_Location_o,
output	wire	[15:0]	Collision_Y_Location_o,

input		wire 	[7:0] 	TileMap0_Control_Reg_i,
input		wire 	[22:0]	TileMap0_Addy_i,
input		wire	[9:0]		TileMap0_X_TotalSize_i,
input		wire	[9:0]		TileMap0_Y_TotalSize_i,
input		wire	[9:0]		TileMap0_X_Window_Pos_i,
input		wire	[9:0]		TileMap0_Y_Window_Pos_i,
input		wire	[4:0]		TileMap0_X_Scroll_i,
input		wire	[4:0]		TileMap0_Y_Scroll_i,

input		wire 	[7:0] 	TileMap1_Control_Reg_i,
input		wire 	[22:0]	TileMap1_Addy_i,
input		wire	[9:0]		TileMap1_X_TotalSize_i,
input		wire	[9:0]		TileMap1_Y_TotalSize_i,
input		wire	[9:0]		TileMap1_X_Window_Pos_i,
input		wire	[9:0]		TileMap1_Y_Window_Pos_i,
input		wire	[4:0]		TileMap1_X_Scroll_i,
input		wire	[4:0]		TileMap1_Y_Scroll_i,

input		wire 	[7:0] 	TileMap2_Control_Reg_i,
input		wire 	[22:0]	TileMap2_Addy_i,
input		wire	[9:0]		TileMap2_X_TotalSize_i,
input		wire	[9:0]		TileMap2_Y_TotalSize_i,
input		wire	[9:0]		TileMap2_X_Window_Pos_i,
input		wire	[9:0]		TileMap2_Y_Window_Pos_i,
input		wire	[4:0]		TileMap2_X_Scroll_i,
input		wire	[4:0]		TileMap2_Y_Scroll_i,

input		wire 	[7:0] 	TileMap3_Control_Reg_i,
input		wire 	[22:0]	TileMap3_Addy_i,
input		wire	[9:0]		TileMap3_X_TotalSize_i,
input		wire	[9:0]		TileMap3_Y_TotalSize_i,
input		wire	[9:0]		TileMap3_X_Window_Pos_i,
input		wire	[9:0]		TileMap3_Y_Window_Pos_i,
input		wire	[4:0]		TileMap3_X_Scroll_i,
input		wire	[4:0]		TileMap3_Y_Scroll_i,
// Addressof TileSet
input		wire	[22:0]	TileSet0Addy_i,
input		wire	[22:0]	TileSet1Addy_i,
input		wire	[22:0]	TileSet2Addy_i,
input		wire	[22:0]	TileSet3Addy_i,
input		wire	[22:0]	TileSet4Addy_i,
input		wire	[22:0]	TileSet5Addy_i,
input		wire	[22:0]	TileSet6Addy_i,
input		wire	[22:0]	TileSet7Addy_i,
// TileSet 
input		wire	[3:0]		TileSet0_CFG_i,
input		wire	[3:0]		TileSet1_CFG_i,
input		wire	[3:0]		TileSet2_CFG_i,
input		wire	[3:0]		TileSet3_CFG_i,
input		wire	[3:0]		TileSet4_CFG_i,
input		wire	[3:0]		TileSet5_CFG_i,
input		wire	[3:0]		TileSet6_CFG_i,
input		wire	[3:0]		TileSet7_CFG_i,
// Sprites
output	wire	[5:0]		Sprite_Active_Channel_o,
input		wire	[63:0]	Sprite_OutputSpriteMem_i,
// Video Output Interface and Background
input		wire	[7:0]		Background_Blue_i,
input		wire	[7:0]		Background_Green_i,
input		wire	[7:0]		Background_Red_i,
output	wire	[31:0]	VGE_RGB_Pixel_o,
// CPU Interface - 14Mhz
input		wire	[31:0]	Bus_A_i,
input		wire				Bus_A_Valid_i,
input		wire				Bus_RW_i,
input		wire	[3:0]		Bus_BE_i,
input		wire				Bus_WE_i,
input		wire	[7:0]		Bus_D8_i,
input		wire	[15:0]	Bus_D16_i,
input		wire	[31:0]	Bus_D32_i,
input		wire	[1:0]		Bus_D_Siz_i,
//output	wire				VDMA_Bus_RDY_o,
input 	wire				CS_VMEM_2_CPU_i,
input 	wire				VMEM_2_CPU_ResetFiFo_i,
output   wire  [9:0] 	VMEM_2_CPU_FIFO_Count_o,
output	wire				VMEM_2_CPU_FIFO_Empty_o,
output	wire  [7:0] 	VMEM_2_CPU_Data_o,
// CPU ChipSelect - 14Mhz
input		wire				CS_VDMA_Controller_i,
input		wire				CS_LUT0_i,
input		wire				CS_VIDEO_RAM_B0_i,
input		wire				CS_VIDEO_RAM_B1_i,
// Data Output to be Read Back - 14Mhz
output	wire	[31:0]		DataOut_LUT_o,
output	wire	[31:0]		DataOut_VDMA_o,

// Input FIFO Interface from the VDMA Controller
//output	wire	[7:0]		FIFO_Input_Channel_o,
//input		wire				FIFO_Input_Read_i,
//output	wire	[9:0]		FIFO_Input_Count_o,
//output	wire				FIFO_Input_Empty_o,

// Output FIFO Interface to  the VDMA Controller
//input		wire				FIFO_Output_Clear_i,
//input		wire	[7:0]		FIFO_Output_Channel_i, 
//input		wire				FIFO_Output_Write_i,
//output	wire	[9:0]		FIFO_Output_Count_o,
//output	wire				FIFO_OUtput_Full_o,

// VDMA Interrupts
output	wire				VDMA_Interrupt_o,

output	wire				Sprite_Collision_Interrupt_o,
output	wire				Bitmap_Collision_Interrupt_o,
output	wire				Tilemap_Collision_Interrupt_o,

// Video RAM Bank A
inout		wire		[31:0]	VRAM_A_DQ_io,
output	wire		[3:0]		VRAM_A_BEn_o,
output	wire		[19:0]	VRAM_A_Addy_o,
output	wire					VRAM_A_OEn_o,
output	wire					VRAM_A_WEn_o,
// Video RAM Bank B
inout		wire		[31:0]	VRAM_B_DQ_io,
output	wire		[3:0]		VRAM_B_BEn_o,	
output	wire		[19:0]	VRAM_B_Addy_o,
output	wire					VRAM_B_OEn_o,
output	wire					VRAM_B_WEn_o
);

assign VDMA_Interrupt_o = 1'b0;
//	.Sprite_Active_Channel_o( Sprite_Active_Channel ),
//	.Sprite_OutputSpriteMem_i( OutputSpriteMem ),

//assign Sprite_Active_Channel_o = 6'b00_0000;

wire				BitmapChannel_A_Enable;
wire				BitmapChannel_B_Enable;

assign 			BitmapChannel_A_Enable = BM0_Layer_Enable_i | BM1_Layer_Enable_i;
assign 			BitmapChannel_B_Enable = BM3_Layer_Enable_i;

wire				VDMA_Transfer_In_Progress_i;
reg				VDMA_Transfer_Time_Available_o;

wire	[7:0]		Line0_Pixel_Out;
wire	[7:0]		Line1_Pixel_Out;
wire	[7:0]		Line2_Pixel_Out;
wire	[7:0]		Line3_Pixel_Out;
wire	[7:0]		Line4_Pixel_Out;
wire	[7:0]		Line5_Pixel_Out;
wire	[7:0]		Line6_Collision_Out;

wire	[7:0]		Line8_Pixel_Out;

wire	[9:0]		Layer_Scan_Address;

wire				Read_Pixel_Lines;

wire				Trig_Effect;

wire	[3:0]		VGE_Bitmap_Engine_SM_A;
wire	[3:0]		VGE_Bitmap_Engine_SM_B;
//wire	[4:0]		VGE_Tile_Engine_SM;
wire 				VGE_Tile_Engine_SM;
wire	[3:0]		VGE_Sprite_Engine_SM;
// Registers:
reg	[2:0]		EffectChannel;

reg	[2:0]		VGE_Engine_HBlanking_i_SYNC;
reg	[1:0]		VGE_Engine_VBlanking_i_SYNC;
reg	[2:0] 	VGE_Engine_SOF_SYNC;
reg	[15:0]	Horizontal_Border_i_EDGE;
reg	[11:0]	VGE_Engine_HLineCount_i0;
reg	[11:0]	VGE_Engine_HLineCount_i1;
reg	[2:0]		Valid_Capture_Time_EDGE;
reg				Valid_Capture_Time;
reg 				CPUCMD_TimeSlice;
/// Registers Needed in the Master State Machine
reg	[4:0]		VGE_Master_Engine_SM;
reg	[4:0]		VGE_Master_Engine_SM_SM;
reg	[11:0]	Horizontal_Line_Count;					
reg	[3:0]		Trigger_Effect;
reg				Bitmap_Effect_On;
reg				TileMap_Effect_On;
reg				Sprite_Effect_On;
reg				VDMA_Module_On;
reg	[2:0]		CPUCMD_TimeSlice_EDGE;
reg	[7:0]		MemoryWriteByte;

// Assignments
assign 			Trig_Effect = Trigger_Effect[3];

wire	[31:0]	VRAM_Data_2_CPU;
wire	[31:0]	VRAM_Data_2_BITMAP_A;
wire	[31:0]	VRAM_Data_2_BITMAP_B;
wire	[31:0]	VRAM_Data_2_TILEMAP;
wire	[31:0]	VRAM_Data_2_SPRITE;
wire	[31:0]	VRAM_Data_2_VDMA_32bits_Mode;
wire				VRAM_Data_Valid;
wire				Counter_Enable_CPU;
wire				Counter_Enable_BM_A;
wire				Counter_Enable_BM_B;
wire				Counter_Enable_TM;
wire				Counter_Enable_SP;
wire				Counter_Enable_VDMA;
wire				Counter_Load_BM_A;
wire				Counter_Load_BM_B;
wire				Counter_Load_TM;
wire				Counter_Load_SP;
wire				Counter_Load_VDMA;

reg 	[19:0]	CPUA_Target_Addy_Start;
reg	[19:0]	CPUA_Target_Addy_Stop;
wire				CPUA_Target_RW;

wire 	[19:0]	BitMap_Target_Addy_Start_A;
wire	[19:0]	BitMap_Target_Addy_Stop_A;

wire 	[19:0]	BitMap_Target_Addy_Start_B;
wire	[19:0]	BitMap_Target_Addy_Stop_B;

wire 	[19:0]	TileMap_Target_Addy_Start;
wire	[19:0]	TileMap_Target_Addy_Stop;

wire 	[19:0]	Sprite_Target_Addy_Start;
wire	[19:0]	Sprite_Target_Addy_Stop;

// VDMA
//wire 	[21:0]	VDMA_Target_Addy_Start;		// This Pointer has a 8bits mode
//wire	[21:0]	VDMA_Target_Addy_Stop;		// This Pointer has a 8bits mode
//wire				VDMA_Target_RW;
//wire	[3:0]		VDMA_Target_Wen;
//wire				VDMA_Target_Dir;
//wire	[31:0]	VDMA_Target_Data_2_Write;
//wire				VDMA_Target_Data_Out_Vld;
//wire				VDMA_Target_Data_Output_Valid;
//wire				VDMA_Target_Cntr_Reached_Cnt;

wire				DRAM2DPRAM_Trsfer_Done;


wire				VDMA_Target_Mode_Byte_Word;
wire	[7:0]		VRAM_Data_2_VDMA_8bits_Mode;
// The single Access CPU Stuff

//////////////////////////////////////////////////////////////////////
// Temporary Assigment
//////////////////////////////////////////////////////////////////////
assign VDMA_Transfer_In_Progress_i = 1'b0;
//assign CPU_CMD = 32'h0000_0000;
assign VMEM_2_CPU_FIFO_Count_o = 10'h000;
assign VMEM_2_CPU_Data_o = 8'h00;
assign DataOut_VDMA_o = 16'hBBBB;
assign VMEM_2_CPU_FIFO_Empty_o = 1'b1;

//wire [31:0] Source;
//wire [31:0] Probe;

//SourceAndProbe SOURCE68K (
//	.source (Source), // sources.source
//	.probe  (Probe)   //  probes.probe
//);

//assign Probe = 32'h0000_0000;

/*
wire [143:0] TP;
wire  Trigger;
assign Trigger = !Bus_RW_i & CS_VIDEO_RAM_B0_i & Bus_WE_i ;


assign TP[63:0] 		= { 3'b000, Bus_RW_i,  Data_2_Write , Bus_A_i[23:0]};
assign TP[73:64] 		= WrusedDW;
assign TP[75]			= CS_VIDEO_RAM_B0_i;
assign TP[76]			= Bus_WE_i;


ChipScope CHIPSCOPE68K (
	.acq_data_in    (TP),    //        tap.acq_data_in
	.acq_trigger_in (Trigger), //           .acq_trigger_in
	.acq_clk        (Bus_Clk_i),        //    acq_clk.clk
	.trigger_in     (Trigger)      // trigger_in.trigger_in
);
*/


//Temp Assignments:

// FIFO Interface between the CPU @ 14Mhz to VRAM @ Single Access Time 
// STEF - DON'T FORGET... YOU ARE DEALING wITH A 32Bits WIDE MEMORY BUS

reg [35:0] Data_2_Write;

//input		wire	[7:0]		Bus_D8_i,
//input		wire	[15:0]	Bus_D16_i,
//input		wire	[31:0]	Bus_D32_i,
//input		wire	[1:0]		Bus_D_Siz_i,

always @ (*) begin
  case ( Bus_D_Siz_i[1:0] )
  // 32bits
  2'b00: begin 
		Data_2_Write = { 4'b1111, Bus_D32_i}; 
	end
	
  // 8bits transfer
  2'b01: begin
		Data_2_Write = { Bus_BE_i[3:0], Bus_D8_i, Bus_D8_i, Bus_D8_i, Bus_D8_i };	// BE3 = LSB, BE0 = MSB
  end
  
  // 16bits transfer
  2'b10: begin
		Data_2_Write = { Bus_BE_i[3:0], Bus_D16_i, Bus_D16_i };
  end
  
  // Line Transfer
  2'b11: begin
		Data_2_Write = { 4'b1111, Bus_D32_i};
	end 
	
  endcase
end


wire 	[8:0] 	FIFO_Short_Count_A;
wire 	[8:0] 	FIFO_Short_Count_B;
wire 	[8:0] 	WrusedDW_A;
wire	[63:0]	CPU_CMD_A;
wire				CPU_CMD_A_Rd_Empty;
reg				CPU_CMD_A_Read;

wire 	[8:0] 	WrusedDW_B;
wire	[63:0]	CPU_CMD_B;
wire				CPU_CMD_B_Rd_Empty;
reg				CPU_CMD_B_Read;

CPU_2_DRAM_FIFO CPU2MEM_64BITS_FIFO_A(
	.aclr( Reset_i ),
	//               3x000 / 1x R_W / 4x BE / 32Bit Data / 24bit Address
	.data( { 3'b000, Bus_RW_i,  Data_2_Write , Bus_A_i[23:0]} ),
	.wrclk( Bus_Clk_i ),
	//.wrreq( CS_VIDEO_RAM_i & !Bus_RW_i ),	
	.wrreq( !Bus_RW_i & CS_VIDEO_RAM_B0_i & Bus_WE_i ),
	.wrusedw( WrusedDW_A ),
	.wrfull(  ),
	// 100Mhz VGE Section
	.rdclk( EngineClk100Mhz_A_i ),
	.rdreq( CPUA_Target_Read_FIFO_A ),
	.q( CPU_CMD_A ),
	.rdempty( CPU_CMD_A_Rd_Empty ),
	.rdusedw( FIFO_Short_Count_A )
);

CPU_2_DRAM_FIFO CPU2MEM_64BITS_FIFO_B(
	.aclr( Reset_i ),
	//               3x000 / 1x R_W / 4x BE / 32Bit Data / 24bit Address
	.data( { 3'b000, Bus_RW_i,  Data_2_Write , Bus_A_i[23:0]} ),
	.wrclk( Bus_Clk_i ),
	//.wrreq( CS_VIDEO_RAM_i & !Bus_RW_i ),	
	.wrreq( !Bus_RW_i & CS_VIDEO_RAM_B1_i & Bus_WE_i ),
	.wrusedw( WrusedDW_B ),
	.wrfull(  ),
	// 100Mhz VGE Section
	.rdclk( EngineClk100Mhz_A_i ),
	.rdreq( CPUA_Target_Read_FIFO_B ),
	.q( CPU_CMD_B ),
	.rdempty( CPU_CMD_B_Rd_Empty ),
	.rdusedw( FIFO_Short_Count_B )
);

wire	Counter_Reached_Count_A;
wire	Counter_Reached_Count_B;
wire	Data_Output_Valid_A;
wire	Data_Output_Valid_B;
wire  CPUA_Target_Read_FIFO_A;
wire  CPUA_Target_Read_FIFO_B;
assign Counter_Enable_CPU 	=  (VGE_Master_Engine_SM == CPU_ACCESS1) ? 1'b1 : 1'b0;
wire  FIFO_Transfer_Done_A;
wire  FIFO_Transfer_Done_B;

A2560K_VMemoryInterface A2560K_VMEM_CTRL_BANK_A(

	.Reset_100Mhz_i( Reset_100Mhz_i ),
	.Reset_i( Reset_i ),
	.EngineClk100Mhz_i( EngineClk100Mhz_A_i ),
// Memory Address Generator Controls Signals
	.Counter_Channel_i( EffectChannel ),					// From VGE
	.Counter_Reached_Count_o( Counter_Reached_Count_A ), 
	
	// VRAM BANK A
// Channel 0 - Single Byte Access
	.CPUA_Target_Enable_i( Counter_Enable_CPU & !CPU_CMD_A_Rd_Empty ),
	.CPUA_Target_Read_FIFO_o( CPUA_Target_Read_FIFO_A ), 
	.CPUA_Target_FIFO_Write_Count_i( FIFO_Short_Count_A ),
	.CPUA_Target_Transfer_Done_o( FIFO_Transfer_Done_A ),
	.CPUA_Target_CPU_CMD_Input_i( CPU_CMD_A ),
// Channel 1 - Read Only 32Bits Access
	.BitMap_Target_Enable_i( Counter_Enable_BM_A ),
	.BitMap_Target_Load_i( Counter_Load_BM_A ),
	.BitMap_Target_Addy_Start_i( BitMap_Target_Addy_Start_A ),
	.BitMap_Target_Addy_Stop_i( BitMap_Target_Addy_Stop_A ),
// Channel 2 - Read Only 32Bits Access
	.TileMap_Target_Enable_i( Counter_Enable_TM ),
	.TileMap_Target_Load_i( Counter_Load_TM ),
	.TileMap_Target_Addy_Start_i( TileMap_Target_Addy_Start ),
	.TileMap_Target_Addy_Stop_i( TileMap_Target_Addy_Stop ),
	.TileMap_Target_Dir_i( 1'b1 ),		// Always 1
// Channel 3 - Read Only 32Bits Access
	.Sprite_Target_Enable_i( Counter_Enable_SP ),
	.Sprite_Target_Load_i( Counter_Load_SP ),
	.Sprite_Target_Addy_Start_i( Sprite_Target_Addy_Start ),
	.Sprite_Target_Addy_Stop_i( Sprite_Target_Addy_Stop ),
	.Sprite_Target_Dir_i( 1'b1 ),		// Always 1
	
// Data Output
	.DataInputChannel0_o( VRAM_Data_2_CPU ),		// CPU
	.DataInputChannel1_o( VRAM_Data_2_BITMAP_A ),		// BITMAP
	.DataInputChannel2_o( VRAM_Data_2_TILEMAP ),		// TILEMAP
	.DataInputChannel3_o( VRAM_Data_2_SPRITE ),		// SPRITE
//	.DataInputChannel4_o( VRAM_Data_2_VDMA_32bits_Mode ),		// VDMA
	.Data_Output_Valid_o( Data_Output_Valid_A ),	
// VDMA	
	.VDMA_Src_Addy_Start_i( VDMA_Src_Addy_Start ),	// Byte Oriented
	.VDMA_Src_Addy_Stop_i( VDMA_Src_Addy_Stop ),		// Byte Oriented
	.VDMA_Src_Addy_Load_i( VDMA_Src_Addy_Load ),
	.VDMA_Src_Addy_Enable_i( VDMA_Src_Addy_Enable ),
	.VDMA_Src_Count_Reached_o( VDMA_Src_Count_Reached ),

	.VDMA_Dst_Addy_Start_i( VDMA_Dst_Addy_Start ),	// Byte Oriented
	.VDMA_Dst_Addy_Stop_i( VDMA_Dst_Addy_Stop ),		// Byte Oriented
	.VDMA_Dst_Addy_Load_i( VDMA_Dst_Addy_Load ),
	.VDMA_Dst_Addy_Enable_i( VDMA_Dst_Addy_Enable ),
	.VDMA_Dst_Count_Reached_o( VDMA_Dst_Count_Reached ),
	
	.VDMA_Transaction_RW_i( VDMA_Transaction_RW ),
	.VDMA_Transaction_Data_i( VDMA_Data_From_VDMA_Ctrl ),		// Byte Input
	.VDMA_Transaction_Data_o( VDMA_Data_To_VDMA_Ctrl ),		// Byte Output
// V(DRAM) Interface A
// Video RAM Bank A
	.VRAM_DQ_io( VRAM_A_DQ_io ),
	.VRAM_BEn_o( VRAM_A_BEn_o ),
	.VRAM_Addy_o( VRAM_A_Addy_o ),
	.VRAM_OEn_o( VRAM_A_OEn_o ),
	.VRAM_WEn_o( VRAM_A_WEn_o ),

	.Debug_i(  )
);

A2560K_VMemoryInterface A2560K_VMEM_CTRL_BANK_B(

	.Reset_100Mhz_i( Reset_100Mhz_i ),
	.Reset_i( Reset_i ),
	.EngineClk100Mhz_i( EngineClk100Mhz_A_i ),
// Memory Address Generator Controls Signals
	.Counter_Channel_i( EffectChannel ),					// From VGE
	.Counter_Reached_Count_o( Counter_Reached_Count_B ), 
	// VRAM BANK B
// Channel 0 - Single Byte Access
	.CPUA_Target_Enable_i( Counter_Enable_CPU & !CPU_CMD_B_Rd_Empty ),
	.CPUA_Target_Read_FIFO_o( CPUA_Target_Read_FIFO_B ), 
	.CPUA_Target_FIFO_Write_Count_i( FIFO_Short_Count_B ),
	.CPUA_Target_Transfer_Done_o( FIFO_Transfer_Done_B ),
	.CPUA_Target_CPU_CMD_Input_i( CPU_CMD_B ),
// Channel 1 - Read Only 32Bits Access
	.BitMap_Target_Enable_i( Counter_Enable_BM_B ),
	.BitMap_Target_Load_i( Counter_Load_BM_B ),
	.BitMap_Target_Addy_Start_i( BitMap_Target_Addy_Start_B ),
	.BitMap_Target_Addy_Stop_i( BitMap_Target_Addy_Stop_B ),
// Channel 2 - Read Only 32Bits Access
	.TileMap_Target_Enable_i( 1'b0 ),
	.TileMap_Target_Load_i( 1'b0 ),
	.TileMap_Target_Addy_Start_i( 20'h0_0000 ),
	.TileMap_Target_Addy_Stop_i( 20'h0_0000 ),
	.TileMap_Target_Dir_i( 1'b1 ),		// Always 1
// Channel 3 - Read Only 32Bits Access
	.Sprite_Target_Enable_i( 1'b0 ),
	.Sprite_Target_Load_i( 1'b0 ),
	.Sprite_Target_Addy_Start_i( 20'h0_0000 ),
	.Sprite_Target_Addy_Stop_i( 20'h0_0000 ),
	.Sprite_Target_Dir_i( 1'b1 ),		// Always 1
	
// Data Output
	.DataInputChannel0_o(  ),		// CPU
	.DataInputChannel1_o( VRAM_Data_2_BITMAP_B ),		// BITMAP
	.DataInputChannel2_o(  ),		// TILEMAP
	.DataInputChannel3_o(  ),		// SPRITE
//	.DataInputChannel4_o( VRAM_Data_2_VDMA_32bits_Mode ),		// VDMA
	.Data_Output_Valid_o( Data_Output_Valid_B ),	
// VDMA	
	.VDMA_Src_Addy_Start_i( VDMA_Src_Addy_Start ),	// Byte Oriented
	.VDMA_Src_Addy_Stop_i( VDMA_Src_Addy_Stop ),		// Byte Oriented
	.VDMA_Src_Addy_Load_i( VDMA_Src_Addy_Load ),
	.VDMA_Src_Addy_Enable_i( VDMA_Src_Addy_Enable ),
	.VDMA_Src_Count_Reached_o(  ),

	.VDMA_Dst_Addy_Start_i( VDMA_Dst_Addy_Start ),	// Byte Oriented
	.VDMA_Dst_Addy_Stop_i( VDMA_Dst_Addy_Stop ),		// Byte Oriented
	.VDMA_Dst_Addy_Load_i( VDMA_Dst_Addy_Load ),
	.VDMA_Dst_Addy_Enable_i( VDMA_Dst_Addy_Enable ),
	.VDMA_Dst_Count_Reached_o(  ),
	
	.VDMA_Transaction_RW_i( VDMA_Transaction_RW ),
	.VDMA_Transaction_Data_i( VDMA_Data_From_VDMA_Ctrl ),		// Byte Input
	.VDMA_Transaction_Data_o(  ),		// Byte Output
// V(DRAM) Interface A
// Video RAM Bank A
	.VRAM_DQ_io( VRAM_B_DQ_io ),
	.VRAM_BEn_o( VRAM_B_BEn_o ),
	.VRAM_Addy_o( VRAM_B_Addy_o ),
	.VRAM_OEn_o( VRAM_B_OEn_o ),
	.VRAM_WEn_o( VRAM_B_WEn_o ),

	.Debug_i(  )
);


assign VDMA_Src_Addy_Start = 20'h00_0000;
assign VDMA_Src_Addy_Stop = 20'h00_0000;
assign VDMA_Src_Addy_Load = 1'b0;
assign VDMA_Src_Addy_Enable = 1'b0;

assign VDMA_Dst_Addy_Start = 20'h00_0000;
assign VDMA_Dst_Addy_Stop = 20'h00_0000;
assign VDMA_Dst_Addy_Enable = 1'b0;
assign VDMA_Dst_Addy_Load = 1'b0;

assign VDMA_Transaction_RW = 1'b0;
assign VDMA_Data_From_VDMA_Ctrl = 8'h00;

wire	[21:0] 	VDMA_Src_Addy_Start;
wire	[21:0] 	VDMA_Src_Addy_Stop;
wire	[21:0] 	VDMA_Dst_Addy_Start;
wire	[21:0] 	VDMA_Dst_Addy_Stop;

wire	VDMA_Src_Addy_Load;
wire	VDMA_Src_Addy_Enable;
wire	VDMA_Src_Count_Reached;

wire	VDMA_Dst_Addy_Load;
wire	VDMA_Dst_Addy_Enable;
wire	VDMA_Dst_Count_Reached;

wire	VDMA_Transaction_RW;

wire	[7:0]		VDMA_Data_From_VDMA_Ctrl;
wire 	[7:0]	 	VDMA_Data_To_VDMA_Ctrl;
/*
C256Foenix_VDMA_Controller	VDMA_Master_Controller(

	.Reset_i					( Reset_i ),	// System Reset
	.Reset_100Mhz_i( Reset_100Mhz_i ),	
	.Bus_Clk_i				( Bus_Clk_i ),	// This is to Sync Bus Req and Bus Ack
	.EngineClk100Mhz_i	( EngineClk100Mhz_A_i ),	// Main Clock to Drive the Local Memory and VideoMemory

	.Bus_A_i					( Bus_A_i ),
	.Bus_RW_i				( Bus_RW_i ),
	.Bus_RDY_i				( Bus_RDY_i ),
	.Bus_RDY_o				( VDMA_Bus_RDY_o ),
	.Bus_D_i					( Bus_D_i ),
	.Bus_D_o					( DataOut_VDMA_o ),
	.CS_VDMA_Controller_i ( CS_VDMA_Controller_i ),
	// Register Level that have been Synched with 100Mhz Clock already
	.VDMA_Interrupt_o		( VDMA_Interrupt_o ),
// 14Mhz Interface Clock Domain
// Input FIFO Interface from the VDMA Controller	
	.FIFO_Input_Channel_o( FIFO_Input_Channel_o ),
	.FIFO_Input_Read_i( FIFO_Input_Read_i ),
	.FIFO_Input_Count_o( FIFO_Input_Count_o ),	
	.FIFO_Input_Empty_o( FIFO_Input_Empty_o ),
// 14Mhz Interface Clock Domain
// Output FIFO Interface to  the VDMA Controller
	.FIFO_Output_Clear_i( FIFO_Output_Clear_i ),
	.FIFO_Output_Channel_i( FIFO_Output_Channel_i ), 
	.FIFO_Output_Write_i( FIFO_Output_Write_i ),
	.FIFO_Output_Count_o( FIFO_Output_Count_o ),
	.FIFO_OUtput_Full_o( FIFO_OUtput_Full_o ),
// VDMA Channel
	.VDMA_Src_Addy_Start_o( VDMA_Src_Addy_Start ),
	.VDMA_Src_Addy_Stop_o( VDMA_Src_Addy_Stop ),
	.VDMA_Src_Addy_Load_o( VDMA_Src_Addy_Load ),
	.VDMA_Src_Addy_Enable_o( VDMA_Src_Addy_Enable ),
	.VDMA_Src_Count_Reached_i( VDMA_Src_Count_Reached ),

	.VDMA_Dst_Addy_Start_o( VDMA_Dst_Addy_Start ),	// Byte Oriented
	.VDMA_Dst_Addy_Stop_o( VDMA_Dst_Addy_Stop ),		// Byte Oriented
	.VDMA_Dst_Addy_Load_o( VDMA_Dst_Addy_Load ),
	.VDMA_Dst_Addy_Enable_o( VDMA_Dst_Addy_Enable ),
	.VDMA_Dst_Count_Reached_i( VDMA_Dst_Count_Reached ),
	
	.VDMA_Transaction_RW_o( VDMA_Transaction_RW ),
	.VDMA_Transaction_Data_o( VDMA_Data_From_VDMA_Ctrl ),		// Byte Input
	.VDMA_Transaction_Data_i( VDMA_Data_To_VDMA_Ctrl ),		// Byte Input

// Status with the Main VGE State Machine
	.VDMA_Transfer_In_Progress_o( VDMA_Transfer_In_Progress_i ),
	.VDMA_Transfer_Time_Available_i( VDMA_Transfer_Time_Available_o )
);
*/

always @ (posedge EngineClk100Mhz_A_i) begin
	if (VideoModeReset_100Mhz_i | Reset_100Mhz_i) begin
		VGE_Engine_SOF_SYNC <= 3'b000;
	end
	else begin
		VGE_Engine_SOF_SYNC[0] <= SOF_i;
		VGE_Engine_SOF_SYNC[1] <= VGE_Engine_SOF_SYNC[0];
		if ( VGE_Engine_SOF_SYNC[1] == VGE_Engine_SOF_SYNC[0] ) begin
				VGE_Engine_SOF_SYNC[2] <= VGE_Engine_SOF_SYNC[1];
		end
	end
end


localparam		IDLE					= 5'b0_0000,		// Wait for Start of Frame
					WAIT_4_LINE			= 5'b0_0001,		// Now that everything has been Primed, let's wait for Line 27
					VBLANKING_TIME		= 5'b0_0011,  
					BITMAP_PROCESS0 	= 5'b0_0010,  
					BITMAP_PROCESS1 	= 5'b0_0110,  
					BITMAP_PROCESS2 	= 5'b0_0111,  
					BITMAP_PROCESS3 	= 5'b0_0101,  
					TILE_PROCESS0		= 5'b0_0100,  
					TILE_PROCESS1		= 5'b0_1100,  
					TILE_PROCESS2		= 5'b0_1101,  
					TILE_PROCESS3		= 5'b0_1111,  
					SPRITE_PROCESS0	= 5'b0_1110,  
					SPRITE_PROCESS1	= 5'b0_1010,  
					SPRITE_PROCESS2	= 5'b0_1011,  
					SPRITE_PROCESS3	= 5'b0_1001,  
					INCREMENT_LINE		= 5'b0_1000,  
					END 					= 5'b1_1000,  
					CPU_ACCESS0			= 5'b1_1001,  
					CPU_ACCESS1			= 5'b1_1011,  
					CPU_ACCESS2			= 5'b1_1010,  
					CPU_ACCESS3			= 5'b1_1110,  
					CPU_ACCESS4			= 5'b1_1111,  
					VDMA_ACCESS0		= 5'b1_1101,
					VDMA_ACCESS1		= 5'b1_1100,  
					VDMA_ACCESS2		= 5'b1_0100,  
					VDMA_ACCESS3		= 5'b1_0101,				
					VDMA_ACCESS4		= 5'b1_0111,  
					VDMA_ACCESS5		= 5'b1_0110;  


// To be Adjusted if the State Machine Changes in each loop
localparam		BM_TRF_DONE			= 4'b0111,
					TL_TRF_DONE			= 5'b10000,
					SP_TRF_DONE			= 4'b1111;
					

reg[1:0]		Time_Rd_Wr_Access_100Mhz_EDGE;
reg[2:0]		VGE_VBlanking_ReSYNC;
		
always @ (posedge EngineClk100Mhz_A_i) begin
	Time_Rd_Wr_Access_100Mhz_EDGE[0] <= Time_Rd_Wr_Access_100Mhz_i;		// We want the Falling Edge
	Time_Rd_Wr_Access_100Mhz_EDGE[1] <= Time_Rd_Wr_Access_100Mhz_EDGE[0];
	VGE_VBlanking_ReSYNC[0] <= !VGE_VBlanking_i;		// Negated VGE_VBlanking_i
	VGE_VBlanking_ReSYNC[1] <= VGE_VBlanking_ReSYNC[0];
	if (VGE_VBlanking_ReSYNC[1] == VGE_VBlanking_ReSYNC[0]) begin
		VGE_VBlanking_ReSYNC[2] <= VGE_VBlanking_ReSYNC[1];
	end
end					
					
/*
//VICKY II Debug
wire 	[71:0]		CS;
wire					Trigger_In;

//assign Trigger_In = Txf_Done;
//assign Trigger_In = CS_Txt_Background_Plt | CS_Txt_Foreground_Plt;
assign Trigger_In = Time_Rd_Only_Access_100Mhz_i & Mstr_Ctrl_Bitmap_Enable_i;


assign CS[11:00] 	= Horizontal_Line_Count;
assign CS[16:12]  = VGE_Master_Engine_SM;
assign CS[17]		= VideoModeReset_i;
assign CS[18]     = VideoRst_i;
assign CS[19]		= Bitmap_Effect_On;
assign CS[20]		= VDMA_Transfer_In_Progress_i;
assign CS[23:21]	= EffectChannel;
assign CS[24]		= Time_Rd_Only_Access_100Mhz_i;
assign CS[25]		= VGE_Engine_Disable_VideoProcessing_i;
assign CS[26]		= VGE_VBlanking_ReSYNC[1];
assign CS[27]		= Trig_Effect;
assign CS[28] 		= Mstr_Ctrl_Bitmap_Enable_i;
assign CS[30:29] 	= VGE_Engine_SOF_SYNC;
//assign CS[31:28]	= VGE_VidMem_Writen_o;
//assign CS[63:32] 	= VGE_VidMem_Data_i;
assign CS[67:64]  = VGE_Bitmap_Engine_SM;


ChipScope u0 (
	.acq_data_in    (CS),    //        tap.acq_data_in
	.acq_trigger_in (Trigger_In), //           .acq_trigger_in
	.acq_clk        (EngineClk100Mhz_A_i),        //    acq_clk.clk
	.trigger_in     (Trigger_In)      // trigger_in.trigger_in
);
*/
// The LineClockTick ought not to go higher then 3200. the 31.777us (640x480), 26.4us (800x600)
// So 3177 for Mode 0
// &  2640 for Mode 1
// This is to compute the time remaining to do DMA Transfer
////////////////////////////////////////////////////
////
//// GRAPHIC ENGINE MASTER STATE MACHINE
////
////////////////////////////////////////////////////
always @ (posedge EngineClk100Mhz_A_i) begin
	if (VideoModeReset_100Mhz_i | Reset_100Mhz_i) begin
			VGE_Master_Engine_SM		<= IDLE;
			EffectChannel        	<= 3'b000; 	// By Default the CPU and DMA have access... Till they don't
			Bitmap_Effect_On			<= 1'b0;
			TileMap_Effect_On			<= 1'b0;
			Sprite_Effect_On			<= 1'b0;
	end
	else begin
	
		Trigger_Effect <= Trigger_Effect << 1'b1;
		
		case( VGE_Master_Engine_SM )

		// This Triggers @ Top of Frame.
		IDLE: begin //1
			if (!VGE_Engine_Disable_VideoProcessing_i) begin //2
				VDMA_Transfer_Time_Available_o 	<= 1'b0;
				if (VGE_Engine_SOF_SYNC[2:1] == 2'b01)  
				begin //3		// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.
					//Horizontal_Line_Count 				<= 12'b0000_0000_0000;
					VGE_Master_Engine_SM 				<= VBLANKING_TIME;
				end //2
				else 
				begin //3		
					EffectChannel   						<= 3'b000; 	// By Default, Keep the Mux For CPU/DMA Access
					if ((CPU_CMD_A_Rd_Empty == 1'b0) || (CPU_CMD_B_Rd_Empty == 1'b0)) begin //4
						//CPU_CMD_Read	<= 1'b1;
						VGE_Master_Engine_SM <= CPU_ACCESS0;
						VGE_Master_Engine_SM_SM <= IDLE;
					end //3
					else 
						VGE_Master_Engine_SM <= IDLE;
				end
			end //2	// End of Positive Disable Video
			else begin //3
			
				if (VDMA_Transfer_In_Progress_i) begin	//4			// Lots of fail safe so the VDMA doesn't go back when it comes back of doing its thing, it needs to wait for the next line to complete the work.
					EffectChannel   						<= 3'b100; 	// Set to VDMA
					VDMA_Transfer_Time_Available_o 	<= 1'b1;
				end //3
				else 
				begin //4		
					EffectChannel   						<= 3'b000; 	// By Default, Keep the Mux For CPU/DMA Access
					VDMA_Transfer_Time_Available_o 	<= 1'b0;
					if ((CPU_CMD_A_Rd_Empty == 1'b0) || (CPU_CMD_B_Rd_Empty == 1'b0)) begin
						//CPU_CMD_Read	<= 1'b1;
						VGE_Master_Engine_SM <= CPU_ACCESS0;
						VGE_Master_Engine_SM_SM <= IDLE;
					end //4
					else begin //3
						VGE_Master_Engine_SM 			<= IDLE;
					end //2
				end	
			end //1
		end //1
		
		// VDMA Transaction Happens here:

		VBLANKING_TIME: begin
			if ( VGE_VBlanking_ReSYNC[2] ) begin	// Negative SPace (VGE_BLANKING = 1 1 Line Prior before the Official Video Blanking)
				if (VDMA_Transfer_In_Progress_i) begin				// Lots of fail safe so the VDMA doesn't go back when it comes back of doing its thing, it needs to wait for the next line to complete the work.
					EffectChannel   						<= 3'b100; 	// Set to VDMA		
					VDMA_Transfer_Time_Available_o 	<= 1'b1;
				end
				else begin
					EffectChannel   						<= 3'b000; 	// By Default, Keep the Mux For CPU/DMA Access				
					VDMA_Transfer_Time_Available_o 	<= 1'b0;
					if ((CPU_CMD_A_Rd_Empty == 1'b0) || (CPU_CMD_B_Rd_Empty == 1'b0)) begin
						//CPU_CMD_Read	<= 1'b1;
						VGE_Master_Engine_SM <= CPU_ACCESS0;
						VGE_Master_Engine_SM_SM <= VBLANKING_TIME;
					end
					else begin
						VGE_Master_Engine_SM 			<= VBLANKING_TIME;
					end
				end
			end
			else begin
				VDMA_Transfer_Time_Available_o 	<= 1'b0;
				VGE_Master_Engine_SM 				<= VDMA_ACCESS0;			
			end
		end

		// We come here for Every Begining of Line
		// Check which module is enabled and bypass right away, no point to go in the process if it is not enabled.
		WAIT_4_LINE: begin
			if (Time_Rd_Only_Access_100Mhz_i )	// Begin the Line 28 (Blanking) + 59 Lines
			begin	
				// Let's Begin with BitMap
				if (Mstr_Ctrl_Bitmap_Enable_i) begin		// Check to see if the BitMap Layer is enabled.
					VGE_Master_Engine_SM 	<= BITMAP_PROCESS0;
					Bitmap_Effect_On			<= 1'b1;
					EffectChannel   			<= 3'b001; 	// Alright Set the First Process to BitMap.
				end
				else begin
					if (Mstr_Ctrl_TileMap_Enable_i) begin		// Check to see if the TileMap Layer is enabled.
						VGE_Master_Engine_SM 	<= TILE_PROCESS0;
						TileMap_Effect_On			<= 1'b1;
						EffectChannel   			<= 3'b010; 	// Alright Set the First Process to BitMap.	
					end
					else begin
						if (Mstr_Ctrl_Sprite_Enable_i) begin		// Check to see if the Sprite Layer is enabled.
							VGE_Master_Engine_SM 	<= SPRITE_PROCESS0;
							Sprite_Effect_On			<= 1'b1;
							EffectChannel   			<= 3'b011; 	// Alright Set the First Process to BitMap.
						end
						else begin
							VGE_Master_Engine_SM 	<= INCREMENT_LINE;
						end
					end
				end
			end
			else begin
				EffectChannel   			<= 3'b000; 	// By Default, Keep the Mux For CPU/DMA Access
				if ( Time_Rd_Wr_Access_100Mhz_i ) begin
					if ((CPU_CMD_A_Rd_Empty == 1'b0) || (CPU_CMD_B_Rd_Empty == 1'b0)) begin
						//CPU_CMD_Read	<= 1'b1;
						VGE_Master_Engine_SM <= CPU_ACCESS0;
						VGE_Master_Engine_SM_SM <= WAIT_4_LINE;						
					end
				end
				else begin
					VGE_Master_Engine_SM <= WAIT_4_LINE;
					end
				end
		end

		// Wait for the Bitmap Process to Finish
		BITMAP_PROCESS0: 
		begin
				VGE_Master_Engine_SM 	<= BITMAP_PROCESS1;
				Trigger_Effect	<= 4'hf;	// Fire up the process
		end
		
		BITMAP_PROCESS1: 
		begin
				VGE_Master_Engine_SM 	<= BITMAP_PROCESS2;		
		end
		
		BITMAP_PROCESS2: 
		begin
			if (((VGE_Bitmap_Engine_SM_A == BM_TRF_DONE) & BitmapChannel_A_Enable) || ((VGE_Bitmap_Engine_SM_B == BM_TRF_DONE) & BitmapChannel_B_Enable))  begin
			//if (VGE_Bitmap_Engine_SM_A == BM_TRF_DONE) begin
				VGE_Master_Engine_SM 	<= BITMAP_PROCESS3;
				Bitmap_Effect_On 			<=	1'b0;		// Turn off Effect, so it can go batch to recharge for next frame
			end
			else
				VGE_Master_Engine_SM 	<= BITMAP_PROCESS2;				
		end
		
		BITMAP_PROCESS3: 
		begin
				if (Mstr_Ctrl_TileMap_Enable_i) begin		// Check to see if the BitMap Layer is enabled.
					VGE_Master_Engine_SM 	<= TILE_PROCESS0;
					TileMap_Effect_On			<= 1'b1;
					EffectChannel   			<= 3'b010; 	// Alright Set the First Process to BitMap.
				end
				else begin
					if (Mstr_Ctrl_Sprite_Enable_i) begin		// Check to see if the BitMap Layer is enabled.
						VGE_Master_Engine_SM 	<= SPRITE_PROCESS0;
						Sprite_Effect_On			<= 1'b1;
						EffectChannel   			<= 3'b011; 	// Alright Set the First Process to BitMap.
					end
					else begin
						VGE_Master_Engine_SM 	<= INCREMENT_LINE;						
					end				
				end
		end
		
		// Wait for the Tile Process to Finish		
		TILE_PROCESS0:
		begin
				VGE_Master_Engine_SM 	<= TILE_PROCESS1;
				Trigger_Effect	<= 4'hf;	// Fire up the process				
		end
		
		TILE_PROCESS1:
		begin
				VGE_Master_Engine_SM 	<= TILE_PROCESS2;
		end
		
		TILE_PROCESS2: 
		begin 
			if ( VGE_Tile_Engine_SM ) begin	// WHen it gets to 1, it is the state machine being Done.
				TileMap_Effect_On			<= 1'b0;		// Turn off Effect, so it can go batch to recharge for next frame			
				VGE_Master_Engine_SM 	<= TILE_PROCESS3;
			end
			else
				VGE_Master_Engine_SM 	<= TILE_PROCESS2;
		end
		
		TILE_PROCESS3: 
		begin
			if (Mstr_Ctrl_Sprite_Enable_i) begin		// Check to see if the BitMap Layer is enabled.
				VGE_Master_Engine_SM 	<= SPRITE_PROCESS0;
				Sprite_Effect_On			<= 1'b1;
				EffectChannel   			<=3'b011; 	// Alright Set the First Process to BitMap.
			end
			else
				VGE_Master_Engine_SM 	<= INCREMENT_LINE;						

		end
		
		// Wait for the Sprite Process to Finish
		SPRITE_PROCESS0: 
		begin
			VGE_Master_Engine_SM 	<= SPRITE_PROCESS1;
			Trigger_Effect	<= 4'hf;	// Fire up the process			
		end

		SPRITE_PROCESS1: 
		begin
			VGE_Master_Engine_SM 	<= SPRITE_PROCESS2;	
		end
		
		SPRITE_PROCESS2: 
		begin 
			if (VGE_Sprite_Engine_SM == SP_TRF_DONE) begin
				Sprite_Effect_On			<= 1'b0;		// Turn off Effect, so it can go batch to recharge for next frame			
				VGE_Master_Engine_SM 	<= SPRITE_PROCESS3;
			end
			else
				VGE_Master_Engine_SM 	<= SPRITE_PROCESS2;	
		end
		
		SPRITE_PROCESS3: 
		begin
			VGE_Master_Engine_SM 	<= INCREMENT_LINE;		
		end
		
		INCREMENT_LINE:
		begin
			if (Horizontal_Line_Count < VisibleLine100Mhz[2][11:0]) begin
				//Horizontal_Line_Count	<= Horizontal_Line_Count + 12'b0000_0000_0001;
				VGE_Master_Engine_SM		<= WAIT_4_LINE;
				//EffectChannel				<= 3'b000;
			end
			else begin
				Bitmap_Effect_On 			<=	1'b0;		// Turn off Effect, so it can go batch to recharge for next frame
				TileMap_Effect_On			<= 1'b0;		// Turn off Effect, so it can go batch to recharge for next frame
				Sprite_Effect_On			<= 1'b0;		// Turn off Effect, so it can go batch to recharge for next frame					
				VGE_Master_Engine_SM		<= END;			
			end		
		end
		
		// This the trigger Point for Each Effect to Return to their Normal State (after an entire frame)
		END:
		begin
				VGE_Master_Engine_SM		<= IDLE;				
		end

		// The CPU Direct Access will be Done here, Byte per Byte
		// 
		CPU_ACCESS0: begin 
			//CPU_CMD_Read <= 1'b0;				
			VGE_Master_Engine_SM <= CPU_ACCESS1;		
		end
		
		// Latency (Read Latency From FIFO Command)
		// Load Address
		CPU_ACCESS1: begin 
			VGE_Master_Engine_SM <= CPU_ACCESS2;
		end
		// Enable Counter Here
		// Data from Fifo is available here
		CPU_ACCESS2: begin 
			VGE_Master_Engine_SM <= CPU_ACCESS3;
		end
		
		CPU_ACCESS3: begin 
			if ( FIFO_Transfer_Done_A || FIFO_Transfer_Done_B )
				VGE_Master_Engine_SM <= CPU_ACCESS3;
			else
				VGE_Master_Engine_SM <= VGE_Master_Engine_SM_SM;			
		end
		
//		CPU_ACCESS4: begin
//			VGE_Master_Engine_SM <= WAIT_4_LINE;			
		//end

		
		// Stick here, till the time to transfer time runs out.
		// 17
		VDMA_ACCESS0: begin
			VGE_Master_Engine_SM <= VDMA_ACCESS1;	
		end

		// 18
		VDMA_ACCESS1: begin
			VGE_Master_Engine_SM <= VDMA_ACCESS2;	
		end

		// 19
		VDMA_ACCESS2: begin
			VGE_Master_Engine_SM <= VDMA_ACCESS3;			
		end
	
		VDMA_ACCESS3: begin
			VGE_Master_Engine_SM <= VDMA_ACCESS4;	
		end
		
		VDMA_ACCESS4: begin
			EffectChannel				<= 3'b000;		
			VGE_Master_Engine_SM <= WAIT_4_LINE;		
		end

	
		default: begin
				VGE_Master_Engine_SM		<= IDLE;				
		end
		endcase
	end
end


always @ (posedge EngineClk100Mhz_A_i) begin
	if (VideoModeReset_100Mhz_i | Reset_100Mhz_i) begin
			Horizontal_Line_Count 				<= 12'b0000_0000_0000;
		end
		else begin
			case( VGE_Master_Engine_SM )
			
			IDLE: begin //1
				if (VGE_Engine_SOF_SYNC[2:1] == 2'b01)  
				begin //3		// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.
					Horizontal_Line_Count 				<= 12'b0000_0000_0000;
				end
			end
			
			
			INCREMENT_LINE:
			begin
				if (Horizontal_Line_Count < VisibleLine100Mhz[2][11:0]) begin
					Horizontal_Line_Count	<= Horizontal_Line_Count + 12'b0000_0000_0001;
				end
			end
				
			endcase
		end
end


/*
always @ (posedge EngineClk100Mhz_A_i) begin
	if (VideoModeReset_100Mhz_i | Reset_100Mhz_i) begin

		end
		else begin
			case( VGE_Master_Engine_SM )
			
			endcase
		end
end

*/
//Visible_Line_Per_Line_Value_i
reg[11:0]	VisibleLine100Mhz[2:0];

always @ (posedge EngineClk100Mhz_A_i) begin
	VisibleLine100Mhz[0][11:0] <= Visible_Line_Per_Line_Value_i;
	VisibleLine100Mhz[1][11:0] <= VisibleLine100Mhz[0][11:0];
	if (VisibleLine100Mhz[0][11:0] == VisibleLine100Mhz[1][11:0])
		VisibleLine100Mhz[2][11:0] <= VisibleLine100Mhz[1][11:0];
end



reg [9:0]	TileMap0_Y_Window_Pos_SOF;
reg [9:0]	TileMap1_Y_Window_Pos_SOF;
reg [9:0]	TileMap2_Y_Window_Pos_SOF;
reg [9:0]	TileMap3_Y_Window_Pos_SOF;

always @ (posedge EngineClk100Mhz_A_i) begin
	if (VGE_Engine_SOF_SYNC[2:1] == 2'b01) begin
			TileMap0_Y_Window_Pos_SOF <= TileMap0_Y_Window_Pos_i;
			TileMap1_Y_Window_Pos_SOF <= TileMap1_Y_Window_Pos_i;
			TileMap2_Y_Window_Pos_SOF <= TileMap2_Y_Window_Pos_i;
			TileMap3_Y_Window_Pos_SOF <= TileMap3_Y_Window_Pos_i;
	end
end



reg [9:0]	BM_Line_Sizes;
//reg [9:0]	BM_Packet_Number;

always @ (*)
begin
	case ({Mstr_Ctrl_Doubling_Pixel_100Mhz_i, Mstr_Ctrl_Video_Mode100Mhz_i[1:0]})
	3'b0_00: BM_Line_Sizes = 10'd704;	// 32+640+32
	3'b0_01: BM_Line_Sizes = 10'd704;	// 32+640+32
	3'b0_10: BM_Line_Sizes = 10'd864;	// 32+800+32
	3'b0_11: BM_Line_Sizes = 10'd864;	// 32+800+32
	3'b1_00: BM_Line_Sizes = 10'd384;	// 32+320+32
	3'b1_01: BM_Line_Sizes = 10'd384;	// 32+320+32
	3'b1_10: BM_Line_Sizes = 10'd464;	// 32+400+32
	3'b1_11: BM_Line_Sizes = 10'd464;	// 32+400+32
	default: BM_Line_Sizes = 10'd704;
	endcase
end

BitMap_State_Machine BM_SM_VRAM_A (
	.EngineClk100Mhz_i( EngineClk100Mhz_B_i ),
	.EngineClk200Mhz_i( EngineClk200Mhz_i ),
	.VGE_Engine_Rst_i(VideoModeReset_100Mhz_i | Reset_100Mhz_i),

	.Clear_Bit_Line_i( Time_Erase_Pixels_Line_100Mhz_i ),		// Trigger
	.Mstr_Ctrl_Video_Mode100Mhz_i( Mstr_Ctrl_Video_Mode100Mhz_i ), 
	
	.Mstr_Ctrl_Doubling_Pixel_i( Mstr_Ctrl_Doubling_Pixel_i ),
	.Mstr_Ctrl_Doubling_Pixel_100Mhz_i( Mstr_Ctrl_Doubling_Pixel_100Mhz_i ), 
	
	.Bitmap_Effect_On_i( Bitmap_Effect_On ),
	.Horizontal_Line_Count_i( Horizontal_Line_Count ),
	.Trig_BM_Read_Memory_i( Trig_Effect ),
// Register Input to Enable each 
	.BM0_Layer_Enable_i( BM0_Layer_Enable_i ),
	.BM1_Layer_Enable_i( BM1_Layer_Enable_i ),
	.COL_Layer_Enable_i( COL_Layer_Enable_i ),
// Register Input on where the Data is in VICKY's memory Space
	.BM0_MapAddy_i( BM0_MapAddy_i ),
	.BM1_MapAddy_i( BM1_MapAddy_i ),
	.COL_MapAddy_i( COL_MapAddy_i ),

// From VMemory Interface Block
// Inputs
	.VRAM_Data_Valid_i( Data_Output_Valid_A ),
	.VRAM_Data_2_BITMAP_i( VRAM_Data_2_BITMAP_A ),
	.Counter_Reached_Count_i( Counter_Reached_Count_A ),
// Outputs
	.Counter_Enable_BM_o( Counter_Enable_BM_A ),
	.Counter_Load_BM_o( Counter_Load_BM_A ),
	.BitMap_Target_Addy_Start_o( BitMap_Target_Addy_Start_A ),
	.BitMap_Target_Addy_Stop_o( BitMap_Target_Addy_Stop_A ),

// Collision/Mixer Signals
	.Read_Pixel_Lines_i( Read_Pixel_Lines ),
	// Pixel Data Out
	.Collision_Data_o( Line6_Collision_Out ),
	.BitMap0_Pixel_o( Line0_Pixel_Out ),
	.BitMap1_Pixel_o( Line5_Pixel_Out ),
	// Collision Data Out
	.Collision_Data_Col_o( Collision_Data_Col ),
	.BitMap0_Pixel_Col_o( BitMap0_Pixel_Col ),
	.BitMap1_Pixel_Col_o( BitMap1_Pixel_Col ),	
	
	.VGE_Bitmap_Engine_SM_o( VGE_Bitmap_Engine_SM_A )
);


BitMap_State_Machine BM_SM_VRAM_B (
	.EngineClk100Mhz_i( EngineClk100Mhz_B_i ),
	.EngineClk200Mhz_i( EngineClk200Mhz_i ),
	.VGE_Engine_Rst_i(VideoModeReset_100Mhz_i | Reset_100Mhz_i),

	.Clear_Bit_Line_i( Time_Erase_Pixels_Line_100Mhz_i ),		// Trigger
	.Mstr_Ctrl_Video_Mode100Mhz_i( Mstr_Ctrl_Video_Mode100Mhz_i ), 
	
	.Mstr_Ctrl_Doubling_Pixel_i( Mstr_Ctrl_Doubling_Pixel_i ),
	.Mstr_Ctrl_Doubling_Pixel_100Mhz_i( Mstr_Ctrl_Doubling_Pixel_100Mhz_i ), 
	
	.Bitmap_Effect_On_i( Bitmap_Effect_On ),
	.Horizontal_Line_Count_i( Horizontal_Line_Count ),
	.Trig_BM_Read_Memory_i( Trig_Effect ),
// Register Input to Enable each 
	.BM0_Layer_Enable_i( BM3_Layer_Enable_i ),
	.BM1_Layer_Enable_i( 1'b0 ),
	.COL_Layer_Enable_i( 1'b0 ),
// Register Input on where the Data is in VICKY's memory Space
	.BM0_MapAddy_i( BM3_MapAddy_i ),
	.BM1_MapAddy_i( 22'h00_0000 ),
	.COL_MapAddy_i( 22'h00_0000 ),

// From VMemory Interface Block
// Inputs
	.VRAM_Data_Valid_i( Data_Output_Valid_B ),
	.VRAM_Data_2_BITMAP_i( VRAM_Data_2_BITMAP_B ),
	.Counter_Reached_Count_i( Counter_Reached_Count_B ),
// Outputs
	.Counter_Enable_BM_o( Counter_Enable_BM_B ),
	.Counter_Load_BM_o( Counter_Load_BM_B ),
	.BitMap_Target_Addy_Start_o( BitMap_Target_Addy_Start_B ),
	.BitMap_Target_Addy_Stop_o( BitMap_Target_Addy_Stop_B ),

// Collision/Mixer Signals
	.Read_Pixel_Lines_i( Read_Pixel_Lines ),
	// Pixel Data Out
	.Collision_Data_o(  ),
	.BitMap0_Pixel_o( Line8_Pixel_Out ),
	.BitMap1_Pixel_o(  ),
	// Collision Data Out
	.Collision_Data_Col_o(  ),
	.BitMap0_Pixel_Col_o(  ),
	.BitMap1_Pixel_Col_o(  ),	
	
	.VGE_Bitmap_Engine_SM_o( VGE_Bitmap_Engine_SM_B )
);



wire [7:0] Collision_Data_Col;
wire [7:0] BitMap0_Pixel_Col;
wire [7:0] BitMap1_Pixel_Col;

TileMap_State_Machine TILE_SM(
	.EngineClk100Mhz_i( EngineClk100Mhz_B_i ),
	.Reset_100Mhz_i( Reset_100Mhz_i ),
	.VGE_Engine_Rst_i( VideoModeReset_100Mhz_i ),
	.Clear_Bit_Line_i( Time_Erase_Pixels_Line_100Mhz_i ),		// Trigger
	
	.Mstr_Ctrl_Video_Mode100Mhz_i( Mstr_Ctrl_Video_Mode100Mhz_i ), 
	.Mstr_Ctrl_Doubling_Pixel_100Mhz_i( Mstr_Ctrl_Doubling_Pixel_100Mhz_i ), 	
	
	.TileMap_Effect_On_i( TileMap_Effect_On ),
	.Time_2_Charge_TileMap_Lines_i( Time_2_Charge_TileMap_Lines_i ),		// THis is the Strobe that tells the State Machine to go fetch the line Info
	.Horizontal_Line_Count_i( Horizontal_Line_Count ),
	.Trig_TL_Read_Memory_i( Trig_Effect ),
	.SOF_i( VGE_Engine_SOF_SYNC[1:0] ),							// Start of Frame - To Update Internal Register before a new Process begin
// TileMap Registers Information
// TileMaps
// Layer0
	.TileMap0Addy_i( TileMap0_Addy_i ),
	.TileMap0_X_TotalSize_i( TileMap0_X_TotalSize_i ),		// Size of the Square of the whole Map Max 1024 Position (54)
	.TileMap0_Y_TotalSize_i( TileMap0_Y_TotalSize_i ),		// Size of the Square of the whole Map Max 1024 Position
	.TileMap0_X_Window_Pos_i( TileMap0_X_Window_Pos_i ),	// X Offset in the Map
	.TileMap0_Y_Window_Pos_i( TileMap0_Y_Window_Pos_SOF ),	// Y Offset in the

// Layer1
	.TileMap1Addy_i( TileMap1_Addy_i ),
	.TileMap1_X_TotalSize_i( TileMap1_X_TotalSize_i ),	// Size of the Square of the whole Map Max 1024 Position (54)
	.TileMap1_Y_TotalSize_i( TileMap1_Y_TotalSize_i ),	// Size of the Square of the whole Map Max 1024 Position
	.TileMap1_X_Window_Pos_i( TileMap1_X_Window_Pos_i ),	// X Offset in the Map
	.TileMap1_Y_Window_Pos_i( TileMap1_Y_Window_Pos_SOF ),	// Y Offset in the

// Layer2
	.TileMap2Addy_i( TileMap2_Addy_i ),
	.TileMap2_X_TotalSize_i( TileMap2_X_TotalSize_i ),	// Size of the Square of the whole Map Max 1024 Position (54)
	.TileMap2_Y_TotalSize_i( TileMap2_Y_TotalSize_i ),	// Size of the Square of the whole Map Max 1024 Position
	.TileMap2_X_Window_Pos_i( TileMap2_X_Window_Pos_i ),	// X Offset in the Map
	.TileMap2_Y_Window_Pos_i( TileMap2_Y_Window_Pos_SOF ),	// Y Offset in the

// Layer2
	.TileMap3Addy_i( TileMap3_Addy_i ),
	.TileMap3_X_TotalSize_i( TileMap3_X_TotalSize_i ),	// Size of the Square of the whole Map Max 1024 Position (54)
	.TileMap3_Y_TotalSize_i( TileMap3_Y_TotalSize_i ),	// Size of the Square of the whole Map Max 1024 Position
	.TileMap3_X_Window_Pos_i( TileMap3_X_Window_Pos_i ),	// X Offset in the Map
	.TileMap3_Y_Window_Pos_i( TileMap3_Y_Window_Pos_SOF ),	// Y Offset in the

// TileSets
	.Tile0_Layer_Control_Reg_i( TileMap0_Control_Reg_i ),
	.Tile1_Layer_Control_Reg_i( TileMap1_Control_Reg_i ),
	.Tile2_Layer_Control_Reg_i( TileMap2_Control_Reg_i ),
	.Tile3_Layer_Control_Reg_i( TileMap3_Control_Reg_i ),

	.Tile0_X_Scroll_Reg_i( TileMap0_X_Scroll_i ),	// Tile Layer 0 -- [4] = 0 - Right	, 1 - Left, [3:0] Position 0 to 15
	.Tile0_Y_Scroll_Reg_i( TileMap0_Y_Scroll_i ),	// Tile Layer 0 -- [4] = 0 - Up		, 1 - Down, [3:0] Position 0 to 15
	.Tile1_X_Scroll_Reg_i( TileMap1_X_Scroll_i ),	// Tile Layer 1 -- [4] = 0 - Right	, 1 - Left, [3:0] Position 0 to 15
	.Tile1_Y_Scroll_Reg_i( TileMap1_Y_Scroll_i ),	// Tile Layer 1 -- [4] = 0 - Up		, 1 - Down, [3:0] Position 0 to 15
	.Tile2_X_Scroll_Reg_i( TileMap2_X_Scroll_i ),	// Tile Layer 2 -- [4] = 0 - Right	, 1 - Left, [3:0] Position 0 to 15
	.Tile2_Y_Scroll_Reg_i( TileMap2_Y_Scroll_i ),	// Tile Layer 2 -- [4] = 0 - Up		, 1 - Down, [3:0] Position 0 to 15
	.Tile3_X_Scroll_Reg_i( TileMap3_X_Scroll_i ),	// Tile Layer 3 -- [4] = 0 - Right	, 1 - Left, [3:0] Position 0 to 15
	.Tile3_Y_Scroll_Reg_i( TileMap3_Y_Scroll_i ),	// Tile Layer 3 -- [4] = 0 - Up		, 1 - Down, [3:0] Position 0 to 15

	.TileSet0Addy_i( TileSet0Addy_i ),
	.TileSet1Addy_i( TileSet1Addy_i ),
	.TileSet2Addy_i( TileSet2Addy_i ),
	.TileSet3Addy_i( TileSet3Addy_i ),
	.TileSet4Addy_i( TileSet4Addy_i ),
	.TileSet5Addy_i( TileSet5Addy_i ),
	.TileSet6Addy_i( TileSet6Addy_i ),
	.TileSet7Addy_i( TileSet7Addy_i ),
	
	.TileSet0Cfg_i( TileSet0_CFG_i ),
	.TileSet1Cfg_i( TileSet1_CFG_i ),
	.TileSet2Cfg_i( TileSet2_CFG_i ),
	.TileSet3Cfg_i( TileSet3_CFG_i ),
	.TileSet4Cfg_i( TileSet4_CFG_i ),
	.TileSet5Cfg_i( TileSet5_CFG_i ),
	.TileSet6Cfg_i( TileSet6_CFG_i ),
	.TileSet7Cfg_i( TileSet7_CFG_i ),

	// Data Output from the Address Generator
	.VRAM_Data_Valid_i( Data_Output_Valid_A ),
	.VRAM_Data_2_TILEMAP_i( VRAM_Data_2_TILEMAP ),
	.Counter_Reached_Count_i( Counter_Reached_Count_A ),
	// Address Setup for the 
	.Counter_Enable_TM_o( Counter_Enable_TM ),
	.Counter_Load_TM_o( Counter_Load_TM ),
	.TileMap_Target_Addy_Start_o( TileMap_Target_Addy_Start ),
	.TileMap_Target_Addy_Stop_o( TileMap_Target_Addy_Stop ),
	
	.VGE_EffectChannel_TL_ADDY_o( VGE_EffectChannel_TL_ADDY ),
	.VGE_Engine_TL0_WE_o( VGE_Engine_TL0_WE ),
	.VGE_Engine_TL1_WE_o( VGE_Engine_TL1_WE ),
	.VGE_Engine_TL2_WE_o( VGE_Engine_TL2_WE ),
	.VGE_Engine_TL3_WE_o( VGE_Engine_TL3_WE ),	
	
	.Tile_Data_o( Tile_Data ),	
	.Tile_Attribute_o( Tile_Attribute ),
	
	.TileL0Collision_On_o( TileL0Collision_On ),
	.TileL1Collision_On_o( TileL1Collision_On ),
	.TileL2Collision_On_o( TileL2Collision_On ),
	.TileL3Collision_On_o( TileL3Collision_On ),
	
	.VGE_TileMap_SM_o(  ),
	.VGE_Tile_Engine_SM_o( VGE_Tile_Engine_SM )
);


wire TileL0Collision_On;
wire TileL1Collision_On;
wire TileL2Collision_On;
wire TileL3Collision_On;


wire	[7:0]		Tile_Attribute;
wire [31:0]		Tile_Data;
wire	[7:0]		VGE_EffectChannel_TL_ADDY;
wire				VGE_Engine_TL0_WE;
wire				VGE_Engine_TL1_WE;
wire				VGE_Engine_TL2_WE;
wire				VGE_Engine_TL3_WE;

/*
wire	[7:0]		SpriteLine_Pixel0_Out;
wire	[7:0]		SpriteLine_Pixel1_Out;
wire	[7:0]		SpriteLine_Pixel2_Out;
wire	[7:0]		SpriteLine_Pixel3_Out;
wire	[7:0]		SpriteLine_Pixel4_Out;
wire	[7:0]		SpriteLine_Pixel5_Out;
wire	[7:0]		SpriteLine_Pixel6_Out;
wire	[7:0]		SpriteLine_Attributes0_Out;
wire	[7:0]		SpriteLine_Attributes1_Out;
wire	[7:0]		SpriteLine_Attributes2_Out;
wire	[7:0]		SpriteLine_Attributes3_Out;
wire	[7:0]		SpriteLine_Attributes4_Out;
wire	[7:0]		SpriteLine_Attributes5_Out;
wire	[7:0]		SpriteLine_Attributes6_Out;
*/
/*
assign Tile_Data = 32'h0000_0000;
assign VGE_EffectChannel_TL_ADDY = 8'h00;
assign VGE_Engine_TL0_WE = 1'b0;
assign VGE_Engine_TL1_WE = 1'b0;
assign VGE_Engine_TL2_WE = 1'b0;
assign VGE_Engine_TL3_WE = 1'b0;
assign VGE_Tile_Engine_SM = 5'b0_0000;
*/

//assign VGE_Tile_Addy = 21'h00_0000;
//assign VGE_Tile_Readn = 1'b1;
//assign Line1_Pixel_Out = 8'h00;
//assign Line2_Pixel_Out = 8'h00;
//assign Line3_Pixel_Out = 8'h00;
//assign Line4_Pixel_Out = 8'h00;
//assign VGE_Tile_Engine_SM = 5'b00000;

Sprite_State_Machine SPRITE_SM(
	.Reset_100Mhz_i( Reset_100Mhz_i ),
	.Reset_200Mhz_i( Reset_200Mhz_i ),
	.EngineClk100Mhz_i( EngineClk100Mhz_B_i ),
	.EngineClk200Mhz_i( EngineClk200Mhz_i ),
	.VGE_Engine_Rst_i( VideoModeReset_100Mhz_i),

	.Clear_Bit_Line_i( Time_Erase_Pixels_Line_200Mhz_i ),		// Trigger
	
	.Mstr_Ctrl_Video_Mode100Mhz_i( Mstr_Ctrl_Video_Mode100Mhz_i ),
	.Mstr_Ctrl_Doubling_Pixel_100Mhz_i( Mstr_Ctrl_Doubling_Pixel_100Mhz_i ), 
	
	.Sprite_Effect_On_i( Sprite_Effect_On ),
	.Time_2_Charge_TileMap_Lines_i( Time_2_Charge_TileMap_Lines_i ),		// THis is the Strobe that tells the State Machine to go fetch the line Info

	.Horizontal_Line_Count_i( Horizontal_Line_Count ),
	
	.Trig_SP_Read_Memory_i( Trig_Effect ),
	.SOF_i( VGE_Engine_SOF_SYNC[1:0] ),
// Register Block
	.Sprite_Active_Channel_o( Sprite_Active_Channel_o ),				// Channel to Read
	.Sprite_OutputSpriteMem_i( Sprite_OutputSpriteMem_i ),

// From VMemory Interface Block
// Inputs
	.VRAM_Data_Valid_i( Data_Output_Valid_A ),
	.VRAM_Data_2_SPRITE_i( VRAM_Data_2_SPRITE ),
	.Counter_Reached_Count_i( Counter_Reached_Count_A ),
// Outputs
	.Counter_Enable_SP_o( Counter_Enable_SP ),
	.Counter_Load_SP_o( Counter_Load_SP ),
	.Sprite_Target_Addy_Start_o( Sprite_Target_Addy_Start ),
	.Sprite_Target_Addy_Stop_o( Sprite_Target_Addy_Stop ),

	.Read_Pixel_Lines_i( Read_Pixel_Lines ),
	
	.Attributes_Data_o( SpriteLine_Attributes_Out ),
	.Sprite_Data_o( SpriteLine_Pixel_Out ),
	.Attributes_Data_Col_o( Attributes_Data_Col ),
	.Sprite_Data_Col_o( Sprite_Data_Col ),	
	
	.VGE_Sprite_Engine_SM_o( VGE_Sprite_Engine_SM )
);

wire  [7:0] 	Sprite_Data_Col;
wire 	[15:0] 	Attributes_Data_Col;
wire	[7:0]		SpriteLine_Pixel_Out;
wire	[15:0]	SpriteLine_Attributes_Out;

wire BM0_Collision_On;
wire BM1_Collision_On;
//////////////////////////////////////////
/////////////
///////////// Converge all Pixel Data from the Different Layers
/////////////
//////////////////////////////////////////
VGE_Pixel_Priority_Collision_Encoder VGE_Serializer(
// Resets
	.Reset_i( Reset_i ),
	.Reset_100Mhz_i( Reset_100Mhz_i ),
	.Reset_200Mhz_i( Reset_200Mhz_i ),
	.Reset_VideoClkOut_i( Reset_VideoClkOut_i ),
	.Reset_VideoClk_Full_Resolution_i( Reset_VideoClk_Full_Resolution_i ),	
// Resets when the mode changes
	.VideoModeReset_i( VideoModeReset_i ),
	.VideoModeReset_100Mhz_i( VideoModeReset_100Mhz_i ),
	.VideoModeReset_200Mhz_i( VideoModeReset_200Mhz_i ),

// Clocks
	.Bus_Clk_i( Bus_Clk_i ),
	.VideoClk_i( VideoClk_i ),
	.VideoClock_Full_Resolution_i( VideoClock_Full_Resolution_i ),
	.Mstr_Ctrl_Video_Mode100Mhz_i( Mstr_Ctrl_Video_Mode100Mhz_i ),
	.Mstr_Ctrl_Doubling_Pixel_100Mhz_i( Mstr_Ctrl_Doubling_Pixel_100Mhz_i ), 
	.EngineClk100Mhz_i( EngineClk100Mhz_B_i ),
	.EngineClk200Mhz_i( EngineClk200Mhz_i ),
	.EngineClk200Mhz_Aux_i( EngineClk200Mhz_Aux_i ),
// Video Signals
	.SOF_i( SOF_i ),
	.Vsync_i( Vsync_i ),
	.VBlanking_i( VBlanking_i ),
	.HBlanking_i( HBlanking_i ),
	.HBlanking_VGE_Lat_i( HBlanking_VGE_Lat_i ),
	
// 
	.Time_Trf_Pixels_2_Pixel_200Mhz_i(Time_Trf_Pixels_2_Pixel_200Mhz_i),
	.Time_2_Display_Line_VidClk_i( Time_2_Display_Line_VideoClk_i ),

	.BM_Line_Sizes_i( BM_Line_Sizes ),

// Input Data Line
	.SpriteLine_Pixel_Out_i( SpriteLine_Pixel_Out ),
	.SpriteLine_Attributes_Out_i( SpriteLine_Attributes_Out ),	// Collision is now included

	.Sprite_Data_Col_i( Sprite_Data_Col ),		
	.Attributes_Data_Col_i( Attributes_Data_Col ),
	
	.Line0_Pixel_Out_i( Line0_Pixel_Out ),	// BM0
	.Line5_Pixel_Out_i( Line5_Pixel_Out ), // BM1
	.Line6_Pixel_Out_i( Line6_Collision_Out ), // COL
	
	.Line8_Pixel_Out_i( Line8_Pixel_Out ), 
	
	.Collision_Data_Col_i( Collision_Data_Col ),
	.BitMap0_Pixel_Col_i( BitMap0_Pixel_Col ),
	.BitMap1_Pixel_Col_i( BitMap1_Pixel_Col ),	

	.BM0_Layer_Lut_i( BM0_Layer_Lut_i ),
	.BM0_Collision_On_i( BM0_Collision_On_i ), 
	.BM1_Layer_Lut_i( BM1_Layer_Lut_i ),
	.BM1_Collision_On_i( BM1_Collision_On_i ),
	.BM1_Coll_Map_Display_En_i( BM1_Coll_Map_Display_En_i ), 
	.COL_Collision_On_i( COL_Collision_On_i),
	
	.BM3_Layer_Lut_i( BM3_Layer_Lut_i ),
	.BM3_Collision_On_i( BM3_Collision_On_i ), 	
	
	.TileL0Collision_On_i( TileL0Collision_On ),
	.TileL1Collision_On_i( TileL1Collision_On ),
	.TileL2Collision_On_i( TileL2Collision_On ),
	.TileL3Collision_On_i( TileL3Collision_On ),	
	
// Collision Status
	.Collision_SpriteL0_o( Collision_SpriteL0_o ),
	.Collision_SpriteL1_o( Collision_SpriteL1_o ),
	.Collision_SpriteL2_o( Collision_SpriteL2_o ),
	.Collision_SpriteL3_o( Collision_SpriteL3_o ),
	.Collision_SpriteL4_o( Collision_SpriteL4_o ),
	.Collision_SpriteL5_o( Collision_SpriteL5_o ),
	.Collision_SpriteL6_o( Collision_SpriteL6_o ),

	.Collision_BM0_o( Collision_BM0_o ),
	.Collision_BM1_o( Collision_BM1_o ),
	.Collision_COL_o( Collision_COL_o ),

	.Collision_TL0_o( Collision_TL0_o ),
	.Collision_TL1_o( Collision_TL1_o ),
	.Collision_TL2_o( Collision_TL2_o ),
	.Collision_TL3_o( Collision_TL3_o ),

// Let the user have the Pixel Information when a Collision Happens
	.Sprite_Collision_Pixel_o( Sprite_Collision_Pixel_o ),
	.Sprite_Collision_Channel_o( Sprite_Collision_Channel_o ),
	
	.Bitmap_L0_Collision_Pixel_o( Bitmap_L0_Collision_Pixel_o ),
	.Bitmap_L1_Collision_Pixel_o( Bitmap_L1_Collision_Pixel_o ),
	.Bitmap_C0_Collision_Pixel_o( Bitmap_C0_Collision_Pixel_o ),
	.Tilemap_L0_Collision_Pixel_o( Tilemap_L0_Collision_Pixel_o ),
	.Tilemap_L1_Collision_Pixel_o( Tilemap_L1_Collision_Pixel_o ),
	.Tilemap_L2_Collision_Pixel_o( Tilemap_L2_Collision_Pixel_o ),
	.Tilemap_L3_Collision_Pixel_o( Tilemap_L3_Collision_Pixel_o ),
//
	.Collision_VideoLine_Active_i( {3'b000, Horizontal_Line_Count} ), 
	.Collision_Sprite_X_Location_o( Collision_Sprite_X_Location_o ),
	.Collision_Bitmap_X_Location_o( Collision_Bitmap_X_Location_o ),
	.Collision_Tiles_X_Location_o( Collision_Tiles_X_Location_o ),	
	.Collision_Y_Location_o( Collision_Y_Location_o ),	
	
// TileMap Pipe
	.VGE_EffectChannel_TL_ADDY_i( VGE_EffectChannel_TL_ADDY ),
	.VGE_Engine_TL0_WE_i( VGE_Engine_TL0_WE ),
	.VGE_Engine_TL1_WE_i( VGE_Engine_TL1_WE ),
	.VGE_Engine_TL2_WE_i( VGE_Engine_TL2_WE ),
	.VGE_Engine_TL3_WE_i( VGE_Engine_TL3_WE ),
	.Tile_Data_i( Tile_Data ),
	.Tile_Attribute_i( Tile_Attribute ), 

	.Tile0_X_Scroll_Reg_i( TileMap0_X_Scroll_i ),
	.Tile1_X_Scroll_Reg_i( TileMap1_X_Scroll_i ),
	.Tile2_X_Scroll_Reg_i( TileMap2_X_Scroll_i ),
	.Tile3_X_Scroll_Reg_i( TileMap3_X_Scroll_i ),
	
	.TileMap0_LUT_i( TileMap0_Control_Reg_i[3:1] ),
	.TileMap1_LUT_i( TileMap1_Control_Reg_i[3:1] ),
	.TileMap2_LUT_i( TileMap2_Control_Reg_i[3:1] ),
	.TileMap3_LUT_i( TileMap3_Control_Reg_i[3:1] ),
	
// Line DP Pointer Read
	.Read_Pixel_Lines_o( Read_Pixel_Lines ),

// Video Output Interface and Background
	.Background_Blue_i( Background_Blue_i ),
	.Background_Green_i( Background_Green_i ),
	.Background_Red_i( Background_Red_i ),

	.VGE_RGB_Pixel_o( VGE_RGB_Pixel_o ),

// CPU Interface
	.Bus_A_i( Bus_A_i ),
	.Bus_RW_i( Bus_RW_i ),
	.Bus_BE_i( Bus_BE_i ),
	.Bus_WE_i( Bus_WE_i ), 
	.Bus_D8_i( Bus_D8_i ),
	.Bus_D16_i( Bus_D16_i ),
	.Bus_D32_i( Bus_D32_i ),
	.Bus_D_Siz_i( Bus_D_Siz_i ),
	.CS_LUT0_i( CS_LUT0_i ),
	.DataOut_LUT_o( DataOut_LUT_o ),
	
	.Sprite_Collision_Interrupt_o( Sprite_Collision_Interrupt_o ),
	.Bitmap_Collision_Interrupt_o( Bitmap_Collision_Interrupt_o ),
	.Tilemap_Collision_Interrupt_o( Tilemap_Collision_Interrupt_o )
);

/*
wire [95:0] ChipScope;
wire			Trigger;
//assign Trigger = VGE_Command_Write & (VGE_Command[21:0] == Sources[85:64]);

//assign Trigger = VRAM_READ_i & (CMD_TSF_ADDY == 21'h00_5800);
//assign Trigger = (VGE_Engine_SOP_SYNC[2:1] == 2'b01); //3 + 11 + 5

//assign Trigger = (VGE_Master_Engine_SM ==  BITMAP_PROCESS2) & (Horizontal_Line_Count == Debug_LineNumberInput_i[11:0]);
//assign Trigger = Time_Rd_Only_Access_100Mhz_i;
assign Trigger = CPU_Access_CMD_Rd_Empty_i;

assign ChipScope[31:0] = VGE_VidMem_Data_i;
assign ChipScope[63:32] = VGE_VidMem_Data_o;
assign ChipScope[83:64] = VGE_Addy_o;
assign ChipScope[84] = VGE_VidMem_Readn_o;
assign ChipScope[88:85] = VGE_VidMem_Writen_o;
assign ChipScope[93:89] = VGE_Master_Engine_SM;
assign ChipScope[94] = 	CPU_CMD_Read;
assign ChipScope[95] =  CPU_Access_CMD_Rd_Empty_i;

//assign ChipScope[95:64] = State_Machine;

ChipScope	ChipScope_inst (
	.acq_clk ( EngineClk100Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);
*/
/*
output	reg	[19:0]	VGE_Addy_o,	// 1Mx32
input		wire	[31:0]	VGE_VidMem_Data_i,
output	wire	[31:0]	VGE_VidMem_Data_o,
output	reg				VGE_VidMem_Readn_o,
output   reg	[3:0]		VGE_VidMem_Writen_o,
*/


endmodule
// Trash LAND
/* 
		//0x10 - WRITEMEM2FIFO
		READ_VRAM_ST1: begin
			Pixel32Write <= 1'b1;
			if ( CMD_TSF_SIZE ) begin
				CMD_TSF_SIZE <= CMD_TSF_SIZE - 8'h01;
				State_Machine <= READ_VRAM_ST4;
			end
			else begin
				VRAM_READ_i <= 1'b1;	// We are done;
				State_Machine <= READ_VRAM_ST3;				
				end
			end
			
			//the Write in the FIFO takes place here.
			//0x11 - WRITEMEM2FIFO_0
		READ_VRAM_ST2: begin
			Pixel32Write <= 1'b1;
			if ( CMD_TSF_SIZE == 8'h01 )  begin
				VRAM_READ_i <= 1'b1;	// We are done;
				State_Machine <= READ_VRAM_ST3;
			end
			else begin
				CMD_TSF_SIZE <= CMD_TSF_SIZE - 8'h01;
				State_Machine <= READ_VRAM_ST4;				
			end	
		end
		
			//0x12 - WRITEMEM2FIFO_1
		READ_VRAM_ST3: begin
			Pixel32Write <= 1'b0;							
			State_Machine <= State_State_Machine;
		end
			
		//0x13 - WRITEMEM2FIFO_2
		READ_VRAM_ST4: begin
			Pixel32Write <= 1'b0;				
			if ( CMD_TSF_SIZE )  begin
				State_Machine <= READ_VRAM_ST2;
			end
			else begin
					VRAM_READ_i <= 1'b1;	// We are done;
					State_Machine <= READ_VRAM_ST3;				
				end
			end
			
		// 1 Delay for Read_i
		READ_VRAM_ST5: begin
			State_Machine <= READ_VRAM_ST1;
		end
		
		END_PROCESS: begin
				State_Machine <= IDLE;	// Go Through Each Sprite Entry and begin Fetching the Data if needs be				
		end
		
		default: begin
				State_Machine <= IDLE;		
		end
	
*/

/*
always @ (*)
begin
	case ( EffectChannel[2:0] )
		3'b000: VGE_Addy_o = CPU_CMD[21:2];
		3'b001: VGE_Addy_o = (BM_Absolute_Addy[21:2] + Pixel2FetchCounter_BM);
		3'b010: VGE_Addy_o = VGE_Tile_Addy[21:2];		// Tile Map Information
		3'b011: VGE_Addy_o = (SP_Absolute_Addy[21:2] + Pixel2FetchCounter_SP);
		3'b100: VGE_Addy_o = VDMA_VRAM_Addy_Out_i;
		3'b101: VGE_Addy_o = VDMA_VRAM_Addy_Out_i;	// VDMA Addy
		3'b110: VGE_Addy_o =	VDMA_VRAM_Addy_Out_i;   // VDMA Addy
		3'b111: VGE_Addy_o = VDMA_VRAM_Addy_Out_i;	// VDMA Addy
	endcase
end
*/
/*

always @ (*)
begin
	case ( EffectChannel[2:0] )
		3'b000: VGE_Addy_o = CPU_ACCESS_ADDY;
		3'b001: VGE_Addy_o = BM_BLOCK_ADDY;
		3'b010: VGE_Addy_o = TILE_BLOCK_ADDY;		// Tile Map Information
		3'b011: VGE_Addy_o = SPRITE_BLOCK_ADDY;
		3'b100: VGE_Addy_o = VDMA_BLOCK_ADDY;
		3'b101: VGE_Addy_o = VDMA_BLOCK_ADDY;	// VDMA Addy
		3'b110: VGE_Addy_o =	VDMA_BLOCK_ADDY;   // VDMA Addy
		3'b111: VGE_Addy_o = VDMA_BLOCK_ADDY;	// VDMA Addy
	endcase
end

always @ (*)
begin
	case ( EffectChannel[2:0] )
		3'b000: VGE_VidMem_Readn_o = 1'b1;				// No CPU Read
		3'b001: VGE_VidMem_Readn_o = BitMap_Read_Strobe_n;
		3'b010: VGE_VidMem_Readn_o = VGE_Tile_Readn;			// MAP Data
		3'b011: VGE_VidMem_Readn_o = Sprite_Read_Strobe_n;		// Tile Data
		3'b100: VGE_VidMem_Readn_o = VDMA_VRAM_Data_Read_i;		// Sprite Read Enable
		3'b101: VGE_VidMem_Readn_o = VDMA_VRAM_Data_Read_i;	// VDMA Read Enable Strobe
		3'b110: VGE_VidMem_Readn_o = VDMA_VRAM_Data_Read_i;	// VDMA Read Enable Strobe
		3'b111: VGE_VidMem_Readn_o = VDMA_VRAM_Data_Read_i;	// VDMA Read Enable Strobe
	endcase
end

always @ (*)
begin
	case ( EffectChannel[2:0] )
		3'b000: VGE_VidMem_Writen_o = MemoryWrite;				// CPU Access
		3'b001: VGE_VidMem_Writen_o = 4'b1111;	// Bitmap
		3'b010: VGE_VidMem_Writen_o = 4'b1111;	// Tile Map 
		3'b011: VGE_VidMem_Writen_o = 4'b1111;	// Tile Data
		3'b100: VGE_VidMem_Writen_o = VDMA_VRAM_Data_Writen_i; // VDMA Write Enable Strobe
		3'b101: VGE_VidMem_Writen_o = VDMA_VRAM_Data_Writen_i; // VDMA Write Enable Strobe 
		3'b110: VGE_VidMem_Writen_o = VDMA_VRAM_Data_Writen_i; // VDMA Write Enable Strobe
		3'b111: VGE_VidMem_Writen_o = VDMA_VRAM_Data_Writen_i; // VDMA Write Enable Strobe
	endcase
end

always @ (*)
begin
	case ( EffectChannel[2:0] )
		3'b000: VGE_VidMem_Data_o = {MemoryWriteByte, MemoryWriteByte, MemoryWriteByte, MemoryWriteByte};				// CPU Access
		3'b001: VGE_VidMem_Data_o = 32'h0000_0000;
		3'b010: VGE_VidMem_Data_o = 32'h0000_0000;
		3'b011: VGE_VidMem_Data_o = 32'h0000_0000;
		3'b100: VGE_VidMem_Data_o = VDMA_VRAM_Data_Out_i; // VDMA Data Write
		3'b101: VGE_VidMem_Data_o = VDMA_VRAM_Data_Out_i; // VDMA Data Write
		3'b110: VGE_VidMem_Data_o = VDMA_VRAM_Data_Out_i; // VDMA Data Write
		3'b111: VGE_VidMem_Data_o = VDMA_VRAM_Data_Out_i; // VDMA Data Write
	endcase
end
*/
/*
always @ (posedge EngineClk100Mhz_i) begin
	if (Reset_i) begin
		CPU_ACCESS_ADDY 				<= 20'h0_0000;
		BM_BLOCK_ADDY 					<= 20'h0_0000;
		TILE_BLOCK_ADDY 				<= 20'h0_0000;
		SPRITE_BLOCK_ADDY 			<= 20'h0_0000;
		MemoryWrite_Dly				<= 4'b1111;
		VDMA_VRAM_Data_Writen_Dly 	<= 4'b1111;
		CPU_DATA_OUT_Dly  			<= 32'h0000_0000;
		VDMA_DATA_OUT_Dly 			<= 32'h0000_0000;
		BitMap_Read_Strobe_n_Dly 	<= BitMap_Read_Strobe_n;
		VGE_Tile_Readn_Dly 			<= VGE_Tile_Readn;
		Sprite_Read_Strobe_n_Dly 	<= Sprite_Read_Strobe_n;
		VDMA_VRAM_Data_Read_i_Dly 	<= VDMA_VRAM_Data_Read_i;
	end
	else begin
		CPU_ACCESS_ADDY 	<= CPU_CMD[21:2];
		BM_BLOCK_ADDY 		<= (BM_Absolute_Addy[21:2] + Pixel2FetchCounter_BM);
		TILE_BLOCK_ADDY 	<= VGE_Tile_Addy[21:2];
		SPRITE_BLOCK_ADDY <= (SP_Absolute_Addy[21:2] + Pixel2FetchCounter_SP);
		VDMA_BLOCK_ADDY	<= VDMA_VRAM_Addy_Out_i;
		MemoryWrite_Dly	<= MemoryWrite;
		VDMA_VRAM_Data_Writen_Dly <= VDMA_VRAM_Data_Writen_i;
		CPU_DATA_OUT_Dly  <= {MemoryWriteByte, MemoryWriteByte, MemoryWriteByte, MemoryWriteByte};
		VDMA_DATA_OUT_Dly <=	VDMA_VRAM_Data_Out_i;
	end
end

always @ (*)
begin
	case ( EffectChannel[2:0] )
		3'b000: VGE_Addy_o = CPU_ACCESS_ADDY;
		3'b001: VGE_Addy_o = BM_BLOCK_ADDY;
		3'b010: VGE_Addy_o = TILE_BLOCK_ADDY;		// Tile Map Information
		3'b011: VGE_Addy_o = SPRITE_BLOCK_ADDY;
		3'b100: VGE_Addy_o = VDMA_BLOCK_ADDY;
		3'b101: VGE_Addy_o = VDMA_BLOCK_ADDY;	// VDMA Addy
		3'b110: VGE_Addy_o =	VDMA_BLOCK_ADDY;   // VDMA Addy
		3'b111: VGE_Addy_o = VDMA_BLOCK_ADDY;	// VDMA Addy
	endcase
end

always @ (*)
begin
	case ( EffectChannel[2:0] )
		3'b000: VGE_VidMem_Readn_o = 1'b1;				// No CPU Read
		3'b001: VGE_VidMem_Readn_o = BitMap_Read_Strobe_n_Dly;
		3'b010: VGE_VidMem_Readn_o = VGE_Tile_Readn_Dly;			// MAP Data
		3'b011: VGE_VidMem_Readn_o = Sprite_Read_Strobe_n_Dly;		// Tile Data
		3'b100: VGE_VidMem_Readn_o = VDMA_VRAM_Data_Read_i_Dly;		// Sprite Read Enable
		3'b101: VGE_VidMem_Readn_o = VDMA_VRAM_Data_Read_i_Dly;	// VDMA Read Enable Strobe
		3'b110: VGE_VidMem_Readn_o = VDMA_VRAM_Data_Read_i_Dly;	// VDMA Read Enable Strobe
		3'b111: VGE_VidMem_Readn_o = VDMA_VRAM_Data_Read_i_Dly;	// VDMA Read Enable Strobe
	endcase
end

always @ (*)
begin
	case ( EffectChannel[2:0] )
		3'b000: VGE_VidMem_Writen_o = MemoryWrite_Dly;				// CPU Access
		3'b001: VGE_VidMem_Writen_o = 4'b1111;	// Bitmap
		3'b010: VGE_VidMem_Writen_o = 4'b1111;	// Tile Map 
		3'b011: VGE_VidMem_Writen_o = 4'b1111;	// Tile Data
		3'b100: VGE_VidMem_Writen_o = VDMA_VRAM_Data_Writen_Dly; // VDMA Write Enable Strobe
		3'b101: VGE_VidMem_Writen_o = VDMA_VRAM_Data_Writen_Dly; // VDMA Write Enable Strobe 
		3'b110: VGE_VidMem_Writen_o = VDMA_VRAM_Data_Writen_Dly; // VDMA Write Enable Strobe
		3'b111: VGE_VidMem_Writen_o = VDMA_VRAM_Data_Writen_Dly; // VDMA Write Enable Strobe
	endcase
end

always @ (*)
begin
	case ( EffectChannel[2:0] )
		3'b000: VGE_VidMem_Data_o = CPU_DATA_OUT_Dly;				// CPU Access
		3'b001: VGE_VidMem_Data_o = 32'h0000_0000;
		3'b010: VGE_VidMem_Data_o = 32'h0000_0000;
		3'b011: VGE_VidMem_Data_o = 32'h0000_0000;
		3'b100: VGE_VidMem_Data_o = VDMA_DATA_OUT_Dly; // VDMA Data Write
		3'b101: VGE_VidMem_Data_o = VDMA_DATA_OUT_Dly; // VDMA Data Write
		3'b110: VGE_VidMem_Data_o = VDMA_DATA_OUT_Dly; // VDMA Data Write
		3'b111: VGE_VidMem_Data_o = VDMA_DATA_OUT_Dly; // VDMA Data Write
	endcase
end
*/


/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

assign TinyTrigger1 = CS_VIDEO_RAM_B0_i;

assign TinyTP1[23:0]  	= Bus_A_i;
assign TinyTP1[39:24] 	= Bus_D_i;
assign TinyTP1[43:40] 	= ByteEnable;
assign TinyTP1[44]		= ( ({ Transaction_Slip[0], CS_VIDEO_RAM_B0_i} == 2'b01) & ( Bus_BE_i[1] | Bus_BE_i[0]) & !Bus_RW_i);
assign TinyTP1[6]			= VClock_Slct_SYNCn_o;
assign TinyTP1[9:7] 		= bitcount;
assign TinyTP1[12:10]	= VidClkSM;
assign TinyTP1[23:16]   = Actual_Value;
assign TinyTP1[31:24]   = { Channel_A, Channel_B };

TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (Bus_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/