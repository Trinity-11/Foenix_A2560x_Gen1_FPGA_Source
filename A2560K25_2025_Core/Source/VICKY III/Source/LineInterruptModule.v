module LineInterruptModule
(
// Video Timming Signals
input		wire				VideoClk_i,
input		wire				VideoRst_i,
input		wire	[11:0]	HLineCount_i,
input		wire	[11:0]	HPixelCount_i,
input		wire				Vsync_i,
input		wire				VBlanking_i,
input		wire				HBlanking_i,
input		wire				VideoModeReset_i,
input		wire	[11:0]	V_Blanking_Value_i,
input		wire	[3:0]		Interrupt_Enable_i,
input		wire	[11:0]	Vicky_Interrupt_LineCompare0_i,
input		wire	[11:0]	Vicky_Interrupt_LineCompare1_i,

output	wire				LineInterrupt_o
);

reg	[1:0]			LineChangeEDGE;
wire [11:0]			HLineCountWithoutBlanking;

assign HLineCountWithoutBlanking = (HLineCount_i < V_Blanking_Value_i) ? 12'b0000_0000_0000 : (HLineCount_i - V_Blanking_Value_i); 


always @ (posedge VideoClk_i) begin
		LineChangeEDGE[0] <= HBlanking_i;
		LineChangeEDGE[1] <= LineChangeEDGE[0];
end

reg	[7:0]			FireInt0;
reg	[7:0]			FireInt1;


assign LineInterrupt_o = (FireInt0[7] & Interrupt_Enable_i[0]) || (FireInt1[7] & Interrupt_Enable_i[1]);


always @ (posedge VideoClk_i) begin
	if (VideoRst_i | VideoModeReset_i) begin
		FireInt0 <= 4'b0000;
		FireInt1 <= 4'b0000;		
	end
	else begin
			FireInt0 <= FireInt0 << 1'b1;
			FireInt1 <= FireInt1 << 1'b1;
	
		if (LineChangeEDGE[1:0] == 2'b10) begin
			if (Vicky_Interrupt_LineCompare0_i == HLineCountWithoutBlanking)
				FireInt0 <= 8'b1111_1111;
				
			if (Vicky_Interrupt_LineCompare1_i == HLineCountWithoutBlanking)
				FireInt1 <= 8'b1111_1111;
		end
	
	end
end

/*
wire	[63:0]	 Chipscope;
wire				Trigger;

assign Chipscope[11:0] = HLineCount_i;
assign Chipscope[23:12] = HPixelCount_i;
assign Chipscope[35:24] = Vicky_Interrupt_LineCompare0_i;
assign Chipscope[47:36] = Vicky_Interrupt_LineCompare1_i;
assign Chipscope[59:48] = HLineCountWithoutBlanking;
assign Chipscope[61:60] = Interrupt_Enable_i[1:0];
assign Chipscope[62] = FireInt0[7];
assign Chipscope[63] = LineInterrupt_o;

assign Trigger = (LineChangeEDGE[1:0] == 2'b10) ? 1'b1 : 1'b0;

ChipScope IntelChipScope(
		.acq_clk(VideoClk_i),        //    acq_clk.clk
		.acq_data_in(Chipscope),    //        tap.acq_data_in
		.acq_trigger_in(Trigger), //           .acq_trigger_in
		.trigger_in(Trigger)      // trigger_in.trigger_in
	);
*/

endmodule

