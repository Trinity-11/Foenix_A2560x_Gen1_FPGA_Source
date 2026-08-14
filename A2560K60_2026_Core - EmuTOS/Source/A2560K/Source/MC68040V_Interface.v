module MC68040V_Interface (

input		wire					Global_Reset_i,
input		wire					Init_F2R_TSF_i,
input		wire					Clk_48Mhz_i,
input		wire					Clk_24Mhz_i,

output	wire						CPU_Clk_o,
// MC68040 General A2560K Interface
inout		wire		[31:0]		CPU_A_io,	// IO
inout		wire		[31:0]		CPU_D_io,	// IO - D[31:0] - ( D[31:24] LSB ) - ( D[7:0] MSB )

output		reg					MEM_BURST_A2_o,
output		reg					MEM_BURST_A3_o,
//CPU Control (MC68040V)
output		wire					CPU_BCLK_o,
output		wire					CPU_AVECn_o,
output		wire					CPU_BGn_o,
input		wire					CPU_BBn_io,
input		wire					CPU_BRn_i,
output		wire					CPU_CDISn_o,
input		wire					CPU_CIOUTn_i,
output		wire					CPU_DLE_o,
input		wire					CPU_IPENDn_i,
output		wire					CPU_IPL0n_o,
output		wire					CPU_IPL1n_o,
output		wire					CPU_IPL2n_o,
input		wire					CPU_LOCKn_i,			//BERRn
output		wire					CPU_LOCKEn_i,			// HALT
output		wire					CPU_MDISn_o,
input		wire					CPU_MIn_i,
output		wire					CPU_PCLK_o,
input		wire					CPU_PST0_i,
input		wire					CPU_PST1_i,
input		wire					CPU_PST2_i,
input		wire					CPU_PST3_i,
inout		wire					CPU_RWn_io,				// IO (MC68040)
output		wire					CPU_RESET_INn_o,		// THis is the CPU Reset In - Sometimes it can be IO
input		wire					CPU_RESET_OUTn_i,		// This is the MC68040 Reset Out Function Called by the Instruction Reset
inout		wire					CPU_SC0_io,				// IO (MC68040)
inout		wire					CPU_SC1_io,				// IO (MC68040)
inout		wire					CPU_SIZ0_io,			// IO (MC68040)
inout		wire					CPU_SIZ1_io,			// IO (MC68040)
inout		wire					CPU_TAn_io,				// IO (MC68040)
inout		wire					CPU_TBIn_io,				//
inout		wire					CPU_TCIn_io,
inout		wire					CPU_TEAn_io,
input		wire					CPU_TIPn_i,
inout		wire					CPU_TSn_io,				// IO (MC68040)
input		wire					CPU_TLN0_i,
input		wire					CPU_TLN1_i,
input		wire					CPU_TM0_i,
input		wire					CPU_TM1_i,
input		wire					CPU_TM2_i,
inout		wire					CPU_TT0_io,				// IO (MC68040)
inout		wire					CPU_TT1_io,				// IO (MC68040)
input		wire					CPU_UPA0_i,
input		wire					CPU_UPA1_i,
output		wire					CPU_LFOn_o,
input		wire					CPU_LOC_i,
input		wire					CPU_SCDn_i,
// Memory Interface
output		wire					LOCAL_MEM_FLASH_CS0n_o,
output		wire					LOCAL_MEM_FLASH_CS1n_o,
output		wire					LOCAL_MEM_FLASH_OEn_o,
output		wire					LOCAL_MEM_FLASH_WEn_o,
output		wire					LOCAL_MEM_FLASH_RSTn_o,
output		wire					LOCAL_MEM_FLASH_WPn_o,
output		wire					LOCAL_MEM_SRAM_BE0n_o,
output		wire					LOCAL_MEM_SRAM_BE1n_o,
output		wire					LOCAL_MEM_SRAM_BE2n_o,
output		wire					LOCAL_MEM_SRAM_BE3n_o,
output		wire					LOCAL_MEM_SRAM_CS0n_o,
output		wire					LOCAL_MEM_SRAM_CS1n_o,
output		reg						LOCAL_MEM_SRAM_OEn_o,
output		reg						LOCAL_MEM_SRAM_WEn_o,

// Slave Interface
output		wire	[31:0]			iBUS_A_o,
output		reg		[7:0]			iBUS_D_Write8_o,
output		reg		[15:0]			iBUS_D_Write16_o,
output		reg		[31:0]			iBUS_D_Write32_o,
output		wire	[31:0]			iBUS_D_Out_virgin_o,
output		wire	[1:0]			iBUS_D_Siz_o,
output		wire					iBUS_RWn_o,
output		wire	[3:0]			iBUS_BE_o,
output		reg						iBUS_WE_o,
output		wire					iBUS_A_Valid_o,
input		wire					iBUS_D_Valid_i,

input		wire	[31:0]			iBUS_D_GABE_i,
input		wire	[31:0]			iBUS_D_BEATRIX_i,
input		wire	[31:0]			iBUS_D_VICKY_i,
input		wire	[31:0]			iBUS_D_MERA_i,


output		wire					iBUS_CS_GABE_o,
output		wire					iBUS_CS_BEATRIX_o,
output		wire					iBUS_CS_VICKY_A_o,
output		wire					iBUS_CS_VICKY_MEM_A_o,
output		wire					iBUS_CS_VICKY_B_o,
output		wire					iBUS_CS_VICKY_MEM_B_o,
output		wire					iBUS_CS_VRAM_A_o,
output		wire					iBUS_CS_VRAM_B_o,
output		wire					iBUS_CS_MERA_o,

input		wire	[6:0]			iIRQ_Interrupt_i,
input		wire	[7:0]			iIRQ_Vector_i,
input		wire					iIRQ_AutoVector_i,
output		wire					iIRQ_GetVector_o,

// Debug Interface
input		wire					Dbg_Mode_On_i,
input		wire	[31:0]			Dbg_Address_Out_i,
input		wire	[31:0]			Dbg_Data_Out_i,
output		wire	[31:0]			Dbg_Data_In_o,
input		wire					Dbg_RWn_Out_i,
input		wire					Dbg_RAM_CS_Lo_i,
input		wire					Dbg_RAM_CS_Hi_i,
input		wire					Dbg_FLASH_CS_Lo_i,
input		wire					Dbg_FLASH_CS_Hi_i,
input		wire					Dbg_FLASH_WR_i,
input		wire					Dbg_FLASH_OE_i,
input		wire					Dbg_OE_i,

input		wire					Dbg_Reset_i,

output		wire					TSF_FLASH2RAM_o,

// Wait-State Section
input		wire					Wait_SDCard_TA_i,
input		wire					Wait_Unity_TA_i,
input		wire					Wait_LPC_TA_i,
input		wire					Wait_RTC_TA_i,
input		wire					Wait_MERA_TA_i, 
input		wire					CS_SDCard_i,
input		wire					CS_Unity_i,
input		wire					CS_LPC_i,
input		wire					CS_RTC_i,
input		wire					SD_Debug_i,
output		wire					Trigger_o
);

