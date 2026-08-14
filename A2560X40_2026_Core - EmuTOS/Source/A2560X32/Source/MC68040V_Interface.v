//Stefany is here
module MC68040V_Interface (

// New Signals
input		wire				Global_Reset_i,
output		wire				Master_Resetn_o,
input		wire				Clk_133Mhz_i,
// MC68040 General A2560K Interface
inout		wire	[31:0]		CPU_A_io,	// IO
inout		wire	[31:0]		CPU_D_io,	// IO - D[31:0] - ( D[31:24] LSB ) - ( D[7:0] MSB )

output		reg					MEM_BURST_A2_o,
output		reg					MEM_BURST_A3_o,
//CPU Control (MC68040V)
output		wire				CPU_BCLK_o,
output		wire				CPU_AVECn_o,
output		wire				CPU_BGn_o,
input		wire				CPU_BBn_io,
input		wire				CPU_BRn_i,
output		wire				CPU_CDISn_o,
input		wire				CPU_CIOUTn_i,
input		wire				CPU_IPENDn_i,
output		wire				CPU_IPL0n_o,
output		wire				CPU_IPL1n_o,
output		wire				CPU_IPL2n_o,
input		wire				CPU_LOCKn_i,			//BERRn
output		wire				CPU_LOCKEn_i,			// HALT
output		wire				CPU_MDISn_o,
input		wire				CPU_MIn_i,
output		wire				CPU_PCLK_o,
input		wire				CPU_PST0_i,
input		wire				CPU_PST1_i,
input		wire				CPU_PST2_i,
input		wire				CPU_PST3_i,
inout		wire				CPU_RWn_io,				// IO (MC68040)
output		wire				CPU_RESET_INn_o,		// THis is the CPU Reset In - Sometimes it can be IO
input		wire				CPU_RESET_OUTn_i,		// This is the MC68040 Reset Out Function Called by the Instruction Reset
inout		wire				CPU_SIZ0_io,			// IO (MC68040)
inout		wire				CPU_SIZ1_io,			// IO (MC68040)
inout		wire				CPU_TAn_io,				// IO (MC68040)
inout		wire				CPU_TBIn_io,				//
inout		wire				CPU_TCIn_io,
inout		wire				CPU_TEAn_io,
input		wire				CPU_TIPn_i,
inout		wire				CPU_TSn_io,				// IO (MC68040)
input		wire				CPU_TLN0_i,
input		wire				CPU_TLN1_i,
input		wire				CPU_TM0_i,
input		wire				CPU_TM1_i,
input		wire				CPU_TM2_i,
inout		wire				CPU_TT0_io,				// IO (MC68040)
inout		wire				CPU_TT1_io,				// IO (MC68040)
input		wire				CPU_UPA0_i,
input		wire				CPU_UPA1_i,
output		wire				CPU_LFOn_o,
input		wire				CPU_LOC_i,
input		wire				CPU_SCDn_i,
// Memory Interface
// Flash (4Meg)
output		wire				LOCAL_MEM_FLASH_CSn_o,
output		wire				LOCAL_MEM_FLASH_OEn_o,
output		wire				LOCAL_MEM_FLASH_WEn_o,
output		wire	[3:0]		LOCAL_MEM_SRAM_BEn_o,
output		wire				LOCAL_MEM_SRAM_CSn_o,
output		reg					LOCAL_MEM_SRAM_OEn_o,
output		reg					LOCAL_MEM_SRAM_WEn_o,
// Slave Interface
output	    wire				iBUS_Clk_o,
output    	wire   				iBUS_2xClk_o,
output		wire	[31:0]		iBUS_A_o,
output		reg		[7:0]		iBUS_D_Write8_o,
output		reg		[15:0]		iBUS_D_Write16_o,
output		reg		[31:0]		iBUS_D_Write32_o,
output		wire	[31:0]		iBUS_D_Out_virgin_o,
output		wire	[1:0]		iBUS_D_Siz_o,
output		wire				iBUS_RWn_o,
output		wire	[3:0]		iBUS_BE_o,
output		reg					iBUS_WE_o,
output		wire				iBUS_A_Valid_o,
// Major Block Input
input		wire	[31:0]		iBUS_D_GAVIN_i,
input		wire	[31:0]		iBUS_D_BEATRIX_i,
input		wire	[31:0]		iBUS_D_VICKY_i,
input		wire	[31:0]		iBUS_D_MERA_i,
// Major Block Chip Select
output		wire				iBUS_CS_GAVIN_o,
output		wire				iBUS_CS_BEATRIX_o,
output		wire				iBUS_CS_VICKY_A_o,
output		wire				iBUS_CS_VICKY_MEM_A_o,
output		wire				iBUS_CS_VICKY_B_o,
output		wire				iBUS_CS_VICKY_MEM_B_o,
output		wire				iBUS_CS_VRAM_A_o,
output		wire				iBUS_CS_VRAM_B_o,
output		wire				iBUS_CS_MERA_o,
// INTERRUPTS
input		wire	[6:0]		iIRQ_Interrupt_i,
input		wire	[7:0]		iIRQ_Vector_i,
input		wire				iIRQ_AutoVector_i,
output		wire				iIRQ_GetVector_o,
// Debug Interface
input		wire				Dbg_Mode_On_i,
input		wire	[31:0]		Dbg_Address_Out_i,
input		wire	[31:0]		Dbg_Data_Out_i,
output		wire	[31:0]		Dbg_Data_In_o,
input  		wire  	[3:0]		Dbg_BEn_i,
input		wire				Dbg_RWn_Out_i,
input		wire				Dbg_RAM_CS_i,
input		wire				Dbg_FLASH_CS_i,
input		wire				Dbg_FLASH_WR_i,
input		wire				Dbg_FLASH_OE_i,
input		wire				Dbg_OE_i,
input		wire				Dbg_RSTn_i,

output		wire				TSF_FLASH2RAM_o,

// Wait-State Section
input		wire				CS_LPC_i,
input		wire				CS_RTC_i,
input		wire				CS_Unity_i,
input  		wire  				CS_IDE_i,
input		wire				Wait_Unity_TA_i,
input		wire				Wait_LPC_TA_i,
input		wire				Wait_RTC_TA_i,
input		wire				Wait_MERA_TA_i
);

