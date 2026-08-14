module WS5500_SPI(
input		wire				Reset_i,
input		wire				CPU_Clk_i,
input 	wire	[31:0]	CPU_A_i,
input 	wire	[7:0]		CPU_D_i,
input 	wire				CPU_R_Wn_i,
input		wire				CPU_A_Valid_i,
input		wire	[3:0]		CPU_BE_i,
input		wire				CPU_WE_i, 	// This == DTACK at the end of Cycle
input		wire	[1:0]		CPU_Siz_i,


//input 	wire				CPU_Data_Valid_i,	
input		wire				CS_WS5500_i,

output 	wire 				WS5500_SCLK_o,			// SCLK
input  	wire 				WS5500_MISO_i,		// MISO
output 	wire 				WS5500_MOSI_o,			// MOSI
output	wire				WS5500_CSn_o,		// CS
input 	wire  			WS5500_LINK_i, 	// 
output 	wire 				WS5500_RSTn_o,		// Reset
output 	reg 	[7:0]		CPU_D_o
);

/*
wire [143:0] TinyTP1;
wire 			TinyTrigger1;

assign TinyTrigger1 = CS_WS5500_i;

assign TinyTP1[31:0]  	= CPU_A_i;
assign TinyTP1[39:32] 	= CPU_D_i;
assign TinyTP1[40] 		= CPU_R_Wn_i;
assign TinyTP1[41] 		= CPU_A_Valid_i;
assign TinyTP1[42] 		= CPU_R_Wn_i;
assign TinyTP1[44:43] 	= CPU_Siz_i;
assign TinyTP1[45]		= CS_WS5500_i;
assign TinyTP1[46]		= CPU_WE_i;
assign TinyTP1[47]		= 1'b0;
assign TinyTP1[51:48]   = CPU_BE_i;
assign TinyTP1[52] 		= WS5500_SCLK_o;
assign TinyTP1[53]		= WS5500_MISO_i; // MISO
assign TinyTP1[54]		= WS5500_MOSI_o;	// MOSI
assign TinyTP1[55]		= F_SD_DAT3_o;	// CS
assign TinyTP1[63:56]	= CPU_D_o;
assign TinyTP1[67:64]	= {1'b0, SD_SM};
assign TinyTP1[71:68]	= {1'b0, SD_SM_SM};
assign TinyTP1[79:72]   = ControlRegister;
assign TinyTP1[80]		= Busy;
assign TinyTP1[81]		= 1'b0;
assign TinyTP1[89:82]   = DelaySlowSpeed;
assign TinyTP1[97:90] 	= ReceivedData;

TinyChipScope u2 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (CPU_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/
//		if (CS_Interrupt_Ctrl_i && !CPU_RW_i & ( CPU_Siz_i[1:0] == 2'b10 ) && CPU_WE_i) begin

wire 		SlowSpeed400Khz;
reg	[7:0]	ControlRegister;


// Keep the Input Value in Registers
always @ (posedge CPU_Clk_i)
begin
	if (Reset_i) begin
		ControlRegister <= 8'h00;		// Control Register
	end 
	else begin
		if (CS_WS5500_i && !CPU_R_Wn_i && ( CPU_Siz_i == 2'b01 ) && !CPU_A_i[0] && CPU_WE_i) 
			ControlRegister <= CPU_D_i;
	end
end


assign CPU_D_o = CPU_A_i[0] ? ReceivedData : { Busy, WS5500_LINK_i, ControlRegister[5:0]} ;	// Read back the control Register


/*
SPI_CTRL_SELECT_SDCARD = $01
SPI_CTRL_SLOWCLK       = $02
SPI_CTRL_AUTOTX        = $08
SPI_CTRL_BUSY          = $80
*/


reg [2:0]	SD_SM;
reg [2:0]	SD_SM_SM;


localparam 		IDLE 		= 3'b000,
					TRSF0 	= 3'b001,
					TRSF1 	= 3'b010,
					TRSF2		= 3'b011,
					TRSF3		= 3'b100,
					TRSF4		= 3'b101,
					DELAY0	= 3'b110,
					DELAY1	= 3'b111;
				
reg 			Clock_o;
reg 			Data_o;
reg			Busy;
reg	[7:0] ReceivedData;
reg	[7:0]	SendData;
reg	[7:0]	BitCount;
reg   [7:0]	DelaySlowSpeed;


assign   WS5500_SCLK_o 		= Clock_o;
assign 	WS5500_MOSI_o 		= SendData[7];
assign 	WS5500_CSn_o 		= !ControlRegister[0];	// [0] = CS (1'b0 = CSn = 1, 1'b1 = CSn = 0)
assign 	SlowSpeed400Khz 	=  ControlRegister[1];  // [1] = Speed (1'b0 = Fast, 1'b1 = Slow )
assign   WS5500_RSTn_o 		= !ControlRegister[2];  // [2] = Module Reset (1'b0 = RSTn = 1 (Not Reset), 1'b1 = RSTn = 1'b0 (Reset Active))

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
			if (CS_WS5500_i && !CPU_R_Wn_i && ( CPU_Siz_i == 2'b01 ) && CPU_A_i[0] && CPU_WE_i) begin
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
			ReceivedData <= {ReceivedData[6:0], WS5500_MISO_i};	
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

/*

always @ (posedge CPU_2xClk_i)
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
			if ( ReSync_Trigger[2] ) begin
				SendData <= CPU_D_i;
				ReceivedData <= 8'h00;
				BitCount 	 <= 8'h07;
				Clock_o <= 1'b0;				
				Busy <= 1'b1;
				// Slow Speed
				if ( SlowSpeed400Khz ) begin
					DelaySlowSpeed <= 8'd63;
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
				DelaySlowSpeed <= 8'd63;
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
				DelaySlowSpeed <= 8'd63;
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
				DelaySlowSpeed <= 8'd63;
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
					DelaySlowSpeed <= 8'd63;
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
*/
endmodule


