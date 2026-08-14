module M68SEC000_2_MC68040V_Interface (

input		wire					Global_Reset_i,
input		wire					Init_F2R_TSF_i,
input		wire					Clk_40Mhz_i,

output	wire					CPU_Clk_o,
// MC68040 General A2560K Interface
inout		wire		[31:0]	CPU_A_io,	// IO
inout		wire		[15:0]	CPU_D_LO_io,	// IO - D[15:0]
input		wire		[15:0]	CPU_D_HI_io,	// IO - D[31:16]
//CPU Control (MC68040V)
output	wire					CPU_BCLK_o,
output	wire					CPU_AVECn_o,
input		wire					CPU_BGn_o,
output	wire					CPU_BGACKn_io,
output	wire					CPU_BRn_i,
output	wire					CPU_CDISn_o,
output	wire					CPU_CIOUTn_o,
output	wire					CPU_DLE_o,
input		wire					CPU_IPENDn_i,
output	wire					CPU_IPL0n_o,
output	wire					CPU_IPL1n_o,
output	wire					CPU_IPL2n_o,
output	wire					CPU_LOCKn_i,			//BERRn
inout		wire					CPU_LOCKEn_i,			// HALT
output	wire					CPU_MDISn_o,
input		wire					CPU_MIn_i,
output	wire					CPU_PCLK_o,
input		wire					CPU_PST0_i,
input		wire					CPU_PST1_i,
input		wire					CPU_PST2_i,
input		wire					CPU_PST3_i,
inout		wire					CPU_RWn_io,				// IO (MC68040)
inout		wire					CPU_RESET_INn_o,		// THis is the CPU Reset In - Sometimes it can be IO
output	wire					CPU_RESET_OUTn_i,		// This is the MC68040 Reset Out Function Called by the Instruction Reset
input		wire					CPU_SC0_io,				// IO (MC68040)
input		wire					CPU_SC1_io,				// IO (MC68040)
input		wire					CPU_SIZ0_io,			// IO (MC68040)
input		wire					CPU_SIZ1_io,			// IO (MC68040)
output	wire					CPU_TAn_io,				// IO (MC68040)
output	wire					CPU_TBIn_o,				//
output	wire					CPU_TCIn_o,
output	wire					CPU_TEAn_o,
input		wire					CPU_TIPn_i,
input		wire					CPU_TSn_io,				// IO (MC68040)
input		wire					CPU_TLN0_i,
input		wire					CPU_TLN1_i,
input		wire					CPU_TM0_i,
input		wire					CPU_TM1_i,
input		wire					CPU_TM2_i,
input		wire					CPU_TT0_io,				// IO (MC68040)
input		wire					CPU_TT1_io,				// IO (MC68040)
input		wire					CPU_UPA0_i,
input		wire					CPU_UPA1_i,
output	wire					CPU_LFOn_o,
input		wire					CPU_LOC_i,
input		wire					CPU_SCDn_i,
// Memory Interface
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

// Slave Interface
output	wire	[31:0]		iBUS_A_o,
output	wire	[15:0]		iBUS_D_Write_o,
output	wire					iBUS_RWn_o,
output	wire	[1:0]			iBUS_BE_o,
output	wire					iBUS_A_Valid_o,
input		wire					iBUS_D_Valid_i,

input		wire	[15:0]		iBUS_D_GABE_i,
input		wire	[15:0]		iBUS_D_BEATRIX_i,
input		wire	[15:0]		iBUS_D_VICKY_i,
input		wire	[15:0]		iBUS_D_MERA_i,

//input		wire	[2:0]			iIRQ_Channel_Number_i,
//input		wire	[7:0]			iIRQ_Vector_Number_i,

output	wire					iBUS_CS_GABE_o,
output	wire					iBUS_CS_BEATRIX_o,
//output	wire					iBUS_CS_SDRAM_o,
output	wire					iBUS_CS_VICKY_A_o,
output	wire					iBUS_CS_VICKY_MEM_A_o,
output	wire					iBUS_CS_VICKY_B_o,
output	wire					iBUS_CS_VICKY_MEM_B_o,
output	wire					iBUS_CS_VRAM_A_o,
output	wire					iBUS_CS_VRAM_B_o,
output	wire					iBUS_CS_MERA_o,

input		wire	[6:0]			iIRQ_Interrupt_i,
input		wire	[7:0]			iIRQ_Vector_i,
input		wire					iIRQ_AutoVector_i,
output	wire					iIRQ_GetVector_o,

// Debug Interface
input		wire					Dbg_Mode_On_i,
input		wire	[23:0]		Dbg_Address_Out_i,
input		wire	[15:0]		Dbg_Data_Out_i,
output	wire	[15:0]		Dbg_Data_In_o,
input		wire					Dbg_RWn_Out_i,
input		wire					Dbg_RAM_CS0_i,
input		wire					Dbg_RAM_CS1_i,
input		wire					Dbg_FLASH_CS0_i,
input		wire					Dbg_FLASH_CS1_i,
input		wire					Dbg_FLASH_WR_i,
input		wire					Dbg_FLASH_OE_i,
input		wire					Dbg_OE_i,

input		wire					Dbg_Reset_i,
input		wire					Dbg_Halt_i,

output	wire					TSF_FLASH2RAM_o,
input		wire					DebugDebug_i
);

