
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
output  	wire   				VGE_Engine_VBlanking_4L_o,
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

// Registers
reg 	[15:0]		HSYNC_START;
reg 	[15:0]		HSYNC_STOP;
reg 	[15:0]		HBLANK_START; 		//1
reg 	[15:0]		HBLANK_STOP;			//256
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
reg					DENA_VERTICAL_4LINEPRIOT;
reg		[11:0]		HPixelCount_Buf0;
reg		[11:0]		HPixelCount_Buf1;
reg		[11:0]		HLineCount_Buf0;
reg		[11:0]		HLineCount_Buf1;
reg		[11:0]		HLineLocal;
reg		[15:0]		HPixelCount;
reg		[15:0]		HLineCount;
reg 	[2:0]		Mstr_Ctrl_Video_Mode_ReSync;
reg 	[2:0]		Mstr_Ctrl_Doubling_Pixel_ReSync;
reg 	[2:0] 		Rst_rstn_reg;
reg 				Time_RD_WR_Strobe;
reg 	[3:0]		Time_RD_Only_Strobe;
reg 	[3:0]		Time_Line_2_LUT_2_FinalLine;
reg 	[3:0]		Time_Line_Erasure;
reg 				Time_Start_Display_Line;
reg 	[10:0] 		Visible_Local_Line_Counter;
reg 	[1:0]		Charge_TL0_Tile_Lines;
reg 	[1:0]		Charge_TL1_Tile_Lines;
reg 	[1:0]		Charge_TL2_Tile_Lines;
reg 	[1:0]		Charge_TL3_Tile_Lines;
reg 	[2:0]		TLayer0Mode8_16_Sync;
reg 	[2:0]		TLayer1Mode8_16_Sync;
reg 	[2:0]		TLayer2Mode8_16_Sync;
reg 	[2:0]		TLayer3Mode8_16_Sync;


// Wires
wire 				reset_mode;
wire 	[15:0] 		HBlankPlusOne ;
wire 	[23:0] 		OneLineCompare;
wire 	[23:0] 		TwoLineCompare;
wire 	[23:0] 		FourLineCompare;
wire 	[11:0] 		HPixelCount_Target;
wire  				TwoOrFourLine_Ahead;



