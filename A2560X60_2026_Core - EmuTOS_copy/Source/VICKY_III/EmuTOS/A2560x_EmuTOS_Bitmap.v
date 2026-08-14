module A2560x_EmuTOS_Bitmap(  
// Reset
input		wire				Reset_i,
input		wire				iBUS_1xClk_i,		// 25/33Mhz
input		wire				iBUS_2xClk_i,		// 50/66Mhz
input		wire				iBUS_4xClk_i,		// 100/133Mhz
input 		wire 				VideoClk_i,			// 108Mhz
// Buses
input		wire	[31:0]		iBUS_A_i,
input		wire				iBUS_A_Valid_i,		// = !TS - So when it comes to 1 the Address is Valid 
input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]		iBUS_D16_i,
input		wire	[31:0]		iBUS_D32_i,
input		wire	[1:0]		iBUS_D_Siz_i,
input		wire				iBUS_RWn_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i,

input 		wire   				CS_VSRAM_B_i,

input		wire				iBUS_CS_TOS_GRAPH_i,
output	    wire	[31:0]		iBUS_D_TOS_GRAPH_o,

output	    wire				CAPTURING_DATA_MEM_o,
output 		wire   				Wait_BufferB_TA_o,

input       wire    [1:0]       Mstr_Ctrl_Video_Mode_i,
input  		wire  	            Mstr_Ctrl_TOS_GRAPH_Enable_i,		// From Master Control Register
input       wire    [1:0]       Mstr_Ctrl_TOS_GRAPH_Mode_i,
// From VMemory Interface Block
// Inputs
input		wire				VRAM_Data_Valid_i,
input		wire    [31:0]		VRAM_Data_2_TOS_GRAPH_i,			// used to be 32 - Now it is 16bits
input		wire			    Counter_Reached_Count_i,
// Outputs
output		reg				    Counter_Enable_MT_o,
output		reg				    Counter_Load_MT_o,
output		wire	[31:0]		TOS_Graph_Target_Addy_Start_o,
output		wire	[31:0]	    TOS_Graph_Target_Addy_Stop_o,
//Video Section
input		wire				VideoClock_i,
input		wire				HBlanking_i,
input		wire				VBlanking_i,
input   	wire  				VBlanking_1LinePrecharge_i,
input		wire	[11:0]		HLineCount_i,
input		wire	[11:0]		HPixelCount_i,
input		wire				SOF_i,

output      wire    [31:0]      TOS_GRAPH_RGB_o
);



reg [63:0]	OnebitperPixel_Slide;
reg [31:0]	TwobitperPixel_Slide_L;
reg [31:0]	TwobitperPixel_Slide_H;
reg [15:0] 	TwobitperPixel_Slide_LL;
reg [15:0]	TwobitperPixel_Slide_LH;
reg [15:0]	TwobitperPixel_Slide_HL;
reg [15:0] 	TwobitperPixel_Slide_HH;

reg [31:0]  TOSGraph_StartAddress;


