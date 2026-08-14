
`timescale 1 ns / 1 ns
module BitMap_Layer_System 
(
input		wire				TransferClk_i,
input		wire				Vid_Clk,
input		wire				Mem_Clk,
input		wire				Rst_i,

input		wire				VideoRst_i,
input		wire	[11:0]	HLineCount_i,
input		wire	[11:0]	HPixelCount_i,
input		wire				VBlanking_i,
input		wire				HBlanking_i,
input		wire				Vertical_Border_i,
input		wire				Horizontal_Border_i,
input		wire				Horizontal_Precharge_i,

input		wire	[11:0]	Total_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Total_Line_Per_Image_Value_i,
input		wire	[11:0]	H_Blanking_Value_i,
input		wire	[11:0]	V_Blanking_Value_i,
input		wire	[11:0]	Visible_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Visible_Line_Per_Line_Value_i,
input		wire				VideoModeReset_i,


output	wire	[31:0]	IID_Engine_RGB_Pixel_o,

input		wire	[7:0]		Background_Blue_i,
input		wire	[7:0]		Background_Green_i,
input		wire	[7:0]		Background_Red_i,
// 1 Pulse Start Of Frame (8 Pixel Long)
input		wire				SOF_i,

input		wire				IID_Engine_Captured_Lines_Done_i,
// This is the Interface from Exterior Mem to Dual Port
// Layer System Signals
input		wire	[7:0]		IID_Engine_EffectChannel_BM_ADDY_i,
input		wire	[7:0]		IID_Engine_EffectChannel_TL_ADDY_i,
input		wire	[9:0]		IID_Engine_EffectChannel_SP_ADDY_i,
input		wire			 	IID_Engine_BM_WE_i,			// Bitmap
input		wire			 	IID_Engine_TL3_WE_i,			// Tile Layer 3 - Is 
input		wire			 	IID_Engine_TL2_WE_i,			// Tile Layer 2
input		wire			 	IID_Engine_TL1_WE_i,			// Tile Layer 1
input		wire			 	IID_Engine_TL0_WE_i,			// Tile Layer 0 - Is always More Priority
input		wire			 	IID_Engine_SP0_WE_i,			// Front Sprite
input		wire			 	IID_Engine_SP1_WE_i,			// In-Between Sprite BM - TL3
input		wire			 	IID_Engine_SP2_WE_i,			// In-Between Sprite TL3 - TL2
input		wire			 	IID_Engine_SP3_WE_i,			// In-Between Sprite TL2 - TL1
input		wire			 	IID_Engine_SP4_WE_i,			// In-Between Sprite TL1 - TL0
input		wire  [31:0]	Mem2PixelLine_Data_BM_i,	// [15:0] - Since it is the while line we write, then 15Bits at the time works
input		wire  [31:0]	Mem2PixelLine_Data_TL_i,	// [15:0] - Since it is the while line we write, then 15Bits at the time works
input		wire  [7:0]		Mem2PixelLine_Data_SP_i,	// [7:0] - This can't work with Sprites, so the state machine will have to fetch data and place it @ the byte level
//
input		wire	[4:0]		Sprite_Select_i,
input		wire	[7:0]		Sprite_Control_Reg_i,
	
input		wire	[1:0]		Tile_Layer_Select_i,
input		wire	[7:0]		Tile_Layer_Control_Reg_i,
//
input		wire	[2:0]		LUT_BM_i,
input		wire	[2:0]		LUT_TM0_i,
input		wire	[2:0]		LUT_TM1_i,
input		wire	[2:0]		LUT_TM2_i,
input		wire	[2:0]		LUT_TM3_i,
input		wire	[2:0]		LUT_SP0_i,
input		wire	[2:0]		LUT_SP1_i,
input		wire	[2:0]		LUT_SP2_i,
input		wire	[2:0]		LUT_SP3_i,
input		wire	[2:0]		LUT_SP4_i,

input		wire	[3:0]		LUT_TM0_X_OFFSET_i,
input		wire	[3:0]		LUT_TM1_X_OFFSET_i,
input		wire	[3:0]		LUT_TM2_X_OFFSET_i,
input		wire	[3:0]		LUT_TM3_X_OFFSET_i,

// CPU Interface to the 8 Look-Up Tables
input 	wire				Bus_Clk_i,
input 	wire	[23:0]	Bus_A_i,
input		wire  [7:0]		Bus_D_i,
input		wire				Bus_RW_i,
input		wire				CS_LUT0_i,
input		wire				CS_LUT1_i,
input		wire				CS_LUT2_i,
input		wire				CS_LUT3_i,
input		wire				CS_LUT4_i,
input		wire				CS_LUT5_i,
input		wire				CS_LUT6_i,
input		wire				CS_LUT7_i,

output	wire	[7:0]		Lut0_Data_o,
output	wire	[7:0]		Lut1_Data_o,
output	wire	[7:0]		Lut2_Data_o,
output	wire	[7:0]		Lut3_Data_o,
output	wire	[7:0]		Lut4_Data_o,
output	wire	[7:0]		Lut5_Data_o,
output	wire	[7:0]		Lut6_Data_o,
output	wire	[7:0]		Lut7_Data_o
);



wire	[11:0]	Layer_Pixel_Out9;	// BM
wire	[11:0]	Layer_Pixel_Out8;	// SP4
wire	[11:0]	Layer_Pixel_Out7; // TL3
wire	[11:0]	Layer_Pixel_Out6; // SP3
wire	[11:0]	Layer_Pixel_Out5; // TL2
wire	[11:0]	Layer_Pixel_Out4; // SP2
wire	[11:0]	Layer_Pixel_Out3; // TL1
wire	[11:0]	Layer_Pixel_Out2; // SP1
wire	[11:0]	Layer_Pixel_Out1; // TL0
wire	[11:0]	Layer_Pixel_Out0; // SP0

reg	[9:0]		Layer_Scan_Address;
reg	[11:0]	DisplayedPixelOut;
reg   [11:0]	DisplayedPixelOut_Latency;

wire	[31:0]	LUT0_RGB_Pixel_Output;
wire	[31:0]	LUT1_RGB_Pixel_Output;
wire	[31:0]	LUT2_RGB_Pixel_Output;
wire	[31:0]	LUT3_RGB_Pixel_Output;
wire	[31:0]	LUT4_RGB_Pixel_Output;
wire	[31:0]	LUT5_RGB_Pixel_Output;
wire	[31:0]	LUT6_RGB_Pixel_Output;
wire	[31:0]	LUT7_RGB_Pixel_Output;
reg	[31:0]	ChosenPixel;




Graphic_PIxel_Layer_Line Layer9(.rdaddress( Layer_Scan_Address ), .rdclock( TransferClk_i ), .q( Layer_Pixel_Out9[7:0] ), .data( Mem2PixelLine_Data_BM_i ), .wraddress( IID_Engine_EffectChannel_BM_ADDY_i ), .wrclock( Mem_Clk ), .wren( IID_Engine_BM_WE_i ));
//Pixel_Layer_Line_Sprite LayerA(.data( Mem2PixelLine_Data_SP_i ), .rdaddress( Layer_Scan_Address ), .rdclock( TransferClk_i ), .wraddress( IID_Engine_EffectChannel_SP_ADDY_i ), .wrclock( TransferClk_i ), .wren( IID_Engine_SP4_WE_i ),.q( Layer_Pixel_Out8[7:0] ));
Graphic_PIxel_Layer_Line Layer7(.rdaddress( Layer_Scan_Address ), .rdclock( TransferClk_i ), .q( Layer_Pixel_Out7[7:0] ), .data( Mem2PixelLine_Data_TL_i ), .wraddress( IID_Engine_EffectChannel_TL_ADDY_i ), .wrclock( Mem_Clk ), .wren( IID_Engine_TL3_WE_i ));
//Pixel_Layer_Line_Sprite LayerB(.data( Mem2PixelLine_Data_SP_i ), .rdaddress( Layer_Scan_Address ), .rdclock( TransferClk_i ), .wraddress( IID_Engine_EffectChannel_SP_ADDY_i ), .wrclock( TransferClk_i ), .wren( IID_Engine_SP3_WE_i ),.q( Layer_Pixel_Out6[7:0] ));
Graphic_PIxel_Layer_Line Layer5(.rdaddress( Layer_Scan_Address ), .rdclock( TransferClk_i ), .q( Layer_Pixel_Out5[7:0] ), .data( Mem2PixelLine_Data_TL_i ), .wraddress( IID_Engine_EffectChannel_TL_ADDY_i ), .wrclock( Mem_Clk ), .wren( IID_Engine_TL2_WE_i ));
//Pixel_Layer_Line_Sprite LayerC(.data( Mem2PixelLine_Data_SP_i ), .rdaddress( Layer_Scan_Address ), .rdclock( TransferClk_i ), .wraddress( IID_Engine_EffectChannel_SP_ADDY_i ), .wrclock( TransferClk_i ), .wren( IID_Engine_SP2_WE_i ),.q( Layer_Pixel_Out4[7:0] ));
Graphic_PIxel_Layer_Line Layer3(.rdaddress( Layer_Scan_Address ), .rdclock( TransferClk_i ), .q( Layer_Pixel_Out3[7:0] ), .data( Mem2PixelLine_Data_TL_i ), .wraddress( IID_Engine_EffectChannel_TL_ADDY_i ), .wrclock( Mem_Clk ), .wren( IID_Engine_TL1_WE_i ));
//Pixel_Layer_Line_Sprite LayerD(.data( Mem2PixelLine_Data_SP_i ), .rdaddress( Layer_Scan_Address ), .rdclock( TransferClk_i ), .wraddress( IID_Engine_EffectChannel_SP_ADDY_i ), .wrclock( TransferClk_i ), .wren( IID_Engine_SP1_WE_i ),.q( Layer_Pixel_Out2[7:0] ));
Graphic_PIxel_Layer_Line Layer1(.rdaddress( Layer_Scan_Address ), .rdclock( TransferClk_i ), .q( Layer_Pixel_Out1[7:0] ), .data( Mem2PixelLine_Data_TL_i ), .wraddress( IID_Engine_EffectChannel_TL_ADDY_i ), .wrclock( Mem_Clk ), .wren( IID_Engine_TL0_WE_i ));

Pixel_Layer_Line_Sprite Layer0(.data( Mem2PixelLine_Data_SP_i ), .rdaddress( Layer_Scan_Address ), .rdclock( TransferClk_i ), .wraddress( IID_Engine_EffectChannel_SP_ADDY_i ), .wrclock( TransferClk_i ), .wren( IID_Engine_SP0_WE_i ),.q( Layer_Pixel_Out0[7:0] ));


// Interstial Sprite Not Used Now
//assign Layer_Pixel_Out7[7:0] = 8'h00;
//assign Layer_Pixel_Out5[7:0] = 8'h00;
//assign Layer_Pixel_Out3[7:0] = 8'h00;
//assign Layer_Pixel_Out1[7:0] = 8'h00;


assign Layer_Pixel_Out8[7:0] = 8'h00;
assign Layer_Pixel_Out6[7:0] = 8'h00;
assign Layer_Pixel_Out4[7:0] = 8'h00;
assign Layer_Pixel_Out2[7:0] = 8'h00;

wire	[9:0] PixelPresent;

assign PixelPresent[9] = Layer_Pixel_Out0[7:0] ? 1'b1 : 1'b0;
assign PixelPresent[8] = Layer_Pixel_Out1[7:0] ? 1'b1 : 1'b0;
assign PixelPresent[7] = Layer_Pixel_Out2[7:0] ? 1'b1 : 1'b0;
assign PixelPresent[6] = Layer_Pixel_Out3[7:0] ? 1'b1 : 1'b0;
assign PixelPresent[5] = Layer_Pixel_Out4[7:0] ? 1'b1 : 1'b0;
assign PixelPresent[4] = Layer_Pixel_Out5[7:0] ? 1'b1 : 1'b0;
assign PixelPresent[3] = Layer_Pixel_Out6[7:0] ? 1'b1 : 1'b0;
assign PixelPresent[2] = Layer_Pixel_Out7[7:0] ? 1'b1 : 1'b0;
assign PixelPresent[1] = Layer_Pixel_Out8[7:0] ? 1'b1 : 1'b0;
assign PixelPresent[0] = Layer_Pixel_Out9[7:0] ? 1'b1 : 1'b0;



always @ *
begin
	casex (PixelPresent)
		10'b1x_xxxx_xxxx: DisplayedPixelOut = {1'b0, LUT_SP0_i, Layer_Pixel_Out0[7:0]};
		10'b01_xxxx_xxxx: DisplayedPixelOut = {1'b0, LUT_TM0_i, Layer_Pixel_Out1[7:0]};
		10'b00_1xxx_xxxx: DisplayedPixelOut = {1'b0, LUT_SP1_i, Layer_Pixel_Out2[7:0]};
		10'b00_01xx_xxxx: DisplayedPixelOut = {1'b0, LUT_TM1_i, Layer_Pixel_Out3[7:0]};
		10'b00_001x_xxxx: DisplayedPixelOut = {1'b0, LUT_SP2_i, Layer_Pixel_Out4[7:0]};
		10'b00_0001_xxxx: DisplayedPixelOut = {1'b0, LUT_TM2_i, Layer_Pixel_Out5[7:0]};
		10'b00_0000_1xxx: DisplayedPixelOut = {1'b0, LUT_SP3_i, Layer_Pixel_Out6[7:0]};
		10'b00_0000_01xx: DisplayedPixelOut = {1'b0, LUT_TM3_i, Layer_Pixel_Out7[7:0]};
		10'b00_0000_001x: DisplayedPixelOut = {1'b0, LUT_SP4_i, Layer_Pixel_Out8[7:0]};
		10'b00_0000_0001: DisplayedPixelOut = {1'b0, LUT_BM_i, Layer_Pixel_Out9[7:0]};
		10'b00_0000_0000: DisplayedPixelOut = {1'b1, 3'b000, 8'b0000_0000};
		default: begin end
	endcase

end





reg	[3:0]	WriteEnableLatency;
// Delay the Pixel Attributes
always @ (posedge TransferClk_i)
begin
	DisplayedPixelOut_Latency <= DisplayedPixelOut;
	
	WriteEnableLatency[0] <= Read_Pixel_Lines;
	WriteEnableLatency[1] <= WriteEnableLatency[0];
	WriteEnableLatency[2] <= WriteEnableLatency[1];
//	WriteEnableLatency[3] <= WriteEnableLatency[2];	
end

/*
assign DisplayedPixelOut  = 	( Layer_Pixel_Out0[7:0] ) ? Layer_Pixel_Out0 :
										( Layer_Pixel_Out1[7:0] ) ? Layer_Pixel_Out1 :
										( Layer_Pixel_Out2[7:0] ) ? Layer_Pixel_Out2 :
										( Layer_Pixel_Out3[7:0] ) ? Layer_Pixel_Out3 :
										( Layer_Pixel_Out4[7:0] ) ? Layer_Pixel_Out4 :
										( Layer_Pixel_Out5[7:0] ) ? Layer_Pixel_Out5 :
										( Layer_Pixel_Out6[7:0] ) ? Layer_Pixel_Out6 :
										( Layer_Pixel_Out7[7:0] ) ? Layer_Pixel_Out7 :
										( Layer_Pixel_Out8[7:0] ) ? Layer_Pixel_Out8 : Layer_Pixel_Out9;

assign DisplayedPixelOut  = 	( Layer_Pixel_Out0[7:0] ) ? Layer_Pixel_Out0 :
										( Layer_Pixel_Out1[7:0] ) ? Layer_Pixel_Out1 :
										( Layer_Pixel_Out3[7:0] ) ? Layer_Pixel_Out3 :
										( Layer_Pixel_Out5[7:0] ) ? Layer_Pixel_Out5 :
										( Layer_Pixel_Out7[7:0] ) ? Layer_Pixel_Out7 : Layer_Pixel_Out9;
*/


// Look-up Table Choice
//assign ChosenPixel		=  (DisplayedPixelOut_Dly[10:8] == 3'b000) ? LUT0_RGB_Pixel_Output :
//									(DisplayedPixelOut_Dly[10:8] == 3'b001) ? LUT1_RGB_Pixel_Output :
//									(DisplayedPixelOut_Dly[10:8] == 3'b010) ? LUT2_RGB_Pixel_Output : LUT3_RGB_Pixel_Output;
//									(DisplayedPixelOut_Dly[10:8] == 3'b011) ? LUT3_RGB_Pixel_Output :
//									(DisplayedPixelOut_Dly[10:8] == 3'b100) ? LUT4_RGB_Pixel_Output :
//									(DisplayedPixelOut_Dly[10:8] == 3'b101) ? LUT5_RGB_Pixel_Output :
//									(DisplayedPixelOut_Dly[10:8] == 3'b110) ? LUT6_RGB_Pixel_Output : LUT7_RGB_Pixel_Output;
									

always @ *
begin
	if (DisplayedPixelOut_Latency[11]) begin
		ChosenPixel = {8'b0000_0000, Background_Red_i, Background_Green_i, Background_Blue_i};
	end
	else begin
		case (DisplayedPixelOut_Latency[10:8])
		3'b000: ChosenPixel = LUT0_RGB_Pixel_Output;
		3'b001: ChosenPixel = LUT1_RGB_Pixel_Output;
		3'b010: ChosenPixel = LUT2_RGB_Pixel_Output;
		3'b011: ChosenPixel = LUT3_RGB_Pixel_Output;
		3'b100: ChosenPixel = LUT4_RGB_Pixel_Output;
		3'b101: ChosenPixel = LUT5_RGB_Pixel_Output;
		3'b110: ChosenPixel = LUT6_RGB_Pixel_Output;
		3'b111: ChosenPixel = LUT7_RGB_Pixel_Output;
		default: begin end
		endcase
	end
end									


reg	[3:0] 	PIXEL_TF_SM;
reg				Read_Pixel_Lines;
reg	[9:0]	 	Memory_Pixel_Pointer;
reg			 	Memory_WriteEnable;
//reg				IID_Engine_Captured_Lines_Done_EDGE;

localparam		IDLE 			= 4'b0000,
					READ 			= 4'b0001,
					READ_LAT0	= 4'b0010,
					READ_LAT1	= 4'b0011,
					READ_LAT2	= 4'b0100,	
					LOOP 			= 4'b0101,
					WRITE			= 4'b0110,
					WRITE_LAT0  = 4'b0111,
					WRITE_LAT1  = 4'b1000,
					WRITE_LAT2  = 4'b1001,
					DONE			= 4'b1010;
						


always @ (posedge TransferClk_i)
begin
	if (Read_Pixel_Lines)
		Layer_Scan_Address <= Layer_Scan_Address + 10'b00_0000_0001;
	else
		Layer_Scan_Address <= 10'b00_0000_0000;
		
	if (WriteEnableLatency[2])
		Memory_Pixel_Pointer <= Memory_Pixel_Pointer + 10'b00_0000_0001;
	else
		Memory_Pixel_Pointer <=  10'b00_0000_0000;
		
	//IID_Engine_Captured_Lines_Done_EDGE <= IID_Engine_Captured_Lines_Done_i;
end


reg [15:0] Horizontal_Border_i_EDGE;

//reg	[11:0]	HPixelCount_i_EDGE0;
//reg	[11:0]	HPixelCount_i_EDGE1;

always @ (posedge TransferClk_i)
begin
//		Horizontal_Border_i_EDGE[0] <= HBlanking_i; //HBlanking_i;
//		Horizontal_Border_i_EDGE[1] <= Horizontal_Border_i_EDGE[0];
//		Horizontal_Border_i_EDGE[2] <= Horizontal_Border_i_EDGE[1];

		Horizontal_Border_i_EDGE <= {Horizontal_Border_i_EDGE[15:1], HBlanking_i} << 1'b1;
end


// This is the Process to Transfer Line Pixels in Output RGB Pixel Line
always @ (posedge TransferClk_i)
begin
	if (Rst_i | VideoModeReset_i) begin
		PIXEL_TF_SM <= IDLE;
		Read_Pixel_Lines <= 1'b0;
	end
	else begin
	
		case (PIXEL_TF_SM)
		
		IDLE: begin
			//if ({IID_Engine_Captured_Lines_Done_EDGE, IID_Engine_Captured_Lines_Done_i} == 2'b01) begin
			if (Horizontal_Border_i_EDGE[15:0] == 16'hFFF0) begin
				Read_Pixel_Lines <= 1'b1;
				PIXEL_TF_SM <= WRITE;
			end
			else begin
//				Memory_WriteEnable <= 1'b0;
				Read_Pixel_Lines <= 1'b0;
				PIXEL_TF_SM <= IDLE;
			end
		end
/*	
		READ: begin
			PIXEL_TF_SM <= READ_LAT0;
		
		end
		
		READ_LAT0: begin
			PIXEL_TF_SM <= READ_LAT1;	
		
		end
		
		READ_LAT1: begin
			PIXEL_TF_SM <= READ_LAT2;
		end
		
		READ_LAT2: begin
			PIXEL_TF_SM <= WRITE;				
//			Memory_WriteEnable <= 1'b1;
		end
	*/
		
		WRITE: begin
			if (Memory_Pixel_Pointer < Visible_Pixel_Per_Line_Value_i)
					PIXEL_TF_SM <= WRITE;
			else begin
					PIXEL_TF_SM <= DONE;
					Read_Pixel_Lines <= 1'b0;		
			end
		end
/*	
		WRITE_LAT0: begin
			PIXEL_TF_SM <= WRITE_LAT1;		
		end
		
		
		WRITE_LAT1: begin
			PIXEL_TF_SM <= WRITE_LAT2;	
		end
		
		WRITE_LAT2: begin
			PIXEL_TF_SM <= DONE;
			Memory_WriteEnable <= 1'b0;	
		end
*/
		
		DONE: begin
			PIXEL_TF_SM <= IDLE;		
		end
		
		
		default: begin
			PIXEL_TF_SM <= IDLE;
		end
		
		
		endcase
	end
end

//wire [7:0] LUT0_B, LUT0_G, LUT0_R;
//wire [7:0] LUT1_B, LUT1_G, LUT1_R;
//wire [7:0] LUT2_B, LUT2_G, LUT2_R;
//wire [7:0] LUT3_B, LUT3_G, LUT3_R;

//LUT_1Channel LUT0_BLUE(.data(  Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),  .wrclock(!Bus_Clk_i),	.wren(CS_LUT0_i & !Bus_RW_i & Bus_Clk_i & {Bus_A_i[1:0] == 2'b00}),	.q( LUT0_B ));
//LUT_1Channel LUT0_GREEN(.data( Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT0_i & !Bus_RW_i & Bus_Clk_i & {Bus_A_i[1:0] == 2'b01}),	.q( LUT0_G ));
//LUT_1Channel LUT0_RED(.data(   Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT0_i & !Bus_RW_i & Bus_Clk_i & {Bus_A_i[1:0] == 2'b10}),	.q( LUT0_R ));
//assign LUT0_RGB_Pixel_Output = {8'b0000_0000, LUT0_R, LUT0_G, LUT0_B};
//LUT_1Channel LUT1_BLUE(.data(  Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT1_i & !Bus_RW_i & Bus_Clk_i & {Bus_A_i[1:0] == 2'b00}),	.q( LUT1_B ));
//LUT_1Channel LUT1_GREEN(.data( Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT1_i & !Bus_RW_i & Bus_Clk_i & {Bus_A_i[1:0] == 2'b01}),	.q( LUT1_G ));
//LUT_1Channel LUT1_RED(.data(   Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT1_i & !Bus_RW_i & Bus_Clk_i & {Bus_A_i[1:0] == 2'b10}),	.q( LUT1_R ));
//assign LUT1_RGB_Pixel_Output = {8'b0000_0000, LUT1_R, LUT1_G, LUT1_B};
//LUT_1Channel LUT2_BLUE(.data(  Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT2_i & !Bus_RW_i & Bus_Clk_i &  {Bus_A_i[1:0] == 2'b00}),	.q( LUT2_B ));
//LUT_1Channel LUT2_GREEN(.data( Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT2_i & !Bus_RW_i & Bus_Clk_i &  {Bus_A_i[1:0] == 2'b01}),	.q( LUT2_G ));
//LUT_1Channel LUT2_RED(.data(   Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT2_i & !Bus_RW_i & Bus_Clk_i &  {Bus_A_i[1:0] == 2'b10}),	.q( LUT2_R ));
//assign LUT2_RGB_Pixel_Output = {8'b0000_0000, LUT2_R, LUT2_G, LUT2_B};
//LUT_1Channel LUT3_BLUE(.data(  Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT3_i & !Bus_RW_i & Bus_Clk_i &  {Bus_A_i[1:0] == 2'b00}),	.q( LUT3_B ));
//LUT_1Channel LUT3_GREEN(.data( Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT3_i & !Bus_RW_i & Bus_Clk_i &  {Bus_A_i[1:0] == 2'b01}),	.q( LUT3_G ));
//LUT_1Channel LUT3_RED(.data(   Bus_D_i ),	.rdaddress(DisplayedPixelOut[7:0]),	.rdclock(TransferClk_i) ,	.wraddress(Bus_A_i[9:2]),	.wrclock(!Bus_Clk_i),	.wren(CS_LUT3_i & !Bus_RW_i & Bus_Clk_i &  {Bus_A_i[1:0] == 2'b10}),	.q( LUT3_R ));
//assign LUT3_RGB_Pixel_Output = {8'b0000_0000, LUT3_R, LUT3_G, LUT3_B};


LUT32 LUT32_0(
	.data( Bus_D_i ),
	.rdaddress( DisplayedPixelOut[7:0] ),
	.rdclock( TransferClk_i ),
	.wraddress( Bus_A_i ),
	.wrclock( !Bus_Clk_i ),
	.wren( CS_LUT0_i & !Bus_RW_i ),
	.q( LUT0_RGB_Pixel_Output )
);

LUT32 LUT32_1(
	.data( Bus_D_i ),
	.rdaddress( DisplayedPixelOut[7:0] ),
	.rdclock( TransferClk_i ),
	.wraddress( Bus_A_i ),
	.wrclock( !Bus_Clk_i ),
	.wren( CS_LUT1_i & !Bus_RW_i ),
	.q( LUT1_RGB_Pixel_Output )
);

LUT32 LUT32_2(
	.data( Bus_D_i ),
	.rdaddress( DisplayedPixelOut[7:0] ),
	.rdclock( TransferClk_i ),
	.wraddress( Bus_A_i ),
	.wrclock( !Bus_Clk_i ),
	.wren( CS_LUT2_i & !Bus_RW_i ),
	.q( LUT2_RGB_Pixel_Output )
);

LUT32 LUT32_3(
	.data( Bus_D_i ),
	.rdaddress( DisplayedPixelOut[7:0] ),
	.rdclock( TransferClk_i ),
	.wraddress( Bus_A_i ),
	.wrclock( !Bus_Clk_i ),
	.wren( CS_LUT3_i & !Bus_RW_i ),
	.q( LUT3_RGB_Pixel_Output )
);

// THis is the Output from
assign Lut0_Data_o = 8'hFF;
assign Lut1_Data_o = 8'hFF;
assign Lut2_Data_o = 8'hFF;
assign Lut3_Data_o = 8'hFF;
assign Lut4_Data_o = 8'hFF;
assign Lut5_Data_o = 8'hFF;
assign Lut6_Data_o = 8'hFF;
assign Lut7_Data_o = 8'hFF;

assign LUT4_RGB_Pixel_Output = 32'b00000000_00000000_00000000_00000000;
assign LUT5_RGB_Pixel_Output = 32'b00000000_00000000_00000000_00000000;
assign LUT6_RGB_Pixel_Output = 32'b00000000_00000000_00000000_00000000;
assign LUT7_RGB_Pixel_Output = 32'b00000000_00000000_00000000_00000000;

Final_RGB_Pixel_Line OUTPUT_RGB(
	.data( ChosenPixel ),
	.rdaddress( Video_Pixel_Pointer ),
	.rdclock( Vid_Clk ),
	
	.wraddress( Memory_Pixel_Pointer ),
	.wrclock( TransferClk_i ),
	.wren( WriteEnableLatency[2] ),
	.q( IID_Engine_RGB_Pixel_o )
);

reg	[9:0]		Video_Pixel_Pointer;

always @ (posedge Vid_Clk)
begin
	if ( VideoRst_i ) begin
		Video_Pixel_Pointer <= 10'b00_0000_0000;	
	end
	else begin
	
		if (VBlanking_i) begin
		
			if (HPixelCount_i == 12'b0000_0000_0010) begin
				Video_Pixel_Pointer <= 10'b00_0000_0000;
			end
			else begin
				if (HPixelCount_i > (H_Blanking_Value_i - 3))
					Video_Pixel_Pointer <= Video_Pixel_Pointer + 10'b00_0000_0001;			
			end
			
		end
		else 
		begin
			Video_Pixel_Pointer <= 10'b00_0000_0000;
		end
	end
end


endmodule