assign CPU_LOCKEn_i = 1'b1;

assign Trigger_o = 1'b0;

//assign MEM_BURST_A2_o = TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_Address_Out_i[2] : ADDY_In[2] ) : TSF_ADDY[2];
//assign MEM_BURST_A3_o = TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_Address_Out_i[3] : ADDY_In[3] ) : TSF_ADDY[3];


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

wire [2:0]  FC;
wire CPU_RWn_In;
wire CPU_RWn_Out;
//wire CPU_Reset_In;
wire BERRn;
wire [31:0] Internal_Address;

assign iBUS_CS_GABE_o = CS_GABE;
assign iBUS_CS_BEATRIX_o = CS_BEATRIX;
//assign iBUS_CS_SDRAM_o = CS_SDRAM & !ASn;
assign iBUS_CS_VICKY_A_o = CS_VICKY_A;
assign iBUS_CS_VICKY_MEM_A_o = CS_VICKY_MEM_A;
assign iBUS_CS_VICKY_B_o = CS_VICKY_B;
assign iBUS_CS_VICKY_MEM_B_o = CS_VICKY_MEM_B;
assign iBUS_CS_VRAM_A_o = CS_VRAM_A;
assign iBUS_CS_VRAM_B_o = CS_VRAM_B;
assign iBUS_CS_MERA_o = CS_MERA;


assign CPU_DLE_o = 1'b1;	// this is JS0 and it should 1
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

wire UUD, UMD, LMD, LLD;

wire LineOr32BitsTransaction;

assign LineOr32BitsTransaction = (!SIZ0 & !SIZ1) | (SIZ0 & SIZ1);


assign UUD = (!Internal_Address[0] & !Internal_Address[1]) | LineOr32BitsTransaction;		// Describe D31:D24

assign UMD = ( Internal_Address[0] & !Internal_Address[1]) | (!Internal_Address[1] & SIZ1) | LineOr32BitsTransaction; // Describe D23:D16

assign LMD = (!Internal_Address[0] & Internal_Address[1]) | LineOr32BitsTransaction;	// Describe [D15:D8]

assign LLD = ( Internal_Address[0] &  Internal_Address[1]) | (Internal_Address[1] & SIZ1) | LineOr32BitsTransaction; // Describe [

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

assign iBUS_D_Out_virgin_o = Data_In[31:0];

assign CPU_BGn_o = TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b1 : CPU_BRn_i) : 1'b1;

wire SIZ0_Output;
wire SIZ1_Output;

wire SIZ0;
wire SIZ1;

assign SIZ0_Output = 1'b0;
assign SIZ1_Output = 1'b0;


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
	
/*
BIDIR_SIGNAL TRANS_ACK_BIDIR (
	.datain ( CPU_TAn_o  ),
	.oe ( 1'b1 ),
	.dataio ( CPU_TAn_io ),
	.dataout ( CPU_TAn_2_FPGA )
	);	
*/	
assign CPU_SC0_io = 1'bz;
assign CPU_SC1_io	= 1'bz;

wire 	CPU_TEAn_o;
wire 	CPU_TCIn_o;
wire	CPU_TBIn_o;
wire 	CPU_TAn_o;

wire 	CPU_TEAn_i;
wire 	CPU_TCIn_i;
wire	CPU_TBIn_i;
wire 	CPU_TAn_i;

wire [3:0] TA_Group_i;

