
module SoundChips2DAC_Interface(
input		wire				Audio_Clk,	//2457600

input		wire				ChipTune_Clk_i, 

input		wire				BUS_Rst_i,	// Reset Valid Hi
input		wire				BUS_Clk_i,	// 20Mhz

input		wire	[31:0]	BUS_A_i,
input		wire	[7:0]		BUS_D8_i,
input		wire	[15:0]	BUS_D16_i,
input		wire	[31:0]	BUS_D32_i,
input		wire	[1:0]		BUS_Siz_i,
input		wire				BUS_RW_i,
input		wire	[3:0]		BUS_BE_i,
input		wire				BUS_WE_i, 
input		wire				BUS_A_Valid_i,
input		wire				CS_L_PSG_i,
input		wire				CS_R_PSG_i,
input		wire				CS_S_PSG_i,

input		wire				CS_OPN2_i,
input		wire				CS_OPM_i,

input		wire				CS_FPGA_YM2149_R_i,
input		wire				CS_FPGA_YM2149_L_i,
input		wire				CS_FPGA_YM2149_S_i,

input		wire				CS_FPGA_L_SID_i,
input		wire				CS_FPGA_R_SID_i,
input		wire				CS_FPGA_S_SID_i,
output	wire	[7:0]		DataOut_OPN2_o,
output	wire	[7:0]		DataOut_OPM_o,
output	wire	[7:0]		DataOut_SID_L_o,
output	wire	[7:0]		DataOut_SID_R_o,

input		wire	[1:0]		LPF_MODE_i,
input		wire				en_hifi_pcm_i,
input		wire				extfilter_en_i,
//input		wire				LADDER_i,
//input		wire				ENABLE_FM_i,
input		wire				ENABLE_PSG_i,
input		wire				audio_96k_i,
input		wire	[4:0]		vol_att_i,
input		wire	[1:0]		audio_mix_i,


//output	wire	[15:0]	I2S_Data_L_o,
//output	wire	[15:0]	I2S_Data_R_o

// I2S Output
output	wire				I2S_BCLK_o,
output	wire				I2S_LRCLK_o,
output	wire				I2S_DATA_o
);

assign DataOut_OPM_o = 8'h4E;
assign DataOut_OPN2_o = 8'h4E;
assign DataOut_SID_L_o = 8'h4C;
assign DataOut_SID_R_o = 8'h52;


wire all_ChipSelect;
wire [31:0] FIFO_Data_Out;

assign all_ChipSelect = CS_FPGA_YM2149_S_i | CS_FPGA_YM2149_R_i | CS_FPGA_YM2149_L_i| CS_FPGA_S_SID_i | CS_FPGA_R_SID_i | CS_FPGA_L_SID_i | CS_OPM_i | CS_OPN2_i | CS_S_PSG_i | CS_R_PSG_i | CS_L_PSG_i;

