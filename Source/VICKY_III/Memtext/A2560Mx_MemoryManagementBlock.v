
module A2560Mx_MemoryManagementBlock(

input		wire				Reset_i,
input 		wire				Reset_100Mhz_i,
input    	wire   				CPU_1xClk_i,
input		wire				CPU_2xClk_i,				//66Mhz

output		wire				Counter_Reached_Count_o, 

input  		wire   [1:0]		Channel_Select_i,			// 00: Memtext, 01: SDMA, 1x: VDMA
input  		wire   				Channel_Select_Special_i,
input		wire				Time2Count_i,				// this signals comes from the Manager of Access that monitors when the CPU wants to getch data from RAM
// Memory Text Controller Port
input		wire				Text_Target_Enable_i,
input		wire				Text_Target_Load_i,
input		wire	[31:0]		Text_Target_Addy_Start_i,
input		wire	[31:0]		Text_Target_Addy_Stop_i,
output		reg		[31:0]		Text_Target_Data_o,		// Memory Text 
output		reg					Data_Output_Valid_o,
// EmuTOS Bitmap
input		wire				EmuTOS_Target_Enable_i,
input		wire				EmuTOS_Target_Load_i,
input		wire	[31:0]		EmuTOS_Target_Addy_Start_i,
input		wire	[31:0]		EmuTOS_Target_Addy_Stop_i,
output		reg		[31:0]		EmuTOS_Target_Data_o,		// Memory Text 
// SDMA Channel	(SRAM <-> SRAM)
input		wire	[31:0]		SDMA_Transaction_Addy_i,
input		wire				SDMA_Transaction_RDn_i,
input		wire				SDMA_Transaction_WRn_i,
input  		wire    [3:0]		SDMA_Transaction_BEn_i,
input		wire				SDMA_Copy_Fill_Strobe_i,
input		wire	[7:0]		SDMA_Data_2_Fill_i,
input       wire    [15:0]      SDMA_Data_2_Fill16_i,
input       wire    [31:0]      SDMA_Data_2_Fill32_i,
input       wire    [3:0]       SDMA_Data_Mask_i,
input       wire                SDMA_Double_Speed_DMA_i,
input  		wire   				SDMA_Quad_Speed_DMA_i,
// VDMA Channel	 (DDR3 <-> SRAM)
input		wire	[31:0]		VDMA_Transaction_Addy_i,
input		wire				VDMA_Transaction_RDn_i,
input		wire				VDMA_Transaction_WRn_i,
input  		wire    [3:0]		VDMA_Transaction_BEn_i,
input       wire    [3:0]       VDMA_Data_Mask_i,
input   	wire  	[31:0]		VDMA_2_SRAM_Data_In_i,
output   	wire  	[31:0]		VDMA_2_SRAM_Data_Out_o,
output   	wire   				VDMA_2_SRAM_Data_Out_Valid_o,

// Interface with CPU Mux Circuit
output		wire	[31:0]		VGE_Addy_o,				// 8Meg Max Memory the TinyVicky Can access
input		wire	[31:0]		VGE_VidMem_Data_i,
output		wire	[31:0]		VGE_VidMem_Data_o,
output		wire				VGE_VidMem_Readn_o,
output   	wire				VGE_VidMem_Writen_o,
output    	wire   	[3:0]		VGE_VidMem_BEn_o
);
// Channel Select[0] 
// Memtext or xDMA
// Channel Select[1] 
// 0: SDMA
// 1: VDMA
// Channel Select[1:0] 
// 00: Memtext Have Access to the SRAM
// 01: SDMA Have Access to the SRAM (to read/write) - Only work on SRAM
// 11: VDMA Have Access to the SRAM (to read or to write) Read from or write to <> DDR3
wire 				Compare_Condition_AEB;
wire 				Compare_Condition_AGEB;
wire 				Compare_Condition_ALB;
wire 				Compare_Condition_ANEB;
wire				WritingSomething;
wire 				Condition2Count;

reg 				Data_Output_Valid_Dly;
reg					Transfer_Direction;
reg		[31:0]		Counter_Start_Addy;
reg		[31:0]		Counter_Stop_Addy;
reg		[31:0]		Counter_Value_2_Compare;
reg					Counter_Enable_i;
reg					Counter_Load_i;
reg   				Memory_LSBn;
reg  				Memory_MSBn;
reg 	[31:0]		CPU_Counter_Output;
//
reg     [3:0]		Direct_BEn;
reg 	[31:0]		Direct_ADDY;
reg 				Direct_RDn;
reg 				Direct_WRn;
reg 	[31:0]		Direct_DATA;

