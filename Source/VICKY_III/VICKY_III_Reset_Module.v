module VICKY_III_Reset_Module(

input		wire			Ext_Reset_i,

input		wire			Clk_100M_i,
input		wire			Clk_200M_i,
input		wire			VideoClk_i,
input		wire			VideoClk_Full_Resolution_i,

input		wire			VideoModeReset_i,

output	wire 			Reset_100Mhz_o,
output	wire 			Reset_200Mhz_o,
output	wire 			Reset_VideoClkOut_o,
output	wire 			Reset_VideoClk_Full_Resolution_o,

output	reg			VideoModeReset_100Mhz_o,
output	reg			VideoModeReset_200Mhz_o
);

reg [1:0]	VideoModeReset_100Mhz_Meta;

reg VideoModeReset;
always @ (posedge VideoClk_i) begin
		VideoModeReset <= VideoModeReset_i;

end


always @ (posedge Clk_100M_i) begin

		VideoModeReset_100Mhz_Meta[0] <= VideoModeReset;
		VideoModeReset_100Mhz_Meta[1] <= VideoModeReset_100Mhz_Meta[0];
			if ( VideoModeReset_100Mhz_Meta[1] == VideoModeReset_100Mhz_Meta[0]) 
				VideoModeReset_100Mhz_o <= VideoModeReset_100Mhz_Meta[1];
end

reg [1:0]	VideoModeReset_200Mhz_Meta;

always @ (posedge Clk_200M_i) begin

		VideoModeReset_200Mhz_Meta[0] <= VideoModeReset;
		VideoModeReset_200Mhz_Meta[1] <= VideoModeReset_200Mhz_Meta[0];
			if ( VideoModeReset_200Mhz_Meta[1] == VideoModeReset_200Mhz_Meta[0]) 
				VideoModeReset_200Mhz_o <= VideoModeReset_200Mhz_Meta[1];
end

//Ext_Reset_i

reg [2:0] Ext_Reset_100Mhz;

wire Reset_100Mhz;
wire Reset_200Mhz;
wire Reset_VideoClkOut;
wire Reset_VideoClk_Full_Resolution;

assign Reset_100Mhz_o = Ext_Reset_100Mhz[2];
assign Reset_200Mhz_o = Ext_Reset_200Mhz[2];
assign Reset_VideoClkOut_o = Ext_Reset_VideoClkOut[2];
assign Reset_VideoClk_Full_Resolution_o = Ext_Reset_VideoClk_Full_Resolution[2];

always @ (posedge Clk_100M_i) begin
	Ext_Reset_100Mhz[0] <= Ext_Reset_i;
	Ext_Reset_100Mhz[1] <= Ext_Reset_100Mhz[0];
	if ( Ext_Reset_100Mhz[1] == Ext_Reset_100Mhz[0] ) begin
		Ext_Reset_100Mhz[2] <= Ext_Reset_100Mhz[1];
	end
end


reg [2:0] Ext_Reset_200Mhz;
always @ (posedge Clk_200M_i) begin
	Ext_Reset_200Mhz[0] <= Ext_Reset_i;
	Ext_Reset_200Mhz[1] <= Ext_Reset_200Mhz[0];
	if ( Ext_Reset_200Mhz[1] == Ext_Reset_200Mhz[0] ) begin
		Ext_Reset_200Mhz[2] <= Ext_Reset_200Mhz[1];
	end
end

reg [2:0] Ext_Reset_VideoClkOut;
always @ (posedge VideoClk_i) begin
	Ext_Reset_VideoClkOut[0] <= Ext_Reset_i;
	Ext_Reset_VideoClkOut[1] <= Ext_Reset_VideoClkOut[0];
	if ( Ext_Reset_VideoClkOut[1] == Ext_Reset_VideoClkOut[0] ) begin
		Ext_Reset_VideoClkOut[2] <= Ext_Reset_VideoClkOut[1];
	end
end


reg [2:0] Ext_Reset_VideoClk_Full_Resolution;
always @ (posedge VideoClk_Full_Resolution_i) begin
	Ext_Reset_VideoClk_Full_Resolution[0] <= Ext_Reset_i;
	Ext_Reset_VideoClk_Full_Resolution[1] <= Ext_Reset_VideoClk_Full_Resolution[0];
	if ( Ext_Reset_VideoClk_Full_Resolution[1] == Ext_Reset_VideoClk_Full_Resolution[0] ) begin
		Ext_Reset_VideoClk_Full_Resolution[2] <= Ext_Reset_VideoClk_Full_Resolution[1];
	end
end


endmodule

