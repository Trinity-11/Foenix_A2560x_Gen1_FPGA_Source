// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

module CFP95179K040V25_TOP
(
// {ALTERA_ARGS_BEGIN} DO NOT REMOVE THIS LINE!
inout		wire		[31:0]	CPU_A_io,	// IO
inout		wire		[15:0]	CPU_D_LO_io,	// IO D[15:0]
input		wire		[15:0]	CPU_D_HI_io,	// IO D[31:16]
//CPU Control (MC68040V)
output		wire				CPU_BCLK_o,
input		wire				CPU_BGn_o,
output		wire				CPU_BGACKn_io,
output		wire				CPU_BRn_i,
output		wire				CPU_CDISn_o,
output		wire				CPU_CIOUTn_o,

output		wire				CPU_DLE_o,
//Interrupts
input		wire				CPU_IPENDn_i,
output		wire				CPU_AVECn_o,
output		wire				CPU_IPL0n_o,
output		wire				CPU_IPL1n_o,
output		wire				CPU_IPL2n_o,

output		wire				CPU_LOCKn_i,		// 68K - BERRn
inout		wire				CPU_LOCKEn_i,		// 68K - HALTn
output		wire				CPU_MDISn_o,
input		wire				CPU_MIn_i,
output		wire				CPU_PCLK_o,				// Processor Clock for the 68040V, not used in the MC68SEC000
input		wire				CPU_PST0_i,
input		wire				CPU_PST1_i,
input		wire				CPU_PST2_i,
input		wire				CPU_PST3_i,
inout		wire				CPU_RWn_io,				// IO (MC68040)
inout		wire				CPU_RESET_INn_o,		// THis is the CPU Reset In - Sometimes it can be IO
input		wire				CPU_RESET_OUTn_i,		// This is the MC68040 Reset Out Function Called by the Instruction Reset
input		wire				CPU_SC0_io,				// IO (MC68040)
input		wire				CPU_SC1_io,				// IO (MC68040)
input		wire				CPU_SIZ0_io,			// IO (MC68040)
input		wire				CPU_SIZ1_io,			// IO (MC68040)

input		wire				CPU_TSn_io,				// IO (MC68040)
output		wire				CPU_TAn_io,				// IO (MC68040)
output		wire				CPU_TBIn_o,				//
output		wire				CPU_TEAn_o,
output		wire				CPU_TCIn_o,
input		wire				CPU_TIPn_i,

input		wire				CPU_TLN0_i,
input		wire				CPU_TLN1_i,
input		wire				CPU_TM0_i,
input		wire				CPU_TM1_i,
input		wire				CPU_TM2_i,
input		wire				CPU_TT0_io,				// IO (MC68040)
input		wire				CPU_TT1_io,				// IO (MC68040)
input		wire				CPU_UPA0_i,
input		wire				CPU_UPA1_i,
output		wire				CPU_LFOn_o,
input		wire				CPU_LOC_i,
input		wire				CPU_SCDn_i,
// Local Memory (SRAM/FLASH) Control Signals
output	wire					LOCAL_MEM_FLASH_CS0n_o,
output	wire					LOCAL_MEM_FLASH_CS1n_o,
output	wire					LOCAL_MEM_FLASH_OEn_o,
output	wire					LOCAL_MEM_FLASH_WEn_o,
output	wire					LOCAL_MEM_FLASH_RSTn_o,
output	wire					LOCAL_MEM_FLASH_WPn_o,
output	wire					LOCAL_MEM_SRAM_BE0n_o,
output	wire					LOCAL_MEM_SRAM_BE1n_o,
output	wire					LOCAL_MEM_SRAM_BE2n_o,
output	wire					LOCAL_MEM_SRAM_BE3n_o,
output	wire					LOCAL_MEM_SRAM_CS0n_o,
output	wire					LOCAL_MEM_SRAM_CS1n_o,
output	wire					LOCAL_MEM_SRAM_OEn_o,
output	wire					LOCAL_MEM_SRAM_WEn_o,
// Audio Bus Control Signals
output	wire					ABUS_CTRL_CLK_o,
output	wire					ABUS_CTRL_IN_o,
output	wire					ABUS_CTRL_LATCH_o,
output	wire					ABUS_DATA_CLK_o,
output	wire					ABUS_DATA_IN0_o,
output	wire					ABUS_DATA_IN1_o,
output	wire					ABUS_DATA_LATCH_o,
output	wire					ABUS_SID_CLK_o,
output	wire					ABUS_SID_IN_o,
output	wire					ABUS_SID_LATCH_o,
output	wire					ABUS_RSTn_o,
output	wire					AUD_PDn_o,
output	wire					AUD2_BICK_o,
output	wire					AUD2_LRCK_o,
output	wire					AUD2_MCLK_o,
output	wire					AUD2_SDTI_o,
output	wire					AUD3_BICK_o,
output	wire					AUD3_LRCK_o,
output	wire					AUD3_MCLK_o,
output	wire					AUD3_SDTI_o,
output	wire					AMP_MUTE_o,
output	wire					AMP_SDBY_o,
output	wire					BTX_BUZZER_o,
output	wire					CHIPTUNE_RSTn_o,
output	wire					DCSG_CLK_o,
input	wire					DCSG_RDY_i,
// CODEC
input	wire					CODEC_ADC_BCLK_i,
input	wire					CODEC_ADC_DAT_i,
input	wire					CODEC_ADC_LRCK_i,
input	wire					CODEC_ADC_MCLK_o,
output	wire					CODEC_DAC_BCLK_o,
output	wire					CODEC_DAC_DAT_o,
output	wire					CODEC_DAC_LRCK_o,
output	wire					CODEC_DAC_MCLK_o,
output	wire					CODEC_DI_o,
output	wire					CODEC_CE_o,
output	wire					CODEC_CL_o,
// Splash Screen Flash
output	wire					CONFIG_CSn_o,
input	wire					CONFIG_MISO_i,
output	wire					CONFIG_MOSI_o,
output	wire					CONFIG_SCLK_o,
// Misc System Control
output	wire					BLU_POWER_LED_o,		// On/Off (board LED)
output	wire					RGB_POWER_LED_o,		// RGB - Some serializing will be needed to get the RGB we want
output	wire					SDCARD_LED_o,			// On/Off (board LED)
input	wire					MACHINE_ID0_i,
input	wire					MACHINE_ID1_i,		
inout	wire					GLOBAL_RESETn_io,	

// Oscillator Input
input	wire					OSC_CLK_14_318Mhz_i,
input	wire					OSC_CLK_33_333Mhz_i,
input	wire					OSC_CLK_22_579Mhz_i,
input	wire					OSC_CLK_24_576Mhz_i,
//input		wire					OSC_CLK_25_175Mhz_i,
input	wire					OSC_CLK_40_000Mhz_i,
//input		wire					OSC_CLK_65_000Mhz_i,
//input		wire					Video_Clk_A_i,
//input		wire					Video_Clk_B_i,
output	wire					VClock_LTC6903_A_CSn_o,
output	wire					VClock_LTC6903_B_CSn_o,
output	wire					VClock_LTC6903_SCLK_o,
output	wire					VClock_LTC6903_DIN_o,		//MoSi
input	wire					LTC6903_A_i,
input	wire					LTC6903_B_i,
// Debug Interface
input	wire					DBG_RX_i,
output	wire					DBG_TX_o,
// SDCard Controller
input	wire					F_SD_CD_i,
output	wire					F_SD_CLK_o,			// CLK
output	wire					F_SD_CMD_o,			// MOSI
input	wire					F_SD_DAT0_io,		// MISO
input	wire					F_SD_DAT1_io,		// IO
input	wire					F_SD_DAT2_io,		// IO
output	wire					F_SD_DAT3_io,		// IO (CS)
input	wire					F_SD_WP_i,
// IO Bus
output	wire		[7:0]		IO_A_io,
inout	wire		[15:0]		IO_D_io,
output	wire					IO_RDn_o,
output	wire					IO_WRn_o,
output	wire					DIP_CSn_o,
//Eth
output	wire					ETH_CSn_o,
output	wire					ETH_FIFO_SEL_o,
output	wire					ETH_RSTn_o,
// IDE
output	wire					IDE_CS0n_o,
output	wire					IDE_CS1n_o,
output	wire					IDE_DATA_DIR_o,
output	wire					IDE_DATA_OEn_o,
input	wire					IDE_IORDY_i,
output	wire					IDE_RESETn_o,
// Interrupt
input	wire					IDE_INTRQ_i,
input	wire					ETH_IRQn_i,
// Joystick
inout	wire					JOY0_BTN0_io,		// IO
inout	wire					JOY0_BTN1_io,		// IO
inout	wire					JOY0_BTN2_io,		// IO
input	wire					JOY0_DWN_io,		// IO
input	wire					JOY0_LFT_io,		// IO
input	wire					JOY0_RGHT_io,		// IO
input	wire					JOY0_UP_io,			// IO
output	wire					JOYSTICK0_RLY_o,
inout	wire					JOY1_BTN0_io,		// IO
inout	wire					JOY1_BTN1_io,		// IO
inout	wire					JOY1_BTN2_io,		// IO
input	wire					JOY1_DWN_io,		// IO
input	wire					JOY1_LFT_io,		// IO
input	wire					JOY1_RGHT_io,		// IO
input	wire					JOY1_UP_io,			// IO
output	wire					JOYSTICK1_RLY_o,
//LPC Interface
output	wire					LPC_CLK_32Khz_o,
inout	wire					LPC_IRQn_io,		// BiDir
input	wire					LPC_LDRQn_i,
inout	wire		[3:0]		LPC_LAD_io,			// BiDir
output	wire					LPC_LFRAMEn_o,
output	wire					LPC_RSTn_o,
// Keyboard (The FPGA is the Slave)
input	wire					KBD_CSn_i,
input	wire					KBD_CLK_i,
output	wire					KBD_INTn_o,
output	wire					KBD_MISO_o,
input	wire					KBD_MOSI_i,
output	wire					MTX_CLK_o,
output	wire					MTX_LATCH_o,
output	wire					MTX_SERIAL_IN_o,
output	wire					STS_CLK_o,
output	wire					STS_LATCH_o,
output	wire					STS_SERIAL_IN_o,

output	wire					OPL3_CLK_o,
output	wire					OPM_CLK_o,
output	wire					OPN2_CLK_o,
output	wire					SID_CLK_o,
input	wire					OPL3_INTn_i,
input	wire					OPM_INTn_i,
input	wire					OPN2_INTn_i,

// RTC
output	wire		[3:0]		RTC_A_o,
inout	wire		[7:0]		RTC_D_io,
output	wire					RTC_OEn_o,
output	wire					RTC_CSn_o,
input	wire					RTC_INTn_i,
output	wire					RTC_RWn_o,

// System RAM
inout	wire		[31:0]		SYSRAM_DQ_io,
output	wire		[3:0]		SYSRAM_DQM_o,
output	wire		[12:0]		SYSRAM_A_o,
output	wire					SYSRAM_BA0_o,
output	wire					SYSRAM_BA1_o,
output	wire					SYSRAM_CASn_o,
output	wire					SYSRAM_RASn_o,
output	wire					SYSRAM_WEn_o,
output	wire					SYSRAM_CS0n_o,
output	wire					SYSRAM_CKE_o,
output	wire					SYSRAM_CLK_o,
// Video
inout	wire					VID_SPC_io,		// IO
inout	wire					VID_SPD_io,		// IO
// Video DAC Output A
output	wire					VID_A_CLK_P_o,
output	wire					VID_A_DE_o,
input	wire					VID_A_HP_INT1n_i,
output	wire					VID_A_HSYNC_o,
output	wire					VID_A_RSTn_o,
output	wire					VID_A_VSYNC_o,
output	wire		[11:0]	VID_A_PIX_o,
// Video DAC Output B
output	wire					VID_B_CLK_P_o,
output	wire					VID_B_DE_o,
input	wire					VID_B_HP_INT1n_i,
output	wire					VID_B_HSYNC_o,
output	wire					VID_B_RSTn_o,
output	wire					VID_B_VSYNC_o,
output	wire		[11:0]	VID_B_PIX_o,
// Video RAM Bank A
inout	wire		[31:0]	VRAM_A_DQ_io,
output	wire		[3:0]		VRAM_A_DQM_o,
output	wire		[10:0]	VRAM_A_Addy_o,
output	wire		[1:0]		VRAM_A_BA_o,
output	wire					VRAM_A_RASn_o,
output	wire					VRAM_A_CASn_o,
output	wire					VRAM_A_WEn_o,
output	wire					VRAM_A_CSn_o,
output	wire					VRAM_A_CKE_o,
output	wire					VRAM_A_CLK_o,
// Video RAM Bank B
inout	wire		[31:0]	VRAM_B_DQ_io,
output	wire		[3:0]		VRAM_B_DQM_o,	
output	wire		[10:0]	VRAM_B_Addy_o,
output	wire		[1:0]		VRAM_B_BA_o,
output	wire					VRAM_B_RASn_o,
output	wire					VRAM_B_CASn_o,
output	wire					VRAM_B_WEn_o,
output	wire					VRAM_B_CSn_o,
output	wire					VRAM_B_CKE_o,
output	wire					VRAM_B_CLK_o
// {ALTERA_ARGS_END} DO NOT REMOVE THIS LINE!

);
// Temporary Assignment
wire 				GLOBAL_RESET_i;
wire				CPU_Clk;
wire 	[15:0]		iBUS_D_GABE;
wire 	[15:0] 		iBUS_D_BEATRIX;
wire	[15:0]		iBUS_D_VICKY;
wire	[15:0]		iBUS_D_MERA;
wire	[31:0]		iBUS_A;
wire	[15:0]		iBUS_D_Write;
wire	[1:0]		iBUS_BE;
wire				iBUS_RWn;

