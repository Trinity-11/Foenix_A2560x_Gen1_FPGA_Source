`timescale 1 ns / 1 ns
module Tile_Registers_Blk(
input 	wire				rst_i,				// This is async Reset
// CPU Signals Interface
input 	wire				Bus_Clk_i,
input 	wire	[9:0]		Bus_A_i,
input		wire  [7:0]		Bus_D_i,
input		wire				Bus_RW_i,
input		wire				Tile_CS_i,
// Output to the F2DEngine

input		wire				IID_Engine_Clk_i,
input		wire	[1:0]		TileLayerSelect_i,

output	reg	[7:0]		TileLayer_Control_Reg,
output	reg	[23:0]	TileLayer_Address_Ptr,
output	reg	[11:0]	TileLayer_X_Stride,
output	reg	[11:0]	TileLayer_Y_Stride,
output	reg	[3:0]		TileLayer_X_Offset,
output	reg	[3:0]		TileLayer_Y_Offset
);

/*
input		wire	[4:0]		Sprite_Select_i,
output	wire	[7:0]		Sprite_Control_Reg_o,
output	wire	[23:0]	Sprite_Address_Ptr_o,
output	wire	[15:0]	Sprite_X_Coordinate_o,
output	wire	[15:0]	Sprite_Y_Coordinate_o
*/
/*
wire	[63:0]	Output;

Tile_Registers_Block TileRegBlock(
	.data( Bus_D_i ),
	.rdaddress( {TileLayerSelect_i, 1'b0}  ),
	.rdclock( IID_Engine_Clk_i ),
	.wraddress( Bus_A_i ),
	.wrclock( !Bus_Clk_i ),
	.wren( Tile_CS_i & !Bus_RW_i ),
	.q( Output )
);
*/
reg [7:0]		TILE_REG[0:31];

//assign Bus_D_o = VICKY_MASTER_REG[Bus_A_i[4:0]];

// Writing Part
always @ (negedge Bus_Clk_i)
begin
	if (rst_i)
	begin
		TILE_REG[0] <= 8'h00;		// VKY Master Ctrl Reg L
		TILE_REG[1] <= 8'h00;		// VKY Master Ctrl Reg H
		TILE_REG[2] <= 8'h00;		// TBD
		TILE_REG[3] <= 8'h00;		// TBD
		TILE_REG[4] <= 8'h00;		// Border CONTROL Reg
		TILE_REG[5] <= 8'h00;		// Border Blue
		TILE_REG[6] <= 8'h00;		// Border Green
		TILE_REG[7] <= 8'h00;		// Border Red 
		TILE_REG[8] <= 8'h00;		// Check Vicky_Monochrome_Text_Block for Capture of that DATA.
		TILE_REG[9] <= 8'h00;
		TILE_REG[10] <= 8'h00;
		TILE_REG[11] <= 8'h00;
		TILE_REG[12] <= 8'h00;
		TILE_REG[13] <= 8'h00;
		TILE_REG[14] <= 8'h00;
		TILE_REG[15] <= 8'h00;
		TILE_REG[16] <= 8'h00;
		TILE_REG[17] <= 8'h00;
		TILE_REG[18] <= 8'h00;
		TILE_REG[19] <= 8'h00;
		TILE_REG[20] <= 8'h00;
		TILE_REG[21] <= 8'h00; 
		TILE_REG[22] <= 8'h00;
		TILE_REG[23] <= 8'h00; 
		TILE_REG[24] <= 8'h00;
		TILE_REG[25] <= 8'h00; 
		TILE_REG[26] <= 8'h00;
		TILE_REG[27] <= 8'h00; 
		TILE_REG[28] <= 8'h00;
		TILE_REG[29] <= 8'h00; 
		TILE_REG[30] <= 8'h00;
		TILE_REG[31] <= 8'h00;
	end
	else
	begin
		if (Tile_CS_i & !Bus_RW_i)
			TILE_REG[Bus_A_i[4:0]] <= Bus_D_i;
	end
end

always @ (posedge IID_Engine_Clk_i)
begin
	case (TileLayerSelect_i)
	
	2'b00: begin
		TileLayer_Control_Reg  <= TILE_REG[0];	
		TileLayer_Address_Ptr  <= {TILE_REG[3], TILE_REG[2], TILE_REG[1]};
		TileLayer_X_Stride     <= {TILE_REG[5][3:0] , TILE_REG[4][7:0]};
		TileLayer_X_Offset	  <= TILE_REG[5][7:4];	
		TileLayer_Y_Stride	  <= {TILE_REG[7][3:0] , TILE_REG[6][7:0]};	//
		TileLayer_Y_Offset	  <= TILE_REG[7][7:4];	
	end
	
	2'b01: begin
		TileLayer_Control_Reg  <= TILE_REG[8];	
		TileLayer_Address_Ptr  <= {TILE_REG[11], TILE_REG[10], TILE_REG[9]};
		TileLayer_X_Stride     <= {TILE_REG[13][3:0] , TILE_REG[12][7:0]};
		TileLayer_X_Offset	  <= TILE_REG[13][7:4];	
		TileLayer_Y_Stride	  <= {TILE_REG[15][3:0] , TILE_REG[14][7:0]};	//
		TileLayer_Y_Offset	  <= TILE_REG[15][7:4];		
	end
	
	2'b10: begin
		TileLayer_Control_Reg  <= TILE_REG[16];	
		TileLayer_Address_Ptr  <= {TILE_REG[19], TILE_REG[18], TILE_REG[17]};
		TileLayer_X_Stride     <= {TILE_REG[21][3:0] , TILE_REG[20][7:0]};
		TileLayer_X_Offset	  <= TILE_REG[21][7:4];	
		TileLayer_Y_Stride	  <= {TILE_REG[23][3:0] , TILE_REG[22][7:0]};	//
		TileLayer_Y_Offset	  <= TILE_REG[23][7:4];		
	end
	
	2'b11: begin
		TileLayer_Control_Reg  <= TILE_REG[24];	
		TileLayer_Address_Ptr  <= {TILE_REG[27], TILE_REG[26], TILE_REG[25]};
		TileLayer_X_Stride     <= {TILE_REG[29][3:0] , TILE_REG[28][7:0]};
		TileLayer_X_Offset	  <= TILE_REG[29][7:4];	
		TileLayer_Y_Stride	  <= {TILE_REG[31][3:0] , TILE_REG[30][7:0]};	//
		TileLayer_Y_Offset	  <= TILE_REG[31][7:4];			
	end
	
	default: begin
	
	end
	
	endcase

end


// Assignment
//assign TileLayer_Control_Reg = Output[7:0];		// Control Register (0 - Enable, 1-3 - LUT
//assign TileLayer_Address_Ptr = Output[31:8];	   // Points towards to the TILE Page where the graphics are
//assign TileLayer_X_Stride    = Output[43:32];	// Offset for next Character Default ought to be $0100 (16 x 16)
//assign TileLayer_X_Offset	  = Output[47:44];	// Offset of the Plane (X Scroll)
//assign TileLayer_Y_Stride	  = Output[59:48];	//
//assign TileLayer_Y_Offset	  = Output[63:60];	// Offset of the Plane (Y Scroll)

endmodule
