`timescale 1ns / 1ps
module GraphicOutputMixer (

// CPU Interface
input		wire				CPU_Clk_i,

input		wire	[7:0]		CPU_D8_i,
input		wire	[15:0]	CPU_D16_i,
input		wire	[31:0]	CPU_D32_i,
input		wire	[1:0]		CPU_D_Siz_i,
input		wire	[31:0]	CPU_Addy_i,
input		wire				CPU_A_Valid_i,
input		wire				CPU_RWn_i,
input		wire	[3:0]		CPU_BE_i,
input		wire				CPU_WE_i, 
input		wire				CS_GAMMA_B_i,
input		wire				CS_GAMMA_G_i,
input		wire				CS_GAMMA_R_i,

input		wire				GAMMA_Enable_i,
input		wire				Text_Mode_Enable_i,
input		wire				Text_Overlay_Enable_i,
input		wire				Graphic_Mode_Enable_i,

output	wire	[31:0]	DataOut_GAMMA_B_o,
output	wire	[31:0]	DataOut_GAMMA_G_o,
output	wire	[31:0]	DataOut_GAMMA_R_o,

input		wire				Turn_Off_Sync_i,

// Video Interface
input		wire 				Video_Clk_i,

// Border Color
input		wire	[7:0]		Border_Blue_i,
input		wire	[7:0]		Border_Green_i,
input		wire	[7:0]		Border_Red_i,
input		wire				Border_Horizontal_i,
input		wire				Border_Vertical_i,

// FONT Color
input		wire				FONT_Mono_i,
input		wire	[7:0]		FONT_Blue_i,
input		wire	[7:0]		FONT_Green_i,
input		wire	[7:0]		FONT_Red_i,

// Mouse Color
input		wire	[31:0]	Mouse_Full_RGB_i,

// VGE Color
input		wire	[7:0]		VGE_Blue_i,
input		wire	[7:0]		VGE_Green_i,
input		wire	[7:0]		VGE_Red_i,

// Timing Generator
input		wire				HSync_i,
input		wire				VSync_i,
input		wire				HSync_Pol_i,
input		wire				VSync_Pol_i,
input		wire				HBlanking_i,
input		wire				VBlanking_i,

// DAC Output Signals
output	wire	[11:0]	VID_PIXEL_o, 
output	wire				VID_DE_o,
output	wire				VID_HSYNC_o,
output	wire				VID_VSYNC_o
);

///////////////////////////////////
// Wire
///////////////////////////////////
wire	[23:0] 	GAMMA_RGB;
reg 	[23:0] 	RGB_Pointer;

wire	[7:0]		Pixel_Gamma_B_Out;
wire	[7:0]		Pixel_Gamma_G_Out;
wire	[7:0]		Pixel_Gamma_R_Out;


///////////////////////////////////
// Regs
///////////////////////////////////
reg 	[23:0] 	GAMMA_RGB_RESYNC0;
reg 	[23:0] 	GAMMA_RGB_RESYNC1;
reg 	[5:0]  	VID_HSYNC_RESYNC;
reg 	[5:0]  	VID_VSYNC_RESYNC;
reg 	[5:0]  	VID_DE_RESYNC;
reg	[23:0]	RGB;
reg	[7:0]		No_Gamma_Blu_Dly;
reg	[7:0]		No_Gamma_Grn_Dly;
reg	[7:0]		No_Gamma_Red_Dly;

reg	[7:0]		No_Gamma_Blu_Dly0;
reg	[7:0]		No_Gamma_Grn_Dly0;
reg	[7:0]		No_Gamma_Red_Dly0;

///////////////////////////////////
// Assign
///////////////////////////////////
assign	VID_DE_o     	= VID_DE_RESYNC[5] & Turn_Off_Sync_i;
assign 	VID_HSYNC_o  	= VID_HSYNC_RESYNC[5] & Turn_Off_Sync_i;
assign	VID_VSYNC_o  	= VID_VSYNC_RESYNC[5] & Turn_Off_Sync_i;

DDR_Pixel_Out	DDR_Pixel_Buffer (
	.datain_h ( GAMMA_RGB_RESYNC1[11:0] ),
	.datain_l ( GAMMA_RGB_RESYNC1[23:12] ),
	.outclock ( Video_Clk_i ),
	.dataout ( VID_PIXEL_o )
);

wire  [7:0] DataOut_GAMMA_B;
wire  [7:0] DataOut_GAMMA_G;
wire  [7:0] DataOut_GAMMA_R;

assign DataOut_GAMMA_B_o = { DataOut_GAMMA_B, DataOut_GAMMA_B, DataOut_GAMMA_B, DataOut_GAMMA_B };
assign DataOut_GAMMA_G_o = { DataOut_GAMMA_G, DataOut_GAMMA_G, DataOut_GAMMA_G, DataOut_GAMMA_G };
assign DataOut_GAMMA_R_o = { DataOut_GAMMA_R, DataOut_GAMMA_R, DataOut_GAMMA_R, DataOut_GAMMA_R };

//assign VID_PIXEL_o = GAMMA_RGB_RESYNC1[23:0];


/*
wire 	[127:0]		CS;
wire					Trigger_In;

//assign Trigger_In = Txf_Done;
assign Trigger_In = VID_DE_o;


assign CS[11:00] 	= GAMMA_RGB_RESYNC1;
assign CS[23:12] 	= GAMMA_RGB_RESYNC1;
assign CS[24] 	= VID_DE_o;
assign CS[25] 	= VID_HSYNC_o;
assign CS[26] 	= VID_VSYNC_o;
assign CS[127:27]		= 0;

ChipScope u0 (
	.acq_data_in    (CS),    //        tap.acq_data_in
	.acq_trigger_in (Trigger_In), //           .acq_trigger_in
	.acq_clk        (Video_Clk_i),        //    acq_clk.clk
	.trigger_in     (Trigger_In)      // trigger_in.trigger_in
);
*/
always @ (posedge Video_Clk_i) begin
	GAMMA_RGB_RESYNC0 <= GAMMA_RGB;
	GAMMA_RGB_RESYNC1 <= GAMMA_RGB_RESYNC0;
	
	VID_HSYNC_RESYNC[0]  <= HSync_Pol_i ? HSync_i : !HSync_i;
	VID_HSYNC_RESYNC[1]  <= VID_HSYNC_RESYNC[0];
	VID_HSYNC_RESYNC[2]  <= VID_HSYNC_RESYNC[1];
	VID_HSYNC_RESYNC[3]  <= VID_HSYNC_RESYNC[2];	
	VID_HSYNC_RESYNC[4]  <= VID_HSYNC_RESYNC[3];	
	VID_HSYNC_RESYNC[5]  <= VID_HSYNC_RESYNC[4];		
	
	VID_VSYNC_RESYNC[0]  <= VSync_Pol_i ? VSync_i : !VSync_i;
	VID_VSYNC_RESYNC[1]  <= VID_VSYNC_RESYNC[0];
	VID_VSYNC_RESYNC[2]  <= VID_VSYNC_RESYNC[1];	
	VID_VSYNC_RESYNC[3]  <= VID_VSYNC_RESYNC[2];	
	VID_VSYNC_RESYNC[4]  <= VID_VSYNC_RESYNC[3];		
	VID_VSYNC_RESYNC[5]  <= VID_VSYNC_RESYNC[4];
	
	VID_DE_RESYNC[0]  <= HBlanking_i & VBlanking_i;
	VID_DE_RESYNC[1]  <= VID_DE_RESYNC[0];
	VID_DE_RESYNC[2]  <= VID_DE_RESYNC[1];	
	VID_DE_RESYNC[3]  <= VID_DE_RESYNC[2];	
	VID_DE_RESYNC[4]  <= VID_DE_RESYNC[3];		
	VID_DE_RESYNC[5]  <= VID_DE_RESYNC[4];	
end


wire Gamma_Write_Condition;

assign Gamma_Write_Condition = !CPU_RWn_i & ( CPU_D_Siz_i[1:0] == 2'b01 ) & CPU_WE_i; 

// GAMMA CHANNEL BLUE
GAMMA_Channel GAMMA_B(
	.clock_a( Video_Clk_i ),	.address_a( RGB_Pointer[7:0] ),	.data_a( 8'h00 ),	.wren_a( 1'b0 ),	.q_a( Pixel_Gamma_B_Out ),		// Pixel Output
	// CPUCPU_Clk_i
	.clock_b( CPU_Clk_i ),  .address_b( CPU_Addy_i[7:0] ), .data_b( CPU_D8_i ), .wren_b( CS_GAMMA_B_i & Gamma_Write_Condition ), .q_b( DataOut_GAMMA_B )
);
// GAMMA CHANNEL GREEN
GAMMA_Channel GAMMA_G(
	.clock_a( Video_Clk_i ),	.address_a( RGB_Pointer[15:8] ),	.data_a( 8'h00 ),	.wren_a( 1'b0 ),	.q_a( Pixel_Gamma_G_Out ),		// Pixel Output
	// CPU
	.clock_b( CPU_Clk_i ),  .address_b( CPU_Addy_i[7:0] ), .data_b( CPU_D8_i ), .wren_b( CS_GAMMA_G_i & Gamma_Write_Condition), .q_b( DataOut_GAMMA_G )
);
// GAMMA CHANNEL RED
GAMMA_Channel GAMMA_R(
	.clock_a( Video_Clk_i ),	.address_a( RGB_Pointer[23:16] ),	.data_a( 8'h00 ),	.wren_a( 1'b0 ),	.q_a( Pixel_Gamma_R_Out ),		// Pixel Output
	// CPU
	.clock_b( CPU_Clk_i ),  .address_b( CPU_Addy_i[7:0] ), .data_b( CPU_D8_i ), .wren_b( CS_GAMMA_R_i & Gamma_Write_Condition ), .q_b( DataOut_GAMMA_R )
);

always @ ( posedge Video_Clk_i ) begin
	if (Border_Horizontal_i | Border_Vertical_i ) begin
		RGB <= { Border_Red_i, Border_Green_i, Border_Blue_i };
	end
	else begin
		case ({ Graphic_Mode_Enable_i, Text_Mode_Enable_i})
			2'b00: begin RGB <=  { Border_Red_i, Border_Green_i,	Border_Blue_i }; 	end
			2'b01: begin RGB <=  { FONT_Red_i, 	FONT_Green_i, 		FONT_Blue_i   }; 	end
			2'b10: begin RGB <=  { VGE_Red_i,		VGE_Green_i,		VGE_Blue_i }; 		end
			2'b11: begin RGB <=  (Text_Overlay_Enable_i) ?   (FONT_Mono_i ? {	FONT_Red_i, FONT_Green_i, FONT_Blue_i } : { VGE_Red_i, VGE_Green_i, VGE_Blue_i }) : { VGE_Red_i, VGE_Green_i, VGE_Blue_i }; end
			default: begin 	end
		endcase
	end
end

reg [31:0] Mouse_Latency0, Mouse_Latency1;

always @ ( posedge Video_Clk_i ) begin
		Mouse_Latency0 <= Mouse_Full_RGB_i;
		Mouse_Latency1 <= Mouse_Latency0;
end

always @ ( posedge Video_Clk_i ) begin
	if ( Mouse_Latency1 )
		RGB_Pointer <= Mouse_Latency1[23:0];
	else
		RGB_Pointer <= RGB;
end

//assign RGB_Pointer = RGB ;


always @ (posedge Video_Clk_i) begin
			No_Gamma_Blu_Dly <= RGB_Pointer[7:0];
			No_Gamma_Grn_Dly <= RGB_Pointer[15:8];
			No_Gamma_Red_Dly <= RGB_Pointer[23:16];	
			
			No_Gamma_Blu_Dly0 <= No_Gamma_Blu_Dly;
			No_Gamma_Grn_Dly0 <= No_Gamma_Grn_Dly;
			No_Gamma_Red_Dly0 <= No_Gamma_Red_Dly;				
end

assign   GAMMA_RGB = GAMMA_Enable_i ? {Pixel_Gamma_R_Out, Pixel_Gamma_G_Out, Pixel_Gamma_B_Out} : {No_Gamma_Red_Dly0, No_Gamma_Grn_Dly0, No_Gamma_Blu_Dly0};
//assign   GAMMA_RGB = {No_Gamma_Red_Dly0, No_Gamma_Grn_Dly0, No_Gamma_Blu_Dly0};
endmodule