`define MC68040

// INFO
// Transfer Type
// TT1:TT0
//  0  0 : Normal Access
//  0  1 : MOVE16 Access
//  1  0 : Alternate Logic Function Code Access
//  1  1 : Acknowledge Access

// TM2:TM1:TM0
//  0   0   0 : Data Cache Push 
//  0   0   1 : User Data Access  (MOVE16)
//  0   1   0 : User Code Access
//  0   1   1 : MMU Table Search Data Access
//  1   0   0 : MMU Table Seasch Code Access
//  1   0   1 : Supervisor Data Access (MOVE16)
//  1   1   0 : SuperVisor Code Access
//  1   1   1 : Reserved

// Alternate Functions
// TM2:TM1:TM0
//  0   0   0 : Logical Function 0 
//  0   0   1 : Reserved
//  0   1   0 : Reserved
//  0   1   1 : Logical Function 3
//  1   0   0 : Logical Function 4
//  1   0   1 : Reserved
//  1   1   0 : Reserved
//  1   1   1 : Logical Function 7

// Memory Alignment
// 32bits Access
// D[31:24] offset 0x03
// D[23:16] offset 0x01
// D[15:8] 	offset 0x02
// D[7:0] 	offset 0x03

// 16bits Access
// D[31:16] offset 0x00
// D[15:0] 	offset 0x02

// 

// SIZ1 : SIZ0 : A1 : A0 
//  0       0     X    X  : D[31:0]

//  0       1     0    0  : D[31:24]
//  0       1     0    1  : D[23:16]
//  0       1     1    0  : D[15:8]
//  0       1     1    1  : D[7:0]

//  1       0     1    0  : D[31:16]
//  1       0     1    1  : D[15:0]

//  1       1     X    X  : D[31:0]			// LINE ACCESS

// Transfer Type
// TT1:TT0
//  0  0 : Normal Access
//  0  1 : MOVE16 Access
//  1  0 : Alternate Logic Function Code Access
//  1  1 : Acknowledge Access


// TM2:TM1:TM0
//  0   0   0 : Data Cache Push 
//  0   0   1 : User Data Access  (MOVE16)
//  0   1   0 : User Code Access
//  0   1   1 : MMU Table Search Data Access
//  1   0   0 : MMU Table Seasch Code Access
//  1   0   1 : Supervisor Data Access (MOVE16)
//  1   1   0 : SuperVisor Code Access
//  1   1   1 : Reserved

///////////////////////////////////////////////////////////////////////
// Registers
reg 	[31:0] 		Data_Out_Mux;
reg		[2:0] 		IPLOut;
reg 	[2:0] 		SmallBootSM;
reg 				CPU_RSTn;
reg 	[4:0] 		WaitCounter;
reg 				Config_On;
reg 	[1:0] 		ClockDivide;
reg 				TSF_FLASH2RAM_EDGE;
reg 				Dbg_RSTn_EDGE;
reg 				Drive_BGn;
reg 	[1:0] 		LineA3_A2;
reg 	[2:0] 		SmallST;
reg 	[7:0]		TBI_TA;
reg					LineA3_A2_Switch;
reg  				CPU_TAn;
reg 				DTACK = 1'b1;
reg 				Pre_DTACK = 1'b1;
reg 	[4:0] 		Wait_FLASH_TA_i;

localparam   	 SB_SM_IDLE		= 3'b000,
				 SB_SM_WAIT1   	= 3'b001,
				 SB_SM_WAIT2 	= 3'b010, // Wait some clocks
				 SB_SM_CFG		= 3'b011, // Present the config 
				 SB_SM_RELEASE	= 3'b100, // Wait a couple of clocks
				 SB_SM_REMOVE	= 3'b101, // Remove Config, go back to normal.
				 SB_SM_WAIT22  	= 3'b110, // Bring BG Down
				 SB_SM_LETBGBE 	= 3'b111; // Let BG be down now.

localparam 		IDLE = 3'b000,		// TS Cycle (Capture A3-A2 Value)
				ST0  = 3'b001,		// TA0 Cycle - Increment A3..A2 for next cycle
				ST1  = 3'b010,		// TA1 Cycle - Incrememt A3..A2 for next cycle
				ST2  = 3'b011,		// TA2 Cycle - Increment A3..A2 for next Cycle
				ST3  = 3'b100;		// We are done, last clock were TA is low

// Let's Divide the Main Clock
always @ (posedge Clk_133Mhz_i) begin 
	ClockDivide <= ClockDivide + 2'b01;
end 

/// WIRES
wire 	[2:0]  		FC;
wire 				CPU_RWn_i;
wire 				CPU_RWn_Out;
wire 				BERRn;
wire 	[31:0] 		Internal_Address;
wire 				UUD, UMD, LMD, LLD;
wire 				LineOr32BitsTransaction;
wire 				SIZ0_Output;
wire 				SIZ1_Output;
wire 				SIZ0;
wire 				SIZ1;
wire 				CPU_TEAn_o;
wire 				CPU_TCIn_o;
wire				CPU_TBIn_o;
wire 				CPU_TAn_o;
wire 	[3:0] 		TA_Group_i;
wire 				CPU_TAn_2_FPGA;
wire 				CPU_TT0_2_FPGA;
wire 				CPU_TT1_2_FPGA;
wire 				CPU_TSn_2_FPGA;
wire 				CPU_TT0_2_CPU;
wire 				CPU_TT1_2_CPU;
wire 				CPU_TSn_2_CPU;
wire 				TSn;
wire 				Remote_Reset_Ctrl;
wire 				Remote_Reset_Direction;
wire 				Remote_Halt_Ctrl;
wire 	[31:0] 		ADDY_In;
wire 	[31:0] 		ADDY_Out;
wire 	[31:0]		Data_In;
wire	[31:0]		Data_Out;
wire 				DataBufferOELogic;
wire 				TSF_RAM_CS;
wire 				TSF_RAM_WR;
wire 				TSF_RAM_OE;
wire 				TSF_FLASH_CS;
wire 				TSF_FLASH_OE;
wire 	[31:0] 		TSF_ADDY;
wire 	[3:0] 		TRF_StateMachine;
wire 				Local_Reset;
wire 				LineTransfer;
wire   				DEAD_ZONE0;
wire   				DEAD_ZONE1;
wire   				DEAD_ZONE2;
wire 				CS_Registers;
wire 				CS_None_Cacheable;
wire 				DataCachePush;
wire 				UserData;
wire 				UserProgram;
wire 				MMU_Table_Search_Data;
wire 				MMU_Table_Search_Code;
wire 				SuperData;
wire 				SuperProgram;
wire 				CPUSpace;
wire   				CS_NO_MANSLAND;
wire 				CS_SRAM;
wire 				CS_MERA;
wire 				CS_GAVIN;
wire 				CS_BEATRIX;
wire 				CS_VRAM_A;
wire 				CS_VRAM_B;
wire 				CS_VICKY_A;
wire 				CS_VICKY_MEM_A;
wire 				CS_VICKY_B;
wire 				CS_VICKY_MEM_B;
wire 				CS_FLASH;
wire 				CS_GET_VECTOR_INT;
wire 				VICKY;
wire   			CPU_BCLK_x2;

// Chip Select Outputs
assign CPU_LOCKEn_i 				= 1'b1;
assign CPU_BCLK_o 					= ClockDivide[1];		// Let's begin with 33Mhz Clock
assign CPU_BCLK_x2 					= ClockDivide[0];		// 66Mhz
assign iBUS_Clk_o 					= ClockDivide[1];		// Local Clock will always be 33Mhz
assign iBUS_2xClk_o					= ClockDivide[0];		// Local Clock will always be 66Mhz
assign iBUS_CS_GAVIN_o				= CS_GAVIN;		
assign iBUS_CS_BEATRIX_o			= CS_BEATRIX;
assign iBUS_CS_VICKY_A_o  			= CS_VICKY_A;
assign iBUS_CS_VICKY_MEM_A_o		= CS_VICKY_MEM_A;
assign iBUS_CS_VICKY_B_o			= CS_VICKY_B;		
assign iBUS_CS_VICKY_MEM_B_o		= CS_VICKY_MEM_B;	
assign iBUS_CS_VRAM_A_o				= CS_VRAM_A;
assign iBUS_CS_VRAM_B_o				= CS_VRAM_B;
assign iBUS_CS_MERA_o 				= CS_MERA;
assign LineOr32BitsTransaction 		= (!SIZ0 & !SIZ1) | (SIZ0 & SIZ1);
assign UUD 							= (!Internal_Address[0] & !Internal_Address[1]) | LineOr32BitsTransaction;		// Describe D31:D24
assign UMD 							= ( Internal_Address[0] & !Internal_Address[1]) | (!Internal_Address[1] & SIZ1) | LineOr32BitsTransaction; // Describe D23:D16
assign LMD 							= (!Internal_Address[0] & Internal_Address[1]) | LineOr32BitsTransaction;	// Describe [D15:D8]
assign LLD 							= ( Internal_Address[0] &  Internal_Address[1]) | (Internal_Address[1] & SIZ1) | LineOr32BitsTransaction; // Describe [
assign iBUS_D_Out_virgin_o 			= Data_In[31:0];

`ifdef MC68040
	assign CPU_BGn_o 				= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b1 : CPU_BRn_i) : 1'b1;	// (MC68040 Mode)
