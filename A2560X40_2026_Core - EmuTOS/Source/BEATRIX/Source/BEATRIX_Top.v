module BEATRIX_TOP(

// Reset
input		wire					Reset_i,
// Clocks Input
input		wire					CPU_Clk_i,				// CPU Clock - Could be 16/20/25/33/40/66/75
input		wire					Clk14_318Mhz_i,
input		wire					Clk22_579Mhz_i,
input		wire					Clk24_576Mhz_i,
input		wire					Clk80_000Mhz_i,
// Clocks Output
input		wire					Clk3_58Mhz_i, 
output	wire					SID_CLK_o,
// CPU Block Buses
input		wire		[31:0]	iBUS_A_i,
input		wire					iBUS_A_Valid_i,
//input		wire		[15:0]	iBUS_D_i,

input		wire		[7:0]		iBUS_D8_i,
input		wire		[15:0]	iBUS_D16_i,
input		wire		[31:0]	iBUS_D32_i,
input		wire		[1:0]		iBUS_D_Siz_i,

output	wire					iBUS_D_Valid_o,
input		wire					iBUS_RWn_i,
input		wire		[3:0]		iBUS_BE_i,
input		wire					iBUS_WE_i,
output	wire		[31:0]	iBUS_D_BEATRIX_o,
input		wire					iBUS_CS_BEATRIX_i,

// CODEC
input		wire					CODEC_ADC_BCLK_i,
input		wire					CODEC_ADC_DAT_i,
input		wire					CODEC_ADC_LRCK_i,
output	wire					CODEC_ADC_MCLK_o,
output	wire					CODEC_DAC_BCLK_o,
output	wire					CODEC_DAC_DAT_o,
output	wire					CODEC_DAC_LRCK_o,
output	wire					CODEC_DAC_MCLK_o,
// CODEC Control
output	wire					CODEC_DI_o,
output	wire					CODEC_CE_o,
output	wire					CODEC_CL_o,

// ChipTune Bus
output	wire					ABUS_CTRL_CLK_o,
output	wire					ABUS_CTRL_IN_o,
output	wire					ABUS_CTRL_LATCH_o,
output	wire					ABUS_DATA_CLK_o,
output	wire					ABUS_DATA_IN0_o,
output	wire					ABUS_DATA_IN1_o,
output	wire					ABUS_DATA_LATCH_o,
output	wire					ABUS_RSTn_o,

output	wire					AMP_MUTE_o,
output	wire					AMP_SDBY_o,

output	wire					CHIPTUNE_RSTn_o,

// SID Bus
output	wire					ABUS_SID_CLK_o,
output	wire					ABUS_SID_IN_o,
output	wire					ABUS_SID_LATCH_o,

// DACs
output	wire					AUD2_BICK_o,
output	wire					AUD2_LRCK_o,
output	wire					AUD2_MCLK_o,
output	wire					AUD2_SDTI_o,
output	wire					AUD3_BICK_o,
output	wire					AUD3_LRCK_o,
output	wire					AUD3_MCLK_o,
output	wire					AUD3_SDTI_o,

output	wire					DAC_Playback_Done48_Int_o,
output	wire					DAC_Playback_Done44_Int_o

);


// Sound Chipset
wire	[7:0] 	OPL3_Data;
wire 	[1:0] 	OPL3_Addy;
wire		  		OPL3_CSn;
wire       		OPL3_RDn;
wire       		OPL3_WRn;

wire 	[7:0] 	OPN2_Data;
wire 	[1:0] 	OPN2_Addy;
wire		  		OPN2_CSn;
wire       		OPN2_RDn;
wire       		OPN2_WRn;
wire 	[7:0] 	OPM_Data;
wire		  		OPM_Addy;
wire		  		OPM_CSn;
wire       		OPM_RDn;
wire       		OPM_WRn;
wire 	[7:0] 	DataOut_OPM;
wire 	[7:0] 	DataOut_OPN2;
wire 	[7:0] 	DataOut_SID_L;
wire 	[7:0] 	DataOut_SID_R;
wire	[15:0]	DataOut_CODEC;

wire 	[7:0]		PSG_Data;
wire				PSG_WEn;
wire				PSG_CEn;

wire		  		TranserInProgress;

