`timescale 1 ns / 1 ns

module VIDEOMEM_CTRL
(
input		wire				rst,
input		wire				EngineClk100Mhz_i,
input		wire				TransferClk_i,
input		wire				Bus_Clk_i,

// Video Timming Signals
input		wire				VideoClk_i,
input		wire				VideoRst_i,
input		wire	[11:0]	HLineCount_i,
input		wire	[11:0]	HPixelCount_i,
input		wire				Vsync_i,
input		wire				VBlanking_i,
input		wire				HBlanking_i,

input		wire	[11:0]	Total_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Total_Line_Per_Image_Value_i,
input		wire	[11:0]	H_Blanking_Value_i,
input		wire	[11:0]	V_Blanking_Value_i,
input		wire	[11:0]	Visible_Pixel_Per_Line_Value_i,
input		wire	[11:0]	Visible_Line_Per_Line_Value_i,
input		wire				VideoModeReset_i,

input		wire	[23:0]	Reg_Border_Color_i,

// VDMA PORT
input		wire	[7:0]		VDMA_Control_Reg_i,
input 	wire	[7:0]		VDMA_Data_2_Write_i,
input		wire	[23:0]	VDMA_Src_Addy_i,
input		wire	[23:0]	VDMA_Dst_Addy_i,
input		wire	[15:0]	VDMA_X_Size_i,
input		wire	[15:0]	VDMA_Y_Size_i,
input		wire	[15:0]	VDMA_Src_Stride_i,
input		wire	[15:0]	VDMA_Dst_Stride_i,
output	wire	[7:0]		VDMA_Status_Reg_o,
output	wire				VDMA_Interrupt_o,

// Pixel Output
output	wire	[31:0]	IID_Engine_RGB_Pixel_o,
output	wire	[7:0]		Border_Blue_o,
output	wire	[7:0]		Border_Green_o,
output	wire	[7:0]		Border_Red_o,

input		wire	[7:0]		Background_Blue_i,
input		wire	[7:0]		Background_Green_i,
input		wire	[7:0]		Background_Red_i,

input		wire				Horizontal_Border_i,
input	   wire				Vertical_Border_i,
input		wire				Horizontal_Precharge_i,
input		wire				IID_Engine_VBlanking_i,
input		wire				SOF_i,
input		wire				Disable_VideoProcessing_i,
input		wire				BitMapEnable_i,
input		wire				TileMapEnable_i,
input		wire				SpriteEnable_i,
// CPU Interface
input		wire	[23:0]	Bus_A_i,
input		wire				Bus_RW_i,
input		wire				Bus_RDY_i,
input		wire	[7:0]		Bus_D_i,

input		wire				CS_Bitmap_Reg_i,
input		wire				CS_Tile_Reg_i,
input		wire				CS_Sprite_Reg_i,

input		wire				CS_LUT0_i,
input		wire				CS_LUT1_i,
input		wire				CS_LUT2_i,
input		wire				CS_LUT3_i,
input		wire				CS_LUT4_i,
input		wire				CS_LUT5_i,
input		wire				CS_LUT6_i,
input		wire				CS_LUT7_i,

input		wire				CS_Tile_Map_i,
input		wire				CS_VIDEO_RAM_i,

output	wire	[7:0]		Bus_Bitmap_Data_o,
output	wire	[7:0]		Bus_LUT0_Data_o,
output	wire	[7:0]		Bus_LUT1_Data_o,
output	wire	[7:0]		Bus_LUT2_Data_o,
output	wire	[7:0]		Bus_LUT3_Data_o,
output	wire	[7:0]		Bus_LUT4_Data_o,
output	wire	[7:0]		Bus_LUT5_Data_o,
output	wire	[7:0]		Bus_LUT6_Data_o,
output	wire	[7:0]		Bus_LUT7_Data_o,

output	wire	[7:0]		Bus_Tile_Map_o,
// Video Memory Interface

// Memory Interface
output	wire	[19:0]	VGE_Addy_o,	// 1Mx32
input		wire	[31:0]	VGE_VidMem_Data_i,
output	wire	[31:0]	VGE_VidMem_Data_o,
output	wire				VGE_VidMem_Readn_o,
output   wire	[3:0]		VGE_VidMem_Writen_o
);

wire				CPU_CMD_Read;
wire	[31:0]	CPU_CMD;
wire				CPU_CMD_Rd_Empty;
wire	[7:0]		CPU_CMD_Rd_usedw;


// when Receiving a CMD from Video Raster
reg	[8:0]		CMD_COUNT;
reg				CMD_COLOR;
reg	[21:0]	CMD_POINTER;
reg	[21:0]	CMD_CPU_POINTER;

wire	[19:0]	IID_Engine_VidMemAddy;

wire				IID_Engine_Start_Process;

wire	[2:0]		LUT_TM0;
wire	[2:0]		LUT_TM1;
wire	[2:0]		LUT_TM2;
wire	[2:0]		LUT_TM3;

//assign 	Border_Enable 	= Horizontal_Border_o | Vertical_Border_o;
assign 	Border_Blue_o 	= Reg_Border_Color_i[7:0];
assign	Border_Green_o = Reg_Border_Color_i[15:8];
assign	Border_Red_o 	= Reg_Border_Color_i[23:16];

// STEF - DON'T FORGET... YOU ARE DEALING wITH A 16Bits WIDE MEMORY BUS

reg	[1:0]		Transaction_Slip;

always @ (negedge Bus_Clk_i)
begin
	if (rst) begin
		Transaction_Slip[1:0] <= 2'b00;
	end
	else begin
		Transaction_Slip[0] <= CS_VIDEO_RAM_i;
		Transaction_Slip[1] <= Transaction_Slip[0];
	end
end

// When the CPU Writes to the Memory, it is always going to be 1 Byte @ the time, every 35ns
CPU_2_MEM CPU2MEM_CMD_FIFO(
	.data({Bus_D_i, 1'b1, Bus_RW_i, !Bus_A_i[21], !Bus_A_i[20], Bus_A_i[19:0]}),
	.wrclk(!Bus_Clk_i),
	.wrreq(({Transaction_Slip[0], CS_VIDEO_RAM_i } == 2'b01)),	
	.wrfull(),

	.rdclk(EngineClk100Mhz_i),
	.rdreq(CPU_CMD_Read),
	.q(CPU_CMD),
	.rdusedw(CPU_CMD_Rd_usedw),		// 8 Bit Output of How much there is left.
	.rdempty(CPU_CMD_Rd_Empty)
);

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
////
////  FIID Graphic Engine Logic
////
////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//
wire				BitMapGraphic_Enable;
wire	[2:0]		BitMapGraphic_LUT;
wire	[21:0]	BitMapGraphic_Addy0;
wire	[15:0]	BitMapGraphic_SizeX;
wire	[15:0]	BitMapGraphic_SizeY;
wire	[21:0]	BitMapGraphic_Addy1;
wire	[3:0]		Map3Graphic_OffsetY;
// Address Pointer for MAP Memory
wire  [12:0]	TileMapPointer;

// Data Output from Tile MAP Memory
wire	[7:0]		TileMap_Active2Tile;
// Signals to Drive each Layers
wire 				IID_Engine_BM_WE;
wire				IID_Engine_TL3_WE;
wire				IID_Engine_TL2_WE;
wire				IID_Engine_TL1_WE;
wire				IID_Engine_TL0_WE;
wire				IID_Engine_SP0_WE;
wire				IID_Engine_SP1_WE;
wire				IID_Engine_SP2_WE;
wire				IID_Engine_SP3_WE;
wire				IID_Engine_SP4_WE;
wire	[7:0]		IID_Engine_EffectChannel_BM_ADDY;
wire	[7:0]		IID_Engine_EffectChannel_TL_ADDY;
wire	[9:0]		IID_Engine_EffectChannel_SP_ADDY;

wire  [31:0]	Mem2PixelLine_Data_BM;			// [15:0] - Since it is the while line we write, then 15Bits at the time works
wire  [31:0]	Mem2PixelLine_Data_TL;			// [15:0] - Since it is the while line we write, then 15Bits at the time works
wire  [7:0]		Mem2PixelLine_Data_SP;			// [7:0] - This can't work with Sprites, so the state machine will have to fetch data and place it @ the byte level
//
wire				BM_DataValid;
wire				BM_DoneReading;
wire				IID_Engine_Captured_Lines_Done;

wire 	[21:0]	BM_Address_2_Read;
wire	[9:0]		BM_NumberofPixel2Fetch;

wire	[1:0]		TileLayerSelect;
wire	[7:0]		TileLayer_Control_Reg;
wire	[23:0] 	TileLayer_Address_Ptr;
wire	[11:0]	TileLayer_X_Stride;
wire	[11:0]	TileLayer_Y_Stride;
wire	[3:0]		TileLayer_X_Offset;
wire	[3:0]		TileLayer_Y_Offset;
wire	[15:0]	Sprite_X_Coordinate;
wire	[15:0]	Sprite_Y_Coordinate;
wire	[23:0]	Sprite_Address_Ptr;
wire	[7:0]		Sprite_Control_Reg;
wire	[4:0]		Sprite_Select;

////////////////////////////////////
////////////////////////////////////
// BITMMAP REGISTER BLOCK
////////////////////////////////////
////////////////////////////////////
Tile_System_RegisterLevel_16Bytes BitmapReg
(
	.rst_i( rst ),				// This is async Reset
// CPU Signals Interface
	.Bus_Clk_i( Bus_Clk_i ),
	.Bus_A_i( Bus_A_i ),
	.Bus_D_i( Bus_D_i ),
	.Bus_D_o( Bus_Bitmap_Data_o ),
	.Bus_RW_i( Bus_RW_i ),
	.Tile_CS_i( CS_Bitmap_Reg_i ),
// Output to the F2DEngine
	.TileLayer_Enable_o( BitMapGraphic_Enable ),		// 1 Bit
	.TileLayer_Lut_o( BitMapGraphic_LUT ),			// 3 Bits
	
	.TileMapAddy_o( BitMapGraphic_Addy0 ),				// 24 Bit Address (22 Only Necessary)
	.TileMapSize_o( BitMapGraphic_SizeX ),				// 16 Bit Size (X)
	.TileMapStride_o( BitMapGraphic_SizeY ),			// 16 Bit Size (Y)
	
	.TileGrapTableAddy_o( BitMapGraphic_Addy1 ),		// 24 Bits Address (22 Only Necessary)
	.TileGrapSize_o(  ),			// 16 Bit Size
	.TileGrapStride_o(  ),			// 16 Bit Stride
	.TileGrapX_Offset_o(  ),		// 4 Bit
	.TileGrapY_Offset_o(  )		// 4 Bits
);

Tile_Registers_Blk TileBlock(
	.rst_i( rst ),				// This is async Reset
	// CPU Signals Interface
	.Bus_Clk_i( Bus_Clk_i ),
	.Bus_A_i( Bus_A_i ),
	.Bus_D_i( Bus_D_i ),
	.Bus_RW_i( Bus_RW_i ),
	.Tile_CS_i( CS_Tile_Reg_i ),
// Output to the F2DEngine

	.IID_Engine_Clk_i( EngineClk100Mhz_i ),
	.TileLayerSelect_i( TileLayerSelect ),
	.TileLayer_Control_Reg( TileLayer_Control_Reg ),
	.TileLayer_Address_Ptr( TileLayer_Address_Ptr ),
	.TileLayer_X_Stride( TileLayer_X_Stride ),
	.TileLayer_Y_Stride( TileLayer_Y_Stride ),
	.TileLayer_X_Offset( TileLayer_X_Offset ),
	.TileLayer_Y_Offset( TileLayer_Y_Offset )
);

SPRITES_Register_Block SpriteBlock(
	.rst_i( rst ),				// This is async Reset
// CPU Signals Interface
	.Bus_Clk_i( Bus_Clk_i ),
	.Bus_A_i( Bus_A_i ),
	.Bus_D_i( Bus_D_i ),
	.Bus_RW_i( Bus_RW_i ),
	.Sprite_CS_i( CS_Sprite_Reg_i ),
	.IID_Engine_Clk_i( TransferClk_i ),
	.Sprite_Select_i( Sprite_Select ),
	.Sprite_Control_Reg_o( Sprite_Control_Reg ),
	.Sprite_Address_Ptr_o( Sprite_Address_Ptr ),
	.Sprite_X_Coordinate_o( Sprite_X_Coordinate ),
	.Sprite_Y_Coordinate_o( Sprite_Y_Coordinate )
);

 TileMapMem TILEMapMemBlock(
	.address_a( {!Bus_A_i[12], Bus_A_i[11:0]} ),
	.address_b( TileMapPointer ),
	.clock_a( !Bus_Clk_i ),
	.clock_b( EngineClk100Mhz_i ),
	.data_a( Bus_D_i ),
	.data_b( 8'h00 ),
	.wren_a( CS_Tile_Map_i & !Bus_RW_i),
	.wren_b( 1'b0 ),
	.q_a( Bus_Tile_Map_o ),
	.q_b( TileMap_Active2Tile )
);

IID_Engine_Memory_Controller IID_ENGINE(
	.IID_Engine_Rst_i( rst ),
	.EngineClk100Mhz_i( EngineClk100Mhz_i ),
	.EngineClk200Mhz_i( TransferClk_i ),
// Videa Signals to Enable the Engine
	.IID_Engine_VideoClk_i( VideoClk_i ),
	.IID_Engine_VideoRst_i( VideoRst_i ),
	.IID_Engine_HLineCount_i( HLineCount_i ),			//input		wire	[11:0]	
	.IID_Engine_HPixelCount_i( HPixelCount_i ),		//input		wire	[11:0]	
	.IID_Engine_VBlanking_i( VBlanking_i ),
	.IID_Engine_HBlanking_i( HBlanking_i ),
	.IID_Engine_SOF_i(SOF_i),
	.IID_Engine_VBlankingSpecial_i( IID_Engine_VBlanking_i ),
	.IID_Engine_Disable_VideoProcessing_i( Disable_VideoProcessing_i ),
	
	.Total_Pixel_Per_Line_Value_i( Total_Pixel_Per_Line_Value_i ),
	.Total_Line_Per_Image_Value_i( Total_Line_Per_Image_Value_i ),
	.H_Blanking_Value_i( H_Blanking_Value_i ),
	.V_Blanking_Value_i( V_Blanking_Value_i ),
	.Visible_Pixel_Per_Line_Value_i( Visible_Pixel_Per_Line_Value_i ),
	.Visible_Line_Per_Line_Value_i( Visible_Line_Per_Line_Value_i ),
	.VideoModeReset_i( VideoModeReset_i ),		

// VDMA PORT
	.VDMA_Control_Reg_i( VDMA_Control_Reg_i ),
	.VDMA_Data_2_Write_i( VDMA_Data_2_Write_i ),	
	.VDMA_Src_Addy_i( VDMA_Src_Addy_i ),
	.VDMA_Dst_Addy_i( VDMA_Dst_Addy_i ),
	.VDMA_X_Size_i( VDMA_X_Size_i ),
	.VDMA_Y_Size_i( VDMA_Y_Size_i ),	
	.VDMA_Src_Stride_i( VDMA_Src_Stride_i ),
	.VDMA_Dst_Stride_i( VDMA_Dst_Stride_i ),	
	.VDMA_Status_Reg_o( VDMA_Status_Reg_o ),
	.VDMA_Interrupt_o( VDMA_Interrupt_o ),
	
// CPU Direct Access Port
// CPU FIFO Port
	.CPU_Access_Cmd_i( CPU_CMD ),
	.CPU_Access_Rd_Strobe_o( CPU_CMD_Read ),
	.CPU_Access_CMD_Rd_Empty_i( CPU_CMD_Rd_Empty ),
	.CPU_Access_CMD_Number_i( CPU_CMD_Rd_usedw ),
	
// State-Machines Status
	.IID_Engine_Start_Process_o( IID_Engine_Start_Process ),			// Signal to Prime Each State-Machine.
	.IID_Engine_Captured_Lines_Done_o( IID_Engine_Captured_Lines_Done ),
// BITMAP
	.IID_Engine_BM_Enable_i( BitMapEnable_i ),
	.IID_Engine_BM_MapStartAddress_i( BitMapGraphic_Addy0 ),	// We are Going to have only one address for now
	.IID_Engine_BM_SizeX_i( BitMapGraphic_SizeX ),
	.IID_Engine_BM_SizeY_i( BitMapGraphic_SizeY ),
// TILE
	.Tile_Block_Enable_i( TileMapEnable_i ),
	.Tile_Layer_Select_o( TileLayerSelect  ),
	.Tile_Layer_Control_Reg_i( TileLayer_Control_Reg ),
	.Tile_Layer_Address_Ptr_i( TileLayer_Address_Ptr ),
	.Tile_X_Stride_i( TileLayer_X_Stride ),
	.Tile_Y_Stride_i( TileLayer_Y_Stride ),
	.Tile_X_Offset_i( TileLayer_X_Offset ),
	.Tile_Y_Offset_i( TileLayer_Y_Offset ),
	.LUT_TM0_o( LUT_TM0 ),
	.LUT_TM1_o( LUT_TM1 ),
	.LUT_TM2_o( LUT_TM2 ),
	.LUT_TM3_o( LUT_TM3 ),
// TILE MAP Access
// Access to the Tile Map Memory 
	.TileMapPointer_o( TileMapPointer ),
// DATA Port
	.TileMap_Active2Tile_i( TileMap_Active2Tile ), // 1 Bytes
// SPRITE	
	.Sprite_Block_Enable_i( SpriteEnable_i ),
	.Sprite_Select_o( Sprite_Select ),
	.Sprite_Control_Reg_i( Sprite_Control_Reg ),
	.Sprite_Address_Ptr_i( Sprite_Address_Ptr ), 
	.Sprite_X_Coordinate_i( Sprite_X_Coordinate ),
	.Sprite_Y_Coordinate_i( Sprite_Y_Coordinate ),

// Signals towards the Layer System
	.IID_Engine_BM_WE_o( IID_Engine_BM_WE ),				// Bitmap
	.IID_Engine_TL3_WE_o( IID_Engine_TL3_WE ),				// Tile Layer 0
	.IID_Engine_TL2_WE_o( IID_Engine_TL2_WE ),		// Tile Layer 1
	.IID_Engine_TL1_WE_o( IID_Engine_TL1_WE ),		// Tile Layer 2
	.IID_Engine_TL0_WE_o( IID_Engine_TL0_WE ),		// Tile Layer 3
	.IID_Engine_SP0_WE_o( IID_Engine_SP0_WE ),		// Front Sprite
	.IID_Engine_SP1_WE_o( IID_Engine_SP1_WE ),		// In-Between Sprite 0
	.IID_Engine_SP2_WE_o( IID_Engine_SP2_WE ),		// In-Between Sprite 1
	.IID_Engine_SP3_WE_o( IID_Engine_SP3_WE ),		// In-Between Sprite 2
	.IID_Engine_SP4_WE_o( IID_Engine_SP4_WE ),		// In-Between Sprite 3
	.IID_Engine_EffectChannel_BM_ADDY_o( IID_Engine_EffectChannel_BM_ADDY ),
	.IID_Engine_EffectChannel_TL_ADDY_o( IID_Engine_EffectChannel_TL_ADDY ),
	.IID_Engine_EffectChannel_SP_ADDY_o( IID_Engine_EffectChannel_SP_ADDY ),
	.Mem2PixelLine_Data_BM_o( Mem2PixelLine_Data_BM ),			// [15:0] - Since it is the while line we write, then 15Bits at the time works
	.Mem2PixelLine_Data_TL_o( Mem2PixelLine_Data_TL ),			// [15:0] - Since it is the while line we write, then 15Bits at the time works
	.Mem2PixelLine_Data_SP_o( Mem2PixelLine_Data_SP ),			// [7:0] - This can't work with Sprites, so the state machine will have to fetch data and place it @ the byte level	

//////////////////////////////////
// External Video Memory Interface
//////////////////////////////////
	.VGE_Addy_o( VGE_Addy_o ),	// 1Mx32
	.VGE_VidMem_Data_i( VGE_VidMem_Data_i ),
	.VGE_VidMem_Data_o( VGE_VidMem_Data_o ),
	.VGE_VidMem_Readn_o( VGE_VidMem_Readn_o ),
	.VGE_VidMem_Writen_o( VGE_VidMem_Writen_o )	
);


BitMap_Layer_System Layering_System_Block(
	.TransferClk_i(TransferClk_i),
	.Vid_Clk( VideoClk_i ),
	.Mem_Clk( EngineClk100Mhz_i ),
	.Rst_i( rst ), 
	.VideoRst_i ( VideoRst_i ),
	.HLineCount_i( HLineCount_i ),
	.HPixelCount_i( HPixelCount_i ),
	.VBlanking_i( VBlanking_i ),
	.HBlanking_i( HBlanking_i ),	

	.Total_Pixel_Per_Line_Value_i( Total_Pixel_Per_Line_Value_i ),
	.Total_Line_Per_Image_Value_i( Total_Line_Per_Image_Value_i ),
	.H_Blanking_Value_i( H_Blanking_Value_i ),
	.V_Blanking_Value_i( V_Blanking_Value_i ),
	.Visible_Pixel_Per_Line_Value_i( Visible_Pixel_Per_Line_Value_i ),
	.Visible_Line_Per_Line_Value_i( Visible_Line_Per_Line_Value_i ),
	.VideoModeReset_i( VideoModeReset_i ),			
	
// Text Box Active Signals
	.Vertical_Border_i( Vertical_Border_i ),
	.Horizontal_Border_i( Horizontal_Border_i ),
	.Horizontal_Precharge_i( Horizontal_Precharge_i ),
	.IID_Engine_RGB_Pixel_o( IID_Engine_RGB_Pixel_o ),		// Graphic BGR Output towards the Display MUX

	.Background_Blue_i( Background_Blue_i ),
	.Background_Green_i( Background_Green_i ),
	.Background_Red_i( Background_Red_i ),	
	
// 1 Pulse Start Of Frame (8 Pixel Long)
	.SOF_i( SOF_i ),
// This is the Interface from Exterior Mem to Dual Port
	.IID_Engine_Captured_Lines_Done_i( IID_Engine_Captured_Lines_Done ),
// Signals towards the Layer System
	.IID_Engine_BM_WE_i( IID_Engine_BM_WE ),				// Bitmap
	.IID_Engine_TL3_WE_i( IID_Engine_TL3_WE ),				// Tile Layer 0
	.IID_Engine_TL2_WE_i( IID_Engine_TL2_WE ),		// Tile Layer 1
	.IID_Engine_TL1_WE_i( IID_Engine_TL1_WE ),		// Tile Layer 2
	.IID_Engine_TL0_WE_i( IID_Engine_TL0_WE ),		// Tile Layer 3
	.IID_Engine_SP0_WE_i( IID_Engine_SP0_WE ),		// Front Sprite
	.IID_Engine_SP1_WE_i( IID_Engine_SP1_WE ),		// In-Between Sprite 0
	.IID_Engine_SP2_WE_i( IID_Engine_SP2_WE ),		// In-Between Sprite 1
	.IID_Engine_SP3_WE_i( IID_Engine_SP3_WE ),		// In-Between Sprite 2
	.IID_Engine_SP4_WE_i( IID_Engine_SP4_WE ),		// In-Between Sprite 3
	.IID_Engine_EffectChannel_BM_ADDY_i( IID_Engine_EffectChannel_BM_ADDY ),
	.IID_Engine_EffectChannel_TL_ADDY_i( IID_Engine_EffectChannel_TL_ADDY ),
	.IID_Engine_EffectChannel_SP_ADDY_i( IID_Engine_EffectChannel_SP_ADDY ),
	.Mem2PixelLine_Data_BM_i( Mem2PixelLine_Data_BM ),			// [15:0] - Since it is the while line we write, then 15Bits at the time works
	.Mem2PixelLine_Data_TL_i( Mem2PixelLine_Data_TL ),			// [15:0] - Since it is the while line we write, then 15Bits at the time works
	.Mem2PixelLine_Data_SP_i( Mem2PixelLine_Data_SP ),			// [7:0] - This can't work with Sprites, so the state machine will have to fetch data and place it @ the byte level	

	.Sprite_Select_i( Sprite_Select ),
	.Sprite_Control_Reg_i( Sprite_Control_Reg ),
	
	.Tile_Layer_Select_i( TileLayerSelect ),
	.Tile_Layer_Control_Reg_i( TileLayer_Control_Reg ),
	
	.LUT_BM_i( 3'b000 ),
	.LUT_TM0_i( LUT_TM0 ),
	.LUT_TM1_i( LUT_TM1 ),
	.LUT_TM2_i( LUT_TM2 ),
	.LUT_TM3_i( LUT_TM3 ),
	.LUT_SP0_i( 3'b001 ),
	.LUT_SP1_i( 3'b000 ),
	.LUT_SP2_i( 3'b000 ),
	.LUT_SP3_i( 3'b000 ),
	.LUT_SP4_i( 3'b000 ),	

	.LUT_TM0_X_OFFSET_i( 4'h0 ),
	.LUT_TM1_X_OFFSET_i( 4'h0 ),
	.LUT_TM2_X_OFFSET_i( 4'h0 ),
	.LUT_TM3_X_OFFSET_i( 4'h0 ),

// CPU Interface to the 8 Look-Up Tables
	.Bus_Clk_i( Bus_Clk_i ),
	.Bus_A_i( Bus_A_i ),
	.Bus_D_i( Bus_D_i ),
	.Bus_RW_i( Bus_RW_i ),
	.CS_LUT0_i( CS_LUT0_i ),
	.CS_LUT1_i( CS_LUT1_i ),
	.CS_LUT2_i( CS_LUT2_i ),
	.CS_LUT3_i( CS_LUT3_i ),
	.CS_LUT4_i( CS_LUT4_i ),
	.CS_LUT5_i( CS_LUT5_i ),
	.CS_LUT6_i( CS_LUT6_i ),
	.CS_LUT7_i( CS_LUT7_i ),

	.Lut0_Data_o( Bus_LUT0_Data_o ),
	.Lut1_Data_o( Bus_LUT1_Data_o ),
	.Lut2_Data_o( Bus_LUT2_Data_o ),
	.Lut3_Data_o( Bus_LUT3_Data_o ),
	.Lut4_Data_o( Bus_LUT4_Data_o ),
	.Lut5_Data_o( Bus_LUT5_Data_o ),
	.Lut6_Data_o( Bus_LUT6_Data_o ),
	.Lut7_Data_o( Bus_LUT7_Data_o )
);

endmodule
