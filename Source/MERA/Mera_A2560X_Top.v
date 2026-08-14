module MERA_A2560X_Top(
// Reset
input	   wire					Reset_i,
input	   wire					CPU_1xClk_i,		// 33Mhz
input 	wire					SYS_2xClk_i,		// 66Mhz
input	   wire					SYS_4xClk_i,		// 133Mhz
input 	wire    				CPU_TIPn_i,			// Transaction in Progress
// Buses
input	   wire		[31:0]	iBUS_A_i,
input	   wire					iBUS_A_Valid_i,		// = !TS - So when it comes to 1 the Address is Valid 
input	   wire		[7:0]		iBUS_D8_i,
input	   wire		[15:0]	iBUS_D16_i,
input	   wire		[31:0]	iBUS_D32_i,
input	   wire		[31:0]   iBUS_D_Out_virgin_i, 

input	   wire		[1:0]		iBUS_D_Siz_i,
output	wire					iBUS_D_Valid_o,
input	   wire					iBUS_RWn_i,
input	   wire		[3:0]		iBUS_BE_i,
input	   wire					iBUS_WE_i,
output	wire		[31:0]	iBUS_D_MERA_o,
input	   wire					iBUS_CS_MERA_i,
output	wire					Wait_MERA_TA_o,

// System RAM
inout	   wire		[31:0]	SYSRAM_DQ_io,
output	wire		[3:0]		SYSRAM_DQM_o,
output	wire		[12:0]	SYSRAM_A_o,
output	wire					SYSRAM_BA0_o,
output	wire					SYSRAM_BA1_o,
output	wire					SYSRAM_CASn_o,
output	wire					SYSRAM_RASn_o,
output	wire					SYSRAM_WEn_o,
output	wire					SYSRAM_CS0n_o,
output	wire					SYSRAM_CKE_o,
output	wire					SYSRAM_CLK_o
); 

wire [31:0]       Data2Read;

assign Wait_MERA_TA_o = 1'b0;
assign iBUS_D_Valid_o = 1'b0;
// 2x 16M16 -> 16M32 = 64MBytes
// Total Address 13 + 9 + 2 = 24Lines = 16M x 32 (4 Bytes)
// 0000_0000 - 0x03FF_FFFF
// A[23:0] = 16MB
// A[25:0] = 64MB
wire 		MERA_Busy;
reg 		Read_Enable;
reg [4:0]     Write_Enable;

always @ ( posedge SYS_4xClk_i ) begin 
	Write_Enable[0] <= ( iBUS_CS_MERA_i & !iBUS_RWn_i );
   Write_Enable[1] <= Write_Enable[0];
   Write_Enable[2] <= Write_Enable[1];
   Write_Enable[3] <= Write_Enable[2];
   Write_Enable[4] <= Write_Enable[3];
	Read_Enable    <= ( iBUS_CS_MERA_i & iBUS_RWn_i );
end 

reg	[15:0]	Reset_Counter = 16'hFFFF;
reg	[1:0]		MiniSDRAM_Init_SM = 2'b00;
reg				SDRAM_Init;

always @ (posedge SYS_4xClk_i) begin

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
			if ( MERA_Busy ) begin
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



