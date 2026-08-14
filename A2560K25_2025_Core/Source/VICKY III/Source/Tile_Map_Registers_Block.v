`timescale 1 ns / 1 ns
module Tile_Map_Registers_Block(
input 	wire				rst_i,				// This is async Reset

input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,

// CPU Signals Interface
input 	wire				Bus_Clk_i,
input 	wire	[31:0]	Bus_A_i,
input		wire				Bus_A_Valid_i,

input		wire	[7:0]		Bus_D8_i,
input		wire	[15:0]	Bus_D16_i,
input		wire	[31:0]	Bus_D32_i,
input		wire	[1:0]		Bus_D_Siz_i,

input		wire				Bus_RW_i,
input		wire	[3:0]		Bus_BE_i,
input		wire				Bus_WE_i,
input		wire				Tile_MAP_CS_i,
input		wire				Tile_Data_CS_i,
output	wire	[31:0]	Bus_D0_o,
output	wire	[31:0]	Bus_D1_o,

// Layer0 Information
output	wire	[7:0]		TileMap0_Control_Reg_o,
output	wire	[22:0]	TileMap0_Addy_o,
output	wire	[9:0]		TileMap0_X_TotalSize_o,		// Size of the Square of the whole Map Max 1024 Position (54)
output	wire	[9:0]		TileMap0_Y_TotalSize_o,		// Size of the Square of the whole Map Max 1024 Position
output	wire	[9:0]		TileMap0_X_Window_Pos_o,	// Window Position
output	wire	[9:0]		TileMap0_Y_Window_Pos_o,	// Window Position
output	wire	[4:0]		TileMap0_X_Scroll_o,
output	wire	[4:0]		TileMap0_Y_Scroll_o,
// Layer1 Information
output	wire	[7:0]		TileMap1_Control_Reg_o,
output	wire	[22:0]	TileMap1_Addy_o,
output	wire	[9:0]		TileMap1_X_TotalSize_o,		// Size of the Square of the whole Map Max 1024 Position (54)
output	wire	[9:0]		TileMap1_Y_TotalSize_o,		// Size of the Square of the whole Map Max 1024 Position
output	wire	[9:0]		TileMap1_X_Window_Pos_o,	// Window Position
output	wire	[9:0]		TileMap1_Y_Window_Pos_o,	// Window Position
output	wire	[4:0]		TileMap1_X_Scroll_o,
output	wire	[4:0]		TileMap1_Y_Scroll_o,
// Layer2 Information,
output	wire	[7:0]		TileMap2_Control_Reg_o,
output	wire	[22:0]	TileMap2_Addy_o,
output	wire	[9:0]		TileMap2_X_TotalSize_o,		// Size of the Square of the whole Map Max 1024 Position (54)
output	wire	[9:0]		TileMap2_Y_TotalSize_o,		// Size of the Square of the whole Map Max 1024 Position
output	wire	[9:0]		TileMap2_X_Window_Pos_o,	// Window Position
output	wire	[9:0]		TileMap2_Y_Window_Pos_o,	// Window Position
output	wire	[4:0]		TileMap2_X_Scroll_o,
output	wire	[4:0]		TileMap2_Y_Scroll_o,
// Layer3 Information
output	wire	[7:0]		TileMap3_Control_Reg_o,
output	wire	[22:0]	TileMap3_Addy_o,
output	wire	[9:0]		TileMap3_X_TotalSize_o,		// Size of the Square of the whole Map Max 1024 Position (54)
output	wire	[9:0]		TileMap3_Y_TotalSize_o,		// Size of the Square of the whole Map Max 1024 Position
output	wire	[9:0]		TileMap3_X_Window_Pos_o,	// Window Position
output	wire	[9:0]		TileMap3_Y_Window_Pos_o,	// Window Position
output	wire	[4:0]		TileMap3_X_Scroll_o,
output	wire	[4:0]		TileMap3_Y_Scroll_o,

output	wire	[22:0]	TileSet0Addy_o,
output	wire	[22:0]	TileSet1Addy_o,
output	wire	[22:0]	TileSet2Addy_o,
output	wire	[22:0]	TileSet3Addy_o,
output	wire	[22:0]	TileSet4Addy_o,
output	wire	[22:0]	TileSet5Addy_o,
output	wire	[22:0]	TileSet6Addy_o,
output	wire	[22:0]	TileSet7Addy_o,

output	wire	[3:0]		TileSet0_CFG_o,
output	wire	[3:0]		TileSet1_CFG_o,
output	wire	[3:0]		TileSet2_CFG_o,
output	wire	[3:0]		TileSet3_CFG_o,
output	wire	[3:0]		TileSet4_CFG_o,
output	wire	[3:0]		TileSet5_CFG_o,
output	wire	[3:0]		TileSet6_CFG_o,
output	wire	[3:0]		TileSet7_CFG_o

);

assign Bus_D0_o = 32'h11111111;
assign Bus_D1_o = 32'h12121212;

reg [31:0]		TILE_REG[0:15];

reg [31:0]		TILE_DAT_REG[0:7];

//assign Bus_D_o = VICKY_MASTER_REG[Bus_A_i[4:0]];

// Writing Part
always @ (posedge Bus_Clk_i)
begin
	if (rst_i)
	begin
		TILE_REG[0]  <= 32'h0000_0000; // TileMap 0
		TILE_REG[1]  <= 32'h0000_0000; // TileMap 0
		TILE_REG[2]  <= 32'h0000_0000; // TileMap 0
		TILE_REG[3]  <= 32'h0000_0000; // TileMap 0
		
		TILE_REG[4]  <= 32'h0000_0000; // TileMap 1
		TILE_REG[5]  <= 32'h0000_0000; // TileMap 1
		TILE_REG[6]	 <= 32'h0000_0000; // TileMap 1
		TILE_REG[7]  <= 32'h0000_0000; // TileMap 1
		
		TILE_REG[8]	 <= 32'h0000_0000; // TileMap 2
		TILE_REG[9]	 <= 32'h0000_0000; // TileMap 2
		TILE_REG[10] <= 32'h0000_0000; // TileMap 2
		TILE_REG[11] <= 32'h0000_0000; // TileMap 2
		
		TILE_REG[12] <= 32'h0000_0000; // TileMap 3
		TILE_REG[13] <= 32'h0000_0000; // TileMap 3
		TILE_REG[14] <= 32'h0000_0000; // TileMap 3
		TILE_REG[15] <= 32'h0000_0000; // TileMap 3
	end
	else
	begin
		if (Tile_MAP_CS_i && !Bus_RW_i && ( Bus_D_Siz_i[1:0] == 2'b00 ) && Bus_WE_i)
			TILE_REG[Bus_A_i[5:2]] <= Bus_D32_i;
	end
end

reg	[15:0]	TILEMAP0_CTRL_REG[0:2];
reg	[31:0]	TILEMAP0_ASSY_REG[0:2];
reg	[15:0]	TILEMAP0_X_MAP_SIZE_REG[0:2];
reg	[15:0]	TILEMAP0_Y_MAP_SIZE_REG[0:2];
reg	[15:0]	TILEMAP0_X_WIN_POS_REG[0:2];	// [14:10] Scroll_X : [9:0] Position
reg	[15:0]	TILEMAP0_Y_WIN_POS_REG[0:2];	// [14:10] Scroll_Y : [9:0] Position

reg	[15:0]	TILEMAP1_CTRL_REG[0:2];
reg	[31:0]	TILEMAP1_ASSY_REG[0:2];
reg	[15:0]	TILEMAP1_X_MAP_SIZE_REG[0:2];
reg	[15:0]	TILEMAP1_Y_MAP_SIZE_REG[0:2];
reg	[15:0]	TILEMAP1_X_WIN_POS_REG[0:2];	//
reg	[15:0]	TILEMAP1_Y_WIN_POS_REG[0:2];	//

reg	[15:0]	TILEMAP2_CTRL_REG[0:2];
reg	[31:0]	TILEMAP2_ASSY_REG[0:2];
reg	[15:0]	TILEMAP2_X_MAP_SIZE_REG[0:2];
reg	[15:0]	TILEMAP2_Y_MAP_SIZE_REG[0:2];
reg	[15:0]	TILEMAP2_X_WIN_POS_REG[0:2];	//
reg	[15:0]	TILEMAP2_Y_WIN_POS_REG[0:2]; //

reg	[15:0]	TILEMAP3_CTRL_REG[0:2];
reg	[31:0]	TILEMAP3_ASSY_REG[0:2];
reg	[15:0]	TILEMAP3_X_MAP_SIZE_REG[0:2];
reg	[15:0]	TILEMAP3_Y_MAP_SIZE_REG[0:2];
reg	[15:0]	TILEMAP3_X_WIN_POS_REG[0:2]; //
reg	[15:0]	TILEMAP3_Y_WIN_POS_REG[0:2]; // 

reg	[31:0]	TILEDATA_ADDY0[0:2]; //3x Byte 
reg	[31:0]	TILEDATA_ADDY1[0:2];
reg	[31:0]	TILEDATA_ADDY2[0:2];
reg	[31:0]	TILEDATA_ADDY3[0:2];
reg	[31:0]	TILEDATA_ADDY4[0:2];
reg	[31:0]	TILEDATA_ADDY5[0:2];
reg	[31:0]	TILEDATA_ADDY6[0:2];
reg	[31:0]	TILEDATA_ADDY7[0:2];


always @ (posedge EngineClk100Mhz_i) begin
	// ReSync for 100Mhz for Layer 0
	//TILEMAP0_CTRL_REG
	TILEMAP0_CTRL_REG[0] <= TILE_REG[0][15:0];
	TILEMAP0_CTRL_REG[1] <= TILEMAP0_CTRL_REG[0];
	if (TILEMAP0_CTRL_REG[1] == TILEMAP0_CTRL_REG[0]) begin
		TILEMAP0_CTRL_REG[2] <= TILEMAP0_CTRL_REG[1];	
	end
	//TILEMAP0_ASSY_REG
	TILEMAP0_ASSY_REG[0] <= TILE_REG[1];
	TILEMAP0_ASSY_REG[1] <= TILEMAP0_ASSY_REG[0];
	if (	TILEMAP0_ASSY_REG[1] == TILEMAP0_ASSY_REG[0] ) begin
		TILEMAP0_ASSY_REG[2] <= TILEMAP0_ASSY_REG[1];
	end
	//TILEMAP0_X_MAP_SIZE_REG
	TILEMAP0_X_MAP_SIZE_REG[0] <= TILE_REG[2][15:0];
	TILEMAP0_X_MAP_SIZE_REG[1] <= TILEMAP0_X_MAP_SIZE_REG[0];
	if (	TILEMAP0_X_MAP_SIZE_REG[1] == TILEMAP0_X_MAP_SIZE_REG[0] ) begin
		TILEMAP0_X_MAP_SIZE_REG[2] <= TILEMAP0_X_MAP_SIZE_REG[1];
	end
	//TILEMAP0_Y_MAP_SIZE_REG
	TILEMAP0_Y_MAP_SIZE_REG[0] <= TILE_REG[2][31:16];
	TILEMAP0_Y_MAP_SIZE_REG[1] <= TILEMAP0_Y_MAP_SIZE_REG[0];
	if (TILEMAP0_Y_MAP_SIZE_REG[1] == TILEMAP0_Y_MAP_SIZE_REG[0] ) begin
		TILEMAP0_Y_MAP_SIZE_REG[2] <= TILEMAP0_Y_MAP_SIZE_REG[1];	
	end
	//TILEMAP0_X_WIN_POS_REG
	TILEMAP0_X_WIN_POS_REG[0] <= TILE_REG[3][15:0];
	TILEMAP0_X_WIN_POS_REG[1] <= TILEMAP0_X_WIN_POS_REG[0];
	if (TILEMAP0_X_WIN_POS_REG[1] == TILEMAP0_X_WIN_POS_REG[0] ) begin
		TILEMAP0_X_WIN_POS_REG[2] <= TILEMAP0_X_WIN_POS_REG[1];
	end
	//TILEMAP0_Y_WIN_POS_REG
	TILEMAP0_Y_WIN_POS_REG[0] <= TILE_REG[3][31:16];
	TILEMAP0_Y_WIN_POS_REG[1] <= TILEMAP0_Y_WIN_POS_REG[0];
	if ( TILEMAP0_Y_WIN_POS_REG[1] == TILEMAP0_Y_WIN_POS_REG[0] ) begin
		TILEMAP0_Y_WIN_POS_REG[2] <= TILEMAP0_Y_WIN_POS_REG[1];	
	end
end

always @ (posedge EngineClk100Mhz_i) begin
	//TILEMAP1_CTRL_REG
	TILEMAP1_CTRL_REG[0] <= TILE_REG[4][15:0];
	TILEMAP1_CTRL_REG[1] <= TILEMAP1_CTRL_REG[0];
	if (	TILEMAP1_CTRL_REG[1] == TILEMAP1_CTRL_REG[0] ) begin
		TILEMAP1_CTRL_REG[2] <= TILEMAP1_CTRL_REG[1];
	end
	//TILEMAP1_ASSY_REG
	TILEMAP1_ASSY_REG[0] <= TILE_REG[5];
	TILEMAP1_ASSY_REG[1] <= TILEMAP1_ASSY_REG[0];
	if ( TILEMAP1_ASSY_REG[1] == TILEMAP1_ASSY_REG[0] ) begin
		TILEMAP1_ASSY_REG[2] <= TILEMAP1_ASSY_REG[1];
	end
	//TILEMAP1_X_MAP_SIZE_REG
	TILEMAP1_X_MAP_SIZE_REG[0] <= TILE_REG[6][15:0];
	TILEMAP1_X_MAP_SIZE_REG[1] <= TILEMAP1_X_MAP_SIZE_REG[0];
	if ( TILEMAP1_X_MAP_SIZE_REG[1] == TILEMAP1_X_MAP_SIZE_REG[0] ) begin
		TILEMAP1_X_MAP_SIZE_REG[2] <= TILEMAP1_X_MAP_SIZE_REG[1];
	end
	//TILEMAP1_Y_MAP_SIZE_REG
	TILEMAP1_Y_MAP_SIZE_REG[0] <= TILE_REG[6][31:16];
	TILEMAP1_Y_MAP_SIZE_REG[1] <= TILEMAP1_Y_MAP_SIZE_REG[0];
	if ( TILEMAP1_Y_MAP_SIZE_REG[1] == TILEMAP1_Y_MAP_SIZE_REG[0] ) begin
		TILEMAP1_Y_MAP_SIZE_REG[2] <= TILEMAP1_Y_MAP_SIZE_REG[1];
	end
	//TILEMAP1_X_WIN_POS_REG
	TILEMAP1_X_WIN_POS_REG[0] <= TILE_REG[7][15:0];
	TILEMAP1_X_WIN_POS_REG[1] <= TILEMAP1_X_WIN_POS_REG[0];	
	if ( TILEMAP1_X_WIN_POS_REG[1] == TILEMAP1_X_WIN_POS_REG[0] ) begin
		TILEMAP1_X_WIN_POS_REG[2] <= TILEMAP1_X_WIN_POS_REG[1];
	end
	//TILEMAP1_Y_WIN_POS_REG
	TILEMAP1_Y_WIN_POS_REG[0] <= TILE_REG[7][31:16];
	TILEMAP1_Y_WIN_POS_REG[1] <= TILEMAP1_Y_WIN_POS_REG[0];
	if ( TILEMAP1_Y_WIN_POS_REG[1] == TILEMAP1_Y_WIN_POS_REG[0] ) begin
		TILEMAP1_Y_WIN_POS_REG[2] <= TILEMAP1_Y_WIN_POS_REG[1];
	end

end

always @ (posedge EngineClk100Mhz_i) begin
	// ReSync for 100Mhz for Layer 2
	//TILEMAP2_CTRL_REG
	TILEMAP2_CTRL_REG[0] <= TILE_REG[8][15:0];
	TILEMAP2_CTRL_REG[1] <= TILEMAP2_CTRL_REG[0];
	if ( TILEMAP2_CTRL_REG[1] == TILEMAP2_CTRL_REG[0] ) begin
		TILEMAP2_CTRL_REG[2] <= TILEMAP2_CTRL_REG[1];
	end
	//TILEMAP2_ASSY_REG
	TILEMAP2_ASSY_REG[0] <= TILE_REG[9];
	TILEMAP2_ASSY_REG[1] <= TILEMAP2_ASSY_REG[0];
	if ( TILEMAP2_ASSY_REG[1] == TILEMAP2_ASSY_REG[0] ) begin
		TILEMAP2_ASSY_REG[2] <= TILEMAP2_ASSY_REG[1];
	end
	//TILEMAP2_X_MAP_SIZE_REG
	TILEMAP2_X_MAP_SIZE_REG[0] <= TILE_REG[10][15:0];
	TILEMAP2_X_MAP_SIZE_REG[1] <= TILEMAP2_X_MAP_SIZE_REG[0];
	if ( TILEMAP2_X_MAP_SIZE_REG[1] == TILEMAP2_X_MAP_SIZE_REG[0] ) begin
		TILEMAP2_X_MAP_SIZE_REG[2] <= TILEMAP2_X_MAP_SIZE_REG[1];
	end
	//TILEMAP2_Y_MAP_SIZE_REG
	TILEMAP2_Y_MAP_SIZE_REG[0] <= TILE_REG[10][31:16];
	TILEMAP2_Y_MAP_SIZE_REG[1] <= TILEMAP2_Y_MAP_SIZE_REG[0];
	if ( TILEMAP2_Y_MAP_SIZE_REG[1] == TILEMAP2_Y_MAP_SIZE_REG[0] ) begin
		TILEMAP2_Y_MAP_SIZE_REG[2] <= TILEMAP2_Y_MAP_SIZE_REG[1];
	end
	//TILEMAP2_X_WIN_POS_REG
	TILEMAP2_X_WIN_POS_REG[0] <= TILE_REG[11][15:0];
	TILEMAP2_X_WIN_POS_REG[1] <= TILEMAP2_X_WIN_POS_REG[0];
	if ( TILEMAP2_X_WIN_POS_REG[1] == TILEMAP2_X_WIN_POS_REG[0] ) begin
		TILEMAP2_X_WIN_POS_REG[2] <= TILEMAP2_X_WIN_POS_REG[1];
	end
	//TILEMAP2_Y_WIN_POS_REG
	TILEMAP2_Y_WIN_POS_REG[0] <= TILE_REG[11][31:16];
	TILEMAP2_Y_WIN_POS_REG[1] <= TILEMAP2_Y_WIN_POS_REG[0];
	if ( TILEMAP2_Y_WIN_POS_REG[1] == TILEMAP2_Y_WIN_POS_REG[0] ) begin
		TILEMAP2_Y_WIN_POS_REG[2] <= TILEMAP2_Y_WIN_POS_REG[1];
	end
	
end

always @ (posedge EngineClk100Mhz_i) begin
	// ReSync for 100Mhz for Layer 3
	//TILEMAP3_CTRL_REG
	TILEMAP3_CTRL_REG[0] <= TILE_REG[12][15:0];
	TILEMAP3_CTRL_REG[1] <= TILEMAP3_CTRL_REG[0];
	if ( TILEMAP3_CTRL_REG[1] == TILEMAP3_CTRL_REG[0] ) begin
		TILEMAP3_CTRL_REG[2] <= TILEMAP3_CTRL_REG[1];
	end
	//TILEMAP3_ASSY_REG
	TILEMAP3_ASSY_REG[0] <= TILE_REG[13];
	TILEMAP3_ASSY_REG[1] <= TILEMAP3_ASSY_REG[0];
	if ( TILEMAP3_ASSY_REG[1] == TILEMAP3_ASSY_REG[0] ) begin
		TILEMAP3_ASSY_REG[2] <= TILEMAP3_ASSY_REG[1];
	end
	//TILEMAP3_X_MAP_SIZE_REG
	TILEMAP3_X_MAP_SIZE_REG[0] <= TILE_REG[14][15:0];
	TILEMAP3_X_MAP_SIZE_REG[1] <= TILEMAP3_X_MAP_SIZE_REG[0];
	if ( TILEMAP3_X_MAP_SIZE_REG[1] == TILEMAP3_X_MAP_SIZE_REG[0] ) begin
		TILEMAP3_X_MAP_SIZE_REG[2] <= TILEMAP3_X_MAP_SIZE_REG[1];
	end
	//TILEMAP3_Y_MAP_SIZE_REG
	TILEMAP3_Y_MAP_SIZE_REG[0] <= TILE_REG[14][31:16];
	TILEMAP3_Y_MAP_SIZE_REG[1] <= TILEMAP3_Y_MAP_SIZE_REG[0];
	if ( TILEMAP3_Y_MAP_SIZE_REG[1] == TILEMAP3_Y_MAP_SIZE_REG[0] ) begin
		TILEMAP3_Y_MAP_SIZE_REG[2] <= TILEMAP3_Y_MAP_SIZE_REG[1];
	end
	//TILEMAP3_X_WIN_POS_REG
	TILEMAP3_X_WIN_POS_REG[0] <= TILE_REG[15][15:0];
	TILEMAP3_X_WIN_POS_REG[1] <= TILEMAP3_X_WIN_POS_REG[0];	
	if ( TILEMAP3_X_WIN_POS_REG[1] == TILEMAP3_X_WIN_POS_REG[0] ) begin
		TILEMAP3_X_WIN_POS_REG[2] <= TILEMAP3_X_WIN_POS_REG[1];
	end
	//TILEMAP3_Y_WIN_POS_REG
	TILEMAP3_Y_WIN_POS_REG[0] <= TILE_REG[15][31:16];
	TILEMAP3_Y_WIN_POS_REG[1] <= TILEMAP3_Y_WIN_POS_REG[0];
	if ( TILEMAP3_Y_WIN_POS_REG[1] == TILEMAP3_Y_WIN_POS_REG[0] ) begin
		TILEMAP3_Y_WIN_POS_REG[2] <= TILEMAP3_Y_WIN_POS_REG[1];
	end	
end

reg	[4:0] TILEMAP0_X_WIN_SCROLL_200_REG[0:2];
reg	[4:0] TILEMAP1_X_WIN_SCROLL_200_REG[0:2];
reg	[4:0] TILEMAP2_X_WIN_SCROLL_200_REG[0:2];
reg	[4:0] TILEMAP3_X_WIN_SCROLL_200_REG[0:2];

always @ (posedge EngineClk200Mhz_i) begin
	TILEMAP0_X_WIN_SCROLL_200_REG[0] <= {TILE_REG[2][15], TILE_REG[2][3:0]};
	TILEMAP0_X_WIN_SCROLL_200_REG[1] <=	TILEMAP0_X_WIN_SCROLL_200_REG[0];
	if ( 	TILEMAP0_X_WIN_SCROLL_200_REG[1] ==	TILEMAP0_X_WIN_SCROLL_200_REG[0] ) begin
		TILEMAP0_X_WIN_SCROLL_200_REG[2] <=	TILEMAP0_X_WIN_SCROLL_200_REG[1];
	end
	
	TILEMAP1_X_WIN_SCROLL_200_REG[0] <= {TILE_REG[6][15], TILE_REG[6][3:0]};
	TILEMAP1_X_WIN_SCROLL_200_REG[1] <=	TILEMAP1_X_WIN_SCROLL_200_REG[0];
	if ( 	TILEMAP1_X_WIN_SCROLL_200_REG[1] ==	TILEMAP1_X_WIN_SCROLL_200_REG[0] ) begin
		TILEMAP1_X_WIN_SCROLL_200_REG[2] <=	TILEMAP1_X_WIN_SCROLL_200_REG[1];
	end
	
	TILEMAP2_X_WIN_SCROLL_200_REG[0] <= {TILE_REG[10][15], TILE_REG[10][3:0]};
	TILEMAP2_X_WIN_SCROLL_200_REG[1] <=	TILEMAP2_X_WIN_SCROLL_200_REG[0];
	if ( 	TILEMAP2_X_WIN_SCROLL_200_REG[1] ==	TILEMAP2_X_WIN_SCROLL_200_REG[0] ) begin
		TILEMAP2_X_WIN_SCROLL_200_REG[2] <=	TILEMAP2_X_WIN_SCROLL_200_REG[1];
	end
	
	TILEMAP3_X_WIN_SCROLL_200_REG[0] <= {TILE_REG[14][15], TILE_REG[14][3:0]};		// Sign + Direction
	TILEMAP3_X_WIN_SCROLL_200_REG[1] <=	TILEMAP3_X_WIN_SCROLL_200_REG[0];
	if ( 	TILEMAP3_X_WIN_SCROLL_200_REG[1] ==	TILEMAP3_X_WIN_SCROLL_200_REG[0] ) begin
		TILEMAP3_X_WIN_SCROLL_200_REG[2] <=	TILEMAP3_X_WIN_SCROLL_200_REG[1];
	end	
end

// Tile Layer 0
assign TileMap0_Control_Reg_o 	= TILEMAP0_CTRL_REG[2][7:0];
assign TileMap0_Addy_o				= TILEMAP0_ASSY_REG[2][21:0];
assign TileMap0_X_TotalSize_o		= TILEMAP0_X_MAP_SIZE_REG[2][9:0];
assign TileMap0_Y_TotalSize_o 	= TILEMAP0_Y_MAP_SIZE_REG[2][9:0];
assign TileMap0_X_Window_Pos_o 	= TILEMAP0_X_WIN_POS_REG[2][13:4];
assign TileMap0_X_Scroll_o 		= TILEMAP0_X_WIN_SCROLL_200_REG[2][4:0];
assign TileMap0_Y_Window_Pos_o 	= TILEMAP0_Y_WIN_POS_REG[2][13:4];
assign TileMap0_Y_Scroll_o 		= {TILEMAP0_Y_WIN_POS_REG[2][15], TILEMAP0_Y_WIN_POS_REG[2][3:0]};
// Tile Layer 1
assign TileMap1_Control_Reg_o 	= TILEMAP1_CTRL_REG[2][7:0];
assign TileMap1_Addy_o 				= TILEMAP1_ASSY_REG[2][21:0];
assign TileMap1_X_TotalSize_o		= TILEMAP1_X_MAP_SIZE_REG[2][9:0];
assign TileMap1_Y_TotalSize_o 	= TILEMAP1_Y_MAP_SIZE_REG[2][9:0];
assign TileMap1_X_Window_Pos_o 	= TILEMAP1_X_WIN_POS_REG[2][13:4];
assign TileMap1_X_Scroll_o 		= TILEMAP1_X_WIN_SCROLL_200_REG[2][4:0];
assign TileMap1_Y_Window_Pos_o 	= TILEMAP1_Y_WIN_POS_REG[2][13:4];
assign TileMap1_Y_Scroll_o 		= {TILEMAP1_Y_WIN_POS_REG[2][15], TILEMAP1_Y_WIN_POS_REG[2][3:0]};
// Tile Layer 2
assign TileMap2_Control_Reg_o 	= TILEMAP2_CTRL_REG[2][7:0];
assign TileMap2_Addy_o 				= TILEMAP2_ASSY_REG[2][21:0];
assign TileMap2_X_TotalSize_o		= TILEMAP2_X_MAP_SIZE_REG[2][9:0];
assign TileMap2_Y_TotalSize_o 	= TILEMAP2_Y_MAP_SIZE_REG[2][9:0];
assign TileMap2_X_Window_Pos_o 	= TILEMAP2_X_WIN_POS_REG[2][13:4];
assign TileMap2_X_Scroll_o 		= TILEMAP2_X_WIN_SCROLL_200_REG[2][4:0];
assign TileMap2_Y_Window_Pos_o 	= TILEMAP2_Y_WIN_POS_REG[2][13:4];
assign TileMap2_Y_Scroll_o 		= {TILEMAP2_Y_WIN_POS_REG[2][15], TILEMAP2_Y_WIN_POS_REG[2][3:0]};
// Tile Layer 3
assign TileMap3_Control_Reg_o 	= TILEMAP3_CTRL_REG[2][7:0];
assign TileMap3_Addy_o 				= TILEMAP3_ASSY_REG[2][21:0];
assign TileMap3_X_TotalSize_o		= TILEMAP3_X_MAP_SIZE_REG[2][9:0];
assign TileMap3_Y_TotalSize_o 	= TILEMAP3_Y_MAP_SIZE_REG[2][9:0];
assign TileMap3_X_Window_Pos_o 	= TILEMAP3_X_WIN_POS_REG[2][13:4];
assign TileMap3_X_Scroll_o 		= TILEMAP3_X_WIN_SCROLL_200_REG[2][4:0];
assign TileMap3_Y_Window_Pos_o 	= TILEMAP3_Y_WIN_POS_REG[2][13:4];
assign TileMap3_Y_Scroll_o 		= {TILEMAP3_Y_WIN_POS_REG[2][15], TILEMAP3_Y_WIN_POS_REG[2][3:0]};

// Writing Part
always @ (posedge Bus_Clk_i)
begin
	if (rst_i)
	begin
		TILE_DAT_REG[0] <= 32'h0000_0000;
		TILE_DAT_REG[1] <= 32'h0000_0000;
		TILE_DAT_REG[2] <= 32'h0000_0000;
		TILE_DAT_REG[3] <= 32'h0000_0000;
		
		TILE_DAT_REG[4] <= 32'h0000_0000;
		TILE_DAT_REG[5] <= 32'h0000_0000;
		TILE_DAT_REG[6] <= 32'h0000_0000;
		TILE_DAT_REG[7] <= 32'h0000_0000;
	end
	else begin
		if (Tile_Data_CS_i && !Bus_RW_i && ( Bus_D_Siz_i[1:0] == 2'b00 ) && Bus_WE_i)
			TILE_DAT_REG[Bus_A_i[4:2]] <= Bus_D32_i;
	end
end

reg	[31:0]	TILESET_ADDY0[0:2];
reg	[31:0]	TILESET_ADDY1[0:2];
reg	[31:0]	TILESET_ADDY2[0:2];
reg	[31:0]	TILESET_ADDY3[0:2];
reg	[31:0]	TILESET_ADDY4[0:2];
reg	[31:0]	TILESET_ADDY5[0:2];
reg	[31:0]	TILESET_ADDY6[0:2];
reg	[31:0]	TILESET_ADDY7[0:2];

always @ (posedge EngineClk100Mhz_i) begin
	// ReSync for 100Mhz for Layer 0
	TILESET_ADDY0[0][31:0] <= TILE_DAT_REG[0];
	TILESET_ADDY0[1][31:0] <= TILESET_ADDY0[0][31:0];
	if (TILESET_ADDY0[1][31:0] == TILESET_ADDY0[0][31:0]) begin
		TILESET_ADDY0[2][31:0] <= TILESET_ADDY0[1][31:0];
	end
	
	TILESET_ADDY1[0][31:0] <= TILE_DAT_REG[1];
	TILESET_ADDY1[1][31:0] <= TILESET_ADDY1[0][31:0];
	if (TILESET_ADDY1[1][31:0] == TILESET_ADDY1[0][31:0]) begin
		TILESET_ADDY1[2][31:0] <= TILESET_ADDY1[1][31:0];
	end	

	TILESET_ADDY2[0][31:0] <= TILE_DAT_REG[2];
	TILESET_ADDY2[1][31:0] <= TILESET_ADDY2[0][31:0];
	if (TILESET_ADDY2[1][31:0] == TILESET_ADDY2[0][31:0]) begin
		TILESET_ADDY2[2][31:0] <= TILESET_ADDY2[1][31:0];
	end		

	TILESET_ADDY3[0][31:0] <= TILE_DAT_REG[3];
	TILESET_ADDY3[1][31:0] <= TILESET_ADDY3[0][31:0];
	if (TILESET_ADDY3[1][31:0] == TILESET_ADDY3[0][31:0]) begin
		TILESET_ADDY3[2][31:0] <= TILESET_ADDY3[1][31:0];
	end		

	TILESET_ADDY4[0][31:0] <= TILE_DAT_REG[4];
	TILESET_ADDY4[1][31:0] <= TILESET_ADDY4[0][31:0];
	if (TILESET_ADDY4[1][31:0] == TILESET_ADDY4[0][31:0]) begin
		TILESET_ADDY4[2][31:0] <= TILESET_ADDY4[1][31:0];
	end		
	
	TILESET_ADDY5[0][31:0] <= TILE_DAT_REG[5];
	TILESET_ADDY5[1][31:0] <= TILESET_ADDY5[0][31:0];
	if (TILESET_ADDY5[1][31:0] == TILESET_ADDY5[0][31:0]) begin
		TILESET_ADDY5[2][31:0] <= TILESET_ADDY5[1][31:0];
	end		

	TILESET_ADDY6[0][31:0] <= TILE_DAT_REG[6];
	TILESET_ADDY6[1][31:0] <= TILESET_ADDY6[0][31:0];
	if (TILESET_ADDY6[1][31:0] == TILESET_ADDY6[0][31:0]) begin
		TILESET_ADDY6[2][31:0] <= TILESET_ADDY6[1][31:0];
	end		
	

	TILESET_ADDY7[0][31:0] <= TILE_DAT_REG[7];
	TILESET_ADDY7[1][31:0] <= TILESET_ADDY7[0][31:0];
	if (TILESET_ADDY7[1][31:0] == TILESET_ADDY7[0][31:0]) begin
		TILESET_ADDY7[2][31:0] <= TILESET_ADDY7[1][31:0];
	end
end

assign TileSet0Addy_o = TILESET_ADDY0[2][21:0];
assign TileSet1Addy_o = TILESET_ADDY1[2][21:0];
assign TileSet2Addy_o = TILESET_ADDY2[2][21:0]; 
assign TileSet3Addy_o = TILESET_ADDY3[2][21:0]; 
assign TileSet4Addy_o = TILESET_ADDY4[2][21:0]; 
assign TileSet5Addy_o = TILESET_ADDY5[2][21:0]; 
assign TileSet6Addy_o = TILESET_ADDY6[2][21:0]; 
assign TileSet7Addy_o = TILESET_ADDY7[2][21:0]; 

assign TileSet0_CFG_o = TILESET_ADDY0[2][27:24];
assign TileSet1_CFG_o = TILESET_ADDY1[2][27:24];
assign TileSet2_CFG_o = TILESET_ADDY2[2][27:24];
assign TileSet3_CFG_o = TILESET_ADDY3[2][27:24];
assign TileSet4_CFG_o = TILESET_ADDY4[2][27:24];
assign TileSet5_CFG_o = TILESET_ADDY5[2][27:24];
assign TileSet6_CFG_o = TILESET_ADDY6[2][27:24];
assign TileSet7_CFG_o = TILESET_ADDY7[2][27:24];

endmodule

