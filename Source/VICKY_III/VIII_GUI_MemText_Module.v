module VIII_GUI_MemText_Module ( 
// Reset
input		wire				Reset_i,                // System Reset
// Clocks
input 		wire  				iBUS_1xClk_i,			// 25Mhz or 33Mhz
input 		wire  				iBUS_2xClk_i,			// 50Mhz or 66Mhz
input		wire				iBUS_4xClk_i,			// 100Mhz or 133Mhz
input  		wire   				VideoClk_i,
// Buses
input		wire	[31:0]		iBUS_A_i,
input		wire				iBUS_A_Valid_i,
input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]		iBUS_D16_i,
input		wire	[31:0]		iBUS_D32_i,
input		wire	[1:0]		iBUS_D_Siz_i,
input		wire				iBUS_RWn_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i,
// Interface Signals
input  		wire 	[1:0] 		Mstr_Ctrl_Video_Mode_CPU_i,
input 		wire 				Mstr_Ctrl_MemText_Enable_i,
input 		wire 				Mstr_Ctrl_MemText_ShowBG_i,
input 		wire 				Mstr_Ctrl_FONT_Show_BG_in_Overlay_i,
input 		wire 				Mstr_Ctrl_TOS_Graph_Enable_i,
input 		wire 	[1:0]		Mstr_Ctrl_TOS_Graph_Mode_i,
input 		wire 				Mstr_Ctrl_Game_GUI_Mode_i,

input       wire                CS_MEMTEXT_i,
input       wire                CS_MEMTEXT_LUT_i,
input       wire                CS_MEMTEXT_FONT_i,
input       wire                CS_EMUTOS_GRAPH_i,

output      wire    [31:0]		DataOut_MEMTEXT_o,
output      wire    [31:0]		DataOut_MEMTEXT_LUT_o,
output      wire    [31:0]		DataOut_MEMTEXT_FONT_o,
output      wire    [31:0]		DataOut_EMUTOS_Graph_o,
//
input 		wire   				VideoClock_i,
input 		wire  				SOF_Channel_i,
input  		wire 				HBlanking_i,
input  		wire 				VBlanking_i,
input  		wire 				VGE_Engine_VBlanking_1L_i,
input  		wire 				VGE_Engine_VBlanking_2L_i,
input  		wire 	[11:0] 		HLineCount_i,
input  		wire 	[11:0] 		HPixelCount_i,
// Memory Text
output      wire                MEMText_Mono_Font_Out_o,
output 		wire  				MEMText_Mono_Cursor_Out_o,
output   	wire   				MEMText_ClrBGisZero_o,
output      wire    [31:0]      MEMText_RGB_o,
// TOSGRAPH
output  	wire    [31:0]		TOSGRAPH_RGB_o,
// CPU Access VSRAM Buffer A - VSRAM Buffer B
input		wire				iBUS_CS_VRAM_A_i,
input		wire				iBUS_CS_VRAM_B_i,
output  	wire  	[31:0]		iBUS_D_VRAM_A_o,
output  	wire  	[31:0]		iBUS_D_VRAM_B_o,
// Memory Buffer Management Signals
output 		wire  				Wait_BufferA_o,
output 		wire  				Wait_BufferB_o,
output 		wire   				Wait_BufferA_TA_o,
output 		reg   				Wait_BufferB_TA_o,
// Video RAM Bank A
input		wire	[31:0]		VRAM_A_DQ_i,
output		wire		[31:0]		VRAM_A_DQ_o,
output		reg		[3:0]		VRAM_A_BEn_o,
output		reg		[19:0]		VRAM_A_Addy_o,
output		reg					VRAM_A_OEn_o,
output		reg					VRAM_A_WEn_o,
// Video RAM Bank B
input		wire	[31:0]		VRAM_B_DQ_i,
output		wire		[31:0]		VRAM_B_DQ_o,
output		reg		[3:0]		VRAM_B_BEn_o,	
output		reg		[19:0]		VRAM_B_Addy_o,
output		reg					VRAM_B_OEn_o,
output		reg					VRAM_B_WEn_o
);


