module OPL3_Access_Module(
input		wire				BUS_Clk_i,
input		wire				BUS_RST_i,
input		wire	[23:0]	BUS_A_i,
input		wire	[7:0]		BUS_D_i,
input		wire				BUS_R_Wn_i,
input		wire				CS_OPL3_i,

input		wire				OPL3_Clk_i,
input		wire				OPL3_RST_i,
input		wire	[7:0]		OPL3_D_i,
output	wire	[7:0]		OPL3_D_o,
output	reg				OPL3_OEn_o,
output	wire	[1:0]		OPL3_A_o,
output	reg				OPL3_CSn,
output	reg				OPL3_RDn,
output	reg				OPL3_WRn,

output	wire	[7:0]		BUS_D_o,
output	wire				BUS_D_RDY_o,
output   wire	[6:0]		Debug_ST_o
);

// Registers
reg	ReadRequest;
reg	[7:0] STATUS_READ;

// Wires
wire	[19:0]	OPL3_Data_2_Write;		// 8 Data + 8 Addy + 1 R/W + CS_L + CS_R + CS_S
wire				OPL3_Data_Read_Empty;
// Assignements
reg	CS_OPL3_DLY;
assign BUS_D_RDY_o = ( CS_OPL3_i & BUS_R_Wn_i ) ? ( CS_OPL3_i & !CS_OPL3_DLY )  : 1'b0;
// READY Line Delay for Access
always @ (negedge BUS_Clk_i) 
begin
	CS_OPL3_DLY <= CS_OPL3_i;
end


OPN2_OPL3_MEM_BLOCK OPL3_Memory_Block (
	.address( { BUS_A_i[8:0]} ),
	.clock( !BUS_Clk_i ),
	.data( BUS_D_i ),
	.wren( CS_OPL3_i & !BUS_R_Wn_i & BUS_Clk_i),
	.q( BUS_D_o )
);

// Front-End Access
reg	[1:0]		Transaction_Slip;
always @ (negedge BUS_Clk_i)
begin
	if (BUS_RST_i) begin
		Transaction_Slip[1:0] <= 2'b00;
	end
	else begin
		Transaction_Slip[0] <= CS_OPL3_i;
		Transaction_Slip[1] <= Transaction_Slip[0];
	end
end

//OPN2_OPL3_FIFO OPN2_FIFO(
//	.data( { BUS_R_Wn_i, BUS_A_i[8:0], BUS_D_i[7:0] } ),
//	.rdclk( OPL3_CLK_i ),
//	.rdreq( ReadRequest ),
//	.wrclk( !BUS_Clk_i ),
//	.wrreq(({Transaction_Slip[0], CS_OPL3_i} == 2'b01) & !BUS_R_Wn_i ),
//	.q( OPL3_Data_2_Write ),
//	.rdempty( OPL3_Data_Read_Empty ),
//	.wrfull(  )
//);

