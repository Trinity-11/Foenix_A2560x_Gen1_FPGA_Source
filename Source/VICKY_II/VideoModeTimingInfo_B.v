module VideoModeTimingInfo_B(

input		wire				VideoRst_i,
input		wire 				Video_Clk_i,
input		wire				PLL_Locked,
input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,

output	reg	[11:0]	Total_Pixel_Per_Line_Value_o,
output	reg	[11:0]	Total_Line_Per_Image_Value_o,
output	reg	[11:0]	H_Blanking_Value_o,
output	reg	[11:0]	V_Blanking_Value_o,
output	reg	[11:0]	Visible_Pixel_Per_Line_Value_o,
output	reg	[11:0]	Visible_Line_Per_Line_Value_o,

output	wire				VideoModeReset_o
);


reg	[1:0]	VideoMode;
reg	[31:0]	VideoMode_Reset_Slip;

assign VideoModeReset_o = VideoMode_Reset_Slip[31] | !PLL_Locked;

always @ (posedge Video_Clk_i)
begin
	if (VideoRst_i) begin

		VideoMode <= Mstr_Ctrl_Video_Mode_i;
		VideoMode_Reset_Slip <= 32'h0000_0000;
	end
	else begin
		VideoMode_Reset_Slip <= VideoMode_Reset_Slip << 1'b1;
	
		if ((VideoMode != Mstr_Ctrl_Video_Mode_i) && PLL_Locked) begin
			VideoMode <= Mstr_Ctrl_Video_Mode_i;
			VideoMode_Reset_Slip <= 32'hFFFF_FFFF;
		end
	
	end
end


always @ (*) begin
	case (Mstr_Ctrl_Video_Mode_i[1:0])

		// 640x480 @ 60Hz
		2'b00: begin 
			Total_Pixel_Per_Line_Value_o 		= 12'd800; //6355
			Total_Line_Per_Image_Value_o 		= 12'd525;
			H_Blanking_Value_o 					= 12'd160;	// 1271 Clocks @ Engine Clocks @ 200Mhz
			V_Blanking_Value_o 					= 12'd45;
			Visible_Pixel_Per_Line_Value_o 	= 12'd640;
			Visible_Line_Per_Line_Value_o 	= 12'd480;			
		end

		// 640 x 400 @ 70Hz
		2'b01: begin 
			Total_Pixel_Per_Line_Value_o 		= 12'd800; //6355
			Total_Line_Per_Image_Value_o 		= 12'd449;
			H_Blanking_Value_o 					= 12'd160;	// 1271 Clocks @ Engine Clocks @ 200Mhz
			V_Blanking_Value_o 					= 12'd49;
			Visible_Pixel_Per_Line_Value_o 	= 12'd640;
			Visible_Line_Per_Line_Value_o 	= 12'd400;
		end

		//800x600 @ 60Hz
		2'b10: begin 
			Total_Pixel_Per_Line_Value_o 		= 12'd1056; // 5280
			Total_Line_Per_Image_Value_o 		= 12'd628;
			H_Blanking_Value_o 					= 12'd256;  // 1280 Clocks Engine Clocks @ 200Mhz
			V_Blanking_Value_o 					= 12'd28;
			Visible_Pixel_Per_Line_Value_o 	= 12'd800;
			Visible_Line_Per_Line_Value_o 	= 12'd600;
		end

		//800x600 @ 60Hz
		2'b11: begin 
			Total_Pixel_Per_Line_Value_o 		= 12'd1056; // 5280
			Total_Line_Per_Image_Value_o 		= 12'd628;
			H_Blanking_Value_o 					= 12'd256;  // 1280 Clocks Engine Clocks @ 200Mhz
			V_Blanking_Value_o 					= 12'd28;
			Visible_Pixel_Per_Line_Value_o 	= 12'd800;
			Visible_Line_Per_Line_Value_o 	= 12'd600;
		end

		default: begin
		
		end
	
	endcase
end

endmodule