wire 				CS_OPL3;
wire 				CS_Ext_OPN2;
wire 				CS_Ext_OPM;
wire 				CS_Ext_PSG;
wire				CS_Codec;
wire 				CS_Ext_L_SID;
wire 				CS_Ext_R_SID;
wire 				CS_Int_OPN2;
wire 				CS_Int_OPM;
wire 				CS_Int_L_PSG;
wire 				CS_Int_R_PSG;
wire 				CS_Int_S_PSG;
wire 				CS_Int_L_SID;
wire 				CS_Int_R_SID;
wire 				CS_Int_S_SID;
wire				CS_YM2149_L;
wire				CS_YM2149_R;
wire				CS_YM2149_S;


// Audio Bus Control Signals
assign ABUS_RSTn_o 		= !Reset_i;

// 44.1Khz
assign AUD2_MCLK_o 		= Clk22_579Mhz_i;

// 48.1Khz
assign AUD3_MCLK_o 		= Clk24_576Mhz_i;


assign CHIPTUNE_RSTn_o 	= !Reset_i;	// Reset all ChipTune

// CODEC
assign CODEC_DAC_MCLK_o = Clk24_576Mhz_i;
assign CODEC_ADC_MCLK_o = Clk24_576Mhz_i;

wire	[7:0] CPU_2_DAC_48_Data_Out;
wire	[7:0] CPU_2_DAC_44_Data_Out;

CODEC_Interface CPU2CODEC(

	.BUS_Rst_i( Reset_i ),
	.BUS_Clk_i( CPU_Clk_i ),
	.Clk_358MHz_i( Clk3_58Mhz_i ),

	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),
	.iBUS_D8_i( iBUS_D8_i  ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_WE_i( iBUS_WE_i ), 
	
	.CS_CODEC_i( CS_Codec ),

	.BTX_CODEC_CL_o( CODEC_CL_o ),
	.BTX_CODEC_DI_o( CODEC_DI_o ),
	.BTX_CODEC_CE_o( CODEC_CE_o ),

	.CODEC_Ready_o( DataOut_CODEC )			// Bit Indicate that Transfer is done
);

wire 	CS_BEATRIX_Config;
wire	CS_CPU_2_DAC44;
wire	CS_CPU_2_DAC48;

wire [31:0] DataOut_BEATRIX_Config;

BEATRIX_CTRL_Reg GABE_CTRL(
	.RST_i( Reset_i ),
	.CPU_Clk_i( CPU_Clk_i ),
	.CPU_A_i( iBUS_A_i ),
	.CPU_D8_i( iBUS_D8_i  ),
	.CPU_D16_i( iBUS_D16_i ),
	.CPU_D32_i( iBUS_D32_i ),
	.CPU_Siz_i( iBUS_D_Siz_i ),
	.CPU_R_Wn_i( iBUS_RWn_i ),
	.CPU_BE_i( iBUS_BE_i ),
	.CPU_WE_i( iBUS_WE_i ), 	
	.CPU_A_Valid_i( iBUS_A_Valid_i ),
	.CS_INT_REG_i( CS_BEATRIX_Config ),
	
	.AMP_MUTE_o( AMP_MUTE_o ),
	.AMP_SDBY_o( AMP_SDBY_o ),

	.CPU_D_o( DataOut_BEATRIX_Config )
);

