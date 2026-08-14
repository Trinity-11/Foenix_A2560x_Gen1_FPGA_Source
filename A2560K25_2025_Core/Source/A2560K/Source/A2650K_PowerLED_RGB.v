module A2650K_PowerLED_RGB(



input	wire				Reset_i,
input	wire				Clk_i,

input	wire	[7:0]		Blue_i,
input	wire	[7:0]		Green_i,
input	wire	[7:0]		Red_i,

input	wire				Enable_i,


output					PowerLed_o
);


// T Period minimum is 1.2us
//                             Min - Standard - Max
// T0H 0 code, high level time 0.2 0.32 0.4 µs
// T0L 0 code, low level time 0.8 -- -- µs
// T1H 1 code, high level time 0.58 0.64 1.0 µs
// T1L 1 code, low level time 0.2 -- -- µs
// Trst Reset code，low level time >80µs

// to Create a Zero - HIGH for 0.32us and LOW for 1us
// to Create a One - High for 0.64us and LOW for 0.64us

endmodule

