
module Keyboard_RGB_Matrix_Module(

input		wire				Clk_i,
input		wire				Rst_i,

input		wire				SOF_i,

input		wire	[31:0]	iBUS_A_i,
input		wire				iBUS_A_Valid_i,
input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]	iBUS_D16_i,
input		wire	[31:0]	iBUS_D32_i,
input		wire	[1:0]		iBUS_D_Siz_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i, 
input		wire				iBUS_RWn_i,
input		wire				CS_MAUS_RGB_i,

output 	wire				MTX_CLK_o,
output	wire				MTX_LATCH_o,
output	wire				MTX_SERIAL_IN_o


);


//always @ (posedge Clk_i) begin



//end



assign MTX_CLK_o 			= Clk_Out;
assign MTX_LATCH_o 		= Latch_Data;
assign MTX_SERIAL_IN_o 	= Bit2Shit[0];



reg [15:0] TimeCount;

//reg STS_Serial_Out;
//reg STS_Latch_Out;
//reg STS_Clock_Out;
//reg [39:0] STS_Value_2_Slide;
//reg [2:0] SM_Status;
//reg [7:0] STS_Counter;

//40'h00_00_00_00_00
// 00 -     COL1, COL2, COL3, COL4, COL5, COL6, COL7, COL8
// 00 -     COL9, COL10, COL11, COL12, COL13, COL14, COL15, COL16
// 00 -     R6.R5.R4.R3.R2.R1.R0.X1.X0
// 00 -     G6.G5.G4.G3.G2.G1.G0.X1.X0
// 00 - LSB B6.B5.B4.B3.B2.B1.B0.X1.X0
//reg [15:0] 	Shift;

/*
reg Clk_Divide;

always @ (posedge Clk_i) begin
	Clk_Divide <= Clk_Divide ^ 1'b1;
end
*/
// 4444444

