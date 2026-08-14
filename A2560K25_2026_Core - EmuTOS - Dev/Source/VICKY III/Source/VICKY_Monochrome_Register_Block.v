module Vicky_Monochrome_Register_Block (

input 	wire				Bus_Clk_i,
input 	wire	[23:0]	Bus_A_i,
input		wire  [7:0]		Bus_D_i,
input		wire				Bus_RW_i,
input		wire				CS_Vicky_Registers_i,

input		wire				VideoClk,
input		wire				VideoRst,

output	wire	[15:0]	Cursor_X_Position_o,
output   wire	[15:0]	Cursor_Y_Position_o,
output	wire	[31:0]	Cursor_Control_Reg_o		// Expanded Control register;

);

reg [2:0]		SM;
//wire			CMD_Write_Empty;
reg				Read_FIFO;
reg 	[7:0]		VICKY_TEXT_REG[0:7];
wire	[7:0]		Video_Data;
wire	[7:0]		Video_Address;
wire				RD_FIFO_Empty;

// This is 2 Transfer Requestion from 14.318Mhz Side to 40Mhz Side
BUS_2_REG40 FIFO_REG14_REG40(
	.data({Bus_D_i[7:0], Bus_A_i[7:0]}),
	.rdclk(VideoClk),
	.rdreq(Read_FIFO),
	.wrclk(!Bus_Clk_i),
	.wrreq(CS_Vicky_Registers_i & !Bus_RW_i & Bus_Clk_i & (Bus_A_i[9:3] == 7'b00_0000_1)),
	.q({Video_Data, Video_Address}),
	.rdempty(RD_FIFO_Empty),
	.wrfull()
);




always @ (posedge VideoClk)
begin
	if (VideoRst) begin
			Read_FIFO <= 1'b0;
			SM <= 3'b000;
	end
	else begin
	
		case (SM)
	
		3'b000: begin 
			if (RD_FIFO_Empty) begin
				SM <= 3'b000;				
			end
			else begin
				Read_FIFO <= 1'b1;			
				SM <= 3'b001;			
			end
		end
		
		// Wait for CMD_Write_Empty
		3'b001: begin
			Read_FIFO <= 1'b0;	
			SM <= 3'b011;	
		end
			
		// Wait for DATA_FIFO_Empty 
		3'b011: begin
			SM <= 3'b000;
		end
		
//		3'b010: begin
//			SM <= 3'b000;
//		end
	
		default: begin
			Read_FIFO <= 1'b0;
			SM <= 3'b000;
		end
	
		endcase
	
	end
end

// Writing Part
always @ (posedge VideoClk)
begin
	if (VideoRst)
	begin
		VICKY_TEXT_REG[0] <= 8'h00;
		VICKY_TEXT_REG[1] <= 8'h00; 
		VICKY_TEXT_REG[2] <= 8'h03;
		VICKY_TEXT_REG[3] <= 8'hA0; 
		VICKY_TEXT_REG[4] <= 8'h00;
		VICKY_TEXT_REG[5] <= 8'h00; 
		VICKY_TEXT_REG[6] <= 8'h0A;
		VICKY_TEXT_REG[7] <= 8'h00; 	
	end
	else
	begin
		if (Read_FIFO)
			VICKY_TEXT_REG[Video_Address[2:0]] <= Video_Data;
	end
end
/*
always @ (*)
begin
	case(Bus_A_i[2:0])
		// Unsigned Mult
		5'b00000: Bus_D_o = VICKY_TEXT_REG[0];		// VKY Master Ctrl Reg L
		5'b00001: Bus_D_o = VICKY_TEXT_REG[1];		// VKY Master Ctrl Reg H
		5'b00010: Bus_D_o = VICKY_TEXT_REG[2];		// TBD
		5'b00011: Bus_D_o = VICKY_TEXT_REG[3];		// TBD
		5'b00100: Bus_D_o = VICKY_TEXT_REG[4];		// TBD
		5'b00101: Bus_D_o = VICKY_TEXT_REG[5];		// TBD
		5'b00110: Bus_D_o = VICKY_TEXT_REG[6];		// TBD
		5'b00111: Bus_D_o = VICKY_TEXT_REG[7];		// TBD

	endcase
end
*/
assign Cursor_X_Position_o = {VICKY_TEXT_REG[5], VICKY_TEXT_REG[4]};
assign Cursor_Y_Position_o = {VICKY_TEXT_REG[7], VICKY_TEXT_REG[6]};
assign Cursor_Control_Reg_o = {VICKY_TEXT_REG[3], VICKY_TEXT_REG[2], VICKY_TEXT_REG[1], VICKY_TEXT_REG[0]};


endmodule
