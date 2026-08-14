`timescale 1ns / 1ps
module VICKYIII_TOP (

// Reset
input		wire					Reset_i,
// Clocks
input		wire					CPU_Clk_i,				// CPU Clock - Could be 16/20/25/33/40/66/75
input		wire					Clk14_318Mhz_i,
input		wire					Clk24_576Mhz_i,

input		wire					Clk40_000Mhz_A_i, 
input		wire					Clk65_000Mhz_A_i,

input		wire					Clk25_175Mhz_B_i, 
input		wire					Clk40_000Mhz_B_i,

input		wire					Clk100M_A_i,
input		wire					Clk200M_A_i,
input		wire					Clk100M_B_i,
input		wire					Clk200M_B_i,

output	wire					VClock_LTC6903_A_CSn_o,
output	wire					VClock_LTC6903_B_CSn_o,
output	wire					VClock_LTC6903_SCLK_o,
output	wire					VClock_LTC6903_DIN_o,		//MoSi
input		wire					LTC6903_A_i,
input		wire					LTC6903_B_i,

// Buses
input		wire		[31:0]	iBUS_A_i,
input		wire					iBUS_A_Valid_i,
input		wire		[7:0]		iBUS_D8_i,
input		wire		[15:0]	iBUS_D16_i,
input		wire		[31:0]	iBUS_D32_i,
input		wire		[1:0]		iBUS_D_Siz_i,

output	wire					iBUS_D_Valid_o,
input		wire					iBUS_RWn_i,
input		wire		[3:0]		iBUS_BE_i,
input		wire					iBUS_WE_i,

input		wire					iBUS_CS_VICKY_A_i,
input		wire					iBUS_CS_VICKY_MEM_A_i,
input		wire					iBUS_CS_VICKY_B_i,
input		wire					iBUS_CS_VICKY_MEM_B_i,
input		wire					iBUS_CS_VRAM_A_i,
input		wire					iBUS_CS_VRAM_B_i,

output	wire		[31:0]	iBUS_D_VICKY_o,			// DataOutput From Vicky III - Slave

// Video
inout		wire					VID_SPC_io,		// IO
inout		wire					VID_SPD_io,		// IO
// Video DAC Output A
output	wire					VID_A_RSTn_o,
output	wire					VID_A_CLK_P_o,
output	wire					VID_A_DE_o,
output	wire					VID_A_HSYNC_o,
output	wire					VID_A_VSYNC_o,
output	wire		[11:0]	VID_A_PIX_o,
// Video RAM Bank A
inout		wire		[31:0]	VRAM_A_DQ_io,
output	wire		[3:0]		VRAM_A_BEn_o,
output	wire		[19:0]	VRAM_A_Addy_o,
output	wire					VRAM_A_OEn_o,
output	wire					VRAM_A_WEn_o,
// Video DAC Output B
// Graphic Side (Bitmap/Tile/Sprites)
output	wire					VID_B_CLK_P_o,
output	wire					VID_B_DE_o,
output	wire					VID_B_HSYNC_o,
output	wire					VID_B_RSTn_o,
output	wire					VID_B_VSYNC_o,
output	wire		[11:0]	VID_B_PIX_o,
// Video RAM Bank B
inout		wire		[31:0]	VRAM_B_DQ_io,
output	wire		[3:0]		VRAM_B_BEn_o,	
output	wire		[19:0]	VRAM_B_Addy_o,
output	wire					VRAM_B_OEn_o,
output	wire					VRAM_B_WEn_o,
// Splash Screen Flash
output	wire					CONFIG_CSn_o,
input		wire					CONFIG_MISO_i,
output	wire					CONFIG_MOSI_o,
output	wire					CONFIG_SCLK_o,

output	wire					SOF_Channel_A_o,
output	wire					SOF_Channel_B_o,

output	wire		[5:0]		VKY_III_Channel_A_IRQ_o,
output	wire		[5:0]		VKY_III_Channel_B_IRQ_o,

input		wire		[1:0]		DP_HIRES_i,
input		wire		[1:0] 	DP_GAMMA_i
);


wire iBUS_D_Valid_A;
wire iBUS_D_Valid_B;
assign iBUS_D_Valid_o = iBUS_D_Valid_A | iBUS_D_Valid_B;
// Temporary Assignments

// Splash Screen Flash
assign CONFIG_CSn_o 		= 1'b1;
assign CONFIG_MOSI_o 	= 1'b0;
assign CONFIG_SCLK_o 	= 1'b0;

//I2C Serial Wires
wire  [1:0]		BiDirOut;
wire	[1:0]		BiDirIn;
wire	[1:0]		BiDirOE;
wire	[1:0]		BiDirPAD;
wire 	[1:0] 	VID_A_VideoModeClk;
wire 	[1:0] 	VID_B_VideoModeClk;


I2CBIDIR BiDirectionBufferI2C( 
	.datain( BiDirIn ),					// What we want to drive with
	.dataio( {VID_SPD_io, VID_SPC_io} ),
	.dataout( BiDirOut ),							// What we receive from bus
	.oe( {!BiDirOE[1], !BiDirOE[0]} )
);

// I2C Initialization for the Video DAC 
InitClockAndVideo InitClk4Vid(
	.Bus_Clk_i( Clk24_576Mhz_i ),
	.Reset_i( Reset_i ),
	.scl_i( BiDirOut[0] ),
	.scl_o( BiDirIn[0] ),
	.scl_t( BiDirOE[0] ),
	.sda_i( BiDirOut[1] ),
	.sda_o( BiDirIn[1] ),
	.sda_t( BiDirOE[1] )
);


// Channel A
// Chip Select
wire				CS_TextMemory_A;
wire				CS_ColorMemory_A;
wire				CS_FG_CLUT_A;
wire				CS_BG_CLUT_A;
wire				CS_VICKY_REG_A;
wire 				CS_GAMMA_B_A;
wire 				CS_GAMMA_G_A;
wire 				CS_GAMMA_R_A;
wire 				CS_Mouse_Ptr_A_Registers;
wire 				CS_Mouse_Ptr_A_Graphics;

// Data Channel Coming Back
wire 	[31:0] 	iBUS_Text_Memory_A_D;
wire 	[31:0]	iBUS_Color_Memory_A_D;
wire	[31:0]	iBUS_VICKYIII_Reg_A_D;
wire 	[31:0] 	iBUS_GAMMA_B_A_D;
wire 	[31:0] 	iBUS_GAMMA_G_A_D;
wire 	[31:0] 	iBUS_GAMMA_R_A_D;

// Channel B
// Chip Select
wire				CS_TextMemory_B;
wire				CS_ColorMemory_B;
wire				CS_FG_CLUT_B;
wire				CS_BG_CLUT_B;
wire				CS_VICKY_REG_B;
wire				CS_Sprites_Registers_B;
wire 				CS_Bitmap_Registers_B;
wire 				CS_Tile0_Registers_B;
wire 				CS_Tile1_Registers_B;
wire 				CS_Collisions_Registers_B;
wire				CS_LUT_B;
wire 				CS_VIDEO_RAM_B0;
wire				CS_VIDEO_RAM_B1;
wire 				CS_GAMMA_B_B;
wire 				CS_GAMMA_G_B;
wire 				CS_GAMMA_R_B;
wire 				CS_Mouse_Ptr_B_Registers;
wire 				CS_Mouse_Ptr_B_Graphics;
wire				CS_VMEM_2_CPU_B;
wire				CS_VDMA_Controller_B;
wire				CS_FONT_A;
wire				CS_FONT_B;
// Data Channel Coming Back
wire	[31:0]	iBUS_Text_Memory_B_D;
wire 	[31:0]	iBUS_Color_Memory_B_D;
wire	[31:0]	iBUS_VICKYIII_Reg_B_D;
wire 	[31:0] 	DataOut_LUT_B;
wire 	[31:0] 	DataOut_VideoMemory_B;
wire 	[31:0] 	DataOut_Bitmap_Regs_B;
wire 	[31:0] 	DataOut_Tile0_Regs_B;
wire 	[31:0] 	DataOut_Tile1_Regs_B;
wire 	[31:0] 	DataOut_Collisions_Regs_B;
wire 	[31:0] 	DataOut_Sprites_Regs_B;
wire 	[31:0] 	iBUS_GAMMA_B_B_D;
wire 	[31:0] 	iBUS_GAMMA_G_B_D;
wire 	[31:0] 	iBUS_GAMMA_R_B_D;
wire 	[31:0] 	DataOut_Mouse_Regs_A;
wire 	[31:0] 	DataOut_Mouse_Regs_B;
/*
wire [7:0] Source;
wire [31:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);

assign Probe = 32'h0000_0000;
*/
/*
VICKY_III_Clock_Select  V3_ClockSelect(

	.CPU_Clk_i( CPU_Clk_i ),
	.Reset_i( Reset_i ),

	.VClock_LTC6903_SCLK_o( VClock_LTC6903_SCLK_o ),
	.VClock_LTC6903_DIN_o( VClock_LTC6903_DIN_o ),
	.VClock_LTC6903_A_CSn_o( VClock_LTC6903_A_CSn_o ),
	.VClock_LTC6903_B_CSn_o( VClock_LTC6903_B_CSn_o ),
	
	.Channel_A_Vid_Clk_Select_i( VID_A_VideoModeClk ),
	.Channel_B_Vid_Clk_Select_i( VID_B_VideoModeClk )
);
*/
assign VClock_LTC6903_SCLK_o = 1'b0;
assign VClock_LTC6903_DIN_o = 1'b0;
assign VClock_LTC6903_A_CSn_o = 1'b1;
assign VClock_LTC6903_B_CSn_o = 1'b1;


VICKY_III_CS_And_Dout VICKY_III_CS_DOUT(

// CPU Interface
	.CPU_Clk_i( CPU_Clk_i ),

	.iBUS_A_i( iBUS_A_i ),

	.iBUS_A_Valid_i( iBUS_A_Valid_i ),
	.iBUS_D8_i( iBUS_D8_i  ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),

	.iBUS_CS_VICKY_A_i( iBUS_CS_VICKY_A_i ),
	.iBUS_CS_VICKY_MEM_A_i( iBUS_CS_VICKY_MEM_A_i ),
	.iBUS_CS_VICKY_B_i( iBUS_CS_VICKY_B_i ),
	.iBUS_CS_VICKY_MEM_B_i( iBUS_CS_VICKY_MEM_B_i ),
	.iBUS_CS_VRAM_A_i( iBUS_CS_VRAM_A_i ),
	.iBUS_CS_VRAM_B_i( iBUS_CS_VRAM_B_i ),

	// Channel A
	.CS_TextMemory_A_o( CS_TextMemory_A ),
	.CS_ColorMemory_A_o( CS_ColorMemory_A ),
	.CS_BF_CLUT_A_o( CS_FG_CLUT_A ),
	.CS_BG_CLUT_A_o( CS_BG_CLUT_A ),
	.CS_VICKY_REG_A_o( CS_VICKY_REG_A ),
	.CS_Mouse_Ptr_A_Graphics_o( CS_Mouse_Ptr_A_Graphics ),
	.CS_Mouse_Ptr_A_Registers_o( CS_Mouse_Ptr_A_Registers ),	
	.CS_GAMMA_B_A_o( CS_GAMMA_B_A ),
	.CS_GAMMA_G_A_o( CS_GAMMA_G_A ),
	.CS_GAMMA_R_A_o( CS_GAMMA_R_A ),
	.CS_FONT_A_o( CS_FONT_A ), 
	// DataOut - For CPU to Read
	.TextMemory_A_Dout_i( iBUS_Text_Memory_A_D ),
	.ColorMemory_A_Dout_i( iBUS_Color_Memory_A_D ),
	.VICKYIII_Reg_A_Dout_i( iBUS_VICKYIII_Reg_A_D ),
	.MousePtr_Reg_A_Dout_i( DataOut_Mouse_Regs_A ),
	
	// Channel B
	.CS_TextMemory_B_o( CS_TextMemory_B ),	
	.CS_ColorMemory_B_o( CS_ColorMemory_B ), 
	.CS_BF_CLUT_B_o( CS_FG_CLUT_B ),
	.CS_BG_CLUT_B_o( CS_BG_CLUT_B ),	
	.CS_VICKY_REG_B_o( CS_VICKY_REG_B ),
	
	// VGE 
	.CS_Bitmap_B_Registers_o( CS_Bitmap_Registers_B ),
	.CS_Tile0_B_Registers_o( CS_Tile0_Registers_B ),
	.CS_Tile1_B_Registers_o( CS_Tile1_Registers_B ),
	.CS_Collisions_B_Registers_o( CS_Collisions_Registers_B ),
	.CS_Mouse_Ptr_B_Graphics_o( CS_Mouse_Ptr_B_Graphics ),
	.CS_Mouse_Ptr_B_Registers_o( CS_Mouse_Ptr_B_Registers ),
	.CS_Sprites_B_Registers_o( CS_Sprites_Registers_B ),	
	.CS_LUT0_B_o( CS_LUT_B ),
	.CS_VIDEO_RAM_B0_o( CS_VIDEO_RAM_B0 ),
	.CS_VIDEO_RAM_B1_o( CS_VIDEO_RAM_B1 ),
	.CS_GAMMA_B_B_o( CS_GAMMA_B_B ),
	.CS_GAMMA_G_B_o( CS_GAMMA_G_B ),
	.CS_GAMMA_R_B_o( CS_GAMMA_R_B ),
	.CS_VMEM_2_CPU_B_o( CS_VMEM_2_CPU_B ), 
	.CS_VDMA_Controller_B_o( CS_VDMA_Controller_B ),
	.CS_FONT_B_o( CS_FONT_B ), 	
	
	// DataOut - For CPU to Read
	.TextMemory_B_Dout_i( iBUS_Text_Memory_B_D ),
	.ColorMemory_B_Dout_i( iBUS_Color_Memory_B_D ),
	.VICKYIII_Reg_B_Dout_i( iBUS_VICKYIII_Reg_B_D ),
// VGE	
	.DataOut_B_LUT_i( DataOut_LUT_B ),
	.DataOut_B_VideoMemory_i( DataOut_VideoMemory_B ),
	.DataOut_B_Bitmap_Regs_i( DataOut_Bitmap_Regs_B ),
	.DataOut_B_Tile0_Regs_i( DataOut_Tile0_Regs_B ),
	.DataOut_B_Tile1_Regs_i( DataOut_Tile1_Regs_B ),
	.DataOut_B_Mouse_Regs_i( DataOut_Mouse_Regs_B ), 
	.DataOut_B_Collisions_Regs_i( DataOut_Collisions_Regs_B ),
	.DataOut_B_Sprites_Regs_i( DataOut_Sprites_Regs_B ),		

	.GAMMA_B_B_Dout_i( iBUS_GAMMA_B_B_D ),
	.GAMMA_G_B_Dout_i( iBUS_GAMMA_G_B_D ),
	.GAMMA_R_B_Dout_i( iBUS_GAMMA_R_B_D ),	
	
// DATAOUT to main CPU
	.DataOut_o( iBUS_D_VICKY_o )
);

/// Channel A Top ///
VICKY_III_Channel_A_Top Channel_A_Top(

// Reset
	.Reset_i( Reset_i ),
// Clocks
	.CPU_Clk_i( CPU_Clk_i ),				// CPU Clock - Could be 16/20/25/33/40/66/75

// VID CLOCKS
	.Clk14_318Mhz_i( Clk14_318Mhz_i ),
	.Clk40_000Mhz_i( Clk40_000Mhz_A_i ),	
	.Clk65_000Mhz_i( Clk65_000Mhz_A_i ), 

	
// CORE CLOCKS
	.Clk100M_i( Clk100M_A_i ),
	.Clk200M_i( Clk200M_A_i ),

	.Video_Clk_A_i(  LTC6903_A_i ), 
// DIP Switch
	.DP_HIRES_i( DP_HIRES_i[0] ),
	.DP_GAMMA_i( DP_GAMMA_i[0] ),


// Buses
	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),
	.iBUS_D8_i( iBUS_D8_i  ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),
	.iBUS_D_Valid_o( iBUS_D_Valid_A ),
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_WE_i( iBUS_WE_i ), 
	
	// Texy Mode Data Path Read
	.iBUS_Text_Memory_D_o( iBUS_Text_Memory_A_D ),
	.iBUS_Color_Memory_D_o( iBUS_Color_Memory_A_D ),
	.iBUS_VICKYIII_Reg_D_o( iBUS_VICKYIII_Reg_A_D ),
	.DataOut_A_Mouse_Regs_o( DataOut_Mouse_Regs_A ), 	
	// General
	.GAMMA_B_Dout_o( iBUS_GAMMA_B_A_D ),
	.GAMMA_G_Dout_o( iBUS_GAMMA_G_A_D ),
	.GAMMA_R_Dout_o( iBUS_GAMMA_R_A_D ),
	

	// Text Mode
	.CS_TextMemory_i( CS_TextMemory_A ),
	.CS_ColorMemory_i( CS_ColorMemory_A ),
	.CS_FG_CLUT_i( CS_FG_CLUT_A ),
	.CS_BG_CLUT_i( CS_BG_CLUT_A ),
	.CS_Vicky_Registers_i( CS_VICKY_REG_A ),
	.CS_Mouse_Ptr_A_Graphics_i( CS_Mouse_Ptr_A_Graphics ),
	.CS_Mouse_Ptr_A_Registers_i( CS_Mouse_Ptr_A_Registers ),
	.CS_FONT_i( CS_FONT_A ),	
	// General
	.CS_GAMMA_B_i( CS_GAMMA_B_A ),
	.CS_GAMMA_G_i( CS_GAMMA_G_A ),
	.CS_GAMMA_R_i( CS_GAMMA_R_A ),	
	
// Video DAC Output A
	.VID_A_RSTn_o( VID_A_RSTn_o ),
	.VID_A_CLK_P_o( VID_A_CLK_P_o ),
	.VID_A_DE_o( VID_A_DE_o ),
	.VID_A_HSYNC_o( VID_A_HSYNC_o ),
	.VID_A_VSYNC_o( VID_A_VSYNC_o ),
	.VID_A_PIX_o( VID_A_PIX_o ),
	
	.SOF_Channel_A_o( SOF_Channel_A_o ),
	.VKY_III_Channel_A_IRQ_o( VKY_III_Channel_A_IRQ_o ),
	.VID_A_VideoModeClk_o( VID_A_VideoModeClk )
);



VICKY_III_Channel_B_Top Channel_B_Top(

// Reset
	.Reset_i( Reset_i ),
// Clocks
	.CPU_Clk_i( CPU_Clk_i ),				// CPU Clock - Could be 16/20/25/33/40/66/75
	.Clk14_318Mhz_i( Clk14_318Mhz_i ),
	.Clk25_175Mhz_i( Clk25_175Mhz_B_i ), 	
	.Clk40_000Mhz_i( Clk40_000Mhz_B_i ),
	
	.Clk100M_i( Clk100M_B_i ),
	.Clk200M_i( Clk200M_B_i ),	
	
	.Video_Clk_B_i( LTC6903_B_i ),
// DIP Switch
	.DP_HIRES_i( DP_HIRES_i[1] ),
	.DP_GAMMA_i( DP_GAMMA_i[1] ),
// Buses
	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),
	.iBUS_D8_i( iBUS_D8_i  ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),
	.iBUS_D_Valid_o( iBUS_D_Valid_B ),
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_WE_i( iBUS_WE_i ), 	

// Text Mode
	.iBUS_Text_Memory_D_o( iBUS_Text_Memory_B_D ),
	.iBUS_Color_Memory_D_o( iBUS_Color_Memory_B_D ),
	.iBUS_VICKYIII_Reg_D_o( iBUS_VICKYIII_Reg_B_D ),
// General
	.GAMMA_B_Dout_o( iBUS_GAMMA_B_B_D ),
	.GAMMA_G_Dout_o( iBUS_GAMMA_G_B_D ),
	.GAMMA_R_Dout_o( iBUS_GAMMA_R_B_D ),	
// VGE	
	.DataOut_LUT_o( DataOut_LUT_B ),
	.DataOut_VideoMemory_o( DataOut_VideoMemory_B ),
	.DataOut_Bitmap_Regs_o( DataOut_Bitmap_Regs_B ),
	.DataOut_Tile0_Regs_o( DataOut_Tile0_Regs_B ),
	.DataOut_Tile1_Regs_o( DataOut_Tile1_Regs_B ),
	.DataOut_Collisions_Regs_o( DataOut_Collisions_Regs_B ),
	.DataOut_Sprites_Regs_o( DataOut_Sprites_Regs_B ),
	.DataOut_B_Mouse_Regs_o( DataOut_Mouse_Regs_B ), 
// Text Mode	
	.CS_TextMemory_i( CS_TextMemory_B ), 
	.CS_ColorMemory_i( CS_ColorMemory_B ),  
	.CS_FG_CLUT_i( CS_FG_CLUT_B ),
	.CS_BG_CLUT_i( CS_BG_CLUT_B ),	
	.CS_Vicky_Registers_i( CS_VICKY_REG_B ),
	.CS_Mouse_Ptr_B_Graphics_i( CS_Mouse_Ptr_B_Graphics ),
	.CS_Mouse_Ptr_B_Registers_i( CS_Mouse_Ptr_B_Registers ),	
// General
	.CS_GAMMA_B_i( CS_GAMMA_B_B ),
	.CS_GAMMA_G_i( CS_GAMMA_G_B ),
	.CS_GAMMA_R_i( CS_GAMMA_R_B ),
// VGE
	.CS_Bitmap_Registers_i( CS_Bitmap_Registers_B ),
	.CS_Tile0_Registers_i( CS_Tile0_Registers_B ),
	.CS_Tile1_Registers_i( CS_Tile1_Registers_B ),
	.CS_Collisions_Registers_i( CS_Collisions_Registers_B ),
	.CS_Sprites_Registers_i( CS_Sprites_Registers_B ),	
	.CS_LUT0_i( CS_LUT_B ),
	.CS_VIDEO_RAM_B0_i( CS_VIDEO_RAM_B0 ),
	.CS_VIDEO_RAM_B1_i( CS_VIDEO_RAM_B1 ),	
	.CS_VMEM_2_CPU_i( CS_VMEM_2_CPU_B ), 
	.CS_VDMA_Controller_i( CS_VDMA_Controller_B ),
	.CS_FONT_i( CS_FONT_B ), 
// Video DAC Output A
	.VID_B_RSTn_o( VID_B_RSTn_o ),
	.VID_B_CLK_P_o( VID_B_CLK_P_o ),
	.VID_B_DE_o( VID_B_DE_o ),
	.VID_B_HSYNC_o( VID_B_HSYNC_o ),
	.VID_B_VSYNC_o( VID_B_VSYNC_o ),
	.VID_B_PIX_o( VID_B_PIX_o ),
	
	.SOF_Channel_B_o( SOF_Channel_B_o ),
	.VKY_III_Channel_B_IRQ_o( VKY_III_Channel_B_IRQ_o ),
	.VID_B_VideoModeClk_o( VID_B_VideoModeClk ),
	
// V(DRAM) Interface A
// Video RAM Bank A
	.VRAM_A_DQ_io( VRAM_A_DQ_io ),
	.VRAM_A_BEn_o( VRAM_A_BEn_o ),
	.VRAM_A_Addy_o( VRAM_A_Addy_o ),
	.VRAM_A_OEn_o( VRAM_A_OEn_o ),
	.VRAM_A_WEn_o( VRAM_A_WEn_o ),
// Video RAM Bank B
	.VRAM_B_DQ_io( VRAM_B_DQ_io ),
	.VRAM_B_BEn_o( VRAM_B_BEn_o ),
	.VRAM_B_Addy_o( VRAM_B_Addy_o ),
	.VRAM_B_OEn_o( VRAM_B_OEn_o ),
	.VRAM_B_WEn_o( VRAM_B_WEn_o )
);




endmodule

