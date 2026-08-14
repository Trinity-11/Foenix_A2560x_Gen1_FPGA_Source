module Parallel2SerialAudio
(
input		wire				RST_i,
input		wire				SERIAL_Clk_i,
// 
input		wire	[7:0]		OPL3_Data_i,
input		wire				OPL3_RD_i,
input		wire				OPL3_WR_i,
input		wire				OPL3_CS_i,
input		wire	[1:0]		OPL3_A_i,

input		wire	[7:0]		OPN2_Data_i,
input		wire				OPN2_RD_i,
input		wire				OPN2_WR_i,
input		wire				OPN2_CS_i,
input		wire	[1:0]		OPN2_A_i,

input		wire	[7:0]		OPM_Data_i,
input		wire				OPM_RD_i,
input		wire				OPM_WR_i,
input		wire				OPM_CS_i,
input		wire				OPM_A_i,

input		wire	[7:0]		PSG_DATA_i,
input		wire				PSG_WE_i,
input		wire				PSG_CE_i,


output	wire				ABUS_CTRL_In_o,
output	wire				ABUS_CTRL_Clk_o,
output	wire				ABUS_CTRL_LATCH_o,

output	wire				ABUS_DATA_In0_o,
output	wire				ABUS_DATA_In1_o,
output	wire				ABUS_DATA_Clk_o,
output	wire				ABUS_DATA_LATCH_o,

output	reg				TIP_o	// Transfer In Progress

);

/*
wire [31:0] DataStream;
//assign DataStream = {OPL3_Data_i[2:7], OPL3_Data_i[1:0], OPN2_Data_i[7:0], PSG_DATA_i[3:7], PSG_DATA_i[2:0], OPM_Data_i[0:7]};
assign DataStream = { 
		OPM_Data_i[7],	// MSB
		OPM_Data_i[6],
		OPM_Data_i[5],
		OPM_Data_i[4],
		OPM_Data_i[3],
		OPM_Data_i[2],
		OPM_Data_i[1],
		OPM_Data_i[0],
		
		PSG_DATA_i[0],
		PSG_DATA_i[1],
		PSG_DATA_i[2],
		PSG_DATA_i[7],
		PSG_DATA_i[6],
		PSG_DATA_i[5],
		PSG_DATA_i[4],
		PSG_DATA_i[3],
		
		OPN2_Data_i[7],
		OPN2_Data_i[6],
		OPN2_Data_i[5],
		OPN2_Data_i[4],
		OPN2_Data_i[3],
		OPN2_Data_i[2],
		OPN2_Data_i[1],
		OPN2_Data_i[0],
		
		OPL3_Data_i[0],
		OPL3_Data_i[1],
		OPL3_Data_i[7],
		OPL3_Data_i[6],
		OPL3_Data_i[5],
		OPL3_Data_i[4],
		OPL3_Data_i[3],
		OPL3_Data_i[2] // LSB
};
*/
wire [15:0] DataStream0;
wire [15:0] DataStream1;
wire	[15:0] ControlStream;
//assign DataStream = {OPL3_Data_i[2:7], OPL3_Data_i[1:0], OPN2_Data_i[7:0], PSG_DATA_i[3:7], PSG_DATA_i[2:0], OPM_Data_i[0:7]};
assign DataStream0 = { 
		OPN2_Data_i[7],
		OPN2_Data_i[6],
		OPN2_Data_i[5],
		OPN2_Data_i[4],
		OPN2_Data_i[3],
		OPN2_Data_i[2],
		OPN2_Data_i[1],
		OPN2_Data_i[0],
		
		OPL3_Data_i[0],
		OPL3_Data_i[1],
		OPL3_Data_i[7],
		OPL3_Data_i[6],
		OPL3_Data_i[5],
		OPL3_Data_i[4],
		OPL3_Data_i[3],
		OPL3_Data_i[2] // LSB
};

assign DataStream1 = { 
		OPM_Data_i[7],	// MSB
		OPM_Data_i[6],
		OPM_Data_i[5],
		OPM_Data_i[4],
		OPM_Data_i[3],
		OPM_Data_i[2],
		OPM_Data_i[1],
		OPM_Data_i[0],
		
		PSG_DATA_i[7],
		PSG_DATA_i[6], 
		PSG_DATA_i[5],
		PSG_DATA_i[0],
		PSG_DATA_i[1],
		PSG_DATA_i[2],
		PSG_DATA_i[3], 
		PSG_DATA_i[4] // LSB
};
//LV595 - SN76489
//Pin 9 - D7 (0) MSB
//Pin 8 - D6 (1)
//Pin 7 - D5 (2)
//Pin 6 - D0 (7)
//Pin 5 - D1 (6)
//Pin 4 - D2 (5)
//Pin 3 - D3 (4)
//Pin 2 - D4 (3) LSB
//		PSG_DATA_i[0],
//		PSG_DATA_i[1], 
//		PSG_DATA_i[2],
//		PSG_DATA_i[7],
//		PSG_DATA_i[6],
//		PSG_DATA_i[5],
//		PSG_DATA_i[4], 
//		PSG_DATA_i[3] // LSB

