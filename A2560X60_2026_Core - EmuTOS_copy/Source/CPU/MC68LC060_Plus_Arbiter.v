// Stefany is here
module MC68LC060_Plus_Arbiter (

input		wire				Global_Reset_i,

output	    wire				Master_Resetn_o,		// System Reset After Data has been transfered

input		wire				Clk_133Mhz_i,

// MC68040 General A2560K Interf/ace
inout		wire	[31:0]	    CPU_A_io,	// IO
inout       wire	[31:0]	   	CPU_D_io,	// IO - D[31:0] - ( D[31:24] LSB ) - ( D[7:0] MSB )

output	    reg					MEM_BURST_A2_o,
output      reg					MEM_BURST_A3_o,
//CPU Control (MC68040V)
output	    wire				CPU_BCLK_o,
output	    wire				CPU_CLK_ENn_o,
output	    wire				CPU_AVECn_o,
// Bus Control Signals
output	    wire				CPU_BGn_o,
input		wire				CPU_BBn_io,
input		wire				CPU_BRn_i,

output	    wire				CPU_CDISn_o,
input		wire				CPU_CIOUTn_i,
input		wire				CPU_IPENDn_i,
output	    wire	[2:0]		CPU_IPLn_o,
output	    wire				CPU_MDISn_o,
input		wire	[4:0]		CPU_PST_i,

input		wire				CPU_RWn_i,				// IO (MC68040)
output	    wire				CPU_RESET_INn_o,		// THis is the CPU Reset In - Sometimes it can be IO
input		wire				CPU_RESET_OUTn_i,		// This is the MC68040 Reset Out Function Called by the Instruction Reset
input		wire	[1:0]		CPU_SIZ_i,			// I (MC68060)
// TA Group
output		wire				CPU_TAn_o,				// IO (MC68040)
output		wire				CPU_TEAn_o,
output		wire				CPU_TBIn_o,				//
output		wire				CPU_TCIn_o,
input		wire				CPU_TIPn_i,
inout		wire				CPU_TSn_io,				// IO (MC68040)
input		wire	[1:0]		CPU_TLN_i,
input		wire	[2:0]		CPU_TM_i,
input		wire				CPU_TT0_i,				// IO (MC68040)
inout		wire				CPU_TT1_io,				// IO (MC68040)
input		wire	[1:0]		CPU_UPA_i,
// New Stuff
input		wire	[3:0]		CPU_BSn_i, 				// Byte Select
inout		wire				CPU_BTTn_io, 			// Bus Tenure Termination
output		wire				CPU_BGRn_o, 			// Bus Grant Relinquish Control
// Flash (4Meg)
output		wire				LOCAL_MEM_FLASH_CSn_o,
output		wire				LOCAL_MEM_FLASH_OEn_o,
output		wire				LOCAL_MEM_FLASH_WEn_o,
// SRAM (4Meg)
output		reg	[3:0]			LOCAL_MEM_SRAM_BEn_o,
output		reg					LOCAL_MEM_SRAM_CSn_o,
output		reg					LOCAL_MEM_SRAM_OEn_o,
output		reg					LOCAL_MEM_SRAM_WEn_o,
// Slave Interface
output	    wire				iBUS_1xClk_o,
output    	wire   				iBUS_2xClk_o,
output		wire	[31:0]		iBUS_A_o,
output		reg		[7:0]		iBUS_D_Write8_o,
output		reg		[15:0]		iBUS_D_Write16_o,
output		reg		[31:0]		iBUS_D_Write32_o,
output		wire	[31:0]		iBUS_D_Out_virgin_o,
output		wire	[1:0]		iBUS_D_Siz_o,
output		wire				iBUS_RWn_o,
output		wire	[3:0]		iBUS_BE_o,
output		wire				iBUS_WE_o,
output		wire				iBUS_A_Valid_o,

input		wire	[31:0]		iBUS_D_GAVIN_i,
input		wire	[31:0]		iBUS_D_BEATRIX_i,
input		wire	[31:0]		iBUS_D_VICKY_i,
input		wire	[31:0]		iBUS_D_MERA_i,
input  		wire    [31:0] 		iBUS_D_VRAM_A_i,
input  		wire    [31:0]		iBUS_D_VRAM_B_i,
// Old New Stuff
output		wire				iBUS_CS_GAVIN_o,
output		wire				iBUS_CS_BEATRIX_o,
output		wire				iBUS_CS_VICKY_A_o,
output		wire				iBUS_CS_VICKY_MEM_A_o,
output		wire				iBUS_CS_VICKY_B_o,
output		wire				iBUS_CS_VICKY_MEM_B_o,
output		wire				iBUS_CS_VRAM_A_o,
output		wire				iBUS_CS_VRAM_B_o,
output		wire				iBUS_CS_MERA_o,
// IRQ Signals
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
// THose 2 Chips Selects Needs Wait-States
input		wire				Wait_Unity_TA_i,
input		wire				Wait_LPC_TA_i,
input		wire				Wait_RTC_TA_i,
input		wire				Wait_MERA_TA_i, 

input 		wire  				Wait_BufferA_i,
input 		wire  				Wait_BufferB_i,
input 		wire   				Wait_BufferA_TA_i,
input 		wire   				Wait_BufferB_TA_i,

input		wire				CS_Unity_i,
input		wire				CS_LPC_i,
input		wire				CS_RTC_i,
// Signal for Sharing the CPU BUS Mastership
output  	wire   	[1:0]		Channel_Select_o,
// SDMA & MemText Interface
input		wire				Ext_RAM_OEn_i,
input		wire				Ext_RAM_WEn_i,
input		wire	[3:0]		Ext_RAM_BEn_i,
input		wire	[31:0]		Ext_RAM_Addy_i,
input		wire	[31:0]		Ext_RAM_Data_i,
output		wire	[31:0]		Ext_RAM_Data_o,

input		wire 				iBUS_MTXT_BRn_i,
output		wire 				iBUS_MTXT_BGn_o,
input		wire 				iBUS_SDMA_BRn_i,
output		wire 				iBUS_SDMA_BGn_o,
input		wire 				iBUS_VDMA_BRn_i,
output		wire 				iBUS_VDMA_BGn_o,
input		wire 				iBUS_DEBUG_BRn_i,
output		wire 				iBUS_DEBUG_BGn_o
);