always @ (posedge Clk_i) begin
	if ( Rst_i ) begin
	
	end
	else begin
	
		if ( CS_MAUS_RGB_i && !iBUS_RWn_i && iBUS_D_Siz_i == 2'b10 && iBUS_WE_i ) begin
			case (iBUS_A_i[7:5])
		
				3'b000: begin Row0[iBUS_A_i[4:1]] <= iBUS_D16_i; end	// FEC0_1000
				3'b001: begin Row1[iBUS_A_i[4:1]] <= iBUS_D16_i; end  // FEC0_1020
				3'b010: begin Row2[iBUS_A_i[4:1]] <= iBUS_D16_i; end  // FEC0_1040
				3'b011: begin Row3[iBUS_A_i[4:1]] <= iBUS_D16_i; end
				3'b100: begin Row4[iBUS_A_i[4:1]] <= iBUS_D16_i; end
				3'b101: begin Row5[iBUS_A_i[4:1]] <= iBUS_D16_i; end
	
				default: begin end
		
			endcase
		end
	end
end



reg [15:0] Row0[0:15];
reg [15:0] Row1[0:15];
reg [15:0] Row2[0:15];
reg [15:0] Row3[0:15];
reg [15:0] Row4[0:15];
reg [15:0] Row5[0:15];

wire [17:0] OutputRGBValue;

assign OutputRGBValue[0] =  Row0[CC][7:4] ? (( Row0[CC][7:4]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // B
assign OutputRGBValue[1] =  Row0[CC][3:0] ? (( Row0[CC][3:0]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // G
assign OutputRGBValue[2] =  Row0[CC][11:8] ? (( Row0[CC][11:8] >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // R

assign OutputRGBValue[3] =  Row1[CC][7:4] ? (( Row1[CC][7:4]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // B
assign OutputRGBValue[4] =  Row1[CC][3:0] ? (( Row1[CC][3:0]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // G
assign OutputRGBValue[5] =  Row1[CC][11:8] ? (( Row1[CC][11:8] >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // R

assign OutputRGBValue[6] =  Row2[CC][7:4] ? (( Row2[CC][7:4]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // B
assign OutputRGBValue[7] =  Row2[CC][3:0] ? (( Row2[CC][3:0]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // G
assign OutputRGBValue[8] =  Row2[CC][11:8] ? (( Row2[CC][11:8] >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // R

assign OutputRGBValue[9]  =  Row3[CC][7:4] ? (( Row3[CC][7:4]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // B
assign OutputRGBValue[10] =  Row3[CC][3:0] ? (( Row3[CC][3:0]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // G
assign OutputRGBValue[11] =  Row3[CC][11:8] ? (( Row3[CC][11:8] >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // R

assign OutputRGBValue[12] =  Row4[CC][7:4] ? (( Row4[CC][7:4]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // B
assign OutputRGBValue[13] =  Row4[CC][3:0] ? (( Row4[CC][3:0]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // G
assign OutputRGBValue[14] =  Row4[CC][11:8] ? (( Row4[CC][11:8] >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // R

assign OutputRGBValue[15] =  Row5[CC][7:4] ? (( Row5[CC][7:4]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // B
assign OutputRGBValue[16] =  Row5[CC][3:0] ? (( Row5[CC][3:0]   >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // G
assign OutputRGBValue[17] =  Row5[CC][11:8] ? (( Row5[CC][11:8] >= LevelCounter[3:0]) ? 1'b1 : 1'b0) : 1'b0; // R


/*
wire [143:0] TinyTP1;
wire 			TinyTrigger1;

assign TinyTrigger1 		= { SOF_Edge, SOF_Sync } == 2'b01;

assign TinyTP1[15:0] 	= Row0[CC];
assign TinyTP1[31:16]	= Row1[CC];
assign TinyTP1[47:32] 	= Row2[CC];
assign TinyTP1[63:48]	= Row3[CC];
assign TinyTP1[79:64]	= Row4[CC];
assign TinyTP1[95:80] 	= Row5[CC];

assign TinyTP1[99:96] 	= CC;
assign TinyTP1[103:100]	= ST;
assign TinyTP1[121:104] = OutputRGBValue;
assign TinyTP1[126:122] = LevelCounter;


TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/


//reg [31:0] Memory[0:15];
reg [4:0] LevelCounter;
/*
// RBG
						// Top Row                Bottom
initial begin
		Memory[0] 	= { 14'h0000, 18'b101_000_000_000_101_101 };	// Top right
		Memory[1] 	= 18'b101_000_000_010_000_101 };
		Memory[2] 	= 18'b101_000_010_010_000_101 };
		Memory[3] 	= 18'b101_010_010_010_010_000 };
		Memory[4] 	= 18'b000_010_010_010_010_000 };
		Memory[5] 	= 18'b000_010_010_010_010_000 };
		Memory[6] 	= 18'b000_010_010_010_010_000 };
		Memory[7]	= 18'b000_010_010_010_010_000 };
		Memory[8] 	= 18'b000_010_010_010_010_000 };
		Memory[9] 	= 18'b000_010_010_010_010_000 };
		Memory[10] 	= 18'b000_010_010_010_010_000 };
		Memory[11] 	= 18'b000_010_010_010_010_000 };
		Memory[12] 	= 18'b000_010_010_010_010_000 };
		Memory[13] 	= 18'b000_010_010_010_010_000 };
		Memory[14] 	= 18'b000_010_010_000_010_000 };
		Memory[15] 	= 18'b101_010_000_000_000_000 }; // Most Left
end
*/
// Purple : 110
// Yellow : 101
// Cyan   : 011
// White  : 111
// Red    : 100
// Blue   : 010
// Green  : 001
/*


always @ (posedge Clk_i) begin
	if (Rst_i) Begin
	
		Memory[0] <= 18'h000_000_000_000_000_000;
		Memory[1] <= 18'h000_000_000_000_000_000;
		Memory[2] <= 18'h000_000_000_000_000_000;
		Memory[3] <= 18'h000_000_000_000_000_000;
		Memory[4] <= 18'h000_000_000_000_000_000;
		Memory[5] <= 18'h000_000_000_000_000_000;
		Memory[6] <= 18'h000_000_000_000_000_000;
		Memory[7] <= 18'h000_000_000_000_000_000;
		Memory[8] <= 18'h000_000_000_000_000_000;
		Memory[9] <= 18'h000_000_000_000_000_000;
		Memory[10] <= 18'h000_000_000_000_000_000;
		Memory[11] <= 18'h000_000_000_000_000_000;
		Memory[12] <= 18'h000_000_000_000_000_000;
		Memory[13] <= 18'h000_000_000_000_000_000;
		Memory[14] <= 18'h000_000_000_000_000_000;
		Memory[15] <= 18'h000_000_000_000_000_000;
	
	end
	else begin
	
		
	
	end
end
*/

reg SOF_Sync, SOF_Edge;

always @ (posedge Clk_i) begin
		SOF_Sync <=	SOF_i;
		SOF_Edge <= SOF_Sync;
end


localparam 		IDLE 					= 4'b0000,
					RESET_COUNTER		= 4'b0001,
					LOAD_VALUE			= 4'b0010,
					
					CLK0_A				= 4'b0100,
					CLK0_B				= 4'b0101,
					CLK1_A				= 4'b0110,
					CLK1_B				= 4'b0111,
					
					LATCH_DATA_A		= 4'b1000,
					LATCH_DATA_B		= 4'b1001,					
					
					TIMER_A				= 4'b1010,
					TIMER_B				= 4'b1011;

reg [3:0]	CC;
reg [15:0]	Colomn;
reg			Clk_Out;
reg			Latch_Data;

always @ (*) begin
	case (CC)
		4'b0000: Colomn <= 16'b0000_0000_0000_0001;
		4'b0001: Colomn <= 16'b0000_0000_0000_0010;
		4'b0010: Colomn <= 16'b0000_0000_0000_0100;
		4'b0011: Colomn <= 16'b0000_0000_0000_1000;
		4'b0100: Colomn <= 16'b0000_0000_0001_0000;
		4'b0101: Colomn <= 16'b0000_0000_0010_0000;
		4'b0110: Colomn <= 16'b0000_0000_0100_0000;
		4'b0111: Colomn <= 16'b0000_0000_1000_0000;
		4'b1000: Colomn <= 16'b0000_0001_0000_0000;
		4'b1001: Colomn <= 16'b0000_0010_0000_0000;
		4'b1010: Colomn <= 16'b0000_0100_0000_0000;
		4'b1011: Colomn <= 16'b0000_1000_0000_0000;
		4'b1100: Colomn <= 16'b0001_0000_0000_0000;
		4'b1101: Colomn <= 16'b0010_0000_0000_0000;
		4'b1110: Colomn <= 16'b0100_0000_0000_0000;
		4'b1111: Colomn <= 16'b1000_0000_0000_0000;
	endcase
end		


// 42K is 16 Level of Colors
/*
assign Bit2Shit_Vector = {Colomn, 	Memory[CC][17], Memory[CC][14], Memory[CC][11], Memory[CC][8], Memory[CC][5], Memory[CC][2], 2'b00,
												Memory[CC][16], Memory[CC][13], Memory[CC][10], Memory[CC][7], Memory[CC][4], Memory[CC][1], 2'b00,
												Memory[CC][15], Memory[CC][12], Memory[CC][9],  Memory[CC][6], Memory[CC][3], Memory[CC][0], 2'b00 };
*/
assign Bit2Shit_Vector = {Colomn, 	OutputRGBValue[17], OutputRGBValue[14], OutputRGBValue[11], OutputRGBValue[8], OutputRGBValue[5], OutputRGBValue[2], 2'b00,
												OutputRGBValue[16], OutputRGBValue[13], OutputRGBValue[10], OutputRGBValue[7], OutputRGBValue[4], OutputRGBValue[1], 2'b00,
												OutputRGBValue[15], OutputRGBValue[12], OutputRGBValue[9],  OutputRGBValue[6], OutputRGBValue[3], OutputRGBValue[0], 2'b00 };												

												
reg	[39:0] BitCount;
reg	[39:0] Bit2Shit;
wire	[39:0] Bit2Shit_Vector;
					
reg 	[3:0]	ST;
				
always @ (posedge Clk_i) begin
	if (Rst_i) begin
		ST <= IDLE;
		CC <= 4'b0000;
		Clk_Out <= 1'b0;
		Latch_Data <= 1'b0;
		LevelCounter <= 5'b0_0000;
	end
	else begin
	
		case (ST)
	
		IDLE: begin
			if ({ SOF_Edge, SOF_Sync } == 2'b01 ) begin
				ST <= RESET_COUNTER;
				LevelCounter <= 5'b0_0000;				
			end
			else begin
				ST <= IDLE;
				Clk_Out <= 1'b0;
				Latch_Data <= 1'b0;			
			end
		
		end
		
		RESET_COUNTER: begin
				CC <= 4'b0000;
				ST <= LOAD_VALUE;				
		end
		
		LOAD_VALUE: begin
				BitCount <= 40'hFF_FF_FF_FF_FF;
				Bit2Shit <= Bit2Shit_Vector;
				ST <= CLK0_A;				
		end
		
		// Clk 0 here
		CLK0_A: begin
			if ( BitCount ) begin
				ST <= CLK0_B;
			end
			else begin
				ST <= LATCH_DATA_A;
				
			end
		end
		
		// Clk 0 here		
		CLK0_B: begin
			Clk_Out <= 1'b1;
			ST <= CLK1_A;
		end
		
		// Clk 1 here
		CLK1_A: begin
			ST <= CLK1_B;
			
		end

		// Clk 1 Here
		CLK1_B: begin
			BitCount <= BitCount >> 1'b1;
			Bit2Shit <= Bit2Shit >> 1'b1;
			Clk_Out <= 1'b0;
			ST <= CLK0_A;			
		end		
		
		
		LATCH_DATA_A: begin
			Latch_Data <= 1'b1;
			ST <= LATCH_DATA_B;				
		end
		
		LATCH_DATA_B: begin
			Latch_Data <= 1'b0;
			TimeCount <= 16'd1250;		// 16 Scans of the 16 rows
			CC	<= CC + 4'b0001;
			ST <= TIMER_A;		
		end
		
		
		TIMER_A: begin
			if (TimeCount) begin
				TimeCount <= TimeCount - 16'h0001;
			end
			else begin
			if ( CC ) begin
					ST <= LOAD_VALUE;	
			end
			else
				begin
					LevelCounter <= LevelCounter + 5'b0_0001;
					ST <= TIMER_B;	
				end
			end		
		end
		
		// this is to integrate Gradiant in the colors a PWM so to speak
		TIMER_B: begin
			if (LevelCounter < 5'b1_0000) begin
				ST <= RESET_COUNTER;	
			end
			else begin
				ST <= IDLE;
			end		
		
		end
		
		default: begin
			ST <= IDLE;		
		end
		
		endcase
	
	end
end
					
					
					
/*
always @ (posedge Clk_i) begin

	if ( Rst_i ) begin
		STS_Clock_Out  <= 1'b0;
		STS_Latch_Out  <= 1'b0;
		STS_Value_2_Slide <= 40'h00_00_00_00_00;
		SM_Status <= 3'b000;
		Shift <= 16'h0001;
	end
	else begin
	
		case (SM_Status)
		
		3'b000: begin 
			STS_Value_2_Slide <= { Shift, 8'h80, 8'h00, 8'h80};
			STS_Clock_Out  <= 1'b0;				
			STS_Counter <= 8'd39;
			SM_Status <= 3'b001;
			TimeCount <= 16'd19530;
		end
		
		//Clock Low Here
		3'b001: begin 
			STS_Clock_Out 	<= 1'b1;			
			SM_Status 		<= 3'b010;		
		end		
		
		//Clock HIGH Here
		3'b010: begin 
			STS_Clock_Out  <= 1'b0;			
			if (STS_Counter) begin 
				STS_Counter				<= STS_Counter - 4'b0001;
				STS_Value_2_Slide  	<= STS_Value_2_Slide >> 1'b1;
				SM_Status 				<= 3'b001;
			end 
			else begin
				SM_Status 				<= 3'b011;
			
			end
		end		
		//Shift
		3'b011: begin 
			SM_Status 		<= 3'b100;
			STS_Latch_Out  <= 1'b1;
		end		
		
		3'b100: begin
			SM_Status 		<= 3'b101;
			STS_Latch_Out  <= 1'b0;
		end
		
		3'b101: begin
			SM_Status 		<= 3'b110;
		end
		
		// Count
		3'b110: begin
			if (TimeCount) begin
				TimeCount <= TimeCount - 16'h0001;
			end
			else begin
			if (Shift)
				Shift <= Shift << 1'b1;
			else
				Shift <= 16'h0001;
//				Active_Led  <= Active_Led + 3'b001;
//				PWM_Counter <= PWM_Counter + 8'h01;
			 SM_Status 		<= 3'b000;			
			end
		end
		
		default: begin
			SM_Status 		<= 3'b000;
		end

		
		
		endcase
	
	end
end
*/
endmodule

