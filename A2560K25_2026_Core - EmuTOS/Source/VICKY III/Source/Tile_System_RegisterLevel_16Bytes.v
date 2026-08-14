
`timescale 1 ns / 1 ns
module Tile_System_RegisterLevel_16Bytes 
(
input 	wire				rst_i,				// This is async Reset
// CPU Signals Interface
input 	wire				Bus_Clk_i,
input 	wire	[9:0]		Bus_A_i,
input		wire  [7:0]		Bus_D_i,
output 	wire	[7:0]		Bus_D_o,
input		wire				Bus_RW_i,
input		wire				Tile_CS_i,
// Output to the F2DEngine
output	wire				TileLayer_Enable_o,
output	wire	[2:0]		TileLayer_Lut_o,
output	wire	[23:0]	TileMapAddy_o,
output	wire	[15:0]	TileMapSize_o,
output	wire	[15:0]	TileMapStride_o,
output	wire	[23:0]	TileGrapTableAddy_o,
output	wire	[15:0]	TileGrapSize_o,
output	wire	[15:0]	TileGrapStride_o,
output	wire	[3:0]		TileGrapX_Offset_o,
output	wire	[3:0]		TileGrapY_Offset_o
);

// This is the Block that the CPU can interact with for Read back mostly.
// The Transfer of the Data from one Clock Domain to another is done in the Proper Block.
//assign Bus_RDY_o = 1'b0;
reg [7:0]		TILE_CTRL_REG0;
reg [7:0]		TILE_CTRL_REG1;
reg [7:0]		TILE_CTRL_REG2;
reg [7:0]		TILE_CTRL_REG3;
reg [7:0]		TILE_CTRL_REG4;
reg [7:0]		TILE_CTRL_REG5;
reg [7:0]		TILE_CTRL_REG6;
reg [7:0]		TILE_CTRL_REG7;
reg [7:0]		TILE_CTRL_REG8;
reg [7:0]		TILE_CTRL_REG9;
reg [7:0]		TILE_CTRL_REG10;
reg [7:0]		TILE_CTRL_REG11;
reg [7:0]		TILE_CTRL_REG12;
reg [7:0]		TILE_CTRL_REG13;
reg [7:0]		TILE_CTRL_REG14;
reg [7:0]		TILE_CTRL_REG15;
//assign Bus_D_o = VICKY_MASTER_REG[Bus_A_i[4:0]];

// Writing Part
always @ (negedge Bus_Clk_i)
begin
	if (rst_i)
	begin
		TILE_CTRL_REG0 <= 8'h00;
		TILE_CTRL_REG1 <= 8'h00;
		TILE_CTRL_REG2 <= 8'h00;
		TILE_CTRL_REG3 <= 8'h00;
		TILE_CTRL_REG4 <= 8'h00;
		TILE_CTRL_REG5 <= 8'h00;
		TILE_CTRL_REG6 <= 8'h00;
		TILE_CTRL_REG7 <= 8'h00; 
		TILE_CTRL_REG8 <= 8'h00;		// Check Vicky_Monochrome_Text_Block for Capture of that DATA.
		TILE_CTRL_REG9 <= 8'h00;
		TILE_CTRL_REG10 <= 8'h00;
		TILE_CTRL_REG11 <= 8'h00;
		TILE_CTRL_REG12 <= 8'h00;
		TILE_CTRL_REG13 <= 8'h00;
		TILE_CTRL_REG14 <= 8'h00;
		TILE_CTRL_REG15 <= 8'h00;
	end
	else
	begin
		if (Tile_CS_i & !Bus_RW_i) begin
			case(Bus_A_i[3:0])
				4'b0000: TILE_CTRL_REG0 <= Bus_D_i;		// Tile_CR
				4'b0001: TILE_CTRL_REG1 <= Bus_D_i;		// Tile Map L
				4'b0010: TILE_CTRL_REG2 <= Bus_D_i;		// Tile Map M
				4'b0011: TILE_CTRL_REG3 <= Bus_D_i;		// Tile Map H
				4'b0100: TILE_CTRL_REG4 <= Bus_D_i;		// Tile Size L
				4'b0101: TILE_CTRL_REG5 <= Bus_D_i;		// Tile Size H
				4'b0110: TILE_CTRL_REG6 <= Bus_D_i;		// Tile Stride L
				4'b0111: TILE_CTRL_REG7 <= Bus_D_i;		// Tile Stride H
				4'b1000: TILE_CTRL_REG8 <= Bus_D_i;		// Tile Graphic Table L
				4'b1001: TILE_CTRL_REG9 <= Bus_D_i;		// Tile Graphic Table M
				4'b1010: TILE_CTRL_REG10 <= Bus_D_i;		// Tile Graphic Table H
				4'b1011: TILE_CTRL_REG11 <= Bus_D_i;		// Tile Graphic Size L
				4'b1100: TILE_CTRL_REG12 <= Bus_D_i;		// Tile Graphic Size H
				4'b1101: TILE_CTRL_REG13 <= Bus_D_i;		// Tile Graphic Stride L
				4'b1110: TILE_CTRL_REG14 <= Bus_D_i;		// Tile Graphic Stride H
				4'b1111: TILE_CTRL_REG15 <= Bus_D_i;		// Tile Graphic Position X:[0..15]:Y:[0..15] 
			endcase		
		 
		end
	end
end
assign Bus_D_o = 8'h00;
/*
always @ (*)
begin
	case(Bus_A_i[3:0])
		4'b0000: Bus_D_o = TILE_CTRL_REG0;		// Tile_CR
		4'b0001: Bus_D_o = TILE_CTRL_REG1;		// Tile Map L
		4'b0010: Bus_D_o = TILE_CTRL_REG2;		// Tile Map M
		4'b0011: Bus_D_o = TILE_CTRL_REG3;		// Tile Map H
		4'b0100: Bus_D_o = TILE_CTRL_REG4;		// Tile Size L
		4'b0101: Bus_D_o = TILE_CTRL_REG5;		// Tile Size H
		4'b0110: Bus_D_o = TILE_CTRL_REG6;		// Tile Stride L
		4'b0111: Bus_D_o = TILE_CTRL_REG7;		// Tile Stride H
		4'b1000: Bus_D_o = TILE_CTRL_REG8;		// Tile Graphic Table L
		4'b1001: Bus_D_o = TILE_CTRL_REG9;		// Tile Graphic Table M
		4'b1010: Bus_D_o = TILE_CTRL_REG10;		// Tile Graphic Table H
		4'b1011: Bus_D_o = TILE_CTRL_REG11;		// Tile Graphic Size L
		4'b1100: Bus_D_o = TILE_CTRL_REG12;		// Tile Graphic Size H
		4'b1101: Bus_D_o = TILE_CTRL_REG13;		// Tile Graphic Stride L
		4'b1110: Bus_D_o = TILE_CTRL_REG14;		// Tile Graphic Stride H
		4'b1111: Bus_D_o = TILE_CTRL_REG15;		// Tile Graphic Position X:[0..15]:Y:[0..15] 
	endcase
end
*/

// Assignment
assign TileLayer_Enable_o = TILE_CTRL_REG0[0];
assign TileLayer_Lut_o = TILE_CTRL_REG0[3:1];
assign TileMapAddy_o = {TILE_CTRL_REG3, TILE_CTRL_REG2, TILE_CTRL_REG1};
assign TileMapSize_o = {TILE_CTRL_REG5, TILE_CTRL_REG4}; 
assign TileMapStride_o = {TILE_CTRL_REG7, TILE_CTRL_REG6}; 
assign TileGrapTableAddy_o = {TILE_CTRL_REG10, TILE_CTRL_REG9, TILE_CTRL_REG8};
assign TileGrapSize_o = {TILE_CTRL_REG12, TILE_CTRL_REG11}; 
assign TileGrapStride_o = {TILE_CTRL_REG14, TILE_CTRL_REG13};
assign TileGrapX_Offset_o = TILE_CTRL_REG15[7:4]; 
assign TileGrapY_Offset_o = TILE_CTRL_REG15[3:0]; 

endmodule