wire				iBUS_A_Valid;
wire				iBUS_D_Valid;

wire 				iBUS_CS_GABE;
wire 				iBUS_CS_BEATRIX;
wire 				iBUS_CS_MERA;
wire 				iBUS_CS_VICKY_A;
wire 				iBUS_CS_VICKY_MEM_A;
wire 				iBUS_CS_VICKY_B;
wire 				iBUS_CS_VICKY_MEM_B;
wire 				iBUS_CS_VRAM_A;
wire 				iBUS_CS_VRAM_B;
// Debug Interface 
wire 				Dbg_Mode_On;
wire 	[23:0] 		Dbg_Address_Out;
wire	[15:0]		Dbg_Data_Out;
wire	[15:0]		Dbg_Data_In;
wire				Dbg_RWn_Out;
wire 				Dbg_RAM_CS0;
wire				Dbg_RAM_CS1;
wire				Dbg_FLASH_CS0;
wire				Dbg_FLASH_CS1;
wire				Dbg_FLASH_WR;
wire				Dbg_FLASH_OE;
wire				Dbg_OE;
wire				Dbg_Reset;
wire				Dbg_Halt;

wire				Clk24Mhz;	// Serial Port (USB Debug Port)
wire				Clk48Mhz;	// SDCard
wire				Clk100Mhz;
wire				Clk200Mhz;
wire				PLL_SDcard_Locked;

