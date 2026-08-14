`timescale 1 ps / 1 ps

module FP_MATH_Module(
input		wire				RST_i,
//input		wire				FP_Clk_i,		// 6x CPU Clock Speed
input		wire				CPU_Clk_i,
input 	wire	[23:0]	CPU_A_i,
input 	wire	[7:0]		CPU_D_i,
input 	wire				CPU_R_Wn_i,
input		wire				CS_MATH_FLOAT_i,
output 	reg 	[7:0]		CPU_D_o
);
//$AF:E200..$AF:E2FF <- Registers

reg	[7:0]	FP_MATH_CTRL[0:3];

reg	[31:0]	UserInput0;
reg	[31:0]	UserInput1;

//reg	[31:0]	UserOutput_FP;
//reg	[31:0]	UserOutput_Fixed;

//reg	[31:0]	MAC_Register;

wire FP_Mult_Status_NaN;
wire FP_Mult_Status_overflow;
wire FP_Mult_Status_underflow;
wire FP_Mult_Status_zero;
wire [31:0]	FP_Mult_Output;	
wire FP_Div_Status_NaN;
wire FP_Div_Status_overflow;
wire FP_Div_Status_underflow;
wire FP_Div_Status_zero;
wire FP_Div_Status_DivideByZero;
wire [31:0]	FP_Div_Output;
wire FP_Add_Status_NaN;
wire FP_Add_Status_overflow;
wire FP_Add_Status_underflow;
wire FP_Add_Status_zero;
wire [31:0]	FP_Add_Output;
wire FP_Converter_Status_NaN;
wire FP_Converter_Status_overflow;
wire FP_Converter_Status_underflow;
wire [31:0]	Fixed_Converter_Output;	



// Keep the Input Value in Registers
always @ (negedge CPU_Clk_i)
begin
	if (RST_i) begin
		FP_MATH_CTRL[0] <= 8'h01;
		FP_MATH_CTRL[1] <= 8'h00;
		FP_MATH_CTRL[2] <= 8'h00;
		FP_MATH_CTRL[3] <= 8'h00;	
	end 
	else begin
		if (CS_MATH_FLOAT_i & !CPU_R_Wn_i) begin
			case (CPU_A_i[3:0])
			4'b0000: FP_MATH_CTRL[0] <= CPU_D_i;
			4'b0001: FP_MATH_CTRL[1] <= CPU_D_i; // Mux Control for Input
			4'b0010: FP_MATH_CTRL[2] <= CPU_D_i;
			4'b0011: FP_MATH_CTRL[3] <= CPU_D_i;
			//4'b0100: FP_MATH_CTRL[4] <= CPU_D_i;
			//4'b0101: FP_MATH_CTRL[5] <= CPU_D_i;
			//4'b0110: FP_MATH_CTRL[6] <= CPU_D_i;
			//4'b0111: FP_MATH_CTRL[7] <= CPU_D_i;
			4'b1000: UserInput0[7:0] 	<= CPU_D_i;
			4'b1001: UserInput0[15:8] 	<= CPU_D_i;
			4'b1010: UserInput0[23:16] <= CPU_D_i;
			4'b1011: UserInput0[31:24] <= CPU_D_i;
			4'b1100: UserInput1[7:0] 	<= CPU_D_i;
			4'b1101: UserInput1[15:8] 	<= CPU_D_i;
			4'b1110: UserInput1[23:16] <= CPU_D_i;
			4'b1111: UserInput1[31:24] <= CPU_D_i;	
			//default: begin end;
			endcase 
		end
	end
end

wire [31:0]	Converter_Output_A;
wire [31:0]	Converter_Output_B;

wire [31:0] Converter0_Output_MUX;
wire [31:0] Converter1_Output_MUX;
/*
reg	[31:0]	ReSync_Data_Input0[0:1];
reg	[31:0]	ReSync_Data_Input1[0:1];
reg	[31:0]	ReSync_Data_Output0[0:1];
reg	[31:0]	ReSync_Data_Output1[0:1];

always @ (posedge FP_Clk_i)
begin
	ReSync_Data_Input0[0] <= UserInput0[31:0];
	ReSync_Data_Input0[1] <= ReSync_Data_Input0[0];

	ReSync_Data_Input1[0] <= UserInput1[31:0];
	ReSync_Data_Input1[1] <= ReSync_Data_Input1[0];

	
end
*/

Converter_20I12F_2_FP	Converter_20I12F_2_FP_inst0 (
	.clock ( CPU_Clk_i ),
	.dataa ( UserInput0 ),
	.result ( Converter_Output_A )
	);

assign 	Converter0_Output_MUX = FP_MATH_CTRL[0][0] ? Converter_Output_A : UserInput0;	
	
Converter_20I12F_2_FP	Converter_20I12F_2_FP_inst1 (
	.clock ( CPU_Clk_i ),
	.dataa ( UserInput1 ),
	.result ( Converter_Output_B )
	);

assign 	Converter1_Output_MUX = FP_MATH_CTRL[0][1] ? Converter_Output_B : UserInput1;		

FP_Mult	FP_Mult_inst0 (
	.clock ( CPU_Clk_i ),
	.dataa ( Converter0_Output_MUX ),
	.datab ( Converter1_Output_MUX ),
	.nan ( FP_Mult_Status_NaN ),	
	.overflow ( FP_Mult_Status_overflow ),
	.result ( FP_Mult_Output ),
	.underflow ( FP_Mult_Status_underflow ),
	.zero ( FP_Mult_Status_zero )
	);

FPDiv	FPDiv_inst0 (
	.clock ( CPU_Clk_i ),
	.dataa ( Converter0_Output_MUX ),
	.datab ( Converter1_Output_MUX ),
	.division_by_zero ( FP_Div_Status_DivideByZero ),
	.nan ( FP_Div_Status_NaN ),
	.overflow ( FP_Div_Status_overflow ),
	.result ( FP_Div_Output ),
	.underflow ( FP_Div_Status_underflow ),
	.zero ( FP_Div_Status_zero )
	);	
	
reg [31:0] FP_ADD_SUB_INPUT0_MUX;
reg [31:0] FP_ADD_SUB_INPUT1_MUX;

always @ (*)
begin
	case (FP_MATH_CTRL[0][5:4])
	2'b00: FP_ADD_SUB_INPUT0_MUX = Converter0_Output_MUX;
	2'b01: FP_ADD_SUB_INPUT0_MUX = Converter1_Output_MUX;
	2'b10: FP_ADD_SUB_INPUT0_MUX = FP_Mult_Output;
	2'b11: FP_ADD_SUB_INPUT0_MUX = FP_Div_Output;
	default: FP_ADD_SUB_INPUT0_MUX = 32'h3f800000;	// Force the FP value of 1 if all else fails
	endcase

end

always @ (*)
begin
	case (FP_MATH_CTRL[0][7:6])
	2'b00: FP_ADD_SUB_INPUT1_MUX = Converter0_Output_MUX;
	2'b01: FP_ADD_SUB_INPUT1_MUX = Converter1_Output_MUX;
	2'b10: FP_ADD_SUB_INPUT1_MUX = FP_Mult_Output;
	2'b11: FP_ADD_SUB_INPUT1_MUX = FP_Div_Output;
	default: FP_ADD_SUB_INPUT1_MUX = 32'h3f800000;	// Force the FP value of 1 if all else fails
	endcase
end



FP_ADD	FP_ADD_inst (
	.add_sub ( FP_MATH_CTRL[0][3] ),
	.clock ( CPU_Clk_i ),
	.dataa ( FP_ADD_SUB_INPUT0_MUX ),
	.datab ( FP_ADD_SUB_INPUT1_MUX ),
	.nan ( FP_Add_Status_NaN ),
	.overflow ( FP_Add_Status_overflow ),
	.result ( FP_Add_Output ),
	.underflow ( FP_Add_Status_underflow ),
	.zero ( FP_Add_Status_zero )
	);

reg [31:0] FP_ADD_SUB_OUTPUT_MUX;
	
always @ (*)
begin
	case (FP_MATH_CTRL[1][1:0])
	2'b00: FP_ADD_SUB_OUTPUT_MUX = FP_Mult_Output;
	2'b01: FP_ADD_SUB_OUTPUT_MUX = FP_Div_Output;
	2'b10: FP_ADD_SUB_OUTPUT_MUX = FP_Add_Output;
	2'b11: FP_ADD_SUB_OUTPUT_MUX = 32'h3f800000;
	default: FP_ADD_SUB_OUTPUT_MUX = 32'h3f800000;	// Force the FP value of 1 if all else fails
	endcase
end


Converter_FP_2_20I12F	Converter_FP_2_20I12F_inst (
	.clock ( CPU_Clk_i ),
	.dataa ( FP_ADD_SUB_OUTPUT_MUX ),
	.nan ( FP_Converter_Status_NaN ),
	.overflow ( FP_Converter_Status_overflow ),
	.result ( Fixed_Converter_Output ),
	.underflow ( FP_Converter_Status_underflow )
	);

/*
always @ (negedge CPU_Clk_i) begin
		ReSync_Data_Output0[0] <= FP_ADD_SUB_OUTPUT_MUX;
		ReSync_Data_Output0[1] <= ReSync_Data_Output0[0];
		ReSync_Data_Output1[0] <= Fixed_Converter_Output;
		ReSync_Data_Output1[1] <= ReSync_Data_Output1[0];
end
*/	
	
always @ (*)
begin
	case(CPU_A_i[3:0])
		4'b0000: CPU_D_o = FP_MATH_CTRL[0];
		4'b0001: CPU_D_o = FP_MATH_CTRL[1];
		4'b0010: CPU_D_o = FP_MATH_CTRL[2];
		4'b0011: CPU_D_o = FP_MATH_CTRL[3];
		4'b0100: CPU_D_o = { 4'b0000, FP_Mult_Status_zero, FP_Mult_Status_underflow, FP_Mult_Status_overflow, FP_Mult_Status_NaN};
		4'b0101: CPU_D_o = { 3'b000, FP_Div_Status_DivideByZero, FP_Div_Status_zero, FP_Div_Status_underflow, FP_Div_Status_overflow, FP_Div_Status_NaN};
		4'b0110: CPU_D_o = { 4'b0000, FP_Add_Status_zero, FP_Add_Status_underflow, FP_Add_Status_overflow, FP_Add_Status_NaN};
		4'b0111: CPU_D_o = { 5'b0000_0, FP_Converter_Status_underflow, FP_Converter_Status_overflow, FP_Converter_Status_NaN};
		4'b1000: CPU_D_o = FP_ADD_SUB_OUTPUT_MUX[7:0];
		4'b1001: CPU_D_o = FP_ADD_SUB_OUTPUT_MUX[15:8];
		4'b1010: CPU_D_o = FP_ADD_SUB_OUTPUT_MUX[23:16];
		4'b1011: CPU_D_o = FP_ADD_SUB_OUTPUT_MUX[31:24];
		4'b1100: CPU_D_o = Fixed_Converter_Output[7:0];
		4'b1101: CPU_D_o = Fixed_Converter_Output[15:8];
		4'b1110: CPU_D_o = Fixed_Converter_Output[23:16];
		4'b1111: CPU_D_o = Fixed_Converter_Output[31:24];
		default: CPU_D_o = 8'hFF;
	endcase
end

endmodule


