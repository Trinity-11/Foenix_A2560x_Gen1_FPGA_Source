module VIII_ModeTimingInfo_B_NEW(

input		wire				VideoRst_i,
input		wire 				Video_Clk_i,
input		wire				PLL_Locked,
input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,
input  		wire   				SOF_i,
output		reg		[11:0]		Total_Pixel_Per_Line_Value_o,
output		reg		[11:0]		Total_Line_Per_Image_Value_o,
output		reg		[11:0]		H_Blanking_Value_o,
output		reg		[11:0]		V_Blanking_Value_o,
output		reg		[11:0]		Visible_Pixel_Per_Line_Value_o,
output		reg		[11:0]		Visible_Line_Per_Line_Value_o,
output		wire				VideoModeReset_o
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


always @ ( posedge Video_Clk_i ) begin
	if ( VideoRst_i ) begin 
				// 1280x960
				Total_Pixel_Per_Line_Value_o 		<= 12'd1800; 	//1800 pixels
				Total_Line_Per_Image_Value_o 		<= 12'd1000;		//1000 Lines
				H_Blanking_Value_o 					<= 12'd520;	
				V_Blanking_Value_o 					<= 12'd40;
				Visible_Pixel_Per_Line_Value_o 		<= 12'd1280;
				Visible_Line_Per_Line_Value_o 		<= 12'd960;
	end 
	else begin 
		if ( SOF_i ) begin 
			if (Mstr_Ctrl_Video_Mode_i[0]) begin 	// Only Switch At the Start of Frame
					// 1280x1024
					Total_Pixel_Per_Line_Value_o 		<= 12'd1688; 	//1688 Pixels
					Total_Line_Per_Image_Value_o 		<= 12'd1066;     // 1066
					H_Blanking_Value_o 					<= 12'd408;		
					V_Blanking_Value_o 					<= 12'd42;
					Visible_Pixel_Per_Line_Value_o 		<= 12'd1280;
					Visible_Line_Per_Line_Value_o 		<= 12'd1024;			
				end
			else begin 
					// 1280x960
					Total_Pixel_Per_Line_Value_o 		<= 12'd1800; 	//1800 pixels
					Total_Line_Per_Image_Value_o 		<= 12'd1000;		//1000 Lines
					H_Blanking_Value_o 					<= 12'd520;	
					V_Blanking_Value_o 					<= 12'd40;
					Visible_Pixel_Per_Line_Value_o 		<= 12'd1280;
					Visible_Line_Per_Line_Value_o 		<= 12'd960;
			end
		end 
	end 
end

/*
always @ (*) begin
	if (Mstr_Ctrl_Video_Mode_i[0]) begin 
			// 1280x1024
			Total_Pixel_Per_Line_Value_o 		= 12'd1688; 	//1688 Pixels
			Total_Line_Per_Image_Value_o 		= 12'd1066;     // 1066
			H_Blanking_Value_o 					= 12'd408;		
			V_Blanking_Value_o 					= 12'd42;
			Visible_Pixel_Per_Line_Value_o 		= 12'd1280;
			Visible_Line_Per_Line_Value_o 		= 12'd1024;			
		end
	else begin 
			// 1280x960
			Total_Pixel_Per_Line_Value_o 		= 12'd1800; 	//1800 pixels
			Total_Line_Per_Image_Value_o 		= 12'd1000;		//1000 Lines
			H_Blanking_Value_o 					= 12'd520;	
			V_Blanking_Value_o 					= 12'd40;
			Visible_Pixel_Per_Line_Value_o 		= 12'd1280;
			Visible_Line_Per_Line_Value_o 		= 12'd960;
	end
end
*/

endmodule
