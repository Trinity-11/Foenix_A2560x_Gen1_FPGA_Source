module C256Foenix_SMemoryInterface(

input		wire				Reset_i,
input		wire				CPU_Clk_i,

// Slave Interface to Program the Registers for the SDMA
input		wire	[23:0]	Bus_A_i,
input		wire	[7:0]		Bus_D_Internal_VickyII_Data_i,
input		wire	[7:0]		Bus_D_i,
output	reg	[7:0]		Bus_D_o,
input		wire				Bus_RW_i,
input		wire				BUS_VPA_i,
input		wire				BUS_VDA_i,
input		wire				Bus_RDY_i,
output	wire				Bus_RDY_o,
input		wire				CS_SDMA_Controller_i,

// Master Interface to go poke and use the bus for Transfer
output	wire	[23:0]	CPU_SDMA_A_o,			// DMA Channel Assy
output	reg	[7:0]		CPU_SDMA_D_Out_o,		// DMA Channel Data Out
input		wire	[7:0]		CPU_SDMA_D_In_i,		// DMA Channel Data In
output	wire				CPU_SDMA_Bus_RW_o,	// DMA Channel Read/Writen
//output	wire				CS_VKYIIn_o,

// External Bus Master Control
output	reg				CPU_SDMA_Bus_Reqn_o,
input		wire				CPU_SDMA_Bus_Ackn_i,
// FIFO Output

// Input FIFO Interface from the VDMA Controller	
input		wire	[7:0]		FIFO_Input_Channel_i,
output	wire				FIFO_Input_Read_o,
input		wire	[9:0]		FIFO_Input_Count_i,
input		wire				FIFO_Input_Empty_i, 
// Output FIFO Interface to  the VDMA Controller
output	reg				FIFO_Output_Clear_o,
output	wire	[7:0]		FIFO_Output_Channel_o, 
output	wire				FIFO_Output_Write_o,
input		wire	[9:0]		FIFO_Output_Count_i,
input		wire				FIFO_OUtput_Full_i
);

/*
wire [71:0] ChipScope;
wire			Trigger;

//assign Trigger = SDMA_REG[0][0] & SDMA_Src_Cntr_Reached_Count & (SDMA_REG[0][5:4] == 2'b01) & (CPU_SDMA_A_o > 24'h3FEEC0);
//assign Trigger = SDMA_REG[0][0] & (SDMA_REG[0][5:4] == 2'b01) & !AlmostFull_Stop_Flag  & (FIFO_Output_Count_i > 10'h0300);
//assign Trigger = SDMA_Dst_Cntr_Reached_Count & (SDMA_REG[0][5:4] == 2'b10);

assign Trigger = FIFO_Input_Read_o;

ChipScope	ChipScope_inst (
	.acq_clk ( CPU_Clk_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

// This is the Signal Driving the Input Side of the DP Memory
// Signal that Drives the VRAM
assign ChipScope[23:0] 		= CPU_SDMA_A_o;		// I am more interested in what is going out than in.
assign ChipScope[47:24]		= SDMA_Dst_Addy_Stop;
assign ChipScope[55:48] 	= FIFO_Input_Channel_i;

assign ChipScope[56] 		= CPU_SDMA_Bus_RW_o;
assign ChipScope[57] 		= SDMA_Dst_Cntr_Reached_Count;
//assign ChipScope[63:58] 	= SDMA_SM;
assign ChipScope[61:58]    = FIFO_Input_Count_i[3:0];
assign ChipScope[65:62]		= StridePointerCounter[3:0];
assign ChipScope[68] 		= FIFO_Input_Empty_i;
assign ChipScope[69] 		= AlmostFull_Stop_Flag;
assign ChipScope[70] 		= Dst_VDMA_Count_Enable;
assign ChipScope[71] 		= FIFO_Input_Read_o;
*/

reg FIFO_Input_Data_Ready_Pos;
reg FIFO_Input_Data_Ready_Pos_Dly;

always @ (posedge CPU_Clk_i)
begin
	FIFO_Input_Data_Ready_Pos <= (!FIFO_Input_Empty_i & Dst_VDMA_Count_Enable) & SDMA_Dst_Compare_Condition_ALB;
	//FIFO_Input_Data_Ready_Pos_Dly <= FIFO_Input_Data_Ready_Pos;
end

reg [7:0] Internal_Data_Bus_Reg;

always @ (posedge CPU_Clk_i)
begin
	Internal_Data_Bus_Reg <= Bus_D_Internal_VickyII_Data_i;
	//FIFO_Input_Data_Ready_Pos_Dly <= FIFO_Input_Data_Ready_Pos;
end


initial begin
	CPU_SDMA_Bus_Reqn_o 	= 1'b1;		// THis is very important to set this by default to 1
	FIFO_Output_Clear_o  = 1'b0;
end

wire	[7:0] SDMA_Status_Reg_i;

assign SDMA_Status_Reg_i = 8'h55;
assign Bus_RDY_o = 1'b0;

wire AlmostFull_Stop_Flag;

//assign AlmostFull_Stop_Flag = (FIFO_Output_Count_i < 10'd960) ? 1'b1 : 1'b0;
assign AlmostFull_Stop_Flag = !FIFO_Output_Count_i[9];

assign FIFO_Output_Channel_o 	= OneWaitState_Read_Zone ? Internal_Data_Bus_Reg : CPU_SDMA_D_In_i;
assign FIFO_Output_Write_o 	= SDMA_REG[0][4] ? (AlmostFull_Stop_Flag & Src_VDMA_Count_Enable) : 1'b0;
assign FIFO_Input_Read_o  		= SDMA_REG[0][5] ? (!FIFO_Input_Empty_i & Dst_VDMA_Count_Enable & !SDMA_Dst_Cntr_Reached_Count) : 1'b0;
assign CPU_SDMA_Bus_RW_o 		= SDMA_REG[0][5] ? !FIFO_Input_Data_Ready_Pos : CPU_SDMA_Bus_RW;

// Data Output to SRAM
always @ (*) begin
	casex({SDMA_REG[0][2], SDMA_REG[0][5:4]})
	3'b000: CPU_SDMA_D_Out_o = OneWaitState_Read_Zone ? Internal_Data_Bus_Reg : CPU_SDMA_D_In_i;
	3'b001: CPU_SDMA_D_Out_o = 8'h00;		// No Output, we are only readin
	3'b010: CPU_SDMA_D_Out_o = FIFO_Input_Channel_i;
	3'b011: CPU_SDMA_D_Out_o = OneWaitState_Read_Zone ? Internal_Data_Bus_Reg : CPU_SDMA_D_In_i;
	3'b1xx: CPU_SDMA_D_Out_o = SDMA_REG[16];	// Fill Byte
	default: CPU_SDMA_D_Out_o = 8'h00;
	endcase
end

// Assignments
//assign CS_VKYIIn_o 	= Begin_Transfer;
//Register Block of 16Bytes
assign Bus_RDY_o = 1'b0;

reg [7:0]		SDMA_REG[0:31];

