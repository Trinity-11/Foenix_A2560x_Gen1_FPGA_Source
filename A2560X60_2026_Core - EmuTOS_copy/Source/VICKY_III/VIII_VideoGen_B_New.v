
`timescale 1ns/1ns

module VIII_VideoGen_B_New (	
input		wire				Reset_VideoClk_Full_Resolution,
input		wire				VideoClk_i,
input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,

input				[1:0]		Mstr_Ctrl_Video_Mode_i,
input							Mstr_Ctrl_Doubling_Pixel_i,

input		wire				TLayer0Mode8_16_i,
input		wire				TLayer1Mode8_16_i,
input		wire				TLayer2Mode8_16_i,
input		wire				TLayer3Mode8_16_i,

output 		reg					HSYNC_o,					//HD
output 		reg					VSYNC_o,					//VD

output		reg					HSync_Pol_o,
output		reg					VSync_Pol_o,

output 		wire	[11:0]  	HPixelCount_o,
output 		wire  	[11:0]		HLineCount_o,

output		wire				HBlanking_Latency_o,
output		wire				HBlanking_Latency_VGE_o,
output		wire				HBlanking_o,
output		wire				VBlanking_o,
output		wire				VGE_Engine_VBlanking_1L_o,
output		wire				VGE_Engine_VBlanking_2L_o,
output 		wire				SOF_o,

output		wire	[15:0]		HBLANK_START_o,
output		wire	[15:0]		HBLANK_STOP_o,

output		wire				Time_Rd_Wr_Access_100Mhz_o,		// 100Mhz Clock Realm
output		wire				Time_Rd_Only_Access_100Mhz_o,	// 100Mhz Clock Realm
output		wire				Time_Trf_Pixels_2_Pixel_200Mhz_o,	// 200Mhz Clock
output		wire				Time_Erase_Pixels_Line_100Mhz_o,
output		wire				Time_Erase_Pixels_Line_200Mhz_o,
output		wire				Time_2_Display_Line_VideoClk_o,
output		wire	[1:0]		Time_2_Charge_TileMap_L0_Lines_o,
output		wire	[1:0]		Time_2_Charge_TileMap_L1_Lines_o,
output		wire	[1:0]		Time_2_Charge_TileMap_L2_Lines_o,
output		wire	[1:0]		Time_2_Charge_TileMap_L3_Lines_o
);

reg 	[15:0]		HSYNC_START;
reg 	[15:0]		HSYNC_STOP;
reg 	[15:0]		HBLANK_START; 		//1
reg 	[15:0]		HBLANK_STOP;			//256
//reg 	[15:0]		VTOTAL; 				//628
reg		[23:0]		VSYNC_START;			//1
reg		[23:0]		VSYNC_STOP;				//5
reg		[23:0]		VBLANK_START;
reg		[23:0]		VBLANK_STOP;
reg     [23:0]  	VBLANK_2Lines;

reg					DENA_VERTICAL;
reg 				DENA_HORIZONTAL;
reg 				DENA_HORIZONTAL_READ_LATENCY;
reg 				DENA_HORIZONTAL_READ_VGE_LAT;
reg		[23:0]		PixelCounter;
reg		[15:0]		HBLANK_START_Dly;
reg		[15:0]		HBLANK_START_VGE_Dly;
reg					DENA_VERTICAL_1LINEPRIOT;
reg					DENA_VERTICAL_2LINEPRIOT;
reg		[11:0]		HPixelCount_Buf0;
reg		[11:0]		HPixelCount_Buf1;
reg		[11:0]		HPixelLocal;
reg		[11:0]		HLineCount_Buf0;
reg		[11:0]		HLineCount_Buf1;
reg		[11:0]		HLineLocal;
reg		[15:0]		HPixelCount;
reg		[15:0]		HLineCount;

reg 	[2:0]		Mstr_Ctrl_Video_Mode_ReSync;
reg 	[2:0]		Mstr_Ctrl_Video_Mode_ReSync_Bit1;
reg 	[2:0] 		Rst_rstn_reg;

wire reset_mode;



assign HBLANK_START_o = HBLANK_START;
assign HBLANK_STOP_o = HBLANK_STOP;

always @ ( posedge VideoClk_i ) begin
	if ( Reset_VideoClk_Full_Resolution ) begin 
			// 1280 x 960 @60Mhz (640x480 / 320x240)(4:3)
			//96  |---96HBL--| 112HS |---312HBL---| Active Video 1280 | Blanking total:520
			// Line Total 1800
			// Horizontal
			HSYNC_START 	<= 16'd95;
			HSYNC_STOP 		<= 16'd207;
			HBLANK_START	<= 16'd519;
			HBLANK_STOP	 	<= 16'd1799;
			HSync_Pol_o     <= 1'b1;	// Positive
			// Vertical 
			// [1 VBLANK][3 VSYNC][36 VBLANK][1000 Lines]
			// VTotal = 1000
			VSYNC_START		<= 24'd1799;
			VSYNC_STOP		<= 24'd7199;
			VBLANK_START	<= 24'd71999;	//40 Lines of Blanking
			VBLANK_STOP		<= 24'd1799999;
			VSync_Pol_o     <= 1'b1; // Positive
	end
	else begin 
		if ( SOF_o ) begin 
			if ( Mstr_Ctrl_Video_Mode_i[0] ) begin
				// 1280 x 1024 @60Mhz (640x512 / 320x256) (5:4)
				//  |---48HBL--| 112HS |---248HBL---| Active Video 1280 | Blanking total:520
				// Line Total 1688
				// Total HBlank = 1688 - 408 = 1280
				// Horizontal
				HSYNC_START 	<= 16'd47;		// Start 
				HSYNC_STOP 		<= 16'd159;		// Stp
				HBLANK_START	<= 16'd407;
				HBLANK_STOP	 	<= 16'd1687;
				HSync_Pol_o     <= 1'b1;	// Positive
				// Vertical 
				// [1 VBLANK][3 VSYNC][38 VBLANK][1066 Lines]
				// VTotal = 1030 (1066 - 1024 = 6)
	//			VBLANK_2Lines   = 24'd67519;    // 40 Lines
				VSYNC_START		<= 24'd1687;
				VSYNC_STOP		<= 24'd6751;
				VBLANK_START	<= 24'd70895;	// 42 Lines of Blankings
				VBLANK_STOP		<= 24'd1799407;
				VSync_Pol_o	    <= 1'b1;
			end
			else begin
				// 1280 x 960 @60Mhz (640x480 / 320x240)(4:3)
				//96  |---96HBL--| 112HS |---312HBL---| Active Video 1280 | Blanking total:520
				// Line Total 1800
				// Horizontal
				HSYNC_START 	<= 16'd95;
				HSYNC_STOP 		<= 16'd207;
				HBLANK_START	<= 16'd519;
				HBLANK_STOP	 	<= 16'd1799;
				HSync_Pol_o     <= 1'b1;	// Positive
				// Vertical 
				// [1 VBLANK][3 VSYNC][36 VBLANK][1000 Lines]
				// VTotal = 1000
	//			VBLANK_2Lines   = 24'd57599;	//4 Lines before beginning
				VSYNC_START	 	<= 24'd1799;
				VSYNC_STOP	 	<= 24'd7199;
				VBLANK_START 	<= 24'd71999;	//40 Lines of Blanking
				VBLANK_STOP	 	<= 24'd1799999;
				VSync_Pol_o     <= 1'b1; // Positive
			end
		end 
	end
end 

// 1280 x 960
//96  |---96HBL--| 112HS |---312HBL---| Active Video 1280 | Blanking total:520
//208 |------208Pixel----|
//520  (1280x960@60hz)
//1800 (1280x960@60hz)
wire [15:0] HBlankPlusOne = HBLANK_STOP + 16'd1;
wire [23:0] OneLineCompare = ((( VBLANK_START + 24'd1 ) - {8'b0000_0000,HBlankPlusOne}) - 24'd1);
wire [23:0] TwoLineCompare = ((( VBLANK_START + 24'd1 ) - {7'b0000_000, HBlankPlusOne, 1'b0}) - 24'd1);

assign 	VBlanking_o 				= DENA_VERTICAL;
assign	HBlanking_o 				= DENA_HORIZONTAL;
assign 	HBlanking_Latency_o 		= DENA_HORIZONTAL_READ_LATENCY;
assign  HBlanking_Latency_VGE_o 	= DENA_HORIZONTAL_READ_VGE_LAT;
assign	VGE_Engine_VBlanking_1L_o 	= DENA_VERTICAL_1LINEPRIOT;
assign	VGE_Engine_VBlanking_2L_o 	= DENA_VERTICAL_2LINEPRIOT;
assign 	reset_mode = ( Mstr_Ctrl_Video_Mode_ReSync[1:0] == 2'b10 ) || ( Mstr_Ctrl_Video_Mode_ReSync[1:0] == 2'b01 );
assign	HPixelCount_o 	= HPixelCount[11:0];
assign 	HLineCount_o 	= HLineCount[11:0];



always @ (posedge VideoClk_i)
begin
	if (Reset_VideoClk_Full_Resolution) begin
		Mstr_Ctrl_Video_Mode_ReSync[2:0] <= 3'b000;
		Mstr_Ctrl_Video_Mode_ReSync_Bit1[2:0] <= 3'b000;
	end
	else begin
		// Resync the Video Mode Register Resync to 108Mhz Dot Clock
		Mstr_Ctrl_Video_Mode_ReSync[0] <= Mstr_Ctrl_Video_Mode_i[0];
		Mstr_Ctrl_Video_Mode_ReSync[1] <= Mstr_Ctrl_Video_Mode_ReSync[0];
		if (  Mstr_Ctrl_Video_Mode_ReSync[1] == Mstr_Ctrl_Video_Mode_ReSync[0] )
			Mstr_Ctrl_Video_Mode_ReSync[2] <= Mstr_Ctrl_Video_Mode_ReSync[1];
		// Doubling Resync to 108Mhz Dot Clock
		Mstr_Ctrl_Video_Mode_ReSync_Bit1[0] <= Mstr_Ctrl_Doubling_Pixel_i;
		Mstr_Ctrl_Video_Mode_ReSync_Bit1[1] <= Mstr_Ctrl_Video_Mode_ReSync_Bit1[0];
		if ( Mstr_Ctrl_Video_Mode_ReSync_Bit1[1] == Mstr_Ctrl_Video_Mode_ReSync_Bit1[0] )
			Mstr_Ctrl_Video_Mode_ReSync_Bit1[2] <= Mstr_Ctrl_Video_Mode_ReSync_Bit1[1];
	end
end

wire Mstr_Ctrl_Video_Mode = Mstr_Ctrl_Video_Mode_ReSync[2];
wire Mstr_Ctrl_Doubling_Pixel = Mstr_Ctrl_Video_Mode_ReSync_Bit1[2];

// Delayed HBlank
always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	
		HBLANK_START_Dly <= 16'h0000;
	end
	else begin
		HBLANK_START_Dly <= HBLANK_START - 2'd2;
	end
end

// Delayed HBlank
always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		HBLANK_START_VGE_Dly <= 16'h0000;
	end
	else begin
		if ( Mstr_Ctrl_Video_Mode )
			HBLANK_START_VGE_Dly <= HBLANK_START - 16'd8;		// Changed from 8 to 11
		else
			HBLANK_START_VGE_Dly <= HBLANK_START - 16'd5;		// Changed from 5 to 7
	end
end


// HBLANK
always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		HPixelCount						<= 16'h0000;
		HLineCount 						<= 16'h0000;
	end
	else begin
	
		// Count from 0 to 1055
		if (HPixelCount < HBLANK_STOP) begin
			HPixelCount <= HPixelCount + 16'h001;
		end
		else begin
			HLineCount  <= HLineCount + 16'h001;
			HPixelCount <= 16'h000;
		end
	
		if (PixelCounter == VBLANK_STOP)
			HLineCount <= 16'h000;
	end	
end


// HBLANK
always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		DENA_HORIZONTAL					<= 1'b0;	
		DENA_HORIZONTAL_READ_LATENCY	<= 1'b0;
		DENA_HORIZONTAL_READ_VGE_LAT  <= 1'b0;
	end
	else begin
	
		// Count from 0 to 1055
		if (HPixelCount >= HBLANK_STOP) begin
			DENA_HORIZONTAL <= 1'b0;	
			DENA_HORIZONTAL_READ_LATENCY	<= 1'b0;
			DENA_HORIZONTAL_READ_VGE_LAT 	<= 1'b0;
		end

		if (HPixelCount == HBLANK_START)
			DENA_HORIZONTAL <= 1'b1;

		if (HPixelCount == HBLANK_START_Dly)
			DENA_HORIZONTAL_READ_LATENCY <= 1'b1;
			
		if (HPixelCount == HBLANK_START_VGE_Dly)
			DENA_HORIZONTAL_READ_VGE_LAT <= 1'b1;			
	end	
end

// HSYNC
always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	
				HSYNC_o <= 1'b0;
	end
	else begin
		if ((HPixelCount >= HSYNC_START) && (HPixelCount <= HSYNC_STOP))
				HSYNC_o <= 1'b1;
		else
				HSYNC_o <= 1'b0;		
	end
end


reg	[7:0] SOF_PULSE;
assign SOF_o = SOF_PULSE[7];

always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		SOF_PULSE <= 8'h00;
	end
	else
	begin
		SOF_PULSE <= SOF_PULSE << 1'b1;

		if (PixelCounter == VBLANK_STOP)
			SOF_PULSE <= 8'hFF;
	end

end

always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		PixelCounter <= 24'h000000;
	end
	else
	begin
		if (PixelCounter == VBLANK_STOP)	begin								
			PixelCounter <= 24'h000000;
			end
		else begin
			PixelCounter <= PixelCounter + 1'b1;
		end
	end
end

// Pixel Counter
//PixelCounter	PixelCounter_inst (
//	.aclr ( rst || ( Mstr_Ctrl_Video_Mode_ReSync[1:0] == 2'b10 ) || ( Mstr_Ctrl_Video_Mode_ReSync[1:0] == 2'b01 ) ),
//	.clock ( VideoClk_i ),
//	.sclr ( PixelCounter == VBLANK_STOP ),
//	.q ( PixelCounter )
//	);

// VSYNC Controlled by PixelCounter

always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		 VSYNC_o <= 1'b0;
	end
	else begin
		if (PixelCounter == VSYNC_START)
			VSYNC_o <= 1'b1;
		else if (PixelCounter == VSYNC_STOP)	// In Pixels Count
			VSYNC_o <= 1'b0;
	end
end

// 28 Line of VBlanking in 800 x 600 = 28 x 1056  = 29568 - 1056 =  28512 - 1 = 28511
// 45 Line of VBlanking in 640 x 480 = 45 x 800   = 36000 - 800 =  35200 - 1 = 35199


//OneLineCompare
//TwoLineCompare


always @ (posedge VideoClk_i)
begin				// VBlanking in Progressive Mode
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		DENA_VERTICAL_1LINEPRIOT <= 1'b0;
		DENA_VERTICAL_2LINEPRIOT <= 1'b0;
		DENA_VERTICAL <= 1'b0;
	end
	else begin
		if (PixelCounter == VBLANK_START)
			DENA_VERTICAL <= 1'b1;

		if (PixelCounter == OneLineCompare)
			DENA_VERTICAL_1LINEPRIOT <= 1'b1;

		if (PixelCounter == TwoLineCompare)
			DENA_VERTICAL_2LINEPRIOT <= 1'b1;			
		
		if (PixelCounter == VBLANK_STOP) begin
			DENA_VERTICAL <= 1'b0;
			DENA_VERTICAL_1LINEPRIOT <= 1'b0;
			DENA_VERTICAL_2LINEPRIOT <= 1'b0;
		end
	end
end			


////
// SEQUENCER
////

reg	[2:0]		Time_RD_WR_Strobe_RESYNC;
reg	[2:0]		Time_RD_Only_Strobe_RESYNC;
reg	[2:0]		Time_Line_2_LUT_2_FinalLine_RESYNC;
reg	[2:0]		Time_Line_Erasure_RESYNC;
reg	[2:0]		Time_Line_Erasure_RESYNC200;


reg	[1:0]		Charge_TL0_Tile_Lines_RESYNC[0:2];
reg	[1:0]		Charge_TL1_Tile_Lines_RESYNC[0:2];
reg	[1:0]		Charge_TL2_Tile_Lines_RESYNC[0:2];
reg	[1:0]		Charge_TL3_Tile_Lines_RESYNC[0:2];


always @ (posedge EngineClk100Mhz_i) 
begin
	Time_RD_WR_Strobe_RESYNC[0] 	<= Time_RD_WR_Strobe;
	Time_RD_WR_Strobe_RESYNC[1] 	<= Time_RD_WR_Strobe_RESYNC[0];
	if ( Time_RD_WR_Strobe_RESYNC[1] == Time_RD_WR_Strobe_RESYNC[0] )
		Time_RD_WR_Strobe_RESYNC[2] <= Time_RD_WR_Strobe_RESYNC[1];
	
	Time_RD_Only_Strobe_RESYNC[0] <= Time_RD_Only_Strobe[3];
	Time_RD_Only_Strobe_RESYNC[1] <= Time_RD_Only_Strobe_RESYNC[0];
	if ( Time_RD_Only_Strobe_RESYNC[1] == Time_RD_Only_Strobe_RESYNC[0] )
		Time_RD_Only_Strobe_RESYNC[2] <= Time_RD_Only_Strobe_RESYNC[1];

	Time_Line_Erasure_RESYNC[0] 	<= Time_Line_Erasure[3];
	Time_Line_Erasure_RESYNC[1] 	<= Time_Line_Erasure_RESYNC[0];
	if (Time_Line_Erasure_RESYNC[1] == Time_Line_Erasure_RESYNC[0] )
		Time_Line_Erasure_RESYNC[2] <= Time_Line_Erasure_RESYNC[1];
	
	// Tile Layer 0
	Charge_TL0_Tile_Lines_RESYNC[0][1:0]	<= Charge_TL0_Tile_Lines[1:0];
	Charge_TL0_Tile_Lines_RESYNC[1][1:0] <=	Charge_TL0_Tile_Lines_RESYNC[0][1:0];
	if ( 	Charge_TL0_Tile_Lines_RESYNC[1][1:0] ==	Charge_TL0_Tile_Lines_RESYNC[0][1:0] )
		Charge_TL0_Tile_Lines_RESYNC[2][1:0] <=	Charge_TL0_Tile_Lines_RESYNC[1][1:0];
	// Tile Layer 1
	Charge_TL1_Tile_Lines_RESYNC[0][1:0]	<= Charge_TL1_Tile_Lines[1:0];
	Charge_TL1_Tile_Lines_RESYNC[1][1:0] <=	Charge_TL1_Tile_Lines_RESYNC[0][1:0];
	if ( 	Charge_TL1_Tile_Lines_RESYNC[1][1:0] ==	Charge_TL1_Tile_Lines_RESYNC[0][1:0] )
		Charge_TL1_Tile_Lines_RESYNC[2][1:0] <=	Charge_TL1_Tile_Lines_RESYNC[1][1:0];
	// Tile Layer 2
	Charge_TL2_Tile_Lines_RESYNC[0][1:0]	<= Charge_TL2_Tile_Lines[1:0];
	Charge_TL2_Tile_Lines_RESYNC[1][1:0] <=	Charge_TL2_Tile_Lines_RESYNC[0][1:0];
	if ( 	Charge_TL2_Tile_Lines_RESYNC[1][1:0] ==	Charge_TL2_Tile_Lines_RESYNC[0][1:0] )
		Charge_TL2_Tile_Lines_RESYNC[2][1:0] <=	Charge_TL2_Tile_Lines_RESYNC[1][1:0];
	// Tile Layer 3
	Charge_TL3_Tile_Lines_RESYNC[0][1:0]	<= Charge_TL3_Tile_Lines[1:0];
	Charge_TL3_Tile_Lines_RESYNC[1][1:0] <=	Charge_TL3_Tile_Lines_RESYNC[0][1:0];
	if ( 	Charge_TL3_Tile_Lines_RESYNC[1][1:0] ==	Charge_TL3_Tile_Lines_RESYNC[0][1:0] )
		Charge_TL3_Tile_Lines_RESYNC[2][1:0] <=	Charge_TL3_Tile_Lines_RESYNC[1][1:0];
		
end

assign Time_Rd_Wr_Access_100Mhz_o 		= Time_RD_WR_Strobe_RESYNC[2];
assign Time_Rd_Only_Access_100Mhz_o		= Time_RD_Only_Strobe_RESYNC[2];

assign Time_Erase_Pixels_Line_100Mhz_o	= Time_Line_Erasure_RESYNC[2];

assign Time_2_Charge_TileMap_L0_Lines_o   = Charge_TL0_Tile_Lines_RESYNC[2][1:0];
assign Time_2_Charge_TileMap_L1_Lines_o   = Charge_TL1_Tile_Lines_RESYNC[2][1:0];
assign Time_2_Charge_TileMap_L2_Lines_o   = Charge_TL2_Tile_Lines_RESYNC[2][1:0];
assign Time_2_Charge_TileMap_L3_Lines_o   = Charge_TL3_Tile_Lines_RESYNC[2][1:0];

always @ (posedge EngineClk200Mhz_i) 
begin
	Time_Line_2_LUT_2_FinalLine_RESYNC[0] <=  Time_Line_2_LUT_2_FinalLine[3];
	Time_Line_2_LUT_2_FinalLine_RESYNC[1] <= 	Time_Line_2_LUT_2_FinalLine_RESYNC[0];
	if ( Time_Line_2_LUT_2_FinalLine_RESYNC[1] == Time_Line_2_LUT_2_FinalLine_RESYNC[0] ) 
		Time_Line_2_LUT_2_FinalLine_RESYNC[2] <= Time_Line_2_LUT_2_FinalLine_RESYNC[1];
	
	Time_Line_Erasure_RESYNC200[0] <= Time_Line_Erasure[3];
	Time_Line_Erasure_RESYNC200[1] <= Time_Line_Erasure_RESYNC200[0];
	if (	Time_Line_Erasure_RESYNC200[1] == Time_Line_Erasure_RESYNC200[0] )
		Time_Line_Erasure_RESYNC200[2] <= Time_Line_Erasure_RESYNC200[1];
end

assign Time_Trf_Pixels_2_Pixel_200Mhz_o = Time_Line_2_LUT_2_FinalLine_RESYNC[2];
assign Time_Erase_Pixels_Line_200Mhz_o = Time_Line_Erasure_RESYNC200[2];
assign Time_2_Display_Line_VideoClk_o = Time_Start_Display_Line;

reg 			Time_RD_WR_Strobe;
reg [3:0]	Time_RD_Only_Strobe;
reg [3:0]	Time_Line_2_LUT_2_FinalLine;
reg [3:0]	Time_Line_Erasure;
reg 			Time_Start_Display_Line;

reg [9:0] Visible_Local_Line_Counter;

reg [1:0]	Charge_TL0_Tile_Lines;
reg [1:0]	Charge_TL1_Tile_Lines;
reg [1:0]	Charge_TL2_Tile_Lines;
reg [1:0]	Charge_TL3_Tile_Lines;

reg [2:0]	TLayer0Mode8_16_Sync;
reg [2:0]	TLayer1Mode8_16_Sync;
reg [2:0]	TLayer2Mode8_16_Sync;
reg [2:0]	TLayer3Mode8_16_Sync;

always @ (posedge VideoClk_i) 
begin
	TLayer0Mode8_16_Sync[0] <= TLayer0Mode8_16_i;
	TLayer0Mode8_16_Sync[1] <= TLayer0Mode8_16_Sync[0];
	if ( TLayer0Mode8_16_Sync[1] == TLayer0Mode8_16_Sync[0])
		TLayer0Mode8_16_Sync[2] <= TLayer0Mode8_16_Sync[1];

	TLayer1Mode8_16_Sync[0] <= TLayer1Mode8_16_i;
	TLayer1Mode8_16_Sync[1] <= TLayer1Mode8_16_Sync[0];
	if ( TLayer1Mode8_16_Sync[1] == TLayer1Mode8_16_Sync[0])
		TLayer1Mode8_16_Sync[2] <= TLayer1Mode8_16_Sync[1];

	TLayer2Mode8_16_Sync[0] <= TLayer2Mode8_16_i;
	TLayer2Mode8_16_Sync[1] <= TLayer2Mode8_16_Sync[0];
	if ( TLayer2Mode8_16_Sync[1] == TLayer2Mode8_16_Sync[0])
		TLayer2Mode8_16_Sync[2] <= TLayer2Mode8_16_Sync[1];

	TLayer3Mode8_16_Sync[0] <= TLayer3Mode8_16_i;
	TLayer3Mode8_16_Sync[1] <= TLayer3Mode8_16_Sync[0];
	if ( TLayer3Mode8_16_Sync[1] == TLayer3Mode8_16_Sync[0])
		TLayer3Mode8_16_Sync[2] <= TLayer3Mode8_16_Sync[1];
end

// Video Clock - Clocked
always @ (posedge VideoClk_i) 
begin
	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
		Visible_Local_Line_Counter		<= 10'b00_0000_0000;
	end
	else begin
		if (VGE_Engine_VBlanking_2L_o)  begin
			if (	HPixelCount == {HBLANK_STOP[11:1],1'b0} )
			Visible_Local_Line_Counter <= Visible_Local_Line_Counter + 10'h001;
		end
		else begin
			Visible_Local_Line_Counter		<= 10'b00_0000_0000;
		end
	end
end

wire ConditionHalfSizeTiles;
wire ConditionFullClock;
wire ConditionHalfClock;
reg  TL0Condition2Trigger;
reg  TL1Condition2Trigger;
reg  TL2Condition2Trigger;
reg  TL3Condition2Trigger;

assign ConditionHalfSizeTiles = (Visible_Local_Line_Counter[2:0] == 3'b000); // When using Tiles
assign ConditionFullClock 	= (Visible_Local_Line_Counter[3:0] == 4'b0000);
assign ConditionHalfClock 	= (Visible_Local_Line_Counter[4:0] == 5'b0_0000);
//assign Condition2Trigger 	= Mstr_Ctrl_Video_Mode_ReSync_Bit1[1] ? ConditionHalfClock : ConditionFullClock;

always @ (*) begin
	case ( { TLayer0Mode8_16_Sync[2], Mstr_Ctrl_Doubling_Pixel } )
		2'b00: begin TL0Condition2Trigger = ConditionFullClock; 		end	// 640
		2'b01: begin TL0Condition2Trigger = ConditionHalfClock; 		end	// 320
		2'b10: begin TL0Condition2Trigger = ConditionHalfSizeTiles;     end
		2'b11: begin TL0Condition2Trigger = ConditionFullClock; 		end
	endcase
end
always @ (*) begin
	case ( { TLayer1Mode8_16_Sync[2], Mstr_Ctrl_Doubling_Pixel } )
		2'b00: begin TL1Condition2Trigger = ConditionFullClock; 		end
		2'b01: begin TL1Condition2Trigger = ConditionHalfClock; 		end
		2'b10: begin TL1Condition2Trigger = ConditionHalfSizeTiles; 	end
		2'b11: begin TL1Condition2Trigger = ConditionFullClock; 		end
	endcase
end
always @ (*) begin
	case ( { TLayer2Mode8_16_Sync[2], Mstr_Ctrl_Doubling_Pixel } )
		2'b00: begin TL2Condition2Trigger = ConditionFullClock; 		end
		2'b01: begin TL2Condition2Trigger = ConditionHalfClock; 		end
		2'b10: begin TL2Condition2Trigger = ConditionHalfSizeTiles; 	end
		2'b11: begin TL2Condition2Trigger = ConditionFullClock; 		end
	endcase
end
always @ (*) begin	
	case ( { TLayer3Mode8_16_Sync[2], Mstr_Ctrl_Doubling_Pixel } )
		2'b00: begin TL3Condition2Trigger = ConditionFullClock; 		end
		2'b01: begin TL3Condition2Trigger = ConditionHalfClock; 		end
		2'b10: begin TL3Condition2Trigger = ConditionHalfSizeTiles; 	end
		2'b11: begin TL3Condition2Trigger = ConditionFullClock; 		end
	endcase	
end

// Tile Layer 0
always @ (posedge VideoClk_i) 
begin
	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
				Charge_TL0_Tile_Lines <= 2'b00;	
	end
	else begin
		// Tile Layer 0
		if ( VGE_Engine_VBlanking_2L_o && TL0Condition2Trigger ) begin
			if (HPixelCount < (HBlankPlusOne - 4))
					Charge_TL0_Tile_Lines[0] <= 1'b1;
			else 
					Charge_TL0_Tile_Lines[0] <= 1'b0;
		end
		else
			Charge_TL0_Tile_Lines[0] <= 1'b0;
			
		// Tile Layer 1
		if ( VGE_Engine_VBlanking_2L_o && TL1Condition2Trigger ) begin
			if (HPixelCount < (HBlankPlusOne - 4))
					Charge_TL1_Tile_Lines[0] <= 1'b1;
			else 
					Charge_TL1_Tile_Lines[0] <= 1'b0;
		end
		else
			Charge_TL1_Tile_Lines[0] <= 1'b0;

		// Tile Layer 2
		if ( VGE_Engine_VBlanking_2L_o && TL2Condition2Trigger ) begin
			if (HPixelCount < (HBlankPlusOne - 4))
					Charge_TL2_Tile_Lines[0] <= 1'b1;
			else 
					Charge_TL2_Tile_Lines[0] <= 1'b0;
		end
		else
			Charge_TL2_Tile_Lines[0] <= 1'b0;
			

		// Tile Layer 2
		if ( VGE_Engine_VBlanking_2L_o && TL3Condition2Trigger ) begin
			if (HPixelCount < (HBlankPlusOne - 4))
					Charge_TL3_Tile_Lines[0] <= 1'b1;
			else 
					Charge_TL3_Tile_Lines[0] <= 1'b0;
		end
		else
			Charge_TL3_Tile_Lines[0] <= 1'b0;


		// First line
		if (VGE_Engine_VBlanking_2L_o && (Visible_Local_Line_Counter == 10'h000)) begin
			Charge_TL0_Tile_Lines[1] <= 1'b1;
			Charge_TL1_Tile_Lines[1] <= 1'b1;
			Charge_TL2_Tile_Lines[1] <= 1'b1;
			Charge_TL3_Tile_Lines[1] <= 1'b1;
		end
		else begin
			Charge_TL0_Tile_Lines[1] <= 1'b0;
			Charge_TL1_Tile_Lines[1] <= 1'b0;
			Charge_TL2_Tile_Lines[1] <= 1'b0;
			Charge_TL3_Tile_Lines[1] <= 1'b0;			
		end
	end
end



// Mstr_Ctrl_Video_Mode_i[1:0]
// 00 = 640x480
// 01 = 640x400
// 10 = 800x600
// 10 = 800x600


// Video Clock - Clocked
always @ (posedge VideoClk_i) 
begin
	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
		Time_RD_WR_Strobe 				<= 1'b0;
		Time_RD_Only_Strobe 				<= 4'b0000;
		Time_Line_Erasure 				<= 4'b0000;
		Time_Start_Display_Line 		<= 1'b0;
	end
	else begin
//			Time_RD_WR_Strobe 				<= Time_RD_WR_Strobe << 1'b1;
			Time_RD_Only_Strobe 				<= Time_RD_Only_Strobe << 1'b1;
			Time_Line_Erasure 				<= Time_Line_Erasure << 1'b1;
//			Time_Start_Display_Line 		<= Time_Start_Display_Line << 1'b1;
	
			case (HPixelCount) 
				// Beginning of the Line
			//12'd0 : Time_RD_WR_Strobe <= 1'b1;

			// 800 x 600 Time to Erase the Line			
			12'd180: begin
				if (VGE_Engine_VBlanking_2L_o) begin
					if ( Mstr_Ctrl_Video_Mode )
							Time_Line_Erasure <= 4'b1111;
					else
							Time_RD_Only_Strobe <= 4'b1111;
				end
			end			
		
			// To be Adujsted for the Latency
			// Video Start in 1280x1024
			12'd402: begin
				if ( VBlanking_o ) begin
					if (Mstr_Ctrl_Video_Mode == 1'b1) begin
						Time_Start_Display_Line <= 1'b1;
						Time_RD_WR_Strobe <= 1'b0;						
					end
				end
			end
			
			// This is the Time Where the process of Fetching the information begins
			// 1280x1024
			12'd442: begin
				if (VGE_Engine_VBlanking_2L_o) begin
					if (Mstr_Ctrl_Video_Mode == 1'b1) begin
						Time_RD_Only_Strobe <= 4'b1111; 
					end
				end
			end
			
			// 1280x960
			12'd480: begin
				if (VGE_Engine_VBlanking_2L_o) begin
					if (Mstr_Ctrl_Video_Mode == 1'b0)
						Time_Line_Erasure <= 4'b1111;
				end
			end

			// Video Start in 1280x960
			12'd516: begin
				if (VBlanking_o) begin
					if (Mstr_Ctrl_Video_Mode == 1'b0) begin
						Time_Start_Display_Line <= 1'b1;
						Time_RD_WR_Strobe <= 1'b0;
					end
				end
			end

			// 1280x960
			12'd1684: begin
				if ( VBlanking_o ) begin
					if (Mstr_Ctrl_Video_Mode == 1'b1) begin //1280x1024
						Time_Start_Display_Line <= 1'b0;				
					end
				end
			end

			// 1280x1024 end of Line		
			12'd1687: begin 
				if (VGE_Engine_VBlanking_2L_o) begin
					if (Mstr_Ctrl_Video_Mode == 1'b1) begin	//1280x1024
						Time_RD_WR_Strobe <= 1'b1;
					end
				end
			end

			// 1280x960 the Pixel Lines last longer
			12'd1795: begin
				if ( VBlanking_o ) begin
					if (Mstr_Ctrl_Video_Mode == 1'b0) begin //1280x960
						Time_Start_Display_Line <= 1'b0;				
					end
				end
			end
			
			// 1280x960
			12'd1799: begin 
				if (VGE_Engine_VBlanking_2L_o) begin
					if (Mstr_Ctrl_Video_Mode == 1'b0) begin	//1280x960
						Time_RD_WR_Strobe <= 1'b1;
					end
				end
			end
		
		default: begin end
		
		endcase
	end
end		

always @ (posedge VideoClk_i) 
begin
	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
		Time_Line_2_LUT_2_FinalLine 	<= 4'b0000;
	end
	else begin
		Time_Line_2_LUT_2_FinalLine 	<= Time_Line_2_LUT_2_FinalLine << 1'b1;
		
		if ((HPixelCount[11:0] == 12'd1799) && VGE_Engine_VBlanking_2L_o && !Mstr_Ctrl_Video_Mode)
					Time_Line_2_LUT_2_FinalLine <= 4'b1111;					//<<<<<<<<
			
		if ((HPixelCount[11:0] == 12'd1687) && VGE_Engine_VBlanking_2L_o && Mstr_Ctrl_Video_Mode)
					Time_Line_2_LUT_2_FinalLine <= 4'b1111;					//<<<<<<<<			
	end
end

endmodule

/*
always @ ( * ) begin 
	if ( Mstr_Ctrl_Video_Mode_i[0] ) begin
		// 1280 x 1024 @60Mhz (640x512 / 320x256) (5:4)
		//  |---48HBL--| 112HS |---248HBL---| Active Video 1280 | Blanking total:520
		// Line Total 1688
		// Total HBlank = 1688 - 408 = 1280
		// Horizontal
		HSYNC_START 	= 16'd47;		// Start 
		HSYNC_STOP 		= 16'd159;		// Stp
		HBLANK_START	= 16'd407;
		HBLANK_STOP	 	= 16'd1687;
		HSync_Pol_o     = 1'b1;	// Positive
		// Vertical 
		// [1 VBLANK][3 VSYNC][38 VBLANK][1066 Lines]
		// VTotal = 1030 (1066 - 1024 = 6)
//		VBLANK_2Lines   = 24'd67519;    // 40 Lines
		VSYNC_START		= 24'd1687;
		VSYNC_STOP		= 24'd6751;
		VBLANK_START	= 24'd70895;	// 42 Lines of Blankings
		VBLANK_STOP		= 24'd1799407;
		VSync_Pol_o	    = 1'b1;
	end
	else begin
		// 1280 x 960 @60Mhz (640x480 / 320x240)(4:3)
		//96  |---96HBL--| 112HS |---312HBL---| Active Video 1280 | Blanking total:520
		// Line Total 1800
		// Horizontal
		HSYNC_START 	= 16'd95;
		HSYNC_STOP 		= 16'd207;
		HBLANK_START	= 16'd519;
		HBLANK_STOP	 	= 16'd1799;
		HSync_Pol_o     = 1'b1;	// Positive
		// Vertical 
		// [1 VBLANK][3 VSYNC][36 VBLANK][1000 Lines]
		// VTotal = 1000
//		VBLANK_2Lines   = 24'd57599;	//4 Lines before beginning
		VSYNC_START		= 24'd1799;
		VSYNC_STOP		= 24'd7199;
		VBLANK_START	= 24'd71999;	//40 Lines of Blanking
		VBLANK_STOP		= 24'd1799999;
		VSync_Pol_o    = 1'b1; // Positive
	end
end

*/