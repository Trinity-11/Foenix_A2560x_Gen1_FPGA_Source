
module TinyChipScope (
	acq_clk,
	acq_data_in,
	acq_trigger_in,
	trigger_in);	

	input		acq_clk;
	input	[143:0]	acq_data_in;
	input	[0:0]	acq_trigger_in;
	input		trigger_in;
endmodule