// inputs
// CLAn -- OKAY
// TAn --
// TRAn -- OKAY
// TEAn -- OKAY
// TBIn -- OKAY
// TCIn -- OKAY
// BGn
// BGRn
// CDISn
// MDISn
// CLK
// CLKEN
//---- Bidir
// TT1
// TSn
// BBn
// BTTn



//`define MC68040


/*
PST4 = Supervisor Mode
PST3 = Branch Instruction
PST2 = Taken Branch Instruction
PST1, PST0 = Number of Instructions Completed that Cycle
*/

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
//  0   0   1 : Debug Access (060)
//  0   1   0 : Reserved
//  0   1   1 : Logical Function 3
//  1   0   0 : Logical Function 4
//  1   0   1 : Debug Pipe Control Mode Access
//  1   1   0 : Debug Pipe Control Mode Access
//  1   1   1 : Logical Function 7

// Byte Select Lines
// D31.24|D23.16|D15.8|D7.0
// BS0n:BS1n:BS2n:BS3n
//  0    1    1    1 : Bxxx Byte 
//  1    0    1    1 : xBxx Byte
//  1    1    0    1 : xxBx Byte 
//  1    1    1    0 : xxxB Byte 
//  0    0    1    1 : WWxx Word
//  1    1    0    0 : xxWW Word
//  0    0    0    0 : LLLL Word
//  0    0    0    0 : LLLL Transfer

// Memory Alignment
// 32bits Access
// D[31:24] offset 0x03
// D[23:16] offset 0x01
// D[15:8] 	offset 0x02
// D[7:0] 	offset 0x03

// 16bits Access
// D[31:16] offset 0x00
// D[15:0] 	offset 0x02

// SIZ1 : SIZ0 : A1 : A0 
//  0       0     X    X  : D[31:0]

//  0       1     0    0  : D[31:24]
//  0       1     0    1  : D[23:16]
//  0       1     1    0  : D[15:8]
//  0       1     1    1  : D[7:0]

//  1       0     1    0  : D[31:16]
//  1       0     1    1  : D[15:0]

//  1       1     X    X  : D[31:0]			// LINE ACCESS

reg 				MEM_BURST_A2;
reg 				MEM_BURST_A3;
reg 	[2:0] 		IPLOut;
reg 	[2:0] 		SmallBootSM;
reg 				CPU_RSTn;
reg 	[4:0] 		WaitCounter;
reg 				Config_On;
reg 				Drive_BGn;
reg 				TSF_FLASH2RAM_EDGE;
reg 	[1:0] 		LineA3_A2;
reg 	[2:0] 		SmallST;
reg 	[7:0]		TBI_TA;
reg					LineA3_A2_Switch;
reg 	[1:0] 		ClockDivide;
reg 				DTACK = 1'b1;
reg 				Pre_DTACK = 1'b1;
reg 				TA;
reg 	[4:0] 		Wait_FLASH_TA_i;

reg  	[31:0]   	Data_Out_Mux;
reg		 			TSF_FLASH2RAM_EDGE1;
reg 	[7:0] 		BTT;
reg 				Dbg_RSTn_EDGE;
reg 				Addy_BiDir_OE;
reg 	[31:0] 		ADDY_Out;
reg		[31:0]		Data_Out;

localparam   		SB_SM_IDLE		= 3'b000,
				 	SB_SM_WAIT1   	= 3'b001,
				 	SB_SM_WAIT2 	= 3'b010, // Wait some clocks
				 	SB_SM_CFG		= 3'b011, // Present the config 
				 	SB_SM_RELEASE	= 3'b100, // Wait a couple of clocks
				 	SB_SM_REMOVE	= 3'b101, // Remove Config, go back to normal.
				 	SB_SM_WAIT22  	= 3'b110, // Bring BG Down
				 	SB_SM_LETBGBE 	= 3'b111; // Let BG be down now.

localparam 			IDLE = 3'b000,		// TS Cycle (Capture A3-A2 Value)
					ST0  = 3'b001,		// TA0 Cycle - Increment A3..A2 for next cycle
					ST1  = 3'b010,		// TA1 Cycle - Incrememt A3..A2 for next cycle
					ST2  = 3'b011,		// TA2 Cycle - Increment A3..A2 for next Cycle
					ST3  = 3'b100;		// We are done, last clock were TA is low

wire 				LineTransfer;
wire 				Local_Reset;
wire 				TSF_RAM_CS;
wire 				TSF_RAM_WR;
wire 				TSF_RAM_OE;

wire 				TSF_FLASH_CS;
wire 				TSF_FLASH_OE;

wire 	[31:0]		TSF_ADDY;
wire 	[3:0] 		TRF_StateMachine;
wire 				UUD, UMD, LMD, LLD;
wire 				LineOr32Bits;
wire 	[2:0]  		FC;
wire 				BERRn;
wire 	[31:0] 		Internal_Address;
wire 				CPU_BTTn_i;
wire 				CPU_TAn_2_FPGA;
wire 				CPU_TT1_2_FPGA;
wire 				CPU_TSn_2_FPGA;
wire 				CPU_TT1_2_CPU;
wire 				CPU_TSn_2_CPU;
wire 				TSn;	
wire 				Remote_Reset_Ctrl;
wire 				Remote_Reset_Direction;
wire 				Remote_Halt_Ctrl;
wire 	[31:0]		Data_In;
wire 	[31:0] 		ADDY_In;
wire  				iBUS_Master;
wire 				DataBufferOELogic;

wire 				CS_Registers;
wire 				CS_None_Cacheable;
//wire 				DataCachePush; // Not Used
wire 				UserData;
wire 				UserProgram;
//wire 				MMU_Table_Search_Data; 	// Not Used
//wire 				MMU_Table_Search_Code; 	// Not Used
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
wire   				CPU_BCLK_x2;

