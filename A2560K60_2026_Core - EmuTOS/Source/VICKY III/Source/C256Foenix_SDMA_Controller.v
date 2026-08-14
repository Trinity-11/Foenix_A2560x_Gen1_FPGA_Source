
module C256Foenix_SDMA_Controller ( 

input 	wire				Rst_i,
input		wire				Bus_Clk_i,

output	reg				Bus_Reqn_o,				// WIll ask for the BUS - Will keep it to zero for the duration of the request.
input		wire				Bus_Ackn_i,				// Will Wait for the Signal to go low, so the process can proceed.
//
output	wire	[23:0]	SDMA_Bus_A_o,			// Address to be Read or Writen
input		wire	[7:0]		SDMA_Bus_D_i,			// Data Read from Memory
output	wire	[7:0]		SDMA_Bus_D_o, 			// Data to be written to Memory
output	reg				SDMA_Bus_RW_o,			// Read = 1, Write = 0


// VDMA PORT
input		wire	[7:0]		SDMA_Control_Reg_i,	//
input 	wire	[7:0]		SDMA_Data_2_Write_i,
input		wire	[23:0]	SDMA_Src_Addy_i,
input		wire	[23:0]	SDMA_Dst_Addy_i,
input		wire	[15:0]	SDMA_X_Size_i,
input		wire	[15:0]	SDMA_Y_Size_i,
input		wire	[15:0]	SDMA_Src_Stride_i,
input		wire	[15:0]	SDMA_Dst_Stride_i,
output	wire	[7:0]		SDMA_Status_Reg_o,
output	wire				SDMA_Interrupt_o,

input 	wire				CPU_2_VCE_WriteFull_SDMA_i,		// This is for the CPU Direct Write (when it overflows)
input		wire	[7:0]		CPU_2_VCE_WriteCount_SDMA_i,

output	reg				SDMA_In_Progress_o,
//output	wire	[21:0]  	SDMA_Address_Pointer_o,
//output	reg			  	SDMA_RW_o,
//output	reg	[10:0]	SDMA_Transfer_Size_o,
output	wire	[35:0]	SDMA_CMD_o,
output	reg			  	SDMA_Write_CMD_o,
// SDMA Write FIFO
output	wire	[8:0]		SDMA_DATA_2_Write_o,
output	reg				SDMA_DATA_2_Write_Write_Req_o,
input		wire				SDMA_DATA_2_Write_Full_i,
input		wire	[9:0]		SDMA_DATA_2_Write_WrUseDW_i,
// SDMA Read FIFO
input		wire	[8:0] 	SDMA_DATA_2_Read_i,
output	reg				SDMA_DATA_2_Read_Req_i,
input		wire				SDMA_DATA_2_Read_Empty_i
);

//assign SDMA_Status_Reg_o = {DMA_In_Progress, 4'b000_0, VDMA_Status_Src_Ovf, VDMA_Status_Dst_Ovf, VDMA_Status_Overflow};

// SDMA Features
// Copy System RAM Source -> System RAM Destination
// Copy System RAM Source -> VICKY Text Memory
// Copy System RAM Source -> VICKY Color Memory 
// Copy System RAM Source -> VICKY VRAM ?
// Copy VICKY Text Memory -> System RAM Destination
// Copy VICKY Color memory -> System RAM Destination
// Copy VICKY VRAM ?      -> System RAM Destination
// Fill System RAM 
// Fill Vicky II Text 
// Fill Vicky II Color 

/*
; Bit Field Definition
VDMA_CTRL_Enable        = $01
VDMA_CTRL_1D_2D         = $02     ; 0 - 1D (Linear) Transfer , 1 - 2D (Block) Transfer
VDMA_CTRL_TRF_Fill      = $04     ; 0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
VDMA_CTRL_Int_Enable    = $08     ; Set to 1 to Enable the Generation of Interrupt when the Transfer is over.
VDMA_CTRL_Start_TRF     = $80     ; Set to 1 To Begin Process, Need to Cleared before, you can start another
*/


