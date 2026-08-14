module LPC_DMA_Controller
(
input 	wire				rst_i,				// That Reset comes from from LPC_CLK Domain
input 	wire				Bus_Clk_i,
input 	wire	[23:0]	Bus_A_i,
input		wire  [7:0]		Bus_D_i,

input		wire				Bus_RW_i,

input		wire				CS_LPC_DMA_CTRL_i,
input		wire				CS_LPC_DMA_DP_i,

output	reg	[7:0]		DataOut_LPC_DMA_CTRL_o,
output	wire	[7:0]		DataOut_LPC_DMA_DP_o,

// LPC Block Interface
input 	wire				LPC_Clk_i,
input		wire	[31:0]	LPC_Data_Out_i,
input		wire				LPC_Ack_i,
input		wire				LPC_Err_i,

input		wire				LPC_DMA_Req_i,
input		wire	[2:0]		LPC_DMA_Channel_i,		// Channel 2 is for Floppy, let's use that first.
output	wire				LPC_DMA_TC_o,
// Outputs
output	wire	[7:0]		LPC_Data_In_o,
output	wire				LPC_Write_o,
output	reg				LPC_Strobe_o,
output 	reg				LPC_DMA_InProgress_o
);


reg	[7:0]	LPC_DMA_CONFIG[0:3];


assign LPC_DMA_TC_o = 1'b1;
assign LPC_Write_o = 1'b0;

initial
begin
LPC_DMA_InProgress_o = 1'b0;
end

// Keep the Input Value in Registers
always @ (negedge Bus_Clk_i)
begin

	if (CS_LPC_DMA_CTRL_i & !Bus_RW_i)
		LPC_DMA_CONFIG[Bus_A_i[1:0]] <= Bus_D_i;

end

always @ (*)
begin
	case(Bus_A_i[3:0])
		4'b0000: DataOut_LPC_DMA_CTRL_o = LPC_DMA_CONFIG[0];
		4'b0001: DataOut_LPC_DMA_CTRL_o = LPC_DMA_CONFIG[1];
		4'b0010: DataOut_LPC_DMA_CTRL_o = LPC_DMA_CONFIG[2];
		4'b0011: DataOut_LPC_DMA_CTRL_o = LPC_DMA_CONFIG[3];
		//4'b0100: DataOut_LPC_DMA_CTRL_o = FIFO_WRITE_BYTE[7:0];
		//4'b0101: DataOut_LPC_DMA_CTRL_o = {6'b0000_00, FIFO_WRITE_FULL, FIFO_WRITE_BYTE[8]};
		//4'b0110: DataOut_LPC_DMA_CTRL_o = FIFO_READ_BYTE[7:0];
		//4'b0111: DataOut_LPC_DMA_CTRL_o = {6'b0000_00, FIFO_READ_EMPTY, FIFO_WRITE_BYTE[8]};
		//4'b1000: DataOut_LPC_DMA_CTRL_o = FIFO_READ_BUS;	// FIFO Output
		default: DataOut_LPC_DMA_CTRL_o = 8'h55;
	endcase
end

reg Read_FIFO_LPC;
wire 	[8:0]	FIFO_READ_BYTE;
wire			FIFO_READ_EMPTY;
wire 	[8:0]	FIFO_WRITE_BYTE;
wire			FIFO_WRITE_FULL;
wire	[7:0]	FIFO_READ_BUS;

