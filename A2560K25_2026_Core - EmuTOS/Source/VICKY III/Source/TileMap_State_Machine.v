
module TileMap_State_Machine(

input		wire				VGE_Engine_Rst_i,
input		wire				Reset_100Mhz_i,
input		wire				EngineClk100Mhz_i,

input		wire				Clear_Bit_Line_i,

input		wire	[1:0]		Mstr_Ctrl_Video_Mode100Mhz_i,
input 	wire				Mstr_Ctrl_Doubling_Pixel_100Mhz_i,

input		wire				TileMap_Effect_On_i,
//input		wire	[1:0]		Time_2_Charge_TileMap_Lines_i,		// THis is the Strobe that tells the State Machine to go fetch the line Info

input		wire	[1:0]		Time_2_Charge_TileMap_L0_Lines_i,
input		wire	[1:0]		Time_2_Charge_TileMap_L1_Lines_i,
input		wire	[1:0]		Time_2_Charge_TileMap_L2_Lines_i,
input		wire	[1:0]		Time_2_Charge_TileMap_L3_Lines_i,


input		wire	[11:0]	Horizontal_Line_Count_i,
input		wire				Trig_TL_Read_Memory_i,
input		wire	[1:0]		SOF_i,

// TileMap Registers Information
// TileMaps
// Layer0
input		wire	[22:0]	TileMap0Addy_i,
input		wire	[9:0]		TileMap0_X_TotalSize_i,		// Size of the Square of the whole Map Max 1024 Position (54)
input		wire	[9:0]		TileMap0_Y_TotalSize_i,		// Size of the Square of the whole Map Max 1024 Position
input		wire	[9:0]		TileMap0_X_Window_Pos_i,	// X Offset in the Map
input		wire	[9:0]		TileMap0_Y_Window_Pos_i,	// Y Offset in the

// Layer1
input		wire	[22:0]	TileMap1Addy_i,
input		wire	[9:0]		TileMap1_X_TotalSize_i,	// Size of the Square of the whole Map Max 1024 Position (54)
input		wire	[9:0]		TileMap1_Y_TotalSize_i,	// Size of the Square of the whole Map Max 1024 Position
input		wire	[9:0]		TileMap1_X_Window_Pos_i,	// X Offset in the Map
input		wire	[9:0]		TileMap1_Y_Window_Pos_i,	// Y Offset in the

// Layer2
input		wire	[22:0]	TileMap2Addy_i,
input		wire	[9:0]		TileMap2_X_TotalSize_i,	// Size of the Square of the whole Map Max 1024 Position (54)
input		wire	[9:0]		TileMap2_Y_TotalSize_i,	// Size of the Square of the whole Map Max 1024 Position
input		wire	[9:0]		TileMap2_X_Window_Pos_i,	// X Offset in the Map
input		wire	[9:0]		TileMap2_Y_Window_Pos_i,	// Y Offset in the

// Layer2
input		wire	[22:0]	TileMap3Addy_i,
input		wire	[9:0]		TileMap3_X_TotalSize_i,	// Size of the Square of the whole Map Max 1024 Position (54)
input		wire	[9:0]		TileMap3_Y_TotalSize_i,	// Size of the Square of the whole Map Max 1024 Position
input		wire	[9:0]		TileMap3_X_Window_Pos_i,	// X Offset in the Map
input		wire	[9:0]		TileMap3_Y_Window_Pos_i,	// Y Offset in the

// TileSets
input		wire	[7:0]		Tile0_Layer_Control_Reg_i,
input		wire	[7:0]		Tile1_Layer_Control_Reg_i,
input		wire	[7:0]		Tile2_Layer_Control_Reg_i,
input		wire	[7:0]		Tile3_Layer_Control_Reg_i,

input		wire	[4:0]		Tile0_X_Scroll_Reg_i,	// Tile Layer 0 -- [4] = 0 - Right	, 1 - Left, [3:0] Position 0 to 15
input		wire	[4:0]		Tile0_Y_Scroll_Reg_i,	// Tile Layer 0 -- [4] = 0 - Up		, 1 - Down, [3:0] Position 0 to 15
input		wire	[4:0]		Tile1_X_Scroll_Reg_i,	// Tile Layer 1 -- [4] = 0 - Right	, 1 - Left, [3:0] Position 0 to 15
input		wire	[4:0]		Tile1_Y_Scroll_Reg_i,	// Tile Layer 1 -- [4] = 0 - Up		, 1 - Down, [3:0] Position 0 to 15
input		wire	[4:0]		Tile2_X_Scroll_Reg_i,	// Tile Layer 2 -- [4] = 0 - Right	, 1 - Left, [3:0] Position 0 to 15
input		wire	[4:0]		Tile2_Y_Scroll_Reg_i,	// Tile Layer 2 -- [4] = 0 - Up		, 1 - Down, [3:0] Position 0 to 15
input		wire	[4:0]		Tile3_X_Scroll_Reg_i,	// Tile Layer 3 -- [4] = 0 - Right	, 1 - Left, [3:0] Position 0 to 15
input		wire	[4:0]		Tile3_Y_Scroll_Reg_i,	// Tile Layer 3 -- [4] = 0 - Up		, 1 - Down, [3:0] Position 0 to 15

input		wire 	[22:0]	TileSet0Addy_i,
input		wire 	[22:0]	TileSet1Addy_i,
input		wire 	[22:0]	TileSet2Addy_i,
input		wire 	[22:0]	TileSet3Addy_i,
input		wire 	[22:0]	TileSet4Addy_i,
input		wire 	[22:0]	TileSet5Addy_i,
input		wire 	[22:0]	TileSet6Addy_i,
input		wire 	[22:0]	TileSet7Addy_i,

input		wire	[3:0]		TileSet0Cfg_i,
input		wire	[3:0]		TileSet1Cfg_i,
input		wire	[3:0]		TileSet2Cfg_i,
input		wire	[3:0]		TileSet3Cfg_i,
input		wire	[3:0]		TileSet4Cfg_i,
input		wire	[3:0]		TileSet5Cfg_i,
input		wire	[3:0]		TileSet6Cfg_i,
input		wire	[3:0]		TileSet7Cfg_i,

// From VMemory Interface Block
// Inputs
input		wire				VRAM_Data_Valid_i,
input		wire	[31:0]	VRAM_Data_2_TILEMAP_i,
input		wire				Counter_Reached_Count_i,
// Outputs
output	wire				Counter_Enable_TM_o,
output	wire				Counter_Load_TM_o,
output	wire	[19:0]	TileMap_Target_Addy_Start_o,
output	wire	[19:0]	TileMap_Target_Addy_Stop_o,

// Priority Pixel (Collisions) Encoder
output	wire	[7:0] 	VGE_EffectChannel_TL_ADDY_o,
output	wire				VGE_Engine_TL0_WE_o,
output	wire				VGE_Engine_TL1_WE_o,
output	wire				VGE_Engine_TL2_WE_o,
output	wire				VGE_Engine_TL3_WE_o,
output	wire	[31:0]	Tile_Data_o,
output	wire	[7:0]		Tile_Attribute_o,

output 	wire 				TileL0Collision_On_o,
output 	wire 				TileL1Collision_On_o,
output 	wire 				TileL2Collision_On_o,
output 	wire 				TileL3Collision_On_o,

output	wire	[3:0]		VGE_TileMap_SM_o,
output	wire				VGE_Tile_Engine_SM_o
);