SIGNAL_TA_GROUP_OC	SIGNAL_TA_GROUP_OC_inst (
	.datain ( { CPU_TCIn_o, CPU_TBIn_o, CPU_TEAn_o, CPU_TAn_o}  ),
	.oe (  4'b1111 ),
	.dataio ( { CPU_TCIn_io, CPU_TBIn_io, CPU_TEAn_io, CPU_TAn_io}  ),
	.dataout ( TA_Group_i )
	);

assign 	CPU_TEAn_i = TA_Group_i[1];
assign 	CPU_TCIn_i = TA_Group_i[3];
assign	CPU_TBIn_i = TA_Group_i[2];
assign 	CPU_TAn_i = TA_Group_i[0];
/*
BIDIR_SIGNAL SNOOP_CTRL0_BIDIR (
	.datain ( 1'b1  ),
	.oe ( 1'b0 ),
	.dataio ( CPU_SC0_io ),
	.dataout ( CPU_TAn_2_FPGA )
	);	
	
BIDIR_SIGNAL SNOOP_CTRL1_BIDIR (
	.datain ( 1'b1  ),
	.oe ( 1'b0 ),
	.dataio ( CPU_SC1_io ),
	.dataout ( CPU_TAn_2_FPGA )
	);	
*/

assign iBUS_D_Siz_o = {	SIZ1, SIZ0 };


wire CPU_TAn_2_FPGA;
wire CPU_TT0_2_FPGA;
wire CPU_TT1_2_FPGA;
wire CPU_TSn_2_FPGA;

wire CPU_TT0_2_CPU;
wire CPU_TT1_2_CPU;
wire CPU_TSn_2_CPU;

assign CPU_TT0_2_CPU = 1'b0;
assign CPU_TT1_2_CPU = 1'b0;
assign CPU_TSn_2_CPU = 1'b1;

	
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
		
wire TSn;

assign TSn = CPU_TSn_2_FPGA;	
	

wire Remote_Reset_Ctrl;
wire Remote_Reset_Direction;
wire Remote_Halt_Ctrl;
// Bi-Dir Signal for the Reset Signal
/*
BIDIR_SIGNAL	RESET_BUFFER (
	.datain ( 1'b0 ),
	.oe ( !Dbg_Reset_i | Global_Reset_i ),
	.dataio ( CPU_RESET_INn_o ),
	.dataout ( CPU_RESET_OUTn_i )
	);
*/	
//assign CPU_RESET_INn_o = ( Dbg_Reset_i & !Global_Reset_i );	// Old Line before transfer
assign CPU_RESET_INn_o = Dbg_Mode_On_i ?  Dbg_Reset_i : TSF_FLASH2RAM_o ;
	
// Bi-Dir Signal for the Rear/Write Signal
BIDIR_SIGNAL RW_BUFFER (
	.datain ( CPU_RWn_Out ),
	.oe ( TSF_FLASH2RAM_o ? Dbg_Mode_On_i : 1'b1),
	.dataio ( CPU_RWn_io ),
	.dataout ( CPU_RWn_In )
	);
	
assign CPU_RWn_Out = TSF_FLASH2RAM_o ? Dbg_RWn_Out_i : TSF_RAM_WR;

//assign iBUS_RWn_o = ( CPU_RWn_In | CPU_TAn_o );
assign iBUS_RWn_o = CPU_RWn_In;
//


wire [31:0] ADDY_In;
wire [31:0] ADDY_Out;

assign ADDY_Out = TSF_FLASH2RAM_o ? { Dbg_Address_Out_i[31:0]} : TSF_ADDY[31:0];	// 
// Bi-Dir BUS For ADDY
BIDIR_ADDY	BIDIR_ADDY_inst (
	.datain ( ADDY_Out ),
	.oe ( TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 32'hFFFF_FFFF : 32'h0000_0000 ) : 32'hFFFF_FFFF),
	.dataio ( CPU_A_io ),
	.dataout ( ADDY_In )
	);
	
wire 	[31:0]	Data_In;
wire	[31:0]	Data_Out;

// Bi-Dir BUS For ADDY
BIDIR_DATA32	CPU_DATA_BIDIR32 (
	.datain ( Data_Out ),
	.oe ( DataBufferOELogic ? 32'hFFFF_FFFF : 32'h0000_0000 ),
	.dataio ( CPU_D_io ),
	.dataout ( Data_In )		// This is the Data Coming from the Exterial World and right now it is 16Bit Wide
	);

reg [31:0] Data_Out_Mux;
assign Dbg_Data_In_o = Data_In;
assign Data_Out 		= 	TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_Data_Out_i : Data_Out_Mux) : 32'hFFFF_FFFF; 
	
wire DataBufferOELogic;


assign DataBufferOELogic = TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !CPU_RWn_Out : (CPU_RWn_In & ( CS_Registers | CS_GET_VECTOR_INT))) : 1'b0;


