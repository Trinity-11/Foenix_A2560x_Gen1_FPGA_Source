`timescale 1 ns / 1 ns
module BitMapRegisterFile 
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
input		wire				Bus_WE_i, 
input		wire				Bitmap_CS_i,
// Output to the F2DEngine
output	wire				BM0_Layer_Enable_o,
output	wire	[2:0]		BM0_Layer_Lut_o,
output	wire	[23:0]	BM0_MapAddy_o,
output	wire 	[4:0]		BM0_X_Offset_o,	// +/- 32
output	wire  [4:0]		BM0_Y_Offset_o,	// +/- 32
output	wire	[3:0]		BM0_Priority_o,
output	wire				BM0_Collision_On_o,

output	wire				BM1_Layer_Enable_o,
output	wire	[2:0]		BM1_Layer_Lut_o,		// Invalid when COllision Map is ON
output	wire				BM1_Coll_Map_En_o,	// Use the BM1 Layer has a Collision Map
output	wire				BM1_Coll_Map_Display_En_o,	// Display the Collision Map (Comes out IN Grey Scale)
output	wire	[23:0]	BM1_MapAddy_o,			// Pointer to the Bitmap or Collision MAP
output	wire 	[4:0]		BM1_X_Offset_o,	// +/- 32
output	wire 	[4:0]		BM1_Y_Offset_o,	// +/- 32
output	wire	[3:0]		BM1_Priority_o,
output	wire				BM1_Collision_On_o,

output	wire				COL_Layer_Enable_o,
output	wire	[23:0]	COL_MapAddy_o,
output	wire				COL_Collision_On_o,

// VRAM BANK B
output	wire				BM3_Layer_Enable_o,
output	wire	[2:0]		BM3_Layer_Lut_o,
output	wire	[23:0]	BM3_MapAddy_o,
output	wire 	[4:0]		BM3_X_Offset_o,	// +/- 32
output	wire  [4:0]		BM3_Y_Offset_o,	// +/- 32
output	wire	[3:0]		BM3_Priority_o,
output	wire				BM3_Collision_On_o
);

// This is the Block that the CPU can interact with for Read back mostly.
// The Transfer of the Data from one Clock Domain to another is done in the Proper Block.
//assign Bus_RDY_o = 1'b0;
reg [31:0]		BITMAP_CTRL0_REG[0:1];	// Control Register
reg [31:0]		BITMAP_CTRL1_REG[0:1];
reg [31:0]		BITMAP_CTRL2_REG[0:1];
reg [31:0]		BITMAP_CTRL3_REG[0:1];
//assign Bus_D_o = VICKY_MASTER_REG[Bus_A_i[4:0]];

// Writing Part
always @ (posedge Bus_Clk_i)
begin
	if (rst_i)
	begin
		BITMAP_CTRL0_REG[0] <= 32'h0000_0001;
		BITMAP_CTRL0_REG[1] <= 32'h0000_0000;
		
		BITMAP_CTRL1_REG[0] <= 32'h0000_0000;	// Check Vicky_Monochrome_Text_Block for Capture of that DATA.
		BITMAP_CTRL1_REG[1] <= 32'h0000_0000;
		
		BITMAP_CTRL2_REG[0] <= 32'h0000_0000;		// Check Vicky_Monochrome_Text_Block for Capture of that DATA.
		BITMAP_CTRL2_REG[1] <= 32'h0000_0000;
		
		BITMAP_CTRL3_REG[0] <= 32'h0000_0000;		// Check Vicky_Monochrome_Text_Block for Capture of that DATA.
		BITMAP_CTRL3_REG[1] <= 32'h0000_0000;
		
	end
	else
	begin
		if (Bitmap_CS_i && !Bus_RW_i && (Bus_D_Siz_i[1:0] == 2'b00) && Bus_WE_i) begin
			case (Bus_A_i[4:3])
				2'b00: BITMAP_CTRL0_REG[Bus_A_i[2]] <= Bus_D32_i;
				2'b01: BITMAP_CTRL1_REG[Bus_A_i[2]] <= Bus_D32_i;
				2'b10: BITMAP_CTRL2_REG[Bus_A_i[2]] <= Bus_D32_i;
				2'b11: BITMAP_CTRL3_REG[Bus_A_i[2]] <= Bus_D32_i;
			endcase
		end
	end
end

// BITMAP Layer 0
// BITMAP0_CTRL_REG[0] = Control Register - Enable/LUT
// BITMAP0_CTRL_REG[3:1] = BitmapPlane_Addy_Pointer
// BITMAP0_CTRL_REG[4] = BitmapPlane0_X_Offset
// BITMAP0_CTRL_REG[5] = BitmapPlane0_Y_Offset
// BITMAP0_CTRL_REG[6] = TBD
// BITMAP0_CTRL_REG[7] = TBD

// BITMAP Layer 1 (GUI MODE)
// BITMAP1_CTRL_REG[0] = Control Register - Enable/LUT
// BITMAP1_CTRL_REG[3:1] = BitmapPlane_Addy_Pointer
// BITMAP1_CTRL_REG[4] = BitmapPlane0_X_Offset
// BITMAP1_CTRL_REG[5] = BitmapPlane0_Y_Offset
// BITMAP1_CTRL_REG[6] = TBD
// BITMAP1_CTRL_REG[7] = TBD
//assign Bus_D_o = 32'h00;

always @ (*)
begin
	case(Bus_A_i[4:2])
		3'b000: Bus_D_o = BITMAP_CTRL0_REG[0];		// Tile_CR
		3'b001: Bus_D_o = BITMAP_CTRL0_REG[1];		// Tile Map L
		3'b010: Bus_D_o = BITMAP_CTRL1_REG[0];		// Tile Map M
		3'b011: Bus_D_o = BITMAP_CTRL1_REG[1];		// Tile Map H
		3'b100: Bus_D_o = BITMAP_CTRL2_REG[0];		// Tile Size L
		3'b101: Bus_D_o = BITMAP_CTRL2_REG[1];		// Tile Size H
		3'b110: Bus_D_o = BITMAP_CTRL3_REG[0];		// Tile Stride L
		3'b111: Bus_D_o = BITMAP_CTRL3_REG[1];		// Tile Stride H
		default: Bus_D_o = 32'hDEAD_BEEF;
	endcase
end


// Register 0 (32bits wide now) - Bitmap Layer 1
reg [31:0] BITMAP_CTRL0_REG01_SYNC_100[0:2];	// Control Register
reg [31:0] BITMAP_CTRL0_REG01_SYNC_200[0:2];
reg [31:0] BITMAP_CTRL0_REG23_SYNC_100[0:2];	// Address Pointer


// Register 0 (32bits wide now) - Bitmap Layer 2
reg [31:0] BITMAP_CTRL1_REG01_SYNC_100[0:2];	// Control Register
reg [31:0] BITMAP_CTRL1_REG01_SYNC_200[0:2];
reg [31:0] BITMAP_CTRL1_REG23_SYNC_100[0:2];	// Address Pointer


// Register 0 (32bits wide now) - Bitmap Layer 3
reg [31:0] BITMAP_CTRL2_REG01_SYNC_100[0:2];	// Control Register
reg [31:0] BITMAP_CTRL2_REG01_SYNC_200[0:2];
reg [31:0] BITMAP_CTRL2_REG23_SYNC_100[0:2];	// Address Pointer

// Register 0 (32bits wide now) - Bitmap Layer 4
reg [31:0] BITMAP_CTRL3_REG01_SYNC_100[0:2];	// Control Register
reg [31:0] BITMAP_CTRL3_REG01_SYNC_200[0:2];
reg [31:0] BITMAP_CTRL3_REG23_SYNC_100[0:2];	// Address Pointer




always @ (posedge EngineClk100Mhz_i)
begin
	// Bitmap Layer 0
	// CTRL0 Reg 0 - Control Register
	BITMAP_CTRL0_REG01_SYNC_100[0]<= BITMAP_CTRL0_REG[0];
	BITMAP_CTRL0_REG01_SYNC_100[1] <= BITMAP_CTRL0_REG01_SYNC_100[0];
	if ( BITMAP_CTRL0_REG01_SYNC_100[1] == BITMAP_CTRL0_REG01_SYNC_100[0])
		BITMAP_CTRL0_REG01_SYNC_100[2] <= BITMAP_CTRL0_REG01_SYNC_100[1];
		
	// CTRL0 Reg 0 - Address Pointer
	BITMAP_CTRL0_REG23_SYNC_100[0]<= BITMAP_CTRL0_REG[1];
	BITMAP_CTRL0_REG23_SYNC_100[1] <= BITMAP_CTRL0_REG23_SYNC_100[0];
	if ( BITMAP_CTRL0_REG23_SYNC_100[1] == BITMAP_CTRL0_REG23_SYNC_100[0])
		BITMAP_CTRL0_REG23_SYNC_100[2] <= BITMAP_CTRL0_REG23_SYNC_100[1];
		
	// Bitmap Layer 1
	// CTRL0 Reg 0 - Control Register
	BITMAP_CTRL1_REG01_SYNC_100[0]<=  BITMAP_CTRL1_REG[0];
	BITMAP_CTRL1_REG01_SYNC_100[1] <= BITMAP_CTRL1_REG01_SYNC_100[0];
	if ( BITMAP_CTRL1_REG01_SYNC_100[1] == BITMAP_CTRL1_REG01_SYNC_100[0])
		BITMAP_CTRL1_REG01_SYNC_100[2] <= BITMAP_CTRL1_REG01_SYNC_100[1];
		
	// CTRL0 Reg 0 - Address Pointer
	BITMAP_CTRL1_REG23_SYNC_100[0]<=  BITMAP_CTRL1_REG[1];
	BITMAP_CTRL1_REG23_SYNC_100[1] <= BITMAP_CTRL1_REG23_SYNC_100[0];
	if ( BITMAP_CTRL1_REG23_SYNC_100[1] == BITMAP_CTRL1_REG23_SYNC_100[0])
		BITMAP_CTRL1_REG23_SYNC_100[2] <= BITMAP_CTRL1_REG23_SYNC_100[1];		
		
	// Bitmap Collision Layer
	// CTRL0 Reg 0 - Control Register
	BITMAP_CTRL2_REG01_SYNC_100[0]<= BITMAP_CTRL2_REG[0];
	BITMAP_CTRL2_REG01_SYNC_100[1] <= BITMAP_CTRL2_REG01_SYNC_100[0];
	if ( BITMAP_CTRL2_REG01_SYNC_100[1] == BITMAP_CTRL2_REG01_SYNC_100[0])
		BITMAP_CTRL2_REG01_SYNC_100[2] <= BITMAP_CTRL2_REG01_SYNC_100[1];
		
	// CTRL0 Reg 0 - Address Pointer
	BITMAP_CTRL2_REG23_SYNC_100[0]<= BITMAP_CTRL2_REG[1];
	BITMAP_CTRL2_REG23_SYNC_100[1] <= BITMAP_CTRL2_REG23_SYNC_100[0];
	if ( BITMAP_CTRL2_REG23_SYNC_100[1] == BITMAP_CTRL2_REG23_SYNC_100[0])
		BITMAP_CTRL2_REG23_SYNC_100[2] <= BITMAP_CTRL2_REG23_SYNC_100[1];
		
	// Bitmap VRAM BANK B
	// CTRL0 Reg 0 - Control Register
	BITMAP_CTRL3_REG01_SYNC_100[0]<= BITMAP_CTRL3_REG[0];
	BITMAP_CTRL3_REG01_SYNC_100[1] <= BITMAP_CTRL3_REG01_SYNC_100[0];
	if ( BITMAP_CTRL3_REG01_SYNC_100[1] == BITMAP_CTRL3_REG01_SYNC_100[0])
		BITMAP_CTRL3_REG01_SYNC_100[2] <= BITMAP_CTRL3_REG01_SYNC_100[1];
		
	// CTRL0 Reg 0 - Address Pointer
	BITMAP_CTRL3_REG23_SYNC_100[0]<= BITMAP_CTRL3_REG[1];
	BITMAP_CTRL3_REG23_SYNC_100[1] <= BITMAP_CTRL3_REG23_SYNC_100[0];
	if ( BITMAP_CTRL3_REG23_SYNC_100[1] == BITMAP_CTRL3_REG23_SYNC_100[0])
		BITMAP_CTRL3_REG23_SYNC_100[2] <= BITMAP_CTRL3_REG23_SYNC_100[1];		

end

always @ (posedge EngineClk200Mhz_i)
begin
	// Bitmap Layer 0
	// CTRL0 Reg 0 - Control Register
	BITMAP_CTRL0_REG01_SYNC_200[0]<= BITMAP_CTRL0_REG[0];
	BITMAP_CTRL0_REG01_SYNC_200[1] <= BITMAP_CTRL0_REG01_SYNC_200[0];
	if ( BITMAP_CTRL0_REG01_SYNC_200[1] == BITMAP_CTRL0_REG01_SYNC_200[0])
		BITMAP_CTRL0_REG01_SYNC_200[2] <= BITMAP_CTRL0_REG01_SYNC_200[1];
		
	// Bitmap Layer 1
	// CTRL0 Reg 0 - Control Register
	BITMAP_CTRL1_REG01_SYNC_200[0]<= BITMAP_CTRL1_REG[0];
	BITMAP_CTRL1_REG01_SYNC_200[1] <= BITMAP_CTRL1_REG01_SYNC_200[0];
	if ( BITMAP_CTRL1_REG01_SYNC_200[1] == BITMAP_CTRL1_REG01_SYNC_200[0])
		BITMAP_CTRL1_REG01_SYNC_200[2] <= BITMAP_CTRL1_REG01_SYNC_200[1];
	
	// Bitmap Collision Layer
	// CTRL0 Reg 0 - Control Register
	BITMAP_CTRL2_REG01_SYNC_200[0]<= BITMAP_CTRL2_REG[0];
	BITMAP_CTRL2_REG01_SYNC_200[1] <= BITMAP_CTRL2_REG01_SYNC_200[0];
	if ( BITMAP_CTRL2_REG01_SYNC_200[1] == BITMAP_CTRL2_REG01_SYNC_200[0])
		BITMAP_CTRL2_REG01_SYNC_200[2] <= BITMAP_CTRL2_REG01_SYNC_200[1];
		
	// Bitmap Collision Layer
	// CTRL0 Reg 0 - Control Register
	BITMAP_CTRL3_REG01_SYNC_200[0]<= BITMAP_CTRL3_REG[0];
	BITMAP_CTRL3_REG01_SYNC_200[1] <= BITMAP_CTRL3_REG01_SYNC_200[0];
	if ( BITMAP_CTRL3_REG01_SYNC_200[1] == BITMAP_CTRL3_REG01_SYNC_200[0])
		BITMAP_CTRL3_REG01_SYNC_200[2] <= BITMAP_CTRL3_REG01_SYNC_200[1];		
	
end

assign BM0_Layer_Enable_o 	= BITMAP_CTRL0_REG01_SYNC_200[2][0];
assign BM0_Layer_Lut_o 		= BITMAP_CTRL0_REG01_SYNC_200[2][3:1]; 
assign BM0_Collision_On_o 	= BITMAP_CTRL0_REG01_SYNC_200[2][6];

assign BM0_MapAddy_o 		= BITMAP_CTRL0_REG23_SYNC_100[2][23:0]; 
assign BM0_X_Offset_o 		= BITMAP_CTRL0_REG01_SYNC_100[2][12:8];			// +/- 32
assign BM0_Y_Offset_o 		= BITMAP_CTRL0_REG01_SYNC_100[2][20:16];			// +/- 32
assign BM0_Priority_o 		= BITMAP_CTRL0_REG01_SYNC_100[2][27:24];	// Priority


assign BM1_Layer_Enable_o 	= BITMAP_CTRL1_REG01_SYNC_200[2][0];
assign BM1_Layer_Lut_o 		= BITMAP_CTRL1_REG01_SYNC_200[2][3:1];
assign BM1_Collision_On_o 	= BITMAP_CTRL1_REG01_SYNC_200[2][6];
// Special Register to Set the Collision MAP
assign BM1_Coll_Map_En_o 			= BITMAP_CTRL1_REG01_SYNC_100[2][4];		// 1: Collision MAP, 0: Bitmap
assign BM1_Coll_Map_Display_En_o = BITMAP_CTRL1_REG01_SYNC_100[2][5];

assign BM1_MapAddy_o  		= BITMAP_CTRL1_REG23_SYNC_100[2][23:0]; 

assign BM1_X_Offset_o 		= BITMAP_CTRL1_REG01_SYNC_100[2][12:8];			// +/ +/- 32
assign BM1_Y_Offset_o 		= BITMAP_CTRL1_REG01_SYNC_100[2][20:16];			// +/ +/- 32
assign BM1_Priority_o 		= BITMAP_CTRL1_REG01_SYNC_100[2][27:24];	// Priority

assign COL_Layer_Enable_o 	= BITMAP_CTRL2_REG01_SYNC_200[2][0];
assign COL_MapAddy_o 		= BITMAP_CTRL2_REG23_SYNC_100[2][23:0];
assign COL_Collision_On_o 	= BITMAP_CTRL2_REG01_SYNC_200[2][6];

// VRAM BANK B
assign BM3_Layer_Enable_o 	= BITMAP_CTRL3_REG01_SYNC_200[2][0];
assign BM3_Layer_Lut_o 		= BITMAP_CTRL3_REG01_SYNC_200[2][3:1]; 
assign BM3_Collision_On_o 	= BITMAP_CTRL3_REG01_SYNC_200[2][6];

assign BM3_MapAddy_o 		= BITMAP_CTRL3_REG23_SYNC_100[2][23:0]; 
assign BM3_X_Offset_o 		= BITMAP_CTRL3_REG01_SYNC_100[2][12:8];			// +/- 32
assign BM3_Y_Offset_o 		= BITMAP_CTRL3_REG01_SYNC_100[2][20:16];			// +/- 32
assign BM3_Priority_o 		= BITMAP_CTRL3_REG01_SYNC_100[2][27:24];	// Priority

endmodule

