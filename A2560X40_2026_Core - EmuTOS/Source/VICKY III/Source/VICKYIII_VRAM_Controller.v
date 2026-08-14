module VICKYIII_VRAM_Controller
(
input             		SDRAM_Init_i,		// reset to initialize RAM
input							Reset_i,
input             		Clk_i,         	// clock ~100MHz
input							SOF_i,				// Start of Frame
														//
														// SDRAM_* - signals to the 2M32 SDRAM
inout		reg 	[31:0]	SDRAM_DQ_io,    	// 16 bit bidirectional data bus
output	reg 	[10:0]	SDRAM_A_o,     	// 11 bit multiplexed address bus
output	wire       		SDRAM_DQM_LL_o,  	// two byte masks
output	wire       		SDRAM_DQM_LH_o,  	// 
output	wire       		SDRAM_DQM_HL_o,  	// two byte masks
output	wire       		SDRAM_DQM_HH_o,  	// 
output	reg  	[1:0] 	SDRAM_BA_o,    	// two banks
output	wire         	SDRAM_nCS_o,   	// a single chip select
output	wire				SDRAM_nWE_o,   	// write enable
output	wire				SDRAM_nRAS_o,  	// row address select
output	wire				SDRAM_nCAS_o,  	// columns address select
output	wire				SDRAM_CKE_o,   	// clock enable
output	wire				SDRAM_CLK_o,
														//
input		wire	[20:0] 	iAddy_i,      		// 25 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations.
input		wire	[18:0]	iSize_i, 			// Maximum Size of 512K (1 Bank Size)

// Write Data From System to DRAM from FIFO
input  	wire				iWrite_i,    		// cpu requests write
output	wire				iSingleWrite_Done_o,
input		wire	[3:0] 	iBE_i,
input  	wire	[31:0] 	iData_i,  			// data input from cpu
//input		wire				iData_FIFO_Empty_i,
//output	wire				iData_FIFO_Read_o,

// Read DRAM to DP Memory Directly
input	             		iRead_i,          // cpu requests read
output   wire	[31:0] 	iData_o,  			// data output to cpu
output 	wire				iData_Valid_o,		// Data Strobe 

output	wire				iBurst_Read_Done_o,
output 	reg        		iCtrl_Rdy_o,
output	reg				iTransfer_In_Progress_o,
output	reg				iRefresh_In_Progress_o,
output 	wire	[4:0]		SM_Debug,
output	wire				CAS_Stop_Burst_Debug,
output	wire				CAS_Stop_Transfer_Debug,
output	wire				Global_Stop_Transfer_Debug,
output	wire	[20:0]	Active_Addy_Debug
	
);

// Bank 00 Address
// $00_0000 - $07_FFFF	- Bank 00
// $08_0000 - $0F_FFFF  - Bank 01
// $10_0000 - $17_FFFF	- Bank 10
// $18_0000 - $1F_FFFF	- Bank 11

// RAS - [A18..A9] - 11 bits
// CAS - [A7..A0]  - 8 bits
// BA0 - A19
// BA1 - A20
assign iSingleWrite_Done_o = (DRAM_SM == ST_WRITE3);

//assign iData_FIFO_Read_o = 1'b0;

assign SDRAM_CKE_o  = 1;
assign SDRAM_nCS_o  = 0;
assign SDRAM_nRAS_o = command[2];
assign SDRAM_nCAS_o = command[1];
assign SDRAM_nWE_o  = command[0];
//assign {DRAM_DQMH,SDRAM_DQML} = SDRAM_A[12:11];
assign SDRAM_DQM_HH_o = !iBE_i[3];
assign SDRAM_DQM_HL_o = !iBE_i[2];
assign SDRAM_DQM_LH_o = !iBE_i[1];
assign SDRAM_DQM_LL_o = !iBE_i[0];

assign iData_o = SDRAM_DQ_io;