MERA_SDRAM_32Bits Mera_SDController (
	.init( SDRAM_Init ),        // reset to initialize RAM
   .clk( SYS_4xClk_i ),         	// clock ~100MHz
   .CPU_TIPn_i( CPU_TIPn_i ),
                                  // SDRAM_* - signals to the MT48LC16M16 chip
   .SDRAM_DQ( SYSRAM_DQ_io[31:0] ),    // 16 bit bidirectional data bus
   .SDRAM_A( SYSRAM_A_o ),     // 13 bit multiplexed address bus
   .SDRAM_DQMLL( SYSRAM_DQM_o[0] ),  // D7..0 - MSB (Be[3])
   .SDRAM_DQMLH( SYSRAM_DQM_o[1] ),  // D15..8
   .SDRAM_DQMHL( SYSRAM_DQM_o[2] ),  // D23..16
	.SDRAM_DQMHH( SYSRAM_DQM_o[3] ),  // D31..24 - LSB (Be[0])
	
   .SDRAM_BA( {SYSRAM_BA1_o, SYSRAM_BA0_o} ),    // two banks
   .SDRAM_nCS( SYSRAM_CS0n_o ),   // a single chip select
   .SDRAM_nWE( SYSRAM_WEn_o ),   // write enable
   .SDRAM_nRAS( SYSRAM_RASn_o ),  // row address select
   .SDRAM_nCAS( SYSRAM_CASn_o ),  // columns address select
   .SDRAM_CKE( SYSRAM_CKE_o ),   // clock enable
	.SDRAM_CLK( SYSRAM_CLK_o ),
	
   .addr( { iBUS_A_i[31:2], 2'b00 } ),        // 25 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations. addr[1:0] for 32bit operation?
   .dout( Data2Read ),        // data output to cpu
	.be( iBUS_BE_i ),
   .din( { iBUS_D_Out_virgin_i[7:0], iBUS_D_Out_virgin_i[15:8], iBUS_D_Out_virgin_i[23:16], iBUS_D_Out_virgin_i[31:24]} ),         // data input from cpu
   .we( Write_Enable[4:3] == 2'b01 ),          // cpu requests write
   .rd( {Read_Enable, ( iBUS_CS_MERA_i & iBUS_RWn_i )} == 2'b01 ),          // cpu requests read

	.ready( MERA_Busy )        // dout is valid. Ready to accept new read/write.
);

assign iBUS_D_MERA_o = {Data2Read[7:0], Data2Read[15:8], Data2Read[23:16], Data2Read[31:24]};

/*
wire [143:0] TP;
wire  Trigger;
assign TP[31:0] 	   = iBUS_A_i;
assign TP[63:32]  	= { iBUS_D_Out_virgin_i[7:0], iBUS_D_Out_virgin_i[15:8], iBUS_D_Out_virgin_i[23:16], iBUS_D_Out_virgin_i[31:24]};
assign TP[95:64]  	= iBUS_D_MERA_o;
assign TP[97:96]   	= iBUS_D_Siz_i;
assign TP[98]	      = iBUS_A_Valid_i;
assign TP[99] 		   = iBUS_RWn_i;
assign TP[103:100]   = iBUS_BE_i;
assign TP[104]   	   = iBUS_WE_i;
assign TP[105]		   = iBUS_CS_MERA_i;
assign TP[106]		   = MERA_Busy;
assign TP[107]	      = 1'b0;
assign TP[108]	      = Write_Enable[4:3] == 2'b01;
assign TP[109]	      = 1'b0;
assign TP[110]		   = ( {Read_Enable, ( iBUS_CS_MERA_i & iBUS_RWn_i )} == 2'b01 );
assign TP[111]		   = 1'b0;
assign TP[112]		   = !CPU_TIPn_i;

assign TP[113]		   = SYSRAM_WEn_o;
assign TP[114] 		= SYSRAM_CASn_o;
assign TP[115] 		= SYSRAM_RASn_o;
assign TP[116] 		= SYSRAM_CS0n_o;
assign TP[117] 		= SYSRAM_CKE_o;
assign TP[119:118]   = {SYSRAM_BA1_o, SYSRAM_BA0_o};
assign TP[132:120]   = SYSRAM_A_o;
assign TP[136:133]	= SYSRAM_DQM_o;
assign TP[141:137] 	= 0;
assign TP[143:142]   = 0;

assign Trigger = iBUS_CS_MERA_i;
TinyChipScope CHIPSCOPE68K (
	.acq_data_in    (TP),                  //        tap.acq_data_in
	.acq_trigger_in ( Trigger ),           //           .acq_trigger_in
	.acq_clk        ( SYS_4xClk_i ),       //    acq_clk.clk
	.trigger_in     ( Trigger )            // trigger_in.trigger_in
);
*/
/*
New_A2560x_SDRAM_CTRL New_Controller(
   .Reset_i( Reset_i ),
   .SYS_2xClk_i( SYS_2xClk_i ),				// 66Mhz
   .SYS_4xClk_i( SYS_4xClk_i ),				// 133Mhz

   .CPU_Dead_Cycle_i( CPU_TIPn_i ),    	// Lots of time when the CPU is not accessing the SDRAM or the BUS in general, so plenty of time to refresh
   .CPU_Accessing_SDRAM_i( iBUS_CS_MERA_i ),
   // Write Portion
   .wr_addr( iBUS_A_i[25:2] ),		// 24Lines x 4x Bytes Enables
   .wr_data( iBUS_D32_i ),       
   .wr_enable( Write_Enable[3:2] == 2'b01 ), // Can't Start a new transaction when The CPU is hold and refresh is being performed
   .wr_byte_enable( iBUS_BE_i ),
   // Read Portion
   .rd_addr( iBUS_A_i[25:2] ),
   .rd_data( iBUS_D_MERA_o ),
   .rd_enable( {Read_Enable, ( iBUS_CS_MERA_i & iBUS_RWn_i )} == 2'b01 ), // Can't Start a new transaction when The CPU is hold and refresh is being performed
   .rd_ready( MERA_Debug_Rd_Data_Rdy_o ),
   .busy( MERA_Debug_Busy_o ),
   
	.SDRAM_Data32_i( SDRAM_Data32_i ),
	.SDRAM_Data32_o( SDRAM_Data32_o ),
	.SDRAM_Debug_SM_o( SDRAM_Debug_SM_o ),
	
   // SDRAM Connectivity
   .addr( SYSRAM_A_o ),
   .bank_addr( {SYSRAM_BA1_o, SYSRAM_BA0_o} ),
   .data( SYSRAM_DQ_io ),
   .clock_enable( SYSRAM_CKE_o ),
   .cs_n( SYSRAM_CS0n_o ),
   .ras_n( SYSRAM_RASn_o ),
   .cas_n( SYSRAM_CASn_o ),
   .we_n( SYSRAM_WEn_o ),
   .data_mask_o( SYSRAM_DQM_o )
);


altddio_out
#(
	.extend_oe_disable("OFF"),
	.intended_device_family("Cyclone V"),
	.invert_output("OFF"),
	.lpm_hint("UNUSED"),
	.lpm_type("altddio_out"),
	.oe_reg("UNREGISTERED"),
	.power_up_high("OFF"),
	.width(1)
)
sdramclk_ddr
(
	.datain_h(1'b0),
	.datain_l(1'b1),
	.outclock(SYS_4xClk_i),
	.dataout(SYSRAM_CLK_o),
	.aclr(1'b0),
	.aset(1'b0),
	.oe(1'b1),
	.outclocken(1'b1),
	.sclr(1'b0),
	.sset(1'b0)
);
*/

endmodule

