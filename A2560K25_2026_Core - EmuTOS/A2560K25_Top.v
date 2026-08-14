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
// Stefany is Here November 1st 2025
module A2560K25_Top (
// {ALTERA_ARGS_BEGIN} DO NOT REMOVE THIS LINE!
inout	wire				COLD_RESETn_io,	

inout	wire		[31:0]	CPU_A_io,	// IO
inout	wire		[31:0]	CPU_D_io,	// IO D[31:0]
output	wire				MEM_A2_o,
output	wire				MEM_A3_o,
// CPU Clock Output
output	wire				CPU_BCLK_o,
output  wire   				CPU_DLE_o,
//Bus Mastering Control (MC68040V)
output	wire				CPU_BGn_o,
input 	wire				CPU_BBn_io,
input 	wire				CPU_BRn_i,
output	wire				CPU_CDISn_o,
input	wire				CPU_CIOUTn_i,	// ??? is it an input or Ouput?

output  wire				CPU_AVECn_o,
input   wire				CPU_IPENDn_i,
output	wire				CPU_IPL0n_o,
output	wire				CPU_IPL1n_o,
output	wire				CPU_IPL2n_o,
// 68060 Signals that are not used
input	wire				CPU_LOCKn_i,	// Output From the CPU - NOT USED
input	wire				CPU_LOCKEn_i,	// Output From the CPU - NOT USED
output	wire				CPU_MDISn_o,
input 	wire                CPU_MIn_i,     	// For MC68040
output	wire				CPU_PCLK_o,				// Processor Clock for the 68040V, not used in the MC68SEC000
input	wire				CPU_PST0_i,
input	wire				CPU_PST1_i,
input	wire				CPU_PST2_i,
input	wire				CPU_PST3_i,
inout	wire				CPU_RWn_io,				// IO (MC68040)
output  wire				CPU_RESET_INn_o,
input   wire				CPU_RESET_OUTn_i,
input	wire				CPU_SC0_io,				// IO (MC68040)
input	wire				CPU_SC1_io,				// IO (MC68040)
inout	wire				CPU_SIZ0_io,			// IO (MC68040)
inout	wire				CPU_SIZ1_io,			// IO (MC68040)
// TA Group
inout	wire				CPU_TSn_io,				// IO (MC68040)
inout	wire				CPU_TAn_io,				// IO (MC68040)
inout	wire				CPU_TBIn_io,			//
inout	wire				CPU_TEAn_io,
inout	wire				CPU_TCIn_io,
input	wire				CPU_TIPn_i,
// Control & Status Signals
input	wire				CPU_TLN0_i,
input	wire				CPU_TLN1_i,
input	wire				CPU_TM0_i,
input	wire				CPU_TM1_i,
input	wire				CPU_TM2_i,
inout	wire				CPU_TT0_io,				// IO (MC68040)
inout	wire				CPU_TT1_io,				// IO (MC68040)
input	wire				CPU_UPA0_i,
input	wire				CPU_UPA1_i,
// MC68040 Specific signals
output	wire				CPU_LFOn_o,
input	wire				CPU_LOC_i,
input	wire				CPU_SCDn_i,
// Local Memory (SRAM/FLASH) Control Signals
output	wire				LOCAL_MEM_FLASH_CS0n_o,
output	wire				LOCAL_MEM_FLASH_CS1n_o,
output	wire				LOCAL_MEM_FLASH_OEn_o,
output	wire				LOCAL_MEM_FLASH_WEn_o,
output	wire				LOCAL_MEM_FLASH_RSTn_o,
output	wire				LOCAL_MEM_FLASH_WPn_o,
output	wire	[3:0]		LOCAL_MEM_SRAM_BEn_o,
output	wire				LOCAL_MEM_SRAM_CS0n_o,
output	wire				LOCAL_MEM_SRAM_CS1n_o,
output	wire				LOCAL_MEM_SRAM_OEn_o,
output	wire				LOCAL_MEM_SRAM_WEn_o,
// Audio Bus Control Signals
output	wire				ABUS_CTRL_CLK_o,
output	wire				ABUS_CTRL_IN_o,
output	wire				ABUS_CTRL_LATCH_o,
output	wire				ABUS_DATA_CLK_o,
output	wire				ABUS_DATA_IN0_o,
output	wire				ABUS_DATA_IN1_o,
output	wire				ABUS_DATA_LATCH_o,
output	wire				ABUS_SID_CLK_o,
output	wire				ABUS_SID_IN_o,
output	wire				ABUS_SID_LATCH_o,
output	wire				ABUS_RSTn_o,
output	wire				AUD_PDn_o,
output	wire				AUD2_BICK_o,
output	wire				AUD2_LRCK_o,
output	wire				AUD2_MCLK_o,
output	wire				AUD2_SDTI_o,
output	wire				AUD3_BICK_o,
output	wire				AUD3_LRCK_o,
output	wire				AUD3_MCLK_o,
output	wire				AUD3_SDTI_o,
output	wire				AMP_MUTE_o,
output	wire				AMP_SDBY_o,
output	wire				BTX_BUZZER_o,
output	wire				CHIPTUNE_RSTn_o,
output	wire				DCSG_CLK_o,
input	wire				DCSG_RDY_i,
// CODEC
input	wire				CODEC_ADC_BCLK_i,
input	wire				CODEC_ADC_DAT_i,
input	wire				CODEC_ADC_LRCK_i,
input	wire				CODEC_ADC_MCLK_o,
output	wire				CODEC_DAC_BCLK_o,
output	wire				CODEC_DAC_DAT_o,
output	wire				CODEC_DAC_LRCK_o,
output	wire				CODEC_DAC_MCLK_o,
output	wire				CODEC_DI_o,
output	wire				CODEC_CE_o,
output	wire				CODEC_CL_o,
// Splash Screen Flash
output	wire				CONFIG_CSn_o,
input	wire				CONFIG_MISO_i,
output	wire				CONFIG_MOSI_o,
output	wire				CONFIG_SCLK_o,
//
input	wire		[1:0]	DIP_BOOT_MODE_i,
input	wire		[1:0]	DIP_GAMMA_MODE_i,
input	wire		[1:0]	DIP_HIRES_MODE_i,
input	wire		[1:0]	DIP_USER_i,
input	wire				CPU_SPEED_i,

// Misc System Control
output	wire				BLU_POWER_LED_o,		// On/Off (board LED)
output	wire				RGB_POWER_LED_o,		// RGB - Some serializing will be needed to get the RGB we want
output	wire				SDCARD_LED_o,			// On/Off (board LED)
input	wire				MACHINE_ID0_i,
input	wire				MACHINE_ID1_i,		

// Oscillator Input
input	wire				OSC_CLK_14_318Mhz_i,
input	wire				OSC_CLK_33_333Mhz_i,
input	wire				OSC_CLK_22_579Mhz_i,
input	wire				OSC_CLK_24_576Mhz_i,
input	wire				OSC_CLK_25_175Mhz_i,
input	wire				OSC_CLK_40_000Mhz_A_i,
input	wire				OSC_CLK_40_000Mhz_B_i,
input	wire				OSC_CLK_65_000Mhz_i,
input  	wire  				OSC_CLK_80_000Mhz_i,
// Not Used
output	wire				VClock_LTC6903_A_CSn_o,
output	wire				VClock_LTC6903_B_CSn_o,
output	wire				VClock_LTC6903_SCLK_o,
output	wire				VClock_LTC6903_DIN_o,		//MoSi
input	wire				LTC6903_A_i,
input	wire				LTC6903_B_i,
// Debug Interface
input	wire				DBG_RX_i,
output	wire				DBG_TX_o,
// SDCard Controller
input	wire				F_SD_CD_i,
output	wire				F_SD_CLK_o,			// CLK
output	wire				F_SD_CMD_o,			// MOSI
input	wire				F_SD_DAT0_io,		// MISO
input	wire				F_SD_DAT1_io,		// IO
input	wire				F_SD_DAT2_io,		// IO
output	wire				F_SD_DAT3_io,		// IO (CS)
input	wire				F_SD_WP_i,
// IO Bus
output	wire	[7:0]		IO_A_o,
inout	wire	[15:0]		IO_D_io,
output	wire				IO_RDn_o,
output	wire				IO_WRn_o,
// Ethernet Specific Signals
output	wire				ETH_CSn_o,
output	wire				ETH_FIFO_SEL_o,
output	wire				ETH_RSTn_o,
// IDE Specifics Signals
output	wire				IDE_CS0n_o,
output	wire				IDE_CS1n_o,
output	wire				IDE_DATA_DIR_o,
output	wire				IDE_DATA_OEn_o,
input	wire				IDE_IORDY_i,
output	wire				IDE_RESETn_o,
// Interrupt
input	wire				IDE_INTRQ_i,
input	wire				ETH_IRQn_i,
// Joystick
inout	wire				JOY0_BTN0_io,		// IO
inout	wire				JOY0_BTN1_io,		// IO
inout	wire				JOY0_BTN2_io,		// IO
input	wire				JOY0_DWN_io,		// IO
input	wire				JOY0_LFT_io,		// IO
input	wire				JOY0_RGHT_io,		// IO
input	wire				JOY0_UP_io,			// IO
output	wire				JOYSTICK0_RLY_o,
inout	wire				JOY1_BTN0_io,		// IO
inout	wire				JOY1_BTN1_io,		// IO
inout	wire				JOY1_BTN2_io,		// IO
input	wire				JOY1_DWN_io,		// IO
input	wire				JOY1_LFT_io,		// IO
input	wire				JOY1_RGHT_io,		// IO
input	wire				JOY1_UP_io,			// IO
output	wire				JOYSTICK1_RLY_o,
//LPC Interface
output	wire				LPC_CLK_32Khz_o,
inout	wire				LPC_IRQn_io,		// BiDir
input	wire				LPC_LDRQn_i,
inout	wire	[3:0]		LPC_LAD_io,			// BiDir
output	wire				LPC_LFRAMEn_o,
output	wire				LPC_RSTn_o,
// Keyboard (The FPGA is the Slave)
input	wire				KBD_CSn_i,
input	wire				KBD_CLK_i,
output	wire				KBD_INTn_o,
output	wire				KBD_MISO_o,
input	wire				KBD_MOSI_i,
output	wire				MTX_CLK_o,
output	wire				MTX_LATCH_o,
output	wire				MTX_SERIAL_IN_o,
output	wire				STS_CLK_o,
output	wire				STS_LATCH_o,
output	wire				STS_SERIAL_IN_o,

output	wire				OPL3_CLK_o,
output	wire				OPM_CLK_o,
output	wire				OPN2_CLK_o,
output	wire				SID_CLK_o,
input	wire				OPL3_INTn_i,
input	wire				OPM_INTn_i,
input	wire				OPN2_INTn_i,

// RTC
output	wire	[3:0]		RTC_A_o,
inout	wire	[7:0]		RTC_D_io,
output	wire				RTC_OEn_o,
output	wire				RTC_CSn_o,
input	wire				RTC_INTn_i,
output	wire				RTC_RWn_o,

// System RAM
inout	wire	[31:0]		SYSRAM_DQ_io,
output	wire	[3:0]		SYSRAM_DQM_o,
output	wire	[12:0]		SYSRAM_A_o,
output	wire				SYSRAM_BA0_o,
output	wire				SYSRAM_BA1_o,
output	wire				SYSRAM_CASn_o,
output	wire				SYSRAM_RASn_o,
output	wire				SYSRAM_WEn_o,
output	wire				SYSRAM_CS0n_o,
output	wire				SYSRAM_CKE_o,
output	wire				SYSRAM_CLK_o,
// Video
inout	wire				VID_SPC_io,		// IO
inout	wire				VID_SPD_io,		// IO
// Video DAC Output A
output	wire				VID_A_CLK_P_o,
output	wire				VID_A_DE_o,
input	wire				VID_A_HP_INT1n_i,
output	wire				VID_A_HSYNC_o,
output	wire				VID_A_RSTn_o,
output	wire				VID_A_VSYNC_o,
output	wire	[11:0]		VID_A_PIX_o,
// Video DAC Output B
output	wire				VID_B_CLK_P_o,
output	wire				VID_B_DE_o,
input	wire				VID_B_HP_INT1n_i,
output	wire				VID_B_HSYNC_o,
output	wire				VID_B_RSTn_o,
output	wire				VID_B_VSYNC_o,
output	wire	[11:0]		VID_B_PIX_o,
// Video RAM Bank A
inout	wire	[31:0]		VRAM_A_DQ_io,
output	wire	[3:0]		VRAM_A_BEn_o,
output	wire	[19:0]		VRAM_A_Addy_o,
output	wire				VRAM_A_OEn_o,
output	wire				VRAM_A_WEn_o,
// Video RAM Bank B
inout	wire	[31:0]		VRAM_B_DQ_io,
output	wire	[3:0]		VRAM_B_BEn_o,	
output	wire	[19:0]		VRAM_B_Addy_o,
output	wire				VRAM_B_OEn_o,
output	wire				VRAM_B_WEn_o
);
// Output that are not used:
assign CONFIG_CSn_o = 1'b1;
assign CONFIG_MOSI_o = 1'b1;
assign CONFIG_SCLK_o = 1'b1;