reg	[1:0] 	SRC_DMA_ATTR;
reg	[1:0] 	DST_DMA_ATTR;

reg				SDMA_CMD_RW;
reg	[21:0]	SDMA_CMD_Address;
reg	[11:0]	SDMA_CMD_Size;


// SDMA_PHASES
// SDMA_CMD_Phase = 0 - Pointer ADDY + Direction
// {1'b0, SDMA_Transfer_Size_i, 1'b1 , SDMA_RW_i, !SDMA_Address_Pointer_i[21], !SDMA_Address_Pointer_i[20], SDMA_Address_Pointer_i[19:0]} 
// SDMA_CMD_Phase = 1 - Size
// { 12'h000, SDMA_Y_Size_i[7:0], SDMA_X_Size_i}
assign SDMA_Address_Pointer  = SDMA_RW ? SDMA_Src_Addy_i[21:0] : SDMA_Dst_Addy_i[21:0];
assign SDMA_CMD_o = { 2'b00, SDMA_CMD_Size, 1'b1 , SDMA_CMD_RW, !SDMA_Address[21], !SDMA_Address[20], SDMA_Address[19:0]}; end





assign SDMA_DATA_2_Write_o[7:0] 	= SDMA_Bus_D_i;
assign SDMA_DATA_2_Write_o[8] 	= ( Linear_Counter < {SDMA_Y_Size_i[7:0], SDMA_X_Size_i});
assign SDMA_Bus_D_o 					= (SRC_DMA_ATTR == 2'b01)  ? SDMA_DATA_2_Read_i[7:0] : SDMA_Bus_D_i;		// if the Source is VRAM, then the destination will be SRAM





always @ (*) begin
	case( SDMA_Src_Addy_i[23:20] )
	4'h0: begin SRC_DMA_ATTR = 2'b00; end	// 2'b00 = RAM, 2'b01 = VRAM, 2'b10 = IO, 2'b11 = NULL
	4'h1: begin SRC_DMA_ATTR = 2'b00; end
	4'h2: begin SRC_DMA_ATTR = 2'b00; end
	4'h3: begin SRC_DMA_ATTR = 2'b00; end
	4'h4: begin SRC_DMA_ATTR = 2'b11; end
	4'h5: begin SRC_DMA_ATTR = 2'b11; end
	4'h6: begin SRC_DMA_ATTR = 2'b11; end
	4'h7: begin SRC_DMA_ATTR = 2'b11; end
	4'h8: begin SRC_DMA_ATTR = 2'b11; end
	4'h9: begin SRC_DMA_ATTR = 2'b11; end
	4'hA: begin SRC_DMA_ATTR = 2'b10; end
	4'hB:	begin SRC_DMA_ATTR = 2'b01; end
	4'hC: begin SRC_DMA_ATTR = 2'b01; end
	4'hD: begin SRC_DMA_ATTR = 2'b01; end
	4'hE: begin SRC_DMA_ATTR = 2'b01; end
	4'hF:	begin SRC_DMA_ATTR = 2'b11; end
	default: begin end
	endcase
end

always @ (*) begin
	case( SDMA_Dst_Addy_i[23:20] )
	4'h0: begin DST_DMA_ATTR = 2'b00; end	// 2'b00 = RAM, 2'b01 = VRAM, 2'b10 = IO, 2'b11 = NULL
	4'h1: begin DST_DMA_ATTR = 2'b00; end
	4'h2: begin DST_DMA_ATTR = 2'b00; end
	4'h3: begin DST_DMA_ATTR = 2'b00; end
	4'h4: begin DST_DMA_ATTR = 2'b11; end
	4'h5: begin DST_DMA_ATTR = 2'b11; end
	4'h6: begin DST_DMA_ATTR = 2'b11; end
	4'h7: begin DST_DMA_ATTR = 2'b11; end
	4'h8: begin DST_DMA_ATTR = 2'b11; end
	4'h9: begin DST_DMA_ATTR = 2'b11; end
	4'hA: begin DST_DMA_ATTR = 2'b10; end
	4'hB:	begin DST_DMA_ATTR = 2'b01; end
	4'hC: begin DST_DMA_ATTR = 2'b01; end
	4'hD: begin DST_DMA_ATTR = 2'b01; end
	4'hE: begin DST_DMA_ATTR = 2'b01; end
	4'hF:	begin DST_DMA_ATTR = 2'b11; end
	default: begin end
	endcase
end



reg	[23:0]	TotalByteTransfer;



assign SDMA_Status_Reg_o = 8'h00;	// There is really no point, since the CPU is stopped, although, if there was an error, it would be sweet to know... But later;
assign SDMA_Interrupt_o = 1'b0;
//reg [15:0]		SDMA_X_Size;
reg [15:0]		SDMA_Y_Size;

reg	[23:0]	Linear_Counter;
reg	[23:0]	VRam_Counter;

wire	[31:0]	SDMA_2D_Pointer;

reg				DMA_In_Progress;


DMA_MULT_BLK	DMA_MULT_BLK_inst (
	.dataa ( SDMA_X_Size_i ),
	.datab ( SDMA_Y_Size ),
	.result ( SDMA_2D_Pointer )
	);

	/*
always @ (posedge Bus_Clk_i)
begin
	if (Rst_i) begin
		Linear_Counter <= 24'h00_0000;
	end
	else begin
		if (( StateMachine == TRF_SRAM_2_SRAM1 ) && ( !CPU_2_VCE_WriteFull_SDMA_i )) begin
			Linear_Counter <= Linear_Counter + 24'h00_0001;
		end
		
		if ( StateMachine == ID_TRANSFER) begin
			Linear_Counter <= 24'h00_0000;
		end
	end
end
*/




always @ (posedge Bus_Clk_i) begin
	if (Rst_i) begin
		Linear_Counter <= 24'h00_0000;
	end
	else begin
	
		case (StateMachine)
		
		TRF_SRAM_2_SRAM1: begin
			if (( !CPU_2_VCE_WriteFull_SDMA_i ))
				Linear_Counter <= Linear_Counter + 24'h00_0001;
		end
	

		ID_TRANSFER: begin
			VRam_Counter   	<= 24'h00_0000;
			Linear_Counter 	<= 24'h00_0000;
			TotalByteTransfer <=	(SDMA_X_Size_i[1:0]) ? {SDMA_Y_Size_i[7:0], SDMA_X_Size_i[15:2], 2'b00} + 24'h000004 : {SDMA_Y_Size_i[7:0], SDMA_X_Size_i};
			//TotalWordTransfer <= (SDMA_X_Size_i[1:0]) ? ({SDMA_Y_Size_i[7:0], SDMA_X_Size_i[15:2]} + 22'h00_0001) : {SDMA_Y_Size_i[7:0], SDMA_X_Size_i[15:2]};
		end
		
		
		TRF_SRAM_2_VRAM0: begin
				Linear_Counter <= Linear_Counter + 24'h00_0001;		
		end 

		
		TRF_SRAM_2_VRAM2: begin
				Linear_Counter <= Linear_Counter + 24'h00_0001;			
		end
		
		
		endcase 
	end
end



// This for the CPU SRAM Address
assign 	SDMA_Bus_A_o = SDMA_Bus_RW_o ? ( SDMA_Src_Addy_i + Linear_Counter ) : ( SDMA_Dst_Addy_i + Linear_Counter );

	
reg	[4:0]		StateMachine;
reg	[4:0]		StateStateMachine;
localparam 	IDLE 					= 5'b0_0000,
				REQ_BUS     		= 5'b0_0001,
				WAIT_ACK				= 5'b0_0010,
				ID_TRANSFER 		= 5'b0_0011,
				VGE_CMD_PHASE0    = 5'b0_0100,
				VGE_CMD_PHASE1		= 5'b0_0101,
				VGE_CMD_PHASE2		= 5'b0_0110,
				
				// SRAM to SRAM
				TRF_SRAM_2_SRAM0 	= 5'b0_1000,
				TRF_SRAM_2_SRAM1 	= 5'b0_1001,
				TRF_SRAM_2_SRAM2 	= 5'b0_1010,
				TRF_SRAM_2_SRAM3 	= 5'b0_1011,
				// VRAM to SRAM (Read VRAM)
				TRF_VRAM_2_SRAM0 	= 5'b0_1100,
				TRF_VRAM_2_SRAM1 	= 5'b0_1101,
				TRF_VRAM_2_SRAM2 	= 5'b0_1110,
				TRF_VRAM_2_SRAM3 	= 5'b0_1111,
				// SRAM to VRAM (Write VRAM)
				TRF_SRAM_2_VRAM0 	= 5'b1_0000,
				TRF_SRAM_2_VRAM1 	= 5'b1_0001,
				TRF_SRAM_2_VRAM2 	= 5'b1_0010,
				TRF_SRAM_2_VRAM3 	= 5'b1_0011,
				// FILL to SRAM 
				TRF_FILL_2_SRAM0 	= 5'b1_1100,
				TRF_FILL_2_SRAM1 	= 5'b1_1101,
				TRF_FILL_2_SRAM2 	= 5'b1_1110,
				
				RELEASE_BUS			= 5'b1_1111;
						

reg [1:0]	SDMA_Control_Reg_i_EDGE;

// Find the Edge of the Start Bit - it will need to be returned to 0
always @ (posedge Bus_Clk_i)
begin
	SDMA_Control_Reg_i_EDGE[0] <= SDMA_Control_Reg_i[7];
	SDMA_Control_Reg_i_EDGE[1] <= SDMA_Control_Reg_i_EDGE[0];
end						

always @ (posedge Bus_Clk_i)
begin
	if (Rst_i) begin
			SDMA_Bus_RW_o 						<= 1'b1;
			Bus_Reqn_o							<= 1'b1;
			SDMA_Y_Size							<= 16'h0000;
			StateMachine						<= IDLE;
			StateStateMachine					<= IDLE;
			SDMA_In_Progress_o				<= 1'b0;
			// VGE Transfer
			SDMA_RW								<=	1'b1;
			SDMA_CMD_Phase						<= 2'b00;
			SDMA_Write_CMD_o					<= 1'b0;
			SDMA_DATA_2_Write_Write_Req_o <= 1'b0;
			SDMA_DATA_2_Read_Req_i			<= 1'b0;
		
	end
	else begin
	
	case (StateMachine)
	
	IDLE:	begin 
	// When the Enable is 1
		if ((SDMA_Control_Reg_i_EDGE[1:0] == 2'b01) && (SDMA_Control_Reg_i[0] )) begin
			StateMachine	<= REQ_BUS;
			Bus_Reqn_o		<= 1'b0;	// Go and request the bus
		end
	end
	
	// This I will keep for a wait state now.
	REQ_BUS: begin
		StateMachine	<= WAIT_ACK;
		end
	
	
	WAIT_ACK: begin
	// Ack will go low when we will have full control over.
		if (Bus_Ackn_i) begin
			StateMachine	<= WAIT_ACK;
		end
		else begin
			SDMA_In_Progress_o <= 1'b1;
			StateMachine		 <= ID_TRANSFER;
			
		end
	end 
	
	// Let's figure what is transfer is requestion
	ID_TRANSFER: begin
		if (SDMA_Control_Reg_i[2])	begin //0 - Transfer Src -> Dst, 1 - Fill Destination with "Byte2Write"
			StateMachine 	<= TRF_FILL_2_SRAM0;
		end
		else begin
			if ((SRC_DMA_ATTR == 2'b10) && ( DST_DMA_ATTR == 2'b00)) begin // Read VRAM -->> RAM
				StateMachine		<= VGE_CMD_PHASE0;	// Send the Command immidiatly
				StateStateMachine <= TRF_VRAM_2_SRAM0;
				SDMA_CMD_Phase		<= 2'b00;				// prepare to send the first phase of the command
				SDMA_RW				<= 1'b1;					// We are going to read
				SDMA_Write_CMD_o 	<= 1'b1;
			end
			else begin
				if ((SRC_DMA_ATTR == 2'b00) && ( DST_DMA_ATTR == 2'b10)) begin
					StateMachine		<= TRF_SRAM_2_VRAM0;	// Go fill the Buffer First, then Send the Command;
					SDMA_CMD_Phase		<= 2'b00;		// prepare to send the first phase of the command
					SDMA_RW				<= 1'b0;		// We are going to read
					SDMA_Bus_RW_o		<= 1'b1;		// Let's Prepare the groundwork
					SDMA_DATA_2_Write_Write_Req_o	<= 1'b1; // Start Writing in the FiFO
					StateStateMachine <= TRF_SRAM_2_VRAM1;					
				end
				else begin
					StateMachine	<= TRF_SRAM_2_SRAM0;
					SDMA_Bus_RW_o	<= 1'b1;					
				end
			end
		end	
	end
	
	// This is to Charge the CMD FIFO to tell the VGE that we need to transfer data in or out
	VGE_CMD_PHASE0: begin 
		SDMA_CMD_Phase		<= 2'b01;		// prepare to send the first phase of the command
		StateMachine		<= VGE_CMD_PHASE1;		
	end
	
	VGE_CMD_PHASE1: begin
		SDMA_CMD_Phase		<= 2'b10;		// prepare to send the first phase of the command
		StateMachine		<= VGE_CMD_PHASE2;		
	end

	// This is when we put the stride in
	VGE_CMD_PHASE2: begin
		SDMA_Write_CMD_o 	<= 1'b0;
		StateMachine 		<= StateStateMachine;
	end
	
	
	// SRAM to SRAM
	// Linear 2D Transfer in RAM
	// Let's begin 
	// Read Here 
	TRF_SRAM_2_SRAM0: begin
		if (Linear_Counter == {SDMA_Y_Size_i[7:0], SDMA_X_Size_i} )	begin 
			StateMachine 	<= RELEASE_BUS;
		end
		else begin
			if (CPU_2_VCE_WriteFull_SDMA_i) begin
				StateMachine	<= TRF_SRAM_2_SRAM0;		// Keep Going till we reach the goal!
			end
			else begin
				SDMA_Bus_RW_o	<= 1'b0;				
				StateMachine	<= TRF_SRAM_2_SRAM1;		// Keep Going till we reach the goal!
			end
		end		
	end
	
	// Write Here -
	TRF_SRAM_2_SRAM1: begin
			if (CPU_2_VCE_WriteFull_SDMA_i) begin		// Wait for the SDMA to empty
				StateMachine	<= TRF_SRAM_2_SRAM1;		
			end
			else begin
				SDMA_Bus_RW_o	<= 1'b1;	
				StateMachine	<= TRF_SRAM_2_SRAM0;
			end
	end
	

	TRF_SRAM_2_SRAM2: begin
		StateMachine	<= IDLE;		
	end

	
	TRF_SRAM_2_SRAM3: begin
		StateMachine	<= IDLE;		
	end
	
	// 
	// VRAM --> SRAM 
	// When Reading from VRAM we need to create the Message first and then wait for the data.
	// When we get here, the Command has been Sent and we are waiting for data
	// input		wire	[7:0] 	SDMA_DATA_2_Read_i,
	// output	reg				SDMA_DATA_2_Read_Req_i,
	// input		wire				SDMA_DATA_2_Read_Empty_i
	// Send the first bout of Data before calling the Command
	TRF_VRAM_2_SRAM0: begin

	end
	
	TRF_VRAM_2_SRAM1: begin
		StateMachine	<= TRF_VRAM_2_SRAM2;		
	end
	
	TRF_VRAM_2_SRAM2: begin
		StateMachine	<= TRF_VRAM_2_SRAM3;		
	end
	
	TRF_VRAM_2_SRAM3: begin 
		StateMachine	<= RELEASE_BUS;		
	end

	// 
	// SRAM --> VRAM 
	// Write to SRAM
	// SDMA Write FIFO
	// output	wire	[8:0]		SDMA_DATA_2_Write_o,
	// output	reg				SDMA_DATA_2_Write_Write_Req_o,
	// input		wire				SDMA_DATA_2_Write_Full_i,	
	TRF_SRAM_2_VRAM0: begin
	// This is to Fill the FiFO and then Send the Command
		if (Linear_Counter == (TotalByteTransfer - 24'h00_0001))	begin 	// Either we reach the Max before the Threshold of 1020 
			StateMachine 						<= VGE_CMD_PHASE0;
			SDMA_DATA_2_Write_Write_Req_o <= 1'b0;
			SDMA_Write_CMD_o 					<= 1'b1;			
		end
		else begin
			if (SDMA_DATA_2_Write_WrUseDW_i < 10'd1019) begin	// Or we do reach 1020 which means that the lOad is bigger then 1020.
				StateMachine	<= TRF_SRAM_2_VRAM0;					// But now we can go and Send the Command the FIFO is fifo
			end
			else begin
				StateMachine 	<= VGE_CMD_PHASE0;
				SDMA_DATA_2_Write_Write_Req_o <= 1'b0;				// Stop Writting to the FIFO
				SDMA_Write_CMD_o 	<= 1'b1;					
			end
		end	
	end
	// Here we are transfering the Balance;
	TRF_SRAM_2_VRAM1: begin
		SDMA_DATA_2_Write_Write_Req_o <= 1'b1;				// Stop Writting to the FIFO
		StateMachine	<= TRF_SRAM_2_VRAM2;					// But now we can go and Send the Command the FIFO is fifo				
	end
	
	TRF_SRAM_2_VRAM2: begin
		if (Linear_Counter == (TotalByteTransfer - 24'h00_0001))	begin 	// Either we reach the Max before the Threshold of 1020 
			StateMachine 						<= RELEASE_BUS;
			SDMA_DATA_2_Write_Write_Req_o <= 1'b0;
		end
		else begin
			if (SDMA_DATA_2_Write_WrUseDW_i >= 10'd1019) begin	// Or we do reach 1020 which means that the lOad is bigger then 1020.
				SDMA_DATA_2_Write_Write_Req_o <= 1'b0;				// Stop Writting to the FIFO			
				StateMachine	<= TRF_SRAM_2_VRAM3;					// But now we can go and Send the Command the FIFO is fifo
			end
			else begin
				StateMachine 	<= VGE_CMD_PHASE0;
				SDMA_DATA_2_Write_Write_Req_o <= 1'b0;				// Stop Writting to the FIFO
			end
		end	
		StateMachine	<= TRF_SRAM_2_VRAM3;
	end
	
	TRF_SRAM_2_VRAM3: begin 
		if (SDMA_DATA_2_Write_WrUseDW_i < 10'd511) begin	// Or we do reach 1020 which means that the lOad is bigger then 1020.
			SDMA_DATA_2_Write_Write_Req_o <= 1'b1;				// Stop Writting to the FIFO			
			StateMachine	<= TRF_SRAM_2_VRAM2;					// But now we can go and Send the Command the FIFO is fifo		
		end
		else begin
			StateMachine	<= TRF_SRAM_2_VRAM3;					// But now we can go and Send the Command the FIFO is fifo				
		end
	end	
	

	// 
	// FILL --> SRAM 
	TRF_FILL_2_SRAM0: begin
		StateMachine	<= TRF_FILL_2_SRAM1;
	end
	
	TRF_FILL_2_SRAM1: begin
		StateMachine	<= TRF_FILL_2_SRAM2;		
	end
	
	TRF_FILL_2_SRAM2: begin
		StateMachine	<= RELEASE_BUS;
	end
	
	// Be Done 
	RELEASE_BUS:		begin
		SDMA_In_Progress_o <= 1'b0;
		Bus_Reqn_o		<= 1'b1;	// Release the BUS, we are done.	
		StateMachine	<= IDLE;			
	end
	
	default: begin
		StateMachine	<= IDLE;	
	end
	endcase
	
	
	end
end


endmodule