CT_FIFO	CT_FIFO_inst (
	.data ( { 1'b0, CS_FPGA_YM2149_S_i, CS_FPGA_YM2149_R_i, CS_FPGA_YM2149_L_i, CS_FPGA_S_SID_i, CS_FPGA_R_SID_i, CS_FPGA_L_SID_i, CS_OPM_i, CS_OPN2_i, CS_S_PSG_i, CS_R_PSG_i, CS_L_PSG_i, BUS_D8_i, BUS_A_i[11:0]} ),
	.wrclk ( BUS_Clk_i ),
	.wrreq ( all_ChipSelect & !BUS_RW_i & (BUS_Siz_i[1:0] == 2'b01) & BUS_WE_i),
	.wrfull (  ),

	// Chip Tune Side with 14.318Mhz Interace
	.rdclk ( ChipTune_Clk_i ),
	.rdreq ( Read_Data_Strobe ),
	.q ( FIFO_Data_Out ),
	.rdempty ( Read_FIFO_Empty )
	);
/*	
wire [143:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger1 = (FIFO_Data_Out[23:16] != 8'h00);

assign TinyTP1[23:0]  	= FIFO_Data_Out;
assign TinyTP1[24] 		= Read_Data_Strobe;
assign TinyTP1[25]   	= Read_FIFO_Empty;


assign TinyTP1[29:26]	= CT_SM;
assign TinyTP1[30] 		= CS_PSG_L;
assign TinyTP1[31]		= CS_PSG_R;
assign TinyTP1[32]		= CS_PSG_S;
assign TinyTP1[33]		= CS_OPM;
assign TinyTP1[34]		= CS_OPN2;
assign TinyTP1[35] 		= CS_SID_L;
assign TinyTP1[36] 		= CS_SID_R;
assign TinyTP1[37] 		= CS_SID_S;
assign TinyTP1[47:40]	= Data_2_Write;
assign TinyTP1[55:48]	= Addy_2_Write;
assign TinyTP1[56] 		= Write_Strobe;




TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (ChipTune_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);	
*/

wire [15:0] YM2151FM_Left;
wire [15:0] YM2151FM_Right;
wire [15:0] YM2612FM_Left;
wire [15:0] YM2612FM_Right;



reg			Read_Data_Strobe;
wire			Read_FIFO_Empty;

reg [3:0]	CT_SM;

localparam 	IDLE 	= 4'b0000,
				ST0	= 4'b0001,
				ST1	= 4'b0010,
				ST2	= 4'b0011,
				ST3	= 4'b0100,
				ST4	= 4'b0101,
				ST5	= 4'b0110,
				ST6	= 4'b0111,
				ST7	= 4'b1000,
				ST8	= 4'b1001,
				ST9	= 4'b1010,
				ST10	= 4'b1011,
				ST11	= 4'b1100,
				ST12	= 4'b1101,
				ST13	= 4'b1110,
				ST14	= 4'b1111;

reg CS_SID_L;
reg CS_SID_R;
reg CS_SID_S;

reg CS_PSG_L;
reg CS_PSG_R;
reg CS_PSG_S;

reg CS_OPM;
reg CS_OPN2;

//reg CS_AY_L;
//reg CS_AY_R;
//reg CS_AY_S;

reg [11:0] 	Data_2_Write;
reg [11:0] 	Addy_2_Write;
reg 		 	YM2151_A0;
reg		 	Write_Strobe;


			
always @ ( posedge ChipTune_Clk_i) begin
	if ( Local_Reset ) begin
		CT_SM <= IDLE;
		Read_Data_Strobe <= 1'b0;
		Write_Strobe <= 1'b0;		
	end
	else begin
	
	case ( CT_SM ) 
	
		IDLE: begin 
			if ( Read_FIFO_Empty == 1'b0 ) begin
				Read_Data_Strobe <= 1'b1;
				CT_SM <= ST0;
			end
			else begin
				Write_Strobe <= 1'b0;
			end
		end
		
		// Read Strobe is 1 Here
		ST0: begin
			Read_Data_Strobe <= 1'b0;		
			CT_SM <= ST1;
		end
		
		// Read Strobe is 0 Here
		ST1: begin
			CT_SM <= ST2;
		end
		
		
		// Data Valid Here
		ST2: begin
			Addy_2_Write <= FIFO_Data_Out[11:0]; // Address
			// okay, let's establish if it is a SID or a Yamaha
			if ( FIFO_Data_Out[24] || FIFO_Data_Out[23] ) begin		//OPN2 & OPM
			// Yamaha Here
				Data_2_Write <= FIFO_Data_Out[11:0];	// Address first for the Yamaha
				YM2151_A0    <= 1'b0;
				CT_SM <= ST8;				
			end
			else begin
			// PSG and SID here
				Data_2_Write <= {4'b0000, FIFO_Data_Out[19:12]};			
				CT_SM <= ST3;
			end
		end
		
		ST3: begin
			CS_SID_L <= FIFO_Data_Out[ 25 ];
			CS_SID_R <= FIFO_Data_Out[ 26 ];
			CS_SID_S <= FIFO_Data_Out[ 27 ];
		
			CS_PSG_L <= FIFO_Data_Out[ 20 ];
			CS_PSG_R <= FIFO_Data_Out[ 21 ];
			CS_PSG_S <= FIFO_Data_Out[ 22 ];
		
			CT_SM <= ST4;
		end
		//CS_FPGA_S_SID_i, CS_FPGA_R_SID_i, CS_FPGA_L_SID_i, DataOut_OPM_o, DataOut_OPN2_o, CS_S_PSG_i, CS_R_PSG_i, CS_L_PSG_i, BUS_D8_i, BUS_A_i[7:0]
//			CS_OPM 	<= FIFO_Data_Out[ 20 ];
//			CS_OPN2 	<= FIFO_Data_Out[ 19 ];
		
		ST4: begin
			Write_Strobe <= 1'b1;
			CT_SM <= ST5;
		end
		
		ST5: begin 
			CT_SM <= ST6;
		end
		
		ST6: begin 
			CT_SM <= ST7;
		end
		
		ST7: begin 
			Write_Strobe <= 1'b0;		
			CS_SID_L <= 1'b0;
			CS_SID_R <= 1'b0;
			CS_SID_S <= 1'b0;
		
			CS_PSG_L <= 1'b0;
			CS_PSG_R <= 1'b0;
			CS_PSG_S <= 1'b0;
			CT_SM <= IDLE;	
		end
		
		// Yamaha Cycles Starts here
		ST8: begin 
			CS_OPN2 	<= FIFO_Data_Out[ 23 ];
			CS_OPM 	<= FIFO_Data_Out[ 24 ];
			Write_Strobe <= 1'b1;			
			CT_SM <= ST9;			
		end
		
		ST9: begin
			CT_SM <= ST10;			
		end

		// Write Enable Valid Here
		ST10: begin
			Write_Strobe <= 1'b0;		
			CS_OPM    	<= 1'b0;
			CS_OPN2		<= 1'b0;
			YM2151_A0   <= 1'b1;
			Data_2_Write <= {4'b0000, FIFO_Data_Out[19:12]};	// Data
			CT_SM <= ST11;			
		end
		
		// Write Invalid Here
		ST11: begin 
			CS_OPM 	<= FIFO_Data_Out[ 24 ];	
			CS_OPN2 	<= FIFO_Data_Out[ 23 ];			
			Write_Strobe <= 1'b1;
			CT_SM <= ST12;
		end
		
		ST12: begin 
			CT_SM <= ST13;
		end
		
		ST13: begin 
			Write_Strobe <= 1'b0;		
			CS_OPM 	<= 1'b0;	
			CS_OPN2	<= 1'b0;
			CT_SM <= ST14;
		end
		
		ST14: begin 
			CT_SM 	<= IDLE;			
		end

		default: begin
			CT_SM <= IDLE;
		end
	
	endcase
	
	end
end
	
	
	
	
	
	
reg [1:0] ReSync_Reset;
wire Local_Reset;

assign Local_Reset = ReSync_Reset[1];

always @ ( posedge  ChipTune_Clk_i) begin
	ReSync_Reset[0] <= BUS_Rst_i;
	ReSync_Reset[1] <= ReSync_Reset[0];
end

reg	PSG_CLKEN;
reg	SID_CLKEN;
reg	OPM_CLKEN;
reg	OPN2_CLKEN;
reg	OPM_CLKEN_HALF;
// Clock Enable to Divide the Original System Clock
always @(posedge ChipTune_Clk_i) begin
	reg [4:0] PCLKCNT = 0;
	reg [4:0] SCLKCNT = 0;
	reg [4:0] MCLKCNT = 0;
	reg [4:0] NCLKCNT = 0;
	reg [4:0] MHCLKCNT = 0;
	
	if ( Local_Reset ) begin
		PCLKCNT <= 0;
		SCLKCNT <= 0;
		MCLKCNT <= 0;
		MHCLKCNT <= 0;
		NCLKCNT <= 0;
	end
	else begin
		// PSG - 3.58 or 4M
		PSG_CLKEN <= 0;
		PCLKCNT <= PCLKCNT + 1'b1;
		if (PCLKCNT == 4) begin			// In the original Code the Frequency to be divide is 53.693175Mhz and it is divide by 14
			PCLKCNT <= 0;					// in our case, the frequency of MCLK = 20 so, the division will be 5 = 4Mhz
			PSG_CLKEN <= 1;
		end
		
		// 1Mhz
		SID_CLKEN <= 0;
		SCLKCNT <= SCLKCNT + 1'b1;
		if (SCLKCNT == 14) begin			// in the case of the SID, the frequency ought to be 14
			SCLKCNT <= 0;
			SID_CLKEN <= 1;
		end	
	
		// 3.58Mhz
		OPM_CLKEN <= 0;
		MCLKCNT <= MCLKCNT + 1'b1;
		if (MCLKCNT == 4) begin			// in the case of the SID, the frequency ought to be 14
			MCLKCNT <= 0;
			OPM_CLKEN <= 1;
		end		

		// 1.78Mhz
		OPM_CLKEN_HALF <= 0;
		MHCLKCNT <= MHCLKCNT + 1'b1;
		if (MHCLKCNT == 8) begin			// in the case of the SID, the frequency ought to be 14
			MHCLKCNT <= 0;
			OPM_CLKEN_HALF <= 1;
		end			
		
		// 7.12Mhz
		OPN2_CLKEN <= 0;
		NCLKCNT <= NCLKCNT + 1'b1;
		if (NCLKCNT == 2) begin			// in the case of the SID, the frequency ought to be 14
			NCLKCNT <= 0;
			OPN2_CLKEN <= 1;
		end	
		
	end
end


wire [17:0] audio6581_L;
wire [17:0] audio6581_R;
wire	[7:0] Int_SID_L_D_o;

/*
reg [3:0] Sid_Left_Write_Strobe;
reg [3:0] Sid_Right_Write_Strobe;

reg [1:0] SIDSM;


always @ (posedge BUS_Clk_i) begin

	if ( BUS_Rst_i ) begin
		SIDSM <= 2'b00;
	
	end 
	else begin
		Sid_Left_Write_Strobe <= Sid_Left_Write_Strobe << 1'b1;
		Sid_Right_Write_Strobe <= Sid_Right_Write_Strobe << 1'b1;
	
		case (SIDSM)
			2'b00: begin
				if (( CS_FPGA_L_SID_i | CS_FPGA_S_SID_i ) && !BUS_RW_i && (BUS_Siz_i[1:0] == 2'b01) && BUS_WE_i)
				begin
					Sid_Left_Write_Strobe <= 4'b1000;
					SIDSM = 2'b01;
				end
		
				if (( CS_FPGA_R_SID_i | CS_FPGA_S_SID_i ) && !BUS_RW_i && (BUS_Siz_i[1:0] == 2'b01) && BUS_WE_i)
				begin
					Sid_Right_Write_Strobe <= 4'b1000;
					SIDSM = 2'b01;				
				end
			end
		
			2'b01: begin
				SIDSM = 2'b10;			
			end
		
			2'b10: begin
				SIDSM = 2'b11;			
			end
		
			2'b11: begin
				SIDSM = 2'b00;			
			end
		endcase
	
	end
		
end
*/

//--------------------------------------------------------------
// SID 
//--------------------------------------------------------------
sid_top sid_6581_Left
(
	.clock( ChipTune_Clk_i ),	//14M
	.reset( Local_Reset ),
	.start_iter( SID_CLKEN ),

	.addr( Addy_2_Write ),
	.wren( (CS_SID_L | CS_SID_S) & Write_Strobe),
	.wdata( Data_2_Write[7:0] ),
	.rdata(  ),

	.extfilter_en(extfilter_en_i),
	.sample_left(audio6581_L)
);

sid_top sid_6581_Right
(
	.clock( ChipTune_Clk_i ),
	.reset( Local_Reset ),
	.start_iter( SID_CLKEN ),

	.addr( Addy_2_Write ),
	.wren( (CS_SID_R | CS_SID_S) & Write_Strobe ),
	.wdata( Data_2_Write[7:0] ),
	.rdata(  ),

	.extfilter_en(extfilter_en_i),
	.sample_left( audio6581_R )
);


reg [15:0] alo,aro;
always @(posedge Audio_Clk) begin
	reg [16:0] alm,arm;

	alm <= {audio6581_L[17],audio6581_L[17:2]};
	arm <= {audio6581_R[17],audio6581_R[17:2]};
	alo <= ($signed(alm) > $signed(17'd32767)) ? 16'd32767 : ($signed(alm) < $signed(-17'd32768)) ? -16'd32768 : alm[15:0];
	aro <= ($signed(arm) > $signed(17'd32767)) ? 16'd32767 : ($signed(arm) < $signed(-17'd32768)) ? -16'd32768 : arm[15:0];
end


//--------------------------------------------------------------
// SN76489
//--------------------------------------------------------------
wire signed [10:0] PSG_L_SND;
jt89 psg_Left
(
	.rst(Local_Reset),
	.clk(ChipTune_Clk_i),
	.clk_en(PSG_CLKEN),

	.wr_n( !( CS_PSG_L | CS_PSG_S ) | Write_Strobe),
	.din( Data_2_Write[7:0] ),

	.sound( PSG_L_SND )
);

wire signed [15:0] PSG_L_SOUND_EXT;

assign PSG_L_SOUND_EXT = PSG_L_SND[10] ? { 2'b11, PSG_L_SND[10:0], 3'b000} : {2'b00, PSG_L_SND[10:0], 3'b000};


wire signed [10:0] PSG_R_SND;
jt89 psg_Right
(
	.rst(Local_Reset),
	.clk(ChipTune_Clk_i),
	.clk_en(PSG_CLKEN),

	.wr_n( !( CS_PSG_R | CS_PSG_S ) | Write_Strobe),
	.din( Data_2_Write[7:0] ),

	.sound( PSG_R_SND )
);

wire signed [15:0] PSG_R_SOUND_EXT;

assign PSG_R_SOUND_EXT = PSG_R_SND[10] ? { 2'b11, PSG_R_SND[10:0], 3'b000} : {2'b00, PSG_R_SND[10:0], 3'b000};


jt51 Internal_YM2151(
    .rst( Local_Reset ),    // reset
    .clk( ChipTune_Clk_i ),    // main clock 14Mhz
    .cen( OPM_CLKEN ),    // clock enable
    .cen_p1( OPM_CLKEN_HALF ), // clock enable at half the speed
    .cs_n( !CS_OPM ),   // chip select
    .wr_n( !Write_Strobe ),   // write
    .a0( YM2151_A0 ),
    .din( Data_2_Write[7:0] ), // data in
    .dout(  ), // data out
    // peripheral control
    .ct1(  ),
    .ct2(  ),
    .irq_n(  ),  // I do not synchronize this signal
    // Low resolution output (same as real chip)
    .sample(  ), // marks new output sample
    .left(  ),
    .right(  ),
    // Full resolution output
    .xleft( YM2151FM_Left ),
    .xright( YM2151FM_Right ),
    // unsigned outputs for sigma delta converters, full resolution
    .dacleft(  ),
    .dacright(  )
);



jt12 Internal_YM2612
(
	.rst( Local_Reset ),
	.clk( ChipTune_Clk_i ),	// 
	.cen( OPN2_CLKEN ),	// Original Clock, so no Clock Enable

	.cs_n( !CS_OPN2 ),
	.addr( {7'b000_0000, Data_2_Write[8], YM2151_A0}),
	.wr_n( !Write_Strobe ),
	.din( Data_2_Write[7:0] ),
	.dout(  ),
	.irq_n(  ),
	.en_hifi_pcm( 1'b0 ),
	
	.snd_left( YM2612FM_Left ),
	.snd_right( YM2612FM_Right )
);

/*
module jt49 ( // note that input ports are not multiplexed
    .rst_n,
    .clk,    // signal on positive edge
    .clk_en, 	// synthesis direct_enable = 1 ,
    .addr,	// Addy[3:0]
    cs_n,
    input            wr_n,  // write
    input  [7:0]     din,
    input            sel, // if sel is low, the clock is divided by 2
    output reg [7:0] dout,
    output reg [9:0] sound,  // combined channel output
    output reg [7:0] A,      // linearised channel output
    output reg [7:0] B,
    output reg [7:0] C,
    output           sample,

    input      [7:0] IOA_in,
    output     [7:0] IOA_out,

    input      [7:0] IOB_in,
    output     [7:0] IOB_out
);
*/
//reg [7:0] Data_2_Write;
//reg [7:0] Addy_2_Write;
//reg		 Write_Strobe;
/*
			CS_SID_L <= 1'b0;
			CS_SID_R <= 1'b0;
			CS_SID_S <= 1'b0;
		
			CS_PSG_L <= 1'b0;
			CS_PSG_R <= 1'b0;
			CS_PSG_S <= 1'b0;
		
			CS_OPM 	<= 1'b0;
			CS_OPN2 	<= 1'b0;
*/


/*

wire signed [15:0] fm_adjust_l = (FM_left << 4) + (FM_left << 2) + (FM_left << 1) + (FM_left >>> 2);
wire signed [15:0] fm_adjust_r = (FM_right << 4) + (FM_right << 2) + (FM_right << 1) + (FM_right >>> 2);

genesis_fm_lpf fm_lpf_l
(
	.clk(!BUS_Clk_i),
	.reset(BUS_Rst_i),
	.in(fm_adjust_l),
	.out(FM_LPF_left)
);

genesis_fm_lpf fm_lpf_r
(
	.clk(!BUS_Clk_i),
	.reset(BUS_Rst_i),
	.in(fm_adjust_r),
	.out(FM_LPF_right)
);

wire signed [15:0] fm_select_l = ((LPF_MODE_i == 2'b01) ? FM_LPF_left : fm_adjust_l);
wire signed [15:0] fm_select_r = ((LPF_MODE_i == 2'b01) ? FM_LPF_right : fm_adjust_r);
*/
/*
wire signed [10:0] psg_adjust = PSG_SND - (PSG_SND >>> 5);

jt12_genmix genmix
(
	.rst(BUS_Rst_i),
	.clk(!BUS_Clk_i),
	.fm_left(fm_select_l),
	.fm_right(fm_select_r),
	.psg_snd(psg_adjust),
	.fm_en(ENABLE_FM_i),
	.psg_en(ENABLE_PSG_i),
	.snd_left(PRE_LPF_L),
	.snd_right(PRE_LPF_R)
);

wire [15:0]	DAC_RDATA;
wire [15:0]	DAC_LDATA;

genesis_lpf lpf_right
(
	.clk(!BUS_Clk_i),
	.reset(BUS_Rst_i),
	.lpf_mode(LPF_MODE_i[1:0]),
	.in(PRE_LPF_R),
	.out(DAC_RDATA)
);

genesis_lpf lpf_left
(
	.clk(!BUS_Clk_i),
	.reset(BUS_Rst_i),
	.lpf_mode(LPF_MODE_i[1:0]),
	.in(PRE_LPF_L),
	.out(DAC_LDATA)
);
*/

//// AUDIO OUT SECTION
//// Different Clock Kingdom
////
reg [31:0] aflt_rate = 7056000;
reg [39:0] acx  = 4258969;
reg  [7:0] acx0 = 3;
reg  [7:0] acx1 = 3;
reg  [7:0] acx2 = 1;
reg [23:0] acy0 = -24'd6216759;
reg [23:0] acy1 =  24'd6143386;
reg [23:0] acy2 = -24'd2023767;
//reg        areset = 0;
//reg [11:0] arc1x = 0;
//reg [11:0] arc1y = 0;
//reg [11:0] arc2x = 0;
//reg [11:0] arc2y = 0;

audio_out audio_out
(
	.reset(BUS_Rst_i),
	.clk(Audio_Clk),

	.att(vol_att_i),
	.mix(audio_mix_i),
	.sample_rate(audio_96k_i),

	.flt_rate(aflt_rate),
	.cx(acx),
	.cx0(acx0),
	.cx1(acx1),
	.cx2(acx2),
	.cy0(acy0),
	.cy1(acy1),
	.cy2(acy2),

	.is_signed(1'b1),
	.YM2151_audio_l_i( YM2151FM_Left ),
	.YM2151_audio_r_i( YM2151FM_Right ),
	
	.YM2612_audio_l_i( YM2612FM_Left ), 
	.YM2612_audio_r_i( YM2612FM_Right ),
	
	.SID_audio_l_i( alo ),		// SID
	.SID_audio_r_i( aro ),		// SID
	//.core_l({{16{DAC_LDATA[15]}}, DAC_LDATA}),
	//.core_r({{16{DAC_LDATA[15]}}, DAC_RDATA}),
	
	.core_l(PSG_L_SOUND_EXT),
	.core_r(PSG_R_SOUND_EXT),	

	//.I2S_Data_L_o( I2S_Data_L_o ), 
	//.I2S_Data_R_o( I2S_Data_R_o ) 	
	
	.i2s_bclk(I2S_BCLK_o),
	.i2s_lrclk(I2S_LRCLK_o),
	.i2s_data(I2S_DATA_o)
);


/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

assign TinyTrigger1 = CS_FPGA_L_SID_i;

assign TinyTP1[23:0]  	= BUS_A_i;
assign TinyTP1[39:24] 	= BUS_Data_i;
assign TinyTP1[57:40]   = audio6581_L;
assign TinyTP1[58]		= SID_CLKEN;
assign TinyTP1[59] 		= Sid_Left_Write_Strobe[3];
assign TinyTP1[60]		= Sid_Right_Write_Strobe[3];
assign TinyTP1[61]      = BUS_RW_i;
assign TinyTP1[63:62]	= iBUS_BE_i;

TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (BUS_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/

endmodule


