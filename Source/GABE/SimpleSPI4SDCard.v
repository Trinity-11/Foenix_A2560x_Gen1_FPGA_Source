module SimpleSPI4SDCard(
input		wire				Reset_i,
input		wire				CPU_Clk_i,
input 		wire	[31:0]		CPU_A_i,
input 		wire	[7:0]		CPU_D_i,
input 		wire				CPU_R_Wn_i,
input		wire				CPU_A_Valid_i,
input		wire	[3:0]		CPU_BE_i,
input		wire				CPU_WE_i, 	// This == DTACK at the end of Cycle
input		wire	[1:0]		CPU_Siz_i,

input		wire				CS_SDCard_i,

output 		wire 				F_SD_CLK_o,			// SCLK
input  		wire 				F_SD_DAT0_i,		// MISO
output 		wire 				F_SD_CMD_o,			// MOSI
output		wire				F_SD_DAT3_o,		// CS

output 		wire 	[7:0]		CPU_D_o
);

localparam 			IDLE 	= 3'b000,
					TRSF0 	= 3'b001,
					TRSF1 	= 3'b010,
					TRSF2	= 3'b011,
					TRSF3	= 3'b100,
					TRSF4	= 3'b101,
					DELAY0	= 3'b110,
					DELAY1	= 3'b111;


reg		[7:0]		ControlRegister;
reg 	[2:0]		SD_SM;
reg 	[2:0]		SD_SM_SM;
reg 				Clock_o;
reg 				Data_o;
reg					Busy;
reg		[7:0] 		ReceivedData;
reg		[7:0]		SendData;
reg		[7:0]		BitCount;
reg   	[7:0]		DelaySlowSpeed;

// Keep the Input Value in Registers
always @ (posedge CPU_Clk_i)
begin
	if (Reset_i) begin
		ControlRegister <= 8'h00;		// Control Register
	end 
	else begin
		if (CS_SDCard_i && !CPU_R_Wn_i && ( CPU_Siz_i == 2'b01 ) && !CPU_A_i[0] && CPU_WE_i) 
			ControlRegister <= CPU_D_i;
	end
end

assign F_SD_DAT3_o = !ControlRegister[0];	// Inverted from what the software wants
assign CPU_D_o = CPU_A_i[0] ? ReceivedData : { Busy, ControlRegister[6:0]} ;	// Read back the control Register


/*
SPI_CTRL_SELECT_SDCARD = $01
SPI_CTRL_SLOWCLK       = $02
SPI_CTRL_AUTOTX        = $08
SPI_CTRL_BUSY          = $80
*/
assign   F_SD_CLK_o = Clock_o;
assign 	F_SD_CMD_o = SendData[7];
wire 		SlowSpeed400Khz = ControlRegister[1];

always @ (posedge CPU_Clk_i)
begin
	if ( Reset_i ) begin
		SD_SM <= IDLE;
		SD_SM_SM <= IDLE;
		Clock_o 	<= 1'b0;
		Busy		<= 1'b0;
	end
	else begin
	
		case ( SD_SM )
		
		IDLE: begin 
			if (CS_SDCard_i && !CPU_R_Wn_i && ( CPU_Siz_i == 2'b01 ) && CPU_A_i[0] && CPU_WE_i) begin
				SendData <= CPU_D_i;
				ReceivedData <= 8'h00;
				BitCount 	 <= 8'h07;
				Clock_o <= 1'b0;				
				Busy <= 1'b1;
				// Slow Speed
				if ( SlowSpeed400Khz ) begin
					DelaySlowSpeed <= 8'd20;
					SD_SM <= DELAY0;
					SD_SM_SM <= TRSF0;
				end
				else begin
					SD_SM <= TRSF0;
				end 
			end
			else begin
				SD_SM <= IDLE;
				Busy <= 1'b0;
			end 
		end 
		
		// Data in the Register is valid here 
		// Clock = 0
		TRSF0: begin	
			// Slow Speed
			if ( SlowSpeed400Khz ) begin
				DelaySlowSpeed <= 8'd20;
				SD_SM <= DELAY0;
				SD_SM_SM <= TRSF1;
			end
			else begin
				SD_SM <= TRSF1;
			end 					
		end
		
		// Clock = 0
		TRSF1: begin
			Clock_o <= 1'b1;		
			// Slow Speed
			if ( SlowSpeed400Khz ) begin
				DelaySlowSpeed <= 8'd20;
				SD_SM <= DELAY0;
				SD_SM_SM <= TRSF2;
			end
			else begin
				SD_SM <= TRSF2;
			end 			
		end 	
		
		// Clock = 1		
		TRSF2: begin
			// Slow Speed
			if ( SlowSpeed400Khz ) begin
				DelaySlowSpeed <= 8'd20;
				SD_SM <= DELAY0;
				SD_SM_SM <= TRSF3;
			end
			else begin
				SD_SM <= TRSF3;
			end 		
			ReceivedData <= {ReceivedData[6:0], F_SD_DAT0_i};	
		end		
		
		// Clock = 1
		TRSF3: begin
			Clock_o  <= 1'b0;		
			if ( BitCount ) begin 
				SendData <= SendData << 1'b1;		// Shift 
				BitCount <= BitCount - 8'h01;	
				// Slow Speed
				if ( SlowSpeed400Khz ) begin
					DelaySlowSpeed <= 8'd20;
					SD_SM <= DELAY0;
					SD_SM_SM <= TRSF0;
				end
				else begin
					SD_SM <= TRSF0;
				end 			
			end
			else begin
				SD_SM <= IDLE;
				Busy <= 1'b0;
			end	
		end		

		// Done 
		//TRSF4: begin

		//end		
		
		DELAY0: begin
			if ( DelaySlowSpeed ) begin 
				DelaySlowSpeed <= DelaySlowSpeed - 8'h01;
			end
			else begin
				SD_SM <= SD_SM_SM;
			end 
		end		
		
		DELAY1: begin
		
		end		
		
		default: begin
				SD_SM <= IDLE;			
				Busy <= 1'b0;		
		end
		
		endcase 
	
	end
end 

endmodule