//assign ASn = CPU_TSn_io;
assign Internal_Address = ADDY_In[31:0];
assign FC[2:0] = ({CPU_TT1_2_FPGA, CPU_TT0_2_FPGA} == 2'b11) ? 3'b111 : {CPU_TM2_i, CPU_TM1_i, CPU_TM0_i};
//assign LDSn = CPU_SIZ0_io;
//assign UDSn = CPU_SIZ1_io;

// Internal Bus 
assign iBUS_A_o 			= Internal_Address;
assign iBUS_BE_o[0]   	= LLD;
assign iBUS_BE_o[1]		= LMD;
assign iBUS_BE_o[2]		= UMD;
assign iBUS_BE_o[3]		= UUD;
assign iBUS_A_Valid_o 	= !TSn;

assign CPU_IPL0n_o 		= IPLOut[0];	// 1 means no Interrupt Request
assign CPU_IPL1n_o 		= IPLOut[1];	// 1 Means no Interrupt Request
assign CPU_IPL2n_o 		= IPLOut[2];	// 1 Means no interrupt Request (1 Lowest - 6 Highest Maskable, 7 is highest none-maskable)

assign CPU_CDISn_o 		= 1'b1;

assign CPU_MDISn_o 		= 1'b1;
assign CPU_PCLK_o 		= 1'b0;	//JS2
				//
assign CPU_TCIn_o 		= CS_None_Cacheable ? CPU_TAn_o : 1'b1;
assign CPU_TEAn_o 		= 1'b1;
assign CPU_LFOn_o 		= 1'b1;


// Generate a Clock of 20Mhz for the MC68SEC0000
/*
reg CPU_Clk_Generation;

always @ (posedge Clk_48Mhz_i) begin
	CPU_Clk_Generation <= CPU_Clk_Generation ^ 1'b1;
end
*/


//assign CPU_BCLK_o = CPU_Clk_Generation;
//assign CPU_Clk_o = CPU_Clk_Generation;
//wire CPU_Clk_Generation;

assign CPU_BCLK_o 			= Clk_24Mhz_i;
assign CPU_Clk_o 				= Clk_24Mhz_i;
//assign CPU_Clk_Generation 	= Clk_24Mhz_i;



reg [2:0] IPLOut;


always @ (*) begin

	casex( iIRQ_Interrupt_i )
		7'b000_0000: begin IPLOut= 3'b111; end	
		7'b000_0001: begin IPLOut= 3'b110; end // Lowest Priority
		7'b000_001x: begin IPLOut= 3'b101; end	
		7'b000_01xx: begin IPLOut= 3'b100; end
		7'b000_1xxx: begin IPLOut= 3'b011; end
		7'b001_xxxx: begin IPLOut= 3'b010; end
		7'b01x_xxxx: begin IPLOut= 3'b001; end // Highest Priority
		7'b1xx_xxxx: begin IPLOut= 3'b000; end
		default: begin IPLOut= 3'b111; end
	endcase
end

wire TSF_RAM_CS;
wire TSF_RAM_WR;
wire TSF_RAM_OE;

wire TSF_FLASH_CS;
wire TSF_FLASH_OE;

wire [31:0] TSF_ADDY;
wire [3:0] TRF_StateMachine;

Transfer_Flash_2_Ram TRF_Module(

	.Clk_i( Clk_24Mhz_i ),
//	.Rst_i( 1'b1 ),
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

wire Local_Reset;

assign Local_Reset = !TSF_FLASH2RAM_o;

//assign TSF_FLASH2RAM_o = 1'b1;
//assign TSF_FLASH_CS = 1'b0;
//assign TSF_FLASH_OE = 1'b0;
//assign TSF_RAM_CS = 1'b0;
//assign TSF_RAM_OE = 1'b0;
//assign TSF_RAM_WR = 1'b0;
//assign TSF_ADDY = 32'h0000_0000;

/*
always @ (posedge CPU_Clk_o) begin


end
*/
/*
wire [7:0] Source;
wire [7:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);

assign Remote_Reset_Ctrl = Source[0];
assign Remote_Reset_Direction = Source[1];
assign Remote_Halt_Ctrl = Source[2];

assign Probe[0] = CPU_Reset_In;
assign Probe[1] = 1'b0;
*/

wire [143:0] TP;
wire  Trigger;

assign TP[31:0] 		= {ADDY_In[31:4], MEM_BURST_A3_o, MEM_BURST_A2_o, ADDY_In[1:0]};
assign TP[63:32]  	= Data_In;
assign TP[95:64]  	= Data_Out;
assign TP[99:96]   	= { !UUD, !UMD, !LMD, !LLD};
assign TP[101:100]	= {SIZ1, SIZ0};
assign TP[102] 		= TSn;
assign TP[103]			= CPU_TAn_o;
assign TP[104]   		= CPU_TIPn_i;
assign TP[105]			= CPU_BRn_i;
assign TP[106]			= CPU_BBn_io;	// This Indicate the Bus Being Busy it is a Bidir Signal
assign TP[108:107]	= {CPU_TT1_2_FPGA, CPU_TT0_2_FPGA};
assign TP[111:109]	= FC[2:0];
assign TP[112]			= CPU_RWn_In;
assign TP[115:113]	= IPLOut;
assign TP[119:116]   = TRF_StateMachine;
//assign TP[119:116]   = { CPU_PST3_i, CPU_PST2_i, CPU_PST1_i, CPU_PST0_i};
assign TP[120]			= CPU_CIOUTn_i;
assign TP[121]			= iBUS_D_Valid_i;
assign TP[125:122]   = TA_Group_i;
assign TP[126] 		= iBUS_RWn_o;
assign TP[127]  		= CPU_AVECn_o;

assign TP[128] 		= CPU_Clk_o;
assign TP[129] 		= CPU_LOCKn_i;
assign TP[130]			= CPU_TBIn_o;
//assign TP[130]		   = (iIRQ_AutoVector_i & CS_GET_VECTOR_INT );
assign TP[131]			= LineTransferCondition;
assign TP[132]			= DataBufferOELogic;
assign TP[133]			= Wait_Unity_TA_i;
assign TP[134]			= LOCAL_MEM_SRAM_CS0n_o;
assign TP[135]			= LOCAL_MEM_SRAM_BE0n_o;
assign TP[136]			= LOCAL_MEM_SRAM_BE1n_o;
assign TP[137]			= LOCAL_MEM_SRAM_BE2n_o;
assign TP[138]			= LOCAL_MEM_SRAM_BE3n_o;
assign TP[139]			= LOCAL_MEM_SRAM_OEn_o;
assign TP[140]			= LOCAL_MEM_SRAM_WEn_o;
assign TP[141]			= LOCAL_MEM_FLASH_CS0n_o;
assign TP[142]			= LOCAL_MEM_FLASH_OEn_o;
assign TP[143]			= NOT_CHIPSELECT;

//assign iBUS_Keyboard_D_o = 16'h0000;

wire [31:0] Source;
wire [31:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);

assign Probe = 32'h0000_0000;

assign Trigger = ((ADDY_In == Source) & !Dbg_Mode_On_i);
//assign Trigger = LineTransferCondition;
//assign Trigger = Global_Reset_i;
//assign Trigger = (ADDY_In == 32'hFEC00310);
//assign Trigger = (ADDY_In == Source) & !Dbg_Mode_On_i  | ( CS_Unity_i );
//assign Trigger = iBUS_D_Valid_i;

//assign Trigger = {CPU_TT1_2_FPGA, CPU_TT0_2_FPGA} == 2'b11;

TinyChipScope CHIPSCOPE68K (
	.acq_data_in    (TP),    //        tap.acq_data_in
	.acq_trigger_in (Trigger), //           .acq_trigger_in
	.acq_clk        (Clk_24Mhz_i),        //    acq_clk.clk
	.trigger_in     (Trigger)      // trigger_in.trigger_in
);


//assign CPU_TAn_o 	= (iIRQ_AutoVector_i & CS_GET_VECTOR_INT ) ? 1'b1 : DTACK;	// DTACK Can't be used when AVEC is used
assign CPU_TAn_o 		= DTACK;
assign CPU_AVECn_o 	= (iIRQ_AutoVector_i & CS_GET_VECTOR_INT ) ? DTACK : 1'b1;	// AVEC is the signal that terminate the cycle when the AutoVector is triggered

//assign CPU_TBIn_o 	= ( {SIZ1,SIZ0} == 2'b11 ) ? CPU_TAn_o : 1'b1;
assign CPU_TBIn_o		=  LineTransferCondition ? 1'b1 :  {SIZ1,SIZ0} == 2'b11  ? CPU_TAn_o : 1'b1 ; // So right now, LINE16 is allowed only in SRAM

// RAM Management
assign LOCAL_MEM_SRAM_CS0n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_RAM_CS_Lo_i	:  !CS0) : !TSF_RAM_CS;
assign LOCAL_MEM_SRAM_CS1n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_RAM_CS_Hi_i	:  !CS0) : !TSF_RAM_CS;

