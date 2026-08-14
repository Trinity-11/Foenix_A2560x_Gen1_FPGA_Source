`timescale 1ns / 1ps
module Trinity(
input		wire				CPU_Clk_i,
input		wire				RST_i,
input 	wire	[23:0]	CPU_A_i,
input 	wire	[7:0]		CPU_D_i,
input 	wire				CPU_R_Wn_i,
input		wire				CS_Trinity_i,
output 	reg 	[7:0]		CPU_D_o,

input 	wire		[1:0]	BOOT_MODE_i,
input 	wire		[2:0]	USER_i,
input 	wire				HD_INSTALLED_i,
input	   wire           F_SD_CD_i,
input		wire				F_SD_WP_i,

input		wire				J0_BUTTON0_i,

input		wire				J0_DOWN_i,
input		wire				J0_LEFT_i,
input		wire				J0_RIGHT_i,
input		wire				J0_UP_i,

input		wire				J1_BUTTON0_i,
input		wire				J1_DOWN_i,
input		wire				J1_LEFT_i,
input		wire				J1_RIGHT_i,
input		wire				J1_UP_i,

input		wire				J0_BUTTON1_i,
input		wire				J0_BUTTON2_i,

output	wire				NES_SNES_CLK0,
output	reg				NES_SNES_LTCH0,
output	wire				NES_PORT_0_ENABLE,
output	wire				NES_SNES_PORT_0_CHOICE,

input		wire				J1_BUTTON1_i,
input		wire				J1_BUTTON2_i,

output	wire				NES_SNES_CLK1,
output	reg				NES_SNES_LTCH1,
output	wire				NES_PORT_1_ENABLE,
output	wire				NES_SNES_PORT_1_CHOICE
);

reg	[11:0]	SNES_SERIAL2PARALEL0 = 12'h000;
reg	[11:0]	SNES_SERIAL2PARALEL1 = 12'h000;

reg	[11:0]	SNES_PORT0_INPUT0	= 12'h000;
reg	[11:0]	SNES_PORT0_INPUT1	= 12'h000;
reg	[11:0]	SNES_PORT0_INPUT2	= 12'h000;
reg	[11:0]	SNES_PORT0_INPUT3	= 12'h000;

reg	[11:0]	SNES_PORT1_INPUT0	= 12'h000;
reg	[11:0]	SNES_PORT1_INPUT1	= 12'h000;
reg	[11:0]	SNES_PORT1_INPUT2	= 12'h000;
reg	[11:0]	SNES_PORT1_INPUT3	= 12'h000;


reg	[7:0]		SNES_CTRL_REG = 8'h00;
reg	[2:0]		S2P_CLK_DELAY_P0 = 3'b000;
reg	[2:0]		S2P_CLK_DELAY_P1 = 3'b000;

wire 		 Serial2Parallel_Clock_P0;
wire 		 Serial2Parallel_Clock_P1;

reg [3:0] BitCounter_P0;
reg [3:0] BitCounter_P1;
reg		 SampleIsDone_P0;
reg		 SampleIsDone_P1;
reg [3:0] StateMachineP0;
reg [3:0] StateStateMachineP0;
reg [3:0] StateMachineP1;
reg [3:0] StateStateMachineP1;

wire  SampleIsDone;
assign SampleIsDone = SampleIsDone_P0 | SampleIsDone_P1;

assign NES_PORT_0_ENABLE = SNES_CTRL_REG[0];
assign NES_PORT_1_ENABLE = SNES_CTRL_REG[1];
assign NES_SNES_PORT_0_CHOICE = !SNES_CTRL_REG[2];
assign NES_SNES_PORT_1_CHOICE = !SNES_CTRL_REG[3];

always @ (*)
begin
	case(CPU_A_i[4:0])
		5'b0_0000: begin CPU_D_o = {J0_BUTTON2_i, J0_BUTTON1_i, 1'b0, J0_BUTTON0_i, J0_RIGHT_i, J0_LEFT_i, J0_DOWN_i, J0_UP_i}; end
		5'b0_0001: begin CPU_D_o = {J1_BUTTON2_i, J1_BUTTON1_i, 1'b0, J1_BUTTON0_i, J1_RIGHT_i, J1_LEFT_i, J1_DOWN_i, J1_UP_i}; end
		5'b0_0010: begin CPU_D_o = 8'h00; end
		5'b0_0011: begin CPU_D_o = 8'h00; end
		5'b0_0100: begin CPU_D_o = { SNES_CTRL_REG[7], SampleIsDone, SNES_CTRL_REG[5:0]}; end
		5'b0_0101: begin CPU_D_o = 8'h41; end
		5'b0_0110: begin CPU_D_o = 8'h31; end
		5'b0_0111: begin CPU_D_o = 8'h41; end
		5'b0_1000: begin CPU_D_o = SNES_CTRL_REG[2] ? { SNES_PORT0_INPUT0[11:8], SNES_PORT0_INPUT0[7:4] } : SNES_PORT0_INPUT0[7:0]; end
		5'b0_1001: begin CPU_D_o = {4'b0000, SNES_PORT0_INPUT0[3:0]}; end
		5'b0_1010: begin CPU_D_o = SNES_CTRL_REG[2] ? { SNES_PORT0_INPUT1[11:8], SNES_PORT0_INPUT1[7:4] } : SNES_PORT0_INPUT1[7:0]; end
		5'b0_1011: begin CPU_D_o = {4'b0000, SNES_PORT0_INPUT1[3:0]}; end
		5'b0_1100: begin CPU_D_o = 8'h55; end		// "U" when the Trinity Chip is Integrated in the C256 Foenix U
		5'b0_1101: begin CPU_D_o = {5'b00_000, USER_i[2], USER_i[1], USER_i[0]}; end				
		5'b0_1110: begin CPU_D_o = {HD_INSTALLED_i, 5'b0_0000, BOOT_MODE_i[1], BOOT_MODE_i[0]}; end	
		
		5'b1_0010: begin CPU_D_o = {6'b00_0000, F_SD_WP_i, F_SD_CD_i}; end 		
		// Port 0 - Input 2 // Input 3
		
		5'b1_0100: begin CPU_D_o = SNES_CTRL_REG[2] ? { SNES_PORT0_INPUT2[11:8], SNES_PORT0_INPUT2[7:4] } : SNES_PORT0_INPUT2[7:0]; end
		5'b1_0101: begin CPU_D_o = {4'b0000, SNES_PORT0_INPUT2[3:0]}; end
		
		5'b1_0110: begin CPU_D_o = SNES_CTRL_REG[2] ? { SNES_PORT0_INPUT3[11:8], SNES_PORT0_INPUT3[7:4] } : SNES_PORT0_INPUT3[7:0]; end
		5'b1_0111: begin CPU_D_o = {4'b0000, SNES_PORT0_INPUT3[3:0]}; end
		// Input 1 - Input 0 // Input 1
		5'b1_1000: begin CPU_D_o = SNES_CTRL_REG[3] ? { SNES_PORT1_INPUT0[11:8], SNES_PORT1_INPUT0[7:4] } : SNES_PORT1_INPUT0[7:0]; end
		5'b1_1001: begin CPU_D_o = {4'b0000, SNES_PORT1_INPUT0[3:0]}; end
		
		5'b1_1010: begin CPU_D_o = SNES_CTRL_REG[3] ? { SNES_PORT1_INPUT1[11:8], SNES_PORT1_INPUT1[7:4] } : SNES_PORT1_INPUT1[7:0]; end
		5'b1_1011: begin CPU_D_o = {4'b0000, SNES_PORT1_INPUT1[3:0]}; end
		
		// Input 1 - Input 2 // Input 3
		5'b1_1100: begin CPU_D_o = SNES_CTRL_REG[3] ? { SNES_PORT1_INPUT2[11:8], SNES_PORT1_INPUT2[7:4] } : SNES_PORT1_INPUT2[7:0]; end
		5'b1_1101: begin CPU_D_o = {4'b0000, SNES_PORT1_INPUT2[3:0]}; end
		
		5'b1_1110: begin CPU_D_o = SNES_CTRL_REG[3] ? { SNES_PORT1_INPUT3[11:8], SNES_PORT1_INPUT3[7:4] } : SNES_PORT1_INPUT3[7:0]; end
		5'b1_1111: begin CPU_D_o = {4'b0000, SNES_PORT1_INPUT3[3:0]}; end

//		5'b0_1111: begin CPU_D_o = ScratchPad[7:0]; end
		default: begin
			CPU_D_o = 8'b10100101;
		end
	endcase
end


localparam 	IDLE 				= 4'b0000,
				TRIG 				= 4'b0001,
				LATCH 			= 4'b0011,
				MODE_SET			= 4'b0010,
				S2P0				= 4'b0110,
				S2P1     		= 4'b0111,
				SET_DONE_BIT 	= 4'b0101,
				DONE     		= 4'b0100,
				FOUR_CLOCK_DLY = 4'b1100;
				
				
/*
00000
00001	1	00001
00010	2	00011
00011	3	00010
00100	4	00110
00101	5	00111
00110	6	00101
00111	7	00100
01000	8	01100
01001	9	01101
*/				

always @ (negedge CPU_Clk_i)
begin
	if (RST_i) begin
			SNES_CTRL_REG  <= 8'b0000_0000;
	end
	else begin
	
		if ( CS_Trinity_i && !CPU_R_Wn_i && ( CPU_A_i[4:0] == 5'b0_0100 ) ) begin
			SNES_CTRL_REG <= CPU_D_i[7:0];
		end
		else begin
		if ((StateMachineP0 == LATCH) || (StateMachineP1 == LATCH))
			SNES_CTRL_REG[7] <= 1'b0;	// Clear the Flag and let's begin the fetch
			
		end
	end
end


//State Machine Port 0
always @ (negedge CPU_Clk_i)
begin
	if (RST_i) begin
		StateMachineP0 <= IDLE;
		BitCounter_P0 <= 4'b0000;
		SampleIsDone_P0 <= 1'b0;
		NES_SNES_LTCH0 <= 1'b0;
	end
	else begin
	
			case( StateMachineP0 )
	
			IDLE: begin 
				if ( SNES_CTRL_REG[0] ) begin
					StateMachineP0 <= TRIG;
				end
				else begin
					StateMachineP0 <= IDLE;				
				end
			end
	
			TRIG: begin 
				if (SNES_CTRL_REG[7]) begin
					StateMachineP0 <= LATCH;
					S2P_CLK_DELAY_P0 <= 3'b010;
				end
				else begin
					if ( SNES_CTRL_REG[0] ) begin
						StateMachineP0 <= TRIG;
					end
					else begin
						StateMachineP0 <= IDLE;				
					end					
				end
			end
	
			LATCH: begin
				SampleIsDone_P0 <= 1'b0;	
				if (SNES_CTRL_REG[0]) begin
					NES_SNES_LTCH0 <= 1'b1;
				end
				
				if (SNES_CTRL_REG[2]) 
					BitCounter_P0 <= 4'd11;
				else
					BitCounter_P0 <= 4'd8;
					
				S2P_CLK_DELAY_P0 <= 3'b010;
				StateMachineP0 <= FOUR_CLOCK_DLY;
				StateStateMachineP0 <= MODE_SET;
			end
	
			MODE_SET: begin 
				NES_SNES_LTCH0 <= 1'b0;
				StateMachineP0 <= S2P0;					
			end
	
			S2P0: begin 
				if (BitCounter_P0) begin
					BitCounter_P0 <= BitCounter_P0 - 4'b0001;
					
					StateMachineP0 <= FOUR_CLOCK_DLY;
					StateStateMachineP0 <= S2P1;					
				end
				else begin
					StateMachineP0 <= SET_DONE_BIT;
				end
			end
	
			S2P1: begin
				if (S2P_CLK_DELAY_P0)
					S2P_CLK_DELAY_P0 <= S2P_CLK_DELAY_P0 - 3'b001;
				else begin			
					S2P_CLK_DELAY_P0 <= 3'b010;
					StateMachineP0 <= S2P0;
				end
			end
	
			SET_DONE_BIT: begin
					SampleIsDone_P0 <= 1'b1;
					StateMachineP0 <= DONE;	
			end
	
			DONE: begin 
				StateMachineP0 <= IDLE;			
			end
	
			FOUR_CLOCK_DLY: begin
				if (S2P_CLK_DELAY_P0)
					S2P_CLK_DELAY_P0 <= S2P_CLK_DELAY_P0 - 3'b001;
				else begin
					S2P_CLK_DELAY_P0 <= 3'b010;
					StateMachineP0 <= StateStateMachineP0;
				end
			end
	
			default:
			begin 
				StateMachineP0 <= IDLE;
			end
	
			endcase
		end
end

//PORT 0
always @(negedge CPU_Clk_i)
begin
	if (RST_i) begin
				SNES_PORT0_INPUT0		<= 12'h000;
				SNES_PORT0_INPUT1		<= 12'h000;
				SNES_PORT0_INPUT2		<= 12'h000;
				SNES_PORT0_INPUT3		<= 12'h000;
	end
	else begin
		if (SNES_CTRL_REG[0]) begin // 0 - 8 Bit Mode (NES), 1 - 12 Bits Mode (SNES)	
			if (StateMachineP0 == S2P0) begin
//				SNES_SERIAL2PARALEL0 <= {SNES_SERIAL2PARALEL0[10:0], J0_BUTTON0_i};
				SNES_PORT0_INPUT0		<= { SNES_PORT0_INPUT0[10:0], J0_UP_i};
				SNES_PORT0_INPUT1		<= { SNES_PORT0_INPUT1[10:0], J0_DOWN_i};
				SNES_PORT0_INPUT2		<= { SNES_PORT0_INPUT2[10:0], J0_LEFT_i};
				SNES_PORT0_INPUT3		<= { SNES_PORT0_INPUT3[10:0], J0_RIGHT_i};
			end
		end
		else begin
			if (StateMachineP0 == LATCH) begin
				SNES_PORT0_INPUT0		<= 12'h000;
				SNES_PORT0_INPUT1		<= 12'h000;
				SNES_PORT0_INPUT2		<= 12'h000;
				SNES_PORT0_INPUT3		<= 12'h000;

			end
		end
	end
end
assign Serial2Parallel_Clock_P0 = (StateMachineP0 == S2P1) ? 1'b1 : 1'b0;
assign NES_SNES_CLK0 = Serial2Parallel_Clock_P0;


////////////////////////////// PORT 1 
always @ (negedge CPU_Clk_i)
begin
	if (RST_i) begin
		StateMachineP1 <= IDLE;
		BitCounter_P1 <= 4'b0000;
		SampleIsDone_P1 <= 1'b0;
		NES_SNES_LTCH1 <= 1'b0;
	end
	else begin
	
			case( StateMachineP1 )
	
			IDLE: begin 
				if (SNES_CTRL_REG[1]) begin
					StateMachineP1 <= TRIG;
				end
				else begin
					StateMachineP1 <= IDLE;				
				end
			end
	
			TRIG: begin 
				if (SNES_CTRL_REG[7]) begin
					StateMachineP1 <= LATCH;
					S2P_CLK_DELAY_P1 <= 3'b010;
				end
				else begin
					if (SNES_CTRL_REG[1]) begin
						StateMachineP1 <= TRIG;
					end
					else begin
						StateMachineP1 <= IDLE;				
					end					
				end
			end
	
			LATCH: begin
				SampleIsDone_P1 <= 1'b0;	
		
				if (SNES_CTRL_REG[1]) begin
					NES_SNES_LTCH1 <= 1'b1;	
				end
				
				if (SNES_CTRL_REG[3]) 
					BitCounter_P1 <= 4'd11;
				else
					BitCounter_P1 <= 4'd8;
					
				S2P_CLK_DELAY_P1 <= 3'b010;
				StateMachineP1 <= FOUR_CLOCK_DLY;
				StateStateMachineP1 <= MODE_SET;
			end
	
			MODE_SET: begin 
				NES_SNES_LTCH1 <= 1'b0;
				StateMachineP1 <= S2P0;					
			end
	
			S2P0: begin 
				if (BitCounter_P1) begin
					BitCounter_P1 <= BitCounter_P1 - 4'b0001;
					StateMachineP1 <= FOUR_CLOCK_DLY;
					StateStateMachineP1 <= S2P1;					
				end
				else begin
					StateMachineP1 <= SET_DONE_BIT;
				end
			end
	
			S2P1: begin
				if (S2P_CLK_DELAY_P1)
					S2P_CLK_DELAY_P1 <= S2P_CLK_DELAY_P1 - 3'b001;
				else begin			
					S2P_CLK_DELAY_P1 <= 3'b010;
					StateMachineP1 <= S2P0;
				end
			end
	
			SET_DONE_BIT: begin
					SampleIsDone_P1 <= 1'b1;
					StateMachineP1 <= DONE;	
			end
	
			DONE: begin 
				StateMachineP1 <= IDLE;			
			end
	
			FOUR_CLOCK_DLY: begin
				if (S2P_CLK_DELAY_P1)
					S2P_CLK_DELAY_P1 <= S2P_CLK_DELAY_P1 - 3'b001;
				else begin
					S2P_CLK_DELAY_P1 <= 3'b010;
					StateMachineP1 <= StateStateMachineP1;
				end
			end
	
			default:
			begin 
				StateMachineP1 <= IDLE;
			end
	
			endcase
		end
end


//PORT 1
always @(negedge CPU_Clk_i)
begin
	if (RST_i) begin
				SNES_PORT1_INPUT0		<= 12'h000;
				SNES_PORT1_INPUT1		<= 12'h000;
				SNES_PORT1_INPUT2		<= 12'h000;
				SNES_PORT1_INPUT3		<= 12'h000;

	end
	else begin
		if (SNES_CTRL_REG[1]) begin // 0 - 8 Bit Mode (NES), 1 - 12 Bits Mode (SNES)
			if (StateMachineP1 == S2P0) begin
				SNES_PORT1_INPUT0		<= { SNES_PORT1_INPUT0[10:0], J1_UP_i};
				SNES_PORT1_INPUT1		<= { SNES_PORT1_INPUT1[10:0], J1_DOWN_i};
				SNES_PORT1_INPUT2		<= { SNES_PORT1_INPUT2[10:0], J1_LEFT_i};
				SNES_PORT1_INPUT3		<= { SNES_PORT1_INPUT3[10:0], J1_RIGHT_i};
			end
				//SNES_SERIAL2PARALEL1 <= {Joystick1[4], SNES_SERIAL2PARALEL1[11:1]};				
		end
		else begin
			if (StateMachineP1 == LATCH) begin
				SNES_PORT1_INPUT0		<= 12'h000;
				SNES_PORT1_INPUT1		<= 12'h000;
				SNES_PORT1_INPUT2		<= 12'h000;
				SNES_PORT1_INPUT3		<= 12'h000;
			end
		end
	end
end
assign Serial2Parallel_Clock_P1 = (StateMachineP1 == S2P1) ? 1'b1 : 1'b0;
assign NES_SNES_CLK1 = Serial2Parallel_Clock_P1;

endmodule 