BEATRIX_CS_And_Dout BTX_CS_And_Dout(
// CPU Interface
	.CPU_Clk_i( CPU_Clk_i ),
	.Reset_i( Reset_i ),
	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),
	.iBUS_D_Valid_o( iBUS_D_Valid_o ),
	.iBUS_D8_i( iBUS_D8_i  ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_CS_BEATRIX_i( iBUS_CS_BEATRIX_i ),

	.DataOut_CPU2DAC44_i( { CPU_2_DAC_44_Data_Out, CPU_2_DAC_44_Data_Out, CPU_2_DAC_44_Data_Out, CPU_2_DAC_44_Data_Out} ),
	.DataOut_CPU2DAC48_i( { CPU_2_DAC_48_Data_Out, CPU_2_DAC_48_Data_Out, CPU_2_DAC_48_Data_Out, CPU_2_DAC_48_Data_Out } ),
	.DataOut_Int_OPN2_i( { DataOut_OPN2, DataOut_OPN2, DataOut_OPN2, DataOut_OPN2 }),			//x1
	.DataOut_Int_OPM_i( { DataOut_OPM, DataOut_OPM, DataOut_OPM, DataOut_OPM } ),			//x1
	.DataOut_CODEC_i( {DataOut_CODEC, DataOut_CODEC} ),
	.DataOut_Int_L_SID_i( { DataOut_SID_L, DataOut_SID_L, DataOut_SID_L, DataOut_SID_L } ),				//x3
	.DataOut_Int_R_SID_i( { DataOut_SID_R, DataOut_SID_R, DataOut_SID_R, DataOut_SID_R } ),
	.DataOut_BEATRIX_Config_i( DataOut_BEATRIX_Config ),			//x1

	.CS_OPL3_o( CS_OPL3 ),							// 
	.CS_Ext_OPN2_o( CS_Ext_OPN2 ),				//
	.CS_Ext_OPM_o( CS_Ext_OPM ),					//
	.CS_Ext_PSG_o( CS_Ext_PSG ),					//
	.CS_Ext_L_SID_o( CS_Ext_L_SID ),				// L, R, S
	.CS_Ext_R_SID_o( CS_Ext_R_SID ),				//
	.CS_Int_OPN2_o( CS_Int_OPN2 ),		  		//
	.CS_Int_OPM_o( CS_Int_OPM ),					//
	.CS_Int_L_PSG_o( CS_Int_L_PSG ),				// Left
	.CS_Int_R_PSG_o( CS_Int_R_PSG ),				// Right
	.CS_Int_S_PSG_o( CS_Int_S_PSG ),				// Both
	.CS_Int_L_SID_o( CS_Int_L_SID ),				//
	.CS_Int_R_SID_o( CS_Int_R_SID ),				//	
	.CS_Int_S_SID_o( CS_Int_S_SID ),				//
	.CS_YM2149_L_o( CS_YM2149_L  ),
	.CS_YM2149_R_o( CS_YM2149_R  ),
	.CS_YM2149_S_o( CS_YM2149_S  ),
	.CS_CODEC_o( CS_Codec ),		// 
	.CS_BEATRIX_Config_o( CS_BEATRIX_Config ),		//
	.CS_CPU_2_DAC44_o( CS_CPU_2_DAC44 ),
	.CS_CPU_2_DAC48_o( CS_CPU_2_DAC48 ),

	.DataOut_o( iBUS_D_BEATRIX_o )
);



BUS_2_ChipTune_Interface ChipTune_Block( 
	.BUS_Clk_i( CPU_Clk_i ),
	.BUS_RST_i( Reset_i ),
	.BUS_A_i( iBUS_A_i ),
	.BUS_D8_i( iBUS_D8_i  ),
	.BUS_D16_i( iBUS_D16_i ),
	.BUS_D32_i( iBUS_D32_i ),
	.BUS_D_Siz_i( iBUS_D_Siz_i ),
	.BUS_A_Valid_i( iBUS_A_Valid_i ),
	.BUS_RWn_i( iBUS_RWn_i ),
	.BUS_BE_i( iBUS_BE_i ),
	.BUS_WE_i( iBUS_WE_i ), 
	// Chip Selects
	.CS_OPL3_i( CS_OPL3 ),
	.CS_OPN2_i( CS_Ext_OPN2 ),
	.CS_OPM_i( CS_Ext_OPM ),
	.CS_PSG_i( CS_Ext_PSG ),	
	
	.TIP_i( TranserInProgress ),

	.OPL3_Clk_i( Clk3_58Mhz_i ), //Clk3_58Mhz, Clk7_15Mhz, Clk14Mhz
	.OPL3_RST_i( Reset_i ),
	
	.OPL3_D_o( OPL3_Data ),
	.OPL3_A_o( OPL3_Addy ),
	.OPL3_CSn( OPL3_CSn ),
	.OPL3_RDn( OPL3_RDn ),
	.OPL3_WRn( OPL3_WRn ),
	
	.OPN2_D_o( OPN2_Data ),
	.OPN2_A_o( OPN2_Addy ),
	.OPN2_CSn( OPN2_CSn ),
	.OPN2_RDn( OPN2_RDn ),
	.OPN2_WRn( OPN2_WRn ),
	
	.OPM_D_o( OPM_Data ),
	.OPM_A_o( OPM_Addy ),
	.OPM_CSn( OPM_CSn ),
	.OPM_RDn( OPM_RDn ),
	.OPM_WRn( OPM_WRn ),
	
	.PSG_D_o( PSG_Data ),
	.PSG_WEn( PSG_WEn ),
	.PSG_CEn( PSG_CEn )
);

