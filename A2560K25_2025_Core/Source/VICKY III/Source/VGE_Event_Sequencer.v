`timescale 1ns/1ns
module VGE_Event_Sequencer (

input		wire				Reset_i,					// System Reset
input		wire				VideoRst_i,				// Reset of the Video System
input		wire				VideoModeReset_i,		// Reset When the Video is Changed

input		wire				VideoClk_i,
input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,

input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,

input		wire	[11:0]	HLineCount_i,
input		wire	[11:0]	HPixelCount_i,
input		wire				SOF_i,
input		wire				VBlanking_i,
input		wire				VGE_VBlanking_i,

output	wire				Time_Rd_Wr_Access_100Mhz_o,		// 100Mhz Clock Realm
output	wire				Time_Rd_Only_Access_100Mhz_o,	// 100Mhz Clock Realm
output	wire				Time_Trf_Pixels_2_Pixel_200Mhz_o,	// 200Mhz Clock
output	wire				Time_Erase_Pixels_Line_100Mhz_o,
output	wire				Time_2_Display_Line_VidClk_o,
output	wire	[1:0]		Time_2_Charge_TileMap_Lines_o
);
/*
reg	[11:0]		Local_HPixelCount;
always @ (posedge VideoClk_i ) 
begin
	if (VideoModeReset_i || VideoRst_i) begin
		Local_HPixelCount <= 12'h000;
	end
	else begin
		// Count from 0 to 1055
		if (Local_HPixelCount < (Mstr_Ctrl_Video_Mode_i[0] ? 12'd1055 : 12'd799)) begin
			Local_HPixelCount <= Local_HPixelCount + 12'h001;
		end
		else begin
			//HLineCount  <= HLineCount + 12'h001;
			Local_HPixelCount <= 12'h000;
		end
	end
end
*/

/*
always @ (*) begin
	if ( Mstr_Ctrl_Video_Mode_i[0] )	begin
		Total_Pixel_Per_Line_Value_o 		<= 12'd1056; // 5280
		Total_Line_Per_Image_Value_o 		<= 12'd628;
		H_Blanking_Value_o 					<= 12'd256;  // 1280 Clocks Engine Clocks @ 200Mhz
		V_Blanking_Value_o 					<= 12'd28;
		Visible_Pixel_Per_Line_Value_o 	<= 12'd800;
		Visible_Line_Per_Line_Value_o 	<= 12'd600;
	end
	else begin
		Total_Pixel_Per_Line_Value_o 		<= 12'd800; //6355
		Total_Line_Per_Image_Value_o 		<= 12'd525;
		H_Blanking_Value_o 					<= 12'd160;	// 1271 Clocks @ Engine Clocks @ 200Mhz
		V_Blanking_Value_o 					<= 12'd45;
		Visible_Pixel_Per_Line_Value_o 	<= 12'd640;
		Visible_Line_Per_Line_Value_o 	<= 12'd480;
	end
end
*/

reg	[1:0]		Time_RD_WR_Strobe_RESYNC;
reg	[1:0]		Time_RD_Only_Strobe_RESYNC;
reg	[1:0]		Time_Line_2_LUT_2_FinalLine_RESYNC;
reg	[1:0]		Time_Line_Erasure_RESYNC;
reg	[1:0]		Charge_Tile_Lines_RESYNC[0:1];


always @ (posedge EngineClk100Mhz_i) 
begin
	Time_RD_WR_Strobe_RESYNC[0] 	<= Time_RD_WR_Strobe;
	Time_RD_WR_Strobe_RESYNC[1] 	<= Time_RD_WR_Strobe_RESYNC[0];
	
	Time_RD_Only_Strobe_RESYNC[0] <= Time_RD_Only_Strobe[3];
	Time_RD_Only_Strobe_RESYNC[1] <= Time_RD_Only_Strobe_RESYNC[0];

	Time_Line_Erasure_RESYNC[0] 	<= Time_Line_Erasure[3];
	Time_Line_Erasure_RESYNC[1] 	<= Time_Line_Erasure_RESYNC[0];
	
	Charge_Tile_Lines_RESYNC[0][1:0]	<= Charge_Tile_Lines[1:0];
	Charge_Tile_Lines_RESYNC[1][1:0] <=	Charge_Tile_Lines_RESYNC[0][1:0];
	
end

assign Time_Rd_Wr_Access_100Mhz_o 		= Time_RD_WR_Strobe_RESYNC[1];
assign Time_Rd_Only_Access_100Mhz_o		= Time_RD_Only_Strobe_RESYNC[1];
assign Time_Erase_Pixels_Line_100Mhz_o	= Time_Line_Erasure_RESYNC[1];
assign Time_2_Charge_TileMap_Lines_o   = Charge_Tile_Lines_RESYNC[1];

always @ (posedge EngineClk200Mhz_i) 
begin
	Time_Line_2_LUT_2_FinalLine_RESYNC[0] <=  Time_Line_2_LUT_2_FinalLine[3];
	Time_Line_2_LUT_2_FinalLine_RESYNC[1] <= 	Time_Line_2_LUT_2_FinalLine_RESYNC[0];	
end

assign Time_Trf_Pixels_2_Pixel_200Mhz_o = Time_Line_2_LUT_2_FinalLine_RESYNC[1];
assign Time_2_Display_Line_VidClk_o = Time_Start_Display_Line;

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
	if (VideoRst_i || VideoModeReset_i) begin
		Visible_Local_Line_Counter		<= 10'b00_0000_0000;
	end
	else begin
		if (Time_Line_2_LUT_2_FinalLine[3:0] == 4'b1111) begin
			Visible_Local_Line_Counter <= Visible_Local_Line_Counter + 10'h001;
		end
		else begin
			if (!VGE_VBlanking_i)
				Visible_Local_Line_Counter		<= 10'b00_0000_0000;
		end
	end
end

always @ (posedge VideoClk_i) 
begin
	if (VideoRst_i || VideoModeReset_i) begin
				Charge_Tile_Lines <= 2'b00;	
	end
	else begin
		if (VGE_VBlanking_i && (Visible_Local_Line_Counter[3:0] == 4'b0000)) begin
			//if (HPixelCount_i < 12'd796) begin
			if (HPixelCount_i < 12'd796) begin			
				if (Visible_Local_Line_Counter == 10'd0)
					Charge_Tile_Lines <= 2'b11;
				else 
					Charge_Tile_Lines <= 2'b01;				
			end
			else begin
				Charge_Tile_Lines <= 2'b00;
			end
		end
		else begin
				Charge_Tile_Lines <= 2'b00;
		end
	end
end



// Video Clock - Clocked
always @ (posedge VideoClk_i) 
begin
	if (VideoRst_i || VideoModeReset_i) begin
		Time_RD_WR_Strobe 				<= 1'b0;
		Time_RD_Only_Strobe 				<= 4'b0000;
		Time_Line_2_LUT_2_FinalLine 	<= 4'b0000;
		Time_Line_Erasure 				<= 4'b0000;
		Time_Start_Display_Line 		<= 1'b0;
	end
	else begin
//			Time_RD_WR_Strobe 				<= Time_RD_WR_Strobe << 1'b1;
			Time_RD_Only_Strobe 				<= Time_RD_Only_Strobe << 1'b1;
			Time_Line_2_LUT_2_FinalLine 	<= Time_Line_2_LUT_2_FinalLine << 1'b1;
			Time_Line_Erasure 				<= Time_Line_Erasure << 1'b1;
//			Time_Start_Display_Line 		<= Time_Start_Display_Line << 1'b1;
	
			case (HPixelCount_i) 
				// Beginning of the Line
			//12'd0 : Time_RD_WR_Strobe <= 1'b1;
		
			// 640 x 480 Time to Erase the Line
			12'd110: begin
				if (VGE_VBlanking_i) begin
					if (Mstr_Ctrl_Video_Mode_i[0] == 1'b0)
						Time_Line_Erasure <= 4'b1111;
				end
			end

			// Video Start in 640x480
			12'd156: begin
				if (VBlanking_i) begin
					if (Mstr_Ctrl_Video_Mode_i[0] == 1'b0) begin
						Time_Start_Display_Line <= 1'b1;
						Time_RD_WR_Strobe <= 1'b0;
					end
				end
			end
			
			// 800 x 600 Time to Erase the Line			
			12'd180: begin
				if (VGE_VBlanking_i) begin
					if ( Mstr_Ctrl_Video_Mode_i[0] )
							Time_Line_Erasure <= 4'b1111;
					else
							Time_RD_Only_Strobe <= 4'b1111;
				end
			end			
		
			// To be Adujsted for the Latency
			// Video Start in 800x600
			12'd252: begin
				if ( VBlanking_i ) begin
					if (Mstr_Ctrl_Video_Mode_i[0]) begin
						Time_Start_Display_Line <= 1'b1;
						Time_RD_WR_Strobe <= 1'b0;						
					end
				end
			end
			
			// This is the Time Where the process of Fetching the information begins
			// 800 x 600 Mode
			12'd290: begin
				if (VGE_VBlanking_i) begin
					if (Mstr_Ctrl_Video_Mode_i[0]) begin
						Time_RD_Only_Strobe <= 4'b1111; 
					end
				end
			end
			
			12'd796: begin
				if ( VBlanking_i ) begin
					if (Mstr_Ctrl_Video_Mode_i[0] == 1'b0) begin
						Time_Start_Display_Line <= 1'b0;				
					end
				end
			end
			
			// 640x480 end of Line
			12'd799: begin 
				if (VGE_VBlanking_i) begin
					if (Mstr_Ctrl_Video_Mode_i[0] == 1'b0) begin
						Time_RD_WR_Strobe <= 1'b1;
						Time_Line_2_LUT_2_FinalLine <= 4'b1111;					
					end
				end
			end
			
			12'd1052: begin
				if ( VBlanking_i ) begin
						Time_Start_Display_Line <= 1'b0;				
					end
			end			
			
			// 800x600 end of Line		
			12'd1055: begin 
				if (VGE_VBlanking_i) begin
					Time_RD_WR_Strobe <= 1'b1;
					Time_Line_2_LUT_2_FinalLine <= 4'b1111;				
				end
			end
		
		default: begin end
		
		endcase
	end
end




/*
wire [95:0] ChipScope;
wire			Trigger;
//assign Trigger = VGE_Command_Write & (VGE_Command[21:0] == Sources[85:64]);

//assign Trigger = VRAM_READ_i & (CMD_TSF_ADDY == 21'h00_5800);
//assign Trigger = (VGE_Engine_SOP_SYNC[2:1] == 2'b01); //3 + 11 + 5

//assign Trigger = (VGE_Master_Engine_SM ==  BITMAP_PROCESS2);
assign Trigger = (HPixelCount_i == 12'h000) & VGE_VBlanking_i;

assign ChipScope[31:0] = 32'h0000_0000;
assign ChipScope[43:32] = Visible_Local_Line_Counter;
assign ChipScope[61:44] = 0;

assign ChipScope[62] = VGE_VBlanking_i;
assign ChipScope[63] = VBlanking_i;
assign ChipScope[64] = Time_RD_WR_Strobe;
assign ChipScope[65] = SOF_i;
assign ChipScope[67:66] = Mstr_Ctrl_Video_Mode_i;
assign ChipScope[79:68] = HLineCount_i;
assign ChipScope[91:80] = HPixelCount_i;
assign ChipScope[92] = Time_RD_Only_Strobe[3];
assign ChipScope[93] = Time_Line_2_LUT_2_FinalLine[3];
assign ChipScope[94] = Time_Line_Erasure[3];
assign ChipScope[95] = Time_Start_Display_Line;


//assign ChipScope[95:64] = State_Machine;

ChipScope	ChipScope_inst (
	.acq_clk ( VideoClk_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

*/


endmodule


// Boneyard
/*
always @ (posedge VideoClk_i) 
begin
	if (VideoRst_i || VideoModeReset_i) begin
		Time_RD_WR_Strobe 				<= 4'b0000;
		Time_RD_Only_Strobe 				<= 4'b0000;
		Time_Line_2_LUT_2_FinalLine 	<= 4'b0000;
		Time_Line_Erasure 				<= 4'b0000;
		Time_Start_Display_Line 		<= 4'b0000;
		Visible_Local_Line_Counter		<= 10'b00_0000_0000;
	end
	else begin
			Time_RD_WR_Strobe 				<= Time_RD_WR_Strobe << 1'b1;
			Time_RD_Only_Strobe 				<= Time_RD_Only_Strobe << 1'b1;
			Time_Line_2_LUT_2_FinalLine 	<= Time_Line_2_LUT_2_FinalLine << 1'b1;
			Time_Line_Erasure 				<= Time_Line_Erasure << 1'b1;
			Time_Start_Display_Line 		<= Time_Start_Display_Line << 1'b1;
	
			case (HPixelCount_i) 
				// Beginning of the Line
			//12'd0 : Time_RD_WR_Strobe <= 1'b1;
		
			// 640 x 480 Time to Erase the Line
			12'd110: begin
				if (VGE_VBlanking_i) begin
					if (Mstr_Ctrl_Video_Mode_i[0] = 1'b0)
							Time_Line_Erasure <= 4'b1111;
				
				end
			
			
				if (VGE_VBlanking_i) begin
					case ({ Visible_Local_Line_Counter[0], Mstr_Ctrl_Video_Mode_i[1:0] } )
						3'b000: Time_Line_Erasure <= 4'b1111;
						3'b100: Time_Line_Erasure <= 4'b1111;
						3'b010: Time_Line_Erasure <= 4'b1111;
					endcase
					
					if ()
					case ({ Visible_Local_Line_Counter[0], Mstr_Ctrl_Video_Mode_i[1:0] } )
						3'b000: Time_Line_Erasure <= 4'b1111;
						3'b100: Time_Line_Erasure <= 4'b1111;
						3'b010: Time_Line_Erasure <= 4'b1111;
					endcase							
			
				//if ((Mstr_Ctrl_Video_Mode_i[0] == 1'b0) && VGE_VBlanking_i) begin
//					Time_Line_Erasure <= 4'b1111; 
				end
			end

			// Video Start in 800x600
			12'd156: begin
				if (Mstr_Ctrl_Video_Mode_i[0] && VBlanking_i)  begin
					Time_Start_Display_Line <= 4'b1111; 
				end			
			end
			
			// 800 x 600 Time to Erase the Line			
			12'd180: begin
				// 800 x 600
				if (VGE_VBlanking_i) begin
					case ({ Visible_Local_Line_Counter[0], Mstr_Ctrl_Video_Mode_i[1:0] } )
						3'b001: Time_Line_Erasure <= 4'b1111;
						3'b101: Time_Line_Erasure <= 4'b1111;
						3'b011: Time_Line_Erasure <= 4'b1111;
					endcase
					
					case ({ Visible_Local_Line_Counter[0], Mstr_Ctrl_Video_Mode_i[1:0] } )
						3'b000: Time_RD_Only_Strobe <= 4'b1111; 
						3'b100: Time_RD_Only_Strobe <= 4'b1111;
						3'b010: Time_RD_Only_Strobe <= 4'b1111;
					endcase
				end
				//if (Mstr_Ctrl_Video_Mode_i[0] && VGE_VBlanking_i) begin
				//					Time_Line_Erasure <= 4'b1111; 
				// end
				
				// 640 x 480
				//if ((Mstr_Ctrl_Video_Mode_i[0] == 1'b0) && VGE_VBlanking_i) begin
					//Time_RD_Only_Strobe <= 4'b1111; // This is the Time Where the process of Fetching the information begins
				//end				
			end			
		
			// To be Adujsted for the Latency
			// Video Start in 640x480
			12'd252: begin
				if ((Mstr_Ctrl_Video_Mode_i[0] == 1'b0) && VBlanking_i) begin
					Time_Start_Display_Line <= 4'b1111;
				end
			end
			
			// This is the Time Where the process of Fetching the information begins
			// 800 x 600 Mode
			12'd290: begin
				if (VGE_VBlanking_i) begin
					case ({ Visible_Local_Line_Counter[0], Mstr_Ctrl_Video_Mode_i[1:0] } )
						3'b001: Time_RD_Only_Strobe <= 4'b1111; 
						3'b101: Time_RD_Only_Strobe <= 4'b1111;
						3'b011: Time_RD_Only_Strobe <= 4'b1111;
					endcase
				end
							
				//if (Mstr_Ctrl_Video_Mode_i[0] && VGE_VBlanking_i) begin
					//Time_RD_Only_Strobe <= 4'b1111; 
				//end			
			end
			
			// 640x480 end of Line
			12'd799: begin 
				if ((Mstr_Ctrl_Video_Mode_i[0] == 1'b0) && VGE_VBlanking_i) begin
					Time_RD_WR_Strobe <= 4'b1111;
					Time_Line_2_LUT_2_FinalLine <= 4'b1111;
				end
				
				if (Mstr_Ctrl_Video_Mode_i[0] == 1'b0) begin
					if ( VGE_VBlanking_i )  begin
						Visible_Local_Line_Counter <= Visible_Local_Line_Counter + 10'b00_0000_0001;
					end 
					else begin
						Visible_Local_Line_Counter		<= 10'b00_0000_0000;				
					end
				end
			end
			
			// 800x600 end of Line		
			12'd1055: begin 
				if ((Mstr_Ctrl_Video_Mode_i[0] == 1'b1) && VGE_VBlanking_i) begin
					Time_RD_WR_Strobe <= 4'b1111; 
					Time_Line_2_LUT_2_FinalLine <= 4'b1111;
				end
				
				if (Mstr_Ctrl_Video_Mode_i[0]) begin
					if (VGE_VBlanking_i) begin
						Visible_Local_Line_Counter <= Visible_Local_Line_Counter + 10'b00_0000_0001;
					end 
					else begin
						Visible_Local_Line_Counter		<= 10'b00_0000_0000;				
					end
				end
			end
		
		default: begin end
		
		endcase
	end
end

*/


