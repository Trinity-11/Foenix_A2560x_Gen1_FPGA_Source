`timescale 1 ns / 1 ns
module BUS_2_ChipTune_Interface(
input		wire				BUS_Clk_i,
input		wire				BUS_RST_i,
input		wire	[31:0]	BUS_A_i,
input		wire	[7:0]		BUS_D8_i,
input		wire	[15:0]	BUS_D16_i,
input		wire	[31:0]	BUS_D32_i,
input		wire	[1:0]		BUS_D_Siz_i,
input		wire				BUS_A_Valid_i,
input		wire				BUS_RWn_i,
input		wire	[3:0]		BUS_BE_i,
input		wire				BUS_WE_i, 


input		wire				CS_OPL3_i,
input		wire				CS_OPN2_i,
input		wire				CS_OPM_i,
input		wire				CS_PSG_i,

input		wire				TIP_i,			// 4.75us Transfer Time

input		wire				OPL3_Clk_i,
input		wire				OPL3_RST_i,

output	reg	[7:0]		OPL3_D_o,
output	reg	[1:0]		OPL3_A_o,
output	reg				OPL3_CSn,
output	wire				OPL3_RDn,
output	reg				OPL3_WRn,

output	reg	[7:0]		OPN2_D_o,
output	reg	[1:0]		OPN2_A_o,
output	reg				OPN2_CSn,
output	wire				OPN2_RDn,
output	reg				OPN2_WRn,

output	reg	[7:0]		OPM_D_o,
output	reg				OPM_A_o,
output	reg				OPM_CSn,
output	wire				OPM_RDn,
output	reg				OPM_WRn,

output	reg	[7:0]		PSG_D_o,
output	reg				PSG_WEn,
output	reg				PSG_CEn
);

// Registers
reg	ReadRequest;
reg	[7:0] STATUS_READ;

// Wires
wire	[16:0]	OPL3_Data_2_Write;	// 8 Data + 9 Addy
wire	[16:0]	OPN2_Data_2_Write;	// 8 Data + 9 Addy
wire	[16:0]	OPM_Data_2_Write;		// 8 Data + 8 Addy
wire  [16:0] 	PSG_Data_2_Write;


wire				OPL3_Data_Read_Empty;
wire				OPN2_Data_Read_Empty;
wire				OPM_Data_Read_Empty;
wire				PSG_Data_Read_Empty;

wire 				CS_OPL3_CONDITION;
wire 				CS_OPN2_CONDITION;
wire 				CS_OPM_CONDITION;
wire 				CS_PSG_CONDITION;

wire Pre_Condition;
assign Pre_Condition = !BUS_RWn_i & (BUS_D_Siz_i == 2'b01) & BUS_WE_i;

assign CS_OPL3_CONDITION = CS_OPL3_i & Pre_Condition;
assign CS_OPN2_CONDITION = CS_OPN2_i & Pre_Condition;
assign CS_OPM_CONDITION = CS_OPM_i & Pre_Condition;
assign CS_PSG_CONDITION = CS_PSG_i & Pre_Condition;
/* 
reg	CS_OPL3_EDGE;
reg	CS_OPN2_EDGE;
reg	CS_OPM_EDGE;
reg	CS_PSG_EDGE;

always @ (posedge BUS_Clk_i)
begin
	if (BUS_RST_i) begin
		CS_OPL3_EDGE <= 1'b0;
		CS_OPN2_EDGE <= 1'b0;
		CS_OPM_EDGE  <= 1'b0;
		CS_PSG_EDGE  <= 1'b0;		
	end
	else begin
		CS_OPL3_EDGE <= CS_OPL3_CONDITION;
//		CS_OPL3_EDGE[1] <= CS_OPL3_EDGE[0];
		
		CS_OPN2_EDGE <= CS_OPN2_CONDITION;
//		CS_OPN2_EDGE[1] <= CS_OPN2_EDGE[0];

		CS_OPM_EDGE <= CS_OPM_CONDITION;
//		CS_OPM_EDGE[1] <= CS_OPM_EDGE[0];

		CS_PSG_EDGE <= CS_PSG_CONDITION;
//		CS_PSG_EDGE[1] <= CS_PSG_EDGE[0];		
	end
end
*/

CHIPTUNE_FIFO OPL3_FIFO (
	// CPU Side
	.wrclk( BUS_Clk_i ),
	.wrreq( 	CS_OPL3_CONDITION ),
	.data( {BUS_A_i[8:0], BUS_D8_i} ),
	// ChipTune Side		
	.rdclk( OPL3_Clk_i ),
	.rdreq( ReadRequest & FIFO_Pick[0]),

	.q( OPL3_Data_2_Write ),
	.rdempty( OPL3_Data_Read_Empty ),
	.wrfull(  )
);

CHIPTUNE_FIFO OPN2_FIFO (
	// CPU Side
	.wrclk( BUS_Clk_i ),
	.wrreq( CS_OPN2_CONDITION ),
	.data( {BUS_A_i[8:0], BUS_D8_i} ),
	// ChipTune Side		
	.rdclk( OPL3_Clk_i ),
	.rdreq( ReadRequest & FIFO_Pick[1] ),
	.q( OPN2_Data_2_Write ),
	.rdempty( OPN2_Data_Read_Empty ),
	.wrfull(  )
);

CHIPTUNE_FIFO OPM_FIFO (
	// CPU Side
	.wrclk( BUS_Clk_i ),
	.wrreq( CS_OPM_CONDITION ),
	.data( {BUS_A_i[8:0], BUS_D8_i}),
	// ChipTune Side	
	.rdclk( OPL3_Clk_i ),
	.rdreq( ReadRequest & FIFO_Pick[2] ),
	.q( OPM_Data_2_Write ),
	.rdempty( OPM_Data_Read_Empty ),
	.wrfull(  )
);


CHIPTUNE_FIFO PSG_FIFO (
	// CPU Side
	.wrclk( BUS_Clk_i ),
	.wrreq( CS_PSG_CONDITION),
	.data( {BUS_A_i[8:0], BUS_D8_i} ),
	// ChipTune Side
	.rdclk( OPL3_Clk_i ),
	.rdreq( ReadRequest & FIFO_Pick[3] ),
	.q( PSG_Data_2_Write ),
	.rdempty( PSG_Data_Read_Empty ),
	.wrfull(  )
);

reg	[4:0]	StateMachine;
reg   [4:0] St_StateMachine;
reg   [4:0] St_St_StateMachine;

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
				EXTENTION_PSG		= 5'b1_1011,
				DELAY_IN_BETWEEN2	= 5'b1_1010,
				
				TIP               = 5'b1_1110,
				
				ID_FIFO0          = 5'b1_1111,
				ID_FIFO1          = 5'b1_1101,
				ID_FIFO2          = 5'b1_1100;				
			
//reg TIP_Sync0;
//reg TIP_Sync1;
				
//always @ (posedge OPL3_Clk_i)              
//begin				
//	TIP_Sync0 <= TIP_i;
//	TIP_Sync1 <= TIP_Sync0;
//end


reg [3:0] FIFO_Pick;
assign OPN2_RDn 	= 1'b1;
assign OPM_RDn 	= 1'b1;
assign OPL3_RDn 	= 1'b1;

//////////////////////////////////
//
// OPL3
//
//////////////////////////////////
/*
				ReadRequest <= 1'b1;
				OPL3_StateMachine <= FIFO_LATENCY;					
			end
			else begin
				StateMachine <= IDLE;
				ReadRequest <= 1'b0;
*/

reg	[9:0] Delay_Value;

reg	[7:0]		Counter256;
always @ (posedge OPL3_Clk_i)              
begin
	if (BUS_RST_i) begin
	
		OPL3_CSn 	<= 1'b1;
		OPL3_WRn 	<= 1'b1;
		OPL3_A_o   	<= 2'b00;
		
		OPN2_CSn  	<= 1'b1;
		OPN2_A_o		<= 2'b00;
		OPN2_WRn		<= 1'b1;
		
		OPM_CSn		<= 1'b1;
		OPM_A_o		<= 1'b0;
		OPM_WRn		<= 1'b1;
		
		PSG_WEn		<= 1'b1;
		PSG_CEn		<= 1'b1;
		
		FIFO_Pick <= 4'b0000;		
		ReadRequest <= 1'b0;
		StateMachine <= IDLE;
	end
	else begin
		case(StateMachine)
		
		IDLE: begin
			if ( OPL3_Data_Read_Empty == 1'b0 || 
				(OPN2_Data_Read_Empty == 1'b0 & !OPN2_Not_Ready) || 
				(OPM_Data_Read_Empty == 1'b0 & !OPM_Not_Ready) || 
				(PSG_Data_Read_Empty == 1'b0 & !PSG_Not_Ready) ) begin
				FIFO_Pick[0] <= !OPL3_Data_Read_Empty;
				FIFO_Pick[1] <= !OPN2_Data_Read_Empty & !OPN2_Not_Ready;
				FIFO_Pick[2] <= !OPM_Data_Read_Empty & !OPM_Not_Ready;
				FIFO_Pick[3] <= !PSG_Data_Read_Empty & !PSG_Not_Ready;		
				StateMachine <= ID_FIFO0;					
			end
			else begin
				ReadRequest <= 1'b0;			
				FIFO_Pick <= 4'b0000;
				StateMachine <= IDLE;
			end		
		end
		
		FIFO_LATENCY: begin
			ReadRequest <= 1'b0;
			// Make sure all the Control Signals are @ Default
			OPL3_CSn 	<= 1'b1;
			OPL3_WRn 	<= 1'b1;
			OPL3_A_o[0] <= 1'b0;
			OPN2_CSn 	<= 1'b1;
			OPN2_WRn 	<= 1'b1;
			OPN2_A_o[0] <= 1'b0;
			OPM_CSn 		<= 1'b1;
			OPM_WRn 		<= 1'b1;
			OPM_A_o		<= 1'b0;
			PSG_CEn		<= 1'b0;
			PSG_WEn		<= 1'b1;
			StateMachine <= TIP;			// Make sure there is no Transaction in Progress
			St_StateMachine <= READ_FIFO;
		end

		READ_FIFO: begin
			if (FIFO_Pick[0]) begin
				OPL3_A_o[0] <= 1'b0;			
				OPL3_A_o[1]	<= OPL3_Data_2_Write[16];
				OPL3_D_o		<= OPL3_Data_2_Write[15:8];
				OPL3_WRn 	<= 1'b0;				
			end

			if (FIFO_Pick[1]) begin
				OPN2_A_o[1]	<= OPN2_Data_2_Write[16];
				OPN2_D_o		<= OPN2_Data_2_Write[15:8];
				OPN2_CSn 	<= 1'b0;				
			end

			if (FIFO_Pick[2]) begin
				OPM_A_o     <= 1'b0;
				OPM_D_o		<= OPM_Data_2_Write[15:8];
				OPM_CSn 		<= 1'b0;					
		
			end

			if (FIFO_Pick[3]) begin
				PSG_WEn 		<= 1'b0;			
				PSG_D_o		<= PSG_Data_2_Write[7:0];
			end			
			
			StateMachine <= TIP;
			St_StateMachine <= WRITE_ADDY_PTR0;
		end
		
		WRITE_ADDY_PTR0: begin
			if (FIFO_Pick[0]) begin
				OPL3_CSn 	<= 1'b0;			
				end

			if (FIFO_Pick[1]) begin
				OPN2_WRn 	<= 1'b0;
			end
			
			if (FIFO_Pick[2]) begin
				OPM_WRn 		<= 1'b0;	
			end
			
			if (FIFO_Pick[3]) begin
			end
						
			StateMachine 		 <= TIP;
			St_StateMachine 	 <= DELAY_IN_BETWEEN0;			
			St_St_StateMachine <= WRITE_ADDY_PTR1;
			Counter256 <= 8'h07;	// Delay of 2us
			
			//StateMachine 		 <= TIP;
			//St_StateMachine 	 <= WRITE_ADDY_PTR1;
		end
		
		WRITE_ADDY_PTR1: begin
			if (FIFO_Pick[0]) begin		
				OPL3_WRn <= 1'b1;
			end
			
			if (FIFO_Pick[1]) begin			
				OPN2_WRn <= 1'b1;
			end
			
			if (FIFO_Pick[2]) begin
				OPM_WRn 		<= 1'b1;	
			end

			//if (FIFO_Pick[3]) begin
				//PSG_WEn 	<= 1'b1;
			//end					
			StateMachine 		 	<= TIP;
			St_StateMachine 		<= DELAY_IN_BETWEEN0;
			St_St_StateMachine 	<= WRITE_ADDY_PTR2;			
			Counter256 <= 8'h07;	// Delay of 2us			

			//StateMachine <= TIP;
			//St_StateMachine <= WRITE_ADDY_PTR2;	
		end

		WRITE_ADDY_PTR2: begin
			if (FIFO_Pick[0]) begin
				OPL3_CSn		<= 1'b1;
				OPL3_A_o[0] <= 1'b1;
			end
			
			if (FIFO_Pick[1]) begin			
				OPN2_CSn		<= 1'b1;
				OPN2_A_o[0] <= 1'b1;
			end
			
			if (FIFO_Pick[2]) begin
				OPM_CSn 		<= 1'b1;				
				OPM_A_o 		<= 1'b1;
			end
			
			//if (FIFO_Pick[3]) begin
				//PSG_CEn 		<= 1'b1;
			//end			
			
			StateMachine <= TIP;
			St_StateMachine <= WRITE_ADDY_PTR3;
		end
		
		// Data has been valid long enough after both Strobe went back high, let's go wait in-between the Addy write and Data Write
		// 2us Delays
		WRITE_ADDY_PTR3: begin
			if (FIFO_Pick[1]) begin		
				OPN2_D_o    	<= OPN2_Data_2_Write[7:0];
			end
			
			Counter256  <= 8'h08;				
			StateMachine 			<= TIP;
			St_StateMachine 		<= DELAY_IN_BETWEEN0;			
			St_St_StateMachine 	<= WRITE_DATA_PTR0;
		end	

		////////////////////////////////
		////		
		// Write Data to Selected Address
		////
		////////////////////////////////		
		WRITE_DATA_PTR0: begin
			if (FIFO_Pick[0]) begin
				OPL3_D_o		<= OPL3_Data_2_Write[7:0];
				OPL3_CSn 	<= 1'b0;
			end
			
			if (FIFO_Pick[1]) begin			
				OPN2_CSn		<= 1'b0;				
			end
			
			if (FIFO_Pick[2]) begin	
				OPM_D_o     <= OPM_Data_2_Write[7:0];
				OPM_CSn		<= 1'b0;	
			end
						
			StateMachine <= TIP;			
			St_StateMachine <= WRITE_DATA_PTR1;			
		end
		
		// 
		WRITE_DATA_PTR1: begin
			if (FIFO_Pick[0]) begin
				OPL3_WRn 	<= 1'b0;			
			end
			
			if (FIFO_Pick[1]) begin			
				OPN2_WRn		<= 1'b0;
			end
			
			if (FIFO_Pick[2]) begin
				OPM_WRn 		<= 1'b0;				
			end
			

			StateMachine 		 	<= TIP;
			St_StateMachine 		<= DELAY_IN_BETWEEN0;			
			St_St_StateMachine 	<= WRITE_DATA_PTR2;
			Counter256 <= 8'h07;	// Delay of 2us					
			//StateMachine <= TIP;				

		end
		
		// Wait 2us
		WRITE_DATA_PTR2: begin
			if (FIFO_Pick[0]) begin
				OPL3_WRn <= 1'b1;
			end
			
			if (FIFO_Pick[1]) begin			
				OPN2_WRn <= 1'b1;
			end
			
			if (FIFO_Pick[2]) begin	
				OPM_WRn 		<= 1'b1;		
			end
			
			Delay_Value <= 10'd128;
			
			StateMachine 		 	<= TIP;
			St_StateMachine 		<= DELAY_IN_BETWEEN0;
			St_St_StateMachine 	<= WRITE_DATA_PTR3;
			Counter256 <= 8'h08;	// Delay of 2us
			//StateMachine <= TIP;
			//St_StateMachine <= WRITE_DATA_PTR3;
		end
		
		// When the Transaction is over, go wait some cycles between starting again
		WRITE_DATA_PTR3: begin
		
			if (FIFO_Pick[0]) begin
				OPL3_CSn	 	<= 1'b1;
			end
			
			if (FIFO_Pick[1]) begin			
				OPN2_CSn		<= 1'b1;
			end
	
			if (FIFO_Pick[2]) begin	
				OPM_CSn <= 1'b1;
			end
			
//			if (FIFO_Pick[3]) begin				
//				PSG_CEn		<= 1'b0;				
//				PSG_WEn 		<= 1'b1;
			//end
			
			if (FIFO_Pick[3]) begin	
				Counter256 <= 8'h20;	// Delay of 2us			
				St_St_StateMachine 		<= EXTENTION_PSG;
			end
			else begin
				Counter256 <= 8'h04;	// Delay of 2us			
				St_St_StateMachine 		<= IDLE;
			end
			StateMachine 			<= TIP;
			St_StateMachine 		<= DELAY_IN_BETWEEN0;
			//St_St_StateMachine 	<= IDLE;
		end
		
		TIP: begin
			if (TIP_i) 	// Wait for the Parallel to Serial Transfer to be Over
				StateMachine <= TIP;
			else
				StateMachine <= St_StateMachine;
		end
		
		DELAY_IN_BETWEEN0: begin
			if (Counter256)
				Counter256 <= Counter256 - 8'h01;
			else
				StateMachine <= St_St_StateMachine;
		end
		
		EXTENTION_PSG: begin
			PSG_CEn		<= 1'b0;				
			PSG_WEn 		<= 1'b1;
			StateMachine <= TIP;
			St_StateMachine <= IDLE;
		end
		
		
		ID_FIFO0: begin
				ReadRequest <= 1'b1;
				StateMachine <= FIFO_LATENCY;					
		end
		
		default: begin
				StateMachine <= IDLE;
		end
		
		endcase
	end
end



// Delay for the In Between 
reg [9:0] OPN2_Delay_Counter;
reg [9:0] OPM_Delay_Counter;
reg [9:0] PSG_Delay_Counter;

reg			OPN2_Not_Ready;
reg			OPM_Not_Ready;
reg			PSG_Not_Ready;


localparam  Wait_Count = 3'b000,
				Count_Count = 3'b001,
				Done_Count  = 3'b010;

reg	[2:0] ST_OPN2_Delay;
reg	[2:0] ST_OPM_Delay;
reg	[2:0] ST_PSG_Delay;

always @ (posedge OPL3_Clk_i)              
begin
	if (BUS_RST_i) begin
		ST_OPN2_Delay <= Wait_Count;
		OPN2_Delay_Counter <= 10'h0000;
		OPN2_Not_Ready <= 1'b0;
	end
	else begin
	
		case (ST_OPN2_Delay)
		Wait_Count: begin 
			if ((StateMachine == WRITE_DATA_PTR3) & FIFO_Pick[1]) begin
				OPN2_Delay_Counter <= Delay_Value;
				OPN2_Not_Ready <= 1'b1;
				ST_OPN2_Delay <= Count_Count;				
			end
		end
		
		Count_Count: begin 
			if (OPN2_Delay_Counter)
				OPN2_Delay_Counter <= OPN2_Delay_Counter - 10'h001;
			else begin
				ST_OPN2_Delay <= Done_Count;	
			end
		end
		
		Done_Count: begin 
				OPN2_Not_Ready <= 1'b0;
				ST_OPN2_Delay <= Wait_Count;				
		end
		
		default: begin 
			ST_OPN2_Delay <= Wait_Count;
		
		end
		
	
		endcase
	end


end

always @ (posedge OPL3_Clk_i)              
begin
	if (BUS_RST_i) begin
		ST_OPM_Delay <= Wait_Count;
		OPM_Delay_Counter <= 10'h0000;
		OPM_Not_Ready <= 1'b0;
	end
	else begin
	
		case (ST_OPM_Delay)
		Wait_Count: begin 
			if ((StateMachine == WRITE_DATA_PTR3) & FIFO_Pick[2]) begin
				OPM_Delay_Counter <= 10'd128;
				OPM_Not_Ready <= 1'b1;
				ST_OPM_Delay <= Count_Count;				
			end
		end
		
		Count_Count: begin 
			if (OPM_Delay_Counter)
				OPM_Delay_Counter <= OPM_Delay_Counter - 10'h001;
			else begin
				ST_OPM_Delay <= Done_Count;	
			end
		end
		
		Done_Count: begin 
				OPM_Not_Ready <= 1'b0;
				ST_OPM_Delay <= Wait_Count;				
		end
		
		default: begin 
			ST_OPM_Delay <= Wait_Count;
		
		end
		
	
		endcase
	end
end


always @ (posedge OPL3_Clk_i)              
begin
	if (BUS_RST_i) begin
		ST_PSG_Delay <= Wait_Count;
		PSG_Delay_Counter <= 10'h0000;
		PSG_Not_Ready <= 1'b0;
	end
	else begin
	
		case (ST_PSG_Delay)
		Wait_Count: begin 
			if ((StateMachine == WRITE_DATA_PTR3) & FIFO_Pick[3]) begin
				PSG_Delay_Counter <= Delay_Value;
				PSG_Not_Ready <= 1'b1;
				ST_PSG_Delay <= Count_Count;				
			end
		end
		
		Count_Count: begin 
			if (PSG_Delay_Counter)
				PSG_Delay_Counter <= PSG_Delay_Counter - 10'h001;
			else begin
				ST_PSG_Delay <= Done_Count;	
			end
		end
		
		Done_Count: begin 
				PSG_Not_Ready <= 1'b0;
				ST_PSG_Delay <= Wait_Count;				
		end
		
		default: begin 
			ST_PSG_Delay <= Wait_Count;
		
		end
		
	
		endcase
	end
end

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
