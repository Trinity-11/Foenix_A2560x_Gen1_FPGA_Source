`timescale 1ns / 1ps
module Trinity(
input		wire				CPU_Clk_i,
input		wire				RST_i,
input 	wire	[31:0]	CPU_A_i,
input		wire	[7:0]		CPU_D8_i,
input		wire	[15:0]	CPU_D16_i,
input		wire	[31:0]	CPU_D32_i,
input		wire	[1:0]		CPU_Siz_i,
input		wire	[3:0]		CPU_BE_i,
input		wire				CPU_WE_i, 
input 	wire				CPU_R_Wn_i,
input		wire				CPU_A_Valid_i,
input		wire				CS_Trinity_i,
output 	reg 	[31:0]	CPU_D_o,

input 	wire	[1:0]		BOOT_MODE_i,
input 	wire	[1:0]		USER_i,
input		wire				CPU_SPEED_i,
input	   wire           F_SD_CD_i,
input		wire				F_SD_WP_i,

//inout		wire				J0_BUTTON0_i,
//inout		wire				J0_BUTTON1_i,
//inout		wire				J0_BUTTON2_i,

input		wire				J0_DOWN_i,
input		wire				J0_LEFT_i,
input		wire				J0_RIGHT_i,
input		wire				J0_UP_i,

inout		wire				J1_BUTTON0_i,
inout		wire				J1_BUTTON1_i,
inout		wire				J1_BUTTON2_i,

input		wire				J1_DOWN_i,
input		wire				J1_LEFT_i,
input		wire				J1_RIGHT_i,
input		wire				J1_UP_i,

output	wire				JOYSTICK0_RLY_o,
output	wire				JOYSTICK1_RLY_o

);

assign JOYSTICK0_RLY_o = SNES_CTRL_REG[8];
assign JOYSTICK1_RLY_o = SNES_CTRL_REG[9];

wire				NES_SNES_CLK0;
reg				NES_SNES_LTCH0;
wire				NES_PORT_0_ENABLE;
wire				NES_SNES_PORT_0_CHOICE;

wire				NES_SNES_CLK1;
reg				NES_SNES_LTCH1;
wire				NES_PORT_1_ENABLE;
wire				NES_SNES_PORT_1_CHOICE;

wire				J0_BUTTON0_Input;
wire				J0_BUTTON1_Input;
wire				J0_BUTTON2_Input;

wire				J1_BUTTON0_Input;
wire				J1_BUTTON1_Input;
wire				J1_BUTTON2_Input;

// Joystick Stuff
// BiDir Buffer For Joystick/NES/SNES Support
/*
BIDIR_SIGNAL NES_SNES_P0_CHOICE (
	.dataout( J0_BUTTON0_Input ),   //   dout.export
	.datain( NES_SNES_PORT_0_CHOICE ),    //    din.export
	.dataio( J0_BUTTON0_i ), // pad_io.export
	.oe( NES_PORT_0_ENABLE )      //     oe.export
);

BIDIR_SIGNAL NES_SNES_CLK0_BUF (
	.dataout( J0_BUTTON1_Input ),   //   dout.export
	.datain( NES_SNES_CLK0 ),    //    din.export
	.dataio( J0_BUTTON1_i ), // pad_io.export
	.oe( NES_PORT_0_ENABLE )      //     oe.export
);

BIDIR_SIGNAL NES_SNES_LTCH0_BUF (
	.dataout( J0_BUTTON2_Input ),   //   dout.export
	.datain( NES_SNES_LTCH0 ),    //    din.export
	.dataio( J0_BUTTON2_i ), // pad_io.export
	.oe( NES_PORT_0_ENABLE )      //     oe.export
);
*/

assign J0_BUTTON0_Input = 1'b1;
assign J0_BUTTON1_Input = 1'b1;
assign J0_BUTTON2_Input = 1'b1;


BIDIR_SIGNAL NES_SNES_CLK1_BUF (
	.dataout( J1_BUTTON1_Input ),   //   dout.export
	.datain( NES_SNES_CLK1 ),    //    din.export
	.dataio( J1_BUTTON1_i ), // pad_io.export
	.oe( NES_PORT_1_ENABLE )      //     oe.export
);

BIDIR_SIGNAL NES_SNES_LTCH1_BUF (
	.dataout( J1_BUTTON2_Input ),   //   dout.export
	.datain( NES_SNES_LTCH1 ),    //    din.export
	.dataio( J1_BUTTON2_i ), // pad_io.export
	.oe( NES_PORT_1_ENABLE )      //     oe.export
);



BIDIR_SIGNAL NES_SNES_P1_CHOICE (
	.dataout( J1_BUTTON0_Input ),   //   dout.export
	.datain( NES_SNES_PORT_1_CHOICE ),    //    din.export
	.dataio( J1_BUTTON0_i ), // pad_io.export
	.oe( NES_PORT_1_ENABLE )      //     oe.export
);


reg	[11:0]	SNES_PORT0_INPUT0	= 12'h000;
reg	[11:0]	SNES_PORT0_INPUT1	= 12'h000;
reg	[11:0]	SNES_PORT0_INPUT2	= 12'h000;
reg	[11:0]	SNES_PORT0_INPUT3	= 12'h000;

reg	[11:0]	SNES_PORT1_INPUT0	= 12'h000;
reg	[11:0]	SNES_PORT1_INPUT1	= 12'h000;
reg	[11:0]	SNES_PORT1_INPUT2	= 12'h000;
reg	[11:0]	SNES_PORT1_INPUT3	= 12'h000;


reg	[31:0]	SNES_CTRL_REG = 32'h0000_0000;
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
//{ SNES_CTRL_REG[7], SampleIsDone, SNES_CTRL_REG[5:0]};

always @ (*)
begin
	case(CPU_A_i[4:2])
		3'b000: begin CPU_D_o = {16'h0000, J0_BUTTON2_Input, J0_BUTTON1_Input, 1'b0, J0_BUTTON0_Input, J0_RIGHT_i, J0_LEFT_i, J0_DOWN_i, J0_UP_i, J1_BUTTON2_Input, J1_BUTTON1_Input, 1'b0, J1_BUTTON0_Input, J1_RIGHT_i, J1_LEFT_i, J1_DOWN_i, J1_UP_i}; end
		3'b001: begin CPU_D_o = {16'h0000, SNES_CTRL_REG[15:7], SampleIsDone, SNES_CTRL_REG[5:0] }; end
		3'b010: begin CPU_D_o = { SNES_PORT0_INPUT1, 4'b0000, SNES_PORT0_INPUT0, 4'b0000 }; end
		3'b011: begin CPU_D_o = { SNES_PORT0_INPUT3, 4'b0000, SNES_PORT0_INPUT2, 4'b0000 }; end
		3'b100: begin CPU_D_o = { SNES_PORT1_INPUT1, 4'b0000, SNES_PORT1_INPUT0, 4'b0000 }; end
		3'b101: begin CPU_D_o = { SNES_PORT1_INPUT3, 4'b0000, SNES_PORT1_INPUT2, 4'b0000 }; end
		3'b110: begin CPU_D_o = {6'b00_0000, F_SD_WP_i, F_SD_CD_i, 8'b0000_0000, 6'b00_0000, USER_i[1], USER_i[0], 4'b0000, CPU_SPEED_i, 1'b0, BOOT_MODE_i[1], BOOT_MODE_i[0]}; end
		3'b111: begin CPU_D_o = 32'hAAAA_5555; end
		default: begin	CPU_D_o = 32'hDEAF_B00B; end
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
always @ (posedge CPU_Clk_i)
begin
	if (RST_i) begin
			SNES_CTRL_REG  <= 32'h0000_0000;
	end
	else begin
	
		if ( CS_Trinity_i && !CPU_R_Wn_i && ( CPU_A_i[4:0] == 5'b0_0100 ) && (CPU_Siz_i[1:0] == 2'b00) && CPU_WE_i) begin
			SNES_CTRL_REG <= CPU_D32_i;
		end
		else begin
		if ((StateMachineP0 == LATCH) || (StateMachineP1 == LATCH))
			SNES_CTRL_REG[7] <= 1'b0;	// Clear the Flag and let's begin the fetch
			
		end
	end
end


//State Machine Port 0
always @ (posedge CPU_Clk_i)
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
					S2P_CLK_DELAY_P0 <= 3'b100;			// Change from 2 to 4 - July 30th 2021
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
					
				S2P_CLK_DELAY_P0 <= 3'b100;			// Change from 2 to 4 - July 30th 2021
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
					S2P_CLK_DELAY_P0 <= 3'b100;		// Change from 2 to 4 - July 30th, 2021
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
always @(posedge CPU_Clk_i)
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
always @ (posedge CPU_Clk_i)
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
					S2P_CLK_DELAY_P1 <= 3'b100;			// Change from 2 to 4 - July 30th 2021
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
					
				S2P_CLK_DELAY_P1 <= 3'b100;			// Change from 2 to 4 - July 30th 2021
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
					S2P_CLK_DELAY_P1 <= 3'b100;			// Change from 2 to 4 - July 30th 2021
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
					S2P_CLK_DELAY_P1 <= 3'b100;			// Change from 2 to 4 - July 30th 2021
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
always @(posedge CPU_Clk_i)
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