assign LOCAL_MEM_SRAM_BE0n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b0	:  !LLD ) : 1'b0; // LDS
assign LOCAL_MEM_SRAM_BE1n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b0	:  !LMD ) : 1'b0; // UDS
assign LOCAL_MEM_SRAM_BE2n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b0	:  !UMD ) : 1'b0;
assign LOCAL_MEM_SRAM_BE3n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b0	:  !UUD ) : 1'b0;	// LLD is 31:24 
//assign LOCAL_MEM_SRAM_OEn_o   = TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_OE_i :	(!CPU_RWn_In | Pre_DTACK) ) : TSF_RAM_OE;
//assign LOCAL_MEM_SRAM_WEn_o	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_RWn_Out_i	: 	(CPU_RWn_In | Pre_DTACK)) : TSF_RAM_WR;

always @ (*) begin
	if ( TSF_FLASH2RAM_o ) begin
			casex ( { Dbg_Mode_On_i, LineA3_A2_Switch} )
			2'b00: begin
//				LOCAL_MEM_SRAM_OEn_o = (!CPU_RWn_In | Pre_DTACK) | !CS0;
				LOCAL_MEM_SRAM_WEn_o = CPU_RWn_In | Pre_DTACK | !CS0;
				LOCAL_MEM_SRAM_OEn_o = !CPU_RWn_In | !CS0;
//				LOCAL_MEM_SRAM_WEn_o = CPU_RWn_In | !CS0;				
			end
			
			3'b01: begin
				if ( CPU_RWn_In ) begin
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

// Flash Management
assign LOCAL_MEM_FLASH_CS0n_o = TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_FLASH_CS_Lo_i	: !FLASH0) : !TSF_FLASH_CS;
assign LOCAL_MEM_FLASH_CS1n_o = TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_FLASH_CS_Hi_i	: !FLASH0) : !TSF_FLASH_CS;
assign LOCAL_MEM_FLASH_OEn_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_FLASH_OE_i :  !FLASH0  ) : TSF_FLASH_OE;
assign LOCAL_MEM_FLASH_WEn_o 	= Dbg_FLASH_WR_i;
// Local Memory (SRAM/FLASH) Control Signals
// FLASH
/*
always @ ( Clk_50Mhz_i ) begin
	if ( !TSn && !CPU_RWn_In 
end
*/