// Writing Part
always @ (negedge CPU_Clk_i)
begin
	if (Reset_i)
	begin
		SDMA_REG[0]  <= 8'h00;		// SDMA_Control_Register0
		SDMA_REG[1]  <= 8'h00;		// SDMA_Control_Register1
		SDMA_REG[2]  <= 8'h00;		// SDMA_Source_Addy_L
		SDMA_REG[3]  <= 8'h00;		// SDMA_Source_Addy_M
		SDMA_REG[4]  <= 8'h00;		// SDMA_Source_Addy_H
		SDMA_REG[5]  <= 8'h00;		// SDMA_Destination_Addy_L
		SDMA_REG[6]  <= 8'h00;		// SDMA_Destination_Addy_M
		SDMA_REG[7]  <= 8'h00;		// SDMA_Destination_Addy_H
		SDMA_REG[8]  <= 8'h00;		// SDMA_X_Size_L
		SDMA_REG[9]  <= 8'h00;		// SDMA_X_Size_H
		SDMA_REG[10] <= 8'h00;		// SDMA_Y_Size_L
		SDMA_REG[11] <= 8'h00;		// SDMA_Y_Size_H
		SDMA_REG[12] <= 8'h00;		// SDMA_Stride_L
		SDMA_REG[13] <= 8'h00;		// SDMA_Stride_H
		SDMA_REG[14] <= 8'h00;		// SDMA_Data_2_Write_L
		SDMA_REG[15] <= 8'h00;		// SDMA_Data_2_Write_H
		SDMA_REG[16] <= 8'h00;		// SDMA_Control_Register
		SDMA_REG[17] <= 8'h00;		// SDMA_Data_2_Write
		SDMA_REG[18] <= 8'h00;		// SDMA_Source_Addy_L
		SDMA_REG[19] <= 8'h00;		// SDMA_Source_Addy_M
		SDMA_REG[20] <= 8'h00;		// SDMA_Source_Addy_H
		SDMA_REG[21] <= 8'h00;		// SDMA_Destination_Addy_L
		SDMA_REG[22] <= 8'h00;		// SDMA_Destination_Addy_M
		SDMA_REG[23] <= 8'h00;		// SDMA_Destination_Addy_H
		SDMA_REG[24] <= 8'h00;		// SDMA_X_Size_L
		SDMA_REG[25] <= 8'h00;		// SDMA_X_Size_H
		SDMA_REG[26] <= 8'h00;		// SDMA_Y_Size_L
		SDMA_REG[27] <= 8'h00;		// SDMA_Y_Size_H
		SDMA_REG[28] <= 8'h00;		// SDMA_Stride_L
		SDMA_REG[29] <= 8'h00;		// SDMA_Stride_H
		SDMA_REG[30] <= 8'h00;		// SDMA_Data_2_Write_L
		SDMA_REG[31] <= 8'h00;		// SDMA_Data_2_Write_H		
	end
	else
	begin
		if (CS_SDMA_Controller_i & !Bus_RW_i)
			SDMA_REG[Bus_A_i[4:0]] <= Bus_D_i;
	end
end

always @ (*)
begin
	case(Bus_A_i[4:0])
		// System Direct Memory Access
		5'b0_0000: Bus_D_o = SDMA_REG[0];				// SDMA_Control_Register0
		5'b0_0001: Bus_D_o = SDMA_REG[1];				// SDMA_Control_Register1
		5'b0_0010: Bus_D_o = SDMA_REG[2];		   	// SDMA_Source_Addy_L
		5'b0_0011: Bus_D_o = SDMA_REG[3];		   	// SDMA_Source_Addy_M
		5'b0_0100: Bus_D_o = SDMA_REG[4];		   	// SDMA_Source_Addy_H
		5'b0_0101: Bus_D_o = SDMA_REG[5];		   	// SDMA_Destination_Addy_L
		5'b0_0110: Bus_D_o = SDMA_REG[6];		   	// SDMA_Destination_Addy_M
		5'b0_0111: Bus_D_o = SDMA_REG[7];		   	// SDMA_Destination_Addy_H
		5'b0_1000: Bus_D_o = SDMA_REG[8];		   	// SDMA_X_Size_L
		5'b0_1001: Bus_D_o = SDMA_REG[9];		   	// SDMA_X_Size_H
		5'b0_1010: Bus_D_o = SDMA_REG[10];		   	// SDMA_Y_Size_L
		5'b0_1011: Bus_D_o = SDMA_REG[11];		   	// SDMA_Y_Size_H
		5'b0_1100: Bus_D_o = SDMA_REG[12];		   	// SDMA_Src_Stride_L
		5'b0_1101: Bus_D_o = SDMA_REG[13];		   	// SDMA_Src_Stride_H
		5'b0_1110: Bus_D_o = SDMA_REG[14];		   	// SDMA_Dst_Stride_L
		5'b0_1111: Bus_D_o = SDMA_REG[15];        	// SDMA_Dst_Stride_H........................
		5'b1_0000: Bus_D_o = SDMA_Status_Reg_i;      // SDMA_Byte_2_Write
		default: Bus_D_o = 8'hAA;
	endcase
end

//////////////////////////////////
//////
///// ADDRESS COMPUTE SECTION
//////
//////////////////////////////////

wire 	[23:0]	SDMA_Src_Addy;
wire	[23:0]	SDMA_Dst_Addy;
wire	[15:0]	SDMA_X_Size;
wire  [15:0]	SDMA_Y_Size;
wire	[15:0]	SDMA_Src_Stride;
wire	[15:0]	SDMA_Dst_Stride;

reg	[15:0]	StridePointerCounter;	// This is Y Counter to Reach the Y Size

wire	[23:0]	Count1D;
wire	[23:0]	Count2D;
wire	[31:0]	ComputeStrideSource;
wire	[31:0]	ComputeStrideDestination;
wire 	[23:0] 	SrcPlusCount1D;
wire 	[23:0] 	DstPlusCount1D;
wire	[23:0]	SrcPlusStride;
wire	[23:0]	DstPlusStride;
wire	[23:0]	SrcPlusStridePlusX;
wire	[23:0]	DstPlusStridePlusX;


// Assignments on some intermediate value to be used in the Start/Stop Address Pointer
assign SDMA_Src_Addy 		= { SDMA_REG[4], SDMA_REG[3], SDMA_REG[2] };
assign SDMA_Dst_Addy			= { SDMA_REG[7], SDMA_REG[6], SDMA_REG[5] };
assign SDMA_X_Size         = { SDMA_REG[9], SDMA_REG[8] 	};
assign SDMA_Y_Size         = { SDMA_REG[11], SDMA_REG[10] };
assign SDMA_Src_Stride		= { SDMA_REG[13], SDMA_REG[12] };
assign SDMA_Dst_Stride		= { SDMA_REG[15], SDMA_REG[14] };

assign Count1D 				= {SDMA_Y_Size[7:0], SDMA_X_Size};

