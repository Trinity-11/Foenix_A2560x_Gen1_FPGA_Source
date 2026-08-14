module VickyII_Collision_System_Module(
input		wire				VideoRst_200Mhz_i,
input		wire				VideoModeReset_200Mhz_i,
input		wire	[1:0]		Mstr_Ctrl_Video_Mode100Mhz_i,
input 	wire				Mstr_Ctrl_Doubling_Pixel_100Mhz_i,
input		wire				EngineClk200Mhz_i,

input		wire				Read_Pixel_Lines_i,
// Sprite MAP  Pixel
input		wire	[7:0]		Sprite_Data_Col_i,
input		wire	[15:0]	Attributes_Data_Col_i,
// Bitmap & Collision Map Pixel
input		wire	[7:0]		BitMap0_Pixel_Col_i,
input		wire	[7:0]		BitMap1_Pixel_Col_i,
input		wire	[7:0]		Collision_Data_Col_i,
// Tile Layer Map INput Pixel
input		wire	[7:0]		Line1_Pixel_Col_i,
input		wire	[7:0]		Line2_Pixel_Col_i,
input		wire	[7:0]		Line3_Pixel_Col_i,
input		wire	[7:0]		Line4_Pixel_Col_i,

input		wire	[7:0]		TileMap0_Attr_Col_i,
input		wire	[7:0]		TileMap1_Attr_Col_i,
input		wire	[7:0]		TileMap2_Attr_Col_i,
input		wire	[7:0]		TileMap3_Attr_Col_i,

input 	wire 				BM0_Collision_On_i,
input		wire 				BM1_Collision_On_i,
input 	wire 				COL_Collision_On_i,

input		wire				TileL0Collision_On_i,
input		wire				TileL1Collision_On_i,
input		wire				TileL2Collision_On_i,
input		wire				TileL3Collision_On_i,

// Pixel Present Flags
input		wire				Sprite_Pixel_Not_Zero_i,
input		wire				BM0_Pixel_Not_Zero_i,
input		wire				BM1_Pixel_Not_Zero_i,
input		wire				COL_Pixel_Not_Zero_i,
input		wire				TL0_Pixel_Not_Zero_i,
input		wire				TL1_Pixel_Not_Zero_i,
input		wire				TL2_Pixel_Not_Zero_i,
input		wire				TL3_Pixel_Not_Zero_i,

// Incoming Mask for the Collision System
output	reg	[15:0]	Collision_SpriteL0_o,
output	reg	[15:0]	Collision_SpriteL1_o,
output	reg	[15:0]	Collision_SpriteL2_o,
output	reg	[15:0]	Collision_SpriteL3_o,
output	reg	[15:0]	Collision_SpriteL4_o,
output	reg	[15:0]	Collision_SpriteL5_o,
output	reg	[15:0]	Collision_SpriteL6_o,

output	reg	[15:0]	Collision_BM0_o,
output	reg	[15:0]	Collision_BM1_o,
output	reg	[15:0]	Collision_COL_o,

output	reg	[15:0]	Collision_TL0_o,
output	reg	[15:0]	Collision_TL1_o,
output	reg	[15:0]	Collision_TL2_o,
output	reg	[15:0]	Collision_TL3_o,

// Let the user have the Pixel Information when a Collision Happens
output	reg	[7:0]		Sprite_Collision_Pixel_o,
output	reg	[5:0]		Sprite_Collision_Channel_o,
output	reg	[7:0]		Bitmap_L0_Collision_Pixel_o,
output	reg	[7:0]		Bitmap_L1_Collision_Pixel_o,
output	reg	[7:0]		Bitmap_C0_Collision_Pixel_o,
output	reg	[7:0]		Tilemap_L0_Collision_Pixel_o,
output	reg	[7:0]		Tilemap_L1_Collision_Pixel_o,
output	reg	[7:0]		Tilemap_L2_Collision_Pixel_o,
output	reg	[7:0]		Tilemap_L3_Collision_Pixel_o,
//
input		wire	[15:0]	Collision_VideoLine_Active_i,
output	reg	[15:0]	Collision_Y_Location_o,
output	reg	[15:0]	Collision_Sprite_X_Location_o,
output	reg	[15:0]	Collision_Bitmap_X_Location_o,
output	reg	[15:0]	Collision_Tiles_X_Location_o,

output	wire				Sprite_Collision_Interrupt_o,
output	wire				Bitmap_Collision_Interrupt_o,
output	wire				Tilemap_Collision_Interrupt_o
);