wire	[31:0]		LOCAL_VRAM_B_DQ_i;
wire	[31:0]		LOCAL_VRAM_B_DQ_o;
wire	[3:0]		LOCAL_VRAM_B_BEn_o;	
wire	[31:0]		LOCAL_VRAM_B_Addy_o;
wire				LOCAL_VRAM_B_OEn_o;
wire				LOCAL_VRAM_B_WEn_o;

wire     			Mux_Bus_TosGraph;
wire     			Mux_Bus_MemText;
wire  				Wait_TA_TosGraph;
wire  				Wait_TA_MemText;

/*
wire [143:0] TP;
wire  Trigger;

assign TP[31:0] 	= VRAM_B_Addy_o;
assign TP[63:32]  	= VRAM_A_DQ_i;
assign TP[95:64] 	= VRAM_A_DQ_o;
assign TP[96]  		= VRAM_B_OEn_o;
assign TP[97]  		= VRAM_B_WEn_o;
assign TP[101:98]	= VRAM_B_BEn_o;
//
assign TP[102]		= Mux_Bus_TosGraph;
assign TP[103] 		= Wait_TA_TosGraph;
//
assign TP[104]		= Mux_Bus_MemText;
assign TP[105] 		= Wait_TA_MemText;
//
assign TP[106]		= iBUS_CS_VRAM_B_i;
assign TP[143:107]  = 0;


assign Trigger = Mux_Bus_TosGraph | Mux_Bus_MemText;

TinyChipScope CHIPSCOPE68K (
	.acq_data_in    ( TP ),    //        tap.acq_data_in
	.acq_trigger_in ( Trigger ), //           .acq_trigger_in
	.acq_clk        ( iBUS_2xClk_i ),        //    acq_clk.clk
	.trigger_in     ( Trigger )      // trigger_in.trigger_in
);
*/

assign Wait_BufferA_o = 1'b0;
assign Wait_BufferA_TA_o = 1'b1;
assign Wait_BufferB_o = Mux_Bus_TosGraph | Mux_Bus_MemText;	// When 1, the TA circuit will wait for us to give out a 0 pulse when ready
//assign Wait_BufferB_TA_o = Wait_TA_TosGraph | Wait_TA_MemText;

always @ ( * ) begin 
	case( {Mstr_Ctrl_MemText_Enable_i, Mstr_Ctrl_TOS_Graph_Enable_i}  )
		2'b00: begin Wait_BufferB_TA_o = Wait_TA_TosGraph; end 
		2'b01: begin Wait_BufferB_TA_o = Wait_TA_TosGraph; end 
		2'b10: begin Wait_BufferB_TA_o = Wait_TA_MemText;  end 
		2'b11: begin Wait_BufferB_TA_o = Wait_TA_TosGraph; end 
	endcase
end 
//assign Wait_BufferB_o = Mux_Bus_TosGraph;	// When 1, the TA circuit will wait for us to give out a 0 pulse when ready
//assign Wait_BufferB_TA_o = Wait_TA_TosGraph;


reg [31:0] iBUS_D32;

always @ ( * ) begin 
	case ( iBUS_D_Siz_i )
	2'b00: begin iBUS_D32 = iBUS_D32_i;  end 
	2'b01: begin iBUS_D32 = {iBUS_D8_i, iBUS_D8_i, iBUS_D8_i, iBUS_D8_i};  end 
	2'b10: begin iBUS_D32 = {iBUS_D16_i, iBUS_D16_i};  end 
	2'b11: begin iBUS_D32 = iBUS_D32_i;  end 
	endcase
end 

//$0080_0000 - $009F_FFFF (2M) 1Mx32 = 4M
//$00A0_0000 - $00BF_FFFF (2M) 1Mx32 = 4M
// A BANK
/*
assign VRAM_A_Addy_o 	= iBUS_A_i[21:2];
assign VRAM_A_BEn_o 	= {!iBUS_BE_i[3], !iBUS_BE_i[2], !iBUS_BE_i[1], !iBUS_BE_i[0]};
assign VRAM_A_OEn_o 	= !( iBUS_RWn_i & iBUS_CS_VRAM_A_i);
assign VRAM_A_WEn_o 	= !( iBUS_WE_i & iBUS_CS_VRAM_A_i & !iBUS_1xClk_i);
*/
assign iBUS_D_VRAM_A_o 	= VRAM_A_DQ_i;
assign VRAM_A_DQ_o 		= iBUS_D32;