wire ASn;
wire [2:0]  FC;
wire UDSn;
wire LDSn;
wire HALTn_In;
wire CPU_RWn_In;
wire CPU_RWn_Out;
//wire CPU_Reset_In;
wire BERRn;
wire [23:0] Internal_Address;

assign iBUS_CS_GABE_o = CS_GABE & !ASn;
assign iBUS_CS_BEATRIX_o = CS_BEATRIX & !ASn;
//assign iBUS_CS_SDRAM_o = CS_SDRAM & !ASn;
assign iBUS_CS_VICKY_A_o = CS_VICKY_A & !ASn;
assign iBUS_CS_VICKY_MEM_A_o = CS_VICKY_MEM_A & !ASn;
assign iBUS_CS_VICKY_B_o = CS_VICKY_B & !ASn;
assign iBUS_CS_VICKY_MEM_B_o = CS_VICKY_MEM_B & !ASn;
assign iBUS_CS_VRAM_A_o = CS_VRAM_A & !ASn;
assign iBUS_CS_VRAM_B_o = CS_VRAM_B & !ASn;
assign iBUS_CS_MERA_o = CS_MERA & !ASn;



// Bi-Dir Signal for 
BIDIR_SIGNAL	HALT_BUFFER (
	.datain ( 1'b0  ),
	.oe ( !Dbg_Halt_i | Global_Reset_i ),
	.dataio ( CPU_LOCKEn_i ),
	.dataout ( HALTn_In )
	);

wire Remote_Reset_Ctrl;
wire Remote_Reset_Direction;
wire Remote_Halt_Ctrl;
// Bi-Dir Signal for the Reset Signal
BIDIR_SIGNAL	RESET_BUFFER (
	.datain ( 1'b0 ),
	.oe ( !Dbg_Reset_i | Global_Reset_i ),
	.dataio ( CPU_RESET_INn_o ),
	.dataout ( CPU_RESET_OUTn_i )
	);
	
// Bi-Dir Signal for the Rear/Write Signal
BIDIR_SIGNAL RW_BUFFER (
	.datain ( CPU_RWn_Out ),
	.oe ( TSF_FLASH2RAM_o ? Dbg_Mode_On_i : 1'b1),
	.dataio ( CPU_RWn_io ),
	.dataout ( CPU_RWn_In )
	);
	
assign CPU_RWn_Out = TSF_FLASH2RAM_o ? Dbg_RWn_Out_i : TSF_RAM_WR;

assign iBUS_RWn_o = CPU_RWn_In;


wire [31:0] ADDY_In;
wire [31:0] ADDY_Out;

assign ADDY_Out = TSF_FLASH2RAM_o ? {7'b0000_000, Dbg_Address_Out_i[23:0], 1'b0} : {7'b0000_000, TSF_ADDY[23:0], 1'b0};	// 
// Bi-Dir BUS For ADDY
BIDIR_ADDY	BIDIR_ADDY_inst (
	.datain ( ADDY_Out ),
	.oe ( TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 32'hFFFF_FFFF : 32'h0000_0000 ) : 32'hFFFF_FFFF),
	.dataio ( CPU_A_io ),
	.dataout ( ADDY_In )
	);

wire 	[15:0]	Data_In;
wire	[15:0]	Data_Out;

// Bi-Dir BUS For ADDY
BIDIR_DATA16	BIDIR_DATA16_inst (
	.datain ( Data_Out ),
	.oe ( DataBufferOELogic ? 16'hFFFF : 16'h0000 ),
	.dataio ( CPU_D_LO_io ),
	.dataout ( Data_In )		// This is the Data Coming from the Exterial World and right now it is 16Bit Wide
	);

reg [15:0] Data_Out_Mux;
assign Dbg_Data_In_o = Data_In;
assign Data_Out 		= 	TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_Data_Out_i : Data_Out_Mux) : 16'hFFFF; 
	
wire DataBufferOELogic;
assign iBUS_D_Write_o = Data_In[15:0];

assign DataBufferOELogic = TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !CPU_RWn_Out : (CPU_RWn_In & ( CS_Registers | CS_GET_VECTOR_INT))) : 1'b0;

assign CPU_LOCKn_i   = BERRn;		// BERRn

assign ASn = CPU_TSn_io;
assign Internal_Address = ADDY_In[24:1];
assign FC[2:0] = {CPU_TM2_i, CPU_TM1_i, CPU_TM0_i};
assign LDSn = CPU_SIZ0_io;
assign UDSn = CPU_SIZ1_io;

// Internal Bus 
assign iBUS_A_o 			= {8'h00, Internal_Address};
assign iBUS_BE_o[0]   	= !LDSn;
assign iBUS_BE_o[1]		= !UDSn;
assign iBUS_A_Valid_o 	= !ASn;

assign CPU_IPL0n_o 		= IPLOut[0];	// 1 means no Interrupt Request
assign CPU_IPL1n_o 		= IPLOut[1];	// 1 Means no Interrupt Request
assign CPU_IPL2n_o 		= IPLOut[2];	// 1 Means no interrupt Request (1 Lowest - 6 Highest Maskable, 7 is highest none-maskable)

assign CPU_BGACKn_io 	= 1'b0;
assign CPU_CDISn_o 		= 1'b1;
assign CPU_CIOUTn_o 		= 1'b1;
assign CPU_DLE_o 			= 1'b0;

assign CPU_MDISn_o 		= 1'b1;
assign CPU_PCLK_o 		= 1'b0;
assign CPU_TBIn_o 		= 1'b1;				//
assign CPU_TCIn_o 		= 1'b1;
assign CPU_TEAn_o 		= 1'b1;
assign CPU_LFOn_o 		= 1'b1;


// Generate a Clock of 20Mhz for the MC68SEC0000
reg CPU_Clk_Generation;

always @ (posedge Clk_40Mhz_i) begin
	CPU_Clk_Generation <= CPU_Clk_Generation ^ 1'b1;
end

assign CPU_BCLK_o = CPU_Clk_Generation;
assign CPU_Clk_o = CPU_Clk_Generation;


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

wire [23:0] TSF_ADDY;
/*
Transfer_Flash_2_Ram TRF_Module(

	.Clk_i( Clk_40Mhz_i ),
	.Rst_i( 1'b1 ),
//	.Rst_i( Init_F2R_TSF_i ),	
	
	.Bus_A_o( TSF_ADDY ),
	
	.Flash_CS_o(  TSF_FLASH_CS ),
	.Flash_OEn_o( TSF_FLASH_OE ),
	
	.RAM_CS_o(  TSF_RAM_CS ),
	.RAM_OEn_o( TSF_RAM_OE ),
	.RAM_WRn_o( TSF_RAM_WR ),

//	.TransferDone( TSF_FLASH2RAM_o )
);
*/
assign TSF_FLASH2RAM_o = 1'b1;
assign TSF_FLASH_CS = 1'b0;
assign TSF_FLASH_OE = 1'b0;
assign TSF_RAM_CS = 1'b0;
assign TSF_RAM_OE = 1'b0;
assign TSF_RAM_WR = 1'b0;
assign TSF_ADDY = 24'h00_0000;

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
assign Probe[1] = HALTn_In;
*/
/*
wire [143:0] TP;
wire  Trigger;

assign TP[23:0] 		= ADDY_In[23:0];
assign TP[39:24]  	= Data_In;
assign TP[55:40]  	= Data_Out;
assign TP[58:56]   	= FC[2:0];
assign TP[59] 			= ASn;
assign TP[60]		   = CPU_TAn_io;
assign TP[61]        = CPU_RWn_In;
assign TP[63:62]		= iBUS_BE_o;
assign TP[64] 			= iBUS_A_Valid_o;
assign TP[65]			= LOCAL_MEM_SRAM_CS0n_o;
assign TP[66]			= LOCAL_MEM_SRAM_BE0n_o;
assign TP[67]			= LOCAL_MEM_SRAM_BE1n_o;
assign TP[68]			= LOCAL_MEM_SRAM_OEn_o;
assign TP[69]			= LOCAL_MEM_SRAM_WEn_o;
assign TP[70]			= LOCAL_MEM_FLASH_CS0n_o;
assign TP[71]			= LOCAL_MEM_FLASH_CS1n_o;
assign TP[72]			= LOCAL_MEM_FLASH_OEn_o;
assign TP[73]			= LOCAL_MEM_FLASH_WEn_o;
assign TP[74]			= iBUS_CS_VICKY_MEM_A_o;
assign TP[75]			= iBUS_CS_VICKY_MEM_B_o;
assign TP[76]			= DataBufferOELogic;
assign TP[77]			= iBUS_CS_VRAM_A_o;
assign TP[78]			= iBUS_CS_VRAM_B_o;
assign TP[95:80]		= iBUS_D_VICKY_i;
assign TP[96] 			= HALTn_In;
assign TP[97]			= CPU_RESET_OUTn_i;
assign TP[98]			= CS_Registers;
assign TP[99] 			= CPU_RWn_Out;
assign TP[100]			= 1'b0;
assign TP[103:101]	= IPLOut;
assign TP[104]			= iIRQ_AutoVector_i;
assign TP[105]			= CS_GET_VECTOR_INT;
assign TP[106]			= CPU_AVECn_o;
assign TP[110:107]	= ST;
assign TP[111] 		= Dbg_Mode_On_i;
assign TP[112] 		= Dbg_FLASH_WR_i;
assign TP[113]			= Init_F2R_TSF_i;

assign TP[143:114] 	= 0;


assign Trigger = ( IPLOut == 3'b100);

ChipScope CHIPSCOPE68K (
	.acq_data_in    (TP),    //        tap.acq_data_in
	.acq_trigger_in (Trigger), //           .acq_trigger_in
	.acq_clk        (CPU_Clk_Generation),        //    acq_clk.clk
	.trigger_in     (Trigger)      // trigger_in.trigger_in
);
*/
//assign CPU_TAn_io 	= !DTACK;		// DTACK
assign CPU_TAn_io 	= (iIRQ_AutoVector_i & CS_GET_VECTOR_INT ) ? 1'b1 : !DTACK;	// DTACK Can't be used when AVEC is used
assign CPU_AVECn_o 	= (iIRQ_AutoVector_i & CS_GET_VECTOR_INT ) ? !DTACK : 1'b1;	// AVEC is the signal that terminate the cycle when the AutoVector is triggered
assign BERRn   		= 1'b1;		// BERRn
assign CPU_BRn_i     = 1'b1;		// Bus Request

// RAM Management
assign LOCAL_MEM_SRAM_CS0n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_RAM_CS0_i	:  !CS0) : !TSF_RAM_CS;
assign LOCAL_MEM_SRAM_CS1n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_RAM_CS1_i	:  !CS1) : 1'b1;
assign LOCAL_MEM_SRAM_BE0n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b0	:  UDSn ) : 1'b0; // LDS
assign LOCAL_MEM_SRAM_BE1n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b0	:  LDSn ) : 1'b0; // UDS
assign LOCAL_MEM_SRAM_BE2n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b0	:  UDSn ) : 1'b0;
assign LOCAL_MEM_SRAM_BE3n_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b0	:  LDSn ) : 1'b0;
assign LOCAL_MEM_SRAM_OEn_o   = TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_OE_i :	!CPU_RWn_In) : TSF_RAM_OE;
assign LOCAL_MEM_SRAM_WEn_o	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_RWn_Out_i	: 	CPU_RWn_In) : TSF_RAM_WR;

