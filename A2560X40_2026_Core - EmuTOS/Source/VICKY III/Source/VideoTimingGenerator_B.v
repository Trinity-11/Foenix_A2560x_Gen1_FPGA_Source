
`timescale 1ns/1ns

module VideoTimingGenerator_B (	
input		wire				Reset_VideoClk_Full_Resolution,
input		wire				VideoClk_i,
input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,

input				[1:0]		Mstr_Ctrl_Video_Mode_i,
input							Mstr_Ctrl_Doubling_Pixel_i,

output 	reg				HSYNC_o,					//HD
output 	reg				VSYNC_o,					//VD

output	reg				HSync_Pol_o,
output	reg				VSync_Pol_o,

output 	wire	[11:0]  	HPixelCount_o,
output 	wire  [11:0]	HLineCount_o,

output						HBlanking_Latency_o,
output						HBlanking_Latency_VGE_o,
output						HBlanking_o,
output 						VBlanking_o,
output	wire				VGE_Engine_VBlanking_o,
output 	wire				SOF_o,

output	wire	[15:0]	HBLANK_START_o,
output	wire	[15:0]	HBLANK_STOP_o,

output	wire				Time_Rd_Wr_Access_100Mhz_o,		// 100Mhz Clock Realm
output	wire				Time_Rd_Only_Access_100Mhz_o,	// 100Mhz Clock Realm
output	wire				Time_Trf_Pixels_2_Pixel_200Mhz_o,	// 200Mhz Clock
output	wire				Time_Erase_Pixels_Line_100Mhz_o,
output	wire				Time_Erase_Pixels_Line_200Mhz_o,
output	wire				Time_2_Display_Line_VideoClk_o,
output	wire	[1:0]		Time_2_Charge_TileMap_Lines_o
);



reg 	[15:0]	HSYNC_START;
reg 	[15:0]	HSYNC_STOP;
reg 	[15:0]	HBLANK_START; 		//1
reg 	[15:0]	HBLANK_STOP;			//256
//reg 	[15:0]	VTOTAL; 				//628
reg	[23:0]	VSYNC_START;			//1
reg	[23:0]	VSYNC_STOP;				//5
reg	[23:0]	VBLANK_START;
reg	[23:0]	VBLANK_STOP;

assign HBLANK_START_o = HBLANK_START;
assign HBLANK_STOP_o = HBLANK_STOP;

always @ (*) begin

	case (Mstr_Ctrl_Video_Mode_i)
	
	// 640x480 @ 60Hz
	2'b00: begin
		// Horizontal
		HSYNC_START 	= 16'd15;
		HSYNC_STOP 		= 16'd111;
		HBLANK_START	= 16'd159;
		HBLANK_STOP	 	= 16'd799;
		HSync_Pol_o    = 1'b0;
		// Vertical 
//		VTOTAL			= 16'd524;
		VSYNC_START		= 24'd7999;
		VSYNC_STOP		= 24'd9599;
		VBLANK_START	= 24'd35999;
		VBLANK_STOP		= 24'd419999;
		VSync_Pol_o    = 1'b0;
	end
	
	// 640x400 @ 70Hz
	2'b01: begin
		// Horizontal
		HSYNC_START 	= 16'd15;
		HSYNC_STOP	 	= 16'd111;
		HBLANK_START 	= 16'd159;
		HBLANK_STOP	 	= 16'd799;
		HSync_Pol_o    = 1'b0;		
		// Vertical 
//		VTOTAL			= 16'd448;
		VSYNC_START		= 24'd9599;
		VSYNC_STOP		= 24'd11199;
		VBLANK_START	= 24'd39199;
		VBLANK_STOP		= 24'd359199;
		VSync_Pol_o	   = 1'b1;			
	end
	
	// 800x600
	2'b10: begin
		// Horizontal
		HSYNC_START 	= 16'd39;
		HSYNC_STOP 		= 16'd167;
		HBLANK_START 	= 16'd255;
		HBLANK_STOP 	= 16'd1055;
		HSync_Pol_o	   = 1'b1;
		// Vertical 
//		VTOTAL			= 16'd627;
		VSYNC_START		= 24'd1055;
		VSYNC_STOP		= 24'd5279;
		VBLANK_START   = 24'd29567;
		VBLANK_STOP    = 24'd663167;
		VSync_Pol_o	   = 1'b1;
		end
	
	// 800x600
	2'b11: begin
		// Horizontal
		HSYNC_START 	= 16'd39;
		HSYNC_STOP 		= 16'd167;
		HBLANK_START 	= 16'd255;
		HBLANK_STOP 	= 16'd1055;
		HSync_Pol_o	   = 1'b1;
		// Vertical 
//		VTOTAL			= 16'd627;
		VSYNC_START		= 24'd1055;
		VSYNC_STOP		= 24'd5279;
		VBLANK_START   = 24'd29567;
		VBLANK_STOP    = 24'd663167;
		VSync_Pol_o	   = 1'b1;	
	end
	
	endcase
end


reg				DENA_VERTICAL;
reg 				DENA_HORIZONTAL;
reg 				DENA_HORIZONTAL_READ_LATENCY;
reg 				DENA_HORIZONTAL_READ_VGE_LAT;
reg	[23:0]	PixelCounter;
reg	[15:0]	HBLANK_START_Dly;
reg	[15:0]	HBLANK_START_VGE_Dly;
reg				DENA_VERTICAL_1LINEPRIOT;
reg	[11:0]	HPixelCount_Buf0;
reg	[11:0]	HPixelCount_Buf1;
reg	[11:0]	HPixelLocal;

reg	[11:0]	HLineCount_Buf0;
reg	[11:0]	HLineCount_Buf1;
reg	[11:0]	HLineLocal;

assign 	VBlanking_o 				= DENA_VERTICAL;
assign	HBlanking_o 				= DENA_HORIZONTAL;
assign 	HBlanking_Latency_o 		= DENA_HORIZONTAL_READ_LATENCY;
assign   HBlanking_Latency_VGE_o = DENA_HORIZONTAL_READ_VGE_LAT;
assign	VGE_Engine_VBlanking_o 	= DENA_VERTICAL_1LINEPRIOT;

reg [1:0]	Mstr_Ctrl_Video_Mode_ReSync;
reg [1:0]	Mstr_Ctrl_Video_Mode_ReSync_Bit1;

reg [2:0] 	Rst_rstn_reg;

always @ (posedge VideoClk_i)
begin
	if (Reset_VideoClk_Full_Resolution) begin
		Mstr_Ctrl_Video_Mode_ReSync[1:0] <= 2'b00;
	end
	else begin
		Mstr_Ctrl_Video_Mode_ReSync[0] <= Mstr_Ctrl_Video_Mode_i[1];
		Mstr_Ctrl_Video_Mode_ReSync[1] <= Mstr_Ctrl_Video_Mode_ReSync[0];
		
		Mstr_Ctrl_Video_Mode_ReSync_Bit1[0] <= Mstr_Ctrl_Doubling_Pixel_i;
		Mstr_Ctrl_Video_Mode_ReSync_Bit1[1] <= Mstr_Ctrl_Video_Mode_ReSync_Bit1[0];		
	end
end

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
		if ( Mstr_Ctrl_Video_Mode_i[1] )
			HBLANK_START_VGE_Dly <= HBLANK_START - 16'd8;		// Changed from 8 to 11
		else
			HBLANK_START_VGE_Dly <= HBLANK_START - 16'd5;		// Changed from 5 to 7
	end
end


wire reset_mode;

assign reset_mode = ( Mstr_Ctrl_Video_Mode_ReSync[1:0] == 2'b10 ) || ( Mstr_Ctrl_Video_Mode_ReSync[1:0] == 2'b01 );


reg	[11:0]	HPixelCount;
reg	[11:0]	HLineCount;


assign HPixelCount_o = HPixelCount;
assign HLineCount_o 	= HLineCount;

// HBLANK
always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		HPixelCount							<= 12'h000;
		HLineCount 						<= 12'h000;
	end
	else begin
	
		// Count from 0 to 1055
		if (HPixelCount < HBLANK_STOP) begin
			HPixelCount <= HPixelCount + 12'h001;
		end
		else begin
			HLineCount  <= HLineCount + 12'h001;
			HPixelCount <= 12'h000;
		end
	
		if (PixelCounter == VBLANK_STOP)
			HLineCount <= 12'h000;
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
		if ((HPixelCount > HSYNC_START) && (HPixelCount <= HSYNC_STOP))
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

always @ (posedge VideoClk_i)
begin				// VBlanking in Progressive Mode
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		DENA_VERTICAL_1LINEPRIOT <= 1'b0;
		DENA_VERTICAL <= 1'b0;
	end
	else begin
		if (PixelCounter == VBLANK_START)
			DENA_VERTICAL <= 1'b1;
		
		if (Mstr_Ctrl_Video_Mode_ReSync[1]) begin
//			if (PixelCounter == 24'd91871)		// 28 + 59 = Line Just before the beginning of the Frame 35199
			if (PixelCounter == 24'd28511)		// 28 + 59 = Line Just before the beginning of the Frame 35199			
				DENA_VERTICAL_1LINEPRIOT <= 1'b1;
		end
		else begin
			if (PixelCounter == 24'd35199)		// 28 + 59 = Line Just before the beginning of the Frame 35199
				DENA_VERTICAL_1LINEPRIOT <= 1'b1;
		end
		
		if (PixelCounter == VBLANK_STOP) begin
			DENA_VERTICAL <= 1'b0;
			DENA_VERTICAL_1LINEPRIOT <= 1'b0;
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
reg	[1:0]		Charge_Tile_Lines_RESYNC[0:2];


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
	
	Charge_Tile_Lines_RESYNC[0][1:0]	<= Charge_Tile_Lines[1:0];
	Charge_Tile_Lines_RESYNC[1][1:0] <=	Charge_Tile_Lines_RESYNC[0][1:0];
	if ( 	Charge_Tile_Lines_RESYNC[1][1:0] ==	Charge_Tile_Lines_RESYNC[0][1:0] )
		Charge_Tile_Lines_RESYNC[2][1:0] <=	Charge_Tile_Lines_RESYNC[1][1:0];
end

assign Time_Rd_Wr_Access_100Mhz_o 		= Time_RD_WR_Strobe_RESYNC[2];
assign Time_Rd_Only_Access_100Mhz_o		= Time_RD_Only_Strobe_RESYNC[2];

assign Time_Erase_Pixels_Line_100Mhz_o	= Time_Line_Erasure_RESYNC[2];
assign Time_2_Charge_TileMap_Lines_o   = Charge_Tile_Lines_RESYNC[2][1:0];

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

reg [1:0]	Charge_Tile_Lines;



// Video Clock - Clocked
always @ (posedge VideoClk_i) 
begin
	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
		Visible_Local_Line_Counter		<= 10'b00_0000_0000;
	end
	else begin
		if (VGE_Engine_VBlanking_o)  begin
			if (	HPixelCount == {HBLANK_STOP[11:1],1'b0} )
			Visible_Local_Line_Counter <= Visible_Local_Line_Counter + 10'h001;
		end
		else begin
			Visible_Local_Line_Counter		<= 10'b00_0000_0000;
		end
	end
end

wire ConditionFullClock;
wire ConditionHalfClock;
wire Condition2Trigger;

assign ConditionFullClock 	= (Visible_Local_Line_Counter[3:0] == 4'b0000);
assign ConditionHalfClock 	= (Visible_Local_Line_Counter[4:0] == 5'b0000);
assign Condition2Trigger 	= Mstr_Ctrl_Video_Mode_ReSync_Bit1[1] ? ConditionHalfClock : ConditionFullClock;

always @ (posedge VideoClk_i) 
begin
	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
				Charge_Tile_Lines <= 2'b00;	
	end
	else begin
		if ( VGE_Engine_VBlanking_o && Condition2Trigger ) begin
			if (HPixelCount < 12'd796)
					Charge_Tile_Lines[0] <= 1'b1;
			else 
					Charge_Tile_Lines[0] <= 1'b0;
		end
		else
			Charge_Tile_Lines[0] <= 1'b0;

		// First line
		if (VGE_Engine_VBlanking_o && (Visible_Local_Line_Counter == 10'h000))
			Charge_Tile_Lines[1] <= 1'b1;
		else
			Charge_Tile_Lines[1] <= 1'b0;		
		
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
		
			// 640 x 480 Time to Erase the Line
			12'd110: begin
				if (VGE_Engine_VBlanking_o) begin
					if (Mstr_Ctrl_Video_Mode_i[1] == 1'b0)
						Time_Line_Erasure <= 4'b1111;
				end
			end

			// Video Start in 640x480
			12'd156: begin
				if (VBlanking_o) begin
					if (Mstr_Ctrl_Video_Mode_i[1] == 1'b0) begin
						Time_Start_Display_Line <= 1'b1;
						Time_RD_WR_Strobe <= 1'b0;
					end
				end
			end
			
			// 800 x 600 Time to Erase the Line			
			12'd180: begin
				if (VGE_Engine_VBlanking_o) begin
					if ( Mstr_Ctrl_Video_Mode_i[1] )
							Time_Line_Erasure <= 4'b1111;
					else
							Time_RD_Only_Strobe <= 4'b1111;
				end
			end			
		
			// To be Adujsted for the Latency
			// Video Start in 800x600
			12'd252: begin
				if ( VBlanking_o ) begin
					if (Mstr_Ctrl_Video_Mode_i[1]) begin
						Time_Start_Display_Line <= 1'b1;
						Time_RD_WR_Strobe <= 1'b0;						
					end
				end
			end
			
			// This is the Time Where the process of Fetching the information begins
			// 800 x 600 Mode
			12'd290: begin
				if (VGE_Engine_VBlanking_o) begin
					if (Mstr_Ctrl_Video_Mode_i[1]) begin
						Time_RD_Only_Strobe <= 4'b1111; 
					end
				end
			end
			
			12'd796: begin
				if ( VBlanking_o ) begin
					if (Mstr_Ctrl_Video_Mode_i[1] == 1'b0) begin
						Time_Start_Display_Line <= 1'b0;				
					end
				end
			end
			
			// 640x480 end of Line
			12'd799: begin 
				if (VGE_Engine_VBlanking_o) begin
					if (Mstr_Ctrl_Video_Mode_i[1] == 1'b0) begin
						Time_RD_WR_Strobe <= 1'b1;
					end
				end
			end
			
			12'd1052: begin
				if ( VBlanking_o ) begin
						Time_Start_Display_Line <= 1'b0;				
					end
			end			
			
			// 800x600 end of Line		
			12'd1055: begin 
				if (VGE_Engine_VBlanking_o) begin
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
		
		if ((HPixelCount == 12'd799) && VGE_Engine_VBlanking_o && !Mstr_Ctrl_Video_Mode_i[1])
					Time_Line_2_LUT_2_FinalLine <= 4'b1111;					//<<<<<<<<
			
		if ((HPixelCount == 12'd1055) && VGE_Engine_VBlanking_o && Mstr_Ctrl_Video_Mode_i[1])
					Time_Line_2_LUT_2_FinalLine <= 4'b1111;					//<<<<<<<<			
	end
end

endmodule

