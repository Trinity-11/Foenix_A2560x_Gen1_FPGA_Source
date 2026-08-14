module CFP95179K_Reset_Block (

input		wire			PLL_SDcard_Locked_i,
input		wire			PLL_Locked_B_i,
input		wire			PLL_Locked_A_i,
input		wire			Clk14Mhz_i,
input		wire			Clk22Mhz_i,
input		wire			Clk24Mhz_i,
input		wire			Clk33Mhz_i,
input		wire			Clk40Mhz_i,
input		wire			Clk48Mhz_i,
input		wire			Clk80Mhz_i,
input		wire			ClkVideoA_i,
input		wire			ClkVideoB_i,
input		wire			CPU_Clock_i,

input		wire			Hard_Reset_i,		// External Reset Button
input		wire			Soft_Reset_i,		// Internal Reset Created by Programming GABE Register
input		wire			CPU_Reset_i,		// External Reset Triggered by CPU

input		wire			Flash_Transfered_i,
input		wire			LPC_Init_Completed_i,

output	wire			Reset_14Mhz_o,
output	wire			Reset_22Mhz_o,
output	wire			Reset_24Mhz_o,
output	wire			Reset_33Mhz_o,
output	wire			Reset_40Mhz_o,
output	wire			Reset_48Mhz_o,
output	wire			Reset_ClkVideoA_o,
output	wire			Reset_ClkVideoB_o,

output	wire			External_Reset_o,

output	wire			Init_SDRAM_o,
output	wire			Init_LPC_o,
output	wire			Init_F2R_TSF_o

);




/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger1 = !CountisReached;

assign TinyTP1[0] = Int_Clock_Divide2[1];
assign TinyTP1[3:1] = Hard_Reset_EDGE;
assign TinyTP1[6:4] = Soft_Reset_EDGE;
assign TinyTP1[9:7] = CPU_Reset_EDGE;
assign TinyTP1[10] = Hard_Reset_i;
assign TinyTP1[11] = Soft_Reset_i;
assign TinyTP1[12] = CPU_Reset_i;
assign TinyTP1[16] = Reset_14Mhz_o;
assign TinyTP1[17] = Reset_22Mhz_o;
assign TinyTP1[18] = Reset_24Mhz_o;
assign TinyTP1[19] = Reset_33Mhz_o;
assign TinyTP1[20] = Reset_40Mhz_o;
assign TinyTP1[21] = Reset_48Mhz_o;
assign TinyTP1[22] = Reset_ClkVideoA_o;
assign TinyTP1[23] = Reset_ClkVideoB_o;

assign TinyTP1[24] = Flash_Transfered_i;
assign TinyTP1[25] = LPC_Init_Completed_i;
assign TinyTP1[26] = Init_SDRAM_o;
assign TinyTP1[27] = Init_LPC_o;
assign TinyTP1[28] = Init_F2R_TSF_o;



TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (InternalClock_Out),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/



reg [2:0] Hard_Reset_EDGE;
reg [2:0] Soft_Reset_EDGE;
reg [2:0] CPU_Reset_EDGE;

always @ (posedge InternalClock_Out) begin

	Hard_Reset_EDGE[0] <= Hard_Reset_i;
	Hard_Reset_EDGE[1] <= Hard_Reset_EDGE[0];
	if ( Hard_Reset_EDGE[1] == Hard_Reset_EDGE[0] ) begin
		Hard_Reset_EDGE[2] <= Hard_Reset_EDGE[1];
	end

	Soft_Reset_EDGE[0] <= Soft_Reset_i;
	Soft_Reset_EDGE[1] <= Soft_Reset_EDGE[0];
	if ( Soft_Reset_EDGE[1] == Soft_Reset_EDGE[0] ) begin
		Soft_Reset_EDGE[2] <= Soft_Reset_EDGE[1];
	end
	
	CPU_Reset_EDGE[0] <= CPU_Reset_i;
	CPU_Reset_EDGE[1] <= CPU_Reset_EDGE[0];
	if ( CPU_Reset_EDGE[1] == CPU_Reset_EDGE[0] ) begin
		CPU_Reset_EDGE[2] <= CPU_Reset_EDGE[1];
	end
		
	
	
