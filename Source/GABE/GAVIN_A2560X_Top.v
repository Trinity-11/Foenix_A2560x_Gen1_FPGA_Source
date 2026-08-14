`timescale 1ns / 1ps
module GAVIN_A2560X_Top (
// Reset
input		wire					Reset_i,
// LPC Reset Signals
input		wire					Cold_Reset_i,
output		wire					Manual_RESET_o,
// Clocks	
input		wire					CPU_Clk_i,				// CPU Clock - Could be 16/20/25/33/40/66/75
input  		wire   					iBUS_2xClk_i, 			// 66Mhz 
input		wire					Clk14_318Mhz_i,
input		wire					LPC_Clk33_333Mhz_i,
input		wire					Clk80_000Mhz_i,
// Buses
// CPU Block Buses
input		wire		[31:0]		iBUS_A_i,
input		wire					iBUS_A_Valid_i,
input		wire		[7:0]		iBUS_D8_i,
input		wire		[15:0]		iBUS_D16_i,
input		wire		[31:0]		iBUS_D32_i,
input		wire		[1:0]		iBUS_D_Siz_i,
output		wire					iBUS_D_Valid_o,
input		wire					iBUS_RWn_i,
input		wire		[3:0]		iBUS_BE_i,
input		wire					iBUS_WE_i,
output		wire		[31:0]		iBUS_D_GAVIN_o,
input		wire					iBUS_CS_GAVIN_i,
// Interrupts Inputs
input		wire					OPM_INTn_i,
input		wire					OPN2_INTn_i,
input		wire					OPL3_INTn_i,
input		wire					VID_A_HP_INT1n_i,
input		wire					VID_B_HP_INT1n_i,
input		wire		[5:0]		VKY_III_Channel_A_IRQ_i,
input		wire		[5:0]		VKY_III_Channel_B_IRQ_i,
input		wire					DAC_Playback_Done48_Int_i,
input		wire					DAC_Playback_Done44_Int_i,
//LPC Interface
output		wire					LPC_CLK_32Khz_o,
inout		wire					LPC_IRQn_io,
input		wire					LPC_LDRQn_i,
inout		wire		[3:0]		LPC_LAD_io,
output		wire					LPC_LFRAMEn_o,
output		wire					LPC_RSTn_o,	
// SD Card Interface
input		wire					F_SD_CD_i,
output		wire					F_SD_CLK_o,			// CLK
output		wire					F_SD_CMD_o,			// MOSI
input		wire					F_SD_DAT0_io,		// MISO
input		wire					F_SD_DAT1_io,		// IO
input		wire					F_SD_DAT2_io,		// IO
output		wire					F_SD_DAT3_io,		// CS
input		wire					F_SD_WP_i,
// Buzzer
output		wire					BTX_BUZZER_o,
// Local BUS
output		wire		[7:0]		IO_A_o,
inout		wire		[15:0]		IO_D_io,
output		wire					IO_RDn_o,
output		wire					IO_WRn_o,
output		wire					ETH_CSn_o,
output		wire					ETH_FIFO_SEL_o,
input		wire					ETH_IRQn_i,
output		wire					IDE_CS0n_o,
output		wire					IDE_CS1n_o,
output		wire					IDE_DATA_DIR_o,
output		wire					IDE_DATA_OEn_o,
input		wire					IDE_INTRQ_i,
input		wire					IDE_IORDY_i,
input		wire					TRINITY_IRQn_i,
output		wire					TRINITY_CSn_o,
output		wire					TRINITY_CPU_CLK_o,
output		wire					RTC_CSn_o,
input		wire					RTC_INTn_i,
// Misc System Control
output		wire					BLU_POWER_LED_o,		// On/Off (board LED)
output		wire					RGB_POWER_LED_o,		// RGB - Some serializing will be needed to get the RGB we want
output		wire					SDCARD_LED_o,			// On/Off (board LED)
output		wire					SDCARD_RGB_o,			// RGB LED installed don the SDCard Board
input		wire					SOF_Channel_A_i,
input		wire					SOF_Channel_B_i,
// CPU Interrupts
output		wire	[6:0]			iIRQ_Interrupt_o,
output		wire	[7:0]			iIRQ_Vector_o,
output		wire					iIRQ_AutoVector_o,
input		wire					iIRQ_GetVector_i,
// Wait-State Section
//output	wire					Wait_SDCard_TA_o,
output		wire					Wait_Unity_TA_o,
output		wire					Wait_LPC_TA_o,
output		wire					Wait_RTC_TA_o,
// Chip Selects to Add Delay in the transaction
output		wire					CS_SDCard_o,
output		wire					CS_Unity_o,
output		wire					CS_LPC_o,
output		wire					CS_RTC_o,
// Misc
output		wire					SD_Debug_o,
input		wire					Trigger_i
);

assign SD_Debug_o = 1'b0;

assign CS_SDCard_o 			= CS_SDCard;
assign CS_Unity_o  			= CS_IDE | CS_NIC;
assign CS_LPC_o	 			= CS_LPC;
assign CS_RTC_o    			= CS_RTC | CS_TRINITY;
assign TRINITY_CPU_CLK_o 	= CPU_Clk_i;

wire [11:0] KeyBoard_Status_LED_Value; 

assign iBUS_D_Valid_o = iBUS_D_Valid_LPC | iBUS_D_Valid_SD ;
wire Buzzer_Enable;

// BUZZER
Buzzer Buz_Block4Khz(
	.Clk_i( CPU_Clk_i ),
	.Buzzer_o( BTX_BUZZER_o ),
	.Buzzer_Enable( Buzzer_Enable )
);

CLK32KhzCreation CLK32K_GEN(
	.Clk14Mhz_i( Clk14_318Mhz_i ),
	.Clk32Khz_o( LPC_CLK_32Khz_o )
);

wire 	[3:0] 		LPC_LAD_In;
wire 	[3:0] 		LPC_LAD_Out;
wire 				LPC_OE;
wire 				LPC_IRQ_In;
wire				LPC_IRQ_Out;
wire				LPC_IRQ_OE;
wire	[31:0]		LPC_Data_Out;
wire				LPC_Frame;
wire 	[31:0] 		LPC_IRQ;

wire				iBUS_D_Valid_LPC;
wire				iBUS_D_Valid_SD;

wire 				CS_LPC;
wire				CS_MATH_FIXED;
wire				CS_MATH_FLOAT;
wire				CS_Interrupt_Ctrl;
wire				CS_Timer;
wire				CS_SDCard;
wire				CS_IDE;
wire				CS_NIC;
wire				CS_TRINITY;
wire				CS_GABE_Config;
wire				CS_RTC;


wire	[7:0]		DataOut_SDCard;
wire	[31:0]		DataOut_Math_Fixed;
wire	[31:0]		DataOut_IDE_ETH_DPS;
wire	[31:0]		DataOut_Trinity;
wire	[31:0]		DataOut_Timer;	
wire	[31:0]		DataOut_GABE_Config;		
wire	[31:0]		DataOut_IRQ_CTRL;
wire	[31:0]		DataOut_RTC;

wire				Interrupt_Timer0;
wire				Interrupt_Timer1;
wire				Interrupt_Timer2;
wire				Interrupt_Timer3;
wire				Interrupt_Timer4;

A2560X_GAVIN_CS_And_Dout GABE_CS_DOUT(
// CPU Interface
	.CPU_Clk_i( CPU_Clk_i ),
	.Reset_i( Reset_i ),
	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),
	.iBUS_D_Valid_o( iBUS_D_Valid_SD ), 
	.iBUS_D8_i( iBUS_D8_i  ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_CS_GABE_i( iBUS_CS_GAVIN_i ),
// Data Out Inputs
// Data Path from the different Block
	.DataOut_LPC_Interface_i( LPC_Data_Out ),		//x1
	.DataOut_Math_Fixed_i( DataOut_Math_Fixed ),			//x4
	.DataOut_Math_Float_i( 32'h22221111 ),			//x1
	.DataOut_Interrupt_Ctrl_i( DataOut_IRQ_CTRL ),		//x1
	.DataOut_Timer_i( DataOut_Timer ),					//x1
	.DataOut_SDCARD_CTRL_i( {Data_Output_SD, Data_Output_SD, Data_Output_SD, Data_Output_SD} ),			//x1
	.DataOut_IDE_ETH_DPS_i( DataOut_IDE_ETH_DPS ),				//x2
	.DataOut_Trinity_i( DataOut_Trinity ),				//x1
	.DataOut_RTC_i( DataOut_RTC ),
	.DataOut_GABE_Config_i( DataOut_GABE_Config ),			//x1

	.CS_LPC_o( CS_LPC ),					// LPC
	.CS_MATH_FIXED_o( CS_MATH_FIXED ),		// Math Block
	.CS_MATH_FLOAT_o( CS_MATH_FLOAT ),  		// Data Come through here - Internal Registers
	.CS_Interrupt_Ctrl_o( CS_Interrupt_Ctrl ),		// Interrupt Controller
	.CS_Timer_o( CS_Timer ),					// Timer Block
	.CS_SDCard_o( CS_SDCard ),				// SDCard Controller
	.CS_IDE_o( CS_IDE ),					// IDE Controller
	.CS_NIC_o( CS_NIC ),					// Network Interface Controller
	.CS_Trinity_o( CS_TRINITY ),				// Joystick
	.CS_RTC_o( CS_RTC ),
	.CS_GABE_Config_o( CS_GABE_Config ),			// GABE Control Registers
	.DataOut_o( iBUS_D_GAVIN_o )
);

wire [23:0] POWER_ON_RGB_Value;

A2560X60_GAVIN_CTRL GABE_CTRL(
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
	.CS_INT_REG_i( CS_GABE_Config ),

	.VARIATION_ID_i( 2'b00 ),
	.CHIP_NUMBER( 16'h5181 ),
	.CHIP_VERSION( 16'h0000 ),
	.CHIP_SUBVERSION( 16'h0000 ),

	.Buzzer_Ctrl_o( Buzzer_Enable ),
	.Power_LED_o( BLU_POWER_LED_o ),
	.SDCARD_LED_o( SDCARD_LED_o ),
	.Manual_RESET_o( Manual_RESET_o ),
	.LPC_RSTn_o( LPC_RSTn_o ), 
	.POWER_ON_RGB_Value_o( POWER_ON_RGB_Value ), 
	.KBD_RGB_Value_o( KeyBoard_Status_LED_Value ),
	.CPU_D_o( DataOut_GABE_Config )
);

RGB_LED_Driver_Module80Mhz PowerOn_RGB_LED_A2560K(
	.Clk80Mhz_i( Clk80_000Mhz_i ),
	.SOF_i( SOF_Channel_A_i ),
	.Reset_i( Reset_i ),
	.RGB_Value_i( POWER_ON_RGB_Value ),
	.RGB_POWER_LED_o( RGB_POWER_LED_o  )
);

RGB_STATUS_LED_Driver_Module80Mhz STATUS_RGB_MOD(

	.Clk80Mhz_i( Clk80_000Mhz_i ),
	.Reset_i( Reset_i ),
	.SOF_i( SOF_Channel_A_i ),
	.RGB_Value0_i( { 1'b0, KeyBoard_Status_LED_Value[2], 6'h00, 1'b0, KeyBoard_Status_LED_Value[1], 6'h00, 1'b0, KeyBoard_Status_LED_Value[0], 6'h00 } ),
	.RGB_Value1_i( { 1'b0, KeyBoard_Status_LED_Value[5], 6'h00, 1'b0, KeyBoard_Status_LED_Value[4], 6'h00, 1'b0, KeyBoard_Status_LED_Value[3], 6'h00 } ),
	.RGB_Value2_i( { 1'b0, KeyBoard_Status_LED_Value[8], 6'h00, 1'b0, KeyBoard_Status_LED_Value[7], 6'h00, 1'b0, KeyBoard_Status_LED_Value[6], 6'h00 } ),
	//.RGB_Value0_i( { 1'b1, 7'h00, 8'h00, 8'h00 } ),
	//.RGB_Value1_i( { 8'h00, 1'b1, 7'h00, 8'h00 } ),
	//.RGB_Value2_i( { 8'h00, 8'h00, 1'b1, 7'h00 } ),

	.RGB_POWER_LED_o( SDCARD_RGB_o )
);



// Fixed Math module, do signed, unsigned 32bits Multiplification and Division in 0 Clock Cycles
Math_Module16 FixedMath_32bits(

// CPU Signals Interface
	.CPU_Clk_i( CPU_Clk_i ),
	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),
	.iBUS_D8_i( iBUS_D8_i  ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_WE_i( iBUS_WE_i ), 
// Chip Selects
	.CS_MATH_FIXED_i( CS_MATH_FIXED ),
// Data Output
	.iBUS_D_FixedMATH_o( DataOut_Math_Fixed )
);


assign LPC_LFRAMEn_o 	= !LPC_Frame;

LPC_BIDir BiDirectionBufferLPC(
	.dataout( LPC_LAD_In ),						 	//   dout.export output wire [3:0] 
	.datain( LPC_LAD_Out ),							//    din.export input  wire [3:0] 
	.dataio( LPC_LAD_io ) , 						// pad_io.export inout  wire [3:0] 
	.oe(  LPC_OE ? 4'b1111 : 4'b0000 )  		//     oe.export
);

// Bidirection Buffer for LPC IRQ
LPC_BIDir_SIRQ BiDirectionSIRQ_BUF(
	.dataout( LPC_IRQ_In ),   				//   dout.export
	.datain( LPC_IRQ_Out  ),    			//    din.export
	.dataio( LPC_IRQn_io ), 					// pad_io.export
	.oe( LPC_IRQ_OE )      				//     oe.export
);

Top_LPC_Interface LPC_Interface_Block(
	.Reset_i( Cold_Reset_i ),
// CPU Interface
	.CPU_Clk_i( CPU_Clk_i ),

	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),
	.iBUS_D8_i( iBUS_D8_i  ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),
	.iBUS_D_Valid_o( iBUS_D_Valid_LPC ),
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_WE_i( iBUS_WE_i ), 
	.iBUS_D_LPC_o( LPC_Data_Out ),
	.CS_LPC_i( CS_LPC ),
	.Wait_LPC_TA_o( Wait_LPC_TA_o ),
	// Debug 
	.LPC_IRQ_i( LPC_IRQ ), 

	// Stef the LPC Circuitry needs to be driven by the external 33Mhz Clock, not the PLL Generated 
	// Which means that the LPC Circuit and CPU Clock are asynchronous.
	.LPC_LDRQn_i( LPC_LDRQn_i ),
	.LPC_Clk_i( LPC_Clk33_333Mhz_i ),
	.lframe_o( LPC_Frame ),
	.lad_i( LPC_LAD_In  ),
	.lad_o( LPC_LAD_Out ),
	.lad_oe_o( LPC_OE )
);

/*
reg [7:0] Data_Input_SD;
reg [2:0] SM;
reg		 SDWrite;
reg		 SDCS;
wire		ack_o;
reg [7:0] Data_Output_SD;


wire [71:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger1 = CS_SDCard;

assign TinyTP1[7:0]  	= iBUS_A_i[7:0];
assign TinyTP1[15:8] 	= Data_Input_SD;
assign TinyTP1[23:16]   = DataOut_SDCard;
assign TinyTP1[24]		= CS_SDCard;
assign TinyTP1[25] 		= iBUS_RWn_i;
assign TinyTP1[28:26]	= SM;
assign TinyTP1[29] 		= SDCS;
assign TinyTP1[30]		= iBUS_A_Valid_i;
assign TinyTP1[31]		= SDWrite;
assign TinyTP1[32]		= ack_o;


TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (CPU_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);

//iBUS_D_Siz == 2'b01 = Byte Transfer
always @ (posedge CPU_Clk_i) begin
	if ( Reset_i ) begin
		SDWrite 	<= 1'b0;
		SDCS		<= 1'b0;
		SM			<= 3'b000;
	end
	else begin
		case (SM)
			3'b000: begin
				if ( CS_SDCard && ( iBUS_D_Siz_i == 2'b01 ) && iBUS_A_Valid_i) begin
					if ( iBUS_RWn_i ) begin
						SDCS <= 1'b1;	
						SM   <= 3'b011;
					end
					else begin
						SM   <= 3'b001;					
					end
				end
				else begin
					SM   			<= 3'b000;
					SDWrite 		<= 1'b0;
					SDCS 			<= 1'b0;					
				end
			end
		
			3'b001: begin
				SDCS <= 1'b1;			
				SDWrite 		  	<= 1'b1;
				Data_Input_SD 	<= iBUS_D8_i;
				SM  		 		<= 3'b010;			
			end
			
			3'b010: begin
				SDWrite   <= 1'b0;
				SM  		 <= 3'b011;			
			end			
		
			// Ack for Read or Write
			3'b011: begin 
				if (ack_o) begin
					Data_Output_SD <= DataOut_SDCard;
					SM   <= 3'b000;
					SDCS <= 1'b0;
				end
				else begin
					SM   <= 3'b011;
				end
			end

			// Wait for the cycle to finish so we don't create endless loop
//			3'b100: begin
//				if (CS_SDCard && Wait_SDCard_TA_o) 
//					SM   <= 3'b000;
//				else 
//					SM   <= 3'b100;
//			end

			
			default: begin
					SM   <= 3'b000;			
			
			end

		endcase
	end

end

spiMaster SDCARD_Controller( 
  .clk_i( CPU_Clk_i ),
  .rst_i( Reset_i ),
  .address_i( iBUS_A_i ),
  .data_i( Data_Input_SD ),
  .data_o( DataOut_SDCard ),		//8bits Output
  .strobe_i( SDCS ),
  .we_i( SDWrite ),
  .ack_o( ack_o ),
	.test_i ( SM ),
  // SPI logic clock
  .spiSysClk( Clk33_333Mhz_i ),
  //SPI bus
  .spiClkOut( F_SD_CLK_o ),		// Output
  .spiDataIn( F_SD_DAT0_io ),		// Input
  .spiDataOut( F_SD_CMD_o ),	// Output
  .spiCS_n( F_SD_DAT3_io )			// Output
);
*/
wire [7:0] Data_Output_SD;
SimpleSPI4SDCard NewSDCard_Controller(
	.Reset_i( Reset_i ),
	.CPU_Clk_i( CPU_Clk_i ),			// 33Mhz internal CPU Speed
	.CPU_A_i( iBUS_A_i ),
	.CPU_D_i( iBUS_D8_i ),
	.CPU_R_Wn_i( iBUS_RWn_i ),
	.CPU_A_Valid_i( iBUS_A_Valid_i  ), 
	.CPU_Siz_i( iBUS_D_Siz_i ),	
	.CPU_BE_i( iBUS_BE_i ),
	.CPU_WE_i( iBUS_WE_i ),	
	.CS_SDCard_i( CS_SDCard ),

	.F_SD_CLK_o( F_SD_CLK_o),			// SCLK
	.F_SD_DAT0_i( F_SD_DAT0_io ),		// MISO
	.F_SD_CMD_o( F_SD_CMD_o ),			// MOSI
	.F_SD_DAT3_o( F_SD_DAT3_io ),		// CS

	.CPU_D_o( Data_Output_SD )
);


A2560X_Unity IDE_And_Ethernet_DP(
	.CPU_Clk_i( CPU_Clk_i ),
	.IDE_Reset_i( Reset_i ), 
	.RST_i( Reset_i ),
	.CPU_A_i( iBUS_A_i ),
	.CPU_D8_i( iBUS_D8_i  ),
	.CPU_D16_i( iBUS_D16_i ),
	.CPU_D32_i( iBUS_D32_i ),
	.CPU_Siz_i( iBUS_D_Siz_i ),
	.CPU_R_Wn_i( iBUS_RWn_i ),
	.CPU_A_Valid_i( iBUS_A_Valid_i  ), 	
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_WE_i( iBUS_WE_i ),

	.Wait_Unity_TA_o( Wait_Unity_TA_o ), 
	.Wait_RTC_TA_o( Wait_RTC_TA_o ), 

	.CS_IDE_i( CS_IDE ),
	.CS_ETH_i( CS_NIC ),
	.CS_RTC_i( CS_RTC ),
	.CS_TRINITY_i( CS_TRINITY ), 
// DataOut
	.iBUS_IDE_ETH_DPS_D_o( DataOut_IDE_ETH_DPS ),
	.iBUS_RTC_D_o( DataOut_RTC ),
	.iBUS_TRINITY_D_o( DataOut_Trinity ),
// IDE Interface
	.IDE_CS0n_o( IDE_CS0n_o ),
	.IDE_CS1n_o( IDE_CS1n_o ),
	.IO_A_o( IO_A_o ),
	.IO_RDn_o( IO_RDn_o ),
	.IO_WRn_o( IO_WRn_o ),
	.IO_D_Input_io( IO_D_io ),
	.IDE_DATA_OEn_o( IDE_DATA_OEn_o ),
	.IDE_DATA_DIR_o( IDE_DATA_DIR_o ),
// Ethernet
	.ETH_CSn_o( ETH_CSn_o ),
	.ETH_FIFO_SEL_o( ETH_FIFO_SEL_o ),
// RTC
	.RTC_CSn_o( RTC_CSn_o ),
// Trinity
	.TRINITY_CSn_o( TRINITY_CSn_o )
);


TimerInterface32 TimerBlock(

	.SOF_Channel_A_i( SOF_Channel_A_i ),
	.SOF_Channel_B_i( SOF_Channel_B_i ),

	.RST_i( Reset_i ), 
	.CPU_Clk_i( CPU_Clk_i ),
	.CPU_A_i( iBUS_A_i ),
	.CPU_A_Valid_i( iBUS_A_Valid_i ),	
	.CPU_D8_i( iBUS_D8_i  ),
	.CPU_D16_i( iBUS_D16_i ),
	.CPU_D32_i( iBUS_D32_i ),
	.CPU_Siz_i( iBUS_D_Siz_i ),
	.CPU_BE_i( iBUS_BE_i ),
	.CPU_WE_i( iBUS_WE_i ),		
	.CPU_R_Wn_i( iBUS_RWn_i ),
	.CS_Timer_i( CS_Timer ),
	.CPU_D_o( DataOut_Timer ),

	.Interrupt_Timer0_o( Interrupt_Timer0 ),
	.Interrupt_Timer1_o( Interrupt_Timer1 ),
	.Interrupt_Timer2_o( Interrupt_Timer2 ),
	.Interrupt_Timer3_o( Interrupt_Timer3 ),
	.Interrupt_Timer4_o( Interrupt_Timer4 )
);


A2560x_IRQ_CTRL IRQ_CTRL32s(
	.RST_i( Reset_i ),
	.CPU_Clk_i( CPU_Clk_i ),
	.LPC_Clk_i( LPC_Clk33_333Mhz_i ), 
	.LPC_RSTn_i( LPC_RSTn_o ),
	.CPU_A_i( iBUS_A_i ),
	.CPU_A_Valid_i( iBUS_A_Valid_i ),
	.CPU_RW_i( iBUS_RWn_i ),
	.CPU_BE_i( iBUS_BE_i ),
	.CPU_WE_i( iBUS_WE_i ),	
	.CPU_D8_i( iBUS_D8_i  ),
	.CPU_D16_i( iBUS_D16_i ),
	.CPU_D32_i( iBUS_D32_i ),
	.CPU_Siz_i( iBUS_D_Siz_i ),
	.CPU_D_o( DataOut_IRQ_CTRL ),
	.CS_Interrupt_Ctrl_i( CS_Interrupt_Ctrl ),
	
	.serirq_i( LPC_IRQ_In ),
	.serirq_o( LPC_IRQ_Out ),
	.serirq_oe( LPC_IRQ_OE ),
	.LPC_IRQ_o( LPC_IRQ ), 
	
	.VID_A_HP_INT1n_i( VID_A_HP_INT1n_i ),
	.VKY_III_Channel_A_IRQ_i( VKY_III_Channel_A_IRQ_i ),
	.VID_B_HP_INT1n_i( VID_B_HP_INT1n_i ), 
	.VKY_III_Channel_B_IRQ_i( VKY_III_Channel_B_IRQ_i ),
	
	.Trinity_IRQ_i( TRINITY_IRQn_i ), 

	.RTC_IRQ_i( RTC_INTn_i ),
	.IDE_IRQ_i( IDE_INTRQ_i ),
	.SD_IRQ_i( 1'b0 ),
	.SD_Card_Insert_i( F_SD_CD_i ),
	.Timer0_i( Interrupt_Timer0 ),		// CPU Clock Timer 0
	.Timer1_i( Interrupt_Timer1 ),		// CPU Clock Timer 1
	.Timer2_i( Interrupt_Timer2 ),		// CPU Clock Timer 2
	.Timer3_i( Interrupt_Timer3 ),		// SOF Channel A Counter IRQ
	.Timer4_i( Interrupt_Timer4 ),		// SOF Channel B Counter IRQ
	.Ethernet_IRQ_i( ETH_IRQn_i ), 
	
	.BTX_IRQ_i( 4'b0000 ),
	.OPL3_EXT_IRQ_i( OPL3_INTn_i ),
	.OPN2_EXT_IRQ_i( OPN2_INTn_i ),
	.OPM_IXT_IRQ_i( OPM_INTn_i ),
	.DAC0_Playback_Done_IRQ_i( DAC_Playback_Done48_Int_i ),
	.DAC1_Playback_Done_IRQ_i( DAC_Playback_Done44_Int_i ),
	

	// Output to the Front End Processor (68K Family)
	.iIRQ_Interrupt_o( iIRQ_Interrupt_o ),
	.iIRQ_Vector_o( iIRQ_Vector_o ),
	.iIRQ_AutoVector_o( iIRQ_AutoVector_o ),
	.iIRQ_GetVector_i( iIRQ_GetVector_i )
);



endmodule