reg [1:0] 	LineA3_A2;
reg [2:0] 	SmallST;
reg [3:0]	TBI_TA;
reg			LineA3_A2_Switch;
wire LineTransferCondition;
assign LineTransferCondition = !CPU_TT1_2_FPGA & CPU_TT0_2_FPGA & SIZ0 & SIZ1 & CS0;		//TT[1:0] == 01, SIZE == 11

localparam 		IDLE = 3'b000,		// TS Cycle (Capture A3-A2 Value)
					ST0  = 3'b001,		// TA0 Cycle - Increment A3..A2 for next cycle
					ST1  = 3'b010,		// TA1 Cycle - Incrememt A3..A2 for next cycle
					ST2  = 3'b011,		// TA2 Cycle - Increment A3..A2 for next Cycle
					ST3  = 3'b100;		// We are done, last clock were TA is low
					
// LINE TRANSFER DETECT
always @ (posedge CPU_Clk_o) begin
	if ( Local_Reset ) begin
		SmallST <= IDLE;
		LineA3_A2_Switch <= 1'b0;
		LineA3_A2 <= 2'b00;
	end
	else begin
		TBI_TA <= TBI_TA << 1'b1;
	
	
	case ( SmallST )
	
	IDLE: begin
			if (( TSn == 1'b0 ) && LineTransferCondition) begin
				LineA3_A2_Switch <= 1'b1;
				LineA3_A2 <= ADDY_In[3:2];
				TBI_TA    <= 4'b1111;
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
	
	
	endcase
	

	
	end
end



assign LOCAL_MEM_FLASH_RSTn_o = 1'b1;
assign LOCAL_MEM_FLASH_WPn_o 	= 1'b1;


reg DTACK = 1'b1;
reg Pre_DTACK = 1'b1;
//reg Pre_AVEC = 1'b1;

always @ (posedge CPU_Clk_o) begin
	if ( Local_Reset ) begin
		Pre_DTACK <= 1'b1;
	end
	else begin
		Pre_DTACK <= TSn;
	end
end

reg [1:0] Wait_FLASH_TA_i;

always @ (posedge CPU_Clk_o) begin
	Wait_FLASH_TA_i[0] <= !TSn;
	Wait_FLASH_TA_i[1] <= Wait_FLASH_TA_i[0];
end

//wire DRAM_READ_Wait;
//assign DRAM_READ_Wait = CPU_RWn_In ? !Wait_FLASH_TA_i[1] : Pre_DTACK;

reg TA;

always @ ( * ) begin
	case ( { LineTransferCondition, CS_MERA , FLASH0, CS_RTC_i, CS_LPC_i, CS_Unity_i, CS_SDCard_i } ) 
		7'b000_0000: begin TA = Pre_DTACK; 				end
		7'b000_0001: begin TA = !Wait_SDCard_TA_i; 	end
		7'b000_0010: begin TA = !Wait_Unity_TA_i;		end
		7'b000_0100: begin TA = !Wait_LPC_TA_i;		end
		7'b000_1000: begin TA = !Wait_RTC_TA_i;		end
		7'b001_0000: begin TA = !Wait_FLASH_TA_i[1];	end
		7'b010_0000: begin TA = !Wait_MERA_TA_i;		end		
		7'b100_0000: begin TA = !TBI_TA[3];				end 
		default: 	 begin TA = Pre_DTACK;				end
	endcase
end



always @ (negedge CPU_Clk_o) begin
	if ( Local_Reset ) begin
		DTACK <= 1'b1;
	end
	else begin
		DTACK <= TA;
	end
end

/*
always @ (negedge CPU_Clk_o) begin
	if ( Local_Reset ) begin
		DTACK <= 1'b1;
	end
	else begin
	case ( { LineTransferCondition, CS_MERA , FLASH0, CS_RTC_i, CS_LPC_i, CS_Unity_i, CS_SDCard_i } ) 
		7'b000_0000: begin DTACK <= Pre_DTACK; 				end
		7'b000_0001: begin DTACK <= !Wait_SDCard_TA_i; 	end
		7'b000_0010: begin DTACK <= !Wait_Unity_TA_i;		end
		7'b000_0100: begin DTACK <= !Wait_LPC_TA_i;		end
		7'b000_1000: begin DTACK <= !Wait_RTC_TA_i;		end
		7'b001_0000: begin DTACK <= !Wait_FLASH_TA_i[1];	end
		7'b010_0000: begin DTACK <= !Wait_MERA_TA_i;		end		
		7'b100_0000: begin DTACK <= !TBI_TA[3];			end 
		default: 	 begin DTACK <= Pre_DTACK;				end
	endcase
	//DTACK <= TA;
	end
end
*/
//assign iBUS_WE_o = !DTACK;

always @ (negedge CPU_Clk_o) begin
	if ( Local_Reset ) begin
		iBUS_WE_o <= 1'b0;
	end
	else begin
		iBUS_WE_o <= !TA;
		//iBUS_WE_o <= !(!Pre_DTACK | Wait_SDCard_TA_i | Wait_Unity_TA_i | Wait_LPC_TA_i | Wait_RTC_TA_i | Wait_FLASH_TA_i[1] | Wait_MERA_TA_i | TBI_TA[3]);
	end
end

//assign iBUS_WE_o = CPU_Clk_o & !DTACK;

/*
always @ (*) begin
	if (CPU_Clk_o && !DTACK) begin
		iBUS_WE_o = 1'b1;
	end
	else begin
		iBUS_WE_o = 1'b0;	
	end
end
*/



// General iBUS Wire Define
/*
reg [3:0] 	ST;
//reg DTACK = 1'b0;
reg [7:0]	WatchDog;
reg		WriteMemory_Strobe;

localparam   IDLE = 4'b0000,
				 ST0	= 4'b0001,
				 ST1  = 4'b0010,
				 ST2  = 4'b0011,
				 ST3	= 4'b0100,
				 WAIT = 4'b0101;

always @ (posedge Clk_50Mhz_i) begin
	if ( Global_Reset_i ) begin
		ST <= IDLE;
		DTACK <= 1'b1;
		WriteMemory_Strobe <= 1'b1;
	end
	else begin
		
		case (ST) 
			// Risign EDGE of 25Mhz
			IDLE: begin 
				if ((CS0 | FLASH0 |  CS_Registers | CS_MERA | CS_GET_VECTOR_INT) & !TSn) begin
//					iBUS_RWn_o <= CPU_RWn_In;
				 ST <= ST0;
				end
				else begin
					DTACK <= 1'b1;
//					iBUS_RWn_o <= 1'b1;
				end
			end
			
			// Falling EDGE of 25Mhz
			ST0: begin 
				if (iBUS_D_Valid_i) begin 
					WatchDog <= 8'h30;		// if after Complete Cycle and Maybe Trigger a BERRn
					ST <= WAIT;	
				end
				else begin
					DTACK <= 1'b0;				
//					if ( CS_GET_VECTOR_INT ) begin
//						ST <= ST3;
//					end
//					else begin
						ST <= ST1;
//					end
				end
				
				if ( !CPU_RWn_In ) begin
					WriteMemory_Strobe <= 1'b0;
				end
				
			end

			// Risign EDGE of 25Mhz			
			ST1: begin 
//				iBUS_RWn_o <= 1'b1;
				WriteMemory_Strobe <= 1'b1;		
				ST <= IDLE;
			end
	
			// Falling EDGE of 25Mhz			
			ST2: begin 
				 DTACK <= 1'b0;
				 ST <= IDLE;			
			end
			
			WAIT: begin
				if (iBUS_D_Valid_i && WatchDog) begin 
					WatchDog <= WatchDog - 8'h01;
					ST <= WAIT;	
				end
				else begin
					// Go Complete Cycle
					if (!CPU_Clk_Generation) begin
						DTACK <= 1'b0;
						ST <= ST1;
					end
				end
			end
			
			default: begin 
				ST <= IDLE; 
				end
		
		endcase
	
	end
end
*/
wire CS0;
wire FLASH0;
wire CS_GABE;
wire CS_BEATRIX;
wire CS_VRAM_A;
wire CS_VRAM_B;
wire CS_VICKY_A;
wire CS_VICKY_MEM_A;
wire CS_VICKY_B;
wire CS_VICKY_MEM_B;
wire CS_MERA;
wire CS_GET_VECTOR_INT;
wire 	INT_CPU_CYCLE;

wire VICKY, GABE, BEATRIX, MERA;

assign GABE = CS_GABE;
assign BEATRIX = CS_BEATRIX;
assign VICKY = (CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B | CS_VRAM_A | CS_VRAM_B );
assign MERA = CS_MERA;
assign INT_CPU_CYCLE = CS_GET_VECTOR_INT;
assign iIRQ_GetVector_o = CS_GET_VECTOR_INT;	// WHen this is going high, the A1..A3 represent the Interrupt Level

always @ (*) begin
	case({ INT_CPU_CYCLE, VICKY, BEATRIX, MERA, GABE })
		5'b0_0001: Data_Out_Mux = iBUS_D_GABE_i;
		5'b0_0010: Data_Out_Mux = iBUS_D_MERA_i;
		5'b0_0100: Data_Out_Mux = iBUS_D_BEATRIX_i;
		5'b0_1000: Data_Out_Mux = iBUS_D_VICKY_i;
		5'b1_0000: Data_Out_Mux = {24'h00_0000, iIRQ_Vector_i};
		default:  Data_Out_Mux =  32'hDEAD_BEEF;
	endcase
end

// THis is the Chip Select For Internal Access to the FPGA
wire CS_Registers;
wire CS_None_Cacheable;
assign CS_Registers      = ( CS_GABE | CS_BEATRIX | CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B | CS_VRAM_A | CS_VRAM_B | CS_MERA);
assign CS_None_Cacheable = ( CS_GABE | CS_BEATRIX | CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B | CS_VRAM_A | CS_VRAM_B | CS_MERA); 
wire UserData;
wire UserProgram;
wire SuperData;
wire SuperProgram;
wire CPUSpace;
//wire MERA_0;
//wire MERA_1;

assign UserData = (FC[2:0] == 3'b001) ;		// LINE16
assign UserProgram = (FC[2:0] == 3'b010);

assign SuperData = (FC[2:0] == 3'b101);		// LINE 16
assign SuperProgram = (FC[2:0] == 3'b110);
assign CPUSpace = ({CPU_TT1_2_FPGA, CPU_TT0_2_FPGA} == 2'b11 );
//assign CS_MERA = MERA_0 | MERA_1;

assign 	CS_GET_VECTOR_INT		= CPUSpace; // Interrupt Request Cycle

assign	CS0 				= ( Internal_Address[31:22] == 10'b0000_0000_00 ) & ( UserData | UserProgram | SuperData | SuperProgram ); //$00 - $3f (4M)
// System RAM
assign   CS_MERA        = ( Internal_Address[31:25] == 7'b0000_001 )  & ( UserData | UserProgram | SuperData | SuperProgram ); //$02000000 - $03FFFFFF 64Meg
//assign   MERA_1        = ( Internal_Address[31:25] == 7'b0000_010 )  & ( UserData | UserProgram | SuperData | SuperProgram ); //$04000000 - $05FFFFFF 64Meg

// Video RAM
assign 	CS_VRAM_A  		= ( Internal_Address[31:21] == 11'b0000_0000_100 )  & ( UserData  | SuperData ); //$08000000 - 09FFFF (2M) (out of 8M)
assign 	CS_VRAM_B  		= ( Internal_Address[31:21] == 11'b0000_0000_101 )  & ( UserData  | SuperData ); //$0A0000 - 0BFFFF (2M) (out of 8M)

assign 	CS_GABE    		= ( Internal_Address[31:17] == 15'b1111_1110_1100_000 ) & ( UserData  | SuperData ); //$FEC0
assign 	CS_BEATRIX 		= ( Internal_Address[31:17] == 15'b1111_1110_1100_001 ) & ( UserData  | SuperData ); //$FEC2
// Vicky Channel A
assign 	CS_VICKY_A 		= ( Internal_Address[31:17] == 15'b1111_1110_1100_010 ) & ( UserData  | SuperData ); //$FEC4
assign 	CS_VICKY_MEM_A	= ( Internal_Address[31:17] == 15'b1111_1110_1100_011 ) & ( UserData  | SuperData ); //$FEC6
//`$00C6_8000 - $00C9_FFFF - Reserved`
// Vicky Channel B
assign 	CS_VICKY_B 		= ( Internal_Address[31:17] == 15'b1111_1110_1100_100 ) & ( UserData  | SuperData ); //$FEC8
assign   CS_VICKY_MEM_B = ( Internal_Address[31:17] == 15'b1111_1110_1100_101 ) & ( UserData  | SuperData ); //$FECA

assign 	FLASH0	= ( Internal_Address[31:21] == 11'b1111_1111_110 ) & ( SuperData | SuperProgram );	//$FFC0_0000

wire NOT_CHIPSELECT;
assign NOT_CHIPSELECT = !(CS0 | CS_MERA | CS_VRAM_A | CS_VRAM_B | CS_GABE | CS_BEATRIX | CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B | FLASH0);

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




// MC68SEC000 / MC68EC020 Memory Map Model
// USER SPACE/ USER PROGRAM / SUPERVISOR DATA
// 1Mx16 (2Mx8) <- $0000_0000 - $001F_FFFF - RAM
// 1Mx16 (2Mx8) <- $0020_0000 - $003F_FFFF - RAM
//       (2Mx8) <- $0040_0000 - $007F_FFFF - DRAM Paging (32 Pages)
// 2Mx32 (4Mx8) <- $0080_0000 - $009F_FFFF - VRAM CHANNEL A (2x 4Mx8 Page)
// 2Mx32 (4Mx8) <- $00A0_0000 - $00BF_FFFF - VRAM CHANNEL B (2x 4Mx8 Page)
//       (2Mx8) <- $00C0_0000 - $00DF_FFFF - System Registers
//                 $00C0_0000 - $00C1_FFFF - GABE Registers (SuperIO/Math Block/SDCard/IDE/Ethernet/SDMA)
//                 $00C2_0000 - $00C3_FFFF - BEATRIX Registers (CODEC/ADC/DAC0/DAC1/DAC2/OPM/OPN2/PSG/SID)
//						 $00C4_0000 - $00C5_FFFF - VICKY Registers Channel A
//						 $00C6_0000 - $00C6_3FFF - TEXT Memory Channel A
//						 $00C6_4000 - $00C6_7FFF - Color Memory Channel A
//						 $00C8_0000 - $00C9_FFFF - VICKY Registers Channel B
//						 $00CA_0000 - $00CA_3FFF - TEXT Memory Channel B
//						 $00CA_4000 - $00CA_7FFF - Color Memory Channel B
//						 $00C8_8000 - $00CF_FFFF - Reserved
//       			 $00D0_0000 - $00DF_FFFF - Reserved
// 1Mx16 (2Mx8) <- $00E0_0000 - $00FF_FFFF - FLASH0

// SUPERVISOR PROGRAM
// 1Mx16 (2Mx8) <- $0000_0000 - $001F_FFFF - RAM
// 1Mx16 (2Mx8) <- $0020_0000 - $003F_FFFF - RAM
//       (2Mx8) <- $0040_0000 - $007F_FFFF - DRAM Paging (32 Pages)
// 2Mx32 (4Mx8) <- $0080_0000 - $009F_FFFF - VRAM CHANNEL A (2x 4Mx8 Page)
// 2Mx32 (4Mx8) <- $00A0_0000 - $00BF_FFFF - VRAM CHANNEL B (2x 4Mx8 Page)
// 1Mx16 (2Mx8) <- $00E0_0000 - $00FF_FFFF - FLASH0





endmodule
