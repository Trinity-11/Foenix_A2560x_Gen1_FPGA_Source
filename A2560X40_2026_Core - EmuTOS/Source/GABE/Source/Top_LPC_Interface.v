`timescale 1 ns / 1 ns

module Top_LPC_Interface
(
input		wire				Reset_i,
//output  	wire				Reset_o,				// Reset Out
// CPU Signals Interface
input		wire				CPU_Clk_i,
input		wire	[31:0]	iBUS_A_i,
input		wire				iBUS_A_Valid_i,

input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]	iBUS_D16_i,
input		wire	[31:0]	iBUS_D32_i,
input		wire	[1:0]		iBUS_D_Siz_i,

output	wire				iBUS_D_Valid_o,
input		wire				iBUS_RWn_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i, 
output	wire	[31:0]	iBUS_D_LPC_o,
input		wire				CS_LPC_i,

output	wire				Wait_LPC_TA_o,
input 	wire	[31:0]	LPC_IRQ_i,
input		wire				LPC_LDRQn_i,
// LPC Signal Interface
input 	wire				LPC_Clk_i,		//That 33Mhz ic coming from 33M Oscillator is completely async to the 33M for the CPU since it is created from the 80Mhz Clock
output	wire				lframe_o,
input		wire	[3:0]		lad_i,
output	wire	[3:0]		lad_o,
output	wire				lad_oe_o

);

wire				PCI_Reset;
//LPC Interface wires
wire				LPC_Strobe;
wire				LPC_Write;
wire	[7:0]		LPC_Data_In;
wire	[15:0]	LPC_Address;
wire				LPC_Err;
wire				LPC_Ack;
wire	[31:0]	LPC_Data_Out;
//BUS Interface wires
wire				BUS_Strobe;
wire				BUS_Write;
wire	[7:0]		BUS_Data_In;
wire	[15:0]	BUS_Address;
wire				BUS_Err;
wire				BUS_Ack;
wire	[31:0]	BUS_Data_Out;

// LPC Block Interface
wire	[31:0] 	wbs_adr_i;		// Input
wire	[31:0]	wbs_dat_o;		// Output
wire	[31:0]	wbs_dat_i;		// Input
wire				wbs_we_i;		// Active Hi
wire				wbs_stb_i;		// Input
wire				wbs_ack_o;		// Output
wire				wbs_err_o;		// Output
wire 	[4:0] 	TempChipscope1;

wire	[1:0]		TGA_o;
//wire 				Config_Done;

reg 	[2:0] rst_i_Resync;
reg 	[2:0] rst_o_Resync;

always @ (posedge LPC_Clk_i)
begin
		rst_i_Resync[0] <= Reset_i;
		rst_i_Resync[1] <= rst_i_Resync[0];
		rst_i_Resync[2] <= rst_i_Resync[1];		
end

//assign Reset_o = rst_o_Resync[2];
/*
LPC_Config_Block LPC_Init_Block(
	.LPC_Clk( LPC_Clk_i ),				// [0:0]
	.Reset_i( rst_i_Resync[2] ),
// Inputs
	.LPC_Data_Out(LPC_Data_Out),	// [31:0]
	.LPC_Ack(LPC_Ack),				// [0:0]
	.LPC_Err(LPC_Err),				// [0:0]
// Outputs
	.LPC_Address(LPC_Address),		// [15:0]
	.LPC_Data_In(LPC_Data_In),		// [7:0]
	.LPC_Write(LPC_Write),			// [0:0]
	.LPC_Strobe(LPC_Strobe),		// [0:0]
// Status
	.PCI_Reset( PCI_Reset ),
	.Config_Done_o( Config_Done ),		// [0:0]
	.ChipScope( TempChipscope1 )
);
*/

BUS_2_LPC_interface Bus_2_LPC(
	.rst_i( Reset_i ),				// This is async Reset
	.Bus_Clk_i( CPU_Clk_i ),
	.Bus_A_i( iBUS_A_i ),
	.Bus_A_Valid_i( iBUS_A_Valid_i ), 
	.Bus_D8_i( iBUS_D8_i ),
	.Bus_D16_i( iBUS_D16_i ),
	.Bus_D32_i( iBUS_D32_i ),
	.Bus_D_Siz_i( iBUS_D_Siz_i ),	

	.Bus_D_o( iBUS_D_LPC_o ),
	.Bus_RW_i( iBUS_RWn_i ),
	.Bus_BE_i( iBUS_BE_i ), 
	.Bus_WE_i( iBUS_WE_i ), 
	.Bus_D_Valid_o( iBUS_D_Valid_o ), 
	.CS_VID_SuperIO_i( CS_LPC_i ),
	.Wait_LPC_TA_o( Wait_LPC_TA_o ), 
// LPC Block Interface
	.LPC_Clk_i( LPC_Clk_i ),
	.LPC_Data_Out_i(BUS_Data_Out),
	.LPC_Ack_i(BUS_Ack),
	.LPC_Err_i(BUS_Err),
// Outputs
	.LPC_Address_o(BUS_Address),
	.LPC_Data_In_o(BUS_Data_In),
	.LPC_Write_o(BUS_Write),
	.LPC_Strobe_o(BUS_Strobe)
);

/*
assign wbs_adr_i 	= 	Config_Done ? BUS_Address : {16'h0000, LPC_Address};
assign wbs_dat_i 	= 	Config_Done ? {24'h000000, BUS_Data_In} : {24'h000000, LPC_Data_In};
assign wbs_we_i 	= 	Config_Done ? BUS_Write :	LPC_Write;
assign wbs_stb_i 	= 	Config_Done ? BUS_Strobe : LPC_Strobe;
assign LPC_Data_Out = Config_Done ? 32'h00000000 : wbs_dat_o;
assign BUS_Data_Out = Config_Done ? wbs_dat_o : 32'h00000000;

assign LPC_Ack = Config_Done ? 1'b0 : wbs_ack_o;
assign BUS_Ack = Config_Done ? wbs_ack_o : 1'b0;
assign LPC_Err = Config_Done ? 1'b0 : wbs_err_o;
assign BUS_Err = Config_Done ? wbs_err_o : 1'b0;
*/

// NEW 

assign wbs_adr_i 	= 	BUS_Address;
assign wbs_dat_i 	= 	{24'h000000, BUS_Data_In};
assign wbs_we_i 	= 	BUS_Write; 
assign wbs_stb_i 	= 	BUS_Strobe;
assign BUS_Data_Out = wbs_dat_o;

assign BUS_Ack = wbs_ack_o;
assign BUS_Err = wbs_err_o;

//assign lpc_reset_o = !Reset_i;
wire [1:0]	TGA_i;		// 01 - IO , 11 - DMA


wb_lpc_host LPC_HOST_Block(
// Wishbone Slave Interface
	.clk_i( LPC_Clk_i ),
	.nrst_i( !rst_i_Resync[2] ),					// Active low reset.
	.wbs_adr_i( wbs_adr_i ),		// input			[31:0]
	.wbs_dat_o( wbs_dat_o ),		// output  		[31:0]
	.wbs_dat_i( wbs_dat_i ),		// input   		[31:0]
	.wbs_sel_i( 4'b0001 ),			// input			[3:0] (1 Byte)
	.wbs_tga_i( 2'b01 ),				// input   		[1:0]
	.wbs_we_i( wbs_we_i ),			// input		(active high)	
	.wbs_stb_i( wbs_stb_i ),		// Input Strobe 
	.wbs_cyc_i( 1'b1 ),				// Input Cycle	
	.wbs_ack_o( wbs_ack_o ),		// Output Ack
	.wbs_err_o( wbs_err_o ),		// Output Error
// LPC Master Interface
	.dma_chan_i( 3'b010 ), 			// DMA Channel input       [2:0] 	
	.dma_tc_i( 1'b1 ),				// DMA Terminal Count	
// LPC Interface
	.lframe_o( lframe_o ),			// LPC Frame output (active high)
	.lad_i( lad_i ),					// input  [3:0] 	LPC AD Input Bus
	.lad_o( lad_o ),					// output reg  [3:0] 	 LPC AD Output Bus
	.lad_oe( lad_oe_o )					// LPC AD Output Enable
);

endmodule

