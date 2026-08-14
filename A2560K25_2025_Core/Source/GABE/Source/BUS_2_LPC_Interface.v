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


wire	[23:0] 		CMD_FIFO_Output;
wire					CMD_FIFO_Empty;
wire					DATA_FIFO_Empty;
wire 	[7:0] 		Data_Out;
wire 					Data_LPC_Out_RDEmpty;

reg 					Data_LPC_Out_RDReq;
reg					WR_FIFO_Data;
reg 	[3:0]			StateMachine;
reg					Read_FIFO_LPC;
reg	[7:0]			Timeout;
reg	[7:0]			Timeout_Error;
reg 	[2:0] 		rst_i_Resync;
reg 	[1:0]			TinySM;
reg 					LPC_DATA_RDY;

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



// There is a Clock Realm Crossing here, but the when the Value is read by CPU, the Value has been stable for a while.

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
	.wrfull(  ),
	// Read Side @ 33Mhz
	.rdclk( LPC_Clk_i ),
	.rdreq( Read_FIFO_LPC ),
	.q( CMD_FIFO_Output ),
	.rdempty( CMD_FIFO_Empty )
);


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

wire Write_2_FIFO_Read_Condition;

assign Bus_D_o = {Data_Out, Data_Out, Data_Out, Data_Out};
assign Write_2_FIFO_Read_Condition = (LPC_Ack_i & CMD_FIFO_Output[15]);

reg Read_LPC_Valid;
always @ (posedge LPC_Clk_i) begin
	Read_LPC_Valid <= Write_2_FIFO_Read_Condition;
end


assign LPC_Address_o = {1'b0, CMD_FIFO_Output[14:0]} & 16'h03FF;
assign LPC_Data_In_o = CMD_FIFO_Output[23:16];
assign LPC_Write_o   = !CMD_FIFO_Output[15];


localparam	IDLE 					= 4'b0000,
				BEGIN_CYCLE			= 4'b0001,
				END_CYCLE 			= 4'b0010,
				END_CYCLE1 			= 4'b0011,
				END_CYCLE2			= 4'b0100;
				
always @ (posedge LPC_Clk_i)
begin
	if (rst_i) begin
		// Normal Stuff 
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