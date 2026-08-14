`timescale 1 ps / 1 ps

module GABE_CTRL_Reg (
input		wire				RST_i,
input		wire				CPU_Clk_i,
input 	wire	[31:0]	CPU_A_i,
input		wire	[7:0]		CPU_D8_i,
input		wire	[15:0]	CPU_D16_i,
input		wire	[31:0]	CPU_D32_i,
input		wire	[1:0]		CPU_Siz_i,
input 	wire				CPU_R_Wn_i,
input		wire				CPU_A_Valid_i,
input		wire	[3:0]		CPU_BE_i,
input		wire				CPU_WE_i, 
input		wire				CS_INT_REG_i,
// Status

input		wire	[1:0]		MACHINE_ID_i,
input		wire  [15:0]	CHIP_NUMBER,
input		wire  [15:0]	CHIP_VERSION,
input		wire	[15:0]	CHIP_SUBVERSION,

// Outputs
output	wire				Buzzer_Ctrl_o,
output	wire				Power_LED_o,
output	wire				SDCARD_LED_o,
output	wire				Manual_RESET_o,
output	wire				LPC_RSTn_o,

output	wire	[23:0]	POWER_ON_RGB_Value_o,

output	wire	[11:0] 	KBD_RGB_Value_o,

output 	reg 	[31:0]	CPU_D_o
);


/*
wire [143:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger1 = CS_INT_REG_i & ( {CPU_A_Valid_Slide, CPU_A_Valid_i} == 2'b10 );

assign TinyTP1[31:0]  	= CPU_A_i;
assign TinyTP1[63:32] 	= CPU_D32_i;
assign TinyTP1[64] 		= CPU_R_Wn_i;
assign TinyTP1[66:65] 	= CPU_Siz_i[1:0];
assign TinyTP1[68:67]	= {CPU_A_Valid_Slide, CPU_A_Valid_i};

assign TinyTP1[103:72]	= ControlRegisters[0];
assign TinyTP1[135:104] = ControlRegisters[2];

TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (CPU_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/


localparam CPU_SPEED_ID = 4'b0100,
			  MACHINE_ID   = 4'b1011,
			  CPU_ID       = 4'b0110;


localparam HW_REV_DIGIT0 = 8'h41, //A (ASCII)			  
			  HW_REV_DIGIT1 = 8'h30, //0 (ASCII)
			  HW_REV_DIGIT2 = 8'h42, //B (ASCII)
			  HW_DATE_YR   = 8'h21, //21  (Decimal)
			  HW_DATA_MT   = 8'h11, // Nov (Decimal)
			  HW_DATA_DY   = 8'h03; // 03 (Decimal)
			  

localparam 	FM_DATE_YR  = 8'h22, // 22 (Decimal)
				FM_DATE_MT  = 8'h03, // 01 (Decimal)
				FM_DATE_DY  = 8'h31; //
			  
wire LFSR_Done;
wire 	[15:0]	LFSR_Data_Out;

reg	[31:0]	ControlRegisters[0:3];

// Keep the Input Value in Registers
always @ (posedge CPU_Clk_i)
begin
	if (RST_i) begin
		ControlRegisters[0] <= 32'h0000_0001;
		ControlRegisters[1] <= 32'h0000_0000;
		ControlRegisters[2] <= 32'h0080_0080;
		ControlRegisters[3] <= {16'h0000, 4'b0000, 3'b010, 3'b000, 3'b000, 3'b001};
		
	end 
	else begin
		if (CS_INT_REG_i && !CPU_R_Wn_i && ( CPU_Siz_i[1:0] == 2'b00) && CPU_WE_i)
			ControlRegisters[CPU_A_i[3:2]] <= CPU_D32_i;
	end
end

assign POWER_ON_RGB_Value_o = {ControlRegisters[2][23:0]};
assign KBD_RGB_Value_o = ControlRegisters[3][11:0];

always @ (*)
begin
	case(CPU_A_i[4:2])
		3'b000: CPU_D_o = ControlRegisters[0];
		3'b001: CPU_D_o = ControlRegisters[1];	// LFSR
		3'b010: CPU_D_o = { 8'h00, LFSR_Done, ControlRegisters[2][6:0], LFSR_Data_Out[15:0]} ;

		3'b011: CPU_D_o = { CHIP_SUBVERSION[15:0], CPU_ID ,4'b0000, CPU_SPEED_ID , MACHINE_ID };
		3'b100: CPU_D_o = { CHIP_NUMBER[15:0], CHIP_VERSION[15:0] };
		3'b101: CPU_D_o = { 8'h00, FM_DATE_DY, FM_DATE_MT, FM_DATE_YR};
		3'b110: CPU_D_o = {HW_REV_DIGIT0, HW_REV_DIGIT1, HW_REV_DIGIT2, 8'h00}; // Hardware Revision
		3'b111: CPU_D_o = { 8'h00, HW_DATA_DY, HW_DATA_MT, HW_DATE_YR}; // Date of PCB (the ID on the board will set the different PCB Rev)
		default: CPU_D_o = 32'hDEAD_BEEF;
	endcase
end

LFSR #(
	.NUM_BITS(16)
) LFSR_Module (
   .i_Clk( CPU_Clk_i ),
   .i_Enable( ControlRegisters[1][0] ),
   // Optional Seed Value
   .i_Seed_DV(ControlRegisters[1][1] ),	// Data Valid
	.i_Seed_Data( ControlRegisters[1][31:16] ),
	.o_LFSR_Data( LFSR_Data_Out ),
   .o_LFSR_Done( LFSR_Done )
);

//;Bit 2, Bit 1, Bit 0
//$000: FMX
//$100: FMX (Future C5A)
//$001: U 2Meg
//$101: U+ 4Meg U+
//$010: TBD (Reserved)
//$110: TBD (Reserved)
//$011: A2560 Dev
//$111: A2560 Keyboard

reg [31:0]	SoftReset;

always @ (posedge CPU_Clk_i) begin
	if ( RST_i ) begin
		SoftReset <= 32'h00000000;
	end
	else begin
		if (ControlRegisters[0][15] && (ControlRegisters[0][31:16] == 16'HDEAD)) begin
			SoftReset <= 32'hFFFFFFFF;
		end
	end
end

assign LPC_RSTn_o = ControlRegisters[0][8];		// @ Reset the Value is 0
assign Power_LED_o = ControlRegisters[0][0];
assign SDCARD_LED_o = ControlRegisters[0][1];
assign Buzzer_Ctrl_o = ControlRegisters[0][4];
assign Manual_RESET_o = SoftReset[31];

/*
reg	[2:0]	SOF_EDGE;


always @ ( posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		SOF_EDGE <= 2'b00;
	end
	else begin
		SOF_EDGE[0] <= SOF_i;
		SOF_EDGE[1] <= SOF_EDGE[0];
		SOF_EDGE[2] <= SOF_EDGE[1];		
	end
end

reg 		[7:0]		SOF_Counter0;
reg		[7:0] 	FlashRate0;
reg		FlashOnOFF0;
always @ (*)
begin
	case (ControlRegisters[1][5:4])
		2'b00: FlashRate0 = 8'd60;
		2'b01: FlashRate0 = 8'd30;
		2'b10: FlashRate0 = 8'd15; 
		2'b11: FlashRate0 = 8'd12;
		default: FlashRate0 = 8'd60;
	endcase
end

always @(posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		SOF_Counter0 <= 8'h00;
		FlashOnOFF0	<= 1'b0;
	end
	else begin
		
		if (SOF_EDGE[2:1] == 2'b01) begin
			SOF_Counter0 <= SOF_Counter0 + 1'b1;
		end

		
		if (SOF_Counter0 == FlashRate0) begin
				FlashOnOFF0 <= FlashOnOFF0 ^ 1'b1;
				SOF_Counter0 <= 8'h00;			
		end
			else begin
				if (SOF_Counter0 > FlashRate0) 
						SOF_Counter0 <= 8'h00;
			end

	end
end

reg 		[7:0]		SOF_Counter1;
reg		[7:0] 	FlashRate1;
reg		FlashOnOFF1;
always @ (*)
begin
	case (ControlRegisters[1][7:6])
		2'b00: FlashRate1 = 8'd60;
		2'b01: FlashRate1 = 8'd30;
		2'b10: FlashRate1 = 8'd15; 
		2'b11: FlashRate1 = 8'd12;
		default: FlashRate1 = 8'd60;
	endcase
end

always @(posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		SOF_Counter1 <= 8'h00;
		FlashOnOFF1	<= 1'b0;
	end
	else begin
		
		if (SOF_EDGE[2:1] == 2'b01) begin
			SOF_Counter1 <= SOF_Counter1 + 1'b1;
		end

		
		if (SOF_Counter1 == FlashRate1) begin
				FlashOnOFF1 <= FlashOnOFF1 ^ 1'b1;
				SOF_Counter1 <= 8'h00;			
		end
			else begin
				if (SOF_Counter1 > FlashRate1) 
						SOF_Counter1 <= 8'h00;
			end

	end
end

*/




endmodule


