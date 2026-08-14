module VICKY_III_VideoTimingParameters (

input		wire	[1:0]		Video_Mode_i,


output 	reg	[15:0]	HSYNC_START_o,		//40
output	reg	[15:0]	HSYNC_STOP_o, 		//168

output	reg	[15:0]	HBLANK_START_o, 	//1
output	reg	[15:0]	HBLANK_STOP_o,		//256

output	reg	[15:0]	VTOTAL_o, 			//628

output	reg	[23:0]	VSYNC_START_o,		//1
output	reg	[23:0]	VSYNC_STOP_o,		//5

output	reg	[23:0]	VBLANK_START_o,	//1
output	reg	[23:0]	VBLANK_STOP_o,		//28

output	reg				HSync_Pol_o,	// 0 = Negative, 1 = Positive
output	reg				VSync_Pol_o		// 0 = Negative, 1 = Positive
);


always @ (*) begin

	case (2'b00)
	
	// 640x480
	2'b00: begin
		// Horizontal
		HSYNC_START_o 	= 16'd15;
		HSYNC_STOP_o 	= 16'd111;
		HBLANK_START_o = 16'd159;
		HBLANK_STOP_o 	= 16'd799;
		HSync_Pol_o    = 1'b0;
		// Vertical 
		VTOTAL_o			= 16'd524;
		VSYNC_START_o	= 24'd7999;
		VSYNC_STOP_o	= 24'd9599;
		VBLANK_START_o = 24'd35999;
		VBLANK_STOP_o  = 24'd419999;
		VSync_Pol_o    = 1'b0;
	end
	
	// 800x600
	2'b01: begin
		// Horizontal
		HSYNC_START_o 	= 16'd39;
		HSYNC_STOP_o 	= 16'd167;
		HBLANK_START_o = 16'd255;
		HBLANK_STOP_o 	= 16'd1055;
		HSync_Pol_o    = 1'b1;
		// Vertical 
		VTOTAL_o			= 16'd627;
		VSYNC_START_o	= 24'd1055;
		VSYNC_STOP_o	= 24'd5279;
		VBLANK_START_o = 24'd29567;
		VBLANK_STOP_o  = 24'd663167;
		VSync_Pol_o	   = 1'b1;
	end
	
	//1024x768
	2'b10: begin
		// Horizontal
		HSYNC_START_o 	= 16'd23;
		HSYNC_STOP_o 	= 16'd183;
		HBLANK_START_o = 16'd319;
		HBLANK_STOP_o 	= 16'd1023;
		HSync_Pol_o    = 1'b0;		
		// Vertical 
		VTOTAL_o			= 16'd805;
		VSYNC_START_o	= 24'd4031;
		VSYNC_STOP_o	= 24'd12095;
		VBLANK_START_o = 24'd51071;
		VBLANK_STOP_o  = 24'd1083264;
		VSync_Pol_o    = 1'b0;		
	end
	
	// 640x400
	2'b11: begin
		// Horizontal
		HSYNC_START_o 	= 16'd15;
		HSYNC_STOP_o 	= 16'd111;
		HBLANK_START_o = 16'd159;
		HBLANK_STOP_o 	= 16'd799;
		HSync_Pol_o    = 1'b0;		
		// Vertical 
		VTOTAL_o			= 16'd448;
		VSYNC_START_o	= 24'd9599;
		VSYNC_STOP_o	= 24'd11199;
		VBLANK_START_o = 24'd39199;
		VBLANK_STOP_o  = 24'd359199;
		VSync_Pol_o	   = 1'b1;		
	end
	
	endcase
end


endmodule