/*
/IPL2  Asserted (0): Extra Data Write Hold Mode Enabled
/IPL2  Negated (1): Extra Data Write Hold Mode Disabled
/IPL1  Asserted (0): Native-MC68060 Acknowledge Termination Protocol
/IPL1  Negated (1): MC68040 Acknowledge Termination Protocol
/IPL0  Asserted (0): Acknowledge Termination Ignore State Capability Enabled
/IPL0  Negated (1): Acknowledge Termination Ignore State Capability Disabled
*/
// CPU Signals Assignments
assign CPU_CDISn_o 		= 1'b1;
assign CPU_MDISn_o 		= 1'b1;
assign CPU_BCLK_o 		= ClockDivide[1];		// Let's begin with 33Mhz Clock
assign CPU_BCLK_x2 		= ClockDivide[0];		// 66Mhz


assign CPU_CLK_ENn_o 	= 1'b0;					// Clock is enabled when 0 (needs to be enabled with Rising Edge of Clk_BLOCK)
assign CPU_RESET_INn_o 	= CPU_RSTn;

assign CPU_TAn_o        = CS_NO_MANSLAND ? 1'b1 : DTACK;
assign CPU_TEAn_o 		= CS_NO_MANSLAND ? DTACK : 1'b1;
assign CPU_TCIn_o 		= CS_None_Cacheable ? DTACK : 1'b1;
assign CPU_TBIn_o		= LineTransfer ? 1'b1 :  CPU_SIZ_i[1:0] == 2'b11  ? DTACK : 1'b1 ; // So right now, LINE16 is allowed only in SRAM
assign CPU_AVECn_o 		= (iIRQ_AutoVector_i & CS_GET_VECTOR_INT ) ? DTACK : 1'b1;	// AVEC is the signal that terminate the cycle when the AutoVector is triggered
assign CPU_IPLn_o		= Config_On ? 3'b111 : IPLOut[2:0];

// iBUS Assignments
assign iBUS_1xClk_o 				= ClockDivide[1];		// Local Clock will always be 33Mhz
assign iBUS_2xClk_o					= ClockDivide[0];		// Local Clock will always be 66Mhz
assign iBUS_D_Siz_o 				= CPU_SIZ_i[1:0];
assign iBUS_RWn_o 					= CPU_RWn_i;
// Chip Select Outputs
assign iBUS_CS_GAVIN_o				= CS_GAVIN;		
assign iBUS_CS_BEATRIX_o			= CS_BEATRIX;
assign iBUS_CS_VICKY_A_o  			= CS_VICKY_A;
assign iBUS_CS_VICKY_MEM_A_o		= CS_VICKY_MEM_A;
assign iBUS_CS_VICKY_B_o			= CS_VICKY_B;		
assign iBUS_CS_VICKY_MEM_B_o		= CS_VICKY_MEM_B;	
assign iBUS_CS_VRAM_A_o				= CS_VRAM_A;
assign iBUS_CS_VRAM_B_o				= CS_VRAM_B;
assign iBUS_CS_MERA_o 				= CS_MERA;

assign iBUS_A_Valid_o 				= !TSn;
assign iBUS_A_o 					= Internal_Address;
assign iBUS_D_Out_virgin_o 			= Data_In[31:0];
assign iBUS_BE_o[0]   				= LLD; 	// BSn_i[0] - D31-D24
assign iBUS_BE_o[1]					= LMD;	// BSn_i[1] - D23-D16
assign iBUS_BE_o[2]					= UMD;	// BSn_i[2] - D15-D8
assign iBUS_BE_o[3]					= UUD;	// BSn_i[3] - D7-D0
assign iIRQ_GetVector_o 			= CS_GET_VECTOR_INT;	// WHen this is going high, the A1..A3 represent the Interrupt Level
assign MEM_BURST_A2_o 				= iBUS_Master ? ADDY_Out[2] : MEM_BURST_A2;
assign MEM_BURST_A3_o 				= iBUS_Master ? ADDY_Out[3] : MEM_BURST_A3;