// LPC_Data_Out_i
// CPU 2 FLOPPY (WRITE)
/*
FloppyDMA_FIFO	FloppyDMA_FIFO_inst (
	.aclr ( LPC_DMA_CONFIG[0] ),

	//Write Section - 14Mhz Clock Domain
	.data ( Bus_D_i ),
	.wrclk ( !Bus_Clk_i ),
	.wrreq ( CS_FLOPPY_DMA_MEM_i & !Bus_RW_i & Bus_Clk_i & (Bus_A_i[7:4] == 4'b0001) ),

	// Read Section - 33Mhz
	.rdclk ( LPC_Clk_i ),
	.rdreq ( Read_FIFO_LPC ),	// Read from LPC DMA
	.q ( LPC_Data_In_o ),		// Output for the DMA Transaction to take place
	
	// Status 
	.rdempty (  ),	// Could be Used to Create an Interrupt for the CPU
	.rdusedw (  ),
	
	.wrfull ( FIFO_WRITE_FULL ),
	.wrusedw ( FIFO_WRITE_BYTE )
	);
*/

DP512Bytes	DP512Bytes_inst (
	// CPU Side @ 14Mhz
	.clock_a 	( !Bus_Clk_i ),
	.address_a	( Bus_A_i ),
	.data_a 		( Bus_D_i ),
	.wren_a 		( CS_LPC_DMA_DP_i & !Bus_RW_i & Bus_Clk_i ),
	.q_a 			( DataOut_LPC_DMA_DP_o ),
	
	// LPC Side @ 33Mhz
	.clock_b ( LPC_Clk_i ),
	.address_b ( LPC_Adress_PTR ),
	.data_b ( LPC_Data_Out_i[7:0] ),
	.wren_b ( LPC_Ack_i ),
	.q_b ( LPC_Data_In_o )
	
	);


reg [2:0]	StateMachine;

reg	[8:0]		LPC_Adress_PTR;

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
		LPC_Strobe_o <= 1'b0;
	end
	else begin
	
		case (StateMachine)

		IDLE: 
		begin
			if (LPC_DMA_Req_i) begin
				StateMachine <= BEGIN_CYCLE;
				LPC_DMA_InProgress_o	<= 1'b1;
			end
			else begin
				StateMachine 	<= IDLE;
				LPC_DMA_InProgress_o	<= 1'b0;
			end
		end

		BEGIN_CYCLE: 
		begin
				LPC_Strobe_o <= 1'b1;	// Begin Cycle
				StateMachine <= END_CYCLE;					
		end
		
		END_CYCLE: 
		begin
			if (LPC_Ack_i) begin
				LPC_Strobe_o <= 1'b0;
				LPC_DMA_InProgress_o	<= 1'b0;				
				StateMachine <= END_CYCLE1;	// If Writing, we are done.
			end
		end

		END_CYCLE1: 
		begin
			LPC_Adress_PTR <= LPC_Adress_PTR + 9'b0_0000_0001;
			StateMachine <= IDLE;	// If Writing, we are done.	
		end

		default: begin
			StateMachine <= IDLE;		
		end
	

	endcase
	
	
	end
end
/*
wire [47:0] ChipScope;
wire Trigger;
//assign Trigger = dma_req_i | LPC_IRQ[6];

assign Trigger = LPC_DRQ_i;

assign ChipScope[7:0] = LPC_Data_Out_i[7:0];
assign ChipScope[15:8] = LPC_Data_In_o[7:0];
assign ChipScope[16] = LPC_Write_o;
assign ChipScope[17] = LPC_Strobe_o;
assign ChipScope[18] = LPC_Ack_i;
assign ChipScope[19] = LPC_Err_i;
assign ChipScope[20] = LPC_DMA_Req_i;
assign ChipScope[21] = LPC_Err_i;
assign ChipScope[22] = LPC_DMA_Req_i;
assign ChipScope[23] = 1'b0;
//assign ChipScope[39:0] = 0;
assign ChipScope[24] = LPC_DMA_Req_i;
assign ChipScope[26:25] = LPC_DMA_Channel_i;
assign ChipScope[29:27] = StateMachine;

assign ChipScope[47:30] = 0;



ChipScope	ChipScope_inst (
	.acq_clk ( LPC_Clk_i ),
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);
*/
	
endmodule
/*
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
				Read_FIFO_LPC 	<= 1'b1;
				Timeout			<= 8'h20;
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
*/