`else 
	assign CPU_BGn_o 				= TSF_FLASH2RAM_o ? ( Drive_BGn  ? 1'b0 : CPU_BGn_o_DLY ) : 1'b1; //( MC68060 Mode)
`endif

assign SIZ0_Output 					= 1'b0;
assign SIZ1_Output 					= 1'b0;
assign iBUS_D_Siz_o 				= {	SIZ1, SIZ0 };
assign CPU_TT0_2_CPU 				= 1'b0;
assign CPU_TT1_2_CPU 				= 1'b0;
assign CPU_TSn_2_CPU 				= 1'b1;
assign TSn 							= CPU_TSn_2_FPGA;
// Bi-Dir Signal for the Reset Signal
assign CPU_RESET_INn_o 				= CPU_RSTn; // CPU_RSTn includes the normal Reset + DBG Reset
assign CPU_RWn_Out 					= TSF_FLASH2RAM_o ? Dbg_RWn_Out_i : TSF_RAM_WR;
assign iBUS_RWn_o 					= CPU_RWn_i;
assign Dbg_Data_In_o 				= Data_In;
assign ADDY_Out 					= TSF_FLASH2RAM_o ? { Dbg_Address_Out_i[31:0]} : TSF_ADDY[31:0];
assign Data_Out 					= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_Data_Out_i : Data_Out_Mux) : 32'hFFFF_FFFF; 
assign DataBufferOELogic 			= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_RWn_Out_i : (CPU_RWn_i & ( CS_Registers | CS_GET_VECTOR_INT))) : 1'b0;
assign Internal_Address 			= ADDY_In[31:0];
assign FC[2:0] 						= ({CPU_TT1_2_FPGA, CPU_TT0_2_FPGA} == 2'b11) ? 3'b111 : {CPU_TM2_i, CPU_TM1_i, CPU_TM0_i};
// Internal Bus 
assign iBUS_A_o 					= Internal_Address;
assign iBUS_BE_o[0]   				= LLD;
assign iBUS_BE_o[1]					= LMD;
assign iBUS_BE_o[2]					= UMD;
assign iBUS_BE_o[3]					= UUD;
assign iBUS_A_Valid_o 				= !TSn;
assign CPU_IPL0n_o 					= Config_On ? 1'b1 :  IPLOut[0];	// 1 means no Interrupt Request
assign CPU_IPL1n_o 					= Config_On ? 1'b1 :  IPLOut[1];	// 1 Means no Interrupt Request
assign CPU_IPL2n_o 					= Config_On ? 1'b1 :  IPLOut[2];	// 1 Means no interrupt Request (1 Lowest - 6 Highest Maskable, 7 is highest none-maskable)
assign CPU_CDISn_o 					= 1'b1;
assign CPU_MDISn_o 					= 1'b1;
assign CPU_PCLK_o 					= 1'b0;	//JS2
assign CPU_TCIn_o 					= CS_None_Cacheable ? CPU_TAn_o : 1'b1;
assign CPU_TEAn_o 					= CS_NO_MANSLAND ? CPU_TAn_o : 1'b1;
assign CPU_LFOn_o 					= 1'b1;
assign Master_Resetn_o 				= TSF_FLASH2RAM_o;
assign Local_Reset 					= !TSF_FLASH2RAM_o;
assign CPU_TAn_o 					= DTACK;
assign CPU_AVECn_o 					= (iIRQ_AutoVector_i & CS_GET_VECTOR_INT ) ? DTACK : 1'b1;	// AVEC is the signal that terminate the cycle when the AutoVector is triggered
assign CPU_TBIn_o					=  LineTransfer ? 1'b1 :   { SIZ1, SIZ0 } == 2'b11  ? CPU_TAn_o : 1'b1 ; // So right now, LINE16 is allowed only in SRAM
// RAM Management
assign LOCAL_MEM_SRAM_CSn_o 		= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_RAM_CS_i	:  !CS_SRAM) : !TSF_RAM_CS;
assign LOCAL_MEM_SRAM_BEn_o[0] 		= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_BEn_i[0]	:  !LLD ) : 1'b0; // LDS
assign LOCAL_MEM_SRAM_BEn_o[1] 		= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_BEn_i[1]	:  !LMD ) : 1'b0; // UDS
assign LOCAL_MEM_SRAM_BEn_o[2] 		= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_BEn_i[2]	:  !UMD ) : 1'b0;
assign LOCAL_MEM_SRAM_BEn_o[3] 		= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_BEn_i[3]	:  !UUD ) : 1'b0;	// LLD is 31:24 
assign LOCAL_MEM_FLASH_CSn_o 		= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_FLASH_CS_i	: !CS_FLASH ) : !TSF_FLASH_CS;
assign LOCAL_MEM_FLASH_OEn_o 		= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_FLASH_OE_i 	: !Flash_OE ) : TSF_FLASH_OE;
assign LOCAL_MEM_FLASH_WEn_o 		= Dbg_FLASH_WR_i;
assign LineTransfer 				= !CPU_TT1_2_FPGA & CPU_TT0_2_FPGA & SIZ1 & SIZ0 & ( CS_SRAM | CS_MERA | CS_VRAM_A | CS_VRAM_B | CS_FLASH);		//TT[1:0] == 01, SIZE == 11

