module BEATRIX_CTRL_Reg (
input		wire				RST_i,
input		wire				CPU_Clk_i,
input 	wire	[23:0]	CPU_A_i,
input		wire	[7:0]		CPU_D8_i,
input		wire	[15:0]	CPU_D16_i,
input		wire	[31:0]	CPU_D32_i,
input		wire	[1:0]		CPU_Siz_i,
input 	wire				CPU_R_Wn_i,
input		wire				CPU_A_Valid_i,
input		wire	[3:0]		CPU_BE_i,
input		wire				CPU_WE_i, 
input		wire				CS_INT_REG_i,

// Outputs
output	wire				AMP_MUTE_o,
output	wire				AMP_SDBY_o,


output 	reg 	[31:0]	CPU_D_o
);


assign AMP_MUTE_o = ControlRegisters[0][4];
assign AMP_SDBY_o = ControlRegisters[0][5];

reg	[31:0]	ControlRegisters[0:1];

// Keep the Input Value in Registers
always @ (posedge CPU_Clk_i)
begin
	if (RST_i) begin
		ControlRegisters[0] <= 32'h0000_0000;
		ControlRegisters[1] <= 32'h0000_0000;
	end 
	else begin
		if (CS_INT_REG_i && !CPU_R_Wn_i && ( CPU_Siz_i[1:0] == 2'b00 ) && CPU_WE_i )
			ControlRegisters[CPU_A_i[2]] <= CPU_D32_i;
	end
end

always @ (*)
begin
	if ( CPU_A_i[2] ) begin
		CPU_D_o = ControlRegisters[1]; 	
	end
	else begin
		CPU_D_o = ControlRegisters[0]; 
	end
end


endmodule
