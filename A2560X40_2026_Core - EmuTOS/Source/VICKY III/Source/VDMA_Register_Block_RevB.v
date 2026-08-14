`timescale 1ns/1ns
module VDMA_Register_Block_RevB(
// General Clock & Reset
input 	wire				Reset_i,
input		wire				Reset_100Mhz_i,
// CPU Interface
input		wire				Bus_Clk_i,
input		wire				EngineClk100Mhz_i,
input		wire	[23:0]	Bus_A_i,
input		wire				Bus_RW_i,
input		wire				Bus_RDY_i,
output	wire				Bus_RDY_o,
input		wire	[7:0]		Bus_D_i,
output 	reg	[7:0]		Bus_D_o,
input		wire				CS_VDMA_Controller_i,

output	wire	[7:0]		VDMA_Control_Reg_o,
output	wire	[7:0]		VDMA_Data_2_Write_o,
output	wire	[23:0]	VDMA_Src_Addy_o,
output	wire	[23:0]	VDMA_Dst_Addy_o,
output	wire	[15:0]	VDMA_X_Size_o,
output	wire	[15:0]	VDMA_Y_Size_o,
output	wire	[15:0]	VDMA_Src_Stride_o,
output	wire	[15:0]	VDMA_Dst_Stride_o,
input		wire	[7:0]		VDMA_Status_Reg_i
);

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
//////////// 
//////////// 14Mhz Section
////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
//Register Block of 16Bytes
assign Bus_RDY_o = 1'b0;

reg [7:0]		VDMA_REG[0:15];

// Writing Part
always @ (negedge Bus_Clk_i)
begin
	if (Reset_i)
	begin
		VDMA_REG[0]  <= 8'h00;		// VDMA_Control_Register
		VDMA_REG[1]  <= 8'h00;		// VDMA_Data_2_Write
		VDMA_REG[2]  <= 8'h00;		// VDMA_Source_Addy_L
		VDMA_REG[3]  <= 8'h00;		// VDMA_Source_Addy_M
		VDMA_REG[4]  <= 8'h00;		// VDMA_Source_Addy_H
		VDMA_REG[5]  <= 8'h00;		// VDMA_Destination_Addy_L
		VDMA_REG[6]  <= 8'h00;		// VDMA_Destination_Addy_M
		VDMA_REG[7]  <= 8'h00;		// VDMA_Destination_Addy_H
		VDMA_REG[8]  <= 8'h00;		// VDMA_X_Size_L
		VDMA_REG[9]  <= 8'h00;		// VDMA_X_Size_H
		VDMA_REG[10] <= 8'h00;		// VDMA_Y_Size_L
		VDMA_REG[11] <= 8'h00;		// VDMA_Y_Size_H
		VDMA_REG[12] <= 8'h00;		// VDMA_Stride_L
		VDMA_REG[13] <= 8'h00;		// VDMA_Stride_H
		VDMA_REG[14] <= 8'h00;		// VDMA_Data_2_Write_L
		VDMA_REG[15] <= 8'h00;		// VDMA_Data_2_Write_H
	end
	else
	begin
		if (CS_VDMA_Controller_i & !Bus_RW_i)
			VDMA_REG[Bus_A_i[3:0]] <= Bus_D_i;
	end
end

always @ (*)
begin
	case(Bus_A_i[3:0])
		// Video Memory DMA
		5'b0_0000: Bus_D_o = VDMA_REG[0];			// VDMA_Control_Register
		5'b0_0001: Bus_D_o = VDMA_Status_Reg_i;	// VDMA_Status_Register / VDMA_Byte_2_Write
		5'b0_0010: Bus_D_o = VDMA_REG[2];		   // VDMA_Source_Addy_L
		5'b0_0011: Bus_D_o = VDMA_REG[3];		   // VDMA_Source_Addy_M
		5'b0_0100: Bus_D_o = VDMA_REG[4];		   // VDMA_Source_Addy_H
		5'b0_0101: Bus_D_o = VDMA_REG[5];		   // VDMA_Destination_Addy_L
		5'b0_0110: Bus_D_o = VDMA_REG[6];		   // VDMA_Destination_Addy_M
		5'b0_0111: Bus_D_o = VDMA_REG[7];		   // VDMA_Destination_Addy_H
		5'b0_1000: Bus_D_o = VDMA_REG[8];		   // VDMA_X_Size_L
		5'b0_1001: Bus_D_o = VDMA_REG[9];		   // VDMA_X_Size_H
		5'b0_1010: Bus_D_o = VDMA_REG[10];		   // VDMA_Y_Size_L
		5'b0_1011: Bus_D_o = VDMA_REG[11];		   // VDMA_Y_Size_H
		5'b0_1100: Bus_D_o = VDMA_REG[12];		   // VDMA_Src_Stride_L
		5'b0_1101: Bus_D_o = VDMA_REG[13];		   // VDMA_Src_Stride_H
		5'b0_1110: Bus_D_o = VDMA_REG[14];		   // VDMA_Dst_Stride_L
		5'b0_1111: Bus_D_o = VDMA_REG[15];        // VDMA_Dst_Stride_H
	endcase
end


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
//////////// 
//////////// 100Mhz Section
////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/*
reg	[6:0] SlowClKEDGE_Detect;

always @ (posedge EngineClk100Mhz_i) begin
	SlowClKEDGE_Detect[0] <= Bus_Clk_i;
	SlowClKEDGE_Detect[1] <= SlowClKEDGE_Detect[0];
	SlowClKEDGE_Detect[2] <= SlowClKEDGE_Detect[1];
	SlowClKEDGE_Detect[3] <= SlowClKEDGE_Detect[2];
	SlowClKEDGE_Detect[4] <= SlowClKEDGE_Detect[3];	
	SlowClKEDGE_Detect[5] <= SlowClKEDGE_Detect[4];	
	SlowClKEDGE_Detect[6] <= SlowClKEDGE_Detect[5];		
end



reg [7:0] Data_In_Clk1;
reg [23:0] Address_In_Clk1;
reg [7:0] Data_In_Clk2;
reg [23:0] Address_In_Clk2;
reg [2:0]	Trigger_Write;

always @ (posedge EngineClk100Mhz_i) begin
	Data_In_Clk1 <= Bus_D_i;
	Data_In_Clk2 <= Data_In_Clk1;
	
	Address_In_Clk1 <= Bus_A_i;
	Address_In_Clk2 <= Address_In_Clk1;
	
	Trigger_Write[0] <= CS_VDMA_Controller_i & !Bus_RW_i;
	Trigger_Write[1] <= Trigger_Write[0];
	Trigger_Write[2] <= Trigger_Write[1];	
end

reg [7:0]		VDMA_REG_100MHZ[0:15];

// Writing Part
always @ (posedge EngineClk100Mhz_i)
begin
	if (Reset_100Mhz_i)
	begin
		VDMA_REG_100MHZ[0]  <= 8'h00;		// VDMA_Control_Register
		VDMA_REG_100MHZ[1]  <= 8'h00;		// VDMA_Data_2_Write
		VDMA_REG_100MHZ[2]  <= 8'h00;		// VDMA_Source_Addy_L
		VDMA_REG_100MHZ[3]  <= 8'h00;		// VDMA_Source_Addy_M
		VDMA_REG_100MHZ[4]  <= 8'h00;		// VDMA_Source_Addy_H
		VDMA_REG_100MHZ[5]  <= 8'h00;		// VDMA_Destination_Addy_L
		VDMA_REG_100MHZ[6]  <= 8'h00;		// VDMA_Destination_Addy_M
		VDMA_REG_100MHZ[7]  <= 8'h00;		// VDMA_Destination_Addy_H
		VDMA_REG_100MHZ[8]  <= 8'h00;		// VDMA_X_Size_L
		VDMA_REG_100MHZ[9]  <= 8'h00;		// VDMA_X_Size_H
		VDMA_REG_100MHZ[10] <= 8'h00;		// VDMA_Y_Size_L
		VDMA_REG_100MHZ[11] <= 8'h00;		// VDMA_Y_Size_H
		VDMA_REG_100MHZ[12] <= 8'h00;		// VDMA_Stride_L
		VDMA_REG_100MHZ[13] <= 8'h00;		// VDMA_Stride_H
		VDMA_REG_100MHZ[14] <= 8'h00;		// VDMA_Data_2_Write_L
		VDMA_REG_100MHZ[15] <= 8'h00;		// VDMA_Data_2_Write_H
	end
	else
	begin
		if (Trigger_Write[2:1] == 2'b01)
			VDMA_REG_100MHZ[Address_In_Clk2[3:0]] <= Data_In_Clk2;
	end
end


assign VDMA_Control_Reg_o 		= VDMA_REG_100MHZ[0];
assign VDMA_Data_2_Write_o 	= VDMA_REG_100MHZ[1];
assign VDMA_Src_Addy_o			= {VDMA_REG_100MHZ[4], VDMA_REG_100MHZ[3], VDMA_REG_100MHZ[2]};
assign VDMA_Dst_Addy_o 			= {VDMA_REG_100MHZ[7], VDMA_REG_100MHZ[6], VDMA_REG_100MHZ[5]};
assign VDMA_X_Size_o				= {VDMA_REG_100MHZ[9], VDMA_REG_100MHZ[8]};
assign VDMA_Y_Size_o 			= {VDMA_REG_100MHZ[11], VDMA_REG_100MHZ[10]};
assign VDMA_Src_Stride_o 		= {VDMA_REG_100MHZ[13], VDMA_REG_100MHZ[12]};
assign VDMA_Dst_Stride_o 		= {VDMA_REG_100MHZ[15], VDMA_REG_100MHZ[14]};
*/
/*

wire [71:0] ChipScope;
wire			Trigger;

assign Trigger = Trigger_Write[1];

ChipScope	ChipScope_inst (
	.acq_clk ( EngineClk100Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

// This is the Signal Driving the Input Side of the DP Memory
// Signal that Drives the VRAM

assign ChipScope[23:0] 		= Address_In_Clk1[23:0];		// I am more interested in what is going out than in.
assign ChipScope[31:24] 	= Data_In_Clk1[7:0];
assign ChipScope[35:32]		= Trigger_Write;	// Write //3'b010
assign ChipScope[43:36] 	= VDMA_Control_Reg_o;
assign ChipScope[66:44] 	= VDMA_Src_Addy_o[22:0];
assign ChipScope[71:67]    = SlowClKEDGE_Detect[4:0];

*/

reg	[7:0]	 VDMA_Control_Reg_META0;
reg	[7:0]	 VDMA_Data_2_Write_META0;
reg 	[23:0] VDMA_Src_Addy_META0;
reg 	[23:0] VDMA_Dst_Addy_META0;
reg 	[15:0] VDMA_X_Size_META0;
reg 	[15:0] VDMA_Y_Size_META0;
reg 	[15:0] VDMA_Src_Stride_META0;
reg 	[15:0] VDMA_Dst_Stride_META0;

reg	[7:0]	VDMA_Control_Reg_META1;
reg	[7:0]	VDMA_Data_2_Write_META1;
reg 	[23:0] VDMA_Src_Addy_META1;
reg 	[23:0] VDMA_Dst_Addy_META1;
reg 	[15:0] VDMA_X_Size_META1;
reg 	[15:0] VDMA_Y_Size_META1;
reg 	[15:0] VDMA_Src_Stride_META1;
reg 	[15:0] VDMA_Dst_Stride_META1;

reg	[7:0]	VDMA_Control_Reg_META2;
reg	[7:0]	VDMA_Data_2_Write_META2;
reg 	[23:0] VDMA_Src_Addy_META2;
reg 	[23:0] VDMA_Dst_Addy_META2;
reg 	[15:0] VDMA_X_Size_META2;
reg 	[15:0] VDMA_Y_Size_META2;
reg 	[15:0] VDMA_Src_Stride_META2;
reg 	[15:0] VDMA_Dst_Stride_META2;


always @ (posedge EngineClk100Mhz_i)
begin
		VDMA_Control_Reg_META0 <= VDMA_REG[0];
		VDMA_Control_Reg_META1 <= VDMA_Control_Reg_META0;
		if (VDMA_Control_Reg_META1 == VDMA_Control_Reg_META0) begin
			VDMA_Control_Reg_META2 <= VDMA_Control_Reg_META1;
		end
		
		VDMA_Data_2_Write_META0 <= VDMA_REG[1];
		VDMA_Data_2_Write_META1 <= VDMA_Data_2_Write_META0;
		if (VDMA_Data_2_Write_META1 == VDMA_Data_2_Write_META0) begin
			VDMA_Data_2_Write_META2 <= VDMA_Data_2_Write_META1;
		end
		
		VDMA_Src_Addy_META0 <= {VDMA_REG[4], VDMA_REG[3], VDMA_REG[2]};
		VDMA_Src_Addy_META1 <= VDMA_Src_Addy_META0;
		if ( VDMA_Src_Addy_META1 == VDMA_Src_Addy_META0 ) begin
			VDMA_Src_Addy_META2 <= VDMA_Src_Addy_META1;
		end
		
		VDMA_Dst_Addy_META0 <= {VDMA_REG[7], VDMA_REG[6], VDMA_REG[5]};
		VDMA_Dst_Addy_META1 <= VDMA_Dst_Addy_META0;
		if (VDMA_Dst_Addy_META1 == VDMA_Dst_Addy_META0) begin
			VDMA_Dst_Addy_META2 <= VDMA_Dst_Addy_META1;
		end
		
		VDMA_X_Size_META0 <= {VDMA_REG[9], VDMA_REG[8]};
		VDMA_X_Size_META1 <= VDMA_X_Size_META0;
		if (VDMA_X_Size_META1 == VDMA_X_Size_META0)
			VDMA_X_Size_META2 <= VDMA_X_Size_META1;
		
		VDMA_Y_Size_META0 <= {VDMA_REG[11], VDMA_REG[10]};
		VDMA_Y_Size_META1 <= VDMA_Y_Size_META0;
		if (VDMA_Y_Size_META1 == VDMA_Y_Size_META0) begin
			VDMA_Y_Size_META2 <= VDMA_Y_Size_META1;
		end
		
		VDMA_Src_Stride_META0 <= {VDMA_REG[13], VDMA_REG[12]};
		VDMA_Src_Stride_META1 <= VDMA_Src_Stride_META0;
		if ( VDMA_Src_Stride_META1 == VDMA_Src_Stride_META0 ) begin
			VDMA_Src_Stride_META2 <= VDMA_Src_Stride_META1;
		end
		
		VDMA_Dst_Stride_META0 <= {VDMA_REG[15], VDMA_REG[14]};
		VDMA_Dst_Stride_META1 <= VDMA_Dst_Stride_META0;
		if ( VDMA_Dst_Stride_META1 == VDMA_Dst_Stride_META0 ) begin
			VDMA_Dst_Stride_META2 <= VDMA_Dst_Stride_META1;
		end
end

assign VDMA_Control_Reg_o 		= VDMA_Control_Reg_META2;
assign VDMA_Data_2_Write_o 	= VDMA_Data_2_Write_META2;
assign VDMA_Src_Addy_o			= VDMA_Src_Addy_META2;
assign VDMA_Dst_Addy_o 			= VDMA_Dst_Addy_META2;
assign VDMA_X_Size_o				= VDMA_X_Size_META2;
assign VDMA_Y_Size_o 			= VDMA_Y_Size_META2;
assign VDMA_Src_Stride_o 		= VDMA_Src_Stride_META2;
assign VDMA_Dst_Stride_o 		= VDMA_Dst_Stride_META2;




endmodule

