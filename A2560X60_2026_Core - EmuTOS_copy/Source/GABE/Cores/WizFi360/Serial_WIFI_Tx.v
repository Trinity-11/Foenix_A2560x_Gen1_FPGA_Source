
module Serial_WIFI_Tx (
input				Serial_Clk_i,
input				Serial_Reset_i,
output				Tx_o,
input		[7:0]	Data_In_i,
input				Data_In_Transmit_i,
output				Data_Sent_Strobe_o,
input               Slow_Mode_i
);
// grey
localparam		    WAIT_RDY 		    = 4'b0000,
					START_BIT		    = 4'b0001,
					BIT_7				= 4'b0011,
					BIT_6				= 4'b0010,
					BIT_5				= 4'b0110,
					BIT_4				= 4'b0111,
					BIT_3				= 4'b0101,
					BIT_2				= 4'b0100,
					BIT_1				= 4'b1100,
					BIT_0				= 4'b1101,
					STOP_BIT			= 4'b1111,
					FINISHED			= 4'b1110,
					WAIT0				= 4'b1010,
					WAIT1				= 4'b1011,
					WAIT2				= 4'b1001,
                    WAIT_SLOW           = 4'b1000;

// Wiznet possible Baudrate
// 2000000, 1500000, 1000000, 921600, 460800, 230400, 115200 (factory default), 57600, 38400, 19200, 14400, 9600, 4800, 2400, 1800, 1200, 600
// 24,000,000 / 2,000,000 = 12
// 24,000,000 / 1,500,000 = 16
// 24,000,000 / 1,000,000 = 24
// 24,000,000 /   921,600 = 26ish
// 24,000,000 /   460,800 = 52ish
// 24,000,000 /   460,800 = 52ish
// 24,000,000 /   230,400 = 104.16ish
// 24,000,000 /   115,200 = 208.33ish

reg 		[3:0]		SM_Tx;
reg		[3:0]		SSM_Tx;
reg					Data_Out;
reg		[3:0]		Data_Out_Sent_SLIDE;
reg 	[15:0]       Delay_115K;

initial begin
	Data_Out	= 1'b1;
end


assign Tx_o = Data_Out;


always @ (posedge Serial_Clk_i)
begin
	Data_Out_Sent_SLIDE <= Data_Out_Sent_SLIDE << 1'b1;

	if (SM_Tx == FINISHED)
		Data_Out_Sent_SLIDE <= 4'b1111;

end

assign Data_Sent_Strobe_o = Data_Out_Sent_SLIDE[3];

	
always @ (posedge Serial_Clk_i)
begin
	if (Serial_Reset_i) begin
		SM_Tx 	<= WAIT_RDY;
		Data_Out <= 1'b1;
	end
	else
	begin
	
		case (SM_Tx)
		
		WAIT_RDY: 
		begin
			if ( Data_In_Transmit_i ) begin
					SM_Tx 	<= WAIT0;
					SSM_Tx	<= START_BIT;
					Data_Out <= 1'b0;
			end
		end
		
		START_BIT:
		begin
			Data_Out <= Data_In_i[0];
			SM_Tx 	<= WAIT0;
			SSM_Tx	<= BIT_7;
		end
		
		BIT_7:
		begin
			Data_Out <= Data_In_i[1];
			SM_Tx 	<= WAIT0;
			SSM_Tx	<= BIT_6;
		end

		BIT_6:
		begin
			Data_Out <= Data_In_i[2];
			SM_Tx 	<= WAIT0;
			SSM_Tx	<= BIT_5;
		end

		BIT_5:
		begin
			Data_Out <= Data_In_i[3];
			SM_Tx 	<= WAIT0;
			SSM_Tx	<= BIT_4;
		end

		BIT_4:
		begin
			Data_Out <= Data_In_i[4];
			SM_Tx 	<= WAIT0;
			SSM_Tx	<= BIT_3;
		end

		BIT_3:
		begin
			Data_Out <= Data_In_i[5];
			SM_Tx 	<= WAIT0;
			SSM_Tx	<= BIT_2;
		end

		BIT_2:
		begin
			Data_Out <= Data_In_i[6];
			SM_Tx 	<= WAIT0;
			SSM_Tx	<= BIT_1;
		end

		BIT_1:
		begin
			Data_Out <= Data_In_i[7];
			SM_Tx 	<= WAIT0;
			SSM_Tx	<= BIT_0;
		end

		BIT_0:
		begin
			Data_Out <= 1'b1;
			SM_Tx 	<= WAIT0;
			SSM_Tx	<= STOP_BIT;
		end
		
		STOP_BIT:
		begin
			SM_Tx 	<= WAIT0;
			SSM_Tx	<= FINISHED;		
		end
		
		FINISHED:
		begin
			SM_Tx 	<= WAIT_RDY;	
		end
		
		WAIT0:
		begin
            if ( Slow_Mode_i ) begin 
                Delay_115K <= 16'd204;	//115,200
            end 
            else begin 
                Delay_115K <= 16'd26;  //921,600
            end 
            SM_Tx <= WAIT_SLOW;	
		end
		
        WAIT_SLOW: begin 
			if ( Delay_115K ) begin
				Delay_115K <= Delay_115K - 8'd1;
            end 
			else begin
                SM_Tx <= SSM_Tx;
			end        
        end 
        
		default:
		begin
			SM_Tx <= WAIT_RDY;	
		end
		
		endcase
	end
end

endmodule