// no burst configured
localparam BURST_LENGTH        = 3'b111;   // 000=1, 001=2, 010=4, 011=8, 111=Full Page
localparam ACCESS_TYPE         = 1'b0;     // 0=sequential, 1=interleaved
localparam CAS_LATENCY         = 3'd3;     // 2 for < 100MHz, 3 for >100MHz
localparam OP_MODE             = 2'b00;    // only 00 (standard operation) allowed
localparam NO_WRITE_BURST      = 1'b1;     // 0= write burst enabled, 1=only single access write
//localparam MODE                = {3'b000, NO_WRITE_BURST, OP_MODE, CAS_LATENCY, ACCESS_TYPE, BURST_LENGTH};
localparam MODE                = {NO_WRITE_BURST, OP_MODE, CAS_LATENCY, ACCESS_TYPE, BURST_LENGTH};

// SDRAM commands
wire [2:0] CMD_NOP             = 3'b111;
wire [2:0] CMD_ACTIVE          = 3'b011;
wire [2:0] CMD_READ            = 3'b101;
wire [2:0] CMD_WRITE           = 3'b100;
wire [2:0] CMD_PRECHARGE       = 3'b010;
wire [2:0] CMD_AUTO_REFRESH    = 3'b001;
wire [2:0] CMD_LOAD_MODE       = 3'b000;
wire [2:0] CMD_BURST_STOP      = 3'b110;

localparam sdram_startup_cycles= 14'd12600;// 105us, plus a little more, @ 120MHz
localparam cycles_per_refresh  = 14'd937;  // (64000*120)/8192-1 Calc'd as (64ms @ 120MHz)/8192 rose

localparam startup_refresh_max = 14'b11111111111111;

reg 	[13:0] 	refresh_count = startup_refresh_max - sdram_startup_cycles;
reg  	[2:0] 	command;

reg 	[4:0]	DRAM_SM;
reg	[4:0] DRAM_SM_SM;

assign SM_Debug = DRAM_SM;


localparam		IDLE 			= 	5'b0_0000,
					ST_INIT0		= 	5'b0_0001,

					ST_ACT0 		= 	5'b0_0011,
					ST_ACT1 		=  5'b0_0010,
					ST_ACT2 		= 	5'b0_0110,
					ST_ACT3		= 	5'b0_0111,
					
					ST_READ0		=  5'b0_0101,
					ST_READ1 	= 	5'b0_0100,
					ST_READ2 	=  5'b0_1100,
					ST_READ3 	= 	5'b0_1101,
					ST_READ4 	= 	5'b0_1111,
					
					ST_READ5 	= 	5'b0_1110,
					ST_READ6 	= 	5'b0_1010,
					ST_READ7 	=	5'b0_1011,
					ST_READ8		= 	5'b0_1001,
					
					ST_WRITE0	= 	5'b0_1000,
					ST_WRITE1	= 	5'b1_1000,
					ST_WRITE2	=  5'b1_1001,
					ST_WRITE3	= 	5'b1_1011,
					
					ST_PRECH0	= 	5'b1_1010,
					ST_PRECH1	= 	5'b1_1110,
					ST_PRECH2	= 	5'b1_1111,
					ST_PRECH3	= 	5'b1_1101,

					REFRESH0		= 	5'b1_1100,
					REFRESH1		= 	5'b1_0100,
					REFRESH2		=	5'b1_0101,
					REFRESH3		= 	5'b1_0111,

					WAIT0			= 	5'b1_0110,
					WAIT1			= 	5'b1_0010,
					WAIT2			= 	5'b1_0011,
					WAIT3			= 	5'b1_0001,
					WAIT4			= 	5'b1_0000;

reg	[3:0]		Refresh_Counter;
reg				SDRAM_Init_i_EDGE;
reg	[2:0]		SOF_i_ReSync;
reg				iWrite_i_EDGE;
reg				iRead_i_EDGE;

always @ (posedge Clk_i ) begin
	SDRAM_Init_i_EDGE <= SDRAM_Init_i;
	// Resync
	SOF_i_ReSync[0] <= SOF_i;
	SOF_i_ReSync[1] <= SOF_i_ReSync[0];
	if (SOF_i_ReSync[1] == SOF_i_ReSync[0] ) 
		SOF_i_ReSync[2] <= SOF_i_ReSync[1];

	iWrite_i_EDGE <= iWrite_i;
	iRead_i_EDGE  <= iRead_i;
end

//reg 	[18:0]	Active_Size;
reg	[31:0]	Data_2_Write;
reg	[20:0]	Active_Addy;
reg	[20:0]	Active_Destination;
wire	[7:0]		Active_Column;
wire	[10:0]	Active_Row;
wire	[1:0]		Active_Bank;
reg	[7:0]		Act_Burst_Size;
reg				Active_1Line;		// Signal that indicates that there will be more then 1 line to go read (so multiple Precharge)

