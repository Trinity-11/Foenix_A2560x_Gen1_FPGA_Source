module Mera_Top(
// Reset
input		wire					Reset_i,
input		wire					CPU_Clk_i,			// 24Mhz
input		wire					SDRAM_Clk_i, 		// 160Mhz
// Buses
input		wire		[31:0]		iBUS_A_i,
input		wire					iBUS_A_Valid_i,		// = !TS - So when it comes to 1 the Address is Valid 
input		wire		[7:0]		iBUS_D8_i,
input		wire		[15:0]		iBUS_D16_i,
input		wire		[31:0]		iBUS_D32_i,
input		wire		[31:0]   	iBUS_D_Out_virgin_i, 

input		wire		[1:0]		iBUS_D_Siz_i,
output		wire					iBUS_D_Valid_o,
input		wire					iBUS_RWn_i,
input		wire		[3:0]		iBUS_BE_i,
input		wire					iBUS_WE_i,
output		wire		[31:0]		iBUS_D_MERA_o,
input		wire					iBUS_CS_MERA_i,
output		wire					Wait_MERA_TA_o,

// System RAM
inout		wire		[31:0]		SYSRAM_DQ_io,
output		wire		[3:0]		SYSRAM_DQM_o,
output		wire		[12:0]		SYSRAM_A_o,
output		wire					SYSRAM_BA0_o,
output		wire					SYSRAM_BA1_o,
output		wire					SYSRAM_CASn_o,
output		wire					SYSRAM_RASn_o,
output		wire					SYSRAM_WEn_o,
output		wire					SYSRAM_CS0n_o,
output		wire					SYSRAM_CKE_o,
output		wire					SYSRAM_CLK_o
); 



localparam IDLE 	= 3'b000,
			  READ0	= 3'b001,
			  READ1	= 3'b010,
			  READ2  = 3'b011,
			  READ3  = 3'b100;
				

reg [2:0] MERA_CPU_ST; /* synthesis preserve noprune */
reg       Read_CPU_FIFO;
reg		 EndCycleReg;
reg 		Read_CPU_FIFO_Strobe;
wire		Data2Read_Empty_Status;