assign CS_GET_VECTOR_INT			= CPUSpace; // Interrupt Request Cycle
assign CS_SRAM 						= ( Internal_Address[31:22] == 10'b0000_0000_00 )  & !CPU_TIPn_i; 																		//$0000_0000 - $003F_FFFF (4Meg)
assign DEAD_ZONE0	    			= ( Internal_Address[31:22] == 10'b0000_0000_01 )  & !CPU_TIPn_i; 																		//$0040_0000 - $007F_FFFF (4Meg)
// Video RAM
assign CS_VRAM_A  					= ( Internal_Address[31:21] == 11'b0000_0000_100 )  & ( UserData  | SuperData ) & !CPU_TIPn_i; 											//$0080_0000 - $009F_FFFF (2M) (out of 8M)
assign CS_VRAM_B  					= ( Internal_Address[31:21] == 11'b0000_0000_101 )  & ( UserData  | SuperData ) & !CPU_TIPn_i; 											//$00A0_0000 - $00BF_FFFF (2M) (out of 8M)
assign DEAD_ZONE1	    			= (( Internal_Address > 32'h00BF_FFFF ) & ( Internal_Address < 32'h0200_0000 )) & !CPU_TIPn_i;
// SDRAM 
assign CS_MERA        				= ( Internal_Address[31:25] == 7'b0000_001 )  & ( UserData | UserProgram | SuperData | SuperProgram ) & !CPU_TIPn_i; 					//$0200_0000 - $03FF_FFFF (64Meg)
assign DEAD_ZONE2	    			= (( Internal_Address > 32'h03FF_FFFF ) & ( Internal_Address < 32'hFE00_0000 )) & !CPU_TIPn_i;
// Internal Registers
assign CS_GAVIN    					= ( Internal_Address[31:17] == 15'b1111_1110_1100_000 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FEC0_0000 - $FEC1_FFFF
assign CS_BEATRIX 					= ( Internal_Address[31:17] == 15'b1111_1110_1100_001 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FEC2_0000 - $FEC3_FFFF
// Vicky Channel A
assign CS_VICKY_A 					= ( Internal_Address[31:17] == 15'b1111_1110_1100_010 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FEC4_0000 - $FEC5_FFFF
assign CS_VICKY_MEM_A				= ( Internal_Address[31:17] == 15'b1111_1110_1100_011 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FEC6_0000 - $FEC7_FFFF
// Vicky Channel B
assign CS_VICKY_B 					= ( Internal_Address[31:17] == 15'b1111_1110_1100_100 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FEC8_0000 - $FEC9_FFFF
assign CS_VICKY_MEM_B 				= ( Internal_Address[31:17] == 15'b1111_1110_1100_101 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FECA_0000 - $FECB_FFFF
assign CS_FLASH						= ( Internal_Address[31:22] == 10'b1111_1111_11 ) 		& ( SuperData | SuperProgram | UserData | UserProgram ) & !CPU_TIPn_i;	//$FFC0_0000 - $FFFF_FFFF
assign CS_Registers 				= ( CS_GAVIN | CS_BEATRIX | CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B | CS_VRAM_A | CS_VRAM_B | CS_MERA);
assign CS_None_Cacheable 			= ( CS_GAVIN | CS_BEATRIX | CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B | CS_VRAM_A | CS_VRAM_B | CS_MERA); 
assign CS_NO_MANSLAND 				= DEAD_ZONE0 | DEAD_ZONE1 | DEAD_ZONE2;
assign DataCachePush 				= (FC[2:0] == 3'b000);
assign UserData 					= (FC[2:0] == 3'b001);		// LINE16
assign UserProgram 					= (FC[2:0] == 3'b010);
assign MMU_Table_Search_Data 		= (FC[2:0] == 3'b011); 
assign MMU_Table_Search_Code 		= (FC[2:0] == 3'b100);
assign SuperData 					= (FC[2:0] == 3'b101);		// LINE 16
assign SuperProgram 				= (FC[2:0] == 3'b110);
assign CPUSpace 					= ({CPU_TT1_2_FPGA, CPU_TT0_2_FPGA} == 2'b11 );
assign VICKY 						= (CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B | CS_VRAM_A | CS_VRAM_B );
assign iIRQ_GetVector_o 			= CS_GET_VECTOR_INT;	// WHen this is going high, the A1..A3 represent the Interrupt Level
//assign iBUS_WE_o 					= !CPU_TAn;

/*
always @ (*) begin
	casex({ CS_GET_VECTOR_INT, VICKY, CS_BEATRIX, CS_MERA, CS_GAVIN, CS_NO_MANSLAND})
		6'b00_0001: Data_Out_Mux = 32'h0000_0000;					// When CPU Access non-mapped devices or memory
		6'b00_001x: Data_Out_Mux = iBUS_D_GAVIN_i;					// GAVIN Registers (System)
		6'b00_01xx: Data_Out_Mux = iBUS_D_MERA_i;					// MERA SDRAM Output
		6'b00_1xxx: Data_Out_Mux = iBUS_D_BEATRIX_i;				// BEATRIX (Sound)
		6'b01_xxxx: Data_Out_Mux = iBUS_D_VICKY_i;					// VICKY (Graphics)
		6'b1x_xxxx: Data_Out_Mux = {24'h00_0000, iIRQ_Vector_i};	// Vector Interrupts Number
		default:   Data_Out_Mux =  32'hDEAD_BEEF;
	endcase
end
*/
always @ (posedge CPU_BCLK_x2) begin
	casex({ CS_GET_VECTOR_INT, VICKY, CS_BEATRIX, CS_MERA, CS_GAVIN, CS_NO_MANSLAND})
		6'b00_0001: Data_Out_Mux <= 32'h0000_0000;					// When CPU Access non-mapped devices or memory
		6'b00_001x: Data_Out_Mux <= iBUS_D_GAVIN_i;					// GAVIN Registers (System)
		6'b00_01xx: Data_Out_Mux <= iBUS_D_MERA_i;					// MERA SDRAM Output
		6'b00_1xxx: Data_Out_Mux <= iBUS_D_BEATRIX_i;				// BEATRIX (Sound)
		6'b01_xxxx: Data_Out_Mux <= iBUS_D_VICKY_i;					// VICKY (Graphics)
		6'b1x_xxxx: Data_Out_Mux <= {24'h00_0000, iIRQ_Vector_i};	// Vector Interrupts Number
		default:   Data_Out_Mux <=  32'hDEAD_BEEF;
	endcase
end


// BUFFERS SECTION
BIDIR_SIGNAL	CPUSIZ0_BIDIR (
	.datain ( SIZ0_Output  ),
	.oe ( 1'b0 ),
	.dataio ( CPU_SIZ0_io ),
	.dataout ( SIZ0 )
	);

BIDIR_SIGNAL	CPUSIZ1_BIDIR (
	.datain ( SIZ1_Output  ),
	.oe ( 1'b0 ),
	.dataio ( CPU_SIZ1_io ),
	.dataout ( SIZ1 )
	);

SIGNAL_TA_GROUP_OC	SIGNAL_TA_GROUP_OC_inst (
	.datain ( { CPU_TCIn_o, CPU_TBIn_o, CPU_TEAn_o, CPU_TAn_o}  ),
	.oe (  4'b1111 ),
	.dataio ( { CPU_TCIn_io, CPU_TBIn_io, CPU_TEAn_io, CPU_TAn_io}  ),
	.dataout ( TA_Group_i )
	);

BIDIR_SIGNAL	CPU_TT0_BIDIR (
	.datain ( CPU_TT0_2_CPU  ),
	.oe ( 1'b0 ),
	.dataio ( CPU_TT0_io ),
	.dataout ( CPU_TT0_2_FPGA )
	);

BIDIR_SIGNAL	CPU_TT1_BIDIR (
	.datain ( CPU_TT1_2_CPU  ),
	.oe ( 1'b0 ),
	.dataio ( CPU_TT1_io ),
	.dataout ( CPU_TT1_2_FPGA )
	);
	

BIDIR_SIGNAL	CPU_TS_BIDIR (
	.datain ( CPU_TSn_2_CPU  ),
	.oe ( 1'b0 ),
	.dataio ( CPU_TSn_io ),
	.dataout ( CPU_TSn_2_FPGA )
	);
// Bi-Dir Signal for the Rear/Write Signal
BIDIR_SIGNAL RW_BUFFER (
	.datain ( CPU_RWn_Out ),
	.oe ( TSF_FLASH2RAM_o ? Dbg_Mode_On_i : 1'b1),
	.dataio ( CPU_RWn_io ),
	.dataout ( CPU_RWn_i )
	);
// Bi-Dir BUS For ADDY
BIDIR_ADDY	BIDIR_ADDY_inst (
	.datain ( ADDY_Out ),
	.oe ( TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 32'hFFFF_FFFF : 32'h0000_0000 ) : 32'hFFFF_FFFF),
	.dataio ( CPU_A_io ),
	.dataout ( ADDY_In )
	);

// Bi-Dir BUS For ADDY -- MC68060 (not usefull here but for the sake of implementing a working circuit
BIDIR_DATA32	CPU_DATA_BIDIR32 (
	.datain ( Config_On ? 32'hFFFF_0000 : Data_Out ),
	.oe ( (DataBufferOELogic | Config_On) ? 32'hFFFF_FFFF : 32'h0000_0000 ),
	.dataio ( CPU_D_io ),
	.dataout ( Data_In )		// This is the Data Coming from the Exterial World and right now it is 16Bit Wide
	);

Transfer_Flash_2_Ram TRF_Module(

	.Clk_i( iBUS_Clk_o ),
	.Rst_i( Global_Reset_i ),		// Active High
	
	.Bus_A_o( TSF_ADDY ),
	
	.Flash_CS_o(  TSF_FLASH_CS ),
	.Flash_OEn_o( TSF_FLASH_OE ),
	
	.RAM_CS_o(  TSF_RAM_CS ),
	.RAM_WRn_o( TSF_RAM_WR ),
	.RAM_OEn_o( TSF_RAM_OE ),	

	.TransferDone( TSF_FLASH2RAM_o ),
	.StateMachine( TRF_StateMachine )
);
				 
				 
always @ ( posedge CPU_BCLK_o ) begin
	TSF_FLASH2RAM_EDGE <= TSF_FLASH2RAM_o;
	Dbg_RSTn_EDGE		<= Dbg_RSTn_i;		// Reset is active Low	
end
				 
// This is the State Machine to create a proper Reset Seq for MC68040 or MC68060

always @ ( posedge CPU_BCLK_o ) begin
	if ( Global_Reset_i ) begin // So while we are Going wait for the Transfer to finish, we keep CPU Reset Asserted
		CPU_RSTn <= 1'b0;		// 0 = Reset, 1= Normal Operation
		Config_On <= 1'b0;
		Drive_BGn <= 1'b0;
		SmallBootSM	<= SB_SM_IDLE;
	end
	else begin
		case( SmallBootSM ) 
		
		SB_SM_IDLE: 	begin 
			if (( {TSF_FLASH2RAM_EDGE, TSF_FLASH2RAM_o} == 2'b01 ) || ( {Dbg_RSTn_EDGE, Dbg_RSTn_i} == 2'b01 )) begin
				WaitCounter <= 5'd4;
				SmallBootSM <= SB_SM_WAIT1;
				CPU_RSTn <= 1'b0;									
			end
			else begin 
				CPU_RSTn <= Dbg_RSTn_i & TSF_FLASH2RAM_o;
				SmallBootSM <= SB_SM_IDLE;		
			end
		end
		
		SB_SM_WAIT1: begin
			if ( WaitCounter ) begin
				WaitCounter <= WaitCounter - 5'd1;
			end
			else begin 
				SmallBootSM <= SB_SM_WAIT2;
				Config_On <= 1'b1;
			end
		end 
		
		
		SB_SM_WAIT2: 	begin 
			SmallBootSM <= SB_SM_CFG;
			WaitCounter <= 5'd2;
		end
		
		SB_SM_CFG:	   begin 
			if ( WaitCounter ) begin
				WaitCounter <= WaitCounter - 5'd1;
			end
			else begin 
				SmallBootSM <= SB_SM_RELEASE;
				CPU_RSTn <= 1'b1;		
			end		
		end
		
		// The Reset is not anymore here		
		SB_SM_RELEASE: begin 
			Config_On <= 1'b0;		
			WaitCounter <= 5'd13;
			SmallBootSM <= SB_SM_REMOVE;			
		end
		
		SB_SM_REMOVE:  begin 
			if ( WaitCounter ) begin
				WaitCounter <= WaitCounter - 5'd1;
			end
			else begin 
				SmallBootSM <= SB_SM_WAIT22;
				Drive_BGn <= 1'b1;
			end			
		end
		
		SB_SM_WAIT22:  begin 
			SmallBootSM <= SB_SM_LETBGBE;		
		end
		
		SB_SM_LETBGBE: begin 
			Drive_BGn <= 1'b0;
			SmallBootSM <= SB_SM_IDLE;			
		end
		
	   default: begin 
			SmallBootSM <= SB_SM_IDLE;
		end 
		endcase
	end
end

always @ ( * ) begin

	if ( TSF_FLASH2RAM_o ) begin
	
		casex ( { Dbg_Mode_On_i, LineA3_A2_Switch} )
			2'b00: begin
				MEM_BURST_A2_o = ADDY_In[2];
				MEM_BURST_A3_o = ADDY_In[3];				
			end
			
			3'b01: begin
				MEM_BURST_A2_o = LineA3_A2[0];
				MEM_BURST_A3_o = LineA3_A2[1];	
			end
			
			3'b1x: begin
				MEM_BURST_A2_o = Dbg_Address_Out_i[2];
				MEM_BURST_A3_o = Dbg_Address_Out_i[3];				
			end
		endcase
	end
	else begin
				MEM_BURST_A2_o = TSF_ADDY[2];
				MEM_BURST_A3_o = TSF_ADDY[3];		
	end

end


// Drive the internal 8 Bit bus
always @ ( * ) begin
	if (!SIZ1 & SIZ0) begin
		case ( Internal_Address[1:0] )
			2'b00: iBUS_D_Write8_o = Data_In[31:24];
			2'b01: iBUS_D_Write8_o = Data_In[23:16];
			2'b10: iBUS_D_Write8_o = Data_In[15:8];
			2'b11: iBUS_D_Write8_o = Data_In[7:0];
		endcase
	end
	else begin
		iBUS_D_Write8_o = 8'h00;
	end
end
// Drive the internal 16 Bit bus
always @ ( * ) begin
	if (SIZ1 & !SIZ0) begin
		if ( Internal_Address[1] ) begin
			iBUS_D_Write16_o = Data_In[15:0];
		end
		else begin
			iBUS_D_Write16_o = Data_In[31:16];
		end
	end
	else begin
		iBUS_D_Write16_o = 16'h0000;
	end
end

//assign iBUS_D_Write32_o = Data_In[31:0];
always @ ( * ) begin
	if (!SIZ1 & !SIZ0) begin
		iBUS_D_Write32_o = Data_In[31:0];
	end
	else begin
		iBUS_D_Write32_o = 32'h0000_0000;
	end
end

/*
always @ ( posedge CPU_BCLK_o ) begin
	//if ( !CPU_CLK_ENn_o ) begin 
		TSF_FLASH2RAM_EDGE1 <= TSF_FLASH2RAM_o;
		BTT <= BTT << 1'b1;
		if ( {TSF_FLASH2RAM_EDGE1, TSF_FLASH2RAM_o} == 2'b01 ) begin
			BTT <= 8'hff;
		end 
	//end
end 

always @ ( posedge CPU_BCLK_o ) begin
	//if ( !CPU_CLK_ENn_o ) begin 
		CPU_BGn_o_DLY <= CPU_BRn_i;
	//end
end
*/
wire  Flash_OE = (!DTACK & CS_FLASH) | (  Wait_FLASH_TA_i[2] & CS_FLASH ) | (  Wait_FLASH_TA_i[1] & CS_FLASH ) | (  Wait_FLASH_TA_i[0] & CS_FLASH );
always @ (*) begin
	casex( iIRQ_Interrupt_i )
		7'b000_0000: begin IPLOut= 3'b111; end	
		7'b000_0001: begin IPLOut= 3'b110; end // Group 5
		7'b000_001x: begin IPLOut= 3'b101; end // Group 4	
		7'b000_01xx: begin IPLOut= 3'b100; end // Group 3
		7'b000_1xxx: begin IPLOut= 3'b011; end // Group 2
		7'b001_xxxx: begin IPLOut= 3'b010; end // Group 1
		7'b01x_xxxx: begin IPLOut= 3'b001; end // Vicky $1E
		7'b1xx_xxxx: begin IPLOut= 3'b000; end
		default: begin IPLOut= 3'b111; end
	endcase
end

always @ (*) begin
	if ( TSF_FLASH2RAM_o ) begin
			casex ( { Dbg_Mode_On_i, LineA3_A2_Switch} )
			2'b00: begin
				LOCAL_MEM_SRAM_WEn_o = !(!CPU_RWn_i & !CPU_TAn_o & CS_SRAM & !CPU_BCLK_o);  // Just Do the Write when the Clock is LOW
				LOCAL_MEM_SRAM_OEn_o = !( CPU_RWn_i & CS_SRAM );
			end
			
			3'b01: begin
				if ( CPU_RWn_i ) begin
					LOCAL_MEM_SRAM_OEn_o = 1'b0;
					LOCAL_MEM_SRAM_WEn_o = 1'b1;
				end
				else begin
					LOCAL_MEM_SRAM_OEn_o = 1'b1;
					LOCAL_MEM_SRAM_WEn_o = 1'b0;
				end
			end
			
			3'b1x: begin
				LOCAL_MEM_SRAM_OEn_o = Dbg_OE_i;
				LOCAL_MEM_SRAM_WEn_o = Dbg_RWn_Out_i;
			end
		endcase
	end
	else begin
		LOCAL_MEM_SRAM_OEn_o = TSF_RAM_OE;
		LOCAL_MEM_SRAM_WEn_o = TSF_RAM_WR;
	end
end

			
// LINE TRANSFER DETECT
always @ (posedge CPU_BCLK_o) begin
	if ( Local_Reset ) begin
		SmallST <= IDLE;
		LineA3_A2_Switch <= 1'b0;
		LineA3_A2 <= 2'b00;
	end
	else begin
		TBI_TA <= TBI_TA << 1'b1;

		case ( SmallST )
			IDLE: begin
				if (( TSn == 1'b0 ) && LineTransfer) begin
					LineA3_A2_Switch <= 1'b1;
					LineA3_A2 		 <= ADDY_In[3:2];
					TBI_TA    		 <= 8'b11111111;
					SmallST	<= ST0;
				end
			end

			//00
			ST0: begin
				LineA3_A2 <= LineA3_A2 + 2'b01;
				SmallST	<= ST1;		
			end

			//01
			ST1: begin
				LineA3_A2 <= LineA3_A2 + 2'b01;
				SmallST	<= ST2;
			end

			//
			ST2: begin
				LineA3_A2 <= LineA3_A2 + 2'b01;
				SmallST	<= ST3;
			end

			ST3: begin
				LineA3_A2_Switch <= 1'b0;
				SmallST	<= IDLE;
			end
			
			default: begin 
				SmallST	<= IDLE;			
		    end 
		endcase
		//end	
	end
end


reg TA;

always @ (posedge iBUS_Clk_o) begin
	if ( Local_Reset ) begin
		Pre_DTACK <= 1'b1;
	end
	else begin
		Pre_DTACK <= TSn;
	end
end

always @ (posedge iBUS_Clk_o) begin
	Wait_FLASH_TA_i[0] <= !TSn;
	Wait_FLASH_TA_i[1] <= Wait_FLASH_TA_i[0];
	Wait_FLASH_TA_i[2] <= Wait_FLASH_TA_i[1];
	Wait_FLASH_TA_i[3] <= Wait_FLASH_TA_i[2];
	Wait_FLASH_TA_i[4] <= Wait_FLASH_TA_i[3];	
end

always @ ( * ) begin

	case ( { LineTransfer, CS_MERA , CS_FLASH, CS_RTC_i, CS_LPC_i, CS_Unity_i } ) 	
		//7'b000_0000: begin TA = Pre_DTACK; 				end
		6'b000_000: begin TA = !Wait_FLASH_TA_i[1]; 	end
		6'b000_001: begin TA = !Wait_Unity_TA_i;		end
		6'b000_010: begin TA = !Wait_LPC_TA_i;			end
		6'b000_100: begin TA = !Wait_RTC_TA_i;			end
		6'b001_000: begin TA = !Wait_FLASH_TA_i[2];		end
		6'b010_000: begin TA = !Wait_MERA_TA_i;			end		
		6'b100_000: begin TA = !TBI_TA[3];				end 
		default: 	 begin TA = Pre_DTACK;				end
	endcase
end

always @ (negedge iBUS_Clk_o) begin
	if ( Local_Reset ) begin
		DTACK <= 1'b1;
	end
	else begin
		DTACK <= TA;
	end
end

assign iBUS_WE_o = !DTACK;




////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
wire [143:0] TP;
wire  Trigger;

assign TP[31:0] 	= {ADDY_In[31:4], MEM_BURST_A3_o, MEM_BURST_A2_o, ADDY_In[1:0]};
assign TP[63:32]  	= Data_In;
assign TP[95:64]  	= Data_Out;
assign TP[99:96]   	= { !UUD, !UMD, !LMD, !LLD};
assign TP[101:100]	= {SIZ1, SIZ0};
assign TP[102] 		= TSn;
assign TP[103]		= CPU_TAn_o;
assign TP[104]   	= CPU_TIPn_i;
assign TP[105]		= CPU_BRn_i;
assign TP[106]		= CPU_BBn_io;	// This Indicate the Bus Being Busy it is a Bidir Signal
assign TP[108:107]	= {CPU_TT1_2_FPGA, CPU_TT0_2_FPGA};
assign TP[111:109]	= FC[2:0];
assign TP[112]		= CPU_RWn_i;
assign TP[115:113]	= IPLOut;
assign TP[119:116]  = { CPU_PST3_i, CPU_PST2_i, CPU_PST1_i, CPU_PST0_i};
assign TP[120]		= CPU_CIOUTn_i;
assign TP[121]		= CS_GAVIN;
assign TP[125:122]  = TA_Group_i;
assign TP[126] 		= iBUS_RWn_o;
assign TP[127]  	= CPU_AVECn_o;
assign TP[128] 		= CPU_BCLK_o;
assign TP[129] 		= CPU_LOCKn_i;
assign TP[130]		= (iIRQ_AutoVector_i & CS_GET_VECTOR_INT );
assign TP[131]		= LineTransfer;
assign TP[132]		= DataBufferOELogic;
assign TP[133]		= VICKY;
assign TP[134]		= LOCAL_MEM_SRAM_CSn_o;
assign TP[138:135]	= LOCAL_MEM_SRAM_BEn_o[3:0];
assign TP[139]		= LOCAL_MEM_SRAM_OEn_o;
assign TP[140]		= LOCAL_MEM_SRAM_WEn_o;
assign TP[141]		= LOCAL_MEM_FLASH_CSn_o;
assign TP[142]		= LOCAL_MEM_FLASH_OEn_o;
assign TP[143]		= CPU_RSTn;

wire [31:0] Source;
wire [31:0] Probe;
SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);

assign Probe = 32'h0000_0000;
assign Trigger = ((ADDY_In == Source) & !Dbg_Mode_On_i) & TSF_FLASH2RAM_o;

TinyChipScope CHIPSCOPE68K (
	.acq_data_in    (TP),    		// tap.acq_data_in
	.acq_trigger_in (Trigger), 		// trigger.acq_trigger_in
	.acq_clk        (Clk_133Mhz_i),  // acq_clk.clk
	.trigger_in     (Trigger)       // trigger_in.trigger_in
);

endmodule

/*
//CPU_BCLK_x2
reg [1:0] 	Flash_Slip_Falling_Edge;		// Flash Wait
reg [7:0] 	RTC_Slip_Falling_Edge;			// RTC Wait
reg [35:0] 	LPC_Slip_Falling_Edge;			// LPC Wait
reg [15:0] 	UNITY_Slip_Falling_Edge;  		// UNITY Wait ( NIC / IDE )
reg [3:0] 	MOVE16_Slip_Falling_Edge;		// Line Transfer
reg 		TSn_Slip_Rising_Edge;			//
reg      TSn_Slip_Rising_Edge1;

always @ (posedge CPU_BCLK_o) begin
		TSn_Slip_Rising_Edge <= TSn;
end 


always @ (negedge CPU_BCLK_o) begin

	if ( Local_Reset ) begin
		Flash_Slip_Falling_Edge <= 2'b11;
		RTC_Slip_Falling_Edge <= 8'hFF;
		LPC_Slip_Falling_Edge <= 36'hF_FFFF_FFFF;
		UNITY_Slip_Falling_Edge <= 16'hFFFF;
		MOVE16_Slip_Falling_Edge <= 4'b1111;
		CPU_TAn <= 1'b1;
	end
	else begin 
		LPC_Slip_Falling_Edge <= LPC_Slip_Falling_Edge << 1'b1;
		RTC_Slip_Falling_Edge <= RTC_Slip_Falling_Edge << 1'b1;
		MOVE16_Slip_Falling_Edge <= MOVE16_Slip_Falling_Edge << 1'b1;	
		UNITY_Slip_Falling_Edge <= UNITY_Slip_Falling_Edge << 1'b1;
		Flash_Slip_Falling_Edge <= Flash_Slip_Falling_Edge << 1'b1;

		case ( {LineTransfer, ( CS_Unity_i | CS_IDE_i), CS_RTC_i, CS_LPC_i, CS_FLASH})

		// RAM (0 Clock Delay @ 33Mhz)
		5'b0_0000: begin 
			CPU_TAn <= TSn_Slip_Rising_Edge1;
			TSn_Slip_Rising_Edge1 <= TSn_Slip_Rising_Edge;
			
			Flash_Slip_Falling_Edge <= 2'b11;
			LPC_Slip_Falling_Edge <= 36'hF_FFFF_FFFF;
			RTC_Slip_Falling_Edge <= 8'b1111_1111;
			UNITY_Slip_Falling_Edge <= 16'hFFFF;			
			MOVE16_Slip_Falling_Edge <= 4'b1111;			
		end 

		// FLASH (1 Clock Delay @ 33Mhz)
		5'b0_0001: begin
			CPU_TAn <= Flash_Slip_Falling_Edge[1];
			Flash_Slip_Falling_Edge[0] <= TSn_Slip_Rising_Edge;
			LPC_Slip_Falling_Edge <= 36'hF_FFFF_FFFF;
			RTC_Slip_Falling_Edge <= 8'b1111_1111;
			UNITY_Slip_Falling_Edge <= 16'hFFFF;			
			MOVE16_Slip_Falling_Edge <= 4'b1111;			
		end 

		// LPC (no Wait for Write, )
		5'b0_0010: begin 
			Flash_Slip_Falling_Edge <= 2'b11;			
			if ( CPU_RWn_i ) begin 
				// Read
				CPU_TAn <= LPC_Slip_Falling_Edge[35];			
				LPC_Slip_Falling_Edge[0] <= TSn_Slip_Rising_Edge;
			end 
			else begin 
				// Write - Wait Like 8 Clock Cycles
				CPU_TAn <= LPC_Slip_Falling_Edge[7];			
				LPC_Slip_Falling_Edge[0] <= TSn_Slip_Rising_Edge;
			end 
			RTC_Slip_Falling_Edge <= 8'b1111_1111;
			UNITY_Slip_Falling_Edge <= 16'hFFFF;
			MOVE16_Slip_Falling_Edge <= 4'b1111;			
		end 

		// RTC (8 Clock Wait for Read and Write @ 33Mhz)
		5'b0_0100: begin
			CPU_TAn <= RTC_Slip_Falling_Edge[7];			
			Flash_Slip_Falling_Edge <= 2'b11;
			LPC_Slip_Falling_Edge <= 36'hF_FFFF_FFFF;
			UNITY_Slip_Falling_Edge <= 16'hFFFF;				
			RTC_Slip_Falling_Edge[0] <= TSn_Slip_Rising_Edge;
			MOVE16_Slip_Falling_Edge <= 4'b1111;			
		end

		// UNITY (NIC + IDE) (16 Clocks Wait for Read and Write @ 33Mhz)
		5'b0_1000: begin
			CPU_TAn <= UNITY_Slip_Falling_Edge[8];
			Flash_Slip_Falling_Edge <= 2'b11;
			LPC_Slip_Falling_Edge <= 36'hF_FFFF_FFFF;			
			RTC_Slip_Falling_Edge <= 8'b1111_1111;
			UNITY_Slip_Falling_Edge[0] <= TSn_Slip_Rising_Edge;			
			MOVE16_Slip_Falling_Edge <= 4'b1111;			
		end		

		// MOVE16
		5'b1_0000: begin
			CPU_TAn <= MOVE16_Slip_Falling_Edge[3];
			Flash_Slip_Falling_Edge <= 2'b11;
			LPC_Slip_Falling_Edge <= 36'hF_FFFF_FFFF;
			RTC_Slip_Falling_Edge <= 8'b1111_1111;
			UNITY_Slip_Falling_Edge <= 16'hFFFF;				
			MOVE16_Slip_Falling_Edge[0] <= TSn_Slip_Rising_Edge;			
		end 	

		// Othe cases of Access for the time being
		default: begin 
			CPU_TAn <= TSn_Slip_Rising_Edge;
			Flash_Slip_Falling_Edge <= 2'b11;
			LPC_Slip_Falling_Edge <= 36'hF_FFFF_FFFF;
			RTC_Slip_Falling_Edge <= 8'b1111_1111;
			UNITY_Slip_Falling_Edge <= 16'hFFFF;				
			MOVE16_Slip_Falling_Edge <= 4'b1111;
		end 
		endcase
	end 

end 
*/
