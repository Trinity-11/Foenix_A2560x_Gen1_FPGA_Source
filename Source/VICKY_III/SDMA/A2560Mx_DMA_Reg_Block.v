`timescale 1 ns / 1 ns
module A2560Mx_DMA_Reg_Block( 
input 		wire				Reset_i,		// This is async Reset
input		wire				iBUS_2xClk_i,	// 66Mhz
// CPU Signals Interface
input		wire				iBUS_Clk_i,		// 33Mhz
input		wire	[31:0]		iBUS_A_i,
input		wire				iBUS_A_Valid_i, 
input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]		iBUS_D16_i,
input		wire	[31:0]		iBUS_D32_i,
input   	wire    			iBUS_RWn_i,
input		wire	[1:0]		iBUS_Siz_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i, 
input		wire				CS_SDMA_Controller_i,
output 		reg   	[31:0]		DataOut_SDMA_o,

output		wire	[31:0]		SDMA_Control_Reg_o,
output		wire	[7:0]		SDMA_Data_2_Write_o,
output      wire    [15:0]      SDMA_Data_2_Write16_o,
output  	wire    [31:0]		SDMA_Data_2_Write32_o,
// Addy
output		wire	[31:0]		SDMA_Src_Addy_o,
output		wire	[31:0]		SDMA_Dst_Addy_o,
// Sizes/Dimensions
output      wire    [31:0]		SDMA_1D_Size_o,
output		wire	[15:0]		SDMA_2D_X_Size_o,
output		wire	[15:0]		SDMA_2D_Y_Size_o,
// Stride
output		wire	[15:0]		SDMA_Src_Stride_o,
output		wire	[15:0]		SDMA_Dst_Stride_o,
input		wire	[7:0]		SDMA_Status_Reg_i
);

reg [31:0]		SDMA_REG[0:7];

// Writing Part
always @ (posedge iBUS_Clk_i)
begin
	if (Reset_i)
	begin
		SDMA_REG[0]  <= 32'h0000_0000; 	// SDMA_Control_Register
		SDMA_REG[1]  <= 32'h0000_0000;	// SDMA_Source_Addy
		SDMA_REG[2]  <= 32'h0000_0000;	// SDMA_Destination_Addy
		SDMA_REG[3]  <= 32'h0000_0000;	// SDMA_1D_SIZE (1D)
		SDMA_REG[4]  <= 32'h0000_0000;	// SDMA_2D_SIZE (2D)
		SDMA_REG[5]  <= 32'h0000_0000;	// SDMA_2D_STRIDE
		SDMA_REG[6]  <= 32'h0000_0000;  // Data Fill (8/16/24)
		SDMA_REG[7]  <= 32'h0000_0000;	// RESERVED
	end
	else
	begin
		if (CS_SDMA_Controller_i && !iBUS_RWn_i && (iBUS_Siz_i == 2'b00) && iBUS_WE_i) begin 
				SDMA_REG[iBUS_A_i[4:2]][31:0] <= iBUS_D32_i;	// Just allow Write Cycle to the first 8 Registers
		end
	end
end

// CPU Readback
always @ ( * )
begin
	if ( iBUS_A_i[4:2] == 3'b000 ) begin 
		DataOut_SDMA_o = { SDMA_Status_Reg_i, SDMA_REG[0][23:0] };
	end 
	else begin 
		DataOut_SDMA_o = SDMA_REG[iBUS_A_i[4:2]][31:0];
	end
end 

assign SDMA_Control_Reg_o 		= SDMA_REG[0][31:0];
assign SDMA_Src_Addy_o			= SDMA_REG[1][31:0];
assign SDMA_Dst_Addy_o 			= SDMA_REG[2][31:0];
assign SDMA_1D_Size_o			= SDMA_REG[3][15:0];
assign SDMA_2D_X_Size_o			= SDMA_REG[4][15:0];
assign SDMA_2D_Y_Size_o 		= SDMA_REG[4][31:16];
assign SDMA_Src_Stride_o 		= SDMA_REG[5][15:0];
assign SDMA_Dst_Stride_o 		= SDMA_REG[5][31:16];

assign SDMA_Data_2_Write_o 		= SDMA_REG[6][31:24];		// NEW
assign SDMA_Data_2_Write16_o 	= SDMA_REG[6][31:16];		// NEW
assign SDMA_Data_2_Write32_o	= SDMA_REG[6][31:0];		// NEW


endmodule