// Direction of the Counter itself
reg 	[31:0] 		Cnt_Val_2_Comp_Registered;
//reg  				Time2Count_EDGE;
//wire   				Time2Count_Once; 


always @ (posedge CPU_2xClk_i) begin
//	Time2Count_EDGE		<= Time2Count_i;
	if ( Channel_Select_Special_i ) begin 
		Counter_Enable_i 	<= Text_Target_Enable_i;
		Counter_Load_i 		<= Text_Target_Load_i;
		Counter_Start_Addy 	<= Text_Target_Addy_Start_i[31:0];
		Counter_Stop_Addy   <= Text_Target_Addy_Stop_i[31:0];
	end 
	else begin 
		Counter_Enable_i 	<= EmuTOS_Target_Enable_i;
		Counter_Load_i 		<= EmuTOS_Target_Load_i;
		Counter_Start_Addy 	<= EmuTOS_Target_Addy_Start_i[31:0];
		Counter_Stop_Addy   <= EmuTOS_Target_Addy_Stop_i[31:0];		
	end 
end 

//assign Time2Count_Once = ({Time2Count_EDGE, Time2Count_i} == 2'b01);
														// Read   : // Write
assign Condition2Count = ( Counter_Enable_i & Compare_Condition_ALB & Time2Count_i); // Change ALB to AEB

always @ (posedge CPU_2xClk_i)
begin
	if ( Reset_100Mhz_i ) begin
		Cnt_Val_2_Comp_Registered <= 32'h0000_0000;
	end
	else begin
		if (Counter_Load_i) begin
				Cnt_Val_2_Comp_Registered <= Counter_Stop_Addy;
		end
	end
end

// Start of Frame Counter
always @ ( posedge CPU_2xClk_i) begin 
	if ( Reset_100Mhz_i ) begin 
		CPU_Counter_Output <= 32'h0000_0000;
	end
	else begin 
		if ( Counter_Load_i ) begin //SLOAD
			CPU_Counter_Output <= Counter_Start_Addy;
		end
		else begin
			if ( Condition2Count ) begin 	// Counter Enable
					CPU_Counter_Output <= CPU_Counter_Output + 32'd4;	// New Count 2
			end
		end 
	end
end 
/*
Counter_Channel_i bits
[3][2][1][0]
 0  0  0  0		Memory Text Target (Read - Words)
 0  0  0  1		BitMap - Counter Access (Read - Words)
 0  0  1  0		TileMap - Counter Access (Read - Words)
 0  0  1  1		Sprites - Counter Access (Read - Bytes)
 1  0  x  x     SDMA - Direct Access (Read/Write - Bytes/Words)
 1  1  x  x     Line Drawing (Write Only - Bytes)
*/

/*
input   	wire  	[31:0]		VDMA_Data_In_i,
output   	reg  	[31:0]		VDMA_Data_Out_o,
output   	reg   				VDMA_Data_Out_Valid_o,
*/
always @ (posedge CPU_2xClk_i) begin
	// SDMA
		Direct_BEn  <= Channel_Select_i[1] ? (VDMA_Transaction_BEn_i | VDMA_Data_Mask_i[3:0]) : (SDMA_Transaction_BEn_i | SDMA_Data_Mask_i[3:0]);
		Direct_ADDY <= Channel_Select_i[1] ? {2'b00, VDMA_Transaction_Addy_i[31:2]} : {2'b00, SDMA_Transaction_Addy_i[31:2]};			// Point to 32bits Data
		Direct_RDn  <= Channel_Select_i[1] ? VDMA_Transaction_RDn_i : SDMA_Transaction_RDn_i;
		Direct_WRn  <= Channel_Select_i[1] ? VDMA_Transaction_WRn_i : SDMA_Transaction_WRn_i;
		//Direct_DATA <= ( SDMA_Copy_Fill_Strobe_i ?  SDMA_Double_Speed_DMA_i ? {2{SDMA_Data_2_Fill16_i}} : {4{SDMA_Data_2_Fill_i}} : VGE_VidMem_Data_i );

		casex( {Channel_Select_i[1], SDMA_Copy_Fill_Strobe_i, SDMA_Quad_Speed_DMA_i, SDMA_Double_Speed_DMA_i}   )
			// SDMA
			4'b00xx: begin Direct_DATA <= VGE_VidMem_Data_i; end 
			4'b0100: begin Direct_DATA <= {4{SDMA_Data_2_Fill_i}}; end	// 4x Bytes
			4'b0101: begin Direct_DATA <= {2{SDMA_Data_2_Fill16_i}}; end 	// 2x Short
			4'b0110: begin Direct_DATA <= SDMA_Data_2_Fill32_i; end 	// 1x Long
			4'b0111: begin Direct_DATA <= VGE_VidMem_Data_i; end 
			// VDMA
			4'b1xxx: begin Direct_DATA <= VDMA_2_SRAM_Data_In_i; end 
		endcase
