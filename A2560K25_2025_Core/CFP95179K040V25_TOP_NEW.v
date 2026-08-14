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

module CFP95179K040V25_TOP_NEW
(
// {ALTERA_ARGS_BEGIN} DO NOT REMOVE THIS LINE!

	ABUS_CTRL_CLK_o,
	ABUS_CTRL_IN_o,
	ABUS_CTRL_LATCH_o,
	ABUS_DATA_CLK_o,
	ABUS_DATA_IN0_o,
	ABUS_DATA_IN1_o,
	ABUS_DATA_LATCH_o,
	ABUS_RSTn_o,
	ABUS_SID_CLK_o,
	ABUS_SID_IN_o,
	ABUS_SID_LATCH_o,
	AMP_MUTE_o,
	AMP_SDBY_o,
	AUD2_BICK_o,
	AUD2_LRCK_o,
	AUD2_MCLK_o,
	AUD2_SDTI_o,
	AUD3_BICK_o,
	AUD3_LRCK_o,
	AUD3_MCLK_o,
	AUD3_SDTI_o,
	AUD_PDn_o,
	BLU_POWER_LED_o,
	BTX_BUZZER_o,
	CHIPTUNE_RSTn_o,
	CODEC_ADC_BCLK_i,
	CODEC_ADC_DAT_i,
	CODEC_ADC_LRCK_i,
	CODEC_ADC_MCLK_o,
	CODEC_CE_o,
	CODEC_CL_o,
	CODEC_DAC_BCLK_o,
	CODEC_DAC_DAT_o,
	CODEC_DAC_LRCK_o,
	CODEC_DAC_MCLK_o,
	CODEC_DI_o,
	CONFIG_CSn_o,
	CONFIG_MISO_i,
	CONFIG_MOSI_o,
	CONFIG_SCLK_o,
	CPU_AVECn_o,
	CPU_A_io,
	CPU_BBn_io,
	CPU_BCLK_o,
	CPU_BGn_o,
	CPU_BRn_i,
	CPU_CDISn_o,
	CPU_CIOUTn_i,
	CPU_DLE_o,
	CPU_D_io,
	CPU_IPENDn_i,
	CPU_IPL0n_o,
	CPU_IPL1n_o,
	CPU_IPL2n_o,
	CPU_LFOn_o,
	CPU_LOCKEn_i,
	CPU_LOCKn_i,
	CPU_LOC_i,
	CPU_MDISn_o,
	CPU_MIn_i,
	CPU_PCLK_o,
	CPU_PST0_i,
	CPU_PST1_i,
	CPU_PST2_i,
	CPU_PST3_i,
	CPU_RESET_INn_o,
	CPU_RESET_OUTn_i,
	CPU_RWn_io,
	CPU_SC0_io,
	CPU_SC1_io,
	CPU_SCDn_i,
	CPU_SIZ0_io,
	CPU_SIZ1_io,
	CPU_TAn_io,
	CPU_TBIn_io,
	CPU_TCIn_io,
	CPU_TEAn_io,
	CPU_TIPn_i,
	CPU_TLN0_i,
	CPU_TLN1_i,
	CPU_TM0_i,
	CPU_TM1_i,
	CPU_TM2_i,
	CPU_TSn_io,
	CPU_TT0_io,
	CPU_TT1_io,
	CPU_UPA0_i,
	CPU_UPA1_i,
	DBG_RX_i,
	DBG_TX_o,
	DCSG_CLK_o,
	DCSG_RDY_i,
	DIP_CSn_o,
	ETH_CSn_o,
	ETH_FIFO_SEL_o,
	ETH_IRQn_i,
	ETH_RSTn_o,
	F_SD_CD_i,
	F_SD_CLK_o,
	F_SD_CMD_o,
	F_SD_DAT0_io,
	F_SD_DAT1_io,
	F_SD_DAT2_io,
	F_SD_DAT3_io,
	F_SD_WP_i,
	GLOBAL_RESETn_io,
	IDE_CS0n_o,
	IDE_CS1n_o,
	IDE_DATA_DIR_o,
	IDE_DATA_OEn_o,
	IDE_INTRQ_i,
	IDE_IORDY_i,
	IDE_RESETn_o,
	IO_A_io,
	IO_D_io,
	IO_RDn_o,
	IO_WRn_o,
	JOY0_BTN0_io,
	JOY0_BTN1_io,
	JOY0_BTN2_io,
	JOY0_DWN_io,
	JOY0_LFT_io,
	JOY0_RGHT_io,
	JOY0_UP_io,
	JOY1_BTN0_io,
	JOY1_BTN1_io,
	JOY1_BTN2_io,
	JOY1_DWN_io,
	JOY1_LFT_io,
	JOY1_RGHT_io,
	JOY1_UP_io,
	JOYSTICK0_RLY_o,
	JOYSTICK1_RLY_o,
	KBD_CLK_i,
	KBD_CSn_i,
	KBD_INTn_o,
	KBD_MISO_o,
	KBD_MOSI_i,
	LOCAL_MEM_FLASH_CS0n_o,
	LOCAL_MEM_FLASH_CS1n_o,
	LOCAL_MEM_FLASH_OEn_o,
	LOCAL_MEM_FLASH_RSTn_o,
	LOCAL_MEM_FLASH_WEn_o,
	LOCAL_MEM_FLASH_WPn_o,
	LOCAL_MEM_SRAM_BE0n_o,
	LOCAL_MEM_SRAM_BE1n_o,
	LOCAL_MEM_SRAM_BE2n_o,
	LOCAL_MEM_SRAM_BE3n_o,
	LOCAL_MEM_SRAM_CS0n_o,
	LOCAL_MEM_SRAM_CS1n_o,
	LOCAL_MEM_SRAM_OEn_o,
	LOCAL_MEM_SRAM_WEn_o,
	LPC_CLK_32Khz_o,
	LPC_IRQn_io,
	LPC_LAD_io,
	LPC_LDRQn_i,
	LPC_LFRAMEn_o,
	LPC_RSTn_o,
	LTC6903_A_i,
	LTC6903_B_i,
	MACHINE_ID0_i,
	MACHINE_ID1_i,
	MTX_CLK_o,
	MTX_LATCH_o,
	MTX_SERIAL_IN_o,
	OPL3_CLK_o,
	OPL3_INTn_i,
	OPM_CLK_o,
	OPM_INTn_i,
	OPN2_CLK_o,
	OPN2_INTn_i,
	OSC_CLK_14_318Mhz_i,
	OSC_CLK_22_579Mhz_i,
	OSC_CLK_24_576Mhz_i,
	OSC_CLK_33_333Mhz_i,
	OSC_CLK_40_000Mhz_i,
	RGB_POWER_LED_o,
	RTC_A_o,
	RTC_CSn_o,
	RTC_D_io,
	RTC_INTn_i,
	RTC_OEn_o,
	RTC_RWn_o,
	SDCARD_LED_o,
	SID_CLK_o,
	STS_CLK_o,
	STS_LATCH_o,
	STS_SERIAL_IN_o,
	SYSRAM_A_o,
	SYSRAM_BA0_o,
	SYSRAM_BA1_o,
	SYSRAM_CASn_o,
	SYSRAM_CKE_o,
	SYSRAM_CLK_o,
	SYSRAM_CS0n_o,
	SYSRAM_DQM_o,
	SYSRAM_DQ_io,
	SYSRAM_RASn_o,
	SYSRAM_WEn_o,
	VClock_LTC6903_A_CSn_o,
	VClock_LTC6903_B_CSn_o,
	VClock_LTC6903_DIN_o,
	VClock_LTC6903_SCLK_o,
	VID_A_CLK_P_o,
	VID_A_DE_o,
	VID_A_HP_INT1n_i,
	VID_A_HSYNC_o,
	VID_A_PIX_o,
	VID_A_RSTn_o,
	VID_A_VSYNC_o,
	VID_B_CLK_P_o,
	VID_B_DE_o,
	VID_B_HP_INT1n_i,
	VID_B_HSYNC_o,
	VID_B_PIX_o,
	VID_B_RSTn_o,
	VID_B_VSYNC_o,
	VID_SPC_io,
	VID_SPD_io,
	VRAM_A_Addy_o,
	VRAM_A_BA_o,
	VRAM_A_CASn_o,
	VRAM_A_CKE_o,
	VRAM_A_CLK_o,
	VRAM_A_CSn_o,
	VRAM_A_DQM_o,
	VRAM_A_DQ_io,
	VRAM_A_RASn_o,
	VRAM_A_WEn_o,
	VRAM_B_Addy_o,
	VRAM_B_BA_o,
	VRAM_B_CASn_o,
	VRAM_B_CKE_o,
	VRAM_B_CLK_o,
	VRAM_B_CSn_o,
	VRAM_B_DQM_o,
	VRAM_B_DQ_io,
	VRAM_B_RASn_o,
	VRAM_B_WEn_o,
	altera_reserved_tck,
	altera_reserved_tdi,
	altera_reserved_tdo,
	altera_reserved_tms,
	MEM_A2_o,
	MEM_A3_o,
	DIP_BOOT_MODE0_i,
	DIP_BOOT_MODE1_i,
	DIP_GAMMA_MODEA_i,
	DIP_GAMMA_MODEB_i,
	DIP_HIRES_MODEA_i,
	DIP_HIRES_MODEB_i,
	DIP_USER0_i,
	DIP_USER1_i,
	CPU_SPEED_i,
	OSC_CLK_25_175Mhz_A_i,
	OSC_CLK_25_175Mhz_B_i,
	OSC_CLK_40_000Mhz_A_i,
	OSC_CLK_40_000Mhz_B_i,
	OSC_CLK_65_000Mhz_i,
	VRAM_A_OEn_o,
	VRAM_B_OEn_o,
	VRAM_A_BEn_o,
	VRAM_B_BEn_o
// {ALTERA_ARGS_END} DO NOT REMOVE THIS LINE!

);

