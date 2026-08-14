`timescale 1 ps / 1 ps
module Serial_Rx(
input 				Serial_Clk_i,
input					Serial_Reset_i,
input					Rx_i,
output	[7:0]		Data_Out_o,
output				Data_Rdy_o
);


reg 	[3:0]		StateMachine_Rx;
reg	[7:0]		BitCount;
reg	[1:0]		Rx_EDGE;
reg	[3:0]		ClockWait;
reg	[7:0]		Rx_Byte;
reg	[7:0]		Received_Byte;
reg	[1:0]		Write_Byte_Strobe;

wire				Received_Byte_Write;

localparam		WAIT_START 		= 4'b0000,
					DELAY3CLK		= 4'b0001,
					FRONT_DELAY0	= 4'b0010,
					FRONT_DELAY1	= 4'b0011,
					READ_VALUE		= 4'b0100,
					BACK_DELAY0		= 4'b0101,
					BACK_DELAY1		= 4'b0110; 


always @ (posedge Serial_Clk_i)
begin	
	Rx_EDGE[0] <= Rx_i;
	Rx_EDGE[1] <= 	Rx_EDGE[0];
end

always @ (posedge Serial_Clk_i)
begin	
	Write_Byte_Strobe <= Write_Byte_Strobe << 1'b1;

	if (StateMachine_Rx == BACK_DELAY1) begin
		//if (Rx_EDGE[1:0] == 2'b01) begin
				Received_Byte 		<= Rx_Byte;
				Write_Byte_Strobe	<= 2'b10;
		//end
	end

end

assign Data_Rdy_o = Write_Byte_Strobe[1];
assign Data_Out_o = Received_Byte;

always @ (posedge Serial_Clk_i)
begin
	if (Serial_Reset_i) begin
		StateMachine_Rx <= WAIT_START;
		ClockWait		<= 4'b0000;
		BitCount 		<= 8'b00000000;
		Rx_Byte			<= 8'h00;
	end
	else begin
	
		case(StateMachine_Rx)
		
		WAIT_START:
		begin
			if (Rx_EDGE[1:0] == 2'b10) begin		// Waiting for the Falling Edge of Start Bit
				ClockWait 	<= 4'h2;
				Rx_Byte		<= 8'h00;
				BitCount 	<= 8'b11111111;
				StateMachine_Rx <= DELAY3CLK;	// By the Time I get Here there is already 1 Clock Passed
			end
			else begin
				StateMachine_Rx <= WAIT_START;	// By the Time I get Here there is already 1 Clock Passed			
			end
		end
		
		DELAY3CLK:
		begin
			if (ClockWait)
				ClockWait <= ClockWait - 2'b01;
			else begin
				StateMachine_Rx <= FRONT_DELAY1;
			end
		
		end
		
		FRONT_DELAY0:
		begin
			StateMachine_Rx <= FRONT_DELAY1;		
		end
		
		FRONT_DELAY1:
		begin
			StateMachine_Rx <= READ_VALUE;
		end
		
		READ_VALUE:
		begin
			if (Rx_i)
					Rx_Byte <= Rx_Byte | 8'h80;
			else
					Rx_Byte <= Rx_Byte & 8'h7F;

			StateMachine_Rx <= BACK_DELAY0;					
		end
		
		BACK_DELAY0:
		begin
			if (BitCount == 8'h80) 
				StateMachine_Rx <= BACK_DELAY1;
			else	begin
				Rx_Byte <= Rx_Byte >> 1'b1;
				BitCount <= BitCount << 1'b1;
				StateMachine_Rx <= FRONT_DELAY0;	
			end	
		end

		BACK_DELAY1:
		begin
			StateMachine_Rx <= WAIT_START;
		end

		default:
		begin
			StateMachine_Rx <= WAIT_START;
		end
	
		endcase
	end
end


endmodule