initial begin
	Collision_Sprite_X_Location_o = 16'h0000;
	Collision_Bitmap_X_Location_o	= 16'h0000;
	Collision_Tiles_X_Location_o	= 16'h0000;
	Collision_Y_Location_o = 16'h0000;
end


assign 		Sprite_Collision_Interrupt_o 	= Collision_GRP_A_Int_Slide[31];
assign 		Bitmap_Collision_Interrupt_o 	= Collision_GRP_B_Int_Slide[31];
assign 		Tilemap_Collision_Interrupt_o = Collision_GRP_C_Int_Slide[31];

wire				SP0_Pixel_Present;
wire				SP1_Pixel_Present;
wire				SP2_Pixel_Present;
wire				SP3_Pixel_Present;
wire				SP4_Pixel_Present;
wire				SP5_Pixel_Present;
wire				SP6_Pixel_Present;
wire				BM0_Pixel_Present;
wire				BM1_Pixel_Present;
wire				COL_Pixel_Present;
wire				TL0_Pixel_Present;
wire				TL1_Pixel_Present;
wire				TL2_Pixel_Present;
wire				TL3_Pixel_Present;

reg	[6:0]		Sprite_Channel;

always @ (posedge  EngineClk200Mhz_i) begin
	case (Attributes_Data_Col_i[5:3])
		3'b000: Sprite_Channel <= 7'b000_0001;		//000
		3'b001: Sprite_Channel <= 7'b000_0010;		//001
		3'b010: Sprite_Channel <= 7'b000_0100;		//010
		3'b011: Sprite_Channel <= 7'b000_1000;		//011
		3'b100: Sprite_Channel <= 7'b001_0000;     //100
		3'b101: Sprite_Channel <= 7'b010_0000;     //101
		3'b110: Sprite_Channel <= 7'b100_0000;     //110
		3'b111: Sprite_Channel <= 7'b000_0000;     //
	endcase
end

assign SP0_Pixel_Present	=  ( Attributes_Data_Col_i[12]	& Sprite_Channel[0] & Sprite_Pixel_Not_Zero_i); 
assign SP1_Pixel_Present	=  ( Attributes_Data_Col_i[12] 	& Sprite_Channel[1] & Sprite_Pixel_Not_Zero_i); 
assign SP2_Pixel_Present	=  ( Attributes_Data_Col_i[12] 	& Sprite_Channel[2] & Sprite_Pixel_Not_Zero_i); 
assign SP3_Pixel_Present	=  ( Attributes_Data_Col_i[12] 	& Sprite_Channel[3] & Sprite_Pixel_Not_Zero_i); 
assign SP4_Pixel_Present	=  ( Attributes_Data_Col_i[12] 	& Sprite_Channel[4] & Sprite_Pixel_Not_Zero_i); 
assign SP5_Pixel_Present   =  ( Attributes_Data_Col_i[12] 	& Sprite_Channel[5] & Sprite_Pixel_Not_Zero_i); 
assign SP6_Pixel_Present	=  ( Attributes_Data_Col_i[12] 	& Sprite_Channel[6] & Sprite_Pixel_Not_Zero_i);
assign BM0_Pixel_Present 	=  ( BM0_Collision_On_i 			& BM0_Pixel_Not_Zero_i);
assign BM1_Pixel_Present 	=  ( BM1_Collision_On_i 			& BM1_Pixel_Not_Zero_i);  
assign COL_Pixel_Present   =  ( COL_Collision_On_i				& COL_Pixel_Not_Zero_i);
assign TL0_Pixel_Present 	=  ( TileMap0_Attr_Col_i[6] & TileL0Collision_On_i & TL0_Pixel_Not_Zero_i);
assign TL1_Pixel_Present 	=  ( TileMap1_Attr_Col_i[6] & TileL1Collision_On_i & TL1_Pixel_Not_Zero_i);
assign TL2_Pixel_Present 	=  ( TileMap2_Attr_Col_i[6] & TileL2Collision_On_i & TL2_Pixel_Not_Zero_i);
assign TL3_Pixel_Present 	=  ( TileMap3_Attr_Col_i[6] & TileL3Collision_On_i & TL3_Pixel_Not_Zero_i);


//////////////////////////////////////////
// SPRITE Collision
//////////////////////////////////////////
reg	[13:0]	SpriteLevel0_Collision_Found;
reg	[13:0]	SpriteLevel1_Collision_Found;
reg	[13:0]	SpriteLevel2_Collision_Found;
reg	[13:0]	SpriteLevel3_Collision_Found;
reg	[13:0]	SpriteLevel4_Collision_Found;
reg	[13:0]	SpriteLevel5_Collision_Found;
reg	[13:0]	SpriteLevel6_Collision_Found;