reg				MAP_DATA;

wire 	[19:0]	TileMap_Addy_Start;
wire	[19:0]	TileMap_Addy_Stop;
wire 			TileMap_Load_Addy;
reg			TileMap_Enable_Tfr;

wire	[19:0]	TileData_Addy_Start;
wire	[19:0]	TileData_Addy_Stop;
wire 			TileData_Load_Addy;
reg			TileData_Enable_Tfr;


assign TileMap_Load_Addy 	= ( VGE_TileMap_SM == TLMAP_WAIT ) | ( VGE_TileMap_SM == TLMAP_WAIT2 )? 1'b1 : 1'b0;

assign TileData_Load_Addy 	= ( VGE_Tile_Engine_SM == TL_STATE_LOAD_ADDY ) ? 1'b1 : 1'b0;

assign TileMap_Target_Addy_Start_o	= MAP_DATA ? TileMap_Addy_Start	: TileData_Addy_Start;
assign TileMap_Target_Addy_Stop_o	= MAP_DATA ? TileMap_Addy_Stop 	: TileData_Addy_Stop;
assign Counter_Load_TM_o 				= MAP_DATA ? TileMap_Load_Addy	: TileData_Load_Addy;
assign Counter_Enable_TM_o 			= MAP_DATA ? TileMap_Enable_Tfr	: TileData_Enable_Tfr;
////////////////////////////////////////////////////////
///////////
/////////// TILE MAP CAPTURE
///////////
////////////////////////////////////////////////////////
wire	[7:0]		TileMap_Addy;

reg	[1:0]		TileMap_Actual_Layer;
reg	[5:0]		TileMap_Y_Actual_Position[0:3];		// 63 X
reg	[21:0]	TileMap_Actual_Effective_Addy[0:3];

reg	[22:0]	Addy_2_Compute;

reg	[9:0]		TileMap_X_Size_Compute;
reg	[9:0]		TileMap_X_Window_Pos;
reg	[9:0]		TileMap_Y_Window_Pos;
reg				TileMapEnabled_Channel;
reg 				TileLineChoiceY;
reg 				TileLineChoiceX;
reg				TileSize8_16;

assign 			TileL0Collision_On_o = Tile0_Layer_Control_Reg_i[6];
assign 			TileL1Collision_On_o = Tile1_Layer_Control_Reg_i[6];
assign 			TileL2Collision_On_o = Tile2_Layer_Control_Reg_i[6];
assign 			TileL3Collision_On_o = Tile3_Layer_Control_Reg_i[6];

initial begin
	TileMap_Actual_Layer = 2'b00;
end


always @ (*) begin
			case(TileMap_Actual_Layer)
			2'b00: begin
				Addy_2_Compute 			= TileMap0Addy_i;
				TileMap_X_Size_Compute 	= TileMap0_X_TotalSize_i;
				TileMap_X_Window_Pos 	= TileMap0_X_Window_Pos_i;
				TileMap_Y_Window_Pos 	= TileMap0_Y_Window_Pos_i;
				TileMapEnabled_Channel 	= Tile0_Layer_Control_Reg_i[0];
				TileSize8_16				= Tile0_Layer_Control_Reg_i[4];
				TileLineChoiceY 			= Tile0_Y_Scroll_Reg_i[4];
			end
			2'b01: begin
				Addy_2_Compute 			= TileMap1Addy_i;
				TileMap_X_Size_Compute 	= TileMap1_X_TotalSize_i;
				TileMap_X_Window_Pos 	= TileMap1_X_Window_Pos_i;
				TileMap_Y_Window_Pos 	= TileMap1_Y_Window_Pos_i;
				TileMapEnabled_Channel 	= Tile1_Layer_Control_Reg_i[0];
				TileSize8_16				= Tile1_Layer_Control_Reg_i[4];				
				TileLineChoiceY 			= Tile1_Y_Scroll_Reg_i[4];
			end
			2'b10: begin
				Addy_2_Compute 			= TileMap2Addy_i;
				TileMap_X_Size_Compute 	= TileMap2_X_TotalSize_i;
				TileMap_X_Window_Pos 	= TileMap2_X_Window_Pos_i;
				TileMap_Y_Window_Pos 	= TileMap2_Y_Window_Pos_i;
				TileMapEnabled_Channel 	= Tile2_Layer_Control_Reg_i[0];
				TileSize8_16				= Tile2_Layer_Control_Reg_i[4];				
				TileLineChoiceY 			= Tile2_Y_Scroll_Reg_i[4];	
			end
			2'b11: begin
				Addy_2_Compute 			= TileMap3Addy_i;
				TileMap_X_Size_Compute 	= TileMap3_X_TotalSize_i;
				TileMap_X_Window_Pos 	= TileMap3_X_Window_Pos_i;
				TileMap_Y_Window_Pos 	= TileMap3_Y_Window_Pos_i;
				TileMapEnabled_Channel 	= Tile3_Layer_Control_Reg_i[0];
				TileSize8_16				= Tile3_Layer_Control_Reg_i[4];
				TileLineChoiceY 			= Tile3_Y_Scroll_Reg_i[4];
			end
		endcase
end

//assign	Addy_2_Compute 			= TileMap0Addy_i;
//assign	TileMap_X_Size_Compute 	= TileMap0_X_TotalSize_i;
//assign	TileMap_X_Window_Pos 	= TileMap0_X_Window_Pos_i;
//assign	TileMap_Y_Window_Pos 	= TileMap0_Y_Window_Pos_i;
//assign	TileMapEnabled_Channel 	= Tile0_Layer_Control_Reg_i[0];
//assign	TileLineChoice 			= Tile0_Y_Scroll_Reg_i[4];



reg 	[7:0]	MaxValueTileMap2BeRead;