Parallel2Serial_SID SID_HardwareSerializer(
	.BUS_RST_i( Reset_i ),
	.BUS_Clk_i( CPU_Clk_i ),
	.SID_Clk_o( SID_CLK_o ),
	.Clk80_000Mhz_i( Clk80_000Mhz_i ), 
	// 
	.BUS_D8_i( iBUS_D8_i  ),
	.BUS_D16_i( iBUS_D16_i ),
	.BUS_D32_i( iBUS_D32_i ),
	.BUS_D_Siz_i( iBUS_D_Siz_i ),
	.BUS_A_Valid_i( iBUS_A_Valid_i ), 
	.BUS_RWn_i( iBUS_RWn_i ),
	.BUS_BE_i( iBUS_BE_i ),
	.BUS_WE_i( iBUS_WE_i ), 	
	.BUS_SID_L_CS_i( CS_Ext_L_SID ),		
	.BUS_SID_R_CS_i( CS_Ext_R_SID ),	
	.BUS_A_i( iBUS_A_i ),		// A[5:0]

	.ABUS_SID_IN_o( ABUS_SID_IN_o ),
	.ABUS_SID_CLK_o( ABUS_SID_CLK_o ),
	.ABUS_SID_LATCH_o( ABUS_SID_LATCH_o )
);


Parallel2SerialAudio AudioChipSerializer(
	.RST_i( Reset_i ),
	.SERIAL_Clk_i( Clk14_318Mhz_i ),	
	// 
	.OPL3_Data_i( OPL3_Data ),
	.OPL3_RD_i( OPL3_RDn ),
	.OPL3_WR_i( OPL3_WRn ),
	.OPL3_CS_i( OPL3_CSn ),
	.OPL3_A_i( OPL3_Addy ),

	.OPN2_Data_i( OPN2_Data ),
	.OPN2_RD_i( OPN2_RDn ),
	.OPN2_WR_i( OPN2_WRn ),
	.OPN2_CS_i( OPN2_CSn ),
	.OPN2_A_i( OPN2_Addy ),

	.OPM_Data_i( OPM_Data ),
	.OPM_RD_i( OPM_RDn ),
	.OPM_WR_i( OPM_WRn ),
	.OPM_CS_i( OPM_CSn ),
	.OPM_A_i( OPM_Addy ),

	.PSG_DATA_i( PSG_Data ),
	.PSG_WE_i( PSG_WEn ),
	.PSG_CE_i( PSG_CEn ),

	.ABUS_CTRL_In_o( ABUS_CTRL_IN_o ),
	.ABUS_CTRL_Clk_o( ABUS_CTRL_CLK_o ),
	.ABUS_CTRL_LATCH_o( ABUS_CTRL_LATCH_o ),

	.ABUS_DATA_In0_o( ABUS_DATA_IN0_o ),
	.ABUS_DATA_In1_o( ABUS_DATA_IN1_o ),	
	.ABUS_DATA_Clk_o( ABUS_DATA_CLK_o ),
	.ABUS_DATA_LATCH_o( ABUS_DATA_LATCH_o ),
	.TIP_o( TranserInProgress ) 				// Transfer in Progress

);