wire 	Tile_Amalgamate;
wire  Bitmap_Amalgamate;
assign Tile_Amalgamate =  TL3_Pixel_Present | TL2_Pixel_Present | TL1_Pixel_Present | TL0_Pixel_Present ;
assign Bitmap_Amalgamate =  BM0_Pixel_Present | BM1_Pixel_Present | COL_Pixel_Present ; 

// Sprite Level 0
always @ (posedge  EngineClk200Mhz_i) begin
	if (( SP0_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel0_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b000_0001};
	end
	else begin
		SpriteLevel0_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 1
always @ (posedge  EngineClk200Mhz_i) begin
	if (( SP1_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel1_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b000_0010};
	end
	else begin
		SpriteLevel1_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 2
always @ (posedge  EngineClk200Mhz_i) begin
	if (( SP2_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel2_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b000_0100};
	end
	else begin
		SpriteLevel2_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 3
always @ (posedge  EngineClk200Mhz_i) begin
	if (( SP3_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel3_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b000_1000};
	end
	else begin
		SpriteLevel3_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 4
always @ (posedge  EngineClk200Mhz_i) begin
	if (( SP4_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel4_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b001_0000};
	end
	else begin
		SpriteLevel4_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 5
always @ (posedge  EngineClk200Mhz_i) begin
	if (( SP5_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel5_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b010_0000};
	end
	else begin
		SpriteLevel5_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
	end
end
// Sprite Level 6
always @ (posedge  EngineClk200Mhz_i) begin
	if (( SP6_Pixel_Present ) & (Tile_Amalgamate | Bitmap_Amalgamate)) begin
		SpriteLevel6_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, COL_Pixel_Present, BM1_Pixel_Present, BM0_Pixel_Present, 7'b100_0000};
	end
	else begin
		SpriteLevel6_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
	end
end

always @ (posedge EngineClk200Mhz_i)
begin 
	if (Collision_GRP_A_Int_Slide[31:30] == 2'b01) begin
		Collision_SpriteL0_o <= Collision_Sprite_L0_Slip1;
		Collision_SpriteL1_o <= Collision_Sprite_L1_Slip1;
		Collision_SpriteL2_o <= Collision_Sprite_L2_Slip1;
		Collision_SpriteL3_o <= Collision_Sprite_L3_Slip1; 
		Collision_SpriteL4_o <= Collision_Sprite_L4_Slip1;
		Collision_SpriteL5_o <= Collision_Sprite_L5_Slip1;
		Collision_SpriteL6_o <= Collision_Sprite_L6_Slip1;	
	end
end

wire Sprite_Collision_Interrupt;

assign Sprite_Collision_Interrupt = SpriteLevel0_Collision_Found[0] | SpriteLevel1_Collision_Found[1] | SpriteLevel2_Collision_Found[2]  | SpriteLevel3_Collision_Found[3] | SpriteLevel4_Collision_Found[4] | SpriteLevel5_Collision_Found[5] | SpriteLevel6_Collision_Found[6]; // | (ColmapX_Collision_Found);

//////////////////////////////////////////
// BitMap Collision
//////////////////////////////////////////
reg	[13:0]	Bitmap0_Collision_Found;
reg	[13:0]	Bitmap1_Collision_Found;
reg	[13:0]	ColmapX_Collision_Found;
// BM0
always @ (posedge  EngineClk200Mhz_i) begin
	if (( BM0_Pixel_Present ) & ( Tile_Amalgamate | Sprite_Channel[6] | Sprite_Channel[5] | Sprite_Channel[4] | Sprite_Channel[3] | Sprite_Channel[2] | Sprite_Channel[1] | Sprite_Channel[0]))
		Bitmap0_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, 3'b001, Sprite_Channel};
	else
		Bitmap0_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
end

// BM1
always @ (posedge  EngineClk200Mhz_i) begin
	if (( BM1_Pixel_Present ) & ( Tile_Amalgamate | Sprite_Channel[6] | Sprite_Channel[5] | Sprite_Channel[4] | Sprite_Channel[3] | Sprite_Channel[2] | Sprite_Channel[1] | Sprite_Channel[0]))
		Bitmap1_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, 3'b010, Sprite_Channel};
	else
		Bitmap1_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
end

// COL

always @ (posedge  EngineClk200Mhz_i) begin
	if (( COL_Pixel_Present ) & ( Tile_Amalgamate | Sprite_Channel[6] | Sprite_Channel[5] | Sprite_Channel[4] | Sprite_Channel[3] | Sprite_Channel[2] | Sprite_Channel[1] | Sprite_Channel[0]))
		ColmapX_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, 3'b100, Sprite_Channel};
	else
		ColmapX_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
end


always @ (posedge EngineClk200Mhz_i)
begin 
	if (Collision_GRP_B_Int_Slide[31:30] == 2'b01) begin
		Collision_BM0_o <= { 2'b00, Bitmap0_Collision_Found };
		Collision_BM1_o <= { 2'b00, Bitmap1_Collision_Found };
		Collision_COL_o <= { 2'b00, ColmapX_Collision_Found };
	end
end

wire BitMap_Collision_Interrupt;

assign BitMap_Collision_Interrupt = (Bitmap0_Collision_Found[7]) | (Bitmap1_Collision_Found[8]) | (ColmapX_Collision_Found[9]); // | (ColmapX_Collision_Found);
//////////////////////////////////////////
// TileMap Collision
//////////////////////////////////////////
reg	[13:0]	TileMap0_Collision_Found;
reg	[13:0]	TileMap1_Collision_Found;
reg	[13:0]	TileMap2_Collision_Found;
reg	[13:0]	TileMap3_Collision_Found;
//Tile Maps inter Layer Collision
always @ (posedge EngineClk200Mhz_i) begin
	if (( TL0_Pixel_Present ) & ( TL3_Pixel_Present | TL2_Pixel_Present | TL1_Pixel_Present ))
		TileMap0_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, TL1_Pixel_Present, 1'b1, 10'b000_0000000};
	else
		TileMap0_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
end

always @ (posedge EngineClk200Mhz_i) begin
	if (( TL1_Pixel_Present ) & ( TL3_Pixel_Present | TL2_Pixel_Present | TL0_Pixel_Present ))
		TileMap1_Collision_Found <= {TL3_Pixel_Present, TL2_Pixel_Present, 1'b1, TL0_Pixel_Present, 10'b000_0000000};
	else
		TileMap1_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
end

always @ (posedge EngineClk200Mhz_i) begin
	if (( TL2_Pixel_Present ) & ( TL3_Pixel_Present | TL1_Pixel_Present | TL0_Pixel_Present ))
		TileMap2_Collision_Found <= {TL3_Pixel_Present, 1'b1, TL1_Pixel_Present, TL0_Pixel_Present, 10'b000_0000000};
	else
		TileMap2_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
end

always @ (posedge EngineClk200Mhz_i) begin
	if (( TL3_Pixel_Present ) & ( TL2_Pixel_Present | TL1_Pixel_Present | TL0_Pixel_Present ))
		TileMap3_Collision_Found <= {1'b1, TL2_Pixel_Present, TL1_Pixel_Present, TL0_Pixel_Present, 10'b000_0000000};
	else
		TileMap3_Collision_Found <= {4'b0000, 3'b000, 7'b0000000};
end


always @ (posedge EngineClk200Mhz_i)
begin 
	if (Collision_GRP_C_Int_Slide[31:30] == 2'b01) begin
		Collision_TL0_o <= {2'b00, TileMap0_Collision_Found};
		Collision_TL1_o <= {2'b00, TileMap1_Collision_Found};
		Collision_TL2_o <= {2'b00, TileMap2_Collision_Found};
		Collision_TL3_o <= {2'b00, TileMap3_Collision_Found};
	end
end

wire TileMap_Collision_Interrupt;
assign TileMap_Collision_Interrupt = (TileMap0_Collision_Found[10]) | (TileMap1_Collision_Found[11]) | (TileMap2_Collision_Found[12]) | (TileMap3_Collision_Found[13]);

reg [31:0]	Collision_GRP_A_Int_Slide;
reg [31:0]	Collision_GRP_B_Int_Slide;
reg [31:0]	Collision_GRP_C_Int_Slide;

reg	[1:0]	Sprite_Collision_Interrupt_Slip;
reg	[1:0]	BitMap_Collision_Interrupt_Slip;
reg	[1:0]	TileMap_Collision_Interrupt_Slip;

reg	[15:0]	Collision_Sprite_L0_Slip0, Collision_Sprite_L0_Slip1;
reg	[15:0]	Collision_Sprite_L1_Slip0, Collision_Sprite_L1_Slip1;
reg	[15:0]	Collision_Sprite_L2_Slip0, Collision_Sprite_L2_Slip1;
reg	[15:0]	Collision_Sprite_L3_Slip0, Collision_Sprite_L3_Slip1;
reg	[15:0]	Collision_Sprite_L4_Slip0, Collision_Sprite_L4_Slip1;
reg	[15:0]	Collision_Sprite_L5_Slip0, Collision_Sprite_L5_Slip1;
reg	[15:0]	Collision_Sprite_L6_Slip0, Collision_Sprite_L6_Slip1;

always @ (posedge EngineClk200Mhz_i)
begin
	if (Sprite_Collision_Interrupt) begin
		Sprite_Collision_Pixel_o 	<= Sprite_Data_Col_i[7:0];				// Report the Pixel that colided 
		Sprite_Collision_Channel_o <= Attributes_Data_Col_i[11:6];	// Report the Sprite Number
	end

	if (Bitmap0_Collision_Found[7]) begin
		Bitmap_L0_Collision_Pixel_o <= BitMap0_Pixel_Col_i[7:0];
	end

	if (Bitmap1_Collision_Found[8]) begin
		Bitmap_L1_Collision_Pixel_o <= BitMap1_Pixel_Col_i[7:0];
	end

	if (ColmapX_Collision_Found[9]) begin
		Bitmap_C0_Collision_Pixel_o <= Collision_Data_Col_i[7:0];
	end

	if ( TileMap0_Collision_Found[10] ) begin
		Tilemap_L0_Collision_Pixel_o <= Line1_Pixel_Col_i[7:0];
	end

	if ( TileMap1_Collision_Found[11] ) begin
		Tilemap_L1_Collision_Pixel_o <= Line2_Pixel_Col_i[7:0];
	end

	if ( TileMap2_Collision_Found[12] ) begin
		Tilemap_L2_Collision_Pixel_o <= Line3_Pixel_Col_i[7:0];
	end

	if ( TileMap3_Collision_Found[13] ) begin
		Tilemap_L3_Collision_Pixel_o <= Line4_Pixel_Col_i[7:0];	
	end
		
end


reg	[2:0]	Mstr_Ctrl_Video_Mode_SYNC;

always @ (posedge EngineClk200Mhz_i)
begin
	Mstr_Ctrl_Video_Mode_SYNC[0] <= Mstr_Ctrl_Doubling_Pixel_100Mhz_i;
	Mstr_Ctrl_Video_Mode_SYNC[1] <= Mstr_Ctrl_Video_Mode_SYNC[0];
	if ( Mstr_Ctrl_Video_Mode_SYNC[1] == Mstr_Ctrl_Video_Mode_SYNC[0] )
		Mstr_Ctrl_Video_Mode_SYNC[2] <= Mstr_Ctrl_Video_Mode_SYNC[1];
end

always @ (posedge EngineClk200Mhz_i)
begin
	if ( VideoRst_200Mhz_i || VideoModeReset_200Mhz_i ) begin
			Collision_Y_Location_o <= 16'h0000;
			Collision_Sprite_X_Location_o <= 16'h0000;	
			Collision_Bitmap_X_Location_o <= 16'h0000;
			Collision_Tiles_X_Location_o  <= 16'h0000;
	end
	else begin
		if ( {Sprite_Collision_Interrupt_Slip[1:0], Sprite_Collision_Interrupt} 	== 3'b001 ) begin
			Collision_Y_Location_o 			<= Mstr_Ctrl_Video_Mode_SYNC[2] ? {1'b0, Collision_VideoLine_Active_i[15:1]} : Collision_VideoLine_Active_i;
			Collision_Sprite_X_Location_o <= {6'b00_0000, X_Position_Collision};		
		end
		
		if ( {BitMap_Collision_Interrupt_Slip[1:0], BitMap_Collision_Interrupt} 	== 3'b001 ) begin
			Collision_Y_Location_o <= Mstr_Ctrl_Video_Mode_SYNC[2] ? {1'b0, Collision_VideoLine_Active_i[15:1]} : Collision_VideoLine_Active_i;
			Collision_Bitmap_X_Location_o <= {6'b00_0000, X_Position_Collision};
		end
		
		if ({TileMap_Collision_Interrupt_Slip[1:0], TileMap_Collision_Interrupt} 	== 3'b001 ) begin
			Collision_Y_Location_o <= Mstr_Ctrl_Video_Mode_SYNC[2] ? {1'b0, Collision_VideoLine_Active_i[15:1]} : Collision_VideoLine_Active_i;
			Collision_Tiles_X_Location_o <= {6'b00_0000, X_Position_Collision};
		end
	end
end

// X Position for the COllision
reg	[9:0] X_Position_Collision;
always @ (posedge EngineClk200Mhz_i)
begin
	if (Read_Pixel_Lines_i)
		X_Position_Collision <= X_Position_Collision + 10'b00_0000_0001;
	else begin
		X_Position_Collision <= 10'b00_0000_0000;
	end
end

always @ (posedge EngineClk200Mhz_i)
begin
	Sprite_Collision_Interrupt_Slip[0] <= Sprite_Collision_Interrupt;
	Sprite_Collision_Interrupt_Slip[1] <= Sprite_Collision_Interrupt_Slip[0];
	
	BitMap_Collision_Interrupt_Slip[0] <= BitMap_Collision_Interrupt;
	BitMap_Collision_Interrupt_Slip[1] <= BitMap_Collision_Interrupt_Slip[0];	

	TileMap_Collision_Interrupt_Slip[0] <= TileMap_Collision_Interrupt;
	TileMap_Collision_Interrupt_Slip[1] <= TileMap_Collision_Interrupt_Slip[0];
	
	if (SpriteLevel0_Collision_Found) begin
		Collision_Sprite_L0_Slip0 <= { 2'b00, SpriteLevel0_Collision_Found };
	end
		Collision_Sprite_L0_Slip1 <= Collision_Sprite_L0_Slip0;

	if (SpriteLevel1_Collision_Found) begin
		Collision_Sprite_L1_Slip0 <= { 2'b00, SpriteLevel1_Collision_Found };
	end
		Collision_Sprite_L1_Slip1 <= Collision_Sprite_L1_Slip0;		

	if (SpriteLevel2_Collision_Found) begin
		Collision_Sprite_L2_Slip0 <= { 2'b00, SpriteLevel2_Collision_Found };
	end
		Collision_Sprite_L2_Slip1 <= Collision_Sprite_L2_Slip0;		

	if (SpriteLevel3_Collision_Found) begin
		Collision_Sprite_L3_Slip0 <= { 2'b00, SpriteLevel3_Collision_Found };
	end
		Collision_Sprite_L3_Slip1 <= Collision_Sprite_L3_Slip0;		

	if (SpriteLevel4_Collision_Found) begin
		Collision_Sprite_L4_Slip0 <= { 2'b00, SpriteLevel4_Collision_Found };
	end	
		Collision_Sprite_L4_Slip1 <= Collision_Sprite_L4_Slip0;		

	if (SpriteLevel5_Collision_Found) begin
		Collision_Sprite_L5_Slip0 <= { 2'b00, SpriteLevel5_Collision_Found };
	end
		
		Collision_Sprite_L5_Slip1 <= Collision_Sprite_L5_Slip0;		

	if (SpriteLevel6_Collision_Found) begin
		Collision_Sprite_L6_Slip0 <= { 2'b00, SpriteLevel6_Collision_Found };
	end
		
		Collision_Sprite_L6_Slip1 <= Collision_Sprite_L6_Slip0;		
end

always @ (posedge EngineClk200Mhz_i)
begin 
	if ( {Sprite_Collision_Interrupt_Slip[0], Sprite_Collision_Interrupt} == 2'b01  ) begin 
	 Collision_GRP_A_Int_Slide <= 32'h7FFF_FFFF;
	end
	else
		Collision_GRP_A_Int_Slide <= Collision_GRP_A_Int_Slide << 1'b1;
end	
	
always @ (posedge EngineClk200Mhz_i)
begin 	
	if ( {BitMap_Collision_Interrupt_Slip[0], BitMap_Collision_Interrupt} == 2'b01 ) begin 
	 Collision_GRP_B_Int_Slide <= 32'h7FFF_FFFF;	
	end
	else
		Collision_GRP_B_Int_Slide <= Collision_GRP_B_Int_Slide << 1'b1;
end
	
always @ (posedge EngineClk200Mhz_i)
begin 	
	if ( {TileMap_Collision_Interrupt_Slip[0], TileMap_Collision_Interrupt} == 2'b01 ) begin 
	 Collision_GRP_C_Int_Slide <= 32'h7FFF_FFFF;	
	end	
	 else
	 	Collision_GRP_C_Int_Slide <= Collision_GRP_C_Int_Slide << 1'b1;	
end






endmodule