assign VClock_LTC6903_A_CSn_o = 1'b0;
assign VClock_LTC6903_B_CSn_o = 1'b0;
assign VClock_LTC6903_SCLK_o = 1'b0;
assign VClock_LTC6903_DIN_o = 1'b0;

assign CPU_DLE_o = 1'b1;

// Temporary Assignment
wire 	[31:0]		iBUS_D_GAVIN;
wire 	[31:0] 		iBUS_D_BEATRIX;
wire	[31:0]		iBUS_D_VICKY;
wire	[31:0]		iBUS_D_MERA;
wire 	[31:0] 		iBUS_D_VRAM_A;
wire 	[31:0] 		iBUS_D_VRAM_B;
wire	[31:0]		iBUS_A;

wire	[7:0]		iBUS_D_Write8;
wire	[15:0]		iBUS_D_Write16;
wire	[31:0]		iBUS_D_Write32;

wire	[3:0]		iBUS_BE;
wire				iBUS_WE;
wire	[1:0]		iBUS_D_Siz;
wire				iBUS_RWn;
wire				iBUS_A_Valid;
wire				iBUS_D_Valid;
wire 				iBUS_CS_GAVIN;
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
wire 	[31:0] 		Dbg_Address_Out;
wire	[31:0]		Dbg_Data_Out;
wire	[31:0]		Dbg_Data_In;
wire				Dbg_RWn_Out;
wire  	[3:0]		Dbg_BEn_Out;
wire 				Dbg_RAM_CS;
wire				Dbg_FLASH_CS;
wire				Dbg_FLASH_WR;
wire				Dbg_FLASH_OE;
wire				Dbg_OE;
wire				Dbg_RSTn;