// Flash Management
assign LOCAL_MEM_FLASH_CS0n_o = TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? !Dbg_FLASH_CS0_i	: !FLASH0) : !TSF_FLASH_CS;
assign LOCAL_MEM_FLASH_CS1n_o = 1'b1;
assign LOCAL_MEM_FLASH_OEn_o 	= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? Dbg_FLASH_OE_i : !CPU_RWn_In) : TSF_FLASH_OE;
assign LOCAL_MEM_FLASH_WEn_o 	= Dbg_FLASH_WR_i;
// Local Memory (SRAM/FLASH) Control Signals
// FLASH

assign LOCAL_MEM_FLASH_RSTn_o = 1'b1;
assign LOCAL_MEM_FLASH_WPn_o 	= 1'b1;


// General iBUS Wire Define

reg [3:0] 	ST;
reg DTACK = 1'b0;
reg [7:0]	WatchDog;

localparam   IDLE = 4'b0000,
				 ST0	= 4'b0001,
				 ST1  = 4'b0010,
				 ST2  = 4'b0011,
				 ST3	= 4'b0100,
				 WAIT = 4'b0101;

always @ (posedge CPU_Clk_o) begin
	if ( Global_Reset_i ) begin
		ST <= IDLE;
		DTACK <= 1'b0;
	end
	else begin
		
		case (ST) 
			IDLE: begin 
				if ((CS0 | CS1 | FLASH0 | FLASH1 | CS_Registers | CS_MERA | CS_GET_VECTOR_INT) & !ASn) begin
				 ST <= ST0;
				end
				else begin
					DTACK <= 1'b0;				
				end
			end
			
			ST0: begin 
				if (iBUS_D_Valid_i) begin 
					WatchDog <= 8'h30;		// if after Complete Cycle and Maybe Trigger a BERRn
					ST <= WAIT;	
				end
				else begin
					DTACK <= 1'b1;				
					if ( CS_GET_VECTOR_INT ) begin
						ST <= ST3;
					end
					else begin
						ST <= ST1;
					end


				end

			end
			
			ST1: begin 
				 ST <= ST2;
			 
			end
			
			ST2: begin 
				 DTACK <= 1'b0;
				 ST <= IDLE;			
			end
			
			// CPU CYCLE
			ST3: begin
				if ( !ASn ) begin
					ST <= ST3;
				end
				else begin
					DTACK <= 1'b0;
					ST <= IDLE;
				end
			end
			
			WAIT: begin
				if (iBUS_D_Valid_i && WatchDog) begin 
					WatchDog <= WatchDog - 8'h01;
					ST <= WAIT;	
				end
				else begin
					// Go Complete Cycle
					DTACK <= 1'b1;
					ST <= ST1;				
				end
			end
			
			default: begin ST <= IDLE; end
		
		endcase
	
	end
