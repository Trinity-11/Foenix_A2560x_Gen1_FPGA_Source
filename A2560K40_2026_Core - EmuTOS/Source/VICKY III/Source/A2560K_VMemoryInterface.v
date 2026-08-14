
module A2560K_VMemoryInterface(

input		wire				Reset_i,
input 	wire				Reset_100Mhz_i,
input		wire				EngineClk100Mhz_i,

input		wire	[2:0]		Counter_Channel_i,
output	wire				Counter_Reached_Count_o, 
// Channel 0
input		wire				CPUA_Target_Enable_i,
input		wire	[8:0]		CPUA_Target_FIFO_Write_Count_i,
output	reg				CPUA_Target_Transfer_Done_o,
output	reg				CPUA_Target_Read_FIFO_o,
input		wire	[63:0]	CPUA_Target_CPU_CMD_Input_i,
// Channel 1
input		wire				BitMap_Target_Enable_i,
input		wire				BitMap_Target_Load_i,
input		wire	[19:0]	BitMap_Target_Addy_Start_i,
input		wire	[19:0]	BitMap_Target_Addy_Stop_i,
// Channel 2
input		wire				TileMap_Target_Enable_i,
input		wire				TileMap_Target_Load_i,
input		wire	[19:0]	TileMap_Target_Addy_Start_i,
input		wire	[19:0]	TileMap_Target_Addy_Stop_i,
input		wire				TileMap_Target_Dir_i,		// Always 1
// Channel 3
input		wire				Sprite_Target_Enable_i,
input		wire				Sprite_Target_Load_i,
input		wire	[19:0]	Sprite_Target_Addy_Start_i,
input		wire	[19:0]	Sprite_Target_Addy_Stop_i,
input		wire				Sprite_Target_Dir_i,		// Always 1

output	reg	[31:0]	DataInputChannel0_o,
output	reg	[31:0]	DataInputChannel1_o,
output	reg	[31:0]	DataInputChannel2_o,
output	reg	[31:0]	DataInputChannel3_o,
//output	reg	[31:0]	DataInputChannel4_o,
output	reg				Data_Output_Valid_o,
// New
// VDMA Channel
input		wire	[21:0]	VDMA_Src_Addy_Start_i,
input		wire	[21:0]	VDMA_Src_Addy_Stop_i,
input		wire 				VDMA_Src_Addy_Load_i,
input		wire				VDMA_Src_Addy_Enable_i,
output	wire				VDMA_Src_Count_Reached_o,

input		wire	[21:0]	VDMA_Dst_Addy_Start_i,	// Byte Oriented
input		wire	[21:0]	VDMA_Dst_Addy_Stop_i,		// Byte Oriented
input		wire				VDMA_Dst_Addy_Load_i,
input		wire				VDMA_Dst_Addy_Enable_i,
output	wire				VDMA_Dst_Count_Reached_o,
	
input		wire				VDMA_Transaction_RW_i,
input		wire	[7:0]		VDMA_Transaction_Data_i,		// Byte Input
output	reg	[7:0]		VDMA_Transaction_Data_o,		// Byte Input

//output	reg	[20:0]	VGE_Addy_o,	// 1Mx32
//inout		wire	[31:0]	VGE_VidMem_Data_io,
//output	reg				VGE_VidMem_Readn_o,
//output   wire				VGE_VidMem_WRn_LL_o,
//output   wire				VGE_VidMem_WRn_LH_o,
//output   wire				VGE_VidMem_WRn_HL_o,
//output   wire				VGE_VidMem_WRn_HH_o,

// Video RAM Bank A
inout		wire		[31:0]	VRAM_DQ_io,
output	reg		[3:0]		VRAM_BEn_o,
output	reg		[19:0]	VRAM_Addy_o,
output	reg					VRAM_OEn_o,
output	reg					VRAM_WEn_o,
input		wire	[6:0]		 Debug_i
);

