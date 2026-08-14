
module TimerInterface32 (

input		wire				SOF_Channel_A_i,
input		wire				SOF_Channel_B_i,

input		wire				CPU_Clk_i,
input		wire				RST_i,
input 	wire	[23:0]	CPU_A_i,
input		wire	[7:0]		CPU_D8_i,
input		wire	[15:0]	CPU_D16_i,
input		wire	[31:0]	CPU_D32_i,
input		wire	[1:0]		CPU_Siz_i,
input		wire	[3:0]		CPU_BE_i,
input 	wire				CPU_R_Wn_i,
input		wire				CS_Timer_i,
output 	reg 	[31:0]	CPU_D_o,

output	wire				Interrupt_Timer0_o,
output	wire				Interrupt_Timer1_o,
output	wire				Interrupt_Timer2_o,
output	wire				Interrupt_Timer3_o,
output	wire				Interrupt_Timer4_o
);


reg [31:0]	Timer0_Reg;
reg [31:0]	Timer1_Reg;
reg [31:0]	Timer2_Reg;
reg [31:0]	Timer3_Reg;
reg [31:0]	Timer4_Reg;
reg [31:0]	Compare_Timer0_Reg;
reg [31:0]	Compare_Timer1_Reg;
reg [31:0]	Compare_Timer2_Reg;
reg [31:0]	Compare_Timer3_Reg;
reg [31:0]	Compare_Timer4_Reg;
reg [31:0]	Control0_Reg;
reg [31:0]	Control1_Reg;

reg[1:0] SOF_Channel_A_RESYNC;
reg[1:0] SOF_Channel_B_RESYNC;

always @ (posedge CPU_Clk_i) begin

	SOF_Channel_A_RESYNC[0] <= SOF_Channel_A_i;
	SOF_Channel_A_RESYNC[1] <= SOF_Channel_A_RESYNC[0];
	
	SOF_Channel_B_RESYNC[0] <= SOF_Channel_B_i;
	SOF_Channel_B_RESYNC[1] <= SOF_Channel_B_RESYNC[0];

end


// Keep the Input Value in Registers
always @ (posedge CPU_Clk_i) begin
	if (RST_i) begin
		Control0_Reg <= 32'h0000;
		Control1_Reg <= 32'h0000;
	end
	else begin
		if (CS_Timer_i & !CPU_R_Wn_i) begin
			case (CPU_A_i[5:2])
				// Timer Block
				4'b0000: begin 	Control0_Reg 			<= CPU_D_i;	end
				4'b0001: begin 	Control1_Reg 			<= CPU_D_i;	end
				4'b0010: begin 	Timer0_Reg 				<= CPU_D_i;	end
				4'b0011: begin 	Compare_Timer0_Reg 	<= CPU_D_i;	end
				4'b0100: begin 	Timer1_Reg				<= CPU_D_i;	end
				4'b0101: begin 	Compare_Timer1_Reg  	<= CPU_D_i;	end
				4'b0110: begin 	Timer2_Reg 				<= CPU_D_i;	end
				4'b0111: begin 	Compare_Timer2_Reg 	<= CPU_D_i;	end
				// SOF Counter
				4'b1000: begin 	Timer3_Reg 				<= CPU_D_i;	end
				4'b1001: begin 	Compare_Timer3_Reg 	<= CPU_D_i;	end
				4'b1010: begin 	Timer4_Reg 				<= CPU_D_i;	end
				4'b1011: begin 	Compare_Timer4_Reg 	<= CPU_D_i;	end
				default: begin end
			endcase
		end
	end
end


always @ (*) begin
		case (CPU_A_i[5:2])
			4'b0000: begin 	CPU_D_o = Control0_Reg; end
			4'b0001: begin 	CPU_D_o = { Control1_Reg_L[31:16], Timer4_Compare_eb, Timer3_Compare_eb, Timer2_Compare_eb, Timer1_Compare_eb, Timer0_Compare_eb, 3'b000, Control1_Reg[7:0]}; end
			4'b0010: begin 	CPU_D_o = Timer0_Output[31:0]; end
			4'b0011: begin 	CPU_D_o = 32'h0000_0000; end
			4'b0100: begin 	CPU_D_o = Timer1_Output[31:0]; end
			4'b0101: begin 	CPU_D_o = 32'h0101_0101; end
			4'b0110: begin 	CPU_D_o = Timer2_Output[31:0]; end
			4'b0111: begin 	CPU_D_o = 32'h0202_0202; end
			4'b1000: begin 	CPU_D_o = Timer3_Output[31:0]; end
			4'b1001: begin 	CPU_D_o = 16'h0303_0303; end
			4'b1010: begin 	CPU_D_o = Timer4_Output[31:0]; end
			4'b1011: begin 	CPU_D_o = 16'h0404_0404; end
			default: begin 	CPU_D_o = 32'hDEAD_BEEF; end
		endcase
end

wire [31:0] Timer0_Output;
wire [31:0] Timer1_Output;
wire [31:0] Timer2_Output;
wire [31:0] Timer3_Output;
wire [31:0] Timer4_Output;

wire	Timer0_Compare_eb;
wire	Timer1_Compare_eb;
wire	Timer2_Compare_eb;
wire	Timer3_Compare_eb;
wire	Timer4_Compare_eb;

