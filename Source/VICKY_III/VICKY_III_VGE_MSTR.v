`timescale 1ns/1ns
// February 2026 Changes
module VICKY_III_VGE_MSTR(

// Resets
input		wire				Reset_100Mhz,
input		wire				Reset_200Mhz,
input		wire				Reset_VideoClkOut,
input		wire				Reset_VideoClk_Full_Resolution,
input		wire				Reset_i,						//Reset
//input		wire				VideoRst_i,
input		wire				VideoModeReset_i,				// Video Freq
input		wire				VideoModeReset_100Mhz_i,		//
input		wire				VideoModeReset_200Mhz_i,
// Clocks
input		wire				Bus_Clk_i,
input   	wire				OSC_CLK_25_175Mhz_i,
input		wire				VideoClock_108Mhz_i,		// Always Full Mode, 25.175Mhz or 40Mhz VideoClock_108Mhz_i
input		wire				EngineClk100Mhz_A_i,
input		wire				EngineClk100Mhz_B_i,
input		wire				EngineClk200Mhz_i,
input		wire				EngineClk200Mhz_Aux_i,

input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,				// Many Video Mode Now
input		wire				Mstr_Ctrl_Doubling_Pixel_i,
input		wire				Mstr_Ctrl_Doubling_Pixel_100Mhz_i,
input		wire	[1:0]		Mstr_Ctrl_Video_Mode100Mhz_i,
input		wire				Mstr_Ctrl_Graphic_Mode_Enable_i,
input		wire				Mstr_Ctrl_Bitmap_Enable_i,
input		wire				Mstr_Ctrl_TileMap_Enable_i,
input		wire				Mstr_Ctrl_Sprite_Enable_i,
input		wire				Mstr_Ctrl_Disable_Video_i,
// New Game System
input 		wire 				Mstr_Ctrl_Game_Layer0_Enable_i,
input 		wire 				Mstr_Ctrl_Game_Layer0_Type_i,
input 		wire 				Mstr_Ctrl_Game_Layer1_Enable_i,
input 		wire 				Mstr_Ctrl_Game_Layer1_Type_i,
input 		wire 				Mstr_Ctrl_Game_Layer2_Enable_i,
input 		wire 				Mstr_Ctrl_Game_Layer2_Type_i,
input 		wire 				Mstr_Ctrl_Game_Layer3_Enable_i,
input 		wire 				Mstr_Ctrl_Game_Layer3_Type_i,

input		wire	[4:0]		Mstr_Ctrl_Master_X_Offset_i,		// Defaulted to 31 + 1
input		wire	[4:0]		Mstr_Ctrl_Master_Y_Offset_i,		// Defaulted to 31 + 1
// Video Interface
input		wire	[11:0]		HLineCount_i,
input		wire	[11:0]		HPixelCount_i,
input		wire				SOF_i,
input		wire				Vsync_i,
input		wire				VBlanking_i,	// Normal V Blanking
input		wire				HBlanking_VGE_Lat_i,	// Horizontal Blanking Adjusted for Latency
input		wire				VGE_Engine_VBlanking_2L_i,	// Equivalent to 1L when in 640x480 - this is allow to process line before frame starts
input		wire				VGE_Engine_VBlanking_4L_i,	// Equivalent to 1L when in 320x240
input		wire				HBlanking_i,
input		wire				Horizontal_Border_i,
input		wire				Vertical_Border_i,
input		wire				Horizontal_Precharge_i,
// Sequencer 
input		wire				Time_Rd_Wr_Access_100Mhz_i,		
input		wire				Time_Rd_Only_Access_100Mhz_i,	// 
input		wire				Time_Trf_Pixels_2_Pixel_200Mhz_i,
input		wire				Time_Erase_Pixels_Line_100Mhz_i,
input		wire				Time_Erase_Pixels_Line_200Mhz_i,
input		wire				Time_2_Display_Line_VideoClk_i,
//input		wire	[1:0]		Time_2_Charge_TileMap_Lines_i,

input		wire	[1:0]		Time_2_Charge_TileMap_L0_Lines_i,
input		wire	[1:0]		Time_2_Charge_TileMap_L1_Lines_i,
input		wire	[1:0]		Time_2_Charge_TileMap_L2_Lines_i,
input		wire	[1:0]		Time_2_Charge_TileMap_L3_Lines_i,

input		wire	[11:0]		Total_Pixel_Per_Line_Value_i,
input		wire	[11:0]		Total_Line_Per_Image_Value_i,
input		wire	[11:0]		H_Blanking_Value_i,
input		wire	[11:0]		V_Blanking_Value_i,
input		wire	[11:0]		Visible_Pixel_Per_Line_Value_i,
input		wire	[11:0]		Visible_Line_Per_Line_Value_i,

input		wire	[7:0]		Background_Blue_i,
input		wire	[7:0]		Background_Green_i,
input		wire	[7:0]		Background_Red_i,

output		wire	[31:0]		VGE_RGB_Pixel_o,

// CPU Interface
input		wire	[31:0]		Bus_A_i,
input		wire				Bus_A_Valid_i,
input		wire				Bus_RW_i,
input		wire				Bus_WE_i,
input		wire	[3:0]		Bus_BE_i,
input		wire	[7:0]		Bus_D8_i,
input		wire	[15:0]		Bus_D16_i,
input		wire	[31:0]		Bus_D32_i,
input		wire	[1:0]		Bus_D_Siz_i,
// Chip Selects
input		wire				CS_VMEM_2_CPU_i,
input		wire				CS_Bitmap_Registers_i,
input		wire				CS_Tile0_Registers_i,
input		wire				CS_Tile1_Registers_i,
input		wire				CS_Collisions_Registers_i,
input		wire				CS_Sprites_Registers_i,
input		wire				CS_LUT0_i,
input		wire				CS_VDMA_Controller_i,
// VSRAM Buffer A - VSRAM Buffer B
input		wire				iBUS_CS_VRAM_A_i,
input		wire				iBUS_CS_VRAM_B_i,
output  	wire  	 [31:0]		iBUS_D_VRAM_A_o,
output  	wire  	 [31:0]		iBUS_D_VRAM_B_o,
// VDMA Interrupts
output		wire				VDMA_Interrupt_o,
// Collision Interrupts
output		wire				Sprite_Collision_Interrupt_o,
output		wire				Bitmap_Collision_Interrupt_o,
output		wire				Tilemap_Collision_Interrupt_o,
// Control Signal back to Video Timing Generator
output		wire				TLayer0Mode8_16_o,
output		wire				TLayer1Mode8_16_o,
output		wire				TLayer2Mode8_16_o,
output		wire				TLayer3Mode8_16_o,

// Data Output to be Read Back DataOut_LUT_o
output		wire	[31:0]		DataOut_LUT_o,
output 		wire  	[31:0]		Bus_Tile_Map_o,
output		wire	[31:0]		DataOut_VideoMemory_o,
//output	wire	[15:0]		DataOut_VDMA_o,
output		wire	[31:0]		DataOut_Bitmap_Regs_o,
output		wire	[31:0]		DataOut_Tile0_Regs_o,
output		wire	[31:0]		DataOut_Tile1_Regs_o,
output		wire	[31:0]		DataOut_Collisions_Regs_o,
output		wire	[31:0]		DataOut_Sprites_Regs_o,

// Video RAM Bank A
input		wire	[31:0]		VRAM_A_DQ_i,
output		wire	[31:0]		VRAM_A_DQ_o,
output		wire	[3:0]		VRAM_A_BEn_o,
output		wire	[19:0]		VRAM_A_Addy_o,
output		wire				VRAM_A_OEn_o,
output		wire				VRAM_A_WEn_o,
// Video RAM Bank B
input		wire	[31:0]		VRAM_B_DQ_i,
output		wire	[31:0]		VRAM_B_DQ_o,
output		wire	[3:0]		VRAM_B_BEn_o,	
output		wire	[19:0]		VRAM_B_Addy_o,
output		wire				VRAM_B_OEn_o,
output		wire				VRAM_B_WEn_o,

input 		wire				BANK_SWITCH_i
);

assign iBUS_D_VRAM_A_o = 32'h0000_00000;
assign iBUS_D_VRAM_B_o = 32'h0000_00000;

assign DataOut_VideoMemory_o = 16'h0000;
assign DataOut_Sprites_Regs_o = 16'h55AA;
assign DataOut_Collisions_Regs_o = 16'h8888;

// Wires
wire				BM0_Layer_Enable;
wire	[2:0] 		BM0_LUT;
wire	[23:0]		BM0_START_ADDY;
wire	[4:0]		BM0_X_Offset;
wire	[4:0]		BM0_Y_Offset;
wire	[3:0]		BM0_Priority;

wire				BM1_Layer_Enable;
wire	[2:0]		BM1_LUT;
wire	[23:0]		BM1_START_ADDY;
wire	[4:0]		BM1_X_Offset;
wire	[4:0]		BM1_Y_Offset;
wire	[3:0]		BM1_Priority;


wire				BM3_Layer_Enable;
wire	[2:0]		BM3_LUT;
wire	[23:0]		BM3_START_ADDY;
wire	[4:0]		BM3_X_Offset;
wire	[4:0]		BM3_Y_Offset;
wire	[3:0]		BM3_Priority;
wire				BM3_Collision_On;

wire 				COL_Layer_Enable;
wire 	[23:0] 		COL_MapAddy;
wire				COL_Collision_On;

wire 	[7:0] 		TileMap0_Control_Reg;
wire 	[22:0]		TileMap0_Addy;
wire	[9:0]		TileMap0_X_TotalSize;
wire	[9:0]		TileMap0_Y_TotalSize;
wire	[9:0]		TileMap0_X_Window_Pos;
wire	[9:0]		TileMap0_Y_Window_Pos;
wire	[4:0]		TileMap0_X_Scroll;
wire	[4:0]		TileMap0_Y_Scroll;

wire 	[7:0] 		TileMap1_Control_Reg;
wire 	[22:0]		TileMap1_Addy;
wire	[9:0]		TileMap1_X_TotalSize;
wire	[9:0]		TileMap1_Y_TotalSize;
wire	[9:0]		TileMap1_X_Window_Pos;
wire	[9:0]		TileMap1_Y_Window_Pos;
wire	[4:0]		TileMap1_X_Scroll;
wire	[4:0]		TileMap1_Y_Scroll;

wire 	[7:0] 		TileMap2_Control_Reg;
wire 	[22:0]		TileMap2_Addy;
wire	[9:0]		TileMap2_X_TotalSize;
wire	[9:0]		TileMap2_Y_TotalSize;
wire	[9:0]		TileMap2_X_Window_Pos;
wire	[9:0]		TileMap2_Y_Window_Pos;
wire	[4:0]		TileMap2_X_Scroll;
wire	[4:0]		TileMap2_Y_Scroll;

wire 	[7:0] 		TileMap3_Control_Reg;
wire 	[22:0]		TileMap3_Addy;
wire	[9:0]		TileMap3_X_TotalSize;
wire	[9:0]		TileMap3_Y_TotalSize;
wire	[9:0]		TileMap3_X_Window_Pos;
wire	[9:0]		TileMap3_Y_Window_Pos;
wire	[4:0]		TileMap3_X_Scroll;
wire	[4:0]		TileMap3_Y_Scroll;

wire	[22:0]		TileSet0Addy;
wire	[22:0]		TileSet1Addy;
wire	[22:0]		TileSet2Addy;
wire	[22:0]		TileSet3Addy;
wire	[22:0]		TileSet4Addy;
wire	[22:0]		TileSet5Addy;
wire	[22:0]		TileSet6Addy;
wire	[22:0]		TileSet7Addy;

wire	[3:0]		TileSet0Cfg;
wire	[3:0]		TileSet1Cfg;
wire	[3:0]		TileSet2Cfg;
wire	[3:0]		TileSet3Cfg;
wire	[3:0]		TileSet4Cfg;
wire	[3:0]		TileSet5Cfg;
wire	[3:0]		TileSet6Cfg;
wire	[3:0]		TileSet7Cfg;

wire	[63:0]		OutputSpriteMem;
wire	[5:0]		Sprite_Active_Channel;

// Collision Pixel
wire	[7:0]		Sprite_Collision_Pixel;
wire	[5:0]		Sprite_Collision_Channel;
wire	[7:0]		Bitmap_L0_Collision_Pixel;
wire	[7:0]		Bitmap_L1_Collision_Pixel;
wire	[7:0]		Bitmap_C0_Collision_Pixel;
wire	[7:0]		Tilemap_L0_Collision_Pixel;
wire	[7:0]		Tilemap_L1_Collision_Pixel;
wire	[7:0]		Tilemap_L2_Collision_Pixel;
wire	[7:0]		Tilemap_L3_Collision_Pixel;
//Coordinate of the Collision
wire  	[15:0]		Collision_Sprite_X_Location;
wire	[15:0]		Collision_Bitmap_X_Location;
wire	[15:0]		Collision_Tiles_X_Location;

wire	[15:0]		Collision_Y_Location;
// Bitmap Resolution
//Resolution Coordinates
// 640x480 - TOTAL: X0:000 Y0:000 X1:704 Y1:544 - VISUAL: VX0:032 VY0:032 VX1:672 VY1:512
// 800x600 - TOTAL: X0:000 Y0:000 X1:864 Y1:664 - VISUAL: VX0:032 VY0:032 VX1:832 VY1:632
// 320x240 - TOTAL: X0:000 Y0:000 X1:384 Y1:304 - VISUAL: VX0:032 VY0:032 VX1:352 VY1:272
// 400x300 - TOTAL: X0:000 Y0:000 X1:464 Y1:364 - VISUAL: VX0:032 VY0:032 VX1:432 VY1:332
wire	[11:0]	SX0;	// System Coordinates
wire	[11:0]	SY0;  
reg		[11:0]	SX1;
reg		[11:0]	SY1;
// This is The offseted Coordinate (the one)
wire	[11:0]	VX0;	// Visual Coordinates
wire	[11:0]	VY0;
reg		[11:0]	VX1;
reg		[11:0]	VY1;

assign SX0 = 12'b0000_0000_0000;		//0
assign SY0 = 12'b0000_0000_0000;		//0
assign VX0 = 12'b0000_0010_0000;		//32
assign VY0 = 12'b0000_0010_0000;		//32


assign Bus_Tile_Map_o = 8'h00;
// In 'Game Graphic Mode` the Base resolution is half of the real resolution.
// Mstr_Ctrl_Video_Mode_o[1:0]
// 00: 1280x960
// 01: 1280x1024
// 10: Not Used
// 11: Not Used
// Mstr_Ctrl_Doubling_Pixel_i[0]
// 0: 640x480 / 640x512
// 1: 320x240 / 320x256
always @ (posedge EngineClk100Mhz_A_i)
begin
	case ({ Mstr_Ctrl_Doubling_Pixel_i, Mstr_Ctrl_Video_Mode_i[0] })
		2'b00: begin 
			// 640x480 @60Hz
			SX1 <= 12'd640 + 12'd64; // 640x
			SY1 <= 12'd480 + 12'd64;
			VX1 <= 12'd640 + 12'd32;
			VY1 <= 12'd480 + 12'd32;
		end

		2'b01: begin
			// 640x512 @60hz
			SX1 <= 12'd640 + 12'd64;
			SY1 <= 12'd512 + 12'd64;
			VX1 <= 12'd640 + 12'd32;
			VY1 <= 12'd512 + 12'd32;
		end
	
		// Pixel Doubling Here
		2'b10: begin 
			// 320x240 @60Hz
			SX1 <= 12'd320 + 12'd64;
			SY1 <= 12'd240 + 12'd64;
			VX1 <= 12'd320 + 12'd32;
			VY1 <= 12'd240 + 12'd32;
		end

		2'b10: begin
			// 320x256 @60hz
			SX1 <= 12'd320 + 12'd64;
			SY1 <= 12'd256 + 12'd64;
			VX1 <= 12'd320 + 12'd32;
			VY1 <= 12'd256 + 12'd32;
		end
	endcase
