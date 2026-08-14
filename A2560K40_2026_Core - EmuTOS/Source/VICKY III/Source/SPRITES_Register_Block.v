`timescale 1 ns / 1 ns
module SPRITES_Register_Block (
input 	wire				rst_i,				// This is async Reset
// CPU Signals Interface
input 	wire				Bus_Clk_i,
input 	wire	[15:0]	Bus_A_i,
input		wire  [7:0]		Bus_D_i,
input		wire				Bus_RW_i,
input		wire				Sprite_CS_i,

input		wire				IID_Engine_Clk_i,
input		wire	[4:0]		Sprite_Select_i,
output	wire	[7:0]		Sprite_Control_Reg_o,
output	wire	[23:0]	Sprite_Address_Ptr_o,
output	wire	[15:0]	Sprite_X_Coordinate_o,
output	wire	[15:0]	Sprite_Y_Coordinate_o

);

// SpriteControl_Register0[7:0] = COntrol Register
// SpriteControl_Register0[31:8] = Sprite Address Pointer in Video Memory
// SpriteControl_Register0[47:32] = SpriteControl_Register0 X Pointer
// SpriteControl_Register0[63:48] = SpriteControl_Register0 Y Pointer

wire	[63:0]		OutputSpriteMem;

Sprite_Register_Block Sprite_Block(
	.data( Bus_D_i ),
	.rdaddress( Sprite_Select_i ),
	.rdclock( IID_Engine_Clk_i ),
	.wraddress( Bus_A_i ),
	.wrclock( !Bus_Clk_i ),
	.wren( Sprite_CS_i & !Bus_RW_i ),
	.q( OutputSpriteMem )
);

assign Sprite_Control_Reg_o = OutputSpriteMem[7:0];
assign Sprite_Address_Ptr_o = OutputSpriteMem[31:8];
assign Sprite_X_Coordinate_o = OutputSpriteMem[47:32];
assign Sprite_Y_Coordinate_o = OutputSpriteMem[63:48];


endmodule