assign SrcPlusCount1D 		= SDMA_Src_Addy + Count1D - 24'h00_0001;
assign SrcPlusStride			= SDMA_Src_Addy + ComputeStrideSource[23:0];
assign SrcPlusStridePlusX	= SDMA_Src_Addy + ComputeStrideSource[23:0] + {8'h00, SDMA_X_Size} - 24'h00_0001;

assign DstPlusCount1D 		= SDMA_Dst_Addy + Count1D - 24'h00_0001;
assign DstPlusStride			= SDMA_Dst_Addy + ComputeStrideDestination[23:0];
assign DstPlusStridePlusX	= SDMA_Dst_Addy + ComputeStrideDestination[23:0] + {8'h00, SDMA_X_Size} - 24'h00_0001;


// Compute Stride for Source
DMA_MULT_BLK SDMASourceStrideCompute(
	.clock( CPU_Clk_i),
	.dataa( StridePointerCounter ),		// This Calculate the Stride in Between each X Begining 
	.datab( SDMA_Src_Stride ), 	// Number of line
	.result( ComputeStrideSource )	// The Output is in Tile Char, 
	);
	
// Compute Stride for Source
DMA_MULT_BLK SDMADestinationStrideCompute(
	.clock( CPU_Clk_i),
	.dataa( StridePointerCounter ),		// This Calculate the Stride in Between each X Begining 
	.datab( SDMA_Dst_Stride ), 	// Number of line
	.result( ComputeStrideDestination )	// The Output is in Tile Char, 
	);

reg	[23:0]	SDMA_Src_Addy_Start;
reg	[23:0]	SDMA_Src_Addy_Stop;
reg	[23:0]	SDMA_Dst_Addy_Start;
reg	[23:0]	SDMA_Dst_Addy_Stop;
/*
SDMA_CONTROL_REG0       = $AF0420
; Bit Field Definition
SDMA_CTRL0_Enable       = $01
SDMA_CTRL0_1D_2D        = $02     ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
SDMA_CTRL0_TRF_Fill     = $04     ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
SDMA_CTRL0_Int_Enable   = $08     ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
SDMA_CTRL0_SysRAM_Src   = $10     ; Set to 1 to Indicate that the Source is the SRAM -> FIFO (VDMA FIFO Port)
SDMA_CTRL0_SysRAM_Dst   = $20     ; Set to 1 to Indicate that the Destination is (VDMA FIFO Port) FIFO -> SRAM
SDMA_CTRL0_Undefined		= $40		 ;
SDMA_CTRL0_Start_TRF    = $80     ; Set to 1 To Begin Process, Need to Cleared before, you can start another

SDMA_CONTROL_REG1       = $AF0421
SDMA_CTRL1_IO_Src			= $01		 ; 1 = Source is an IO Address (ADC, SuperIO, IDE)
SDMA_CTRL1_IO_Src16		= $02		 ; 0 = Src 8Bits Transfer / 1= 16Bits Transfer
SDMA_CTRL1_IO_Dst			= $04		 ; 1 = Destination is an IO Address (DAC, SuperIO, IDE)
SDMA_CTRL1_IO_Dst16     = $08     ; 0 = Dst 8bits Transfer / 1= 16bits
*/
always @ (posedge CPU_Clk_i)
begin
	case ( {SDMA_REG[0][1], SDMA_REG[0][5:4]} )
	
	// 1D
	// This is a Local Transfer
	3'b000: begin
			// SRAM
			SDMA_Src_Addy_Start 	<= SDMA_Src_Addy;
			SDMA_Src_Addy_Stop 	<= SrcPlusCount1D;
			SDMA_Dst_Addy_Start	<= SDMA_Dst_Addy;
			SDMA_Dst_Addy_Stop	<= DstPlusCount1D;
	end
	
	// SRAM is the Source, VRAM is the Destination
	3'b001: begin 
			// SRAM
			SDMA_Src_Addy_Start 	<= SDMA_Src_Addy;
			SDMA_Src_Addy_Stop 	<= SrcPlusCount1D;
			SDMA_Dst_Addy_Start	<= 24'h00_0000;
			SDMA_Dst_Addy_Stop	<= 24'h00_0000;
	end
	
	// VRAM is the Source, SRAM is the Destination
	3'b010: begin 
			// SRAM
			SDMA_Src_Addy_Start 	<= 24'h00_0000;
			SDMA_Src_Addy_Stop 	<= 24'h00_0000;
			SDMA_Dst_Addy_Start	<= SDMA_Dst_Addy;
			SDMA_Dst_Addy_Stop	<= DstPlusCount1D;	
	end
	
	// IO Transfer
	3'b011: begin 
			// SRAM		
			SDMA_Src_Addy_Start 	<= 24'h00_0000;
			SDMA_Src_Addy_Stop 	<= 24'h00_0000;
			SDMA_Dst_Addy_Start	<= 24'h00_0000;
			SDMA_Dst_Addy_Stop	<= 24'h00_0000;	
	end
	
	// 2D Transfer
	3'b100: begin 
			SDMA_Src_Addy_Start 	<= SrcPlusStride;
			SDMA_Src_Addy_Stop 	<= SrcPlusStridePlusX;
			SDMA_Dst_Addy_Start	<= DstPlusStride;
			SDMA_Dst_Addy_Stop	<= DstPlusStridePlusX;
	end
	
	// SRAM is the Source, VRAM is the Destination	
	3'b101: begin 
			SDMA_Src_Addy_Start 	<= SrcPlusStride;
			SDMA_Src_Addy_Stop 	<= SrcPlusStridePlusX;
			SDMA_Dst_Addy_Start	<= 24'h00_0000;
			SDMA_Dst_Addy_Stop	<= 24'h00_0000;
	end

	// VRAM is the Source, SRAM is the Destination	
	3'b110: begin 
			SDMA_Src_Addy_Start 	<= 24'h00_0000;
			SDMA_Src_Addy_Stop 	<= 24'h00_0000;
			SDMA_Dst_Addy_Start	<= DstPlusStride;
			SDMA_Dst_Addy_Stop	<= DstPlusStridePlusX;
	end
	
	// IO Transfer in 2D (not Sure there is a purpose)	
	3'b111: begin 
			SDMA_Src_Addy_Start 	<= 24'h00_0000;
			SDMA_Src_Addy_Stop 	<= 24'h00_0000;
			SDMA_Dst_Addy_Start	<= 24'h00_0000;
			SDMA_Dst_Addy_Stop	<= 24'h00_0000;	
	end
	
	default: begin
			SDMA_Src_Addy_Start 	<= 24'h00_0000;
			SDMA_Src_Addy_Stop 	<= 24'h00_0000;
			SDMA_Dst_Addy_Start	<= 24'h00_0000;
			SDMA_Dst_Addy_Stop	<= 24'h00_0000;
	end

	endcase
end


wire				OneWaitState_Read_Zone;

// Okay, so if you read in with the SDMA in the AF:XXXX then 1 wait state will be added.
assign 			OneWaitState_Read_Zone = ( SDMA_Src_Addy_Start[23:16] == 8'b1010_1111 )  ? 1'b1 : 1'b0;

// Source Counter

reg 				Src_Counter_Enable;
wire	[23:0]	Src_Address_Counter;
wire 				SDMA_Src_Compare_Condition_AEB;
wire 				SDMA_Src_Compare_Condition_AGEB;
wire 				SDMA_Src_Compare_Condition_ALB;
wire 				SDMA_Src_Compare_Condition_ANEB;

reg 				Dst_Counter_Enable;
wire	[23:0]	Dst_Address_Counter;
wire 				SDMA_Dst_Compare_Condition_AEB;
wire 				SDMA_Dst_Compare_Condition_AGEB;
wire 				SDMA_Dst_Compare_Condition_ALB;
wire 				SDMA_Dst_Compare_Condition_ANEB;

wire 				SDMA_Src_Cntr_Reached_Count;
wire 				SDMA_Dst_Cntr_Reached_Count;

reg				Src_VDMA_Count_Enable;
reg				Dst_VDMA_Count_Enable;

// 24BitAddress Address (Counter of Int (1bytes))
ADDY_COUNTER	ADDY_COUNTER_Src (
	.aclr ( Reset_i ),
	.clk_en ( 1'b1 ),
	.clock ( CPU_Clk_i ),
	.cnt_en ( SDMA_REG[0][4] ? ( AlmostFull_Stop_Flag & Src_VDMA_Count_Enable )  : Src_Counter_Enable ),
	.data ( SDMA_Src_Addy_Start ),
	.sload ( Load_Src_Addy[1] ),
	.updown ( 1'b1 ),							// 1= Up, 0= Down
	.q ( Src_Address_Counter )						// Directly drive the VRAM Address
);

ADDY_COMPARE ADDY_COMP_Src (
	.dataa( Src_Address_Counter ),
	.datab( SDMA_Src_Addy_Stop ),
	.aeb( SDMA_Src_Compare_Condition_AEB ),		// A == B
	.ageb( SDMA_Src_Compare_Condition_AGEB ),		// A >= B
	.alb( SDMA_Src_Compare_Condition_ALB ),		// A < B 
	.aneb( SDMA_Src_Compare_Condition_ANEB )		// A != B
);

// 24BitAddress Address (Counter of Int (1bytes))
ADDY_COUNTER	ADDY_COUNTER_Dst (
	.aclr ( Reset_i ),
	.clk_en ( 1'b1 ),
	.clock ( CPU_Clk_i ),
	.cnt_en ( SDMA_REG[0][5] ? FIFO_Input_Data_Ready_Pos : Dst_Counter_Enable ),
	.data ( SDMA_Dst_Addy_Start ),
	.sload ( Load_Dst_Addy[1] ),
	.updown ( 1'b1 ),							// 1= Up, 0= Down
	.q ( Dst_Address_Counter )						// Directly drive the VRAM Address
);


ADDY_COMPARE ADDY_COMP_Dst (
	.dataa( Dst_Address_Counter ),
	.datab( SDMA_Dst_Addy_Stop ),
	.aeb( SDMA_Dst_Compare_Condition_AEB ),		// A == B
	.ageb( SDMA_Dst_Compare_Condition_AGEB ),		// A >= B
	.alb( SDMA_Dst_Compare_Condition_ALB ),		// A < B 
	.aneb( SDMA_Dst_Compare_Condition_ANEB )		// A != B
);

assign CPU_SDMA_A_o = CPU_SDMA_Bus_RW_o ? Src_Address_Counter : Dst_Address_Counter;


assign SDMA_Src_Cntr_Reached_Count = SDMA_Src_Compare_Condition_AGEB;
assign SDMA_Dst_Cntr_Reached_Count = SDMA_Dst_Compare_Condition_AGEB;


//SDMA_Target_Data_Output_Valid_o <= (SDMA_Target_Counter_Enable_i & SDMA_Compare_Condition_ALB);


////////////////////////////////////////////
////////
//////// State Machine
////////
////////////////////////////////////////////


reg	[5:0]		SDMA_SM;
reg	[5:0]		SDMA_SM_SM;

localparam		IDLE					=	6'b00_0000,
					VALIDATE0			=	6'b00_0001,// Make Sure the Parameters are Valid
					VALIDATE1			=	6'b00_0011,
					VALIDATE2			=	6'b00_0010,
					// SRAM to SRAM in 1D/2D/Fill
					SRAM_SRAM_ST00		=	6'b00_0110,
					SRAM_SRAM_ST01		=	6'b00_0111,
					SRAM_SRAM_ST02		=	6'b00_0101,
					SRAM_SRAM_ST03		=	6'b00_0100,
					SRAM_SRAM_ST04		=	6'b00_1100,
					SRAM_SRAM_ST05		=	6'b00_1101,
					SRAM_SRAM_ST06		=	6'b00_1111,
					SRAM_SRAM_ST07		=	6'b00_1110,
					SRAM_SRAM_ST08		=	6'b00_1010,
					SRAM_SRAM_ST09		=	6'b00_1011,
					SRAM_SRAM_ST0A		=	6'b00_1001,
					SRAM_SRAM_ST0B		=	6'b00_1000,
					SRAM_SRAM_ST0C		=	6'b01_1000,
					SRAM_SRAM_ST0D		=	6'b01_1001,
					SRAM_SRAM_ST0E		=	6'b01_1011,
					SRAM_SRAM_ST0F		=	6'b01_1010,
					// Req CPU Bus
					SRAM_REQ_ST00		=	6'b01_1110,
					SRAM_REQ_ST01		=	6'b01_1111,
					// SRAM to VRAM 
					SRAM_FIFO_ST00		=	6'b01_1101,
					SRAM_FIFO_ST01		=	6'b01_1100,
					SRAM_FIFO_ST02		=	6'b01_0100,
					SRAM_FIFO_ST03		=	6'b01_0101,
					SRAM_FIFO_ST04		=	6'b01_0111,
					SRAM_FIFO_ST05		=	6'b01_0110,
					SRAM_FIFO_ST06		=	6'b01_0010,
					SRAM_FIFO_ST07		=	6'b01_0011,
					// VRAM to SRAM
					FIFO_SRAM_ST00		=	6'b01_0001,
					FIFO_SRAM_ST01		=	6'b01_0000,
					FIFO_SRAM_ST02		=	6'b11_0000,
					FIFO_SRAM_ST03		=	6'b11_0001,
					FIFO_SRAM_ST04		=	6'b11_0011,
					FIFO_SRAM_ST05		=	6'b11_0010,
					FIFO_SRAM_ST06		=	6'b11_0110,
					FIFO_SRAM_ST07		=	6'b11_0111,
					// IO Transfer

					IO_TRF_CTRL			=	6'b11_0101,
					// IO to SRAM					
					SRAM_IO_ST00		=	6'b11_0100,
					SRAM_IO_ST01		=	6'b11_1100,
					SRAM_IO_ST02		=	6'b11_1101,
					SRAM_IO_ST03		=	6'b11_1111,
					SRAM_IO_ST04		=	6'b11_1110,
					SRAM_IO_ST05		=	6'b11_1010,
					SRAM_IO_ST06		=	6'b11_1011,
					// SRAM to IO
					IO_SRAM_ST00		=	6'b11_1001,
					IO_SRAM_ST01		=	6'b11_1000,
					IO_SRAM_ST02		=	6'b10_1000,
					IO_SRAM_ST03		=	6'b10_1001,
					IO_SRAM_ST04		=	6'b10_1011,
					IO_SRAM_ST05		=	6'b10_1010,
					IO_SRAM_ST06		=	6'b10_1110,
					// Transaction End;					
					NO_OPERATION		=	6'b10_1111,
					END_GEN_INT			=	6'b10_1101,
					SRAM_ACK_ST00		=	6'b10_1100,
					SRAM_ACK_ST01		=	6'b10_0100,
					THE_END				=	6'b10_0101;


// Trigger the Beginning of the Transfer
reg	[1:0]		Fire_Transfer;
always @ (posedge CPU_Clk_i) begin
	if (Reset_i) begin
		Fire_Transfer <= 2'b00;
	end
	else begin
			Fire_Transfer[0] <= SDMA_REG[0][7];
			Fire_Transfer[1] <= Fire_Transfer[0];
		end
end
// Register Defines
reg	[1:0]	Load_Src_Addy;
reg	[1:0]	Load_Dst_Addy;


always @ (posedge CPU_Clk_i) begin
	if (Reset_i) begin
			StridePointerCounter      	<= 16'h0000; // This is the Value that needs to increment and compared to Y_Size
	end
	else begin
			case(SDMA_SM)

				SRAM_SRAM_ST06, SRAM_FIFO_ST03, FIFO_SRAM_ST03: 
				begin
					StridePointerCounter <= StridePointerCounter + 16'h0001;
				end

				SRAM_SRAM_ST00, SRAM_SRAM_ST0F, SRAM_FIFO_ST00, FIFO_SRAM_ST00: 
				begin
					StridePointerCounter	<= 16'h0000;
				end
			endcase
	end
end

reg CPU_SDMA_Bus_RW;

always @ (posedge CPU_Clk_i) begin
	if (Reset_i) begin
			SDMA_SM							<= IDLE;
			SDMA_SM_SM 						<= IDLE;
			// VRAM Side
			CPU_SDMA_Bus_Reqn_o			<= 1'b1;	// THis pin needs to 1 at all time from the very beginning till we need to take control
			CPU_SDMA_Bus_RW				<= 1'b1;
			Src_Counter_Enable			<= 1'b0;
			Dst_Counter_Enable			<= 1'b0;
			Src_VDMA_Count_Enable		<= 1'b0;
			Dst_VDMA_Count_Enable		<= 1'b0;
			FIFO_Output_Clear_o			<= 1'b0;
	end
	else begin
		// Cool Slipping Bit to Enable the Load
		Load_Src_Addy <= Load_Src_Addy << 1'b1;
		Load_Dst_Addy <= Load_Dst_Addy << 1'b1;
	
		case(SDMA_SM)
		
		IDLE: begin 
			if ( SDMA_REG[0][0] && (Fire_Transfer[1:0] == 2'b01) ) begin
				SDMA_SM <= VALIDATE0;
			end
			else begin
				SDMA_SM <= IDLE;
			end
		end

		VALIDATE0: begin
			FIFO_Output_Clear_o <= 1'b1;
			SDMA_SM <= VALIDATE1;
		end

		VALIDATE1: begin 
			SDMA_SM <= VALIDATE2;
		end
/*
	SDMA_CONTROL_REG0       = $AF0420
		; Bit Field Definition
		SDMA_CTRL0_Enable       = $01
		SDMA_CTRL0_1D_2D        = $02     ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
		SDMA_CTRL0_TRF_Fill     = $04     ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
		SDMA_CTRL0_Int_Enable   = $08     ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
		SDMA_CTRL0_SysRAM_Src   = $10     ; Set to 1 to Indicate that the Source is the SRAM -> VRAM
		SDMA_CTRL0_SysRAM_Dst   = $20     ; Set to 1 to Indicate that the Destination is VRAM -> SRAM
		SDMA_CTRL0_Undefined		= $40		 ;
		SDMA_CTRL0_Start_TRF    = $80     ; Set to 1 To Begin Process, Need to Cleared before, you can start another

	SDMA_CONTROL_REG1       = $AF0421
		SDMA_CTRL1_IO_Src			= $01		 ; 1 = Source is an IO Address (ADC, SuperIO, IDE)
		SDMA_CTRL1_IO_Src16		= $02		 ; 0 = Src 8Bits Transfer / 1= 16Bits Transfer
		SDMA_CTRL1_IO_Dst			= $04		 ; 1 = Destination is an IO Address (DAC, SuperIO, IDE)
		SDMA_CTRL1_IO_Dst16     = $08     ; 0 = Dst 8bits Transfer / 1= 16bits
*/		
		
		VALIDATE2: begin
			FIFO_Output_Clear_o <= 1'b0;
			Load_Src_Addy	<= 2'b11; 	// Load Source Address
			Load_Dst_Addy	<= 2'b11; 	// Load Destination Address			
			case( SDMA_REG[0][5:4])
			2'b00: begin SDMA_SM <= SRAM_REQ_ST00; SDMA_SM_SM <= SRAM_SRAM_ST00; end		// SRAM to SRAM - 1D/2D/FILL 	
			2'b01: begin SDMA_SM <= SRAM_REQ_ST00; SDMA_SM_SM <= SRAM_FIFO_ST00; end		// SRAM to FIFO - 1D/2D
			2'b10: begin SDMA_SM <= SRAM_REQ_ST00; SDMA_SM_SM <= FIFO_SRAM_ST00; end		// VRAM to FIFO - 1D/2D/FILL 	
			2'b11: begin SDMA_SM <= SRAM_REQ_ST00; SDMA_SM_SM <= IO_TRF_CTRL; 	end		// IO_TRANSFER  - 1D/2D 		-> SRAM @100Mbyte/Sec
			default: begin	SDMA_SM <= END_GEN_INT; end
			endcase
		end

		//////////////////////////////////////////
		// VRAM to VRAM
		//////////////////////////////////////////			
		// VRAM Internal Transfer 1D/2D/Fill
		SRAM_SRAM_ST00: begin 
	
			if (SDMA_REG[0][1]) begin
					SDMA_SM_SM 		<= SRAM_SRAM_ST06; 				
			end
			else begin
					SDMA_SM_SM 		<= SRAM_SRAM_ST0F;
			end


			if (SDMA_REG[0][2]) begin
					SDMA_SM 			<= SRAM_SRAM_ST04;			
			end
			else begin
					SDMA_SM 			<= SRAM_SRAM_ST01; 
			end
	
		end

// Sram to Sram - 1D 
		// Read Byte - Increment 1
		SRAM_SRAM_ST01: begin 
			if (SDMA_Dst_Cntr_Reached_Count) begin
				CPU_SDMA_Bus_RW	 	<= 1'b1;		// Go Read First
				Src_Counter_Enable	<= 1'b0;
				Dst_Counter_Enable   <= 1'b0;
				SDMA_SM <= SDMA_SM_SM;
			end
			else begin		
				CPU_SDMA_Bus_RW	 	<= 1'b1;		// Go Read First
				Dst_Counter_Enable   <= 1'b0;
				Src_Counter_Enable	<= 1'b1;					
				//if ( OneWaitState_Read_Zone ) begin
//					SDMA_SM <= SRAM_SRAM_ST03;
				//end
				//else begin
					SDMA_SM <= SRAM_SRAM_ST02;				
			//	end
			end
		end
		
		// The Byte has been Read - Here;
		SRAM_SRAM_ST02: begin 
				CPU_SDMA_Bus_RW	 	<= 1'b0;		// Go Read First
				Src_Counter_Enable	<= 1'b0;
				Dst_Counter_Enable   <= 1'b1;				
				SDMA_SM <= SRAM_SRAM_ST01;
		end
	

		// Will keep that state for later introduce a Ready Delay in the Read
		// Wait 
		// OneWaitState_Read_Zone = $AF:XXXX Zone gets 1 Wait State
		//SRAM_SRAM_ST03: begin 
				//Src_Counter_Enable	<= 1'b0;		
				//SDMA_SM <= SRAM_SRAM_ST02;		
		//end
//
// Fill 1D Here
		SRAM_SRAM_ST04: begin 
			CPU_SDMA_Bus_RW	 	<= 1'b0;		// Go Read Firstend	// 1D - FILL
			Dst_Counter_Enable   <= 1'b1;
			SDMA_SM <= SRAM_SRAM_ST05;
		end

		SRAM_SRAM_ST05: begin 
			if (SDMA_Dst_Cntr_Reached_Count) begin
				CPU_SDMA_Bus_RW		<= 1'b1;		// Go Read First
				Src_Counter_Enable	<= 1'b0;
				Dst_Counter_Enable   <= 1'b0;
				SDMA_SM <= SDMA_SM_SM;			
			end
			else begin
				SDMA_SM <= SRAM_SRAM_ST05;
			end
		end
		
// Transfer 2D
		SRAM_SRAM_ST06: begin
			SDMA_SM <= SRAM_SRAM_ST07;
		end
		// the Value is StridePointerCounter is updated here
		// But the MATH Mult takes 1 Clock to Computer
		SRAM_SRAM_ST07: begin 
			if (StridePointerCounter == SDMA_Y_Size) begin
				SDMA_SM 			<= SRAM_SRAM_ST0F;	// if we get here the overall transfer is done
			end
			else begin
				SDMA_SM 			<= SRAM_SRAM_ST08;		
			end
		end

		SRAM_SRAM_ST08: begin 
			SDMA_SM_SM 				<= SRAM_SRAM_ST06;			
			if (SDMA_REG[0][2]) begin
				Load_Dst_Addy			<= 2'b10; 	// Load Destination Address			
				SDMA_SM 					<= SRAM_SRAM_ST04;
			end
			else begin
				Load_Src_Addy			<= 2'b10; 	// Load Source Address
				Load_Dst_Addy			<= 2'b10; 	// Load Destination Address					
				SDMA_SM 					<= SRAM_SRAM_ST01;
			end

		end
		
/*				
		SRAM_SRAM_ST09: begin

		end


		SRAM_SRAM_ST0A: begin 
			SDMA_SM <= SRAM_SRAM_ST0A;	
		end
		
		SRAM_SRAM_ST0B: begin 
				SDMA_SM <= SRAM_SRAM_ST04;	// if we haven't finish the Transfer go do another batch of read and write
		end
			
		SRAM_SRAM_ST0C: begin 
			SDMA_SM <= SRAM_SRAM_ST0D;
		end

		SRAM_SRAM_ST0D: begin 

		end
		// Transaction Termination
		SRAM_SRAM_ST0E: begin 
			VRAM2VRAM_Enable				<= 1'b0;	// Turn off the VRAM to VRAM
			SDMA_SM 						<= SRAM_SRAM_ST0F;
		end
*/		
		SRAM_SRAM_ST0F: begin 
			SDMA_SM 				<= SRAM_ACK_ST00;
			SDMA_SM_SM			<= IDLE;
		end

		//////////////////////////////////////////
		// ACQUIRE THE MAIN BUS for DMA TRANSACTION
		//////////////////////////////////////////		
		// Req CPU Bus
		// We are obviously assuming that the bus is not already taken by another device
		// if the code is being ran and have trigger the beginning of the transfer
		SRAM_REQ_ST00: begin 
			CPU_SDMA_Bus_Reqn_o 	<= 1'b0;
			SDMA_SM 				<= SRAM_REQ_ST01;
		end

		// Wait for the Actn to go low
		SRAM_REQ_ST01: begin 
			if (CPU_SDMA_Bus_Ackn_i) begin
				SDMA_SM <= SRAM_REQ_ST01;
			end
			else begin
				SDMA_SM <= SDMA_SM_SM;	
			end
		end

//////////////////////////////////////////
// SRAM to FIFO
//////////////////////////////////////////

		SRAM_FIFO_ST00: begin	
			CPU_SDMA_Bus_RW	 		<= 1'b1;		// Go Start the Reading		
			if (SDMA_REG[0][1]) begin
					SDMA_SM_SM 		<= SRAM_FIFO_ST03; 				
			end
			else begin
					SDMA_SM_SM 		<= SRAM_SRAM_ST0F;
			end
			SDMA_SM <= SRAM_FIFO_ST01;
		end

		SRAM_FIFO_ST01: begin
			Src_VDMA_Count_Enable	<= 1'b1;		// Dedicated Enable Line, so it doesn't interfere with other modes
			SDMA_SM <= SRAM_FIFO_ST02;				
		end

		SRAM_FIFO_ST02: begin
			if (SDMA_Src_Cntr_Reached_Count) begin
				Src_VDMA_Count_Enable	<= 1'b0;
				SDMA_SM <= SDMA_SM_SM;
			end
			else begin
				SDMA_SM <= SRAM_FIFO_ST02;
			end
		end

		// Increment the Stride Count
		SRAM_FIFO_ST03: begin 
			SDMA_SM <= SRAM_FIFO_ST04;
		end

		SRAM_FIFO_ST04: begin
			if (StridePointerCounter == SDMA_Y_Size) begin
				SDMA_SM 	<= SRAM_SRAM_ST0F;	// if we get here the overall transfer is done
			end
			else begin
				SDMA_SM <= SRAM_FIFO_ST05;		
			end		
		end

		SRAM_FIFO_ST05: begin
			SDMA_SM_SM 			<= SRAM_FIFO_ST03;			
			Load_Src_Addy		<= 2'b10; 	// Load Source Address
			SDMA_SM 				<= SRAM_FIFO_ST01;
		end

/*
		SRAM_FIFO_ST06: begin
			SDMA_SM <= SRAM_FIFO_ST07;
		end

		SRAM_FIFO_ST07: begin
			SDMA_SM <= END_GEN_INT;
		end
*/
//////////////////////////////////////////
// FIFO to SRAM
//////////////////////////////////////////

		FIFO_SRAM_ST00: begin
			CPU_SDMA_Bus_RW	<= 1'b1;		// Go Start the Reading
			
			if (SDMA_REG[0][1]) begin
					SDMA_SM_SM 		<= FIFO_SRAM_ST03; 				
			end
			else begin
					SDMA_SM_SM 		<= SRAM_SRAM_ST0F;
			end
			SDMA_SM <= FIFO_SRAM_ST01;
		end

		FIFO_SRAM_ST01: begin
			Dst_VDMA_Count_Enable	<= 1'b1;		// Dedicated Enable Line, so it doesn't interfere with other modes
			SDMA_SM <= FIFO_SRAM_ST02;
		end

		FIFO_SRAM_ST02: begin
			if (SDMA_Dst_Cntr_Reached_Count) begin
				Dst_VDMA_Count_Enable	<= 1'b0;
				SDMA_SM <= SDMA_SM_SM;
			end
			else begin
				SDMA_SM <= FIFO_SRAM_ST02;
			end		
		end

		FIFO_SRAM_ST03: begin
			SDMA_SM <= FIFO_SRAM_ST04;
		end

		FIFO_SRAM_ST04: begin
			if (StridePointerCounter == SDMA_Y_Size) begin
				SDMA_SM 	<= SRAM_SRAM_ST0F;	// if we get here the overall transfer is done
			end
			else begin
				SDMA_SM <= FIFO_SRAM_ST05;		
			end		

		end

		FIFO_SRAM_ST05: begin
			SDMA_SM_SM 			<= FIFO_SRAM_ST03;			
			Load_Dst_Addy		<= 2'b10; 	// Load Source Address
			SDMA_SM 				<= FIFO_SRAM_ST01;
		end
/*
		FIFO_SRAM_ST06: begin
			SDMA_SM <= FIFO_SRAM_ST07;
		end

		FIFO_SRAM_ST07: begin
			SDMA_SM <= END_GEN_INT;
		end
*/
//////////////////////////////////////////
// Io TRANSFER Control
//////////////////////////////////////////

		IO_TRF_CTRL: begin
			SDMA_SM <= SRAM_ACK_ST00;
//			SDMA_SM <= SRAM_IO_ST00;
			
		end
//////////////////////////////////////////
// SRAM to IO
//////////////////////////////////////////
/*
		SRAM_IO_ST00: begin
			SDMA_SM <= SRAM_IO_ST01;
		end

		SRAM_IO_ST01: begin
			SDMA_SM <= SRAM_IO_ST02;
		end

		SRAM_IO_ST02: begin 
			SDMA_SM <= SRAM_IO_ST03;
		end

		SRAM_IO_ST03: begin 
			SDMA_SM <= SRAM_IO_ST04;
		end

		SRAM_IO_ST04: begin
			SDMA_SM <= SRAM_IO_ST05;
		end

		SRAM_IO_ST05: begin
			SDMA_SM <= SRAM_IO_ST06;
		end

		SRAM_IO_ST06: begin
			SDMA_SM <= END_GEN_INT;
		end
*/
//////////////////////////////////////////
// IO to SRAM
//////////////////////////////////////////
/*
		IO_SRAM_ST00: begin
			SDMA_SM <= IO_SRAM_ST01;
		end

		IO_SRAM_ST01: begin
			SDMA_SM <= IO_SRAM_ST02;
		end

		IO_SRAM_ST02: begin
			SDMA_SM <= IO_SRAM_ST03;
		end

		IO_SRAM_ST03: begin 
			SDMA_SM <= IO_SRAM_ST04;
		end

		IO_SRAM_ST04: begin 
			SDMA_SM <= IO_SRAM_ST05;
		end

		IO_SRAM_ST05: begin
			SDMA_SM <= IO_SRAM_ST06;
		end

		IO_SRAM_ST06: begin
			SDMA_SM <= END_GEN_INT;
		end

*/
//////////////////////////////////////////
// Interrupt Generation
//////////////////////////////////////////		
		END_GEN_INT: begin
			SDMA_SM <= IDLE;
		end
		
//////////////////////////////////////////
// RELEASE THE MAIN BUS
//////////////////////////////////////////
// WHen CPU BUS is used and things needs to go back to normal
		// 0x2D
		SRAM_ACK_ST00: begin
			CPU_SDMA_Bus_Reqn_o <= 1'b1;	
			SDMA_SM <= SRAM_ACK_ST01;
		end 
		//0x2C
		SRAM_ACK_ST01: begin 
			if (CPU_SDMA_Bus_Ackn_i) begin
				SDMA_SM <= END_GEN_INT;
			end
			else begin
				SDMA_SM <= SRAM_ACK_ST01;
			end
		end

		//0x25
		THE_END: begin 
			SDMA_SM <= SDMA_SM_SM;		
		end

		default: begin 

		end

		endcase
	end
end


















endmodule

//Code Boneyard

/*
input		wire				CPU_Counter_Enable_i,		// This is the Start
input		wire				CPU_Counter_Load_i,
output	wire				CPU_Counter_Reached_Count_o, 

input		wire	[23:0]	CPU_Target_Addy_Start_i,
input		wire	[23:0]	CPU_Target_Addy_Stop_i,
input		wire				CPU_Target_RW14Mhz_i,		// Read or Write 
input		wire				CPU_Target_RW100Mhz_i,
input		wire	[7:0]		CPU_Target_VRAM_Data_i,
input		wire				CPU_Target_VRAM_Data_Valid_i,
input		wire				CPU_FIFO_Read_i,
output	wire				CPU_FIFO_Empty_o,

input		wire	[7:0]		CPU_FILL_Data_i,
input		wire				CPU_FILL_SRAM_Enable_i,

output	wire	[7:0]		CPU_DataInputChannel_o,
output	wire				CPU_Data_Output_Valid_o,

output	wire				SDMA_Counter_Enable_FiFo_Wr_Full_o,
*/


//assign CPU_Counter_Reached_Count_o = CPU_Compare_Condition_AEB;
/*
reg CPU_Counter_Reached_Count_ReSync;

always @ (posedge EngineClk100Mhz_i)
begin
	CPU_Counter_Reached_Count_ReSync <= CPU_Compare_Condition_AEB;
	CPU_Counter_Reached_Count_o <= CPU_Counter_Reached_Count_ReSync;
end
*/

//reg CPU_Data_Output_Valid_Dly;
/*
reg CPU_Data_Output_Valid;

always @ (posedge CPU_Clk_i)
begin
	CPU_Data_Output_Valid <= (CPU_Counter_Enable_ReSync2 & CPU_Compare_Condition_ALB);
	//CPU_Data_Output_Valid <= CPU_Data_Output_Valid_Dly;
end

reg [7:0] Data_Valid;

always @ (posedge CPU_Clk_i)
begin
	Data_Valid 	<= CPU_SDMA_D_In_i;
end
*/
/*
wire [139:0] ChipScope;
wire			Trigger;

//assign Trigger = !Data_Valid;
assign Trigger = CPU_Counter_Enable_i;


ChipScope	ChipScope_inst (
	.acq_clk ( CPU_Clk_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

// This is the Signal Driving the Input Side of the DP Memory
//assign ChipScope[23:0] 		= CPU_SDMA_A_o;
assign ChipScope[23:0] 		= CPU_SDMA_A_o;
assign ChipScope[31:24] 	= CPU_SDMA_D_Out_o;
assign ChipScope[39:32] 	= CPU_SDMA_D_In_i;
assign ChipScope[40] 		= CPU_SDMA_Bus_RW_o;

assign ChipScope[64:41] 	= CPU_Target_Addy_Start_ReSync1;
assign ChipScope[88:65] 	= CPU_Target_Addy_Stop_ReSync1;
assign ChipScope[89] 		= CPU_Target_RW_ReSync1;
assign ChipScope[97:90]		= CPU_Target_VRAM_Data_i;
//assign ChipScope[105:98]  	= CPU_DataInputChannel_o;
//assign ChipScope[106] 		= CPU_Data_Output_Valid_o;

assign ChipScope[107]		= CPU_Counter_Enable_ReSync2;
assign ChipScope[108]		= CPU_Counter_Load_ReSync1;
assign ChipScope[109]		= CPU_Counter_Reached_Count_o;

assign ChipScope[110]    	= CPU_Compare_Condition_AEB;
assign ChipScope[111] 		= CPU_Compare_Condition_AGEB;
assign ChipScope[112] 		= CPU_Compare_Condition_ANEB;

assign ChipScope[113]		= Debug0_i;
assign ChipScope[114]		= Debug1_i;
assign ChipScope[115] 		= Counter_Enable;
assign ChipScope[116] 		= Data_Valid;
assign ChipScope[117] 		= Data_Valid_Dly;
//assign ChipScope[115]		= rdempty;
*/ 
/*
ChipScope	ChipScope_inst (
	.acq_clk ( EngineClk100Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);
assign Trigger = CPU_Target_VRAM_Data_Valid_i;
// This is the Signal Driving the Input Side of the DP Memory
//assign ChipScope[23:0] 		= CPU_SDMA_A_o;
//assign ChipScope[23:0] 		= CPU_SDMA_A_o;
//assign ChipScope[31:24] 	= CPU_SDMA_D_Out_o;
//assign ChipScope[39:32] 	= CPU_SDMA_D_In_i;
//assign ChipScope[40] 		= CPU_SDMA_Bus_RW_o;

//assign ChipScope[64:41] 	= CPU_Target_Addy_Start_ReSync1;
//assign ChipScope[88:65] 	= CPU_Target_Addy_Stop_ReSync1;
//assign ChipScope[89] 		= CPU_Target_RW_ReSync1;
//assign ChipScope[97:90]		= CPU_Target_VRAM_Data_i;
assign ChipScope[105:98]  	= CPU_Target_VRAM_Data_i;
assign ChipScope[106] 		= CPU_Target_VRAM_Data_Valid_i;

//assign ChipScope[107]		= CPU_Counter_Enable_i;
//assign ChipScope[108]		= CPU_Counter_Load_i;
//assign ChipScope[109]		= CPU_Counter_Reached_Count_o;

assign ChipScope[119:110]    	= wrusedw;
*/

/*
wire 	[9:0]	wrusedw;
wire	Data_Valid;
wire	[8:0] CPU_SDMA_D_Out;

// it is not 8bits, it is 9bits
VGE_2_CPU_FIFO8_2_8	WriteSRAM_ReadVRAM (
	.aclr ( Reset_i ),
	
	//
	.rdreq ( 1'b1 ),
	.rdclk ( CPU_Clk_i ),
	.q ( CPU_SDMA_D_Out ),
	.rdempty ( Data_Valid ),	
	
	// Incoming Data From VRAM to be written in SRAM
	.data ( {1'b0, CPU_Target_VRAM_Data_i} ),
	.wrclk ( EngineClk100Mhz_i ),
	.wrreq ( CPU_Target_VRAM_Data_Valid_i & !CPU_Target_RW100Mhz_i),
	.wrfull (  ),
	.wrusedw ( wrusedw )
);

assign SDMA_Counter_Enable_FiFo_Wr_Full_o = (wrusedw < 10'd1012) ? 1'b1 : 1'b0;

assign CPU_SDMA_D_Out_o = CPU_FILL_SRAM_Enable_i ? CPU_FILL_Data_i[7:0] : CPU_SDMA_D_Out[7:0];

wire rdempty;
wire [8:0] FIFODataOut;
wire wrfull;

assign CPU_Data_Output_Valid_o = !CPU_FIFO_Empty_o;

VGE_2_CPU_FIFO8_2_8	ReadSRAM_WriteVRAM (
	.aclr ( Reset_i ),
	// Outgoing Data to VRAM
	.rdreq ( CPU_FIFO_Read_i ),
	.rdclk ( EngineClk100Mhz_i ),
	.q ( FIFODataOut ),
	.rdempty ( CPU_FIFO_Empty_o ),	
	
	// Incoming Data from SRAM Bus
	.data ( {CPU_Compare_Condition_AEB, CPU_SDMA_D_In_i} ),
	.wrclk ( CPU_Clk_i ),
	.wrreq ( CPU_Target_RW14Mhz_i ? (CPU_Counter_Enable_ReSync2 & CPU_Compare_Condition_ALB ) : 1'b0),
	.wrfull ( wrfull ),
	.wrusedw( )	
	);

assign CPU_DataInputChannel_o = FIFODataOut[7:0];
assign CPU_Counter_Reached_Count_o = CPU_Target_RW100Mhz_i ? FIFODataOut[8] : CPU_Compare_Condition_AEB_ReSync[1];


reg	[1:0] CPU_Compare_Condition_AEB_ReSync;

always @ (posedge EngineClk100Mhz_i) 
begin
	CPU_Compare_Condition_AEB_ReSync[0] <= CPU_Compare_Condition_AEB;
	CPU_Compare_Condition_AEB_ReSync[1] <= CPU_Compare_Condition_AEB_ReSync[0];
end
//assign CPU_SDMA_D_Out_o = CPU_Target_VRAM_Data_i;

assign CS_VKYIIn_o = (CPU_SDMA_A_o[23:21] == 3'b001) ? 1'b1 : 1'b0;		// This bit chose RAM0 or RAM1

wire Counter_Enable;

assign Counter_Enable = CPU_Target_RW14Mhz_i ? ( CPU_Counter_Enable_ReSync2 & CPU_Compare_Condition_ALB) : CPU_FILL_SRAM_Enable_i ? ( CPU_Counter_Enable_ReSync2 & CPU_Compare_Condition_ALB) : !Data_Valid_Dly;

wire	[23:0]	Temp_Address_Out;
// 24BitAddress Address (Counter of Int (1bytes))
ADDY_COUNTER	ADDY_COUNTER_inst (
	.aclr ( Reset_i ),
	.clk_en ( 1'b1 ),
	.clock ( CPU_Clk_i ),
	.cnt_en ( Counter_Enable ),
	.data ( CPU_Target_Addy_Start_i ),
	.sload ( CPU_Counter_Load_ReSync1 ),
	.updown ( 1'b1 ),		// 1= Up, 0= Down
	.q ( CPU_SDMA_A_o )							// Directly drive the VRAM Address
);

assign CPU_SDMA_Bus_RW_o = Counter_Enable ? CPU_FILL_SRAM_Enable_i ? 1'b0 : Data_Valid_Dly : 1'b1;

wire CPU_Compare_Condition_AEB;
wire CPU_Compare_Condition_AGEB;
wire CPU_Compare_Condition_ALB;
wire CPU_Compare_Condition_ANEB;

ADDY_COMPARE ADDY_COMP_ADDYs (
	.dataa( CPU_SDMA_A_o ),
	.datab( CPU_Target_Addy_Stop_i ),
	.aeb( CPU_Compare_Condition_AEB ),		// A == B
	.ageb( CPU_Compare_Condition_AGEB ),		// A != B
	.alb( CPU_Compare_Condition_ALB ),		// A < B
	.aneb( CPU_Compare_Condition_ANEB )		// A >= B
);
*/