end
	
wire BM0_Collision_On;
wire BM1_Collision_On;
//////////////////////////////
// Register FILES BitMap
//////////////////////////////

BitMapRegisterFile BM_Register_File
(
	.rst_i( Reset_i ),	
	.EngineClk100Mhz_i(EngineClk100Mhz_A_i),
	.EngineClk200Mhz_i(EngineClk200Mhz_i),
// CPU Signals Interface
	.Bus_Clk_i( Bus_Clk_i ),
	.Bus_A_i( Bus_A_i ),
	.Bus_D8_i( Bus_D8_i ),
	.Bus_D16_i( Bus_D16_i ),
	.Bus_D32_i( Bus_D32_i ),
	.Bus_D_Siz_i( Bus_D_Siz_i ),
	.Bus_A_Valid_i( Bus_A_Valid_i ),
	.Bus_WE_i( Bus_WE_i ), 
	
	.Bus_RW_i( Bus_RW_i ),	
	.Bus_BE_i( Bus_BE_i ), 
	.Bus_D_o( DataOut_Bitmap_Regs_o ),
	.Bitmap_CS_i( CS_Bitmap_Registers_i ),
// Output to the F2DEngine
	.BM0_Layer_Enable_o( BM0_Layer_Enable ),
	.BM0_Layer_Lut_o( BM0_LUT ),
	.BM0_MapAddy_o( BM0_START_ADDY ),
	.BM0_X_Offset_o( BM0_X_Offset ),	// +/- 32
	.BM0_Y_Offset_o( BM0_Y_Offset ),	// +/- 32
	.BM0_Priority_o( BM0_Priority ), 
	.BM0_Collision_On_o( BM0_Collision_On ), 

	.BM1_Layer_Enable_o( BM1_Layer_Enable ),
	.BM1_Layer_Lut_o( BM1_LUT ),
	.BM1_Coll_Map_En_o( BM1_Coll_Map_En ),	//
	.BM1_Coll_Map_Display_En_o( BM1_Coll_Map_Display_En ),
	.BM1_MapAddy_o( BM1_START_ADDY ),
	.BM1_X_Offset_o( BM1_X_Offset ),	// +/- 32
	.BM1_Y_Offset_o( BM1_Y_Offset ),	// +/- 32
	.BM1_Priority_o( BM1_Priority ),
	.BM1_Collision_On_o( BM1_Collision_On ),
	
	.COL_Layer_Enable_o( COL_Layer_Enable ),
	.COL_MapAddy_o( COL_MapAddy ),
	.COL_Collision_On_o( COL_Collision_On ),
	
	.BM3_Layer_Enable_o( BM3_Layer_Enable ),
	.BM3_Layer_Lut_o( BM3_LUT ),
	.BM3_MapAddy_o( BM3_START_ADDY ),
	.BM3_X_Offset_o( BM3_X_Offset ),	// +/- 32
	.BM3_Y_Offset_o( BM3_Y_Offset ),	// +/- 32
	.BM3_Priority_o( BM3_Priority ),
	.BM3_Collision_On_o( BM3_Collision_On )	
	
);