/*
wire [143:0] TP;
wire  Trigger;

assign TP[19:0] 		= VRAM_A_Addy_o[19:0];
assign TP[23:20] 		= VRAM_A_BEn_o;
assign TP[24] 			= VRAM_A_OEn_o;
assign TP[25] 			= VRAM_A_WEn_o;
assign TP[28:26] 		= Counter_Channel_i;
assign TP[29]			= BitMap_Target_Enable_i;
assign TP[30]			= BitMap_Target_Load_i;
assign TP[31]			= Data_Output_Valid_o;
assign TP[63:32]  	= VGE_VidMem_Data_i;
assign TP[95:64]		= DataInputChannel0_o;
assign TP[96]			= Data_Output_Valid_o;



//assign Trigger = CPUA_Target_Enable_i & ( Counter_Channel_i == 3'b000) & (CPUA_Target_CPU_CMD_Input_i[20:0] == Source[20:0]) ;
assign Trigger = BitMap_Target_Load_i & ( BitMap_Target_Addy_Start_i[19:0] == Source[19:0]);

ChipScope VMEM_CONTROLLER (
	.acq_data_in    (TP),    //        tap.acq_data_in
	.acq_trigger_in (Trigger), //           .acq_trigger_in
	.acq_clk        (EngineClk100Mhz_i),        //    acq_clk.clk
	.trigger_in     (Trigger)      // trigger_in.trigger_in
);

wire [31:0] Source;
wire [31:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);

assign Probe = 32'h0000_0000;
*/



reg			 	VGE_VidMem_Readn_o;
reg 	[3:0]  	VGE_VidMem_Writen_o;
wire 	[31:0] 	VGE_VidMem_Data_i;
reg 	[31:0] 	VGE_VidMem_Data_o;
wire 				VidMemWriteN;

assign VidMemWriteN = VGE_VidMem_Writen_o[3] & VGE_VidMem_Writen_o[2] & VGE_VidMem_Writen_o[1] & VGE_VidMem_Writen_o[0];


always @ (*) begin
	case( { VGE_VidMem_Readn_o, VidMemWriteN } )
		2'b01: begin VRAM_OEn_o = 1'b0; VRAM_WEn_o = 1'b1; VRAM_BEn_o = 4'b0000; end
		2'b10: begin VRAM_OEn_o = 1'b1; VRAM_WEn_o = 1'b0; VRAM_BEn_o = VGE_VidMem_Writen_o[3:0]; end
	 default: begin VRAM_OEn_o = 1'b1; VRAM_WEn_o = 1'b1; VRAM_BEn_o = 4'b1111; end
	endcase
end

// VID MEM DATA EXTERNAL BUFFERS
BIDIR_DATA8 DATA_VMEM_BIDIR_LL(
	.dataout(VGE_VidMem_Data_i[7:0]),   //   dout.export
	.datain(VGE_VidMem_Data_o[7:0]),    //    din.export
	.dataio(VRAM_DQ_io[7:0]), // pad_io.export
	.oe(VGE_VidMem_Writen_o[0] ? 8'h00 : 8'hFF)      //     oe.export
);
// VID MEM DATA EXTERNAL BUFFERS
BIDIR_DATA8 DATA_VMEM_BIDIR_LH(
	.dataout(VGE_VidMem_Data_i[15:8]),   //   dout.export
	.datain(VGE_VidMem_Data_o[15:8]),    //    din.export
	.dataio(VRAM_DQ_io[15:8]), // pad_io.export
	.oe(VGE_VidMem_Writen_o[1] ? 8'h00 : 8'hFF)      //     oe.export
);
// VID MEM DATA EXTERNAL BUFFERS
BIDIR_DATA8 DATA_VMEM_BIDIR_HL(
	.dataout(VGE_VidMem_Data_i[23:16]),   //   dout.export
	.datain(VGE_VidMem_Data_o[23:16]),    //    din.export
	.dataio(VRAM_DQ_io[23:16]), // pad_io.export
	.oe(VGE_VidMem_Writen_o[2] ? 8'h00 : 8'hFF)      //     oe.export
);
// VID MEM DATA EXTERNAL BUFFERS
BIDIR_DATA8 DATA_VMEM_BIDIR_HH(
	.dataout(VGE_VidMem_Data_i[31:24]),   //   dout.export
	.datain(VGE_VidMem_Data_o[31:24]),    //    din.export
	.dataio(VRAM_DQ_io[31:24]), // pad_io.export
	.oe(VGE_VidMem_Writen_o[3] ? 8'h00 : 8'hFF)      //     oe.export
);



