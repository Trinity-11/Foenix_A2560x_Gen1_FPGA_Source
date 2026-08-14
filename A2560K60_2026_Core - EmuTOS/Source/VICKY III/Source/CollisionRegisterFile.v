`timescale 1 ns / 1 ns
module CollisionRegisterFile 
(
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
output 	reg	[31:0]	Bus_D_o,
input		wire				Bus_RW_i,
input		wire	[3:0]		Bus_BE_i, 
input		wire				Collision_CS_i,
// Output to the F2DEngine
input		wire	[15:0]	Collision_SpriteL0_i,
input		wire	[15:0]	Collision_SpriteL1_i,
input		wire	[15:0]	Collision_SpriteL2_i,
input		wire	[15:0]	Collision_SpriteL3_i,
input		wire	[15:0]	Collision_SpriteL4_i,
input		wire	[15:0]	Collision_SpriteL5_i,
input		wire	[15:0]	Collision_SpriteL6_i,

input		wire	[15:0]	Collision_BM0_i,
input		wire	[15:0]	Collision_BM1_i,
input		wire	[15:0]	Collision_COL_i,

input		wire	[15:0]	Collision_TL0_i,
input		wire	[15:0]	Collision_TL1_i,
input		wire	[15:0]	Collision_TL2_i,
input		wire	[15:0]	Collision_TL3_i,

input		wire	[7:0]		Sprite_Collision_Pixel_i,
input		wire	[5:0]		Sprite_Collision_Channel_i,

input		wire	[7:0]		Bitmap_L0_Collision_Pixel_i,
input		wire	[7:0]		Bitmap_L1_Collision_Pixel_i,
input		wire	[7:0]		Bitmap_C0_Collision_Pixel_i,

input		wire	[7:0]		Tilemap_L0_Collision_Pixel_i,
input		wire	[7:0]		Tilemap_L1_Collision_Pixel_i,
input		wire	[7:0]		Tilemap_L2_Collision_Pixel_i,
input		wire	[7:0]		Tilemap_L3_Collision_Pixel_i,
//
input    wire	[15:0]	Collision_Sprite_X_Location_i,
input		wire	[15:0]	Collision_Bitmap_X_Location_i,
input		wire	[15:0]	Collision_Tiles_X_Location_i,

input		wire	[15:0]	Collision_Y_Location_i
);

// This is the Block that the CPU can interact with for Read back mostly.
// The Transfer of the Data from one Clock Domain to another is done in the Proper Block.
//assign Bus_RDY_o = 1'b0;
//reg [7:0]		COLLISION_MTX_REG[0:31];

//assign Bus_D_o = VICKY_MASTER_REG[Bus_A_i[4:0]];

// Writing Part
/*
always @ (negedge Bus_Clk_i)
begin
	if (rst_i)
	begin
		COLLISION_MTX_REG[0] 	<= 8'h00;
		COLLISION_MTX_REG[1] 	<= 8'h00;
		COLLISION_MTX_REG[2] 	<= 8'h00;
		COLLISION_MTX_REG[3] 	<= 8'h00;
		COLLISION_MTX_REG[4] 	<= 8'h00;
		COLLISION_MTX_REG[5] 	<= 8'h00;
		COLLISION_MTX_REG[6] 	<= 8'h00;
		COLLISION_MTX_REG[7] 	<= 8'h00; 
		COLLISION_MTX_REG[8] 	<= 8'h00;
		COLLISION_MTX_REG[9] 	<= 8'h00;
		COLLISION_MTX_REG[10] 	<= 8'h00;
		COLLISION_MTX_REG[11] 	<= 8'h00;
		COLLISION_MTX_REG[12] 	<= 8'h00;
		COLLISION_MTX_REG[13] 	<= 8'h00;
		COLLISION_MTX_REG[14] 	<= 8'h00;
		COLLISION_MTX_REG[15] 	<= 8'h00;
		COLLISION_MTX_REG[16] 	<= 8'h00;
		COLLISION_MTX_REG[17] 	<= 8'h00;
		COLLISION_MTX_REG[18] 	<= 8'h00;
		COLLISION_MTX_REG[19] 	<= 8'h00;
		COLLISION_MTX_REG[20] 	<= 8'h00;
		COLLISION_MTX_REG[21] 	<= 8'h00;
		COLLISION_MTX_REG[22] 	<= 8'h00;
		COLLISION_MTX_REG[23] 	<= 8'h00; 
	end
	else
	begin
		if (Collision_CS_i & !Bus_RW_i) begin
				COLLISION_MTX_REG[Bus_A_i[4:0]] <= Bus_D_i;
		end
	end
end
*/

always @ (*)
begin
	case(Bus_A_i[5:2])
		4'b0000: Bus_D_o = { COLLISION_MTX_REG1_SYNC1[15:0], COLLISION_MTX_REG0_SYNC1[15:0]};	// SP_L0
		4'b0001: Bus_D_o = { COLLISION_MTX_REG3_SYNC1[15:0], COLLISION_MTX_REG2_SYNC1[15:0]};	// SP_L2
		4'b0010: Bus_D_o = { COLLISION_MTX_REG5_SYNC1[15:0], COLLISION_MTX_REG4_SYNC1[15:0]};	// SP_L4
		4'b0011: Bus_D_o = { COLLISION_MTX_REG7_SYNC1[15:0], COLLISION_MTX_REG6_SYNC1[15:0]};	// SP_L6
		4'b0100: Bus_D_o = { COLLISION_MTX_REG9_SYNC1[15:0], COLLISION_MTX_REG8_SYNC1[15:0]};	// Collision_BM1_i
		4'b0101: Bus_D_o = { COLLISION_MTX_REGB_SYNC1[15:0], COLLISION_MTX_REGA_SYNC1[15:0]};	// Collision_TL0_i
		4'b0110: Bus_D_o = { COLLISION_MTX_REGD_SYNC1[15:0], COLLISION_MTX_REGC_SYNC1[15:0]};	// Collision_TL2_i
		4'b0111: Bus_D_o = { COLLISION_MTX_REGF_SYNC1[15:0], COLLISION_MTX_REGE_SYNC1[15:0]};	// Sprite_Collision_Pixel_i, 2'b00, Sprite_Collision_Channel_i
		
		4'b1000: Bus_D_o = { COLLISION_MTX_REG11_SYNC1[15:0], COLLISION_MTX_REG10_SYNC1[15:0]};//
		4'b1001: Bus_D_o = { COLLISION_MTX_REG13_SYNC1[15:0], COLLISION_MTX_REG12_SYNC1[15:0]};//
		4'b1010: Bus_D_o = { COLLISION_MTX_REG15_SYNC1[15:0], COLLISION_MTX_REG14_SYNC1[15:0]};//
		4'b1011: Bus_D_o = { 16'h0000, COLLISION_MTX_REG16_SYNC1[15:0]};//
		default: begin
			Bus_D_o = 32'hDEAD_BEEF;
		end
	endcase
end


reg	[15:0]	COLLISION_MTX_REG0_SYNC0, 	COLLISION_MTX_REG0_SYNC1;
reg	[15:0]	COLLISION_MTX_REG1_SYNC0, 	COLLISION_MTX_REG1_SYNC1;
reg	[15:0]	COLLISION_MTX_REG2_SYNC0, 	COLLISION_MTX_REG2_SYNC1;
reg	[15:0]	COLLISION_MTX_REG3_SYNC0, 	COLLISION_MTX_REG3_SYNC1;
reg	[15:0]	COLLISION_MTX_REG4_SYNC0, 	COLLISION_MTX_REG4_SYNC1;
reg	[15:0]	COLLISION_MTX_REG5_SYNC0, 	COLLISION_MTX_REG5_SYNC1;
reg	[15:0]	COLLISION_MTX_REG6_SYNC0, 	COLLISION_MTX_REG6_SYNC1;
reg	[15:0]	COLLISION_MTX_REG7_SYNC0, 	COLLISION_MTX_REG7_SYNC1;
reg	[15:0]	COLLISION_MTX_REG8_SYNC0, 	COLLISION_MTX_REG8_SYNC1;
reg	[15:0]	COLLISION_MTX_REG9_SYNC0, 	COLLISION_MTX_REG9_SYNC1;
reg	[15:0]	COLLISION_MTX_REGA_SYNC0, 	COLLISION_MTX_REGA_SYNC1;
reg	[15:0]	COLLISION_MTX_REGB_SYNC0, 	COLLISION_MTX_REGB_SYNC1;
reg	[15:0]	COLLISION_MTX_REGC_SYNC0, 	COLLISION_MTX_REGC_SYNC1;
reg	[15:0]	COLLISION_MTX_REGD_SYNC0, 	COLLISION_MTX_REGD_SYNC1;
reg	[15:0]	COLLISION_MTX_REGE_SYNC0, 	COLLISION_MTX_REGE_SYNC1;
reg	[15:0]	COLLISION_MTX_REGF_SYNC0, 	COLLISION_MTX_REGF_SYNC1;
reg	[15:0]	COLLISION_MTX_REG10_SYNC0, COLLISION_MTX_REG10_SYNC1;
reg	[15:0]	COLLISION_MTX_REG11_SYNC0, COLLISION_MTX_REG11_SYNC1;
reg	[15:0]	COLLISION_MTX_REG12_SYNC0, COLLISION_MTX_REG12_SYNC1;
reg	[15:0]	COLLISION_MTX_REG13_SYNC0, COLLISION_MTX_REG13_SYNC1;
reg	[15:0]	COLLISION_MTX_REG14_SYNC0, COLLISION_MTX_REG14_SYNC1;
reg	[15:0]	COLLISION_MTX_REG15_SYNC0, COLLISION_MTX_REG15_SYNC1;
reg	[15:0]	COLLISION_MTX_REG16_SYNC0, COLLISION_MTX_REG16_SYNC1;


always @ (posedge Bus_Clk_i)
begin
	// 16Bit Wide
	COLLISION_MTX_REG0_SYNC0 <= Collision_SpriteL0_i;
	COLLISION_MTX_REG0_SYNC1 <= COLLISION_MTX_REG0_SYNC0;
	
	COLLISION_MTX_REG1_SYNC0 <= Collision_SpriteL1_i;
	COLLISION_MTX_REG1_SYNC1 <= COLLISION_MTX_REG1_SYNC0;
	
	COLLISION_MTX_REG2_SYNC0 <= Collision_SpriteL2_i;
	COLLISION_MTX_REG2_SYNC1 <= COLLISION_MTX_REG2_SYNC0;
	
	COLLISION_MTX_REG3_SYNC0 <= Collision_SpriteL3_i;
	COLLISION_MTX_REG3_SYNC1 <= COLLISION_MTX_REG3_SYNC0;
	
	COLLISION_MTX_REG4_SYNC0 <= Collision_SpriteL4_i;
	COLLISION_MTX_REG4_SYNC1 <= COLLISION_MTX_REG4_SYNC0;
	
	COLLISION_MTX_REG5_SYNC0 <= Collision_SpriteL5_i;
	COLLISION_MTX_REG5_SYNC1 <= COLLISION_MTX_REG5_SYNC0;	
	
	COLLISION_MTX_REG6_SYNC0 <= Collision_SpriteL6_i;
	COLLISION_MTX_REG6_SYNC1 <= COLLISION_MTX_REG6_SYNC0;	
	
	COLLISION_MTX_REG7_SYNC0 <= Collision_BM0_i;
	COLLISION_MTX_REG7_SYNC1 <= COLLISION_MTX_REG7_SYNC0;
	
	COLLISION_MTX_REG8_SYNC0 <= Collision_BM1_i;
	COLLISION_MTX_REG8_SYNC1 <= COLLISION_MTX_REG8_SYNC0;	

	COLLISION_MTX_REG9_SYNC0 <= Collision_COL_i;
	COLLISION_MTX_REG9_SYNC1 <= COLLISION_MTX_REG9_SYNC0;

	COLLISION_MTX_REGA_SYNC0 <= Collision_TL0_i;
	COLLISION_MTX_REGA_SYNC1 <= COLLISION_MTX_REGA_SYNC0;

	COLLISION_MTX_REGB_SYNC0 <= Collision_TL1_i;
	COLLISION_MTX_REGB_SYNC1 <= COLLISION_MTX_REGB_SYNC0;

	COLLISION_MTX_REGC_SYNC0 <= Collision_TL2_i;
	COLLISION_MTX_REGC_SYNC1 <= COLLISION_MTX_REGC_SYNC0;

	COLLISION_MTX_REGD_SYNC0 <= Collision_TL3_i;
	COLLISION_MTX_REGD_SYNC1 <= COLLISION_MTX_REGD_SYNC0;

	COLLISION_MTX_REGE_SYNC0 <= { Sprite_Collision_Pixel_i, 2'b00, Sprite_Collision_Channel_i};
	COLLISION_MTX_REGE_SYNC1 <= COLLISION_MTX_REGE_SYNC0;
	
	COLLISION_MTX_REGF_SYNC0 <= {Bitmap_L0_Collision_Pixel_i, Bitmap_L1_Collision_Pixel_i};
	COLLISION_MTX_REGF_SYNC1 <= COLLISION_MTX_REGF_SYNC0;
	
	COLLISION_MTX_REG10_SYNC0 <= {Bitmap_C0_Collision_Pixel_i, 8'h0000};
	COLLISION_MTX_REG10_SYNC1 <= COLLISION_MTX_REG10_SYNC0;
	
	COLLISION_MTX_REG11_SYNC0 <= {Tilemap_L0_Collision_Pixel_i, Tilemap_L1_Collision_Pixel_i};
	COLLISION_MTX_REG11_SYNC1 <= COLLISION_MTX_REG11_SYNC0;
	
	COLLISION_MTX_REG12_SYNC0 <= {Tilemap_L2_Collision_Pixel_i, Tilemap_L3_Collision_Pixel_i};
	COLLISION_MTX_REG12_SYNC1 <= COLLISION_MTX_REG12_SYNC0;
	
	COLLISION_MTX_REG13_SYNC0 <= Collision_Sprite_X_Location_i;
	COLLISION_MTX_REG13_SYNC1 <= COLLISION_MTX_REG13_SYNC0;	
	
	COLLISION_MTX_REG14_SYNC0 <= Collision_Bitmap_X_Location_i;
	COLLISION_MTX_REG14_SYNC1 <= COLLISION_MTX_REG14_SYNC0;
	
	COLLISION_MTX_REG15_SYNC0 <= Collision_Tiles_X_Location_i;
	COLLISION_MTX_REG15_SYNC1 <= COLLISION_MTX_REG15_SYNC0;

	COLLISION_MTX_REG16_SYNC0 <= Collision_Y_Location_i;
	COLLISION_MTX_REG16_SYNC1 <= COLLISION_MTX_REG16_SYNC0;	
end


endmodule

// COLLISION BIT DESCRIPTION
// Sprite L0
// Bit[00] = XX
// Bit[01] = Sprite_L1
// Bit[02] = Sprite_L2
// Bit[03] = Sprite_L3
// Bit[04] = Sprite_L4
// Bit[05] = Sprite_L5
// Bit[06] = Sprite_L6
// Bit[07] = XX
// Bit[08] = BITMAP0
// Bit[09] = BITMAP1
// Bit[10] = COLMAP
// Bit[11] = TILE0
// Bit[12] = TILE1
// Bit[13] = TILE2
// Bit[14] = TILE3
// Bit[15] = XX

// Sprite L1
// Bit[00] = Sprite_L0
// Bit[01] = XX
// Bit[02] = Sprite_L2
// Bit[03] = Sprite_L3
// Bit[04] = Sprite_L4
// Bit[05] = Sprite_L5
// Bit[06] = Sprite_L6
// Bit[07] = XX
// Bit[08] = BITMAP0
// Bit[09] = BITMAP1
// Bit[10] = COLMAP
// Bit[11] = TILE0
// Bit[12] = TILE1
// Bit[13] = TILE2
// Bit[14] = TILE3
// Bit[15] = XX

// Sprite L2
// Bit[00] = Sprite_L0
// Bit[01] = Sprite_L1
// Bit[02] = XX
// Bit[03] = Sprite_L3
// Bit[04] = Sprite_L4
// Bit[05] = Sprite_L5
// Bit[06] = Sprite_L6
// Bit[07] = XX
// Bit[08] = BITMAP0
// Bit[09] = BITMAP1
// Bit[10] = COLMAP
// Bit[11] = TILE0
// Bit[12] = TILE1
// Bit[13] = TILE2
// Bit[14] = TILE3
// Bit[15] = XX

// Sprite L3
// Bit[00] = Sprite_L0
// Bit[01] = Sprite_L1
// Bit[02] = Sprite_L2
// Bit[03] = XX
// Bit[04] = Sprite_L4
// Bit[05] = Sprite_L5
// Bit[06] = Sprite_L6
// Bit[07] = XX
// Bit[08] = BITMAP0
// Bit[09] = BITMAP1
// Bit[10] = COLMAP
// Bit[11] = TILE0
// Bit[12] = TILE1
// Bit[13] = TILE2
// Bit[14] = TILE3
// Bit[15] = XX

// Sprite L4
// Bit[00] = Sprite_L0
// Bit[01] = Sprite_L1
// Bit[02] = Sprite_L2
// Bit[03] = Sprite_L3
// Bit[04] = XX
// Bit[05] = Sprite_L5
// Bit[06] = Sprite_L6
// Bit[07] = XX
// Bit[08] = BITMAP0
// Bit[09] = BITMAP1
// Bit[10] = COLMAP
// Bit[11] = TILE0
// Bit[12] = TILE1
// Bit[13] = TILE2
// Bit[14] = TILE3
// Bit[15] = XX

// Sprite L5
// Bit[00] = Sprite_L0
// Bit[01] = Sprite_L1
// Bit[02] = Sprite_L2
// Bit[03] = Sprite_L3
// Bit[04] = Sprite_L4
// Bit[05] = XX
// Bit[06] = Sprite_L6
// Bit[07] = XX
// Bit[08] = BITMAP0
// Bit[09] = BITMAP1
// Bit[10] = COLMAP
// Bit[11] = TILE0
// Bit[12] = TILE1
// Bit[13] = TILE2
// Bit[14] = TILE3
// Bit[15] = XX

// Sprite L6
// Bit[00] = Sprite_L0
// Bit[01] = Sprite_L1
// Bit[02] = Sprite_L2
// Bit[03] = Sprite_L3
// Bit[04] = Sprite_L4
// Bit[05] = Sprite_L5
// Bit[06] = XX
// Bit[07] = XX
// Bit[08] = BITMAP0
// Bit[09] = BITMAP1
// Bit[10] = COLMAP
// Bit[11] = TILE0
// Bit[12] = TILE1
// Bit[13] = TILE2
// Bit[14] = TILE3
// Bit[15] = XX

// COLLISION BIT DESCRIPTION
// BM0
// Bit[00] = XX
// Bit[01] = BM1
// Bit[02] = COL
// Bit[03] = XX
// Bit[04] = TILE0
// Bit[05] = TILE1
// Bit[06] = TILE2
// Bit[07] = TILE3

// COLLISION BIT DESCRIPTION
// BM1
// Bit[00] = BM0
// Bit[01] = XX
// Bit[02] = COL
// Bit[03] = XX
// Bit[04] = TILE0
// Bit[05] = TILE1
// Bit[06] = TILE2
// Bit[07] = TILE3

// COLLISION BIT DESCRIPTION
// COL
// Bit[00] = BM0
// Bit[01] = BM1
// Bit[02] = XX
// Bit[03] = XX
// Bit[04] = TILE0
// Bit[05] = TILE1
// Bit[06] = TILE2
// Bit[07] = TILE3

// COLLISION BIT DESCRIPTION
// TILE0
// Bit[00] = BM0
// Bit[01] = BM1
// Bit[02] = XX
// Bit[03] = XX
// Bit[04] = XX
// Bit[05] = TILE1
// Bit[06] = TILE2
// Bit[07] = TILE3

// COLLISION BIT DESCRIPTION
// TILE1
// Bit[00] = BM0
// Bit[01] = BM1
// Bit[02] = XX
// Bit[03] = XX
// Bit[04] = TILE0
// Bit[05] = XX
// Bit[06] = TILE2
// Bit[07] = TILE3

// COLLISION BIT DESCRIPTION
// TILE2
// Bit[00] = BM0
// Bit[01] = BM1
// Bit[02] = XX
// Bit[03] = XX
// Bit[04] = TILE0
// Bit[05] = TILE1
// Bit[06] = XX
// Bit[07] = TILE3

// COLLISION BIT DESCRIPTION
// TILE3
// Bit[00] = BM0
// Bit[01] = BM1
// Bit[02] = XX
// Bit[03] = XX
// Bit[04] = TILE0
// Bit[05] = TILE1
// Bit[06] = TILE2
// Bit[07] = XX


