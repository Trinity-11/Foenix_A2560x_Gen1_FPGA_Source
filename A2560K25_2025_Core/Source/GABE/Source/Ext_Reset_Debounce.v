`timescale 1 ps / 1 ps

module Ext_Reset_Debounce(
input					Clk14Mhz,
input 				Reset_i,
output 				Reset_o
);

wire slow_clk;
wire Q1,Q2;

clock_div u1(
	.Fast_clk(Clk14Mhz), 
	.Slow_clk(slow_clk)
);

my_dff d1(
	.DFF_CLOCK(slow_clk), 
	.D(Reset_i),
	.Q(Q1)
);

my_dff d2(
	.DFF_CLOCK(slow_clk), 
	.D(Q1),
	.Q(Q2)
);

assign Reset_o = Q1 &  ~Q2;

endmodule


// Slow clock for debouncing 
module clock_div(
input 			Fast_clk, 
output reg 		Slow_clk
);
    
reg [26:0]counter=0;
always @(posedge Fast_clk)
begin
	counter <= (counter >= 27'd249999) ? 0 : counter + 27'd1;
   Slow_clk <= (counter < 125000) ? 1'b0 : 1'b1;
end

endmodule
// D-flip-flop for debouncing module 
module my_dff(
input 			DFF_CLOCK, 
input				D, 
output reg 		Q
);

    always @ (posedge DFF_CLOCK) begin
        Q <= D;
    end

endmodule