end 

// Channel_Select has been inverted so it is 0 = Memtext, 1 = DMA
//                                               DMA         : MEMTEXT
assign VGE_VidMem_BEn_o			= Channel_Select_i[0] ? Direct_BEn : 4'b0000;
assign VGE_Addy_o 				= Channel_Select_i[0] ? Direct_ADDY : {CPU_Counter_Output[31:2], 2'b00};
assign VGE_VidMem_Readn_o 		= Channel_Select_i[0] ? Direct_RDn  : 1'b0;
assign VGE_VidMem_Writen_o 		= Channel_Select_i[0] ? Direct_WRn  : 1'b1;	
assign VGE_VidMem_Data_o   		= Channel_Select_i[0] ? Direct_DATA : 32'h0000_0000;
assign Compare_Condition_AEB 	= ( CPU_Counter_Output == Cnt_Val_2_Comp_Registered );
assign Compare_Condition_ALB 	= ( CPU_Counter_Output < Cnt_Val_2_Comp_Registered );
assign Counter_Reached_Count_o 	= Compare_Condition_AEB;

// Ready Latency
reg [1:0] DMA_Read_Strobe_Dly;
reg [31:0] VGE_VidMem_Data_Dly;

always @ (posedge CPU_2xClk_i)
begin
	if ( Reset_100Mhz_i ) begin
		Data_Output_Valid_Dly <= 1'b0;
	end
	else begin
		Data_Output_Valid_Dly 	<= Condition2Count;
		Data_Output_Valid_o 	<= Data_Output_Valid_Dly;
		VGE_VidMem_Data_Dly		<= VGE_VidMem_Data_i;

		Text_Target_Data_o 		<= VGE_VidMem_Data_Dly;
		EmuTOS_Target_Data_o    <= VGE_VidMem_Data_Dly;
		// VDMA Read from SRAM Output + Output Valid Bit
		DMA_Read_Strobe_Dly[0]	<= !Direct_RDn;
		DMA_Read_Strobe_Dly[1]  <= DMA_Read_Strobe_Dly[0];
		VDMA_2_SRAM_Data_Out_o 		<= VGE_VidMem_Data_i;
		VDMA_2_SRAM_Data_Out_Valid_o   <= DMA_Read_Strobe_Dly[1];
	end
end


/*
wire [143:0] TP;
wire  Trigger;

assign TP[31:0] 	= Counter_Start_Addy;
assign TP[63:32] 	= Counter_Stop_Addy;
assign TP[95:64] 	= VGE_VidMem_Data_i;
assign TP[127:96]	= EmuTOS_Target_Data_o;
assign TP[128]  	= Counter_Enable_i;
assign TP[129]  	= Counter_Load_i;
assign TP[130]		= Condition2Count;
assign TP[131]		= VGE_VidMem_Readn_o;
assign TP[132]		= VGE_VidMem_Writen_o;
assign TP[136:133]  = VGE_VidMem_BEn_o[3:0];
assign TP[137] 		= Data_Output_Valid_o;

assign Trigger = Condition2Count & (EmuTOS_Target_Addy_Start_i == 32'h0000_0000);

TinyChipScope CHIPSCOPE68K (
	.acq_data_in    ( TP ),    //        tap.acq_data_in
	.acq_trigger_in ( Trigger ), //           .acq_trigger_in
	.acq_clk        ( CPU_2xClk_i ),        //    acq_clk.clk
	.trigger_in     ( Trigger )      // trigger_in.trigger_in
);
*/
endmodule


