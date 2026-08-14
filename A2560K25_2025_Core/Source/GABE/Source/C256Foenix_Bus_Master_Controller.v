`timescale 1 ps / 1 ps
module C256Foenix_Bus_Master_Controller(

input		wire				RST_i,
input		wire				CPU_Clk_i,
input    wire				CPU_Clk4x_i,

input		wire				BUSMASTER_REQ_i,
input		wire				BUSMASTER_REQ_VKY_i,
output	reg				BUSMASTER_ACK_o,	

output	reg				BUSMASTER_RDY_o,	// This is to Stop the CPU

output	reg				BUSMASTER_BE_o,
output	reg				BUSMASTER_MUX_OE_o,
output	reg				BUSMASTER_INPROGRESS_o
);


reg	[3:0]		StateMachine;


localparam	IDLE 					= 4'b0000,
				STOP_CPU				= 4'b0001,
				WAIT_1_CYCLE  		= 4'b0010,
				HI_Z_THEBUS			= 4'b0011,
				GIVEUPTHEBUS		= 4'b0100,
				WAIT_2_GETITBACK	= 4'b0101,
				RE_ENABLE_THEBUS	= 4'b0110,
				LET_GO_OF_THE_CPU = 4'b0111,
				THE_END           = 4'b1000;




reg	[1:0]		BUS_REQ_i_EDGE;

always @ (posedge CPU_Clk_i)
begin
	BUS_REQ_i_EDGE[0] <= BUSMASTER_REQ_i;
	BUS_REQ_i_EDGE[1] <= BUS_REQ_i_EDGE[0];
end

reg	[1:0]		BUS_REQ_VKY_i_EDGE;

always @ (posedge CPU_Clk_i)
begin
	BUS_REQ_VKY_i_EDGE[0] <= BUSMASTER_REQ_VKY_i;
	BUS_REQ_VKY_i_EDGE[1] <= BUS_REQ_VKY_i_EDGE[0];
end


always @ (posedge CPU_Clk4x_i) begin

	if (RST_i) begin
			BUSMASTER_RDY_o <= 1'b0;	
	end
	else begin
		if (StateMachine == STOP_CPU) 
			BUSMASTER_RDY_o <= 1'b1;
			
		if ((StateMachine == LET_GO_OF_THE_CPU) || (StateMachine == IDLE))
			BUSMASTER_RDY_o <= 1'b0;	
	end
	
end

reg BusMaster_Ready;

always @ (posedge CPU_Clk_i)
begin
	if (RST_i) begin
		BUSMASTER_ACK_o		<= 1'b1;	// When a request will be submited and accepted, the ACK will be brought down.
		//BUSMASTER_RDY_o		<= 1'b0; // RDY = 1'b0, the CPU is working as it should
		BUSMASTER_BE_o			<= 1'b1; // BE = 1'b1, the Driver from the CPU are Enabled
		BUSMASTER_MUX_OE_o	<= 1'b0;	// OE = 1'b0, the MUX is doing its work
		BUSMASTER_INPROGRESS_o <= 1'b0; // InProgress = 1'b1 = VICKY II is requesting the BUS (4 DMA)
		
		StateMachine <= IDLE;
	end
	else begin
		case(StateMachine)
		
		IDLE: begin 
			if ((BUS_REQ_i_EDGE[1:0] == 2'b10) || (BUS_REQ_VKY_i_EDGE[1:0] == 2'b10)) begin
				StateMachine <= STOP_CPU;
			
			end
			else begin
				StateMachine <= IDLE;		
		
			end
		end
		
		STOP_CPU: begin 
				StateMachine <= WAIT_1_CYCLE;
			//	BUSMASTER_RDY_o <= 1'b1;
		end
		
		WAIT_1_CYCLE: begin
				StateMachine <= HI_Z_THEBUS;		
		end
		
		// The CPU should have stopped.
		HI_Z_THEBUS: begin 
				BUSMASTER_BE_o	<= 1'b0;
				BUSMASTER_MUX_OE_o <= 1'b1;
				StateMachine <= GIVEUPTHEBUS;
				
		end
		
		GIVEUPTHEBUS: begin 
				BUSMASTER_ACK_o <= 1'b0;
				BUSMASTER_INPROGRESS_o <= 1'b1;
				StateMachine <= WAIT_2_GETITBACK;		
		end
		
		WAIT_2_GETITBACK: begin 
			if ( BUS_REQ_i_EDGE[1] && BUS_REQ_VKY_i_EDGE[1] ) begin 
				StateMachine <= RE_ENABLE_THEBUS;
				BUSMASTER_ACK_o <= 1'b1;	// Release the BUS
				BUSMASTER_BE_o	<= 1'b1;
				BUSMASTER_MUX_OE_o <= 1'b0;
			end 
			else begin
				StateMachine <= WAIT_2_GETITBACK;				
			end
		end
		
		RE_ENABLE_THEBUS: begin
				BUSMASTER_INPROGRESS_o <= 1'b0;
				StateMachine <= LET_GO_OF_THE_CPU;	
		end
		
		LET_GO_OF_THE_CPU: begin
				//BUSMASTER_RDY_o <= 1'b0;
				StateMachine <= THE_END;		
		end
		
		THE_END: begin 
				StateMachine <= IDLE;		
		end
		
		endcase
	end


end

endmodule

