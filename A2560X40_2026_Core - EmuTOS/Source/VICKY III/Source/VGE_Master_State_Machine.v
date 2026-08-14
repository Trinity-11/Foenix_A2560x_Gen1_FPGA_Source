`timescale 1ns/1ns
module VGE_Master_State_Machine(

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

// Master Control Signals
input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,
input		wire				Mstr_Ctrl_Graphic_Mode_Enable_i,
input		wire				Mstr_Ctrl_Bitmap_Enable_i,
input		wire				Mstr_Ctrl_TileMap_Enable_i,
input		wire				Mstr_Ctrl_Sprite_Enable_i,

input		wire	[11:0]	SX0_i,
input		wire	[11:0]	SY0_i,
input		wire	[11:0]	SX1_i,
input		wire	[11:0]	SY1_i,

input		wire	[11:0]	VX0_i,
input		wire	[11:0]	VY0_i,
input		wire	[11:0]	VX1_i,
input		wire	[11:0]	VY1_i,

// Bitmaps & Collision Map
input		wire				BM0_Layer_Enable_i,
input		wire	[2:0] 	BM0_Layer_Lut_i,
input		wire	[23:0]	BM0_MapAddy_i,
input		wire	[4:0]		BM0_X_Offset_i, // +/- 32
input		wire	[4:0]		BM0_Y_Offset_i, // +/- 32

input		wire				BM1_Layer_Enable_i,
input		wire	[2:0]		BM1_Layer_Lut_i,
input		wire				BM1_Coll_Map_En_i,
input		wire				BM1_Coll_Map_Display_En_i,
input		wire	[23:0]	BM1_MapAddy_i,
input		wire	[4:0]		BM1_X_Offset_i, // +/- 32
input		wire	[4:0]		BM1_Y_Offset_i, // +/- 32	

// Tile Maps
input		wire				TL0_Enabled_i,
input		wire				TL1_Enabled_i,
input		wire				TL2_Enabled_i,
input		wire				TL3_Enabled_i,

// Sprites
input		wire				SPRITE_Enabled_i,
input		wire	[21:0]	SPRITE_Addy_i,
output	wire	[5:0]		SPRITE_Active_Channel_o,			
input		wire	[15:0]	Sprite_X0_Coordinate_i,
input		wire	[15:0]	Sprite_X1_Coordinate_i,
input		wire	[15:0]	Sprite_Y0_Coordinate_i,
input		wire	[15:0]	Sprite_Y1_Coordinate_i,
input		wire	[2:0]		Sprite_Priority_i,
input		wire	[2:0]		Sprite_LUT_i,

// VDMA
input		wire				VDMA_Enabled_i,

// CPU
input		wire				CPU_Transfer_i,
input		wire				CPU_Transfer_Direction_i,
input		wire	[7:0]		CPU_Transfer_Size_i,

// Memory Controller Command PORT
output	reg	[35:0]	VGE_Command_o,
output	reg				VGE_Command_Write_o,
input		wire				VGE_Command_Full_i,
// Memory Controller Tag Port - 
output	reg	[35:0]	VGE_Command_Tag_o,
output	reg				VGE_Command_Tag_Write_o,
input		wire				VGE_Command_Tag_Full_i
);

// VGE_CMD
// VGE_CMD [21:00] Address - Pointer from Were on 4 Bytes Boundary. [21:0]	// From 00:0000..3F:0000
// VGE_CMD [31:22] Count (in Bytes) - How Many Words I need to Fetch from Memory [9:0]

// VGE_CMD [01:00] Mode - 00: Memory Read, 01: Memory Write, 10:DMA Read, 11:DMA Write 
// VGE_CMD [03:02] FETCH NODE 00: BM, 01: TILE, 10: SPRITE, 11: MISC 	// Tags to Be Attached with Returning Data
// VGE_CMD [09:04] SPRITE NUMBER [5:0] 6 Bits								   // Tags to Be Attached with Returning Data
// VGE_CMD [12:10] GRAPHIC PRIORITY [2:0] 3 Bits									// Tags to Be Attached with Returning Data		
// VGE_CMD [47:45] GRAPHIC LUT [2:0] 3 Bits										// Tags to Be Attached with Returning Data

reg	HBlanking_Sync0, HBlanking_Sync1;
reg	[1:0]	SOF_Sync;
reg	[1:0]	HBlanking_Sync;

// SOF goes from 0 to 1 when it begins a new frame
always @ (posedge EngineClk200Mhz_i )
begin
	SOF_Sync[0] <= SOF_i;
	SOF_Sync[1] <= SOF_Sync[0];
	
	HBlanking_Sync[0] <= HBlanking_i;		// Go for 1 to 0 
	HBlanking_Sync[1] <= HBlanking_Sync[0];
end

reg 	[11:0]	TotalLineCounter200Mhz;
reg	[12:0]	VideoPixelCounter200Mhz;

wire LineValid_200Mhz;
reg	[11:0]	VisibleLineCounter200Mhz;

assign LineValid_200Mhz = (TotalLineCounter200Mhz >= (Mstr_Ctrl_Video_Mode_i[1] ? 12'd28 : 12'd45)) ? 1'b1 : 1'b0;

always @ (posedge EngineClk200Mhz_i)
begin
	if (SOF_Sync[1:0] == 2'b01) begin
		TotalLineCounter200Mhz <= 12'h000;
		VideoPixelCounter200Mhz <= 13'h000;
	end
	else begin
		if (HBlanking_Sync[1:0] == 2'b10)	begin// Falling edge of 
			VideoPixelCounter200Mhz	<= 12'h000;
			if (LineValid_200Mhz) begin
					VisibleLineCounter200Mhz <= VisibleLineCounter200Mhz + 12'h001;	// Visible Line Counter
				end
				else begin
					VisibleLineCounter200Mhz <= 12'h020;		
				end					
				TotalLineCounter200Mhz <= TotalLineCounter200Mhz + 12'h001;		// Total Line Counter
		end
		else begin
			VideoPixelCounter200Mhz <= VideoPixelCounter200Mhz + 13'h001;
		end
	end
end




// 1280 Clocks Engine Clocks @ 200Mhz (800x600) for Horizontal Blanking (28 Lines)
// 1271 Clocks Engine Clocks @ 200Mhz (640x480) for Horizontal Blanking (45 Lines)

// Synching of the Line Number 



wire [4:0]		SpriteLineNumber_Temp;

assign SpriteLineNumber_Temp = (({4'b0000,VisibleLineCounter200Mhz} - Sprite_Y0_Coordinate_i) & 16'h001F) ; // 35 - 10 = 25 * 32 + Addy  ;



reg 				Sprite_Line_Hit;
wire [15:0] 	Line_Number_In_Sprite;
reg	[4:0]		SpriteLineNumber;
reg	[21:0]	SPRITE_Addy_Plus_Sprite_Line;

always @ (*) begin
	if (Sprite_Y0_Coordinate_i < VY0_i) begin
			if ({4'b0000,VisibleLineCounter200Mhz} < Sprite_Y1_Coordinate_i) begin
				Sprite_Line_Hit = 1'b1;
				SpriteLineNumber = SpriteLineNumber_Temp;
				SPRITE_Addy_Plus_Sprite_Line[21:0] = {SPRITE_Addy_i[21:2], 2'b00} + (SpriteLineNumber_Temp << 3'd5);	// Multiply the Line Number by 32
			end
			else begin
				Sprite_Line_Hit = 1'b0;
				SpriteLineNumber = 5'b0_0000;
				SPRITE_Addy_Plus_Sprite_Line[21:0] = {SPRITE_Addy_i[21:2], 2'b00};
			end			
	end
	else begin
		if ((Sprite_Y0_Coordinate_i >= VY0_i ) && (Sprite_Y1_Coordinate_i < SY1_i )) begin
			if (({4'b0000,VisibleLineCounter200Mhz} >= Sprite_Y0_Coordinate_i) && ({4'b0000,VisibleLineCounter200Mhz} < Sprite_Y1_Coordinate_i)) begin			
				Sprite_Line_Hit = 1'b1;
				SpriteLineNumber = SpriteLineNumber_Temp;
				SPRITE_Addy_Plus_Sprite_Line[21:0] = {SPRITE_Addy_i[21:2], 2'b00} + (SpriteLineNumber_Temp << 3'd5);	// Multiply the Line Number by 32
			end
			else begin
				Sprite_Line_Hit = 1'b0;
				SpriteLineNumber = 5'b0_0000;
				SPRITE_Addy_Plus_Sprite_Line[21:0] = {SPRITE_Addy_i[21:2], 2'b00};
			end
		end
	end
end



reg	[5:0]			Sprite_Active_Reg;	// Lets Start with 64 Sprites


assign SPRITE_Active_Channel_o = Sprite_Active_Reg;


wire	[31:0]	BM_Line_Ptr;
wire	[15:0]	BM_Packet_Ptr;

reg	[31:0]		State_Machine;


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
					SP_No_Attr		= 3'b000;


localparam	
	IDLE 							= 32'b0000_0000_0000_0000_0000_0000_0000_0000,
	// Video Information Collect
	VID_LINE_WAIT0				= 32'b0000_0000_0000_0000_0000_0000_0000_0001,
	VID_LINE_WAIT1 			= 32'b0000_0000_0000_0000_0000_0000_0000_0010,
	VID_LINE_WAIT2 			= 32'b0000_0000_0000_0000_0000_0000_0000_0100,
	UNUSED_STATE				= 32'b0000_0000_0000_0000_0000_0000_0000_1000,
	
	// GET BM and/or Tile Info
	VID_FETCH_BM_ST0 			= 32'b0000_0000_0000_0000_0000_0000_0001_0000,		// Send the Command to Get Line for BitMap0
	VID_FETCH_BM_ST1 			= 32'b0000_0000_0000_0000_0000_0000_0010_0000,		// Send the Command to Get Line for BitMap1
	VID_FETCH_BM_ST2 			= 32'b0000_0000_0000_0000_0000_0000_0100_0000,		// Send the Command to Get the Collision Plane Info
	VID_FETCH_BM_ST3 			= 32'b0000_0000_0000_0000_0000_0000_1000_0000,		// We are done here, where to now
	// This is where the Command are sent to Get the Tile Map Information
	VID_FETCH_TILEMAP_ST0 	= 32'b0000_0000_0000_0000_0000_0001_0000_0000,		// Send the Command to Get the Data for Line for Map0
	VID_FETCH_TILEMAP_ST1 	= 32'b0000_0000_0000_0000_0000_0010_0000_0000,
	VID_FETCH_TILEMAP_ST2 	= 32'b0000_0000_0000_0000_0000_0100_0000_0000,
	VID_FETCH_TILEMAP_ST3 	= 32'b0000_0000_0000_0000_0000_1000_0000_0000,
	// This is where the command are sent to collect the Tiles Data
	VID_FETCH_TILEDATA_ST0	= 32'b0000_0000_0000_0000_0001_0000_0000_0000,		//
	VID_FETCH_TILEDATA_ST1	= 32'b0000_0000_0000_0000_0010_0000_0000_0000,		//
	VID_FETCH_TILEDATA_ST2	= 32'b0000_0000_0000_0000_0100_0000_0000_0000,		//
	VID_FETCH_TILEDATA_ST3	= 32'b0000_0000_0000_0000_1000_0000_0000_0000,		//
	// SCAN Sprites 
	VID_FETCH_SPRITE0 		= 32'b0000_0000_0000_0001_0000_0000_0000_0000,
	VID_FETCH_SPRITE1 		= 32'b0000_0000_0000_0010_0000_0000_0000_0000,
	VID_FETCH_SPRITE2 		= 32'b0000_0000_0000_0100_0000_0000_0000_0000,
	VID_FETCH_SPRITE3 		= 32'b0000_0000_0000_1000_0000_0000_0000_0000,
	VID_FETCH_SPRITE4 		= 32'b0000_0000_0001_0000_0000_0000_0000_0000,
	// This is where Data from the CPU written to the VRAM which is mostly the VBlanking and the remainder of the unused Videoline
	WRITE_DATA2MEM_ST0 		= 32'b0000_0000_0010_0000_0000_0000_0000_0000,
	WRITE_DATA2MEM_ST1 		= 32'b0000_0000_0100_0000_0000_0000_0000_0000,
	WRITE_DATA2MEM_ST2 		= 32'b0000_0000_1000_0000_0000_0000_0000_0000,
	WRITE_DATA2MEM_ST3 		= 32'b0000_0001_0000_0000_0000_0000_0000_0000,
	// This is where the command are sent to Read Data from VRAM and Returned to the CPU
	READ_DATA2CPU_ST0 		= 32'b0000_0010_0000_0000_0000_0000_0000_0000,
	READ_DATA2CPU_ST1 		= 32'b0000_0100_0000_0000_0000_0000_0000_0000,
	READ_DATA2CPU_ST2 		= 32'b0000_1000_0000_0000_0000_0000_0000_0000,
	READ_DATA2CPU_ST3 		= 32'b0001_0000_0000_0000_0000_0000_0000_0000,
	// This is Where the COmmands to DMA stuff will be created
	DMA_DATA_ST0		 		= 32'b0010_0000_0000_0000_0000_0000_0000_0000,
	DMA_DATA_ST1 				= 32'b0100_0000_0000_0000_0000_0000_0000_0000,
	
	END_PROCESS					= 32'b1000_0000_0000_0000_0000_0000_0000_0000;
	
	
						
						
always @ (posedge EngineClk200Mhz_i )	
begin
	if ( VideoRst_i ) begin
	
	end
	else begin
		case ( State_Machine )
	
		IDLE: begin 
			if ((VideoPixelCounter200Mhz[12:1] == 12'b0000_0000_0000) & LineValid_200Mhz ) begin	// This is when we go from 
				State_Machine <= VID_LINE_WAIT0;
			end
		
		end
		
		VID_LINE_WAIT0: begin 
			State_Machine <= VID_LINE_WAIT1;
		end
		
		VID_LINE_WAIT1: begin 
			State_Machine <= VID_LINE_WAIT2;		
		end

		VID_LINE_WAIT2: begin 
			if (Mstr_Ctrl_Bitmap_Enable_i) begin
					if (BM0_Layer_Enable_i)
						State_Machine <= VID_FETCH_BM_ST0;	// Go Through Each Sprite Entry and begin Fetching the Data if needs be
				else begin
					if (BM1_Layer_Enable_i)
							State_Machine <= VID_FETCH_BM_ST1;	// Go Through Each Sprite Entry and begin Fetching the Data if needs be
					else
							State_Machine <= VID_FETCH_BM_ST2;	// Go Through Each Sprite Entry and begin Fetching the Data if needs be					
				end
			end
			else 
				State_Machine <= IDLE;	// Go Through Each Sprite Entry and begin Fetching the Data if needs be
		end

		UNUSED_STATE: begin
		
		end
// The Fetch of the Data for the BM and Tiles with be done in Packets

		// Fetch Data for Top Bitmap
		VID_FETCH_BM_ST0: begin 
			VGE_Command_o[21:0]			<= BM0_MapAddy_i[21:0] + BM_Line_Ptr[21:0]; // Set the Address
			VGE_Command_o[31:22] 		<= BM_Line_Sizes;		// Go fetch the Entire Line
			VGE_Command_o[32]  			<= Mode_Read;					// Read = 0, Write = 1
			VGE_Command_o[35:33] 		<= Mode_Bitmap;
			
			VGE_Command_Tag_o[9:0]		<= 10'b0_0000_0000;		// Set the Tag for Read = 0, Write = 1
			VGE_Command_Tag_o[12:10]	<= 3'b000;
			VGE_Command_Tag_o[13:11] 	<= BM0_Layer_Lut_i;
			VGE_Command_Tag_o[29:14] 	<= {11'h000, BM0_X_Offset_i};
			VGE_Command_Tag_o[32:30]   <= BM_Attr_BM0;			// Attritube to the Mode 
			VGE_Command_Tag_o[35:33] 	<= Mode_Bitmap;			// Mode
		
			VGE_Command_Write_o 			<= 1'b1;
			VGE_Command_Tag_Write_o 	<= 1'b1;
			if ( BM1_Layer_Enable_i )
				State_Machine <= VID_FETCH_BM_ST1;
			else 
				State_Machine <= VID_FETCH_BM_ST3;	
		end
		
		// Fetch Data for Bottom BitMap
		VID_FETCH_BM_ST1: begin
			VGE_Command_o[21:0]			<= BM1_MapAddy_i[21:0] + BM_Line_Ptr[21:0]; // Set the Address
			VGE_Command_o[31:22] 		<= BM_Line_Sizes;		// Place the command to fetch the entire Line
			VGE_Command_o[32]          <= Mode_Read;
			VGE_Command_o[35:33] 		<= Mode_Bitmap;		

			VGE_Command_Tag_o[9:0]		<= 10'b0_0000_0000;
			VGE_Command_Tag_o[12:10]	<= 3'b000;
			VGE_Command_Tag_o[13:11] 	<= BM1_Layer_Lut_i;
			VGE_Command_Tag_o[29:14] 	<= {11'h000, BM1_X_Offset_i};
			VGE_Command_Tag_o[32:30]   <= BM_Attr_BM1;		// 000 - Channel 0, 001 - Channel 1
			VGE_Command_Tag_o[35:33] 	<= Mode_Bitmap;		// 000 - Bitmap, 001 - Sprite, 010 - TileMap, 011 - TileData, ... 111 - Collision
			
			VGE_Command_Write_o 			<= 1'b1;
			VGE_Command_Tag_Write_o 	<= 1'b1;
			State_Machine <= VID_FETCH_BM_ST3;		
		end


		VID_FETCH_BM_ST2: begin
			State_Machine <= VID_FETCH_BM_ST3;
		end


		VID_FETCH_BM_ST3: begin
			VGE_Command_Write_o 			<= 1'b0;
			VGE_Command_Tag_Write_o 	<= 1'b0;
			if (Mstr_Ctrl_TileMap_Enable_i) begin
				State_Machine <= VID_FETCH_TILEMAP_ST0;
			end
			else begin
				State_Machine <= VID_FETCH_TILEDATA_ST3;			
			end
		end

		// States that are about collection the MAP Information
		VID_FETCH_TILEMAP_ST0: begin 
				State_Machine <= VID_FETCH_TILEMAP_ST1;		
		end
		
		VID_FETCH_TILEMAP_ST1: begin 
				State_Machine <= VID_FETCH_TILEMAP_ST2;		
		end
		
		VID_FETCH_TILEMAP_ST2: begin 
				State_Machine <= VID_FETCH_TILEMAP_ST3;		
		end
		
		VID_FETCH_TILEMAP_ST3: begin 
				State_Machine <= VID_FETCH_TILEDATA_ST0;		
		end

		// States that are about collection of the Data Information for each tile
		VID_FETCH_TILEDATA_ST0: begin 
				State_Machine <= VID_FETCH_TILEDATA_ST1;		
		end
		
      VID_FETCH_TILEDATA_ST1: begin 
				State_Machine <= VID_FETCH_TILEDATA_ST2;		
		end
      
		VID_FETCH_TILEDATA_ST2: begin 
				State_Machine <= VID_FETCH_TILEDATA_ST3;		
		end
      
		VID_FETCH_TILEDATA_ST3: begin 
			if (Mstr_Ctrl_Sprite_Enable_i) begin
				Sprite_Active_Reg <= 6'h3F;	// Start the Scan 63;
				State_Machine <= VID_FETCH_SPRITE0;	// Go Through Each Sprite Entry and begin Fetching the Data if needs be
			end
			else 
				State_Machine <= VID_FETCH_SPRITE4;	// Go Through Each Sprite Entry and begin Fetching the Data if needs be	
		end

		// Sprites Scan	Latency 1 Clock
		//5ns
		VID_FETCH_SPRITE0: begin 
				State_Machine <= VID_FETCH_SPRITE1;	// Go Through Each Sprite Entry and begin Fetching the Data if needs be
		end
		
		// Data From Register is Valid Here
		//5ns		
		VID_FETCH_SPRITE1: begin 
			if (SPRITE_Enabled_i && Sprite_Line_Hit) begin
				VGE_Command_o[21:0]			<= SPRITE_Addy_Plus_Sprite_Line;	// Set the Address
				VGE_Command_o[31:22] 		<= 10'h0020;			// Set the 32 Size of the Sprite
				VGE_Command_o[32]  			<= Mode_Read;			// 0 - Read / 1 - Write
				VGE_Command_o[35:33] 		<= Mode_Sprites;		// 000 - Bitmap, 001 - Sprite, 010 - TileMap, 011 - TileData, ... 111 - Collision
				
				VGE_Command_Tag_o[7:0]		<= {2'b00, Sprite_Active_Reg};	// Let's do 64 For now - Max During a Line
				VGE_Command_Tag_o[10:8]		<= Sprite_Priority_i; // 000 - 8 Level
				VGE_Command_Tag_o[13:11] 	<= Sprite_LUT_i;		 // 000 - 8 LUT
				VGE_Command_Tag_o[29:14] 	<= Sprite_X0_Coordinate_i;
				VGE_Command_Tag_o[32:30]   <= SP_No_Attr;
				VGE_Command_Tag_o[35:33] 	<= Mode_Sprites;		// 000 - Bitmap, 001 - Sprite, 010 - TileMap, 011 - TileData, ... 111 - Collision
				
				VGE_Command_Write_o 			<= 1'b1;
				VGE_Command_Tag_Write_o 	<= 1'b1;
			end
			State_Machine <= VID_FETCH_SPRITE2;
		end
		
		VID_FETCH_SPRITE2: begin 
			VGE_Command_Write_o 			<= 1'b0;
			VGE_Command_Tag_Write_o 	<= 1'b0;
			if (Sprite_Active_Reg) begin
				Sprite_Active_Reg <= Sprite_Active_Reg  - 6'h01;
				State_Machine <= VID_FETCH_SPRITE0;				
			end
			else begin
				State_Machine <= VID_FETCH_SPRITE3;			
			end					
		end

		VID_FETCH_SPRITE3: begin 
			if (CPU_Transfer_i) begin
				State_Machine <= VID_FETCH_SPRITE4;
			end
			else begin
				State_Machine <= IDLE;	// Go Through Each Sprite Entry and begin Fetching the Data if needs be		
			end
		end
		
		VID_FETCH_SPRITE4: begin 
			if (CPU_Transfer_Direction_i) begin
				State_Machine <= WRITE_DATA2MEM_ST0;
			end
			else begin
				State_Machine <= READ_DATA2CPU_ST0;			
			end
				
		end
	
		WRITE_DATA2MEM_ST0: begin
			State_Machine <= WRITE_DATA2MEM_ST1;		
		end
		
		WRITE_DATA2MEM_ST1: begin
			State_Machine <= WRITE_DATA2MEM_ST2;		
		end
		
		WRITE_DATA2MEM_ST2: begin
			State_Machine <= WRITE_DATA2MEM_ST3;
		end
		
		WRITE_DATA2MEM_ST3: begin
			State_Machine <= IDLE;
		end

		READ_DATA2CPU_ST0: begin
			State_Machine <= READ_DATA2CPU_ST1;
		end
		
		READ_DATA2CPU_ST1: begin
			State_Machine <= READ_DATA2CPU_ST2;
		end

		READ_DATA2CPU_ST2: begin
			State_Machine <= READ_DATA2CPU_ST3;
		end
		
		READ_DATA2CPU_ST3: begin
			State_Machine <= IDLE;
		end
		
		DMA_DATA_ST0: begin
		
		end
		
		DMA_DATA_ST1: begin
		
		end
		
		END_PROCESS: begin
		
		
		end
		
		default: begin
				State_Machine <= IDLE;		
		end
	
	
		endcase 
	end
end

reg [9:0]	BM_Line_Sizes;
reg [9:0]	BM_Packet_Number;

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

TextAddy_Mult MULT8x8(
	.dataa( BM_Packet_Number ),
	.datab( BM_Line_Sizes ),
	.result( BM_Packet_Ptr )
);

DMA_MULT_BLK MULT16x16(
	.dataa( VisibleLineCounter200Mhz ),
	.datab( SX1_i ),
	.result( BM_Line_Ptr )
);

//always @ (*)
//begin


//end


// VGE_CMD
// VGE_CMD [21:00] Address - Pointer from Were on 4 Bytes Boundary. [21:0]	// From 00:0000..3F:0000
// VGE_CMD [31:22] Count (in Bytes) - How Many Words I need to Fetch from Memory [9:0]

// GENERAL INFO
// VGE_CMD_TAG [01:00] Mode - 00: Memory Read, 01: Memory Write, 10:DMA Read, 11:DMA Write 
// VGE_CMD_TAG [03:02] FETCH NODE 00: BM, 01: TILE, 10: SPRITE, 11: COLLISION 	// Tags to Be Attached with Returning Data

// Sprite TAG
// VGE_CMD_TAG [09:04] SPRITE NUMBER [5:0] 6 Bits								   // Tags to Be Attached with Returning Data
// VGE_CMD_TAG [12:10] GRAPHIC PRIORITY [2:0] 3 Bits									// Tags to Be Attached with Returning Data		
// VGE_CMD_TAG [15:13] GRAPHIC LUT [2:0] 3 Bits										// Tags to Be Attached with Returning Data
// VGE_CMD_TAG [31:16] GRAPHIC X Position [15:0] (Signed or not) (in Byte)
// BM TAG

// 
/*
input		wire				BM0_Layer_Enable_i,
input		wire	[2:0] 	BM0_LUT_i,
input		wire	[23:0]	BM0_START_ADDY_i,
input		wire	[4:0]		BM0_X_Offset_i, // +/- 32
input		wire	[4:0]		BM0_Y_Offset_i, // +/- 32

input		wire				BM1_Layer_Enable_i,
input		wire	[2:0]		BM1_LUT_i,
input		wire	[23:0]	BM1_START_ADDY_i,
input		wire	[4:0]		BM1_X_Offset_i, // +/- 32
input		wire	[4:0]		BM1_Y_Offset_i, // +/- 32	

*/

// 640 / 32 = 20 : 704 / 32 = 22
// 800 / 40 = 20 : 864 / 32 = 27 
// 320 / 16 = 20 : 384 / 16 = 24
// 400 / 20 = 20 : 464 / 16 = 29
/*
wire [127:0] ChipScope;
wire			Trigger;
assign Trigger = (SPRITE_Enabled_i & Sprite_Line_Hit);

//assign Trigger = SOF_Sync[1:0] == 2'b01 ? 1'b1: 1'b0;
//assign Trigger = LineValid_200Mhz;

assign ChipScope[10:0] = TotalLineCounter200Mhz;
assign ChipScope[22:11] = VisibleLineCounter200Mhz ;
assign ChipScope[35:23] = VideoPixelCounter200Mhz;
assign ChipScope[41:36] = State_Machine;
assign ChipScope[42] 	= Sprite_Line_Hit;
assign ChipScope[48:43] = SpriteLineNumber;

assign ChipScope[49] = HBlanking_Sync1;
assign ChipScope[50] = HBlanking_Sync0;
assign ChipScope[51] = 1'b0;
assign ChipScope[52] = SPRITE_Enabled_i;
assign ChipScope[58:53] = Sprite_Active_Reg;
assign ChipScope[59] = VGE_Command_Write_o;
assign ChipScope[60] = VGE_Command_Tag_Write_o; 
assign ChipScope[61] = LineValid_200Mhz;
assign ChipScope[63:62] = 0;

assign ChipScope[79:64] = Sprite_Y0_Coordinate_i ;
assign ChipScope[95:80] = Sprite_Y1_Coordinate_i;

assign ChipScope[127:96] = VGE_Command_Tag_o[31:0];

ChipScope	ChipScope_inst (
	.acq_clk ( EngineClk200Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);
*/



endmodule


