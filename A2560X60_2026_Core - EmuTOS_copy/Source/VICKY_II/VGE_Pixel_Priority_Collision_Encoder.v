`timescale 1ns/1ns
module VGE_Pixel_Priority_Collision_Encoder(
// Resets
input		wire				Reset_100Mhz_i,
input		wire				Reset_200Mhz_i,
input		wire				Reset_VideoClkOut_i,
input		wire				Reset_VideoClk_Full_Resolution_i,
input		wire				Reset_i,		//14Mhz Reset

input		wire				VideoModeReset_i,
input		wire				VideoModeReset_100Mhz_i,
input		wire				VideoModeReset_200Mhz_i,

// Clocks
input		wire				Bus_Clk_i,
input		wire				VideoClk_i,
input		wire				VideoClock_Full_Resolution_i,
input		wire	[1:0]		Mstr_Ctrl_Video_Mode100Mhz_i,
input 	wire				Mstr_Ctrl_Doubling_Pixel_100Mhz_i,
input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,
input		wire				EngineClk200Mhz_Aux_i,
// Video Signals
input		wire				SOF_i,
input		wire				Vsync_i,
input		wire				VBlanking_i,
input		wire				HBlanking_i,
input		wire				HBlanking_VGE_Lat_i,

input		wire			  	Time_Trf_Pixels_2_Pixel_200Mhz_i,
input		wire				Time_2_Display_Line_VidClk_i,

input		wire	[9:0]		BM_Line_Sizes_i,

// Incoming Mask for the Collision System
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

// Let the user have the Pixel Information when a Collision Happens
output	wire	[7:0]		Sprite_Collision_Pixel_o,
output	wire	[5:0]		Sprite_Collision_Channel_o,
output	wire	[7:0]		Bitmap_L0_Collision_Pixel_o,
output	wire	[7:0]		Bitmap_L1_Collision_Pixel_o,
output	wire	[7:0]		Bitmap_C0_Collision_Pixel_o,
output	wire	[7:0]		Tilemap_L0_Collision_Pixel_o,
output	wire	[7:0]		Tilemap_L1_Collision_Pixel_o,
output	wire	[7:0]		Tilemap_L2_Collision_Pixel_o,
output	wire	[7:0]		Tilemap_L3_Collision_Pixel_o,
//
input		wire	[15:0]	Collision_VideoLine_Active_i,
output	wire	[15:0]	Collision_Y_Location_o,
output	wire	[15:0]	Collision_Sprite_X_Location_o,
output	wire	[15:0]	Collision_Bitmap_X_Location_o,
output	wire	[15:0]	Collision_Tiles_X_Location_o,


// Input Data Line
input		wire	[7:0]		SpriteLine_Pixel_Out_i, //- 4 Clocks Latency (3 Registers ReSync)
input		wire	[15:0]	SpriteLine_Attributes_Out_i, 

input		wire	[7:0]		Sprite_Data_Col_i,
input		wire	[15:0]	Attributes_Data_Col_i,
//	.data( { Sprite_X_Position, 3'b000, Sprite_Collision_On, Sprite_Active_Channel_o, Sprite_Depth, Sprite_LUT } ),		// 6, 3, 3 = 12 Bits

input		wire	[7:0]		Line0_Pixel_Out_i,	// BM0 - 4 Clocks Latency (4 Registers ReSync)
input		wire	[7:0]		Line5_Pixel_Out_i,	// BM1 - 4 Clocks Latency (4 Registers ReSync)
input		wire	[7:0]		Line6_Pixel_Out_i,   // Collision - 4 Clocks Latency (4 Registers ReSync)

input		wire	[7:0]		Line8_Pixel_Out_i,   // BM3

input		wire	[7:0]		Collision_Data_Col_i, //- 4 Clocks Latency (3 Registers ReSync) + Clock Latency for the Read
input		wire	[7:0]		BitMap0_Pixel_Col_i,  //- 4 Clocks Latency (3 Registers ReSync)
input		wire	[7:0]		BitMap1_Pixel_Col_i,	 //- 4 Clocks Latency (3 Registers ReSync)


input		wire	[2:0]		BM0_Layer_Lut_i,
input		wire				BM0_Collision_On_i,
input		wire	[2:0]		BM1_Layer_Lut_i,
input		wire				BM1_Collision_On_i,
input		wire				BM1_Coll_Map_Display_En_i,
input		wire				COL_Collision_On_i,

input		wire	[2:0]		BM3_Layer_Lut_i,
input		wire				BM3_Collision_On_i,

input 	wire				TileL0Collision_On_i,
input 	wire				TileL1Collision_On_i,
input 	wire				TileL2Collision_On_i,
input 	wire				TileL3Collision_On_i,
// Tile MAP Pipe
input		wire	[7:0]		VGE_EffectChannel_TL_ADDY_i,
input		wire				VGE_Engine_TL0_WE_i,
input		wire				VGE_Engine_TL1_WE_i,
input		wire				VGE_Engine_TL2_WE_i,
input		wire				VGE_Engine_TL3_WE_i,
input		wire	[31:0]	Tile_Data_i,
input		wire	[7:0]		Tile_Attribute_i,
//input		wire	[2:0]		TileLUT_i,

input		wire	[4:0]		Tile0_X_Scroll_Reg_i,
input		wire	[4:0]		Tile1_X_Scroll_Reg_i,
input		wire	[4:0]		Tile2_X_Scroll_Reg_i,
input		wire	[4:0]		Tile3_X_Scroll_Reg_i,

// Output 
output	wire				Read_Pixel_Lines_o,
// Video Output Interface and Background
input		wire	[7:0]		Background_Blue_i,
input		wire	[7:0]		Background_Green_i,
input		wire	[7:0]		Background_Red_i,

output	wire	[31:0]	VGE_RGB_Pixel_o,

// CPU Interface
input		wire	[31:0]	Bus_A_i,
input		wire				Bus_A_Valid_i,
input		wire				Bus_RW_i,
input		wire	[3:0]		Bus_BE_i,
input		wire				Bus_WE_i,
input		wire	[7:0]		Bus_D8_i,
input		wire	[15:0]	Bus_D16_i,
input		wire	[31:0]	Bus_D32_i,
input		wire	[1:0]		Bus_D_Siz_i,

input		wire				CS_LUT0_i,

output	wire	[31:0]	DataOut_LUT_o,

output	wire				Sprite_Collision_Interrupt_o,
output	wire				Bitmap_Collision_Interrupt_o,
output	wire				Tilemap_Collision_Interrupt_o
);

wire	[7:0]	TileMap0_Pixel;
wire	[7:0]	TileMap1_Pixel;
wire	[7:0]	TileMap2_Pixel;
wire	[7:0]	TileMap3_Pixel;

wire 	[7:0] TileMap0_Attr;
wire 	[7:0] TileMap1_Attr;
wire 	[7:0] TileMap2_Attr;
wire 	[7:0] TileMap3_Attr;

reg	[9:0]	LayerScanAddress_Tile0;
reg	[9:0]	LayerScanAddress_Tile1;
reg	[9:0]	LayerScanAddress_Tile2;
reg	[9:0]	LayerScanAddress_Tile3;

reg	[7:0] Line1_Pixel_Out;
reg	[7:0] Line2_Pixel_Out;
reg	[7:0] Line3_Pixel_Out;
reg	[7:0] Line4_Pixel_Out;

reg	[7:0] Line0_Pixel_Dly_Out;
reg	[7:0] Line1_Pixel_Dly_Out;
reg	[7:0] Line2_Pixel_Dly_Out;
reg	[7:0] Line3_Pixel_Dly_Out;

reg	[7:0] Line1_Pixel_Col_Out;
reg	[7:0] Line2_Pixel_Col_Out;
reg	[7:0] Line3_Pixel_Col_Out;
reg	[7:0] Line4_Pixel_Col_Out;

reg	[7:0] Line1_Pixel_Col_Dly_Out;
reg	[7:0] Line2_Pixel_Col_Dly_Out;
reg	[7:0] Line3_Pixel_Col_Dly_Out;
reg	[7:0] Line4_Pixel_Col_Dly_Out;

reg 	[7:0] TileMap0_Attr_Out;
reg 	[7:0] TileMap1_Attr_Out;
reg 	[7:0] TileMap2_Attr_Out;
reg 	[7:0] TileMap3_Attr_Out;


reg 	[7:0] TileMap0_Attr_Dly_Out;
reg 	[7:0] TileMap1_Attr_Dly_Out;
reg 	[7:0] TileMap2_Attr_Dly_Out;
reg 	[7:0] TileMap3_Attr_Dly_Out;

reg 	[7:0] TileMap0_Attr_Col_Out;
reg 	[7:0] TileMap1_Attr_Col_Out;
reg 	[7:0] TileMap2_Attr_Col_Out;
reg 	[7:0] TileMap3_Attr_Col_Out;

reg 	[7:0] TileMap0_Attr_Col_Dly_Out;
reg 	[7:0] TileMap1_Attr_Col_Dly_Out;
reg 	[7:0] TileMap2_Attr_Col_Dly_Out;
reg 	[7:0] TileMap3_Attr_Col_Dly_Out;


// Overal 3 Clock Latency for BM/Sprites/Tiles
always @ (posedge EngineClk200Mhz_i)
begin
		Line0_Pixel_Dly_Out 	<= TileMap0_Pixel;		// 1 Clock Latency
		Line1_Pixel_Dly_Out 	<= TileMap1_Pixel;
		Line2_Pixel_Dly_Out 	<= TileMap2_Pixel;
		Line3_Pixel_Dly_Out 	<= TileMap3_Pixel;
		
		TileMap0_Attr_Dly_Out	<= TileMap0_Attr;
		TileMap1_Attr_Dly_Out	<= TileMap1_Attr;
		TileMap2_Attr_Dly_Out	<= TileMap2_Attr;
		TileMap3_Attr_Dly_Out	<= TileMap3_Attr;		
end

always @ (posedge EngineClk200Mhz_i)
begin
		Line1_Pixel_Out 	<= Line0_Pixel_Dly_Out;		// 1 Clock Latency
		Line2_Pixel_Out 	<= Line1_Pixel_Dly_Out;
		Line3_Pixel_Out 	<= Line2_Pixel_Dly_Out;
		Line4_Pixel_Out 	<= Line3_Pixel_Dly_Out;
		
		TileMap0_Attr_Out	<= TileMap0_Attr_Dly_Out;
		TileMap1_Attr_Out	<= TileMap1_Attr_Dly_Out;
		TileMap2_Attr_Out	<= TileMap2_Attr_Dly_Out;
		TileMap3_Attr_Out	<= TileMap3_Attr_Dly_Out;		
end

always @ (posedge EngineClk200Mhz_i)
begin
		Line1_Pixel_Col_Dly_Out 	<= TileMap0_Pixel;
		Line2_Pixel_Col_Dly_Out 	<= TileMap1_Pixel;
		Line3_Pixel_Col_Dly_Out 	<= TileMap2_Pixel;
		Line4_Pixel_Col_Dly_Out 	<= TileMap3_Pixel;
		
		TileMap0_Attr_Col_Dly_Out	<= TileMap0_Attr;
		TileMap1_Attr_Col_Dly_Out	<= TileMap1_Attr;
		TileMap2_Attr_Col_Dly_Out	<= TileMap2_Attr;
		TileMap3_Attr_Col_Dly_Out	<= TileMap3_Attr;		
end

always @ (posedge EngineClk200Mhz_i)
begin
		Line1_Pixel_Col_Out 	<= Line1_Pixel_Col_Dly_Out;
		Line2_Pixel_Col_Out 	<= Line2_Pixel_Col_Dly_Out;
		Line3_Pixel_Col_Out 	<= Line3_Pixel_Col_Dly_Out;
		Line4_Pixel_Col_Out 	<= Line4_Pixel_Col_Dly_Out;
		
		TileMap0_Attr_Col_Out	<= TileMap0_Attr_Col_Dly_Out;
		TileMap1_Attr_Col_Out	<= TileMap1_Attr_Col_Dly_Out;
		TileMap2_Attr_Col_Out	<= TileMap2_Attr_Col_Dly_Out;
		TileMap3_Attr_Col_Out	<= TileMap3_Attr_Col_Dly_Out;		
end



// Individual Counter for Every Pixel Line
always @ (posedge EngineClk200Mhz_i)
begin
	if (Read_Pixel_Lines)
		LayerScanAddress_Tile0 <= LayerScanAddress_Tile0 + 10'b00_0000_0001;
	else begin
		if (Tile0_X_Scroll_Reg_i[4])
			LayerScanAddress_Tile0 <= 10'b00_0001_1111 - {6'b00_0000, Tile0_X_Scroll_Reg_i[3:0]};
		else
			LayerScanAddress_Tile0 <= 10'b00_0010_0000 + {6'b00_0000, Tile0_X_Scroll_Reg_i[3:0]};		
	end
end

VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_Map0 (
// Pixel Out
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_Tile0 ), 
	.q ( TileMap0_Pixel ),		// 1 Clock Latency
// Packed Pixel In
	.data ( Tile_Data_i ),
	.wrclock( EngineClk100Mhz_i ), 
	.wraddress ( VGE_EffectChannel_TL_ADDY_i ), 
	.wren ( VGE_Engine_TL0_WE_i )
);

//TILE_ATTRIBUTE_MEM	TILE_Attributes_Map0 (
VICKYII_Pixel32_8Line	TILE_Attributes_Map0 (
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_Tile0 ), 
	.q ( TileMap0_Attr ),

	.data ( {Tile_Attribute_i, Tile_Attribute_i, Tile_Attribute_i, Tile_Attribute_i} ),
	.wrclock( EngineClk100Mhz_i ), 
	.wraddress ( VGE_EffectChannel_TL_ADDY_i ), 
	.wren ( VGE_Engine_TL0_WE_i )
);

always @ (posedge EngineClk200Mhz_i)
begin
	if (Read_Pixel_Lines)
		LayerScanAddress_Tile1 <= LayerScanAddress_Tile1 + 10'b00_0000_0001;
	else begin
		if (Tile1_X_Scroll_Reg_i[4])
			LayerScanAddress_Tile1 <= 10'b00_0001_1111 - {6'b00_0000, Tile1_X_Scroll_Reg_i[3:0]};
		else
			LayerScanAddress_Tile1 <= 10'b00_0010_0000 + {6'b00_0000, Tile1_X_Scroll_Reg_i[3:0]};		
	end
end

VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_Map1 (
// Pixel Out
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_Tile1 ), 
	.q ( TileMap1_Pixel ),	//TileMap1_Pixel_o
	
// Packed Pixel In
	.data ( Tile_Data_i ),
	.wrclock( EngineClk100Mhz_i ), 
	.wraddress ( VGE_EffectChannel_TL_ADDY_i ), 
	.wren ( VGE_Engine_TL1_WE_i )
);

VICKYII_Pixel32_8Line	TILE_Attributes_Map1 (
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_Tile1 ), 
	.q ( TileMap1_Attr ),

	//.data ( Tile_Attribute_i ),
	.data ( {Tile_Attribute_i, Tile_Attribute_i, Tile_Attribute_i, Tile_Attribute_i} ),	
	.wrclock( EngineClk100Mhz_i ), 
	.wraddress ( VGE_EffectChannel_TL_ADDY_i ), 
	.wren ( VGE_Engine_TL1_WE_i )
);


always @ (posedge EngineClk200Mhz_i)
begin
	if (Read_Pixel_Lines)
		LayerScanAddress_Tile2 <= LayerScanAddress_Tile2 + 10'b00_0000_0001;
	else begin
		if (Tile2_X_Scroll_Reg_i[4])
			LayerScanAddress_Tile2 <= 10'b00_0001_1111 - {6'b00_0000, Tile2_X_Scroll_Reg_i[3:0]};
		else
			LayerScanAddress_Tile2 <= 10'b00_0010_0000 + {6'b00_0000, Tile2_X_Scroll_Reg_i[3:0]};		
	end
end

VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_Map2 (
// Pixel Out
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_Tile2 ), 
	.q ( TileMap2_Pixel ),	//TileMap2_Pixel_o
// Packed Pixel In
	.data ( Tile_Data_i ),
	.wrclock( EngineClk100Mhz_i ), 
	.wraddress ( VGE_EffectChannel_TL_ADDY_i ), 
	.wren ( VGE_Engine_TL2_WE_i )
);

VICKYII_Pixel32_8Line	TILE_Attributes_Map2 (
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_Tile2 ), 
	.q ( TileMap2_Attr ),

	//.data ( Tile_Attribute_i ),
	.data ( {Tile_Attribute_i, Tile_Attribute_i, Tile_Attribute_i, Tile_Attribute_i} ),	
	.wrclock( EngineClk100Mhz_i ), 
	.wraddress ( VGE_EffectChannel_TL_ADDY_i ), 
	.wren ( VGE_Engine_TL2_WE_i )
);


always @ (posedge EngineClk200Mhz_i)
begin
	if (Read_Pixel_Lines)
		LayerScanAddress_Tile3 <= LayerScanAddress_Tile3 + 10'b00_0000_0001;
	else begin
		if (Tile3_X_Scroll_Reg_i[4])
			LayerScanAddress_Tile3 <= 10'b00_0001_1111 - {6'b00_0000, Tile3_X_Scroll_Reg_i[3:0]};
		else
			LayerScanAddress_Tile3 <= 10'b00_0010_0000 + {6'b00_0000, Tile3_X_Scroll_Reg_i[3:0]};		
	end
end

VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_Map3 (
// Pixel Out
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_Tile3 ), 
	.q ( TileMap3_Pixel ),	//TileMap3_Pixel_o
// Packed Pixel In
	.data ( Tile_Data_i ),
	.wrclock( EngineClk100Mhz_i ),
	.wraddress ( VGE_EffectChannel_TL_ADDY_i ), 
	.wren ( VGE_Engine_TL3_WE_i )
);

VICKYII_Pixel32_8Line	TILE_Attributes_Map3 (
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_Tile3 ), 
	.q ( TileMap3_Attr ),

	//.data ( Tile_Attribute_i ),
	.data ( {Tile_Attribute_i, Tile_Attribute_i, Tile_Attribute_i, Tile_Attribute_i} ),	
	.wrclock( EngineClk100Mhz_i ), 
	.wraddress ( VGE_EffectChannel_TL_ADDY_i ), 
	.wren ( VGE_Engine_TL3_WE_i )
);


VickyII_Collision_System_Module  CollisionSystemModule(
	.VideoRst_200Mhz_i( Reset_200Mhz_i ),
	.VideoModeReset_200Mhz_i( VideoModeReset_200Mhz_i ),
	.EngineClk200Mhz_i(EngineClk200Mhz_Aux_i),
	.Mstr_Ctrl_Video_Mode100Mhz_i( Mstr_Ctrl_Video_Mode100Mhz_i ),
	.Mstr_Ctrl_Doubling_Pixel_100Mhz_i( Mstr_Ctrl_Doubling_Pixel_100Mhz_i ), 
	.Read_Pixel_Lines_i( Read_Pixel_Lines ), 
// Sprite MAP  Pixel
	.Sprite_Data_Col_i( Sprite_Data_Col_i ),
	.Attributes_Data_Col_i( Attributes_Data_Col_i ),
// Bitmap & Collision Map Pixel
	.BitMap0_Pixel_Col_i( BitMap0_Pixel_Col_i ),
	.BitMap1_Pixel_Col_i( BitMap1_Pixel_Col_i ),
	.Collision_Data_Col_i( Collision_Data_Col_i ),
// Tile Layer Map INput Pixel
	.Line1_Pixel_Col_i( Line1_Pixel_Col_Out ),
	.Line2_Pixel_Col_i( Line2_Pixel_Col_Out ),
	.Line3_Pixel_Col_i( Line3_Pixel_Col_Out ),
	.Line4_Pixel_Col_i( Line4_Pixel_Col_Out ),

	.BM0_Collision_On_i( BM0_Collision_On_i ),
	.BM1_Collision_On_i( BM1_Collision_On_i ),
	.COL_Collision_On_i( COL_Collision_On_i ),
	
	.TileMap0_Attr_Col_i( TileMap0_Attr_Col_Out ),
	.TileMap1_Attr_Col_i( TileMap1_Attr_Col_Out ),
	.TileMap2_Attr_Col_i( TileMap2_Attr_Col_Out ),
	.TileMap3_Attr_Col_i( TileMap3_Attr_Col_Out ),	
	
	.TileL0Collision_On_i( TileL0Collision_On_i ),	
	.TileL1Collision_On_i( TileL1Collision_On_i ),	
	.TileL2Collision_On_i( TileL2Collision_On_i ),	
	.TileL3Collision_On_i( TileL3Collision_On_i ),
	
// Pixel Present Flags
	.Sprite_Pixel_Not_Zero_i( Sprite_Pixel_Not_Zero ),
	.BM0_Pixel_Not_Zero_i( BM0_Pixel_Not_Zero ),
	.BM1_Pixel_Not_Zero_i( BM1_Pixel_Not_Zero ),
	.COL_Pixel_Not_Zero_i( COL_Pixel_Not_Zero ),
	.TL0_Pixel_Not_Zero_i( TL0_Pixel_Not_Zero ),
	.TL1_Pixel_Not_Zero_i( TL1_Pixel_Not_Zero ),
	.TL2_Pixel_Not_Zero_i( TL2_Pixel_Not_Zero ),	
	.TL3_Pixel_Not_Zero_i( TL3_Pixel_Not_Zero ),

// Incoming Mask for the Collision System
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
	.Collision_VideoLine_Active_i( Collision_VideoLine_Active_i ),
	.Collision_Y_Location_o( Collision_Y_Location_o ),
	.Collision_Sprite_X_Location_o( Collision_Sprite_X_Location_o ),
	.Collision_Bitmap_X_Location_o( Collision_Bitmap_X_Location_o ),
	.Collision_Tiles_X_Location_o( Collision_Tiles_X_Location_o ),

	.Sprite_Collision_Interrupt_o( Sprite_Collision_Interrupt_o ),
	.Bitmap_Collision_Interrupt_o( Bitmap_Collision_Interrupt_o ),
	.Tilemap_Collision_Interrupt_o( Tilemap_Collision_Interrupt_o )
);

// Code to Sort out what pixel will be displayed.

wire	[13:0] 	PixelPresent;
wire	[13:0] 	PixelPresent_Collision;
reg	[11:0]	DisplayedPixelOut;

wire 				Sprite_Collision_On;
wire				Tile_Layer0_Collision_On;
wire				Tile_Layer1_Collision_On;
wire				Tile_Layer2_Collision_On;
wire				Tile_Layer3_Collision_On;
wire				BM0_Collision_On;
wire				BM1_Collision_On;




reg	[6:0]	Sprite_Channel;


wire				Sprite_Pixel_Not_Zero;
wire				BM0_Pixel_Not_Zero;
wire				BM1_Pixel_Not_Zero;
wire				COL_Pixel_Not_Zero;
wire				TL0_Pixel_Not_Zero;
wire				TL1_Pixel_Not_Zero;
wire 				TL2_Pixel_Not_Zero;
wire 				TL3_Pixel_Not_Zero;
wire				BM3_Pixel_Not_Zero;
/*
always @ (posedge  EngineClk200Mhz_i) begin
	Sprite_Pixel_Not_Zero 	<= ( SpriteLine_Pixel_Out_i[7:0] == 8'h00 )	? 1'b0 : 1'b1;
	BM0_Pixel_Not_Zero 		<= ( Line0_Pixel_Out_i[7:0] == 8'h00 ) 	? 1'b0 : 1'b1;
	TL0_Pixel_Not_Zero 		<= ( Line1_Pixel_Out[7:0] == 8'h00 ) 		? 1'b0 : 1'b1;	
	TL1_Pixel_Not_Zero 		<= ( Line2_Pixel_Out[7:0] == 8'h00 ) 		? 1'b0 : 1'b1;	
	TL2_Pixel_Not_Zero 		<= ( Line3_Pixel_Out[7:0] == 8'h00 ) 		? 1'b0 : 1'b1;	
	TL3_Pixel_Not_Zero 		<= ( Line4_Pixel_Out[7:0] == 8'h00 ) 		? 1'b0 : 1'b1;	
	BM1_Pixel_Not_Zero 		<= ( Line5_Pixel_Out_i[7:0] == 8'h00 ) 	? 1'b0 : 1'b1;
	COL_Pixel_Not_Zero   	<= ( Line6_Pixel_Out_i[7:0] == 8'h00 ) 	? 1'b0 : 1'b1;
end
*/

assign 	Sprite_Pixel_Not_Zero 	= ( SpriteLine_Pixel_Out_i[7:0] == 8'h00 )	? 1'b0 : 1'b1;
assign 	BM0_Pixel_Not_Zero 		= ( Line0_Pixel_Out_i[7:0] == 8'h00 ) 	? 1'b0 : 1'b1;
assign 	TL0_Pixel_Not_Zero 		= ( Line1_Pixel_Out[7:0] == 8'h00 ) 		? 1'b0 : 1'b1;	
assign 	TL1_Pixel_Not_Zero 		= ( Line2_Pixel_Out[7:0] == 8'h00 ) 		? 1'b0 : 1'b1;	
assign 	TL2_Pixel_Not_Zero 		= ( Line3_Pixel_Out[7:0] == 8'h00 ) 		? 1'b0 : 1'b1;	
assign 	TL3_Pixel_Not_Zero 		= ( Line4_Pixel_Out[7:0] == 8'h00 ) 		? 1'b0 : 1'b1;	
assign 	BM1_Pixel_Not_Zero 		= ( Line5_Pixel_Out_i[7:0] == 8'h00 ) 	? 1'b0 : 1'b1;
assign 	COL_Pixel_Not_Zero   	= ( Line6_Pixel_Out_i[7:0] == 8'h00 ) 	? 1'b0 : 1'b1;
assign   BM3_Pixel_Not_Zero      = ( Line8_Pixel_Out_i[7:0] == 8'h00 )  ? 1'b0 : 1'b1;


//	.data( { Sprite_X_Position, 3'b000, Sprite_Collision_On, Sprite_Active_Channel_o, Sprite_Depth, Sprite_LUT } ),		// 6, 3, 3 = 12 Bits 

//3'b000, Sprite_Collision_On, Sprite_Active_Channel_o, Sprite_Depth, Sprite_LUT
assign PixelPresent[13]	= BM3_Pixel_Not_Zero;
assign PixelPresent[12]	= (SpriteLine_Attributes_Out_i[5:3] == 3'b000) && Sprite_Pixel_Not_Zero;	// Sprite L0;
assign PixelPresent[11] = BM0_Pixel_Not_Zero;								// BM0
assign PixelPresent[10] = (SpriteLine_Attributes_Out_i[5:3] == 3'b001) && Sprite_Pixel_Not_Zero;	// Sprite L1
assign PixelPresent[9] 	= TL0_Pixel_Not_Zero;								// TL0
assign PixelPresent[8] 	= (SpriteLine_Attributes_Out_i[5:3] == 3'b010) && Sprite_Pixel_Not_Zero;	// Sprite L2
assign PixelPresent[7] 	= TL1_Pixel_Not_Zero;								// TL1
assign PixelPresent[6] 	= (SpriteLine_Attributes_Out_i[5:3] == 3'b011) && Sprite_Pixel_Not_Zero;	// Sprite L3
assign PixelPresent[5] 	= TL2_Pixel_Not_Zero;								// TL2
assign PixelPresent[4] 	= (SpriteLine_Attributes_Out_i[5:3] == 3'b100) && Sprite_Pixel_Not_Zero;	// Sprite L4
assign PixelPresent[3] 	= TL3_Pixel_Not_Zero;								// TL3
assign PixelPresent[2] 	= (SpriteLine_Attributes_Out_i[5:3] == 3'b101) && Sprite_Pixel_Not_Zero;	// Sprite L5
assign PixelPresent[1] 	= BM1_Pixel_Not_Zero;								// BM1
assign PixelPresent[0] 	= (SpriteLine_Attributes_Out_i[5:3] == 3'b110) && Sprite_Pixel_Not_Zero;	// Sprite L6

// This makes an association between the Priority and LUT
/*
always @ (posedge EngineClk200Mhz_i)
begin
	casex (PixelPresent)
		14'b1x_xxxx_xxxx_xxxx: DisplayedPixelOut <= {2'b10, 3'b000, Line6_Pixel_Out_i[7:0]}; 	
		14'b01_xxxx_xxxx_xxxx: DisplayedPixelOut <= {2'b00, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};	 // TOP - FOREGROUND
		14'b00_1xxx_xxxx_xxxx: DisplayedPixelOut <= {2'b00, BM0_Layer_Lut_i[2:0], Line0_Pixel_Out_i[7:0]};	
		14'b00_01xx_xxxx_xxxx: DisplayedPixelOut <= {2'b00, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};	
		14'b00_001x_xxxx_xxxx: DisplayedPixelOut <= {2'b00, TileMap0_Attr_Out[2:0], Line1_Pixel_Out[7:0]};
		14'b00_0001_xxxx_xxxx: DisplayedPixelOut <= {2'b00, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		14'b00_0000_1xxx_xxxx: DisplayedPixelOut <= {2'b00, TileMap1_Attr_Out[2:0], Line2_Pixel_Out[7:0]};
		14'b00_0000_01xx_xxxx: DisplayedPixelOut <= {2'b00, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		14'b00_0000_001x_xxxx: DisplayedPixelOut <= {2'b00, TileMap2_Attr_Out[2:0], Line3_Pixel_Out[7:0]};
		14'b00_0000_0001_xxxx: DisplayedPixelOut <= {2'b00, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		14'b00_0000_0000_1xxx: DisplayedPixelOut <= {2'b00, TileMap3_Attr_Out[2:0], Line4_Pixel_Out[7:0]};
		14'b00_0000_0000_01xx: DisplayedPixelOut <= {2'b00, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		14'b00_0000_0000_001x: DisplayedPixelOut <= {2'b00, BM1_Layer_Lut_i[2:0], Line5_Pixel_Out_i[7:0]}; 
		14'b00_0000_0000_0001: DisplayedPixelOut <= {2'b00, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]}; // BOTTOM - BACKGROUND
		14'b00_0000_0000_0000: DisplayedPixelOut <= {2'b01, 3'b000, 8'b0000_0000};
		default: begin
		end
	endcase
end
*/

always @ (posedge EngineClk200Mhz_i)
begin
	casex (PixelPresent)
		14'b1x_xxxx_xxxx_xxxx: DisplayedPixelOut <= {1'b0, BM3_Layer_Lut_i[2:0], Line8_Pixel_Out_i[7:0]};		 // TOP - TOP  - FOREGROUND (VBANK B)
		14'b01_xxxx_xxxx_xxxx: DisplayedPixelOut <= {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};	 // TOP - FOREGROUND
		14'b00_1xxx_xxxx_xxxx: DisplayedPixelOut <= {1'b0, BM0_Layer_Lut_i[2:0], Line0_Pixel_Out_i[7:0]};	
		14'b00_01xx_xxxx_xxxx: DisplayedPixelOut <= {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};	
		14'b00_001x_xxxx_xxxx: DisplayedPixelOut <= {1'b0, TileMap0_Attr_Out[2:0], Line1_Pixel_Out[7:0]};
		14'b00_0001_xxxx_xxxx: DisplayedPixelOut <= {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		14'b00_0000_1xxx_xxxx: DisplayedPixelOut <= {1'b0, TileMap1_Attr_Out[2:0], Line2_Pixel_Out[7:0]};
		14'b00_0000_01xx_xxxx: DisplayedPixelOut <= {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		14'b00_0000_001x_xxxx: DisplayedPixelOut <= {1'b0, TileMap2_Attr_Out[2:0], Line3_Pixel_Out[7:0]};
		14'b00_0000_0001_xxxx: DisplayedPixelOut <= {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		14'b00_0000_0000_1xxx: DisplayedPixelOut <= {1'b0, TileMap3_Attr_Out[2:0], Line4_Pixel_Out[7:0]};
		14'b00_0000_0000_01xx: DisplayedPixelOut <= {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		14'b00_0000_0000_001x: DisplayedPixelOut <= {1'b0, BM1_Layer_Lut_i[2:0], Line5_Pixel_Out_i[7:0]}; 
		14'b00_0000_0000_0001: DisplayedPixelOut <= {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]}; // BOTTOM - BACKGROUND
		14'b00_0000_0000_0000: DisplayedPixelOut <= {1'b1, 3'b000, 8'b0000_0000};
		default: begin		
		end
	endcase
end


/*
wire 	[71:0]		CS;
wire					Trigger_In;

//assign Trigger_In = Txf_Done;
//assign Trigger_In = CS_Txt_Background_Plt | CS_Txt_Foreground_Plt;
assign Trigger_In = Read_Pixel_Lines;

assign CS[12:00] 	= PixelPresent;
assign CS[20:13]  = WriteEnableLatency;
assign CS[32:21]  = DisplayedPixelOut_ReSync;
assign CS[64:33]  = LUT_RGB_Pixel_Output;
assign CS[65] 		= DisplayedPixelOut_Dly[1];
assign CS[66]     = Read_Pixel_Lines;
assign CS[71:67]  = 0;



ChipScope u0 (
	.acq_data_in    (CS),    //        tap.acq_data_in
	.acq_trigger_in (Trigger_In), //           .acq_trigger_in
	.acq_clk        (EngineClk200Mhz_i),        //    acq_clk.clk
	.trigger_in     (Trigger_In)      // trigger_in.trigger_in
);
*/


reg	[11:0]	DisplayedPixelOut_ReSync;

always @ (posedge EngineClk200Mhz_i)
begin
	DisplayedPixelOut_ReSync <= DisplayedPixelOut;

end

reg	[31:0]	LUT_RGB_Pixel_Output;
wire  [31:0] 	LUT_Table_Out;

// THis is the Output from

reg [1:0] DisplayedPixelOut_Dly;

always @ (posedge EngineClk200Mhz_i)
begin
	DisplayedPixelOut_Dly[0] <= DisplayedPixelOut_ReSync[11];
	DisplayedPixelOut_Dly[1] <= DisplayedPixelOut_Dly[0];	
end

reg [31:0] BackGround_Dly0, BackGround_Dly1, BackGround_Dly2;

always @ (posedge EngineClk200Mhz_i)
begin
	BackGround_Dly0 <= {8'h00, Background_Red_i, Background_Green_i, Background_Blue_i};
	BackGround_Dly1 <= BackGround_Dly0;
	if ( BackGround_Dly1 == BackGround_Dly0 )
		BackGround_Dly2 <= BackGround_Dly1;
end

assign DataOut_LUT_o = {LUT_Output_8Bits, LUT_Output_8Bits, LUT_Output_8Bits, LUT_Output_8Bits};

wire [7:0] LUT_Output_8Bits;

LUT32	LUT32_0 (
	// CPU Side
	.clock_a ( Bus_Clk_i ),
	.address_a ( Bus_A_i[12:0] ),
	.wren_a ( CS_LUT0_i & !Bus_RW_i & (Bus_D_Siz_i[1:0] == 2'b01) & Bus_WE_i ),	
	.data_a ( Bus_D8_i ),
	.q_a ( LUT_Output_8Bits ),

	// 200Mhz Side
	.clock_b ( EngineClk200Mhz_i ),
	.address_b ( DisplayedPixelOut_ReSync[10:0] ),
	.wren_b ( 1'b0 ),	
	.data_b ( 32'h0000_0000 ),		
	.q_b ( LUT_Table_Out )
	);

	
always @ (posedge EngineClk200Mhz_i)
begin	
	LUT_RGB_Pixel_Output <= DisplayedPixelOut_Dly[1] ? BackGround_Dly2 : LUT_Table_Out;
end

reg [7:0] WriteEnableLatency;

assign Read_Pixel_Lines_o = Read_Pixel_Lines;

// Delay the Pixel Attributes
always @ (posedge EngineClk200Mhz_i)
begin
	WriteEnableLatency[0] <= Read_Pixel_Lines;
	WriteEnableLatency[1] <= WriteEnableLatency[0];	// Read Pixel Line is Valid Here
	WriteEnableLatency[2] <= WriteEnableLatency[1];
	WriteEnableLatency[3] <= WriteEnableLatency[2];	
	WriteEnableLatency[4] <= WriteEnableLatency[3];
	WriteEnableLatency[5] <= WriteEnableLatency[4];
	WriteEnableLatency[6] <= WriteEnableLatency[5];
	WriteEnableLatency[7] <= WriteEnableLatency[6];		
end

reg	[3:0] 	PIXEL_TF_SM;
reg				Read_Pixel_Lines;
reg	[9:0]	 	Memory_Pixel_Pointer;
reg			 	Memory_WriteEnable;

localparam		IDLE_PIXEL	= 4'b0000,
					READ 			= 4'b0001,
					READ_LAT0	= 4'b0010,
					READ_LAT1	= 4'b0011,
					READ_LAT2	= 4'b0100,	
					LOOP 			= 4'b0101,
					WRITE			= 4'b0110,
					WRITE_LAT0  = 4'b0111,
					WRITE_LAT1  = 4'b1000,
					WRITE_LAT2  = 4'b1001,
					DONE			= 4'b1010;
						
always @ (posedge EngineClk200Mhz_i)
begin
		
	if (WriteEnableLatency[6])
		Memory_Pixel_Pointer <= Memory_Pixel_Pointer + 10'b00_0000_0001;
	else
		Memory_Pixel_Pointer <=  10'b00_0010_0000;
end

/*
reg [15:0] Horizontal_Border_i_EDGE;

always @ (posedge EngineClk200Mhz_i)
begin
		Horizontal_Border_i_EDGE <= {Horizontal_Border_i_EDGE[15:1], HBlanking_i} << 1'b1;
end
*/

// This is the Process to Transfer Line Pixels in Output RGB Pixel Line
always @ (posedge EngineClk200Mhz_i)
begin
	if ( Reset_200Mhz_i || VideoModeReset_200Mhz_i ) begin
		PIXEL_TF_SM <= IDLE_PIXEL;
		Read_Pixel_Lines <= 1'b0;
	end
	else begin
	
		case (PIXEL_TF_SM)
		
		IDLE_PIXEL: begin
			//if ({IID_Engine_Captured_Lines_Done_EDGE, IID_Engine_Captured_Lines_Done_i} == 2'b01) begin
			//if (Horizontal_Border_i_EDGE[15:0] == 16'hFFF0) begin
			if (Time_Trf_Pixels_2_Pixel_200Mhz_i) begin
				Read_Pixel_Lines <= 1'b1;
				PIXEL_TF_SM <= WRITE;
			end
			else begin
//				Memory_WriteEnable <= 1'b0;
				Read_Pixel_Lines <= 1'b0;
				PIXEL_TF_SM <= IDLE_PIXEL;
			end
		end
		
		WRITE: begin
			if (Memory_Pixel_Pointer < BM_Line_Sizes_i)
					PIXEL_TF_SM <= WRITE;
			else begin
					PIXEL_TF_SM <= DONE;
					Read_Pixel_Lines <= 1'b0;		
			end
		end
		
		DONE: begin
			PIXEL_TF_SM <= IDLE_PIXEL;		
		end
		
		
		default: begin
			PIXEL_TF_SM <= IDLE_PIXEL;
		end
		endcase
	end
end

Final_RGB_Pixel_Line OUTPUT_RGB(

	.rdaddress( Video_Pixel_Pointer ),
	.rdclock( VideoClk_i ),
	.q( VGE_RGB_Pixel_o ),
	
	.data( LUT_RGB_Pixel_Output ),
	.wraddress( Memory_Pixel_Pointer ),
	.wrclock( EngineClk200Mhz_i ),
	.wren( WriteEnableLatency[6] )

);
/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger1 = Time_Trf_Pixels_2_Pixel_200Mhz_i ;

assign TinyTP1[10:0]  	= DisplayedPixelOut_ReSync[10:0];
assign TinyTP1[21:11]	= Memory_Pixel_Pointer;
assign TinyTP1[22]		= WriteEnableLatency[6];
assign TinyTP1[23]		= DisplayedPixelOut_ReSync[11];
assign TinyTP1[55:24] 	= LUT_RGB_Pixel_Output;

TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (EngineClk200Mhz_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/

reg	[9:0]		Video_Pixel_Pointer;

always @ (posedge VideoClk_i)
begin
	if ( Reset_VideoClkOut_i || VideoModeReset_i ) begin
		Video_Pixel_Pointer <= 10'b00_0000_0000;	
	end
	else begin
		//if (Time_2_Display_Line_VidClk_i) begin
		if (HBlanking_VGE_Lat_i && VBlanking_i) begin
			Video_Pixel_Pointer <= Video_Pixel_Pointer + 10'b00_0000_0001;
		end
		else begin
			Video_Pixel_Pointer <= 10'd32;
		end
	end
end
/*
wire [71:0] TinyTP2;
wire 			TinyTrigger2;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger2 = HBlanking_VGE_Lat_i && VBlanking_i ;

assign TinyTP2[9:0]  	= Video_Pixel_Pointer[9:0];
assign TinyTP2[63:32] 	= VGE_RGB_Pixel_o;

TinyChipScope u2 (
	.acq_data_in    (TinyTP2),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger2), //           .acq_trigger_in
	.acq_clk        (VideoClk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger2)      // trigger_in.trigger_in
);
*/






endmodule

/*
//assign PixelPresent[12]	= (SpriteLine_Attributes_Out[6:4] == 3'b000) && (SpriteLine_Pixel_Out) ? 1'b1 : 1'b0;	// Sprite L0
assign PixelPresent[12]	= 1'b0;
assign PixelPresent[11] = Line0_Pixel_Out_i[7:0] ? 1'b1 : 1'b0;								// BM0
assign PixelPresent[10] = (SpriteLine_Attributes_Out_i[6:4] == 3'b001) && (SpriteLine_Pixel_Out_i) ? 1'b1 : 1'b0;	// Sprite L1
assign PixelPresent[9] 	= Line1_Pixel_Out_i[7:0] ? 1'b1 : 1'b0;								// TL0
assign PixelPresent[8] 	= (SpriteLine_Attributes_Out_i[6:4] == 3'b010) && (SpriteLine_Pixel_Out_i) ? 1'b1 : 1'b0;	// Sprite L2
assign PixelPresent[7] 	= Line2_Pixel_Out_i[7:0] ? 1'b1 : 1'b0;								// TL1
assign PixelPresent[6] 	= (SpriteLine_Attributes_Out_i[6:4] == 3'b011) && (SpriteLine_Pixel_Out_i) ? 1'b1 : 1'b0;	// Sprite L3
assign PixelPresent[5] 	= Line3_Pixel_Out_i[7:0] ? 1'b1 : 1'b0;								// TL2
assign PixelPresent[4] 	= (SpriteLine_Attributes_Out_i[6:4] == 3'b100) && (SpriteLine_Pixel_Out_i) ? 1'b1 : 1'b0;	// Sprite L4
assign PixelPresent[3] 	= Line4_Pixel_Out_i[7:0] ? 1'b1 : 1'b0;								// TL3
assign PixelPresent[2] 	= (SpriteLine_Attributes_Out_i[6:4] == 3'b101) && (SpriteLine_Pixel_Out_i) ? 1'b1 : 1'b0;	// Sprite L5
assign PixelPresent[1] 	= Line5_Pixel_Out_i[7:0] ? 1'b1 : 1'b0;								// BM1
assign PixelPresent[0] 	= (SpriteLine_Attributes_Out_i[6:4] == 3'b110) && (SpriteLine_Pixel_Out_i) ? 1'b1 : 1'b0;	// Sprite L6

// This makes an association between the Priority and LUT
always @ *
begin
	casex (PixelPresent)
		13'b1_xxxx_xxxx_xxxx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};	
		13'b0_1xxx_xxxx_xxxx: DisplayedPixelOut = {1'b0, BM0_Layer_Lut_i, Line0_Pixel_Out_i[7:0]};	
		13'b0_01xx_xxxx_xxxx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};	
		13'b0_001x_xxxx_xxxx: DisplayedPixelOut = {1'b0, TileMap0_LUT_i, Line1_Pixel_Out_i[7:0]};
		13'b0_0001_xxxx_xxxx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		13'b0_0000_1xxx_xxxx: DisplayedPixelOut = {1'b0, TileMap1_LUT_i, Line2_Pixel_Out_i[7:0]};
		13'b0_0000_01xx_xxxx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		13'b0_0000_001x_xxxx: DisplayedPixelOut = {1'b0, TileMap2_LUT_i, Line3_Pixel_Out_i[7:0]};
		13'b0_0000_0001_xxxx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		13'b0_0000_0000_1xxx: DisplayedPixelOut = {1'b0, TileMap3_LUT_i, Line4_Pixel_Out_i[7:0]};
		13'b0_0000_0000_01xx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		13'b0_0000_0000_001x: DisplayedPixelOut = {1'b0, BM1_Layer_Lut_i, Line5_Pixel_Out_i[7:0]};
		13'b0_0000_0000_0001: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out_i[2:0], SpriteLine_Pixel_Out_i[7:0]};
		13'b0_0000_0000_0000: DisplayedPixelOut = {1'b1, 3'b000, 8'b0000_0000};
		default: begin end
	endcase
end
*/

/*
// Sprite Level 0
always @ (*) begin
	if (( SP0_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel0_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b000_0001};
	end
	else begin
		SpriteLevel0_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 1
always @ (*) begin
	if (( SP1_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel1_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b000_0010};
	end
	else begin
		SpriteLevel1_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 2
always @ (*) begin
	if (( SP2_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel2_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b000_0100};
	end
	else begin
		SpriteLevel2_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 3
always @ (*) begin
	if (( SP3_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel3_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b000_1000};
	end
	else begin
		SpriteLevel3_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 4
always @ (*) begin
	if (( SP4_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel4_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b001_0000};
	end
	else begin
		SpriteLevel4_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 5
always @ (*) begin
	if (( SP5_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel5_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b010_0000};
	end
	else begin
		SpriteLevel5_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 6
always @ (*) begin
	if (( SP6_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel6_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b100_0000};
	end
	else begin
		SpriteLevel6_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
	end
end

*/

/*
// BM0
always @ (*) begin
	if (( BM0_Pixel_Present ) & ( Tile_Amalgamate | Sprite_Channel[6] | Sprite_Channel[5] | Sprite_Channel[4] | Sprite_Channel[3] | Sprite_Channel[2] | Sprite_Channel[1] | Sprite_Channel[0]))
		Bitmap0_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, 3'b001, Sprite_Channel};
	else
		Bitmap0_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
end

// BM1
always @ (*) begin
	if (( BM1_Pixel_Present ) & ( Tile_Amalgamate | Sprite_Channel[6] | Sprite_Channel[5] | Sprite_Channel[4] | Sprite_Channel[3] | Sprite_Channel[2] | Sprite_Channel[1] | Sprite_Channel[0]))
		Bitmap1_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, 3'b010, Sprite_Channel};
	else
		Bitmap1_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
end

// COL

always @ (*) begin
	if (( COL_Pixel_Present ) & ( Tile_Amalgamate | Sprite_Channel[6] | Sprite_Channel[5] | Sprite_Channel[4] | Sprite_Channel[3] | Sprite_Channel[2] | Sprite_Channel[1] | Sprite_Channel[0]))
		ColmapX_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, 3'b100, Sprite_Channel};
	else
		ColmapX_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
end

*/

/*
//Tile Maps inter Layer Collision
always @ (*) begin
	if (( TL0_Pixel_Present ) & ( TL3_Pixel_Present | TL2_Pixel_Present | TL1_Pixel_Present ))
		TileMap0_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, 1'b1, 10'b000_0000000};
	else
		TileMap0_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
end

always @ (*) begin
	if (( TL1_Pixel_Present ) & ( TL3_Pixel_Present | TL2_Pixel_Present | TL0_Pixel_Present ))
		TileMap1_Collision_Found = {TL3_Pixel_Present, TL2_Pixel_Present, 1'b1, TL0_Pixel_Present, 10'b000_0000000};
	else
		TileMap1_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
end

always @ (*) begin
	if (( TL2_Pixel_Present ) & ( TL3_Pixel_Present | TL1_Pixel_Present | TL0_Pixel_Present ))
		TileMap2_Collision_Found = {TL3_Pixel_Present, 1'b1, TL1_Pixel_Present, TL0_Pixel_Present, 10'b000_0000000};
	else
		TileMap2_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
end

always @ (*) begin
	if (( TL3_Pixel_Present ) & ( TL2_Pixel_Present | TL1_Pixel_Present | TL0_Pixel_Present ))
		TileMap3_Collision_Found = {1'b1, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, 10'b000_0000000};
	else
		TileMap3_Collision_Found = {4'b0000, 3'b000, 7'b0000000};
end
*/