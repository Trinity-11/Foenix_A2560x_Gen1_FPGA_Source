
module C256Foenix_VMemoryInterface(

input		wire				Reset_i,
input 	wire				Reset_100Mhz_i,
input		wire				EngineClk100Mhz_i,

input		wire				SOF_i,

input		wire	[2:0]		Counter_Channel_i,
output	wire				DRAM2DPRAM_Trsfer_Done_o,
output	wire				iTransfer_In_Progress_o,
output	wire				iRefresh_In_Progress_o,
// Channel 0
input		wire				CPUA_Target_Start_i,
input		wire	[20:0]	CPUA_Target_Addy_Start_i,
input		wire	[18:0]	CPUA_Target_Addy_Size_i,
input		wire				CPUA_Target_RW_i,		// Read or Write 
input		wire	[3:0]		CPUA_Target_Be_i,
input		wire	[31:0]	CPUA_Target_Data_2_Write_i,
output	wire				iSingleWrite_Done_o,
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

input		wire	[6:0]		Debug_i,

// Video RAM Bank A
inout		wire		[31:0]	VRAM_A_DQ_io,
output	wire		[3:0]		VRAM_A_BEn_o,
output	wire		[19:0]	VRAM_A_Addy_o,
output	wire					VRAM_A_OEn_o,
output	wire					VRAM_A_WEn_o,
// Video RAM Bank B
inout		wire		[31:0]	VRAM_B_DQ_io,
output	wire		[3:0]		VRAM_B_BEn_o,	
output	wire		[19:0]	VRAM_B_Addy_o,
output	wire					VRAM_B_OEn_o,
output	wire					VRAM_B_WEn_o

);

wire	[19:0]	VGE_Addy_o;	// 1Mx32
wire	[31:0]	VGE_VidMem_Data_i;
wire	[31:0]	VGE_VidMem_Data_o;
wire				VGE_VidMem_Readn_o;
wire	[3:0]		VGE_VidMem_Writen_o;


reg	[20:0]	Source_Addy;
reg	[18:0] 	Transfer_Size;
reg	[3:0]		ByteEnable;
reg 				Read_Start;
reg 				Write_Start;

always @ ( posedge EngineClk100Mhz_i) begin
	if ( Reset_100Mhz_i ) begin
		Read_Start <= 1'b0;
		Write_Start <= 1'b0;
	end
	else begin
		Read_Start <= ( BitMap_Target_Start_i | TileMap_Target_Start_i | Sprite_Target_Start_i | ( CPUA_Target_Start_i & CPUA_Target_RW_i));
		Write_Start <= ( CPUA_Target_Start_i & !CPUA_Target_RW_i);
	end
end

always @ ( * ) begin
	case(Counter_Channel_i[1:0])
		2'b00: ByteEnable = CPUA_Target_Be_i;
		2'b01: ByteEnable = 4'b1111;
		2'b10: ByteEnable = 4'b1111;
		2'b11: ByteEnable = 4'b1111;
	endcase
end

// This is to give the DRAM Controller the Start Address
always @ ( * )  begin
	case(Counter_Channel_i[1:0])
		2'b00: Source_Addy = CPUA_Target_Addy_Start_i;
		2'b01: Source_Addy = BitMap_Target_Addy_Start_i;
		2'b10: Source_Addy = TileMap_Target_Addy_Start_i;
		2'b11: Source_Addy = Sprite_Target_Addy_Start_i;
	endcase
end

always @ ( * )  begin
	case(Counter_Channel_i[1:0])
		2'b00: Transfer_Size = CPUA_Target_Addy_Size_i;
		2'b01: Transfer_Size = BitMap_Target_Addy_Size_i;
		2'b10: Transfer_Size = TileMap_Target_Addy_Size_i;
		2'b11: Transfer_Size = Sprite_Target_Addy_Size_i;
	endcase
end

always @ (posedge EngineClk100Mhz_i)
begin
	Data_Output_Valid_o <= (Counter_Channel_i[1:0] == 2'b00) ? CPUA_Target_RW_i : iData_Valid;
	DataInputChannel0_o <= VGE_VidMem_Data_i;
	DataInputChannel1_o <= VGE_VidMem_Data_i;
	DataInputChannel2_o <= VGE_VidMem_Data_i;
	DataInputChannel3_o <= VGE_VidMem_Data_i;
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

/////////////////////////////////////////////////
////////////
///////////   VDMA SECTION
////////////
/////////////////////////////////////////////////


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


