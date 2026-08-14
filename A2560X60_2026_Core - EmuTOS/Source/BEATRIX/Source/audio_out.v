module audio_out
#(
	parameter CLK_RATE = 24576000
)
(
	input        reset,
	input        clk,
	//0 - 48KHz, 1 - 96KHz
	input        sample_rate,

	input  [31:0] flt_rate,
	input  [39:0] cx,
	input   [7:0] cx0,
	input   [7:0] cx1,
	input   [7:0] cx2,
	input  [23:0] cy0,
	input  [23:0] cy1,
	input  [23:0] cy2,

	input  [4:0] att,

	input        is_signed,
	input [15:0] PSG_Audio_l_i,			// PSG
	input [15:0] PSG_Audio_r_i,
	
	input	[15:0] YM2151_Audio_l_i, // YM2151
	input	[15:0] YM2151_Audio_r_i,
	
	input	[15:0] YM2612_Audio_l_i,
	input	[15:0] YM2612_Audio_r_i,
	
	input	[15:0] SID_Audio_l_i, // SID
	input	[15:0] SID_Audio_r_i,
	
	// I2S is now managed by the CPU to DAC Portion
	// I2S
	//output	[15:0] I2S_Data_L_o, 
	//output	[15:0] I2S_Data_R_o 
	output       i2s_bclk,
	output       i2s_lrclk,
	output       i2s_data
);

reg [15:0] 	PSG_Audio_l_Resync[0:2];
reg [15:0] 	PSG_Audio_r_Resync[0:2];

reg [15:0] 	YM2151_Audio_l_Resync[0:2];
reg [15:0] 	YM2151_Audio_r_Resync[0:2];

reg [15:0] 	YM2612_Audio_l_Resync[0:2];
reg [15:0] 	YM2612_Audio_r_Resync[0:2];

reg [15:0] 	SID_Audio_l_Resync[0:2];
reg [15:0] 	SID_Audio_r_Resync[0:2];


always @ ( posedge clk ) begin 

	PSG_Audio_l_Resync[0] <= PSG_Audio_l_i;
	PSG_Audio_l_Resync[1] <= PSG_Audio_l_Resync[0];
	if ( PSG_Audio_l_Resync[1] == PSG_Audio_l_Resync[0] ) 
		PSG_Audio_l_Resync[2] <= PSG_Audio_l_Resync[1];
		
		
	YM2151_Audio_l_Resync[0] <= YM2151_Audio_l_i;
	YM2151_Audio_l_Resync[1] <= YM2151_Audio_l_Resync[0];
	if ( YM2151_Audio_l_Resync[1] == YM2151_Audio_l_Resync[0] ) 
		YM2151_Audio_l_Resync[2] <= YM2151_Audio_l_Resync[1];	
	
	YM2612_Audio_l_Resync[0] <= YM2612_Audio_l_i;
	YM2612_Audio_l_Resync[1] <= YM2612_Audio_l_Resync[0];
	if ( YM2612_Audio_l_Resync[1] == YM2612_Audio_l_Resync[0] ) 
		YM2612_Audio_l_Resync[2] <= YM2612_Audio_l_Resync[1];	
	
	SID_Audio_l_Resync[0] <= PSG_Audio_r_i;
	SID_Audio_l_Resync[1] <= SID_Audio_l_Resync[0];
	if ( SID_Audio_l_Resync[1] == SID_Audio_l_Resync[0] ) 
		SID_Audio_l_Resync[2] <= SID_Audio_l_Resync[1];	
	
	// Right Channel 
	PSG_Audio_r_Resync[0] <= PSG_Audio_l_i;
	PSG_Audio_r_Resync[1] <= PSG_Audio_r_Resync[0];
	if ( PSG_Audio_r_Resync[1] == PSG_Audio_r_Resync[0] ) 
		PSG_Audio_r_Resync[2] <= PSG_Audio_r_Resync[1];
		
		
	YM2151_Audio_r_Resync[0] <= YM2151_Audio_r_i;
	YM2151_Audio_r_Resync[1] <= YM2151_Audio_r_Resync[0];
	if ( YM2151_Audio_r_Resync[1] == YM2151_Audio_r_Resync[0] ) 
		YM2151_Audio_r_Resync[2] <= YM2151_Audio_r_Resync[1];	
	
	YM2612_Audio_r_Resync[0] <= YM2612_Audio_r_i;
	YM2612_Audio_r_Resync[1] <= YM2612_Audio_r_Resync[0];
	if ( YM2612_Audio_r_Resync[1] == YM2612_Audio_r_Resync[0] ) 
		YM2612_Audio_r_Resync[2] <= YM2612_Audio_r_Resync[1];	
	
	SID_Audio_r_Resync[0] <= SID_Audio_r_i;
	SID_Audio_r_Resync[1] <= SID_Audio_r_Resync[0];
	if ( SID_Audio_r_Resync[1] == SID_Audio_r_Resync[0] ) 
		SID_Audio_r_Resync[2] <= SID_Audio_r_Resync[1];	



end 

localparam AUDIO_RATE = 48000;
localparam AUDIO_DW = 16;

localparam CE_RATE = AUDIO_RATE*AUDIO_DW*8;
localparam FILTER_DIV = (CE_RATE/(AUDIO_RATE*32))-1;