wire BM1_Coll_Map_En;
wire BM1_Coll_Map_Display_En;

//////////////////////////////
// Register FILES TILE
//////////////////////////////
Tile_Map_Registers_Block TL_REgister_File(
	.rst_i( Reset_i ),							// This is async Reset
	.EngineClk100Mhz_i(EngineClk100Mhz_A_i),
	.EngineClk200Mhz_i(EngineClk200Mhz_i),
	// CPU Signals Interface
	.Bus_Clk_i( Bus_Clk_i ),
	.Bus_A_i( Bus_A_i ),
	.Bus_A_Valid_i( Bus_A_Valid_i ),	
	.Bus_D8_i( Bus_D8_i ),
	.Bus_D16_i( Bus_D16_i ),
	.Bus_D32_i( Bus_D32_i ),
	.Bus_D_Siz_i( Bus_D_Siz_i ),
	.Bus_RW_i( Bus_RW_i ),
	.Bus_BE_i( Bus_BE_i ), 
	.Bus_WE_i( Bus_WE_i ), 
	.Bus_D0_o( DataOut_Tile0_Regs_o ),	
	.Bus_D1_o( DataOut_Tile1_Regs_o ),
	.Tile_MAP_CS_i( CS_Tile0_Registers_i ),	// Set the Different Layer
	.Tile_Data_CS_i( CS_Tile1_Registers_i ),	// This is to set the Address for each Tile Graphics Addresses
	// Layer0 Information
	.TileMap0_Control_Reg_o( TileMap0_Control_Reg ),
	.TileMap0_Addy_o( TileMap0_Addy ),
	.TileMap0_X_TotalSize_o( TileMap0_X_TotalSize ),		// Size of the Square of the whole Map Max 1024 Position (54)
	.TileMap0_Y_TotalSize_o( TileMap0_Y_TotalSize ),		// Size of the Square of the whole Map Max 1024 Position
	.TileMap0_X_Window_Pos_o( TileMap0_X_Window_Pos ),	// Window Position
	.TileMap0_Y_Window_Pos_o( TileMap0_Y_Window_Pos ),	// Window Position
	.TileMap0_X_Scroll_o( TileMap0_X_Scroll ),
	.TileMap0_Y_Scroll_o( TileMap0_Y_Scroll ),
	// Layer1 Information
	.TileMap1_Control_Reg_o( TileMap1_Control_Reg ),
	.TileMap1_Addy_o( TileMap1_Addy ),
	.TileMap1_X_TotalSize_o( TileMap1_X_TotalSize ),		// Size of the Square of the whole Map Max 1024 Position (54)
	.TileMap1_Y_TotalSize_o( TileMap1_Y_TotalSize ),		// Size of the Square of the whole Map Max 1024 Position
	.TileMap1_X_Window_Pos_o( TileMap1_X_Window_Pos ),	// Window Position
	.TileMap1_Y_Window_Pos_o( TileMap1_Y_Window_Pos ),	// Window Position
	.TileMap1_X_Scroll_o( TileMap1_X_Scroll ),
	.TileMap1_Y_Scroll_o( TileMap1_Y_Scroll ),
	// Layer2 Information
	.TileMap2_Control_Reg_o( TileMap2_Control_Reg ),
	.TileMap2_Addy_o( TileMap2_Addy ),
	.TileMap2_X_TotalSize_o( TileMap2_X_TotalSize ),		// Size of the Square of the whole Map Max 1024 Position (54)
	.TileMap2_Y_TotalSize_o( TileMap2_Y_TotalSize ),		// Size of the Square of the whole Map Max 1024 Position
	.TileMap2_X_Window_Pos_o( TileMap2_X_Window_Pos ),	// Window Position
	.TileMap2_Y_Window_Pos_o( TileMap2_Y_Window_Pos ),	// Window Position
	.TileMap2_X_Scroll_o( TileMap2_X_Scroll ),
	.TileMap2_Y_Scroll_o( TileMap2_Y_Scroll ),	
	// Layer3 Information
	.TileMap3_Control_Reg_o( TileMap3_Control_Reg ),
	.TileMap3_Addy_o( TileMap3_Addy ),
	.TileMap3_X_TotalSize_o( TileMap3_X_TotalSize ),		// Size of the Square of the whole Map Max 1024 Position (54)
	.TileMap3_Y_TotalSize_o( TileMap3_Y_TotalSize ),		// Size of the Square of the whole Map Max 1024 Position
	.TileMap3_X_Window_Pos_o( TileMap3_X_Window_Pos ),	// Window Position
	.TileMap3_Y_Window_Pos_o( TileMap3_Y_Window_Pos ),	// Window Position
	.TileMap3_X_Scroll_o( TileMap3_X_Scroll ),
	.TileMap3_Y_Scroll_o( TileMap3_Y_Scroll ),
	// Tile Set Address
	.TileSet0Addy_o( TileSet0Addy ),
	.TileSet1Addy_o( TileSet1Addy ),
	.TileSet2Addy_o( TileSet2Addy ),
	.TileSet3Addy_o( TileSet3Addy ),	
	.TileSet4Addy_o( TileSet4Addy ),
	.TileSet5Addy_o( TileSet5Addy ),
	.TileSet6Addy_o( TileSet6Addy ),
	.TileSet7Addy_o( TileSet7Addy ),
	
	.TileSet0_CFG_o( TileSet0Cfg ),
	.TileSet1_CFG_o( TileSet1Cfg ),
	.TileSet2_CFG_o( TileSet2Cfg ),
	.TileSet3_CFG_o( TileSet3Cfg ),
	.TileSet4_CFG_o( TileSet4Cfg ),
	.TileSet5_CFG_o( TileSet5Cfg ),
	.TileSet6_CFG_o( TileSet6Cfg ),
	.TileSet7_CFG_o( TileSet7Cfg ),
	
	.Layer0Mode8_16_o( TLayer0Mode8_16_o ),
	.Layer1Mode8_16_o( TLayer1Mode8_16_o ),
	.Layer2Mode8_16_o( TLayer2Mode8_16_o ),
	.Layer3Mode8_16_o( TLayer3Mode8_16_o )	
);