reg [2:0] MiniStateMachine;

localparam 	IDLE	= 3'b000,
				ST0	= 3'b001,
				ST1	= 3'b010,
				ST2	= 3'b011,
				ST3	= 3'b100,
				ST4	= 3'b101,
				ST5	= 3'b110;

reg [3:0] 	Counter2Write;
reg [3:0]	CPU_Write_2_Memory;
reg [31:0]  CPU_Data_2_Write;
reg [3:0]   Write_Enable;
reg [19:0]  CPU_Addy_2_Write;

//	.data( { 3'b000, Bus_RW_i,  Data_2_Write , Bus_A_i[23:0]} ),
// Data_2_Write = { 4'b1111, Bus_D32_i}; 

always @ (posedge EngineClk100Mhz_i) begin
	if ( Reset_100Mhz_i ) begin
		CPU_Write_2_Memory <= 4'b1111;
		CPU_Addy_2_Write <= 20'h0_0000;
		CPU_Data_2_Write <= 32'h0000_0000;
	end
	else begin
		if (FIFO_Latency) begin
			
			CPU_Addy_2_Write <= {1'b0, CPUA_Target_CPU_CMD_Input_i[20:2]}; 
			CPU_Data_2_Write <= CPUA_Target_CPU_CMD_Input_i[55:24];
			
			case ({ CPUA_Target_CPU_CMD_Input_i[59:56]} )
				4'b1111: begin CPU_Write_2_Memory <= 4'b0000; end
				// Byte
				4'b0001: begin CPU_Write_2_Memory <= 4'b0111;  end
				4'b0010: begin CPU_Write_2_Memory <= 4'b1011;  end
				4'b0100: begin CPU_Write_2_Memory <= 4'b1101;  end
				4'b1000: begin CPU_Write_2_Memory <= 4'b1110;  end
				// Short 
				4'b0011: begin CPU_Write_2_Memory <= 4'b1100;  end
				4'b1100: begin CPU_Write_2_Memory <= 4'b0011;  end
				// Default
				default: begin CPU_Write_2_Memory <= 4'b1111;  end
			endcase
		end
		else begin
			CPU_Write_2_Memory <= 4'b1111;		
		end
	end
end

reg FIFO_Latency;


always @ (posedge EngineClk100Mhz_i) begin

	if (Reset_100Mhz_i) begin
		MiniStateMachine <= IDLE;
		CPUA_Target_Transfer_Done_o <= 1'b0;
		CPUA_Target_Read_FIFO_o <= 1'b0;
	end
	else begin
	
	FIFO_Latency <=  CPUA_Target_Read_FIFO_o;
	
	case(MiniStateMachine)
	
		IDLE: begin 
			if ( CPUA_Target_Enable_i && ( Counter_Channel_i == 3'b000)) begin
				Counter2Write <= (CPUA_Target_FIFO_Write_Count_i > 9'h08) ? 4'b1000 : CPUA_Target_FIFO_Write_Count_i[3:0];
				CPUA_Target_Read_FIFO_o <= 1'b1;
				CPUA_Target_Transfer_Done_o <= 1'b1;
				MiniStateMachine <= ST0;
			end
			else begin
				CPUA_Target_Read_FIFO_o <= 1'b0;
				CPUA_Target_Transfer_Done_o <= 1'b0;			
				MiniStateMachine <= IDLE;
			end
		end

		ST0:	begin 
			if (Counter2Write) begin
				if ( Counter2Write == 4'b0001)	// if we have only one to fetch, Turn off the read right away
					CPUA_Target_Read_FIFO_o <= 1'b0;
				Counter2Write <= Counter2Write - 4'b0001;					
			end
			else begin
				MiniStateMachine <= ST1;		
			end
		end

		// Latency		
		ST1:	begin	
			MiniStateMachine <= ST2;
		end
		
		// Data Valid here
		ST2: 	begin	
			MiniStateMachine <= ST3;
		end
		
		ST3:	begin	
			MiniStateMachine <= ST4;
		
		end
		
		ST4:	begin 
			CPUA_Target_Transfer_Done_o <= 1'b0;		
			MiniStateMachine <= IDLE;		
		end
		
		
		//ST5:	begin end
		
		default: begin MiniStateMachine <= IDLE; end
	endcase
	
	end
end

reg				Counter_Direction;
//wire				Transfer_Direction;
reg	[19:0]	Counter_Load_Addy;
reg	[19:0]	Counter_Value_2_Compare;
//reg	[3:0]		CPU_VGE_VidMem_Writen;
// Direction of the Counter itself

reg	Counter_Enable_i;
reg	Counter_Load_i;

always @ * begin
	case(Counter_Channel_i[1:0])
		2'b00: Counter_Enable_i = 1'b0;
		2'b01: Counter_Enable_i = BitMap_Target_Enable_i;
		2'b10: Counter_Enable_i = TileMap_Target_Enable_i;
		2'b11: Counter_Enable_i = Sprite_Target_Enable_i;
	endcase
end

always @ * begin
	case(Counter_Channel_i[1:0])
		2'b00: Counter_Load_i = 1'b0;
		2'b01: Counter_Load_i = BitMap_Target_Load_i;
		2'b10: Counter_Load_i = TileMap_Target_Load_i;
		2'b11: Counter_Load_i = Sprite_Target_Load_i;
	endcase
end


// Direction of the Counter itself
always @ * begin
	case(Counter_Channel_i[1:0])
		2'b00: Counter_Direction = 1'b1;
		2'b01: Counter_Direction = 1'b1;
		2'b10: Counter_Direction = TileMap_Target_Dir_i;
		2'b11: Counter_Direction = Sprite_Target_Dir_i;
	endcase
end

//assign Transfer_Direction = 1'b1;
// What Value will be loaded in the Counter;
always @ * begin
	case(Counter_Channel_i[1:0])
		2'b00: Counter_Load_Addy = 20'h00000;
		2'b01: Counter_Load_Addy = BitMap_Target_Addy_Start_i;
		2'b10: Counter_Load_Addy = TileMap_Target_Addy_Start_i;
		2'b11: Counter_Load_Addy = Sprite_Target_Addy_Start_i;
	endcase
end

wire [23:0]		CPU_Counter_Output;

reg 	[19:0] Cnt_Val_2_Comp_Registered;

always @ (posedge EngineClk100Mhz_i)
begin
	if ( Reset_100Mhz_i ) begin
		Cnt_Val_2_Comp_Registered <= 20'h0_0000;
	end
	else begin
		if (Counter_Load_i) begin
			case(Counter_Channel_i[1:0])
				2'b00: begin Cnt_Val_2_Comp_Registered <= 20'h00000; end
				2'b01: begin Cnt_Val_2_Comp_Registered <= BitMap_Target_Addy_Stop_i; end
				2'b10: begin Cnt_Val_2_Comp_Registered <= TileMap_Target_Addy_Stop_i; end
				2'b11: begin Cnt_Val_2_Comp_Registered <= Sprite_Target_Addy_Stop_i; end			
			endcase
		end
	end
end

// 20BitAddress Address (Counter of Int (4bytes))
ADDY_COUNTER	VGE_Addy_Generator (
	.aclr ( Reset_100Mhz_i ),
	.clk_en ( 1'b1 ),
	.clock ( EngineClk100Mhz_i ),
	.cnt_en ( ( Counter_Enable_i & Compare_Condition_ALB) ),
	.data ( {4'b0000, Counter_Load_Addy} ),
	.sload ( Counter_Load_i ),
	.updown ( Counter_Direction ),		// 1= Up, 0= Down
	.q ( CPU_Counter_Output )					// Directly drive the VRAM Address
);

// VRAM BANK A
always @ (posedge EngineClk100Mhz_i)
begin
	if ( Reset_100Mhz_i ) begin
		VRAM_Addy_o <= 20'h0_0000;
	end
	else begin
		casex(Counter_Channel_i[2:0])
			3'b000: begin VRAM_Addy_o <= CPU_Addy_2_Write; end
			3'b001: begin VRAM_Addy_o <= CPU_Counter_Output[19:0]; end
			3'b010: begin VRAM_Addy_o <= CPU_Counter_Output[19:0]; end
			3'b011: begin VRAM_Addy_o <= CPU_Counter_Output[19:0]; end			
			3'b1xx: begin VRAM_Addy_o <= VDMA_Pointer_Addy[19:0]; end
		endcase
	end
end


always @ (posedge EngineClk100Mhz_i)
begin
	if ( Reset_100Mhz_i ) begin
		VGE_VidMem_Readn_o <= 1'b1;
	end
	else begin
		casex(Counter_Channel_i[2:0])
			3'b000: begin VGE_VidMem_Readn_o <= 1'b1; end
			3'b001: begin VGE_VidMem_Readn_o <= !(Counter_Enable_i & Compare_Condition_ALB); end
			3'b010: begin VGE_VidMem_Readn_o <= !(Counter_Enable_i & Compare_Condition_ALB); end
			3'b011: begin VGE_VidMem_Readn_o <= !(Counter_Enable_i & Compare_Condition_ALB); end
			3'b1xx: begin VGE_VidMem_Readn_o <= (VDMA_Transaction_RW_i ? !(VDMA_Src_Addy_Enable_i & VDMA_Src_Compare_Condition_ALB) : 1'b1); end
		endcase
	end
end

always @ (posedge EngineClk100Mhz_i)
begin
	if ( Reset_100Mhz_i ) begin
		VGE_VidMem_Writen_o <= 4'b1111;
	end
	else begin
		casex(Counter_Channel_i[2:0])
			3'b000: begin VGE_VidMem_Writen_o <= CPU_Write_2_Memory; end
			3'b001: begin VGE_VidMem_Writen_o <= 4'b1111; end
			3'b010: begin VGE_VidMem_Writen_o <= 4'b1111; end
			3'b011: begin VGE_VidMem_Writen_o <= 4'b1111; end			
			3'b1xx: begin VGE_VidMem_Writen_o <= VDMA_Target_Wen; end
		endcase
	end
end


always @ (posedge EngineClk100Mhz_i)
begin
	if ( Reset_100Mhz_i ) begin
		VGE_VidMem_Data_o <= 32'h0000_0000;
	end
	else begin
		casex(Counter_Channel_i[2:0])
			3'b000: begin VGE_VidMem_Data_o <= CPU_Data_2_Write; end
			3'b001: begin VGE_VidMem_Data_o <= 32'h0000_0000; end
			3'b010: begin VGE_VidMem_Data_o <= 32'h0000_0000; end
			3'b011: begin VGE_VidMem_Data_o <= 32'h0000_0000; end			
			3'b1xx: begin VGE_VidMem_Data_o <= {VDMA_Transaction_Data_i, VDMA_Transaction_Data_i, VDMA_Transaction_Data_i, VDMA_Transaction_Data_i}; end
		endcase
	end
end


//assign VGE_Addy_o = 				Counter_Channel_i[2] ?  {1'b0, VDMA_Pointer_Addy[19:0]} : {1'b0, CPU_Counter_Output[19:0] };
//assign VGE_VidMem_Readn_o = 	Counter_Channel_i[2] ?	(VDMA_Transaction_RW_i ? !(VDMA_Src_Addy_Enable_i & VDMA_Src_Compare_Condition_ALB) : 1'b1)	: (Transfer_Direction ? !(Counter_Enable_i & Compare_Condition_ALB) : 1'b1);
//assign VGE_VidMem_Writen_o =	Counter_Channel_i[2] ? 	VDMA_Target_Wen	  			: CPU_VGE_VidMem_Writen;
//assign VGE_VidMem_Data_o   =  Counter_Channel_i[2] ? 	{VDMA_Transaction_Data_i, VDMA_Transaction_Data_i, VDMA_Transaction_Data_i, VDMA_Transaction_Data_i}	: CPUA_Target_Data_2_Write_i;

wire Compare_Condition_AEB;
wire Compare_Condition_AGEB;
wire Compare_Condition_ALB;
wire Compare_Condition_ANEB;

ADDY_COMPARE VGE_Addy_Comparator (
	.dataa( {4'b0000, CPU_Counter_Output[19:0]} ),
	.datab( {4'b0000, Cnt_Val_2_Comp_Registered} ),
	.aeb( Compare_Condition_AEB ),		// A == B
	.ageb( Compare_Condition_AGEB ),		// A >= B
	.alb( Compare_Condition_ALB ),		// A < B
	.aneb( Compare_Condition_ANEB )		// A != B
);

assign Counter_Reached_Count_o = Compare_Condition_AEB;

reg Data_Output_Valid_Dly;
reg Data_Output_Valid_Dly0;
/*
always @ (posedge EngineClk100Mhz_i)
begin
	if (Reset_100Mhz_i) begin
		Data_Output_Valid_Dly <= 1'b0;
	end
	else begin
		Data_Output_Valid_Dly <= Transfer_Direction ? (Counter_Enable_i & Compare_Condition_ALB) : 1'b0;
		Data_Output_Valid_Dly0 <= Data_Output_Valid_Dly;	// Added now because the Addy is bring registered before being outputed
		Data_Output_Valid_o <= Data_Output_Valid_Dly0;
	end
end
*/
always @ (posedge EngineClk100Mhz_i)
begin
	if (Reset_100Mhz_i) begin
		Data_Output_Valid_Dly <= 1'b0;
	end
	else begin
		Data_Output_Valid_Dly <= (Counter_Enable_i & Compare_Condition_ALB);
		Data_Output_Valid_Dly0 <= Data_Output_Valid_Dly;
		Data_Output_Valid_o <= Data_Output_Valid_Dly0;
	end
end

reg [31:0] DataInputChannel4_o;

always @ (posedge EngineClk100Mhz_i)
begin
	DataInputChannel0_o <= VGE_VidMem_Data_i;
	DataInputChannel1_o <= VGE_VidMem_Data_i;
	DataInputChannel2_o <= VGE_VidMem_Data_i;
	DataInputChannel3_o <= VGE_VidMem_Data_i;
//	DataInputChannel4_o <= VGE_VidMem_Data_i;
end

/////////////////////////////////////////////////
////////////
///////////   VDMA SECTION
////////////
/////////////////////////////////////////////////
/*
wire [63:0] ChipScope;
wire			Trigger;

assign Trigger = VDMA_Src_Addy_Enable_i | VDMA_Dst_Addy_Enable_i;

ChipScope	ChipScope_inst (
	.acq_clk ( EngineClk100Mhz_i ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

wire 	[23:0]	Test_Byte_Address_Pointer;

assign Test_Byte_Address_Pointer = VDMA_Transaction_RW_i ? VDMA_Src_Addy[21:0] : VDMA_Dst_Addy[21:0];
	
// This is the Signal Driving the Input Side of the DP Memory
// Signal that Drives the VRAM
assign ChipScope[23:0] 		= Test_Byte_Address_Pointer;		// I am more interested in what is going out than in.
assign ChipScope[31:24] 	= VDMA_Transaction_Data_i;
assign ChipScope[39:32] 	= VDMA_Transaction_Data_o;
assign ChipScope[40] 		= VDMA_Src_Addy_Enable_i;
assign ChipScope[41] 		= VDMA_Src_Addy_Load_i;
assign ChipScope[42] 		= VDMA_Src_Compare_Condition_ALB;
assign ChipScope[43] 		= VDMA_Dst_Addy_Enable_i;
assign ChipScope[44] 		= VDMA_Dst_Addy_Load_i;
assign ChipScope[45] 		= VDMA_Dst_Compare_Condition_ALB;
assign ChipScope[51:46]		= 0;
assign ChipScope[52] 		= VDMA_Src_Count_Reached_o;
assign ChipScope[53] 		= VDMA_Dst_Count_Reached_o;
assign ChipScope[54] 		= VGE_VidMem_Readn_o;
assign ChipScope[58:55]		= VGE_VidMem_Writen_o;
assign ChipScope[59] 		= VDMA_Transaction_RW_i;
assign ChipScope[63:60] 	= 0;
*/

wire 	[23:0]	VDMA_Src_Addy;
wire 	[23:0]	VDMA_Dst_Addy;
wire	[23:0]	VDMA_Counter_Output;
wire	[23:0]	VDMA_Pointer_Addy;
reg	[3:0]		VDMA_Target_Wen;

/////////////////////////////////////////////
// NEW VDMA CODE
/////////////////////////////////////////////
// 24BitAddress Address (Counter of Bytes)
// SOURCE
ADDY_COUNTER	VDMA_Src_Addy_Gen (
	.aclr ( Reset_100Mhz_i ),
	.clk_en ( 1'b1 ),
	.clock ( EngineClk100Mhz_i ),
	.cnt_en ( VDMA_Src_Addy_Enable_i ),
	.data ( {2'b00, VDMA_Src_Addy_Start_i} ),
	.sload ( VDMA_Src_Addy_Load_i ),
	.updown ( 1'b1 ),								// 1= Up, 0= Down
	.q ( VDMA_Src_Addy )					// Directly drive the VRAM Address
);

wire VDMA_Src_Compare_Condition_AEB;
wire VDMA_Src_Compare_Condition_AGEB;
wire VDMA_Src_Compare_Condition_ALB;
wire VDMA_Src_Compare_Condition_ANEB;

ADDY_COMPARE VDMA_Src_Addy_Comp (
	.dataa( VDMA_Src_Addy ),			// 24 Bits
	.datab( {2'b00, VDMA_Src_Addy_Stop_i} ),
	.aeb( VDMA_Src_Compare_Condition_AEB ),		// A == B
	.ageb( VDMA_Src_Compare_Condition_AGEB ),		// A >= B
	.alb( VDMA_Src_Compare_Condition_ALB ),		// A < B
	.aneb( VDMA_Src_Compare_Condition_ANEB )		// A != B
);
////////////////////////////////////
// DESTINATION
////////////////////////////////////
ADDY_COUNTER	VDMA_Dst_Addy_Gen (
	.aclr ( Reset_100Mhz_i ),
	.clk_en ( 1'b1 ),
	.clock ( EngineClk100Mhz_i ),
	.cnt_en ( VDMA_Dst_Addy_Enable_i ),
	.data ( {2'b00, VDMA_Dst_Addy_Start_i} ),
	.sload ( VDMA_Dst_Addy_Load_i ),
	.updown ( 1'b1 ),								// 1= Up, 0= Down
	.q ( VDMA_Dst_Addy )					// Directly drive the VRAM Address
);

wire VDMA_Dst_Compare_Condition_AEB;
wire VDMA_Dst_Compare_Condition_AGEB;
wire VDMA_Dst_Compare_Condition_ALB;
wire VDMA_Dst_Compare_Condition_ANEB;

ADDY_COMPARE VDMA_Dst_Addy_Comp (
	.dataa( VDMA_Dst_Addy ),			// 24 Bits
	.datab( {2'b00, VDMA_Dst_Addy_Stop_i} ),
	.aeb( VDMA_Dst_Compare_Condition_AEB ),		// A == B
	.ageb( VDMA_Dst_Compare_Condition_AGEB ),		// A >= B
	.alb( VDMA_Dst_Compare_Condition_ALB ),		// A < B
	.aneb( VDMA_Dst_Compare_Condition_ANEB )		// A != B
);

assign VDMA_Pointer_Addy = VDMA_Transaction_RW_i ? VDMA_Src_Addy[21:2] : VDMA_Dst_Addy[21:2];

//assign VDMA_Src_Count_Reached_o = VDMA_Src_Compare_Condition_AGEB;
//assign VDMA_Dst_Count_Reached_o = VDMA_Dst_Compare_Condition_AGEB;

assign VDMA_Src_Count_Reached_o = VDMA_Src_Compare_Condition_AEB;
assign VDMA_Dst_Count_Reached_o = VDMA_Dst_Compare_Condition_AEB;

// Read Data out of the Integer

always @ (*)
begin
	case (VDMA_Src_Addy[1:0])
		2'b00: VDMA_Transaction_Data_o = VGE_VidMem_Data_i[31:24];
		2'b01: VDMA_Transaction_Data_o = VGE_VidMem_Data_i[7:0];
		2'b10: VDMA_Transaction_Data_o = VGE_VidMem_Data_i[15:8]; 
		2'b11: VDMA_Transaction_Data_o = VGE_VidMem_Data_i[23:16];
		default: VDMA_Transaction_Data_o = 8'h00;
	endcase
end

/*
assign VDMA_Transaction_Data_o = ( VDMA_Src_Addy[1:0] == 2'b00 ) ? VGE_VidMem_Data_i[7:0] :
											( VDMA_Src_Addy[1:0] == 2'b01 ) ? VGE_VidMem_Data_i[15:8] :
											( VDMA_Src_Addy[1:0] == 2'b10 ) ? VGE_VidMem_Data_i[23:16] :
											( VDMA_Src_Addy[1:0] == 2'b11 ) ? VGE_VidMem_Data_i[31:24] : 8'b0000_0000;
*/											
// Write Strobe for the incomming
always @ (*)
begin
	if ( VDMA_Dst_Addy_Enable_i && !VDMA_Transaction_RW_i && !VDMA_Dst_Compare_Condition_AEB) begin
		casex ({VDMA_Transaction_RW_i, VDMA_Dst_Addy[1:0]})
			3'b000: VDMA_Target_Wen = 4'b1110;
			3'b001: VDMA_Target_Wen = 4'b1101; 
			3'b010: VDMA_Target_Wen = 4'b1011;
			3'b011: VDMA_Target_Wen = 4'b0111;
			3'b1xx: VDMA_Target_Wen = 4'b1111;
			default: VDMA_Target_Wen = 4'b1111;
		endcase
	end
	else begin
		VDMA_Target_Wen = 4'b1111;
	end
end


endmodule


/*
//VICKY II Debug
wire 	[71:0]		CS;
wire					Trigger_In;

assign Trigger_In = CPUA_Target_Enable_i;

assign CS[19:00] 	= VGE_Addy_o[19:0];
assign CS[51:20]  = VGE_VidMem_Data_o;
assign CS[55:52]  = VGE_VidMem_Writen_o;
assign CS[56]     = CPUA_Target_Read_FIFO_o;
assign CS[57] 		= FIFO_Latency;
assign CS[59:58]	= Counter_Channel_i;
assign CS[62:60]  = MiniStateMachine;
assign CS[66:63]  = Counter2Write;
assign CS[71:67]  = CPUA_Target_FIFO_Write_Count_i[4:0];

TinyChipScope u0 (
	.acq_data_in    (CS),    //        tap.acq_data_in
	.acq_trigger_in (Trigger_In), //           .acq_trigger_in
	.acq_clk        (EngineClk100Mhz_i),        //    acq_clk.clk
	.trigger_in     (Trigger_In)      // trigger_in.trigger_in
);
*/