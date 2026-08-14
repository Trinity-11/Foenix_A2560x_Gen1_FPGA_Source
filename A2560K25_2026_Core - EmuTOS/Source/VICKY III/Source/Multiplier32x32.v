`timescale 1 ns / 1 ns
module Multiplier_32x32(

input 	wire				rst_i,				// This is async Reset
// CPU Signals Interface
input 	wire				Bus_Clk_i,
input 	wire	[9:0]		Bus_A_i,
input		wire  [7:0]		Bus_D_i,
output 	reg	[7:0]		Bus_D_o,
input		wire				Bus_RW_i,
input		wire				Multiplier32x32_CS_i
);


reg [7:0]		MUX_REG_A[0:3];
reg [7:0]		MUX_REG_B[0:3];


//assign Bus_D_o = VICKY_MASTER_REG[Bus_A_i[4:0]];

// Writing Part
always @ (negedge Bus_Clk_i)
begin
	if (rst_i)
	begin
	// Multiplier A
		MUX_REG_A[0] <= 8'h00;
		MUX_REG_A[1] <= 8'h00;
		MUX_REG_A[2] <= 8'h00;
		MUX_REG_A[3] <= 8'h00;
	// Multiplier B
		MUX_REG_B[0] <= 8'h00;		// Check Vicky_Monochrome_Text_Block for Capture of that DATA.
		MUX_REG_B[1] <= 8'h00;
		MUX_REG_B[2] <= 8'h00;
		MUX_REG_B[3] <= 8'h00;
	end
	else
	begin
		if (Multiplier32x32_CS_i & !Bus_RW_i) begin
			if (Bus_A_i[2])
				MUX_REG_B[Bus_A_i[1:0]] <= Bus_D_i;
				else
				MUX_REG_A[Bus_A_i[1:0]] <= Bus_D_i;
		end
	end
end

wire [63:0] Mux_Output;

Multiplier32x32	Multiplier32x32_inst (
	.dataa ( {MUX_REG_A[3], MUX_REG_A[2], MUX_REG_A[1], MUX_REG_A[0]} ),
	.datab ( {MUX_REG_B[3], MUX_REG_B[2], MUX_REG_B[1], MUX_REG_B[0]} ),
	.result ( Mux_Output )
	);

always @ (*)
begin
	case(Bus_A_i[3:0])
		4'b0000: Bus_D_o = MUX_REG_A[0];		//
		4'b0001: Bus_D_o = MUX_REG_A[1];		//
		4'b0010: Bus_D_o = MUX_REG_A[2];		//
		4'b0011: Bus_D_o = MUX_REG_A[3];		//
		4'b0100: Bus_D_o = MUX_REG_B[0];		//
		4'b0101: Bus_D_o = MUX_REG_B[1];		//
		4'b0110: Bus_D_o = MUX_REG_B[2];		//
		4'b0111: Bus_D_o = MUX_REG_B[3];		//
		4'b1000: Bus_D_o = Mux_Output[0];	//
		4'b1001: Bus_D_o = Mux_Output[1];	//
		4'b1010: Bus_D_o = Mux_Output[2];	//
		4'b1011: Bus_D_o = Mux_Output[3];	//
		4'b1100: Bus_D_o = Mux_Output[4];	//
		4'b1101: Bus_D_o = Mux_Output[5];	//
		4'b1110: Bus_D_o = Mux_Output[6];	//
		4'b1111: Bus_D_o = Mux_Output[7];	//
	endcase
end
	
	
endmodule