wire				iBUS_D_Valid_BEATRIX;
wire				iBUS_D_Valid_GABE;
wire				iBUS_D_Valid_VICKY;
wire				iBUS_D_Valid_MERA;

wire				GLOBAL_RESETn_i;

wire 				SOF_Channel_A;
wire 				SOF_Channel_B;

wire 	[1:0] 	DP_HIRES;
wire 	[1:0] 	DP_GAMMA;

wire 	[6:0]		iIRQ_Interrupt;
wire 	[7:0]		iIRQ_Vector;
wire				iIRQ_AutoVector;
wire 				iIRQ_GetVector;

wire 	[5:0] 	VKY_III_Channel_A_IRQ;
wire 	[5:0] 	VKY_III_Channel_B_IRQ;

wire 				DAC_Playback_Done48_Int;
wire 				DAC_Playback_Done44_Int;
/*
wire [31:0] Cold_Reset_Counter;	// This is 1 Shot Reset; 0.5s
wire Cold_Reset;					   // Will Stay @ 1 till it reaches 0.5sec
RST_COUNTER	RST_COUNTER_inst (
	.clock ( OSC_CLK_40_000Mhz_i ),
	.cnt_en ( Cold_Reset ),
	.q ( Cold_Reset_Counter )
	);
	
RST_COMPARE	RST_COMPARE_inst (
	.dataa ( Cold_Reset_Counter ),
	.alb ( Cold_Reset )
	);	
*/


