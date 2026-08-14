`timescale 1 ps / 1 ps
module Serial_WIFI_Rx(
input 				Serial_Clk_i,
input					Serial_Reset_i,
input					Rx_i,
output	[7:0]		Data_Out_o,
output				Data_Rdy_o,
input               Slow_Mode_i
);

// Wiznet possible Baudrate
// 2000000, 1500000, 1000000, 921600, 460800, 230400, 115200 (factory default), 57600, 38400, 19200, 14400, 9600, 4800, 2400, 1800, 1200, 600


reg 	[3:0]		StateMachine_Rx;
reg	[7:0]		BitCount;
reg	[1:0]		Rx_EDGE;
reg	[8:0]		ClockWait;
reg	[7:0]		Rx_Byte;
reg	[7:0]		Received_Byte;
reg	[1:0]		Write_Byte_Strobe;

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
				Write_Byte_Strobe	<= 2'b01;
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
		
        // When detected, there is already 1 Clock pass 
		WAIT_START:
		begin
			if (Rx_EDGE[1:0] == 2'b10) begin		// Waiting for the Falling Edge of Start Bit
                if ( Slow_Mode_i ) begin 
                    ClockWait 	<= 9'd310;          // 115200 208 to pass the time for Start Bit then 100 clock more puts us in the middle the first data bit
                end 
                else begin 
                    ClockWait 	<= (9'd26 + 9'd13);			// 921600 26 Clocks + 13 For middle bit
                end 
                
				Rx_Byte		<= 8'h00;
				BitCount 	<= 8'b11111111;
				StateMachine_Rx <= DELAY3CLK;	// By the Time I get Here there is already 1 Clock Passed
			end
			else begin
				StateMachine_Rx <= WAIT_START;	// By the Time I get Here there is already 1 Clock Passed			
			end
		end
		
        // 3 Clocks here 
		DELAY3CLK:
		begin
			if (ClockWait) begin
				ClockWait <= ClockWait - 9'd1;
            end 
			else begin
				StateMachine_Rx <= FRONT_DELAY1;
			end
		end
		
        // 1 Clock here
		FRONT_DELAY0:
		begin
			StateMachine_Rx <= FRONT_DELAY1;		
		end
		// 1 Clock Here
		FRONT_DELAY1:
		begin
			StateMachine_Rx <= READ_VALUE;
		end
		
        // Sample Here 1 Clock Here
		READ_VALUE:
		begin
			if (Rx_i)
					Rx_Byte <= Rx_Byte | 8'h80;
			else
					Rx_Byte <= Rx_Byte & 8'h7F;

			StateMachine_Rx <= BACK_DELAY0;					
		end
		
        // 1 Clock Here
		BACK_DELAY0:
		begin
			if (BitCount == 8'h80) 
				StateMachine_Rx <= BACK_DELAY1;
			else	begin
				Rx_Byte <= Rx_Byte >> 1'b1;
				BitCount <= BitCount << 1'b1;
                if ( Slow_Mode_i ) begin
                    ClockWait 	<= 9'd204;          // Going from mid bit to mid-bit           
                    StateMachine_Rx <= DELAY3CLK;  
                end
                else begin 
                    ClockWait 	<= 9'd22;          // Going from mid bit to mid-bit ( 26 - 4 ) For the State Machine Compensation
                    StateMachine_Rx <= DELAY3CLK;                
                end 
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