// this is the number of Words to Read from the VRAM
always @ (*) begin
	case({TileSize8_16, Mstr_Ctrl_Doubling_Pixel_100Mhz_i, Mstr_Ctrl_Video_Mode100Mhz_i[1:0]})
		4'b0000: MaxValueTileMap2BeRead = 8'd22;	// (42) 16 + 640 + 16 ( 1 + 40 + 1) Y: 480 + 32 = 32 Tiles (Tiles / 2) + 2
		4'b0001: MaxValueTileMap2BeRead = 8'd22; 	// (52) 16 + 640 + 16 ( 1 + 40 + 1) Y: 600 + 32 = 40 tiles
		4'b0010: MaxValueTileMap2BeRead = 8'd27;	// (66) 16 + 800 + 16 ( 1 + 50 + 1) Y: 768 + 32 = 15 Tiles
		4'b0011: MaxValueTileMap2BeRead = 8'd27; 	// (42) 16 + 800 + 16 ( 1 + 50 + 1) Y: 400 + 32 = 21 Tiles
		4'b0100: MaxValueTileMap2BeRead = 8'd12;	// (22) 16 + 320 + 16 ( 1 + 20 + 1) Y: 240 + 32 = 15 Tiles
		4'b0101: MaxValueTileMap2BeRead = 8'd12; 	// (27) 16 + 400 + 16 ( 1 + 20 + 1) Y: 300 + 32 = 21 Tiles
		4'b0110: MaxValueTileMap2BeRead = 8'd15;	// (22) 16 + 512 + 16 ( 1 + 25 + 1) Y: 384 + 32 = 15 Tiles
		4'b0111: MaxValueTileMap2BeRead = 8'd15; 	// (22) 16 + 320 + 16 ( 1 + 25 + 1) Y: 200 + 32 = 15 Tiles
		
		4'b1000: MaxValueTileMap2BeRead = 8'd42;	// (82) 8 + 640 + 8 ( 1 + 80 + 1) Y: 480 + 16 = 32 Tiles (Tiles / 2) + 2
		4'b1001: MaxValueTileMap2BeRead = 8'd42; 	// (52) 8 + 640 + 8 ( 1 + 80 + 1) Y: 600 + 16 = 40 tiles
		4'b1010: MaxValueTileMap2BeRead = 8'd52;	// (66) 8 + 800 + 8 ( 1 + 100 + 1) Y: 768 + 16 = 15 Tiles
		4'b1011: MaxValueTileMap2BeRead = 8'd52; 	// (42) 8 + 800 + 8 ( 1 + 100 + 1) Y: 400 + 16 = 21 Tiles
		4'b1100: MaxValueTileMap2BeRead = 8'd22;	// (22) 8 + 320 + 8 ( 1 + 40 + 1) Y: 240 + 16 = 15 Tiles
		4'b1101: MaxValueTileMap2BeRead = 8'd22; 	// (27) 8 + 400 + 8 ( 1 + 40 + 1) Y: 300 + 16 = 21 Tiles
		4'b1110: MaxValueTileMap2BeRead = 8'd27;	// (22) 8 + 512 + 8 ( 1 + 50 + 1) Y: 384 + 16 = 15 Tiles
		4'b1111: MaxValueTileMap2BeRead = 8'd27; 	// (22) 8 + 320 + 8 ( 1 + 50 + 1) Y: 200 + 16 = 15 Tiles
	endcase
end

wire	[31:0] Absolute_Compute_Mult;
wire	[31:0] Relative_Compute_Mult;
//wire	[21:0] TileMap_Effective_Addy;
//reg	[9:0] TileMap_X_Window_Pos_Compute_Minus1;
//wire	[9:0] TileMap_X_Window_Pos_Compute_Plus1;


reg	[9:0] TileMap_Y_Window_Pos_Compute;

