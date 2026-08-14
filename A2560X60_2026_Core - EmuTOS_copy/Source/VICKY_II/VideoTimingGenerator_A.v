
`timescale 1ns/1ns

module VideoTimingGenerator_A (	
input		wire				Reset_VideoClk_Full_Resolution,
input		wire				VideoClk_i,
input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,

input							Mstr_Ctrl_Video_Mode_i,
input							Mstr_Ctrl_Doubling_Pixel_i,

output 	reg				HSYNC_o,					//HD
output 	reg				VSYNC_o,					//VD

output	reg				HSync_Pol_o,
output	reg				VSync_Pol_o,

output 	wire	[11:0]  	HPixelCount_o,
output 	wire  [11:0]	HLineCount_o,

output						HBlanking_Latency_o,
output						HBlanking_o,
output 						VBlanking_o,
output 	wire				SOF_o,

output	wire	[15:0]	HBLANK_START_o,
output	wire	[15:0]	HBLANK_STOP_o
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

always @ (posedge VideoClk_i) begin

	if ( Mstr_Ctrl_Video_Mode_i ) begin
		// Horizontal
		HSYNC_START 	<= 16'd23;
		HSYNC_STOP 		<= 16'd159;
		HBLANK_START   <= 16'd319;
		HBLANK_STOP	 	<= 16'd1343;
		HSync_Pol_o    <= 1'b0;		
		// Vertical 
//		VTOTAL 			= 16'd805;
		VSYNC_START 	<= 24'd4031;
		VSYNC_STOP  	<= 24'd12095;
		VBLANK_START   <= 24'd51071;
		VBLANK_STOP    <= 24'd1083263;
		VSync_Pol_o    <= 1'b0;	
	end
	else begin
		// Horizontal
		HSYNC_START 	<= 16'd39;
		HSYNC_STOP 		<= 16'd167;
		HBLANK_START 	<= 16'd255;
		HBLANK_STOP 	<= 16'd1055;
		HSync_Pol_o	   <= 1'b1;
		// Vertical 
//		VTOTAL			= 16'd627;
		VSYNC_START		<= 24'd1055;
		VSYNC_STOP		<= 24'd5279;
		VBLANK_START   <= 24'd29567;
		VBLANK_STOP    <= 24'd663167;
		VSync_Pol_o	   <= 1'b1;	
	end
end

reg				DENA_VERTICAL;
reg 				DENA_HORIZONTAL;
reg 				DENA_HORIZONTAL_READ_LATENCY;
reg	[23:0]	PixelCounter;
reg	[15:0]	HBLANK_START_Dly;
//reg	[15:0]	HBLANK_START_VGE_Dly;
reg	[11:0]	HPixelLocal;

reg	[11:0]	HLineCount_Buf0;
reg	[11:0]	HLineCount_Buf1;
reg	[11:0]	HLineLocal;

assign 	VBlanking_o 				= DENA_VERTICAL;
assign	HBlanking_o 				= DENA_HORIZONTAL;
assign 	HBlanking_Latency_o 		= DENA_HORIZONTAL_READ_LATENCY;


reg [1:0]	Mstr_Ctrl_Video_Mode_ReSync;
reg [1:0]	Mstr_Ctrl_Video_Mode_ReSync_Bit1;

reg [2:0] 	Rst_rstn_reg;

always @ (posedge VideoClk_i)
begin
	if (Reset_VideoClk_Full_Resolution) begin
		Mstr_Ctrl_Video_Mode_ReSync[1:0] <= 2'b00;
	end
	else begin
		Mstr_Ctrl_Video_Mode_ReSync[0] <= Mstr_Ctrl_Video_Mode_i;
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
/*
// Delayed HBlank
always @ (posedge VideoClk_i)
begin
//	if (Reset_VideoClk_Full_Resolution || reset_mode) begin
	if ( Reset_VideoClk_Full_Resolution ) begin	

		HBLANK_START_VGE_Dly <= 16'h0000;
	end
	else begin
		if ( Mstr_Ctrl_Video_Mode_i )
			HBLANK_START_VGE_Dly <= HBLANK_START - 16'd8;		// Changed from 8 to 11
		else
			HBLANK_START_VGE_Dly <= HBLANK_START - 16'd5;		// Changed from 5 to 7
	end
end
*/

//wire reset_mode;

//assign reset_mode = ( Mstr_Ctrl_Video_Mode_ReSync[1:0] == 2'b10 ) || ( Mstr_Ctrl_Video_Mode_ReSync[1:0] == 2'b01 );


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
	end
	else begin
	
		// Count from 0 to 1055
		if (HPixelCount >= HBLANK_STOP) begin
			DENA_HORIZONTAL <= 1'b0;	
			DENA_HORIZONTAL_READ_LATENCY	<= 1'b0;
		end

		if (HPixelCount == HBLANK_START)
			DENA_HORIZONTAL <= 1'b1;

		if (HPixelCount == HBLANK_START_Dly)
			DENA_HORIZONTAL_READ_LATENCY <= 1'b1;
		
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
			PixelCounter <= PixelCounter + 24'h000001;

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
		DENA_VERTICAL <= 1'b0;
	end
	else begin
		if (PixelCounter == VBLANK_START)
			DENA_VERTICAL <= 1'b1;

		if (PixelCounter == VBLANK_STOP) begin
			DENA_VERTICAL <= 1'b0;
		end
	end
end			




endmodule

