`timescale 1ns/1ns
module PixelStreamLiner(
input		wire				Reset_i,
input		wire				VideoRst_i,
input		wire				VideoModeReset_i,

// Clocks
input		wire				EngineClk200Mhz_i,
input		wire				VideoClk_i,

// Video Signals
input		wire	[11:0]	HLineCount_i,
input		wire	[11:0]	HPixelCount_i,
input		wire				SOF_i,
input		wire				Vsync_i,
input		wire				VBlanking_i,
input		wire				HBlanking_i,
// Video Timming Constants
input		wire	[11:0]	Total_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Total_Line_Per_Image_Value_i,
input		wire	[11:0]	H_Blanking_Value_i,
input		wire	[11:0]	V_Blanking_Value_i,
input		wire	[11:0]	Visible_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Visible_Line_Per_Line_Value_i,

input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,

input		wire	[31:0]	VGE_DATA_2_READ_i,
output	reg				VGE_DATA_2_READ_Read_o,
input		wire				VGE_DATA_2_READ_Empty_i,
input   	wire	[7:0]		VGE_DATA_2_READ_Count_i,

input		wire	[35:0]	VGE_DATA_2_READ_Tag_i,
output	reg				VGE_DATA_2_READ_Tag_Read_o,
input		wire				VGE_DATA_2_READ_Tag_Empty_i,
input   	wire	[7:0]		VGE_DATA_2_READ_Tag_Count_i

);

wire	[7:0]		Line0_Pixel_Out;
wire	[7:0]		Line1_Pixel_Out;
wire	[7:0]		Line2_Pixel_Out;
wire	[7:0]		Line3_Pixel_Out;
wire	[7:0]		Line4_Pixel_Out;
wire	[7:0]		Line5_Pixel_Out;
wire	[7:0]		Line6_Collision_Out;

wire	[7:0]		SpriteLine_Pixel_Out;
wire	[7:0]		SpriteLine_Attributes_Out;

reg 				Line0_Data_Write;
reg 				Line1_Data_Write;
reg 				Line2_Data_Write;
reg 				Line3_Data_Write;
reg 				Line4_Data_Write;
reg 				Line5_Data_Write;

reg				SpriteLine_Pixel_Write;


reg	[7:0]		Pixel_In32_Address;
reg	[9:0]		Pixel_Out8_Address;

// Sprite Info
reg	[15:0]		SpritePixelXAxis[0:63];
reg	[3:0]			SpritePixelPriority[0:63];
reg	[2:0]			SpritePixelLUT[0:63];
reg	[5:0]			SpritePixelReadBackCount[0:63];
reg	[7:0]			SpritePixelRegister[0:63];
reg					SpritePixelEnabled[0:63];

reg	[2:0]			SpritePixelPtr;
reg					WriteSpriteTagData;
reg					WriteSpritePixel;
reg	[5:0]			SpriteLinePixelChannel;

// BM Info
reg	[2:0]			Bitmap0_LUT;
reg	[2:0]			Bitmap1_LUT;

// TileMap Info
reg	[2:0]			TileMap0_LUT;
reg	[2:0]			TileMap1_LUT;
reg	[2:0]			TileMap2_LUT;
reg	[2:0]			TileMap3_LUT;


reg	[7:0]			Pixel32Count;
reg					Pixel32Write;


initial begin
	SpritePixelPtr = 3'b000;
	WriteSpriteTagData = 1'b0;
	WriteSpritePixel = 1'b0;
	Bitmap0_LUT = 3'b000;
	Bitmap1_LUT = 3'b000;
	TileMap0_LUT = 3'b000;
	TileMap1_LUT = 3'b001;
	TileMap2_LUT = 3'b010;
	TileMap3_LUT = 3'b011;
end

localparam 		Mode_Bitmap 	= 3'b000,
					Mode_Tile_Map  = 3'b001,
					Mode_Tile_Data = 3'b010,
					Mode_Sprites   = 3'b011,
					Mode_MemRead	= 3'b100,
					Mode_MemWrite  = 3'b101,
					Mode_DMA_Read	= 3'b110,
					Mode_DMA_Write = 3'b111;

localparam		Mode_Read		= 1'b0,
					Mode_Write		= 1'b1;

localparam		BM_Attr_BM0		= 3'b000,
					BM_Attr_BM1		= 3'b001,
					BM_Attr_Col		= 3'b010,
					SP_No_Attr		= 3'b000,
					TL_MAP0_Attr	= 3'b000,
					TL_MAP1_Attr	= 3'b001,
					TL_MAP2_Attr	= 3'b010,
					TL_MAP3_Attr	= 3'b011,
					TL_DATA0_Attr	= 3'b100,
					TL_DATA1_Attr	= 3'b101,
					TL_DATA2_Attr	= 3'b110,
					TL_DATA3_Attr	= 3'b111;
					
reg [9:0]	BM_Line_Sizes;

always @ (*)
begin
	case (Mstr_Ctrl_Video_Mode_i)
		2'b00: BM_Line_Sizes = 10'd704;
		2'b01: BM_Line_Sizes = 10'd864;
		2'b10: BM_Line_Sizes = 10'd384;
		2'b11: BM_Line_Sizes = 10'd464;
	default: BM_Line_Sizes = 10'd704;
	endcase
end					

reg	[27:0]		StateMachine;

localparam		IDLE 							= 28'b0000_0000_0000_0000_0000_0000_0000,
					WAIT_FOR_DATA				= 28'b0000_0000_0000_0000_0000_0000_0001,
					GET_TAG						= 28'b0000_0000_0000_0000_0000_0000_0010,
					READ_TAG						= 28'b0000_0000_0000_0000_0000_0000_0100,
					
					WAIT_4_DATA_AVAIL			= 28'b0000_0000_0000_0000_0000_0000_1000,
					WAIT_DATA_LATENCY_OUT	= 28'b0000_0000_0000_0000_0000_0001_0000,
					FIFO_DATA_VALID_HERE		= 28'b0000_0000_0000_0000_0000_0010_0000,

					DONE_TRANSFER				= 28'b0000_0000_0000_0000_0000_0100_0000,
					POST_PROCESS1				= 28'b0000_0000_0000_0000_0000_1000_0000,
					
					PROCESS_TAG_BM0 	= 28'b0000_0000_0000_0000_0001_0000_0000,
					PROCESS_TAG_BM1 	= 28'b0000_0000_0000_0000_0010_0000_0000,
					PROCESS_TAG_BM2 	= 28'b0000_0000_0000_0000_0100_0000_0000,
					PROCESS_TAG_BM3 	= 28'b0000_0000_0000_0000_1000_0000_0000,
					
					PROCESS_TAG_TLM0 	= 28'b0000_0000_0000_0001_0000_0000_0000,
					PROCESS_TAG_TLM1 	= 28'b0000_0000_0000_0010_0000_0000_0000,
					PROCESS_TAG_TLM2 	= 28'b0000_0000_0000_0100_0000_0000_0000,
					PROCESS_TAG_TLM3 	= 28'b0000_0000_0000_1000_0000_0000_0000,
					PROCESS_TAG_TLD0 	= 28'b0000_0000_0001_0000_0000_0000_0000,
					PROCESS_TAG_TLD1 	= 28'b0000_0000_0010_0000_0000_0000_0000,
					PROCESS_TAG_TLD2 	= 28'b0000_0000_0100_0000_0000_0000_0000,
					PROCESS_TAG_TLD3 	= 28'b0000_0000_1000_0000_0000_0000_0000,

					PROCESS_TAG_SP0 	= 28'b0000_0001_0000_0000_0000_0000_0000,
					PROCESS_TAG_SP1 	= 28'b0000_0010_0000_0000_0000_0000_0000,
					PROCESS_TAG_SP2 	= 28'b0000_0100_0000_0000_0000_0000_0000,
					PROCESS_TAG_SP3 	= 28'b0000_1000_0000_0000_0000_0000_0000,
					PROCESS_TAG_SP4 	= 28'b0001_0000_0000_0000_0000_0000_0000,
					PROCESS_TAG_SP5 	= 28'b0010_0000_0000_0000_0000_0000_0000,
					PROCESS_TAG_SP6 	= 28'b0100_0000_0000_0000_0000_0000_0000,
					PROCESS_TAG_SP7 	= 28'b1000_0000_0000_0000_0000_0000_0000;

					
// NOTE:
// The State Machine works @ 200Mhz and the Memory interface is Working @ 100Mhz, so the 
					
always @ (posedge EngineClk200Mhz_i) begin
	if (VideoRst_i || VideoModeReset_i) begin
		StateMachine 					<= IDLE;
		VGE_DATA_2_READ_Tag_Read_o <= 1'b0;
		VGE_DATA_2_READ_Read_o     <= 1'b0;
		Pixel32Count 					<= 8'h00;	// Number of Pixel in Pack of 4 (32Bits) that needs to be transfered
		Pixel32Write					<= 1'b0;
	end
	else begin
	
		case (StateMachine)
			IDLE: begin 
				if (VGE_DATA_2_READ_Tag_Empty_i == 1'b1) begin	// Wait for a Tag
					StateMachine <= IDLE;
				end 
				else begin
					StateMachine <= WAIT_FOR_DATA;
					VGE_DATA_2_READ_Tag_Read_o <= 1'b1;	// There is a Tag in the FIFO
				end
			end
		
		WAIT_FOR_DATA: begin 
			VGE_DATA_2_READ_Tag_Read_o <= 1'b0;
			StateMachine <= READ_TAG;			
		end
		
		// Latency to get Data Out;
		GET_TAG: begin
				StateMachine <= READ_TAG;
		end
		
		// The Tag Data is ready to be Read Her
		// The Data Read is Enabled here, but we need to wait for 1 Latency before we can write
		READ_TAG: begin 
			case (VGE_DATA_2_READ_Tag_i[35:33])
				Mode_Bitmap: 		begin Pixel32Count <= BM_Line_Sizes[9:2]; end	// Bitmap
				Mode_Tile_Map: 	begin Pixel32Count <= BM_Line_Sizes[9:6]; end 	// TileMap Get Map
				Mode_Tile_Data: 	begin Pixel32Count <= 10'h0004; end 				// TileData (16Bytes)
				Mode_Sprites: 		begin Pixel32Count <= 10'h0008; end 				// Sprite (32Bytes)
				default:				begin Pixel32Count <= 10'h0000; end
			endcase
				StateMachine <=  WAIT_4_DATA_AVAIL;
		end
		
		// Okay, when the Empty Flag goes low, then we need to take 
		WAIT_4_DATA_AVAIL: begin
			if (VGE_DATA_2_READ_Tag_Empty_i == 1'b1 ) begin	// Now Wait for the Data that comes along with it		
				StateMachine <= WAIT_4_DATA_AVAIL;
			end
			else begin
				VGE_DATA_2_READ_Read_o <= 1'b1;					// Open the Gate to Read, but we need to wait 1 Clock for Latency
				StateMachine <= WAIT_DATA_LATENCY_OUT;
			end			
		
		end
		
		// 1 Clock Latency
		WAIT_DATA_LATENCY_OUT: begin
			Pixel32Write <= 1'b1;			// Next Clock, the Data will be available;
				StateMachine <= FIFO_DATA_VALID_HERE;
		end
		
		FIFO_DATA_VALID_HERE: begin
			Pixel32Write <= 1'b0;			// We read twice as fast as the data is written, so we have to take a breather.
			if (Pixel32Count) begin
				Pixel32Count <= Pixel32Count - 8'h01;
				StateMachine <=  WAIT_DATA_LATENCY_OUT;
				if (Pixel32Count == 8'h01)
					VGE_DATA_2_READ_Read_o <= 1'b0;
			end
			else begin
				StateMachine <= IDLE;	
			end			
		end
		
		// By Now, if it is a
		DONE_TRANSFER: begin
				StateMachine <= DONE_TRANSFER;	
		end

/*		
		POST_PROCESS0: begin 
				StateMachine <= POST_PROCESS1;		
		end

		POST_PROCESS1: begin 
				StateMachine <= POST_PROCESS2;		
		end
		
		POST_PROCESS2: begin 
				StateMachine <= PREP_FIFO3;		
		end
		
		// Process 
		PROCESS_TAG_BM0: begin end
		
		PROCESS_TAG_BM1: begin end
		
		PROCESS_TAG_BM2: begin end
		
		PROCESS_TAG_BM3: begin end
		
		
		// Process Tile MAP Here
		PROCESS_TAG_TLM0: begin end
		
		PROCESS_TAG_TLM1: begin end
		
		PROCESS_TAG_TLM2: begin end
		
		PROCESS_TAG_TLM3: begin end
		
		// Process Tile Data Here
		PROCESS_TAG_TLD0: begin end
		
		PROCESS_TAG_TLD1: begin end
		
		PROCESS_TAG_TLD2: begin end
		
		PROCESS_TAG_TLD3: begin end
		
		// Process Sprites Data Here:
		PROCESS_TAG_SP0: begin end
		
		PROCESS_TAG_SP1: begin end
		
		PROCESS_TAG_SP2: begin end
		
		PROCESS_TAG_SP3: begin end
		
		PROCESS_TAG_SP4: begin end
		
		PROCESS_TAG_SP5: begin end
		
		PROCESS_TAG_SP6: begin end
		
		PROCESS_TAG_SP7: begin 
		
		end
*/		
		default: begin
			StateMachine <= IDLE;
		end
		endcase
	end
end


// Write Strobe Depending on the Mode
wire BitMapModeWrite;
wire TileMapModeWrite;
wire TileDataModeWrite;
wire SpriteModeWrite;
// Attributes
wire	BitMapLayer0;
wire	BitMapLayer1;
wire	BitMapCollision;
wire	TileMap0;
wire	TileMap1;
wire  TileMap2;
wire	TileMap3;
wire	TileData0;
wire	TileData1;
wire  TileData2;
wire	TileData3;

assign BitMapModeWrite 		= (VGE_DATA_2_READ_Tag_i[35:33] == Mode_Bitmap);
assign TileMapModeWrite		= (VGE_DATA_2_READ_Tag_i[35:33] == Mode_Tile_Map);
assign TileDataModeWrite	= (VGE_DATA_2_READ_Tag_i[35:33] == Mode_Tile_Data);
assign SpriteModeWrite		= (VGE_DATA_2_READ_Tag_i[35:33] == Mode_Sprites);
// Attributes Bitmap
assign BitMapLayer0 			=	(VGE_DATA_2_READ_Tag_i[32:30] == BM_Attr_BM0);
assign BitMapLayer1 			= 	(VGE_DATA_2_READ_Tag_i[32:30] == BM_Attr_BM1);
assign BitMapCollision 		= 	(VGE_DATA_2_READ_Tag_i[32:30] == BM_Attr_Col);

assign TileMap0 				=	(VGE_DATA_2_READ_Tag_i[32:30] == TL_MAP0_Attr);
assign TileMap1 				= 	(VGE_DATA_2_READ_Tag_i[32:30] == TL_MAP1_Attr);
assign TileMap2 				=	(VGE_DATA_2_READ_Tag_i[32:30] == TL_MAP2_Attr);
assign TileMap3 				= 	(VGE_DATA_2_READ_Tag_i[32:30] == TL_MAP3_Attr);
assign TileData0 				=	(VGE_DATA_2_READ_Tag_i[32:30] == TL_DATA0_Attr);
assign TileData1 				= 	(VGE_DATA_2_READ_Tag_i[32:30] == TL_DATA1_Attr);
assign TileData2 				=	(VGE_DATA_2_READ_Tag_i[32:30] == TL_DATA2_Attr);
assign TileData3 				= 	(VGE_DATA_2_READ_Tag_i[32:30] == TL_DATA3_Attr);

always @ (posedge EngineClk200Mhz_i) begin
	
	if (WriteSpriteTagData) begin
		SpritePixelRegister[SpriteLinePixelChannel]  	<= VGE_DATA_2_READ_Tag_i[7:0];		// This is the SpriteIDNumber (Registers Number)
		SpritePixelXAxis[SpriteLinePixelChannel] 			<= VGE_DATA_2_READ_Tag_i[29:14];		// Save the Position in X
		SpritePixelPriority[SpriteLinePixelChannel] 		<= VGE_DATA_2_READ_Tag_i[10:8];		// Save the Level
		SpritePixelLUT[SpriteLinePixelChannel] 			<= VGE_DATA_2_READ_Tag_i[13:11];		// Save the LUT for it
	end
end

always @ (posedge EngineClk200Mhz_i) begin
	if (VideoRst_i || VideoModeReset_i) begin
		Pixel_In32_Address <= 8'h00;
	end
	else begin
		if (Pixel32Write) begin
				Pixel_In32_Address <= Pixel_In32_Address + 8'h01;
			end
		else begin
			Pixel_In32_Address <= 8'h00;
		end
	end
end


/*
VICKYII_Pixel32_8Line (	
	.clock ( EngineClk200Mhz_i ), 
	.data ( VGE_DATA_2_READ_i ), 
	.wraddress ( {SpriteLinePixelChannel, SpritePixelPtr}  ),	// Store the Sprite Line Info Here
	.wren ( Line0_Data_Write ),
	
	// Read Side
	.rdaddress ( Pixel_Out8_Address ), 
	.q ( Sprite_MemBuffer_PixelOut )
	
);
*/
reg			SpriteLine0_Pixel_Write;
reg	[9:0]	Pixel_In8_Address;
reg 	[7:0]	Sprite_Pixel_2_Write;
wire 	[7:0]	Sprite_Attributes_2_Writes;

initial begin
SpriteLine0_Pixel_Write = 1'b0;

end

assign Sprite_Attributes_2_Writes[2:0] = SpritePixelPriority[SpriteLinePixelChannel];
assign Sprite_Attributes_2_Writes[3] = 1'b0;
assign Sprite_Attributes_2_Writes[6:4] = SpritePixelLUT[SpriteLinePixelChannel];
assign Sprite_Attributes_2_Writes[7] = 1'b0;

// Sprite Layer 
VICKYII_Pixel8_8Line	VICKYII_Pixel8_8Sprite_Line0 ( .clock ( EngineClk200Mhz_i ), .data ( Sprite_Pixel_2_Write ), .wraddress ( Pixel_In8_Address ), .wren ( SpriteLine0_Pixel_Write ),	.rdaddress ( Pixel_Out8_Address ),	.q ( SpriteLine_Pixel_Out ));
// Sprite Priority (0..15)
VICKYII_Pixel8_8Line	VICKYII_Pixel8_8Sprite_Line1 ( .clock ( EngineClk200Mhz_i ), .data ( Sprite_Attributes_2_Writes ), .wraddress ( Pixel_In8_Address ), .wren ( SpriteLine0_Pixel_Write ),	.rdaddress ( Pixel_Out8_Address ),	.q ( SpriteLine_Attributes_Out ));

// High Priority BitMap Layer 1
VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_inst0 (	.clock ( EngineClk200Mhz_i ), .data ( VGE_DATA_2_READ_i ), .wraddress ( Pixel_In32_Address ),	.wren ( Pixel32Write & BitMapModeWrite & BitMapLayer1 ), .rdaddress ( Pixel_Out8_Address ), .q ( Line0_Pixel_Out ));
// Low  Priority BitMap Layer 11
VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_inst5 (	.clock ( EngineClk200Mhz_i ), .data ( VGE_DATA_2_READ_i ), .wraddress ( Pixel_In32_Address ),	.wren ( Pixel32Write & BitMapModeWrite & BitMapLayer0 ), .rdaddress ( Pixel_Out8_Address ), .q ( Line5_Pixel_Out ));

// Tile Layer 3
VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_inst1 (	.clock ( EngineClk200Mhz_i ), .data ( VGE_DATA_2_READ_i ), .wraddress ( Pixel_In32_Address ),	.wren ( Pixel32Write & TileDataModeWrite & TileData3), .rdaddress ( Pixel_Out8_Address ), .q ( Line1_Pixel_Out ));
// Tile Layer 5
VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_inst2 (	.clock ( EngineClk200Mhz_i ), .data ( VGE_DATA_2_READ_i ), .wraddress ( Pixel_In32_Address ),	.wren ( Pixel32Write & TileDataModeWrite & TileData2), .rdaddress ( Pixel_Out8_Address ), .q ( Line2_Pixel_Out ));
// Tile Layer 7
VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_inst3 (	.clock ( EngineClk200Mhz_i ), .data ( VGE_DATA_2_READ_i ), .wraddress ( Pixel_In32_Address ),	.wren ( Pixel32Write & TileDataModeWrite & TileData1), .rdaddress ( Pixel_Out8_Address ), .q ( Line3_Pixel_Out ));
// Tile Layer 9
VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_inst4 (	.clock ( EngineClk200Mhz_i ), .data ( VGE_DATA_2_READ_i ), .wraddress ( Pixel_In32_Address ),	.wren ( Pixel32Write & TileDataModeWrite & TileData0), .rdaddress ( Pixel_Out8_Address ), .q ( Line4_Pixel_Out ));

// Collision MAP
VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_inst6 (	.clock ( EngineClk200Mhz_i ), .data ( VGE_DATA_2_READ_i ), .wraddress ( Pixel_In32_Address ),	.wren ( Pixel32Write & BitMapModeWrite & BitMapCollision ), .rdaddress ( Pixel_Out8_Address ), .q ( Line6_Collision_Out ));


// Code to Sort out what pixel will be displayed.

wire	[12:0] 	PixelPresent;
reg	[11:0]	DisplayedPixelOut;

assign PixelPresent[12]	= (SpriteLine_Attributes_Out[6:4] == 3'b000) && (SpriteLine_Pixel_Out) ? 1'b1 : 1'b0;	// Sprite L0
assign PixelPresent[11] = Line0_Pixel_Out[7:0] ? 1'b1 : 1'b0;								// BM0
assign PixelPresent[10] = (SpriteLine_Attributes_Out[6:4] == 3'b001) && (SpriteLine_Pixel_Out) ? 1'b1 : 1'b0;	// Sprite L1
assign PixelPresent[9] 	= Line1_Pixel_Out[7:0] ? 1'b1 : 1'b0;								// TL0
assign PixelPresent[8] 	= (SpriteLine_Attributes_Out[6:4] == 3'b010) && (SpriteLine_Pixel_Out) ? 1'b1 : 1'b0;	// Sprite L2
assign PixelPresent[7] 	= Line2_Pixel_Out[7:0] ? 1'b1 : 1'b0;								// TL1
assign PixelPresent[6] 	= (SpriteLine_Attributes_Out[6:4] == 3'b011) && (SpriteLine_Pixel_Out) ? 1'b1 : 1'b0;	// Sprite L3
assign PixelPresent[5] 	= Line3_Pixel_Out[7:0] ? 1'b1 : 1'b0;								// TL2
assign PixelPresent[4] 	= (SpriteLine_Attributes_Out[6:4] == 3'b100) && (SpriteLine_Pixel_Out) ? 1'b1 : 1'b0;	// Sprite L4
assign PixelPresent[3] 	= Line4_Pixel_Out[7:0] ? 1'b1 : 1'b0;								// TL3
assign PixelPresent[2] 	= (SpriteLine_Attributes_Out[6:4] == 3'b101) && (SpriteLine_Pixel_Out) ? 1'b1 : 1'b0;	// Sprite L5
assign PixelPresent[1] 	= Line5_Pixel_Out[7:0] ? 1'b1 : 1'b0;								// BM1
assign PixelPresent[0] 	= (SpriteLine_Attributes_Out[6:4] == 3'b110) && (SpriteLine_Pixel_Out) ? 1'b1 : 1'b0;	// Sprite L6

// This makes an association between the Priority and LUT
always @ *
begin
	casex (PixelPresent)
		13'b1_xxxx_xxxx_xxxx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out[6:4], SpriteLine_Pixel_Out[7:0]};	
		13'b0_1xxx_xxxx_xxxx: DisplayedPixelOut = {1'b0, Bitmap0_LUT, Line0_Pixel_Out[7:0]};	
		13'b0_01xx_xxxx_xxxx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out[6:4], SpriteLine_Pixel_Out[7:0]};	
		13'b0_001x_xxxx_xxxx: DisplayedPixelOut = {1'b0, TileMap0_LUT, Line1_Pixel_Out[7:0]};
		13'b0_0001_xxxx_xxxx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out[6:4], SpriteLine_Pixel_Out[7:0]};
		13'b0_0000_1xxx_xxxx: DisplayedPixelOut = {1'b0, TileMap1_LUT, Line2_Pixel_Out[7:0]};
		13'b0_0000_01xx_xxxx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out[6:4], SpriteLine_Pixel_Out[7:0]};
		13'b0_0000_001x_xxxx: DisplayedPixelOut = {1'b0, TileMap2_LUT, Line3_Pixel_Out[7:0]};
		13'b0_0000_0001_xxxx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out[6:4], SpriteLine_Pixel_Out[7:0]};
		13'b0_0000_0000_1xxx: DisplayedPixelOut = {1'b0, TileMap3_LUT, Line4_Pixel_Out[7:0]};
		13'b0_0000_0000_01xx: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out[6:4], SpriteLine_Pixel_Out[7:0]};
		13'b0_0000_0000_001x: DisplayedPixelOut = {1'b0, Bitmap1_LUT, Line5_Pixel_Out[7:0]};
		13'b0_0000_0000_0001: DisplayedPixelOut = {1'b0, SpriteLine_Attributes_Out[6:4], SpriteLine_Pixel_Out[7:0]};
		13'b0_0000_0000_0000: DisplayedPixelOut = {1'b1, 3'b000, 8'b0000_0000};
		default: begin end
	endcase

end
/*
wire [127:0] ChipScope;
wire			Trigger;
assign Trigger = Pixel32Write;

assign ChipScope[31:0] = VGE_DATA_2_READ_i[31:0];
assign ChipScope[39:32] = Pixel_In32_Address;
assign ChipScope[40] = Pixel32Write;
assign ChipScope[41] = Pixel32Write & BitMapModeWrite & BitMapLayer1;
assign ChipScope[42] = Pixel32Write & BitMapModeWrite & BitMapLayer0;
assign ChipScope[59:43] = 0;

assign ChipScope[95:60] = VGE_DATA_2_READ_Tag_i;
assign ChipScope[127:96] = {4'b0000, StateMachine};


//assign ChipScope[23:0] = BUS_A;
//assign ChipScope[31:24] = DataIn;
//assign ChipScope[39:32] = DataOut;
//assign ChipScope[40] = BUS_RWn;
//assign ChipScope[41] = BUS_RDY;
//assign ChipScope[42] = BUS_VDA;
//assign ChipScope[43] = BUS_VPA;
//assign ChipScope[63:44] = 0;

//assign ChipScope[31:0]  = VidMemData_i;
//assign ChipScope[63:32] = VidMemData_o;
//assign ChipScope[83:64] = {1'b0,VMEM_A};
//assign ChipScope[87:84] = VMEM_WEn;
//assign ChipScope[88] = VMEM_OEn;

//assign ChipScope[127:112] = VRAM_Debug;

ChipScope	ChipScope_inst (
	.acq_clk ( Clk200Mhz ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);
*/


endmodule


