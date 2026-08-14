`timescale 1ns/1ns
module C256Foenix_VDMA_Controller(
input		wire				EngineClk100Mhz_i,	// Main Clock to Drive the Local Memory and VideoMemory
input		wire				Reset_100Mhz_i,
//CPU Interface
input		wire				Reset_i,
input		wire				Bus_Clk_i,
input		wire	[23:0]	Bus_A_i,
input		wire				Bus_RW_i,
input		wire				Bus_RDY_i,
output	wire				Bus_RDY_o,
input		wire	[7:0]		Bus_D_i,
output 	wire	[7:0]		Bus_D_o,
input		wire				CS_VDMA_Controller_i,

// Register Level that have been Synched with 100Mhz Clock already
output	wire				VDMA_Interrupt_o,

// 14Mhz Interface Clock Domain
// Input FIFO Interface from the VDMA Controller	
output	wire	[7:0]		FIFO_Input_Channel_o,
input		wire				FIFO_Input_Read_i,
output	wire	[9:0]		FIFO_Input_Count_o,
output	wire				FIFO_Input_Empty_o,
// 14Mhz Interface Clock Domain
// Output FIFO Interface to  the VDMA Controller
input		wire				FIFO_Output_Clear_i,
input		wire	[7:0]		FIFO_Output_Channel_i, 
input		wire				FIFO_Output_Write_i,
output	wire	[9:0]		FIFO_Output_Count_o,
output	wire				FIFO_OUtput_Full_o,
// VDMA Channel
output	reg	[21:0]	VDMA_Src_Addy_Start_o,
output	reg	[21:0]	VDMA_Src_Addy_Stop_o,
output	wire 				VDMA_Src_Addy_Load_o,
output	wire				VDMA_Src_Addy_Enable_o,
input		wire				VDMA_Src_Count_Reached_i,

output	reg	[21:0]	VDMA_Dst_Addy_Start_o,	// Byte Oriented
output	reg	[21:0]	VDMA_Dst_Addy_Stop_o,		// Byte Oriented
output	wire				VDMA_Dst_Addy_Load_o,
output	wire				VDMA_Dst_Addy_Enable_o,
input		wire				VDMA_Dst_Count_Reached_i,
	
output	wire				VDMA_Transaction_RW_o,
output	reg	[7:0]		VDMA_Transaction_Data_o,		// Byte Input
input		wire	[7:0]		VDMA_Transaction_Data_i,		// Byte Input

// Status with the Main VGE State Machine
output	reg				VDMA_Transfer_In_Progress_o,
input		wire				VDMA_Transfer_Time_Available_i
);

reg	Dst_FIFO_Counter_Enable;

assign VDMA_Src_Addy_Load_o 	= Load_Src_Addy;
assign VDMA_Dst_Addy_Load_o 	= Load_Dst_Addy;
assign VDMA_Src_Addy_Enable_o = VDMA_Control_Reg[5] ? Slide_Control_Write[0]		: Src_Counter_Enable;
assign VDMA_Dst_Addy_Enable_o = VDMA_Control_Reg[4] ? Dst_FIFO_Counter_Enable 	: Dst_Counter_Enable;
//assign VDMA_Transaction_RW_o 	= VDMA_Control_Reg_ReSync[4] ? !Dst_FIFO_Write_Enable    : VDMA_Transaction_RW;
assign VDMA_Transaction_RW_o 	= VDMA_Transaction_RW;



wire AlmostFull_Stop_Flag;
wire	[9:0] FIFO_Input_Count_i;
assign AlmostFull_Stop_Flag = (FIFO_Input_Count_i < 10'd1016) ? 1'b1 : 1'b0;

/*
wire	[7:0]		FIFO_VDMA_Data_Write;
reg				FIFO_VDMA_Write_Strobe;
wire				FIFO_VDMA_Full_Status;
*/

//assign FIFO_Input_Channel_o = 8'h00;
//assign FIFO_Input_Empty_o = 1'b1;
//assign FIFO_OUtput_Full_o = 1'b0;
 
 // Wires
wire	[7:0]		VDMA_Control_Reg; 
wire	[7:0]		VDMA_Data_2_Write;
wire	[23:0]	VDMA_Src_Addy;
wire	[23:0]	VDMA_Dst_Addy;
wire	[15:0]	VDMA_X_Size;
wire	[15:0]	VDMA_Y_Size;
wire	[15:0]	VDMA_Src_Stride;
wire	[15:0]	VDMA_Dst_Stride;

wire	[7:0]		VDMA_Status_Reg;

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

// Registers

// INTERRUPT AND STATUS CIRCUIT
reg 	[1:0] 	Interrupt_Generation_ReSync;
reg 	[2:0] 	VDMA_Status_Progress_ReSync;

reg	[15:0]	StridePointerCounter;
reg   			VDMA_Status_Progress;

//reg				Begin_Transfer;
reg				Termination_Feedback;

// REGISTER BLOCK
VDMA_Register_Block_RevB VDMA_Register_Block(
// General Clock & Reset
	.Reset_i( Reset_i ),
	.Reset_100Mhz_i( Reset_100Mhz_i ), 
// RESYNC Clock
	.EngineClk100Mhz_i( EngineClk100Mhz_i ),
// CPU Interface
	.Bus_Clk_i( Bus_Clk_i ),
// Interface to the 14Mhz Clock to Read and Write the VDMA Register Block
	.Bus_A_i( Bus_A_i ),
	.Bus_RW_i( Bus_RW_i ),
	.Bus_RDY_i( Bus_RDY_i ),
	.Bus_RDY_o( Bus_RDY_o ),
	.Bus_D_i( Bus_D_i ),
	.Bus_D_o( Bus_D_o ),
	.CS_VDMA_Controller_i( CS_VDMA_Controller_i ),
	
// Registers Output (Conditioned with 100Mhz Clock)
	.VDMA_Control_Reg_o( VDMA_Control_Reg ),
	.VDMA_Data_2_Write_o( VDMA_Data_2_Write ),
	.VDMA_Src_Addy_o( VDMA_Src_Addy ),
	.VDMA_Dst_Addy_o( VDMA_Dst_Addy ),
	.VDMA_X_Size_o( VDMA_X_Size ),
	.VDMA_Y_Size_o( VDMA_Y_Size ),
	.VDMA_Src_Stride_o( VDMA_Src_Stride ),
	.VDMA_Dst_Stride_o( VDMA_Dst_Stride ),
	
//Staus
	.VDMA_Status_Reg_i( VDMA_Status_Reg )
);

// 14Mhz Interrupt Generation
always @ (posedge Bus_Clk_i)
begin
	// Resync in 14Mhz Space for Int
	Interrupt_Generation_ReSync[0] <= Interrupt_Generation[15];
	Interrupt_Generation_ReSync[1] <= Interrupt_Generation_ReSync[0];
	// Resync in 14Mhz Space for In Progress
	VDMA_Status_Progress_ReSync[0] <= VDMA_Status_Progress;
	VDMA_Status_Progress_ReSync[1] <= VDMA_Status_Progress_ReSync[0];
	if ( VDMA_Status_Progress_ReSync[1] == VDMA_Status_Progress_ReSync[0]) 
			VDMA_Status_Progress_ReSync[2] <= VDMA_Status_Progress_ReSync[1];
end

assign VDMA_Interrupt_o = Interrupt_Generation_ReSync[1];
assign VDMA_Status_Reg = {VDMA_Status_Progress_ReSync[2], 7'b000_0000};
// 100Mhz Interrupt Generation
reg	[15:0]	Interrupt_Generation;

always @ (posedge EngineClk100Mhz_i) begin
	if (Reset_100Mhz_i) begin
		Interrupt_Generation <= 16'h0000;
	end
	else begin
		Interrupt_Generation <= Interrupt_Generation << 1'b1;
		if (VDMA_Control_Reg[3]) begin
			if (VDMA_SM == END_GEN_INT) begin
				Interrupt_Generation <= 16'hFFFF;
			end
		end
	end
end


// Assignments on some intermediate value to be used in the Start/Stop Address Pointer
//assign Count1D 				= {VDMA_Y_Size[7:0], VDMA_X_Size} - 24'h00_0001;
assign Count1D 				= {VDMA_Y_Size[7:0], VDMA_X_Size};
assign SrcPlusCount1D 		= VDMA_Src_Addy + Count1D;
assign DstPlusCount1D 		= VDMA_Dst_Addy + Count1D;

assign SrcPlusStride			= VDMA_Src_Addy + ComputeStrideSource[23:0];
assign SrcPlusStridePlusX	= VDMA_Src_Addy + ComputeStrideSource[23:0] + {8'h00, VDMA_X_Size};

assign DstPlusStride			= VDMA_Dst_Addy + ComputeStrideDestination[23:0];
//assign SrcPlusStridePlusX	= VDMA_Src_Addy + ComputeStrideSource[23:0] + {8'h00, VDMA_X_Size} - 24'h00_0001;
//assign DstPlusStridePlusX	= VDMA_Dst_Addy + ComputeStrideDestination[23:0] + {8'h00, VDMA_X_Size} - 24'h00_0001;

assign DstPlusStridePlusX	= VDMA_Dst_Addy + ComputeStrideDestination[23:0] + {8'h00, VDMA_X_Size};


// Compute Stride for Source
DMA_MULT_BLK SourceStrideCompute(
	.clock( EngineClk100Mhz_i),
	.dataa( StridePointerCounter ),		// This Calculate the Stride in Between each X Begining 
	.datab( VDMA_Src_Stride ), 	// Number of line
	.result( ComputeStrideSource )	// The Output is in Tile Char, 
	);
	
// Compute Stride for Destination
DMA_MULT_BLK DestinationStrideCompute(
	.clock(EngineClk100Mhz_i),
	.dataa( StridePointerCounter ),		// This Calculate the Stride in Between each X Begining 
	.datab( VDMA_Dst_Stride ), 	// Number of line
	.result( ComputeStrideDestination )	// The Output is in Tile Char, 
	);	


always @ (posedge EngineClk100Mhz_i) begin
				// 1D/2D             // Transfer Style
	case ( {VDMA_Control_Reg[1], VDMA_Control_Reg[5:4]} )
		// 1D TRANSFER - Linear - (The Stride is ignored)
		3'b000: begin 
			// VRAM
			VDMA_Src_Addy_Start_o		<= VDMA_Src_Addy[21:0];
			VDMA_Src_Addy_Stop_o			<= SrcPlusCount1D[21:0];
			VDMA_Dst_Addy_Start_o		<= VDMA_Dst_Addy[21:0];
			VDMA_Dst_Addy_Stop_o			<= DstPlusCount1D[21:0];
		end
		
		3'b001: begin  
			// VRAM
			VDMA_Src_Addy_Start_o		<= 22'h00_0000;
			VDMA_Src_Addy_Stop_o			<= 22'h00_0000;
			VDMA_Dst_Addy_Start_o		<= VDMA_Dst_Addy[21:0];
			VDMA_Dst_Addy_Stop_o			<= DstPlusCount1D[21:0];			
		end
		
		3'b010: begin

			// VRAM
			VDMA_Src_Addy_Start_o		<= VDMA_Src_Addy[21:0];
			VDMA_Src_Addy_Stop_o			<= SrcPlusCount1D[21:0];
			VDMA_Dst_Addy_Start_o		<= 22'h00_0000;
			VDMA_Dst_Addy_Stop_o			<= 22'h00_0000;			
		end
		
		3'b011: begin
			VDMA_Src_Addy_Start_o		<= 22'h00_0000;
			VDMA_Src_Addy_Stop_o			<= 22'h00_0000;
			VDMA_Dst_Addy_Start_o		<= 22'h00_0000;
			VDMA_Dst_Addy_Stop_o			<= 22'h00_0000;			
		end
		
		// 2D TRANSFER (The Stride is Used)
		3'b100: begin
			VDMA_Src_Addy_Start_o		<= SrcPlusStride[21:0];
			VDMA_Src_Addy_Stop_o			<= SrcPlusStridePlusX[21:0];
			VDMA_Dst_Addy_Start_o		<= DstPlusStride[21:0];
			VDMA_Dst_Addy_Stop_o			<= DstPlusStridePlusX[21:0];			
		end
		
		3'b101: begin
			// VRAM
			VDMA_Src_Addy_Start_o		<= 22'h00_0000;
			VDMA_Src_Addy_Stop_o			<= 22'h00_0000;
			VDMA_Dst_Addy_Start_o		<= DstPlusStride[21:0];
			VDMA_Dst_Addy_Stop_o			<= DstPlusStridePlusX[21:0];					
		end
		
		3'b110: begin
			// VRAM
			VDMA_Src_Addy_Start_o		<= SrcPlusStride[21:0];
			VDMA_Src_Addy_Stop_o			<= SrcPlusStridePlusX[21:0];
			VDMA_Dst_Addy_Start_o		<= 22'h00_0000;
			VDMA_Dst_Addy_Stop_o			<= 22'h00_0000;				
		end
		
		3'b111: begin
			// VRAM
			VDMA_Src_Addy_Start_o		<= 22'h00_0000;
			VDMA_Src_Addy_Stop_o			<= 22'h00_0000;
			VDMA_Dst_Addy_Start_o		<= 22'h00_0000;
			VDMA_Dst_Addy_Stop_o			<= 22'h00_0000;				
		end
		default:  begin  
			// VRAM
			VDMA_Src_Addy_Start_o		<= 22'h00_0000;
			VDMA_Src_Addy_Stop_o			<= 22'h00_0000;
			VDMA_Dst_Addy_Start_o		<= 22'h00_0000;
			VDMA_Dst_Addy_Stop_o			<= 22'h00_0000;		
		end
	endcase
end


// Data Output to VRAM
always @ (*) begin
	casex({VDMA_Control_Reg[2], VDMA_Control_Reg[5:4]})
		3'b000: VDMA_Transaction_Data_o = VDMA_Transaction_Data_i;
		3'b001: VDMA_Transaction_Data_o = FIFO_VDMA_Data_Read;		// Writing within the VMEM itself
		3'b010: VDMA_Transaction_Data_o = 8'hFF; 		// FIFO Input
		3'b011: VDMA_Transaction_Data_o = 8'hFF;		// No IO Mode in the VDMA, so this ough to be considered an illegal choice
		3'b1xx: VDMA_Transaction_Data_o = VDMA_Data_2_Write;	// Fill Byte
		default: VDMA_Transaction_Data_o = 8'h00;
	endcase
end


wire 	[7:0]		FIFO_VDMA_Data_Read;
reg				FIFO_VDMA_Read_Strobe;
wire				FIFO_VDMA_Empty_Status;

//100Mhz Interface to Read from VRAM to Write SRAM
wire	[7:0]		FIFO_VDMA_Data_Write;
reg				FIFO_VDMA_Write_Strobe;
reg				FIFO_Write_Clear;

VDMA_VRAM2VRAM_FIFO	VDMA_2_SDMA (
	.aclr ( Reset_100Mhz_i | FIFO_Write_Clear ),
	
	.wrclk ( EngineClk100Mhz_i ),
	.wrreq ( Slide_Control_Write[1] ),	
	.wrfull (  ),
	.wrusedw ( FIFO_Input_Count_i ),
	.data ( VDMA_Transaction_Data_i ),	
	
	.rdclk ( Bus_Clk_i ),
	.rdreq ( FIFO_Input_Read_i ),
	.rdempty ( FIFO_Input_Empty_o ),
	.rdusedw ( FIFO_Input_Count_o ),
	.q ( FIFO_Input_Channel_o )
	);


// This FIFO Function works, although, it needs to be tested.
wire [9:0]	FIFO_VDMA_Data_Count;

// The output of this FIFO will be Saved in the VRAM
VDMA_VRAM2VRAM_FIFO	SDMA_2_VDMA (
	.aclr ( Reset_i | FIFO_Output_Clear_i ),
	.wrclk ( Bus_Clk_i ),
	.wrreq ( FIFO_Output_Write_i ),	
	.wrfull ( FIFO_OUtput_Full_o ),
	.wrusedw ( FIFO_Output_Count_o ),
	.data ( FIFO_Output_Channel_i ),	

	.rdclk ( EngineClk100Mhz_i ),
	.rdreq ( FIFO_VDMA_Read_Strobe ),
	.rdempty ( FIFO_VDMA_Empty_Status ),
	.rdusedw ( FIFO_VDMA_Data_Count ),	
	.q ( FIFO_VDMA_Data_Read )
	);

/*
wire [71:0] ChipScope;
wire			Trigger;

//assign Trigger = (VDMA_Control_Reg[0] & (Fire_Transfer[1:0] == 2'b01));
assign Trigger = VDMA_Control_Reg[0] & VDMA_Control_Reg[4] & VDMA_Transfer_Time_Available_i;  // & (FIFO_VDMA_Data_Count >= 10'd1000)
//assign Trigger = VDMA_Control_Reg[0] & VDMA_Control_Reg[4] & (FIFO_VDMA_Data_Count > 10'h340);

//assign Trigger = VDMA_Control_Reg[0] & VDMA_Control_Reg[4] & (StridePointerCounter == 16'd239);

//assign Trigger = FIFO_VDMA_Read_Strobe & VDMA_Dst_Addy_Enable_o;
//assign Trigger = ((StridePointerCounter == 16'd8) ? 1'b1 : 1'b0);

ChipScope	ChipScope_inst (
	.acq_clk ( EngineClk100Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

// This is the Signal Driving the Input Side of the DP Memory
// Signal that Drives the VRAM

assign ChipScope[23:0] 		= {8'h00, StridePointerCounter};		// I am more interested in what is going out than in.
assign ChipScope[31:24] 	= FIFO_VDMA_Data_Read;
assign ChipScope[32] 		= FIFO_VDMA_Empty_Status;	// Write //3'b010
assign ChipScope[33] 		= FIFO_VDMA_Read_Strobe;	// Advance
assign ChipScope[34]			= VDMA_Transfer_Time_Available_i;
assign ChipScope[35] 		= !VDMA_Dst_Count_Reached_i;
assign ChipScope[36] 		= 1'b0;
assign ChipScope[37]			= VDMA_Dst_Addy_Enable_o;
assign ChipScope[38]			= VDMA_Transfer_In_Progress_o;
assign ChipScope[39]			= VDMA_Transaction_RW_o;
assign ChipScope[45:40]		= VDMA_SM;
assign ChipScope[51:46]		= VDMA_SM_SM;
assign ChipScope[63:54] 	= FIFO_VDMA_Data_Count;
assign ChipScope[71:64]    = 0;
*/
//reg FIFO_VDMA_Data_Read_RDY;
//reg FIFO_VDMA_Data_Read_RDY_RDY;
/*
reg [2:0] Slide_Control;
reg [1:0] StateMachine_Read_Data;
	
always @ ( posedge EngineClk100Mhz_i) begin
	if ( Reset_i ) begin
		StateMachine_Read_Data <= 2'b00;
	end
	else begin
		Slide_Control <= Slide_Control << 1'b1;
		
		if (FIFO_VDMA_Read_Strobe) begin
		
			case (StateMachine_Read_Data)
				2'b00: begin
				if (!FIFO_VDMA_Empty_Status && VDMA_Transfer_Time_Available_i && VDMA_Transfer_In_Progress_o && !VDMA_Dst_Count_Reached_i) begin
					Slide_Control <= 3'b001;
					StateMachine_Read_Data <= 2'b01;
				end
				else begin
					StateMachine_Read_Data <= 2'b00;	
				end	
			end
			// 3'b010
			// Read Valid Here
			2'b01: begin
				StateMachine_Read_Data <= 2'b10;
			end
			// 3'b100
			// Latency
			2'b10: begin
				StateMachine_Read_Data <= 2'b11;	
			end
		
			// Write Here and move 1 Address
			2'b11: begin
				StateMachine_Read_Data <= 2'b00;		
			end
		
			default: begin
				StateMachine_Read_Data <= 2'b00;			
			end
		
			endcase
		end
		else begin
			StateMachine_Read_Data <= 2'b00;		
		end
	end
end

*/

reg [1:0] Slide_Control_Write;
reg [1:0] StateMachine_Write_Data;

// Read Memory to go write in FIFO
always @ ( posedge EngineClk100Mhz_i) begin
	if ( Reset_100Mhz_i ) begin
		StateMachine_Write_Data <= 2'b00;
	end
	else begin
		Slide_Control_Write <= Slide_Control_Write << 1'b1;
		
		case (StateMachine_Write_Data)
			2'b00: begin
			if (AlmostFull_Stop_Flag && FIFO_VDMA_Write_Strobe && VDMA_Transfer_Time_Available_i && !VDMA_Src_Count_Reached_i) begin
				Slide_Control_Write <= 2'b01;
				StateMachine_Write_Data <= 2'b01;
			end
			else begin
				StateMachine_Write_Data <= 2'b00;
			end	
		end
		// 2'b01
		// 001 (Write to the FIFO) - the First Data has been there since the beginning
		2'b01: begin
			StateMachine_Write_Data <= 2'b00;
		end
		/*
		// 2'b10
		// 010 (Enable the Counter + 1)
		2'b10: begin
			StateMachine_Write_Data <= 2'b00;	
		end
	
		// 100 (New Address Here)
		2'b11: begin
			StateMachine_Write_Data <= 2'b00;		
		end
		*/
		default: begin
			StateMachine_Write_Data <= 2'b00;			
		end
		
		endcase
	end
end


/*
; DMA Controller $AF0400 - $AF04FF
VDMA_CONTROL_REG        = $AF0400
; Bit Field Definition
VDMA_CTRL_Enable     [0]= $01
VDMA_CTRL_1D_2D      [1]= $02     ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
VDMA_CTRL_TRF_Fill   [2]= $04     ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
VDMA_CTRL_Int_Enable [3]= $08     ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
VDMA_CTRL_SysRAM_Src [4]= $10     ; Set to 1 to Access the System as the Source (This will Stop Program from executing)
VDMA_CTRL_SysRAM_Dst [5]= $20     ; Set to 1 to Access the System as the Destination (This will stop Program from executing)
                     [6]= $40     ; Not Defines
VDMA_CTRL_Start_TRF  [7]= $80     ; Set to 1 To Begin Process, Need to Cleared before, you can start another
*/
reg	[5:0]		VDMA_SM;
reg	[5:0]		VDMA_SM_SM;

localparam		IDLE					=	6'b00_0000,
					VALIDATE0			=	6'b00_0001,// Make Sure the Parameters are Valid
					VALIDATE1			=	6'b00_0011,
					VALIDATE2			=	6'b00_0010,
					// VRAM Internal Transfer in 1D/2D/Fill
					VRAM_VRAM_ST00		=	6'b00_0110,
					VRAM_VRAM_ST01		=	6'b00_0111,
					VRAM_VRAM_ST02		=	6'b00_0101,
					VRAM_VRAM_ST03		=	6'b00_0100,
					VRAM_VRAM_ST04		=	6'b00_1100,
					VRAM_VRAM_ST05		=	6'b00_1101,
					VRAM_VRAM_ST06		=	6'b00_1111,
					VRAM_VRAM_ST07		=	6'b00_1110,
					VRAM_VRAM_ST08		=	6'b00_1010,
					VRAM_VRAM_ST09		=	6'b00_1011,
					VRAM_VRAM_ST0A		=	6'b00_1001,
					VRAM_VRAM_ST0B		=	6'b00_1000,
					VRAM_VRAM_ST0C		=	6'b01_1000,
					VRAM_VRAM_ST0D		=	6'b01_1001,
					VRAM_VRAM_ST0E		=	6'b01_1011,
					VRAM_VRAM_ST0F		=	6'b01_1010,
					// SRAM to VRAM
					SRAM_VRAM_ST00		=	6'b01_1110,
					SRAM_VRAM_ST01		=	6'b01_1111,
					SRAM_VRAM_ST02		=	6'b01_1101,
					SRAM_VRAM_ST03		=	6'b01_1100,
					SRAM_VRAM_ST04		=	6'b01_0100,
					SRAM_VRAM_ST05		=	6'b01_0101,
					SRAM_VRAM_ST06		=	6'b01_0111,
					SRAM_VRAM_ST07		=	6'b01_0110,
					SRAM_VRAM_ST08		=	6'b01_0010,
					SRAM_VRAM_ST09		=	6'b01_0011,
					SRAM_VRAM_ST0A		=	6'b01_0001,
					SRAM_VRAM_ST0B		=	6'b01_0000,
					SRAM_VRAM_ST0C		=	6'b11_0000,
					SRAM_VRAM_ST0D		=	6'b11_0001,
					SRAM_VRAM_ST0E		=	6'b11_0011,
					SRAM_VRAM_ST0F		=	6'b11_0010,
					// VRAM to SRAM
					VRAM_SRAM_ST00		=	6'b11_0110,
					VRAM_SRAM_ST01		=	6'b11_0111,
					VRAM_SRAM_ST02		=	6'b11_0101,
					VRAM_SRAM_ST03		=	6'b11_0100,
					VRAM_SRAM_ST04		=	6'b11_1100,
					VRAM_SRAM_ST05		=	6'b11_1101,
					VRAM_SRAM_ST06		=	6'b11_1111,
					VRAM_SRAM_ST07		=	6'b11_1110,
					VRAM_SRAM_ST08		=	6'b11_1010,
					VRAM_SRAM_ST09		=	6'b11_1011,
					VRAM_SRAM_ST0A		=	6'b11_1001,
					VRAM_SRAM_ST0B		=	6'b11_1000,
					VRAM_SRAM_ST0C		=	6'b10_1000,
					VRAM_SRAM_ST0D		=	6'b10_1001,
					VRAM_SRAM_ST0E		=	6'b10_1011,
					VRAM_SRAM_ST0F		=	6'b10_1010,
					NOT_USED_ST0		=	6'b10_1110,
					NOT_USED_ST1		=	6'b10_1111,
					NOT_USED_ST2		=	6'b10_1101,
					END_GEN_INT			=	6'b10_1100,
					WAIT_2_TRF			=	6'b10_0100,
					THE_END				=	6'b10_0101;

					/*
wire [71:0] ChipScope;
wire			Trigger;

//assign Trigger = (VDMA_Control_Reg[0] & (Fire_Transfer[1:0] == 2'b01));
assign Trigger = VDMA_Control_Reg[0] & VDMA_Control_Reg[7] & VDMA_Transfer_Time_Available_i;
//assign Trigger = VDMA_Control_Reg[0] & VDMA_Control_Reg[4] & VDMA_Transfer_Time_Available_i;
//assign Trigger = VDMA_Control_Reg[0] & (SRAM_VRAM_ST00 == VDMA_SM);
//assign Trigger = FIFO_VDMA_Read_Strobe & VDMA_Dst_Addy_Enable_o;
//assign Trigger = ((StridePointerCounter == 16'd8) ? 1'b1 : 1'b0);

ChipScope	ChipScope_inst (
	.acq_clk ( EngineClk100Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

// This is the Signal Driving the Input Side of the DP Memory
// Signal that Drives the VRAM

assign ChipScope[23:0] 		= VDMA_Src_Addy;		// I am more interested in what is going out than in.
assign ChipScope[31:24] 	= VDMA_Control_Reg;
assign ChipScope[32] 		= VDMA_Transfer_Time_Available_i;	// Write //3'b010
assign ChipScope[33] 		= VDMA_Transfer_Time_Available_EDGE;	// Advance
assign ChipScope[34]			= FIFO_VDMA_Empty_Status;
assign ChipScope[35] 		= VDMA_Transfer_In_Progress_o;
assign ChipScope[36] 		= FIFO_Write_Clear;
assign ChipScope[37]			= VDMA_Status_Progress;
assign ChipScope[38]			= VDMA_Transaction_RW_o;
assign ChipScope[39]			= VDMA_Dst_Count_Reached_i;
assign ChipScope[45:40]		= VDMA_SM;
assign ChipScope[51:46]		= VDMA_SM_SM;
assign ChipScope[63:54] 	= FIFO_VDMA_Data_Count;
*/
/*
assign ChipScope[21:0] 		= VDMA_Src_Addy_Start_o;
assign ChipScope[43:22]		= VDMA_Src_Addy_Stop_o;
assign ChipScope[44] 		= VDMA_Src_Addy_Load_o;
assign ChipScope[45] 		= VDMA_Src_Addy_Enable_o;
assign ChipScope[46] 		= VDMA_Src_Count_Reached_i;
assign ChipScope[49:47] 	= {VDMA_Control_Reg_ReSync[1], VDMA_Control_Reg_ReSync[5:4]};
assign ChipScope[50]			= Slide_Control_Write[0];
assign ChipScope[51]			= Slide_Control_Write[1];
assign ChipScope[52] 		= VDMA_Transfer_In_Progress_o;
assign ChipScope[63:56] 	= VDMA_Transaction_Data_i;
*/


/*
wire [15:0] Probes;
wire [15:0] Sources;
SourceProbe	SourceProbe_inst (
	.probe ( Probes ),
	.source ( Sources )
	);
assign Probes[7:0] 		= VDMA_Control_Reg_ReSync;
assign Probes[15:8]  	= 1'b0;
*/

reg	[1:0]		Fire_Transfer;
always @ (posedge EngineClk100Mhz_i) begin
	if (Reset_100Mhz_i) begin
		Fire_Transfer <= 2'b00;
	end
	else begin
			Fire_Transfer[0] <= VDMA_Control_Reg[7];
			Fire_Transfer[1] <= Fire_Transfer[0];
		end
end

reg			Load_Src_Addy;
reg			Load_Dst_Addy;
reg			Src_Counter_Enable;
reg			Dst_Counter_Enable;
reg			VDMA_Transaction_RW;

always @ (posedge EngineClk100Mhz_i) begin
	if (Reset_100Mhz_i) begin
			VDMA_SM								<= IDLE;
			VDMA_SM_SM 							<= IDLE;
			VDMA_Transfer_In_Progress_o 	<= 1'b0;
			VDMA_Status_Progress				<= 1'b0;

			VDMA_Transaction_RW				<= 1'b1;
			Src_Counter_Enable				<= 1'b0;
			Dst_Counter_Enable				<= 1'b0;
		
			FIFO_VDMA_Write_Strobe			<= 1'b0;
			FIFO_VDMA_Read_Strobe			<= 1'b0;
			
			FIFO_Write_Clear					<= 1'b0;
			StridePointerCounter				<= 16'h0000;
			
			Dst_FIFO_Counter_Enable			<= 1'b0;

	end
	else begin

		case(VDMA_SM)
		
		IDLE: begin 
			if ( VDMA_Control_Reg[0] && (Fire_Transfer[1:0] == 2'b01) ) begin
				VDMA_SM <= VALIDATE0;
				FIFO_Write_Clear 		<= 1'b1;
				VDMA_Status_Progress	<= 1'b1;				
			end
			else
				VDMA_SM <= IDLE;
		end

		VALIDATE0: begin
			VDMA_SM <= VALIDATE1;
		end

		VALIDATE1: begin 
			VDMA_SM <= VALIDATE2;
		end
		
		VALIDATE2: begin
			FIFO_Write_Clear 	<= 1'b0;
			case( VDMA_Control_Reg[5:4])
			2'b00: begin VDMA_SM <= WAIT_2_TRF; VDMA_SM_SM <= VRAM_VRAM_ST00; VDMA_Transfer_In_Progress_o <= 1'b1; end		// VRAM to VRAM - 1D/2D/FILL 	-> VRAM @50Mbyte/Sec 
			2'b01: begin VDMA_SM <= WAIT_2_TRF; VDMA_SM_SM <= SRAM_VRAM_ST00; VDMA_Transfer_In_Progress_o <= 1'b1; end		// SRAM to VRAM - 1D/2D 		-> VRAM @133Mbyte/Sec
			2'b10: begin VDMA_SM <= WAIT_2_TRF; VDMA_SM_SM <= VRAM_SRAM_ST00; VDMA_Transfer_In_Progress_o <= 1'b1; end		// VRAM to SRAM - 1D/2D/FILL 	-> SRAM @100Mbyte/Sec
			2'b11: begin VDMA_SM <= IDLE; end		//
			default: begin	VDMA_SM <= END_GEN_INT; end
			endcase
		end

		//////////////////////////////////////////
		// VRAM to VRAM
		//////////////////////////////////////////			
		// VRAM Internal Transfer 1D/2D/Fill
		VRAM_VRAM_ST00: begin 
		
			// 1D/2D
			if (VDMA_Control_Reg[1]) 
				VDMA_SM_SM 				<= VRAM_VRAM_ST06;
			else 
				VDMA_SM_SM 				<= VRAM_VRAM_ST0F;
				
			// Transfer/Fill
			if (VDMA_Control_Reg[2]) begin
				VDMA_SM 					<= VRAM_VRAM_ST04; 	// Go for a swing
				Load_Src_Addy			<= 1'b0; 	// Load Source Address				
			end
			else begin
				VDMA_SM 					<= VRAM_VRAM_ST01;
				Load_Src_Addy			<= 1'b1; 	// Load Source Address				
			end
			Load_Dst_Addy				<= 1'b1; 	// Load Destination Address								
			//Begin_Transfer 			<= 1'b1;
			StridePointerCounter		<= 16'h0000;
		end


		VRAM_VRAM_ST01: begin 
			Load_Src_Addy					<= 1'b0; 	// Load Source Address
			Load_Dst_Addy					<= 1'b0; 	// Load Destination Address
				
			if (VDMA_Dst_Count_Reached_i) begin
				VDMA_Transaction_RW		<= 1'b1;		// Go Read First
				Src_Counter_Enable		<= 1'b0;
				Dst_Counter_Enable   	<= 1'b0;
				VDMA_SM 						<= VDMA_SM_SM;
			end
			else begin		
				VDMA_Transaction_RW		<= 1'b1;		// Go Read First
				Dst_Counter_Enable   	<= 1'b0;				
				if (VDMA_Transfer_Time_Available_i) begin
					Src_Counter_Enable		<= 1'b1;
					VDMA_SM						<= VRAM_VRAM_ST02;
				end
				else begin
					VDMA_SM						<= VRAM_VRAM_ST01;	//Stay Here as long as the 
				end
			end
			
		end
		
		VRAM_VRAM_ST02: begin 
				VDMA_SM 						<= VRAM_VRAM_ST03;
				Src_Counter_Enable		<= 1'b0;				
		end
	
		// Will keep that state for later introduce a Ready Delay in the Read
		VRAM_VRAM_ST03: begin 
				VDMA_Transaction_RW		<= 1'b0;		// Go Read First
				Dst_Counter_Enable   	<= 1'b1;				
				VDMA_SM 						<= VRAM_VRAM_ST01;		
		end
		
		// *******************************************
		// FILL
		// *******************************************
		VRAM_VRAM_ST04: begin 
			Load_Dst_Addy					<= 1'b0; 	// Load Destination Address		
			VDMA_Transaction_RW		 	<= 1'b0;		// Go Read Firstend	// 1D - FILL
			Dst_Counter_Enable   		<= 1'b1;
			VDMA_SM 							<= VRAM_VRAM_ST05;
		end
		
		
		VRAM_VRAM_ST05: begin 
			if (VDMA_Dst_Count_Reached_i) begin
				VDMA_Transaction_RW	 	<= 1'b1;		// Go Read First
				Src_Counter_Enable		<= 1'b0;
				Dst_Counter_Enable   	<= 1'b0;
				VDMA_SM 						<= VDMA_SM_SM;
			end
			else begin
				if (VDMA_Transfer_Time_Available_i) begin
					VDMA_Transaction_RW		 	<= 1'b0;		// Go Read Firstend	// 1D - FILL
					Dst_Counter_Enable   		<= 1'b1;
				end
				else begin
					VDMA_Transaction_RW	 	<= 1'b1;		// Go Read First				
					Dst_Counter_Enable   	<= 1'b0;				
				end
				VDMA_SM 						<= VRAM_VRAM_ST05;
			end
		end
		
		// Let's go read the bytes in the VRAM
		VRAM_VRAM_ST06: begin 
			StridePointerCounter <= StridePointerCounter + 16'h0001;		
			VDMA_SM 							<= VRAM_VRAM_ST07;
		end
		
		VRAM_VRAM_ST07: begin 
			if (StridePointerCounter == VDMA_Y_Size) begin
				VDMA_SM 						<= VRAM_VRAM_ST0F;	// if we get here the overall transfer is done
			end
			else begin
				VDMA_SM 						<= VRAM_VRAM_ST08;		
			end
		end

		// Charge the Destination Address
		VRAM_VRAM_ST08: begin 
			if (VDMA_Control_Reg[2]) begin
				Load_Dst_Addy			<= 1'b1; 	// Load Destination Address			
				VDMA_SM 					<= VRAM_VRAM_ST04;
			end
			else begin
				Load_Src_Addy			<= 1'b1; 	// Load Source Address
				Load_Dst_Addy			<= 1'b1; 	// Load Destination Address				
				VDMA_SM 					<= VRAM_VRAM_ST01;
			end
			VDMA_SM_SM 				<= VRAM_VRAM_ST06;
		end


		VRAM_VRAM_ST0F: begin
			StridePointerCounter				<= 16'h0000;		
			VDMA_Transfer_In_Progress_o	<= 1'b0;
			VDMA_Transaction_RW				<= 1'b1;	// Write VRAM			
			//Begin_Transfer 					<= 1'b0;		
			VDMA_SM 								<= END_GEN_INT;
		end



//////////////////////////////////////////
// SRAM to VRAM
//////////////////////////////////////////
// Read SRAM - Write VRAM
		SRAM_VRAM_ST00: begin
			Load_Dst_Addy				<= 1'b1; 	// Load Destination Address	
			VDMA_Transaction_RW			<= 1'b1;		// Go Read Firstend	// 1D - FILL				
			// 1D/2D
			if (VDMA_Control_Reg[1]) 
				VDMA_SM_SM 				<= SRAM_VRAM_ST03;
			else 
				VDMA_SM_SM 				<= VRAM_VRAM_ST0F;
				
			VDMA_SM 					<= SRAM_VRAM_ST01;

			//Begin_Transfer 		<= 1'b1;
			StridePointerCounter	<= 16'h0000;			
		end

		// Wait for Data To be Available
		//	Src_Counter_Enable		<= 1'b0;
		//	Dst_Counter_Enable   	<= 1'b1;
		//	FIFO_VDMA_Empty_Status
		// FIFO_VDMA_Read_Strobe
		SRAM_VRAM_ST01: begin
			Load_Dst_Addy					<= 1'b0; 	// Load Destination Address		
			VDMA_SM 							<= SRAM_VRAM_ST06;				
		end

		// This is the 1D Transfer
		SRAM_VRAM_ST02: begin
			if ( VDMA_Dst_Count_Reached_i ) begin
				FIFO_VDMA_Read_Strobe 	<= 1'b0;
				VDMA_Transaction_RW		<= 1'b1;		// Go Read Firstend	// 1D - FILL						
				VDMA_SM 						<= VDMA_SM_SM;
			end
			else begin		
				VDMA_SM						<= SRAM_VRAM_ST06;
			end		
		end
		// THis is for the 2D Transfer
		SRAM_VRAM_ST03: begin
			StridePointerCounter <= StridePointerCounter + 16'h0001;		
			VDMA_SM 							<= SRAM_VRAM_ST04;
		end

		SRAM_VRAM_ST04: begin 
			if (StridePointerCounter == VDMA_Y_Size) begin
				VDMA_SM 						<= VRAM_VRAM_ST0F;	// if we get here the overall transfer is done
			end
			else begin
				VDMA_SM 						<= SRAM_VRAM_ST05;
			end		
		end

		SRAM_VRAM_ST05: begin
			Load_Dst_Addy					<= 1'b1; 	// Load Destination Address
			VDMA_SM_SM 						<= SRAM_VRAM_ST03;			
			VDMA_SM 							<= SRAM_VRAM_ST01;
		end

		// Check FIFO
		SRAM_VRAM_ST06: begin
			if (FIFO_VDMA_Empty_Status == 1'b0) begin
				if (	VDMA_Transfer_Time_Available_i ) begin			
					FIFO_VDMA_Read_Strobe 		<= 1'b1;		// This will enable the process - However, the VDMA_Transfer_Time_Available_i will dictate when the data will be availabe hence when it is going to be written.
					VDMA_SM 							<= SRAM_VRAM_ST07;
				end
				else 
					VDMA_SM 							<= SRAM_VRAM_ST06;
			end
			else 
				VDMA_SM 							<= SRAM_VRAM_ST06;
		end
		
		// Read has been sent,
		SRAM_VRAM_ST07: begin
			FIFO_VDMA_Read_Strobe 		<= 1'b0;		// This will enable the process - However, the VDMA_Transfer_Time_Available_i will dictate when the data will be availabe hence when it is going to be written.
			if (	VDMA_Transfer_Time_Available_i ) begin
				VDMA_Transaction_RW			<= 1'b0;
				Dst_FIFO_Counter_Enable	  	<= 1'b1; //Advance One
				VDMA_SM 						  	<= SRAM_VRAM_ST08;						
			end
		else
			VDMA_SM 							<= SRAM_VRAM_ST07;					
		end
		
		// DATA VALID HERE
		SRAM_VRAM_ST08: begin
			VDMA_Transaction_RW		  <= 1'b1;		
			Dst_FIFO_Counter_Enable	  <= 1'b0; //Advance One
			VDMA_SM 						  <= SRAM_VRAM_ST02;			
		end
		
//		VRAM_SRAM_ST09: begin

//			VDMA_SM 							<= SRAM_VRAM_ST02;				
		
//		end		
		//////////////////////////////////////////
		// VRAM to SRAM
		//////////////////////////////////////////
		//		So the extenal bus available
		// Then let's see what we have to do next, is it VRAM to SRAM or the other way around
// VRAM to SRAM
	
		VRAM_SRAM_ST00: begin
			Load_Src_Addy					<= 1'b1; 	// Load Source Address
			VDMA_Transaction_RW			<= 1'b1;			
			// 1D/2D
			if (VDMA_Control_Reg[1]) 
				VDMA_SM_SM 					<= VRAM_SRAM_ST03;
			else 
				VDMA_SM_SM 					<= VRAM_VRAM_ST0F;

			VDMA_SM 							<= VRAM_SRAM_ST01;
			
			//Begin_Transfer 				<= 1'b1;
			StridePointerCounter			<= 16'h0000;			
		end

		VRAM_SRAM_ST01: begin
			Load_Src_Addy					<= 1'b0; 	// Load Source Address
			FIFO_VDMA_Write_Strobe 		<= 1'b1;	// This will enable the process
			VDMA_SM 							<= VRAM_SRAM_ST02;	
		end

		VRAM_SRAM_ST02: begin
			if (VDMA_Src_Count_Reached_i) begin
				FIFO_VDMA_Write_Strobe 	<= 1'b0;
				VDMA_SM 						<= VDMA_SM_SM;
			end
			else begin		
				VDMA_SM						<= VRAM_SRAM_ST02;
			end			
		end

		VRAM_SRAM_ST03: begin
			StridePointerCounter <= StridePointerCounter + 16'h0001;		
			VDMA_SM <= VRAM_SRAM_ST04;
		end

		// 3C
		VRAM_SRAM_ST04: begin
			if (StridePointerCounter == VDMA_Y_Size) begin
				VDMA_SM 					<= VRAM_VRAM_ST0F;	// if we get here the overall transfer is done
			end
			else begin
				VDMA_SM 					<= VRAM_SRAM_ST05;
			end	
		end		
		
		// 3D
		VRAM_SRAM_ST05: begin
			Load_Src_Addy				<= 1'b1; 	// Load Source Address
			VDMA_SM 						<= VRAM_SRAM_ST06;
		end


		VRAM_SRAM_ST06: begin
			Load_Src_Addy				<= 1'b0; 	// Load Source Address
			VDMA_SM_SM 					<= VRAM_SRAM_ST03;			
			VDMA_SM 						<= VRAM_SRAM_ST01;
		end

		END_GEN_INT: begin
			VDMA_Status_Progress	<= 1'b0;		
			VDMA_SM <= IDLE;
		end

		// THis is where we wait before we can start the transfer
		WAIT_2_TRF: begin 
			//if (( VDMA_Transfer_Time_Available_EDGE == 2'b01 ) || ( VDMA_Transfer_Time_Available_EDGE == 2'b11 )) begin
			
			if ({VDMA_Transfer_Time_Available_EDGE, VDMA_Transfer_Time_Available_i} == 2'b01) begin
			//if (VDMA_Transfer_Time_Available_i) begin			
				VDMA_SM <= VDMA_SM_SM;
			end
			else begin
				VDMA_SM <= WAIT_2_TRF;
			end
		end

		//0x25
		THE_END: begin 
			VDMA_SM <= VDMA_SM_SM;		
		end

		default: begin 

		end

		endcase
	end
end

reg VDMA_Transfer_Time_Available_EDGE;

always @ ( posedge EngineClk100Mhz_i ) begin
	VDMA_Transfer_Time_Available_EDGE <= VDMA_Transfer_Time_Available_i;
end



endmodule

/*
; Bit Field Definition
VDMA_CTRL_Enable        = $01
VDMA_CTRL_1D_2D         = $02     ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
VDMA_CTRL_TRF_Fill      = $04     ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
VDMA_CTRL_Int_Enable    = $08     ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
VDMA_CTRL_SysRAM_Src    = $10     ; Set to 1 to Indicate that the Source is the System Ram Memory
VDMA_CTRL_SysRAM_Dst    = $20     ; Set to 1 to Indicate that the Destination is the System Ram Memory
VDMA_CTRL_Start_TRF     = $80     ; Set to 1 To Begin Process, Need to Cleared before, you can start another
*/




//assign VDMA_Control_Reg 	= 	Debug_Source_i[23:16];
//assign VDMA_Data_2_Write 	=  8'h00;
//assign VDMA_Src_Addy			= 	Debug_Source_i[47:24];
//assign VDMA_Dst_Addy 		=	Debug_Source_i[71:48];
//assign VDMA_X_Size			=	Debug_Source_i[87:72];
//assign VDMA_Y_Size 			=	Debug_Source_i[103:88];
//assign VDMA_Src_Stride 		= 	16'h0000;
//assign VDMA_Dst_Stride 		= 	16'h0000;

// END of VDMA Register Block

/*
wire [139:0] ChipScope;
wire			Trigger;

//assign Trigger = ( VDMA_Control_Reg[0] && (Fire_Transfer[1:0] == 2'b01) );
//assign Trigger = VDMA_Transfer_In_Progress_o & VDMA_Transfer_Time_Available_i;
assign Trigger = VDMA_Transfer_Time_Available_i;
//assign ChipScope[95:64] = State_Machine;

ChipScope	ChipScope_inst (
	.acq_clk ( EngineClk100Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

assign ChipScope[31:0] 	= VDMA_VRAM_Data_Out_o;
assign ChipScope[63:32] = VDMA_VRAM_Data_In_i;
assign ChipScope[85:64] = VDMA_VRAM_Addy_Out_o;
assign ChipScope[86] 	= VDMA_VRAM_Data_Read_o;
assign ChipScope[90:87] = VDMA_VRAM_Data_Writen_o;
assign ChipScope[96:91] = VDMA_SM;
assign ChipScope[118:97] = CPU_VDMA_A_o[21:0];
assign ChipScope[119] = Validate_Wr;
assign ChipScope[127:120] = CPU_VDMA_D_Out_o;
assign ChipScope[135:128] = CPU_VDMA_D_In_i;
assign ChipScope[136] = CPU_VDMA_Bus_RW_o;
assign ChipScope[137] = VDMA_Transfer_In_Progress_o;
assign ChipScope[138] = VDMA_Transfer_Time_Available_i;

*/
/*
00000 0  00000
00001	1	00001
00010	2	00011
00011	3	00010
00100	4	00110
00101	5	00111
00110	6	00101
00111	7	00100
01000	8	01100
01001	9	01101
01010	10	01111
01011	11	01110
01100	12	01010
01101	13	01011
01110	14	01001
01111	15	01000
10000	16	11000
10001	17	11001
10010	18	11011
10011	19	11010
10100	20	11110
10101	21	11111
10110	22	11101
10111	23	11100
11000	24	10100
11001	25	10101
11010	26	10111
11011	27	10110
11100	28	10010
11101	29	10011
11110	30	10001
11111	31	10000
*/
/*
// SRAM VDMA Address Generation Circuit
C256Foenix_SMemoryInterface C256_SMEM_Interface(
	.Reset_i( Reset_i ),
	.EngineClk50Mhz_i( EngineClk50Mhz_i ),
	.EngineClk100Mhz_i( EngineClk100Mhz_i ),

	.CPU_Counter_Enable_i( VDMA_SRAM_Side_Enable ),		// This is the Start
	.CPU_Counter_Load_i( VDMA_SRAM_Side_Load ),
	.CPU_Counter_Reached_Count_o( VDMA_SRAM_Side_Reached_Count ), 

	.CPU_Target_Addy_Start_i( VDMA_SRAM_Side_Addy_Start ),
	.CPU_Target_Addy_Stop_i( VDMA_SRAM_Side_Addy_Stop ),
	.CPU_Target_RW_i( CPU_Target_RW ),		// Read or Write
	.CPU_Target_VRAM_Data_i( VDMA_SRAM_Outgoing_Data ),	// DATA <<<<<--------

	.CPU_DataInputChannel_o( VDMA_SRAM_InComing_Data ),		// DATA -------->>>>>
	.CPU_Data_Output_Valid_o( VDMA_SRAM_Side_Data_Valid ),

	.CPU_VDMA_A_o( CPU_VDMA_A_o ),			// DMA Channel Addy
	.CPU_VDMA_D_Out_o( CPU_VDMA_D_Out_o ),		// DMA Channel Data Out
	.CPU_VDMA_D_In_i( CPU_VDMA_D_In_i ),		// DMA Channel Data In
	.CPU_VDMA_Bus_RW_o( CPU_VDMA_Bus_RW_o )	// DMA Channel Read/Writen
);
*/
/*

assign VDMA_SRAM_Outgoing_Valid_o = VDMA_Target_Data_Output_Valid_i;

reg	[1:0]	SmallState;
reg			Enable_FIFO_Data;
localparam 	Small_St0 = 2'b00,
				Small_St1 = 2'b01,
				Small_St2 = 2'b10,
				Small_St3 = 2'b11;

always @ (posedge EngineClk100Mhz_i) begin
	if (Reset_i) begin
		SmallState <= 2'b00;
		CPU_FIFO_Read_o <= 1'b0;
	end
	else begin
		case(SmallState)
		Small_St0: begin 
			if (CPU_FIFO_Empty_i)
				SmallState <= Small_St0;
			else begin
				if (VDMA_Transfer_Time_Available_i) begin
					CPU_FIFO_Read_o <= 1'b1;
					SmallState <= Small_St1;
				end
			end
		end
		// Read FIFO Here - Read is Valid Here
		Small_St1: begin
			CPU_FIFO_Read_o <= 1'b0;
			Enable_FIFO_Data <= 1'b1;
			SmallState <= Small_St2;
		end
		
		// Data Valid Here
		Small_St2: begin
			Enable_FIFO_Data <= 1'b0;
			SmallState <= Small_St3;			
		end
		
		Small_St3: begin
			SmallState <= Small_St0;		
		end
		endcase
	end
end
*/