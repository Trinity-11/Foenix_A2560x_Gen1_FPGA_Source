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

// 33Mhz Version
// EMUTOS Special
module A2560X60Plus_Top
(
// {ALTERA_ARGS_BEGIN} DO NOT REMOVE THIS LINE!
inout		wire		[31:0]		CPU_A_io,	// IO
inout		wire		[31:0]		CPU_D_io,	// IO D[31:0]

output		wire					MEM_A2_o,
output		wire					MEM_A3_o,

//Bus Control Signals
input   	wire                CPU_BBn_io,
output  	wire                CPU_BGn_o,
output  	wire                CPU_BGRn_o,
input   	wire                CPU_BRn_i,
// 68060 Signals that are not used
input		wire				CPU_LOCKn_i,			// Output From the CPU - NOT USED
input		wire				CPU_LOCKEn_i,			// Output From the CPU - NOT USED
output 		wire				CPU_TRAn_o,				// CPU Inputs that has a Pull-UP on board - NOT USED
output 		wire				CPU_SNOOPn_o,			// CPU Inputs that has a Pull-UP on board - NOT USED
output 		wire				CPU_CLAn_o,				// CPU Inputs that has a Pull-UP on board - NOT USED
input 		wire				CPU_SASn_i,				// Output From the CPU - NOT USED
// TA Group
output  	wire                CPU_TAn_o,
inout   	wire                CPU_TSn_io,
output  	wire                CPU_TBIn_o,
output  	wire                CPU_TCIn_o,
output  	wire                CPU_TEAn_o,
input   	wire                CPU_TIPn_i,
// Control & Status Signals
input 		wire                CPU_MIn_i,      // For MC68040
input 		wire    [3:0]       CPU_BSn_i,
input 		wire    [1:0]       CPU_SIZ_i,
input 		wire    [1:0]       CPU_TLN_i,
input 		wire    [2:0]       CPU_TM_i,
input 		wire				CPU_TT0_i,
inout 		wire				CPU_TT1_io,
input 		wire    [1:0]       CPU_UPA_i,
inout 		wire				CPU_BTTn_io,
output		wire				CPU_BCLK_o,
output		wire				CPU_CLKEN_o,
output		wire				CPU_CDISn_o,
output		wire				CPU_MDISn_o,
input		wire				CPU_CIOUTn_i,
// Interrupts
output  	wire				CPU_AVECn_o,
input   	wire				CPU_IPENDn_i,
output  	wire    [2:0]       CPU_IPL_o,
input   	wire    [4:0]       CPU_PST_i,
input   	wire				CPU_RWn_i,
output  	wire				CPU_RESET_INn_o,
input   	wire				CPU_RESET_OUTn_i,
// MC68040 signals
output		wire				CPU_LFOn_o,
input		wire				CPU_LOC_i,
input		wire				CPU_SCDn_i,
// Local Memory (SRAM/FLASH) Control Signals
output		wire				LOCAL_MEM_FLASH_CS0n_o,
output		wire				LOCAL_MEM_FLASH_CS1n_o,
output		wire				LOCAL_MEM_FLASH_OEn_o,
output		wire				LOCAL_MEM_FLASH_WEn_o,
output		wire	[3:0]		LOCAL_MEM_SRAM_BEn_o,
output		wire				LOCAL_MEM_SRAM_CS0n_o,
output		wire				LOCAL_MEM_SRAM_CS1n_o,
output		wire				LOCAL_MEM_SRAM_OEn_o,
output		wire				LOCAL_MEM_SRAM_WEn_o,
// Audio Bus Control Signals
output		wire				ABUS_CTRL_CLK_o,
output		wire				ABUS_CTRL_IN_o,
output		wire				ABUS_CTRL_LATCH_o,
output		wire				ABUS_DATA_CLK_o,
output		wire				ABUS_DATA_IN0_o,
output		wire				ABUS_DATA_IN1_o,
output		wire				ABUS_DATA_LATCH_o,
output		wire				ABUS_SID_CLK_o,
output		wire				ABUS_SID_IN_o,
output		wire				ABUS_SID_LATCH_o,
output		wire				ABUS_RSTn_o,
output		wire				AUD_PDn_o,
output		wire				AUD2_BICK_o,
output		wire				AUD2_LRCK_o,
output		wire				AUD2_MCLK_o,
output		wire				AUD2_SDTI_o,
output		wire				AUD3_BICK_o,
output		wire				AUD3_LRCK_o,
output		wire				AUD3_MCLK_o,
output		wire				AUD3_SDTI_o,
output		wire				Audio_Mute_o,
output		wire				Audio_Standby_o,
output		wire				BTX_BUZZER_o,

output		wire				SID_CLK_o,
// CODEC
input		wire				CODEC_ADC_BCLK_i,
input		wire				CODEC_ADC_DAT_i,
input		wire				CODEC_ADC_LRCK_i,
output		wire				CODEC_ADC_MCLK_o,

output		wire				CODEC_DAC_BCLK_o,
output		wire				CODEC_DAC_DAT_o,
output		wire				CODEC_DAC_LRCK_o,
output		wire				CODEC_DAC_MCLK_o,
output		wire				CODEC_DI_o,
output		wire				CODEC_CE_o,
output		wire				CODEC_CL_o,
// X32 Dip Swiches
input		wire				GAMMA_MODE_A_i,			// ** NEW Signals
input		wire				GAMMA_MODE_B_i,			// ** NEW Signals
input		wire				HI_RES_MODE_A_i,		// ** NEW Signals
input		wire				HI_RES_MODE_B_i,		// ** NEW Signals
// Misc System Control
output		wire				INT_POWER_LED_o,		// On/Off (board LED)
output		wire				POWER_RGB_LED_o,
output		wire				SDCARD_LED_o,			// On/Off (board LED)
output		wire				SDCARD_RGB_o,			// RGB Status LED

inout		wire				COLD_RESETn_io,
input		wire				CPLD_COLD_RSTn_i,
input		wire				SDCARD_RESET_i,
// Oscillator Input
input		wire				OSC_CLK_14_318Mhz_i,
input		wire				OSC_CLK_22_579Mhz_i,
input		wire				OSC_CLK_24_576Mhz_i,
input		wire				OSC_CLK_25_175Mhz_i, 
input		wire				OSC_CLK_33_333Mhz_i,
input		wire				OSC_CLK_33_333Mhz_B_i,
input		wire				OSC_CLK_33_333Mhz_C_i,
input		wire				OSC_CLK_40_000Mhz_A_i,
input		wire				OSC_CLK_40_000Mhz_B_i,
input		wire				OSC_CLK_65_000Mhz_i,
input		wire				OSC_CLK_80_000Mhz_i,
input		wire				OSC_CLK_80_000Mhz_A_i,		// *** NEW NAMING
// Debug Interface
input		wire				DBG_RX_i,
output		wire				DBG_TX_o,
// SDCard Controller
input		wire				F_SD_CD_i,
output		wire				F_SD_CLK_o,			// CLK
output		wire				F_SD_CMD_o,			// MOSI
input		wire				F_SD_DAT0_io,		// MISO
input		wire				F_SD_DAT1_io,		// IO
input		wire				F_SD_DAT2_io,		// IO
output		wire				F_SD_DAT3_io,		// IO (CS)
input		wire				F_SD_WP_i,
// IO Bus
output		wire	[7:0]		IO_A_o,
inout		   wire	[15:0]		IO_D_io,
output		wire				IO_RDn_o,
output		wire				IO_WRn_o,

output		wire				ETH_CSn_o,
output		wire				ETH_FIFO_SEL_o,

output		wire				IDE_CS0n_o,
output		wire				IDE_CS1n_o,
output		wire				IDE_DATA_DIR_o,
output		wire				IDE_DATA_OEn_o,
input		wire				IDE_IORDY_i,
output		wire				RTC_CSn_o,
output		wire				TRINITY_CSn_o,
output		wire				TRINITY_CPU_CLK_o,
// Interrupt
input		wire				IDE_INTRQ_i,
input		wire				ETH_IRQn_i,
input		wire				TRINITY_IRQn_i,
//put		wire				OPL3_INTn_i,
//input		wire				OPM_INTn_i,
//input		wire				OPN2_INTn_i,
input		wire				RTC_INTn_i,
//LPC Interface
output		wire				LPC_CLK_32Khz_o,
inout		wire				LPC_IRQn_io,		// BiDir
input		wire				LPC_LDRQn_i,
inout		wire	[3:0]		LPC_LAD_io,			// BiDir
output		wire				LPC_LFRAMEn_o,
output		wire				LPC_RESETn_o,
// System RAM
inout		wire	[31:0]		SYSRAM_DQ_io,
output		wire	[3:0]		SYSRAM_DQM_o,
output		wire	[12:0]		SYSRAM_A_o,
output		wire				SYSRAM_BA0_o,
output		wire				SYSRAM_BA1_o,
output		wire				SYSRAM_CASn_o,
output		wire				SYSRAM_RASn_o,
output		wire				SYSRAM_WEn_o,
output		wire				SYSRAM_CS0n_o,
output		wire				SYSRAM_CKE_o,
output		wire				SYSRAM_CLK_o,
// Video
inout		wire				VID_SPC_io,		// IO
inout		wire				VID_SPD_io,		// IO
// Video DAC Output A
output		wire				VID_A_CLK_P_o,
output		wire				VID_A_DE_o,
input		wire				VID_A_HP_INT1n_i,
output		wire				VID_A_HSYNC_o,
output		wire				VID_A_VSYNC_o,
output		wire	[11:0]		VID_A_PIX_o,
// Video DAC Output B
output		wire				VID_B_CLK_P_o,
output		wire				VID_B_DE_o,
input		wire				VID_B_HP_INT1n_i,
output		wire				VID_B_HSYNC_o,
output		wire				VID_B_VSYNC_o,
output		wire	[11:0]		VID_B_PIX_o,
// Video RAM Bank A
inout		wire	[31:0]		VRAM_A_DQ_io,
output		wire	[3:0]		VRAM_A_BEn_o,
output		wire	[19:0]		VRAM_A_Addy_o,
output		wire				VRAM_A_OEn_o,
output		wire				VRAM_A_WEn_o,
// Video RAM Bank B
inout		wire	[31:0]		VRAM_B_DQ_io,
output		wire	[3:0]		VRAM_B_BEn_o,	
output		wire	[19:0]		VRAM_B_Addy_o,
output		wire				VRAM_B_OEn_o,
output		wire				VRAM_B_WEn_o,

// 65C816
inout		wire	[23:0]		BUS_A_io,
inout		wire	[7:0]		BUS_D_io,
output		wire				CS_FLASH0n_o,
output		wire				CS_FLASH1n_o,
output		wire				CS_RAM0n_o,
output		wire				CS_RAM1n_o,
output		wire				CS_RAM2n_o,
output		wire				CS_RAM3n_o,
output		wire				C816_ABORTn_o,
output		wire				C816_BE_o,
output		wire				C816_CLK_o,
input		wire				C816_E_i,
input		wire				C816_IRQn_oc,
input		wire				C816_MLn_i,
input		wire				C816_MX_i,
input		wire				C816_NMIn_oc,
input		wire				C816_RWn_i,
output		wire				C816_RSTn_o,
inout		wire				C816_RDY_io,
input		wire				BUS_VPn_i,
input		wire				BUS_VDA_i,
input		wire				BUS_VPA_i,
output		wire				BUS_RWn_o,
output		wire				OEn_o,
output		wire				WR_FLASHn_o,
output		wire				CPU_A_LATCH_o,
output		wire				CPU_A_OEn_o,
// A2560X+
//WIZFI
input 		wire 				WIZFI_SPI_INTn_i,
output 		wire 				WIZFI_CTSn_o,
output 		wire 				WIZFI_RxD_o,
input 		wire 				WIZFI_TxD_i,
input 		wire 				WIZFI_RTSn_i,

output  	wire   				BEAUTIFICATION_RGB_LED_o,
output  	wire   				INIT_DONE_o
);

