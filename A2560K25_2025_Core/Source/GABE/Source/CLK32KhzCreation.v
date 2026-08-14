
`timescale 1ns/1ns

module CLK32KhzCreation (
input 	wire 			Clk14Mhz_i,
output 	reg		 Clk32Khz_o
);

wire	[7:0]	CounterOut;

//Modulo 218 
CLK32_COUNTER CLK32COUNT(
	.clock(Clk14Mhz_i),
	.q(CounterOut)
);

always @ (posedge Clk14Mhz_i)
begin
	if (CounterOut == 8'h00)
		Clk32Khz_o <= Clk32Khz_o ^ 1'b1;
end

endmodule


 