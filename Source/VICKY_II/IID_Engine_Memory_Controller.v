`timescale 1 ns / 1 ns

module IID_Engine_Memory_Controller (
input		wire				IID_Engine_Rst_i,
input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,
// Videa Signals to Enable the Engine
input		wire				IID_Engine_VideoClk_i,
input		wire				IID_Engine_VideoRst_i,
input		wire	[11:0]	IID_Engine_HLineCount_i,
input		wire	[11:0]	IID_Engine_HPixelCount_i,
input		wire				IID_Engine_VBlanking_i,
input		wire				IID_Engine_HBlanking_i,
input		wire				IID_Engine_SOF_i,
input		wire				IID_Engine_VBlankingSpecial_i,
input		wire				IID_Engine_Disable_VideoProcessing_i,

input		wire	[11:0]	Total_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Total_Line_Per_Image_Value_i,
input		wire	[11:0]	H_Blanking_Value_i,
input		wire	[11:0]	V_Blanking_Value_i,
input		wire	[11:0]	Visible_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Visible_Line_Per_Line_Value_i,
input		wire				VideoModeReset_i,
// VDMA PORT
input		wire	[7:0]		VDMA_Control_Reg_i,
input		wire	[7:0]		VDMA_Data_2_Write_i,
input		wire	[23:0]	VDMA_Src_Addy_i,
input		wire	[23:0]	VDMA_Dst_Addy_i,
input		wire	[15:0]	VDMA_X_Size_i,
input		wire	[15:0]	VDMA_Y_Size_i,
input		wire	[15:0]	VDMA_Src_Stride_i,
input		wire	[15:0]	VDMA_Dst_Stride_i,
output	wire	[7:0]		VDMA_Status_Reg_o,
output	wire				VDMA_Interrupt_o,
// CPU FIFO Port
input		wire	[31:0]	CPU_Access_Cmd_i,
output	reg				CPU_Access_Rd_Strobe_o,
input		wire				CPU_Access_CMD_Rd_Empty_i,
input		wire	[7:0]		CPU_Access_CMD_Number_i,
// State-Machines Status
output	wire				IID_Engine_Start_Process_o,			// Signal to Prime Each State-Machine.
output	wire				IID_Engine_Captured_Lines_Done_o,		// This is to activate the Transfer of Pixel
// BitMap
input		wire				IID_Engine_BM_Enable_i,
input		wire	[21:0]	IID_Engine_BM_MapStartAddress_i,	// We are Going to have only one address for now
input    wire	[9:0]		IID_Engine_BM_SizeX_i,
input		wire	[9:0]		IID_Engine_BM_SizeY_i,
// TILE
input		wire				Tile_Block_Enable_i,
output	wire	[1:0]		Tile_Layer_Select_o,
input		wire	[7:0]		Tile_Layer_Control_Reg_i,
input		wire	[23:0]	Tile_Layer_Address_Ptr_i,
input		wire	[11:0]	Tile_X_Stride_i,
input		wire	[11:0]	Tile_Y_Stride_i,
input		wire	[3:0]		Tile_X_Offset_i,
input		wire	[3:0]		Tile_Y_Offset_i,
output	wire	[2:0]		LUT_TM0_o,
output	wire	[2:0]		LUT_TM1_o,
output	wire	[2:0]		LUT_TM2_o,
output	wire	[2:0]		LUT_TM3_o,
// Access to the Tile Map Memory
output	wire	[12:0]	TileMapPointer_o,
input		wire	[7:0]		TileMap_Active2Tile_i, // 1 Bytes
// SPRITE
input		wire				Sprite_Block_Enable_i,
output	wire	[4:0]		Sprite_Select_o,
input		wire	[7:0]		Sprite_Control_Reg_i,
input		wire	[23:0]	Sprite_Address_Ptr_i,
input		wire	[15:0]	Sprite_X_Coordinate_i,
input		wire	[15:0]	Sprite_Y_Coordinate_i,
// Layer System Signals
output	reg	[8:0]		IID_Engine_EffectChannel_BM_ADDY_o,
output	reg	[8:0]		IID_Engine_EffectChannel_TL_ADDY_o,
output	wire	[9:0]		IID_Engine_EffectChannel_SP_ADDY_o,
output	reg			 	IID_Engine_BM_WE_o,			// Bitmap
output	wire			 	IID_Engine_TL3_WE_o,			// Tile Layer 3 - Is 
output	wire			 	IID_Engine_TL2_WE_o,			// Tile Layer 2
output	wire			 	IID_Engine_TL1_WE_o,			// Tile Layer 1
output	wire			 	IID_Engine_TL0_WE_o,			// Tile Layer 0 - Is always More Priority
output	wire			 	IID_Engine_SP0_WE_o,			// Front Sprite
output	wire			 	IID_Engine_SP1_WE_o,			// In-Between Sprite BM - TL3
output	wire			 	IID_Engine_SP2_WE_o,			// In-Between Sprite TL3 - TL2
output	wire			 	IID_Engine_SP3_WE_o,			// In-Between Sprite TL2 - TL1
output	wire			 	IID_Engine_SP4_WE_o,			// In-Between Sprite TL1 - TL0
output	wire  [31:0]	Mem2PixelLine_Data_BM_o,	// [15:0] - Since it is the while line we write, then 15Bits at the time works
output	wire  [31:0]	Mem2PixelLine_Data_TL_o,	// [15:0] - Since it is the while line we write, then 15Bits at the time works
output	wire  [7:0]		Mem2PixelLine_Data_SP_o,	// [7:0] - This can't work with Sprites, so the state machine will have to fetch data and place it @ the byte level

// Memory Interface
output	reg	[19:0]	VGE_Addy_o,	// 1Mx32
input		wire	[31:0]	VGE_VidMem_Data_i,
output	reg	[31:0]	VGE_VidMem_Data_o,
output	reg				VGE_VidMem_Readn_o,
output   reg	[3:0]		VGE_VidMem_Writen_o
);

reg			MemoryRead;
// No Writing right now

//assign IID_Engine_VidMemDataLo_o = IID_Engine_MEM_VID_WELn_o ? 8'h00 : MemoryWriteLowByte;
//assign IID_Engine_VidMemDataHi_o = IID_Engine_MEM_VID_WEHn_o ? 8'h00 : MemoryWriteHiByte;


reg				Bitmap_Active;
reg				Tile_Active;
reg				Sprite_Active;
reg	[31:0]	IID_Engine_Start_Process_SLIP;

reg	[9:0]		Pixel2FetchCounter_BM;
reg	[15:0]	Pixel2FetchCounter_TL;
reg	[4:0]		Pixel2FetchCounter_SP;
reg	[21:0]	CPU_Absolute_Addy;
reg	[21:0]	BM_Absolute_Addy;
reg	[21:0]   TL_Absolute_Addy;
reg	[21:0]	SP_Absolute_Addy;
reg	[21:0]	DMA_Absolute_Addy;

reg	[3:0]		IID_Engine_Captured_Lines_Done_Slip;
reg	[5:0]		TileMAP_X_Counter;		//64 Positions
reg	[4:0]		TileMAP_Y_Counter;		//32 Positions
reg				IID_Engine_TL_WE_o;
reg				IID_Engine_SP_WE_o;
reg	[9:0]		IID_Engine_EffectChannel_SP_ADDY;
reg	[2:0]		Sprite_Depth_Line_Select;

///////////////////////////////////////////
/// MEMORY PORTS SIGNAL MUX
///
///////////////////////////////////////////
reg	DMA_Read_Strobe_n;
//reg	CPU_Read_Strobe_n;
reg	BitMap_Read_Strobe_n;
reg	TileMap_Read_Strobe_n;
reg	Sprite_Read_Strobe_n;
reg	DMA_Write_L_Strobe_n;
reg	DMA_Write_H_Strobe_n;
//reg	CPU_Write_L_Strobe_n;
//reg	CPU_Write_H_Strobe_n;
reg 	Clear_PixelLine_BitMap;
reg 	Clear_PixelLine_TileMap;
reg 	Clear_PixelLine_Sprite;
initial begin
//	DMA_Read_Strobe_n 		= 1'b1;
//	CPU_Read_Strobe_n 		= 1'b1;
	BitMap_Read_Strobe_n 	= 1'b1;
	TileMap_Read_Strobe_n 	= 1'b1;
	Sprite_Read_Strobe_n 	= 1'b1;
//	DMA_Write_L_Strobe_n 	= 1'b1;
//	DMA_Write_H_Strobe_n 	= 1'b1;
//	CPU_Write_L_Strobe_n 	= 1'b1;
//	CPU_Write_H_Strobe_n 	= 1'b1;
	Tile_Active = 1'b0;
	Sprite_Active = 1'b0;
	IID_Engine_TL_WE_o = 1'b0;
	IID_Engine_SP_WE_o = 1'b0;
	Clear_PixelLine_BitMap = 1'b0;
	Clear_PixelLine_TileMap = 1'b0;
	Clear_PixelLine_Sprite = 1'b0;
end
reg	[2:0]			CPUCMD_TimeSlice_EDGE;
/*
wire	[63:0]	 Chipscope;
wire				Trigger;

assign Chipscope[31:0] = CPU_Access_Cmd_i;
assign Chipscope[39:32] = CPU_Access_CMD_Number_i;
assign Chipscope[40] = CPU_Access_CMD_Rd_Empty_i;
assign Chipscope[41] = CPU_Access_Rd_Strobe_o;
assign Chipscope[46:42] = IID_Master_Engine_SM;
assign Chipscope[47] = CPUCMD_TimeSlice_EDGE[1];
assign Chipscope[55:48] = IID_Engine_VidMemDataHi_o;
assign Chipscope[63:56] = IID_Engine_VidMemDataLo_o;

//assign Trigger = (IID_Master_Engine_SM == CPU_ACCESS0) ? 1'b1 : 1'b0;
assign Trigger = CPU_Access_Rd_Strobe_o;

ChipScope IntelChipScope(
		.acq_clk(EngineClk100Mhz_i),        //    acq_clk.clk
		.acq_data_in(Chipscope),    //        tap.acq_data_in
		.acq_trigger_in(Trigger), //           .acq_trigger_in
		.trigger_in(Trigger)      // trigger_in.trigger_in
	);
*/

///////////////////////////////////////////
/// CPU PORT SIGNALs
/// 
///////////////////////////////////////////
// Channel 0 - CPU/VDMA
// Channel 1 - Background (full 640 Pixel Fetch)
// Channel 2 - Tile (4 Layers of Character Graphic 16 x 16) @ the end of process, it will fill a full line too)
// Channel 3 - Sprite (32 Sprites) Generates Blocks of Graphics anywhere.



//assign IID_Engine_VidMemAddy_o = 	( EffectChannel[1:0] == 2'b00 ) ? (DMA_In_Progress ? Output_Dst_Addy[21:1] : CPU_Access_Cmd_i[21:1]) :					// This will end-up being DMA or CPU Access
//												( EffectChannel[1:0] == 2'b01 ) ? (BM_Absolute_Addy[21:1] + Pixel2FetchCounter_BM) :
//												( EffectChannel[1:0] == 2'b10 ) ? (TL_Absolute_Addy[21:1] + Pixel2FetchCounter_TL) : (SP_Absolute_Addy[21:1] + Pixel2FetchCounter_SP);
//												

always @ (*)
begin
	case ( EffectChannel[1:0] )
		2'b00: VGE_Addy_o = (DMA_In_Progress ? DMA_FILL_ADDY[21:2] : CPU_Access_Cmd_i[21:2]);
		2'b01: VGE_Addy_o = (BM_Absolute_Addy[21:2] + Pixel2FetchCounter_BM);
		2'b10: VGE_Addy_o = (TL_Absolute_Addy[21:2] + Pixel2FetchCounter_TL);
		2'b11: VGE_Addy_o = (SP_Absolute_Addy[21:2] + Pixel2FetchCounter_SP);
	endcase
end

always @ (*)
begin
	case ( EffectChannel[1:0] )
		2'b00: VGE_VidMem_Readn_o = (DMA_In_Progress ? !DMA_VMem_Read : !MemoryRead);
		2'b01: VGE_VidMem_Readn_o = BitMap_Read_Strobe_n;
		2'b10: VGE_VidMem_Readn_o = TileMap_Read_Strobe_n;
		2'b11: VGE_VidMem_Readn_o = Sprite_Read_Strobe_n;
	endcase
end



always @ (*)
begin
	case ( EffectChannel[1:0] )
		2'b00: VGE_VidMem_Writen_o = (DMA_In_Progress ? {!DMA_Fill_Write_Hi, !DMA_Fill_Write_Lo, !DMA_Fill_Write_Hi, !DMA_Fill_Write_Lo} : {!MemWriteByte3, !MemWriteByte2, !MemWriteByte1, !MemWriteByte0});
		2'b01: VGE_VidMem_Writen_o = 4'b1111;
		2'b10: VGE_VidMem_Writen_o = 4'b1111;
		2'b11: VGE_VidMem_Writen_o = 4'b1111;
	endcase
end

always @ (*)
begin

	if (DMA_In_Progress) begin
		VGE_VidMem_Data_o[7:0] 		= DMA_Data_2_Write_LL;
		VGE_VidMem_Data_o[15:8] 	= DMA_Data_2_Write_LH;
		VGE_VidMem_Data_o[23:16] 	= DMA_Data_2_Write_HL;
		VGE_VidMem_Data_o[31:24] 	= DMA_Data_2_Write_HH;
	end
	else begin	// WHen in CPU Mode - The Write Cycle will always be 1 Byte at the Time. 
		VGE_VidMem_Data_o[7:0] 		= CPU_Access_Cmd_i[31:24];
		VGE_VidMem_Data_o[15:8] 	= CPU_Access_Cmd_i[31:24];
		VGE_VidMem_Data_o[23:16] 	= CPU_Access_Cmd_i[31:24];
		VGE_VidMem_Data_o[31:24] 	= CPU_Access_Cmd_i[31:24];		
	end
end

assign Mem2PixelLine_Data_BM_o = Clear_PixelLine_BitMap ? 32'h0000_0000 : VGE_VidMem_Data_i;
assign Mem2PixelLine_Data_TL_o = Clear_PixelLine_TileMap ? 32'h0000_0000 : VGE_VidMem_Data_i;
assign Mem2PixelLine_Data_SP_o = Clear_PixelLine_Sprite ? 8'h00 : Pixel2StoreData;

reg	[7:0]	Pixel2StoreData;
reg			Pixel2Store_Write;
reg 	[4:0]	Sprite_Pixel_Pointer;		

/*
wire	[63:0]	 Chipscope;
wire				Trigger;

assign Chipscope[15:0] 		= {IID_Engine_VidMemDataLH_i, IID_Engine_VidMemDataLL_i};
assign Chipscope[23:16] 	= Mem2PixelLine_Data_SP_o;

assign Chipscope[24] 		= Sprite_Read_Strobe_n;
assign Chipscope[25]			= IID_Engine_SP0_WE_o;
assign Chipscope[26] 		= Sprite_Active;
assign Chipscope[27]			= Pixel2Store_Write;

assign Chipscope[53:49]    = Sprite_Pixel_Pointer;

assign Chipscope[63:54]		= IID_Engine_EffectChannel_SP_ADDY_o;


assign Trigger = Sprite_Read_Strobe_n;

ChipScope IntelChipScope(
		.acq_clk(EngineClk200Mhz_i),        //    acq_clk.clk
		.acq_data_in(Chipscope),    //        tap.acq_data_in
		.acq_trigger_in(Trigger), //           .acq_trigger_in
		.trigger_in(Trigger)      // trigger_in.trigger_in
	);
*/
reg	[31:0]	TempMemSprite[7:0];
reg	[3:0]		TempMemAddy;
always @ (posedge EngineClk100Mhz_i) 
begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
			TempMemSprite[0] <= 32'h0000_0000;
			TempMemSprite[1] <= 32'h0000_0000;
			TempMemSprite[2] <= 32'h0000_0000;
			TempMemSprite[3] <= 32'h0000_0000;
			TempMemSprite[4] <= 32'h0000_0000;
			TempMemSprite[5] <= 32'h0000_0000;
			TempMemSprite[6] <= 32'h0000_0000;
			TempMemSprite[7] <= 32'h0000_0000;			
//			TempMemSprite[8] <= 32'h0000_0000;
//			TempMemSprite[9] <= 32'h0000_0000;
//			TempMemSprite[10] <= 32'h0000_0000;
//			TempMemSprite[11] <= 32'h0000_0000;			
//			TempMemSprite[12] <= 32'h0000_0000;
//			TempMemSprite[13] <= 32'h0000_0000;
//			TempMemSprite[14] <= 32'h0000_0000;
//			TempMemSprite[15] <= 32'h0000_0000;		
	end
	else begin
		if (IID_Engine_SP_WE_o && Sprite_Active)	begin
				TempMemSprite[TempMemAddy] <=	VGE_VidMem_Data_i;
				TempMemAddy <= TempMemAddy + 4'b0001;
		end
		else 
			TempMemAddy <= 4'b0000;
	end
end

always @ (*)
begin
	case ( Sprite_Pixel_Pointer[4:0])
		5'b0_0000: Pixel2StoreData = TempMemSprite[0][7:0];
		5'b0_0001: Pixel2StoreData = TempMemSprite[0][15:8];
		5'b0_0010: Pixel2StoreData = TempMemSprite[0][23:16];
		5'b0_0011: Pixel2StoreData = TempMemSprite[0][31:24];
		5'b0_0100: Pixel2StoreData = TempMemSprite[1][7:0];
		5'b0_0101: Pixel2StoreData = TempMemSprite[1][15:8];
		5'b0_0110: Pixel2StoreData = TempMemSprite[1][23:16];
		5'b0_0111: Pixel2StoreData = TempMemSprite[1][31:24];
		5'b0_1000: Pixel2StoreData = TempMemSprite[2][7:0];
		5'b0_1001: Pixel2StoreData = TempMemSprite[2][15:8];
		5'b0_1010: Pixel2StoreData = TempMemSprite[2][23:16];
		5'b0_1011: Pixel2StoreData = TempMemSprite[2][31:24];
		5'b0_1100: Pixel2StoreData = TempMemSprite[3][7:0];
		5'b0_1101: Pixel2StoreData = TempMemSprite[3][15:8];
		5'b0_1110: Pixel2StoreData = TempMemSprite[3][23:16];
		5'b0_1111: Pixel2StoreData = TempMemSprite[3][31:24];		
		5'b1_0000: Pixel2StoreData = TempMemSprite[4][7:0];
		5'b1_0001: Pixel2StoreData = TempMemSprite[4][15:8];
		5'b1_0010: Pixel2StoreData = TempMemSprite[4][23:16];
		5'b1_0011: Pixel2StoreData = TempMemSprite[4][31:24];
		5'b1_0100: Pixel2StoreData = TempMemSprite[5][7:0];
		5'b1_0101: Pixel2StoreData = TempMemSprite[5][15:8];
		5'b1_0110: Pixel2StoreData = TempMemSprite[5][23:16];
		5'b1_0111: Pixel2StoreData = TempMemSprite[5][31:24];
		5'b1_1000: Pixel2StoreData = TempMemSprite[6][7:0];
		5'b1_1001: Pixel2StoreData = TempMemSprite[6][15:8];
		5'b1_1010: Pixel2StoreData = TempMemSprite[6][23:16];
		5'b1_1011: Pixel2StoreData = TempMemSprite[6][31:24];
		5'b1_1100: Pixel2StoreData = TempMemSprite[7][7:0];
		5'b1_1101: Pixel2StoreData = TempMemSprite[7][15:8];
		5'b1_1110: Pixel2StoreData = TempMemSprite[7][23:16];
		5'b1_1111: Pixel2StoreData = TempMemSprite[7][31:24];
		default: Pixel2StoreData = 8'h00;
	endcase
end

// Pick and Choose the Which Depth the Sprite will be Written Too.
//assign IID_Engine_SP0_WE_o = (( Sprite_Depth_Line_Select[2:0] == 3'b000 ) | ( Sprite_Depth_Line_Select[2:0] == 3'b111 )) ? Pixel2Store_Write : 1'b0;	// Most Priority
//assign IID_Engine_SP1_WE_o = (( Sprite_Depth_Line_Select[2:0] == 3'b001 ) | ( Sprite_Depth_Line_Select[2:0] == 3'b111 )) ? Pixel2Store_Write : 1'b0;
//assign IID_Engine_SP2_WE_o = (( Sprite_Depth_Line_Select[2:0] == 3'b010 ) | ( Sprite_Depth_Line_Select[2:0] == 3'b111 )) ? Pixel2Store_Write : 1'b0;
//assign IID_Engine_SP3_WE_o = (( Sprite_Depth_Line_Select[2:0] == 3'b011 ) | ( Sprite_Depth_Line_Select[2:0] == 3'b111 )) ? Pixel2Store_Write : 1'b0;
//assign IID_Engine_SP4_WE_o = (( Sprite_Depth_Line_Select[2:0] == 3'b100 ) | ( Sprite_Depth_Line_Select[2:0] == 3'b111 )) ? Pixel2Store_Write : 1'b0; // Least Priority

assign IID_Engine_SP0_WE_o = ( Sprite_Depth_Line_Select[2:0] == 3'b000 ) ? (Pixel2Store_Write & WritePixel_Enable) : ( Sprite_Depth_Line_Select[2:0] == 3'b111 ) ? Pixel2Store_Write : 1'b0;	// Most Priority
assign IID_Engine_SP1_WE_o = ( Sprite_Depth_Line_Select[2:0] == 3'b001 ) ? (Pixel2Store_Write & WritePixel_Enable) : ( Sprite_Depth_Line_Select[2:0] == 3'b111 ) ? Pixel2Store_Write : 1'b0;	// Most Priority
assign IID_Engine_SP2_WE_o = ( Sprite_Depth_Line_Select[2:0] == 3'b010 ) ? (Pixel2Store_Write & WritePixel_Enable) : ( Sprite_Depth_Line_Select[2:0] == 3'b111 ) ? Pixel2Store_Write : 1'b0;	// Most Priority
assign IID_Engine_SP3_WE_o = ( Sprite_Depth_Line_Select[2:0] == 3'b011 ) ? (Pixel2Store_Write & WritePixel_Enable) : ( Sprite_Depth_Line_Select[2:0] == 3'b111 ) ? Pixel2Store_Write : 1'b0;	// Most Priority
assign IID_Engine_SP4_WE_o = ( Sprite_Depth_Line_Select[2:0] == 3'b100 ) ? (Pixel2Store_Write & WritePixel_Enable) : ( Sprite_Depth_Line_Select[2:0] == 3'b111 ) ? Pixel2Store_Write : 1'b0;	// Most Priority


assign IID_Engine_EffectChannel_SP_ADDY_o = IID_Engine_EffectChannel_SP_ADDY + {5'b0_0000, Sprite_Pixel_Pointer};

wire WritePixel_Enable;

assign WritePixel_Enable = Pixel2StoreData ? 1'b1 : 1'b0;

reg	[2:0]	Sprite_Write_ST;

localparam 		SP_WR_ST_IDLE 		= 3'b000,
					SP_WR_ST_WAIT0		= 3'b001,
					SP_WR_ST_WAIT1		= 3'b010,
					SP_WR_ST_WAIT2		= 3'b011,
					SP_WR_ST_READ0  	= 3'b100,
					SP_WR_ST_READ1		= 3'b101,
					SP_WR_ST_CLEAR		= 4'b111;
					
					

always @ (posedge EngineClk200Mhz_i) 
begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
			Sprite_Pixel_Pointer <= 5'b0_0000;
	end
	else begin
		if (Pixel2Store_Write && !Clear_PixelLine_Sprite)
			Sprite_Pixel_Pointer <= Sprite_Pixel_Pointer + 5'b0_0001;
		else
			Sprite_Pixel_Pointer <= 5'b0_0000;	
	end
end
						
						
always @ (posedge EngineClk200Mhz_i) 
begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
		Sprite_Write_ST <= SP_WR_ST_IDLE;
	
	end
	else begin

		case (Sprite_Write_ST)
		
		SP_WR_ST_IDLE: begin
			if (Sprite_Active) begin
				if (Clear_PixelLine_Sprite) begin
						Pixel2Store_Write <= 1'b1;
						Sprite_Write_ST <= SP_WR_ST_CLEAR;				

				end
				else begin
					if (IID_Engine_SP_WE_o) begin	// The Process of Reading data in Memory has begun
						Sprite_Write_ST <= SP_WR_ST_WAIT0;
						IID_Engine_EffectChannel_SP_ADDY <= Sprite_X_Coordinate_i[9:0];	// Load the Offset
					end
				end
			end
			else begin
				Pixel2Store_Write <= 1'b0;
				IID_Engine_EffectChannel_SP_ADDY <= 10'b00_0000_0000;			
			end
		end

		// Wait for 1 Clock Cycle @100Mhz to be performed
		SP_WR_ST_WAIT0: begin
				Sprite_Write_ST <= SP_WR_ST_WAIT1;
		end		

		SP_WR_ST_WAIT1: begin
				Sprite_Write_ST <= SP_WR_ST_WAIT2;
		end		
		
		// Wait for 1 Clock Cycle @100Mhz to be performed
		SP_WR_ST_WAIT2: begin
				Pixel2Store_Write <= 1'b1;		
				Sprite_Write_ST <= SP_WR_ST_READ0;
		end
		
		// Latency
		SP_WR_ST_READ0: begin
			if (Sprite_Pixel_Pointer == 5'd31) begin
				Pixel2Store_Write <= 1'b0;
				Sprite_Write_ST <= SP_WR_ST_READ1;				
			end

		end
		

		SP_WR_ST_READ1: begin
				Sprite_Write_ST <= SP_WR_ST_IDLE;
		end		
		
//		SP_WR_ST_WRITE0: begin
//		
//		end
		
		
		SP_WR_ST_CLEAR: begin
			if (Clear_PixelLine_Sprite) begin
				Sprite_Write_ST <= SP_WR_ST_CLEAR;			
				IID_Engine_EffectChannel_SP_ADDY <= IID_Engine_EffectChannel_SP_ADDY + 10'b00_0000_0001;
			end
			else begin
				Sprite_Write_ST <= SP_WR_ST_IDLE;			
				Pixel2Store_Write <= 1'b0;			
			end
		end
		default: begin end
		
		endcase
	
	
	end
end

/////////////////////////////////////
// Sprite Pixel Line Counter <- This One is reloaded, since it is only bits and pieces that needs to be written.
/////////////////////////////////////
/*
always @ (posedge EngineClk200Mhz_i) 
begin
	if (IID_Engine_Rst_i) begin
		IID_Engine_EffectChannel_SP_ADDY_o <= 10'b00_0000_0000;
	end
	else begin
	
		if (Sprite_Active) begin
			if (IID_Engine_SP_WE_o || Clear_PixelLine_Sprite) begin
				Sprite_Pixel_Pointer <= Sprite_Pixel_Pointer + 1'b1;
				IID_Engine_EffectChannel_SP_ADDY_o <= IID_Engine_EffectChannel_SP_ADDY_o + 10'b00_0000_0001;
			end
			else begin
				Sprite_Pixel_Pointer <= 5'b0_0000;
				IID_Engine_EffectChannel_SP_ADDY_o <= Sprite_X_Coordinate_i[9:0];	// Load the Offset
			end
		end
		else begin
			IID_Engine_EffectChannel_SP_ADDY_o <= 10'b00_0000_0000;
			Sprite_Pixel_Pointer <= 5'b0_0000;			
		end
	end
end
*/




/////////////////////////////////////
// BackGround Memory Pixel Counter
/////////////////////////////////////
// BitMap
always @ (posedge EngineClk100Mhz_i) 
begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
		Pixel2FetchCounter_BM <= 10'b00_0000_0000;
	end
	else begin
		if (BitMap_Read_Strobe_n)
			Pixel2FetchCounter_BM <= 10'b00_0000_0000;
		else
			Pixel2FetchCounter_BM <= Pixel2FetchCounter_BM + 10'b00_0000_0001;		// When we Read, we read 4 Bytes at the time
	end
end

// Tile
always @ (posedge EngineClk100Mhz_i) 
begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
		Pixel2FetchCounter_TL <= 16'b0000_0000_0000_0000;
	end
	else begin
		if (TileMap_Read_Strobe_n) begin
			if (Tile_Stride256x256) begin
				Pixel2FetchCounter_TL <= {TileMap_Active2Tile_i[7:4], Horizontal_Line_Count[3:0], TileMap_Active2Tile_i[3:0], 3'b000};
			end
			else begin
				Pixel2FetchCounter_TL <= {1'b0, TileMap_Active2Tile_i, Horizontal_Line_Count[3:0], 3'b000};
			end
		end
		else
			Pixel2FetchCounter_TL <= Pixel2FetchCounter_TL + 16'b0000_0000_0000_0001;
	end
end

// Sprite
always @ (posedge EngineClk100Mhz_i) 
begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
		Pixel2FetchCounter_SP <= 5'b0_0000;
	end
	else begin
		if (Sprite_Read_Strobe_n)
			Pixel2FetchCounter_SP <= 5'b0_0000;
		else
			Pixel2FetchCounter_SP <= Pixel2FetchCounter_SP + 5'b0_0001;	
	end
end


/////////////////////////////////////
// BackGround Pixel Line Counter
/////////////////////////////////////
always @ (posedge EngineClk100Mhz_i)
begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
		IID_Engine_EffectChannel_BM_ADDY_o <= 9'b0_0000_0000;
	end
	else begin
		if (Bitmap_Active) begin
			if (IID_Engine_BM_WE_o || Clear_PixelLine_BitMap)
				IID_Engine_EffectChannel_BM_ADDY_o <= IID_Engine_EffectChannel_BM_ADDY_o + 9'b0_0000_0001;
			else 
				IID_Engine_EffectChannel_BM_ADDY_o <= 9'b0_0000_0000;
		end
	end
end

/////////////////////////////////////
// Tile Pixel Line Counter
/////////////////////////////////////
always @ (posedge EngineClk100Mhz_i) begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
		IID_Engine_EffectChannel_TL_ADDY_o <= 9'b0_0000_0000;
	end
	else begin
	
		if (Tile_Active) begin
			if (IID_Engine_TL_WE_o || Clear_PixelLine_TileMap)
				IID_Engine_EffectChannel_TL_ADDY_o <= IID_Engine_EffectChannel_TL_ADDY_o + 9'b0_0000_0001;
		end
			else 
				IID_Engine_EffectChannel_TL_ADDY_o <= 9'b0_0000_0000;
	end
end


assign IID_Engine_Start_Process_o = 1'b0;

reg	[1:0]	 	EffectChannel;
reg	[5:0]	 	Address_Pointer;




// Channel 0 - Nothing
// Channel 1 - Background (full 640 Pixel Fetch)
// Channel 2 - Tile (4 Layers of Character Graphic 16 x 16) @ the end of process, it will fill a full line too)
// Channel 3 - Sprite (32 Sprites) Generates Blocks of Graphics anywhere.


								 

//// Mux Related to Address the TileMap Memory Inside the FPGA
// Pointer to the 
assign TileMapPointer_o = {TileBank, Horizontal_Line_Count[8:4], TileMAP_X_Counter};

assign IID_Engine_TL0_WE_o = (( TileBank[1:0] == 2'b00 ) | Clear_PixelLine_TileMap) ? IID_Engine_TL_WE_o : 1'b0; // Less Priority
assign IID_Engine_TL1_WE_o = (( TileBank[1:0] == 2'b01 ) | Clear_PixelLine_TileMap) ? IID_Engine_TL_WE_o : 1'b0;
assign IID_Engine_TL2_WE_o = (( TileBank[1:0] == 2'b10 ) | Clear_PixelLine_TileMap) ? IID_Engine_TL_WE_o : 1'b0;
assign IID_Engine_TL3_WE_o = (( TileBank[1:0] == 2'b11 ) | Clear_PixelLine_TileMap) ? IID_Engine_TL_WE_o : 1'b0; // More Priority



reg	[2:0]	IID_Engine_HBlanking_i_SYNC;
reg	[1:0]	IID_Engine_VBlanking_i_SYNC;
reg	[2:0] IID_Engine_SOP_SYNC;
reg	[15:0]	Horizontal_Border_i_EDGE;

always @ (posedge EngineClk100Mhz_i) begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin

		IID_Engine_HBlanking_i_SYNC <= 3'b000;
		IID_Engine_VBlanking_i_SYNC <= 2'b00;
	end
	else begin
		IID_Engine_HBlanking_i_SYNC[0] <= IID_Engine_HBlanking_i;
		IID_Engine_HBlanking_i_SYNC[1] <= IID_Engine_HBlanking_i_SYNC[0];
		IID_Engine_HBlanking_i_SYNC[2] <= IID_Engine_HBlanking_i_SYNC[1];
		
		IID_Engine_VBlanking_i_SYNC[0] <= IID_Engine_VBlankingSpecial_i;	// VBlank that begins @ Line 27 Instead
		IID_Engine_VBlanking_i_SYNC[1] <= IID_Engine_VBlanking_i_SYNC[0];
		
		IID_Engine_SOP_SYNC[0] <= IID_Engine_SOF_i;
		IID_Engine_SOP_SYNC[1] <= IID_Engine_SOP_SYNC[0];
		IID_Engine_SOP_SYNC[2] <= IID_Engine_SOP_SYNC[1];
		
		Horizontal_Border_i_EDGE <= {Horizontal_Border_i_EDGE[15:1], IID_Engine_HBlanking_i} << 1'b1;
	end
end

			
			
assign IID_Engine_Captured_Lines_Done_o = IID_Engine_Captured_Lines_Done_Slip[3];

always @ (posedge EngineClk100Mhz_i) begin

		IID_Engine_Captured_Lines_Done_Slip <= IID_Engine_Captured_Lines_Done_Slip << 1'b1;
		if (IID_Master_Engine_SM == INCREMENT_LINE)
			IID_Engine_Captured_Lines_Done_Slip <= 4'b0111;
end


reg	[11:0]		IID_Engine_HLineCount_i0;
reg	[11:0]		IID_Engine_HLineCount_i1;

reg					Valid_Capture_Time;
reg	[2:0]			Valid_Capture_Time_EDGE;

//parameter 	Process_Start_Vertical_line	= 12'd43;	// (>43) The whole Thing begins @ 44
//parameter	Process_Stop_Vertical_line		= 12'd525;	// (<525)The Whole Thing Stops @524
//parameter	Process_Max_Vertical_line		= 10'd480;	// Total Number of Line to be processed
//parameter	Process_Max_Horizontal_line	= 10'd640;

always @ (posedge IID_Engine_VideoClk_i) 
begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
			Valid_Capture_Time <= 1'b0;
	end
	else begin
		if (IID_Engine_HLineCount_i > (V_Blanking_Value_i - 2) && (IID_Engine_HLineCount_i < Total_Line_Per_Image_Value_i))
			Valid_Capture_Time <= 1'b1;
		else
			Valid_Capture_Time <= 1'b0;
	end
end

reg CPUCMD_TimeSlice;

always @ (posedge IID_Engine_VideoClk_i) 
begin
//		if (((IID_Engine_HLineCount_i >= 0) && (IID_Engine_HLineCount_i < 42)) || (IID_Engine_HPixelCount_i >= 0) && (IID_Engine_HPixelCount_i < 150))
		if ((IID_Engine_HPixelCount_i >= 0) && (IID_Engine_HPixelCount_i < (H_Blanking_Value_i - 12'd10)))
			CPUCMD_TimeSlice <= 1;
		else
			CPUCMD_TimeSlice <= 0;		
end


always @ (posedge EngineClk100Mhz_i) begin
		Valid_Capture_Time_EDGE[0] <= Valid_Capture_Time;
		Valid_Capture_Time_EDGE[1] <= Valid_Capture_Time_EDGE[0];
		Valid_Capture_Time_EDGE[2] <=	Valid_Capture_Time_EDGE[1];
		CPUCMD_TimeSlice_EDGE[0] <=	CPUCMD_TimeSlice;
		CPUCMD_TimeSlice_EDGE[1] <=	CPUCMD_TimeSlice_EDGE[0];
		CPUCMD_TimeSlice_EDGE[2] <=	CPUCMD_TimeSlice_EDGE[1];		

end

/// MASTER STATE MACHINE STATE
localparam		IDLE					= 5'b0_0000,			// Wait for Start of Frame
					WAIT_4_LINE			= 5'b0_0001,			// Now that everything has been Primed, let's wait for Line 27
				
					BITMAP_PROCESS0 	= 5'b0_0010,
					BITMAP_PROCESS1 	= 5'b0_0011,
					BITMAP_PROCESS2 	= 5'b0_0100,
					BITMAP_PROCESS3 	= 5'b0_0101,
					
					TILE_PROCESS0		= 5'b0_0110,
					TILE_PROCESS1		= 5'b0_0111,
					TILE_PROCESS2		= 5'b0_1000,
					TILE_PROCESS3		= 5'b0_1001,

					SPRITE_PROCESS0	= 5'b0_1010,
					SPRITE_PROCESS1	= 5'b0_1011,
					SPRITE_PROCESS2	= 5'b0_1100,
					SPRITE_PROCESS3	= 5'b0_1101,
					
					INCREMENT_LINE		= 5'b0_1110,
					
					END 					= 5'b0_1111,
					
					CPU_ACCESS0			= 5'b1_0000,
					CPU_ACCESS1			= 5'b1_0001,
					CPU_ACCESS2			= 5'b1_0010,
					CPU_ACCESS3			= 5'b1_0011,
					CPU_ACCESS4			= 5'b1_0100,
					
					VDMA_ACCESS0		= 5'b1_1000,
					VDMA_ACCESS1		= 5'b1_1001,
					VDMA_ACCESS2		= 5'b1_1010,
					VDMA_ACCESS3		= 5'b1_1011;
					
					

/// Registers Needed in the Master State Machine
reg	[4:0]		IID_Master_Engine_SM;
reg	[8:0]		Horizontal_Line_Count;					
reg	[3:0]		Trigger_Effect;
reg				Bitmap_Effect_On;
reg				TileMap_Effect_On;
reg				Sprite_Effect_On;
reg				VDMA_Module_On;
reg				IID_Master_Engine_MemWrite_OE_o;
// Wire Needed for the Master State Machine
wire				Trig_Effect;

assign 			Trig_Effect = Trigger_Effect[3];


reg				MemWriteByte0;
reg				MemWriteByte1;
reg				MemWriteByte2;
reg				MemWriteByte3;

////////////////////////////////////////////////////
////
//// GRAPHIC ENGINE MASTER STATE MACHINE
////
////////////////////////////////////////////////////
always @ (posedge EngineClk100Mhz_i) begin
	if (IID_Engine_Rst_i  | VideoModeReset_i ) begin
			IID_Master_Engine_SM		<= IDLE;
			EffectChannel        	<= 2'b00; 	// By Default the CPU and DMA have access... Till they don't
			Bitmap_Effect_On			<= 1'b0;
			TileMap_Effect_On			<= 1'b0;
			Sprite_Effect_On			<= 1'b0;
		
			MemWriteByte0				<= 1'b0;
			MemWriteByte1				<= 1'b0;
			MemWriteByte2				<= 1'b0;
			MemWriteByte3				<= 1'b0;			
			
			
			MemoryRead	  				<= 1'b0;
	end
	else begin
	
		Trigger_Effect <= Trigger_Effect << 1'b1;
		
		case( IID_Master_Engine_SM )

		// This Triggers @ Top of Frame.
		IDLE: begin
//			if ((IID_Engine_SOP_SYNC[2:1] == 2'b01) && !IID_Engine_Disable_VideoProcessing_i)  begin		// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.		
				if (IID_Engine_SOP_SYNC[2:1] == 2'b01) begin		// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.
						Horizontal_Line_Count 				<= 9'b0_0000_0000;
						EffectChannel   						<= 2'b00; 	// By Default, Keep the Mux For CPU/DMA Access						
						BM_Absolute_Addy 						<= IID_Engine_BM_MapStartAddress_i;					
						IID_Master_Engine_SM 				<= WAIT_4_LINE;
				end
			else begin
						IID_Master_Engine_SM <= IDLE;
				end
		end		
		
		// We come here for Every Begining of Line
		// Check which module is enabled and bypass right away, no point to go in the process if it is not enabled.
		WAIT_4_LINE: begin
			if ((IID_Engine_HBlanking_i_SYNC[2:1] == 2'b01) && Valid_Capture_Time_EDGE[2] && !IID_Engine_Disable_VideoProcessing_i)	// Begin the Line 28 (Blanking) + 59 Lines
			begin	
				// Let's Begin with BitMap
				if (IID_Engine_BM_Enable_i) begin		// Check to see if the BitMap Layer is enabled.
					IID_Master_Engine_SM 	<= BITMAP_PROCESS0;
					Bitmap_Effect_On			<= 1'b1;
					EffectChannel   			<= 2'b01; 	// Alright Set the First Process to BitMap.
				end
				else begin
					if (Tile_Block_Enable_i) begin		// Check to see if the TileMap Layer is enabled.
						IID_Master_Engine_SM 	<= TILE_PROCESS0;
						TileMap_Effect_On			<= 1'b1;
						EffectChannel   			<= 2'b10; 	// Alright Set the First Process to BitMap.	
					end
					else begin
						if (Sprite_Block_Enable_i) begin		// Check to see if the Sprite Layer is enabled.
							IID_Master_Engine_SM 	<= SPRITE_PROCESS0;
							Sprite_Effect_On			<= 1'b1;
							EffectChannel   			<= 2'b11; 	// Alright Set the First Process to BitMap.
						end
						else begin
							IID_Master_Engine_SM 	<= INCREMENT_LINE;
						end
					end
				end
			end
			else begin
				EffectChannel   			<= 2'b00; 	// By Default, Keep the Mux For CPU/DMA Access
				if ((CPU_Access_CMD_Rd_Empty_i == 1'b0) && (CPUCMD_TimeSlice_EDGE[1]) && !DMA_In_Progress) begin
//				if ((CPU_Access_CMD_Rd_Empty_i == 1'b0) && (CPUCMD_TimeSlice_EDGE[1])) begin				
					CPU_Access_Rd_Strobe_o	<= 1'b1;
					IID_Master_Engine_SM <= CPU_ACCESS0;
				end
					else begin
						CPU_Access_Rd_Strobe_o <= 1'b0;
						IID_Master_Engine_SM <= WAIT_4_LINE;					
					end
			end
		end
		
		// Wait for the Bitmap Process to Finish
		BITMAP_PROCESS0: 
		begin
				IID_Master_Engine_SM 	<= BITMAP_PROCESS1;
				Trigger_Effect	<= 4'hf;	// Fire up the process
		end
		
		BITMAP_PROCESS1: 
		begin
				IID_Master_Engine_SM 	<= BITMAP_PROCESS2;		
		end
		
		BITMAP_PROCESS2: 
		begin
			if (IID_Bitmap_Engine_SM == BM_TRF_DONE) begin
				IID_Master_Engine_SM 	<= BITMAP_PROCESS3;
				Bitmap_Effect_On 			<=	1'b0;		// Turn off Effect, so it can go batch to recharge for next frame				
				BM_Absolute_Addy     	<= BM_Absolute_Addy + IID_Engine_BM_SizeX_i[9:0];
			end
			else
				IID_Master_Engine_SM 	<= BITMAP_PROCESS2;				

		end
		
		BITMAP_PROCESS3: 
		begin
				if (Tile_Block_Enable_i) begin		// Check to see if the BitMap Layer is enabled.
					IID_Master_Engine_SM 	<= TILE_PROCESS0;
					TileMap_Effect_On			<= 1'b1;
					EffectChannel   			<= 2'b10; 	// Alright Set the First Process to BitMap.
				end
				else begin
					if (Sprite_Block_Enable_i) begin		// Check to see if the BitMap Layer is enabled.
						IID_Master_Engine_SM 	<= SPRITE_PROCESS0;
						Sprite_Effect_On			<= 1'b1;
						EffectChannel   			<= 2'b11; 	// Alright Set the First Process to BitMap.
					end
					else begin
						IID_Master_Engine_SM 	<= INCREMENT_LINE;						
					end				
				end
		end
		
		// Wait for the Tile Process to Finish		
		TILE_PROCESS0:
		begin
				IID_Master_Engine_SM 	<= TILE_PROCESS1;
		end
		
		TILE_PROCESS1:
		begin
				IID_Master_Engine_SM 	<= TILE_PROCESS2;
		end
		
		TILE_PROCESS2: 
		begin 
			if (IID_Tile_Engine_SM == TL_TRF_DONE) begin
				TileMap_Effect_On			<= 1'b0;		// Turn off Effect, so it can go batch to recharge for next frame			
				IID_Master_Engine_SM 	<= TILE_PROCESS3;
			end
			else
				IID_Master_Engine_SM 	<= TILE_PROCESS2;
		end
		
		TILE_PROCESS3: 
		begin
			if (Sprite_Block_Enable_i) begin		// Check to see if the BitMap Layer is enabled.
				IID_Master_Engine_SM 	<= SPRITE_PROCESS0;
				Sprite_Effect_On			<= 1'b1;
				EffectChannel   			<= 2'b11; 	// Alright Set the First Process to BitMap.
			end
			else
				IID_Master_Engine_SM 	<= INCREMENT_LINE;						

		end
		
		// Wait for the Sprite Process to Finish
		SPRITE_PROCESS0: 
		begin
			IID_Master_Engine_SM 	<= SPRITE_PROCESS1;
		end

		SPRITE_PROCESS1: 
		begin
			IID_Master_Engine_SM 	<= SPRITE_PROCESS2;	
		end
		
		SPRITE_PROCESS2: 
		begin 
			if (IID_Sprite_Engine_SM == SP_TRF_DONE) begin
				Sprite_Effect_On			<= 1'b0;		// Turn off Effect, so it can go batch to recharge for next frame			
				IID_Master_Engine_SM 	<= SPRITE_PROCESS3;
			end
			else
				IID_Master_Engine_SM 	<= SPRITE_PROCESS2;	
		end
		
		SPRITE_PROCESS3: 
		begin
			IID_Master_Engine_SM 	<= INCREMENT_LINE;		
		end
		
		INCREMENT_LINE:
		begin
			if (Horizontal_Line_Count < Visible_Line_Per_Line_Value_i) begin
					Horizontal_Line_Count	<= Horizontal_Line_Count + 9'b0_0000_0001;
				// Tile He
					IID_Master_Engine_SM		<= WAIT_4_LINE;
					EffectChannel				<= 2'b00;
			end
			else begin
					Bitmap_Effect_On 			<=	1'b0;		// Turn off Effect, so it can go batch to recharge for next frame
					TileMap_Effect_On			<= 1'b0;		// Turn off Effect, so it can go batch to recharge for next frame
					Sprite_Effect_On			<= 1'b0;		// Turn off Effect, so it can go batch to recharge for next frame					
					IID_Master_Engine_SM		<= END;			
			end		
		end
		
		// This the trigger Point for Each Effect to Return to their Normal State (after an entire frame)
		END:
		begin
				IID_Master_Engine_SM		<= IDLE;				
		end

		// The CPU Direct Access will be Done here, Byte per Byte
		// 
		CPU_ACCESS0: begin 
			CPU_Access_Rd_Strobe_o <= 1'b0;
			IID_Master_Engine_SM <= CPU_ACCESS1;			
		end
		
		// Latency (Read Latency From FIFO Command)
		CPU_ACCESS1: begin 
			IID_Master_Engine_SM <= CPU_ACCESS2;
	
		end
		
		CPU_ACCESS2: begin 
			if (CPU_Access_Cmd_i[22])		// If Read
			begin
					MemWriteByte0	<= 1'b0;
					MemWriteByte1	<= 1'b0;
					MemWriteByte2	<= 1'b0;
					MemWriteByte3	<= 1'b0;					
					MemoryRead	 	<= 1'b0;					
			end
			else begin
			
				case (CPU_Access_Cmd_i[1:0])
					2'b00: MemWriteByte0	<= 1'b1;
					2'b01: MemWriteByte1	<= 1'b1;
					2'b10: MemWriteByte2	<= 1'b1;
					2'b11: MemWriteByte3	<= 1'b1;
					default: begin end
				endcase
			end
			IID_Master_Engine_SM <= CPU_ACCESS3;			
		end
		
		CPU_ACCESS3: begin 
			IID_Master_Engine_SM <= CPU_ACCESS4;			
		
		end
		
		CPU_ACCESS4: begin
			MemWriteByte0				<= 1'b0;
			MemWriteByte1				<= 1'b0;
			MemWriteByte2				<= 1'b0;
			MemWriteByte3				<= 1'b0;		
			IID_Master_Engine_SM <= WAIT_4_LINE;			
		end
		
		
		VDMA_ACCESS0: begin 
		
		end
		
		VDMA_ACCESS1: begin 
		
		end
		
		VDMA_ACCESS2: begin
		
		end
		
		VDMA_ACCESS3: begin
		
		
		end
		
		default: begin
				IID_Master_Engine_SM		<= IDLE;				
		end
		endcase
	end
end



/// BITMAP STATE MACHINE STATE
localparam		BM_IDLE				= 4'b0000,			// Wait for Start of Frame
					BM_STATE0			= 4'b0001,			// Now that everything has been Primed, let's wait for Line 27
					FETCH_BM_16PIX0 	= 4'b0010,
					FETCH_BM_16PIX1 	= 4'b0011,
					FETCH_BM_16PIX2 	= 4'b0100,
					FETCH_BM_16PIX3 	= 4'b0101,
					BM_TRF_DONE			= 4'b0110,
					BM_CLEAR_LINE0		= 4'b0111,
					BM_CLEAR_LINE1		= 4'b1000;



/// Registers Needed in the Master State Machine
reg	[3:0]		IID_Bitmap_Engine_SM;
				

////////////////////////////////////////////////////
////
//// GRAPHIC ENGINE BITMAP STATE MACHINE
////
////////////////////////////////////////////////////
always @ (posedge EngineClk100Mhz_i) begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
			IID_Bitmap_Engine_SM	<= BM_IDLE;
			IID_Engine_BM_WE_o	<= 1'b0;
	end
	else begin
	

		case( IID_Bitmap_Engine_SM )

		// THis Process can't start if the Text Mode is ON.
		BM_IDLE: begin
			if (Bitmap_Effect_On)		// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.
				IID_Bitmap_Engine_SM <= BM_STATE0;
			else begin
				if (Horizontal_Border_i_EDGE[15:0] == 16'hFF00) begin	// Begin the Line 28 (Blanking) + 59 Lines
					IID_Bitmap_Engine_SM <= BM_CLEAR_LINE0;
				end
				else			
					IID_Bitmap_Engine_SM <= BM_IDLE;
			end
		
		end
		
		// Wait for the Master State Machine Trigger
		BM_STATE0: begin
			if (Trig_Effect)	begin		// Begin the Line 28 (Blanking) + 59 Lines
				// Let's Begin with BitMap
				IID_Bitmap_Engine_SM <= FETCH_BM_16PIX0;
				Bitmap_Active 			<= 1'b1;						// Enable the Write Counter to increase
			end
			else begin
				if (Bitmap_Effect_On)
					IID_Bitmap_Engine_SM <= BM_STATE0;
				else
					IID_Bitmap_Engine_SM <= BM_IDLE;
			end
		end
	
		// THIS IS TO FETCH 640 Pixels for the Bitmap 
		// Check for Enable Bit First (No Point into doing Anything if the Unit is not enabled
		FETCH_BM_16PIX0: begin
			BitMap_Read_Strobe_n <= 1'b0; // Begin Read Cycles
			IID_Bitmap_Engine_SM	<= FETCH_BM_16PIX1;
		end
		
		// Address for External RAM is Valid Here
		FETCH_BM_16PIX1: begin
			IID_Engine_BM_WE_o 	<= 1'b1;
			IID_Bitmap_Engine_SM	<= FETCH_BM_16PIX2;	
		end

		// Data from External RAM is Valid Here
		FETCH_BM_16PIX2: begin
			if (Pixel2FetchCounter_BM 	< {2'b00, IID_Engine_BM_SizeX_i[9:2]}) begin	// This should 640 / 4 = 160
				IID_Bitmap_Engine_SM		<= FETCH_BM_16PIX2;
			end
			else begin
				BitMap_Read_Strobe_n 	<= 1'b1;
				IID_Bitmap_Engine_SM		<= FETCH_BM_16PIX3;				
			end
		end
		
		FETCH_BM_16PIX3: begin
			IID_Engine_BM_WE_o 	<= 1'b0;
			Bitmap_Active			<= 1'b0;
			IID_Bitmap_Engine_SM <= BM_TRF_DONE;	
		end
		
		
		BM_TRF_DONE: begin
				IID_Bitmap_Engine_SM <= BM_STATE0;	// If we haven't reach the last line, go wait for another Trigger
		end


		BM_CLEAR_LINE0: begin
				Bitmap_Active		   		<= 1'b1;
				Clear_PixelLine_BitMap		<= 1'b1;
				IID_Engine_BM_WE_o			<= 1'b1;		
				IID_Bitmap_Engine_SM <= BM_CLEAR_LINE1;	// If we haven't reach the last line, go wait for another Trigger		
		end
		
		
		BM_CLEAR_LINE1: begin
			if (IID_Engine_EffectChannel_BM_ADDY_o < 9'd336)		//<<<<<<<<<<<<<<<<<<<<<<<<<< 
				IID_Bitmap_Engine_SM <= BM_CLEAR_LINE1;
			else begin
				IID_Bitmap_Engine_SM <= BM_IDLE;
				Bitmap_Active			   	<= 1'b0;	
				Clear_PixelLine_BitMap		<= 1'b0;
				IID_Engine_BM_WE_o			<= 1'b0;
			end		
		
		end
		
		default: begin
				IID_Bitmap_Engine_SM	<= BM_IDLE;				
		end

		endcase
	end
end



/*
output	wire	[1:0]		Tile_Layer_Select_o,
input		wire	[7:0]		Tile_Layer_Control_Reg_i,
input		wire	[23:0]	Tile_Layer_Address_Ptr_i,
input		wire	[11:0]	Tile_X_Stride_i,
input		wire	[11:0]	Tile_Y_Stride_i,
input		wire	[3:0]		Tile_X_Offset_i,
input		wire	[3:0]		Tile_Y_Offset_i,
TileMap_Active2Tile_i
*/


/// TILE STATE MACHINE STATE
localparam		TL_IDLE				= 4'b0000,			// Wait for Start of Frame
					TL_PRESTATE       = 4'b0001,
					TL_STATE0			= 4'b0010,			// Latence to get Valid Value
					TL_STATE1			= 4'b0011,
					TL_STATE2			= 4'b0100,
					TL_STATE3			= 4'b0101,
					TL_STATE4			= 4'b0110,
					TL_STATE5			= 4'b0111,
					TL_STATE6			= 4'b1000,
					TL_STATE7			= 4'b1001,

					
					PREFETCH_TL_16PIX	= 4'b1010,
					FETCH_TL_16PIX0 	= 4'b1011,
					FETCH_TL_16PIX1 	= 4'b1100,
					FETCH_TL_16PIX2 	= 4'b1101,
					FETCH_TL_16PIX3 	= 4'b1110,
					TL_TRF_DONE			= 4'b1111;



//reg	[3:0]		IID_Sprite_Engine_SM;
/// Registers Needed in the Master State Machine
reg	[3:0]		IID_Tile_Engine_SM;
reg	[1:0]		TileBank;
reg	[3:0]		PixelCount;
reg				Tile_Stride256x256;
reg	[2:0]		LUT_SELECT[3:0];
assign Tile_Layer_Select_o = TileBank;

assign	LUT_TM0_o = LUT_SELECT[0][2:0];
assign 	LUT_TM1_o = LUT_SELECT[1][2:0];
assign 	LUT_TM2_o = LUT_SELECT[2][2:0];
assign 	LUT_TM3_o = LUT_SELECT[3][2:0];

////////////////////////////////////////////////////
////
//// GRAPHIC ENGINE TILEMAP STATE MACHINE
////
////////////////////////////////////////////////////
always @ (posedge EngineClk100Mhz_i) begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
			IID_Tile_Engine_SM		<= TL_IDLE;
			TileMap_Read_Strobe_n 	<= 1'b1;
			IID_Engine_TL_WE_o		<= 1'b0;
			TileBank						<= 2'b00;
			Tile_Active					<= 1'b0;
			TL_Absolute_Addy 			<= 22'h000000;
			TileMAP_X_Counter 		<= 6'b00_0000;
			Tile_Stride256x256		<= 1'b0;

	end
	else begin
	

		case( IID_Tile_Engine_SM )

		// THis Process can't start if the Text Mode is ON.
		TL_IDLE: begin
			if (TileMap_Effect_On) begin		// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.
				IID_Tile_Engine_SM <= TL_PRESTATE;
				TileBank <= 2'b00;
			end
			else begin
				if (Horizontal_Border_i_EDGE[15:0] == 16'hFF00) begin	// Begin the Line 28 (Blanking) + 59 Lines
					IID_Tile_Engine_SM <= TL_STATE6;
				end
				else			
					IID_Tile_Engine_SM <= TL_IDLE;
			end
		end
		
		// Wait for the Master State Machine Trigger
		TL_PRESTATE: begin
			if (Trig_Effect)	begin		// Begin the Line 28 (Blanking) + 59 Lines
				// Let's Begin with BitMap
				IID_Tile_Engine_SM <= TL_STATE0;
			end
			else begin
				if (TileMap_Effect_On)
					IID_Tile_Engine_SM <= TL_STATE0;
				else
					IID_Tile_Engine_SM <= TL_IDLE;
			end
		end
		
		//This is For Latency for the Register Information to be Valid
		// State 2
		TL_STATE0: begin
				IID_Tile_Engine_SM <= TL_STATE1;
		end

		// State 3
		TL_STATE1: begin
				if (Tile_Layer_Control_Reg_i[0])	begin	// If the Layer is On, let's start the fun
					IID_Tile_Engine_SM 	<= TL_STATE3;
					Tile_Active 			<= 1'b1;						// Enable the Write Counter to increase						
					TL_Absolute_Addy 		<=	Tile_Layer_Address_Ptr_i[21:0];
					Tile_Stride256x256	<= Tile_Layer_Control_Reg_i[7];
					LUT_SELECT[TileBank]	<= Tile_Layer_Control_Reg_i[3:1];
				end
				else
					IID_Tile_Engine_SM <= TL_STATE2; // Check Next Channel
		end
	
		TL_STATE2: begin
			if (TileBank == 2'b11)						// If we have reached Layer 4 and it is not Enable, just go at the end and declare the process to be over.
				IID_Tile_Engine_SM <= TL_TRF_DONE;
			else begin
				TileBank <= TileBank + 2'b01;
				IID_Tile_Engine_SM <= TL_STATE0;
			end
		end	
	
		// The Process Starts Here @ The Beginning, we are already @ 0,0 
		TL_STATE3: begin
				PixelCount <= 4'h3; // 4 Cycles - 1
				IID_Tile_Engine_SM <= FETCH_TL_16PIX0;	// Go Read 16Bytes (4 Cycles)
		end

		TL_STATE5: begin
			if (TileMAP_X_Counter < 6'd40) begin
				IID_Tile_Engine_SM <= TL_STATE3;	// Go Read 16Bytes (4 Cycles)					
			end
			else begin
				IID_Tile_Engine_SM <= TL_STATE2;	// Go Read 16Bytes (4 Cycles)	
				TileMAP_X_Counter 	<= 6'h00;
				Tile_Active			   <= 1'b0;				
				
			end
		end
		
		// Clear the Line Before Drawing in
		TL_STATE6: begin
				Tile_Active			   		<= 1'b1;
				Clear_PixelLine_TileMap		<= 1'b1;
				IID_Engine_TL_WE_o			<= 1'b1;
				IID_Tile_Engine_SM <= TL_STATE7;	// Go Read 16Bytes (8 Cycles)			
		end
		
		
		TL_STATE7: begin
				if (IID_Engine_EffectChannel_TL_ADDY_o < 9'd336)			// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
					IID_Tile_Engine_SM <= TL_STATE7;
				else begin
					IID_Tile_Engine_SM <= TL_IDLE;
					Tile_Active			   		<= 1'b0;	
					Clear_PixelLine_TileMap		<= 1'b0;
					IID_Engine_TL_WE_o			<= 1'b0;
				end
		end
	
		///////
		//0xB
		FETCH_TL_16PIX0: begin
			TileMap_Read_Strobe_n <= 1'b0; // Begin Read Cycles
			IID_Tile_Engine_SM	<= FETCH_TL_16PIX1;
		end
		
		// Address for External RAM is Valid Here
		//0xC
		FETCH_TL_16PIX1: begin
			IID_Engine_TL_WE_o 	<= 1'b1;
			IID_Tile_Engine_SM	<= FETCH_TL_16PIX2;	
		end

		// Data from External RAM is Valid Here (This is where we need to Check for 16 Pixels (8 Pixels)
		FETCH_TL_16PIX2: begin
			if (PixelCount) begin	// This should 640 / 4 = 160
				PixelCount <= PixelCount - 4'h1;
				IID_Tile_Engine_SM		<= FETCH_TL_16PIX2;
			end
			else begin
				TileMap_Read_Strobe_n 	<= 1'b1;
				IID_Tile_Engine_SM		<= FETCH_TL_16PIX3;				
			end
		end
		
		FETCH_TL_16PIX3: begin
			IID_Engine_TL_WE_o 	<= 1'b0;
			TileMAP_X_Counter <= TileMAP_X_Counter + 1'b1;	// Now Switch Character
			IID_Tile_Engine_SM 	<= TL_STATE5;			
		end

		// When the Line has been Drawned
		TL_TRF_DONE: begin
				IID_Tile_Engine_SM <= TL_IDLE;	// If we haven't reach the last line, go wait for another Trigger
		end


		default: begin
				IID_Tile_Engine_SM	<= TL_IDLE;				
		end

		endcase
	end
end

/////////////////////////////
////////////////////////////
//////////////////////////////////////////////////*****************************************************

/// SPRITE STATE MACHINE STATE
localparam		SP_IDLE				= 4'b0000,			// Wait for Start of Frame
					SP_PRESTATE       = 4'b0001,
					SP_STATE0			= 4'b0010,			// Latence to get Valid Value
					SP_STATE1			= 4'b0011,
					ENABLED				= 4'b0100,
					NEXTCHANNEL			= 4'b0101,
					SP_STATE4			= 4'b0110,
					SP_STATE5			= 4'b0111,
					SP_STATE6			= 4'b1000,
					SP_STATE7			= 4'b1001,

					
					PREFETCH_SP_16PIX	= 4'b1010,
					FETCH_SP_16PIX0 	= 4'b1011,
					FETCH_SP_16PIX1 	= 4'b1100,
					FETCH_SP_16PIX2 	= 4'b1101,
					FETCH_SP_16PIX3 	= 4'b1110,
					SP_TRF_DONE			= 4'b1111;


/// Registers Needed in the Master State Machine
reg	[3:0]		IID_Sprite_Engine_SM;
reg	[4:0]		Sprite_Select;
reg	[4:0]		SP_PixelCount;

parameter SpriteMax = 32;
wire 				Sprite_Line_Hit;
//wire				Sprite_Line_Hits_Clear_Line;
wire	[15:0]	Line_Number_In_Sprite;
wire	[23:0]	Video_Memory_Start_Addy;
wire	[15:0]	Y1;

assign Y1 = (Sprite_Y_Coordinate_i + 16'd32);

assign Sprite_Select_o = Sprite_Select;
assign Sprite_Line_Hit = ((Horizontal_Line_Count >= Sprite_Y_Coordinate_i) && (Horizontal_Line_Count < Y1)) ? 1'b1 : 1'b0;
//assign Sprite_Line_Hits_Clear_Line = (Horizontal_Line_Count == Y1);
assign Line_Number_In_Sprite = Sprite_Line_Hit ? (Horizontal_Line_Count - Sprite_Y_Coordinate_i ) : 16'h0000;

////////////////////////////////////////////////////
////
//// GRAPHIC ENGINE SPRITE STATE MACHINE
////
////////////////////////////////////////////////////
always @ (posedge EngineClk100Mhz_i) begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
			IID_Sprite_Engine_SM		<= SP_IDLE;
			SP_Absolute_Addy 			<= 22'h000000;
			Sprite_Read_Strobe_n 	<= 1'b1;
			IID_Engine_SP_WE_o		<= 1'b0;
			Sprite_Active				<= 1'b0;
			SP_PixelCount				<= 5'b0_0000;
			Clear_PixelLine_Sprite  <= 1'b0;
	end
	else begin
	

		case( IID_Sprite_Engine_SM )

		// THis Process can't start if the Text Mode is ON.
		SP_IDLE: begin
			if (Sprite_Effect_On) begin		// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.
				Sprite_Select <= 5'b0_0000;		// Just go with 16 for now.				
				IID_Sprite_Engine_SM <= SP_PRESTATE;
			end
			else
				begin
					if (Horizontal_Border_i_EDGE[15:0] == 16'hFF00) begin	// Begin the Line 28 (Blanking) + 59 Lines
						IID_Sprite_Engine_SM <= SP_STATE4;
					end
					else
						IID_Sprite_Engine_SM <= SP_IDLE;
				end
		end
		
		// Wait for the Master State Machine Trigger
		//1
		SP_PRESTATE: begin
			if (Trig_Effect)	begin
				IID_Sprite_Engine_SM <= SP_STATE0;
			end
			else begin
				if (Sprite_Effect_On)
					IID_Sprite_Engine_SM <= SP_STATE0;
				else
					IID_Sprite_Engine_SM <= SP_IDLE;
			end
		end
		
		//This is For Latency for the Register Information to be Valid
		// State 2
		SP_STATE0: begin
				IID_Sprite_Engine_SM <= SP_STATE1;
		end

		// State 3
		SP_STATE1: begin
			if (Sprite_Control_Reg_i[0]) begin
				IID_Sprite_Engine_SM <= ENABLED;
				Sprite_Active						<= 1'b1;				
				end
			else
				IID_Sprite_Engine_SM <= NEXTCHANNEL;		
		end

		ENABLED: begin
			if (Sprite_Line_Hit) begin
//				SP_Absolute_Addy 					<= (Sprite_Address_Ptr_i + {3'b000, Line_Number_In_Sprite, 5'b0_0000}) & 24'h3FFFFF;			
//				SP_Absolute_Addy 					<= (Sprite_Address_Ptr_i[21:0] + {4'b0000, Line_Number_In_Sprite, 4'b0000});
				SP_Absolute_Addy 					<= (Sprite_Address_Ptr_i[21:0] + {3'b000, Line_Number_In_Sprite, 5'b0_0000});				
				//Video_Color_LookUp_Table_o		<= Sprite_Control_Reg_i[3:1];
				Sprite_Depth_Line_Select 		<= Sprite_Control_Reg_i[6:4];	// This is to indicate which layer the Sprite ought to be inserted in.
				SP_PixelCount 						<= 5'd6;
				IID_Sprite_Engine_SM 			<= FETCH_SP_16PIX0;	// Go Read 32Bytes (8 Cycles)
			end
			else begin
//				if (Sprite_Line_Hits_Clear_Line) begin
//						IID_Sprite_Engine_SM <= SP_STATE4;	
//						SP_PixelCount <= 5'd16;
//					end
//				else 
					IID_Sprite_Engine_SM <= NEXTCHANNEL;
			end
		end	
	
		// The Process Starts Here @ The Beginning, we are already @ 0,0
		// Go Fetch the DATA
		NEXTCHANNEL: begin
			if (Sprite_Select == SpriteMax) begin
				IID_Sprite_Engine_SM <= SP_TRF_DONE;
				Sprite_Active	<= 1'b0;				
			end
			else begin
				Sprite_Select <= Sprite_Select + 5'b0_0001;
				IID_Sprite_Engine_SM <= SP_STATE0;				
			end
		end

		// Go Clear the Line Before the Processing Begins
		SP_STATE4: begin
			IID_Sprite_Engine_SM <= SP_STATE5;
			Sprite_Active	<= 1'b1;
			Clear_PixelLine_Sprite <= 1'b1;
//			IID_Engine_SP_WE_o <= 1'b1;
			Sprite_Depth_Line_Select <= 3'b111;
		end
		
		SP_STATE5: begin
			if (IID_Engine_EffectChannel_SP_ADDY_o < (Visible_Pixel_Per_Line_Value_i + 32))
				IID_Sprite_Engine_SM <= SP_STATE5;
			else begin
				Sprite_Depth_Line_Select <= 3'b000;
//				IID_Engine_SP_WE_o <= 1'b0;
				Sprite_Active	<= 1'b0;
				Clear_PixelLine_Sprite <= 1'b0;			
				IID_Sprite_Engine_SM <= SP_IDLE;
			end
		end		
		

//		SP_STATE6: begin
//
//			IID_Sprite_Engine_SM <= SP_IDLE;		
//		end
		
		//
		//0xB
		FETCH_SP_16PIX0: begin
			Sprite_Read_Strobe_n <= 1'b0; // Begin Read Cycles
			IID_Sprite_Engine_SM	<= FETCH_SP_16PIX1;
		end
		
		// Address for External RAM is Valid Here
		//0xC
		FETCH_SP_16PIX1: begin
			IID_Engine_SP_WE_o 	<= 1'b1;
			IID_Sprite_Engine_SM	<= FETCH_SP_16PIX2;	
		end

		// Data from External RAM is Valid Here (This is where we need to Check for 16 Pixels (8 Pixels)
		FETCH_SP_16PIX2: begin
			if (SP_PixelCount) begin	// This should 640 / 4 = 160
				SP_PixelCount <= SP_PixelCount - 4'h1;
				IID_Sprite_Engine_SM		<= FETCH_SP_16PIX2;
			end
			else begin
				Sprite_Read_Strobe_n 	<= 1'b1;
				IID_Sprite_Engine_SM		<= FETCH_SP_16PIX3;				
			end
		end
		
		FETCH_SP_16PIX3: begin
			IID_Engine_SP_WE_o 	<= 1'b0;
			//TileMAP_X_Counter <= TileMAP_X_Counter + 1'b1;	// Now Switch Character
			IID_Sprite_Engine_SM 	<= NEXTCHANNEL;			
		end

		// When the Line has been Drawned
		SP_TRF_DONE: begin
				IID_Sprite_Engine_SM <= SP_IDLE;	// If we haven't reach the last line, go wait for another Trigger
		end


		default: begin
				IID_Tile_Engine_SM	<= SP_IDLE;				
		end

		endcase
	end
end


/////////////////////////////
////////////////////////////
//////////////////////////////////////////////////*****************************************************


// VDMA PORT
/*
input		wire	[7:0]		VDMA_Control_Reg_i,
input		wire	[7:0]		VDMA_Data_2_Write_i,
input		wire	[23:0]	VDMA_Src_Addy_i,
input		wire	[23:0]	VDMA_Dst_Addy_i,
input		wire	[15:0]	VDMA_X_Size_i,
input		wire	[15:0]	VDMA_Y_Size_i,
input		wire	[15:0]	VDMA_Src_Stride_i,
input		wire	[15:0]	VDMA_Dst_Stride_i,
output	wire	[7:0]		VDMA_Status_Reg_o,
output	wire				VDMA_Interrupt_o,
*/
wire				LL_Byte_Valid;
wire				LH_Byte_Valid;
wire				HL_Byte_Valid;
wire				HH_Byte_Valid;
reg				DMA_Read_Req;
reg				DMA_Write_Req;
//reg	[21:0] 	Compute_VDMA_Src_Addy;
//reg	[21:0] 	Compute_VDMA_Dst_Addy;
reg				DMA_In_Progress;
reg				DMA_VMem_Read;
//reg				DMA_VMem_WriteLo;
//reg				DMA_VMem_WriteHi;
reg				VDMA_Src_Dst_Mux_Choice;
reg				VDMA_Status_Overflow;
reg				VDMA_Status_Dst_Ovf; //Dst_Address Out of Range
reg				VDMA_Status_Src_Ovf; //Src Adress Out of Range


//reg	[7:0]  	Proc_VDMA_Control_Reg_i;
//reg	[23:0]	Proc_VDMA_Src_Addy;
//reg	[23:0]	Proc_VDMA_Dst_Addy;
//reg	[15:0]	Proc_VDMA_X_Size;
//reg	[15:0]	Proc_VDMA_Y_Size;
//reg	[15:0]	Proc_VDMA_Src_Stride;
//reg	[15:0]	Proc_VDMA_Dst_Stride;
//reg	[7:0]		Proc_VDMA_Data_2_Write;
reg	[21:0]	Src_Step_Counter;
reg	[21:0]	Dst_Step_Counter;
reg	[21:0]	Src_Stride_Counter;
reg	[21:0]	Dst_Stride_Counter;


// Output From FIFO
wire 	[7:0]		DMA_FIFO_Data_LL;
wire				DMA_FIFO_Data_LL_Valid;
wire 	[7:0]		DMA_FIFO_Data_LH;
wire				DMA_FIFO_Data_LH_Valid;
wire 	[7:0]		DMA_FIFO_Data_HL;
wire				DMA_FIFO_Data_HL_Valid;
wire 	[7:0]		DMA_FIFO_Data_HH;
wire				DMA_FIFO_Data_HH_Valid;

// FIFO
wire	[8:0] 	rdusedw;	// Number of Value In FIFO (16bit Short)
wire	[8:0]		wrusedw;	// Number of Value In FIFO (16bit Short)
wire				DMA_Read_FIFO_Empty;
wire				DMA_Write_FIFO_Full;

// Stride ADDERS
wire	[21:0]	Output_Src_Addy;
wire	[21:0]	Output_Dst_Addy;
wire	[31:0]	VDMA_2D_Count_Size;
wire	[31:0]	TransferByteCount;
wire	[21:0]	VDMA_VMem_Addy;

wire	[7:0]		DMA_Data_2_Write_LL;
wire	[7:0]		DMA_Data_2_Write_LH;
wire	[7:0]		DMA_Data_2_Write_HL;
wire	[7:0]		DMA_Data_2_Write_HH;


assign VDMA_Interrupt_o = 1'b0;

initial
begin
	DMA_Read_Req 		 		= 1'b0;
	DMA_Write_Req 	 			= 1'b0;
	DMA_In_Progress  			= 1'b0;
	DMA_VMem_Read     		= 1'b0;
	//DMA_VMem_WriteLo  		= 1'b0;
	//DMA_VMem_WriteHi  		= 1'b0;
	VDMA_Src_Dst_Mux_Choice 	= 1'b0;	// 1 = Read (Src Addy), 0 = Write (Dst Addy)
end

assign VDMA_Status_Reg_o = {DMA_In_Progress, 4'b000_0, VDMA_Status_Src_Ovf, VDMA_Status_Dst_Ovf, VDMA_Status_Overflow};

DMA_RX_FIFO VDMA_Rx_FiFo(
	.data({HH_Byte_Valid, HL_Byte_Valid, LH_Byte_Valid, LL_Byte_Valid, VGE_VidMem_Data_i}),						// 18Bits Input 16 Bits Data, 2Bit DataValid
	.rdclk( EngineClk100Mhz_i ),
	.rdreq( DMA_Read_Req ),
	.wrclk( EngineClk100Mhz_i ),
	.wrreq( DMA_Write_Req ),
	.q( {  DMA_FIFO_Data_HH_Valid, DMA_FIFO_Data_HL_Valid, DMA_FIFO_Data_LH_Valid, DMA_FIFO_Data_LL_Valid, DMA_FIFO_Data_HH, DMA_FIFO_Data_HL, DMA_FIFO_Data_LH, DMA_FIFO_Data_LL} ),
	.rdempty( DMA_Read_FIFO_Empty ),
	.rdusedw( rdusedw ),
	.wrfull( DMA_Write_FIFO_Full ),
	.wrusedw( wrusedw )
);

DMA_MULT_BLK VDMA_Size_2_Count(
	.dataa( VDMA_X_Size_i ),
	.datab( VDMA_Y_Size_i ),
	.result( VDMA_2D_Count_Size )
);

assign TransferByteCount 	= VDMA_Control_Reg_i[1] ? VDMA_2D_Count_Size : {8'b0000_0000, VDMA_Y_Size_i[7:0], VDMA_X_Size_i};

//assign Output_Src_Addy 		= Compute_VDMA_Src_Addy + Src_Step_Counter + Src_Stride_Counter;
//assign Output_Dst_Addy 		= Compute_VDMA_Dst_Addy + Dst_Step_Counter + Dst_Stride_Counter;

assign VDMA_VMem_Addy      = VDMA_Src_Dst_Mux_Choice   ? Output_Src_Addy : Output_Dst_Addy;

// Data to Write Either From FIFO or From Forced Value
assign DMA_Data_2_Write_LL	= VDMA_Control_Reg_i[2] ? VDMA_Data_2_Write_i : DMA_FIFO_Data_LL;
assign DMA_Data_2_Write_LH	= VDMA_Control_Reg_i[2] ? VDMA_Data_2_Write_i : DMA_FIFO_Data_LH;
assign DMA_Data_2_Write_HL	= VDMA_Control_Reg_i[2] ? VDMA_Data_2_Write_i : DMA_FIFO_Data_HL;
assign DMA_Data_2_Write_HH	= VDMA_Control_Reg_i[2] ? VDMA_Data_2_Write_i : DMA_FIFO_Data_HH;
/// SPRITE STATE MACHINE STATE
localparam		VDMA_IDLE			= 5'b0_0000,
					VDMA_INIT_REG     = 5'b0_0001,
					VDMA_MASTER_CTRL0	= 5'b0_0010,
					VDMA_MASTER_CTRL1 = 5'b0_0011,
					VDMA_MASTER_CTRL2	= 5'b0_0100,
					VDMA_MASTER_CTRL3	= 5'b0_0101,
					
					VDMA_MASTER_CTRL4	= 5'b0_0110,
					VDMA_MASTER_CTRL5	= 5'b0_0111,
					VDMA_MASTER_CTRL6	= 5'b0_1000,
					VDMA_READ_0			= 5'b0_1001,
					VDMA_READ_1   		= 5'b0_1011,
					VDMA_READ_2   		= 5'b0_1100,
					VDMA_READ_3   		= 5'b0_1101,
					VDMA_READ_4   		= 5'b0_1110,
					VDMA_READ_5			= 5'b0_1111,
					VDMA_READ_6			= 5'b1_0000,
					VDMA_READ_7       = 5'b1_0001,
				
               VDMA_WRITE_0		= 5'b1_0110,
               VDMA_WRITE_1		= 5'b1_0111,
               VDMA_WRITE_2		= 5'b1_1000,
               VDMA_WRITE_3		= 5'b1_1001,
               VDMA_WRITE_4  		= 5'b1_1011,
               VDMA_WRITE_5  		= 5'b1_1100,
					VDMA_WRITE_6  		= 5'b1_1101,
					VDMA_WRITE_7  		= 5'b1_1110,

					VDMA_END_OF_TRANS	= 5'b1_1111;
					
/*
// register to Create Address and Strobe to Address External Video RAM
reg [21:0]	DMA_Absolute_Addy
reg			DMA_Read_Strobe_n;
reg			DMA_Write_L_Strobe_n;
reg			DMA_Write_H_Strobe_n;

*/


/// Registers Needed in the Master State Machine

reg	[4:0]		IID_VDMA_Engine_SM;
reg	[4:0]		IID_VDMA_Engine_SM_SM;
reg				Dst_First_Odd_Write;
reg				Dst_Last_Even_Write;
reg				Src_First_Odd_Write;
reg				Src_Last_Even_Write;
/*
always @ (posedge EngineClk100Mhz_i) begin

	if (IID_VDMA_Engine_SM == VDMA_MASTER_CTRL3) begin
	
		if (Proc_VDMA_Control_Reg_i[1]) begin
		// 2D Access
			Dst_First_Odd_Write <= Compute_VDMA_Dst_Addy[0];
			Dst_Last_Even_Write <= Compute_VDMA_Dst_Addy[0] ^ Proc_VDMA_X_Size[0]; // We Assume that the Stride is always Even
			Src_First_Odd_Write <= Compute_VDMA_Src_Addy[0];
			Src_Last_Even_Write <= Compute_VDMA_Src_Addy[0] ^ Proc_VDMA_X_Size[0];
		end
		else begin
		// 1D Access
			Dst_First_Odd_Write <= Compute_VDMA_Dst_Addy[0];
			Dst_Last_Even_Write <= Compute_VDMA_Dst_Addy[0] ^ TransferByteCount[0];
			Src_First_Odd_Write <= Compute_VDMA_Src_Addy[0];
			Src_Last_Even_Write <= Compute_VDMA_Src_Addy[0] ^ TransferByteCount[0];		
		end

	end
end
*/
////////////////////////////////////////////////////
////
//// VDMA Main Engine
////
////////////////////////////////////////////////////
//
//	CPU_Access_Rd_Strobe_o   <- These Needs to be checked to make sure that there is no 
//	CPU_Access_CMD_Rd_Empty_i

//
reg [3:0]	EDGE_Start_DMA_Transfer;
reg [23:0]	Tfr_ByteCounts;

always @ (posedge EngineClk100Mhz_i) begin
		EDGE_Start_DMA_Transfer[0] <= VDMA_Control_Reg_i[7];
		EDGE_Start_DMA_Transfer[1] <= EDGE_Start_DMA_Transfer[0];
		EDGE_Start_DMA_Transfer[2] <= EDGE_Start_DMA_Transfer[1];
		EDGE_Start_DMA_Transfer[3] <= EDGE_Start_DMA_Transfer[2];		
end
/*
always @ (posedge EngineClk100Mhz_i) begin

	if (IID_Engine_Rst_i) begin
		Proc_VDMA_Control_Reg_i <= 8'h00;
		Proc_VDMA_Src_Addy 		<= 24'h00_0000;
		Proc_VDMA_Dst_Addy 		<= 24'h00_0000;
		Proc_VDMA_X_Size 			<= 16'h0000;
		Proc_VDMA_Y_Size 			<= 16'h0000;
		Proc_VDMA_Src_Stride 	<= 16'h0000;
		Proc_VDMA_Dst_Stride 	<= 16'h0000;
		Proc_VDMA_Data_2_Write 	<= 8'h00;
	end
	else begin
		if (EDGE_Start_DMA_Transfer[3:0] == 4'b0011) begin	
			Proc_VDMA_Control_Reg_i <= VDMA_Control_Reg_i;
			Proc_VDMA_Src_Addy 		<= VDMA_Src_Addy_i;
			Proc_VDMA_Dst_Addy 		<= VDMA_Dst_Addy_i;
			Proc_VDMA_X_Size 			<= VDMA_X_Size_i;
			Proc_VDMA_Y_Size 			<= VDMA_Y_Size_i;
			Proc_VDMA_Src_Stride 	<= {VDMA_Src_Stride_i[15:1], 1'b0};
			Proc_VDMA_Dst_Stride 	<= {VDMA_Dst_Stride_i[15:1], 1'b0};
			Proc_VDMA_Data_2_Write 	<= VDMA_Data_2_Write_i;		
		end
	end
end 
*/
reg	[3:0] 	Fire_Fill_Function;

always @ (posedge EngineClk100Mhz_i) begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
			IID_VDMA_Engine_SM		<= VDMA_IDLE;
			VDMA_Src_Dst_Mux_Choice	<= 1'b0;
			DMA_In_Progress			<= 1'b0;
			VDMA_Status_Overflow		<= 1'b0;
			VDMA_Status_Dst_Ovf		<= 1'b0;
			VDMA_Status_Src_Ovf		<= 1'b0;			
			Tfr_ByteCounts				<= 24'h00_0000;
			DMA_VMem_Read				<= 1'b0;
			//DMA_VMem_WriteLo			<= 1'b0;
			//DMA_VMem_WriteHi			<= 1'b0;			
	end
	else begin
		Fire_Fill_Function <= Fire_Fill_Function << 1'b1;
		
		case( IID_VDMA_Engine_SM )

		// THis Process can't start if the Text Mode is ON.
		VDMA_IDLE: begin
			if (VDMA_Control_Reg_i[0]) begin		// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.

				IID_VDMA_Engine_SM <= VDMA_INIT_REG;
			end
			else begin
						IID_VDMA_Engine_SM <= VDMA_IDLE;
				end
		end
		
		VDMA_INIT_REG: begin 
			if (EDGE_Start_DMA_Transfer[3:0] == 4'b0111) begin		// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.
				IID_VDMA_Engine_SM <= VDMA_MASTER_CTRL0;
			end
			else begin
				if (VDMA_Control_Reg_i[0])
					IID_VDMA_Engine_SM <= VDMA_INIT_REG;
				else 
					IID_VDMA_Engine_SM <= VDMA_IDLE;
			end			
		
		
		end
		
		// Let's Setup Everything and Make sure we are good to go...
		// Verify a Certain Integrity of certain variables;
		VDMA_MASTER_CTRL0: begin
			if (( TransferByteCount == 32'h00000000 ) || ( TransferByteCount > 32'h00FFFFFF )) begin
				VDMA_Status_Overflow <= 1'b1;
				IID_VDMA_Engine_SM <= VDMA_INIT_REG;
			end
			else begin
				VDMA_Status_Overflow <= 1'b0;
				IID_VDMA_Engine_SM <= VDMA_MASTER_CTRL1;				
			end
		end
		
		// Check Destination Address
		VDMA_MASTER_CTRL1: begin 
			if (VDMA_Dst_Addy_i < 24'h40_0000) begin
//				Compute_VDMA_Dst_Addy <= Proc_VDMA_Dst_Addy[21:0];
				VDMA_Status_Dst_Ovf <= 1'b0;
					if (VDMA_Control_Reg_i[2]) begin
						//IID_VDMA_Engine_SM_SM 	<= VDMA_FILL_0;
						IID_VDMA_Engine_SM 		<= VDMA_MASTER_CTRL3;						
					end
					else begin
						//IID_VDMA_Engine_SM_SM	<= VDMA_READ_0;
						IID_VDMA_Engine_SM 		<= VDMA_MASTER_CTRL2;
					end
				end
				else begin
					VDMA_Status_Dst_Ovf <= 1'b1;			
					IID_VDMA_Engine_SM <= VDMA_INIT_REG;
				end
		end
		
		// Check Source Addy
		VDMA_MASTER_CTRL2: begin
			if (VDMA_Src_Addy_i < 24'h40_0000) begin
//				Compute_VDMA_Src_Addy <= Proc_VDMA_Src_Addy[21:0];
				VDMA_Status_Src_Ovf <= 1'b0;		
				IID_VDMA_Engine_SM <= VDMA_MASTER_CTRL3;
			end 
			else begin
				VDMA_Status_Src_Ovf <= 1'b1;			
				IID_VDMA_Engine_SM <= VDMA_INIT_REG;			
			end

		end
		// THis is the point where the Process Begins
		VDMA_MASTER_CTRL3: begin
			IID_VDMA_Engine_SM <= VDMA_MASTER_CTRL4;
			
			if (VDMA_Control_Reg_i[2])
				VDMA_Src_Dst_Mux_Choice <= 1'b0; // Assign to the Output Address the Source Pointer, since we need to transfer data.
			else
				VDMA_Src_Dst_Mux_Choice <= 1'b1;	// Assign to the Output Address the Destination Right now, since we only need to go write
				
			if (VDMA_Control_Reg_i[1]) begin
			// 2D Access
				Dst_First_Odd_Write <= VDMA_Dst_Addy_i[0];
				Dst_Last_Even_Write <= VDMA_Dst_Addy_i[0] ^ VDMA_X_Size_i[0]; // We Assume that the Stride is always Even
				Src_First_Odd_Write <= VDMA_Src_Addy_i[0];
				Src_Last_Even_Write <= VDMA_Src_Addy_i[0] ^ VDMA_X_Size_i[0];
			end
			else begin
			// 1D Access
				Dst_First_Odd_Write <= VDMA_Dst_Addy_i[0];
				Dst_Last_Even_Write <= VDMA_Dst_Addy_i[0] ^ TransferByteCount[0];
				Src_First_Odd_Write <= VDMA_Src_Addy_i[0];
				Src_Last_Even_Write <= VDMA_Src_Addy_i[0] ^ TransferByteCount[0];		
			end				
			DMA_In_Progress 	<= 1'b1;
		end
		
		
		VDMA_MASTER_CTRL4: begin
			if (Valid_Capture_Time_EDGE[2:0] == 3'b000) begin
				Fire_Fill_Function <= 4'b1111;
				IID_VDMA_Engine_SM <= VDMA_MASTER_CTRL5;
			end
			else begin
				IID_VDMA_Engine_SM <= VDMA_MASTER_CTRL4;
			end
		end
		
		VDMA_MASTER_CTRL5: begin
			if (Fill_StateMachine == FILL_0007) begin
				IID_VDMA_Engine_SM 	<= VDMA_MASTER_CTRL6;		
			end
			else begin
				IID_VDMA_Engine_SM 	<= VDMA_MASTER_CTRL5;				
			end
		end		
		
		VDMA_MASTER_CTRL6: begin
			DMA_In_Progress 		<= 1'b0;
			IID_VDMA_Engine_SM 	<= VDMA_IDLE;
		end		
		
		
		// VDMA Read Function
		// Go Read the Memory and Fill the FIFO
		VDMA_READ_0: begin
		
		
		end
		
		
		VDMA_READ_1: begin
		
		
		end
		
		VDMA_READ_2: begin
		
		
		end

		VDMA_READ_3: begin
		
		
		end

		VDMA_READ_4: begin
	

		end

		VDMA_READ_5: begin
	

		end

		VDMA_READ_6: begin
	
		end
		
		VDMA_READ_7: begin
	

		end

     
		// VDMA Write Sequence
		// Read FIFO And Go write its Content to whereever we need to		
      VDMA_WRITE_0: begin
		
		
		end
		
      VDMA_WRITE_1: begin
		
		
		end
		
      VDMA_WRITE_2: begin
		
		
		end
		
      VDMA_WRITE_3: begin
		
		
		end
		
		VDMA_WRITE_4: begin
		
		
		end
		
		
		VDMA_WRITE_5: begin 
		
		
		end
		
		VDMA_WRITE_6: begin
		
		
		end

		VDMA_WRITE_7: begin
		
		
		end
				

		VDMA_END_OF_TRANS: begin
			DMA_In_Progress <= 1'b0;		
			IID_VDMA_Engine_SM	<= VDMA_IDLE;
		end
		

		default: begin
			IID_VDMA_Engine_SM	<= VDMA_IDLE;
		end		

		endcase
	end
end

localparam	FILL_IDLE	= 4'b0000,
				FILL_0001	= 4'b0001,
				FILL_0002   = 4'b0010,
				FILL_0003	= 4'b0011,
				FILL_0004   = 4'b0100,
				FILL_0005	= 4'b0101,
				FILL_0006   = 4'b0110,
				FILL_0007	= 4'b0111,
				FILL_0008   = 4'b1000,
				FILL_0009   = 4'b1001,
				FILL_0010   = 4'b1010,
				FILL_0011   = 4'b1011,
				FILL_0012   = 4'b1100;
				
reg	[3:0]		Fill_StateMachine;
reg 	[23:0]	Fill_ByteCounts;
reg				DMA_Fill_Write_Lo;
reg				DMA_Fill_Write_Hi;
reg 	[21:0]	DMA_Fill_Step_Counter;
reg 	[21:0]	DMA_Fill_Stride_Counter;
wire	[21:0]	DMA_FILL_ADDY;
reg	[15:0]	DMA_Y_Counter;

assign DMA_FILL_ADDY	= VDMA_Dst_Addy_i + DMA_Fill_Step_Counter + DMA_Fill_Stride_Counter;
//assign VDMA_Fill_Write_Enable = !Valid_Capture_Time_EDGE[2];

always @ (posedge EngineClk100Mhz_i) begin
	if (IID_Engine_Rst_i | VideoModeReset_i) begin
			Fill_ByteCounts			<= 24'h00_0000;
			DMA_Fill_Write_Lo			<= 1'b0;
			DMA_Fill_Write_Hi			<= 1'b0;
			Fill_StateMachine			<= FILL_IDLE;		
	end
	else begin
	
		case( Fill_StateMachine )

		// Wait for the 
		FILL_IDLE: begin 
		 if ( Fire_Fill_Function[3] ) begin
			Fill_StateMachine <= FILL_0001;		 
			if (VDMA_Control_Reg_i[1]) begin
				DMA_Y_Counter		<= VDMA_Y_Size_i;
				Fill_ByteCounts   <= VDMA_X_Size_i;
			end
			else begin
				Fill_ByteCounts   <= TransferByteCount;
			end		 
		 end
		 else begin
			Fill_StateMachine				<= FILL_IDLE;
			DMA_Fill_Step_Counter 		<= 22'h00_0000;
			DMA_Fill_Stride_Counter 	<= 22'h00_0000;
		 end
		end
		
		// Fill 1D
		FILL_0001: begin 
			if (!Valid_Capture_Time_EDGE[2]) begin
				if (Dst_First_Odd_Write) begin
					DMA_Fill_Write_Hi 		<= 1'b1;	// The Stored Value is valid
					DMA_Fill_Write_Lo 		<= 1'b0;	// The Stored Value is valid
					Fill_StateMachine 		<= FILL_0003;
				end
				else begin
					DMA_Fill_Write_Hi 		<= 1'b1;	// The Stored Value is valid
					DMA_Fill_Write_Lo 		<= 1'b1;	// The Stored Value is valid
					Fill_StateMachine 	<= FILL_0004; // Jump in that State If the Start Address is ODD
				end
			end
			else begin
				Fill_StateMachine <= FILL_0001;				
			end		
		end
		
		// ODD Start (High Part Start)
		// Index 0
/*
		FILL_0002: begin
			if (!Valid_Capture_Time_EDGE[2]) begin		
				DMA_Fill_Write_Hi 		<= 1'b1;	// The Stored Value is valid
				DMA_Fill_Write_Lo 		<= 1'b0;	// The Stored Value is valid
				Fill_StateMachine 		<= FILL_0003;
			end
			else begin
				Fill_StateMachine <= FILL_0002;
			end
		end
*/

		FILL_0003: begin
			if (!Valid_Capture_Time_EDGE[2]) begin		
				DMA_Fill_Step_Counter 	<= DMA_Fill_Step_Counter + 1;	// DMA_Fill_Step_Counter = DMA_Fill_Step_Counter + 1
				Fill_ByteCounts   		<= Fill_ByteCounts - 1;
				DMA_Fill_Write_Hi 		<= 1'b1;	// The Stored Value is valid
				DMA_Fill_Write_Lo 		<= 1'b1;	// The Stored Value is valid
				Fill_StateMachine 		<= FILL_0004;
			end
			else begin
				Fill_StateMachine <= FILL_0003;
			end			
		end

		
		FILL_0004: begin
			if (!Valid_Capture_Time_EDGE[2]) begin			
				if (Fill_ByteCounts[23:1]) begin
					DMA_Fill_Step_Counter 	<= DMA_Fill_Step_Counter + 2; // DMA_Fill_Step_Counter = DMA_Fill_Step_Counter + 2
					Fill_ByteCounts   		<= Fill_ByteCounts - 2;
				end
				else begin
					if ( Dst_Last_Even_Write ) begin
						DMA_Fill_Step_Counter 	<= DMA_Fill_Step_Counter + 1; // DMA_Fill_Step_Counter = DMA_Fill_Step_Counter + 2
						Fill_ByteCounts   		<= Fill_ByteCounts - 1;
						DMA_Fill_Write_Hi 		<= 1'b0;	// The Stored Value is valid
						DMA_Fill_Write_Lo 		<= 1'b1;	// The Stored Value is valid
						Fill_StateMachine 		<= FILL_0005;					
					end
					else begin
						DMA_Fill_Write_Hi 		<= 1'b0;	// The Stored Value is valid
						DMA_Fill_Write_Lo 		<= 1'b0;	// The Stored Value is valid
						Fill_StateMachine 		<= FILL_0006;	
					end
				end
			end
			else begin
				Fill_StateMachine <= FILL_0004;
			end				
		end
		
		FILL_0005: begin
			if (!Valid_Capture_Time_EDGE[2]) begin			
				DMA_Fill_Write_Hi 		<= 1'b0;	// The Stored Value is valid
				DMA_Fill_Write_Lo 		<= 1'b0;	// The Stored Value is valid
				Fill_StateMachine 		<= FILL_0006;
			end
			else begin
				Fill_StateMachine <= FILL_0005;
			end
		end
		
		FILL_0006: begin
			if (!Valid_Capture_Time_EDGE[2]) begin			
				if (VDMA_Control_Reg_i[1]) begin
					if (DMA_Y_Counter) begin
						DMA_Fill_Stride_Counter <= DMA_Fill_Stride_Counter + {VDMA_Dst_Stride_i[15:1], 1'b0};
						DMA_Fill_Step_Counter   <= 16'h0000;
						DMA_Y_Counter 				<= DMA_Y_Counter - 1;
						Fill_ByteCounts   		<= VDMA_X_Size_i;
						Fill_StateMachine 		<= FILL_0001;
					end
					else begin
						Fill_StateMachine <= FILL_0007;				
					end
				end
				else begin
				// 1D Transfer Done
					Fill_StateMachine <= FILL_0007;
				end
			end
			else begin
				Fill_StateMachine <= FILL_0006;
			end			
		
		end
		// 2D Fill
		FILL_0007: begin
				Fill_StateMachine <= FILL_IDLE;	
		end
		
		default: begin 
				Fill_StateMachine <= FILL_IDLE;		
		end

		endcase
	end
end





/*
wire	[63:0]	 Chipscope;
wire				Trigger;
assign Chipscope[4:0] 	= IID_VDMA_Engine_SM;
assign Chipscope[15:8] = DMA_Data_2_Write_LL;
assign Chipscope[37:16] = IID_Engine_VidMemAddy_o;
assign Chipscope[58:38] = Tfr_ByteCounts;
assign Chipscope[59] = Dst_First_Odd_Write;
assign Chipscope[60] = Dst_Last_Even_Write;
assign Chipscope[61] = IID_Engine_MEM_VID_WEHn_o;
assign Chipscope[62] = IID_Engine_MEM_VID_WELn_o;
assign Chipscope[63] = DMA_In_Progress;

assign Trigger = ((Valid_Capture_Time_EDGE[2] == 0) ? 1'b1 : 1'b0) & ((IID_VDMA_Engine_SM != VDMA_INIT_REG) ? 1'b1 : 1'b0);

ChipScope IntelChipScope(
		.acq_clk(EngineClk100Mhz_i),        //    acq_clk.clk
		.acq_data_in(Chipscope),    //        tap.acq_data_in
		.acq_trigger_in(Trigger), //           .acq_trigger_in
		.trigger_in(Trigger)      // trigger_in.trigger_in
	);
*/

endmodule

//
//VDMA_Control_Register[0] = Enable VDMA Block 
//VDMA_Control_Register[1] = 1D/2D Transfer (0 - (1D) Linear ({Y_Size_L, X_Size_H, X_Size_L}), 1 - 2D ((X Size + (Stride)) x Y Size)
//VDMA_Control_Register[2] = Src/Dst Transfer, Data2WriteDst (0 - Read Source -> Write Destination) - (1 - Read Byte to Write -> Write Destination) (Short Transfer)
//VDMA_Control_Register[3] = Enable VDMA Interrupt (VDMA Tsf done)
//VDMA_Control_Register[4] = TBD
//VDMA_Control_Register[5] = TBD
//VDMA_Control_Register[6] = TBD
//VDMA_Control_Register[7] = Start Transfer


/*

		default: begin
				IID_VDMA_Engine_SM	<= VDMA_IDLE;
		end
		
		
		//
		//0xB
		FETCH_VDMD_PIX0: begin
			VDMA_Read_Strobe_n <= 1'b0; // Begin Read Cycles
			IID_VDMA_Engine_SM	<= FETCH_VDMD_PIX1;
		end
		
		// Address for External RAM is Valid Here
		//0xC
		FETCH_VDMD_PIX1: begin
			IID_Engine_VDMA_WE_o 	<= 1'b1;
			IID_VDMA_Engine_SM	<= FETCH_VDMD_PIX2;	
		end

		// Data from External RAM is Valid Here (This is where we need to Check for 16 Pixels (8 Pixels)
		FETCH_VDMD_PIX2: begin
			if (VDMA_PixelCount) begin	// This should 640 / 2 = 320
				VDMA_PixelCount <= VDMA_PixelCount - 16'h0001;
				IID_VDMA_Engine_SM		<= FETCH_VDMD_PIX2;
			end
			else begin
				VDMA_Read_Strobe_n 	<= 1'b1;
				IID_VDMA_Engine_SM		<= FETCH_SP_16PIX3;				
			end
		end
		
		FETCH_VDMD_PIX3: begin
			IID_Engine_VDMA_WE_o 	<= 1'b0;
			//TileMAP_X_Counter <= TileMAP_X_Counter + 1'b1;	// Now Switch Character
			IID_VDMA_Engine_SM 	<= NEXTCHANNEL;			
		end

		// When the Line has been Drawned
		SP_VDMA_DONE: begin
				IID_VDMA_Engine_SM <= VDMA_IDLE;	// If we haven't reach the last line, go wait for another Trigger
		end

*/
