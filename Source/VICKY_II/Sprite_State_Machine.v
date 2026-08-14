
module Sprite_State_Machine (
input		wire				VGE_Engine_Rst_i,
input		wire				Reset_100Mhz_i,
input		wire				Reset_200Mhz_i,

input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,
input		wire				Clear_Bit_Line_i,
input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,	
input		wire	[1:0]		Mstr_Ctrl_Video_Mode100Mhz_i,
input		wire				Mstr_Ctrl_Doubling_Pixel_100Mhz_i,
input		wire				Sprite_Effect_On_i,
input		wire	[11:0]		Horizontal_Line_Count_i,
input		wire				Trig_SP_Read_Memory_i,
input		wire	[1:0]		SOF_i,
// Register Block
output		wire	[5:0]		Sprite_Active_Channel_o,				// Channel to Read
input		wire	[63:0]		Sprite_OutputSpriteMem_i,

// From VMemory Interface Block
// Inputs
input		wire				VRAM_Data_Valid_i,
input		wire	[31:0]		VRAM_Data_2_SPRITE_i,
input		wire				Counter_Reached_Count_i,
// Outputs
output		reg					Counter_Enable_SP_o,
output		wire				Counter_Load_SP_o,
output		reg		[19:0]		Sprite_Target_Addy_Start_o,
output		reg		[19:0]		Sprite_Target_Addy_Stop_o,


input		wire				Read_Pixel_Lines_i,

output		reg		[7:0]		Sprite_Data_o,
output		reg		[7:0]		Sprite_Data_Col_o,

output		reg		[15:0]		Attributes_Data_o,
output		reg		[15:0]		Attributes_Data_Col_o,
output		wire	[3:0]		VGE_Sprite_Engine_SM_o
);

/*
vicky_def.asm
SPRITE_Enable             = $01
SPRITE_LUT0               = $02 ; This is the LUT that the Sprite will use
SPRITE_LUT1               = $04
SPRITE_LUT2               = $08 ; Only 4 LUT for Now, So this bit is not used.
SPRITE_DEPTH0             = $10 ; This is the Layer the Sprite will be Displayed in
SPRITE_DEPTH1             = $20
SPRITE_DEPTH2             = $40

; Sprite 0 (Highest Priority)
SP00_CONTROL_REG        = $AF0200
SP00_ADDY_PTR_L         = $AF0201
SP00_ADDY_PTR_M         = $AF0202
SP00_ADDY_PTR_H         = $AF0203
SP00_X_POS_L            = $AF0204
SP00_X_POS_H            = $AF0205
SP00_Y_POS_L            = $AF0206
SP00_Y_POS_H            = $AF0207

Sprite_OutputSpriteMem_i[7:0] 	= Sprite Control Register
Sprite_OutputSpriteMem_i[31:8] 	= Sprite Graphic Addy
Sprite_OutputSpriteMem_i[47:32] 	= Sprite X Position
Sprite_OutputSpriteMem_i[63:48] 	= Sprite Y Position 


*/
/*
wire [15:0] Source;
wire [32:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);

assign Probe[0] = Sprite_Enable;
assign Probe[3:1] = Sprite_LUT;
assign Probe[6:4] = Sprite_Depth;
assign Probe[7] = Sprite_Collision_On;
assign Probe[15:8] = Sprite_Graphic_Addy[23:16];
assign Probe[23:16] = Sprite_X_Position[7:0];
assign Probe[31:24] = Sprite_Y_Position[7:0];
*/

wire 				Sprite_Enable;
wire 	[2:0]		Sprite_LUT;
wire 	[2:0]		Sprite_Depth;
wire 	[23:0] 		Sprite_Graphic_Addy;
wire 	[15:0]		Sprite_X_Position; // Top Corner X
wire 	[15:0]		Sprite_Y_Position; // Top Corner Y
wire 	[7:0]		UsedWrite_Space;
wire				Sprite_Collision_On;

assign Sprite_Enable 		= Sprite_OutputSpriteMem_i[0];
assign Sprite_LUT 			= Sprite_OutputSpriteMem_i[3:1];
assign Sprite_Depth			= Sprite_OutputSpriteMem_i[6:4];
assign Sprite_Collision_On = Sprite_OutputSpriteMem_i[7];		// When on, the Collision will be used
assign Sprite_Graphic_Addy	= Sprite_OutputSpriteMem_i[31:8];
assign Sprite_X_Position	= Sprite_OutputSpriteMem_i[47:32];
assign Sprite_Y_Position	= Sprite_OutputSpriteMem_i[63:48];

assign VGE_Sprite_Engine_SM_o = VGE_Sprite_Engine_SM;

wire 				Sprite_Graphic_Data_Read;
wire	[7:0]		Sprite_Graphic_Data_Out;
wire 				Sprite_Graphic_Data_Read_Empty;
reg 				Sprite_Attributes_Write;
reg 				Sprite_Attributes_Read;
wire 				Sprite_Attributes_Read_Empty;
wire	[31:0]		Sprite_Attributes_Data_Out;