always @ ( posedge iBUS_2xClk_i ) begin 
	VRAM_A_Addy_o 		<= iBUS_A_i[21:2];
	VRAM_A_BEn_o 		<= {!iBUS_BE_i[3], !iBUS_BE_i[2], !iBUS_BE_i[1], !iBUS_BE_i[0]};
	VRAM_A_OEn_o 		<= !( iBUS_RWn_i & iBUS_CS_VRAM_A_i);
	VRAM_A_WEn_o 		<= !( iBUS_WE_i & iBUS_CS_VRAM_A_i & !iBUS_1xClk_i);
//	iBUS_D_VRAM_A_o 	<= VRAM_A_DQ_i;
//	VRAM_A_DQ_o 		<= iBUS_D32;
end 

// B BANK
/*
assign VRAM_B_Addy_o    	= ( Mux_Bus_TosGraph | Mux_Bus_MemText ) ?  LOCAL_VRAM_B_Addy_o[21:2]  	: iBUS_A_i[21:2];
assign VRAM_B_BEn_o     	= ( Mux_Bus_TosGraph | Mux_Bus_MemText ) ?  LOCAL_VRAM_B_BEn_o   		: {!iBUS_BE_i[3], !iBUS_BE_i[2], !iBUS_BE_i[1], !iBUS_BE_i[0]};
assign VRAM_B_OEn_o     	= ( Mux_Bus_TosGraph | Mux_Bus_MemText ) ?  LOCAL_VRAM_B_OEn_o   		: !( iBUS_RWn_i & iBUS_CS_VRAM_B_i);
assign VRAM_B_WEn_o     	= ( Mux_Bus_TosGraph | Mux_Bus_MemText ) ?  LOCAL_VRAM_B_WEn_o   		: !( iBUS_WE_i & iBUS_CS_VRAM_B_i & !iBUS_1xClk_i);
*/
assign VRAM_B_DQ_o 			= ( Mux_Bus_TosGraph | Mux_Bus_MemText ) ?  LOCAL_VRAM_B_DQ_o  			:  iBUS_D32;

assign LOCAL_VRAM_B_DQ_i 	= VRAM_B_DQ_i;
assign iBUS_D_VRAM_B_o  	= VRAM_B_DQ_i;

always @ ( posedge iBUS_2xClk_i ) begin 
	VRAM_B_Addy_o    	<= ( Mux_Bus_TosGraph | Mux_Bus_MemText ) ?  LOCAL_VRAM_B_Addy_o[21:2]  	: iBUS_A_i[21:2];
	VRAM_B_BEn_o     	<= ( Mux_Bus_TosGraph | Mux_Bus_MemText ) ?  LOCAL_VRAM_B_BEn_o   			: {!iBUS_BE_i[3], !iBUS_BE_i[2], !iBUS_BE_i[1], !iBUS_BE_i[0]};
	VRAM_B_OEn_o     	<= ( Mux_Bus_TosGraph | Mux_Bus_MemText ) ?  LOCAL_VRAM_B_OEn_o   			: !( iBUS_RWn_i & iBUS_CS_VRAM_B_i);
	VRAM_B_WEn_o     	<= ( Mux_Bus_TosGraph | Mux_Bus_MemText ) ?  LOCAL_VRAM_B_WEn_o   			: !( iBUS_WE_i & iBUS_CS_VRAM_B_i & !iBUS_1xClk_i);
//	VRAM_B_DQ_o 		<= ( Mux_Bus_TosGraph | Mux_Bus_MemText ) ?  LOCAL_VRAM_B_DQ_o  			:  iBUS_D32;
end 