assign INIT_DONE_o 		= 1'b1;
assign BEAUTIFICATION_RGB_LED_o = 1'b0;
assign C816_RDY_io 		= 1'bz;
assign WIZFI_CTSn_o 	= WIZFI_RTSn_i;
//assign WIZFI_RxD_o 		= 1'b1;
// Output that are not used:
assign CPU_TRAn_o 		= 1'bz;
assign CPU_SNOOPn_o 	= 1'bz;
assign CPU_CLAn_o 		= 1'bz;
assign CPU_LFOn_o 		= 1'b1;

// CFP95179X8 Side Assignments
assign BUS_A_io = 24'hzzzzzz;
assign BUS_D_io = 8'hzz;
assign CS_FLASH0n_o = 1'b1;
assign CS_FLASH1n_o = 1'b1;
assign CS_RAM0n_o = 1'b1;
assign CS_RAM1n_o = 1'b1;
assign CS_RAM2n_o = 1'b1;
assign CS_RAM3n_o = 1'b1;
assign C816_ABORTn_o = 1'b1;
assign C816_BE_o = 1'b0;
assign C816_CLK_o = 1'b0;
assign C816_RSTn_o = 1'b0;
assign BUS_RWn_o = 1'b1;
assign OEn_o = 1'b1;
assign WR_FLASHn_o = 1'b1;
assign CPU_A_LATCH_o = 1'b0;
assign CPU_A_OEn_o = 1'b1;

