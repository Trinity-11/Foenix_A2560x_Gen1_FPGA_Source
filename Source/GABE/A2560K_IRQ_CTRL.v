`timescale 1ns / 1ps
module A2560K_IRQ_CTRL (
input		wire				RST_i,
input		wire				CPU_Clk_i,
input		wire				LPC_Clk_i,
input 		wire				LPC_RSTn_i,

// CPU Bus Input
input		wire	[31:0]		CPU_A_i,
input		wire				CPU_A_Valid_i,
input		wire				CPU_RW_i,
input		wire	[3:0]		CPU_BE_i,
input		wire				CPU_WE_i, 
input		wire	[7:0]		CPU_D8_i,
input		wire	[15:0]		CPU_D16_i,
input		wire	[31:0]		CPU_D32_i,
input		wire	[1:0]		CPU_Siz_i,
output 		reg 	[31:0]		CPU_D_o,
input		wire				CS_Interrupt_Ctrl_i,
// LPC signals 
input		wire				serirq_i,
output		wire				serirq_o,
output		wire				serirq_oe,
// Interrupt Sources Input
input		wire	[5:0]		VKY_III_Channel_A_IRQ_i,
input		wire				VID_A_HP_INT1n_i,
input		wire	[5:0]		VKY_III_Channel_B_IRQ_i,
input		wire				VID_B_HP_INT1n_i,
// GABE IRQ
input		wire				Trinity_IRQ_i,
input		wire 				Ethernet_IRQ_i,
input		wire				RTC_IRQ_i,
input		wire				IDE_IRQ_i,
input		wire				SD_IRQ_i,
input		wire				SD_Card_Insert_i,
input		wire				Timer0_i,		// CPU Clock Timer 0
input		wire				Timer1_i,		// CPU Clock Timer 1
input		wire				Timer2_i,		// CPU Clock Timer 2
input		wire				Timer3_i,		// SOF Channel A Counter IRQ
input		wire				Timer4_i,		// SOF Channel B Counter IRQ
// BEATRIX IRQ
input		wire	[3:0]		BTX_IRQ_i,
input		wire				OPL3_EXT_IRQ_i,
input		wire				OPN2_EXT_IRQ_i,
input		wire				OPM_IXT_IRQ_i,
input		wire				DAC0_Playback_Done_IRQ_i,
input		wire				DAC1_Playback_Done_IRQ_i,

input		wire				A2560K_Keyboard_IRQ_i,


output 		wire	[31:0]		LPC_IRQ_o,

// Output IRQ - MC68SEC000
output		reg		[6:0]		iIRQ_Interrupt_o,
output		reg		[7:0]		iIRQ_Vector_o,
output		reg					iIRQ_AutoVector_o,
input		wire				iIRQ_GetVector_i		// When this is high, that means that we are in a CPU CYCLE and the CPU wants its AutoVector or the Vector Number
);


wire [31:0] LPC_IRQ_i; 
reg [2:0] LPC_RSTn_RESYNC;

always @ ( posedge LPC_Clk_i ) begin
		LPC_RSTn_RESYNC[0] <= LPC_RSTn_i;
		LPC_RSTn_RESYNC[1] <= LPC_RSTn_RESYNC[0];
			if ( LPC_RSTn_RESYNC[1] == LPC_RSTn_RESYNC[0] )
				LPC_RSTn_RESYNC[2] <= LPC_RSTn_RESYNC[1];
end 

wire [31:0] irq_o;
serirq_host LPC_SerialIRQ_Block(
	.clk_i( LPC_Clk_i ), 				// LPC_33Mhz - that Clock is Async to the the CPU Clock
	.nrst_i( LPC_RSTn_RESYNC[2] ), 	// Resynced RESET with LPC Clock
   .serirq_mode_i(1'b1), 			// Quiet mode?
	.irq_o( irq_o ),
	.serirq_i(serirq_i),
   .serirq_o(serirq_o), 
	.serirq_oe( serirq_oe ),
	.statemachine_Debug(   ) 
);

reg[31:0] irq_o_RESYNC[0:2];
// RESYNC from LPC Clock Domain to CPU Clock Domain 
always @ (posedge CPU_Clk_i ) begin
	irq_o_RESYNC[0] <= irq_o;
	irq_o_RESYNC[1] <= irq_o_RESYNC[0];
	if ( irq_o_RESYNC[1] == irq_o_RESYNC[0] ) begin
		irq_o_RESYNC[2] <= irq_o_RESYNC[1];
	end 
end 

assign LPC_IRQ_i = irq_o_RESYNC[2];	// Internal IRQ Circuit
assign LPC_IRQ_o = irq_o_RESYNC[2];


reg  [47:0] pol, edgen, pending, mask;   // register bank
reg  [47:0] lirq, dirq;                  // latched irqs, delayed latched irqs
reg  [47:0] Ena;
//

reg	[47:0] lirq0;
reg	[47:0] lirq1;

// latch interrupt inputs
always @(posedge CPU_Clk_i) begin
	lirq0 <= {  DAC0_Playback_Done_IRQ_i, 1'b0, DAC1_Playback_Done_IRQ_i, 1'b0, BTX_IRQ_i[3:0], 2'b00, OPL3_EXT_IRQ_i, OPN2_EXT_IRQ_i, OPM_IXT_IRQ_i, SD_IRQ_i, SD_Card_Insert_i, IDE_IRQ_i,
					RTC_int_PulSe[3], ETH_int_PulSe[3], Trinity_IRQ_i, ~Timer4_i, ~Timer3_i, ~Timer2_i, ~Timer1_i, ~Timer0_i, !MPU_401_int_PulSe[3], !FDC_int_PulSe[3], !LPT1_int_PulSe[3], !COM2_int_PulSe[3], !COM1_int_PulSe[3], !Mouse_int_PulSe[3], !A2560Keyboard_int_PulSe[3] , !Keyboard_int_PulSe[3], //16bits
					VID_B_HP_INT1n_i, 1'b0, VKY_III_Channel_B_IRQ_i, VID_A_HP_INT1n_i, 1'b0, VKY_III_Channel_A_IRQ_i }; //16bits
	lirq1 <= lirq0;
	if ( lirq1 == lirq0) begin
		lirq <= 	lirq1;	
	end
end
 

//
// generate delayed latched irqs
always @(posedge CPU_Clk_i) begin
  dirq <= lirq;
end

  //
  // generate actual triggers
function trigger;
	input edgen, pol, lirq, dirq;
 
	reg   edge_irq, level_irq;
	begin
		edge_irq  = pol ? (lirq & ~dirq) : (dirq & ~lirq);
		level_irq = pol ? lirq : ~lirq;
		trigger = edgen ? edge_irq : level_irq;
	end
endfunction

reg  [47:0] irq_event;

integer n;
always @(posedge CPU_Clk_i) begin
  for(n=0; n < 48; n=n+1) begin
    irq_event[n] <= trigger(edgen[n], pol[n], lirq[n], dirq[n]);
	end
end



// REPROCESSING of all Interrupts
//
//
////////////////////
/// RTC
////////////////////
// Keep the Input Value in Registers
reg	[1:0]		RTC_int;
reg	[3:0] 	RTC_int_PulSe;
always @ (posedge CPU_Clk_i)
begin
	RTC_int[0] <= !RTC_IRQ_i;
	RTC_int[1] <= RTC_int[0]; 
end

always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		RTC_int_PulSe <= 4'h0;
	end
	else
	begin
		RTC_int_PulSe <= RTC_int_PulSe << 1'b1;
		if (RTC_int[1:0] == 2'b01)
			RTC_int_PulSe <= 4'hF;
	end
end

////////////////////
/// KEYBOARD (1)
////////////////////
// Keep the Input Value in Registers
reg	[1:0]		A2560Keyboard_int;
reg	[3:0] 	A2560Keyboard_int_PulSe;
always @ (posedge CPU_Clk_i)
begin
	A2560Keyboard_int[0] <= A2560K_Keyboard_IRQ_i;
	A2560Keyboard_int[1] <= A2560Keyboard_int[0]; 
end

always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		A2560Keyboard_int_PulSe <= 4'h0;
	end
	else
	begin
		A2560Keyboard_int_PulSe <= A2560Keyboard_int_PulSe << 1'b1;
		if (A2560Keyboard_int[1:0] == 2'b01)
			A2560Keyboard_int_PulSe <= 4'hF;
	end
end

// REPROCESSING THE LPC Interrupts
//
//
////////////////////
/// KEYBOARD (1)
////////////////////
// Keep the Input Value in Registers
reg	[1:0]		Keyboard_int;
reg	[3:0] 	Keyboard_int_PulSe;
always @ (posedge CPU_Clk_i)
begin
	Keyboard_int[0] <= LPC_IRQ_i[1];
//	Keyboard_int[0] <= SuperIO_KB_i;
	Keyboard_int[1] <= Keyboard_int[0]; 
end

always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		Keyboard_int_PulSe <= 4'h0;
	end
	else
	begin
		Keyboard_int_PulSe <= Keyboard_int_PulSe << 1'b1;
		if (Keyboard_int[1:0] == 2'b01)
			Keyboard_int_PulSe <= 4'hF;
	end
end
////////////////////
/// MOUSE (2)
////////////////////
// Keep the Input Value in Registers
reg	[1:0]		Mouse_int;
reg	[3:0] 	Mouse_int_PulSe;
always @ (posedge CPU_Clk_i)
begin
	Mouse_int[0] <= LPC_IRQ_i[2];
//	Mouse_int[0] <= SuperIO_MS_i;
	Mouse_int[1] <= Mouse_int[0]; 
end


always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		Mouse_int_PulSe <= 4'h0;
	
	end
	else
	begin
		Mouse_int_PulSe <= Mouse_int_PulSe << 1'b1;
		if (Mouse_int[1:0] == 2'b01)
			Mouse_int_PulSe <= 4'hF;
	end
end
////////////////////
/// COM2 (3)
////////////////////
reg	[1:0]		COM2_int;
reg	[3:0] 	COM2_int_PulSe;
always @ (posedge CPU_Clk_i)
begin
	COM2_int[0] <= LPC_IRQ_i[3];
	COM2_int[1] <= COM2_int[0];
end

always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		COM2_int_PulSe <= 4'h0;
	end
	else
	begin
		COM2_int_PulSe <= COM2_int_PulSe << 1'b1;
		if (COM2_int[1:0] == 2'b01)
			COM2_int_PulSe <= 4'hF;
	end
end
////////////////////
/// COM1 (4)
////////////////////
reg	[1:0]		COM1_int;
reg	[3:0] 	COM1_int_PulSe;
always @ (posedge CPU_Clk_i)
begin
	COM1_int[0] <= LPC_IRQ_i[4];
	COM1_int[1] <= COM1_int[0]; 
end

always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		COM1_int_PulSe <= 4'h0;
	
	end
	else
	begin
		COM1_int_PulSe <= COM1_int_PulSe << 1'b1;
		if (COM1_int[1:0] == 2'b01)
			COM1_int_PulSe <= 4'hF;
	end
end

////////////////////
/// MPU-401 (5)
////////////////////
reg	[1:0]		MPU_401_int;
reg	[3:0] 	MPU_401_int_PulSe;
always @ (posedge CPU_Clk_i)
begin
	MPU_401_int[0] <= LPC_IRQ_i[5];
	MPU_401_int[1] <= MPU_401_int[0];
end

always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		MPU_401_int_PulSe <= 4'h0;
	end
	else
	begin
		MPU_401_int_PulSe <= MPU_401_int_PulSe << 1'b1;
		if (MPU_401_int[1:0] == 2'b01)
			MPU_401_int_PulSe <= 4'hF;
	end
end
////////////////////
/// FDC (6)
////////////////////
reg	[1:0]		FDC_int;
reg	[3:0] 	FDC_int_PulSe;
always @ (posedge CPU_Clk_i)
begin
	FDC_int[0] <= LPC_IRQ_i[6];
	FDC_int[1] <= FDC_int[0]; 
end

always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		FDC_int_PulSe <= 4'h0;
	
	end
	else
	begin
		FDC_int_PulSe <= FDC_int_PulSe << 1'b1;
		if (FDC_int[1:0] == 2'b01)
			FDC_int_PulSe <= 4'hF;
	end
end
////////////////////
/// LPT1 (7)
////////////////////
reg	[1:0]		LPT1_int;
reg	[3:0] 	LPT1_int_PulSe;
always @ (posedge CPU_Clk_i)
begin
	LPT1_int[0] <= LPC_IRQ_i[7];
	LPT1_int[1] <= LPT1_int[0];
end

always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		LPT1_int_PulSe <= 4'h0;
	end
	else
	begin
		LPT1_int_PulSe <= LPT1_int_PulSe << 1'b1;
		if (LPT1_int[1:0] == 2'b01)
			LPT1_int_PulSe <= 4'hF;
	end
end


////////////////////
/// ETHERNET
////////////////////
reg	[1:0]		ETH_int;
reg	[3:0] 	ETH_int_PulSe;
always @ (posedge CPU_Clk_i)
begin
	ETH_int[0] <= Ethernet_IRQ_i;
	ETH_int[1] <= ETH_int[0];
end

always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		ETH_int_PulSe <= 4'h0;
	end
	else
	begin
		ETH_int_PulSe <= ETH_int_PulSe << 1'b1;
		if (ETH_int[1:0] == 2'b01)
			ETH_int_PulSe <= 4'hF;
	end
end


initial 
begin
	pol[47:0] 		= 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
	edgen[47:0] 	= 48'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;		
	mask[47:0] 		= 48'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
	pending[47:0] 	= 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
end

reg [15:0] Temp_Reg_Unused[0:3];

/*
wire [143:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger1 = LPC_IRQ_i[1];

assign TinyTP1[12:0]  	= statemachine_Debug;
assign TinyTP1[31:15]	= LPC_IRQ_i[15:0];
assign TinyTP1[40] 		= CPU_RW_i;
assign TinyTP1[42:41] 	= CPU_Siz_i[1:0];
assign TinyTP1[44:43]	= 2'b00;
assign TinyTP1[45] 		= CS_Interrupt_Ctrl_i;
assign TinyTP1[46] 		= iIRQ_AutoVector_o;
assign TinyTP1[47] 		= 1'b0;
assign TinyTP1[95:48]	= pending;
assign TinyTP1[143:96]  = mask;

TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (CPU_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/
// Keep the Input Value in Registers
always @ (posedge CPU_Clk_i)
begin
	if (RST_i) 
	begin
		pol[47:0] 		<= 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
		edgen[47:0] 	<= 48'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
		mask[47:0] 		<= 48'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
		pending[47:0] 	<= 48'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
	end
	else
	begin
		if (CS_Interrupt_Ctrl_i && !CPU_RW_i & ( CPU_Siz_i[1:0] == 2'b10 ) && CPU_WE_i) begin
		
			case(CPU_A_i[4:1])
			4'b0000: begin pending[15:0] 	<= (pending[15:0]  & ~CPU_D16_i); end
			4'b0001: begin pending[31:16]	<= (pending[31:16] & ~CPU_D16_i); end
			4'b0010: begin pending[47:32]	<= (pending[47:32] & ~CPU_D16_i); end
			4'b0011: begin Temp_Reg_Unused[0] <= CPU_D16_i; end
			4'b0100: begin pol[15:0] 	<= CPU_D16_i; end
			4'b0101: begin pol[31:16] 	<= CPU_D16_i; end
			4'b0110: begin pol[47:32] 	<= CPU_D16_i; end
			4'b0111: begin Temp_Reg_Unused[1] <= CPU_D16_i; end
			4'b1000: begin edgen[15:0] <= CPU_D16_i; end
			4'b1001: begin edgen[31:16]<= CPU_D16_i; end
			4'b1010: begin edgen[47:32]<= CPU_D16_i; end
			4'b1011: begin Temp_Reg_Unused[2] <= CPU_D16_i; end
			4'b1100: begin mask[15:0] 	<= CPU_D16_i; end
			4'b1101: begin mask[31:16] <= CPU_D16_i; end
			4'b1110: begin mask[47:32] <= CPU_D16_i; end
			4'b1111: begin Temp_Reg_Unused[3] <= CPU_D16_i; end
			default: begin end			
			
			
			endcase
		end
		else begin
          pending <= pending | irq_event;
		end
	end
end


always @ (*)
begin
	case(CPU_A_i[4:1])
		4'b0000: CPU_D_o = { pending[15:0], pending[15:0]};
		4'b0001: CPU_D_o = { pending[31:16], pending[31:16]};
		4'b0010: CPU_D_o = { pending[47:32], pending[47:32]};
		4'b0011: CPU_D_o = { Temp_Reg_Unused[0], Temp_Reg_Unused[0]};
		4'b0100: CPU_D_o = { pol[15:0], pol[15:0]};
		4'b0101: CPU_D_o = { pol[31:16],pol[31:16]};
		4'b0110: CPU_D_o = { pol[47:32], pol[47:32]};
		4'b0111: CPU_D_o = { Temp_Reg_Unused[1],Temp_Reg_Unused[1]};
		4'b1000: CPU_D_o = { edgen[15:0], edgen[15:0]};
		4'b1001: CPU_D_o = { edgen[31:16], edgen[31:16]};
		4'b1010: CPU_D_o = { edgen[47:32], edgen[47:32]};
		4'b1011: CPU_D_o = { Temp_Reg_Unused[2], Temp_Reg_Unused[2]};
		4'b1100: CPU_D_o = { mask[15:0], mask[15:0]};
		4'b1101: CPU_D_o = { mask[31:16], mask[31:16]};
		4'b1110: CPU_D_o = { mask[47:32], mask[47:32]};
		4'b1111: CPU_D_o = { Temp_Reg_Unused[3],Temp_Reg_Unused[3]};
		default: CPU_D_o = { 32'h55AA_55AA};		
	endcase
end


wire	[47:0] Interrupt;
assign Interrupt[0] = (pending[0] & ~mask[0]);
assign Interrupt[1] = (pending[1] & ~mask[1]);
assign Interrupt[2] = (pending[2] & ~mask[2]);
assign Interrupt[3] = (pending[3] & ~mask[3]);
assign Interrupt[4] = (pending[4] & ~mask[4]);
assign Interrupt[5] = (pending[5] & ~mask[5]);
assign Interrupt[6] = (pending[6] & ~mask[6]);
assign Interrupt[7] = (pending[7] & ~mask[7]);
assign Interrupt[8] = (pending[8] & ~mask[8]);
assign Interrupt[9] = (pending[9] & ~mask[9]);
assign Interrupt[10] = (pending[10] & ~mask[10]);
assign Interrupt[11] = (pending[11] & ~mask[11]);
assign Interrupt[12] = (pending[12] & ~mask[12]);
assign Interrupt[13] = (pending[13] & ~mask[13]);
assign Interrupt[14] = (pending[14] & ~mask[14]);
assign Interrupt[15] = (pending[15] & ~mask[15]);
assign Interrupt[16] = (pending[16] & ~mask[16]);
assign Interrupt[17] = (pending[17] & ~mask[17]);
assign Interrupt[18] = (pending[18] & ~mask[18]);
assign Interrupt[19] = (pending[19] & ~mask[19]);
assign Interrupt[20] = (pending[20] & ~mask[20]);
assign Interrupt[21] = (pending[21] & ~mask[21]);
assign Interrupt[22] = (pending[22] & ~mask[22]);
assign Interrupt[23] = (pending[23] & ~mask[23]);
assign Interrupt[24] = (pending[24] & ~mask[24]);
assign Interrupt[25] = (pending[25] & ~mask[25]);
assign Interrupt[26] = (pending[26] & ~mask[26]);
assign Interrupt[27] = (pending[27] & ~mask[27]);
assign Interrupt[28] = (pending[28] & ~mask[28]);
assign Interrupt[29] = (pending[29] & ~mask[29]);
assign Interrupt[30] = (pending[30] & ~mask[30]);
assign Interrupt[31] = (pending[31] & ~mask[31]);
assign Interrupt[32] = (pending[32] & ~mask[32]);
assign Interrupt[33] = (pending[33] & ~mask[33]);
assign Interrupt[34] = (pending[34] & ~mask[34]);
assign Interrupt[35] = (pending[35] & ~mask[35]);
assign Interrupt[36] = (pending[36] & ~mask[36]);
assign Interrupt[37] = (pending[37] & ~mask[37]);
assign Interrupt[38] = (pending[38] & ~mask[38]);
assign Interrupt[39] = (pending[39] & ~mask[39]);
assign Interrupt[40] = (pending[40] & ~mask[40]);
assign Interrupt[41] = (pending[41] & ~mask[41]);
assign Interrupt[42] = (pending[42] & ~mask[42]);
assign Interrupt[43] = (pending[43] & ~mask[43]);
assign Interrupt[44] = (pending[44] & ~mask[44]);
assign Interrupt[45] = (pending[45] & ~mask[45]);
assign Interrupt[46] = (pending[46] & ~mask[46]);
assign Interrupt[47] = (pending[47] & ~mask[47]);

wire Interrupt_Group[5:0];

assign Interrupt_Group[0] = ( Interrupt[0] | Interrupt[1] | Interrupt[2] | Interrupt[3] | Interrupt[4] | Interrupt[5] );  // Channel A
assign Interrupt_Group[1] = ( Interrupt[8] | Interrupt[9] | Interrupt[10] | Interrupt[11] | Interrupt[12] | Interrupt[13] ); // Channel B
assign Interrupt_Group[2] = ( Interrupt[16] | Interrupt[17] | Interrupt[18] | Interrupt[19] | Interrupt[20] | Interrupt[21] | Interrupt[22] | Interrupt[23] ); 
assign Interrupt_Group[3] = ( Interrupt[24] | Interrupt[25] | Interrupt[26] | Interrupt[27] | Interrupt[28] | Interrupt[29] | Interrupt[30] | Interrupt[31] ); 
assign Interrupt_Group[4] = ( Interrupt[32] | Interrupt[33] | Interrupt[34] | Interrupt[35] | Interrupt[36] | Interrupt[37] | Interrupt[38] | Interrupt[39] ); 
assign Interrupt_Group[5] = ( Interrupt[40] | Interrupt[41] | Interrupt[42] | Interrupt[43] | Interrupt[44] | Interrupt[45] | Interrupt[46] | Interrupt[47] ); 
//iIRQ_Interrupt_o

reg[7:0] Intr_Group2;

always @ (*) begin
	casex ( Interrupt[23:16] )
		8'b0000_0001: begin Intr_Group2 = 8'H40; end
		8'b0000_001x: begin Intr_Group2 = 8'H41; end
		8'b0000_01xx: begin Intr_Group2 = 8'H42; end
		8'b0000_1xxx: begin Intr_Group2 = 8'H43; end
		8'b0001_xxxx: begin Intr_Group2 = 8'H44; end
		8'b001x_xxxx: begin Intr_Group2 = 8'H45; end
		8'b01xx_xxxx: begin Intr_Group2 = 8'H46; end
		8'b1xxx_xxxx: begin Intr_Group2 = 8'H47; end
		default: begin Intr_Group2 = 8'H40; end
	endcase
end

reg[7:0] Intr_Group3;

always @ (*) begin
	casex ( Interrupt[31:24] )
		8'b0000_0001: begin Intr_Group3 = 8'H48; end
		8'b0000_001x: begin Intr_Group3 = 8'H49; end
		8'b0000_01xx: begin Intr_Group3 = 8'H4A; end
		8'b0000_1xxx: begin Intr_Group3 = 8'H4B; end
		8'b0001_xxxx: begin Intr_Group3 = 8'H4C; end
		8'b001x_xxxx: begin Intr_Group3 = 8'H4D; end
		8'b01xx_xxxx: begin Intr_Group3 = 8'H4E; end
		8'b1xxx_xxxx: begin Intr_Group3 = 8'H4F; end
		default: begin Intr_Group3 = 8'H48; end		
	endcase
end

reg[7:0] Intr_Group4;

always @ (*) begin
	casex ( Interrupt[39:32] )
		8'b0000_0001: begin Intr_Group4 = 8'H50; end
		8'b0000_001x: begin Intr_Group4 = 8'H51; end
		8'b0000_01xx: begin Intr_Group4 = 8'H52; end
		8'b0000_1xxx: begin Intr_Group4 = 8'H53; end
		8'b0001_xxxx: begin Intr_Group4 = 8'H54; end
		8'b001x_xxxx: begin Intr_Group4 = 8'H55; end
		8'b01xx_xxxx: begin Intr_Group4 = 8'H56; end
		8'b1xxx_xxxx: begin Intr_Group4 = 8'H57; end
		default: begin Intr_Group4 = 8'H50; end	
	endcase
end

reg[7:0] Intr_Group5;

always @ (*) begin
	casex ( Interrupt[47:40] )
		8'b0000_0001: begin Intr_Group5 = 8'H58; end
		8'b0000_001x: begin Intr_Group5 = 8'H59; end
		8'b0000_01xx: begin Intr_Group5 = 8'H5A; end
		8'b0000_1xxx: begin Intr_Group5 = 8'H5B; end
		8'b0001_xxxx: begin Intr_Group5 = 8'H5C; end
		8'b001x_xxxx: begin Intr_Group5 = 8'H5D; end
		8'b01xx_xxxx: begin Intr_Group5 = 8'H5E; end
		8'b1xxx_xxxx: begin Intr_Group5 = 8'H5F; end
		default: begin Intr_Group5 = 8'H58; end
	endcase
end


always @ (posedge CPU_Clk_i ) begin
	
	iIRQ_Interrupt_o[0] <= Interrupt_Group[5];
	iIRQ_Interrupt_o[1] <= Interrupt_Group[4];
	iIRQ_Interrupt_o[2] <= Interrupt_Group[3];
	iIRQ_Interrupt_o[3] <= Interrupt_Group[2];
	iIRQ_Interrupt_o[4] <= Interrupt_Group[0];
	iIRQ_Interrupt_o[5] <= Interrupt_Group[1];
	iIRQ_Interrupt_o[6] <= 1'b0;
	
	iIRQ_AutoVector_o   <= ( Interrupt_Group[0] | Interrupt_Group[1] );
	
	casex ( iIRQ_Interrupt_o[6:0] )
		7'b000_0001: begin iIRQ_Vector_o		<= Intr_Group5; end		// 88 to 95 - Lowest Priority - ( IPLOut= 3'b110 )
		7'b000_001x: begin iIRQ_Vector_o		<= Intr_Group4; end		// 80 to 87 - ( IPLOut= 3'b101 )
		7'b000_01xx: begin iIRQ_Vector_o		<= Intr_Group3; end		// 72 to 79 - ( IPLOut= 3'b100 )
		7'b000_1xxx: begin iIRQ_Vector_o		<= Intr_Group2; end		// 64 to 71 - ( IPLOut= 3'b011 )
		7'b001_xxxx: begin iIRQ_Vector_o		<= 8'h1D; end				// VICKY Channel A - ( IPLOut= 3'b010 )
		7'b01x_xxxx: begin iIRQ_Vector_o		<= 8'h1E; end				// VICKY Channel B - ( IPLOut= 3'b001 )
		7'b1xx_xxxx: begin iIRQ_Vector_o		<= 8'h60; end				// No Int Assigned here - Highest priority
		default: begin iIRQ_Vector_o		 	<= 8'H60; end
	endcase

end


/*
wire [23:0] Address2Brake;


Probe (
		.probe(8'h00),  //  probes.probe
		.source( Address2Brake )  // sources.source
	);

*/
//// DEBUG ChipScope
/*
wire [47:0] ScopeIn;
wire			Trigger;

assign Trigger = LPC_INT_i[0] & !LPC_INT_i[1] & !LPC_INT_i[2] & LPC_INT_i[3] & LPC_INT_i[4] & !LPC_INT_i[5] & LPC_INT_i[6] & LPC_INT_i[7] ;


assign ScopeIn[15:0] = LPC_INT_i[15:0];
assign ScopeIn[47:32] = 0;


ChipScope ChipSCOPE(
		.acq_clk(!CPU_Clk_i),        // acq_clk.clk
		.acq_data_in(ScopeIn),    //     tap.acq_data_in
		.acq_trigger_in(Trigger),  //        .acq_trigger_in
		.trigger_in(Trigger)
	);
*/

endmodule