wire [31:0] real_ce = sample_rate ? {CE_RATE[30:0],1'b0} : CE_RATE[31:0];

reg mclk_ce;
always @(posedge clk) begin
	reg [31:0] cnt;

	mclk_ce = 0;
	cnt = cnt + real_ce;
	if(cnt >= CLK_RATE) begin
		cnt = cnt - CLK_RATE;
		mclk_ce = 1;
	end
end

reg i2s_ce;
always @(posedge clk) begin
	reg div;
	i2s_ce <= 0;
	if(mclk_ce) begin
		div <= ~div;
		i2s_ce <= div;
	end
end

i2s i2s
(
	.reset(reset),

	.clk(clk),
	.ce(i2s_ce),

	.sclk(i2s_bclk),
	.lrclk(i2s_lrclk),
	.sdata(i2s_data),

	//.core_l({{16{DAC_LDATA[15]}}, DAC_LDATA}),
	//.core_r({{16{DAC_LDATA[15]}}, DAC_RDATA}),	
	
//	.left_chan(	{{16{al[15]}}, al} ),
//	.right_chan({{16{ar[15]}}, ar} )
	
	.left_chan(	al ),
	.right_chan( ar )
);


//assign I2S_Data_L_o = al;
//assign I2S_Data_R_o = ar;

reg sample_ce;
always @(posedge clk) begin
	reg [8:0] div = 0;
	reg [1:0] add = 0;

	div <= div + add;
	if(!div) begin
		div <= 2'd1 << sample_rate;
		add  <= 2'd1 << sample_rate;
	end

	sample_ce <= !div;
end

//reg flt_ce;
always @(posedge clk) begin
	reg [31:0] cnt = 0;

	//flt_ce = 0;
	cnt = cnt + {flt_rate[30:0],1'b0};
	if(cnt >= CLK_RATE) begin
		cnt = cnt - CLK_RATE;
		//flt_ce = 1;
	end
end
/*
reg [15:0] cl,cr;
always @(posedge clk) begin
	reg [15:0] cl1,cl2;
	reg [15:0] cr1,cr2;

	cl1 <= core_l; cl2 <= cl1;
	if(cl2 == cl1) cl <= cl2;

	cr1 <= core_r; cr2 <= cr1;
	if(cr2 == cr1) cr <= cr2;
end

reg a_en1 = 0, a_en2 = 0;
always @(posedge clk, posedge reset) begin
	reg  [1:0] dly1 = 0;
	reg [14:0] dly2 = 0;

	if(reset) begin
		dly1 <= 0;
		dly2 <= 0;
		a_en1 <= 0;
		a_en2 <= 0;
	end
	else begin
		if(flt_ce) begin
			if(~&dly1) dly1 <= dly1 + 1'd1;
			else a_en1 <= 1;
		end

		if(sample_ce) begin
			if(!dly2[13+sample_rate]) dly2 <= dly2 + 1'd1;
			else a_en2 <= 1;
		end
	end
end

wire [15:0] acl, acr;
IIR_filter #(.use_params(0)) IIR_filter
(
	.clk(clk),
	.reset(reset),

	.ce(flt_ce & a_en1),
	.sample_ce(sample_ce),

	.cx(cx),
	.cx0(cx0),
	.cx1(cx1),
	.cx2(cx2),
	.cy0(cy0),
	.cy1(cy1),
	.cy2(cy2),

	.input_l({~is_signed ^ cl[15], cl[14:0]}),
	.input_r({~is_signed ^ cr[15], cr[14:0]}),
	.output_l(acl),
	.output_r(acr)
);

wire [15:0] adl;
DC_blocker dcb_l
(
	.clk(clk),
	.ce(sample_ce),
	.sample_rate(sample_rate),
	.mute(~a_en2),
	.din(acl),
	.dout(adl)
);

wire [15:0] adr;
DC_blocker dcb_r
(
	.clk(clk),
	.ce(sample_ce),
	.sample_rate(sample_rate),
	.mute(~a_en2),
	.din(acr),
	.dout(adr)
);
*/
wire [15:0] al, audio_l_pre;
aud_mix_top audmix_l
(
	.clk(clk),
	.ce(sample_ce),
	.att(att),
	//.core_audio(adl),
	.Audio_Line0_In(SID_Audio_l_Resync[2]),	
	.Audio_Line1_In(YM2151_Audio_l_Resync[2]),	
	.Audio_Line2_In(YM2612_Audio_l_Resync[2]),	
	.Audio_Line3_In(PSG_Audio_l_Resync[2]),	
	.out(al)
);

wire [15:0] ar, audio_r_pre;
aud_mix_top audmix_r
(
	.clk(clk),
	.ce(sample_ce),
	.att(att),

	.Audio_Line0_In(SID_Audio_r_Resync[2]),	
	.Audio_Line1_In(YM2151_Audio_r_Resync[2]),
	.Audio_Line2_In(YM2612_Audio_r_Resync[2]),	
	.Audio_Line3_In(PSG_Audio_r_Resync[2]),	
	.out(ar)
);

endmodule
module aud_mix_top
(
	input             clk,
	input             ce,

	input       [4:0] att,

	input      [15:0] Audio_Line0_In,
	input      [15:0] Audio_Line1_In,
	input      [15:0] Audio_Line2_In,
	input      [15:0] Audio_Line3_In,

	output reg [15:0] out = 0
);

reg signed [16:0] a1, a2, a3, a4, a5;
always @(posedge clk) if (ce) begin

	a1 <= {Audio_Line0_In[15], Audio_Line0_In};
	a2 <= a1 + {Audio_Line1_In[15],Audio_Line1_In};
	a3 <= a2 + {Audio_Line2_In[15],Audio_Line2_In};
	a4 <= a3 + {Audio_Line3_In[15],Audio_Line3_In};

	if(att[4]) a4 <= 0;
	else a5 <= a4 >>> att[3:0];

	//clamping
	out <= ^a5[16:15] ? {a5[16],{15{a5[15]}}} : a5[15:0];
end

endmodule