BIDIR_SIGNAL	HALT_BUFFER (
	.datain ( 1'b0  ),
	.oe ( External_Reset ),
	.dataio ( GLOBAL_RESETn_io ),
	.dataout ( GLOBAL_RESETn_i )
	);

wire Manual_RESET;
wire Flash_Transfered;
wire PLL_Locked_A;
wire PLL_Locked_B;
wire Reset_14Mhz;
wire Reset_22Mhz;
wire Reset_24Mhz;
wire Reset_33Mhz;
wire Reset_40Mhz;
wire Reset_48Mhz;
wire Reset_ClkVideoA;
wire Reset_ClkVideoB;
wire External_Reset;
wire System_Reset;
wire Init_SDRAM;
wire Init_LPC_Reset;
wire Init_F2R_TSF;
wire TSF_FLASH2RAM;
	
CFP95179K_Reset_Block SystemResetBlock(
	.PLL_SDcard_Locked_i( PLL_SDcard_Locked ),
	.PLL_Locked_A_i( PLL_Locked_A ),
	.PLL_Locked_B_i( PLL_Locked_B ),
	.Clk14Mhz_i( OSC_CLK_14_318Mhz_i ),
	.Clk22Mhz_i( OSC_CLK_22_579Mhz_i ),
	.Clk24Mhz_i( OSC_CLK_24_576Mhz_i ),
	.Clk33Mhz_i( OSC_CLK_33_333Mhz_i ),
	.Clk40Mhz_i( Clk40_Div_A ),
	.Clk48Mhz_i( Clk48 ),
	.Clk80Mhz_i( Clk80 ), 
	.ClkVideoA_i( LTC6903_A_i ),
	.ClkVideoB_i( LTC6903_B_i ),
	.CPU_Clock_i( CPU_Clk ),
	
	.Hard_Reset_i( !GLOBAL_RESETn_i ),		// External Reset Button
	.Soft_Reset_i( Manual_RESET ),		// Internal Reset Created by Programming GABE Register
	.CPU_Reset_i( 1'b0 ),		// External Reset Triggered by CPU
	
	.Flash_Transfered_i( TSF_FLASH2RAM ),
	.LPC_Init_Completed_i( LPC_Init_Done ),
	
	.Reset_14Mhz_o( Reset_14Mhz ),
	.Reset_22Mhz_o( Reset_22Mhz ),
	.Reset_24Mhz_o( Reset_24Mhz ),
	.Reset_33Mhz_o( Reset_33Mhz ),
	.Reset_40Mhz_o( Reset_40Mhz ),
	.Reset_48Mhz_o( Reset_48Mhz ),
	.Reset_ClkVideoA_o( Reset_ClkVideoA ),
	.Reset_ClkVideoB_o( Reset_ClkVideoB ),
	.External_Reset_o( External_Reset ),
	
	.Init_SDRAM_o( Init_SDRAM ),
	.Init_LPC_o( Init_LPC_Reset ),
	.Init_F2R_TSF_o( Init_F2R_TSF )
);	
	
	

assign System_Reset = External_Reset;		// CPU Reset


wire LPC_Init_Done;


wire Clk80;
wire Clk240_A;
wire Clk240_B;
wire Clk48;

//wire	VideoClk40Mhz;

//assign VideoClk40Mhz = CPU_PCLK_o;

PLL_SDCard_Debug	PLL_SDCard_Debug_inst (
	.inclk0 ( OSC_CLK_40_000Mhz_i ),
	.c0 ( CPU_PCLK_o ),		// Output on the Processor Clock
	.c1 ( Clk80 ),				// This is to feed the SDRAM MERA and be in Sync with CPU
	.c2 ( Clk240_A ), 		// This is for Channel A 
	.c3 ( Clk240_B ), 		// This is for Channel B
	.c4 ( Clk48 ),				// This is for SDCard and Serial Interface
	.locked ( PLL_SDcard_Locked )
	);

// VGE Engine Clock Channel A
reg Clk40_Div_A;
always @ (posedge Clk80) begin
	Clk40_Div_A <= Clk40_Div_A ^ 1'b1;
end
	
// VGE Engine Clock Channel A
reg Clk120_Div_A;
always @ (posedge Clk240_A) begin
	Clk120_Div_A <= Clk120_Div_A ^ 1'b1;
end

// VGE Engine Clock Channel B
reg Clk120_Div_B;
always @ (posedge Clk240_B) begin
	Clk120_Div_B <= Clk120_Div_B ^ 1'b1;
end

// Division of 48Mhz to get us the Clock for USB Serial Port
reg Clk24_Div_A;
always @ (posedge Clk48) begin
	Clk24_Div_A <= Clk24_Div_A ^ 1'b1;
end

//assign GLOBAL_RESET_i = ~GLOBAL_RESETn_io;

MC68040V_Interface M68000_2_M68040(

	.Global_Reset_i( System_Reset ),
	.Init_F2R_TSF_i( Init_F2R_TSF ), 
	.Clk_40Mhz_i( Clk40_Div_A ),

	.CPU_Clk_o( CPU_Clk ),	// 20Mhz Clock
// MC68040 General A2560K Interface
	.CPU_A_io( CPU_A_io ),	// IO
	.CPU_D_LO_io( CPU_D_LO_io ),	// IO
	.CPU_D_HI_io( CPU_D_HI_io ),	// IO	
//CPU Control (MC68040V)
	.CPU_BCLK_o( CPU_BCLK_o ),
	.CPU_AVECn_o( CPU_AVECn_o ),
	.CPU_BGn_o( CPU_BGn_o ),
	.CPU_BGACKn_io( CPU_BGACKn_io ),
	.CPU_BRn_i(CPU_BRn_i  ),
	.CPU_CDISn_o( CPU_CDISn_o ),
	.CPU_CIOUTn_o( CPU_CIOUTn_o ),
	.CPU_DLE_o( CPU_DLE_o ),
	.CPU_IPENDn_i( CPU_IPENDn_i ),
	.CPU_IPL0n_o(CPU_IPL0n_o  ),
	.CPU_IPL1n_o( CPU_IPL1n_o ),
	.CPU_IPL2n_o( CPU_IPL2n_o ),
	.CPU_LOCKn_i( CPU_LOCKn_i ),
	.CPU_LOCKEn_i( CPU_LOCKEn_i ),
	.CPU_MDISn_o( CPU_MDISn_o ),
	.CPU_MIn_i( CPU_MIn_i ),
	.CPU_PCLK_o( 1'b0 ),
	.CPU_PST0_i( CPU_PST0_i ),
	.CPU_PST1_i( CPU_PST1_i ),
	.CPU_PST2_i( CPU_PST2_i ),
	.CPU_PST3_i( CPU_PST3_i ),
	.CPU_RWn_io( CPU_RWn_io ),				// IO (MC68040)
	.CPU_RESET_INn_o( CPU_RESET_INn_o ),		// THis is the CPU Reset In - Sometimes it can be IO
	.CPU_RESET_OUTn_i( CPU_RESET_OUTn_i ),		// This is the MC68040 Reset Out Function Called by the Instruction Reset
	.CPU_SC0_io( CPU_SC0_io ),				// IO (MC68040)
	.CPU_SC1_io( CPU_SC1_io ),				// IO (MC68040)
	.CPU_SIZ0_io( CPU_SIZ0_io ),			// IO (MC68040)
	.CPU_SIZ1_io( CPU_SIZ1_io ),			// IO (MC68040)
	.CPU_TAn_io( CPU_TAn_io ),				// IO (MC68040)
	.CPU_TBIn_o( CPU_TBIn_o ),				//
	.CPU_TCIn_o( CPU_TCIn_o ),
	.CPU_TEAn_o( CPU_TEAn_o ),
	.CPU_TIPn_i( CPU_TIPn_i ),
	.CPU_TSn_io( CPU_TSn_io ),				// IO (MC68040)
	.CPU_TLN0_i( CPU_TLN0_i ),
	.CPU_TLN1_i( CPU_TLN1_i ),
	.CPU_TM0_i( CPU_TM0_i ),
	.CPU_TM1_i( CPU_TM1_i ),
	.CPU_TM2_i( CPU_TM2_i ),
	.CPU_TT0_io( CPU_TT0_io ),				// IO (MC68040)
	.CPU_TT1_io( CPU_TT1_io ),				// IO (MC68040)
	.CPU_UPA0_i( CPU_UPA0_i ),
	.CPU_UPA1_i( CPU_UPA1_i ),
	.CPU_LFOn_o( CPU_LFOn_o ),
	.CPU_LOC_i( CPU_LOC_i ),
	.CPU_SCDn_i( CPU_SCDn_i ),
// External Memory Interface
	.LOCAL_MEM_FLASH_CS0n_o( LOCAL_MEM_FLASH_CS0n_o ),
	.LOCAL_MEM_FLASH_CS1n_o( LOCAL_MEM_FLASH_CS1n_o ),
	.LOCAL_MEM_FLASH_OEn_o( LOCAL_MEM_FLASH_OEn_o ),
	.LOCAL_MEM_FLASH_WEn_o( LOCAL_MEM_FLASH_WEn_o ),
	.LOCAL_MEM_FLASH_RSTn_o( LOCAL_MEM_FLASH_RSTn_o ),
	.LOCAL_MEM_FLASH_WPn_o( LOCAL_MEM_FLASH_WPn_o ),
	.LOCAL_MEM_SRAM_BE0n_o( LOCAL_MEM_SRAM_BE0n_o ),
	.LOCAL_MEM_SRAM_BE1n_o( LOCAL_MEM_SRAM_BE1n_o ),
	.LOCAL_MEM_SRAM_BE2n_o( LOCAL_MEM_SRAM_BE2n_o ),
	.LOCAL_MEM_SRAM_BE3n_o( LOCAL_MEM_SRAM_BE3n_o ),
	.LOCAL_MEM_SRAM_CS0n_o( LOCAL_MEM_SRAM_CS0n_o ),
	.LOCAL_MEM_SRAM_CS1n_o( LOCAL_MEM_SRAM_CS1n_o ),
	.LOCAL_MEM_SRAM_OEn_o( LOCAL_MEM_SRAM_OEn_o ),
	.LOCAL_MEM_SRAM_WEn_o( LOCAL_MEM_SRAM_WEn_o ),
// Slave Interface
	.iBUS_A_o( iBUS_A ),
	.iBUS_D_Write_o( iBUS_D_Write ),
	.iBUS_RWn_o( iBUS_RWn ),
	.iBUS_BE_o( iBUS_BE ),
	.iBUS_A_Valid_o( iBUS_A_Valid ) ,
	.iBUS_D_Valid_i( iBUS_D_Valid_BEATRIX | iBUS_D_Valid_GABE | iBUS_D_Valid_VICKY | iBUS_D_Valid_MERA),			// this is to extend the DTACK Cycle

	// Interrupt 
	.iIRQ_Interrupt_i( iIRQ_Interrupt ),
	.iIRQ_Vector_i( iIRQ_Vector ),
	.iIRQ_AutoVector_i( iIRQ_AutoVector ),
	.iIRQ_GetVector_o( iIRQ_GetVector ), 

	.iBUS_D_GABE_i( iBUS_D_GABE ),
	.iBUS_D_BEATRIX_i( iBUS_D_BEATRIX ),
	.iBUS_D_VICKY_i( iBUS_D_VICKY ),
	.iBUS_D_MERA_i( iBUS_D_MERA ),
	
	.iBUS_CS_GABE_o( iBUS_CS_GABE ),
	.iBUS_CS_BEATRIX_o( iBUS_CS_BEATRIX ),
	.iBUS_CS_VICKY_A_o( iBUS_CS_VICKY_A ),
	.iBUS_CS_VICKY_MEM_A_o( iBUS_CS_VICKY_MEM_A ),
	.iBUS_CS_VICKY_B_o( iBUS_CS_VICKY_B ),
	.iBUS_CS_VICKY_MEM_B_o( iBUS_CS_VICKY_MEM_B ),
	.iBUS_CS_VRAM_A_o( iBUS_CS_VRAM_A ),
	.iBUS_CS_VRAM_B_o( iBUS_CS_VRAM_B ),
	.iBUS_CS_MERA_o( iBUS_CS_MERA ), 
// Debug Interface
	.Dbg_Mode_On_i( Dbg_Mode_On ),
	.Dbg_Address_Out_i( Dbg_Address_Out ),
	.Dbg_Data_Out_i( Dbg_Data_Out ),
	.Dbg_Data_In_o( Dbg_Data_In ),
	.Dbg_RWn_Out_i( Dbg_RWn_Out ),
	.Dbg_RAM_CS0_i( Dbg_RAM_CS0 ),
	.Dbg_RAM_CS1_i( Dbg_RAM_CS1 ),
	.Dbg_FLASH_CS0_i( Dbg_FLASH_CS0 ),
	.Dbg_FLASH_CS1_i( Dbg_FLASH_CS1 ),
	.Dbg_FLASH_WR_i( Dbg_FLASH_WR ),
	.Dbg_FLASH_OE_i( Dbg_FLASH_OE ), 
	.Dbg_OE_i( Dbg_OE ),
	.Dbg_Reset_i( Dbg_Reset ),
	.Dbg_Halt_i( Dbg_Halt ),
	
	.TSF_FLASH2RAM_o( TSF_FLASH2RAM ),
	.DebugDebug_i( DebugDebugTrig )	
);

wire DebugDebugTrig;
// System RAM
//assign SYSRAM_BA0_o 		= 1'b0;
//assign SYSRAM_BA1_o 		= 1'b0;
//assign SYSRAM_CASn_o 	= 1'b1;
//assign SYSRAM_RASn_o 	= 1'b1;
//assign SYSRAM_WEn_o 		= 1'b1;
//assign SYSRAM_CS0n_o 	= 1'b1;
//assign SYSRAM_CKE_o 		= 1'b0;
//assign SYSRAM_CLK_o 		= 1'b0;

Mera_Top		MERA_TOP_SDRAM(
// Reset
	.SDRAM_Init_i( Init_SDRAM ),
	.Reset_i( System_Reset ),
	.CPU_Clk_i( CPU_Clk ),						// CPU Clock - Could be 16/20/25/33/40/66/75
	.SDRAM_Clk_i( Clk80 ), 	// CPU Clock is right now 40/2, so they are in Sync, no FIFO needed.
// Buses
	.iBUS_A_i( iBUS_A ),
	.iBUS_A_Valid_i( iBUS_A_Valid ),
	.iBUS_D_i( iBUS_D_Write ), 
	.iBUS_D_Valid_o( iBUS_D_Valid_MERA ), 
	.iBUS_RWn_i( iBUS_RWn ),
	.iBUS_BE_i( iBUS_BE ),
	.iBUS_D_MERA_o( iBUS_D_MERA ),
	.iBUS_CS_MERA_i( iBUS_CS_MERA ),

// System RAM
	.SYSRAM_DQ_io( SYSRAM_DQ_io ),
	.SYSRAM_DQM_o( SYSRAM_DQM_o ),
	.SYSRAM_A_o( SYSRAM_A_o ),
	.SYSRAM_BA0_o( SYSRAM_BA0_o ),
	.SYSRAM_BA1_o( SYSRAM_BA1_o ),
	.SYSRAM_CASn_o( SYSRAM_CASn_o ),
	.SYSRAM_RASn_o( SYSRAM_RASn_o ),
	.SYSRAM_WEn_o( SYSRAM_WEn_o ),
	.SYSRAM_CS0n_o( SYSRAM_CS0n_o ),
	.SYSRAM_CKE_o( SYSRAM_CKE_o ),
	.SYSRAM_CLK_o( SYSRAM_CLK_o )
);

GABE_Top GABE_TOP_LEVEL(
// Reset
	.LPC_Reset_i( Init_LPC_Reset ),
	.IDE_Reset_i( Init_SDRAM ),
	.Reset_i( System_Reset ),
	.Reset_14Mhz_i( Reset_14Mhz ),
	.Reset_33Mhz_i( Reset_33Mhz ),
	.Reset_40Mhz_i( Reset_40Mhz ),
	.Reset_48Mhz_i( Reset_48Mhz ),
// Output Reset From Programming Gabe Reg
	.Manual_RESET_o( Manual_RESET ),	
// Clocks	
	.CPU_Clk_i( CPU_Clk ),

	.Clk14_318Mhz_i( OSC_CLK_14_318Mhz_i ),
	.Clk33_333Mhz_i( OSC_CLK_33_333Mhz_i ),
	.Clk40_000Mhz_i( Clk40_Div_A         ), 
	.Clk48Mhz_i( Clk48 ),
// Buses
// CPU Block Buses
	.iBUS_A_i( iBUS_A ),
	.iBUS_A_Valid_i( iBUS_A_Valid ),
	.iBUS_D_i( iBUS_D_Write ),
	.iBUS_D_Valid_o( iBUS_D_Valid_GABE ), 	// This is to extend DTACK
	.iBUS_RWn_i( iBUS_RWn ),
	.iBUS_BE_i( iBUS_BE ),	
	.iBUS_D_GABE_o( iBUS_D_GABE ),
	.iBUS_CS_GABE_i( iBUS_CS_GABE ),		
	
// Interrupts Input 
	.OPL3_INTn_i( OPL3_INTn_i ),
	.OPN2_INTn_i( OPN2_INTn_i ),
	.OPM_INTn_i( OPM_INTn_i ),
	.VID_A_HP_INT1n_i( VID_A_HP_INT1n_i ),
	.VID_B_HP_INT1n_i( VID_B_HP_INT1n_i ),	
	.VKY_III_Channel_A_IRQ_i( VKY_III_Channel_A_IRQ ),
	.VKY_III_Channel_B_IRQ_i( VKY_III_Channel_B_IRQ ),	
	.DAC_Playback_Done48_Int_i( DAC_Playback_Done48_Int ),
	.DAC_Playback_Done44_Int_i( DAC_Playback_Done44_Int ),
//LPC Interface
	.LPC_CLK_32Khz_o( LPC_CLK_32Khz_o ),
	.LPC_IRQn_io( LPC_IRQn_io ),
	.LPC_LDRQn_i( LPC_LDRQn_i ),
	.LPC_LAD_io( LPC_LAD_io ),
	.LPC_LFRAMEn_o( LPC_LFRAMEn_o ),
	.LPC_RSTn_o( LPC_RSTn_o ),
	
	.LPC_Init_Done_o( LPC_Init_Done ), //0 = LPC Init, 1 = Done INIT - it is sync with CPU_Clk

// SD Card Interface
	.F_SD_CD_i( F_SD_CD_i ),
	.F_SD_CLK_o( F_SD_CLK_o ),
	.F_SD_CMD_o( F_SD_CMD_o ),
	.F_SD_DAT0_io( F_SD_DAT0_io ),		// IO
	.F_SD_DAT1_io( F_SD_DAT1_io ),		// IO
	.F_SD_DAT2_io( F_SD_DAT2_io ),		// IO
	.F_SD_DAT3_io( F_SD_DAT3_io ),		// IO
	.F_SD_WP_i( F_SD_WP_i ),

// Buzzer
	.BTX_BUZZER_o( BTX_BUZZER_o ),
	
// IDE / ETH / DP
	.IO_A_io( IO_A_io ),
	.IO_D_io( IO_D_io ),
	.IO_RDn_o( IO_RDn_o ),
	.IO_WRn_o( IO_WRn_o ),
	.DIP_CSn_o( DIP_CSn_o ),
	.ETH_CSn_o( ETH_CSn_o ),
	.ETH_FIFO_SEL_o( ETH_FIFO_SEL_o ),
	.ETH_IRQn_i( ETH_IRQn_i ),
	.ETH_RSTn_o( ETH_RSTn_o ),
	.IDE_CS0n_o( IDE_CS0n_o ),
	.IDE_CS1n_o( IDE_CS1n_o ),
	.IDE_DATA_DIR_o( IDE_DATA_DIR_o ),
	.IDE_DATA_OEn_o( IDE_DATA_OEn_o ),
	.IDE_INTRQ_i( IDE_INTRQ_i ),
	.IDE_IORDY_i( IDE_IORDY_i ),
	.IDE_RESETn_o( IDE_RESETn_o ),

// Joystick
	.JOY0_BTN0_io( JOY0_BTN0_io ),		// IO
	.JOY0_BTN1_io( JOY0_BTN1_io ),		// IO
	.JOY0_BTN2_io( JOY0_BTN2_io ),		// IO
	.JOY0_DWN_io( JOY0_DWN_io ),		// IO
	.JOY0_LFT_io( JOY0_LFT_io ),		// IO
	.JOY0_RGHT_io( JOY0_RGHT_io ),		// IO
	.JOY0_UP_io( JOY0_UP_io ),			// IO
	.JOYSTICK0_RLY_o( JOYSTICK0_RLY_o ),
	.JOY1_BTN0_io( JOY1_BTN0_io ),		// IO
	.JOY1_BTN1_io( JOY1_BTN1_io ),		// IO
	.JOY1_BTN2_io( JOY1_BTN2_io ),		// IO
	.JOY1_DWN_io( JOY1_DWN_io ),		// IO
	.JOY1_LFT_io( JOY1_LFT_io ),		// IO
	.JOY1_RGHT_io( JOY1_RGHT_io ),		// IO
	.JOY1_UP_io( JOY1_UP_io ),			// IO
	.JOYSTICK1_RLY_o( JOYSTICK1_RLY_o ),
	
// Keyboard
	.KBD_CSn_i( KBD_CSn_i ),
	.KBD_CLK_i( KBD_CLK_i ),
	.KBD_INTn_o( KBD_INTn_o ),
	.KBD_MISO_o( KBD_MISO_o ),
	.KBD_MOSI_i( KBD_MOSI_i ),
	
	.MTX_CLK_o( MTX_CLK_o ),
	.MTX_LATCH_o( MTX_LATCH_o ),
	.MTX_SERIAL_IN_o( MTX_SERIAL_IN_o ),
	.STS_CLK_o( STS_CLK_o ),
	.STS_LATCH_o( STS_LATCH_o ),
	.STS_SERIAL_IN_o( STS_SERIAL_IN_o ),
	
// RTC
	.RTC_A_o( RTC_A_o ),
	.RTC_D_io( RTC_D_io ),
	.RTC_OEn_o( RTC_OEn_o ),
	.RTC_CSn_o( RTC_CSn_o ),
	.RTC_INTn_i( RTC_INTn_i ),
	.RTC_RWn_o( RTC_RWn_o),
	
// Misc System Control
	.BLU_POWER_LED_o( BLU_POWER_LED_o ),		// On/Off (board LED)
	.RGB_POWER_LED_o( RGB_POWER_LED_o ),		// RGB - Some serializing will be needed to get the RGB we want
	.SDCARD_LED_o( SDCARD_LED_o ),			// On/Off (board LED)
	.MACHINE_ID0_i( MACHINE_ID0_i ),
	.MACHINE_ID1_i( MACHINE_ID1_i ),

	.SOF_Channel_A_i( SOF_Channel_A ),
	.SOF_Channel_B_i( SOF_Channel_B ),
	
	.DP_HIRES_o( DP_HIRES ),
	.DP_GAMMA_o( DP_GAMMA ),
	// Interrupt 
	.iIRQ_Interrupt_o( iIRQ_Interrupt ),
	.iIRQ_Vector_o( iIRQ_Vector ),
	.iIRQ_AutoVector_o( iIRQ_AutoVector ),
	.iIRQ_GetVector_i( iIRQ_GetVector )
);

BEATRIX_TOP BEATRIX_TOP_LEVEL(
// Reset
	.Reset_i( System_Reset ),
	.Reset_14Mhz_i( Reset_14Mhz ),
	.Reset_22Mhz_i( Reset_22Mhz ),
	.Reset_24Mhz_i( Reset_24Mhz ),
// Clocks Input
	.CPU_Clk_i( CPU_Clk ),
	.Clk14_318Mhz_i( OSC_CLK_14_318Mhz_i ),
	.Clk22_579Mhz_i( OSC_CLK_22_579Mhz_i ),
	.Clk24_576Mhz_i( OSC_CLK_24_576Mhz_i ),
// Clocks Output
	.OPL3_CLK_o( OPL3_CLK_o ),
	.OPM_CLK_o( OPM_CLK_o ),
	.OPN2_CLK_o( OPN2_CLK_o ),
	.DCSG_CLK_o( DCSG_CLK_o ),
	.SID_CLK_o( SID_CLK_o ),
// CPU Block Buses
	.iBUS_A_i( iBUS_A ),
	.iBUS_A_Valid_i( iBUS_A_Valid ),
	.iBUS_D_i( iBUS_D_Write ),
	.iBUS_D_Valid_o( iBUS_D_Valid_BEATRIX ), 
	.iBUS_RWn_i( iBUS_RWn ),
	.iBUS_BE_i( iBUS_BE ),	
	.iBUS_D_BEATRIX_o( iBUS_D_BEATRIX ),
	.iBUS_CS_BEATRIX_i( iBUS_CS_BEATRIX ),		

// CODEC
	.CODEC_ADC_BCLK_i( CODEC_ADC_BCLK_i ),
	.CODEC_ADC_DAT_i( CODEC_ADC_DAT_i ),
	.CODEC_ADC_LRCK_i( CODEC_ADC_LRCK_i ),
	.CODEC_ADC_MCLK_o( CODEC_ADC_MCLK_o ),
	.CODEC_DAC_BCLK_o( CODEC_DAC_BCLK_o ),
	.CODEC_DAC_DAT_o( CODEC_DAC_DAT_o ),
	.CODEC_DAC_LRCK_o( CODEC_DAC_LRCK_o ),
	.CODEC_DAC_MCLK_o( CODEC_DAC_MCLK_o ),
// CODEC Control
	.CODEC_DI_o( CODEC_DI_o ),
	.CODEC_CE_o( CODEC_CE_o ),
	.CODEC_CL_o( CODEC_CL_o ),

// ChipTune Bus
	// Control Section
	.ABUS_CTRL_CLK_o( ABUS_CTRL_CLK_o ),
	.ABUS_CTRL_IN_o( ABUS_CTRL_IN_o ),
	.ABUS_CTRL_LATCH_o( ABUS_CTRL_LATCH_o ),
	// Data Section
	.ABUS_DATA_CLK_o( ABUS_DATA_CLK_o ),
	.ABUS_DATA_IN0_o( ABUS_DATA_IN0_o ),
	.ABUS_DATA_IN1_o( ABUS_DATA_IN1_o ),
	.ABUS_DATA_LATCH_o( ABUS_DATA_LATCH_o ),
	
	.ABUS_RSTn_o( ABUS_RSTn_o ),
	// Audio Amplifier Output
	.AMP_MUTE_o( AMP_MUTE_o ),
	.AMP_SDBY_o( AMP_SDBY_o ),

	.CHIPTUNE_RSTn_o( CHIPTUNE_RSTn_o ),

	.DCSG_RDY_i( DCSG_RDY_i ),
// SID Bus
	.ABUS_SID_CLK_o( ABUS_SID_CLK_o ),
	.ABUS_SID_IN_o( ABUS_SID_IN_o ),
	.ABUS_SID_LATCH_o( ABUS_SID_LATCH_o ),
// DACs
	.AUD_PDn_o( AUD_PDn_o ),
	// Channel 0
	.AUD2_BICK_o( AUD2_BICK_o ),
	.AUD2_LRCK_o( AUD2_LRCK_o ),
	.AUD2_MCLK_o( AUD2_MCLK_o ),
	.AUD2_SDTI_o( AUD2_SDTI_o ),
	// Channel 1
	.AUD3_BICK_o( AUD3_BICK_o ),
	.AUD3_LRCK_o( AUD3_LRCK_o ),
	.AUD3_MCLK_o( AUD3_MCLK_o ),
	.AUD3_SDTI_o( AUD3_SDTI_o ),
	
	.DAC_Playback_Done48_Int_o( DAC_Playback_Done48_Int ),
	.DAC_Playback_Done44_Int_o( DAC_Playback_Done44_Int )

);


VICKYIII_TOP VICKYIII_TOP_LEVEL(

// Reset
	.Reset_i( System_Reset ),
	.Reset_14Mhz_i( Reset_14Mhz ),
	.Reset_24Mhz_i( Reset_24Mhz ),
	.Reset_40Mhz_i( Reset_40Mhz  ),
	.Reset_ClkVideoA_i( Reset_ClkVideoA ),
	.Reset_ClkVideoB_i( Reset_ClkVideoB ),	

	// Clocks
	.CPU_Clk_i( CPU_Clk ),				// CPU Clock - Could be 16/20/25/33/40/66/75

	.Clk14_318Mhz_i( OSC_CLK_14_318Mhz_i ),
	.Clk24_576Mhz_i( OSC_CLK_24_576Mhz_i ), 	// for I2C 
//	.Clk25_175Mhz_i( OSC_CLK_25_175Mhz_i ),
	.Clk40_000Mhz_i( OSC_CLK_40_000Mhz_i ),
//	.Clk65_000Mhz_i( OSC_CLK_65_000Mhz_i ),
	.Clk100M_A_i( Clk120_Div_A ),
	.Clk200M_A_i( Clk240_A ),	
	.Clk100M_B_i( Clk120_Div_B ),
	.Clk200M_B_i( Clk240_B ),	

// Video Clock Switches Interface	
	.LTC6903_A_i( LTC6903_A_i ),
	.LTC6903_B_i( LTC6903_B_i ),

	.VClock_LTC6903_A_CSn_o( VClock_LTC6903_A_CSn_o ),
	.VClock_LTC6903_B_CSn_o( VClock_LTC6903_B_CSn_o ),
	.VClock_LTC6903_SCLK_o( VClock_LTC6903_SCLK_o ),
	.VClock_LTC6903_DIN_o( VClock_LTC6903_DIN_o ),
// Buses
	.iBUS_A_i( iBUS_A ),
	.iBUS_A_Valid_i( iBUS_A_Valid ),
	.iBUS_D_i( iBUS_D_Write ),
	.iBUS_D_Valid_o( iBUS_D_Valid_VICKY ), 
	.iBUS_RWn_i( iBUS_RWn ),
	.iBUS_BE_i( iBUS_BE ),	
	.iBUS_D_VICKY_o( iBUS_D_VICKY ),
	
	
	.iBUS_CS_VICKY_A_i( iBUS_CS_VICKY_A ),
	.iBUS_CS_VICKY_MEM_A_i( iBUS_CS_VICKY_MEM_A ),
	.iBUS_CS_VICKY_B_i( iBUS_CS_VICKY_B ),
	.iBUS_CS_VICKY_MEM_B_i( iBUS_CS_VICKY_MEM_B ),
	.iBUS_CS_VRAM_A_i( iBUS_CS_VRAM_A ),
	.iBUS_CS_VRAM_B_i( iBUS_CS_VRAM_B ),
	
	
// Video
	.VID_SPC_io( VID_SPC_io ),		// IO
	.VID_SPD_io( VID_SPD_io ),		// IO
// Video DAC Output A
	.VID_A_RSTn_o( VID_A_RSTn_o ),
	.VID_A_CLK_P_o( VID_A_CLK_P_o ),
	.VID_A_HSYNC_o( VID_A_HSYNC_o ),
	.VID_A_VSYNC_o( VID_A_VSYNC_o ),
	.VID_A_DE_o( VID_A_DE_o ),	
	.VID_A_PIX_o( VID_A_PIX_o ),
// Video RAM Bank A
	.VRAM_A_DQ_io( VRAM_A_DQ_io ),
	.VRAM_A_DQM_o( VRAM_A_DQM_o ),
	.VRAM_A_Addy_o( VRAM_A_Addy_o ),
	.VRAM_A_BA_o( VRAM_A_BA_o ),
	.VRAM_A_RASn_o( VRAM_A_RASn_o ),
	.VRAM_A_CASn_o( VRAM_A_CASn_o ),
	.VRAM_A_WEn_o( VRAM_A_WEn_o ),
	.VRAM_A_CSn_o( VRAM_A_CSn_o ),
	.VRAM_A_CKE_o( VRAM_A_CKE_o ),
	.VRAM_A_CLK_o( VRAM_A_CLK_o ),	
	
// Video DAC Output B
	.VID_B_RSTn_o( VID_B_RSTn_o ),
	.VID_B_CLK_P_o( VID_B_CLK_P_o ),
	.VID_B_HSYNC_o( VID_B_HSYNC_o ),
	.VID_B_VSYNC_o( VID_B_VSYNC_o ),
	.VID_B_DE_o( VID_B_DE_o ),	
	.VID_B_PIX_o( VID_B_PIX_o ),
// Video RAM Bank B
	.VRAM_B_DQ_io( VRAM_B_DQ_io ),
	.VRAM_B_DQM_o( VRAM_B_DQM_o ),	
	.VRAM_B_Addy_o( VRAM_B_Addy_o ),
	.VRAM_B_BA_o( VRAM_B_BA_o ),
	.VRAM_B_RASn_o( VRAM_B_RASn_o ),
	.VRAM_B_CASn_o( VRAM_B_CASn_o ),
	.VRAM_B_WEn_o( VRAM_B_WEn_o ),
	.VRAM_B_CSn_o( VRAM_B_CSn_o ),
	.VRAM_B_CKE_o( VRAM_B_CKE_o ),
	.VRAM_B_CLK_o( VRAM_B_CLK_o ),
// Splash Screen Flash
	.CONFIG_CSn_o( CONFIG_CSn_o ),
	.CONFIG_MISO_i( CONFIG_MISO_i ),
	.CONFIG_MOSI_o( CONFIG_MOSI_o ),
	.CONFIG_SCLK_o( CONFIG_SCLK_o ),
	
	.SOF_Channel_A_o( SOF_Channel_A ),
	.SOF_Channel_B_o( SOF_Channel_B ),
	
	.VKY_III_Channel_A_IRQ_o( VKY_III_Channel_A_IRQ ),
	.VKY_III_Channel_B_IRQ_o( VKY_III_Channel_B_IRQ ),
	
	.DP_HIRES_i( DP_HIRES ),
	.DP_GAMMA_i( DP_GAMMA ),
	
	.PLL_Locked_A_o( PLL_Locked_A ),
	.PLL_Locked_B_o( PLL_Locked_B )
);



DebugModule GavinDebug(
	.Serial_Clk_i( Clk24_Div_A ),
	.Serial_Rst_i( Reset_48Mhz ),
	.System_Rst_i( System_Reset ),
	// Debug Interface
	.Dbg_Clk_i( CPU_Clk  ),
	.Dbg_Mode_o( Dbg_Mode_On ),	// Indicate when the Debug Mode has taken over
	.Dbg_A_o( Dbg_Address_Out ),
	.Dbg_D_o( Dbg_Data_Out ),
	.Dbg_D_i( Dbg_Data_In ),		// This is the Databus from SystemBUS (mem, chipset, etc...)


	.Dbg_CPU_Rst_o( Dbg_Reset ),
	.Dbg_CPU_Halt_o( Dbg_Halt ),

	.Dbg_RAM0_CS_o( Dbg_RAM_CS0 ),
	.Dbg_RAM1_CS_o( Dbg_RAM_CS1 ),
	.Dbg_RW_o( Dbg_RWn_Out ),	
	.Dbg_Oe_o( Dbg_OE ),

	.Dbg_Flash0_CS_o( Dbg_FLASH_CS0 ),
	.Dbg_Flash1_CS_o( Dbg_FLASH_CS1 ),	
	.Dbg_Flash_WRn_o( Dbg_FLASH_WR ),
	.Dbg_Flash_OEn_o( Dbg_FLASH_OE ), 
	
	
	// RS-232 Interface
	.Rs_RX_i(DBG_RX_i),
	.Rs_TX_o(DBG_TX_o),
	
	// Debug Output of the Debug Interface
	.DebugDebug_o( DebugDebugTrig )
);



/*
Pin definition for the MC68SEC000
MC68SEC000  ->   MC68040V
D0					  	D0, D16
D1					  	D1, D17
D2					  	D2, D18
D3					  	D3, D19
D4					  	D4, D20
D5					  	D5, D21
D6					  	D6, D22
D7					  	D7, D23
D8					  	D8, D24
D9					  	D9, D25
D10				  	D10, D26
D11				  	D11, D27
D12				  	D12, D28
D13				  	D13, D29
D14				  	D14, D30
D15				  	D15, D31

NC					  	A0
A0						A1
A1						A2
A2						A3
A3						A4
A4						A5
A5						A6
A6						A7
A7						A8
A8						A9
A9						A10
A10					A11
A11					A12
A12					A13
A13					A14
A14					A15
A15					A16
A16					A17
A17					A18
A18					A19
A19					A20
A20					A21
A21					A22
A22					A23
A23					A24
NC						A25
NC						A26
NC						A27
NC						A28
NC						A29
NC						A30
NC						A31

NC					   MDISn
NC						CDISn
NC						CIOUTn
IPL0n					IPL0n
IPL1n					IPL1n
IPL2n					IPL2n
NC						IPENDn
CPU_CLK				BCLK
NC						PCLK
FC2					TM2
FC1					TM1
FC0					TM0
R_Wn					R_Wn
NC						DLE
NC						TT0
NC						TT1
LDSn					SIZ0
UDSn					SIZ1
NC						TLN1
NC						TLN0
NC						UPA1
NC						UPA0
NC						TEAn
NC						TIPn
ASn					TSn
NC						MIn					
NC						TBIn
NC						TCIn
DTACKn				TAn
AVECn					AVECn
HALTn					LOCKEn
BERRn					LOCKn
NC						PST3
NC						PST2
NC						PST1
NC						PST0
NC						SC1
NC						SC0
BRn					BRn
BGn					BGn
NC						BBn
RESETn				RSTIn (this is bidir signals)
NC						RSTOn
*/




// {ALTERA_IO_END} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_BEGIN} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_END} DO NOT REMOVE THIS LINE!
endmodule