wire				Clk24Mhz;	// Serial Port (USB Debug Port)
wire				Clk100Mhz;
wire				Clk200Mhz;
wire				PLL_SDcard_Locked;

wire				iBUS_D_Valid_BEATRIX;
wire				iBUS_D_Valid_GABE;
wire				iBUS_D_Valid_VICKY;
wire				iBUS_D_Valid_MERA;

wire 				SOF_Channel_A;
wire 				SOF_Channel_B;

wire 	[6:0]		iIRQ_Interrupt;
wire 	[7:0]		iIRQ_Vector;
wire				iIRQ_AutoVector;
wire 				iIRQ_GetVector;

wire 	[5:0] 		VKY_III_Channel_A_IRQ;
wire 	[5:0] 		VKY_III_Channel_B_IRQ;

wire 				DAC_Playback_Done48_Int;
wire 				DAC_Playback_Done44_Int;


wire 				Manual_RESET;
wire 				COLD_RESETn_In;

wire 				FLASH_CSn;
wire 				FLASH_OEn;
wire 				FLASH_WEn;
wire 	[3:0]		SRAM_BEn;
wire 				SRAM_CSn;
wire 				SRAM_OEn;
wire 				SRAM_WEn;
wire 				CS_RTC;
wire 				Wait_Unity_TA;
wire 				Wait_LPC_TA;
wire				Wait_RTC_TA;
wire 				Wait_MERA_TA;
wire 				Wait_BufferA;
wire 				Wait_BufferB;
wire 				Wait_BufferA_TA;
wire 				Wait_BufferB_TA;

wire 				CS_SDCard;
wire 				CS_Unity;
wire 				CS_LPC;
wire 				CS_IDE;
// New Signal For CPU Bus Mastering
wire     [1:0]      Channel_Select;
wire                iBUS_MTXT_BRn;
wire                iBUS_MTXT_BGn;
wire                iBUS_SDMA_BRn;
wire                iBUS_SDMA_BGn;
wire                iBUS_VDMA_BRn;
wire                iBUS_VDMA_BGn;
wire                iBUS_DEBUG_BRn;
wire                iBUS_DEBUG_BGn;
// External SRAM Access Port
wire               	Ext_RAM_OEn;
wire               	Ext_RAM_WEn;
wire    [3:0]     	Ext_RAM_BEn;
wire    [31:0]    	Ext_RAM_Addy;
wire    [31:0]    	Ext_RAM_Data_In;
wire    [31:0]    	Ext_RAM_Data_Out;

wire 	[31:0] 		iBUS_D_Out_virgin;


assign LOCAL_MEM_FLASH_CS0n_o = FLASH_CSn;
assign LOCAL_MEM_FLASH_CS1n_o = FLASH_CSn;
assign LOCAL_MEM_FLASH_OEn_o = 	FLASH_OEn;
assign LOCAL_MEM_FLASH_WEn_o = 	FLASH_WEn;
assign LOCAL_MEM_FLASH_RSTn_o = 1'b1;
assign LOCAL_MEM_FLASH_WPn_o  = 1'b1; 
assign LOCAL_MEM_SRAM_BEn_o = SRAM_BEn;
assign LOCAL_MEM_SRAM_CS0n_o = SRAM_CSn;
assign LOCAL_MEM_SRAM_CS1n_o = SRAM_CSn;
assign LOCAL_MEM_SRAM_OEn_o = SRAM_OEn;
assign LOCAL_MEM_SRAM_WEn_o = SRAM_WEn;

