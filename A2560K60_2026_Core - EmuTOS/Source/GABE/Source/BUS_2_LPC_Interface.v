`timescale 1 ns / 1 ns

module BUS_2_LPC_interface 
(
input 	wire				rst_i,				// That Reset comes from from LPC_CLK Domain
input 	wire				Bus_Clk_i,
input 	wire	[31:0]	Bus_A_i,
input		wire				Bus_A_Valid_i,

input		wire	[7:0]		Bus_D8_i,
input		wire	[15:0]	Bus_D16_i,
input		wire	[31:0]	Bus_D32_i,
input		wire	[1:0]		Bus_D_Siz_i,

output 	wire	[31:0]	Bus_D_o,
input		wire				Bus_RW_i,
output	wire				Bus_D_Valid_o,
input		wire	[3:0]		Bus_BE_i,
input		wire				Bus_WE_i, 
input		wire				CS_VID_SuperIO_i,
output	wire				Wait_LPC_TA_o, 

// LPC Block Interface
input 	wire				LPC_Clk_i,
input		wire	[31:0]	LPC_Data_Out_i,
input		wire				LPC_Ack_i,
input		wire				LPC_Err_i,
// Outputs
output	wire	[15:0] 	LPC_Address_o,
output	wire	[7:0]		LPC_Data_In_o,
output	wire				LPC_Write_o,
output	reg				LPC_Strobe_o
);



assign Bus_D_Valid_o = 1'b0;

reg [63:0]	LPC_Slide;


always @ ( posedge Bus_Clk_i ) begin
	if (rst_i) begin
		LPC_Slide <= 64'h0000_0000_0000_0000;
	
	end 
	else begin
		if ( CS_VID_SuperIO_i ) begin
			LPC_Slide <= {LPC_Slide[62:0], Bus_A_Valid_i};
		end
		else begin
			LPC_Slide <= 64'h0000_0000_0000_0000;
		end
	end
end

assign Wait_LPC_TA_o = Bus_RW_i ? (LPC_Slide[63] | LPC_DATA_RDY) : LPC_Slide[3];	// 

reg [1:0]	TinySM;
reg LPC_DATA_RDY;

always @ (posedge Bus_Clk_i) begin
	if (rst_i) begin
		TinySM <= 2'b00;
		Data_LPC_Out_RDReq <= 1'b0;
		LPC_DATA_RDY <= 1'b0;
	end
	else begin
	
		case (TinySM) 
			2'b00: begin 
				if ( Data_LPC_Out_RDEmpty == 1'b0 ) begin
						Data_LPC_Out_RDReq <= 1'b1;
						TinySM <= 2'b01;
				end
				else begin
					Data_LPC_Out_RDReq <= 1'b0;
					LPC_DATA_RDY <= 1'b0;
				end
			
			end
			
			2'b01: begin 
					TinySM <= 2'b10;
					Data_LPC_Out_RDReq <= 1'b0;
			end
			
			// 
			2'b10: begin 
				TinySM <= 2'b11;
				LPC_DATA_RDY <= 1'b1;
			end
			
			//Data Valid Here
			2'b11: begin 
				TinySM <= 2'b00;	
			end
			
			default: begin 
				TinySM <= 2'b00;
			end
			
		endcase
	end
end


/*
reg [1:0]	TinySM;

reg	[19:0] CountDownDTACK;
assign BUS_D_Valid_o = CountDownDTACK[19];

always @ (posedge Bus_Clk_i) begin
	if (rst_i) begin

		CountDownDTACK	<= 20'h0_0000;
		TinySM			<= 2'b00;
	end
	else begin
		CountDownDTACK <= CountDownDTACK << 1'b1;
	
		case (TinySM) 
			2'b00: begin
				if (CS_VID_SuperIO_i & Bus_RW_i) begin
					CountDownDTACK <= 20'hF_FFF8;
					TinySM <= 2'b01;
				end
				else begin
					if (CS_VID_SuperIO_i & !Bus_RW_i) begin
						CountDownDTACK <= 20'hF_0000;
						TinySM <= 2'b01;
					end
					else begin
						CountDownDTACK <= 20'h0_0000;
						TinySM <= 2'b00;
					end
				end
	
			end
		
			2'b01: begin 
				if (BUS_D_Valid_o) begin
					TinySM <= 2'b01;				
				end
				else begin
					TinySM <= 2'b10;				
				end
			end
		
			2'b10: begin 
					TinySM <= 2'b11;
			end
		
			2'b11: begin 
					TinySM <= 2'b00;			
			end
		
		endcase
	
	end

end
*/

/*
wire [71:0] TinyTP;
wire 			TinyTrigger;

assign TinyTrigger = (CS_VID_SuperIO_i_Slide[2:0] == 3'b001) ? 1'b1 : 1'b0;

assign TinyTP[23:0]  	= Bus_A_i[23:0];
assign TinyTP[39:24] 	= Bus_D8_i;
assign TinyTP[47:40]   	= Data_Out;
assign TinyTP[48]   		= Bus_RW_i;
assign TinyTP[49]   		= CS_VID_SuperIO_i;
assign TinyTP[53:50] 	= Bus_BE_i;
assign TinyTP[54]			= Bus_D_Valid_o;
assign TinyTP[55]			= WrFull;
assign TinyTP[56]			= 1'b0;
assign TinyTP[57]			= Bus_A_Valid_i;
assign TinyTP[58]			= Wait_LPC_TA_o;
assign TinyTP[59] 		= Data_LPC_Out_RDEmpty;
assign TinyTP[60]			= Data_LPC_Out_RDReq;
assign TinyTP[61] 		= LPC_DATA_RDY;
assign TinyTP[64:62] 	= CS_VID_SuperIO_i_Slide[2:0];


TinyChipScope u0 (
	.acq_data_in    (TinyTP),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger), //           .acq_trigger_in
	.acq_clk        (Bus_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger)      // trigger_in.trigger_in
);
*/

// There is a Clock Realm Crossing here, but the when the Value is read by CPU, the Value has been stable for a while.

wire	[23:0] 		CMD_FIFO_Output;
wire					CMD_FIFO_Empty;
wire					DATA_FIFO_Empty;

reg 	[2:0] rst_i_Resync;



//wire Write_2_FIFO_CMD_Condition;

//assign Write_2_FIFO_CMD_Condition = ( CS_VID_SuperIO_i & ( Bus_D_Siz_i[1:0] == 2'b01 ) & Bus_WE_i);

//assign Write_2_FIFO_CMD_Condition = (CS_VID_SuperIO_i & ( Bus_D_Siz_i[1:0] == 2'b01 ))
// Resync Reset Since it is coming from the 33Mhz Realm
reg [2:0] CS_VID_SuperIO_i_Slide;

always @ (posedge Bus_Clk_i)
begin
	CS_VID_SuperIO_i_Slide[0]  <= CS_VID_SuperIO_i;
	CS_VID_SuperIO_i_Slide[1]  <=	CS_VID_SuperIO_i_Slide[0];
	CS_VID_SuperIO_i_Slide[2]  <=	CS_VID_SuperIO_i_Slide[1];	
end



always @ (posedge Bus_Clk_i)
begin
		rst_i_Resync[0] <= rst_i;
		rst_i_Resync[1] <= rst_i_Resync[0];
		rst_i_Resync[2] <= rst_i_Resync[1];		
end


wire WrFull;

LPC_CMD_FIFO LPC_COMMAND_FIFO(
	// Write Side @ 20Mhz with the MC68SEC000
	.aclr ( rst_i_Resync[2] ),
	.data({ Bus_D8_i, Bus_RW_i, Bus_A_i[14:0] }),
	.wrclk( Bus_Clk_i ),
	.wrreq(CS_VID_SuperIO_i_Slide[2:0] == 3'b001),
	.wrfull( WrFull ),
	// Read Side @ 33Mhz
	.rdclk( LPC_Clk_i ),
	.rdreq( Read_FIFO_LPC ),
	.q( CMD_FIFO_Output ),
	.rdempty( CMD_FIFO_Empty )
);



wire [7:0] Data_Out;
wire 			Data_LPC_Out_RDEmpty;
reg 			Data_LPC_Out_RDReq;
reg			WR_FIFO_Data;

LPC_DATA_FIFO	LPC_DATA_FIFO_inst (
	.aclr ( rst_i_Resync[2] ),

	.rdclk ( Bus_Clk_i ),
	.rdreq ( Data_LPC_Out_RDReq ),
	.q ( Data_Out ),

	.wrclk ( LPC_Clk_i ),
	.wrreq ( CMD_FIFO_Output[15] ? LPC_Ack_i : 1'b0 ),
	.data ( LPC_Data_Out_i[7:0] ),

	.rdempty ( Data_LPC_Out_RDEmpty ),
	.wrfull (  )
	);
	
assign Bus_D_o = {Data_Out, Data_Out, Data_Out, Data_Out};

wire Write_2_FIFO_Read_Condition;

assign Write_2_FIFO_Read_Condition = (LPC_Ack_i & CMD_FIFO_Output[15]);

reg Read_LPC_Valid;
always @ (posedge LPC_Clk_i) begin
	Read_LPC_Valid <= Write_2_FIFO_Read_Condition;
end
/*
wire [7:0] Source;
wire [7:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);
*/
/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = ( Source == CMD_FIFO_Output[23:16] ) & LPC_Write_o;
assign TinyTrigger1 = CMD_FIFO_Empty == 1'b0;

assign TinyTP1[23:0]  	= CMD_FIFO_Output;
assign TinyTP1[24] 		= CMD_FIFO_Empty;
assign TinyTP1[25]   	= Read_FIFO_LPC;
assign TinyTP1[28:26]	= StateMachine;
assign TinyTP1[29] 		= LPC_Write_o;
assign TinyTP1[30]		= LPC_Strobe_o;
assign TinyTP1[31]		= LPC_Ack_i;
assign TinyTP1[63:32]	= LPC_Data_Out_i;


TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (LPC_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/

assign LPC_Address_o = {1'b0, CMD_FIFO_Output[14:0]} & 16'h03FF;
assign LPC_Data_In_o = CMD_FIFO_Output[23:16];
assign LPC_Write_o = !CMD_FIFO_Output[15];


reg [2:0]	StateMachine;
reg			Read_FIFO_LPC;

localparam	IDLE 					= 3'b000,
				BEGIN_CYCLE			= 3'b001,
				END_CYCLE 			= 3'b010,
				END_CYCLE1 			= 3'b011,
				END_CYCLE2			= 3'b100;

reg	[7:0]	Timeout;
reg	[7:0]	Timeout_Error;

always @ (posedge LPC_Clk_i)
begin
	if (rst_i) begin
		StateMachine <= IDLE;
		Timeout_Error <= 8'h00;
		Read_FIFO_LPC <= 1'b0;
		LPC_Strobe_o <= 1'b0;
	end
	else begin
	
		case (StateMachine)

		IDLE: 
		begin
			if (CMD_FIFO_Empty) begin
				StateMachine <= IDLE;		
			end
			else begin
				WR_FIFO_Data <= 1'b0;
				Read_FIFO_LPC 	<= 1'b1;
				Timeout			<= 8'h30;
				StateMachine 	<= BEGIN_CYCLE;				
			end
		end

		BEGIN_CYCLE: 
		begin
				Read_FIFO_LPC <= 1'b0;
				LPC_Strobe_o <= 1'b1;
				StateMachine <= END_CYCLE;					
		end
		
		END_CYCLE: 
		begin
			if (LPC_Ack_i) begin
				LPC_Strobe_o <= 1'b0;
				StateMachine <= END_CYCLE1;	// If Writing, we are done.

			end
			else begin
				if (Timeout) begin
					Timeout <= Timeout - 1'b1;
					StateMachine <= END_CYCLE;					
					end
					else begin
						Timeout_Error <= Timeout_Error + 1'b1;
						LPC_Strobe_o <= 1'b0;
						
						StateMachine <= END_CYCLE1;	// If Writing, we are done.					
					end
			end
		end

		END_CYCLE1: 
		begin
			StateMachine <= IDLE;	// If Writing, we are done.	
		end
		


		default: begin
			StateMachine <= IDLE;		
		end
	

	endcase
	
	
	end
end

// Delay the DATA Fifo Empty
/*
reg [2:0] DATA_FIFO_Empty_DLY;

always @ (posedge Bus_Clk_i)
begin

	if (rst_i_Resync[2]) begin
		DATA_FIFO_Empty_DLY[2:0] <= 3'b111;
	end
	else begin
		DATA_FIFO_Empty_DLY[0] <= DATA_FIFO_Empty;
		DATA_FIFO_Empty_DLY[1] <= DATA_FIFO_Empty_DLY[0];
		DATA_FIFO_Empty_DLY[2] <= DATA_FIFO_Empty_DLY[1];
	end
		
end
*/
/*
LPC_2_READ_FIFO LPC_2_BUS_FIFO(
	.aclr ( rst_i_Resync[2] ),
	.data(  LPC_Data_Out_i[7:0] ),
	.rdclk( !Bus_Clk_i ),
//	.rdreq( Read_FIFO ),
	.rdreq( 1'b1 ),	
	.wrclk( LPC_Clk_i ),
	.wrreq( LPC_Ack_i ),
	.q( LPC_Data_Out_o ),
	.rdempty( DATA_FIFO_Empty ),
	.wrfull()
);
*/

/*
wire	[7:0]		PeekPoke;
wire	[63:0]	ChipScope;
wire				Trigger;
//assign ChipScope[6:0] = {Write_LPC_IncomingData ,Read_Data_Strobe, CMD_FIFO_Empty, StateMachine};

assign ChipScope[23:0] = Bus_A_i;
assign ChipScope[31:24] = Bus_D_i;
assign ChipScope[39:32] = Bus_D_o;
assign ChipScope[40] = CS_VID_SuperIO_i;
assign ChipScope[41] = Bus_RW_i;
assign ChipScope[42] = rst_i;
assign ChipScope[43] = Bus_Rdy_o;
assign ChipScope[44] = DATA_FIFO_Empty;
assign ChipScope[52:45] = LPC_Data_Out_o;
assign ChipScope[63:53] = 0;
*/
/*
assign ChipScope[23:0] = {8'h00, LPC_Address_o};
assign ChipScope[31:24] = LPC_Data_In_o;
assign ChipScope[39:32] = LPC_Data_Out_i[7:0];
assign ChipScope[40] = LPC_Strobe_o;
assign ChipScope[41] = LPC_Ack_i;
assign ChipScope[42] = LPC_Write_o;
assign ChipScope[43] = CMD_FIFO_Empty;
assign ChipScope[44] = LPC_Err_i;
assign ChipScope[47:45] = StateMachine;
assign ChipScope[48] = rst_i;
assign ChipScope[53:49] = 0;
assign ChipScope[55:54] = 0;
assign ChipScope[63:56] = Timeout_Error;
*/

//assign Trigger = !LPC_Write_o & LPC_Strobe_o & (LPC_Address_o == 16'h0060);
/*
assign Trigger = CS_VID_SuperIO_i & !Bus_RW_i & (Bus_A_i == 24'h7F1123);


ChipScope ChipSCOPE(
		.acq_clk(!Bus_Clk_i),        // acq_clk.clk
		.acq_data_in(ChipScope),    //     tap.acq_data_in
		.acq_trigger_in(Trigger),  //        .acq_trigger_in
		.trigger_in(Trigger)
	);
*/
/*
ChipScope ChipSCOPE(
		.acq_clk(LPC_Clk_i),        // acq_clk.clk
		.acq_data_in(ChipScope),    //     tap.acq_data_in
		.acq_trigger_in(Trigger),  //        .acq_trigger_in
		.trigger_in(Trigger)
	);
*/
	
	
endmodule

/*
always @ (negedge Bus_Clk_i)
begin
	if (rst_i) begin
			EnableReady <= 1'b0;
			SM <= 3'b000;
	end
	else begin
	
		case (SM)
	
		3'b000: begin 
			if ({Read_Slip[1:0], Read_Cycle} == 3'b001) begin
				SM <= 3'b001;
				EnableReady <= 1'b1;
				end
			else
				SM <= 3'b000;
		end
		
		// Wait for CMD_Write_Empty
		3'b001: begin
			if (CMD_Write_Empty)
					SM <= 3'b010;
			else
					SM <= 3'b001;
			end
		// Wait for DATA_FIFO_Empty 
		3'b010: begin
			if (DATA_FIFO_Empty)
					SM <= 3'b010;
			else begin
					EnableReady <= 1'b0;			// The Data is Valid, stop the Ready		
					SM <= 3'b011;
			end		
		
		end
		
		3'b011: begin
			if ({Read_Slip[1:0], Read_Cycle} == 3'b110) begin		// Wait for the Falling Edge
				SM <= 3'b000;
			end
			else
				SM <= 3'b011;				
		end
	
		default: begin
			EnableReady <= 1'b0;
			SM <= 3'b000;
		end
	
		endcase
	
	end

end
*/