Sprite_Register_Block	Sprite_Register_Module16 (
	.rdclock ( EngineClk100Mhz_A_i ),
	.rdaddress ( Sprite_Active_Channel ),
	.q ( OutputSpriteMem ),	

	.data ( Bus_D32_i ),	
	.wraddress ( Bus_A_i[8:2] ),
	.wrclock ( Bus_Clk_i ),
	.wren ( CS_Sprites_Registers_i & !Bus_RW_i & ( Bus_D_Siz_i[1:0] == 2'b00 ) & Bus_WE_i )
);

wire	[15:0]	Collision_SpriteL0;
wire	[15:0]	Collision_SpriteL1;
wire	[15:0]	Collision_SpriteL2;
wire	[15:0]	Collision_SpriteL3;
wire	[15:0]	Collision_SpriteL4;
wire	[15:0]	Collision_SpriteL5;
wire	[15:0]	Collision_SpriteL6;
wire	[15:0]	Collision_BM0;
wire	[15:0]	Collision_BM1;
wire	[15:0]	Collision_COL;
wire	[15:0]	Collision_TL0;
wire	[15:0]	Collision_TL1;
wire	[15:0]	Collision_TL2;
wire	[15:0]	Collision_TL3;

CollisionRegisterFile CollisionRegisters
(
	.rst_i( Reset_i ),							// This is async Reset
	.EngineClk100Mhz_i(EngineClk100Mhz_A_i),
	.EngineClk200Mhz_i(EngineClk200Mhz_i),
	// CPU Signals Interface
	.Bus_Clk_i( Bus_Clk_i ),
	.Bus_A_i( Bus_A_i ),
	.Bus_A_Valid_i( Bus_A_Valid_i ),	
	.Bus_D8_i( Bus_D8_i ),
	.Bus_D16_i( Bus_D16_i ),
	.Bus_D32_i( Bus_D32_i ),
	.Bus_D_Siz_i( Bus_D_Siz_i ),
	.Bus_RW_i( Bus_RW_i ),
	.Bus_BE_i( Bus_BE_i ), 	
	.Bus_D_o(DataOut_Collisions_Regs_o ),
	.Collision_CS_i( CS_Collisions_Registers_i ),
// Output to the F2DEngine
	.Collision_SpriteL0_i( Collision_SpriteL0 ),
	.Collision_SpriteL1_i( Collision_SpriteL1 ),
	.Collision_SpriteL2_i( Collision_SpriteL2 ),
	.Collision_SpriteL3_i( Collision_SpriteL3 ),
	.Collision_SpriteL4_i( Collision_SpriteL4 ),
	.Collision_SpriteL5_i( Collision_SpriteL5 ),
	.Collision_SpriteL6_i( Collision_SpriteL6 ),

	.Collision_BM0_i( Collision_BM0 ),
	.Collision_BM1_i( Collision_BM1 ),
	.Collision_COL_i( Collision_COL ),

	.Collision_TL0_i( Collision_TL0 ),
	.Collision_TL1_i( Collision_TL1 ),
	.Collision_TL2_i( Collision_TL2 ),
	.Collision_TL3_i( Collision_TL3 ),
	
// Collision Pixel
	.Sprite_Collision_Pixel_i( Sprite_Collision_Pixel ),
	.Sprite_Collision_Channel_i( Sprite_Collision_Channel ),
	.Bitmap_L0_Collision_Pixel_i( Bitmap_L0_Collision_Pixel ),
	.Bitmap_L1_Collision_Pixel_i( Bitmap_L1_Collision_Pixel ),
	.Bitmap_C0_Collision_Pixel_i( Bitmap_C0_Collision_Pixel ),
	.Tilemap_L0_Collision_Pixel_i( Tilemap_L0_Collision_Pixel ),
	.Tilemap_L1_Collision_Pixel_i( Tilemap_L1_Collision_Pixel ),
	.Tilemap_L2_Collision_Pixel_i( Tilemap_L2_Collision_Pixel ),
	.Tilemap_L3_Collision_Pixel_i( Tilemap_L3_Collision_Pixel ),
//Coordinate of the Collision
	.Collision_Sprite_X_Location_i( Collision_Sprite_X_Location ),
	.Collision_Bitmap_X_Location_i( Collision_Bitmap_X_Location ),
	.Collision_Tiles_X_Location_i( Collision_Tiles_X_Location ),	
	.Collision_Y_Location_i( Collision_Y_Location )
);


VideoGraphicEngine VGE (
	.Reset_i( Reset_i ),
	.Reset_100Mhz_i( Reset_100Mhz ),
	.Reset_200Mhz_i( Reset_200Mhz ),
	.Reset_VideoClkOut_i( Reset_VideoClkOut ),
	.Reset_VideoClk_Full_Resolution_i( Reset_VideoClk_Full_Resolution ),	
	
	.VideoModeReset_i( VideoModeReset_i ),
	.VideoModeReset_100Mhz_i( VideoModeReset_100Mhz_i ),
	.VideoModeReset_200Mhz_i( VideoModeReset_200Mhz_i ),
	// Clocks
	.EngineClk100Mhz_A_i( EngineClk100Mhz_A_i ),
	.EngineClk100Mhz_B_i( EngineClk100Mhz_B_i ),
	.EngineClk200Mhz_i( EngineClk200Mhz_i ),
	.EngineClk200Mhz_Aux_i( EngineClk200Mhz_Aux_i ),
	.VideoClk_i( VideoClock_108Mhz_i ),							// I am feeding both with 108Mhz because most following Logic uses that clock
	.Bus_Clk_i( Bus_Clk_i ),
	// Video Signals
	.SOF_i( SOF_i ),
	.Vsync_i( Vsync_i ),
	.VBlanking_i( VBlanking_i ),
	.HBlanking_i( HBlanking_i ),
//	.VGE_VBlanking_i( VGE_VBlanking_i ),
	.VGE_Engine_VBlanking_2L_i( VGE_Engine_VBlanking_2L_i ), 
	.VGE_Engine_VBlanking_4L_i( VGE_Engine_VBlanking_4L_i ), 	
	.HBlanking_VGE_Lat_i( HBlanking_VGE_Lat_i ),
	
// Video Timming Constants
	.Total_Pixel_Per_Line_Value_i( Total_Pixel_Per_Line_Value_i ),
	.Total_Line_Per_Image_Value_i( Total_Line_Per_Image_Value_i ),
	.H_Blanking_Value_i( H_Blanking_Value_i ),
	.V_Blanking_Value_i( V_Blanking_Value_i ),
	.Visible_Pixel_Per_Line_Value_i( Visible_Pixel_Per_Line_Value_i ),
	.Visible_Line_Per_Line_Value_i( Visible_Line_Per_Line_Value_i ),
// Sequencer
	.Time_Rd_Wr_Access_100Mhz_i( Time_Rd_Wr_Access_100Mhz_i ),		
	.Time_Rd_Only_Access_100Mhz_i( Time_Rd_Only_Access_100Mhz_i ),	// 
	.Time_Trf_Pixels_2_Pixel_200Mhz_i( Time_Trf_Pixels_2_Pixel_200Mhz_i ),
	.Time_Erase_Pixels_Line_100Mhz_i( Time_Erase_Pixels_Line_100Mhz_i ),
	.Time_Erase_Pixels_Line_200Mhz_i( Time_Erase_Pixels_Line_200Mhz_i ),
	.Time_2_Display_Line_VideoClk_i( Time_2_Display_Line_VideoClk_i ),
	//.Time_2_Charge_TileMap_Lines_i( Time_2_Charge_TileMap_Lines_i ),
	.Time_2_Charge_TileMap_L0_Lines_i( Time_2_Charge_TileMap_L0_Lines_i ),
	.Time_2_Charge_TileMap_L1_Lines_i( Time_2_Charge_TileMap_L1_Lines_i ),
	.Time_2_Charge_TileMap_L2_Lines_i( Time_2_Charge_TileMap_L2_Lines_i ),
	.Time_2_Charge_TileMap_L3_Lines_i( Time_2_Charge_TileMap_L3_Lines_i ),	
// Master Control Signals
	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode_i ),
	.Mstr_Ctrl_Doubling_Pixel_i( Mstr_Ctrl_Doubling_Pixel_i ),
	
	.Mstr_Ctrl_Video_Mode100Mhz_i( Mstr_Ctrl_Video_Mode100Mhz_i ), 
	.Mstr_Ctrl_Doubling_Pixel_100Mhz_i( Mstr_Ctrl_Doubling_Pixel_100Mhz_i ), 
	
	.Mstr_Ctrl_Graphic_Mode_Enable_i( Mstr_Ctrl_Graphic_Mode_Enable_i ),
	.Mstr_Ctrl_Bitmap_Enable_i( Mstr_Ctrl_Bitmap_Enable_i ),
	.Mstr_Ctrl_TileMap_Enable_i( Mstr_Ctrl_TileMap_Enable_i ),
	.Mstr_Ctrl_Sprite_Enable_i( Mstr_Ctrl_Sprite_Enable_i ),
	.VGE_Engine_Disable_VideoProcessing_i( Mstr_Ctrl_Disable_Video_i ),
	// 
	.SX0_i( SX0 ),
	.SY0_i( SY0 ),
	.SX1_i( SX1 ),		
	.SY1_i( SY1 ),	
	//
	.VX0_i( VX0 ),
	.VY0_i( VY0 ),	
	.VX1_i( VX1 ),	
	.VY1_i( VY1 ),
	// Bitmap & Collision Map
	.BM0_Layer_Enable_i( BM0_Layer_Enable ),
	.BM0_Layer_Lut_i( BM0_LUT ),
	.BM0_MapAddy_i( BM0_START_ADDY ),
	.BM0_X_Offset_i( BM0_X_Offset ),	// +/- 32
	.BM0_Y_Offset_i( BM0_Y_Offset ),	// +/- 32
	.BM0_Collision_On_i( BM0_Collision_On ), 
	//.BM0_Priority_i( BM0_Priority ),
	
	// VRAM BANK B
	.BM3_Layer_Enable_i( BM3_Layer_Enable ),
	.BM3_Layer_Lut_i( BM3_LUT ),
	.BM3_MapAddy_i( BM3_START_ADDY ),
	.BM3_X_Offset_i( BM3_X_Offset ),	// +/- 32
	.BM3_Y_Offset_i( BM3_Y_Offset ),	// +/- 32
	.BM3_Collision_On_i( BM3_Collision_On ), 	
	
	.BM1_Layer_Enable_i( BM1_Layer_Enable ),
	.BM1_Layer_Lut_i( BM1_LUT ),
	.BM1_MapAddy_i( BM1_START_ADDY ),
	.BM1_X_Offset_i( BM1_X_Offset ),	// +/- 32 [0..31]
	.BM1_Y_Offset_i( BM1_Y_Offset ),	// +/- 32 [0..31]
	.BM1_Collision_On_i( BM1_Collision_On ),
	.BM1_Coll_Map_En_i( BM1_Coll_Map_En ),	//
	.BM1_Coll_Map_Display_En_i( BM1_Coll_Map_Display_En ),	

	.COL_Layer_Enable_i( COL_Layer_Enable ),
	.COL_MapAddy_i( COL_MapAddy ),
	.COL_X_Offset_i( 5'b0_0000 ),	// +/- 32 [0..31]
	.COL_Y_Offset_i( 5'b0_0000 ),	// +/- 32 [0..31]
	.COL_Collision_On_i( COL_Collision_On ), 
	
	.Collision_SpriteL0_o( Collision_SpriteL0 ),
	.Collision_SpriteL1_o( Collision_SpriteL1 ),
	.Collision_SpriteL2_o( Collision_SpriteL2 ),
	.Collision_SpriteL3_o( Collision_SpriteL3 ),
	.Collision_SpriteL4_o( Collision_SpriteL4 ),
	.Collision_SpriteL5_o( Collision_SpriteL5 ),
	.Collision_SpriteL6_o( Collision_SpriteL6 ),

	.Collision_BM0_o( Collision_BM0 ),
	.Collision_BM1_o( Collision_BM1 ),
	.Collision_COL_o( Collision_COL ),

	.Collision_TL0_o( Collision_TL0 ),
	.Collision_TL1_o( Collision_TL1 ),
	.Collision_TL2_o( Collision_TL2 ),
	.Collision_TL3_o( Collision_TL3 ),
	// Collision Pixel
	.Sprite_Collision_Pixel_o( Sprite_Collision_Pixel ),
	.Sprite_Collision_Channel_o( Sprite_Collision_Channel ),
	.Bitmap_L0_Collision_Pixel_o( Bitmap_L0_Collision_Pixel ),
	.Bitmap_L1_Collision_Pixel_o( Bitmap_L1_Collision_Pixel ),
	.Bitmap_C0_Collision_Pixel_o( Bitmap_C0_Collision_Pixel ),
	.Tilemap_L0_Collision_Pixel_o( Tilemap_L0_Collision_Pixel ),
	.Tilemap_L1_Collision_Pixel_o( Tilemap_L1_Collision_Pixel ),
	.Tilemap_L2_Collision_Pixel_o( Tilemap_L2_Collision_Pixel ),
	.Tilemap_L3_Collision_Pixel_o( Tilemap_L3_Collision_Pixel ),
	//Coordinate of the Collision
	.Collision_Sprite_X_Location_o( Collision_Sprite_X_Location ),
	.Collision_Bitmap_X_Location_o( Collision_Bitmap_X_Location ),
	.Collision_Tiles_X_Location_o( Collision_Tiles_X_Location ),	
	.Collision_Y_Location_o( Collision_Y_Location ),

	.TileMap0_Control_Reg_i( TileMap0_Control_Reg ),
	.TileMap0_Addy_i( TileMap0_Addy ),
	.TileMap0_X_TotalSize_i( TileMap0_X_TotalSize ),
	.TileMap0_Y_TotalSize_i( TileMap0_Y_TotalSize ),
	.TileMap0_X_Window_Pos_i( TileMap0_X_Window_Pos ),
	.TileMap0_Y_Window_Pos_i( TileMap0_Y_Window_Pos ),
	.TileMap0_X_Scroll_i( TileMap0_X_Scroll ),
	.TileMap0_Y_Scroll_i( TileMap0_Y_Scroll ),
	
	.TileMap1_Control_Reg_i( TileMap1_Control_Reg ),
	.TileMap1_Addy_i(TileMap1_Addy ),
	.TileMap1_X_TotalSize_i( TileMap1_X_TotalSize ),
	.TileMap1_Y_TotalSize_i( TileMap1_Y_TotalSize  ),
	.TileMap1_X_Window_Pos_i( TileMap1_X_Window_Pos ),
	.TileMap1_Y_Window_Pos_i( TileMap1_Y_Window_Pos ),
	.TileMap1_X_Scroll_i( TileMap1_X_Scroll ),
	.TileMap1_Y_Scroll_i( TileMap1_Y_Scroll ),

	.TileMap2_Control_Reg_i( TileMap2_Control_Reg ),
	.TileMap2_Addy_i( TileMap2_Addy ),
	.TileMap2_X_TotalSize_i( TileMap2_X_TotalSize ),
	.TileMap2_Y_TotalSize_i( TileMap2_Y_TotalSize ),
	.TileMap2_X_Window_Pos_i( TileMap2_X_Window_Pos ),
	.TileMap2_Y_Window_Pos_i( TileMap2_Y_Window_Pos ),
	.TileMap2_X_Scroll_i( TileMap2_X_Scroll ),
	.TileMap2_Y_Scroll_i( TileMap2_Y_Scroll ),

	.TileMap3_Control_Reg_i( TileMap3_Control_Reg ),
	.TileMap3_Addy_i( TileMap3_Addy ),
	.TileMap3_X_TotalSize_i( TileMap3_X_TotalSize ),
	.TileMap3_Y_TotalSize_i( TileMap3_Y_TotalSize ),
	.TileMap3_X_Window_Pos_i( TileMap3_X_Window_Pos ),
	.TileMap3_Y_Window_Pos_i( TileMap3_Y_Window_Pos ),
	.TileMap3_X_Scroll_i( TileMap3_X_Scroll ),
	.TileMap3_Y_Scroll_i( TileMap3_Y_Scroll ),
	
	.TileSet0Addy_i( TileSet0Addy ),
	.TileSet1Addy_i( TileSet1Addy ),
	.TileSet2Addy_i( TileSet2Addy ),
	.TileSet3Addy_i( TileSet3Addy ),
	.TileSet4Addy_i( TileSet4Addy ),
	.TileSet5Addy_i( TileSet5Addy ),
	.TileSet6Addy_i( TileSet6Addy ),
	.TileSet7Addy_i( TileSet7Addy ),
	
	.TileSet0_CFG_i( TileSet0Cfg ),
	.TileSet1_CFG_i( TileSet1Cfg ),
	.TileSet2_CFG_i( TileSet2Cfg ),
	.TileSet3_CFG_i( TileSet3Cfg ),
	.TileSet4_CFG_i( TileSet4Cfg ),
	.TileSet5_CFG_i( TileSet5Cfg ),
	.TileSet6_CFG_i( TileSet6Cfg ),
	.TileSet7_CFG_i( TileSet7Cfg ),

	// Sprites
	.Sprite_Active_Channel_o( Sprite_Active_Channel ),
	.Sprite_OutputSpriteMem_i( OutputSpriteMem ),
		
	// Video Output & Background 
	.Background_Blue_i( Background_Blue_i ),
	.Background_Green_i( Background_Green_i ),
	.Background_Red_i( Background_Red_i ),

	.VGE_RGB_Pixel_o( VGE_RGB_Pixel_o ),
	
// Collision Interrupt
	.Sprite_Collision_Interrupt_o( Sprite_Collision_Interrupt_o ),
	.Bitmap_Collision_Interrupt_o( Bitmap_Collision_Interrupt_o ),
	.Tilemap_Collision_Interrupt_o( Tilemap_Collision_Interrupt_o ),

// CPU Interface - 25/40Mhz
	.Bus_A_i( Bus_A_i ),
	.Bus_A_Valid_i( Bus_A_Valid_i ),
	.Bus_RW_i( Bus_RW_i ),
	.Bus_BE_i( Bus_BE_i ),
	.Bus_D8_i( Bus_D8_i ),
	.Bus_D16_i( Bus_D16_i ),
	.Bus_D32_i( Bus_D32_i ),
	.Bus_D_Siz_i( Bus_D_Siz_i ),
	.Bus_WE_i( Bus_WE_i ), 
//	.VDMA_Bus_RDY_o( VDMA_Bus_RDY_o ),
	.CS_VMEM_2_CPU_i( CS_VMEM_2_CPU_i ),
	//.VMEM_2_CPU_ResetFiFo_i( VMEM_2_CPU_ResetFiFo_i ),
	//.VMEM_2_CPU_FIFO_Count_o( VMEM_2_CPU_FIFO_Count_o ),
	//.VMEM_2_CPU_FIFO_Empty_o( VMEM_2_CPU_FIFO_Empty_o ),
	//.VMEM_2_CPU_Data_o( VMEM_2_CPU_Data_o ),	
// CPU ChipSelect - 14Mhz
	.CS_VDMA_Controller_i( CS_VDMA_Controller_i ),
	.CS_LUT0_i( CS_LUT0_i ),
	.CS_VIDEO_RAM_B0_i( iBUS_CS_VRAM_A_i ),
	.CS_VIDEO_RAM_B1_i( iBUS_CS_VRAM_B_i ),
// Data Output to be Read Back
	.DataOut_LUT_o( DataOut_LUT_o ),
	//.DataOut_VDMA_o( DataOut_VDMA_o ),

/////////////////////////////////////////////////////////////	
// New SDMA 2 VDMA Interface
// Input FIFO Interface from the VDMA Controller
	//.FIFO_Input_Channel_o( FIFO_Input_Channel_o ),
	//.FIFO_Input_Read_i( FIFO_Input_Read_i ),
	//.FIFO_Input_Count_o( FIFO_Input_Count_o ),
	//.FIFO_Input_Empty_o( FIFO_Input_Empty_o ), 
// Output FIFO Interface to  the VDMA Controller
	//.FIFO_Output_Clear_i( FIFO_Output_Clear_i ),
	//.FIFO_Output_Channel_i( FIFO_Output_Channel_i ), 
	//.FIFO_Output_Write_i( FIFO_Output_Write_i ),
	//.FIFO_Output_Count_o( FIFO_Output_Count_o ),	
	//.FIFO_OUtput_Full_o( FIFO_OUtput_Full_o ),
/////////////////////////////////////////////////////////////	

// VDMA Interrupt
	.VDMA_Interrupt_o( VDMA_Interrupt_o ),

// V(DRAM) Interface A
// Video RAM Bank A
	.VRAM_A_DQ_i( VRAM_A_DQ_i  ),
	.VRAM_A_DQ_o( VRAM_A_DQ_o  ),
	.VRAM_A_BEn_o( VRAM_A_BEn_o ),
	.VRAM_A_Addy_o( VRAM_A_Addy_o ),
	.VRAM_A_OEn_o( VRAM_A_OEn_o ),
	.VRAM_A_WEn_o( VRAM_A_WEn_o ),
// Video RAM Bank B
	.VRAM_B_DQ_i( VRAM_B_DQ_i  ),
	.VRAM_B_DQ_o( VRAM_B_DQ_o  ),
	.VRAM_B_BEn_o( VRAM_B_BEn_o ),
	.VRAM_B_Addy_o( VRAM_B_Addy_o ),
	.VRAM_B_OEn_o( VRAM_B_OEn_o ),
	.VRAM_B_WEn_o( VRAM_B_WEn_o ),
	
	.BANK_SWITCH_i( BANK_SWITCH_i )
);



endmodule
