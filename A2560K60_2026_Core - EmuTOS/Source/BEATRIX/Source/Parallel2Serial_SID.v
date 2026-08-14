module Parallel2Serial_SID (
input		wire				BUS_RST_i,
input		wire				BUS_Clk_i,
output	wire				SID_Clk_o,
input		wire				Clk80_000Mhz_i,
	// 
input		wire	[7:0]		BUS_D8_i,
input		wire	[15:0]	BUS_D16_i,
input		wire	[31:0]	BUS_D32_i,
input		wire	[1:0]		BUS_D_Siz_i,
input		wire				BUS_A_Valid_i,
input		wire				BUS_RWn_i,
input		wire	[3:0]		BUS_BE_i,
input		wire				BUS_WE_i, 
input		wire				BUS_SID_L_CS_i,
input		wire				BUS_SID_R_CS_i,
input		wire	[31:0]	BUS_A_i,

output	wire				ABUS_SID_IN_o,
output	wire				ABUS_SID_CLK_o,
output	wire				ABUS_SID_LATCH_o
);

/*
wire [143:0] TP;
wire  Trigger;

assign TP[31:0] 		= BUS_A_i;
assign TP[39:32] 		= BUS_D8_i;
assign TP[43:40] 		= BUS_BE_i;
assign TP[44]			= BUS_RWn_i;
assign TP[45]			= BUS_WE_i;
assign TP[46]			= BUS_SID_L_CS_i;
assign TP[47]			= BUS_SID_R_CS_i;

assign TP[48] 			= SID_Clk_o;
assign TP[49]			= ABUS_SID_IN_o;
assign TP[50]			= ABUS_SID_CLK_o;
assign TP[51]			= ABUS_SID_LATCH_o;

assign TP[143:52]		= 0;

assign Trigger = (BUS_SID_L_CS_i | BUS_SID_R_CS_i);

TinyChipScope CHIPSCOPE68K (
	.acq_data_in    (TP),    //        tap.acq_data_in
	.acq_trigger_in (Trigger), //           .acq_trigger_in
	.acq_clk        (Clk80_000Mhz_i),        //    acq_clk.clk
	.trigger_in     (Trigger)      // trigger_in.trigger_in
);
*/

reg [1:0] SID_Rstn_SYNC;

reg	[4:0]	Address_2_Target;
reg	[7:0]	Data_2_Target;
reg			ChipSelect_L_Target;
reg			ChipSelect_R_Target;
reg			RWn_Target;

reg			BUS_SID_R_CS_i_Edge;
reg			BUS_SID_L_CS_i_Edge;