always @ (posedge EngineClk100Mhz_i) begin
	TileMap_Y_Window_Pos_Compute <= TileLineChoiceY ? ((TileMap_Y_Window_Pos == 10'b00_0000_0000) ? 10'b00_0000_0000 : TileMap_Y_Window_Pos - 10'b00_0000_0001) : TileMap_Y_Window_Pos;
end

// This Computes the Position in Y to add to the Absolute Address Beginning. THis is Short Boundary (16bits Boundary)
DMA_MULT_BLK TileMapAddyOrigineCompute(
	.clock(EngineClk100Mhz_i),
	.dataa( { 5'b0_0000, TileMap_X_Size_Compute, 1'b0} ),				// Size of the Map x 2 (1x Short per Tile) since we are computing Address
	.datab( { 6'b00_0000, TileMap_Y_Window_Pos_Compute}), 	// Number of line
	.result( Absolute_Compute_Mult )	// The Output is in Tile Char, 
	);

wire [5:0] TileMap_LineCount_With_Flip;

assign TileMap_LineCount_With_Flip = TileMap_LineCounter[5:0] + {5'b00_000, TileMap_LineFlip};
	
DMA_MULT_BLK TileMapAddyLineCompute(
	.clock(EngineClk100Mhz_i),
	.dataa( { 5'b0_0000, TileMap_X_Size_Compute, 1'b0} ),		// X-Stride in Words
	.datab( { 10'b00_0000_0000, TileMap_LineCount_With_Flip} ), 		//Line Number
	.result( Relative_Compute_Mult )	// The Output is in Tile Char, 
	);

wire	[31:0] ADDY_ADDER_Results;
ADDY_ADDER	ADDY_ADDER_inst (
	.data0x ( {10'b00_0000_0000, Addy_2_Compute[21:0]} ),
	.data1x ( {10'b00_0000_0000, Absolute_Compute_Mult[21:0]} ),
	.data2x ( {21'b0_0000_0000_0000_0000_0000, TileMap_X_Window_Pos[9:1], 2'b00} ),
	.data3x ( {10'b00_0000_0000, Relative_Compute_Mult[21:0]} ),
	.data4x ( 32'h0000_0000 ),
	.data5x ( 32'h0000_0000 ),
	.data6x ( 32'h0000_0000 ),
	.data7x ( 32'h0000_0000 ),
	.result ( ADDY_ADDER_Results )
	);


assign TileMap_Addy_Start 	= ADDY_ADDER_Results[21:2]; // Stop (Number of Tile of 16bits)
assign TileMap_Addy_Stop 	= ADDY_ADDER_Results[21:2] + MaxValueTileMap2BeRead; // Stop (Number of Tile of 16bits) 

//reg	[5:0]		Buffer_X_Pointer;

always @ (posedge EngineClk100Mhz_i) 
begin
	if (VGE_Engine_Rst_i || Reset_100Mhz_i) begin
		TileMap_Position <= 5'b0_0000;
	end
	else begin
		if (VRAM_Data_Valid_i & MAP_DATA)
			TileMap_Position <= TileMap_Position + 5'b0_0001;		
		else
			TileMap_Position <= 5'b0_0000;
	end
end

wire All_Triggers;
reg 	Triggers_By_Layers;

assign All_Triggers = Time_2_Charge_TileMap_L0_Lines_i[0] | Time_2_Charge_TileMap_L1_Lines_i[0] | Time_2_Charge_TileMap_L2_Lines_i[0]  | Time_2_Charge_TileMap_L3_Lines_i[0];

always @ (*) begin
	case ( TileMap_Actual_Layer ) 
		2'b00: begin Triggers_By_Layers = Time_2_Charge_TileMap_L0_Lines_i[0]; end
		2'b01: begin Triggers_By_Layers = Time_2_Charge_TileMap_L1_Lines_i[0]; end
		2'b10: begin Triggers_By_Layers = Time_2_Charge_TileMap_L2_Lines_i[0]; end
		2'b11: begin Triggers_By_Layers = Time_2_Charge_TileMap_L3_Lines_i[0]; end
	endcase
end


reg	[4:0]		TileMap_Position;	// 32x 32 
reg	[5:0]		TileMap_LineCounter;
reg				TileMap_LineFlip;

assign TileMap_Addy = { TileMap_Actual_Layer, TileMap_LineFlip, TileMap_Position };

reg	[3:0]		VGE_TileMap_SM;
reg	[3:0]		VGE_TileMap_SM_SM;

assign VGE_TileMap_SM_o = VGE_TileMap_SM;

initial begin
			TileMap_LineFlip 		= 1'b0;
end

localparam	TLMAP_IDLE		= 4'b0000,

				TLMAP_PREP0		= 4'b0001,
				TLMAP_PREP1		= 4'b0010,
				
				TLMAP_WAIT		= 4'b0011,
				
				TLMAP_WAITX    = 4'b0100,
				
				TLMAP_READ0		= 4'b0101,
				TLMAP_WAIT0		= 4'b0110,
				TLMAP_WAIT1		= 4'b0111,
				TLMAP_WAIT2		= 4'b1000,
				TLMAP_READ1		= 4'b1001,
				TLMAP_READ2		= 4'b1010,
				TLMAP_READ3		= 4'b1011,
				TLMAP_READ4		= 4'b1100,				
				
				TLMAP_UPDCH		= 4'b1101,
				TLMAP_WAIT_END	= 4'b1110;


always @ (posedge EngineClk100Mhz_i) begin
	if (VGE_Engine_Rst_i || Reset_100Mhz_i) begin
			VGE_TileMap_SM			<= TL_IDLE;
			TileMap_LineCounter	<= 6'b00_0000;
			TileMap_Actual_Layer	<= 2'b00;
			TileMap_LineFlip		<= 1'b0;
			TileMap_Enable_Tfr	<= 1'b0;
	end
	else begin
		case (VGE_TileMap_SM)
		
		// Let's wait for the Cue to go Fetch
		// Lets
		TLMAP_IDLE: begin
			if ( All_Triggers  &&  TileMap_Effect_On_i  && Trig_TL_Read_Memory_i) begin	// 2'b11 Represent the beginning of a Frame - So Precharge 2 lines
				TileMap_Actual_Layer 	<= 2'b00;			// The Layer Counter
				MAP_DATA						<= 1'b1;				
				VGE_TileMap_SM 			<= TLMAP_PREP0;

				if ( Time_2_Charge_TileMap_L0_Lines_i[1] | Time_2_Charge_TileMap_L1_Lines_i[1] | Time_2_Charge_TileMap_L2_Lines_i[1] | Time_2_Charge_TileMap_L3_Lines_i[1]) begin
					TileMap_LineCounter 		<= 6'b00_0000;		// We begin a new cycle
				end
			end
			else begin
				MAP_DATA						<= 1'b0;
				VGE_TileMap_SM 			<= TLMAP_IDLE;
			end
		end
		
		
		// Check if it is the first Line (because we will to have to fech 2 line 
		TLMAP_PREP0: begin
			VGE_TileMap_SM		<= TLMAP_PREP1;
		end
		
		// Check if the Channel is Enabled
		TLMAP_PREP1: begin
			if (TileMapEnabled_Channel && Triggers_By_Layers) begin
					VGE_TileMap_SM			<= TLMAP_WAIT;
					TileMap_LineFlip		<= 1'b0; // Fill in Line 0
				end
			else begin
					VGE_TileMap_SM			<= TLMAP_UPDCH;			
			end
		end
		
		// memory Ready latency
		// When this State is reached the Address is Loaded in the COunter;
		TLMAP_WAIT: begin 
			VGE_TileMap_SM			<= TLMAP_READ0;
			TileMap_Enable_Tfr	<= 1'b1;	// We are ready to roll
		end
		
	
		// Data Valid and Write is Enabled
		TLMAP_READ0: begin 
			if (Counter_Reached_Count_i) begin
				TileMap_Enable_Tfr 	<= 1'b0;			// Stops the Counters (When we are here the Starts Addy = Stop Addy)
				VGE_TileMap_SM	<= TLMAP_WAIT0;
			end
			else begin
				VGE_TileMap_SM	<= TLMAP_READ0;
			end
		end
		
		// 1 Clock Extra for Data to Finished Writen in the DP RAM (2 Latency on the DataValid)
		TLMAP_WAIT0: begin
				TileMap_LineFlip 		<= 1'b1;	// Fill in Line 1	
				VGE_TileMap_SM	<= TLMAP_WAIT1;
		end
		
		// Let's load the New Address here
		TLMAP_WAIT1: begin
				VGE_TileMap_SM	<= TLMAP_WAIT2;		
		end	
	
		TLMAP_WAIT2: begin
				TileMap_Enable_Tfr	<= 1'b1;	// We are ready to roll		
				VGE_TileMap_SM	<= TLMAP_READ1;		
		end		
		
		TLMAP_READ1: begin 
			if (Counter_Reached_Count_i) begin
				TileMap_Enable_Tfr 	<= 1'b0;			// Stops the Counters (When we are here the Starts Addy = Stop Addy)
				VGE_TileMap_SM	<= TLMAP_UPDCH;
			end
			else begin
				VGE_TileMap_SM	<= TLMAP_READ1;
			end	
		end

		// Layer Loop
		TLMAP_UPDCH: begin
			TileMap_LineFlip 		<= 1'b0;	// Fill in Line 1
			TileMap_Actual_Layer <= TileMap_Actual_Layer + 2'b01;			
			
			if ( TileMap_Actual_Layer != 2'b11 ) begin
				VGE_TileMap_SM		<= TLMAP_PREP0;				
			end
			else begin
			
				TileMap_LineCounter	<= TileMap_LineCounter + 6'b00_0001;
				VGE_TileMap_SM			<= TLMAP_WAIT_END;
				MAP_DATA					<= 1'b0;				
			end
		end
		
		// Wait here till the Time_2_Charge_TileMap_Lines_i returns to 0 
		TLMAP_WAIT_END: begin
			if ( All_Triggers  &&  TileMap_Effect_On_i )		
				VGE_TileMap_SM		<= TLMAP_WAIT_END;
			else
				VGE_TileMap_SM		<= TL_IDLE;
		end
		
		default: begin
			VGE_TileMap_SM		<= TL_IDLE;		
		end
	
		endcase
	end
end	

/*
wire [143:0] ChipScope;
wire			Trigger;
//assign Trigger = (Time_2_Charge_TileMap_Lines_i[1:0] == 2'b11) & TileMap_Effect_On_i;

// Triggers on Layer 0
//assign Trigger = (Time_2_Charge_TileMap_L0_Lines_i[1:0] == 2'b11) & TileMap_Effect_On_i & Trig_TL_Read_Memory_i;
//assign Trigger = (Horizontal_Line_Count_i == Debug_Source_i[11:0]) & TileMap_Effect_On_i & Trig_TL_Read_Memory_i;

assign Trigger = (VGE_Tile_Engine_SM == TL_STATE0);
//assign Trigger = TileMap_Effect_On_i & Trig_TL_Read_Memory_i;

TinyChipScope	ChipScope_inst (
	.acq_clk ( EngineClk100Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

// This is the Signal Driving the Input Side of the DP Memory
assign ChipScope[31:0] 		= VRAM_Data_2_TILEMAP_i;
assign ChipScope[32] 		= VRAM_Data_Valid_i;
assign ChipScope[40:33] 	= TileMap_Addy;
assign ChipScope[44:41] 	= VGE_TileMap_SM;
assign ChipScope[46:45] 	= Time_2_Charge_TileMap_L0_Lines_i;
assign ChipScope[47]    	= TileMap_Effect_On_i;
// These are the signals 
assign ChipScope[63:48] 	= Active_Tile_Data;
assign ChipScope[72:64] 	= Tile2Pick_Addy;
// 
assign ChipScope[73] 		= TileMapEnabled_Channel;
assign ChipScope[74] 		= Trig_TL_Read_Memory_i;
//assign ChipScope[78:75] 	= TileMap_X_Window_Pos[3:0];
//assign ChipScope[82:79] 	= TileMap_Y_Window_Pos[3:0];
assign ChipScope[79:75] 	= Offset[4:0];
assign ChipScope[84:80] 	= TileLinePointer[4:0];
assign ChipScope[88:85]		= Horizontal_Line_Count_i[3:0];
//assign ChipScope[92:83] 	= TileMap0_X_TotalSize_i;
assign ChipScope[93:89] 	= Tile2Pick_Addy_Position;
assign ChipScope[95:94]		= TileMap_Actual_Layer;
assign ChipScope[117:96] 	= TileMap_Target_Addy_Start_o;
assign ChipScope[118]   	= MAP_DATA;
assign ChipScope[124:119] 	= TileMap_LineCount_With_Flip;
assign ChipScope[129:125]  = VGE_Tile_Engine_SM;
assign ChipScope[137:130] 	= VGE_EffectChannel_TL_ADDY;
assign ChipScope[138]		= Counter_Load_TM_o;
assign ChipScope[139]		= DataValidStrobe_DataMap_Time;
assign ChipScope[140] 		= TileSize8_16;
assign ChipScope[141] 		= Counter_Reached_Count_i;
*/
TILEMAP_2Lines_Capture TileMapCapture(

	.clock( EngineClk100Mhz_i ),
	.rdaddress( Tile2Pick_Addy ),
	.q( Active_Tile_Data ), //16
	
	.data( VRAM_Data_2_TILEMAP_i ),
	.wraddress( TileMap_Addy ),
	.wren( VRAM_Data_Valid_i & MAP_DATA )
);

// We Store 2 Lines of Tile Here
// This is the Memory we capture the Tiles 
// Active_Tile_Data[7:0] -> Tile Number
// Active_Tile_Data[10:8] -> Tile Attributes // Tile Set
// Active_Tile_Data[13:11] -> Tile Attributes // Tile LUT
// Active_Tile_Data[14] -> TileCollision0 - Enable Collision
// Active_Tile_Data[15] -> TileCollision1 - Reserved

// Tile2Pick_Addy[5:0] -> Tile2Pick 64 Position
// Tile2Pick_Addy[6] -> 0 - Line Zero, 1 - Line One
// Tile2Pick_Addy[8:7] -> 00 - Layer0, 01 - Layer1, 10 - Layer2, 11 - Layer3
/*

reg	[4:0]		TileMap_Position;	// 32x 32 
reg				TileMap_Write;		// Write Strobe from the Memory
reg	[5:0]		TileMap_LineCounter;
							// 2'b00, 1'b0, 5'b0_0000		(32Bits Data Path)
assign TileMap_Addy = { TileMap_Actual_Layer, TileMap_LineCounter[0], TileMap_Position };
*/


wire	[15:0]	Active_Tile_Data;
wire	[8:0]		Tile2Pick_Addy;

reg 	[4:0]		TileVerticalOffset[0:3];
reg 	[5:0]		Tile2Pick_Addy_Position;
reg	[7:0]		Active_Tile_Attributes;
								// 2'b00, 1'b0, 6'b00_0000 (16Bits Data Path)
assign Tile2Pick_Addy = TileSize ? { TileBank, TileLinePointer[3], Tile2Pick_Addy_Position } : { TileBank, TileLinePointer[4], Tile2Pick_Addy_Position };

////////////////////////////////////////////////////////
///////////
/////////// TILE PIXEL CAPTURE
///////////
////////////////////////////////////////////////////////
//	.wraddress ( VGE_Engine_EffectChannel_BM_ADDY ), 
//	.wren (( VGE_Engine_BM_WE & Collision_Mode_Write_i ) | Clear_PixelLine_BitMap )

assign Tile_Data_o 		= ( Clear_PixelLine_TileMap ) ? 32'h0000_0000 	: VRAM_Data_2_TILEMAP_i;
assign Tile_Attribute_o = ( Clear_PixelLine_TileMap ) ? 8'h00 				: Active_Tile_Attributes; 

reg	[7:0] 	Tile_Layer_Control_Reg;

always @ (posedge EngineClk100Mhz_i) begin
	if (VGE_Engine_Rst_i || Reset_100Mhz_i) begin
		Tile_Layer_Control_Reg <= 8'h00;
	end
	else begin
		case(TileBank)
			2'b00: Tile_Layer_Control_Reg 	<= Tile0_Layer_Control_Reg_i;
			2'b01: Tile_Layer_Control_Reg 	<= Tile1_Layer_Control_Reg_i;
			2'b10: Tile_Layer_Control_Reg 	<= Tile2_Layer_Control_Reg_i;
			2'b11: Tile_Layer_Control_Reg 	<= Tile3_Layer_Control_Reg_i;
		endcase
	end
end

reg	[22:0]		Active_TileSet_Addy;
always @ (*) begin
	case(Active_Tile_Data[10:8])
		3'b000: Active_TileSet_Addy = TileSet0Addy_i[22:0];
		3'b001: Active_TileSet_Addy = TileSet1Addy_i[22:0];
		3'b010: Active_TileSet_Addy = TileSet2Addy_i[22:0];
		3'b011: Active_TileSet_Addy = TileSet3Addy_i[22:0];
		3'b100: Active_TileSet_Addy = TileSet4Addy_i[22:0];
		3'b101: Active_TileSet_Addy = TileSet5Addy_i[22:0];
		3'b110: Active_TileSet_Addy = TileSet6Addy_i[22:0];
		3'b111: Active_TileSet_Addy = TileSet7Addy_i[22:0];	
	endcase
end

reg	[3:0]		Active_TileSet_Cfg;
always @ (*) begin
	case(Active_Tile_Data[10:8])
		3'b000: Active_TileSet_Cfg = TileSet0Cfg_i;
		3'b001: Active_TileSet_Cfg = TileSet1Cfg_i;
		3'b010: Active_TileSet_Cfg = TileSet2Cfg_i;
		3'b011: Active_TileSet_Cfg = TileSet3Cfg_i;
		3'b100: Active_TileSet_Cfg = TileSet4Cfg_i;
		3'b101: Active_TileSet_Cfg = TileSet5Cfg_i;
		3'b110: Active_TileSet_Cfg = TileSet6Cfg_i;
		3'b111: Active_TileSet_Cfg = TileSet7Cfg_i;	
	endcase
end

wire TileSize;

assign TileSize = Tile_Layer_Control_Reg[4];

always @ (*) begin
	case({ TileSize, Mstr_Ctrl_Doubling_Pixel_100Mhz_i, Mstr_Ctrl_Video_Mode100Mhz_i[1:0]})
		// Tile is 16x16
		4'b0000: NumberOfTile2Read = 8'd44;	// (42) 16 + 640 + 16 	( 1 + 40 + 1)
		4'b0001: NumberOfTile2Read = 8'd44; // (52) 16 + 640 + 16 	( 1 + 40 + 1)
		4'b0010: NumberOfTile2Read = 8'd54; // (66) 16 + 800 + 16 	( 1 + 54 + 1)
		4'b0011: NumberOfTile2Read = 8'd54; // (27) 16 + 800 + 16 	( 1 + 54 + 1)
		// Doubling Mode
		4'b0100: NumberOfTile2Read = 8'd24;	// (42) 16 + 320 + 16 	( 1 + 20 + 1)
		4'b0101: NumberOfTile2Read = 8'd24;  // (52) 16 + 400 + 16 	( 1 + 25 + 1)
		4'b0110: NumberOfTile2Read = 8'd29; 	// (22) 16 + 512 + 16 	( 1 + 32 + 1)
		4'b0111: NumberOfTile2Read = 8'd29; 	// (27) 16 + 320 + 16 	( 1 + 20 + 1) 
		// Tile is 8x8
		4'b1000: NumberOfTile2Read = 8'd84;	// (42) 8 + 640 + 8 	( 1 + 80 + 1)
		4'b1001: NumberOfTile2Read = 8'd84; // (52) 8 + 640 + 8 	( 1 + 80 + 1)
		4'b1010: NumberOfTile2Read = 8'd104; // (66) 8 + 800 + 8 	( 1 + 100 + 1)
		4'b1011: NumberOfTile2Read = 8'd104; // (27) 8 + 800 + 8 	( 1 + 100 + 1)		
		// Doubling Mode		
		4'b1100: NumberOfTile2Read = 8'd44;	// (42) 8 + 320 + 8 	( 1 + 20 + 1)
		4'b1101: NumberOfTile2Read = 8'd44;  // (52) 8 + 400 + 8 	( 1 + 25 + 1)
		4'b1110: NumberOfTile2Read = 8'd54; 	// (22) 8 + 512 + 8 	( 1 + 32 + 1)
		4'b1111: NumberOfTile2Read = 8'd54; 	// (27) 8 + 320 + 8 	( 1 + 20 + 1) 
		
	endcase
end					


// Wires
wire 				TileStride256x256;
//wire	[2:0]		TileLUT;
//wire	[2:0]		TileSet;
reg	[4:0]		TileLinePointer;
wire				DataValidStrobe_DataMap_Time;
/// Registers Needed in the Master State Machine
reg	[4:0]		VGE_Tile_Engine_SM;
reg	[1:0]		TileBank;
reg	[3:0]		PixelCount;
reg				Tile_Stride256x256;
reg	[4:0]		Scroll_Y_Tile_Offset[0:3];
reg	[4:0]		Tile_Y_Scroll_Reg[0:3];
reg	[7:0]		NumberOfTile2Read;
reg	[7:0] 	VGE_EffectChannel_TL_ADDY;
reg				Tile_Active;
reg	[15:0]	Pixel2FetchCounter_TL;
reg				Clear_PixelLine_TileMap;
// Assignments

assign VGE_EffectChannel_TL_ADDY_o = VGE_EffectChannel_TL_ADDY;

assign VGE_Tile_Engine_SM_o = (VGE_Tile_Engine_SM == TL_TRF_DONE);
assign TileStride256x256 = Active_TileSet_Cfg[3];
//assign TileSet = Active_Tile_Data[10:8];
//assign TileLinePointer = Mstr_Ctrl_Doubling_Pixel_100Mhz_i ? ({1'b0, Horizontal_Line_Count_i[4:1]} + Offset) : ({1'b0, Horizontal_Line_Count_i[3:0]} + Offset);


always @ (*) begin
	case( {   TileSize, Mstr_Ctrl_Doubling_Pixel_100Mhz_i} ) 
		2'b00: TileLinePointer = ({1'b0, Horizontal_Line_Count_i[3:0]} + Offset);	//Offset <= {1'b0, (4'b1111 - Tile_Y_Scroll_Reg[TileBank][3:0])
		2'b01: TileLinePointer = ({1'b0, Horizontal_Line_Count_i[4:1]} + Offset);
		2'b10: TileLinePointer = ({2'b00, Horizontal_Line_Count_i[2:0]} + Offset); //{2'b00, (3'b111 - Tile_Y_Scroll_Reg[TileBank][2:0])}
		2'b11: TileLinePointer = ({2'b00, Horizontal_Line_Count_i[3:1]} + Offset);
	endcase
end

reg [4:0] Offset;
																

assign DataValidStrobe_DataMap_Time = (VRAM_Data_Valid_i & !MAP_DATA);
// Pointer to the 
assign VGE_Engine_TL0_WE_o = (( TileBank[1:0] == 2'b00 )  ? DataValidStrobe_DataMap_Time : 1'b0 ) | Clear_PixelLine_TileMap; // Less Priority
assign VGE_Engine_TL1_WE_o = (( TileBank[1:0] == 2'b01 )  ? DataValidStrobe_DataMap_Time : 1'b0 ) | Clear_PixelLine_TileMap;
assign VGE_Engine_TL2_WE_o = (( TileBank[1:0] == 2'b10 )  ? DataValidStrobe_DataMap_Time : 1'b0 ) | Clear_PixelLine_TileMap;
assign VGE_Engine_TL3_WE_o = (( TileBank[1:0] == 2'b11 )  ? DataValidStrobe_DataMap_Time : 1'b0 ) | Clear_PixelLine_TileMap; // More Priority

/////////////////////////////////////
// Tile Pixel Line Counter
/////////////////////////////////////
always @ (posedge EngineClk100Mhz_i) begin
	if (VGE_Engine_Rst_i || Reset_100Mhz_i) begin
		VGE_EffectChannel_TL_ADDY <= 8'b0000_0000;
	end
	else begin
		if (Tile_Active) begin
			if (DataValidStrobe_DataMap_Time || Clear_PixelLine_TileMap)
				VGE_EffectChannel_TL_ADDY <= VGE_EffectChannel_TL_ADDY + 8'b0000_0001;
		end
			else
				VGE_EffectChannel_TL_ADDY <= 8'b0000_0100;		// Byte (Pixel)
	end
end

// Init a Bunch of Memory Location @ INIT PRELOAD STATE
always @ (posedge EngineClk100Mhz_i) begin
	if (VGE_Engine_Rst_i || Reset_100Mhz_i) begin
		//
		Tile_Y_Scroll_Reg[0] <= 5'b0_0000;
		Tile_Y_Scroll_Reg[1] <= 5'b0_0000;
		Tile_Y_Scroll_Reg[2] <= 5'b0_0000;
		Tile_Y_Scroll_Reg[3] <= 5'b0_0000;
	end
	else begin
		if (SOF_i[1:0] == 2'b10) begin
			Tile_Y_Scroll_Reg[0] <= Tile0_Y_Scroll_Reg_i;
			Tile_Y_Scroll_Reg[1] <= Tile1_Y_Scroll_Reg_i;
			Tile_Y_Scroll_Reg[2] <= Tile2_Y_Scroll_Reg_i;
			Tile_Y_Scroll_Reg[3] <= Tile3_Y_Scroll_Reg_i;
		end
	end
end

// [21:0]
//assign VGE_TileData_Addy = Active_TileSet_Addy[21:0] + {6'b00_0000, Pixel2FetchCounter_TL[15:0]};
//assign TileData_Addy_Start = TileSize ? (Active_TileSet_Addy[21:2] + {6'b00_0000, Pixel2FetchCounter_TL[15:2]}) : (Active_TileSet_Addy[21:2] + {6'b00_0000, Pixel2FetchCounter_TL[15:2]});
assign TileData_Addy_Start = (Active_TileSet_Addy[21:2] + {6'b00_0000, Pixel2FetchCounter_TL[15:2]});
assign TileData_Addy_Stop 	= TileSize ? (Active_TileSet_Addy[21:2] + {6'b00_0000, Pixel2FetchCounter_TL[15:2]} + 20'h0_0002) : (Active_TileSet_Addy[21:2] + {6'b00_0000, Pixel2FetchCounter_TL[15:2]} + 20'h0_0004);

always @ (*)
begin
	case ( { TileSize, TileStride256x256} ) 
		2'b00: Pixel2FetchCounter_TL = {Active_Tile_Data[7:0], TileLinePointer[3:0], 4'b0000};
		2'b01: Pixel2FetchCounter_TL = {Active_Tile_Data[7:4], TileLinePointer[3:0], Active_Tile_Data[3:0], 4'b0000};
		2'b10: Pixel2FetchCounter_TL = {2'b00, Active_Tile_Data[7:0], TileLinePointer[2:0], 3'b000};
		2'b11: Pixel2FetchCounter_TL = {3'b000, Active_Tile_Data[7:4], TileLinePointer[2:0], Active_Tile_Data[3:0], 3'b000};
	endcase
end


reg		TileMap_X_Windows_TileChoice;
always @ (*) 
begin
	case(TileBank)
		2'b00:	TileMap_X_Windows_TileChoice <= TileMap0_X_Window_Pos_i[0];
		2'b01:	TileMap_X_Windows_TileChoice <= TileMap1_X_Window_Pos_i[0];
		2'b10:	TileMap_X_Windows_TileChoice <= TileMap2_X_Window_Pos_i[0];
		2'b11:	TileMap_X_Windows_TileChoice <= TileMap3_X_Window_Pos_i[0];
	endcase
end

/// TILE STATE MACHINE STATE

localparam		TL_IDLE					= 5'b00000,	//0
					TL_PRESTATE       	= 5'b00001,	//1
					TL_INIT_PRELOAD		= 5'b00011,	//2
					TL_PRESTATE0			= 5'b00010,	//3
					TL_STATE0				= 5'b00110,	//4
					TL_STATE1				= 5'b00111,	//5
					TL_STATE2				= 5'b00101,	//6
					TL_STATE_LOAD_ADDY 	= 5'b00100,	//7
					TL_STATE4				= 5'b01100,	//8
					TL_STATE5				= 5'b01101,	//9
					TL_STATE6				= 5'b01111,	//10
					TL_STATE7				= 5'b01110,	//11
					TL_STATE8				= 5'b01010,	//12
					TL_STATE9				= 5'b01011,	//13
					TL_CLEAN_LINE0			= 5'b01001,	//14
					TL_CLEAN_LINE1			= 5'b01000,	//15
               TL_STATE_LATENCY 		= 5'b11000,	//16
               FETCH_TL_16PIX1   	= 5'b11001,	//17
               FETCH_TL_16PIX2   	= 5'b11011,	//18
               FETCH_TL_16PIX3   	= 5'b11010,	//19
               FETCH_TL_16PIX4   	= 5'b11110,	//20
               FETCH_TL_16PIX5   	= 5'b11111,	//21
               FETCH_TL_16PIX6   	= 5'b11101,	//22
               FETCH_TL_16PIX7   	= 5'b11100,	//23
               TL_TEMP0					= 5'b10100,	//24
               TL_TEMP1					= 5'b10101,	//25
               TL_TEMP2					= 5'b10111,	//26
               TL_TEMP3					= 5'b10110,	//27
               TL_TEMP4					= 5'b10010,	//28
               TL_TEMP5					= 5'b10011,	//29
               TL_TEMP6					= 5'b10001,	//30
					TL_TRF_DONE				= 5'b10000;	//31	
		
always @ ( posedge EngineClk100Mhz_i ) begin
		// The Load happens here
		if (VGE_Tile_Engine_SM == TL_STATE_LOAD_ADDY)  begin
			Active_Tile_Attributes <= {1'b0, Active_Tile_Data[14], 2'b00, Active_Tile_Data[15], Active_Tile_Data[13:11]};
		end
end

////////////////////////////////////////////////////
////
//// GRAPHIC ENGINE TILEMAP STATE MACHINE
////
////////////////////////////////////////////////////
reg [4:0] VGE_Tile_Engine_SM_SM;

always @ (posedge EngineClk100Mhz_i) begin
	if (VGE_Engine_Rst_i || Reset_100Mhz_i) begin
			VGE_Tile_Engine_SM		<= TL_IDLE;
			//VGE_Tile_Engine_SM_SM   <= TL_IDLE;
			Tile_Active					<= 1'b0;
			Tile2Pick_Addy_Position	<= 6'b00_0000;
			TileData_Enable_Tfr		<= 1'b0;
			Offset						<= 4'b0_0000;
	end
	else begin
	

		case( VGE_Tile_Engine_SM )

		TL_IDLE: begin
			if (TileMap_Effect_On_i && Trig_TL_Read_Memory_i) // Ok this is the trigger for the Map char line to be loaded with new frame
			begin
					VGE_Tile_Engine_SM <= TL_PRESTATE;
					TileBank <= 2'b00;
			end
			else begin
				if (Clear_Bit_Line_i) begin			// Begin the Line 28 (Blanking) + 59 Lines
					Tile_Active			   		<= 1'b1;
					Clear_PixelLine_TileMap		<= 1'b1;
					VGE_Tile_Engine_SM 			<= TL_CLEAN_LINE0;
					//VGE_Tile_Engine_SM_SM   	<= TL_IDLE;					
				end
				else 
					VGE_Tile_Engine_SM <= TL_IDLE;
			end
		end
		
		// Check if we are in a Map Line Capture
		TL_PRESTATE: begin
				VGE_Tile_Engine_SM <= TL_PRESTATE0;	// Wait for the MAP Line to be read
		end
		

		// Check if we are in a Map Line Capture
		TL_PRESTATE0: begin
			if (MAP_DATA)
				VGE_Tile_Engine_SM <= TL_PRESTATE0;	// Wait for the MAP Line to be read
			else 
				VGE_Tile_Engine_SM <= TL_STATE0;		// We are already in 
		end

		// Ran once at the begining of the frame
		// Anything that needs to be reseted before a new frame ought to be done here.
	
	
		TL_STATE0: begin
			if (Tile_Layer_Control_Reg[0])		// Check if the layer is On
				VGE_Tile_Engine_SM <= TL_STATE1; // if the Layer is On, then Let's get Cracking
			else begin	
				VGE_Tile_Engine_SM <= TL_STATE8;	// Go Change the Layer since this one is OFF
			end
		end
		
		// We are Fetching the MAP Char that we are going to fetch 
		// Tile Fetch Layer
		TL_STATE1: begin
			if (TileMap_X_Windows_TileChoice)
				Tile2Pick_Addy_Position <= 6'b00_0001;
			else 
				Tile2Pick_Addy_Position <= 6'b00_0000;		
			
			if ( TileSize ) begin
				// 8x8
				if (Tile_Y_Scroll_Reg[TileBank][4]) begin
					Offset <= {2'b00, (3'b111 - Tile_Y_Scroll_Reg[TileBank][2:0])}; // What line Graphics (We calculate from bottom)
				end
				else begin
					Offset <= {2'b00, Tile_Y_Scroll_Reg[TileBank][2:0]}; // What line Graphics (We calculate from bottom)
				end			
			end 
			else begin
				// 16x16 
				if (Tile_Y_Scroll_Reg[TileBank][4]) begin
					Offset <= {1'b0, (4'b1111 - Tile_Y_Scroll_Reg[TileBank][3:0])}; // What line Graphics (We calculate from bottom)
				end
				else begin
					Offset <= {1'b0, Tile_Y_Scroll_Reg[TileBank][3:0]}; // What line Graphics (We calculate from bottom)
				end
			end

				
				
			VGE_Tile_Engine_SM <= TL_STATE2; // if the Layer is On, then Let's get Cracking
			Tile_Active <= 1'b1;	// This will allow for Writing to the DP lines
		end
		
		// Latency from Map Char Mem
		TL_STATE2: begin
			VGE_Tile_Engine_SM <= TL_STATE_LATENCY;
		end
		
		// The Load happens here
		TL_STATE_LOAD_ADDY: begin
			TileData_Enable_Tfr <= 1'b1;
			VGE_Tile_Engine_SM <= TL_STATE4;	
		end
		
		// Transfer begins here
		// Clock 0
		TL_STATE4: begin
			Tile2Pick_Addy_Position <= Tile2Pick_Addy_Position + 6'b00_0001; 			// Prepare the Next Address
			VGE_Tile_Engine_SM <= TL_STATE5; // if the Layer is On, then Let's get Cracking			
		end
		
		// Clock 1/2/3
		TL_STATE5: begin
			if (Counter_Reached_Count_i) begin
				TileData_Enable_Tfr 	<= 1'b0;			// Stops the Counters (When we are here the Starts Addy = Stop Addy)
				//VGE_Tile_Engine_SM <= TL_STATE7; 				
				if (Tile2Pick_Addy_Position < NumberOfTile2Read) begin
					VGE_Tile_Engine_SM <= TL_STATE_LOAD_ADDY; // if the Layer is On, then Let's get Cracking					
				end
				else begin
					Tile_Active <= 1'b0;	// This will reset Counter for the DP Output Memory
					VGE_Tile_Engine_SM <= TL_STATE8; // if the Layer is On, then Let's get Cracking								
				end					
			end
			else begin
				VGE_Tile_Engine_SM <= TL_STATE5; 
			end
		end

		// Tile Bank Number will take effect here
		// Next state the Config Information will be valid
		TL_STATE8: begin
			if (TileBank == 2'b11)						// If we have reached Layer 4 and it is not Enable, just go at the end and declare the process to be over.
				VGE_Tile_Engine_SM <= TL_TRF_DONE;	// We have Filled 4 Lineds of Pixels from 4 Layers
			else begin
				TileBank <= TileBank + 2'b01;
				VGE_Tile_Engine_SM <= TL_STATE9;
			end	
		end
		
		TL_STATE9: begin
				VGE_Tile_Engine_SM <= TL_STATE0;
		end
		////////////////////////////////////////////
		// Clear the Line Before Drawing in
		////////////////////////////////////////////
		TL_CLEAN_LINE0: begin
				if (VGE_EffectChannel_TL_ADDY < {NumberOfTile2Read[5:0], 2'b00} ) begin
					VGE_Tile_Engine_SM <= TL_CLEAN_LINE0;
				end
				else begin
					//VGE_Tile_Engine_SM 			<= VGE_Tile_Engine_SM_SM;
					VGE_Tile_Engine_SM 			<= TL_IDLE;
					Tile_Active			   		<= 1'b0;	
					Clear_PixelLine_TileMap		<= 1'b0;
				end
		end

		TL_STATE_LATENCY: begin
				VGE_Tile_Engine_SM <= TL_STATE_LOAD_ADDY;
				
		end
		
		// When the Line has been Drawned
		TL_TRF_DONE: begin
				VGE_Tile_Engine_SM <= TL_IDLE;	// If we haven't reach the last line, go wait for another Trigger
		end


		default: begin
				VGE_Tile_Engine_SM	<= TL_IDLE;				
		end

		endcase
	end
end


endmodule