TimerCounter32 Timer0 (
	.clock ( CPU_Clk_i ),
	.cnt_en ( Control0_Reg[0] ),
	.data ( Timer0_Reg ),
	.sclr ( Control0_Reg[1] & (Timer0_Compare_eb & Control0_Reg[4])),
	.sload ( Control0_Reg[2] & (Timer0_Compare_eb & Control0_Reg[5])),
	.updown ( Control0_Reg[3] ),
	.q ( Timer0_Output )
	);
	
TimerCounter32 Timer1 (
	.clock ( CPU_Clk_i ),
	.cnt_en ( Control0_Reg[8] ),
	.data ( Timer1_Reg ),
	.sclr ( Control0_Reg[9] & (Timer1_Compare_eb & Control0_Reg[12])),
	.sload ( Control0_Reg[10] & (Timer1_Compare_eb & Control0_Reg[13])),
	.updown ( Control0_Reg[11] ),
	.q ( Timer1_Output )
	);	

TimerCounter32 Timer2 (
	.clock ( CPU_Clk_i ),
	.cnt_en ( Control0_Reg[16] ),
	.data ( Timer2_Reg ),
	.sclr ( Control0_Reg[17] & (Timer0_Compare_eb & Control0_Reg[20])),
	.sload ( Control0_Reg[18] & (Timer0_Compare_eb & Control0_Reg[21])),
	.updown ( Control0_Reg[19] ),
	.q ( Timer2_Output )
	);

// SOF Timer Channel A
TimerCounter32 Timer3 (
	.clock ( SOF_Channel_A_RESYNC[1] ),
	.cnt_en ( Control1_Reg[0] ),
	.data ( Timer3_Reg ),
	.sclr ( Control1_Reg[1] & (Timer1_Compare_eb & Control1_Reg[4])),
	.sload ( Control1_Reg[2] & (Timer1_Compare_eb & Control1_Reg[5])),
	.updown ( Control1_Reg[3] ),
	.q ( Timer3_Output )
	);		
	
// SOF Timer Channel B
TimerCounter32 Timer4 (
	.clock ( CPU_Clk_i ),
	.cnt_en ( Control1_Reg[8] ),
	.data ( Timer4_Reg ),
	.sclr ( Control1_Reg[9] & (Timer1_Compare_eb & Control1_Reg[12])),
	.sload ( Control1_Reg[10] & (Timer1_Compare_eb & Control1_Reg[13])),
	.updown ( Control1_Reg[11] ),
	.q ( Timer4_Output )
	);		

	
TimerCompare32 Timer0Compare(
	.dataa( Timer0_Output ),
	.datab( Compare_Timer0_Reg ),
	.aeb( Timer0_Compare_eb )	
);


TimerCompare32 Timer1Compare(
	.dataa( Timer1_Output ),
	.datab( Compare_Timer1_Reg ),
	.aeb( Timer1_Compare_eb )
);

TimerCompare32 Timer2Compare(
	.dataa( Timer2_Output ),
	.datab( Compare_Timer2_Reg ),
	.aeb( Timer2_Compare_eb )	
);

// SOF Channel A
TimerCompare32 Timer3Compare(
	.dataa( Timer3_Output ),
	.datab( Compare_Timer3_Reg ),
	.aeb( Timer3_Compare_eb )
);

// SOF Channel B
TimerCompare32 Timer4Compare(
	.dataa( Timer4_Output ),
	.datab( Compare_Timer4_Reg ),
	.aeb( Timer4_Compare_eb )
);



reg [3:0] Sliptimer0;
reg [3:0] Sliptimer1;
reg [3:0] Sliptimer2;
reg [3:0] Sliptimer3;
reg [3:0] Sliptimer4;

always @ (posedge CPU_Clk_i)
begin
	Sliptimer0 <= Sliptimer0 << 1'b1;
	Sliptimer1 <= Sliptimer1 << 1'b1;
	Sliptimer2 <= Sliptimer2 << 1'b1;
	Sliptimer3 <= Sliptimer3 << 1'b1;
	Sliptimer4 <= Sliptimer4 << 1'b1;
	
	if (Timer0_Compare_eb)
		Sliptimer0 <= 4'b1111;
		
	if (Timer1_Compare_eb)
		Sliptimer1 <= 4'b1111;

	if (Timer2_Compare_eb)
		Sliptimer2 <= 4'b1111;
		
	if (Timer3_Compare_eb)
		Sliptimer3 <= 4'b1111;

	if (Timer4_Compare_eb)
		Sliptimer4 <= 4'b1111;
		
end

assign Interrupt_Timer0_o = Sliptimer0[3] & Control0_Reg[7];
assign Interrupt_Timer1_o = Sliptimer1[3] & Control0_Reg[15];
assign Interrupt_Timer2_o = Sliptimer2[3] & Control0_Reg[23];
assign Interrupt_Timer3_o = Sliptimer3[3] & Control0_Reg[31];
assign Interrupt_Timer4_o = Sliptimer4[3] & Control1_Reg[7];


/*
wire [47:0] ScopeIn;
wire			Trigger;

assign Trigger = Control_Reg_TMR0[0] ;


assign ScopeIn[23:0] = Timer0_Output[23:0];
assign ScopeIn[47:24] = { Compare_Timer0_Reg_H, Compare_Timer0_Reg_M, Compare_Timer0_Reg_L};


ChipScope ChipSCOPE(
		.acq_clk(!CPU_Clk_i),        // acq_clk.clk
		.acq_data_in(ScopeIn),    //     tap.acq_data_in
		.acq_trigger_in(Trigger),  //        .acq_trigger_in
		.trigger_in(Trigger)
	);
*/


endmodule