end

wire HardResetEDGE;
wire SoftResetEDGE;
wire CPUResetEDGE;

assign HardResetEDGE = (Hard_Reset_EDGE[2:1] == 2'b01) ? 1'b1 : 1'b0;
assign SoftResetEDGE = (Soft_Reset_EDGE[2:1] == 2'b01) ? 1'b1 : 1'b0;
assign CPUResetEDGE  = ( CPU_Reset_EDGE[2:1] == 2'b01) ? 1'b1 : 1'b0;

wire InternalClock_Out;

// 80Mhz Clock
InternalClock u0 (
	.oscena ( PLL_SDcard_Locked_i ), // oscena.oscena
	.clkout ( InternalClock_Out )  // clkout.clk
);

//pre-scale
reg [1:0] Int_Clock_Divide2;
// Divide By 4 = 80Mhz / 4 = 20Mhz
always @ (posedge InternalClock_Out) begin
	Int_Clock_Divide2 <= Int_Clock_Divide2 + 2'b01;
end

wire [23:0]		Counter24bitsOutput;

Reset_Counter	Reset_Counter_inst (
	.aclr ( (!CountisReached & (HardResetEDGE | SoftResetEDGE | CPUResetEDGE)) ),
	.clock ( Int_Clock_Divide2[1] ),	// 20Mhz Clock Input - //16Mbit Counter
	.cnt_en ( CountisReached & LPC_Init_Completed_i ),
	.q ( Counter24bitsOutput )
	);

wire CountisReached;

assign CountisReached = (Counter24bitsOutput < 24'd2000000) ? 1'b1 : 1'b0;


// This will Reset Only Once @ Power up after the FPGA is loaded
wire [23:0]		Counter1Shot;
wire 				CountisDone;
Reset_Counter	Reset_Counter_OneShot (
	.aclr ( 1'b0 ),
	.clock ( Int_Clock_Divide2[1] ),	// 20Mhz Clock Input - //16Mbit Counter
	.cnt_en ( CountisDone & LPC_Init_Completed_i ),
	.q ( Counter1Shot )
	);



assign CountisDone = (Counter1Shot < 24'd1000000) ? 1'b1 : 1'b0;

// 80 Mhz
reg [2:0] ResetClk80;
always @ (posedge Clk80Mhz_i) begin
	ResetClk80[0] <= CountisDone;
	ResetClk80[1] <= ResetClk80[0];
	if ( ResetClk80[1] == ResetClk80[0] ) begin
		ResetClk80[2] <= ResetClk80[1];
	end
end


assign Init_SDRAM_o = ResetClk80[2];


/// 33 Mhz - LPC
reg [2:0] ResetClk33LPC;
always @ (posedge Clk33Mhz_i) begin
	ResetClk33LPC[0] <= CountisDone;
	ResetClk33LPC[1] <= ResetClk33LPC[0];
	if ( ResetClk33LPC[1] == ResetClk33LPC[0] ) begin
		ResetClk33LPC[2] <= ResetClk33LPC[1];
	end
end


assign Init_LPC_o = ResetClk33LPC[2];


/// 20 Mhz - RAM Transfer
wire CountisReached_Bis;
assign CountisReached_Bis = (Counter24bitsOutput < 24'd1000000) ? 1'b1 : 1'b0;
reg [2:0] ResetClk40TSF;
always @ (posedge Clk40Mhz_i) begin
	ResetClk40TSF[0] <= CountisReached_Bis;
	ResetClk40TSF[1] <= ResetClk40TSF[0];
	if ( ResetClk40TSF[1] == ResetClk40TSF[0] ) begin
		ResetClk40TSF[2] <= ResetClk40TSF[1];
	end
end

assign Init_F2R_TSF_o = ResetClk40TSF[2];















/// 14 Mhz
reg [2:0] ResetClk14;
always @ (posedge Clk14Mhz_i) begin
	ResetClk14[0] <= CountisReached;
	ResetClk14[1] <= ResetClk14[0];
	if ( ResetClk14[1] == ResetClk14[0] ) begin
		ResetClk14[2] <= ResetClk14[1];
	end
end

assign Reset_14Mhz_o = ResetClk14[2];

/// 22 Mhz
reg [2:0] ResetClk22;
always @ (posedge Clk22Mhz_i) begin
	ResetClk22[0] <= CountisReached;
	ResetClk22[1] <= ResetClk22[0];
	if ( ResetClk22[1] == ResetClk22[0] ) begin
		ResetClk22[2] <= ResetClk22[1];
	end
end

assign Reset_22Mhz_o = ResetClk22[2];

/// 24 Mhz
reg [2:0] ResetClk24;
always @ (posedge Clk24Mhz_i) begin
	ResetClk24[0] <= CountisReached;
	ResetClk24[1] <= ResetClk24[0];
	if ( ResetClk24[1] == ResetClk24[0] ) begin
		ResetClk24[2] <= ResetClk24[1];
	end
end

assign Reset_24Mhz_o = ResetClk24[2];

/// 33 Mhz
reg [2:0] ResetClk33;
always @ (posedge Clk33Mhz_i) begin
	ResetClk33[0] <= CountisReached;
	ResetClk33[1] <= ResetClk33[0];
	if ( ResetClk33[1] == ResetClk33[0] ) begin
		ResetClk33[2] <= ResetClk33[1];
	end
end

assign Reset_33Mhz_o = ResetClk33[2];

/// 40 Mhz
reg [2:0] ResetClk40;
always @ (posedge Clk40Mhz_i) begin
	ResetClk40[0] <= CountisReached;
	ResetClk40[1] <= ResetClk40[0];
	if ( ResetClk40[1] == ResetClk40[0] ) begin
		ResetClk40[2] <= ResetClk40[1];
	end
end

assign Reset_40Mhz_o = ResetClk40[2];

/// 48 Mhz
reg [2:0] ResetClk48;
always @ (posedge Clk48Mhz_i) begin
	ResetClk48[0] <= CountisReached;
	ResetClk48[1] <= ResetClk48[0];
	if ( ResetClk48[1] == ResetClk48[0] ) begin
		ResetClk48[2] <= ResetClk48[1];
	end
end

assign Reset_48Mhz_o = ResetClk48[2];

/// Video Output A
reg [2:0] ResetVidA;
always @ (posedge ClkVideoA_i) begin
	ResetVidA[0] <= CountisReached;
	ResetVidA[1] <= ResetVidA[0];
	if ( ResetVidA[1] == ResetVidA[0] ) begin
		ResetVidA[2] <= ResetVidA[1];
	end
end

assign Reset_ClkVideoA_o = ResetVidA[2];

/// Video Output B
reg [2:0] ResetVidB;
always @ (posedge ClkVideoB_i) begin
	ResetVidB[0] <= CountisReached;
	ResetVidB[1] <= ResetVidB[0];
	if ( ResetVidB[1] == ResetVidB[0] ) begin
		ResetVidB[2] <= ResetVidB[1];
	end
end

assign Reset_ClkVideoB_o = ResetVidB[2];


/// CPU Clock
reg [2:0] ResetCPUClk;
always @ (posedge CPU_Clock_i) begin
	ResetCPUClk[0] <= CountisReached;
	ResetCPUClk[1] <= ResetCPUClk[0];
	if ( ResetCPUClk[1] == ResetCPUClk[0] ) begin
		ResetCPUClk[2] <= ResetCPUClk[1];
	end
end

assign External_Reset_o = ResetCPUClk[2];


endmodule