// Inputs
wire				VSRAM_Data_Valid;
wire	[31:0]		VSRAM_Data_2_MEMTEXT;
wire				Counter_Reached_Count;
// MemText Graphics 
wire				MEMTEXT_Counter_Enable_MT;
wire				MEMTEXT_Counter_Load_MT;
wire	[31:0]		MEMTEXT_Target_Addy_Start;
wire	[31:0]		MEMTEXT_Target_Addy_Stop;
wire   				Channel_Select;
// Bitmap Graphics EMUTOS Encoding Style
wire    		    EMUTOS_Target_Enable;
wire    		    EMUTOS_Target_Load;
wire    [31:0]	    EMUTOS_Target_Addy_Start;
wire    [31:0]	    EMUTOS_Target_Addy_Stop;
wire    [31:0]	    EMUTOS_Target_Data;

/*
reg SpecialChannel;
always @ ( * ) begin 
	case( {Mstr_Ctrl_TOS_Graph_Enable_i, Mstr_Ctrl_TOS_Graph_Enable_i})
	2'b00: SpecialChannel = 1'b0;
	2'b01: SpecialChannel = 1'b0;
	2'b10: SpecialChannel = 1'b1;
	2'b11: SpecialChannel = 1'b0;
	endcase
end 
*/

//////////////////////////////////////
//////////////////////////////////////
//
// CHANNEL B MANAGEMENT
//
//////////////////////////////////////
//////////////////////////////////////
A2560x_GEN1_VSRAM_MMU GEN1_VSRAM_MMU(
    .Reset_i( Reset_i ),
    .CPU_1xClk_i( iBUS_1xClk_i ),
    .CPU_2xClk_i( iBUS_2xClk_i ),

    .Counter_Reached_Count_o( Counter_Reached_Count ), 

    .Channel_Select_i( 2'b00 ),					// 00: Memtext, 01: SDMA, 1x: VDMA
    .Channel_Select_Special_i( Mstr_Ctrl_MemText_Enable_i ),  		// 0: Ch0 (TOSGRAPH), 1: Ch1 
    .Time2Count_i( 1'b1 ),						// this signals comes from the Manager of Access that monitors when the CPU wants to getch data from RAM
    .Data_Output_Valid_o( VSRAM_Data_Valid ),
// Memory Text Controller Port
    .Ch0_Target_Enable_i( MEMTEXT_Counter_Enable_MT ),
    .Ch0_Target_Load_i( MEMTEXT_Counter_Load_MT ),
    .Ch0_Target_Addy_Start_i( MEMTEXT_Target_Addy_Start ),
    .Ch0_Target_Addy_Stop_i( MEMTEXT_Target_Addy_Stop ),
    .Ch0_Target_Data_o( VSRAM_Data_2_MEMTEXT ),
// EmuTOS Bitmap
    .Ch1_Target_Enable_i( EMUTOS_Target_Enable ),
    .Ch1_Target_Load_i( EMUTOS_Target_Load ),
    .Ch1_Target_Addy_Start_i( EMUTOS_Target_Addy_Start ),
    .Ch1_Target_Addy_Stop_i( EMUTOS_Target_Addy_Stop ),
    .Ch1_Target_Data_o( EMUTOS_Target_Data ),
// SDMA Channel	(SRAM <-> SRAM)
    .Ch2_Transaction_Addy_i( 32'h0000_0000 ),
    .Ch2_Transaction_RDn_i( 1'b1 ),
    .Ch2_Transaction_WRn_i( 1'b1 ),
    .Ch2_Transaction_BEn_i( 4'b1111 ),
    .Ch2_Copy_Fill_Strobe_i( 1'b0 ),
    .Ch2_Data_2_Fill_i( 8'h00 ),
    .Ch2_Data_2_Fill16_i( 16'h0000 ),
    .Ch2_Data_2_Fill32_i( 32'h0000_0000 ),
    .Ch2_Data_Mask_i( 4'b0000 ),
    .Ch2_Double_Speed_DMA_i( 1'b0 ),
    .Ch2_Quad_Speed_DMA_i( 1'b0 ),
// VDMA Channel	 (DDR3 <-> SRAM)
    .Ch3_Transaction_Addy_i( 32'h0000_0000 ),
    .Ch3_Transaction_RDn_i( 1'b1 ),
    .Ch3_Transaction_WRn_i( 1'b1 ),
    .Ch3_Transaction_BEn_i( 4'b1111 ),
    .Ch3_Data_Mask_i( 4'b0000 ),
    .Ch3_2_SRAM_Data_In_i( 32'h5555_aaaa ),
    .Ch3_2_SRAM_Data_Out_o(  ),
	.Ch3_2_SRAM_Data_Out_Valid_o(  ),
// Interface with Video SRAM
    .VSRAM_Addy_o( LOCAL_VRAM_B_Addy_o ),
    .VSRAM_VidMem_Data_i( LOCAL_VRAM_B_DQ_i ),
    .VSRAM_VidMem_Data_o( LOCAL_VRAM_B_DQ_o ),
    .VSRAM_VidMem_Readn_o( LOCAL_VRAM_B_OEn_o ),
    .VSRAM_VidMem_Writen_o( LOCAL_VRAM_B_WEn_o ),
    .VSRAM_VidMem_BEn_o( LOCAL_VRAM_B_BEn_o )
);

//////////////////////////////////////
//////////////////////////////////////
//
// MEMTEXT SYSTEM
//
//////////////////////////////////////
//////////////////////////////////////
A2560Mx_MEMTEXT_SM A2560Mx_MemText(
	.VGE_Engine_Rst_i( Reset_i ),
	.CPU_2xClk_i( iBUS_2xClk_i ),								//100Mhz
//	.Time2Count_i( Ext_Time_i ),				// this signals comes from the Manager of Access that monitors when the CPU wants to getch data from RAM	
	.Mstr_Ctrl_MemText_Enable_i( Mstr_Ctrl_MemText_Enable_i ),
	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode_CPU_i  ),
// From VMemory Interface Block
// Inputs
	.VRAM_Data_Valid_i( VSRAM_Data_Valid ),
	.VRAM_Data_2_MEMTEXT_i( VSRAM_Data_2_MEMTEXT ),			// used to be 32 - Now it is 16bits
	.Counter_Reached_Count_i( Counter_Reached_Count ),		// 
// Outputs
	.Counter_Enable_MT_o( MEMTEXT_Counter_Enable_MT ),
	.Counter_Load_MT_o( MEMTEXT_Counter_Load_MT ),
	.MEMTEXT_Target_Addy_Start_o( MEMTEXT_Target_Addy_Start ),
	.MEMTEXT_Target_Addy_Stop_o( MEMTEXT_Target_Addy_Stop ),
// CPU Interface
	.iBUS_Clk_i( iBUS_1xClk_i ),			// 50Mhz Clock
	.iBUS_A_i( iBUS_A_i ),				// 32bits Addy
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),	// Addy Valid
	.iBUS_D8_i( iBUS_D8_i ),			// Byte Transaction
	.iBUS_D16_i( iBUS_D16_i ),			// Short Transaction
	.iBUS_D32_i( iBUS_D32_i ),			// Short Transaction	
	.iBUS_RWn_i( iBUS_RWn_i ),			// R/Wn
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),		// Size
	.iBUS_BE_i( iBUS_BE_i ),			// Byte Enable [1:0] - 0 = High Byte, 1 = Low Byte
	.iBUS_WE_i( iBUS_WE_i ),			// Write Enable [3:0] - 0 = High Byte, 1 = Low Byte		

	.CS_VSRAM_B_i( iBUS_CS_VRAM_B_i  ),

// Control Registers and Data Output for the Memtext Registers + LUT
	.CS_MEMTEXT_i( CS_MEMTEXT_i ),           // This will be the CS for the Control Registers and LUT
	.DataOut_MEMTEXT_o( DataOut_MEMTEXT_o ),
// Chip Select and Dataout for the FONT Block
	.CS_MEMTEXT_LUT_i( CS_MEMTEXT_LUT_i ),
	.DataOut_MEMTEXT_LUT_o( DataOut_MEMTEXT_LUT_o ),

	.CS_MEMTEXT_FONT_i( CS_MEMTEXT_FONT_i ),
	.DataOut_MEMTEXT_FONT_o( DataOut_MEMTEXT_FONT_o ),	

// Video Section (Now we are dealing with 1280 x 960)
	.VideoClock_i( VideoClock_i ),
	.HBlanking_i( HBlanking_i ),
	.VBlanking_i( VBlanking_i ),
	.VBlanking_2LinePrecharge_i( VGE_Engine_VBlanking_2L_i ),
	.HLineCount_i( HLineCount_i ),
	.HPixelCount_i( HPixelCount_i ),
	.SOF_i( SOF_Channel_i ),

	.CAPTURING_DATA_MEM_o( Mux_Bus_MemText ),		// This goes high when active
	.Wait_BufferB_TA_o( Wait_TA_MemText ),
// Output 
	.Mono_Font_Output_o( MEMText_Mono_Font_Out_o ),
	.Mono_Cursor_Output_o( MEMText_Mono_Cursor_Out_o ),
	.MEMTxtClrBGisZero_o( MEMText_ClrBGisZero_o ),
	.MEMTEXT_RGB_o( MEMText_RGB_o )	//24bits RGB Out
);


//////////////////////////////////////
//////////////////////////////////////
//
// MEMTEXT SYSTEM
//
//////////////////////////////////////
//////////////////////////////////////

A2560x_EmuTOS_Bitmap TOS_GRAPH(  
	.Reset_i( Reset_i ),
	.iBUS_1xClk_i( iBUS_1xClk_i ),		// 33Mhz
	.iBUS_2xClk_i( iBUS_2xClk_i ),		// 66Mhz
	.iBUS_4xClk_i( iBUS_4xClk_i ),		// 66Mhz
	.VideoClk_i( VideoClock_i  ),

	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),		// = !TS - So when it comes to 1 the Address is Valid 
	.iBUS_D8_i( iBUS_D8_i ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_WE_i( iBUS_WE_i ),
//	
	.CS_VSRAM_B_i( iBUS_CS_VRAM_B_i  ),
	.iBUS_CS_TOS_GRAPH_i( CS_EMUTOS_GRAPH_i ),
	.iBUS_D_TOS_GRAPH_o( DataOut_EMUTOS_Graph_o ),

	.CAPTURING_DATA_MEM_o( Mux_Bus_TosGraph ),
	.Wait_BufferB_TA_o( Wait_TA_TosGraph  ),

	.Mstr_Ctrl_Video_Mode_i( Mstr_Ctrl_Video_Mode_CPU_i  ),
	.Mstr_Ctrl_TOS_GRAPH_Enable_i( Mstr_Ctrl_TOS_Graph_Enable_i ),		// From Master Control Register
	.Mstr_Ctrl_TOS_GRAPH_Mode_i( Mstr_Ctrl_TOS_Graph_Mode_i ),

	.VRAM_Data_Valid_i( VSRAM_Data_Valid  ),
	.VRAM_Data_2_TOS_GRAPH_i( EMUTOS_Target_Data ),			// used to be 32 - Now it is 16bits
	.Counter_Reached_Count_i( Counter_Reached_Count ),

	.Counter_Enable_MT_o( EMUTOS_Target_Enable ),
	.Counter_Load_MT_o( EMUTOS_Target_Load ),
	.TOS_Graph_Target_Addy_Start_o( EMUTOS_Target_Addy_Start ),
	.TOS_Graph_Target_Addy_Stop_o( EMUTOS_Target_Addy_Stop  ),

	.VideoClock_i( VideoClock_i ),
	.HBlanking_i( HBlanking_i ),
	.VBlanking_i( VBlanking_i ),
	.VBlanking_1LinePrecharge_i( VGE_Engine_VBlanking_1L_i ),
	.HLineCount_i( HLineCount_i ),
	.HPixelCount_i( HPixelCount_i ),
	.SOF_i( SOF_Channel_i ),

	.TOS_GRAPH_RGB_o( TOSGRAPH_RGB_o )
);




endmodule