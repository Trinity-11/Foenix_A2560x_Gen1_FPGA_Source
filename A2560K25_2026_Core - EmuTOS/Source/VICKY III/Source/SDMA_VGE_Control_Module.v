`timescale 1ns/1ns
module SDMA_VGE_Control_Module(

input		wire				Reset_i,
input		wire				EngineClk100Mhz_i,
input		wire				VideoMode_i,			// I need to know it if is 640x480 or 800x600
// Incoming Command from CPU
input		wire	[35:0]	Command_Phase0_i,
input		wire	[35:0]	Command_Phase1_i,
input		wire	[35:0]	Command_Phase2_i,
// Write SRAM Data to VRAM (CPU Write VRAM)
output	reg				SRAM_2_VRAM_Data_Read_Req_o,
input		wire				SRAM_2_VRAM_FIFO_Empty_i,
// Write VRAM Data to SRAM (CPU Read VRAM)
output	reg				VRAM_2_SRAM_Data_Write_Req_o,
input		wire				VRAM_2_SRAM_FIFO_Full_i,
// Interface to VRAM
output	wire	[19:0]	VMEM_SDMA_Addy_o,
output	reg				VMEM_SDMA_Readn_o,
// Interface to Master State Machine
input		wire  [11:0]	LineTickTock_i,
input		wire				SDMA_VGE_Enabled_i,
input		wire				SDMA_VGE_Trigger_i,

output	reg				SDMA_In_Progress_o,

output	reg	[4:0]		SMDA_VGE_SM_o
);

initial begin
VMEM_SDMA_Readn_o = 1'b1;
end

/*
always @ (*) begin
	case (SDMA_CMD_Phase)
		2'b00: 	begin SDMA_CMD_o = { 11'h000, SDMA_Control_Reg_i[1], 1'b1 , SDMA_RW, !SDMA_Address_Pointer[21], !SDMA_Address_Pointer[20], SDMA_Address_Pointer[19:0]}; end
		2'b01: 	begin SDMA_CMD_o = { 4'h0, SDMA_Y_Size_i, SDMA_X_Size_i}; end 
		2'b10: 	begin SDMA_CMD_o = { 4'h0, SDMA_Dst_Stride_i, SDMA_Src_Stride_i}; end 
		2'b11: 	begin SDMA_CMD_o = { 11'h000, SDMA_Control_Reg_i[1], 1'b1 , SDMA_RW, !SDMA_Address_Pointer[21], !SDMA_Address_Pointer[20], SDMA_Address_Pointer[19:0]}; end
		default: begin SDMA_CMD_o = { 11'h000, SDMA_Control_Reg_i[1], 1'b1 , SDMA_RW, !SDMA_Address_Pointer[21], !SDMA_Address_Pointer[20], SDMA_Address_Pointer[19:0]}; end
	endcase
end
*/

// The LineClockTick ought not to go higher then 3200. the 31.777us (640x480), 26.4us (800x600)
// So 3177 for Mode 0
// &  2640 for Mode 1

wire 				SDMA_VGE_Dir;
wire 				SDMA_VGE_1D2D;
wire	[23:0]	SDMA_VGE_1D_Size;
wire	[15:0]	SDMA_VGE_2DX_Size;
wire	[15:0]	SDMA_VGE_2DY_Size;

reg	[19:0]	Address_Pointer;
reg	[19:0]	Counter;

assign VMEM_SDMA_Addy_o 	= Command_Phase0_i[21:2] + Address_Pointer;
assign SDMA_VGE_Dir 			= Command_Phase0_i[22];
assign SDMA_VGE_1D2D 		= Command_Phase0_i[23];
assign SDMA_VGE_1D_Size 	= Command_Phase1_i[23:0];
assign SDMA_VGE_2DX_Size 	= Command_Phase1_i[15:0];
assign SDMA_VGE_2DY_Size	= Command_Phase1_i[31:16];


always @ (posedge EngineClk100Mhz_i) begin
	if ( Reset_i ) begin
	
	end
	else begin
		if (SMDA_VGE_SM_o == WRITE_0) begin
			if ((SRAM_2_VRAM_FIFO_Empty_i == 1'b0) && (LineTickTock_i > 12'h10)) begin
				Address_Pointer <= Address_Pointer + 12'h001;
			end
		end
		else begin
				Address_Pointer <= 12'h000;		
		end
	end
end


localparam	IDLE 		= 5'b0_0000,
				
				DIR_TIME	= 5'b0_0001,
				
				READ_0	= 5'b0_0010,
				READ_1	= 5'b0_0011,
				READ_2	= 5'b0_0100,
				READ_3	= 5'b0_0101,
				READ_4	= 5'b0_0110,
				READ_5	= 5'b0_0111,

				WRITE_L  = 5'b1_0000,
				WRITE_0	= 5'b1_0001,
				WRITE_1	= 5'b1_0010,
				WRITE_2	= 5'b1_0011,
				WRITE_3	= 5'b1_0100,
				WRITE_4	= 5'b1_0101,
				WRITE_5	= 5'b1_0110,
				
				THE_END	= 5'b1_1111;
				

always @ (posedge EngineClk100Mhz_i)
begin
	if ( Reset_i ) begin
		SMDA_VGE_SM_o 						<= IDLE;
		VMEM_SDMA_Readn_o 				<= 1'b1;
		VRAM_2_SRAM_Data_Write_Req_o 	<= 1'b0;
		SRAM_2_VRAM_Data_Read_Req_o 	<= 1'b0;
		
	end
	else begin
		case (SMDA_VGE_SM_o)
		
		IDLE: begin 
			if ( SDMA_VGE_Enabled_i && SDMA_VGE_Trigger_i ) begin		// Make sure it is at leasr bigger than 32 Clock left, so we can actually do something
				SMDA_VGE_SM_o <= DIR_TIME;
			end
			else begin
				SMDA_VGE_SM_o <= IDLE;
			end
		end
		
		// Check the Direction and Set the Time Out
		// TimeLeftTickTock is now a Count Down, so 
		DIR_TIME: begin 
			if (SDMA_VGE_Dir) begin
				SMDA_VGE_SM_o <= READ_0;
			end
			else begin
				SMDA_VGE_SM_o <= WRITE_L;
				SRAM_2_VRAM_Data_Read_Req_o <= 1'b1;
			end
		end
		

		READ_0: begin
			SMDA_VGE_SM_o <= READ_1;		
		end
		
		READ_1: begin 
			SMDA_VGE_SM_o <= READ_2;		
		end
		
		READ_2: begin 
			SMDA_VGE_SM_o <= READ_3;		
		end
		
		READ_3: begin 
			SMDA_VGE_SM_o <= READ_4;		
		end
		
		READ_4: begin 
			SMDA_VGE_SM_o <= READ_5;		
		end
		
		READ_5: begin 
			SMDA_VGE_SM_o <= THE_END;		
		
		end

		////// WRITE DATA TO MEMORY
		// FIFO Latency 0
		// Read Is 1 here
		WRITE_L: begin
			SMDA_VGE_SM_o <= WRITE_0;
		end
		
		// 1 Clock Latency
		// Data is Valid here, the only thing we have to do is just count or wait
		WRITE_0: begin 
			if ( Address_Pointer < Command_Phase1_i[19:2] )	// if the Address_Pointer Reaches the 
				SMDA_VGE_SM_o <= WRITE_0;
			else begin
				SRAM_2_VRAM_Data_Read_Req_o <= 1'b0;			
				SMDA_VGE_SM_o <= THE_END;
			end
		end
		
		// Output from FIFO is valid here:
		WRITE_1: begin 
			SMDA_VGE_SM_o <= WRITE_2;		
		end
		
		WRITE_2: begin 
			SMDA_VGE_SM_o <= WRITE_3;		
		end
		
		WRITE_3: begin 
			SMDA_VGE_SM_o <= WRITE_4;		
		end
		
		WRITE_4: begin 
			SMDA_VGE_SM_o <= WRITE_5;		
		end
		
		WRITE_5: begin 
			SMDA_VGE_SM_o <= THE_END;		
		end
		
		THE_END: begin 
			SMDA_VGE_SM_o <= IDLE;		
		end
		
		default: begin 
		
		
		end
		
		endcase
	end
end





endmodule

