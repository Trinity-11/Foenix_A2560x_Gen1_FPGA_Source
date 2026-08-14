`timescale 1 ns / 1 ns
module BitMap_State_Machine (

input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,
input		wire				VGE_Engine_Rst_i,

input		wire				Clear_Bit_Line_i,

input		wire	[1:0]		Mstr_Ctrl_Video_Mode_i,		// Synched on Video Memory Clock
input		wire				Mstr_Ctrl_Doubling_Pixel_i,
input		wire	[1:0]		Mstr_Ctrl_Video_Mode100Mhz_i,	// Synched on 100Mhz Clock
input 	wire				Mstr_Ctrl_Doubling_Pixel_100Mhz_i,

input		wire				Bitmap_Effect_On_i,
input		wire	[11:0]	Horizontal_Line_Count_i,

input		wire				Trig_BM_Read_Memory_i,		// Trig the Process of reading 1 Single Line of Bitmap

input		wire				BM0_Layer_Enable_i,
input		wire				BM1_Layer_Enable_i,
input		wire				COL_Layer_Enable_i,

input		wire	[21:0]	BM0_MapAddy_i,
input		wire	[21:0]	BM1_MapAddy_i,
input		wire	[21:0]	COL_MapAddy_i,	

// From VMemory Interface Block
// Inputs
input		wire				VRAM_Data_Valid_i,
input		wire	[31:0]	VRAM_Data_2_BITMAP_i,
input		wire				Counter_Reached_Count_i,
// Outputs
output	reg				Counter_Enable_BM_o,
output	reg				Counter_Load_BM_o,
output	wire	[19:0]	BitMap_Target_Addy_Start_o,
output	wire	[19:0]	BitMap_Target_Addy_Stop_o,

// Collision/Mixer Signals
input		wire				Read_Pixel_Lines_i,
output	reg	[7:0]		Collision_Data_o,
output	reg	[7:0]		BitMap0_Pixel_o,
output	reg	[7:0]		BitMap1_Pixel_o,

output	reg	[7:0]		Collision_Data_Col_o,
output	reg	[7:0]		BitMap0_Pixel_Col_o,
output	reg	[7:0]		BitMap1_Pixel_Col_o,

output	reg	[3:0]		VGE_Bitmap_Engine_SM_o
);

/*
wire [143:0] TP;
wire  Trigger;

assign TP[19:0] 		= BM0_MapAddy_i[19:0];
assign TP[23:20] 		= VGE_Bitmap_Engine_SM_o;
assign TP[24] 			= BM0_Layer_Enable_i;
assign TP[25] 			= Bitmap_Effect_On_i;

assign TP[28:26] 		= 0;

assign TP[29]			= Counter_Enable_BM_o;
assign TP[30]			= Counter_Load_BM_o;
assign TP[31]			= VRAM_Data_Valid_i;
assign TP[63:32]  	= VRAM_Data_2_BITMAP_i;
assign TP[95:64]  	= 0;

assign TP[115:96] 	= BitMap_Target_Addy_Start_o;
assign TP[135:116] 	= BitMap_Target_Addy_Stop_o;

//assign iBUS_Keyboard_D_o = 16'h0000;

wire [31:0] Source;
wire [31:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);

assign Probe = 32'h0000_0000;

assign Trigger = Trig_BM_Read_Memory_i ;
//assign Trigger = (ADDY_In == 32'hFEC00310);
//assign Trigger = (ADDY_In == Source) & !Dbg_Mode_On_i  | ( CS_Unity_i );
//assign Trigger = iBUS_D_Valid_i;

//assign Trigger = {CPU_TT1_2_FPGA, CPU_TT0_2_FPGA} == 2'b11;

ChipScope VMEM_CONTROLLER (
	.acq_data_in    (TP),    //        tap.acq_data_in
	.acq_trigger_in (Trigger), //           .acq_trigger_in
	.acq_clk        ( EngineClk100Mhz_i ),        //    acq_clk.clk
	.trigger_in     (Trigger)      // trigger_in.trigger_in
);
*/




// Wires
wire [31:0]		Absolute_Compute_Mult;
wire [31:0] 	DataInputMux;

wire	[7:0]		BitMap0_Pixel;
wire	[7:0]		BitMap1_Pixel;
wire	[7:0]		Collision_Data;

wire				Write_Data_Enabled;

wire				VGE_Engine_BM0_WE;
wire				VGE_Engine_BM1_WE;
wire				VGE_Engine_COL_WE;

// Regs
reg	[9:0]		BitMap_Line_Sizes;
reg	[1:0]		PlaneChoice;


reg	[9:0]		LayerScanAddress_BM0;
reg	[9:0]		LayerScanAddress_BM1;
reg	[9:0]		LayerScanAddress_COL;

reg	[7:0]		VGE_Engine_EffectChannel_BM_ADDY;

reg				VGE_Engine_BM_WE;
reg				Clear_PixelLine_BitMap;

reg				Bitmap_Active;
reg	[21:0] 	Selected_Plane_MapAddy;

reg				Selected_Enabled;
// Assignments

// This is a 20Bit Address, so this is a Word Address
//                                  // Base Address that fit 32bit Boundary + Line Address 
//// MATH BLOCk HERE
// This is a Math Block to Computer Address Position - This is costing us 1 Clock Cycle Latency, keep that in mind.
DMA_MULT_BLK TileMapAddyOrigineCompute(
	.clock(EngineClk100Mhz_i),
	.dataa( { 6'b0000_00, BitMap_Line_Sizes[9:0]} ),				// Size of the Map x 2 (1x Short per Tile) since we are computing Address
	.datab( Mstr_Ctrl_Doubling_Pixel_i ? { 5'b00000, Horizontal_Line_Count_i[11:1]} : { 4'b0000, Horizontal_Line_Count_i[11:0]} ), 	// Number of line
	.result( Absolute_Compute_Mult )	// The Output is in Tile Char, 
	);


assign BitMap_Target_Addy_Start_o = Selected_Plane_MapAddy[21:2] + Absolute_Compute_Mult[21:2];

assign BitMap_Target_Addy_Stop_o  = BitMap_Target_Addy_Start_o + { 12'b0000_0000_0000, BitMap_Line_Sizes[9:2]};	// This is the Address + 1 Address Line, so if Start = 0 then Stop = 160 (640/4)
assign DataInputMux = Clear_PixelLine_BitMap ? 32'h0000_0000 : VRAM_Data_2_BITMAP_i;

assign Write_Data_Enabled = Bitmap_Active & VRAM_Data_Valid_i;

assign VGE_Engine_BM0_WE = ( PlaneChoice[1:0] == 2'b00 ) ? Write_Data_Enabled : 1'b0; // Less Priority
assign VGE_Engine_BM1_WE = ( PlaneChoice[1:0] == 2'b01 ) ? Write_Data_Enabled : 1'b0; // Less Priority
assign VGE_Engine_COL_WE = ( PlaneChoice[1:0] == 2'b10 ) ? Write_Data_Enabled : 1'b0; // Less Priority

// Blocking Always
always @ (*)
begin
	case ({Mstr_Ctrl_Doubling_Pixel_100Mhz_i, Mstr_Ctrl_Video_Mode100Mhz_i})
	3'b000: BitMap_Line_Sizes 			= 10'd640; // 640x480
	3'b001: BitMap_Line_Sizes 			= 10'd640; // 640x400
	3'b010: BitMap_Line_Sizes 			= 10'd800; // 800x600
	3'b011: BitMap_Line_Sizes 			= 10'd800; // 800x600
	3'b100: BitMap_Line_Sizes 			= 10'd320;
	3'b101: BitMap_Line_Sizes 			= 10'd320;
	3'b110: BitMap_Line_Sizes 			= 10'd400;
	3'b111: BitMap_Line_Sizes 			= 10'd400;
	
	default: BitMap_Line_Sizes 		= 10'd640;
	endcase
end

always @ (*)
begin
	case (PlaneChoice)
		2'b00: Selected_Plane_MapAddy = BM0_MapAddy_i;
		2'b01: Selected_Plane_MapAddy = BM1_MapAddy_i;
		2'b10: Selected_Plane_MapAddy = COL_MapAddy_i;
		2'b11: Selected_Plane_MapAddy = BM0_MapAddy_i;
		default: Selected_Plane_MapAddy = BM0_MapAddy_i;
	endcase
end

always @ (*)
begin
	case (PlaneChoice)
		2'b00: Selected_Enabled 		= BM0_Layer_Enable_i;
		2'b01: Selected_Enabled 		= BM1_Layer_Enable_i;
		2'b10: Selected_Enabled 		= COL_Layer_Enable_i;
		2'b11: Selected_Enabled 		= 1'b0;
		default: Selected_Enabled 		= BM0_Layer_Enable_i;
	endcase
end

reg	[7:0] Collision_Data_Dly;
reg 	[7:0] BitMap0_Pixel_Dly;
reg 	[7:0] BitMap1_Pixel_Dly;

reg	[7:0] Collision_Data_Col_Dly;
reg 	[7:0] BitMap0_Pixel_Col_Dly;
reg 	[7:0] BitMap1_Pixel_Col_Dly;
 

always @ (posedge EngineClk200Mhz_i)
begin

	//Collision_Data_o 	<= Collision_Data;
	//BitMap0_Pixel_o	<= BitMap0_Pixel;				// 1 Latency
	//BitMap1_Pixel_o	<= BitMap1_Pixel;	
	Collision_Data_Dly <= Collision_Data;
	BitMap0_Pixel_Dly	<= BitMap0_Pixel;				// 1 Latency
	BitMap1_Pixel_Dly	<= BitMap1_Pixel;	
	
	Collision_Data_o 	<= Collision_Data_Dly;
	BitMap0_Pixel_o	<= BitMap0_Pixel_Dly;		// 1 Latency
	BitMap1_Pixel_o	<= BitMap1_Pixel_Dly;
end

always @ (posedge EngineClk200Mhz_i)
begin
	Collision_Data_Col_Dly <= Collision_Data;
	BitMap0_Pixel_Col_Dly	<= BitMap0_Pixel;
	BitMap1_Pixel_Col_Dly	<= BitMap1_Pixel;	
	
	Collision_Data_Col_o 	<= Collision_Data_Col_Dly;
	BitMap0_Pixel_Col_o	<= BitMap0_Pixel_Col_Dly;
	BitMap1_Pixel_Col_o	<= BitMap1_Pixel_Col_Dly;
end

/////////////////
////// BITMAP LAYER 0 - 
/////////////////
always @ (posedge EngineClk200Mhz_i)
begin
	if (Read_Pixel_Lines_i)
		LayerScanAddress_BM0 <= LayerScanAddress_BM0 + 10'b00_0000_0001;
	else begin
		LayerScanAddress_BM0 <= 10'b00_0010_0000;
	end
end
// Low  Priority BitMap Layer 0 - TOP
VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_inst0 (
// Pixel Out
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_BM0 ), 
	.q ( BitMap0_Pixel ),

// Packed Pixel In	
	.data ( DataInputMux ), 
	.wrclock( EngineClk100Mhz_i ), 	
	.wraddress ( VGE_Engine_EffectChannel_BM_ADDY ), 
	.wren (VGE_Engine_BM0_WE | Clear_PixelLine_BitMap )
);

/*
wire [71:0] TinyTP2;
wire 			TinyTrigger2;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger2 = Bitmap_Active ;

assign TinyTP2[7:0]  	= VGE_Engine_EffectChannel_BM_ADDY;
assign TinyTP2[10]		= VRAM_Data_Valid_i;
assign TinyTP2[11]		= Clear_PixelLine_BitMap;

assign TinyTP2[63:32] 	= DataInputMux;

TinyChipScope u2 (
	.acq_data_in    (TinyTP2),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger2), //           .acq_trigger_in
	.acq_clk        (EngineClk100Mhz_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger2)      // trigger_in.trigger_in
);
*/

/////////////////
////// BITMAP LAYER 1
/////////////////
always @ (posedge EngineClk200Mhz_i)
begin
	if (Read_Pixel_Lines_i)
		LayerScanAddress_BM1 <= LayerScanAddress_BM1 + 10'b00_0000_0001;
	else begin
		LayerScanAddress_BM1 <= 10'b00_0010_0000;
	end
end
// Low  Priority BitMap Layer 11
VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_inst5 (
// Pixel Out
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_BM1 ), 
	.q ( BitMap1_Pixel ),
// Packed Pixel In
	.data ( DataInputMux ), 
	.wrclock( EngineClk100Mhz_i ), 	
	.wraddress ( VGE_Engine_EffectChannel_BM_ADDY ), 
	.wren ( VGE_Engine_BM1_WE | Clear_PixelLine_BitMap )
);

/////////////////
////// COLLISIONS
/////////////////
always @ (posedge EngineClk200Mhz_i)
begin
	if (Read_Pixel_Lines_i)
		LayerScanAddress_COL <= LayerScanAddress_COL + 10'b00_0000_0001;
	else begin
		LayerScanAddress_COL <= 10'b00_0010_0000;
	end
end
//
VICKYII_Pixel32_8Line	VICKYII_Pixel32_8Line_inst6 (
// Pixel Out
	.rdclock ( EngineClk200Mhz_i ), 
	.rdaddress ( LayerScanAddress_COL ), 
	.q ( Collision_Data ),

// Packed Pixel In
	.data ( DataInputMux ),
	.wrclock( EngineClk100Mhz_i ), 
	.wraddress ( VGE_Engine_EffectChannel_BM_ADDY ), 
	.wren (VGE_Engine_COL_WE | Clear_PixelLine_BitMap )
);




/////////////////////////////////////
// BackGround Pixel Line Counter
/////////////////////////////////////
always @ (posedge EngineClk100Mhz_i)
begin
	if (VGE_Engine_Rst_i) begin
		VGE_Engine_EffectChannel_BM_ADDY <= 8'b0000_0000;
	end
	else begin
		if (Bitmap_Active) begin
			if (Write_Data_Enabled || Clear_PixelLine_BitMap)
				VGE_Engine_EffectChannel_BM_ADDY <= VGE_Engine_EffectChannel_BM_ADDY + 8'b0000_0001;
			else begin
				VGE_Engine_EffectChannel_BM_ADDY <= 8'b0000_1000;	// Begin @ 32 offset, but read only 640
			end
		end
	end
end

/// BITMAP STATE MACHINE STATE
localparam		BM_IDLE				= 4'b0000,			// Wait for Start of Frame
					BM_STATE0			= 4'b0001,			// Now that everything has been Primed, let's wait for Line 27
					BM_STATE1			= 4'b0010,
					BM_STATE2			= 4'b0011,
					BM_STATE3 			= 4'b0100,
					BM_STATE4 			= 4'b0101,
					BM_STATE5			= 4'b0110,			// ReChard the Start Stop
					BM_TRF_DONE			= 4'b0111,
					BM_CLEAR_LINE0		= 4'b1000,
					BM_CLEAR_LINE1		= 4'b1001;

////////////////////////////////////////////////////
////
//// GRAPHIC ENGINE BITMAP STATE MACHINE
////
////////////////////////////////////////////////////
always @ (posedge EngineClk100Mhz_i) begin
	if (VGE_Engine_Rst_i) begin
			VGE_Bitmap_Engine_SM_o	<= BM_IDLE;
			PlaneChoice			<= 2'b00;
			Counter_Load_BM_o <= 1'b0;
			Counter_Enable_BM_o <= 1'b0;
	end
	else begin
	
		case( VGE_Bitmap_Engine_SM_o )

		// THis Process can't start if the Text Mode is ON.
		BM_IDLE: begin
			if ( Bitmap_Effect_On_i )	begin	// We will prime each Block @ Start of Frame, so there will be a bunch of time in between the time it is prime and started to be used.
				VGE_Bitmap_Engine_SM_o <= BM_STATE0;
				PlaneChoice			<= 2'b00;
			end
			else begin
				if (Clear_Bit_Line_i) begin	// Begin the Line 28 (Blanking) + 59 Lines
					Bitmap_Active		   		<= 1'b1;				
					VGE_Bitmap_Engine_SM_o <= BM_CLEAR_LINE0;
				end
				else			
					VGE_Bitmap_Engine_SM_o <= BM_IDLE;
			end
		
		end
	
		// Wait for the Master State Machine Trigger
		BM_STATE0: begin
			if (Trig_BM_Read_Memory_i)	begin		// Begin the Line 28 (Blanking) + 59 Lines
				// Let's Begin with BitMap
				VGE_Bitmap_Engine_SM_o <= BM_STATE1;
				Bitmap_Active 		<= 1'b1;						// Enable the Write Counter to increase

			end
			else begin
				if ( Bitmap_Effect_On_i )
					VGE_Bitmap_Engine_SM_o <= BM_STATE0;
				else
					VGE_Bitmap_Engine_SM_o <= BM_IDLE;
			end
		end
	
		BM_STATE1: begin
			if (PlaneChoice == 2'b11) begin
					Bitmap_Active			<= 1'b0;			
					VGE_Bitmap_Engine_SM_o <= BM_TRF_DONE;
					PlaneChoice			<= 2'b00;
			end
			else begin
					Counter_Load_BM_o <= 1'b1;						// Load the Actual Start/Stop Address			
					VGE_Bitmap_Engine_SM_o <= BM_STATE2;	// Go Process the Next Plane		
			end
		end
	
		BM_STATE2: begin
			Counter_Load_BM_o <= 1'b0;			
			if (Selected_Enabled) begin			// Check to see if the BM is Enabled
					Counter_Enable_BM_o <= 1'b1;	// Starts the Counter and the Reading of the Data we need.
					VGE_Bitmap_Engine_SM_o <= BM_STATE3;
			end
			else begin
					VGE_Bitmap_Engine_SM_o <= BM_STATE4;
			end
		end
		
		// THIS IS TO FETCH 640 Pixels for the Bitmap 
		// The Counter has been loaded with the Start Address and Stop Address
		BM_STATE3: begin

			if (Counter_Reached_Count_i) begin
				Counter_Enable_BM_o <= 1'b0;			// Stops the Counters (When we are here the Starts Addy = Stop Addy)
				VGE_Bitmap_Engine_SM_o	<= BM_STATE4;
			end
			else begin
				VGE_Bitmap_Engine_SM_o	<= BM_STATE3;
			end
		end
		
		BM_STATE4: begin
			VGE_Bitmap_Engine_SM_o	<= BM_STATE5;		
		end
		
		BM_STATE5: begin
			PlaneChoice	<= PlaneChoice + 2'b01;
			VGE_Bitmap_Engine_SM_o	<= BM_STATE1;		
		end
		
		BM_TRF_DONE: begin
				VGE_Bitmap_Engine_SM_o <= BM_STATE0;	// If we haven't reach the last line, go wait for another Trigger
		end


		BM_CLEAR_LINE0: begin
				Clear_PixelLine_BitMap		<= 1'b1;
				VGE_Bitmap_Engine_SM_o 		<= BM_CLEAR_LINE1;	// If we haven't reach the last line, go wait for another Trigger		
		end
		
		
		BM_CLEAR_LINE1: begin
			//if (VGE_Engine_EffectChannel_BM_ADDY < Line_Size_i[9:2])
			if (VGE_Engine_EffectChannel_BM_ADDY < 8'hD8)			
				VGE_Bitmap_Engine_SM_o <= BM_CLEAR_LINE1;
			else begin
				VGE_Bitmap_Engine_SM_o 		<= BM_IDLE;
				Bitmap_Active			   	<= 1'b0;	
				Clear_PixelLine_BitMap		<= 1'b0;
			end		
		
		end
		
		default: begin
				VGE_Bitmap_Engine_SM_o	<= BM_IDLE;				
		end

		endcase
	end
end
/*
wire [95:0] ChipScope;
wire			Trigger;

//assign Trigger = Trig_BM_Read_Memory_i;
assign Trigger = Clear_Bit_Line_i;

assign ChipScope[7:0] = Pixel2FetchCounter_BM_o;
assign ChipScope[15:8] = VGE_Engine_EffectChannel_BM_ADDY;
assign ChipScope[19:16] = VGE_Bitmap_Engine_SM_o;
assign ChipScope[20] = Bitmap_Effect_On_i;
assign ChipScope[21] = Clear_Bit_Line_i;
assign ChipScope[22] = Clear_PixelLine_BitMap;
assign ChipScope[23] = Bitmap_Active;
assign ChipScope[24] = VGE_Engine_BM_WE;


assign ChipScope[95:64] = DataInputMux;



//assign ChipScope[95:64] = State_Machine;

ChipScope	ChipScope_inst (
	.acq_clk ( EngineClk100Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);
*/



endmodule 