end

wire CS0;
wire CS1;
wire FLASH0;
wire FLASH1;
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
		5'b1_0000: Data_Out_Mux = {8'h00, iIRQ_Vector_i};
		default:  Data_Out_Mux =  16'hDEAD;
	endcase
end

// THis is the Chip Select For Internal Access to the FPGA
wire CS_Registers;
assign CS_Registers = ( CS_GABE | CS_BEATRIX | CS_VICKY_A | CS_VICKY_MEM_A | CS_VICKY_B | CS_VICKY_MEM_B | CS_VRAM_A | CS_VRAM_B | CS_MERA);

wire UserData;
wire UserProgram;
wire SuperData;
wire SuperProgram;
wire CPUSpace;

assign UserData = (FC[2:0] == 3'b001);
assign UserProgram = (FC[2:0] == 3'b010);

assign SuperData = (FC[2:0] == 3'b101);
assign SuperProgram = (FC[2:0] == 3'b110);
assign CPUSpace = (FC[2:0] == 3'b111);

assign 	CS_GET_VECTOR_INT		= CPUSpace; // Interrupt Request Cycle

assign	CS0 				= ( Internal_Address[23:21] == 3'b000 ) & ( UserData | UserProgram | SuperData | SuperProgram ); //$00 (2M)
assign 	CS1 				= ( Internal_Address[23:21] == 3'b001 ) & ( UserData | UserProgram | SuperData | SuperProgram ); //$02 (2M)
// System RAM
assign   CS_MERA        = ( Internal_Address[23:22] == 2'b01 )  & ( UserData  | SuperData ); //$040000 - $07FFFF (4M) (out of 64Meg)

// Video RAM
assign 	CS_VRAM_A  		= ( Internal_Address[23:21] == 3'b100 )  & ( UserData  | SuperData ); //$080000 - 09FFFF (2M) (out of 8M)
assign 	CS_VRAM_B  		= ( Internal_Address[23:21] == 3'b101 )  & ( UserData  | SuperData ); //$0A0000 - 0BFFFF (2M) (out of 8M)

assign 	CS_GABE    		= ( Internal_Address[23:17] == 7'b1100_000 ) & ( UserData  | SuperData ); //$C0
assign 	CS_BEATRIX 		= ( Internal_Address[23:17] == 7'b1100_001 ) & ( UserData  | SuperData ); //$C2
// Vicky Channel A
assign 	CS_VICKY_A 		= ( Internal_Address[23:17] == 7'b1100_010 ) & ( UserData  | SuperData ); //$C4
assign 	CS_VICKY_MEM_A	= ( Internal_Address[23:17] == 7'b1100_011 ) & ( UserData  | SuperData ); //$C6
//`$00C6_8000 - $00C9_FFFF - Reserved`
// Vicky Channel B
assign 	CS_VICKY_B 		= ( Internal_Address[23:17] == 7'b1100_100 ) & ( UserData  | SuperData ); //$C8
assign   CS_VICKY_MEM_B = ( Internal_Address[23:17] == 7'b1100_101 ) & ( UserData  | SuperData ); //$CA

//assign   CS_SDRAM = ( Internal_Address[23:21] == 3'b111 ) & ( UserProgram | UserData  );	//$E0_0000

//assign 	FLASH0_A	= ( Internal_Address[23:20] == 4'b1100 ) & ( SuperProgram );	//$C0_0000
//assign 	FLASH0_B	= ( Internal_Address[23:20] == 4'b1101 ) & ( SuperData | SuperProgram );	//$D0_0000
assign 	FLASH0	= ( Internal_Address[23:21] == 3'b111 ) & ( SuperData | SuperProgram );	//$E0_0000
assign 	FLASH1	= 1'b0;

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