SoundChips2DAC_Interface SOUNDCHIP_INTERFACE(
	.Audio_Clk( Clk24_576Mhz_i ),	//2457600

	.ChipTune_Clk_i( Clk14_318Mhz_i ), 
	
	.BUS_Rst_i( Reset_i ),	// Reset Valid Hi
	.BUS_Clk_i( CPU_Clk_i ),	// 14Mhz

	.BUS_A_i( iBUS_A_i ),
	.BUS_D8_i( iBUS_D8_i  ),
	.BUS_D16_i( iBUS_D16_i ),
	.BUS_D32_i( iBUS_D32_i ),
	.BUS_Siz_i( iBUS_D_Siz_i ),
	.BUS_A_Valid_i( iBUS_A_Valid_i ), 
	.BUS_BE_i( iBUS_BE_i ),
	.BUS_WE_i( iBUS_WE_i ), 	
	.BUS_RW_i( iBUS_RWn_i ),
	.CS_L_PSG_i( CS_Int_L_PSG ),
	.CS_R_PSG_i( CS_Int_R_PSG ),	
	.CS_S_PSG_i( CS_Int_S_PSG ),	
	.CS_OPN2_i( CS_Int_OPN2 ),
	.CS_OPM_i( CS_Int_OPM ),
	.CS_FPGA_L_SID_i( CS_Int_L_SID ),
	.CS_FPGA_R_SID_i( CS_Int_R_SID ),
	.CS_FPGA_S_SID_i( CS_Int_S_SID ),
	.DataOut_OPM_o( DataOut_OPM ),
	.DataOut_OPN2_o( DataOut_OPN2 ),
	.DataOut_SID_L_o( DataOut_SID_L ),
	.DataOut_SID_R_o( DataOut_SID_R ), 
	.CS_FPGA_YM2149_L_i( CS_YM2149_L ),
	.CS_FPGA_YM2149_R_i( CS_YM2149_R ),	
	.CS_FPGA_YM2149_S_i( CS_YM2149_S ),

	.LPF_MODE_i( 2'b01 ),
	.en_hifi_pcm_i( 1'b1 ),
	.extfilter_en_i( 1'b1 ),
	//.LADDER_i( 1'b1 ),
//	.ENABLE_FM_i( 1'b1 ),
	.ENABLE_PSG_i( 1'b1 ),
	.audio_96k_i( 1'b0 ),
	.vol_att_i( 5'b0_0000 ),

// I2S Output
	.I2S_BCLK_o( CODEC_DAC_BCLK_o ),
	.I2S_LRCLK_o( CODEC_DAC_LRCK_o ),
	.I2S_DATA_o( CODEC_DAC_DAT_o )
);



CPU_Interface_2_AudioDAC
#(
	.CLK_RATE(24576000)
) CPU_2_DAC48
(
	.RST_i( Reset_i ),
	.CPU_Clk_i( CPU_Clk_i ),
// CPU Bus Input
	.CPU_A_i( iBUS_A_i ),
	.CPU_RW_i( iBUS_RWn_i ),
	.CPU_D8_i( iBUS_D8_i  ),
	.CPU_D16_i( iBUS_D16_i ),
	.CPU_D32_i( iBUS_D32_i ),
	.CPU_Siz_i( iBUS_D_Siz_i ),
	.CPU_A_Valid_i( iBUS_A_Valid_i ), 
	.CPU_BE_i( iBUS_BE_i ),
	.CPU_WE_i( iBUS_WE_i ), 	
	
	.CPU_D_o( CPU_2_DAC_48_Data_Out ),
	.CS_SAMPLE_PLAYBACK_i( CS_CPU_2_DAC48 ),
	.DAC_Playback_Done_Int_o( DAC_Playback_Done48_Int_o ),						// Interrupt

	.I2S_Encoder_Reset_i( Reset_i ), 
	.Clk_Audio_Sampling_i( Clk24_576Mhz_i ),

	.i2s_bclk_o( AUD3_BICK_o ),
	.i2s_lrclk_o( AUD3_LRCK_o ),
	.i2s_data_o( AUD3_SDTI_o )
);

CPU_Interface_2_AudioDAC
#(
	.CLK_RATE(22579000)
) CPU_2_DAC44
(
	.RST_i( Reset_i ),
	.CPU_Clk_i( CPU_Clk_i ),

// CPU Bus Input
	.CPU_A_i( iBUS_A_i ),
	.CPU_RW_i( iBUS_RWn_i ),
	.CPU_D8_i( iBUS_D8_i  ),
	.CPU_D16_i( iBUS_D16_i ),
	.CPU_D32_i( iBUS_D32_i ),
	.CPU_Siz_i( iBUS_D_Siz_i ),
	.CPU_A_Valid_i( iBUS_A_Valid_i ), 
	.CPU_BE_i( iBUS_BE_i ),
	.CPU_D_o( CPU_2_DAC_44_Data_Out ),
	.CS_SAMPLE_PLAYBACK_i( CS_CPU_2_DAC44 ),
	.DAC_Playback_Done_Int_o( DAC_Playback_Done44_Int_o ),					// Interrupt

	.I2S_Encoder_Reset_i( Reset_i ), 	
	.Clk_Audio_Sampling_i( Clk22_579Mhz_i ),

	.i2s_bclk_o( AUD2_BICK_o ),
	.i2s_lrclk_o( AUD2_LRCK_o ),
	.i2s_data_o( AUD2_SDTI_o )

);



endmodule