reg 	[31:0]   	TOSGRAPH_REG[0:19];
reg 	[31:0]   	TOSGRAPH_REG1[0:3];
///////////////////////////////////////////
//// CONTROL REGISTERS
///////////////////////////////////////////
always @ (posedge iBUS_1xClk_i)
begin
	if (Reset_i)
	begin
		TOSGRAPH_REG[0]   <= 32'h0000_0000; 	// Memory Text Control, Cursor Register
		TOSGRAPH_REG[1]   <= 32'h0000_0000;	// Start Address Text
		TOSGRAPH_REG[2]   <= 32'h0000_0000;	// 
		TOSGRAPH_REG[3]   <= 32'h0000_0000;	// 

		TOSGRAPH_REG[4]   <= 32'hFFFF_FFFF;	// 0000 Bit_Value (B&W 0 - 0x00000000) (2bpp 0 - 0x00000000) (4bpp 0 - 0x00000000)
		TOSGRAPH_REG[5]   <= 32'hFF80_0000;	// 0001 Bit Value (B&W 1 - 0xFF808080) (2bpp 1 - 0x00000000) (4bpp 1 - 0x00000000)
		TOSGRAPH_REG[6]   <= 32'hFF00_8000;  // 0010 Bit Value                      (2bpp 2 - 0x00000000) (4bpp 2 - 0x00000000)
		TOSGRAPH_REG[7]   <= 32'hFF80_8000;	// 0011 Bit Value                      (2bpp 3 - 0x00000000) (4bpp 3 - 0x00000000)
		TOSGRAPH_REG[8]   <= 32'hFF00_0080;	// 0100 Bit Value											 (4bpp 4 - 0x00000000)                         
		TOSGRAPH_REG[9]   <= 32'hFF80_0080;	// 0101 Bit Value											 (4bpp 5 - 0x00000000)                         
		TOSGRAPH_REG[10]  <= 32'hFF00_8080;	// 0110 Bit Value											 (4bpp 6 - 0x00000000)                         
		TOSGRAPH_REG[11]  <= 32'hFF80_8080;	// 0111 Bit Value											 (4bpp 7 - 0x00000000)                         
		TOSGRAPH_REG[12]  <= 32'hFF40_4040;	// 1000 Bit Value											 (4bpp 8 - 0x00000000)                         
		TOSGRAPH_REG[13]  <= 32'hFF80_4000;	// 1001 Bit Value											 (4bpp 9 - 0x00000000)                         
		TOSGRAPH_REG[14]  <= 32'hFF20_8020;	// 1010 Bit Value											 (4bpp A - 0x00000000)                         
		TOSGRAPH_REG[15]  <= 32'hFF80_8020;	// 1011 Bit Value											 (4bpp B - 0x00000000)                         
		TOSGRAPH_REG[16]  <= 32'hFF40_2080;	// 1100 Bit Value											 (4bpp C - 0x00000000)                         
		TOSGRAPH_REG[17]  <= 32'hFF80_2040;	// 1101 Bit Value											 (4bpp D - 0x00000000)                         
		TOSGRAPH_REG[18]  <= 32'hFF20_8080;	// 1110 Bit Value											 (4bpp E - 0x00000000)                         
		TOSGRAPH_REG[19]  <= 32'hFF00_0000;	// 1111 Bit Value											 (4bpp F - 0x00000000) 
	end
	else
	begin
		if (iBUS_CS_TOS_GRAPH_i && !iBUS_RWn_i && (iBUS_D_Siz_i == 2'b00) && iBUS_WE_i) begin 
				TOSGRAPH_REG[iBUS_A_i[6:2]][31:0] <= iBUS_D32_i;	// Just allow Write Cycle to the first 8 Registers
				TOSGRAPH_REG1[iBUS_A_i[3:2]][31:0] <= iBUS_D32_i;
		end 
	end
end

assign iBUS_D_TOS_GRAPH_o = TOSGRAPH_REG1[iBUS_A_i[3:2]];

wire            TOSGraph_Enable = TOSGRAPH_REG[0][0];
wire  			TOSGraph_Double = TOSGRAPH_REG[0][1];	
reg [2:0] 	SOF_ReSync;
always @ ( posedge iBUS_2xClk_i ) begin 
	SOF_ReSync[0] <= SOF_i;
	SOF_ReSync[1] <= SOF_ReSync[0];
	if ( SOF_ReSync[1] == SOF_ReSync[0] )
		SOF_ReSync[2] <= SOF_ReSync[1];
end 

reg [2:0] 	SOF_ReSync4x;
always @ ( posedge iBUS_4xClk_i ) begin 
	SOF_ReSync4x[0] <= SOF_i;
	SOF_ReSync4x[1] <= SOF_ReSync4x[0];
	if ( SOF_ReSync4x[1] == SOF_ReSync4x[0] )
		SOF_ReSync4x[2] <= SOF_ReSync4x[1];
end 


reg 	  TOSGraph_Double_SOF;
reg [1:0] TOSGraph_Mode2x;
// Only update the Color Mode during a SOF so the change is not done in the middle of processing and then everything goes down the shitter!
always @ ( posedge iBUS_2xClk_i ) begin 
	if ( SOF_ReSync[2] ) begin
		TOSGraph_Mode2x 		<= TOSGRAPH_REG[0][3:2];       // 00 - 1bpp, 01 - 2bpp
		TOSGraph_Double_SOF <= TOSGRAPH_REG[0][1];		// Double Pixel (Decrease Resolution)
	end
end 

reg [1:0] TOSGraph_Mode4x;
// Only update the Color Mode during a SOF so the change is not done in the middle of processing and then everything goes down the shitter!
always @ ( posedge iBUS_4xClk_i ) begin 
	if ( SOF_ReSync4x[2] ) begin
		TOSGraph_Mode4x 		<= TOSGRAPH_REG[0][3:2];       // 00 - 1bpp, 01 - 2bpp
	end
end 

wire [31:0]     TOSGraph_Addy_Start = TOSGRAPH_REG[1];

wire [31:0]     TOSGraph_1bpp_0Val = TOSGRAPH_REG[4];
wire [31:0]     TOSGraph_1bpp_1Val = TOSGRAPH_REG[5];

wire [31:0]     TOSGraph_2bpp_0Val = TOSGRAPH_REG[4];
wire [31:0]     TOSGraph_2bpp_1Val = TOSGRAPH_REG[5];
wire [31:0]     TOSGraph_2bpp_2Val = TOSGRAPH_REG[6];
wire [31:0]     TOSGraph_2bpp_3Val = TOSGRAPH_REG[7];

wire [31:0]     TOSGraph_4bpp_0Val = TOSGRAPH_REG[4];
wire [31:0]     TOSGraph_4bpp_1Val = TOSGRAPH_REG[5];
wire [31:0]     TOSGraph_4bpp_2Val = TOSGRAPH_REG[6];
wire [31:0]     TOSGraph_4bpp_3Val = TOSGRAPH_REG[7];
wire [31:0]     TOSGraph_4bpp_4Val = TOSGRAPH_REG[8];
wire [31:0]     TOSGraph_4bpp_5Val = TOSGRAPH_REG[9];
wire [31:0]     TOSGraph_4bpp_6Val = TOSGRAPH_REG[10];
wire [31:0]     TOSGraph_4bpp_7Val = TOSGRAPH_REG[11];
wire [31:0]     TOSGraph_4bpp_8Val = TOSGRAPH_REG[12];
wire [31:0]     TOSGraph_4bpp_9Val = TOSGRAPH_REG[13];
wire [31:0]     TOSGraph_4bpp_AVal = TOSGRAPH_REG[14];
wire [31:0]     TOSGraph_4bpp_BVal = TOSGRAPH_REG[15];
wire [31:0]     TOSGraph_4bpp_CVal = TOSGRAPH_REG[16];
wire [31:0]     TOSGraph_4bpp_DVal = TOSGRAPH_REG[17];
wire [31:0]     TOSGraph_4bpp_EVal = TOSGRAPH_REG[18];
wire [31:0]     TOSGraph_4bpp_FVal = TOSGRAPH_REG[19];

wire [63:0] OnebitperPixel;
// 2BPS Encoding
wire [31:0] TwobitperPixel_L;
wire [31:0] TwobitperPixel_H;
// 4BPS Encoding
wire [15:0] TwobitperPixel_LL;
wire [15:0] TwobitperPixel_LH;
wire [15:0] TwobitperPixel_HL;
wire [15:0] TwobitperPixel_HH;

// EmuTOS bitmap Encoding
// 1bit per pixel (40 Packets)
// Packet16_Times4_Out[19][63:0]..Packet16_Times4_Out[0][63:0]. <--- Bit[63] is the one come out first!
//
// 2bits per pixel (80 Packets)
// First Pack of 16 Pixels        - Second Pack of 16 Pixels
// Packet16_Times4_Out[63:48] LSB - Packet16_Times4_Out[31:16]
// Packet16_Times4_Out[47:32] MSB - Packet16_Times4_Out[15:0]
//
// 4bits per pixel (160 Packets)
// First Pack of 16 Pixels      Color Encoding
// Packet16_Times4_Out[63:48] - Bit Weight[0]
// Packet16_Times4_Out[47:32] - Bit Weight[1]
// Packet16_Times4_Out[31:16] - Bit Weight[2]
// Packet16_Times4_Out[15:0]  - Bit Weight[3]

reg [7:0] 	Write_DP_Pointer;
reg [6:0] 	Read_DP_Pointer;

wire [15:0] Packet0_Data_Out;
wire [15:0] Packet1_Data_Out;
wire [15:0] Packet2_Data_Out;
wire [15:0] Packet3_Data_Out;
// 16 x 128 
always @ ( posedge iBUS_2xClk_i ) begin 
if ( Reset_i ) begin 
		Write_DP_Pointer <= 8'h00;
	end
	else begin 

		if (  Counter_Enable_MT_o ) begin 
			if ( VRAM_Data_Valid_i )
				Write_DP_Pointer <= Write_DP_Pointer + 8'h01;
		end 
		else begin 
			Write_DP_Pointer <= 8'h00;
		end 
	end
end
// SHORT 0
// 128x16
// Addy[6:0]
EMUTOS_DP64	Packet0 (
// Write Part
	// Write @ 50Mhz or 66Mhz
	.wrclock ( iBUS_2xClk_i ),
	.data ( VRAM_Data_2_TOS_GRAPH_i[31:16] ),
	.wraddress ( Write_DP_Pointer[7:1] ),
	.wren ( (Counter_Enable_MT_o & VRAM_Data_Valid_i & !Write_DP_Pointer[0]) ),
	// Read Port
	.rdaddress ( Read_DP_Pointer ),
	.rdclock ( iBUS_4xClk_i ),
	.q ( Packet0_Data_Out )
	);

// SHORT 1
EMUTOS_DP64	Packet1 (
// Write Part
	// Write @ 50Mhz or 66Mhz
	.wrclock ( iBUS_2xClk_i ),
	.data ( VRAM_Data_2_TOS_GRAPH_i[15:0] ),
	.wraddress ( Write_DP_Pointer[7:1] ),
	.wren ( (Counter_Enable_MT_o & VRAM_Data_Valid_i & !Write_DP_Pointer[0]) ),
	// Read Port
	.rdaddress ( Read_DP_Pointer ),
	.rdclock ( iBUS_4xClk_i ),
	.q ( Packet1_Data_Out )
);

// SHORT 2
EMUTOS_DP64	Packet2 (
// Write Part
	// Write @ 50Mhz or 66Mhz
	.wrclock ( iBUS_2xClk_i ),
	.data ( VRAM_Data_2_TOS_GRAPH_i[31:16] ),
	.wraddress ( Write_DP_Pointer[7:1] ),
	.wren ( (Counter_Enable_MT_o & VRAM_Data_Valid_i & Write_DP_Pointer[0]) ),
	// Read Port
	.rdaddress ( Read_DP_Pointer ),
	.rdclock ( iBUS_4xClk_i ),
	.q ( Packet2_Data_Out )
	);

// SHORT 4
// 1 Latency
EMUTOS_DP64	Packet3 (
	// Write @ 50Mhz or 66Mhz
	.wrclock ( iBUS_2xClk_i ),
	.data ( VRAM_Data_2_TOS_GRAPH_i[15:0] ),
	.wraddress ( Write_DP_Pointer[7:1] ),
	.wren ( ( Counter_Enable_MT_o & VRAM_Data_Valid_i & Write_DP_Pointer[0]) ),
	// Read Port
	.rdaddress ( Read_DP_Pointer ),
	.rdclock ( iBUS_4xClk_i ),
	.q ( Packet3_Data_Out )
);


assign OnebitperPixel[63:0]       	= {Packet0_Data_Out, Packet1_Data_Out, Packet2_Data_Out, Packet3_Data_Out};
assign TwobitperPixel_L[31:0] 		= {Packet0_Data_Out, Packet2_Data_Out  };
assign TwobitperPixel_H[31:0]    	= {Packet1_Data_Out, Packet3_Data_Out  };
assign TwobitperPixel_LL[15:0]    	= Packet0_Data_Out;
assign TwobitperPixel_LH[15:0]    	= Packet1_Data_Out;
assign TwobitperPixel_HL[15:0]		= Packet2_Data_Out;
assign TwobitperPixel_HH[15:0]    	= Packet3_Data_Out;


//1280 * 4 = 5120 / 16 = 320 Packet 
/////////////////////////////////
///////
/////// State Machine to Generate & Trigger the Capture of Data From memory
//////
/////////////////////////////////
reg [3:0]	SM_Addy;
reg [3:0]   SM_Post;
localparam 			ADDY_IDLE = 4'b0000,
					ADDY_SM0  = 4'b0001,
					ADDY_SM1  = 4'b0011,
					ADDY_SM2  = 4'b0010,
					ADDY_SM3  = 4'b0110,
					ADDY_SM4  = 4'b0111,
					ADDY_SM5  = 4'b0101,
					ADDY_SM6  = 4'b0100,
					ADDY_SM7  = 4'b1100,
					ADDY_SM8  = 4'b1101,//
					ADDY_SM9  = 4'b1111,// 
					ADDY_SM10 = 4'b1110,// 
					ADDY_SM11  = 4'b1010,
					ADDY_SM12  = 4'b1011,
					ADDY_SM13  = 4'b1001,
					ADDY_SM14  = 4'b1000;

localparam 			POST_IDLE = 4'b0000,
					POST_SM0  = 4'b0001,
					POST_SM1  = 4'b0011,
					POST_SM2  = 4'b0010,
					POST_SM3  = 4'b0110,
					POST_SM4  = 4'b0111,
					POST_SM5  = 4'b0101,
					POST_SM6  = 4'b0100,
					POST_SM7  = 4'b1100,
					POST_SM8  = 4'b1101,
					POST_SM9  = 4'b1111,
					POST_SM10 = 4'b1110,
					POST_SM11  = 4'b1010,
					POST_SM12  = 4'b1011,
					POST_SM13  = 4'b1001,
					POST_SM14  = 4'b1000;					

// Resync Visible_Local_Line_Counter_i
reg [11:0] VisibleLineReSync0, VisibleLineReSync1, VisibleLineReSync2;

reg  	  VBlanking_ReSync0, VBlanking_ReSync1, VBlanking_ReSync2;
reg [2:0] HBlanking_ReSync;

reg [11:0] Line_Counter;
reg [2:0] Mstr_Ctrl_Video_Mode_ReSync;
reg [15:0] NumberOfWords;
reg [15:0] Addy_Add;
reg [7:0] BitCounter;

// 1280 / 32bits = 40 Packets
// 2560 / 32bits = 80 Packets
// 5120 / 32bits = 160 Packets


always @ (*) begin 
	case( {TOSGraph_Double, TOSGraph_Mode2x[1:0]} )
		3'b000: begin NumberOfWords = 16'd160; end	//Needs to be in Bytes not in Words
		3'b001: begin NumberOfWords = 16'd320; end 
		3'b010: begin NumberOfWords = 16'd640; end
		3'b011: begin NumberOfWords = 16'd640; end
		3'b100: begin NumberOfWords = 16'd80; end	//Needs to be in Bytes not in Words
		3'b101: begin NumberOfWords = 16'd160; end 
		3'b110: begin NumberOfWords = 16'd320; end
		3'b111: begin NumberOfWords = 16'd320; end		
	endcase
end 
/*
// This is the number of Words
always @ (*) begin 
	case( {TOSGraph_Double, TOSGraph_Mode[1:0]})
		3'b000: begin Addy_Add = 16'd160; end	//Needs to be in Bytes not in Words 40x Long Words
		3'b001: begin Addy_Add = 16'd320; end 	//Needs to be in Bytes not in Words 80x Long Words
		3'b010: begin Addy_Add = 16'd640; end	//Needs to be in Bytes not in Words 160x Long Words
		3'b011: begin Addy_Add = 16'd640; end
		3'b100: begin Addy_Add = 16'd80; end	//Needs to be in Bytes not in Words 20x Long Words
		3'b101: begin Addy_Add = 16'd160; end   //Needs to be in Bytes not in Words 40x Long Words
		3'b110: begin Addy_Add = 16'd320; end	//Needs to be in Bytes not in Words 80x Long Words
		3'b111: begin Addy_Add = 16'd320; end		
	endcase
end 
*/
assign TOS_Graph_Target_Addy_Start_o = TOSGraph_StartAddress;
assign TOS_Graph_Target_Addy_Stop_o  = TOSGraph_StartAddress + {16'd0, NumberOfWords} + 32'd4; // I am adding an extra LONG because of the latency that cuts off the last LONG - So I am actually cheating here.

always @ ( posedge VideoClock_i ) begin 
	Mstr_Ctrl_Video_Mode_ReSync[0] <= Mstr_Ctrl_Video_Mode_i[0];
	Mstr_Ctrl_Video_Mode_ReSync[1] <= Mstr_Ctrl_Video_Mode_ReSync[0];
	if ( Mstr_Ctrl_Video_Mode_ReSync[1] == Mstr_Ctrl_Video_Mode_ReSync[0] )
		Mstr_Ctrl_Video_Mode_ReSync[2] <= Mstr_Ctrl_Video_Mode_ReSync[1];
end 

reg [2:0] HLineCount_Even;
// ReSync Line
always @ ( posedge iBUS_2xClk_i ) begin 
	//VBlanking_ReSync0 <= VBlanking_1LinePrecharge_i;		// Precharge here
	VBlanking_ReSync0 <= VBlanking_i;
	VBlanking_ReSync1 <= VBlanking_ReSync0;
	if ( VBlanking_ReSync1 == VBlanking_ReSync0) 
		VBlanking_ReSync2 <= VBlanking_ReSync1;		

	HBlanking_ReSync[0] <= HBlanking_i;
	HBlanking_ReSync[1] <= HBlanking_ReSync[0];
	if ( HBlanking_ReSync[1] == HBlanking_ReSync[0] )
			HBlanking_ReSync[2] <= HBlanking_ReSync[1];


	HLineCount_Even[0] <= HLineCount_i[0];
	HLineCount_Even[1] <= HLineCount_Even[0];
	if ( HLineCount_Even[1] == HLineCount_Even[0] )
			HLineCount_Even[2] <= HLineCount_Even[1];
end 


reg TOS_TA_RDY;
reg TOSGraph_Active;
assign CAPTURING_DATA_MEM_o 	= TOSGraph_Active;
assign Wait_BufferB_TA_o 		= TOS_TA_RDY;

/*
reg [8:0] line_Counter;
always @ ( posedge iBUS_2xClk_i ) begin 
	if ( Reset_i ) begin 
		line_Counter 			<= 9'd0;
	end 
	else begin 
		if (  VBlanking_ReSync2 ) begin 
			if ( HBlanking_ReSync[2] == 1'b0 )
					line_Counter <= line_Counter + 9'd1;
		end 
		else begin 
			line_Counter 			<= 9'd0;
		end 
	end 
end 
*/
reg [2:0] TOS_Graph_Enabled;
always @ ( posedge iBUS_2xClk_i ) begin 
	TOS_Graph_Enabled[0] <=  Mstr_Ctrl_TOS_GRAPH_Enable_i & TOSGraph_Enable;
	TOS_Graph_Enabled[1] <= TOS_Graph_Enabled[0];
	if ( TOS_Graph_Enabled[1] == TOS_Graph_Enabled[0] )
		TOS_Graph_Enabled[2] <= TOS_Graph_Enabled[1];
end 

always @ ( posedge iBUS_2xClk_i ) begin 
	if ( Reset_i ) begin 
		Counter_Enable_MT_o     <= 1'b0;
		Counter_Load_MT_o 	    <= 1'b0;
		TOSGraph_StartAddress   <= 32'h0000_0000;
		SM_Addy				    <= ADDY_IDLE;
		TOSGraph_Active		    <= 1'b0;
		TOS_TA_RDY 				<= 1'b0;
	end 
	else begin 

		case ( SM_Addy )

		ADDY_IDLE: begin
			if (  CS_VSRAM_B_i ) begin 
				SM_Addy	<= ADDY_SM8;
			end 
			else begin 
				// VBlanking = 1 (Active Display), = 0 - Blanking (DMA Time)
				if (  TOS_Graph_Enabled[2] ) begin 
					if (  VBlanking_ReSync2  ) begin 
						// Go Fetch Char & Colors every lines
						if ( ( HBlanking_ReSync[2] == 1'b0 ) && ( TOSGraph_Double_SOF ? !HLineCount_Even[2] : 1'b1)) begin 	// The State-machine will begin when HBLANK is low and there is no active transaction on the bank
							SM_Addy	<= ADDY_SM0;									// If there is an active transaction it ought not to last only for few clocks
							TOSGraph_Active		<= 1'b1;
							Counter_Load_MT_o 	<= 1'b1;
						end
					end 
					else begin 
					// Init The Pointer for Char
						TOSGraph_StartAddress <= TOSGraph_Addy_Start;
						Counter_Enable_MT_o <= 1'b0;
						Counter_Load_MT_o 	<= 1'b0;
						SM_Addy	<= ADDY_IDLE;					
					end 
				end
				else begin 
					TOSGraph_Active		<= 1'b0;					
					SM_Addy	<= ADDY_IDLE;
				end  
			end 
		end

		// Load the Addy in the Counter
		// Text + Attribute Here
		// Char_Color_Flag == 1'b0
		ADDY_SM0: begin
			Counter_Load_MT_o 	<= 1'b0;
			SM_Addy				<= ADDY_SM1;
		end 

		ADDY_SM1: begin
			Counter_Enable_MT_o <= 1'b1;			
			SM_Addy				<= ADDY_SM2;
		end  

		// Counter Enable Here
		ADDY_SM2: begin 	
			SM_Addy				<= ADDY_SM3;
		end

		// Wait for the Char & Attributes to fill the DP Memory for the next 8 Lines
		ADDY_SM3: begin 	
			if (Counter_Reached_Count_i) begin
				Counter_Enable_MT_o <= 1'b0;			// Stops the Counters (When we are here the Starts Addy = Stop Addy)
				TOSGraph_Active <= 1'b0;				// Access to the SRAM is over
				SM_Addy	<= ADDY_SM4;
			end
			else begin
				SM_Addy	<= ADDY_SM3;
			end
		end

		// Let's Begin the Post-Processing
		// TOS Active is now Low
		ADDY_SM4: begin
			TOSGraph_StartAddress <= TOSGraph_StartAddress + {16'd0, NumberOfWords};
			SM_Addy	<= ADDY_SM5;	
		end
		//just wait for the new address to take place.
		ADDY_SM5: begin
			SM_Addy	<= ADDY_SM6;
			TOS_TA_RDY <= 1'b1;
		end
		// TA = 1 - CPU will resume
		ADDY_SM6: begin 
			SM_Addy	<= ADDY_SM7;
			TOS_TA_RDY <= 1'b0;
		end 
		// TA = 0, by now, the next cycle has begun
		// Let's wait for the blanking to end before going back to the IDLE State
		ADDY_SM7: begin 
			if ( HBlanking_ReSync[2] == 1'b0 )
			 	SM_Addy	<= ADDY_SM7;
			else 
			 	SM_Addy	<= ADDY_IDLE;
		end 

		////
		//just wait for the new address to take place.
		ADDY_SM8: begin
			SM_Addy	<= ADDY_SM9;
		end
		// TA = 1 - CPU will resume
		ADDY_SM9: begin 
			SM_Addy	<= ADDY_SM10;
			TOS_TA_RDY <= 1'b1;				
		end 

		ADDY_SM10: begin 
			SM_Addy	<= ADDY_SM11;
		end 	

		ADDY_SM11: begin 
			SM_Addy	<= ADDY_IDLE;
			TOS_TA_RDY <= 1'b0;
		end 

		default: begin 
			SM_Addy	<= ADDY_IDLE;
		end 
		endcase


	end 
end 

reg [7:0] TOSGraph_Active_ReSync[0:7];
reg [2:0] TOSGraph_Double_ReSync;

always @ ( posedge iBUS_4xClk_i ) begin 
	TOSGraph_Active_ReSync[0][7:0] <= Write_DP_Pointer[7:0];	// Wait for the first full data to be present
	TOSGraph_Active_ReSync[1][7:0] <= TOSGraph_Active_ReSync[0][7:0];
	if ( TOSGraph_Active_ReSync[1][7:0] == TOSGraph_Active_ReSync[0][7:0] )
		TOSGraph_Active_ReSync[2][7:0] <= TOSGraph_Active_ReSync[1][7:0];

	TOSGraph_Double_ReSync[0] <= TOSGraph_Double;	// Wait for the first full data to be present
	TOSGraph_Double_ReSync[1] <= TOSGraph_Double_ReSync[0];
	if ( TOSGraph_Double_ReSync[1] == TOSGraph_Double_ReSync[0] )
		TOSGraph_Double_ReSync[2] <= TOSGraph_Double_ReSync[1];		
end

always @ ( posedge iBUS_4xClk_i ) begin 
	if ( Reset_i ) begin 
		SM_Post				<= POST_IDLE;
		Read_DP_Pointer 	<= 7'd0;
	end 
	else begin 

		case ( SM_Post )

		POST_IDLE: begin	
			// Wait for the First Count then begin, and it won't begin again before a brand new line.
			if ( TOSGraph_Active_ReSync[2] == 8'h01 )	begin 
				SM_Post	<= POST_SM0;
			end 
			Read_DP_Pointer <= 7'd0;
		end 

		POST_SM0: begin
			case( TOSGraph_Mode4x[1:0] )
				2'b00: begin SM_Post	<= POST_SM1;    end // 1bit per pixel
				2'b01: begin SM_Post	<= POST_SM4;	end // 2bits per pixel
				2'b10: begin SM_Post	<= POST_SM7;	end // 4bits per pixel
				2'b11: begin SM_Post	<= POST_SM7;	end // 4bits per pixel
			endcase
		end 

		/////////////////////////////////////////////
		// 1bpp Post-process State 1
		/////////////////////////////////////////////		
		POST_SM1: begin
			BitCounter <= 8'd64;
			OnebitperPixel_Slide <= OnebitperPixel;	// Store the output in a register that we are going to shift
			SM_Post	<= POST_SM2;	
		end  

		// 1bpp Post-process State 2
		POST_SM2: begin 	
			if ( BitCounter ) begin 
				BitCounter <= BitCounter - 8'd1;
				OnebitperPixel_Slide[63:0] <= {OnebitperPixel_Slide[62:0], 1'b0};	// Shift left
				SM_Post	<= POST_SM2;
			end 
			else begin 
				Read_DP_Pointer <= Read_DP_Pointer + 7'd1; // Go Get the next 
				 SM_Post	<= POST_SM3;
			end 
		end
		// 1bpp Post-process State 3
		POST_SM3: begin 	
			if ( Read_DP_Pointer < ( TOSGraph_Double_ReSync[2] ? 7'd10 : 7'd20) )	// 20 x 64 = 1280bits
				SM_Post	<= POST_SM1;
			else 
				SM_Post	<= POST_IDLE;	// We are done with the 1bpp
		end

		/////////////////////////////////////////////
		// 2bpp Post-process State 1
		/////////////////////////////////////////////		
		POST_SM4: begin
			BitCounter <= 8'd32;			
			TwobitperPixel_Slide_L <= TwobitperPixel_L;	// Store the output in a register that we are going to shift
			TwobitperPixel_Slide_H <= TwobitperPixel_H;
			SM_Post	<= POST_SM5;	
		end


		POST_SM5: begin
			if ( BitCounter ) begin 
				BitCounter <= BitCounter - 8'd1;
				TwobitperPixel_Slide_L[31:0] <= {TwobitperPixel_Slide_L[30:0], 1'b0};	// Shift left\
				TwobitperPixel_Slide_H[31:0] <= {TwobitperPixel_Slide_H[30:0], 1'b0};	// Shift left				
				SM_Post	<= POST_SM5;
			end 
			else begin 
				Read_DP_Pointer <= Read_DP_Pointer + 7'd1; // Go Get the next 
				 SM_Post	<= POST_SM6;
			end 
		end
			
		POST_SM6: begin
			if ( Read_DP_Pointer < ( TOSGraph_Double_ReSync[2] ? 7'd20 : 7'd40) )	// 20 x 64 = 1280bits
				SM_Post	<= POST_SM4;
			else 
				SM_Post	<= POST_IDLE;	// We are done with the 1bpp
		end

		/////////////////////////////////////////////
		// 4bpp Post-process State 1
		/////////////////////////////////////////////
		POST_SM7: begin 	
			BitCounter <= 8'd16;			
			TwobitperPixel_Slide_LL <= TwobitperPixel_LL;
			TwobitperPixel_Slide_LH <= TwobitperPixel_LH;
			TwobitperPixel_Slide_HL <= TwobitperPixel_HL;
			TwobitperPixel_Slide_HH <= TwobitperPixel_HH;
			SM_Post	<= POST_SM8;
		end
			
		// 2 bit per pixel
		// SRAM Read Data Valid	
		POST_SM8: begin
			if ( BitCounter ) begin 
				BitCounter <= BitCounter - 8'd1;
				TwobitperPixel_Slide_LL[15:0] <= {TwobitperPixel_Slide_LL[14:0], 1'b0};	// Shift left\
				TwobitperPixel_Slide_LH[15:0] <= {TwobitperPixel_Slide_LH[14:0], 1'b0};	// Shift left	
				TwobitperPixel_Slide_HL[15:0] <= {TwobitperPixel_Slide_HL[14:0], 1'b0};	// Shift left\
				TwobitperPixel_Slide_HH[15:0] <= {TwobitperPixel_Slide_HH[14:0], 1'b0};	// Shift left
				SM_Post	<= POST_SM8;
			end 
			else begin 
				Read_DP_Pointer <= Read_DP_Pointer + 7'd1; // Go Get the next 
				SM_Post	<= POST_SM9;
			end 
		end
		

		POST_SM9: begin 
			if ( Read_DP_Pointer < ( TOSGraph_Double_ReSync[2] ? 7'd40 : 7'd80) )	// 20 x 64 = 1280bits
				SM_Post	<= POST_SM7;
			else 
				SM_Post	<= POST_IDLE;	// We are done with the 1bpp
		end


		default: begin 
			SM_Post	<= POST_IDLE;
		end 
		endcase


	end 
end 

/*
wire [143:0] TP;
wire  Trigger;

assign TP[63:0] 	= OnebitperPixel_Slide;
assign TP[95:64] 	= VRAM_Data_2_TOS_GRAPH_i;
assign TP[96]  		= VRAM_Data_Valid_i;
assign TP[97]  		= HBlanking_ReSync[2];
assign TP[98]		= Counter_Load_MT_o;
assign TP[99]		= Counter_Reached_Count_i;
assign TP[107:100]	= Write_DP_Pointer;
assign TP[114:108]  = Read_DP_Pointer;
assign TP[118:115]  = SM_Addy;
assign TP[119] 		= Pixel2BeStored_Wr;
assign TP[130:120]  = Pixel2BeStored;
assign TP[131]		  = CS_VSRAM_B_i;
assign TP[139:132]	= BitCounter;
assign TP[143:140]  = SM_Post;

assign Trigger = Mstr_Ctrl_TOS_GRAPH_Enable_i & TOSGraph_Enable & (SM_Addy == ADDY_SM0) & (TOS_Graph_Target_Addy_Start_o == 32'h0000_0000);

TinyChipScope CHIPSCOPE68K (
	.acq_data_in    ( TP ),    //        tap.acq_data_in
	.acq_trigger_in ( Trigger ), //           .acq_trigger_in
	.acq_clk        ( iBUS_4xClk_i ),        //    acq_clk.clk
	.trigger_in     ( Trigger )      // trigger_in.trigger_in
);
*/

// One Bit Per Pixel
reg  [31:0] Color1BPP;
always @ ( * ) begin 
	if ( OnebitperPixel_Slide[63] )
		 Color1BPP = TOSGraph_1bpp_1Val;
	else 
		 Color1BPP = TOSGraph_1bpp_0Val;
 end 

reg [31:0] Color2BPP;
always @ ( * ) begin 
	case( {TwobitperPixel_Slide_H[31],TwobitperPixel_Slide_L[31]} )
		2'b00: begin Color2BPP = TOSGraph_2bpp_0Val; end
		2'b01: begin Color2BPP = TOSGraph_2bpp_1Val; end
		2'b10: begin Color2BPP = TOSGraph_2bpp_2Val; end
		2'b11: begin Color2BPP = TOSGraph_2bpp_3Val; end
	endcase
end 

reg [31:0] Color4BPP;
always @ ( * ) begin 
	case( {TwobitperPixel_Slide_HH[15], TwobitperPixel_Slide_HL[15], TwobitperPixel_Slide_LH[15],TwobitperPixel_Slide_LL[15]} )
		4'b0000: begin Color4BPP = TOSGraph_4bpp_0Val; end
		4'b0001: begin Color4BPP = TOSGraph_4bpp_1Val; end
		4'b0010: begin Color4BPP = TOSGraph_4bpp_2Val; end
		4'b0011: begin Color4BPP = TOSGraph_4bpp_3Val; end
		4'b0100: begin Color4BPP = TOSGraph_4bpp_4Val; end
		4'b0101: begin Color4BPP = TOSGraph_4bpp_5Val; end
		4'b0110: begin Color4BPP = TOSGraph_4bpp_6Val; end
		4'b0111: begin Color4BPP = TOSGraph_4bpp_7Val; end
		4'b1000: begin Color4BPP = TOSGraph_4bpp_8Val; end
		4'b1001: begin Color4BPP = TOSGraph_4bpp_9Val; end
		4'b1010: begin Color4BPP = TOSGraph_4bpp_AVal; end
		4'b1011: begin Color4BPP = TOSGraph_4bpp_BVal; end
		4'b1100: begin Color4BPP = TOSGraph_4bpp_CVal; end
		4'b1101: begin Color4BPP = TOSGraph_4bpp_DVal; end
		4'b1110: begin Color4BPP = TOSGraph_4bpp_EVal; end
		4'b1111: begin Color4BPP = TOSGraph_4bpp_FVal; end
	endcase
end 

reg [31:0] Pixel2BeWritten;

always @ ( * ) begin 
	case ( TOSGraph_Mode2x )
		2'b00: begin Pixel2BeWritten = Color1BPP; end 
		2'b01: begin Pixel2BeWritten = Color2BPP; end 
		2'b10: begin Pixel2BeWritten = Color4BPP; end 
		2'b11: begin Pixel2BeWritten = Color4BPP; end 
	endcase
end 
reg [10:0] 	Pixel2BeStored;


always @ (posedge iBUS_4xClk_i) begin 
	if ( Reset_i ) begin 
		Pixel2BeStored <= 11'd0;
	end 
	else begin 
		if ( BitCounter ) begin 
			Pixel2BeStored <= Pixel2BeStored + 11'd1;
		end 
		else begin 
			if ( SM_Post	<= POST_IDLE )
				Pixel2BeStored <= 11'd0;
		end
	end
end 

wire Pixel2BeStored_Wr = ( BitCounter ) ? 1'b1 : 1'b0;

reg	[10:0]		Video_Pixel_Pointer;
reg [2:0] 		Reset_ReSync;

reg [2:0] TOSGraph_DoubleV_ReSync;

always @ ( posedge VideoClk_i ) begin 
	TOSGraph_DoubleV_ReSync[0] <= TOSGraph_Double;	// Wait for the first full data to be present
	TOSGraph_DoubleV_ReSync[1] <= TOSGraph_DoubleV_ReSync[0];
	if ( TOSGraph_DoubleV_ReSync[1] == TOSGraph_DoubleV_ReSync[0] )
		TOSGraph_DoubleV_ReSync[2] <= TOSGraph_DoubleV_ReSync[1];		
end

// 2 Clock Latency
TOSGRAPH_PIXEL_LINE2K	TOSGRAPH_PIXELOUT (
// 100Mhz
	.data ( Pixel2BeWritten ),
	.wraddress ( Pixel2BeStored ),
	.wrclock ( iBUS_4xClk_i ),
	.wren ( Pixel2BeStored_Wr ),

// Read Data Pixel when ready	
	.rdclock ( VideoClk_i ),
	.rden( 1'b1 ), 
	.rdaddress ( TOSGraph_DoubleV_ReSync[2] ? {1'b0, Video_Pixel_Pointer[10:1]} : Video_Pixel_Pointer ),
	.q ( TOS_GRAPH_RGB_o )
	);

// Horizontal Blanking 1280x960 = 520
// Horizontal Blanking 1280x1024 = 408
wire Horizontal_Precharge = Mstr_Ctrl_Video_Mode_ReSync[2] ? (HPixelCount_i > 12'd405) : (HPixelCount_i > 12'd517);		// Active - 10


always @ (posedge VideoClk_i) begin 
		Reset_ReSync[0] <= Reset_i;
		Reset_ReSync[1] <= Reset_ReSync[0];
		if ( Reset_ReSync[1] == Reset_ReSync[0] )
			Reset_ReSync[2] <= Reset_ReSync[1];
end 

always @ (posedge VideoClk_i)
begin
	if ( Reset_ReSync[2] ) begin
		Video_Pixel_Pointer <= 11'd0;
	end
	else begin
		//if (Time_2_Display_Line_VidClk_i) begin
		if (Horizontal_Precharge && VBlanking_i) begin
			Video_Pixel_Pointer <= Video_Pixel_Pointer + 11'd1;
		end
		else begin
			Video_Pixel_Pointer <= 11'd0;
		end
	end
end

/*
wire [143:0] TPV;
wire  TriggerV;

assign TPV[31:0]	= TOS_GRAPH_RGB_o;
assign TPV[32] 		= Horizontal_Precharge;
assign TPV[33] 		= HBlanking_i;
assign TPV[34] 		= VBlanking_i;
assign TPV[39:35] = 0;
assign TPV[50:40] = Video_Pixel_Pointer;
assign TPV[59:51] = 0;
assign TPV[71:60] = HLineCount_i;
assign TPV[79:72] = 0;
assign TPV[91:80] = HPixelCount_i;
assign TPV[143:92] = 0;

wire [31:0] Source;
wire [31:0] Probe;

SourceAndProbe TOSGRAPH (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);
assign Probe = 32'h0000_0000;

assign TriggerV =  (Source[31:20] == HPixelCount_i) & (Source[11:0] == HLineCount_i);

TinyChipScope VIDEOCS (
	.acq_data_in    ( TPV ),    //        tap.acq_data_in
	.acq_trigger_in ( TriggerV ), //           .acq_trigger_in
	.acq_clk        ( VideoClk_i ),        //    acq_clk.clk
	.trigger_in     ( TriggerV )      // trigger_in.trigger_in
);
*/

// DP Line for Video Output
endmodule
