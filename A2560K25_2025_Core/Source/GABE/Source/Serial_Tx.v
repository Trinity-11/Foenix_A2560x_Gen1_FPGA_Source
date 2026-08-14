
module Serial_Tx (
input					Serial_Clk_i,
input					Serial_Reset_i,
output				Tx_o,
input		[7:0]		Data_In_i,
input					Data_Rdy_i,
output				Data_Sent_Strobe_o
);


reg 	[3:0]		SM_Tx;
reg	[3:0]		SSM_Tx;
reg	[1:0]		Data_Rdy_i_EDGE;
reg				Data_Out;
reg	[1:0]		Data_Out_Sent_SLIDE;

initial begin
	Data_Out	= 1'b1;
end


assign Tx_o = Data_Out;

always @ (posedge Serial_Clk_i)
begin
		Data_Rdy_i_EDGE[0] <= Data_Rdy_i;
		Data_Rdy_i_EDGE[1] <= Data_Rdy_i_EDGE[0];
end

always @ (posedge Serial_Clk_i)
begin
	Data_Out_Sent_SLIDE <= Data_Out_Sent_SLIDE << 1'b1;

	if (SM_Tx == STOP_BIT)
		Data_Out_Sent_SLIDE <= 2'b01;

end

assign Data_Sent_Strobe_o = Data_Out_Sent_SLIDE[1];


localparam		WAIT_RDY 		= 4'b0000,
					START_BIT		= 4'b0001,
					BIT_7				= 4'b0010,
					BIT_6				= 4'b0011,
					BIT_5				= 4'b0100,
					BIT_4				= 4'b0101,
					BIT_3				= 4'b0110,
					BIT_2				= 4'b0111,					
					BIT_1				= 4'b1000,
					BIT_0				= 4'b1001,
					STOP_BIT			= 4'b1010,
					FINISHED			= 4'b1011,
					WAIT0				= 4'b1100,
					WAIT1				= 4'b1101,
					WAIT2				= 4'b1110;

	
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
			if (Data_Rdy_i_EDGE[1:0] == 2'b01) begin
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
			SM_Tx <= WAIT1;
		end
		
		WAIT1:
		begin
			SM_Tx <= WAIT2;		
		end
		
		WAIT2:
		begin
			SM_Tx <= SSM_Tx;
		end
		
		default:
		begin
			SM_Tx <= WAIT_RDY;	
		end
		
		endcase
	end
end

endmodule
