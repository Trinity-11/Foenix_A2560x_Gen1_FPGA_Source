`timescale 1 ns / 1 ns
module A2560Mx_DMA_Controller ( 

input 	wire				Reset_i,				// This is async Reset
input	wire				iBUS_2xClk_i,			// 66Mhz
// CPU Signals Interface
input	wire				iBUS_Clk_i,				// 33Mhz
input	wire	[31:0]		iBUS_A_i,
input	wire				iBUS_A_Valid_i, 
input	wire	[7:0]		iBUS_D8_i,
input	wire	[15:0]		iBUS_D16_i,
input	wire	[31:0]		iBUS_D32_i,
input	wire				iBUS_RWn_i,
input	wire	[1:0]		iBUS_Siz_i,
input	wire	[3:0]		iBUS_BE_i,
input	wire				iBUS_WE_i, 
input   wire   				CS_SDMA_Controller_i,
output  wire   	[31:0]		DataOut_SDMA_o,

output	wire 				iBUS_SDMA_BRn_o,
input	wire 				iBUS_SDMA_BGn_i,

//input	wire				SDMA_Read_Valid_i, 
output	wire	[31:0]		SDMA_Transaction_Addy_o,
output	wire				SDMA_Transaction_RDn_o,
output	wire				SDMA_Transaction_WRn_o,
output 	reg   	[3:0]		SDMA_Transaction_BEn_o,
output	wire				SDMA_Copy_Fill_Strobe_o,
output	wire	[7:0]		SDMA_Data_2_Fill_o,
output  wire    [15:0]      SDMA_Data_2_Fill16_o,
output  wire    [31:0]      SDMA_Data_2_Fill32_o,
output  wire    [3:0]       SMDA_Data_Mask_o,
output  wire                SMDA_Double_Speed_DMA_o,
output  wire   				SDMA_Quad_Speed_DMA_o,

//input	wire				SDMA_Trf_Time_Before2Late_i,
input	wire				SDMA_Transfer_Time_Available_i,

output	reg					SDMA_Transfer_In_Progress_o,
output	wire				SDMA_Interrupt_o
);

assign iBUS_SDMA_BRn_o = 1'b1; 

 // Wires
wire	[31:0]		SDMA_Control_Reg; 		// Will be 32bits From now on.
wire	[7:0]		SDMA_Data_2_Write;
wire    [15:0]      SDMA_Data_2_Write16;
wire    [31:0]      SDMA_Data_2_Write32;
wire	[31:0]		SDMA_Src_Addy;
wire	[31:0]		SDMA_Dst_Addy;
wire    [31:0]		SDMA_1D_Size;
wire	[15:0]		SDMA_X_Size;
wire	[15:0]		SDMA_Y_Size;
wire	[15:0]		SDMA_Src_Stride;
wire	[15:0]		SDMA_Dst_Stride;

wire	[7:0]		SDMA_Status_Reg;

wire	[31:0]		Count1D;
wire	[31:0]		Count2D;
wire	[31:0]		ComputeStrideSource;
wire	[31:0]		ComputeStrideDestination;
wire 	[31:0] 		SrcPlusCount1D;
wire 	[31:0] 		DstPlusCount1D;
wire	[31:0]		SrcPlusStride;
wire	[31:0]		DstPlusStride;
wire	[31:0]		SrcPlusStridePlusX;
wire	[31:0]		DstPlusStridePlusX;
wire   				Read_Reached_End;
wire   				Write_Reached_End;
wire   				Double_Speed_DMA;

reg 	[31:0]		Read_Data_Address_Pointer;
reg 	[31:0]		Write_Data_Address_Pointer;
reg					Write_Strobe;
reg 				Read_Strobe;
reg					Advance_Read_Pointer;
reg 	[2:0] 		SDMA_Trf_Time_Before2Late_RESYNC;
reg 				SDMA_Transfer_Time_Available_RESYNC;
reg		[15:0]		Interrupt_Generation;

// INTERRUPT AND STATUS CIRCUIT
reg 	[1:0] 		Interrupt_Generation_ReSync;
reg 	[2:0] 		SDMA_Status_Progress_ReSync;
reg		[15:0]		StridePointerCounter;
reg   				SDMA_Status_Progress;
reg					Termination_Feedback;
reg 	[31:0] 		SDMA_Src_Addy_Start;	
reg		[31:0]		SDMA_Src_Addy_Stop;
reg		[31:0]		SDMA_Dst_Addy_Start;
reg		[31:0]		SDMA_Dst_Addy_Stop;
reg		[5:0]		SDMA_SM;
reg		[5:0]		SDMA_SM_SM;
reg		[5:0]		SDMA_SM_SM_SM;
reg		[1:0]		Fire_Transfer;



localparam			IDLE				=	6'b00_0000,
					VALIDATE0			=	6'b00_0001,// Make Sure the Parameters are Valid
					VALIDATE1			=	6'b00_0011,
					VALIDATE2			=	6'b00_0010,
					// VRAM Internal Transfer in 1D/2D/Fill
					VRAM_VRAM_ST00		=	6'b00_0110,
					VRAM_1D_ST01		=	6'b00_0111,
					VRAM_1D_ST02		=	6'b00_0101,
					VRAM_1D_ST03		=	6'b00_0100,
					VRAM_1D_FILL_ST01	=	6'b00_1100,
					VRAM_1D_FILL_ST02	=	6'b00_1101,
					VRAM_1D_FILL_ST03	=	6'b00_1111,
					VRAM_2D_ST01		=	6'b00_1110,
					VRAM_2D_ST02		=	6'b00_1010,
					VRAM_2D_ST03		=	6'b00_1011,
					VRAM_2D_ST04		=	6'b00_1001,
					VRAM_2D_ST05		=	6'b00_1000,
					WAIT_NEXT_SOF		=	6'b01_1000,
					VRAM_VRAM_ST0D		=	6'b01_1001,
					VRAM_VRAM_ST0E		=	6'b01_1011,
					VRAM_VRAM_ST0F		=	6'b01_1010,
					// SRAM to VRAM

					NOT_USED_ST0		=	6'b10_1110,
					NOT_USED_ST1		=	6'b10_1111,
					NOT_USED_ST2		=	6'b10_1101,
					END_GEN_INT			=	6'b10_1100,
					WAIT_2_TRF			=	6'b10_0100,
					THE_END				=	6'b10_0101;

//assign SDMA_Debug_Sig_o = SDMA_Read_Valid_i;

A2560Mx_DMA_Reg_Block RegBlock( 
	.Reset_i( Reset_i ),		// This is async Reset
	.iBUS_2xClk_i( iBUS_2xClk_i ),
	.iBUS_Clk_i( iBUS_Clk_i ),		//50Mhz
	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ), 
	.iBUS_D8_i( iBUS_D8_i ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),			// Short Transaction		
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_Siz_i( iBUS_Siz_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_WE_i( iBUS_WE_i ),			// Write Enable [3:0] - 0 = High Byte, 1 = Low Byte		
	.CS_SDMA_Controller_i( CS_SDMA_Controller_i ),
	.DataOut_SDMA_o( DataOut_SDMA_o ),
	
	.SDMA_Control_Reg_o( SDMA_Control_Reg ) ,
	.SDMA_Data_2_Write_o( SDMA_Data_2_Write ),
	.SDMA_Data_2_Write16_o( SDMA_Data_2_Write16 ),
	.SDMA_Data_2_Write32_o( SDMA_Data_2_Write32 ),
	.SDMA_Src_Addy_o( SDMA_Src_Addy ),
	.SDMA_Dst_Addy_o( SDMA_Dst_Addy ),
	.SDMA_1D_Size_o( SDMA_1D_Size ),
	.SDMA_2D_X_Size_o( SDMA_X_Size ),
	.SDMA_2D_Y_Size_o( SDMA_Y_Size ),
	.SDMA_Src_Stride_o( SDMA_Src_Stride ),
	.SDMA_Dst_Stride_o( SDMA_Dst_Stride ),
	.SDMA_Status_Reg_i( SDMA_Status_Reg )

);

always @ (posedge iBUS_Clk_i)	// 33Mhz
begin
	// Resync in 14Mhz Space for Int
	Interrupt_Generation_ReSync[0] <= Interrupt_Generation[15];
	Interrupt_Generation_ReSync[1] <= Interrupt_Generation_ReSync[0];
	// Resync in 14Mhz Space for In Progress
	SDMA_Status_Progress_ReSync[0] <= SDMA_Status_Progress;
	SDMA_Status_Progress_ReSync[1] <= SDMA_Status_Progress_ReSync[0];
	if ( SDMA_Status_Progress_ReSync[1] == SDMA_Status_Progress_ReSync[0]) 
			SDMA_Status_Progress_ReSync[2] <= SDMA_Status_Progress_ReSync[1];
end

assign SDMA_Interrupt_o = Interrupt_Generation_ReSync[1];
assign SDMA_Status_Reg = {SDMA_Status_Progress_ReSync[2], 7'b000_0000};

always @ (posedge iBUS_2xClk_i) begin
	if (Reset_i) begin
		Interrupt_Generation <= 16'h0000;
	end
	else begin
		Interrupt_Generation <= Interrupt_Generation << 1'b1;
		if (SDMA_Control_Reg[3]) begin
			if (SDMA_SM == END_GEN_INT) begin
				Interrupt_Generation <= 16'hFFFF;
			end
		end
	end
end

// Assignments on some intermediate value to be used in the Start/Stop Address Pointer

assign Count1D 					= SDMA_1D_Size;					//32bits
assign SrcPlusCount1D 			= SDMA_Src_Addy + Count1D;		//32bits
assign DstPlusCount1D 			= SDMA_Dst_Addy + Count1D - 1;	//32bits
assign SrcPlusStride			= SDMA_Src_Addy + ComputeStrideSource[31:0];
assign SrcPlusStridePlusX		= SDMA_Src_Addy + ComputeStrideSource[31:0] + {16'h0000, SDMA_X_Size};
assign DstPlusStride			= SDMA_Dst_Addy + ComputeStrideDestination[31:0];
assign DstPlusStridePlusX		= ( SDMA_Dst_Addy + ComputeStrideDestination[31:0] + {16'h0000, SDMA_X_Size} ) - 1;


// Compute Stride for Source
DMA_MULT_BLK SourceStrideCompute(
    .clock(iBUS_2xClk_i),
    .dataa( StridePointerCounter ),
    .datab( SDMA_Src_Stride ), 
    .result( ComputeStrideSource )	// The Output is in Tile Char, 
  );

// Compute Stride for Destination
DMA_MULT_BLK DestinationStrideCompute(
    .clock(iBUS_2xClk_i),
    .dataa( StridePointerCounter ),
    .datab( SDMA_Dst_Stride ), 
    .result( ComputeStrideDestination )	// The Output is in Tile Char, 
  );

always @ (posedge iBUS_2xClk_i) begin	
	if ( SDMA_Control_Reg[1] ) begin 
		// 2D TRANSFER (The Stride is Used)
		SDMA_Src_Addy_Start		<= SrcPlusStride[31:0];
		SDMA_Src_Addy_Stop		<= SrcPlusStridePlusX[31:0];
		SDMA_Dst_Addy_Start		<= DstPlusStride[31:0];
		SDMA_Dst_Addy_Stop		<= DstPlusStridePlusX[31:0];		
	end
	else begin 
		// 1D TRANSFER - Linear - (The Stride is ignored)
		SDMA_Src_Addy_Start		<= SDMA_Src_Addy[31:0];
		SDMA_Src_Addy_Stop		<= SrcPlusCount1D[31:0];
		SDMA_Dst_Addy_Start		<= SDMA_Dst_Addy[31:0];
		SDMA_Dst_Addy_Stop		<= DstPlusCount1D[31:0];
	end 
end


//assign SDMA_Transaction_LSBn_o = Double_Speed_DMA ?  1'b0 : SDMA_Transaction_Addy_o[0];
//assign SDMA_Transaction_MSBn_o = Double_Speed_DMA ?  1'b0 : !SDMA_Transaction_Addy_o[0];


always @ ( * ) begin 
	casex( {SDMA_Control_Reg[5:4] })
	// 8bits
	2'b00: begin 
		SDMA_Transaction_BEn_o[0]  = !(SDMA_Transaction_Addy_o[1:0] == 2'b11);	// A[1:0] = 11
		SDMA_Transaction_BEn_o[1]  = !(SDMA_Transaction_Addy_o[1:0] == 2'b10);	// A[1:0] = 10
		SDMA_Transaction_BEn_o[2]  = !(SDMA_Transaction_Addy_o[1:0] == 2'b01);	// A[1:0] = 01
		SDMA_Transaction_BEn_o[3]  = !(SDMA_Transaction_Addy_o[1:0] == 2'b00);	// A[1:0] = 00
	end

	// 16bits
	2'b01: begin 
		SDMA_Transaction_BEn_o[0]  = !(SDMA_Transaction_Addy_o[1] == 1'b1);	// A[1:0] = 11
		SDMA_Transaction_BEn_o[1]  = !(SDMA_Transaction_Addy_o[1] == 1'b1);	// A[1:0] = 10
		SDMA_Transaction_BEn_o[2]  = !(SDMA_Transaction_Addy_o[1] == 1'b0);	// A[1:0] = 01
		SDMA_Transaction_BEn_o[3]  = !(SDMA_Transaction_Addy_o[1] == 1'b0);	// A[1:0] = 00
	end 

	//32bits
	2'b1x: begin 
		SDMA_Transaction_BEn_o[3:0]  = 4'b0000;
	end 

	endcase
end 

//Control Register Bits
//[0] - Enable SDMA Block (SRAM DMA)
//[1] - Transfer Dimension - 0: 1D, 1: 2D
//[2] - Transfer Type - 0: Data, 1: Fill 
//[3] - Enable IRQ Generation @ End of transfer
//[4] - Double Speed Transfer - 0: Byte (8bits) Transfer, 1: Short (16bits) Transfer
//[5] - Quad Speed Transfer - 0: (Byte or Short) 1: Long (32bits) Transfer
//[6] - Reserved
//[7] - Start Transfer
//[11:8] - Mask Bits 0000 - Full, any '1' will mask one (or many) of the bytes when the writting takes place
//[31:12] - Reserved


assign SDMA_Transaction_Addy_o 		= Write_Strobe ? Write_Data_Address_Pointer[31:0] : Read_Data_Address_Pointer[31:0];
assign SDMA_Transaction_RDn_o  		= !Read_Strobe;
assign SDMA_Transaction_WRn_o  		= !Write_Strobe;
assign Read_Reached_End			 	= Double_Speed_DMA ? ( {Read_Data_Address_Pointer[31:1], 1'b0} == {SDMA_Src_Addy_Stop[31:1], 1'b0} ) : ( Read_Data_Address_Pointer == SDMA_Src_Addy_Stop );
assign Write_Reached_End		 	= Double_Speed_DMA ? ( {Write_Data_Address_Pointer[31:1], 1'b0} < {SDMA_Dst_Addy_Stop[31:1], 1'b0} ) : ( Write_Data_Address_Pointer < SDMA_Dst_Addy_Stop );
assign SDMA_Data_2_Fill_o      		= SDMA_Data_2_Write;
assign SDMA_Data_2_Fill16_o         = SDMA_Data_2_Write16;
assign SDMA_Data_2_Fill32_o 		= SDMA_Data_2_Write32;
assign SDMA_Copy_Fill_Strobe_o 		= SDMA_Control_Reg[2];
assign Double_Speed_DMA 			= SDMA_Control_Reg[4];
assign SMDA_Double_Speed_DMA_o      = SDMA_Control_Reg[4];
assign SDMA_Quad_Speed_DMA_o		= SDMA_Control_Reg[5];
assign SMDA_Data_Mask_o             = SDMA_Control_Reg[11:8];

always @ (posedge iBUS_2xClk_i) begin
	if (Reset_i) begin
		Read_Data_Address_Pointer <= 24'h00_0000;
	end
	else begin 
		if ( Write_Strobe ) begin 
			if ( Double_Speed_DMA )			
				Read_Data_Address_Pointer <= Read_Data_Address_Pointer + 24'h00_0002;
			else
				Read_Data_Address_Pointer <= Read_Data_Address_Pointer + 24'h00_0001;
		end 
		else begin 
			if (( SDMA_SM == VALIDATE2 ) || ( SDMA_SM == VRAM_2D_ST04 ))
				Read_Data_Address_Pointer <= SDMA_Src_Addy_Start;
		end 
	end
end

always @ (posedge iBUS_2xClk_i) begin
	if (Reset_i) begin
		Write_Data_Address_Pointer <= 24'h00_0000;
	end
	else begin 
		if ( Write_Strobe ) begin 
			if ( Double_Speed_DMA )
				Write_Data_Address_Pointer <= Write_Data_Address_Pointer + 24'h00_0002;
			else
				Write_Data_Address_Pointer <= Write_Data_Address_Pointer + 24'h00_0001; 
		end 
		else begin 
			if (( SDMA_SM == VALIDATE2 ) || ( SDMA_SM == VRAM_2D_ST04 ))
				Write_Data_Address_Pointer <= SDMA_Dst_Addy_Start;
		end 	
	end
end

//wire [1:0] 	Src_TARGET = SDMA_Src_Addy_Start[20:19];
// 00 = RAM
// 01 = FLASH
// 10 = CART
// 11 = NOT POSSIBLE
//wire [1:0] 	Dst_TARGET = SDMA_Dst_Addy_Start[20:19];
// 00 = RAM
// 01 = FLASH - Impossible Choice
// 10 = CART
// 11 = NOT POSSIBLE

//assign Bus_RDY_o = SDMA_Transfer_Time_Available_RESYNC[2] & SDMA_Status_Progress;	


/*
; DMA Controller $AF0400 - $AF04FF
SDMA_CONTROL_REG        = $AF0400
; Bit Field Definition
SDMA_CTRL_Enable     [0]= $01
SDMA_CTRL_1D_2D      [1]= $02     ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
SDMA_CTRL_TRF_Fill   [2]= $04     ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
SDMA_CTRL_Int_Enable [3]= $08     ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
NOT USED             [4]= $10     ; Reserved
NOT USED             [5]= $20     ; Reserved
SixteenBit_Enable	 [6]= $40     ; Set to 1 to Do a 16bits Transfer
SDMA_CTRL_Start_TRF  [7]= $80     ; Set to 1 To Begin Process, Need to Cleared before, you can start another
*/

always @ (posedge iBUS_2xClk_i) begin
	if (Reset_i) begin
		Fire_Transfer <= 2'b00;
	end
	else begin
			Fire_Transfer[0] <= SDMA_Control_Reg[7];
			Fire_Transfer[1] <= Fire_Transfer[0];
		end
end

always @ (posedge iBUS_2xClk_i) begin
	if (Reset_i) begin
			SDMA_SM								<= IDLE;
			SDMA_SM_SM 							<= IDLE;
			SDMA_Transfer_In_Progress_o 		<= 1'b0;
			SDMA_Status_Progress				<= 1'b0;
			Write_Strobe						<= 1'b0;
			Read_Strobe							<= 1'b0;
			StridePointerCounter				<= 16'h0000;
			//Advance_Read_Pointer				<= 1'b0;
	end
	else begin

		case(SDMA_SM)
		
		IDLE: begin 
			if ( SDMA_Control_Reg[0] && (Fire_Transfer[1:0] == 2'b01) ) begin
				SDMA_SM <= VALIDATE0;
				SDMA_Status_Progress	<= 1'b1;				
			end
			else begin 
				SDMA_SM <= IDLE;
				Write_Strobe						<= 1'b0;
				Read_Strobe							<= 1'b0;				
			end 
		end

		VALIDATE0: begin
			SDMA_SM <= VALIDATE1;
		end

		VALIDATE1: begin 
			//SDMA_SM <= VALIDATE2;
			SDMA_SM <= WAIT_2_TRF; 
			SDMA_SM_SM <= VALIDATE2; 			
		end
		
		VALIDATE2: begin
			SDMA_SM <= VRAM_VRAM_ST00; 
//			Bus_RDY_o <= 1'b1;	// Stop the CPU				
			SDMA_Transfer_In_Progress_o <= 1'b1; // For now there is just RAM to RAM
		end

		//////////////////////////////////////////
		// VRAM to VRAM
		//////////////////////////////////////////			
		// VRAM Internal Transfer 1D/2D/Fill - 0x06
		VRAM_VRAM_ST00: begin 
			// Setting up the SDMA_SM_SM (the next step)
			// 1D/2D
			if (SDMA_Control_Reg[1]) 
				SDMA_SM_SM 				<= VRAM_2D_ST01;		// When you are done with First Line you move on to increase the stride line
			else 
				SDMA_SM_SM 				<= VRAM_VRAM_ST0F;
				
			// Transfer/Fill
			if (SDMA_Control_Reg[2]) begin
				SDMA_SM 							<= VRAM_1D_FILL_ST01; 	// Go for a swing
				Write_Strobe			      <= 1'b1;				
			end
			else begin
				SDMA_SM 							<= VRAM_1D_ST01;
				Read_Strobe						<= 1'b1;	// This will Enable OEn
			end
						
			StridePointerCounter		<= 16'h0000;
		end

		// 0x07
		// Transfer 1D Read Source - Write Destination 
		// By Now the Valid Address Ought to be Valid
		// OEn is Valid Here
		VRAM_1D_ST01: begin 
			SDMA_SM 					<= VRAM_1D_ST02;	
			Write_Strobe			<= 1'b1;

		end
		
		// 0x05
		// Data Valid Here  
		// The Switch Happens, and then the write happens 
		VRAM_1D_ST02: begin 	
			SDMA_SM 					<= VRAM_1D_ST03;
			Write_Strobe			<= 1'b0;
		end
	
		/// RDn Not Valid Here 
		VRAM_1D_ST03: begin 
			if ( Read_Reached_End ) begin 
				Read_Strobe <= 1'b0;			
				if ( SDMA_Transfer_Time_Available_i ) begin 
					SDMA_SM <= SDMA_SM_SM;
				end
				else begin
//					Bus_RDY_o <= 1'b0;
					SDMA_SM <= WAIT_NEXT_SOF;
					SDMA_SM_SM_SM <= SDMA_SM_SM;
				end
			end 
			else begin 
				if ( SDMA_Transfer_Time_Available_i ) begin 
					SDMA_SM 				<= VRAM_1D_ST01;
				end
				else begin
//					Bus_RDY_o <= 1'b0;				
					SDMA_SM <= WAIT_NEXT_SOF;
					SDMA_SM_SM_SM <= VRAM_1D_ST01;				
				end 
			end
		end

		// *******************************************
		// FILL 1D
		// *******************************************
		// 0x0C
		VRAM_1D_FILL_ST01: begin 	
			if ( Write_Reached_End ) begin 
				if ( SDMA_Transfer_Time_Available_i ) begin 	
					SDMA_SM <= VRAM_1D_FILL_ST01;
				end
				else begin 
//					Bus_RDY_o <= 1'b0;				
					SDMA_SM <= WAIT_NEXT_SOF;
					SDMA_SM_SM_SM <= VRAM_1D_FILL_ST01;				
				end 
			end 
			else begin 			
				Write_Strobe <= 1'b0;			
				if ( SDMA_Transfer_Time_Available_i ) begin 			
					SDMA_SM <= SDMA_SM_SM;
				end 
				else begin
//					Bus_RDY_o <= 1'b0;				
					SDMA_SM <= WAIT_NEXT_SOF;
					SDMA_SM_SM_SM <= SDMA_SM_SM;				
				end 
			end 		
		end
		
		// 0x0D
		VRAM_1D_FILL_ST02: begin 

		end
		
		// Let's go read the bytes in the VRAM
		VRAM_1D_FILL_ST03: begin 

		end
		
		//////////////////////////////////////////
		// VRAM to VRAM - 2D Transfer/FILL
		//////////////////////////////////////////			
		
		VRAM_2D_ST01: begin 
			StridePointerCounter <= StridePointerCounter + 16'h0001;			
			SDMA_SM 	<= VRAM_2D_ST02;
		end
		
		VRAM_2D_ST02: begin 
			if (StridePointerCounter == SDMA_Y_Size) begin
				SDMA_SM 	<= VRAM_VRAM_ST0F;	// if we get here the overall transfer is done
			end
			else begin
				SDMA_SM 	<= VRAM_2D_ST03;		
			end
		end
		
		VRAM_2D_ST03: begin
				SDMA_SM 	<= VRAM_2D_ST04;			
		
		end

		VRAM_2D_ST04: begin
				SDMA_SM 	<= VRAM_2D_ST05;
		end
		

		VRAM_2D_ST05: begin 
			SDMA_SM_SM 			<= VRAM_2D_ST01;		
			if (SDMA_Control_Reg[2]) begin		
				SDMA_SM 		<= VRAM_1D_FILL_ST01; 	// Go for a swing
				Write_Strobe	<= 1'b1;		
			end
			else begin			
				SDMA_SM 		<= VRAM_1D_ST01;
				Read_Strobe		<= 1'b1;	// This will Enable OEn
			end
		end	
		
		WAIT_NEXT_SOF: begin
			if ( SDMA_Transfer_Time_Available_i ) begin 
				SDMA_SM <= SDMA_SM_SM_SM;
			end
			else begin
				SDMA_SM <= WAIT_NEXT_SOF;			
			end
		end 

		VRAM_VRAM_ST0F: begin
			StridePointerCounter			<= 16'h0000;		
			SDMA_Transfer_In_Progress_o		<= 1'b0;				
			SDMA_SM 						<= END_GEN_INT;
		end

		END_GEN_INT: begin
//			Bus_RDY_o <= 1'b0;	// Reboot CPU
			SDMA_Status_Progress	<= 1'b0;		
			SDMA_SM <= IDLE;
		end

		// THis is where we wait before we can start the transfer
		WAIT_2_TRF: begin 
			// Okay, it is not driven by SOF now because other then the times the Text Mode needs to fetch data, we can start any time
			if (SDMA_Transfer_Time_Available_i) begin	
				SDMA_SM <= SDMA_SM_SM;
			end
			else begin
				SDMA_SM <= WAIT_2_TRF;
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

//always @ ( posedge iBUS_2xClk_i ) begin
//	SDMA_Transfer_Time_Available_RESYNC <= SDMA_Transfer_Time_Available_i;
// Channel_Select has been inverted is 0 = Memtext, 1 = DMA
/*
	SDMA_Transfer_Time_Available_RESYNC[0] <= SDMA_Transfer_Time_Available_i;
	SDMA_Transfer_Time_Available_RESYNC[1] <= SDMA_Transfer_Time_Available_RESYNC[0];
	if ( SDMA_Transfer_Time_Available_RESYNC[1] == SDMA_Transfer_Time_Available_RESYNC[0] ) begin
		SDMA_Transfer_Time_Available_RESYNC[2] <= SDMA_Transfer_Time_Available_RESYNC[1];
	end	
*/	
//	
/*
	SDMA_Trf_Time_Before2Late_RESYNC[0] <= SDMA_Trf_Time_Before2Late_i;
	SDMA_Trf_Time_Before2Late_RESYNC[1] <= SDMA_Trf_Time_Before2Late_RESYNC[0];
	
	if ( SDMA_Trf_Time_Before2Late_RESYNC[1] == SDMA_Trf_Time_Before2Late_RESYNC[0] ) begin
		SDMA_Trf_Time_Before2Late_RESYNC[2] <= SDMA_Trf_Time_Before2Late_RESYNC[1];
	end
	*/
//end

endmodule 

