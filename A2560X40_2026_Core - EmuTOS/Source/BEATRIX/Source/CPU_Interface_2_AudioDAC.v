`timescale 1ns / 1ps
module CPU_Interface_2_AudioDAC
#(
	parameter CLK_RATE = 24576000
)
(
input		wire				RST_i,
input		wire				CPU_Clk_i,

// CPU Bus Input
input		wire	[31:0]	CPU_A_i,
input		wire				CPU_RW_i,
input		wire	[7:0]		CPU_D8_i,
input		wire	[15:0]	CPU_D16_i,
input		wire	[31:0]	CPU_D32_i,
input		wire	[1:0]		CPU_Siz_i,
input		wire				CPU_A_Valid_i, 
input		wire	[3:0]		CPU_BE_i,
input		wire				CPU_WE_i, 
output 	reg 	[7:0]		CPU_D_o,
input		wire				CS_SAMPLE_PLAYBACK_i,
output	wire				DAC_Playback_Done_Int_o,

input		wire				I2S_Encoder_Reset_i,
input		wire				Clk_Audio_Sampling_i,

//input		wire	[15:0]	I2S_Data_L_i,
//input		wire	[15:0]	I2S_Data_R_i,

output	wire				i2s_bclk_o,
output	wire				i2s_lrclk_o,
output	wire				i2s_data_o

);

wire sample_rate;

assign sample_rate = 1'b0;

reg [15:0] Right_Side_Output;
reg [15:0] Left_Side_Output;


localparam AUDIO_RATE = 48000;
localparam AUDIO_DW = 16;

localparam CE_RATE = AUDIO_RATE*AUDIO_DW*8;
localparam FILTER_DIV = (CE_RATE/(AUDIO_RATE*32))-1;

wire [31:0] real_ce = sample_rate ? {CE_RATE[30:0],1'b0} : CE_RATE[31:0];

reg mclk_ce;
always @(posedge Clk_Audio_Sampling_i) begin
	reg [31:0] cnt;

	mclk_ce = 0;
	cnt = cnt + real_ce;
	if(cnt >= CLK_RATE) begin
		cnt = cnt - CLK_RATE;
		mclk_ce = 1;
	end
end

reg i2s_ce;
always @(posedge Clk_Audio_Sampling_i) begin
	reg div;
	i2s_ce <= 0;
	if(mclk_ce) begin
		div <= ~div;
		i2s_ce <= div;
	end
end


wire i2s_lrclk_o_x2;
/*
reg signed [16:0] L1, L2;
reg signed [16:0] R1, R2;
reg			[15:0] LOUT, ROUT;

always @ (posedge Clk_Audio_Sampling_i) begin
	L1 <= {Left_Side_Output[15], Left_Side_Output};
	R1 <= {Right_Side_Output[15], Right_Side_Output};
	
	L2 <= L1 + {I2S_Data_L_i[15], I2S_Data_L_i};
	R2 <= R1 + {I2S_Data_R_i[15], I2S_Data_R_i};
	
	LOUT <= L2[16:1];
	ROUT <= R2[16:1];
end
*/




i2s i2s
(
	.reset(I2S_Encoder_Reset_i),

	.clk(Clk_Audio_Sampling_i),
	.ce(i2s_ce),

	.sclk(i2s_bclk_o),
	.lrclk(i2s_lrclk_o),
	.sdata(i2s_data_o),
	.lrclkx2( i2s_lrclk_o_x2 ),		// Twice as fast for the 16Bits Stereo

	.left_chan(	Left_Side_Output ),
	.right_chan( Right_Side_Output )
	
);


// Mode 0 - 8 Bits Mono - 16Bits - 24Khz ( Clk_Audio_Sampling_i / 1024)
// Mode 1 - 8 Bits Stereo - 16 Bits - 48Khz ( Clk_Audio_Sampling_i / 512 )
// Mode 2 - 16 Bits Mono - 16 Bits - 48Khz ( Clk_Audio_Sampling_i / 512 )
// Mode 3 - 16 Bits Stereo - 32 Bits - 96Khz ( Clk_Audio_Sampling_i / 256 )


wire [1:0] Mode;

wire [15:0]	 FIFO_Output16_o;

reg [7:0] Registers[0:3];

assign DAC_Playback_Done_Int_o = Interrupt_Generation[7];

reg [7:0] Interrupt_Generation;
reg		 wrempty_sig_EDGE;

/*
reg[10:0] ClkDevide512;		// this 256
wire SamplingClk;

assign SamplingClk = (Mode == 2'b11) ? ClkDevide512[8] :	// Divide by 256
							(Mode == 2'b10) ? ClkDevide512[9] :	// Divide by 512
							(Mode == 2'b01) ? ClkDevide512[9] : // Divide by 512
							ClkDevide512[10]; 	// Divide by 1024


always @ (posedge Clk_Audio_Sampling_i) begin
	ClkDevide512 <= ClkDevide512 + 11'h0_01;
end

*/

// Interrupt Generation
always @ (posedge CPU_Clk_i) begin
	if (RST_i) begin
		Interrupt_Generation <= 8'h00;
	end
	else begin
		Interrupt_Generation <= Interrupt_Generation << 1'b1;
		wrempty_sig_EDGE <= wrempty_sig;
	
		if ( {wrempty_sig_EDGE, wrempty_sig} == 2'b01 ) begin
			Interrupt_Generation <= 8'b0011_1100;
		end
	end
end


// Register Level.
always @ (posedge CPU_Clk_i) begin
	if (RST_i) begin
		Registers[0] <= 8'h00;
		Registers[1] <= 8'h00;
		Registers[2] <= 8'h00;
		Registers[3] <= 8'h00;
	end
	else begin
		if (CS_SAMPLE_PLAYBACK_i && !CPU_RW_i && (CPU_A_i[3] == 1'b0) && ( CPU_Siz_i[1:0] == 2'b01) && CPU_WE_i) begin
			Registers[CPU_A_i[1:0]] <= CPU_D8_i;
		end	
	end
end

always @ (*) begin
	case (CPU_A_i[2:0])
		3'b000: begin CPU_D_o = Registers[0]; end
		3'b001: begin CPU_D_o = Registers[1]; end
		3'b010: begin CPU_D_o = Registers[2]; end
		3'b011: begin CPU_D_o = Registers[3]; end
		3'b100: begin CPU_D_o = wrusedw_sig[7:0]; end
		3'b101: begin CPU_D_o = { wrempty_sig, wrfull_sig, 2'b00, wrusedw_sig[11:8]}; end
		3'b110: begin CPU_D_o = 8'h00; end
		3'b111: begin CPU_D_o = 8'hFF; end
	endcase
end

/*
wire [71:0] ChipScope;
wire			Trigger;

//assign Trigger = (VDMA_Control_Reg[0] & (Fire_Transfer[1:0] == 2'b01));
assign Trigger = CS_SAMPLE_PLAYBACK_i & !CPU_RW_i & (CPU_A_i[3:1] == 3'b100);  // & (FIFO_VDMA_Data_Count >= 10'd1000)
//assign Trigger = VDMA_Control_Reg[0] & VDMA_Control_Reg[4] & (FIFO_VDMA_Data_Count > 10'h340);

//assign Trigger = VDMA_Control_Reg[0] & VDMA_Control_Reg[4] & (StridePointerCounter == 16'd239);

//assign Trigger = FIFO_VDMA_Read_Strobe & VDMA_Dst_Addy_Enable_o;
//assign Trigger = ((StridePointerCounter == 16'd8) ? 1'b1 : 1'b0);

ChipScope	ChipScope_inst (
	.acq_clk ( !CPU_Clk_i),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

// This is the Signal Driving the Input Side of the DP Memory
// Signal that Drives the VRAM

assign ChipScope[7:0] 		= CPU_D_i;		
assign ChipScope[8] 			= CS_SAMPLE_PLAYBACK_i & !CPU_RW_i & (CPU_A_i[3:1] == 3'b100);
assign ChipScope[9] 			= wrempty_sig;
assign ChipScope[10]			= wrfull_sig;
assign ChipScope[11] 		= Registers0_Resync2[1];
assign ChipScope[15:12] 	= CPU_A_i[3:0];
assign ChipScope[31:20] 	= wrusedw_sig;
*/

//reg Clk_Fifo = 1'b0;

//always @ (posedge i2s_lrclk_o) begin
//	Clk_Fifo <= Clk_Fifo ^ 1'b1;
//end
reg WriteFIFO_EDGE;
wire WriteFIFO;
assign WriteFIFO = (CS_SAMPLE_PLAYBACK_i & !CPU_RW_i & (CPU_A_i[3:0] == 4'b1000) & ( CPU_BE_i[1] & CPU_BE_i[0] ));

always @ (posedge CPU_Clk_i) begin
	WriteFIFO_EDGE <= WriteFIFO;
end

CPU_2_CODEC_DAC_FIFO	CPU_2_CODEC_DAC_FIFO_inst (
	.aclr ( Registers0_Resync2[1] | I2S_Encoder_Reset_i ),
	// Read Side - Audio Side
	.rdclk ( Clk2Samples ),		// In Theory this should be 48Khz
	.rdreq ( Read_Empty_Delayed ),
	.rdempty ( Read_Empty ),
	.rdfull (  ),
	.rdusedw ( ),
	.q ( FIFO_Output16_o ),	
	
	// Write
	.data ( CPU_D8_i ),	
	.wrclk ( CPU_Clk_i ),
	.wrreq ( { WriteFIFO_EDGE, WriteFIFO} ),
	.wrempty ( wrempty_sig ),
	.wrfull ( wrfull_sig ),
	.wrusedw ( wrusedw_sig )
	);

/*
wire [71:0] ChipScope;
wire			Trigger;

assign Trigger = Read_Empty_Delayed;  // & (FIFO_VDMA_Data_Count >= 10'd1000)

ChipScope	ChipScope_inst (
	.acq_clk ( i2s_bclk_o ),		//
	.acq_data_in ( ChipScope ),
	.acq_trigger_in ( Trigger ),
	.trigger_in ( Trigger )
	);

// This is the Signal Driving the Input Side of the DP Memory
// Signal that Drives the VRAM

assign ChipScope[15:0] 		= Left_Side_Output;		
assign ChipScope[31:16] 	= Right_Side_Output;
assign ChipScope[32] 		= i2s_ce;
assign ChipScope[33]			= i2s_bclk_o;
assign ChipScope[34] 		= i2s_lrclk_o;
assign ChipScope[35] 		= i2s_data_o;
assign ChipScope[36]			= Clk2Samples;
*/
	
	
wire Clk2Samples;

assign Clk2Samples = ( Mode[1:0] == 2'b11 ) ? i2s_lrclk_o_x2 : i2s_lrclk_o;
	
//
// UINT8 sample8 = ...;
// INT16 sample16 = (INT16) (sample8 - 0x80) << 8;
//
// Left Side
always @ (*) begin
	case (Mode[1:0])
		2'b00: begin Left_Side_Output = Read_Empty_Delayed ? {(FIFO_Output16_o[15:8] - 8'h80), 8'h00} : {(FIFO_Output16_o[7:0] - 8'h80), 8'h00}; end  						// Divide by 1024 (Mono 8Bits)
		2'b01: begin Left_Side_Output = {(FIFO_Output16_o[7:0] - 8'h80), 8'h00}; end  // Divide by 512 (Stereo 8Bits)
		2'b10: begin Left_Side_Output = FIFO_Output16_o[15:0]; end  						// Divide by 512 (Mono 16Bits)
		2'b11: begin Left_Side_Output = Stereo16Bits_Left[15:0]; end  									// Divide by 256 (Stereo 16Bits)
	endcase
end

// Right Side
always @ (*) begin
	case (Mode[1:0])
		2'b00: begin Right_Side_Output = Read_Empty_Delayed ? {(FIFO_Output16_o[15:8] - 8'h80), 8'h00} : {(FIFO_Output16_o[7:0] - 8'h80), 8'h00}; end // Divide by 1024
		2'b01: begin Right_Side_Output = {(FIFO_Output16_o[15:8] - 8'h80), 8'h00}; end // Divide by 512
		2'b10: begin Right_Side_Output = FIFO_Output16_o[15:0]; end // Divide by 512
		2'b11: begin Right_Side_Output = Stereo16Bits_Right[15:0]; end // Divide by 256
	endcase
end

reg [7:0]	Registers0_Resync0, Registers0_Resync1, Registers0_Resync2;
//reg [7:0]	Registers0_Resync0, Registers0_Resync1, Registers0_Resync2;


// 24.576Mhz
always @ (posedge Clk_Audio_Sampling_i) begin
	Registers0_Resync0 <= Registers[0];
	Registers0_Resync1 <= Registers0_Resync0;
	if (Registers0_Resync0 == Registers0_Resync1)
		Registers0_Resync2 <= Registers0_Resync1; 
end

// Registers0
// Bit0 = Enable
// Bit1 = Reset FIFO
// Bit3:2 = Mode - 00 - 8Bits Mono, 01 - 8Bits Stereo, 10 - 16Bits Mono, 11 - 16Bits Stereo

assign Mode[1:0] = Registers0_Resync2[3:2];


wire Read_Empty;
reg 	Read_Empty_Delayed;
wire wrempty_sig;
wire wrfull_sig;
wire [11:0] wrusedw_sig; 

reg	[15:0] Stereo16Bits_Left;
reg	[15:0] Stereo16Bits_Right;

always @ (posedge i2s_lrclk_o_x2) begin
	if ( i2s_lrclk_o )
		Stereo16Bits_Right <= FIFO_Output16_o;
	else
		Stereo16Bits_Left <= FIFO_Output16_o;	
end

/*
reg [3:0] MiniSt;

localparam 	IDLE 			= 4'b0000,
			   MODE0_ST0 	= 4'b0001,
			   MODE0_ST1 	= 4'b0010, 
			   MODE0_ST2 	= 4'b0011,
			   MODE0_ST3 	= 4'b0100,
				
				MODE1_2_ST0	= 4'b0101,
				MODE1_2_ST1	= 4'b0110,
				MODE1_2_ST2	= 4'b0111,
				MODE1_2_ST3	= 4'b1000,
				
				MODE3_ST0	= 4'b1001,
				MODE3_ST1	= 4'b1010,
				MODE3_ST2	= 4'b1011,
				MODE3_ST3	= 4'b1100
*/

				

always @ (posedge Clk2Samples) begin
	if (Registers0_Resync2[1]) begin
		Read_Empty_Delayed 	<= 1'b0;
	end
	else begin
		
		case (Mode[1:0])
		2'b00: begin 
			if ({Read_Empty_Delayed, Read_Empty} == 2'b00) begin
				Read_Empty_Delayed <= !Read_Empty;			
			end
			else begin
				Read_Empty_Delayed <= 1'b0;
			end
		
		end
		
		2'b01, 2'b10: begin
				Read_Empty_Delayed <= !Read_Empty;
		end
		
		2'b11: begin
				Read_Empty_Delayed <= !Read_Empty;		
		
		end
		
		default: begin
				Read_Empty_Delayed <= !Read_Empty;
		end
		
		endcase
	
	end
end





endmodule