BIDIR_SIGNAL	RESET_BUFFER (
	.datain ( 1'b0  ),
	.dataio ( COLD_RESETn_io ),
	.dataout ( COLD_RESETn_In ),				// Cold Reset - Active Low
	.oe ( Manual_RESET | Timer_Reset_once )	//| Manual_RESET
	);

reg [31:0] Timer_Reset_once;

initial Timer_Reset_once = 32'h0800_0000;

always @ (posedge OSC_CLK_14_318Mhz_i ) begin
	if ( Timer_Reset_once ) begin
		Timer_Reset_once <= Timer_Reset_once - 32'h0000_0001;
	end
	else begin
		Timer_Reset_once <= 32'h0000_0000;
	end 
end 
	
assign AUD_PDn_o = COLD_RESETn_In;

reg [1:0] Clk3_58Mhz;
always @ (posedge OSC_CLK_14_318Mhz_i)
begin
	Clk3_58Mhz <= Clk3_58Mhz + 2'b01;
end

assign OPL3_CLK_o 		= OSC_CLK_14_318Mhz_i;
assign OPN2_CLK_o 		= Clk3_58Mhz[0];	 	// Clk 7M (14.318M / 2)
assign OPM_CLK_o 		= Clk3_58Mhz[1];	 // Clk 3M (14.318M / 4)
assign DCSG_CLK_o 		= Clk3_58Mhz[1];  	// Clk 3M (14.318M / 4)

wire 	CPU_Clk66Mhz;
wire 	DRAM_Clk133Mhz;
wire 	VEng_A_Clk199Mhz;
wire 	VEng_B_Clk199Mhz;
wire 	SYS_Clk33Mhz;
wire 	Clock133Mhz;
wire    Video108Mhz;		// New Dot Clock to generate 1280x960 or 1280x1024
wire    Video108Mhz_Locked;
wire 	iBUS_1xClk;		//	33Mhz
wire  	iBUS_2xClk;		// 66Mhz
wire    Internal_80Mhz;

PLL_SDCard_Debug	PLL_SDCard_Debug_inst (
	.inclk0 ( OSC_CLK_80_000Mhz_i ),		// Feb 23th 2026
	.c0 ( Clk24Mhz ),		// Output on the Processor Clock
	.c1( Clock133Mhz ),	//100Mhz
	.c2( VEng_A_Clk199Mhz ),	//200Mhz
	.c3( VEng_B_Clk199Mhz ),	//200Mhz
	.locked ( PLL_SDcard_Locked )
	);

PLL_40Mhz_108Mhz	PLL_40Mhz_108Mhz_inst (
	.areset ( !PLL_SDcard_Locked ),
	.inclk0 ( OSC_CLK_40_000Mhz_B_i ),		// Video Clock 40Mhz
	.c0 ( Video108Mhz ),
	.locked ( Video108Mhz_Locked )
	);

reg Clk099_A;
// 1/2
always @ (posedge VEng_A_Clk199Mhz) begin
	Clk099_A <= ~Clk099_A;
end

reg Clk099_B;
// 1/2
always @ (posedge VEng_B_Clk199Mhz) begin
	Clk099_B <= ~Clk099_B;
end
	

wire Master_Resetn;
wire System_Clk133_RST;
//wire System_Clk133_RSTn;
reg [2:0] COLD_RESETn_RESYNC;
always @ (posedge Clock133Mhz) begin 
    COLD_RESETn_RESYNC[0] <= COLD_RESETn_In;
    COLD_RESETn_RESYNC[1] <= COLD_RESETn_RESYNC[0];
    if ( COLD_RESETn_RESYNC[1] == COLD_RESETn_RESYNC[0] )
        COLD_RESETn_RESYNC[2] <= COLD_RESETn_RESYNC[1];
end 
// This is the System Clock 133Mhz ReSynced Incoming Reset
assign System_Clk133_RST = !COLD_RESETn_RESYNC[2];
//assign System_Clk133_RSTn = COLD_RESETn_RESYNC[2];
//////////////////////////////////////
//////////////////////////////////////
//
// NEW MC68060 INTERFACE
//
//////////////////////////////////////
//////////////////////////////////////
/*
MC68LC060_Plus_Arbiter MainCPU_Module(
    .Global_Reset_i( !COLD_RESETn_In ),
    .Master_Resetn_o( Master_Resetn ),   // That Reset Comes out after Code is Transfered in RAM ( SRAM <- FLASH )
    .Clk_133Mhz_i( Clock133Mhz ),	// 132Mhz = CPU Speed 33Mhz

    .CPU_A_io( CPU_A_io ),	// IO
    .CPU_D_io( CPU_D_io ),	// IO - D[31:0] - ( D[31:24] LSB ) - ( D[7:0] MSB )
    .MEM_BURST_A2_o( MEM_A2_o ),
    .MEM_BURST_A3_o( MEM_A3_o ),

    .CPU_BCLK_o( CPU_BCLK_o ),
    .CPU_CLK_ENn_o( CPU_CLKEN_o ),
    .CPU_AVECn_o( CPU_AVECn_o ),
// Bus Control Signals
    .CPU_BGn_o( CPU_BGn_o ),
    .CPU_BBn_io( CPU_BBn_io ),
    .CPU_BRn_i( CPU_BRn_i ),
    .CPU_BGRn_o( CPU_BGRn_o ),			// Bus Grant Relinquish Control

    .CPU_CDISn_o( CPU_CDISn_o ),
    .CPU_CIOUTn_i( CPU_CIOUTn_i ),
    .CPU_IPENDn_i( CPU_IPENDn_i ),
    .CPU_IPLn_o( CPU_IPL_o ),
    .CPU_MDISn_o( CPU_MDISn_o ),
    .CPU_PST_i( CPU_PST_i ),
    .CPU_RWn_i( CPU_RWn_i ),
    .CPU_RESET_INn_o( CPU_RESET_INn_o ),
    .CPU_RESET_OUTn_i( CPU_RESET_OUTn_i ),
    .CPU_SIZ_i( CPU_SIZ_i ),
	// TA Group
    .CPU_TAn_o( CPU_TAn_o ),
    .CPU_TEAn_o( CPU_TEAn_o ),
    .CPU_TBIn_o( CPU_TBIn_o ),
    .CPU_TCIn_o( CPU_TCIn_o ),
    .CPU_TIPn_i( CPU_TIPn_i ),
    .CPU_TSn_io( CPU_TSn_io ),
    .CPU_TLN_i( CPU_TLN_i ),
    .CPU_TM_i( CPU_TM_i ),
    .CPU_TT0_i( CPU_TT0_i ),
    .CPU_TT1_io( CPU_TT1_io ),
    .CPU_UPA_i( CPU_UPA_i ),        // Not Used

    .CPU_BSn_i( CPU_BSn_i ),		        // Byte Select
    .CPU_BTTn_io( CPU_BTTn_io ),			// Bus Tenure Termination 

    .LOCAL_MEM_FLASH_CSn_o( FLASH_CSn ),
    .LOCAL_MEM_FLASH_OEn_o( FLASH_OEn ),
    .LOCAL_MEM_FLASH_WEn_o( FLASH_WEn ),
    .LOCAL_MEM_SRAM_BEn_o(  SRAM_BEn  ),
    .LOCAL_MEM_SRAM_CSn_o(  SRAM_CSn  ),
    .LOCAL_MEM_SRAM_OEn_o(  SRAM_OEn  ),
    .LOCAL_MEM_SRAM_WEn_o(  SRAM_WEn  ),
// Internal Clock Signals 
    .iBUS_1xClk_o( iBUS_1xClk ),    //33Mhz
    .iBUS_2xClk_o( iBUS_2xClk ),    //66Mhz
    .iBUS_A_o( iBUS_A ),
    .iBUS_D_Write8_o( iBUS_D_Write8 ),
    .iBUS_D_Write16_o( iBUS_D_Write16 ),
    .iBUS_D_Write32_o( iBUS_D_Write32 ),
    .iBUS_D_Out_virgin_o( iBUS_D_Out_virgin ),   // Full 32bits BUS from CPU (Without Filtering or Organizing)
    .iBUS_D_Siz_o( iBUS_D_Siz ),
    .iBUS_RWn_o( iBUS_RWn ),
    .iBUS_BE_o( iBUS_BE ),
    .iBUS_WE_o( iBUS_WE ),
    .iBUS_A_Valid_o( iBUS_A_Valid ),
    // Devices 32bits Databus
	.iBUS_D_GAVIN_i( iBUS_D_GAVIN ),
	.iBUS_D_BEATRIX_i( iBUS_D_BEATRIX ),
	.iBUS_D_VICKY_i( iBUS_D_VICKY ),
	.iBUS_D_MERA_i( iBUS_D_MERA ),

    // Devices Chipselect
	.iBUS_CS_GAVIN_o( iBUS_CS_GAVIN ),
	.iBUS_CS_BEATRIX_o( iBUS_CS_BEATRIX ),
	.iBUS_CS_VICKY_A_o( iBUS_CS_VICKY_A ),
	.iBUS_CS_VICKY_MEM_A_o( iBUS_CS_VICKY_MEM_A ),
	.iBUS_CS_VICKY_B_o( iBUS_CS_VICKY_B ),
	.iBUS_CS_VICKY_MEM_B_o( iBUS_CS_VICKY_MEM_B ),
	.iBUS_CS_VRAM_A_o( iBUS_CS_VRAM_A ),
	.iBUS_CS_VRAM_B_o( iBUS_CS_VRAM_B ),
	.iBUS_CS_MERA_o( iBUS_CS_MERA ),  
  
    // Interrupts
    .iIRQ_Interrupt_i( iIRQ_Interrupt ),
    .iIRQ_Vector_i( iIRQ_Vector ),
    .iIRQ_AutoVector_i( iIRQ_AutoVector ),
    .iIRQ_GetVector_o( iIRQ_GetVector ),

    .Dbg_Mode_On_i( Dbg_Mode_On ),
    .Dbg_Address_Out_i( Dbg_Address_Out ),
    .Dbg_Data_Out_i( Dbg_Data_Out ),
    .Dbg_Data_In_o( Dbg_Data_In ),
    .Dbg_BEn_i( Dbg_BEn_Out  ),
    .Dbg_RWn_Out_i( Dbg_RWn_Out ),
    .Dbg_RAM_CS_i( Dbg_RAM_CS ),
    .Dbg_FLASH_CS_i( Dbg_FLASH_CS ),
    .Dbg_FLASH_WR_i( Dbg_FLASH_WR ),
    .Dbg_FLASH_OE_i( Dbg_FLASH_OE ),
    .Dbg_OE_i( Dbg_OE ),
    .Dbg_RSTn_i( Dbg_RSTn ),

    .TSF_FLASH2RAM_o(  ),
// Wait-State Section	
	.Wait_Unity_TA_i( Wait_Unity_TA ),
	.Wait_LPC_TA_i( Wait_LPC_TA ),
	.Wait_RTC_TA_i( Wait_RTC_TA ),
	.Wait_MERA_TA_i( Wait_MERA_TA ), 

	.CS_Unity_i( CS_Unity ),
	.CS_LPC_i( CS_LPC ),
	.CS_RTC_i( CS_RTC ),

// Signal for Sharing the CPU BUS Mastership
   .Channel_Select_o( Channel_Select ),
// SDMA & MemText Interface
    .Ext_RAM_OEn_i( Ext_RAM_OEn ),
    .Ext_RAM_WEn_i( Ext_RAM_WEn ),
    .Ext_RAM_BEn_i( Ext_RAM_BEn ),
    .Ext_RAM_Addy_i( Ext_RAM_Addy ),
    .Ext_RAM_Data_i( Ext_RAM_Data_Out ),
    .Ext_RAM_Data_o( Ext_RAM_Data_In ),

    .iBUS_MTXT_BRn_i( iBUS_MTXT_BRn ),
    .iBUS_MTXT_BGn_o( iBUS_MTXT_BGn ),
    .iBUS_SDMA_BRn_i( iBUS_SDMA_BRn ),
    .iBUS_SDMA_BGn_o( iBUS_SDMA_BGn ),
    .iBUS_VDMA_BRn_i( iBUS_VDMA_BRn ),
    .iBUS_VDMA_BGn_o( iBUS_VDMA_BGn ),
    .iBUS_DEBUG_BRn_i( iBUS_DEBUG_BRn ),
    .iBUS_DEBUG_BGn_o( iBUS_DEBUG_BGn )	
);
*/
//////////////////////////////////////
//////////////////////////////////////
//
// NEW MC68040 INTERFACE WiTH ARBITER
//
//////////////////////////////////////
//////////////////////////////////////
MC68040V_Plus_Arbiter MainCPU_Module(
	.Global_Reset_i( !COLD_RESETn_In ),
	.Master_Resetn_o( Master_Resetn ),			// This Reset will unreset when the code is transfered.
	.Clk_133Mhz_i( Clock133Mhz ), 				// 133Mhz In
// MC68040 General A2560K Interface
	.CPU_A_io( CPU_A_io ),	// IO
	.CPU_D_io( CPU_D_io ),	// IO
	
	.MEM_BURST_A2_o( MEM_A2_o ),
	.MEM_BURST_A3_o( MEM_A3_o ), 

//CPU Control (MC68040V)
	.CPU_BCLK_o( CPU_BCLK_o ),
	.CPU_AVECn_o( CPU_AVECn_o ),
// Bus Control Signals
	.CPU_BGn_o( CPU_BGn_o ),
	.CPU_BBn_io( CPU_BBn_io ),
	.CPU_BRn_i(CPU_BRn_i  ),
//	
	.CPU_CDISn_o( CPU_CDISn_o ),
	.CPU_CIOUTn_i( CPU_CIOUTn_i ),
	.CPU_IPENDn_i( CPU_IPENDn_i ),
	.CPU_IPL0n_o(CPU_IPL0n_o  ),
	.CPU_IPL1n_o( CPU_IPL1n_o ),
	.CPU_IPL2n_o( CPU_IPL2n_o ),
	.CPU_LOCKn_i( CPU_LOCKn_i ),
	.CPU_LOCKEn_i( CPU_LOCKEn_i ),
	.CPU_MDISn_o( CPU_MDISn_o ),
	.CPU_MIn_i( CPU_MIn_i ),
	.CPU_PCLK_o( CPU_PCLK_o ),		// 
	.CPU_PST0_i( CPU_PST0_i ),
	.CPU_PST1_i( CPU_PST1_i ),
	.CPU_PST2_i( CPU_PST2_i ),
	.CPU_PST3_i( CPU_PST3_i ),
	.CPU_RWn_io( CPU_RWn_io ),				// IO (MC68040)
	.CPU_RESET_INn_o( CPU_RESET_INn_o ),		// THis is the CPU Reset In - Sometimes it can be IO
	.CPU_RESET_OUTn_i( CPU_RESET_OUTn_i ),		// This is the MC68040 Reset Out Function Called by the Instruction Reset
	.CPU_SIZ0_io( CPU_SIZ0_io ),			// IO (MC68040)
	.CPU_SIZ1_io( CPU_SIZ1_io ),			// IO (MC68040)

	.CPU_TAn_io( CPU_TAn_io ),				// IO (MC68040)
	.CPU_TBIn_io( CPU_TBIn_io ),				//
	.CPU_TCIn_io( CPU_TCIn_io ),
	.CPU_TEAn_io( CPU_TEAn_io ),
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
	.LOCAL_MEM_FLASH_CSn_o( FLASH_CSn ),
	.LOCAL_MEM_FLASH_OEn_o( FLASH_OEn ),
	.LOCAL_MEM_FLASH_WEn_o( FLASH_WEn ),
	.LOCAL_MEM_SRAM_BEn_o( SRAM_BEn ),
	.LOCAL_MEM_SRAM_CSn_o( SRAM_CSn ),
	.LOCAL_MEM_SRAM_OEn_o( SRAM_OEn ),
	.LOCAL_MEM_SRAM_WEn_o( SRAM_WEn ),
// Slave Interface
// Internal Clock Signals 
    .iBUS_1xClk_o( iBUS_1xClk ),    //33Mhz
    .iBUS_2xClk_o( iBUS_2xClk ),    //66Mhz
	.iBUS_A_o( iBUS_A ),
	.iBUS_D_Write8_o( iBUS_D_Write8  ),
	.iBUS_D_Write16_o( iBUS_D_Write16 ),
	.iBUS_D_Write32_o( iBUS_D_Write32 ),
	.iBUS_D_Out_virgin_o( iBUS_D_Out_virgin ), 
	.iBUS_D_Siz_o( iBUS_D_Siz ), 
	.iBUS_RWn_o( iBUS_RWn ),
	.iBUS_BE_o( iBUS_BE ),
	.iBUS_WE_o( iBUS_WE ), 
	.iBUS_A_Valid_o( iBUS_A_Valid ) ,
// Devices 32bits Databus
	.iBUS_D_GAVIN_i( iBUS_D_GAVIN ),
	.iBUS_D_BEATRIX_i( iBUS_D_BEATRIX ),
	.iBUS_D_VICKY_i( iBUS_D_VICKY ),
	.iBUS_D_MERA_i( iBUS_D_MERA ),
	.iBUS_D_VRAM_A_i( iBUS_D_VRAM_A ),
	.iBUS_D_VRAM_B_i( iBUS_D_VRAM_B ),
// Devices Chipselect
	.iBUS_CS_GAVIN_o( iBUS_CS_GAVIN ),
	.iBUS_CS_BEATRIX_o( iBUS_CS_BEATRIX ),
	.iBUS_CS_VICKY_A_o( iBUS_CS_VICKY_A ),
	.iBUS_CS_VICKY_MEM_A_o( iBUS_CS_VICKY_MEM_A ),
	.iBUS_CS_VICKY_B_o( iBUS_CS_VICKY_B ),
	.iBUS_CS_VICKY_MEM_B_o( iBUS_CS_VICKY_MEM_B ),
	.iBUS_CS_VRAM_A_o( iBUS_CS_VRAM_A ),
	.iBUS_CS_VRAM_B_o( iBUS_CS_VRAM_B ),
	.iBUS_CS_MERA_o( iBUS_CS_MERA ), 
	// Interrupt 
	.iIRQ_Interrupt_i( iIRQ_Interrupt ),
	.iIRQ_Vector_i( iIRQ_Vector ),
	.iIRQ_AutoVector_i( iIRQ_AutoVector ),
	.iIRQ_GetVector_o( iIRQ_GetVector ), 
// Debug Interface
	.Dbg_Mode_On_i( Dbg_Mode_On ),
	.Dbg_Address_Out_i( Dbg_Address_Out ),
	.Dbg_Data_Out_i( Dbg_Data_Out ),
	.Dbg_Data_In_o( Dbg_Data_In ),
	.Dbg_BEn_i( Dbg_BEn_Out ),
	.Dbg_RWn_Out_i( Dbg_RWn_Out ),
	.Dbg_RAM_CS_i( Dbg_RAM_CS ),
	.Dbg_FLASH_CS_i( Dbg_FLASH_CS ),
	.Dbg_FLASH_WR_i( Dbg_FLASH_WR ),
	.Dbg_FLASH_OE_i( Dbg_FLASH_OE ),
	.Dbg_OE_i( Dbg_OE ),
	.Dbg_RSTn_i( Dbg_RSTn ),
	.TSF_FLASH2RAM_o(),
// Wait-State Section
	.Wait_Unity_TA_i( Wait_Unity_TA ),
	.Wait_LPC_TA_i( Wait_LPC_TA ),
	.Wait_RTC_TA_i( Wait_RTC_TA ),
	// NEW
	.Wait_BufferA_i( Wait_BufferA ),
	.Wait_BufferB_i( Wait_BufferB ),
	.Wait_BufferA_TA_i( Wait_BufferA_TA ),
	.Wait_BufferB_TA_i( Wait_BufferB_TA ),	
	//
	.Wait_MERA_TA_i( Wait_MERA_TA ), 
	//
	.CS_Unity_i( CS_Unity ),
	.CS_LPC_i( CS_LPC ),
	.CS_RTC_i( CS_RTC ),
// Signal for Sharing the CPU BUS Mastership
   .Channel_Select_o( Channel_Select ),
// SDMA & MemText Interface
    .Ext_RAM_OEn_i( Ext_RAM_OEn ),
    .Ext_RAM_WEn_i( Ext_RAM_WEn ),
    .Ext_RAM_BEn_i( Ext_RAM_BEn ),
    .Ext_RAM_Addy_i( Ext_RAM_Addy ),
    .Ext_RAM_Data_i( Ext_RAM_Data_Out ),
    .Ext_RAM_Data_o( Ext_RAM_Data_In ),

    .iBUS_MTXT_BRn_i( iBUS_MTXT_BRn ),
    .iBUS_MTXT_BGn_o( iBUS_MTXT_BGn ),
    .iBUS_SDMA_BRn_i( iBUS_SDMA_BRn ),
    .iBUS_SDMA_BGn_o( iBUS_SDMA_BGn ),
    .iBUS_VDMA_BRn_i( iBUS_VDMA_BRn ),
    .iBUS_VDMA_BGn_o( iBUS_VDMA_BGn ),
    .iBUS_DEBUG_BRn_i( iBUS_DEBUG_BRn ),
    .iBUS_DEBUG_BGn_o( iBUS_DEBUG_BGn )
);


MERA_A2560X_Top MERA_THE_BEAUTIFUL(
	.Reset_i( System_Clk133_RST ),
	.CPU_1xClk_i( iBUS_1xClk ),		// 33Mhz
	.SYS_2xClk_i( iBUS_2xClk ),		// 66Mhz
	.SYS_4xClk_i( Clock133Mhz ),		// 133Mhz
	.CPU_TIPn_i( CPU_TIPn_i ),			// Transaction in Progress	

	.iBUS_A_i( iBUS_A ),
	.iBUS_A_Valid_i( iBUS_A_Valid ),		// = !TS - So when it comes to 1 the Address is Valid 
	.iBUS_D8_i( iBUS_D_Write8 ),
	.iBUS_D16_i( iBUS_D_Write16 ),
	.iBUS_D32_i( iBUS_D_Write32 ),
	.iBUS_D_Out_virgin_i( iBUS_D_Out_virgin ), 	
	.iBUS_D_Siz_i( iBUS_D_Siz ),
	.iBUS_D_Valid_o( iBUS_D_Valid_MERA ),
	.iBUS_RWn_i( iBUS_RWn ),
	.iBUS_BE_i( iBUS_BE ),
	.iBUS_WE_i( iBUS_WE ),
	.iBUS_D_MERA_o( iBUS_D_MERA ),
	.iBUS_CS_MERA_i( iBUS_CS_MERA ),
	.Wait_MERA_TA_o( Wait_MERA_TA ),	

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

GAVIN_A2560KEmuTOS_Top GABE_TOP_LEVEL (
// Reset
	.Reset_i( !Master_Resetn ),
	.Cold_Reset_i( !COLD_RESETn_In ), 	
	.Manual_RESET_o( Manual_RESET ),	
// Clocks	
	.iBUS_1xClk_i( iBUS_1xClk ),
   .iBUS_2xClk_i( iBUS_2xClk ),
	.Clk14_318Mhz_i( OSC_CLK_14_318Mhz_i ),
	.LPC_Clk33_333Mhz_i( OSC_CLK_33_333Mhz_i ),
	.Clk40_000Mhz_i( OSC_CLK_40_000Mhz_A_i ),
// Buses
// Buses
// CPU Block Buses
	.iBUS_A_i( iBUS_A ),
	.iBUS_A_Valid_i( iBUS_A_Valid ),
	.iBUS_D8_i( iBUS_D_Write8  ),
	.iBUS_D16_i( iBUS_D_Write16 ),
	.iBUS_D32_i( iBUS_D_Write32 ),
	.iBUS_D_Valid_o( iBUS_D_Valid_GABE ), 	// This is to extend DTACK
	.iBUS_RWn_i( iBUS_RWn ),
	.iBUS_BE_i( iBUS_BE ),
	.iBUS_WE_i( iBUS_WE ),
	.iBUS_D_Siz_i( iBUS_D_Siz ),	
	.iBUS_D_GAVIN_o( iBUS_D_GAVIN ),
	.iBUS_CS_GAVIN_i( iBUS_CS_GAVIN ),
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
// COMMON SIGNALS for the LOCAL BUS
	.IO_A_o( IO_A_o ),
	.IO_D_io( IO_D_io ),
	.IO_RDn_o( IO_RDn_o ),
	.IO_WRn_o( IO_WRn_o ),
// NIC
	.ETH_CSn_o( ETH_CSn_o ),
	.ETH_FIFO_SEL_o( ETH_FIFO_SEL_o ),
	.ETH_IRQn_i( ETH_IRQn_i ),
	.ETH_RSTn_o( ETH_RSTn_o ),
// IDE
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
// MAU - Keyboard
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
// DIP Switch
	.DIP_BOOT_MODE_i( DIP_BOOT_MODE_i ),
	.DIP_USER_i( DIP_USER_i ),
	.CPU_SPEED_i( CPU_SPEED_i ),
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
	// Interrupt 
	.iIRQ_Interrupt_o( iIRQ_Interrupt ),
	.iIRQ_Vector_o( iIRQ_Vector ),
	.iIRQ_AutoVector_o( iIRQ_AutoVector ),
	.iIRQ_GetVector_i( iIRQ_GetVector ),
// Wait-State Section
	.Wait_Unity_TA_o( Wait_Unity_TA ),
	.Wait_LPC_TA_o( Wait_LPC_TA ),
	.Wait_RTC_TA_o( Wait_RTC_TA ), 

	.CS_Unity_o( CS_Unity ),
	.CS_LPC_o( CS_LPC ),
	.CS_RTC_o( CS_RTC ),
////////////////////////////////////////////
// SDMA & MEMText System
////////////////////////////////////////////
// Channel Select for the device to be able to access the SRAM (Memtext/SDMA/VDMA)
	// SRAM Interface Signals
   	.Channel_Select_i( Channel_Select ),
   	.Ext_RAM_OEn_o( Ext_RAM_OEn ),
   	.Ext_RAM_WEn_o( Ext_RAM_WEn ),
   	.Ext_RAM_BEn_o( Ext_RAM_BEn ),
   	.Ext_RAM_Addy_o( Ext_RAM_Addy ),
   	.Ext_RAM_Data_o( Ext_RAM_Data_Out ),
   	.Ext_RAM_Data_i( Ext_RAM_Data_In ),
	// Arbiter Signals
   	.iBUS_MTXT_BRn_o( iBUS_MTXT_BRn ),
   	.iBUS_MTXT_BGn_i( iBUS_MTXT_BGn ),
   	.iBUS_SDMA_BRn_o( iBUS_SDMA_BRn ),
   	.iBUS_SDMA_BGn_i( iBUS_SDMA_BGn ),
   	.iBUS_VDMA_BRn_o( iBUS_VDMA_BRn ),
   	.iBUS_VDMA_BGn_i( iBUS_VDMA_BGn ),
   	.iBUS_DEBUG_BRn_i( iBUS_DEBUG_BRn ),
   	.iBUS_DEBUG_BGn_i( iBUS_DEBUG_BGn )
);

//ReSync 4 Beatrix
reg [31:0] 		iBUS_A_Buff;
reg 	  		iBUS_A_Valid_Buff;
reg [31:0] 		iBUS_D32_Buff;
reg [15:0] 		iBUS_D16_Buff;
reg [7:0]  		iBUS_D8_Buff;
reg 	  		iBUS_RWn_Buff;
reg [3:0]		iBUS_BE_Buff;
reg	  			iBUS_WE_Buff;
reg [1:0] 		iBUS_D_Siz_Buff;
reg 	  		iBUS_CS_BEATRIX_Buff;

// Re-Registers all the input CPU Bus Signals to give the fan-out a chance.
always @ ( posedge iBUS_1xClk ) begin
	iBUS_CS_BEATRIX_Buff <= iBUS_CS_BEATRIX;
	iBUS_D_Siz_Buff 		<= iBUS_D_Siz;
	iBUS_WE_Buff 			<= iBUS_WE;
	iBUS_BE_Buff 			<= iBUS_BE;
	iBUS_RWn_Buff 			<= iBUS_RWn;
	iBUS_D8_Buff 			<= iBUS_D_Write8;
	iBUS_D16_Buff 			<= iBUS_D_Write16;
	iBUS_D32_Buff 			<= iBUS_D_Write32;
	iBUS_A_Buff 			<= iBUS_A;
	iBUS_A_Valid_Buff 	<= iBUS_A_Valid;
end

BEATRIX_TOP BEATRIX_TOP_LEVEL(
// Reset
	.Reset_i( !Master_Resetn ),
// Clocks Input
	.CPU_Clk_i( iBUS_1xClk ),
	.Clk14_318Mhz_i( OSC_CLK_14_318Mhz_i ),
	.Clk22_579Mhz_i( OSC_CLK_22_579Mhz_i ),
	.Clk24_576Mhz_i( OSC_CLK_24_576Mhz_i ),
	.Clk3_58Mhz_i( Clk3_58Mhz[1] ), 
	.Clk80_000Mhz_i( OSC_CLK_80_000Mhz_i ),  
// Clocks Output
	.SID_CLK_o( SID_CLK_o ),
// CPU Block Buses
	.iBUS_A_i( iBUS_A_Buff ),
	.iBUS_A_Valid_i( iBUS_A_Valid_Buff ),
	.iBUS_D8_i( iBUS_D8_Buff  ),
	.iBUS_D16_i( iBUS_D16_Buff ),
	.iBUS_D32_i( iBUS_D32_Buff ),
	.iBUS_D_Valid_o( iBUS_D_Valid_BEATRIX ), 
	.iBUS_RWn_i( iBUS_RWn_Buff ),
	.iBUS_BE_i( iBUS_BE_Buff ),	
	.iBUS_WE_i( iBUS_WE_Buff ),		
	.iBUS_D_Siz_i( iBUS_D_Siz_Buff ),	
	.iBUS_D_BEATRIX_o( iBUS_D_BEATRIX ),
	.iBUS_CS_BEATRIX_i( iBUS_CS_BEATRIX_Buff ),	

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

	.ABUS_SID_CLK_o( ABUS_SID_CLK_o ),
	.ABUS_SID_IN_o( ABUS_SID_IN_o ),
	.ABUS_SID_LATCH_o( ABUS_SID_LATCH_o ),
// DACs
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

VICKYIII_NEW_TOP VICKYIII_TOP_LEVEL(
// Reset
	.Reset_i( !Master_Resetn ),
// Clocks
	.iBUS_1xClk_i( iBUS_1xClk ),		// 25Mhz or 33Mhz
    .iBUS_2xClk_i( iBUS_2xClk ),		// 50Mhz or 66Mhz
	.iBUS_4xClk_i( Clock133Mhz ),		// 100Mhz or 133Mhz
	.Clk14_318Mhz_i( OSC_CLK_14_318Mhz_i ),
	.Clk24_576Mhz_i( OSC_CLK_24_576Mhz_i ), // for I2C 
// Clock for Channel A
	.Clk40_000Mhz_A_i( OSC_CLK_40_000Mhz_A_i ),
	.Clk65_000Mhz_A_i( OSC_CLK_65_000Mhz_i ),	
// Clock for Channel B
	.Clk108Mhz_B_i( Video108Mhz ),
	.Clk108Mhz_Locked_B_i( Video108Mhz_Locked ),
   
// VICKY Core Frequency
	.Clk100M_A_i( Clk099_A ),
	.Clk200M_A_i( VEng_A_Clk199Mhz ),	
	.Clk100M_B_i( Clk099_B ),
	.Clk200M_B_i( VEng_B_Clk199Mhz ),	
// Buses
	.iBUS_A_i( iBUS_A ),
	.iBUS_A_Valid_i( iBUS_A_Valid ),
	.iBUS_D8_i( iBUS_D_Write8  ),
	.iBUS_D16_i( iBUS_D_Write16 ),
	.iBUS_D32_i( iBUS_D_Write32 ),
	.iBUS_D_Siz_i( iBUS_D_Siz ),	
	.iBUS_D_Valid_o( iBUS_D_Valid_VICKY ), 
	.iBUS_RWn_i( iBUS_RWn ),
	.iBUS_BE_i( iBUS_BE ),	
	.iBUS_WE_i( iBUS_WE ),	
	.iBUS_D_VICKY_o( iBUS_D_VICKY ),
	.iBUS_CS_VICKY_A_i( iBUS_CS_VICKY_A ),
	.iBUS_CS_VICKY_MEM_A_i( iBUS_CS_VICKY_MEM_A ),
	.iBUS_CS_VICKY_B_i( iBUS_CS_VICKY_B ),
	.iBUS_CS_VICKY_MEM_B_i( iBUS_CS_VICKY_MEM_B ),
// VSRAM BUFFERS	
	.iBUS_CS_VRAM_A_i( iBUS_CS_VRAM_A ),
	.iBUS_CS_VRAM_B_i( iBUS_CS_VRAM_B ),
	.iBUS_D_VRAM_A_o( iBUS_D_VRAM_A ),	
	.iBUS_D_VRAM_B_o( iBUS_D_VRAM_B ),
// Memory management
	.Wait_BufferA_o( Wait_BufferA ),
	.Wait_BufferB_o( Wait_BufferB ),
	.Wait_BufferA_TA_o( Wait_BufferA_TA ),
	.Wait_BufferB_TA_o( Wait_BufferB_TA ),		
// Video
	.VID_SPC_io( VID_SPC_io ),		// IO
	.VID_SPD_io( VID_SPD_io ),		// IO
// Channel A
// Video DAC Output A
	.VID_A_RSTn_o( VID_A_RSTn_o ),
	.VID_A_CLK_P_o( VID_A_CLK_P_o ),
	.VID_A_HSYNC_o( VID_A_HSYNC_o ),
	.VID_A_VSYNC_o( VID_A_VSYNC_o ),
	.VID_A_DE_o( VID_A_DE_o ),	
	.VID_A_PIX_o( VID_A_PIX_o ),
// Video RAM Bank A
	.VRAM_A_DQ_io( VRAM_A_DQ_io ),
	.VRAM_A_BEn_o( VRAM_A_BEn_o ),
	.VRAM_A_Addy_o( VRAM_A_Addy_o ),
	.VRAM_A_OEn_o( VRAM_A_OEn_o ),
	.VRAM_A_WEn_o( VRAM_A_WEn_o ),
/// Channel B
// Video RAM Bank B
	.VRAM_B_DQ_io( VRAM_B_DQ_io ),
	.VRAM_B_BEn_o( VRAM_B_BEn_o ),
	.VRAM_B_Addy_o( VRAM_B_Addy_o ),
	.VRAM_B_OEn_o( VRAM_B_OEn_o ),
	.VRAM_B_WEn_o( VRAM_B_WEn_o ),
// Video DAC Output B
	.VID_B_RSTn_o( VID_B_RSTn_o ),
	.VID_B_CLK_P_o( VID_B_CLK_P_o ),
	.VID_B_HSYNC_o( VID_B_HSYNC_o ),
	.VID_B_VSYNC_o( VID_B_VSYNC_o ),
	.VID_B_DE_o( VID_B_DE_o ),	
	.VID_B_PIX_o( VID_B_PIX_o ),
	
	.SOF_Channel_A_o( SOF_Channel_A ),
	.SOF_Channel_B_o( SOF_Channel_B ),
	
	.VKY_III_Channel_A_IRQ_o( VKY_III_Channel_A_IRQ ),
	.VKY_III_Channel_B_IRQ_o( VKY_III_Channel_B_IRQ ),

	.DP_HIRES_i( DIP_HIRES_MODE_i ),
	.DP_GAMMA_i( DIP_GAMMA_MODE_i ),
	.BANK_SWITCH_i( CPU_SPEED_i )
);

New_DebugModuleExtra GavinDebug(
	.Serial_Clk_i( Clk24Mhz ),
	.Serial_Rst_i( !PLL_SDcard_Locked ),
	.System_Rst_i( !Master_Resetn ),
	// Debug Interface
	.Dbg_Clk_i( iBUS_1xClk  ),
	.Dbg_Mode_o( Dbg_Mode_On ),	// Indicate when the Debug Mode has taken over
	.Dbg_A_o( Dbg_Address_Out ),
	.Dbg_D_o( Dbg_Data_Out ),
	.Dbg_D_i( Dbg_Data_In ),		// This is the Databus from SystemBUS (mem, chipset, etc...)
	.Dbg_BEn_o( Dbg_BEn_Out  ),
	.Dbg_CPU_RSTn_o( Dbg_RSTn ),	// 0 = Reset, 1 = Normal
	.Dbg_RAM_CS_o( Dbg_RAM_CS ),
	.Dbg_RW_o( Dbg_RWn_Out ),	
	.Dbg_Oe_o( Dbg_OE ),

	.Dbg_Flash_CS_o( Dbg_FLASH_CS ),
	.Dbg_Flash_WRn_o( Dbg_FLASH_WR ),
	.Dbg_Flash_OEn_o( Dbg_FLASH_OE ), 
	
	// RS-232 Interface
	.Rs_RX_i(DBG_RX_i),
	.Rs_TX_o(DBG_TX_o),

   .iBUS_DEBUG_BRn_o( iBUS_DEBUG_BRn ),
   .iBUS_DEBUG_BGn_i( iBUS_DEBUG_BGn )	
	// Debug Output of the Debug Interface
	//.DebugDebug_o( DebugDebugTrig )
);

endmodule

