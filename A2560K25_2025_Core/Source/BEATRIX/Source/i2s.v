module i2s
#(
	parameter AUDIO_DW = 16
)
(
	input      reset,
	input      clk,
	input      ce,

	output reg sclk,
	output reg lrclk,
	output reg sdata,
	output reg lrclkx2,

	input [AUDIO_DW-1:0]	left_chan,
	input [AUDIO_DW-1:0]	right_chan
);
/*
wire 	[127:0]		CS;
wire					Trigger_In;

//assign Trigger_In = Txf_Done;
//assign Trigger_In = CS_Txt_Background_Plt | CS_Txt_Foreground_Plt;
assign Trigger_In = (left_chan[15:0] == 16'h0000) ? 1'b0 : 1'b1;

assign CS[31:0] 	= {16'h0000, left_chan};
assign CS[63:32] 	= {16'h0000, right_chan};

assign CS[64] 	= sclk;
assign CS[65] 	= lrclk;
assign CS[66] 	= sdata;


ChipScope u0 (
	.acq_data_in    (CS),    //        tap.acq_data_in
	.acq_trigger_in (Trigger_In), //           .acq_trigger_in
	.acq_clk        (sclk),        //    acq_clk.clk
	.trigger_in     (Trigger_In)      // trigger_in.trigger_in
);
*/
reg  [7:0] bit_cnt;


always @(posedge clk) begin
	if (reset) begin
		lrclkx2 <= 1'b0; 
	end
	else begin
		if (bit_cnt == 14) begin	
			lrclkx2 <= 1'b0; 
		end
		
		if (bit_cnt == 6) begin	
			lrclkx2 <= 1'b1; 
		end	
	end
end

always @(posedge clk) begin
reg msclk;
reg [AUDIO_DW-1:0] left;
reg [AUDIO_DW-1:0] right;


	if (reset) begin
		bit_cnt <= 1;
		lrclk   <= 1;
		sclk    <= 1;
		msclk   <= 1;

	end
	else begin
		sclk <= msclk;
		if(ce) begin
			msclk <= ~msclk;
			if(msclk) begin
				if(bit_cnt >= AUDIO_DW) begin
					bit_cnt <= 1;
					lrclk <= ~lrclk;

					if(lrclk) begin
						left  <= left_chan;
						right <= right_chan;
					end
				end
				else begin
					bit_cnt <= bit_cnt + 1'd1;
				end
				
				sdata <= lrclk ? right[AUDIO_DW - bit_cnt] : left[AUDIO_DW - bit_cnt];
			end
		end
	end
end

endmodule

