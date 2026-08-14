
`timescale 1 ns / 1 ns
module CODEC_Interface (

input		wire				BUS_Rst_i,
input		wire				BUS_Clk_i,
input		wire				Clk_358MHz_i,

input		wire	[23:0]	BUS_A_i,
input 	wire	[7:0]		BUS_Data_i,
input		wire				BUS_RW_i,
input		wire				CS_CODEC_i,

output	wire			   BTX_CODEC_CL_o,
output	wire			   BTX_CODEC_DI_o,
output	wire			   BTX_CODEC_CE_o,

output	wire				CODEC_Ready_o,			// Bit Indicate that Transfer is done
output	wire	[2:0]		StateMachine,
output	wire	[3:0]		Debug_o,
output	wire	[15:0]	Debug_CR

);


wire CS_WR00;
wire CS_WR01;
wire CS_WR10;
wire CS_WR11;

assign CS_WR00 = CS_CODEC_i & !BUS_RW_i & !BUS_A_i[1] & !BUS_A_i[0] & BUS_Clk_i;
assign CS_WR01 = CS_CODEC_i & !BUS_RW_i & !BUS_A_i[1] &  BUS_A_i[0] & BUS_Clk_i;
assign CS_WR10 = CS_CODEC_i & !BUS_RW_i &  BUS_A_i[1] & !BUS_A_i[0] & BUS_Clk_i;
assign CS_WR11 = CS_CODEC_i & !BUS_RW_i &  BUS_A_i[1] &  BUS_A_i[0] & BUS_Clk_i;
assign Debug_o = {CS_WR11, CS_WR10, CS_WR01, CS_WR00};

reg	[15:0]		CR;
assign Debug_CR = CR;

always @ (negedge BUS_Clk_i)
begin
	if (BUS_Rst_i) begin
		CR[15:0] <= 16'b0000_0000_0000_0000;
	end
	else begin
		if (CS_WR00)
			CR[7:0] <= BUS_Data_i;
		if (CS_WR01)
			CR[15:8] <= BUS_Data_i;
	end
end

reg	[35:0]	REG_CE;
reg	[35:0]	REG_CL;
reg	[35:0]	REG_DI;
reg	[35:0]	REG_BSY;

initial begin
		REG_DI  = 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_CL  = 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_CE  = 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_BSY = 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
end


assign BTX_CODEC_CL_o = REG_CL[35];
assign BTX_CODEC_DI_o = REG_DI[35];
assign BTX_CODEC_CE_o = !REG_CE[35];
assign CODEC_Ready_o  = REG_BSY[35];

assign StateMachine = SM;

reg	[2:0]	SM;

reg	[7:0] Slider;

always @ (negedge BUS_Clk_i)
begin
	Slider <= Slider << 1'b1;
	
	if (CS_WR10)
		Slider <= 8'hFF;
end


localparam			IDLE 		= 3'b000,
						LOAD		= 3'b001,
						WAIT		= 3'b010,
						END		= 3'b011;

always @ (posedge Clk_358MHz_i)
begin
	if (BUS_Rst_i) begin
		SM <= IDLE;
		REG_DI  <= 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_CL  <= 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_CE  <= 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_BSY <= 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		
	end
	else begin
	
			REG_DI  <= REG_DI  << 1'b1;
			REG_CL  <= REG_CL  << 1'b1;
			REG_CE  <= REG_CE  << 1'b1;
			REG_BSY <= REG_BSY << 1'b1;	
	
		if (Slider[7:4] == 4'b1111) begin
			REG_BSY <= 36'b1111_1111_1111_1111_1111_1111_1111_1111_1111;		
			REG_CE  <= 36'b0000_0000_0000_0000_0000_0000_0000_0000_0010;
			REG_CL  <= 36'b0001_0101_0101_0101_0101_0101_0101_0101_0100;
			REG_DI  <= {2'b00, 	CR[15], CR[15], CR[14], CR[14], CR[13], CR[13], CR[12], CR[12], CR[11], CR[11], CR[10], CR[10], CR[9], CR[9], CR[8], CR[8],
										CR[7],  CR[7], CR[6], CR[6], CR[5], CR[5], CR[4], CR[4], CR[3], CR[3], CR[2], CR[2], CR[1], CR[1], CR[0], CR[0], 2'b00};		
		
		end
	end
end


endmodule