OPN2_OPL3_FIFO OPL3_FIFO (
	.data( { BUS_R_Wn_i, BUS_A_i[8:0], BUS_D_i[7:0] } ),
	.rdclk( OPL3_Clk_i ),
	.rdreq( ReadRequest ),
	.wrclk( !BUS_Clk_i ),
	.wrreq( ({Transaction_Slip[0], CS_OPL3_i} == 2'b01) & !BUS_R_Wn_i ),
	.q( OPL3_Data_2_Write ),
	.rdempty( OPL3_Data_Read_Empty ),
	.wrfull(  )
);


reg	OPL3_A0;
assign OPL3_D_o = OPL3_A0 ? OPL3_Data_2_Write[7:0] : OPL3_Data_2_Write[15:8];
assign OPL3_A_o[1] = OPL3_Data_2_Write[16];
assign OPL3_A_o[0] = OPL3_A0;

reg	[4:0]	StateMachine;
assign Debug_ST_o = {ReadRequest, OPL3_Data_Read_Empty, StateMachine};

localparam	IDLE 					= 5'b0_0001,
				FIFO_LATENCY		= 5'b0_0011,
				READ_FIFO			= 5'b0_0010,
				WRITE_ADDY_PTR0 	= 5'b0_0110,
				WRITE_ADDY_PTR1 	= 5'b0_0111,
				WRITE_ADDY_PTR2 	= 5'b0_0101,
				WRITE_ADDY_PTR3 	= 5'b0_0100,
                                          
				WRITE_DATA_PTR0 	= 5'b0_1100,
				WRITE_DATA_PTR1 	= 5'b0_1101,
				WRITE_DATA_PTR2 	= 5'b0_1111,
				WRITE_DATA_PTR3 	= 5'b0_1110,
				                              
				READ_DATA_PTR0 	= 5'b0_1010,
				READ_DATA_PTR1 	= 5'b0_1011,
				READ_DATA_PTR2 	= 5'b0_1001,
				READ_DATA_PTR3 	= 5'b0_1000,
				ENDOFCYCLE			= 5'b1_1000,
				
				DELAY_IN_BETWEEN0	= 5'b1_1001,
				DELAY_IN_BETWEEN1	= 5'b1_1011,
				DELAY_IN_BETWEEN2	= 5'b1_1010;

reg	[7:0]		Counter256;
          
always @ (posedge OPL3_Clk_i)              
begin
	if (BUS_RST_i) begin
		OPL3_CSn <= 1'b1;
		OPL3_RDn <= 1'b1;
		OPL3_WRn <= 1'b1;
		OPL3_OEn_o <= 1'b0;
		OPL3_A0   <= 1'b0;
		ReadRequest <= 1'b0;
		StateMachine <= IDLE;	
	end
	else begin
		case(StateMachine)
		
		IDLE: begin
			if (OPL3_Data_Read_Empty == 1'b0) begin
				ReadRequest <= 1'b1;
				StateMachine <= FIFO_LATENCY;					
			end
			else begin
				StateMachine <= IDLE;
				ReadRequest <= 1'b0;
				OPL3_OEn_o <= 1'b0;
				OPL3_CSn <= 1'b1;
				OPL3_RDn <= 1'b1;
				OPL3_WRn <= 1'b1;
			end		
		end
		
		FIFO_LATENCY: begin
			ReadRequest <= 1'b0;			
			StateMachine <= READ_FIFO;			
		end
		
		// FIFO Output is Ready Here, let's proceed with the Write Cycle to Write the
		// TCSW (200ns) - 
		READ_FIFO: begin
			OPL3_A0 		<= 1'b0;
			OPL3_WRn 	<= 1'b0;
			OPL3_OEn_o  <= 1'b1;			
			StateMachine <= WRITE_ADDY_PTR0;		
		end
		
		WRITE_ADDY_PTR0: begin
			OPL3_CSn 	<= 1'b0;
			Counter256  <= 8'h04;
			StateMachine <= WRITE_ADDY_PTR1;			
		end
		
		// Wait 2us
		WRITE_ADDY_PTR1: begin
			if (Counter256)
				Counter256 <= Counter256 - 8'h01;
			else begin
				StateMachine <= WRITE_ADDY_PTR2;
				OPL3_WRn <= 1'b1;
			end
		end

		WRITE_ADDY_PTR2: begin
			OPL3_CSn	<= 1'b1;
			Counter256 <= 8'h30;			
			StateMachine <= WRITE_ADDY_PTR3;
		end
		
		// Data has been valid long enough after both Strobe went back high, let's go wait in-between the Addy write and Data Write
		// 2us Delays
		WRITE_ADDY_PTR3: begin
			if (Counter256)
				Counter256 <= Counter256 - 8'h01;
			else begin		
				if (OPL3_Data_2_Write[17]) begin
					if (OPL3_Data_2_Write[15:8] < 8'h21) begin
							StateMachine <= READ_DATA_PTR0;
							OPL3_OEn_o  <= 1'b0;
					end
					else
							StateMachine <= IDLE;
				end
				else
					StateMachine <= WRITE_DATA_PTR0;
			end
		end	
		
		////////////////////////////////
		////		
		// Write Data to Selected Address
		////
		////////////////////////////////		
		WRITE_DATA_PTR0: begin
			OPL3_A0     <= 1'b1;
			OPL3_WRn <= 1'b0;			
			StateMachine <= WRITE_DATA_PTR1;			
		end
		
		WRITE_DATA_PTR1: begin
			OPL3_CSn 	<= 1'b0;
			Counter256 <= 8'h04;	
			StateMachine <= WRITE_DATA_PTR2;		
		end
		// Wait 2us
		WRITE_DATA_PTR2: begin
			if (Counter256)
				Counter256 <= Counter256 - 8'h01;
			else begin
				OPL3_WRn <= 1'b1;
				StateMachine <= WRITE_DATA_PTR3;		
			end
		end
		
		// When the Transaction is over, go wait some cycles between starting again
		WRITE_DATA_PTR3: begin
			OPL3_CSn	<= 1'b1;
			OPL3_OEn_o  <= 1'b0;			
			StateMachine <= DELAY_IN_BETWEEN0;
		end
		
		////////////////////////////////
		////
		//// Read Data to be Selected Address
		////
		////////////////////////////////
		READ_DATA_PTR0: begin
			OPL3_A0 	<= 1'b1;
			OPL3_CSn <= 1'b0;
			StateMachine <= READ_DATA_PTR1;
		end
		
		// Wait 2us		
		READ_DATA_PTR1: begin
			OPL3_RDn <= 1'b0;
			Counter256 <= 8'h04;
			StateMachine <= READ_DATA_PTR2;
		end

		READ_DATA_PTR2: begin
			if (Counter256)
				Counter256 <= Counter256 - 8'h01;
			else
				StateMachine <= READ_DATA_PTR3;
		end
		
		READ_DATA_PTR3: begin
			STATUS_READ <= OPL3_D_i;
			OPL3_CSn	<= 1'b1;
			OPL3_RDn <= 1'b1;
			StateMachine <= DELAY_IN_BETWEEN0;
		end		
		
		////////////////////////////////
		////
		//// INter Transaction Delay
		////
		////////////////////////////////		
		DELAY_IN_BETWEEN0: begin
			StateMachine <= DELAY_IN_BETWEEN1;
			Counter256 <= 8'h20;	// Wait 32 Cycles before starting a new cycle of W/W or W/R
		end

		DELAY_IN_BETWEEN1: begin
			if (Counter256) begin
				Counter256 <= Counter256 - 8'b0000_0001;
			end 
			else begin
				StateMachine <= DELAY_IN_BETWEEN2;
			end		
		end
		
		DELAY_IN_BETWEEN2: begin
				StateMachine <= IDLE;
		end
		
		default: begin
				StateMachine <= IDLE;
		
		end
		
		endcase
	end
end

/*
 void OPL3::SetOPLMode(bool isOPL3)
 {
    Reset();
    Send(0x05, isOPL3, 1); //Set the OPL mode. Write 1 to this address for OPL3, 0 for OPL2.
    delayMicroseconds(5);
 }
*/


/*
wire Trigger_in;
wire [63:0] SignalTap;
assign Trigger_in = OPL3_Data_Read_Empty;

assign SignalTap[7:0] = OPL3_D_i;
assign SignalTap[15:8] = OPL3_D_o;
assign SignalTap[17:16] = OPL3_A_o;
assign SignalTap[18] = OPL3_CSn;
assign SignalTap[19] = OPL3_RDn;
assign SignalTap[20] = OPL3_WRn;
assign SignalTap[21] = OPL3_OEn_o;
assign SignalTap[22] = ReadRequest;
assign SignalTap[23] = OPL3_Data_Read_Empty;
assign SignalTap[31:24] = Counter256;
assign SignalTap[36:32] = StateMachine;
assign SignalTap[63:44] = OPL3_Data_2_Write;



assign SignalTap[23:0] = CPU_A_FULL;
assign SignalTap[31:24]= CPU_D_INPUT;
assign SignalTap[39:32]= CPU_D_OUTPUT;
assign SignalTap[40] = BUS_RWn;
assign SignalTap[41] = BTX_DBG_RDY;
assign SignalTap[42] = BUS_RDY;
assign SignalTap[63:43] = 0;

// CPU
ChipScope ChipScopeII(
	//.acq_clk( CLK_CHIPSCOPE_28M ),
	.acq_clk( OPL3_Clk_i  ),	
	.acq_data_in( SignalTap ),
	.acq_trigger_in( Trigger_in ),
	.trigger_in( Trigger_in )
);
*/

endmodule

// Grey Code Encoding
/*
00000
00001	1	00001
00010	2	00011
00011	3	00010
00100	4	00110
00101	5	00111
00110	6	00101
00111	7	00100
01000	8	01100
01001	9	01101
01010	10	01111
01011	11	01110
01100	12	01010
01101	13	01011
01110	14	01001
01111	15	01000
10000	16	11000
10001	17	11001
10010	18	11011
10011	19	11010
10100	20	11110
10101	21	11111
10110	22	11101
10111	23	11100
11000	24	10100
11001	25	10101
11010	26	10111
11011	27	10110
11100	28	10010
11101	29	10011
11110	30	10001
11111	31	10000
5'b0_0001
5'b0_0011
5'b0_0010
5'b0_0110
5'b0_0111
5'b0_0101
5'b0_0100
5'b0_1100
5'b0_1101
5'b0_1111
5'b0_1110
5'b0_1010
5'b0_1011
5'b0_1001
5'b0_1000
5'b1_1000
5'b1_1001
5'b1_1011
5'b1_1010
5'b1_1110
5'b1_1111
5'b1_1101
5'b1_1100
5'b1_0100
5'b1_0101
5'b1_0111
5'b1_0110
5'b1_0010
5'b1_0011
5'b1_0001
5'b1_0000
*/	 
/*
CODE BONE YARD
			StateMachine <= DELAY_IN_BETWEEN0;
			if ((OPN2_Data_2_Write[15:8] > 8'h20) && (OPN2_Data_2_Write[15:8] < 8'h9F)) begin
				Counter256 <= 8'd83;
			end
			else begin
				if ((OPN2_Data_2_Write[15:8] > 8'h9F) && (OPN2_Data_2_Write[15:8] < 8'hB7)) begin
					Counter256 <= 8'd47;
				end
				else begin
					Counter256 <= 8'd17;
				end
			end

*/
