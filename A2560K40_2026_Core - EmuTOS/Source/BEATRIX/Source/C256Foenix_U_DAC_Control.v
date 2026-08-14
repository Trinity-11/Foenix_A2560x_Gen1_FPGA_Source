`timescale 1 ps / 1 ps
module C256FOENIX_U_DAC_Control(
input		wire				CPU_Clk_i,
input		wire				RST_i,

output	reg			 	AUD_CCLK_o,
output	wire				AUD_CDTI_o,

output	reg				AUD0_CSn_o,
output	reg				AUD1_CSn_o,
output	reg				AUD2_CSn_o,
output	reg				AUD3_CSn_o
);




localparam		Dummy_CMD			= 8'hDE,
					Dummy_REG_ADDY 	= 16'hADDA,
					Dummy_CTRL_DATA 	= 8'h7A;	// Send 4 times as dummy commands

reg	[7:0]		REG_CMD;
reg	[15:0]	REG_ADDY;
reg	[7:0]		REG_CTRL_DATA;
reg	[3:0]		SEND_CMD_ST;
reg	[3:0]		SEND_CMD_ST_ST;

reg	[7:0]		Delay;
reg	[3:0]		Trigger_Send_Cmd;

localparam			IDLE_CMD		= 4'b0000,
						SEND_DMMY0	= 4'b0001,
						SEND_DMMY1	= 4'b0010,
						SEND_DMMY2  = 4'b0011,
						SEND_DMMY3	= 4'b0100,
						SEND_MODE	= 4'b0101,	// Send Byte 07 to Register 02
						
						WAIT			= 4'b1100,
						
						SEND_COMMAND= 4'b1101,
						SEND_CMD1	= 4'b1110,
						DONE_CMD		= 4'b1111;

assign Start_Transaction = Trigger_Send_Cmd[3];

always @ (negedge CPU_Clk_i) begin

	if (RST_i) begin
		SEND_CMD_ST 		<= IDLE_CMD;
		SEND_CMD_ST_ST		<= IDLE_CMD;
		Delay					<= 16'h0000;
		REG_CMD				<= 8'h00;
		REG_ADDY				<= 16'h0000;
		REG_CTRL_DATA		<= 8'h00;
		Delay 				<= 16'd16384;		
	end
	else begin
		Trigger_Send_Cmd <= Trigger_Send_Cmd << 1'b1;
	
		case ( SEND_CMD_ST )
		
		// Wait 1.2ms before starting the transactions
		IDLE_CMD: begin	
			if (Delay) begin
				Delay <= Delay - 8'h01;
				SEND_CMD_ST <= IDLE_CMD;			
			end
			else begin
				SEND_CMD_ST <= SEND_DMMY0;			
			end

		end
		
		// Dummy was sent once
		SEND_DMMY0: begin 
			SEND_CMD_ST 		<= SEND_COMMAND;
			SEND_CMD_ST_ST		<= SEND_DMMY1;
			// Load with Dummy
			REG_CMD				<= Dummy_CMD;
			REG_ADDY				<= Dummy_REG_ADDY;
			REG_CTRL_DATA		<= Dummy_CTRL_DATA;
		end
		
		// Dummy was sent twice
		SEND_DMMY1: begin 
			SEND_CMD_ST 		<= SEND_COMMAND;
			SEND_CMD_ST_ST		<= SEND_DMMY2;
		end

		// Dummy was sent trice
		SEND_DMMY2: begin 
			SEND_CMD_ST 		<= SEND_COMMAND;
			SEND_CMD_ST_ST		<= SEND_DMMY3;	
		end
		
		// Dummy was sent Forth
		SEND_DMMY3: begin 
			SEND_CMD_ST 		<= SEND_COMMAND;
			SEND_CMD_ST_ST		<= SEND_MODE;
		end
		
		// Send the real Command here
		SEND_MODE: 	begin	
			REG_CMD				<= 8'hC0;		// RW/1/0/0/0/0/0/0
			REG_ADDY				<= 16'h0002;	//Register to write to
			REG_CTRL_DATA		<= 8'h07;		
			SEND_CMD_ST 		<= SEND_COMMAND;
			SEND_CMD_ST_ST		<= DONE_CMD;			// Only one write to do at this point
		end
		
		
		WAIT: begin
		
			if (Delay) begin
				Delay <= Delay - 8'h01;
				SEND_CMD_ST <= WAIT;			
			end
			else begin
				SEND_CMD_ST <= SEND_CMD_ST_ST;			
			end

		
		end
		
		SEND_COMMAND: 	begin
			Trigger_Send_Cmd  <= 4'b1111;		// Trigger		
			SEND_CMD_ST <= SEND_CMD1;				
		end
		
		SEND_CMD1:  begin 
			if (DAC_ST == DONE) begin
				Delay <= 16'd32;
				SEND_CMD_ST <= WAIT;						
			end
			else begin
				SEND_CMD_ST <= SEND_CMD1;				
			end
		end

		// Stay Here
		DONE_CMD: begin 
				SEND_CMD_ST <= DONE_CMD;	
		end
		
		
		endcase

   end
end


reg	[3:0]		DAC_ST;


localparam			IDLE 				= 4'b0000,
						ST1			   = 4'b0001,
						ST2			   = 4'b0010,
						ST3			   = 4'b0011,
						ST4			   = 4'b0100,
						ST5			   = 4'b0101,
						ST6			   = 4'b0110,
						ST7			   = 4'b0111,
						ST8			   = 4'b1000,
						ST9			   = 4'b1001,
						STA			   = 4'b1010,
						STB			   = 4'b1011,
						STC			   = 4'b1100,
						STD			   = 4'b1101,
						STE			   = 4'b1110,
						DONE			   = 4'b1111;

						
reg	[31:0]	Data_2_Send;
reg	[7:0]		BitCount;
wire				Start_Transaction;
					
assign AUD_CDTI_o = Data_2_Send[31];
// this is the state machine to go write a Register in the Different DACs (prolly receive all the same information 4 now)
always @ (negedge CPU_Clk_i) begin

	if (RST_i) begin
		DAC_ST 		<= IDLE;
		AUD_CCLK_o	<= 1'b1;
		AUD0_CSn_o  <= 1'b1;
		AUD1_CSn_o  <= 1'b1;
		AUD2_CSn_o  <= 1'b1;
		AUD3_CSn_o  <= 1'b1;		
	end
	else begin
	
		case (DAC_ST) 
		
		IDLE: begin
			if ( Start_Transaction ) begin
				Data_2_Send <= { REG_CMD, REG_ADDY, REG_CTRL_DATA };	// THis is the message to be sent
				BitCount    <= 8'd32;	// 32 bit to transfer
				AUD_CCLK_o	<= 1'b1;		// Make sure to start with Clock Hi
				DAC_ST <= ST1;
			end
			else 
				DAC_ST <= IDLE;
		end
		
		// Bringing the ChipSelect Down
		// the 4 DAC will receive the same information
		ST1: begin
			AUD0_CSn_o  <= 1'b0;
			AUD1_CSn_o  <= 1'b0;
			AUD2_CSn_o  <= 1'b0;
			AUD3_CSn_o  <= 1'b0;			
			DAC_ST <= ST2;
		end
		
		// Clock Hi
		ST2: begin
			DAC_ST <= ST3;
		end

		// Clock Hi
		ST3: begin
			AUD_CCLK_o	<= 1'b0;		// Make sure to start with Clock Hi		
			DAC_ST <= ST4;
		end
		
		// Clock LO
		ST4: begin
			DAC_ST <= ST5;
			
		end

		// Clock LO		
		ST5: begin
			DAC_ST <= ST6;
		end
		
		// Clock LO
		// Data Valid Here
		ST6: begin
			AUD_CCLK_o	<= 1'b1;		// Make sure to start with Clock Hi		
			DAC_ST <= ST7;
		end

		// Data has been registered here
		// Clock HI
		ST7: begin
			DAC_ST <= ST8;
		end
		
		// Clock HI
		ST8: begin
			Data_2_Send <= Data_2_Send << 1'b1;
			
			if ( BitCount ) begin
				BitCount <= BitCount - 8'b0000_00001;
				DAC_ST <= ST3;				
			end
			else begin
				DAC_ST <= ST9;				
			end
		end
		
		ST9: begin
			AUD0_CSn_o  <= 1'b1;
			AUD1_CSn_o  <= 1'b1;
			AUD2_CSn_o  <= 1'b1;
			AUD3_CSn_o  <= 1'b1;				
			DAC_ST <= DONE;
		end
		
		// Reaching that point that registers were written
		DONE: begin
		
			DAC_ST <= IDLE;
		end

		default: begin
			DAC_ST <= IDLE;		
		end
		
		endcase

	end
end









endmodule

