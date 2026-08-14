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
output	reg				Wait_LPC_TA_o, 

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
assign Bus_D_Valid_o 	= 1'b0;


reg 		ACCESS_FIFO_Write;
always @ (posedge Bus_Clk_i) begin
	ACCESS_FIFO_Write <= (CS_VID_SuperIO_i & Bus_A_Valid_i);
end 

reg [2:0]	MiniST;
reg [2:0]	MiniSTST;

localparam 	CPU_IDLE				= 3'b000,
				CPU_WRITE 			= 3'b001,
				CPU_WRITE_END		= 3'b010,
				CPU_READ0			= 3'b011,
				CPU_READ1			= 3'b100,
				CPU_READ2			= 3'b101,
				CPU_TERMINATE 		= 3'b110;
				
always @ ( posedge Bus_Clk_i) begin
	if ( rst_i ) begin
		MiniST <= CPU_IDLE;
		Data_FIFO_Read <= 1'b0;
		CMD_FIFO_Write <= 1'b0;
		Wait_LPC_TA_o	<= 1'b0;
	end
	else begin
	
	case ( MiniST ) 

		CPU_IDLE: begin 
			if ( {ACCESS_FIFO_Write, (CS_VID_SuperIO_i & Bus_A_Valid_i)} == 2'b01 ) begin
				MiniST <= CPU_WRITE;
				if ( Bus_RW_i ) begin
					MiniSTST <= CPU_READ0;
				end
				else begin
					MiniSTST <= CPU_TERMINATE;				
				end				
			end
			else begin
				MiniST <= CPU_IDLE;
				Wait_LPC_TA_o	<= 1'b0;				
				Data_FIFO_Read <= 1'b0;
				CMD_FIFO_Write <= 1'b0;				
			end 
		
		end
		
		// It is a write Cycle, Just terminate the Cycle
		CPU_WRITE: begin 
			MiniST <= CPU_WRITE_END;	
		end
		
		CPU_WRITE_END: begin
			CMD_FIFO_Write <= 1'b1;		
			MiniST <= MiniSTST;		
		end
		
		// Read Cycle, wait for the Data to be Ready
		CPU_READ0: begin 
			CMD_FIFO_Write <= 1'b0;		// Command sent - Let's wait for anwsers		
			if ( Data_FIFO_Empty == 1'b0 ) begin
				Data_FIFO_Read <= 1'b1;
				MiniST <= CPU_READ1;
			end
			else begin
				MiniST <= CPU_READ0;			
			end
		end
		
		CPU_READ1: begin 
			Data_FIFO_Read <= 1'b0;
			MiniST <= CPU_READ2;
		end

		//Data Valid Here
		CPU_READ2: begin 
			MiniST <= CPU_TERMINATE;
		end
		
		CPU_TERMINATE: begin
			CMD_FIFO_Write <= 1'b0;		
			Wait_LPC_TA_o	<= 1'b1;		
			MiniST <= CPU_IDLE;
		end
	
		default: begin
			MiniST <= CPU_IDLE;		
		end 
	endcase 
	end
end 

reg 				Data_FIFO_Write;
reg 				Data_FIFO_Read;
wire 				Data_FIFO_Empty;
wire [7:0]		Data_FIFO_Out;

reg 				CMD_FIFO_Read;
reg				CMD_FIFO_Write;
wire 				CMD_FIFO_Empty;
wire [23:0] 	LPC_CMD_Data_Out;
// 24bits 
/// COMMAND FIFO
LPC_CMD_FIFO	LPC_FIFO_CMD (
	.aclr ( rst_i ),
	// Write
	.data ( { Bus_D8_i, !Bus_RW_i, Bus_A_i[14:0]}),
	.wrreq ( CMD_FIFO_Write ),	
	.wrclk ( Bus_Clk_i ),
	.wrempty (  ),	
	
	// Read
	.rdclk ( LPC_Clk_i ),
	.rdreq ( CMD_FIFO_Read ),
	.q ( LPC_CMD_Data_Out ),
	.rdempty ( CMD_FIFO_Empty ),
	
	
	.wrfull (  )
	);
	
assign Bus_D_o = {Data_FIFO_Out, Data_FIFO_Out, Data_FIFO_Out, Data_FIFO_Out};

wire [7:0]		Data_FIFO_Count;
/// DATA FIFO	
LPC_DATA_FIFO	LPC_FIFO_DATA (
	.aclr ( LPC_Reset[2] ),

	// Data Write
	.data ( LPC_Data_Out_i[7:0] ),	
	.wrclk ( LPC_Clk_i ),
	.wrreq ( Data_FIFO_Write ),

	// Data Read
	.rdclk ( Bus_Clk_i ),
	.rdreq ( Data_FIFO_Read ),	
	.q ( Data_FIFO_Out ),
	
	.rdempty ( Data_FIFO_Empty ),
	.rdusedw ( Data_FIFO_Count ),
	.wrfull (  )
	);	

assign LPC_Address_o 	= {1'b0, LPC_CMD_Data_Out[14:0]} & 16'h03FF;		// ReSynced to LPC_Clk;
assign LPC_Data_In_o 	= LPC_CMD_Data_Out[23:16];								// ReSynced to LPC_Clk;
assign LPC_Write_o 		= LPC_CMD_Data_Out[15];												// ReSynced to LPC_Clk;
reg [2:0] 	LPC_Reset;

always @ ( posedge LPC_Clk_i ) begin
	LPC_Reset[0] <= rst_i;
	LPC_Reset[1] <= LPC_Reset[0];
	if ( LPC_Reset[1] == LPC_Reset[0] )
		LPC_Reset[2] <= LPC_Reset[1];		
end

localparam	IDLE 					= 3'b000,
				FIFO_READ0			= 3'b001,
				FIFO_READ1			= 3'b010,
				START_CYCLE			= 3'b011,
				ACK_CYCLE			= 3'b100,
				END_CYCLE 			= 3'b101,
				WRITE_FIFO0			= 3'b110,
				WRITE_FIFO1			= 3'b111;

reg	[7:0]	Timeout;
reg	[7:0]	Timeout_Error;
reg 	[2:0]	StateMachine;

always @ ( posedge LPC_Clk_i )
begin
	if ( LPC_Reset[2] ) begin
		StateMachine <= IDLE;
		CMD_FIFO_Read <= 1'b0;
		Data_FIFO_Write <= 1'b0;
		Timeout_Error <= 8'h00;
	end
	else begin
	
		case (StateMachine)

		IDLE: 
		begin
			if ( CMD_FIFO_Empty == 1'b0 ) begin
				StateMachine <= FIFO_READ0;	
				CMD_FIFO_Read <= 1'b1;
			end
			else begin
				StateMachine <= IDLE;
			end
		end
		
		// FIFO Read Valid Here
		// But Need 1 Clock Latency to get Data Out
		FIFO_READ0: begin
			StateMachine <= FIFO_READ1;		
			CMD_FIFO_Read <= 1'b0;
		end
		
		// Data Valid Here
		FIFO_READ1: begin
			StateMachine <= START_CYCLE;
			LPC_Strobe_o <= 1'b1;
			Timeout		<= 8'd64;	// Max 30 Clock Cycles		
		end 
		
		//Cycle Begins Here
		START_CYCLE: begin
			StateMachine <= ACK_CYCLE;
		end 

		ACK_CYCLE: 
		begin
			if (LPC_Ack_i) begin
				LPC_Strobe_o <= 1'b0;
				if ( LPC_Write_o ) 
					StateMachine <= WRITE_FIFO1;	// If Writing, we are done.
				else
					StateMachine <= END_CYCLE;	// If Writing, we are done.					

			end
			else begin
				if (Timeout) begin
					Timeout <= Timeout - 1'b1;
					StateMachine <= ACK_CYCLE;					
					end
					else begin
						Timeout_Error <= Timeout_Error + 1'b1;
						LPC_Strobe_o <= 1'b0;
						StateMachine <= WRITE_FIFO1;	// If Writing, we are done.					
					end
			end			
		end


		END_CYCLE: 
		begin
			Data_FIFO_Write <= 1'b1;
			StateMachine <= WRITE_FIFO0;	// If Writing, we are done.	
		end
		
		// Since there is valid data, we need to wait for it to go through the Resync Circuit
		WRITE_FIFO0: 
		begin
			Data_FIFO_Write <= 1'b0;
			StateMachine <= WRITE_FIFO1;	// If Writing, we are done.	
		end

		WRITE_FIFO1: 
		begin
			StateMachine <= IDLE;	// If Writing, we are done.	
		end	
			

		default: begin
			StateMachine <= IDLE;		
		end
	

	endcase
	
	
	end
end


endmodule