always @ (posedge CPU_Clk_i) begin

	if (Reset_i) begin
		MERA_CPU_ST <= IDLE;
		Read_CPU_FIFO_Strobe <= 1'b0;
		EndCycleReg <= 1'b0;
	end
	else begin
	
		case (MERA_CPU_ST)
		
		IDLE: begin
			if ( Data2Read_Empty_Status == 1'b0 )	begin // if not empty anymore, let's go get the command
				Read_CPU_FIFO_Strobe <= 1'b1;
				MERA_CPU_ST <= READ0;	
			end 
			else begin
				Read_CPU_FIFO_Strobe <= 1'b0;
				MERA_CPU_ST <= IDLE;
			end
		end
		
		// The Read Strobe for the Command is 1 here
		READ0: begin 
			Read_CPU_FIFO_Strobe <= 1'b0;
			MERA_CPU_ST <= READ1;		
		end
		
		// The Read Strobe for the Command is 0 here		
		READ1: begin 
			MERA_CPU_ST <= READ2;
			EndCycleReg <= 1'b1;
		end
		
		// Data Valid Here
		READ2: begin
			EndCycleReg <= 1'b0;		
			MERA_CPU_ST <= READ3;
		end
		
		READ3: begin
			MERA_CPU_ST <= IDLE;
		end		
		
		endcase
	end
end


assign Wait_MERA_TA_o = iBUS_RWn_i ? EndCycleReg : iBUS_A_Valid_i;


reg [1:0] iBUS_CS_MERA_EDGE;
always @ (posedge CPU_Clk_i) begin
	iBUS_CS_MERA_EDGE[0] <= iBUS_CS_MERA_i;
	iBUS_CS_MERA_EDGE[1] <= iBUS_CS_MERA_EDGE[0];
end

reg WriteCMD;

always @ (*) begin
	
	case ( { iBUS_CS_MERA_i, iBUS_RWn_i } ) 
		2'b00: begin WriteCMD = 1'b0; end
		2'b01: begin WriteCMD = 1'b0; end
		2'b10: begin WriteCMD = {iBUS_CS_MERA_EDGE[1:0], iBUS_CS_MERA_i} == 3'b011; end
		2'b11: begin WriteCMD = {iBUS_CS_MERA_EDGE[1:0], iBUS_CS_MERA_i} == 3'b001; end
	endcase

end

wire [31:0] ADD;

assign ADD[31:0] = iBUS_A_i[31:0] - 32'h0200_0000; 

// 31:0 -> 0000_001X_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX - 0200 to 03FF - 32Meg
// 31:0 -> 0000_010X_XXXX_XXXX_XXXX_XXXX_XXXX_XXXX - 0400 to 03FF - 32Meg

// Translation from $02 to $00
// Translation from $04 to $02
/*
always @ (*) begin
	case (iBUS_A_i[26:25])
		2'b00: begin ADDY = 24'h00_0000; end
		2'b01: begin ADDY = {1'b0, iBUS_A_i[24:2]}; end
		2'b10: begin ADDY = {1'b1, iBUS_A_i[24:2]}; end
		2'b11: begin ADDY = 24'h00_0000; end
	endcase
end
*/

// CMD FIFO - 64Bits Wide
SDRAM_CMD_FIFO	SDRAM_CMD_FIFO (
	.aclr( Reset_i ),
	.data ( { iBUS_D_Out_virgin_i[7:0], iBUS_D_Out_virgin_i[15:8], iBUS_D_Out_virgin_i[23:16], iBUS_D_Out_virgin_i[31:24], iBUS_D_Siz_i, 1'b0, iBUS_RWn_i, iBUS_BE_i[3:0], ADD[25:2]} ),		// 16M x 4 Bytes
	.wrclk ( CPU_Clk_i ),
	.wrreq ( WriteCMD  ), // Any Transaction needs to be Stored here
	.wrfull (  ),
	.wrusedw (  ),

	.rdclk ( SDRAM_Clk_i ),
	.rdreq ( CMD_Read_Strobe ),
	.rdempty ( CMD_Empty_Status ),
	.rdusedw (  ),
	.q ( CMD )
	
	);
reg Data_2_Write_WR_Strobe;
	
// Outgoing Data FIFO (MERA -> CPU)
SDRAM_DATA_FIFO SDRAM_DATA_FIFO (
// 24Mhz
	.aclr( Reset_i ),
	.rdclk ( CPU_Clk_i ),
	.rdreq ( Read_CPU_FIFO_Strobe ),
	.rdempty ( Data2Read_Empty_Status ),
	.rdusedw (  ),
	.q ( iBUS_D_MERA_o ),

// 160Mhz	
	.data ( {Data2Read[7:0], Data2Read[15:8], Data2Read[23:16], Data2Read[31:24]} ),
	.wrclk ( SDRAM_Clk_i ),
	.wrreq ( Data_2_Write_WR_Strobe ),
	.wrfull (  ),
	.wrusedw (  )
	);


reg [2:0]	MERA_CMD_ST; /* synthesis preserve noprune */

localparam 		CMD_IDLE				= 3'b000,
					READ_cMD_ST0		= 3'b001,
					READ_CMD_ST1		= 3'b011,
					READ_CMD_ST2		= 3'b010,
					CMD_WRITE_ST0		= 3'b110,
					CMD_WRITE_ST1		= 3'b111,
					CMD_READ_ST0		= 3'b101,
					CMD_READ_ST1		= 3'b100;
					
					

					
wire [31:0] Data2Read;
wire [63:0] CMD;
wire [3:0] 	CMD_BE;
wire 			CMD_RW;
wire [23:0] CMD_ADDY;
wire [31:0] CMD_DATA;

assign CMD_ADDY = CMD[23:0];
assign CMD_BE	 = CMD[27:24];
assign CMD_RW   = CMD[28];
assign CMD_DATA = CMD[63:32];

					
reg				CMD_Read_Strobe;
wire				CMD_Empty_Status;

// CMD State Machine
// around 160Mhz Right now = Jan 27th_2021
always @ (posedge SDRAM_Clk_i) begin

	if (Reset_i) begin
		MERA_CMD_ST <= CMD_IDLE;
		CMD_Read_Strobe <= 1'b0;
	end
	else begin
	
		case (MERA_CMD_ST)
		
		CMD_IDLE: begin
			if ( CMD_Empty_Status == 1'b0 )	begin // if not empty anymore, let's go get the command
				CMD_Read_Strobe <= 1'b1;
				MERA_CMD_ST <= READ_cMD_ST0;	
			end 
			else begin
				CMD_Read_Strobe <= 1'b0;
			end
		end
		
		// The Read Strobe for the Command is 1 here
		READ_cMD_ST0: begin 
			CMD_Read_Strobe <= 1'b0;
			MERA_CMD_ST <= READ_CMD_ST1;		
		end
		
		// The Read Strobe for the Command is 0 here		
		READ_CMD_ST1: begin 
			MERA_CMD_ST <= READ_CMD_ST2;
		end
		
		// Data Valid Here
		READ_CMD_ST2: begin 
			if (CMD_RW == 1'b1)	begin	// Read Write
				MERA_CMD_ST <= CMD_READ_ST0;				
			end
			else begin
				MERA_CMD_ST <= CMD_WRITE_ST0;				
			end
		end
		
		// 
		CMD_WRITE_ST0: begin 
			if ( MERA_WR_ST == WR_DONE )
				MERA_CMD_ST <= CMD_IDLE;
			else
				MERA_CMD_ST <= CMD_WRITE_ST0;
		end
		
//		CMD_WRITE_ST1: begin 
//				MERA_CMD_ST <= CMD_IDLE;	
//		end
		
		CMD_READ_ST0: begin 
			if ( MERA_RD_ST == RD_DONE )
				MERA_CMD_ST <= CMD_IDLE;	
			else
				MERA_CMD_ST <= CMD_READ_ST0;		
		end
		
//		CMD_READ_ST1: begin 
//				MERA_CMD_ST <= CMD_IDLE;
//		end
		
		default: begin
			MERA_CMD_ST <= CMD_IDLE;
		end

		endcase
	end
end

reg [2:0]	MERA_WR_ST; /* synthesis preserve noprune */

wire 			SDRAM_CTRL_RDY;

localparam 		WR_IDLE				= 3'b000,
					WR_STROBE1			= 3'b001,
					WR_STROBE0			= 3'b011,
					WR_WAIT				= 3'b010,
					WR_DONE				= 3'b110,
					WR_WAIT_CTRL		= 3'b111;

					
// Write State Machine
// around 160Mhz Right now = Jan 27th_2021
always @ (posedge SDRAM_Clk_i) begin

	if (Reset_i) begin
		MERA_WR_ST <= WR_IDLE;

	end
	else begin
	
		case (MERA_WR_ST)
		
		WR_IDLE: begin
			if (( MERA_CMD_ST == READ_CMD_ST2) && ( CMD_RW == 1'b0 ) ) begin // Wait for the Controller to be ready. )begin
				if ( SDRAM_CTRL_RDY ) begin // Wait for the Controller to be ready.
						Write_Strobe <= 1'b1;
						MERA_WR_ST <= WR_STROBE1;
				end
				else begin
						MERA_WR_ST <= WR_WAIT_CTRL;				
				end
			end
			else begin
				MERA_WR_ST <= WR_IDLE;
			end
		end	
		
		WR_STROBE1: begin
			Write_Strobe <= 1'b0;
			MERA_WR_ST <= WR_STROBE0;
		end
		
		//
		WR_STROBE0: begin
			if ( SDRAM_CTRL_RDY ) begin // Wait for the Controller to be ready.
					MERA_WR_ST <= WR_DONE;
			end
			else begin
					MERA_WR_ST <= WR_STROBE0;				
			end		
		end
		
		WR_WAIT: begin
			MERA_WR_ST <= WR_IDLE;	
		end
		
		WR_DONE: begin
				MERA_WR_ST <= WR_IDLE;		
		end
		
		WR_WAIT_CTRL: begin
			if ( SDRAM_CTRL_RDY ) begin // Wait for the Controller to be ready.
						MERA_WR_ST <= WR_STROBE1;
			end
			else begin
					MERA_WR_ST <= WR_WAIT_CTRL;				
			end		
		end

		default: begin
			MERA_WR_ST <= WR_IDLE;
		end
					
		endcase	
	end
end


reg [2:0]	MERA_RD_ST; /* synthesis preserve noprune */

localparam 		RD_IDLE				= 3'b000,
					RD_STROBE1			= 3'b001,
					RD_STROBE0			= 3'b011,
					RD_WRITE_FIFO0		= 3'b010,
					RD_WRITE_FIFO1		= 3'b110,
					RD_DONE				= 3'b111,
					RD_WAIT_CTRL		= 3'b101;
					
////////////////////////////////////////////////////					
// READ State Machine
// around 160Mhz Right now = Jan 27th_2021
always @ (posedge SDRAM_Clk_i) begin

	if (Reset_i) begin
		MERA_RD_ST <= RD_IDLE;
		Data_2_Write_WR_Strobe <= 1'b0;
		Read_Strobe <= 1'b0;
	end
	else begin
	
		case (MERA_RD_ST)
		
		RD_IDLE: begin
			if (( MERA_CMD_ST == READ_CMD_ST2) && ( CMD_RW == 1'b1 ) ) begin // Wait for the Controller to be ready. )begin
				if ( SDRAM_CTRL_RDY ) begin // Wait for the Controller to be ready.
						Read_Strobe <= 1'b1;
						MERA_RD_ST <= RD_STROBE1;
				end
				else begin
						MERA_RD_ST <= RD_WAIT_CTRL;				
				end
			end
			else begin
				MERA_RD_ST <= RD_IDLE;
			end
		end	
		
		RD_STROBE1: begin
			Read_Strobe <= 1'b0;
			MERA_RD_ST <= RD_STROBE0;
		end
		
		//
		RD_STROBE0: begin
			if ( SDRAM_CTRL_RDY ) begin // Wait for the Controller to be ready.
					MERA_RD_ST <= RD_WRITE_FIFO0;
					Data_2_Write_WR_Strobe <= 1'b1;
			end
			else begin
					MERA_RD_ST <= RD_STROBE0;				
			end		
		end
		
		RD_WRITE_FIFO0: begin
			Data_2_Write_WR_Strobe <= 1'b0;
			MERA_RD_ST <= RD_DONE;	
		end
		
//		RD_WRITE_FIFO1: begin
//			MERA_RD_ST <= RD_IDLE;	
//		end		
		
		RD_DONE: begin
				MERA_RD_ST <= RD_IDLE;		
		end
		
		RD_WAIT_CTRL: begin
			if ( SDRAM_CTRL_RDY ) begin // Wait for the Controller to be ready.
					Read_Strobe <= 1'b1;			
					MERA_RD_ST <= RD_STROBE1;
			end
			else begin
					MERA_RD_ST <= RD_WAIT_CTRL;				
			end		
		end

		default: begin
			MERA_RD_ST <= RD_IDLE;
		end
					
		endcase	
	end
end

assign iBUS_D_Valid_o = 1'b0;

reg Read_Strobe;
reg Write_Strobe;
reg SDRAM_VALID;

reg	[15:0]	Reset_Counter = 16'hFFFF;
reg	[1:0]		MiniSDRAM_Init_SM = 2'b00;
wire 				Controller_Is_Ready_2_Roll;
//reg				SDControler_Init = 1'b0;
reg				SDRAM_Init;

always @ (posedge SDRAM_Clk_i) begin

	case ( MiniSDRAM_Init_SM )
		2'b00: begin 
			SDRAM_Init <= 1'b0;
			if ( Reset_Counter )
				Reset_Counter <= Reset_Counter - 16'h0001;
			else begin
				MiniSDRAM_Init_SM <= 2'b01;
			end
		end
	
		2'b01: begin 
			MiniSDRAM_Init_SM <= 2'b10;
			SDRAM_Init <= 1'b1;
		end
	
		2'b10: begin 
			if ( SDRAM_CTRL_RDY ) begin
				MiniSDRAM_Init_SM <= 2'b11;		
			end
		end
	
		// If we get here, We are all set!
		2'b11: begin 
			SDRAM_Init <= 1'b0;
			MiniSDRAM_Init_SM <= 2'b11;	
		end
	
	endcase
end

wire [1:0] SDRAM_BA;

assign SYSRAM_BA0_o = SDRAM_BA[0];
assign SYSRAM_BA1_o = SDRAM_BA[1];


MERA_SDRAM_32Bits Mera_SDController (
	.init( SDRAM_Init ),        // reset to initialize RAM
   .clk( SDRAM_Clk_i ),         	// clock ~100MHz
                                  // SDRAM_* - signals to the MT48LC16M16 chip
   .SDRAM_DQ( SYSRAM_DQ_io[31:0] ),    // 16 bit bidirectional data bus
   .SDRAM_A( SYSRAM_A_o ),     // 13 bit multiplexed address bus
   .SDRAM_DQMLL( SYSRAM_DQM_o[0] ),  // D7..0 - MSB (Be[3])
   .SDRAM_DQMLH( SYSRAM_DQM_o[1] ),  // D15..8
   .SDRAM_DQMHL( SYSRAM_DQM_o[2] ),  // D23..16
	.SDRAM_DQMHH( SYSRAM_DQM_o[3] ),  // D31..24 - LSB (Be[0])
	
   .SDRAM_BA( SDRAM_BA ),    // two banks
   .SDRAM_nCS( SYSRAM_CS0n_o ),   // a single chip select
   .SDRAM_nWE( SYSRAM_WEn_o ),   // write enable
   .SDRAM_nRAS( SYSRAM_RASn_o ),  // row address select
   .SDRAM_nCAS( SYSRAM_CASn_o ),  // columns address select
   .SDRAM_CKE( SYSRAM_CKE_o ),   // clock enable
	.SDRAM_CLK( SYSRAM_CLK_o ),
                                  //
   .addr( { CMD_ADDY[23:0], 2'b00 } ),        // 25 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations. addr[1:0] for 32bit operation?
   .dout( Data2Read ),        // data output to cpu
	.be( CMD_BE ),
   .din( CMD_DATA ),         // data input from cpu
	
   .we( Write_Strobe ),          // cpu requests write
   .rd( Read_Strobe ),          // cpu requests read

   .ready( SDRAM_CTRL_RDY )        // dout is valid. Ready to accept new read/write.
);


endmodule

/*
reg	[1:0]	 iBUS_CS_MERA_i_EDGE;

wire Mera_CS;

assign Mera_CS = iBUS_CS_MERA_i & ( iBUS_BE_i[0] | iBUS_BE_i[1]);

always @ ( posedge CPU_Clk_i) begin
	iBUS_CS_MERA_i_EDGE[0] <= Mera_CS;
	iBUS_CS_MERA_i_EDGE[1] <= 	iBUS_CS_MERA_i_EDGE[0];
end

SDRAM_DATA_FIFO	CPU_2_SDRAM_DATA (
	.data ( {16'h0000, iBUS_D_i} ),
	.wrclk ( CPU_Clk_i ),
	.wrreq ( { iBUS_CS_MERA_i_EDGE[0], Mera_CS} == 2'b01),
	.wrfull (  ),
	
	.rdclk ( rdclk_sig ),
	.rdreq ( rdreq_sig ),
	.q ( q_sig ),
	.rdempty ( rdempty_sig )
);

SDRAM_DATA_FIFO	CPU_2_SDRAM_ADDY (
	.data ( { iBUS_BE_i[1:0], 5'h00, iBUS_A_i} ),
	.wrclk ( CPU_Clk_i ),
	.wrreq ( { iBUS_CS_MERA_i_EDGE[0], Mera_CS} == 2'b01),
	.wrfull (  ),
	
	.rdclk ( rdclk_sig ),
	.rdreq ( rdreq_sig ),
	.q ( q_sig ),
	.rdempty ( rdempty_sig )
);
*/
///////////////////////////////////////
// CODE BONEYARD
//////////////////////////////////////
/*
reg [2:0] MiniSM;

localparam    	IDLE 	= 3'b000,
					ST0	= 3'b001,
					ST1	= 3'b010,
					ST2	= 3'b011,
					ST3	= 3'b100,
					ST4	= 3'b101,
					ST5	= 3'b110,
					ST6	= 3'b111;

initial begin
	Read_Strobe = 1'b0;
	Write_Strobe = 1'b0;
	SDRAM_VALID = 1'b0;
end

always @ (posedge SDRAM_Clk_i) begin
	if (Reset_i) begin
		Read_Strobe <= 1'b0;
		Write_Strobe <= 1'b0;
		SDRAM_VALID <= 1'b0;
		MiniSM <= IDLE;
	end
	else begin
	
		case( MiniSM )
		
		IDLE: begin 
				if ( {iBUS_CS_MERA_i_EDGE[2:0], iBUS_CS_MERA_i & iBUS_A_Valid_i} == 4'b0011 ) begin
//					SDRAM_VALID <= 1'b1;	// DTACK
					if (iBUS_RWn_i) begin
						// Read
						MiniSM <= ST0;					
					end
					else begin
						// Write
						MiniSM <= ST4;					
					end
			end
			else begin
				MiniSM <= IDLE;
			end
		end
		
		// Read
		ST0: begin 
			if ( SDRAM_CTRL_RDY ) begin // Wait for the Controller to be ready.
				Read_Strobe <= 1'b1;
				MiniSM <= ST1;
			end
			else begin
				MiniSM <= ST0;		
			end
		end
		
		ST1: begin
			Read_Strobe <= 1'b0;
			MiniSM <= ST2;
		end
		
		ST2: begin
			if ( SDRAM_CTRL_RDY ) begin
				MiniSM <= ST3; // When here, Data is valid
			end
			else begin
				MiniSM <= ST2;
			end
		end
		
		ST3: begin 
//			SDRAM_VALID <= 1'b0;	// DTACK
			if ( SDRAM_CTRL_RDY )
					MiniSM <= IDLE;
			else
					MiniSM <= ST3;
		end
		
		ST4: begin 
			if ( SDRAM_CTRL_RDY && iBUS_WE_i) begin // Wait for the Controller to be ready and that the data is actually valid to be written
				Write_Strobe <= 1'b1;
				MiniSM <= ST5;
			end
			else begin
				MiniSM <= ST4;		
			end		
		end

		ST5: begin 
//			SDRAM_VALID <= 1'b0;	// DTACK
			Write_Strobe <= 1'b0;
			MiniSM <= ST6;		
		end

		ST6: begin 
			if ( SDRAM_CTRL_RDY )
					MiniSM <= IDLE;
			else
					MiniSM <= ST6;	
		end
		
		default: begin
			MiniSM <= IDLE;
		end
		
		endcase
	
	end
end
*/