/*
always @ (posedge BUS_Clk_i)
begin
	if (BUS_RST_i) begin
		BUS_SID_R_CS_i_Edge <= 1'b0;
		BUS_SID_L_CS_i_Edge <= 1'b0;		
	end
	else begin
		BUS_SID_R_CS_i_Edge <= BUS_SID_R_CS_i & ( BUS_D_Siz_i[1:0] == 2'b01 ) & ({BUS_A_Valid_Slide, BUS_A_Valid_i} == 2'b10);
		BUS_SID_L_CS_i_Edge <= BUS_SID_L_CS_i & ( BUS_D_Siz_i[1:0] == 2'b01 ) & ({BUS_A_Valid_Slide, BUS_A_Valid_i} == 2'b10);
	end
end
*/
wire	[15:0]	Output_Fifo;
wire				EmptyFIFO;
SID_CMD_Write_FIFO	SID_CMD_Write_FIFO_inst (
	.aclr( BUS_RST_i ), 
	// CPU SPEED
	.wrclk ( BUS_Clk_i ),
	.wrreq ( (BUS_SID_R_CS_i | BUS_SID_L_CS_i) & ( BUS_D_Siz_i[1:0] == 2'b01 ) & BUS_WE_i ),	
	.wrfull (  ),	
	.data ( {BUS_D8_i, BUS_RWn_i, BUS_SID_L_CS_i, BUS_SID_R_CS_i, BUS_A_i[4:0] } ),
	
	// 80Mhz
	.rdclk( Clk80_000Mhz_i ), 
	.rdreq ( ReadFifo ),
	.rdempty ( EmptyFIFO ),
	.q ( Output_Fifo )
	//.usedw (  )
	);


localparam	PARA_IDLE				= 4'b0000,
				READ_FIFO				= 4'b0001,
				LATENCY_READ			= 4'b0010,
				WAIT_RISING_EDGE		= 4'b0011,
				Enable_Transaction	= 4'b0100,
				WAIT_FALLING_EDGE		= 4'b0101,
				DONE						= 4'b0110;

reg	[3:0]		SM_SID;
reg				ReadFifo;


wire 	[7:0] SID_Data;
wire	[4:0]	SID_Addy;


reg REG_SID_CS_R;
reg REG_SID_CS_L;
reg REG_SID_RW;

// When the CPU writes, the Target are Refreshed and the state Machine can begin
assign	SID_Data 	= Output_Fifo[15:8];
assign 	SID_Addy  	= Output_Fifo[4:0];

always @ (posedge Clk80_000Mhz_i)
begin
	if (BUS_RST_i) begin
		SM_SID <= PARA_IDLE;
		//Enable <= 1'b0;
		ReadFifo <= 1'b0;
	end
	else begin
		case(SM_SID)
		
		PARA_IDLE: begin
			if ( ( EmptyFIFO == 1'b0) && ( TIP_o == 1'b0 ) ) begin
				ReadFifo <= 1'b1;
				SM_SID <= READ_FIFO;
			end
		end
		
		READ_FIFO: begin
			ReadFifo <= 1'b0;		
			SM_SID <= LATENCY_READ;
		end
		
		LATENCY_READ: begin
			SM_SID <= WAIT_RISING_EDGE;		
		end
		
		// Data Valid Here
		// Wait here to get the next Clock Edge
		WAIT_RISING_EDGE: begin
			if ({ SIDCLK_EDGE, SID_Clk_o } == 2'b10)	begin// Rising Edge
				REG_SID_CS_L 	<= !Output_Fifo[5];
				REG_SID_CS_R 	<= !Output_Fifo[6];	
				REG_SID_RW 		<=  Output_Fifo[7];
				SM_SID <= Enable_Transaction;
			end
			else
				SM_SID <= WAIT_RISING_EDGE;
		end
		
		Enable_Transaction: begin
			SM_SID <= WAIT_FALLING_EDGE;			
		end
		
		WAIT_FALLING_EDGE: begin
			if ({ SIDCLK_EDGE, SID_Clk_o } == 2'b01) begin// Falling Edge
				SM_SID <= DONE;
				REG_SID_CS_L <= 1'b1;
				REG_SID_CS_R <= 1'b1;	
				REG_SID_RW <= 1'b1;
			end
			else
				SM_SID <= WAIT_FALLING_EDGE;			
		end
		
		DONE: begin
			SM_SID <= PARA_IDLE;			
		end
	
		
		default: begin
			SM_SID <= PARA_IDLE;
		
		end
		
		endcase
	end
end

reg SIDCLK_EDGE;

always @ (posedge Clk80_000Mhz_i)
begin
	SIDCLK_EDGE <= SID_Clk_o;
end



// Clock Generation
reg	[7:0] 	ClockGenerationCNT;

always @ (posedge Clk80_000Mhz_i)
begin
	if (BUS_RST_i) begin
		ClockGenerationCNT <= 8'b0000_0000; 
	end
	else begin
		if (ClockGenerationCNT < 8'd40) begin
			ClockGenerationCNT <= ClockGenerationCNT + 8'b0000_0001;
		end
		else begin
			SID_Clk_o <= ~SID_Clk_o;
			ClockGenerationCNT <= 8'b0000_0000;
		end
	
	end
end



/////////////////////////////////////
///  SERIALIZATION SECTION
/////////////////////////////////////
wire 	[15:0]	 DataStream0;
//wire				 SERIAL_Clk_i;
/*
assign DataStream0 = { 
		SID_Data[7], // MSB
		SID_Data[6],
		SID_Data[5],
		SID_Data[4],
		SID_Data[3],
		SID_Data[2],
		SID_Data[1],
		SID_Data[0],
		
		SID_RW,
		SID_CS_L,
		SID_CS_R,
		SID_Addy[0],
		SID_Addy[1],
		SID_Addy[2],
		SID_Addy[3],
		SID_Addy[4] // LSB
};
*/

assign DataStream0 = { SID_Addy[4], SID_Addy[3], SID_Addy[2], SID_Addy[1],	SID_Addy[0], REG_SID_CS_R, REG_SID_CS_L,	REG_SID_RW,
							  SID_Data[7], SID_Data[6], SID_Data[5], SID_Data[4],	SID_Data[3],SID_Data[2], SID_Data[1], SID_Data[0] };

localparam SERIAL_IDLE   = 5'b0_0000,
			  STATE1 = 5'b0_0001,
			  STATE2 = 5'b0_0011,
			  STATE3 = 5'b0_0010,
			  STATE4 = 5'b0_0110,
			  STATE5 = 5'b0_0111,
			  STATE6 = 5'b0_0101,
			  STATE7 = 5'b0_0100,
			  STATE8 = 5'b0_1100,
			  STATE9 = 5'b0_1101;

reg	[4:0] 	StateMachine;
reg				TIP_o;
reg   [7:0] 	BitCounter;
reg	[15:0]	Reg_DataStream0;
reg	[15:0]		Reg_ControlStream_Sync;

assign ABUS_SID_IN_o = Reg_DataStream0[15];

//assign SERIAL_Clk_i = BUS_Clk_i;

always @ (posedge Clk80_000Mhz_i)
begin
	if (BUS_RST_i) begin
			Reg_DataStream0 <= 16'b1000_0110_1010_1010;
	end
	else begin
	
		case (StateMachine)
			
		STATE1: begin
			Reg_DataStream0	<= DataStream0;
		end
	
		STATE3: begin
			Reg_DataStream0	<= Reg_DataStream0 << 1'b1;
		end
	
		endcase
	end
end

wire 	 Clk_CTRL_Toggle;
assign Clk_CTRL_Toggle = (StateMachine == STATE3) ? 1'b1 : 1'b0;
assign ABUS_SID_CLK_o =  Clk_CTRL_Toggle;
reg 	Ctrl_Latch;
assign ABUS_SID_LATCH_o = Ctrl_Latch;
// 4.46us Second To Update the Entire Serial To Parallel

always @ (posedge Clk80_000Mhz_i)
begin
	if (BUS_RST_i) begin
		Ctrl_Latch <= 1'b0;
		TIP_o <= 1'b0;	
		StateMachine <= SERIAL_IDLE;
		Reg_ControlStream_Sync <= 16'hFFFF;
		BitCounter <= 8'b0000_0000;
	end
	else begin
	
		case(StateMachine)
	
		SERIAL_IDLE: begin
			if (Reg_ControlStream_Sync == DataStream0) begin
				StateMachine <= SERIAL_IDLE;
				Ctrl_Latch <= 1'b0;
				TIP_o <= 1'b0;				
			end 
			else begin
				StateMachine <= STATE1;
				TIP_o <= 1'b1;
				Reg_ControlStream_Sync <= DataStream0;				
			end
		end
		
		// Registering the Actual Data to be Streamed out
		STATE1: begin
				BitCounter <= 8'b0001_0000;	// Load the nUmber of bit to shift 32.
				StateMachine <= STATE2;		
		end
		
		// Transfer the first 16Bits with Data and Command
		STATE2: begin
			if (BitCounter) begin
				BitCounter <= BitCounter - 8'b0000_0001;
				StateMachine <= STATE3;				
			end
			else begin
				StateMachine <= STATE4;
			end
		end
		
		STATE3: begin
				StateMachine 	<= STATE2;
		end
		
		STATE4: begin
				StateMachine 	<= STATE5;
				Ctrl_Latch 		<= 1'b1;
		end
		
		STATE5: begin
				StateMachine 	<= SERIAL_IDLE;		
		end

		default: begin
			StateMachine <= SERIAL_IDLE;
		end
	
		endcase
	end
end

endmodule