// {ALTERA_IO_BEGIN} DO NOT REMOVE THIS LINE!
output			ABUS_CTRL_CLK_o;
output			ABUS_CTRL_IN_o;
output			ABUS_CTRL_LATCH_o;
output			ABUS_DATA_CLK_o;
output			ABUS_DATA_IN0_o;
output			ABUS_DATA_IN1_o;
output			ABUS_DATA_LATCH_o;
output			ABUS_RSTn_o;
output			ABUS_SID_CLK_o;
output			ABUS_SID_IN_o;
output			ABUS_SID_LATCH_o;
output			AMP_MUTE_o;
output			AMP_SDBY_o;
output			AUD2_BICK_o;
output			AUD2_LRCK_o;
output			AUD2_MCLK_o;
output			AUD2_SDTI_o;
output			AUD3_BICK_o;
output			AUD3_LRCK_o;
output			AUD3_MCLK_o;
output			AUD3_SDTI_o;
output			AUD_PDn_o;
output			BLU_POWER_LED_o;
output			BTX_BUZZER_o;
output			CHIPTUNE_RSTn_o;
input			CODEC_ADC_BCLK_i;
input			CODEC_ADC_DAT_i;
input			CODEC_ADC_LRCK_i;
input			CODEC_ADC_MCLK_o;
output			CODEC_CE_o;
output			CODEC_CL_o;
output			CODEC_DAC_BCLK_o;
output			CODEC_DAC_DAT_o;
output			CODEC_DAC_LRCK_o;
output			CODEC_DAC_MCLK_o;
output			CODEC_DI_o;
output			CONFIG_CSn_o;
input			CONFIG_MISO_i;
output			CONFIG_MOSI_o;
output			CONFIG_SCLK_o;
output			CPU_AVECn_o;
inout	[31:0]	CPU_A_io;
input			CPU_BBn_io;
output			CPU_BCLK_o;
output			CPU_BGn_o;
input			CPU_BRn_i;
output			CPU_CDISn_o;
input			CPU_CIOUTn_i;
output			CPU_DLE_o;
inout	[31:0]	CPU_D_io;
input			CPU_IPENDn_i;
output			CPU_IPL0n_o;
output			CPU_IPL1n_o;
output			CPU_IPL2n_o;
output			CPU_LFOn_o;
inout			CPU_LOCKEn_i;
input			CPU_LOCKn_i;
input			CPU_LOC_i;
output			CPU_MDISn_o;
input			CPU_MIn_i;
output			CPU_PCLK_o;
input			CPU_PST0_i;
input			CPU_PST1_i;
input			CPU_PST2_i;
input			CPU_PST3_i;
output			CPU_RESET_INn_o;
input			CPU_RESET_OUTn_i;
inout			CPU_RWn_io;
inout			CPU_SC0_io;
inout			CPU_SC1_io;
input			CPU_SCDn_i;
inout			CPU_SIZ0_io;
inout			CPU_SIZ1_io;
inout			CPU_TAn_io;
inout			CPU_TBIn_io;
inout			CPU_TCIn_io;
inout			CPU_TEAn_io;
input			CPU_TIPn_i;
input			CPU_TLN0_i;
input			CPU_TLN1_i;
input			CPU_TM0_i;
input			CPU_TM1_i;
input			CPU_TM2_i;
inout			CPU_TSn_io;
inout			CPU_TT0_io;
inout			CPU_TT1_io;
input			CPU_UPA0_i;
input			CPU_UPA1_i;
input			DBG_RX_i;
output			DBG_TX_o;
output			DCSG_CLK_o;
input			DCSG_RDY_i;
output			DIP_CSn_o;
output			ETH_CSn_o;
output			ETH_FIFO_SEL_o;
input			ETH_IRQn_i;
output			ETH_RSTn_o;
input			F_SD_CD_i;
output			F_SD_CLK_o;
output			F_SD_CMD_o;
input			F_SD_DAT0_io;
input			F_SD_DAT1_io;
input			F_SD_DAT2_io;
output			F_SD_DAT3_io;
input			F_SD_WP_i;
inout			GLOBAL_RESETn_io;
output			IDE_CS0n_o;
output			IDE_CS1n_o;
output			IDE_DATA_DIR_o;
output			IDE_DATA_OEn_o;
input			IDE_INTRQ_i;
input			IDE_IORDY_i;
output			IDE_RESETn_o;
output	[7:0]	IO_A_io;
inout	[15:0]	IO_D_io;
output			IO_RDn_o;
output			IO_WRn_o;
inout			JOY0_BTN0_io;
inout			JOY0_BTN1_io;
inout			JOY0_BTN2_io;
input			JOY0_DWN_io;
input			JOY0_LFT_io;
input			JOY0_RGHT_io;
input			JOY0_UP_io;
inout			JOY1_BTN0_io;
inout			JOY1_BTN1_io;
inout			JOY1_BTN2_io;
input			JOY1_DWN_io;
input			JOY1_LFT_io;
input			JOY1_RGHT_io;
input			JOY1_UP_io;
output			JOYSTICK0_RLY_o;
output			JOYSTICK1_RLY_o;
input			KBD_CLK_i;
input			KBD_CSn_i;
output			KBD_INTn_o;
output			KBD_MISO_o;
input			KBD_MOSI_i;
output			LOCAL_MEM_FLASH_CS0n_o;
output			LOCAL_MEM_FLASH_CS1n_o;
output			LOCAL_MEM_FLASH_OEn_o;
output			LOCAL_MEM_FLASH_RSTn_o;
output			LOCAL_MEM_FLASH_WEn_o;
output			LOCAL_MEM_FLASH_WPn_o;
output			LOCAL_MEM_SRAM_BE0n_o;
output			LOCAL_MEM_SRAM_BE1n_o;
output			LOCAL_MEM_SRAM_BE2n_o;
output			LOCAL_MEM_SRAM_BE3n_o;
output			LOCAL_MEM_SRAM_CS0n_o;
output			LOCAL_MEM_SRAM_CS1n_o;
output			LOCAL_MEM_SRAM_OEn_o;
output			LOCAL_MEM_SRAM_WEn_o;
output			LPC_CLK_32Khz_o;
inout			LPC_IRQn_io;
inout	[3:0]	LPC_LAD_io;
input			LPC_LDRQn_i;
output			LPC_LFRAMEn_o;
output			LPC_RSTn_o;
input			LTC6903_A_i;
input			LTC6903_B_i;
input			MACHINE_ID0_i;
input			MACHINE_ID1_i;
output			MTX_CLK_o;
output			MTX_LATCH_o;
output			MTX_SERIAL_IN_o;
output			OPL3_CLK_o;
input			OPL3_INTn_i;
output			OPM_CLK_o;
input			OPM_INTn_i;
output			OPN2_CLK_o;
input			OPN2_INTn_i;
input			OSC_CLK_14_318Mhz_i;
input			OSC_CLK_22_579Mhz_i;
input			OSC_CLK_24_576Mhz_i;
input			OSC_CLK_33_333Mhz_i;
input			OSC_CLK_40_000Mhz_i;
output			RGB_POWER_LED_o;
output	[3:0]	RTC_A_o;
output			RTC_CSn_o;
inout	[7:0]	RTC_D_io;
input			RTC_INTn_i;
output			RTC_OEn_o;
output			RTC_RWn_o;
output			SDCARD_LED_o;
output			SID_CLK_o;
output			STS_CLK_o;
output			STS_LATCH_o;
output			STS_SERIAL_IN_o;
output	[12:0]	SYSRAM_A_o;
output			SYSRAM_BA0_o;
output			SYSRAM_BA1_o;
output			SYSRAM_CASn_o;
output			SYSRAM_CKE_o;
output			SYSRAM_CLK_o;
output			SYSRAM_CS0n_o;
output	[3:0]	SYSRAM_DQM_o;
inout	[31:0]	SYSRAM_DQ_io;
output			SYSRAM_RASn_o;
output			SYSRAM_WEn_o;
output			VClock_LTC6903_A_CSn_o;
output			VClock_LTC6903_B_CSn_o;
output			VClock_LTC6903_DIN_o;
output			VClock_LTC6903_SCLK_o;
output			VID_A_CLK_P_o;
output			VID_A_DE_o;
input			VID_A_HP_INT1n_i;
output			VID_A_HSYNC_o;
output	[11:0]	VID_A_PIX_o;
output			VID_A_RSTn_o;
output			VID_A_VSYNC_o;
output			VID_B_CLK_P_o;
output			VID_B_DE_o;
input			VID_B_HP_INT1n_i;
output			VID_B_HSYNC_o;
output	[11:0]	VID_B_PIX_o;
output			VID_B_RSTn_o;
output			VID_B_VSYNC_o;
inout			VID_SPC_io;
inout			VID_SPD_io;
output	[19:0]	VRAM_A_Addy_o;
output	[1:0]	VRAM_A_BA_o;
output			VRAM_A_CASn_o;
output			VRAM_A_CKE_o;
output			VRAM_A_CLK_o;
output			VRAM_A_CSn_o;
output	[3:0]	VRAM_A_DQM_o;
inout	[31:0]	VRAM_A_DQ_io;
output			VRAM_A_RASn_o;
output			VRAM_A_WEn_o;
output	[19:0]	VRAM_B_Addy_o;
output	[1:0]	VRAM_B_BA_o;
output			VRAM_B_CASn_o;
output			VRAM_B_CKE_o;
output			VRAM_B_CLK_o;
output			VRAM_B_CSn_o;
output	[3:0]	VRAM_B_DQM_o;
inout	[31:0]	VRAM_B_DQ_io;
output			VRAM_B_RASn_o;
output			VRAM_B_WEn_o;
input			altera_reserved_tck;
input			altera_reserved_tdi;
output			altera_reserved_tdo;
input			altera_reserved_tms;
input			MEM_A2_o;
input			MEM_A3_o;
input			DIP_BOOT_MODE0_i;
input			DIP_BOOT_MODE1_i;
input			DIP_GAMMA_MODEA_i;
input			DIP_GAMMA_MODEB_i;
input			DIP_HIRES_MODEA_i;
input			DIP_HIRES_MODEB_i;
input			DIP_USER0_i;
input			DIP_USER1_i;
input			CPU_SPEED_i;
input			OSC_CLK_25_175Mhz_A_i;
input			OSC_CLK_25_175Mhz_B_i;
input			OSC_CLK_40_000Mhz_A_i;
input			OSC_CLK_40_000Mhz_B_i;
input			OSC_CLK_65_000Mhz_i;
input			VRAM_A_OEn_o;
input			VRAM_B_OEn_o;
input	[0:3]	VRAM_A_BEn_o;
input	[0:3]	VRAM_B_BEn_o;

// {ALTERA_IO_END} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_BEGIN} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_END} DO NOT REMOVE THIS LINE!
endmodule
