`timescale 1 ps / 1 ps

module Math_Module16 (

// CPU Signals Interface
input		wire				CPU_Clk_i,
input		wire	[31:0]	iBUS_A_i,
input		wire				iBUS_A_Valid_i,
input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]	iBUS_D16_i,
input		wire	[31:0]	iBUS_D32_i,
input		wire	[1:0]		iBUS_D_Siz_i,
input		wire				iBUS_RWn_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i, 

input		wire				CS_MATH_FIXED_i,

output	reg	[31:0]	iBUS_D_FixedMATH_o
);

reg [31:0] iBUS_A_ReSync;
reg [31:0] iBUS_D32_ReSync;
reg 		  iBUS_RWn_ReSync;
reg		  iBUS_WE_ReSync;
reg		  CS_MATH_FIXED_ReSync;
always @ (posedge CPU_Clk_i)
begin
	CS_MATH_FIXED_ReSync <= CS_MATH_FIXED_i;
	iBUS_A_ReSync <= iBUS_A_i;
	iBUS_D32_ReSync <= iBUS_D32_i;
	iBUS_RWn_ReSync <= iBUS_RWn_i;
	iBUS_WE_ReSync <= iBUS_WE_i;
end



reg   [31:0] 	Fixed_Math_Para[15:0];

wire	[63:0]	UnsignedMultOutput;
wire	[63:0]	SignedMultOutput;

wire	[31:0]	UnsignedDivisionQuotient;
wire	[31:0]	UnsignedDivisionremain;

wire	[31:0]	SignedDivisionQuotient;
wire	[31:0]	SignedDivisionremain;

// Keep the Input Value in Registers
always @ (posedge CPU_Clk_i)
begin
	if (CS_MATH_FIXED_ReSync && !iBUS_RWn_ReSync && iBUS_WE_ReSync )
		Fixed_Math_Para[iBUS_A_ReSync[5:2]] <= iBUS_D32_ReSync;
end

UNSIGNED_MULT16 UNSIGNEDMULT(
	.clock( CPU_Clk_i ),
	.dataa(Fixed_Math_Para[0]),
	.datab(Fixed_Math_Para[1]),
	.result(UnsignedMultOutput)
);


SIGNED_MULT16 SIGNEDMULT(
	.clock( CPU_Clk_i ),
	.dataa(Fixed_Math_Para[4]),
	.datab(Fixed_Math_Para[5]),
	.result(SignedMultOutput)
);



UNSIGNED_DIV16 UNSIGNEDDIV(
	.clock( CPU_Clk_i ),
	.denom(Fixed_Math_Para[8]),
	.numer(Fixed_Math_Para[9]),
	.quotient(UnsignedDivisionQuotient),
	.remain(UnsignedDivisionremain)
);

SIGNED_DIV16 SIGNEDDIV(
//	.clock( CPU_2xClk_i ),
	.clock( CPU_Clk_i ),
	.denom(Fixed_Math_Para[12]),
	.numer(Fixed_Math_Para[13]),
	.quotient(SignedDivisionQuotient),
	.remain(SignedDivisionremain)
);

always @ (*)
begin
	case(iBUS_A_i[5:2])
		// Unsigned Mult
		4'b0000: iBUS_D_FixedMATH_o = Fixed_Math_Para[0];
		4'b0001: iBUS_D_FixedMATH_o = Fixed_Math_Para[1];
		4'b0010: iBUS_D_FixedMATH_o = UnsignedMultOutput[31:0]; 
		4'b0011: iBUS_D_FixedMATH_o = UnsignedMultOutput[63:32];
		// Signed Mult
		4'b0100: iBUS_D_FixedMATH_o = Fixed_Math_Para[4];
		4'b0101: iBUS_D_FixedMATH_o = Fixed_Math_Para[5];
		4'b0110: iBUS_D_FixedMATH_o = SignedMultOutput[31:0];
		4'b0111: iBUS_D_FixedMATH_o = SignedMultOutput[63:32];
		// Unsigned Div
		4'b1000: iBUS_D_FixedMATH_o = Fixed_Math_Para[8];
		4'b1001: iBUS_D_FixedMATH_o = Fixed_Math_Para[9];
		4'b1010: iBUS_D_FixedMATH_o = UnsignedDivisionQuotient[31:0];
		4'b1011: iBUS_D_FixedMATH_o = UnsignedDivisionremain[31:0];
		// Signed Div
		4'b1100: iBUS_D_FixedMATH_o = Fixed_Math_Para[12];
		4'b1101: iBUS_D_FixedMATH_o = Fixed_Math_Para[13];
		4'b1110: iBUS_D_FixedMATH_o = SignedDivisionQuotient[31:0];
		4'b1111: iBUS_D_FixedMATH_o = SignedDivisionremain[31:0];
	endcase
end

endmodule

