`timescale 1ns/1ns
module VGE_MasterController_Module(

// Resets
input		wire				Reset_i,
input		wire				VideoRst_i,
input		wire				VideoModeReset_i,

// Clocks
input		wire				Bus_Clk_i,
input		wire				VideoClk_i,
input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,

input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,
input		wire				Mstr_Ctrl_Graphic_Mode_Enable_i,
input		wire				Mstr_Ctrl_Bitmap_Enable_i,
input		wire				Mstr_Ctrl_TileMap_Enable_i,
input		wire				Mstr_Ctrl_Sprite_Enable_i,

input		wire	[4:0]		Mstr_Ctrl_Master_X_Offset_i,		// Defaulted to 31 + 1
input		wire	[4:0]		Mstr_Ctrl_Master_Y_Offset_i,		// Defaulted to 31 + 1

// Video Interface
input		wire	[11:0]	HLineCount_i,
input		wire	[11:0]	HPixelCount_i,
input		wire				SOF_i,
input		wire				Vsync_i,
input		wire				VBlanking_i,
input		wire				HBlanking_i,
input		wire				Horizontal_Border_i,
input		wire				Vertical_Border_i,
input		wire				Horizontal_Precharge_i,

input		wire	[11:0]	Total_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Total_Line_Per_Image_Value_i,
input		wire	[11:0]	H_Blanking_Value_i,
input		wire	[11:0]	V_Blanking_Value_i,
input		wire	[11:0]	Visible_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Visible_Line_Per_Line_Value_i,

input		wire	[7:0]		Background_Blue_i,
input		wire	[7:0]		Background_Green_i,
input		wire	[7:0]		Background_Red_i,

output	wire	[31:0]	VGE_RGB_Pixel_o,

// CPU Interface
input		wire	[23:0]	Bus_A_i,
input		wire				Bus_RW_i,
input		wire				Bus_RDY_i,
input		wire	[7:0]		Bus_D_i,

// Chip Selects
input		wire				CS_Bitmap_Reg_i,
input		wire				CS_Tile_Reg_i,
input		wire				CS_Sprite_Reg_i,
input		wire				CS_LUT0_i,
input		wire				CS_LUT1_i,
input		wire				CS_LUT2_i,
input		wire				CS_LUT3_i,
input		wire				CS_LUT4_i,
input		wire				CS_LUT5_i,
input		wire				CS_LUT6_i,
input		wire				CS_LUT7_i,
input		wire				CS_Tile_Map_i,
input		wire				CS_VIDEO_RAM_i,

// Data Output to be Read Back
output	wire	[7:0]		Bus_Bitmap_Data_o,
output	wire	[7:0]		Bus_LUT0_Data_o,
output	wire	[7:0]		Bus_LUT1_Data_o,
output	wire	[7:0]		Bus_LUT2_Data_o,
output	wire	[7:0]		Bus_LUT3_Data_o,
output	wire	[7:0]		Bus_LUT4_Data_o,
output	wire	[7:0]		Bus_LUT5_Data_o,
output	wire	[7:0]		Bus_LUT6_Data_o,
output	wire	[7:0]		Bus_LUT7_Data_o,
output 	wire  [7:0]		Bus_Tile_Map_o,


// Video RAM Access Module Interface
output	wire	[19:0]	VGE_Addy_o,	// 1Mx32
input		wire	[31:0]	VGE_VidMem_Data_i,
output	wire	[31:0]	VGE_VidMem_Data_o,
output	wire				VGE_VidMem_Readn_o,
output   wire	[3:0]		VGE_VidMem_Writen_o
);


wire	[35:0]	VGE_Command_Tag;
wire				VGE_Command_Tag_Write;
wire				VGE_Command_Tag_Full;

wire	[35:0]	VGE_DATA_2_READ_Tag;
wire				VGE_DATA_2_READ_Tag_Read;

wire				VGE_DATA_2_READ_Tag_Empty;
wire	[7:0]		VGE_DATA_2_READ_Tag_Count;	


// Wires
wire				BM0_Layer_Enable;
wire	[2:0] 	BM0_LUT;
wire	[23:0]	BM0_START_ADDY;
wire	[4:0]		BM0_X_Offset;
wire	[4:0]		BM0_Y_Offset;
wire	[3:0]		BM0_Priority;

wire				BM1_Layer_Enable;
wire	[2:0]		BM1_LUT;
wire	[23:0]	BM1_START_ADDY;
wire	[4:0]		BM1_X_Offset;
wire	[4:0]		BM1_Y_Offset;
wire	[3:0]		BM1_Priority;


wire	[63:0]	OutputSpriteMem;
wire	[7:0]		Sprite_Control_Reg;
wire	[23:0]	Sprite_Address_Ptr;
wire	[15:0]	Sprite_X0_Coordinate;
wire	[15:0]	Sprite_Y0_Coordinate;
wire	[15:0]	Sprite_X1_Coordinate;
wire  [15:0]	Sprite_Y1_Coordinate;
wire	[5:0]		Sprite_Active_Channel;


// Registers

assign   Bus_Tile_Map_o 	= 8'h00;

//////////////////////////////
// Register FILES BitMap
//////////////////////////////
BitMapRegisterFile BM_Register_File
(
	.rst_i( Reset_i ),	
	.EngineClk200Mhz_i( EngineClk200Mhz_i ),
// CPU Signals Interface
	.Bus_Clk_i( Bus_Clk_i ),
	.Bus_A_i( Bus_A_i ),
	.Bus_D_i( Bus_D_i ),
	.Bus_D_o(  ),
	.Bus_RW_i( Bus_RW_i ),
	.Bitmap_CS_i( CS_Bitmap_Reg_i ),
// Output to the F2DEngine
	.BM0_Layer_Enable_o( BM0_Layer_Enable ),
	.BM0_Layer_Lut_o( BM0_LUT ),
	.BM0_MapAddy_o( BM0_START_ADDY ),
	.BM0_X_Offset_o( BM0_X_Offset ),	// +/- 32
	.BM0_Y_Offset_o( BM0_Y_Offset ),	// +/- 32
	.BM0_Priority_o( BM0_Priority ), 

	.BM1_Layer_Enable_o( BM1_Layer_Enable ),
	.BM1_Layer_Lut_o( BM1_LUT ),
	.BM1_Coll_Map_En_o(  ),	//
	.BM1_Coll_Map_Display_En_o(  ),
	.BM1_MapAddy_o( BM1_START_ADDY ),
	.BM1_X_Offset_o( BM1_X_Offset ),	// +/- 32
	.BM1_Y_Offset_o( BM1_Y_Offset ),	// +/- 32
	.BM1_Priority_o( BM1_Priority )
);


//Sprite_Register_Block	Sprite_Register_Module (
//	.rdclock ( EngineClk200Mhz_i ),
//	.rdaddress ( Sprite_Active_Channel ),
//	.q ( OutputSpriteMem ),	
	
//	.data ( Bus_D_i ),	
//	.wraddress ( Bus_A_i ),
//	.wrclock ( !Bus_Clk_i ),
//	.wren ( CS_Sprite_Reg_i & !Bus_RW_i )
//
//	);
	
Sprite_Register_Block_Debug	Sprite_Register_Block_Debug_inst (
	.address ( Sprite_Active_Channel ),
	.clock ( EngineClk200Mhz_i ),
	.data ( 64'h0000_0000_0000_0000 ),
	.wren ( 1'b0 ),
	.q ( OutputSpriteMem )
	);


// Bitmap Resolution
//Resolution Coordinates
// 640x480 - TOTAL: X0:000 Y0:000 X1:704 Y1:544 - VISUAL: VX0:032 VY0:032 VX1:672 VY1:512
// 800x600 - TOTAL: X0:000 Y0:000 X1:864 Y1:664 - VISUAL: VX0:032 VY0:032 VX1:832 VY1:632
// 320x240 - TOTAL: X0:000 Y0:000 X1:384 Y1:304 - VISUAL: VX0:032 VY0:032 VX1:352 VY1:272
// 400x300 - TOTAL: X0:000 Y0:000 X1:464 Y1:364 - VISUAL: VX0:032 VY0:032 VX1:432 VY1:332


wire	[11:0]	SX0;	// System Coordinates
wire	[11:0]	SY0;  
reg	[11:0]	SX1;
reg	[11:0]	SY1;
// This is The offseted Coordinate (the one)
wire	[11:0]	VX0;	// Visual Coordinates
wire	[11:0]	VY0;
reg	[11:0]	VX1;
reg	[11:0]	VY1;

assign SX0 = 12'b0000_0000_0000;		//0
assign SY0 = 12'b0000_0000_0000;		//0
assign VX0 = 12'b0000_0010_0000;		//32
assign VY0 = 12'b0000_0010_0000;		//32

always @ (*)
begin
	case (Mstr_Ctrl_Video_Mode_i[1:0])
		2'b00: begin 
			// 640x480
			SX1 = 12'd704;
			SY1 = 12'd544;
			VX1 = 12'd672;
			VY1 = 12'd512;
		end

		2'b01: begin
			// 800x600
			SX1 = 12'd864;
			SY1 = 12'd664;
			VX1 = 12'd832;
			VY1 = 12'd632;
		end
	
		2'b10: begin 
			// 320x240
			SX1 = 12'd384;
			SY1 = 12'd304;
			VX1 = 12'd352;
			VY1 = 12'd272;
		end
	
		2'b11: begin 
			// 800x600
			SX1 = 12'd464;
			SY1 = 12'd364;
			VX1 = 12'd432;
			VY1 = 12'd332;
		end
	endcase
end

// Choose the limits if it is a 640/320 or 800/400
assign Sprite_Control_Reg = OutputSpriteMem[7:0];
assign Sprite_Address_Ptr = {2'b00, OutputSpriteMem[29:8]};	// [19:0]
assign Sprite_X0_Coordinate = ( OutputSpriteMem[47:32] >= VX1) ? VX1 : OutputSpriteMem[47:32];	// This Sets the limits of the Coordinate System
assign Sprite_Y0_Coordinate = ( OutputSpriteMem[63:48] >= VY1) ? VY1 : OutputSpriteMem[63:48];	// 
assign Sprite_X1_Coordinate = Sprite_X0_Coordinate + 16'd32;
assign Sprite_Y1_Coordinate = Sprite_Y0_Coordinate + 16'd32;


VideoGraphicEngine VGE (
	.Reset_i( Reset_i ),
	.VideoRst_i( VideoRst_i ),
	.VideoModeReset_i( VideoModeReset_i ),
	
	// Clocks
	.EngineClk100Mhz_i( EngineClk100Mhz_i ),
	.EngineClk200Mhz_i( EngineClk200Mhz_i ),
	.VideoClk_i( VideoClk_i ),
	.Bus_Clk_i( Bus_Clk_i ),
	// Video Signals
	.HLineCount_i( HLineCount_i ),
	.HPixelCount_i( HPixelCount_i ),
	.SOF_i( SOF_i ),
	.Vsync_i( Vsync_i ),
	.VBlanking_i( VBlanking_i ),
	.HBlanking_i( HBlanking_i ),	
// Video Timming Constants
	.Total_Pixel_Per_Line_Value_i( Total_Pixel_Per_Line_Value_i ),
	.Total_Line_Per_Image_Value_i( Total_Line_Per_Image_Value_i ),
	.H_Blanking_Value_i( H_Blanking_Value_i ),
	.V_Blanking_Value_i( V_Blanking_Value_i ),
	.Visible_Pixel_Per_Line_Value_i( Visible_Pixel_Per_Line_Value_i ),
	.Visible_Line_Per_Line_Value_i( Visible_Line_Per_Line_Value_i ),

// Master Control Signals
	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode_i ),	
	.Mstr_Ctrl_Graphic_Mode_Enable_i( Mstr_Ctrl_Graphic_Mode_Enable_i ),
	.Mstr_Ctrl_Bitmap_Enable_i( Mstr_Ctrl_Bitmap_Enable_i ),
	.Mstr_Ctrl_TileMap_Enable_i( Mstr_Ctrl_TileMap_Enable_i ),
	.Mstr_Ctrl_Sprite_Enable_i( Mstr_Ctrl_Sprite_Enable_i ),	
	// 
	.SX0_i( SX0 ),
	.SY0_i( SY0 ),
	.SX1_i( SX1 ),		
	.SY1_i( SY1 ),	
	//
	.VX0_i( VX0 ),
	.VX1_i( VX1 ),	
	.VY0_i( VY0 ),
	.VY1_i( VY1 ),

	// Bitmap & Collision Map
//	.BM0_Layer_Enable_i( BM0_Layer_Enable ),
//	.BM0_Layer_Lut_i( BM0_LUT ),
//	.BM0_MapAddy_i( BM0_START_ADDY ),
//	.BM0_X_Offset_i( BM0_X_Offset ),	// +/- 32
//	.BM0_Y_Offset_i( BM0_Y_Offset ),	// +/- 32
//	.BM0_Priority_i( BM0_Priority ),

	.BM0_Layer_Enable_i( 1'b1 ),
	.BM0_Layer_Lut_i( 3'b000 ),
	.BM0_MapAddy_i( 24'h00_0000 ),
	.BM0_X_Offset_i( 5'b0_0000 ),	// +/- 32
	.BM0_Y_Offset_i( 5'b0_0000 ),	// +/- 32
	
	.BM1_Layer_Enable_i( BM1_Layer_Enable ),
	.BM1_Layer_Lut_i( BM1_LUT ),
	.BM1_MapAddy_i( BM1_START_ADDY ),
	.BM1_X_Offset_i( BM1_X_Offset ),	// +/- 32 [0..31]
	.BM1_Y_Offset_i( BM1_Y_Offset ),	// +/- 32 [0..31]

	.COL_Layer_Enable_i( 1'b0 ),
	.COL_MapAddy_i( 24'h00_0000 ),
	.COL_X_Offset_i( 5'b0_0000 ),	// +/- 32 [0..31]
	.COL_Y_Offset_i( 5'b0_0000 ),	// +/- 32 [0..31]

	
	// Tile Maps
	.TL0_Enabled_i( 1'b0 ),
	.TileMap0_LUT_i(3'b000),
	
	.TL1_Enabled_i( 1'b0 ),
	.TileMap1_LUT_i(3'b000),
	
	.TL2_Enabled_i( 1'b0 ),
	.TileMap2_LUT_i(3'b000),

	.TL3_Enabled_i( 1'b0 ),
	.TileMap3_LUT_i(3'b000),

	// Sprites
	.SPRITE_Enabled_i(Sprite_Control_Reg[0]),
	.SPRITE_Addy_i(Sprite_Address_Ptr),
	.SPRITE_Active_Channel_o( Sprite_Active_Channel ),
	.Sprite_X0_Coordinate_i( Sprite_X0_Coordinate ),
	.Sprite_Y0_Coordinate_i( Sprite_Y0_Coordinate ),
	.Sprite_X1_Coordinate_i( Sprite_X1_Coordinate ),	
	.Sprite_Y1_Coordinate_i( Sprite_Y1_Coordinate ),
	.Sprite_Priority_i( Sprite_Control_Reg[6:4]),
	.Sprite_LUT_i( Sprite_Control_Reg[3:1] ),
		
	// VDMA
	.VDMA_Enabled_i( 1'b0 ),
	
	// Video Output & Background 
	.Background_Blue_i( Background_Blue_i ),
	.Background_Green_i( Background_Green_i ),
	.Background_Red_i( Background_Red_i ),

	.VGE_RGB_Pixel_o( VGE_RGB_Pixel_o ),

// CPU Interface
	.Bus_A_i( Bus_A_i ),
	.Bus_RW_i( Bus_RW_i ),
	.Bus_RDY_i( Bus_RDY_i ),
	.Bus_D_i( Bus_D_i ),

	.CS_LUT0_i( CS_LUT0_i ),
	.CS_LUT1_i( CS_LUT1_i ),
	.CS_LUT2_i( CS_LUT2_i ),
	.CS_LUT3_i( CS_LUT3_i ),
	.CS_LUT4_i( CS_LUT4_i ),
	.CS_LUT5_i( CS_LUT5_i ),
	.CS_LUT6_i( CS_LUT6_i ),
	.CS_LUT7_i( CS_LUT7_i ),

	.CS_VIDEO_RAM_i( CS_VIDEO_RAM_i ),

// Data Output to be Read Back
	.Bus_Bitmap_Data_o( Bus_Bitmap_Data_o ),

	.Bus_LUT0_Data_o( Bus_LUT0_Data_o ),
	.Bus_LUT1_Data_o( Bus_LUT1_Data_o ),
	.Bus_LUT2_Data_o( Bus_LUT2_Data_o ),
	.Bus_LUT3_Data_o( Bus_LUT3_Data_o ),
	.Bus_LUT4_Data_o( Bus_LUT4_Data_o ),
	.Bus_LUT5_Data_o( Bus_LUT5_Data_o ),
	.Bus_LUT6_Data_o( Bus_LUT6_Data_o ),
	.Bus_LUT7_Data_o( Bus_LUT7_Data_o ),

	// VideoRAM Interface
	.VGE_Addy_o( VGE_Addy_o ),	// 1Mx32
	.VGE_VidMem_Data_i( VGE_VidMem_Data_i ),
	.VGE_VidMem_Data_o( VGE_VidMem_Data_o ),
	.VGE_VidMem_Readn_o( VGE_VidMem_Readn_o ),
	.VGE_VidMem_Writen_o( VGE_VidMem_Writen_o )
);



endmodule