// Temporary Assignment
wire 	            iBUS_1xClk;		//	33Mhz
wire  	            iBUS_2xClk;		// 66Mhz
wire                Master_Resetn;
wire 				GLOBAL_RESET_i;
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
wire 	[31:0] 	    Dbg_Address_Out;
wire	[31:0]	    Dbg_Data_Out;
wire	[31:0]	    Dbg_Data_In;
wire				Dbg_RWn_Out;
wire    [3:0]	    Dbg_BEn_Out;
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

wire				GLOBAL_RESETn_i;

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

// New Signals for the A2560X+
wire 				FLASH_CSn;
wire 				FLASH_OEn;
wire 				FLASH_WEn;
wire 	[3:0]		SRAM_BEn;
wire 				SRAM_CSn;
wire 				SRAM_OEn;
wire 				SRAM_WEn;
wire 		        SD_Debug;
wire 		        DebugDebugTrig;

wire 				CS_RTC;
wire 				CS_SDCard;
wire 				CS_Unity;
wire 				CS_LPC;

wire 				Wait_Unity_TA;
wire 				Wait_LPC_TA;
wire		        Wait_RTC_TA;
wire 		        Wait_MERA_TA;
wire 				Wait_BufferA;
wire 				Wait_BufferB;
wire 				Wait_BufferA_TA;
wire 				Wait_BufferB_TA;
wire    [31:0]      iBUS_D_Out_virgin;
// New Signal For CPU Bus Mastering
wire     [1:0]       Channel_Select;
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
wire     [3:0]     	Ext_RAM_BEn;
wire     [31:0]    	Ext_RAM_Addy;
wire     [31:0]    	Ext_RAM_Data_In;
wire     [31:0]    	Ext_RAM_Data_Out;