// MISC
assign Local_Reset 				= !TSF_FLASH2RAM_o;
assign FC[2:0] 					= ({CPU_TT1_2_FPGA, CPU_TT0_i} == 2'b11) ? 3'b111 	: CPU_TM_i[2:0];
assign TSn 						= CPU_TSn_2_FPGA;
//assign ADDY_Out 				= TSF_FLASH2RAM_o ? { Dbg_Address_Out_i[31:0]} 		: TSF_ADDY[31:0];	// 
assign LineOr32Bits 			= (CPU_SIZ_i[1:0] == 2'b00) | (CPU_SIZ_i[1:0] == 2'b11);	//32bits transactor or Line Burst
//`ifdef MC68040
assign UUD 						= (!Internal_Address[0] & !Internal_Address[1]) | LineOr32Bits;		// Describe D31:D24
assign UMD 						= ( Internal_Address[0] & !Internal_Address[1]) | (!Internal_Address[1] & CPU_SIZ_i[1]) | LineOr32Bits; // Describe D23:D16
assign LMD 						= (!Internal_Address[0] & Internal_Address[1]) | LineOr32Bits;	// Describe [D15:D8]
assign LLD 						= ( Internal_Address[0] &  Internal_Address[1]) | (Internal_Address[1] & CPU_SIZ_i[1]) | LineOr32Bits; // Describe [
//`else
//assign UUD 						= !CPU_BSn_i[0] | LineOr32Bits;
//assign UMD 						= !CPU_BSn_i[1] | LineOr32Bits;
//assign LMD 						= !CPU_BSn_i[2] | LineOr32Bits;
//assign LLD 						= !CPU_BSn_i[3] | LineOr32Bits;
//`endif


assign Internal_Address 		= ADDY_In[31:0];
assign Master_Resetn_o 			= TSF_FLASH2RAM_o;
assign LineTransfer 			= !CPU_TT1_2_FPGA & CPU_TT0_i & (CPU_SIZ_i[1:0] == 2'b11) & ( CS_SRAM | CS_MERA | CS_VRAM_A | CS_VRAM_B);		//TT[1:0] == 01, SIZE == 11
// RAM Management
assign Ext_RAM_Data_o 			= Data_In;

// Strobes
always @ (*) begin
	if ( TSF_FLASH2RAM_o ) begin
			casex ( {iBUS_Master, Dbg_Mode_On_i, LineA3_A2_Switch} )
			3'b000: begin
				LOCAL_MEM_SRAM_WEn_o = !(!CPU_RWn_i & !DTACK & CS_SRAM & !CPU_BCLK_o);  // Just Do the Write when the Clock is LOW
				LOCAL_MEM_SRAM_OEn_o = !( CPU_RWn_i & CS_SRAM );
			end
			
			3'b001: begin
				if ( CPU_RWn_i ) begin
					LOCAL_MEM_SRAM_OEn_o = 1'b0;
					LOCAL_MEM_SRAM_WEn_o = 1'b1;
				end
				else begin
					LOCAL_MEM_SRAM_OEn_o = 1'b1;
					LOCAL_MEM_SRAM_WEn_o = 1'b0;
				end
			end
			
			3'b01x: begin
				LOCAL_MEM_SRAM_OEn_o 	= Dbg_OE_i;
				LOCAL_MEM_SRAM_WEn_o 	= Dbg_RWn_Out_i;
			end

			3'b1xx: begin 
				LOCAL_MEM_SRAM_OEn_o 	= Ext_RAM_OEn_i;
				LOCAL_MEM_SRAM_WEn_o 	= Ext_RAM_WEn_i;
			end

			default: begin 
				LOCAL_MEM_SRAM_OEn_o 	= 1'b1;
				LOCAL_MEM_SRAM_WEn_o 	= 1'b1;
			end 
		endcase
	end
	else begin
		LOCAL_MEM_SRAM_OEn_o = TSF_RAM_OE;
		LOCAL_MEM_SRAM_WEn_o = TSF_RAM_WR;
	end
end

always @ ( * ) begin 
	casex ( {!TSF_FLASH2RAM_o, Dbg_Mode_On_i, iBUS_Master } )
		// No Special Access - This is normal Transactions
		3'b000: begin 
			LOCAL_MEM_SRAM_CSn_o = !CS_SRAM; 		
			LOCAL_MEM_SRAM_BEn_o[3:0] = { !UUD, !UMD, !LMD, !LLD};
			Addy_BiDir_OE = 1'b0;
			ADDY_Out = 32'h0000_0000;
			Data_Out = Data_Out_Mux;
			DataBufferOELogic = (CPU_RWn_i & ( CS_Registers | CS_GET_VECTOR_INT | CS_NO_MANSLAND | CS_MERA | CS_VRAM_B | CS_VRAM_A));
		end

		// When Memtext Or SDMA Or VDMA Goes on to R/W to the SRAM
		3'b001: begin 
			LOCAL_MEM_SRAM_CSn_o 		= 1'b0; 			
			LOCAL_MEM_SRAM_BEn_o[3:0] 	= Ext_RAM_BEn_i[3:0];
			Addy_BiDir_OE 				= 1'b1;
			ADDY_Out 					= Ext_RAM_Addy_i[31:0];
			DataBufferOELogic			= !Ext_RAM_WEn_i;
			Data_Out 					= Ext_RAM_Data_i;			
		end

		// When in Debug Mode
		3'b01x: begin 
			LOCAL_MEM_SRAM_CSn_o 		= !Dbg_RAM_CS_i; 
			LOCAL_MEM_SRAM_BEn_o[3:0] 	= Dbg_BEn_i[3:0];
			Addy_BiDir_OE 				= 1'b1;
			ADDY_Out 					= Dbg_Address_Out_i[31:0];	
			DataBufferOELogic			= !Dbg_RWn_Out_i;
			Data_Out 					= Dbg_Data_Out_i;
		end

		// When booting
		3'b1xx: begin 
			LOCAL_MEM_SRAM_CSn_o 		= !TSF_RAM_CS; 	
			LOCAL_MEM_SRAM_BEn_o[3:0] 	= 4'b0000;
			Addy_BiDir_OE 				= 1'b1;
			ADDY_Out 					= TSF_ADDY[31:0];
			DataBufferOELogic			= 1'b0;
			Data_Out 					= 32'hFFFF_FFFF;			
		end
	endcase
end 



wire [3:0]	Arbiter_Debug_SM_o;
MC680xx_BusArbiter CPU_BUS_Arbiter(
	.Reset_i( Master_Resetn_o ),
	.Clk_133Mhz_i( Clk_133Mhz_i ),		// 	133Mhz
	.iBUS_Clk_i( iBUS_1xClk_o ),			//	33Mhz
	.iBUS_2xClk_i( iBUS_2xClk_o ), 		// 	66Mhz
// System Signals
	.MODE_060_040_i( 1'b1 ),			// 0: 68040, 1: 68060
	.TSF_FLASH2RAM_i( TSF_FLASH2RAM_o ),
	.Dbg_Mode_On_i( Dbg_Mode_On_i ),
	.Drive_BGn_i( Drive_BGn ),
	.Channel_Select_o(  Channel_Select_o ),
// CPU Signals 
	.CPU_BRn_i( CPU_BRn_i ),
	.CPU_BGn_o( CPU_BGn_o ),
	.CPU_BGRn_o( CPU_BGRn_o ),     //
	.CPU_BTTn_i( CPU_BTTn_i ),     // Monitoring
	.CPU_BBn_io( CPU_BBn_io ),     // Monitoring
// MemText/SDMA Signals
    .iBUS_MTXT_BRn_i( iBUS_MTXT_BRn_i ),
    .iBUS_MTXT_BGn_o( iBUS_MTXT_BGn_o ),
    .iBUS_SDMA_BRn_i( iBUS_SDMA_BRn_i ),
    .iBUS_SDMA_BGn_o( iBUS_SDMA_BGn_o ),
    .iBUS_VDMA_BRn_i( iBUS_VDMA_BRn_i ),
    .iBUS_VDMA_BGn_o( iBUS_VDMA_BGn_o ),
	.iBUS_DEBUG_BRn_i( iBUS_DEBUG_BRn_i ),
	.iBUS_DEBUG_BGn_o( iBUS_DEBUG_BGn_o ),
// Get the Logic to switch the External Memory to be handled by another Logic Block than the CPU	
	.iBUS_ExtBUS_Valid_o( iBUS_Master ),
	.Arbiter_Debug_SM_o( Arbiter_Debug_SM_o )
);

//assign LOCAL_MEM_SRAM_CSn_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_RAM_CS_i	:  !CS_SRAM) : !TSF_RAM_CS;
//assign LOCAL_MEM_SRAM_BEn_o[0] 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_BEn_i[0]	:  !LLD ) : 1'b0; // LDS
//assign LOCAL_MEM_SRAM_BEn_o[1] 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_BEn_i[1]	:  !LMD ) : 1'b0; // UDS
//assign LOCAL_MEM_SRAM_BEn_o[2] 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_BEn_i[2]	:  !UMD ) : 1'b0;
//assign LOCAL_MEM_SRAM_BEn_o[3] 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_BEn_i[3]	:  !UUD ) : 1'b0;	// LLD is 31:24 	
// Flash Management
wire  Flash_OE = (!DTACK & CS_FLASH) | (  Wait_FLASH_TA_i[2] & CS_FLASH ) | (  Wait_FLASH_TA_i[1] & CS_FLASH ) | (  Wait_FLASH_TA_i[0] & CS_FLASH );
assign LOCAL_MEM_FLASH_CSn_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_FLASH_CS_i	: !CS_FLASH ) : !TSF_FLASH_CS;
assign LOCAL_MEM_FLASH_OEn_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_FLASH_OE_i 	: !Flash_OE ) : TSF_FLASH_OE;
assign LOCAL_MEM_FLASH_WEn_o 	= Dbg_FLASH_WR_i;
assign CS_GET_VECTOR_INT		= CPUSpace; // Interrupt Request Cycle

assign CS_SRAM 					= ( Internal_Address[31:22] == 10'b0000_0000_00 ) & !CPU_TIPn_i; 	//$0000_0000 - $003F_FFFF (4Meg) - Local to CPU
assign CS_VRAM_A  				= ( Internal_Address[31:22] == 10'b0000_0000_01 ) & !CPU_TIPn_i; 	//$0040_0000 - $007F_FFFF (4Meg) - Isolated from CPU - VRAM
assign CS_VRAM_B  				= ( Internal_Address[31:22] == 10'b0000_0000_10 ) & !CPU_TIPn_i; 	//$0080_0000 - $00BF_FFFF (4Meg) - Isolated from CPU - VRAM
wire   DEAD_ZONE1	    		= (( Internal_Address > 32'h00BF_FFFF ) & ( Internal_Address < 32'h0200_0000 )) & !CPU_TIPn_i;
// SDRAM 
assign CS_MERA        			= (( Internal_Address[31:25] == 7'b0000_001 ) | ( Internal_Address[31:25] == 7'b0000_010 )) & ( UserData | UserProgram | SuperData | SuperProgram ) & !CPU_TIPn_i; 			//$0200_0000 - $05FF_FFFF (64Meg) (400_0000)

wire   DEAD_ZONE2	    		= (( Internal_Address > 32'h05FF_FFFF ) & ( Internal_Address < 32'hFE00_0000 )) & !CPU_TIPn_i;	// Nothing in between 0x0600_0000 - 0xFDFF_FFFF
// Internal Registers
assign CS_GAVIN    				= ( Internal_Address[31:17] == 15'b1111_1110_1100_000 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FEC0_0000 - $FEC1_FFFF
assign CS_BEATRIX 				= ( Internal_Address[31:17] == 15'b1111_1110_1100_001 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FEC2_0000 - $FEC3_FFFF
// Vicky Channel A
assign CS_VICKY_A 				= ( Internal_Address[31:17] == 15'b1111_1110_1100_010 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FEC4_0000 - $FEC5_FFFF
assign CS_VICKY_MEM_A			= ( Internal_Address[31:17] == 15'b1111_1110_1100_011 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FEC6_0000 - $FEC7_FFFF
// Vicky Channel B
assign CS_VICKY_B 				= ( Internal_Address[31:17] == 15'b1111_1110_1100_100 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FEC8_0000 - $FEC9_FFFF
assign CS_VICKY_MEM_B 			= ( Internal_Address[31:17] == 15'b1111_1110_1100_101 ) & ( UserData  | SuperData ) & !CPU_TIPn_i; 								//$FECA_0000 - $FECB_FFFF
assign CS_FLASH					= ( Internal_Address[31:22] == 10'b1111_1111_11 ) 		& ( SuperData | SuperProgram | UserData | UserProgram ) & !CPU_TIPn_i;	//$FFC0_0000 - $FFFF_FFFF
// Debug
assign Dbg_Data_In_o 			= Data_In;

assign CS_NO_MANSLAND 			= DEAD_ZONE1 | DEAD_ZONE2;
// THis is the Chip Select For Internal Access to the FPGA
assign CS_Registers 			= ( CS_GAVIN | CS_BEATRIX | CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B );
assign CS_None_Cacheable 		= ( CS_GAVIN | CS_BEATRIX | CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B ); 
//assign DataCachePush 			= (FC[2:0] == 3'b000);
assign UserData 				= (FC[2:0] == 3'b001);		// LINE16
assign UserProgram 				= (FC[2:0] == 3'b010);
//assign MMU_Table_Search_Data 	= (FC[2:0] == 3'b011); 
//assign MMU_Table_Search_Code 	= (FC[2:0] == 3'b100);
assign SuperData 				= (FC[2:0] == 3'b101);		// LINE 16
assign SuperProgram 			= (FC[2:0] == 3'b110);
assign CPUSpace 				= ({CPU_TT1_2_FPGA, CPU_TT0_i} == 2'b11 );

wire VICKY = (CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B );


always @ (posedge CPU_BCLK_x2) begin
	casex({ CS_GET_VECTOR_INT, VICKY, CS_BEATRIX, CS_GAVIN , CS_MERA, CS_VRAM_B, CS_VRAM_A, CS_NO_MANSLAND })
		8'b0000_0001: Data_Out_Mux <= 32'h0000_0000;					// When CPU Access non-mapped devices or memory
		8'b0000_001x: Data_Out_Mux <= iBUS_D_VRAM_A_i;					// 1st VSRAM Buffer (4MB)
		8'b0000_01xx: Data_Out_Mux <= iBUS_D_VRAM_B_i;					// 2nd VSRAM Buffer (4MB)
		8'b0000_1xxx: Data_Out_Mux <= iBUS_D_MERA_i;					// SDRAM MEMORY
		8'b0001_xxxx: Data_Out_Mux <= iBUS_D_GAVIN_i;					// MERA SDRAM Output
		8'b001x_xxxx: Data_Out_Mux <= iBUS_D_BEATRIX_i;				// BEATRIX (Sound)
		8'b01xx_xxxx: Data_Out_Mux <= iBUS_D_VICKY_i;					// VICKY (Graphics)
		8'b1xxx_xxxx: Data_Out_Mux <= {24'h00_0000, iIRQ_Vector_i};	// Vector Interrupts Number
		default:   Data_Out_Mux <=  32'hDEAD_BEEF;
	endcase
end

/*
always @ (*) begin
	casex({ CS_GET_VECTOR_INT, VICKY, CS_BEATRIX, CS_GAVIN, CS_MERA, CS_VRAM_B, CS_VRAM_A, CS_NO_MANSLAND })
		8'b0000_0001: Data_Out_Mux = 32'h0000_0000;					// When CPU Access non-mapped devices or memory
		8'b0000_001x: Data_Out_Mux = iBUS_D_VRAM_A_i;					// GAVIN Registers (System)
		8'b0000_01xx: Data_Out_Mux = iBUS_D_VRAM_B_i;					// GAVIN Registers (System)		
		8'b0000_1xxx: Data_Out_Mux = iBUS_D_MERA_i;					// GAVIN Registers (System)
		8'b0001_xxxx: Data_Out_Mux = iBUS_D_GAVIN_i;					// MERA SDRAM Output
		8'b001x_xxxx: Data_Out_Mux = iBUS_D_BEATRIX_i;				// BEATRIX (Sound)
		8'b01xx_xxxx: Data_Out_Mux = iBUS_D_VICKY_i;					// VICKY (Graphics)
		8'b1xxx_xxxx: Data_Out_Mux = {24'h00_0000, iIRQ_Vector_i};	// Vector Interrupts Number
		default:   Data_Out_Mux =  32'hDEAD_BEEF;
	endcase
end
*/
/*
0xFEC0:0000 0xFEC1:FFFF 8/16/32 I/O R/W GAVIN Registers (System Controller)
0xFEC2:0000 0xFEC3:FFFF 8/16/32 I/O R/W BEATRIX Registers (Sound/Music/DAC)
0xFEC4:0000 0xFEC5:FFFF 8/16/32 I/O R/W VKY III  Chan A  (Text/Graphics Controller)
0xFEC6:0000 0xFEC6:3FFF 8       MEM R/W VKY III  Chan A  Text Memory Block
0xFEC6:8000 0xFEC6:FFFF 8       MEM R/W VKY III  Chan A  Text Color Memory Block
0xFEC8:0000 0xFEC9:FFFF 8/16/32 I/O R/W VKY III  Chan B  (Text/Graphics Controller)
0xFECA:0000 0xFECA:3FFF 8       MEM R/W VKY III  Chan B  Text Memory Block
0xFECA:8000 0xFECA:FFFF 8       MEM R/W VKY III  Chan B  Text Color Memory Block
*/

assign CPU_TT1_2_CPU = 1'b0;
assign CPU_TSn_2_CPU = 1'b1;
///// BUFFERS /////
BIDIR_SIGNAL CPUSIZ0_BIDIR (
	.datain ( 1'b0  ),
	.oe ( BTT[7] ),		// 0 = Output is Tri-Stated - 1 = Output is being driven.
	.dataio ( CPU_BTTn_io ),
	.dataout ( CPU_BTTn_i )
	);

BIDIR_SIGNAL CPU_TT1_BIDIR (
	.datain ( CPU_TT1_2_CPU  ),
	.oe ( 1'b0 ),
	.dataio ( CPU_TT1_io ),
	.dataout ( CPU_TT1_2_FPGA )
	);

BIDIR_SIGNAL CPU_TS_BIDIR (
	.datain ( CPU_TSn_2_CPU  ),
	.oe ( 1'b0 ),
	.dataio ( CPU_TSn_io ),
	.dataout ( CPU_TSn_2_FPGA )
	);

// Bi-Dir BUS For ADDY
BIDIR_ADDY	CPU_ADDY_BIDIR32 (
	.datain ( ADDY_Out ),
//	.oe ( TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 32'hFFFF_FFFF : 32'h0000_0000 ) : 32'hFFFF_FFFF),
	.oe ( Addy_BiDir_OE ? 32'hffff_ffff : 32'h0000_0000 ),
	.dataio ( CPU_A_io ),
	.dataout ( ADDY_In )
	);	
		
// Bi-Dir BUS For DATA
BIDIR_DATA32 CPU_DATA_BIDIR32 (
	.datain ( Config_On ? 32'hFFFF_0000 : Data_Out ),
	.oe ( (DataBufferOELogic | Config_On) ? 32'hFFFF_FFFF : 32'h0000_0000 ),
	.dataio ( CPU_D_io ),
	.dataout ( Data_In )		// This is the Data Coming from the Exterial World and right now it is 16Bit Wide
	);

/// SYSTEM CIRCUITS

// Let's Divide the Main Clock
always @ (posedge Clk_133Mhz_i) begin 
	ClockDivide <= ClockDivide + 2'b01;
end 

Transfer_Flash_2_Ram TRF_Module(
	.Clk_i( iBUS_1xClk_o ),
	.Rst_i( Global_Reset_i ),		// Ext_Reset == 1 = LPC During Init, 0 = When Init is over with
	
	.Bus_A_o( TSF_ADDY ),
	
	.Flash_CS_o(  TSF_FLASH_CS ),
	.Flash_OEn_o( TSF_FLASH_OE ),
	
	.RAM_CS_o(  TSF_RAM_CS ),
	.RAM_WRn_o( TSF_RAM_WR ),
	.RAM_OEn_o( TSF_RAM_OE ),	

	.TransferDone( TSF_FLASH2RAM_o ),	// 0 = In progress, 1 = Finished
	.StateMachine( TRF_StateMachine )
);


always @ ( posedge CPU_BCLK_o ) begin
	TSF_FLASH2RAM_EDGE <= TSF_FLASH2RAM_o;
	Dbg_RSTn_EDGE		<= Dbg_RSTn_i;		// Reset is active Low
end
// || ( Dbg_RSTn_i & !Dbg_RSTn_i ))
always @ ( negedge CPU_BCLK_o ) begin
	if ( Global_Reset_i ) begin // So while we are Going wait for the Transfer to finish, we keep CPU Reset Asserted
		CPU_RSTn <= 1'b0;		// 0 = Reset, 1= Normal Operation
		Config_On <= 1'b0;
		Drive_BGn <= 1'b0;
		SmallBootSM	<= SB_SM_IDLE;
	end
	else begin
		//if ( !CPU_CLK_ENn_o ) begin 	// Put in the Clock Enable
			case( SmallBootSM ) 
				SB_SM_IDLE: begin 
					//if (( {TSF_FLASH2RAM_EDGE, TSF_FLASH2RAM_o} == 2'b01 ) || ( {Dbg_RSTn_EDGE, Dbg_RSTn_i} == 2'b01 )) begin
					if (( {TSF_FLASH2RAM_EDGE, TSF_FLASH2RAM_o} == 2'b01 ) || ( {Dbg_RSTn_EDGE, Dbg_RSTn_i} == 2'b10 )) begin					
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
		//end
	end
end



always @ ( posedge CPU_BCLK_x2 ) begin 
	if ( TSF_FLASH2RAM_o ) begin
		casex ( { Dbg_Mode_On_i, LineA3_A2_Switch} )
			2'b00: begin
				MEM_BURST_A2 <= ADDY_In[2];
				MEM_BURST_A3 <= ADDY_In[3];
			end
			
			2'b01: begin
				MEM_BURST_A2 <= LineA3_A2[0];
				MEM_BURST_A3 <= LineA3_A2[1];	
			end
			
			2'b1x: begin
				MEM_BURST_A2 <= Dbg_Address_Out_i[2];
				MEM_BURST_A3 <= Dbg_Address_Out_i[3];
			end
		endcase
	end
	else begin
				MEM_BURST_A2 <= TSF_ADDY[2];
				MEM_BURST_A3 <= TSF_ADDY[3];
	end
end 

// Drive the internal 8 Bit bus
always @ ( posedge CPU_BCLK_x2 ) begin
	if (CPU_SIZ_i[1:0] == 2'b01) begin
		case ( Internal_Address[1:0] )
			2'b00: iBUS_D_Write8_o <= Data_In[31:24];
			2'b01: iBUS_D_Write8_o <= Data_In[23:16];
			2'b10: iBUS_D_Write8_o <= Data_In[15:8];
			2'b11: iBUS_D_Write8_o <= Data_In[7:0];
		endcase
	end
	else begin
		iBUS_D_Write8_o = 8'h00;
	end
end
// Drive the internal 16 Bit bus
always @ ( posedge CPU_BCLK_x2 ) begin
	if (CPU_SIZ_i[1:0] == 2'b10) begin
		if ( Internal_Address[1] ) begin
			iBUS_D_Write16_o <= Data_In[15:0];
		end
		else begin
			iBUS_D_Write16_o <= Data_In[31:16];
		end
	end
	else begin
		iBUS_D_Write16_o = 16'h0000;
	end
end

//assign iBUS_D_Write32_o = Data_In[31:0];
always @ ( posedge CPU_BCLK_x2 ) begin
	if (CPU_SIZ_i[1:0] == 2'b00) begin
		iBUS_D_Write32_o <= Data_In[31:0];
	end
	else begin
		iBUS_D_Write32_o <= 32'h0000_0000;
	end
end

always @ ( posedge CPU_BCLK_o ) begin
	//if ( !CPU_CLK_ENn_o ) begin 
		TSF_FLASH2RAM_EDGE1 <= TSF_FLASH2RAM_o;
		BTT <= BTT << 1'b1;
		if ( {TSF_FLASH2RAM_EDGE1, TSF_FLASH2RAM_o} == 2'b01 ) begin
			BTT <= 8'hff;
		end 
	//end
end 

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

// LINE TRANSFER DETECT
always @ (posedge CPU_BCLK_o) begin
	if ( Local_Reset ) begin
		SmallST <= IDLE;
		LineA3_A2_Switch <= 1'b0;
		LineA3_A2 <= 2'b00;
	end
	else begin
	//if ( !CPU_CLK_ENn_o ) begin 		
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

always @ (posedge CPU_BCLK_o) begin
	if ( Local_Reset ) begin
		Pre_DTACK <= 1'b1;
	end
	else begin
		Pre_DTACK <= TSn;
	end
end

always @ (posedge CPU_BCLK_o) begin
	Wait_FLASH_TA_i[0] <= !TSn;
	Wait_FLASH_TA_i[1] <= Wait_FLASH_TA_i[0];
	Wait_FLASH_TA_i[2] <= Wait_FLASH_TA_i[1];
	Wait_FLASH_TA_i[3] <= Wait_FLASH_TA_i[2];
	Wait_FLASH_TA_i[4] <= Wait_FLASH_TA_i[3];	
end


always @ ( * ) begin
	//casex ( { LineTransfer, CS_VRAM_B, CS_VRAM_A, CS_SRAM, CS_FLASH, CS_MERA, CS_LPC_i, CS_RTC_i, CS_Unity_i } ) 	
	casex ( { LineTransfer, CS_VRAM_B, CS_FLASH, CS_LPC_i, CS_RTC_i, CS_Unity_i } )
		6'b000_000: begin TA = !Wait_FLASH_TA_i[1]; 		end	// Any Transactions other than the registers
		
		6'b000_001: begin TA = !Wait_Unity_TA_i;			end	// Unity - IDE
		6'b000_01x: begin TA = !Wait_RTC_TA_i;			end	// Real Time Clock
		6'b000_1xx: begin TA = !Wait_LPC_TA_i;			end	// LPC
		6'b001_xxx: begin TA = !Wait_FLASH_TA_i[2];		end // FLASH
		6'b01x_xxx: begin TA = !Wait_BufferB_TA_i;		end // VSRAM B		
		6'b1xx_xxx: begin TA = !TBI_TA[3];				end // 4 Lines (32bits) Transfer
		default:	begin TA = Pre_DTACK;					end
	endcase
end


always @ (negedge CPU_BCLK_o) begin
	if ( Local_Reset ) begin
		DTACK <= 1'b1;
	end
	else begin
		DTACK <= TA;
	end
end

assign iBUS_WE_o = !DTACK;


///////////// CHIPSCOPE ////////////////////
/*
wire [143:0] TP;
wire  Trigger;

assign TP[31:0] 	= {ADDY_In[31:4], MEM_BURST_A3_o, MEM_BURST_A2_o, ADDY_In[1:0]};
assign TP[63:32]  	= Data_In;
assign TP[95:64]  	= Data_Out;
assign TP[99:96]   	= CPU_BSn_i[3:0];
assign TP[101:100]	= CPU_SIZ_i[1:0];
assign TP[102] 		= TSn;
assign TP[103]		= CPU_TAn_o;
assign TP[104]   	= CPU_TEAn_o;
assign TP[105]		= CPU_BRn_i;
assign TP[106]		= CPU_BBn_io;	// This Indicate the Bus Being Busy it is a Bidir Signal
assign TP[107]		= CPU_BGn_o;
assign TP[108]		= CPU_BTTn_i;
assign TP[111:109]	= FC[2:0];
assign TP[112]		= CPU_RWn_i;
assign TP[116:113]	= Arbiter_Debug_SM_o;
assign TP[117]  	= Dbg_Mode_On_i;
assign TP[118]  	= Config_On;
assign TP[119]  	= CPU_CIOUTn_i;
assign TP[120]		= CPU_TCIn_o;
assign TP[121]		= iBUS_Master;
assign TP[122]  	= CPU_PST_i[0];
assign TP[123]  	= CPU_PST_i[1];
assign TP[124]  	= CPU_PST_i[2];
assign TP[125]  	= CPU_PST_i[3];
assign TP[126] 		= CPU_PST_i[4];
assign TP[127]  	= CPU_RESET_INn_o;
assign TP[128] 		= CPU_AVECn_o;
assign TP[129] 		= iBUS_1xClk_o;
assign TP[130]		= CPU_TBIn_o;
assign TP[131]		= CPU_TIPn_i;
assign TP[132]		= DataBufferOELogic;
assign TP[133]		= TSF_FLASH2RAM_o;
assign TP[134]		= CS_SRAM;
assign TP[137:135] 	= CPU_IPLn_o;
assign TP[138] 		= 1'b0;
//assign TP[135]		= LOCAL_MEM_SRAM_BEn_o[0];
//assign TP[136]		= LOCAL_MEM_SRAM_BEn_o[1];
//assign TP[137]		= LOCAL_MEM_SRAM_BEn_o[2];
//assign TP[138]		= LOCAL_MEM_SRAM_BEn_o[3];
assign TP[139]		= LOCAL_MEM_SRAM_OEn_o;
assign TP[140]		= LOCAL_MEM_SRAM_WEn_o;
assign TP[141]		= LOCAL_MEM_FLASH_CSn_o;
assign TP[142]		= LOCAL_MEM_FLASH_OEn_o;
assign TP[143]		= LOCAL_MEM_FLASH_WEn_o;

wire [31:0] Source;
wire [31:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);

//assign Trigger = TSF_FLASH2RAM_o | ( {Dbg_RSTn_EDGE, Dbg_RSTn_i} == 2'b01 );
assign Probe = 32'h0000_0000;
assign Trigger = (((ADDY_In == Source) & TSF_FLASH2RAM_o) | !CPU_TEAn_o);

TinyChipScope CHIPSCOPE68K (
	.acq_data_in    (TP),    //        tap.acq_data_in
	.acq_trigger_in (Trigger), //           .acq_trigger_in
	.acq_clk        (iBUS_2xClk_o),        //    acq_clk.clk
	.trigger_in     (Trigger)      // trigger_in.trigger_in
);
*/
endmodule

/*
assign iBUS_WE_o = !CPU_TAn_o;


//CPU_BCLK_x2
reg [1:0] 	Flash_Slip_Falling_Edge;
//reg 			Flash_Slip_Falling_Edge;
reg [7:0] 	RTC_Slip_Falling_Edge;
reg [35:0] 	LPC_Slip_Falling_Edge;
reg [15:0] 	UNITY_Slip_Falling_Edge;
reg [3:0] 	MOVE16_Slip_Falling_Edge;
reg 		TSn_Slip_Rising_Edge;

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
			CPU_TAn <= TSn_Slip_Rising_Edge;
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