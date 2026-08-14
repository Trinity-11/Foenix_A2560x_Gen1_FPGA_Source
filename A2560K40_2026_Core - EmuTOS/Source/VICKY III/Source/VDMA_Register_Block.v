`timescale 1ns/1ns
module VDMA_Register_Block(
// General Clock & Reset
input 	wire				Rst_i,
// CPU Interface
input		wire				Bus_Clk_i,
input		wire				Engine_Clk_i,
input		wire	[23:0]	Bus_A_i,
input		wire				Bus_RW_i,
input		wire				Bus_RDY_i,
output	wire				Bus_RDY_o,
input		wire	[7:0]		Bus_D_i,
output 	reg	[7:0]		Bus_D_o,
input		wire				CS_DMA_Controller_i,

output	wire	[7:0]		VDMA_Control_Reg_o,
output	wire	[7:0]		VDMA_Data_2_Write_o,
output	wire	[23:0]	VDMA_Src_Addy_o,
output	wire	[23:0]	VDMA_Dst_Addy_o,
output	wire	[15:0]	VDMA_X_Size_o,
output	wire	[15:0]	VDMA_Y_Size_o,
output	wire	[15:0]	VDMA_Src_Stride_o,
output	wire	[15:0]	VDMA_Dst_Stride_o,

output	wire	[7:0]		SDMA_Control_Reg_o,
output	wire	[7:0]		SDMA_Data_2_Write_o,
output	wire	[23:0]	SDMA_Src_Addy_o,
output	wire	[23:0]	SDMA_Dst_Addy_o,
output	wire	[15:0]	SDMA_X_Size_o,
output	wire	[15:0]	SDMA_Y_Size_o,
output	wire	[15:0]	SDMA_Src_Stride_o,
output	wire	[15:0]	SDMA_Dst_Stride_o,

input		wire	[7:0]		VDMA_Status_Reg_i,
input		wire	[7:0]		SDMA_Status_Reg_i
);

//Register Block of 16Bytes
assign Bus_RDY_o = 1'b0;
reg [7:0]		VDMA_REG[0:31];


// Writing Part
always @ (negedge Bus_Clk_i)
begin
	if (Rst_i)
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
		VDMA_REG[16] <= 8'h00;		// SDMA_Source_Addy_L
		VDMA_REG[17] <= 8'h00;		// SDMA_Source_Addy_M
		VDMA_REG[18] <= 8'h00;		// SDMA_Source_Addy_H
		VDMA_REG[19] <= 8'h00;		// SDMA_Destination_Addy_L
		VDMA_REG[20] <= 8'h00;		// SDMA_Destination_Addy_M
		VDMA_REG[21] <= 8'h00;		// SDMA_Destination_Addy_H
		VDMA_REG[22] <= 8'h00;		// SDMA_X_Size_L
		VDMA_REG[23] <= 8'h00;     // SDMA_X_Size_H
		VDMA_REG[24] <= 8'h00;     // SDMA_Y_Size_L
		VDMA_REG[25] <= 8'h00;     // SDMA_Y_Size_H
		VDMA_REG[26] <= 8'h00;     // SDMA_Stride_L
		VDMA_REG[27] <= 8'h00;     // SDMA_Stride_H
		VDMA_REG[28] <= 8'h00;		// SDMA_Byte_2_Write______
		VDMA_REG[29] <= 8'h00;
		VDMA_REG[30] <= 8'h00;
		VDMA_REG[31] <= 8'h00;		
	end
	else
	begin
		if (CS_DMA_Controller_i & !Bus_RW_i)
			VDMA_REG[Bus_A_i[4:0]] <= Bus_D_i;
	end
end

always @ (*)
begin
	case(Bus_A_i[4:0])
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
		// System DMA
		5'b1_0000: Bus_D_o = VDMA_REG[16];	      // SDMA_Control_Register
		5'b1_0001: Bus_D_o = SDMA_Status_Reg_i;	// SDMA_Status_Register / SDMA_Byte_2_Write
		5'b1_0010: Bus_D_o = VDMA_REG[18];		   // SDMA_Source_Addy_L
		5'b1_0011: Bus_D_o = VDMA_REG[19];		   // SDMA_Source_Addy_M
		5'b1_0100: Bus_D_o = VDMA_REG[20];		   // SDMA_Source_Addy_H
		5'b1_0101: Bus_D_o = VDMA_REG[21];		   // SDMA_Destination_Addy_L
		5'b1_0110: Bus_D_o = VDMA_REG[22];		   // SDMA_Destination_Addy_M
		5'b1_0111: Bus_D_o = VDMA_REG[23];		   // SDMA_Destination_Addy_H
		5'b1_1000: Bus_D_o = VDMA_REG[24];		   // SDMA_X_Size_L
		5'b1_1001: Bus_D_o = VDMA_REG[25];		   // SDMA_X_Size_H
		5'b1_1010: Bus_D_o = VDMA_REG[26];		   // SDMA_Y_Size_L
		5'b1_1011: Bus_D_o = VDMA_REG[27];		   // SDMA_Y_Size_H
		5'b1_1100: Bus_D_o = VDMA_REG[28];		   // SDMA_Src_Stride_L
		5'b1_1101: Bus_D_o = VDMA_REG[29];		   // SDMA_Src_Stride_H
		5'b1_1110: Bus_D_o = VDMA_REG[30];		   // SDMA_Dst_Stride_L
		5'b1_1111: Bus_D_o = VDMA_REG[31];        // SDMA_Dst_Stride_H........................
	endcase
end

//assign VDMA_Control_Reg_o = 	VDMA_REG[0];
//assign VDMA_Data_2_Write_o = 	VDMA_REG[1];
//assign VDMA_Src_Addy_o = 		{VDMA_REG[4], VDMA_REG[3], VDMA_REG[2]};
//assign VDMA_Dst_Addy_o = 		{VDMA_REG[7], VDMA_REG[6], VDMA_REG[5]};
//assign VDMA_X_Size_o = 			{VDMA_REG[9], VDMA_REG[8]};
//assign VDMA_Y_Size_o = 			{VDMA_REG[11], VDMA_REG[10]};
//assign VDMA_Src_Stride_o = 	{VDMA_REG[13], VDMA_REG[12]};
//assign VDMA_Dst_Stride_o = 	{VDMA_REG[15], VDMA_REG[14]};


assign SDMA_Control_Reg_o = 	VDMA_REG[16];
assign SDMA_Data_2_Write_o = 	VDMA_REG[17];
assign SDMA_Src_Addy_o = 		{VDMA_REG[20], VDMA_REG[19], VDMA_REG[18]};
assign SDMA_Dst_Addy_o = 		{VDMA_REG[23], VDMA_REG[22], VDMA_REG[21]};
assign SDMA_X_Size_o = 			{VDMA_REG[25], VDMA_REG[24]};
assign SDMA_Y_Size_o = 			{VDMA_REG[27], VDMA_REG[26]};
assign SDMA_Src_Stride_o = 	{VDMA_REG[29], VDMA_REG[28]};
assign SDMA_Dst_Stride_o = 	{VDMA_REG[31], VDMA_REG[30]};


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

//reg	[7:0]	SDMA_Control_Reg_META0;
//reg	[7:0]	SDMA_Data_2_Write_META0;
//reg 	[23:0] SDMA_Src_Addy_META0;
//reg 	[23:0] SDMA_Dst_Addy_META0;
//reg 	[15:0] SDMA_X_Size_META0;
//reg 	[15:0] SDMA_Y_Size_META0;
//reg 	[15:0] SDMA_Src_Stride_META0;
//reg 	[15:0] SDMA_Dst_Stride_META0;

//reg	[7:0]	SDMA_Control_Reg_META1;
//reg	[7:0]	SDMA_Data_2_Write_META1;
//reg 	[23:0] SDMA_Src_Addy_META1;
//reg 	[23:0] SDMA_Dst_Addy_META1;
//reg 	[15:0] SDMA_X_Size_META1;
//reg 	[15:0] SDMA_Y_Size_META1;
//reg 	[15:0] SDMA_Src_Stride_META1;
//reg 	[15:0] SDMA_Dst_Stride_META1;


always @ (posedge Engine_Clk_i)
begin
		VDMA_Control_Reg_META0 <= VDMA_REG[0];
		VDMA_Data_2_Write_META0 <= VDMA_REG[1];
		VDMA_Src_Addy_META0 <= {VDMA_REG[4], VDMA_REG[3], VDMA_REG[2]};
		VDMA_Dst_Addy_META0 <= {VDMA_REG[7], VDMA_REG[6], VDMA_REG[5]};
		VDMA_X_Size_META0 <= {VDMA_REG[9], VDMA_REG[8]};
		VDMA_Y_Size_META0 <= {VDMA_REG[11], VDMA_REG[10]};
		VDMA_Src_Stride_META0 <= {VDMA_REG[13], VDMA_REG[12]};
		VDMA_Dst_Stride_META0 <= {VDMA_REG[15], VDMA_REG[14]};
		
		VDMA_Control_Reg_META1 <= VDMA_Control_Reg_META0;
		VDMA_Data_2_Write_META1 <= VDMA_Data_2_Write_META0;
		VDMA_Src_Addy_META1 <= VDMA_Src_Addy_META0;
		VDMA_Dst_Addy_META1 <= VDMA_Dst_Addy_META0;
		VDMA_X_Size_META1 <= VDMA_X_Size_META0;
		VDMA_Y_Size_META1 <= VDMA_Y_Size_META0;
		VDMA_Src_Stride_META1 <= VDMA_Src_Stride_META0;
		VDMA_Dst_Stride_META1 <= VDMA_Dst_Stride_META0;
end



assign VDMA_Control_Reg_o = 	VDMA_Control_Reg_META1;
assign VDMA_Data_2_Write_o =  VDMA_Data_2_Write_META1;
assign VDMA_Src_Addy_o = 		VDMA_Src_Addy_META1;
assign VDMA_Dst_Addy_o = 		VDMA_Dst_Addy_META1;
assign VDMA_X_Size_o = 			VDMA_X_Size_META1;
assign VDMA_Y_Size_o = 			VDMA_Y_Size_META1;
assign VDMA_Src_Stride_o = 	VDMA_Src_Stride_META1;
assign VDMA_Dst_Stride_o = 	VDMA_Dst_Stride_META1;



//
//VDMA_Control_Register[0] = Enable VDMA Block 
//VDMA_Control_Register[1] = 1D/2D Transfer (0 - (1D) Linear ({Y_Size_L, X_Size_H, X_Size_L}), 1 - 2D ((X Size + (Stride)) x Y Size)
//VDMA_Control_Register[2] = Src/Dst Transfer, Data2WriteDst (0 - Read Source -> Write Destination) - (1 - Read Byte to Write -> Write Destination) (Short Transfer)
//VDMA_Control_Register[3] = Enable VDMA Interrupt (VDMA Tsf done)
//VDMA_Control_Register[4] = TBD
//VDMA_Control_Register[5] = TBD
//VDMA_Control_Register[6] = TBD
//VDMA_Control_Register[7] = Start Transfer

//SDMA_Control_Register[0] = Enable SDMA Block
//SDMA_Control_Register[1] = 1D/2D Transfer (0 - (1D) Linear ({Y_Size_L, X_Size_H, X_Size_L}), 1 - 2D ((X Size + (Stride)) x Y Size)
//SDMA_Control_Register[2] = Src/Dst Transfer, Data2WriteDst (0 - Read Source -> Write Destination) - (1 - Read Byte to Write -> Write Destination) (Byte Transfer)
//SDMA_Control_Register[3] = Enable SDMA Interrupt (SDMA Tsf Done)
//SDMA_Control_Register[4] = 
//SDMA_Control_Register[5] = 
//SDMA_Control_Register[6] = 
//SDMA_Control_Register[7] = Start Transfer

// VDMA Function (works Only within VICKY's memory) $00_0000 - $3F:0000
// Mode 1 - 1D Transfer Src to Dst + Size -> Linear Transfer
// Mode 2 - 2D Transfer Src to Dst + X Size, Y Size


endmodule