assign LOCAL_MEM_FLASH_CS0n_o = FLASH_CSn;
assign LOCAL_MEM_FLASH_CS1n_o = FLASH_CSn;
assign LOCAL_MEM_FLASH_OEn_o = 	FLASH_OEn;
assign LOCAL_MEM_FLASH_WEn_o = 	FLASH_WEn;
assign LOCAL_MEM_SRAM_BEn_o = SRAM_BEn;
assign LOCAL_MEM_SRAM_CS0n_o = SRAM_CSn;
assign LOCAL_MEM_SRAM_CS1n_o = SRAM_CSn;
assign LOCAL_MEM_SRAM_OEn_o = SRAM_OEn;
assign LOCAL_MEM_SRAM_WEn_o = SRAM_WEn;

wire Manual_RESET;
wire COLD_RESETn_In;

BIDIR_SIGNAL	RESET_BUFFER (
	.datain ( 1'b0  ),
	.dataio ( COLD_RESETn_io ),
	.dataout ( COLD_RESETn_In ),				// Cold Reset - Active Low
	.oe ( !SDCARD_RESET_i | !CPLD_COLD_RSTn_i | Timer_Reset_once )	//| Manual_RESET
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
// Clock Divide
always @ (posedge OSC_CLK_14_318Mhz_i)
begin
	Clk3_58Mhz <= Clk3_58Mhz + 2'b01;
end

wire 	CPU_Clk66Mhz;
wire 	DRAM_Clk133Mhz;
wire 	VEng_A_Clk199Mhz;
wire 	VEng_B_Clk199Mhz;
wire 	SYS_Clk33Mhz;
wire 	Clock133Mhz;
wire    Video108Mhz;		// New Dot Clock to generate 1280x960 or 1280x1024
wire    Video108Mhz_Locked;

PLL_SDCard_Debug	PLL_SDCard_Debug_inst (
	.inclk0 ( OSC_CLK_80_000Mhz_A_i ),		// Feb 18th_2023	
	.c0 ( Clk24Mhz ),		// Output on the Processor Clock
	.c1( Clock133Mhz ),	
	.c2( VEng_A_Clk199Mhz ),
	.c3( VEng_B_Clk199Mhz ),	
	.locked ( PLL_SDcard_Locked )
	);

PLL_40Mhz_108Mhz	PLL_40Mhz_108Mhz_inst (
	.areset ( !PLL_SDcard_Locked ),
	.inclk0 ( OSC_CLK_40_000Mhz_A_i ),		// Video Clock 40Mhz
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


wire System_Clk133_RST;
wire System_Clk133_RSTn;
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
MC68LC060_Plus_Arbiter MainCPU_Module(
    .Global_Reset_i( !COLD_RESETn_In ),
    .Master_Resetn_o( Master_Resetn ),   // That Reset Comes out after Code is Transfered in RAM ( SRAM <- FLASH )
    .Clk_133Mhz_i( Clock133Mhz ),	// 132Mhz = CPU Speed 33Mhz

// MC68LC060 General A2560X60+ Interface
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
    .iBUS_1xClk_o( iBUS_1xClk ),        //33Mhz
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
    // Interrupts
    .iIRQ_Interrupt_i( iIRQ_Interrupt ),
    .iIRQ_Vector_i( iIRQ_Vector ),
    .iIRQ_AutoVector_i( iIRQ_AutoVector ),
    .iIRQ_GetVector_o( iIRQ_GetVector ),
	
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
    .TSF_FLASH2RAM_o(  ),
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

/*
assign SYSRAM_DQ_io = 32'hzzzz_zzzz;
assign SYSRAM_DQM_o = 4'b0000;
assign SYSRAM_A_o = 13'h0000;
assign SYSRAM_BA0_o = 1'b0;
assign SYSRAM_BA1_o = 1'b0;
assign SYSRAM_CASn_o = 1'b1;
assign SYSRAM_RASn_o = 1'b1;
assign SYSRAM_WEn_o = 1'b1;
assign SYSRAM_CS0n_o = 1'b1;
assign SYSRAM_CKE_o = 1'b1;
assign SYSRAM_CLK_o = 1'b0;
assign Wait_MERA_TA = 1'b0;
assign iBUS_D_MERA = 32'hDEADBEEF;
*/
//assign iBUS_D_Valid_MERA = 1'b0;

GAVIN_A2560XEmuTOS_Top GAVIN_TOP_LEVEL(
// Reset
	.Reset_i( !Master_Resetn ),
// LPC Reset Signals
	.Cold_Reset_i( !COLD_RESETn_In ), 
	.Manual_RESET_o( Manual_RESET ),	
// Clocks	
	.iBUS_1xClk_i( iBUS_1xClk ),
    .iBUS_2xClk_i( iBUS_2xClk ),
	.Clk_Serial_24Mhz_i( Clk24Mhz ),
	.Clk14_318Mhz_i( OSC_CLK_14_318Mhz_i ),
	.LPC_Clk33_333Mhz_i( OSC_CLK_33_333Mhz_i ),
	.Clk40_000Mhz_i( OSC_CLK_40_000Mhz_A_i ),

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
// Interrupts Inputs
	.OPM_INTn_i( 1'b1 ),
	.OPN2_INTn_i( 1'b1 ),
	.OPL3_INTn_i( 1'b1 ), 
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
	.LPC_RSTn_o( LPC_RESETn_o ),
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
// Local BUS
	.IO_A_o( IO_A_o ),
	.IO_D_io( IO_D_io ),
	.IO_RDn_o( IO_RDn_o ),
	.IO_WRn_o( IO_WRn_o ),
	.ETH_CSn_o( ETH_CSn_o ),
	.ETH_FIFO_SEL_o( ETH_FIFO_SEL_o ),
	.ETH_IRQn_i( ETH_IRQn_i ),
	.IDE_CS0n_o( IDE_CS0n_o ),
	.IDE_CS1n_o( IDE_CS1n_o ),
	.IDE_DATA_DIR_o( IDE_DATA_DIR_o ),
	.IDE_DATA_OEn_o( IDE_DATA_OEn_o ),
	.IDE_INTRQ_i( IDE_INTRQ_i ),
	.IDE_IORDY_i( IDE_IORDY_i ),
	.TRINITY_IRQn_i( TRINITY_IRQn_i ),
	.TRINITY_CSn_o( TRINITY_CSn_o ),
	.TRINITY_CPU_CLK_o( TRINITY_CPU_CLK_o ),
	.RTC_CSn_o( RTC_CSn_o ),
	.RTC_INTn_i( RTC_INTn_i ),     
// Misc System Control
	.BLU_POWER_LED_o( INT_POWER_LED_o ),		// On/Off (board LED)
	.RGB_POWER_LED_o( POWER_RGB_LED_o ),		// RGB - Some serializing will be needed to get the RGB we want
	.SDCARD_LED_o( SDCARD_LED_o ),			// On/Off (board LED)
	.SDCARD_RGB_o( SDCARD_RGB_o ), 
	.SOF_Channel_A_i( SOF_Channel_A ),
	.SOF_Channel_B_i( SOF_Channel_B ),
// CPU Interrupts
	.iIRQ_Interrupt_o( iIRQ_Interrupt ),
	.iIRQ_Vector_o( iIRQ_Vector ),
	.iIRQ_AutoVector_o( iIRQ_AutoVector ),
	.iIRQ_GetVector_i( iIRQ_GetVector ),
// Wait-State Section
	//.Wait_SDCard_TA_o( Wait_SDCard_TA ),
	.Wait_Unity_TA_o( Wait_Unity_TA ),
	.Wait_LPC_TA_o( Wait_LPC_TA ),
	.Wait_RTC_TA_o( Wait_RTC_TA ), 
// Chip Selects to Add Delay in the transaction    
	.CS_SDCard_o( CS_SDCard ),
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
   	.iBUS_DEBUG_BGn_i( iBUS_DEBUG_BGn ),

	.WIZFI_SPI_INTn_i( WIZFI_SPI_INTn_i ),
	.WIZFI_RxD_o( WIZFI_RxD_o ),
	.WIZFI_TxD_i( WIZFI_TxD_i  )	
);


reg	 [31:0] 	iBUS_A_Buff;
reg	 		  	iBUS_A_Valid_Buff;
reg	 [31:0] 	iBUS_D32_Buff;
reg	 [15:0] 	iBUS_D16_Buff;
reg	 [7:0]  	iBUS_D8_Buff;
reg	 		  	iBUS_RWn_Buff;
reg	 [3:0] 		iBUS_BE_Buff;
reg			  	iBUS_WE_Buff;
reg	 [1:0] 		iBUS_D_Siz_Buff;
reg	 		  	iBUS_CS_BEATRIX_Buff;

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
	.Clk80_000Mhz_i( OSC_CLK_80_000Mhz_A_i ), 
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
	.AMP_MUTE_o( Audio_Mute_o ),
	.AMP_SDBY_o( Audio_Standby_o ),

	.CHIPTUNE_RSTn_o(  ),
// SID Bus
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
	.iBUS_1xClk_i( iBUS_1xClk ),
    .iBUS_2xClk_i( iBUS_2xClk ),
	.iBUS_4xClk_i( Clock133Mhz ), 	
	.Clk14_318Mhz_i( OSC_CLK_14_318Mhz_i ),
	.Clk24_576Mhz_i( OSC_CLK_24_576Mhz_i ), 	// for I2C 
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
	//.VID_A_RSTn_o(  ),
	//.VID_A_CLK_P_o( VID_B_CLK_P_o ),
	//.VID_A_HSYNC_o( VID_B_HSYNC_o ),
	//.VID_A_VSYNC_o( VID_B_VSYNC_o ),
	//.VID_A_DE_o( VID_B_DE_o ),	
	//.VID_A_PIX_o( VID_B_PIX_o ),
	.VID_A_RSTn_o(  ),
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
	//.VID_B_RSTn_o(  ),
	//.VID_B_CLK_P_o( VID_A_CLK_P_o ),
	//.VID_B_HSYNC_o( VID_A_HSYNC_o ),
	//.VID_B_VSYNC_o( VID_A_VSYNC_o ),
	//.VID_B_DE_o( VID_A_DE_o ),	
	//.VID_B_PIX_o( VID_A_PIX_o ),
	.VID_B_RSTn_o(  ),
	.VID_B_CLK_P_o( VID_B_CLK_P_o ),
	.VID_B_HSYNC_o( VID_B_HSYNC_o ),
	.VID_B_VSYNC_o( VID_B_VSYNC_o ),
	.VID_B_DE_o( VID_B_DE_o ),	
	.VID_B_PIX_o( VID_B_PIX_o ),
	
	.SOF_Channel_A_o( SOF_Channel_A ),
	.SOF_Channel_B_o( SOF_Channel_B ),
	
	.VKY_III_Channel_A_IRQ_o( VKY_III_Channel_A_IRQ ),
	.VKY_III_Channel_B_IRQ_o( VKY_III_Channel_B_IRQ ),

	.DP_HIRES_i( {HI_RES_MODE_B_i, HI_RES_MODE_A_i} ),
	.DP_GAMMA_i( {GAMMA_MODE_B_i, GAMMA_MODE_A_i} ),
	.BANK_SWITCH_i( 1'b0 )
);

New_DebugModuleExtra GavinDebug(
	//.Serial_Clk_i( Clk24_Div_A ),
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