assign ControlStream = 
{ 
		OPM_WR_i,
		OPM_RD_i,
		OPM_CS_i,
		OPM_A_i,
		PSG_WE_i,
		PSG_CE_i,
		OPN2_A_i[1],
		OPN2_A_i[0],
		OPN2_RD_i,
		OPN2_WR_i,
		OPN2_CS_i,
		OPL3_A_i[0],
		OPL3_A_i[1],
		OPL3_WR_i,
		OPL3_RD_i,
		OPL3_CS_i
};


localparam IDLE   = 5'b0_0000,
			  STATE1 = 5'b0_0001,
			  STATE2 = 5'b0_0011,
			  STATE3 = 5'b0_0010,
			  STATE4 = 5'b0_0110,
			  STATE5 = 5'b0_0111,
			  STATE6 = 5'b0_0101,
			  STATE7 = 5'b0_0100,
			  STATE8 = 5'b0_1100,
			  STATE9 = 5'b0_1101;

reg [4:0] StateMachine;

reg	[15:0]   Reg_CtrlStream; 			  
reg	[15:0]	Reg_ControlStream_Sync;

reg	[15:0]	Reg_DataStream0;
reg	[15:0]	Reg_DataStream1;

reg   [7:0] 	BitCounter;

assign ABUS_DATA_In1_o = Reg_DataStream1[15];
assign ABUS_DATA_In0_o = Reg_DataStream0[15];
assign ABUS_CTRL_In_o = Reg_CtrlStream[15];

always @ (posedge SERIAL_Clk_i)
begin
	if (RST_i) begin
			Reg_DataStream1 <= 16'h0000;	
			Reg_DataStream0 <= 16'h0000;
			Reg_CtrlStream <= 16'h0000;
	end
	else begin
	
		case (StateMachine)
			
		STATE1: begin
			Reg_CtrlStream 	<= ControlStream;
			Reg_DataStream0	<= DataStream0;
			Reg_DataStream1	<= DataStream1;
		end
	
		STATE3: begin
			Reg_CtrlStream 	<= Reg_CtrlStream  << 1'b1;
			Reg_DataStream0	<= Reg_DataStream0 << 1'b1;
			Reg_DataStream1	<= Reg_DataStream1 << 1'b1;				
		end
	
		endcase
	end
end

wire 	 Clk_CTRL_Toggle;
assign Clk_CTRL_Toggle = (StateMachine == STATE3) ? 1'b1 : 1'b0;
assign ABUS_CTRL_Clk_o =  Clk_CTRL_Toggle;
assign ABUS_DATA_Clk_o =  Clk_CTRL_Toggle;

reg Ctrl_Latch;
assign ABUS_CTRL_LATCH_o = Ctrl_Latch;
assign ABUS_DATA_LATCH_o = Ctrl_Latch;


// 4.46us Second To Update the Entire Serial To Parallel

always @ (posedge SERIAL_Clk_i)
begin
	if (RST_i) begin
		Ctrl_Latch <= 1'b0;
		TIP_o <= 1'b0;	
		StateMachine <= IDLE;
		Reg_ControlStream_Sync <= 16'hFFFF;
		BitCounter <= 8'b0000_0000;
	end
	else begin
	
		case(StateMachine)
	
		IDLE: begin
			if (Reg_ControlStream_Sync == ControlStream) begin
				StateMachine <= IDLE;
				Ctrl_Latch <= 1'b0;
				TIP_o <= 1'b0;				
			end 
			else begin
				StateMachine <= STATE1;
				TIP_o <= 1'b1;
				Reg_ControlStream_Sync <= ControlStream;				
			end
		end
		
		// Registering the Actual Data to be Streamed out
		STATE1: begin
				BitCounter <= 8'b0001_0000;	// Load the nUmber of bit to shift 32.
				StateMachine <= STATE2;		
		end
		
		// Transfer the first 16Bits with Data and Command
		STATE2: begin
			if (BitCounter) begin
				BitCounter <= BitCounter - 8'b0000_0001;
				StateMachine <= STATE3;				
			end
			else begin
				StateMachine <= STATE4;
			end
		end
		
		STATE3: begin
				StateMachine 	<= STATE2;
		end
		
		STATE4: begin
				StateMachine 	<= STATE5;
				Ctrl_Latch 		<= 1'b1;
		end
		
		STATE5: begin
				StateMachine 	<= IDLE;		
		end

		default: begin
			StateMachine <= IDLE;
		end
	
		endcase
	end
end


endmodule

// Grey Code Encoding
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
01010	10	01111
01011	11	01110
01100	12	01010
01101	13	01011
01110	14	01001
01111	15	01000
10000	16	11000
10001	17	11001
10010	18	11011
10011	19	11010
10100	20	11110
10101	21	11111
10110	22	11101
10111	23	11100
11000	24	10100
11001	25	10101
11010	26	10111
11011	27	10110
11100	28	10010
11101	29	10011
11110	30	10001
11111	31	10000
5'b0_0001
5'b0_0011
5'b0_0010
5'b0_0110
5'b0_0111
5'b0_0101
5'b0_0100
5'b0_1100
5'b0_1101
5'b0_1111
5'b0_1110
5'b0_1010
5'b0_1011
5'b0_1001
5'b0_1000
5'b1_1000
5'b1_1001
5'b1_1011
5'b1_1010
5'b1_1110
5'b1_1111
5'b1_1101
5'b1_1100
5'b1_0100
5'b1_0101
5'b1_0111
5'b1_0110
5'b1_0010
5'b1_0011
5'b1_0001
5'b1_0000
*/	 