// Assignments
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
assign HBlankPlusOne 	= HBLANK_STOP + 16'd1;
//                        In clock cycles:    (72000) - (1800)
assign OneLineCompare 	= ((( VBLANK_START + 24'd1 ) - {8'b0000_0000,HBlankPlusOne}) - 24'd1);
//                        In clock cycles:    (72000) - (3600)
assign TwoLineCompare 	= ((( VBLANK_START + 24'd1 ) - {7'b0000_000, HBlankPlusOne, 1'b0}) - 24'd1);
//                        In clock cycles:    (72000) - (7200)
assign FourLineCompare 	= ((( VBLANK_START + 24'd1 ) - {6'b0000_000, HBlankPlusOne, 2'b00}) - 24'd1);

assign 	VBlanking_o 				= DENA_VERTICAL;
assign	HBlanking_o 				= DENA_HORIZONTAL;
assign 	HBlanking_Latency_o 		= DENA_HORIZONTAL_READ_LATENCY;
assign  HBlanking_Latency_VGE_o 	= DENA_HORIZONTAL_READ_VGE_LAT;
assign	VGE_Engine_VBlanking_1L_o 	= DENA_VERTICAL_1LINEPRIOT;
assign	VGE_Engine_VBlanking_2L_o 	= DENA_VERTICAL_2LINEPRIOT;
assign  VGE_Engine_VBlanking_4L_o 	= DENA_VERTICAL_4LINEPRIOT;
assign 	reset_mode = ( Mstr_Ctrl_Video_Mode_ReSync[1:0] == 2'b10 ) || ( Mstr_Ctrl_Video_Mode_ReSync[1:0] == 2'b01 );
assign	HPixelCount_o 	= HPixelCount[11:0];
assign 	HLineCount_o 	= HLineCount[11:0];



always @ (posedge VideoClk_i)
begin
	if (Reset_VideoClk_Full_Resolution) begin
		Mstr_Ctrl_Video_Mode_ReSync[2:0] <= 3'b000;
		Mstr_Ctrl_Doubling_Pixel_ReSync[2:0] <= 3'b000;
	end
	else begin
		// Resync the Video Mode Register Resync to 108Mhz Dot Clock
		Mstr_Ctrl_Video_Mode_ReSync[0] <= Mstr_Ctrl_Video_Mode_i[0];
		Mstr_Ctrl_Video_Mode_ReSync[1] <= Mstr_Ctrl_Video_Mode_ReSync[0];
		if (  Mstr_Ctrl_Video_Mode_ReSync[1] == Mstr_Ctrl_Video_Mode_ReSync[0] )
			Mstr_Ctrl_Video_Mode_ReSync[2] <= Mstr_Ctrl_Video_Mode_ReSync[1];
		// Doubling Resync to 108Mhz Dot Clock
		Mstr_Ctrl_Doubling_Pixel_ReSync[0] <= Mstr_Ctrl_Doubling_Pixel_i;
		Mstr_Ctrl_Doubling_Pixel_ReSync[1] <= Mstr_Ctrl_Doubling_Pixel_ReSync[0];
		if ( Mstr_Ctrl_Doubling_Pixel_ReSync[1] == Mstr_Ctrl_Doubling_Pixel_ReSync[0] )
			Mstr_Ctrl_Doubling_Pixel_ReSync[2] <= Mstr_Ctrl_Doubling_Pixel_ReSync[1];
	end
end

wire Mstr_Ctrl_Video_Mode = Mstr_Ctrl_Video_Mode_ReSync[2];
wire Mstr_Ctrl_Doubling_Pixel = Mstr_Ctrl_Doubling_Pixel_ReSync[2];

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

		DENA_VERTICAL_1LINEPRIOT <= 1'b0;	// 
		DENA_VERTICAL_2LINEPRIOT <= 1'b0;
		DENA_VERTICAL_4LINEPRIOT <= 1'b0;
		DENA_VERTICAL <= 1'b0;
	end
	else begin
		if (PixelCounter == VBLANK_START)
			DENA_VERTICAL <= 1'b1;

		if (PixelCounter == OneLineCompare)
			DENA_VERTICAL_1LINEPRIOT <= 1'b1;

		if (PixelCounter == TwoLineCompare)
			DENA_VERTICAL_2LINEPRIOT <= 1'b1;

		if (PixelCounter == FourLineCompare)
			DENA_VERTICAL_4LINEPRIOT <= 1'b1;					
		
		if (PixelCounter == VBLANK_STOP) begin
			DENA_VERTICAL <= 1'b0;
			DENA_VERTICAL_1LINEPRIOT <= 1'b0;
			DENA_VERTICAL_2LINEPRIOT <= 1'b0;
			DENA_VERTICAL_4LINEPRIOT <= 1'b0;			
		end
	end
end			


////
// SEQUENCER
////
// Let's create a LOCAL HPixelCount_Local and VLineCount_Local for the Sequencer since it is not running @ 25.125Mhz but 4 time faster

reg [11:0] HPixelCount_Local;

// HBLANK
always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		HPixelCount_Local				<= 12'h000;
	end
	else begin
		// Count from 0 to 1055
		if (HPixelCount_Local < HBLANK_STOP) begin
			HPixelCount_Local <= HPixelCount_Local + 12'h001;
		end
		else begin
			HPixelCount_Local <= 12'h000;			
		end
	end	
end

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
// Okay Guys we are dealing with 108Mhz, so 960 or 1024 lines per frame, so let's add 1 bit to the counter.
// So now, the charging happens either every 2 lines or every 4 lines.
// in 640x480 mode - there would be 
// Visible_Local_Line_Counter[10:0] = [0..2047] 
// 1280x960 : 960 Lines Will be Counted
// 1280x1024: 1024 Lines Will be Counted
/*
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
*/
always @ (posedge VideoClk_i) 
begin
	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
		Visible_Local_Line_Counter		<= 11'b00_0000_0000;
	end
	else begin
		if ( TwoOrFourLine_Ahead )  begin
			if ( HPixelCount_Local == HBLANK_STOP )
				Visible_Local_Line_Counter <= Visible_Local_Line_Counter + 11'h001;
		end
		else begin
			Visible_Local_Line_Counter		<= 11'b00_0000_0000;
		end
	end
end

reg  TL0Condition2Trigger;
reg  TL1Condition2Trigger;
reg  TL2Condition2Trigger;
reg  TL3Condition2Trigger;

wire Condition16Lines;
wire Condition32Lines;
wire Condition64Lines;

// Old Conditions with 25.125Mhz or 40.000Mhz Video Clock
//assign ConditionHalfSizeTiles = (Visible_Local_Line_Counter[2:0] == 3'b000); // When using Tiles
//assign Condition16PixelTiles 	= (Visible_Local_Line_Counter[3:0] == 4'b0000);
//assign ConditionHalfClock 	= (Visible_Local_Line_Counter[4:0] == 5'b0_0000);
//So the deal is TileSize8_16 = [0] = 16 Pixels per tile, [1] = 8 Pixels per Tile
// if in 16x16 mode, with 960 Lines where every other lines are doubled, then I need 32 lines out 960 or 1024 (640x480 Mode) / (640x512)
// if in 8x8 mode, with 960 lines where every other lines are doubled, then I need 16 lines out 960 or 1024 (640x480 Mode) / (640x512)
//.... Now:
// if in 16x16 mode, with 960 Lines where every other lines are Quadrupled, then I need 64 Lines out 960 or 1024 (320x240) / (320x256)
// if in 8x8 mode, with 960 Lines where every other lines are Quadrupled, then I need 32 Lines (320x240) / (320x256)
assign Condition16Lines 	= (Visible_Local_Line_Counter[3:0] == 4'b0000); 	// Every 16 Lines
assign Condition32Lines 	= (Visible_Local_Line_Counter[4:0] == 5'b0_0000);	// Every 32 Lines
assign Condition64Lines 	= (Visible_Local_Line_Counter[5:0] == 6'b00_0000);  // Every 64 Lines

always @ (*) begin
	case ( { TLayer0Mode8_16_Sync[2], Mstr_Ctrl_Doubling_Pixel_ReSync[2] } )
		2'b00: begin TL0Condition2Trigger = Condition32Lines;  	end		// 640x480/512 - 16x16 Tiles
		2'b01: begin TL0Condition2Trigger = Condition64Lines;  	end		// 320x240/256 - 16x16 Tiles
		2'b10: begin TL0Condition2Trigger = Condition16Lines;  	end		// 640x480/512 - 8x8 Tiles
		2'b11: begin TL0Condition2Trigger = Condition32Lines;  	end		// 320x240/256 - 8x8 Tiles
	endcase
end
always @ (*) begin
	case ( { TLayer1Mode8_16_Sync[2], Mstr_Ctrl_Doubling_Pixel_ReSync[2] } )
		2'b00: begin TL1Condition2Trigger = Condition32Lines; 	end		// 640x480/512 - 16x16 Tiles
		2'b01: begin TL1Condition2Trigger = Condition64Lines; 	end		// 320x240/256 - 16x16 Tiles
		2'b10: begin TL1Condition2Trigger = Condition16Lines; 	end		// 640x480/512 - 8x8 Tiles
		2'b11: begin TL1Condition2Trigger = Condition32Lines; 	end		// 320x240/256 - 8x8 Tiles
	endcase
end
always @ (*) begin
	case ( { TLayer2Mode8_16_Sync[2], Mstr_Ctrl_Doubling_Pixel_ReSync[2] } )
		2'b00: begin TL2Condition2Trigger = Condition32Lines;	end		// 640x480/512 - 16x16 Tiles
		2'b01: begin TL2Condition2Trigger = Condition64Lines;	end		// 320x240/256 - 16x16 Tiles
		2'b10: begin TL2Condition2Trigger = Condition16Lines; 	end		// 640x480/512 - 8x8 Tiles
		2'b11: begin TL2Condition2Trigger = Condition32Lines;	end		// 320x240/256 - 8x8 Tiles
	endcase
end

always @ (*) begin	
	case ( { TLayer3Mode8_16_Sync[2], Mstr_Ctrl_Doubling_Pixel_ReSync[2] } )
		2'b00: begin TL3Condition2Trigger = Condition32Lines;	end		// 640x480/512 - 16x16 Tiles
		2'b01: begin TL3Condition2Trigger = Condition64Lines;	end		// 320x240/256 - 16x16 Tiles
		2'b10: begin TL3Condition2Trigger = Condition16Lines; 	end		// 640x480/512 - 8x8 Tiles
		2'b11: begin TL3Condition2Trigger = Condition32Lines;	end		// 320x240/256 - 8x8 Tiles
	endcase	
end

// 0 -> 1799 for 1290x960 (1800 Pixels in 1 Line) (Starts @ 519)
// 0 -> 1687 for 1280x1024 (1688 Pixels in 1 Line) (Starts @ 407)
//Mstr_Ctrl_Doubling_Pixel = [0] = 640x480 so 2 Lines before, [1] = 320x240 so 4 Lines before
assign HPixelCount_Target = Mstr_Ctrl_Doubling_Pixel_ReSync[2] ? 12'd1683 : 12'd1795; // ( 1687 - 4 ), ( 1799 - 4 )
assign TwoOrFourLine_Ahead = Mstr_Ctrl_Doubling_Pixel ? VGE_Engine_VBlanking_4L_o : VGE_Engine_VBlanking_2L_o;

// Tile Layer 0
always @ (posedge VideoClk_i) 
begin
	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
				Charge_TL0_Tile_Lines <= 2'b00;	
	end
	else begin
		// Tile Layer 0
		if ( TwoOrFourLine_Ahead && TL0Condition2Trigger ) begin
			if (HPixelCount < HPixelCount_Target)
					Charge_TL0_Tile_Lines[0] <= 1'b1;
			else 
					Charge_TL0_Tile_Lines[0] <= 1'b0;
		end
		else
			Charge_TL0_Tile_Lines[0] <= 1'b0;
			
		// Tile Layer 1
		if ( TwoOrFourLine_Ahead && TL1Condition2Trigger ) begin
			if (HPixelCount < HPixelCount_Target)
					Charge_TL1_Tile_Lines[0] <= 1'b1;
			else 
					Charge_TL1_Tile_Lines[0] <= 1'b0;
		end
		else
			Charge_TL1_Tile_Lines[0] <= 1'b0;

		// Tile Layer 2
		if ( TwoOrFourLine_Ahead && TL2Condition2Trigger ) begin
			if (HPixelCount < HPixelCount_Target)
					Charge_TL2_Tile_Lines[0] <= 1'b1;
			else 
					Charge_TL2_Tile_Lines[0] <= 1'b0;
		end
		else
			Charge_TL2_Tile_Lines[0] <= 1'b0;
			

		// Tile Layer 2
		if ( TwoOrFourLine_Ahead && TL3Condition2Trigger ) begin
			if (HPixelCount < HPixelCount_Target)
					Charge_TL3_Tile_Lines[0] <= 1'b1;
			else 
					Charge_TL3_Tile_Lines[0] <= 1'b0;
		end
		else
			Charge_TL3_Tile_Lines[0] <= 1'b0;


		// First line
		if (TwoOrFourLine_Ahead && (Visible_Local_Line_Counter == 11'h000)) begin
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

// Mstr_Ctrl_Video_Mode_i[0]
// 00 = 1280x960 (Actually the Resolution is Doubled or Quadrupled)
// 01 = 1280x1024 (Actually the Resolution is Doubled or Quadrupled)
/// The Sequencer is like this : based off old timings @ 25.175MHz
// Line Starts @ 0
// Dot Clock 0 to 110 	- Transfer of Process Pixels for display (after HBlank is over with) - 'Time_RD_WR_Strobe <= 1'b1 ' 
// Dot Clock 110 to 156 - This is the time where the old Pixel Processing lines are cleared - 'Time_Line_Erasure' (trigger one-shot signal)
// Dot Clock 156 - Enable the Display of the new Active Line / Disable 'Time_RD_WR_Strobe' (on/off signal) // Time_RD_WR_Strobe <= 1'b0; 
// Dot Clock 180 - Trigger the Processing of a new Line??? - Trigger the 'Time_RD_Only_Strobe' (trigger one-shot signal)
// Dot Clock 796 - Disable the Display of the new Actile Line
// Dot Clock 799 - Enable 'Time_RD_WR_Strobe'

// So timing wise we have the following:
// 110 Clocks @ 25.125Mhz = ~4.37uS (0-110)			// 5us with 108Mhz Clock Cycles = 540 -> Trigger Erasure
// 46 Clocks @ 25.125Mhz = ~1.82uS (156 - 110)		// 2us with 108Mhz Clock Cycles = 216 -> Time when the Line is being fed to screen output
// 70 Clocks @ 25.125Mhz = ~2.78uS (180 - 110)		// ~3 uS with 108Mhz Clock Cycles = 324
//TwoOrFourLine_Ahead


// Video Clock - Clocked
always @ (posedge VideoClk_i) 
begin
	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
		Time_RD_WR_Strobe 				<= 1'b0;
		Time_RD_Only_Strobe 			<= 4'b0000;
		Time_Line_Erasure 				<= 4'b0000;
		Time_Start_Display_Line 		<= 1'b0;
	end
	else begin
			Time_RD_Only_Strobe 			<= Time_RD_Only_Strobe << 1'b1;
			Time_Line_Erasure 				<= Time_Line_Erasure << 1'b1;

	
			case (HPixelCount_Local) 

/////////////////////////////
/// Time_Start_Display_Line
/////////////////////////////
			// Video Start in 640x480
			// 160 is the HBLank in 25.175Mhz 640x480
			// 540 Clock Cycles @ 9.25nS to Transfer the new line to be displayed

			// This is the moment to enable display for the 1280x1024 mode
			// 4 Clock Cycles Later the HBlanking ends
			12'd404: begin
				if (VBlanking_o) begin
					if ( Mstr_Ctrl_Video_Mode_i[0] ) begin
						Time_Start_Display_Line <= 1'b1;
						Time_RD_WR_Strobe <= 1'b0;
					end
				end
			end

			// This is the moment to enable display for the 1280x960 mode
			// 4 Clock Cycles Later the HBlanking ends
			12'd516: begin
				if (VBlanking_o) begin
					if ( !Mstr_Ctrl_Video_Mode_i[0] ) begin
						Time_Start_Display_Line <= 1'b1;
						Time_RD_WR_Strobe <= 1'b0;
					end
				end
			end

/////////////////////////////
/// Time_Line_Erasure
/////////////////////////////
			// The Line Transfer is over, the Line Erasure begins.
			// Both modes needs the same time for both tasks.
			12'd540: begin
				if (TwoOrFourLine_Ahead) begin
					// 1280x960 & 1280x1024 Mode - They share the same Clock Cycle
					Time_Line_Erasure <= 4'b1111;					
				end
			end

/////////////////////////////
/// Time_RD_Only_Strobe
/////////////////////////////
			// FYI Line is Active Between PixelClock 520 to 1799 for 1280x960
			// FYI Line is Active Between PixelClock 408 to 1688 for 1280x1024
			// So considering the above timings, by the time we get here we are pretty much in the middle on the first line.
			// in the 640x480 Display, we have 2 full lines to process all the tiles.
			// in the 320x240 Display, we will have 4 Full Lines to process all the tiles.
			// Both modes needs the same time for the same task.
			12'd864: begin 
				if (TwoOrFourLine_Ahead) begin
						Time_RD_Only_Strobe <= 4'b1111;
				end
			end

/////////////////////////////
/// Time_Start_Display_Line for 1280 x 1024
/////////////////////////////
// 1024x1024 Mode (Shorter Line, more Vertical Resolution) 5:4
			// 1280x1024
			12'd1684: begin
				if ( VBlanking_o ) begin
					if (Mstr_Ctrl_Video_Mode_i[0] ) begin
						Time_Start_Display_Line <= 1'b0;				
					end			
					end
			end			

/////////////////////////////
/// Time_RD_WR_Strobe for 1280 x 1024
/////////////////////////////			
			// 1280x1024 end of Line		
			12'd1687: begin 
				if (TwoOrFourLine_Ahead) begin
					if ( Mstr_Ctrl_Video_Mode_i[0] ) begin
						Time_RD_WR_Strobe <= 1'b1;
					end
				end
			end

/////////////////////////////
/// Time_Start_Display_Line for 1280 x 960
/////////////////////////////
// 1024x960 Mode (Longer Line, less Vertical Resolution) 4:3
			12'd1796: begin
				if ( VBlanking_o ) begin
						Time_Start_Display_Line <= 1'b0;				
				end
			end

/////////////////////////////
/// Time_RD_WR_Strobe for 1280 x 960
/////////////////////////////				
			// 1280x960 End of Line
			12'd1799: begin 
				if (TwoOrFourLine_Ahead) begin
						Time_RD_WR_Strobe <= 1'b1;
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
		
		if ((HPixelCount_Local == 12'd1799) && TwoOrFourLine_Ahead && !Mstr_Ctrl_Video_Mode)
					Time_Line_2_LUT_2_FinalLine <= 4'b1111;					//<<<<<<<<
			
		if ((HPixelCount_Local == 12'd1687) && TwoOrFourLine_Ahead && Mstr_Ctrl_Video_Mode)
					Time_Line_2_LUT_2_FinalLine <= 4'b1111;					//<<<<<<<<			
	end
end

/*
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
output  	wire   				VGE_Engine_VBlanking_4L_o,
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
*/

wire [143:0] TP;
wire  Trigger;

wire [31:0] Source;
wire [31:0] Probe;

assign Probe = 32'h55ffaa00;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);

assign Trigger = (( HPixelCount_Local == Source[11:0]) & (HLineCount_o == Source[27:16]));


assign TP[11:0] 	= HPixelCount_o;
assign TP[23:12] 	= HPixelCount_Local;
assign TP[35:24] 	= HLineCount_o;
assign TP[47:36]	= {1'b0, Visible_Local_Line_Counter};
assign TP[49:48]	= Mstr_Ctrl_Video_Mode_i;
assign TP[50]		= Mstr_Ctrl_Doubling_Pixel_i;
assign TP[51]		= HSYNC_o;
assign TP[52] 		= VSYNC_o;
assign TP[53]		= HBlanking_Latency_o;
assign TP[54] 		= HBlanking_Latency_VGE_o;
assign TP[55] 		= HBlanking_o;
assign TP[56] 		= VBlanking_o;
assign TP[57]		= VGE_Engine_VBlanking_1L_o;
assign TP[58] 		= VGE_Engine_VBlanking_2L_o;
assign TP[59] 		= VGE_Engine_VBlanking_4L_o;
assign TP[60] 		= SOF_o;
assign TP[61] 		= Time_RD_WR_Strobe;
assign TP[62] 		= Time_RD_Only_Strobe[3];
assign TP[63] 		= Time_Line_2_LUT_2_FinalLine[3];
assign TP[64] 		= Time_Line_Erasure[3];
assign TP[65] 		= Time_Start_Display_Line;
assign TP[67:66] 	= Charge_TL0_Tile_Lines[1:0];
assign TP[69:68] 	= Charge_TL1_Tile_Lines[1:0];
assign TP[71:70] 	= Charge_TL2_Tile_Lines[1:0];
assign TP[73:72] 	= Charge_TL3_Tile_Lines[1:0];
assign TP[143:74] 	= 0;

// not so tiny anymore
TinyChipScope CHIPSCOPE_VID (
	.acq_data_in    ( TP ),    //        tap.acq_data_in
	.acq_trigger_in ( Trigger ), //           .acq_trigger_in
	.acq_clk        ( VideoClk_i ),        //    acq_clk.clk
	.trigger_in     ( Trigger )      // trigger_in.trigger_in
);



endmodule