assign Active_Addy_Debug = Active_Addy;


assign Active_Column = Active_Addy[7:0];
assign Active_Row    = Active_Addy[18:8];
assign Active_Bank   = Active_Addy[20:19];

assign	CAS_Stop_Burst_Debug = CAS_Stop_Burst;
assign	CAS_Stop_Transfer_Debug = CAS_Stop_Transfer;
assign   Global_Stop_Transfer_Debug = Global_Stop_Transfer;

wire	 	Global_Stop_Transfer;
wire	 	CAS_Stop_Transfer;
wire		CAS_Stop_Burst;
assign 	Global_Stop_Transfer = ( Active_Addy == Active_Destination );
assign 	CAS_Stop_Burst = ( Active_Addy[7:0] == 8'hFB );
assign 	CAS_Stop_Transfer = ( Active_Addy[7:0] == 8'hFF );
assign 	iBurst_Read_Done_o = Global_Stop_Transfer_SLIP[3];

reg[3:0] Global_Stop_Transfer_SLIP;
reg 		Global_Stop_Transfer_EDGE;

always @ (posedge Clk_i) begin

	Global_Stop_Transfer_EDGE <= Global_Stop_Transfer;
	Global_Stop_Transfer_SLIP	<= Global_Stop_Transfer_SLIP << 1'b1;

	if ( {Global_Stop_Transfer_EDGE, Global_Stop_Transfer} == 2'b01 ) begin
			Global_Stop_Transfer_SLIP <= 4'b1110;
	end

end

assign iData_Valid_o = ( DRAM_SM == ST_READ4 );

always @ (posedge Clk_i) begin

	if ( DRAM_SM == ST_ACT0 ) begin
			Active_Addy 			<= iAddy_i;			// Save Starting Address
			Active_Destination	<= iAddy_i + {2'b00, iSize_i} - 19'h000001;	
//			Active_Destination	<= iAddy_i + { 2'b00, 19'h000A0 } - 19'h000001;	
			Data_2_Write			<= iData_i;	
	end
	else begin
		if ( DRAM_SM == ST_READ4 ) begin
			Active_Addy <= Active_Addy + 21'h000001;
		end
	end
end

reg	[3:0]	SmallCount;

always @ (posedge Clk_i) begin
	if ( Reset_i ) begin
		DRAM_SM 		<= IDLE;
		DRAM_SM_SM	<= IDLE;
		iCtrl_Rdy_o	<= 1'b0;
		SmallCount  <= 4'b0000;
		
	end
	else begin
		refresh_count  <= refresh_count + 1'b1;
		SDRAM_DQ_io <= 32'bZ;
		command  <= CMD_NOP;	
		
		if ( Global_Stop_Transfer || CAS_Stop_Burst )
				command  <= CMD_BURST_STOP;	
		
		case (DRAM_SM) 
		
		IDLE: begin 
			// Init the SDRAM
			if ( ({ SDRAM_Init_i_EDGE, SDRAM_Init_i } == 2'b01) ) begin
				DRAM_SM <= ST_INIT0;
			end
			
			if ( {SOF_i_ReSync[2],SOF_i_ReSync[1]} == 2'b01 ) begin
				iRefresh_In_Progress_o <= 1'b1;
				DRAM_SM <= REFRESH0;
				Refresh_Counter <= 4'd08;
			end
			
			// Write 
			if ( ({iWrite_i_EDGE, iWrite_i} == 2'b01) ) begin
				DRAM_SM <= ST_ACT0;			// Go Activate the Row and the Bank we need
				DRAM_SM_SM <= ST_WRITE0;	// Then go write the incoming data
			
			end
			
			// Read
			if ( ({iRead_i_EDGE, iRead_i} == 2'b01) ) begin
				DRAM_SM <= ST_ACT0;			// Go Activate the Row and the Bank we need
				DRAM_SM_SM <= ST_READ0;
			end
		
			iTransfer_In_Progress_o <= 1'b0;
		end
		
		ST_INIT0: begin 
			SDRAM_A_o    <= 0;
			SDRAM_BA_o   <= 0;

			if (refresh_count == startup_refresh_max-31) begin
				command     <= CMD_PRECHARGE;
				SDRAM_A_o[10] <= 1;  // all banks
				SDRAM_BA_o    <= 2'b00;
			end
			if (refresh_count == startup_refresh_max-23) begin
				command     <= CMD_AUTO_REFRESH;
			end
			if (refresh_count == startup_refresh_max-15) begin
				command     <= CMD_AUTO_REFRESH;
			end
			if (refresh_count == startup_refresh_max-7) begin
				command     	<= CMD_LOAD_MODE;
				SDRAM_A_o     	<= MODE;
			end

			if(!refresh_count) begin
				DRAM_SM			<= IDLE;
				iCtrl_Rdy_o   <= 1;
				refresh_count <= 0;
			end		
		end
		
		ST_ACT0: begin
			iTransfer_In_Progress_o <= 1'b1;
			DRAM_SM 					<= ST_ACT1;		
		end

		// Register the Value we will need for the transfer
		ST_ACT1: begin 
			command  			<= CMD_ACTIVE;
			SDRAM_A_o  			<= Active_Row;		// 2048 ROW (RAS) A0..A10 (11bits) - Active Banks (RAS Access)
			SDRAM_BA_o 			<= Active_Bank;	// 2Bits for Bank	
			DRAM_SM 				<= ST_ACT2;
		end
		
		ST_ACT2: begin
			DRAM_SM 				<= ST_ACT3;
		end
		
		// 2 Clock Cycle Delay
		ST_ACT3: begin
				DRAM_SM 			<= DRAM_SM_SM;	// Go Read or Write
		end
		
		// Read Cycle is Here
		ST_READ0: begin
			command  		<= CMD_READ;
			SDRAM_A_o 		<= {3'b000, Active_Column};		// A10 = No Automatic Precharche because I use Burst Stop
			DRAM_SM 			<= ST_READ1;
		end
		
		ST_READ1: begin	DRAM_SM 	<= ST_READ2; end 	// Read Command is registered Here
		ST_READ2: begin	DRAM_SM 	<= ST_READ3; end 	// 1st Clock Cycle Here (CAS Latency)
		ST_READ3: begin 	DRAM_SM 	<= ST_READ4; end 	// 2nd Clock Cycle Here (CAS Latency)
		ST_READ4: begin										// 3 Clock Cycle Here (CAS Latency)	- Data will be Valid Here 		
			if ( Global_Stop_Transfer ||  CAS_Stop_Transfer ) begin
				SmallCount    <= 4'b1000;
				
				if ( Global_Stop_Transfer ) begin
					DRAM_SM 	<= ST_READ5;
				end
				else begin
					SDRAM_A_o[10] 	<= 1'b0;  			// Go Precharge the Actual Bank + RAS
					command  		<= CMD_PRECHARGE;
					DRAM_SM 			<= ST_READ6; 	
				end
			end
			else begin
				DRAM_SM 	<= ST_READ4;				
			end
		end	
	
		// Transfer is Over, Let's close the burst and then Close the ROW and go back to IDLE
		ST_READ5: begin
			if (SmallCount) begin
				SmallCount <= SmallCount - 4'b0001;
			end
			else begin
				SDRAM_A_o[10] <= 0;  			// Go Precharge the Actual Bank + RAS
				command       <= CMD_PRECHARGE;
				DRAM_SM 		  <= IDLE;				
			end 
		end
	
		// The ROW has been closed, let's wait 7 Clock Cycle to make sure everything is kusher!
		ST_READ6: begin
			if (SmallCount) begin
				SmallCount <= SmallCount - 4'b0001;
			end
			else begin
				//Active_Addy 	<= Active_Addy + 21'h000001;				
				DRAM_SM_SM	  	<= ST_READ0;
				DRAM_SM 		  	<= ST_ACT1;	// Go back to reactivate the next ROW and let's move on with the next Burst Sequence	
			end 
		end
	
		
		ST_WRITE0: begin
			command  		<= CMD_WRITE;
			SDRAM_A_o 		<= {3'b100, Active_Column};		// A10 = 1 - Write and Auto-Precharge right after.
			SDRAM_DQ_io		<= Data_2_Write;
			DRAM_SM 			<= ST_WRITE1; 		
		end
	
		ST_WRITE1: begin 
				DRAM_SM <= ST_WRITE2;
		end
		
	
		ST_WRITE2: begin 
				DRAM_SM <= ST_WRITE3; 		
		end
		
		ST_WRITE3: begin 
				DRAM_SM <= IDLE; 		
		end

/*
		ST_PRECH0: begin 
	
		end

		ST_PRECH1: begin
		
		end
		
		ST_PRECH2: begin
		
		end
		
		ST_PRECH3: begin
		
		end
*/		
		
		REFRESH0: begin
				command  <= CMD_AUTO_REFRESH;
				DRAM_SM <= REFRESH1;
		end
		
		REFRESH1: begin
			if (Refresh_Counter) begin
				Refresh_Counter <= Refresh_Counter - 4'b0001;
			end
			else begin
				iRefresh_In_Progress_o <= 1'b0;
				DRAM_SM <= IDLE; 
			end
		
		end
/*
		REFRESH2: begin
		
		end
		
		REFRESH3: begin
		
		end
		
		WAIT0: begin 
		
		end
		
		WAIT1: begin 
		
		end
		
		WAIT2: begin
		
		end
		
		WAIT3: begin
		
		end
*/

default: begin 
			DRAM_SM 		<= IDLE; 
			DRAM_SM_SM	<= IDLE;
		end 
		endcase 
	end
end























altddio_out
#(
	.extend_oe_disable("OFF"),
	.intended_device_family("Cyclone V"),
	.invert_output("OFF"),
	.lpm_hint("UNUSED"),
	.lpm_type("altddio_out"),
	.oe_reg("UNREGISTERED"),
	.power_up_high("OFF"),
	.width(1)
)
sdramclk_ddr
(
	.datain_h(1'b0),
	.datain_l(1'b1),
	.outclock(Clk_i),
	.dataout(SDRAM_CLK_o),
	.aclr(1'b0),
	.aset(1'b0),
	.oe(1'b1),
	.outclocken(1'b1),
	.sclr(1'b0),
	.sset(1'b0)
);



/*
always @ (posedge Clk_i) begin
	if ( Reset_i ) begin
		Active_Size		<= 19'h0_0000;
		Active_Addy		<= 21'h00_0000;
		Act_Burst_Size <= 8'h00;	// Number of Transaction
		Active_1Line	<= 1'b0;
	end
	else begin
	
	
	
	
		case (DRAM_SM)
		
		IDLE: begin
			Active_Addy 			<= iAddy_i;			// Save Starting Address
			Active_Size 			<= iSize_i;
			Active_Destination	<= iAddy_i + {2'b00, iSize_i};
		end
	
		// Compute the Value we Need
		ST_ACT0: begin
			if (Active_Size > 19'd256) begin	// is the Size > of 1 Column Line
			// Alright we will have to cross the threshold of 1 Column
				Act_Burst_Size <= Column_Test0;
				Active_Size <= Active_Size - Column_Test0;
				Active_1Line <= 1'b1;
			end
			else begin
				if ( Column_Test1[8] ) begin
					Act_Burst_Size <= Column_Test0;
					Active_Size <= Active_Size - Column_Test0;					
					Active_1Line <= 1'b1;		
				end
				else
				begin
					// This will require only one Instance call on the Column, only one Active, then burst, stop burst then we are done.
					Act_Burst_Size <= Active_Size;
					Active_Size <= 19'h0_0000;	// If we get here, Active Size should equal 0				
					Active_1Line <= 1'b0;
				end
			end
		end
		
		default: begin 
		
		end
	
		endcase
	
	end
end
*/






endmodule
/*
0	00000	00000
1	00001	00001
2	00010	00011
3	00011	00010
4	00100	00110
5	00101	00111
6	00110	00101
7	00111	00100
8	01000	01100
9	01001	01101
10	01010	01111
11	01011	01110
12	01100	01010
13	01101	01011
14	01110	01001
15	01111	01000
16	10000	11000
17	10001	11001
18	10010	11011
19	10011	11010
20	10100	11110
21	10101	11111
22	10110	11101
23	10111	11100
24	11000	10100
25	11001	10101
26	11010	10111
27	11011	10110
28	11100	10010
29	11101	10011
30	11110	10001
31	11111	10000
*/