wire				Sprite_FIFO_Graphic_Wr_Empty;
wire				Sprite_FIFO_Attributes_Wr_Empty;
// 32Bits In from Vram - 8Bits Out for Pixel Line
SPRITE_FIFO_DATA Sprite_Graphic_Data(
	.aclr( VGE_Engine_Rst_i | Reset_100Mhz_i),
	// Write Section @ 100Mhz - Interface to VRAM
	.wrclk( EngineClk100Mhz_i ),
	.wrreq( VRAM_Data_Valid_i & Sprite_Effect_On_i ),
	.data( VRAM_Data_2_SPRITE_i ),
	.wrfull(  ),
	.wrempty( Sprite_FIFO_Graphic_Wr_Empty ),
	.wrusedw( UsedWrite_Space ),
	// Read Graphic Data Side
	.rdclk( EngineClk200Mhz_i ),
	.rdreq( Sprite_Graphic_Data_Read ),				// 1 Clock Latency from moment 
	.q( Sprite_Graphic_Data_Out ),
	.rdempty( Sprite_Graphic_Data_Read_Empty )
);

/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

assign TinyTrigger1 = Sprite_Graphic_Data_Read;

assign TinyTP1[7:0]  	= Sprite_Graphic_Data_Out;
assign TinyTP1[8]   		= Sprite_Graphic_Data_Read_Empty;
assign TinyTP1[9] 		= Sprite_Graphic_Data_Read;
assign TinyTP1[13:10]	= SP_DTA_SM;
assign TinyTP1[29]		= Sprite_Attributes_Read;
assign TinyTP1[30]		= Sprite_Attributes_Read_Empty;
assign TinyTP1[63:31]	= Sprite_Attributes_Data_Out;

TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (EngineClk200Mhz_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/
/*
assign TinyTrigger1 = VRAM_Data_Valid_i & Sprite_Effect_On_i;

assign TinyTP1[31:0]  	= VRAM_Data_2_SPRITE_i;
assign TinyTP1[39:32]	= UsedWrite_Space;
assign TinyTP1[40]   	= Sprite_FIFO_Graphic_Wr_Empty;
assign TinyTP1[41] 		= VGE_Engine_Rst_i | Reset_100Mhz_i;
assign TinyTP1[42] 		= VRAM_Data_Valid_i & Sprite_Effect_On_i;
assign TinyTP1[63:60]	= VGE_Sprite_Engine_SM;
*/

/*
reg [7:0]	Sprite_Graphic_Data_Out_Dly0;
reg [7:0]	Sprite_Graphic_Data_Out_Dly1;
reg [31:0]  Sprite_Attributes_Data_Out_Dly0;
reg [31:0]  Sprite_Attributes_Data_Out_Dly1;

always @ (posedge EngineClk200Mhz_i)
begin
	Sprite_Graphic_Data_Out_Dly0 <= Sprite_Graphic_Data_Out;	// 1 Clock Latency from moment 
//	Sprite_Graphic_Data_Out_Dly1 <= Sprite_Graphic_Data_Out_Dly0; // 1 Clock Latency from moment 
	
	Sprite_Attributes_Data_Out_Dly0 <= Sprite_Attributes_Data_Out;
	Sprite_Attributes_Data_Out_Dly1 <= Sprite_Attributes_Data_Out_Dly0;	
end
*/

// 32Bits Attributes (LUT + DEPTH + X OFFSET)
SPRITE_FIFO_ATTR Sprite_Attribute_Data(
	.aclr( VGE_Engine_Rst_i | Reset_100Mhz_i),
// Write Attributes
	.wrclk( EngineClk100Mhz_i ),
	.wrreq( Sprite_Attributes_Write ),
	.data( { Sprite_X_Position, 3'b000, Sprite_Collision_On, Sprite_Active_Channel_o, Sprite_Depth, Sprite_LUT } ),		// 6, 3, 3 = 12 Bits
	.wrfull(  ),
	.wrempty( Sprite_FIFO_Attributes_Wr_Empty ),	
// Read Attribute Side	
	.rdclk( EngineClk200Mhz_i ),
	.rdreq( Sprite_Attributes_Read ),
	.q( Sprite_Attributes_Data_Out ),
	.rdempty( Sprite_Attributes_Read_Empty )
);

assign Sprite_Active_Channel_o = Sprite_Select[5:0];
// This should be 100Mhz Clock
always @ (posedge EngineClk100Mhz_i)
begin
	Sprite_Target_Addy_Start_o <= Sprite_Graphic_Addy[21:2] + {1'b0, Line_Number_In_Sprite, 3'b0_00};		// 1 + 16 + 3
	Sprite_Target_Addy_Stop_o  <= Sprite_Graphic_Addy[21:2] + {1'b0, Line_Number_In_Sprite, 3'b0_00} + {16'b0000_0000_0000_0000, 4'b10_00};
end


reg	[15:0]	Attribute_2_Store;

/////////////////
////// BITMAP LAYER 0 - 
/////////////////

reg	[9:0]	LayerScanAddress_SP;
reg	[9:0]	LayerScanAddress_SP_Dly;
reg			Read_Pixel_Lines_Dly;


always @ (posedge EngineClk200Mhz_i)
begin
	//if (Read_Pixel_Lines_i || Pixel_Erase_Line_Write_Strobe)
	if (Read_Pixel_Lines_i)	
		LayerScanAddress_SP <= LayerScanAddress_SP + 10'b00_0000_0001;
	else begin
		LayerScanAddress_SP <= 10'b00_0010_0000;
	end
end

reg 			Write_Pixel_Line_Data_And_Attr;
reg 	[9:0]	Write_Pixel_Line_Addy;
reg			Write_Pixel_Line_Strobe;
//reg			Pixel_Erase_Line_Write_Strobe;

initial begin
//Pixel_Erase_Line_Write_Strobe = 1'b0;
Counter_Enable_SP_o = 1'b0;
end

always @ (posedge EngineClk200Mhz_i)
begin
	Read_Pixel_Lines_Dly <= Read_Pixel_Lines_i;	
	if (Read_Pixel_Lines_Dly)	
		LayerScanAddress_SP_Dly <= LayerScanAddress_SP_Dly + 10'b00_0000_0001;
	else begin
		LayerScanAddress_SP_Dly <= 10'b00_0010_0000;
	end
end

wire [7:0] Sprite_Data_Output;
wire [15:0] Attributes_Data_Output;

// Pixel Data
VICKYII_Pixel8_8Line	SPRITE_Pixel_Out (
	.clock( EngineClk200Mhz_i ),
	// Write Data
	.address_a ( Read_Pixel_Lines_Dly ? LayerScanAddress_SP_Dly : Write_Pixel_Line_Addy ),
	.data_a ( Read_Pixel_Lines_Dly ? 8'h00 : Sprite_Graphic_Data_Out ),
	.wren_a ( Read_Pixel_Lines_Dly ? 1'b1 : Sprite_Graphic_Data_Read_Dly & ( Sprite_Graphic_Data_Out != 8'h00 )),	
	.q_a (  ),

	// Read Out and Clear
	.address_b ( LayerScanAddress_SP ),
	.data_b ( 8'h00 ),
	.wren_b ( 1'b0 ),
	//.wren_b ( Pixel_Erase_Line_Write_Strobe ),	
	.q_b ( Sprite_Data_Output )
);


// Attribute Data
VICKYII_PIXEL16_16LINE	SPRITE_Attributes_Out (
	.clock( EngineClk200Mhz_i ),
	// Write Data
	.address_a ( Read_Pixel_Lines_Dly ? LayerScanAddress_SP_Dly : Write_Pixel_Line_Addy ),
	.data_a ( Read_Pixel_Lines_Dly ? 16'h0000 :Attribute_2_Store ),
	.wren_a ( Read_Pixel_Lines_Dly ? 1'b1 : Sprite_Graphic_Data_Read_Dly & ( Sprite_Graphic_Data_Out != 8'h00 )),	
	.q_a (  ),

	// Read Out and Clear
	.address_b ( LayerScanAddress_SP ),
	.data_b ( 8'h00 ),
	//.wren_b ( Pixel_Erase_Line_Write_Strobe ),	
	.wren_b ( 1'b0 ),
	.q_b ( Attributes_Data_Output )
);

reg [7:0] Sprite_Data_Output_Dly;
reg [7:0] Sprite_Data_Output_Col_Dly;
reg [15:0] Attributes_Data_Output_Dly;
reg [15:0] Attributes_Data_Output_Col_Dly;

// Sprite DATA
always @ (posedge EngineClk200Mhz_i) begin
	Sprite_Data_Output_Dly <= Sprite_Data_Output;		// 1 Clock Latency
	Sprite_Data_o  <= Sprite_Data_Output_Dly;				// 1 Clock Latency
	
	Sprite_Data_Output_Col_Dly <= Sprite_Data_Output;
	Sprite_Data_Col_o <= Sprite_Data_Output_Col_Dly;
end

// Sprite Attributes
always @ (posedge EngineClk200Mhz_i) begin
	Attributes_Data_Output_Dly 		<= Attributes_Data_Output;
	Attributes_Data_o 	 				<= Attributes_Data_Output_Dly;

	Attributes_Data_Output_Col_Dly	<= Attributes_Data_Output;
	Attributes_Data_Col_o  				<= Attributes_Data_Output_Col_Dly;	
end

/*
wire [71:0] ChipScope;
wire			Trigger;

//assign Trigger = Sprite_Effect_On_i & Trig_SP_Read_Memory_i & ((Horizontal_Line_Count_i == 12'h078) ? 1'b1 : 1'b0);
//assign Trigger = Counter_Load_SP_o;
assign Trigger = Sprite_Attributes_Read_Empty;

ChipScope	ChipScope_inst (
	.acq_clk ( EngineClk200Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

// This is the Signal Driving the Input Side of the DP Memory
assign ChipScope[7:0] 		= Sprite_Graphic_Data_Out;
assign ChipScope[39:8]		= Sprite_Attributes_Data_Out;
assign ChipScope[49:40]		= Write_Pixel_Line_Addy;
assign ChipScope[50] 		= Sprite_Graphic_Data_Read;
assign ChipScope[51] 		= Sprite_Attributes_Read;
assign ChipScope[59:52]    = Attribute_2_Store;
//assign ChipScope[67:60] 	= Sprite_Graphic_Data_Out_Dly1;
assign ChipScope[70]			= Sprite_Graphic_Data_Read_Dly;
*/
/// Sprite Data Transfer State Machine
localparam		SD_IDLE				= 4'b0000,			// Wait for Start of Frame
				SD_PRESTATE       	= 4'b0001,
				SD_STATE0			= 4'b0010,			// Latence to get Valid Value
				SD_STATE1			= 4'b0011,
				SD_STATE2			= 4'b0110,
				SD_STATE3			= 4'b0111,
				SD_STATE4			= 4'b1000,
				SD_STATE5			= 4'b1001,
				SD_STATE6			= 4'b1010,
				SD_STATE7 			= 4'b1011,
				SD_STATE8 			= 4'b1100,
				SD_ERASE_LINE0		= 4'b1101,
				SD_ERASE_LINE1		= 4'b1110,
				SD_TRF_DONE			= 4'b1111;

reg	[3:0]		SP_DTA_SM;
reg				Sprite_Graphic_Data_Read_Dly;
//reg				Sprite_Graphic_Data_Read_Dly0;
//reg				Sprite_Graphic_Data_Read_Dly1;


always @ (posedge EngineClk200Mhz_i) begin
	if ( VGE_Engine_Rst_i || Reset_200Mhz_i) begin
		Write_Pixel_Line_Addy 			<= 10'b00_0000_0000;

		Attribute_2_Store					<= 8'h0000_0000;
	end
	else begin
		if (Sprite_Graphic_Data_Read_Dly) begin
			Write_Pixel_Line_Addy <= Write_Pixel_Line_Addy + 10'b00_0000_0001;
		end
		else begin
			if (SP_DTA_SM  == SD_STATE0) begin
			//	.data( { Sprite_X_Position, 3'b000, Sprite_Collision_On, Sprite_Active_Channel_o, Sprite_Depth, Sprite_LUT } ),		// 6, 3, 3 = 12 Bits
				Attribute_2_Store <= Sprite_Attributes_Data_Out[15:0];		// Let's Store LUT and DEPTH and Collision		
				Write_Pixel_Line_Addy <= Sprite_Attributes_Data_Out[25:16];
			end 		
		end
	end
	// Delay the Data FIFO Read, so it can become a Write Strobe for the DP
	Sprite_Graphic_Data_Read_Dly <= Sprite_Graphic_Data_Read;			// 
//	Sprite_Graphic_Data_Read_Dly0 <= Sprite_Graphic_Data_Read_Dly;		//
//	Sprite_Graphic_Data_Read_Dly1 <= Sprite_Graphic_Data_Read_Dly0;	// 3 Clock Latency
end

reg	[31:0] Read_FiFo_Slip;

assign Sprite_Graphic_Data_Read = Read_FiFo_Slip[31];

always @ (posedge EngineClk200Mhz_i) begin
	if (VGE_Engine_Rst_i || Reset_200Mhz_i) begin
		SP_DTA_SM								<= SD_IDLE;
		Read_FiFo_Slip	<= 32'h0000_0000;
		// FIFO Read Strobe to Get Attributes
		Sprite_Attributes_Read				<= 1'b0;	// Strobe to Read FIFO to Get Attributes
	end
	else begin
	Read_FiFo_Slip <= Read_FiFo_Slip << 1'b1;
	
		case ( SP_DTA_SM )
		
		SD_IDLE: begin
			if ( Sprite_Attributes_Read_Empty ) begin
//				if (Clear_Bit_Line_i) begin
//					SP_DTA_SM <= SD_ERASE_LINE0;
//					Pixel_Erase_Line_Write_Strobe <= 1'b1;
//				end
//					else begin
						SP_DTA_SM <= SD_IDLE;
//				end
			end
			else begin
				Sprite_Attributes_Read <= 1'b1;
				SP_DTA_SM <= SD_PRESTATE;				
			end
		end
		
		// Read Strobe is set here, but data will have to wait another Clock Cycle
		SD_PRESTATE: begin
			Sprite_Attributes_Read <= 1'b0;
			SP_DTA_SM <= SD_STATE0;
		end 
		
		
		// WITH DRAM - The Time in Between The Sprite Attribute and getting the data takes 8 clock cycles (way more then before).
		// The overall process of getting 32bytes, takes 16 Clock Cycle (fetch 8 Words)
		
		// Normally the Data Would be Valid Here - but we are recyncing twice
		SD_STATE0: begin
			SP_DTA_SM <= SD_STATE1;
		end

		SD_STATE1: begin
			SP_DTA_SM <= SD_STATE5;
		end

//		SD_STATE2: begin
//			SP_DTA_SM <= SD_STATE5;
		//end
		
		// Attributes Info is available here:
		SD_STATE5: begin

		if (Sprite_Graphic_Data_Read_Empty == 1'b0) begin
				Read_FiFo_Slip <= 32'hFFFF_FFFF;	// This Will Enable the FIFO to Spit out the Pixel Data
				SP_DTA_SM <= SD_STATE6;
			end
		end
		
		// The Read Strobe is One, but data will be available only in the next state
		SD_STATE6: begin
			if (Sprite_Graphic_Data_Read) 
				SP_DTA_SM <= SD_STATE6;
			else
				SP_DTA_SM <= SD_STATE7;
		end
		
		// The Read is over (we need to make sure we really read 32, otherwise the whole thing will be off)
		SD_STATE7: begin

				SP_DTA_SM <= SD_STATE8;	
		end
		
		SD_STATE8: begin
				SP_DTA_SM <= SD_IDLE;	
		end
		
		
	
		default: begin
				SP_DTA_SM								<= SD_IDLE;
		end
		endcase
	end
end

/*
			if (Counter_Pixel_FIFO_Transfer < 6'd30) begin
					SP_DTA_SM <= SD_STATE6;	// Wait for the Transfer from FIFO to DP Happens.
			end
			else begin
				Sprite_Graphic_Data_Read <= 1'b0; // We have Read Enough
				SP_DTA_SM <= SD_STATE7;					
			end

*/

/////////////////////////////
////////////////////////////
//////////////////////////////////////////////////*****************************************************

/// SPRITE STATE MACHINE STATE
localparam			SP_IDLE				= 4'b0000,			// Wait for Start of Frame
					SP_PRESTATE       	= 4'b0001,
					SP_STATE0			= 4'b0010,			// Latence to get Valid Value
					SP_STATE1			= 4'b0011,
					ENABLED				= 4'b0100,
					NEXTCHANNEL			= 4'b0101,
					SP_GET_DATA_VRAM0	= 4'b0110,
					SP_GET_DATA_VRAM1	= 4'b0111,
					SP_GET_DATA_VRAM2	= 4'b1000,
					SP_WRITE_ATTRIB0	= 4'b1001,
					SP_WRITE_ATTRIB1	= 4'b1010,
					SP_WRITE_ATTRIB2 	= 4'b1011,
					SP_GET_DATA_VRAM5 	= 4'b1100,
					SP_GET_DATA_VRAM6 	= 4'b1101,
					SP_GET_DATA_VRAM7	= 4'b1110,
					SP_TRF_DONE			= 4'b1111;


/// Registers Needed in the Master State Machine
reg	[3:0]			VGE_Sprite_Engine_SM;
reg	[7:0]			Sprite_Select;
reg	[7:0]			Sprite_Same_Line_Max;

parameter 			SpriteMax = 8'd64;
wire 				Sprite_Line_Hit;
//wire				Sprite_Line_Hits_Clear_Line;
wire	[15:0]		Line_Number_In_Sprite;
wire	[23:0]		Video_Memory_Start_Addy;
wire	[15:0]		Y1;


wire 	[15:0]	Horizontal_Line_Count_Div;

//assign Horizontal_Line_Count_Div = Mstr_Ctrl_Video_Mode_i[1] ? {5'b0_0000, Horizontal_Line_Count_i[11:1]} : {4'b0000, Horizontal_Line_Count_i[11:0]};
assign Horizontal_Line_Count_Div = Mstr_Ctrl_Doubling_Pixel_100Mhz_i ? ({6'b00_0000, Horizontal_Line_Count_i[11:2]} + 16'h0020) : ({5'b0_0000, Horizontal_Line_Count_i[11:1]} + 16'h0020);

assign Y1 = (Sprite_Y_Position + 16'd32);
assign Sprite_Line_Hit = ((Horizontal_Line_Count_Div >= Sprite_Y_Position) && (Horizontal_Line_Count_Div < Y1)) ? 1'b1 : 1'b0;
assign Line_Number_In_Sprite = Sprite_Line_Hit ? (Horizontal_Line_Count_Div - Sprite_Y_Position ) : 16'h0000;

reg	[1:0]		Counter_Load_SP_Slip;
assign Counter_Load_SP_o = Counter_Load_SP_Slip[1];
/////////////////////////////////////////////////////
////
//// Video Graphic Engine - Sprite Collection Data
////
////////////////////////////////////////////////////
always @ (posedge EngineClk100Mhz_i) begin
	if (VGE_Engine_Rst_i || Reset_100Mhz_i) begin
			VGE_Sprite_Engine_SM		<= SP_IDLE;
			Sprite_Attributes_Write		<= 1'b0;
			Sprite_Same_Line_Max		<= SpriteMax - 1;
			Counter_Load_SP_Slip		<= 2'b00;
			Counter_Enable_SP_o     	<= 1'b0;
	end
	else begin
		Counter_Load_SP_Slip <= Counter_Load_SP_Slip << 1'b1;

		case( VGE_Sprite_Engine_SM )

		// THis Process can't start if the Text Mode is ON.
		SP_IDLE: begin
			if (Sprite_Effect_On_i) begin			// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.
				Sprite_Select 				<= SpriteMax - 1;		// Set to the 63rd Sprite.				
				VGE_Sprite_Engine_SM 	<= SP_PRESTATE;
			end
			else
				begin
					VGE_Sprite_Engine_SM <= SP_IDLE;
				end
		end
		
		// Wait for the Master State Machine Trigger
		//1
		SP_PRESTATE: begin
			if (Trig_SP_Read_Memory_i)	begin
				VGE_Sprite_Engine_SM <= SP_STATE0;
				Sprite_Same_Line_Max <= 8'b0000_0000;
			end
			else begin
				if (Sprite_Effect_On_i)
					VGE_Sprite_Engine_SM <= SP_STATE0;
				else
					VGE_Sprite_Engine_SM <= SP_IDLE;
			end
		end
		
		// The Fun Begins Here
		//This is For Latency for the Register Information to be Valid
		// if the previous state Changed the Address of the Register Block we need to wait 1 clock cycle
		SP_STATE0: begin
				VGE_Sprite_Engine_SM <= SP_STATE1;
		end

		// Alright, here all the data, Enable, LUT, Dept, Addy and Position are valid
		SP_STATE1: begin
			if (Sprite_Enable) begin				// is the Sprite Enable ?
				VGE_Sprite_Engine_SM 			<= ENABLED;
				end
			else
				VGE_Sprite_Engine_SM				<= NEXTCHANNEL; // No Can do, let's Move on to the Next Channel
		end

		ENABLED: begin
			if (Sprite_Line_Hit) begin
				Counter_Load_SP_Slip				<= 2'b01;					// Load the Address
				VGE_Sprite_Engine_SM 			<= SP_GET_DATA_VRAM0;	// Go Read 32Bytes (16 Cycles)
			end
			else begin
					VGE_Sprite_Engine_SM <= NEXTCHANNEL;
			end
		end	
	
	
		// The Process Starts Here @ The Beginning, we are already @ 0,0
		// Go Fetch the DATA
		NEXTCHANNEL: begin
			if (Sprite_Select) begin		
				Sprite_Select <= Sprite_Select - 8'b0000_0001;	// Reduce 1
				VGE_Sprite_Engine_SM <= SP_STATE0;				
			end
			else begin
				VGE_Sprite_Engine_SM <= SP_GET_DATA_VRAM6;
			end
		end
	
		
		// Go Clear the Line Before the Processing Begins
		SP_GET_DATA_VRAM0: begin
			//Counter_Enable_SP_o 		<= 1'b1;  //<<<<
			VGE_Sprite_Engine_SM 	<= SP_GET_DATA_VRAM1;
		end
		
		// the VRAM Read begins Here
		SP_GET_DATA_VRAM1: begin
			Counter_Enable_SP_o 		<= 1'b1;		
			VGE_Sprite_Engine_SM 	<= SP_WRITE_ATTRIB0;
		end		
		// the first valid Data (4 Pixels) Comes in Here
//		SP_GET_DATA_VRAM2: begin
//			VGE_Sprite_Engine_SM 	<= SP_GET_DATA_VRAM3;
//		end
		// the Second valid Data (4 Pixels) Comes in Here		
//		SP_GET_DATA_VRAM3: begin
//			VGE_Sprite_Engine_SM 	<= SP_GET_DATA_VRAM4;
//		end
		// the Third valid Data (4 Pixels) Comes in Here			
//		SP_GET_DATA_VRAM4: begin
//			VGE_Sprite_Engine_SM 	<= SP_WRITE_ATTRIB0;
		//end
		// the Forth valid Data (4 Pixels) Comes in Here		
		SP_WRITE_ATTRIB0: begin
			VGE_Sprite_Engine_SM 	<= SP_WRITE_ATTRIB1;
			Sprite_Attributes_Write <= 1'b1;
		end
		// The Attribute that is needed to process the incoming data is being written here
		// the Fifth valid Data (4 Pixels) Comes in Here	
		SP_WRITE_ATTRIB1: begin
			VGE_Sprite_Engine_SM 	<= SP_WRITE_ATTRIB2;
			Sprite_Attributes_Write <= 1'b0;		
		end
		
		// The Attributes has been Saved (the Other Process will now begin)
		// the Sixth valid Data (4 Pixels) Comes in Here
		SP_WRITE_ATTRIB2: begin
			if (Counter_Reached_Count_i)	begin
				VGE_Sprite_Engine_SM <= SP_GET_DATA_VRAM5;
				Sprite_Same_Line_Max <= Sprite_Same_Line_Max + 8'b0000_0001;	// Max 32 Sprites per line, 				
				Counter_Enable_SP_o <= 1'b0;	// Stop the Read if we have reached the Destination
			end
			else begin
				VGE_Sprite_Engine_SM <= SP_WRITE_ATTRIB2;			
			end
		end
		// This an extra latency to make sure all the data have been saved in the FIFO
		// Return back to process to go through all Sprites 
		SP_GET_DATA_VRAM5: begin
			if (Sprite_Same_Line_Max < SpriteMax)
				VGE_Sprite_Engine_SM <= NEXTCHANNEL;
			else 
				VGE_Sprite_Engine_SM <= SP_GET_DATA_VRAM6;	// If we reached max Sprite, just stop going for more sprites
		end	

		// Let's sait for both FIFO to be completely Empty before calling it a Day
		SP_GET_DATA_VRAM6: begin
			if ( Sprite_FIFO_Graphic_Wr_Empty && Sprite_FIFO_Attributes_Wr_Empty) begin
					VGE_Sprite_Engine_SM <= SP_TRF_DONE;
			end
			else begin
					VGE_Sprite_Engine_SM <= SP_GET_DATA_VRAM6;			
			end
		end
		
		// When the Line has been Drawned
		SP_TRF_DONE: begin
				VGE_Sprite_Engine_SM <= SP_IDLE;	// If we haven't reach the last line, go wait for another Trigger
		end


		default: begin
				VGE_Sprite_Engine_SM	<= SP_IDLE;				
		end

		endcase
	end
end


endmodule

/*
// Channel 0
always @ (posedge EngineClk100Mhz_i) 
begin
	if (VGE_Engine_Rst_i) begin
			Channel0MemSprite[0] <= 32'h0000;
			Channel0MemSprite[1] <= 32'h0000;
			Channel0MemSprite[2] <= 32'h0000;
			Channel0MemSprite[3] <= 32'h0000;
			Channel0MemSprite[4] <= 32'h0000;
			Channel0MemSprite[5] <= 32'h0000;
			Channel0MemSprite[6] <= 32'h0000;
			Channel0MemSprite[7] <= 32'h0000;			
	end
	else begin
		if (VRAM_Data_Valid_i && Sprite_Active && Channel0_Enabled)	begin
				Channel0MemSprite[Channel0MemAddy] <=	VRAM_Data_2_SPRITE_i;
				Channel0MemAddy <= Channel0MemAddy + 3'b001;
		end
		else 
			Channel0MemAddy <= 3'b000;
	end
end

always @ (*)
begin
	case ( Sprite_Pixel_Pointer_Channel0[4:0])
		5'b0_0000: Channel0SpriteData = Channel0MemSprite[0][7:0];
		5'b0_0001: Channel0SpriteData = Channel0MemSprite[0][15:8];
		5'b0_0010: Channel0SpriteData = Channel0MemSprite[0][23:16];
		5'b0_0011: Channel0SpriteData = Channel0MemSprite[0][31:24];
		5'b0_0100: Channel0SpriteData = Channel0MemSprite[1][7:0];
		5'b0_0101: Channel0SpriteData = Channel0MemSprite[1][15:8];
		5'b0_0110: Channel0SpriteData = Channel0MemSprite[1][23:16];
		5'b0_0111: Channel0SpriteData = Channel0MemSprite[1][31:24];
		5'b0_1000: Channel0SpriteData = Channel0MemSprite[2][7:0];
		5'b0_1001: Channel0SpriteData = Channel0MemSprite[2][15:8];
		5'b0_1010: Channel0SpriteData = Channel0MemSprite[2][23:16];
		5'b0_1011: Channel0SpriteData = Channel0MemSprite[2][31:24];
		5'b0_1100: Channel0SpriteData = Channel0MemSprite[3][7:0];
		5'b0_1101: Channel0SpriteData = Channel0MemSprite[3][15:8];
		5'b0_1110: Channel0SpriteData = Channel0MemSprite[3][23:16];
		5'b0_1111: Channel0SpriteData = Channel0MemSprite[3][31:24];		
		5'b1_0000: Channel0SpriteData = Channel0MemSprite[4][7:0];
		5'b1_0001: Channel0SpriteData = Channel0MemSprite[4][15:8];
		5'b1_0010: Channel0SpriteData = Channel0MemSprite[4][23:16];
		5'b1_0011: Channel0SpriteData = Channel0MemSprite[4][31:24];
		5'b1_0100: Channel0SpriteData = Channel0MemSprite[5][7:0];
		5'b1_0101: Channel0SpriteData = Channel0MemSprite[5][15:8];
		5'b1_0110: Channel0SpriteData = Channel0MemSprite[5][23:16];
		5'b1_0111: Channel0SpriteData = Channel0MemSprite[5][31:24];
		5'b1_1000: Channel0SpriteData = Channel0MemSprite[6][7:0];
		5'b1_1001: Channel0SpriteData = Channel0MemSprite[6][15:8];
		5'b1_1010: Channel0SpriteData = Channel0MemSprite[6][23:16];
		5'b1_1011: Channel0SpriteData = Channel0MemSprite[6][31:24];
		5'b1_1100: Channel0SpriteData = Channel0MemSprite[7][7:0];
		5'b1_1101: Channel0SpriteData = Channel0MemSprite[7][15:8];
		5'b1_1110: Channel0SpriteData = Channel0MemSprite[7][23:16];
		5'b1_1111: Channel0SpriteData = Channel0MemSprite[7][31:24];
		default: Channel0SpriteData = 8'h00;
	endcase
end

// Channel 1
always @ (posedge EngineClk100Mhz_i) 
begin
	if (VGE_Engine_Rst_i) begin
			Channel1MemSprite[0] <= 32'h0000;
			Channel1MemSprite[1] <= 32'h0000;
			Channel1MemSprite[2] <= 32'h0000;
			Channel1MemSprite[3] <= 32'h0000;
			Channel1MemSprite[4] <= 32'h0000;
			Channel1MemSprite[5] <= 32'h0000;
			Channel1MemSprite[6] <= 32'h0000;
			Channel1MemSprite[7] <= 32'h0000;			
	end
	else begin
		if (VRAM_Data_Valid_i && Sprite_Active && Channel1_Enabled)	begin
				Channel1MemSprite[Channel1MemAddy] <=	VRAM_Data_2_SPRITE_i;
				Channel1MemAddy <= Channel1MemAddy + 3'b001;
		end
		else 
			Channel1MemAddy <= 3'b000;
	end
end

always @ (*)
begin
	case ( Sprite_Pixel_Pointer_Channel1[4:0])
		5'b0_0000: Channel1SpriteData = Channel1MemSprite[0][7:0];
		5'b0_0001: Channel1SpriteData = Channel1MemSprite[0][15:8];
		5'b0_0010: Channel1SpriteData = Channel1MemSprite[0][23:16];
		5'b0_0011: Channel1SpriteData = Channel1MemSprite[0][31:24];
		5'b0_0100: Channel1SpriteData = Channel1MemSprite[1][7:0];
		5'b0_0101: Channel1SpriteData = Channel1MemSprite[1][15:8];
		5'b0_0110: Channel1SpriteData = Channel1MemSprite[1][23:16];
		5'b0_0111: Channel1SpriteData = Channel1MemSprite[1][31:24];
		5'b0_1000: Channel1SpriteData = Channel1MemSprite[2][7:0];
		5'b0_1001: Channel1SpriteData = Channel1MemSprite[2][15:8];
		5'b0_1010: Channel1SpriteData = Channel1MemSprite[2][23:16];
		5'b0_1011: Channel1SpriteData = Channel1MemSprite[2][31:24];
		5'b0_1100: Channel1SpriteData = Channel1MemSprite[3][7:0];
		5'b0_1101: Channel1SpriteData = Channel1MemSprite[3][15:8];
		5'b0_1110: Channel1SpriteData = Channel1MemSprite[3][23:16];
		5'b0_1111: Channel1SpriteData = Channel1MemSprite[3][31:24];		
		5'b1_0000: Channel1SpriteData = Channel1MemSprite[4][7:0];
		5'b1_0001: Channel1SpriteData = Channel1MemSprite[4][15:8];
		5'b1_0010: Channel1SpriteData = Channel1MemSprite[4][23:16];
		5'b1_0011: Channel1SpriteData = Channel1MemSprite[4][31:24];
		5'b1_0100: Channel1SpriteData = Channel1MemSprite[5][7:0];
		5'b1_0101: Channel1SpriteData = Channel1MemSprite[5][15:8];
		5'b1_0110: Channel1SpriteData = Channel1MemSprite[5][23:16];
		5'b1_0111: Channel1SpriteData = Channel1MemSprite[5][31:24];
		5'b1_1000: Channel1SpriteData = Channel1MemSprite[6][7:0];
		5'b1_1001: Channel1SpriteData = Channel1MemSprite[6][15:8];
		5'b1_1010: Channel1SpriteData = Channel1MemSprite[6][23:16];
		5'b1_1011: Channel1SpriteData = Channel1MemSprite[6][31:24];
		5'b1_1100: Channel1SpriteData = Channel1MemSprite[7][7:0];
		5'b1_1101: Channel1SpriteData = Channel1MemSprite[7][15:8];
		5'b1_1110: Channel1SpriteData = Channel1MemSprite[7][23:16];
		5'b1_1111: Channel1SpriteData = Channel1MemSprite[7][31:24];
		default: Channel1SpriteData = 8'h00;
	endcase
end
*/