`timescale 1ns / 1ps
module VIII_Graphics_Mixer_B (

// CPU Interface
input		wire				CPU_Clk_i,

input		wire	[7:0]		CPU_D8_i,
input		wire	[15:0]		CPU_D16_i,
input		wire	[31:0]		CPU_D32_i,
input		wire	[1:0]		CPU_D_Siz_i,
input		wire	[31:0]		CPU_Addy_i,
input		wire				CPU_A_Valid_i,
input		wire				CPU_RWn_i,
input		wire	[3:0]		CPU_BE_i,
input		wire				CPU_WE_i, 
input		wire				CS_GAMMA_B_i,
input		wire				CS_GAMMA_G_i,
input		wire				CS_GAMMA_R_i,

output		wire	[31:0]		DataOut_GAMMA_B_o,
output		wire	[31:0]		DataOut_GAMMA_G_o,
output		wire	[31:0]		DataOut_GAMMA_R_o,
// New Signals
input  		wire  				HSync_Pol_Select_i,
input 		wire  				VSync_Pol_Select_i,
input		wire				Mstr_Ctrl_GAMMA_Enable_i,
input		wire				Mstr_Ctrl_Text_Mode_Enable_i,
input		wire				Mstr_Ctrl_Text_Mode_Overlay_i,
input		wire				Mstr_Ctrl_Graphic_Mode_Enable_i,
input		wire				Mstr_Ctrl_Turn_Off_Sync_i,
input  		wire   				Mstr_Ctrl_MemText_Enable_i,
input  		wire  				Mstr_Ctrl_MemText_ShowBG_i,
input       wire                Mstr_Ctrl_FONT_Show_BG_in_Overlay_i,
input 		wire  				Mstr_Ctrl_TOS_Graph_Enable_i,
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
input  		wire  				FONT_Active_Area_i,
input		wire	[7:0]		FONT_Blue_i,
input		wire	[7:0]		FONT_Green_i,
input		wire	[7:0]		FONT_Red_i,

input       wire                TextClrBGisZero_i,		// Overlay Feature
// EXTERNAL MEMORY TEXT SYSTEM
input  		wire  				MEMText_Mono_Font_Out_i,
input  		wire  				MEMText_Mono_Cursor_Out_i,
input  		wire  				MEMText_ClrBGisZero_i,	// Overlay Feature
input  		wire  	[31:0]		MEMText_RGB_i,

input  		wire 	[31:0]		TOSGRAPH_RGB_i,

// Mouse Color
input		wire	[31:0]		Mouse_Full_RGB_i,

// VGE Color
input		wire	[7:0]		VGE_Blue_i,
input		wire	[7:0]		VGE_Green_i,
input		wire	[7:0]		VGE_Red_i,

// Timing Generator
input		wire				HSync_i,
input		wire				VSync_i,
input		wire				HBlanking_i,
input		wire				VBlanking_i,

// DAC Output Signals
output		wire	[11:0]		VID_PIXEL_o, 
output		wire				VID_DE_o,
output		wire				VID_HSYNC_o,
output		wire				VID_VSYNC_o
);

///////////////////////////////////
// Wire
///////////////////////////////////
wire	[23:0] 		GAMMA_RGB;
reg 	[23:0] 		RGB_Pointer;

wire	[7:0]		Pixel_Gamma_B_Out;
wire	[7:0]		Pixel_Gamma_G_Out;
wire	[7:0]		Pixel_Gamma_R_Out;


///////////////////////////////////
// Regs
///////////////////////////////////
reg 	[23:0] 		GAMMA_RGB_RESYNC0;
reg 	[23:0] 		GAMMA_RGB_RESYNC1;
reg 	[23:0] 		GAMMA_RGB_RESYNC2;
reg 	[5:0]  		VID_HSYNC_RESYNC;
reg 	[5:0]  		VID_VSYNC_RESYNC;
reg 	[5:0]  		VID_DE_RESYNC;
reg		[23:0]		RGB;

reg		[7:0]		No_Gamma_Blu_Dly;
reg		[7:0]		No_Gamma_Grn_Dly;
reg		[7:0]		No_Gamma_Red_Dly;

reg		[7:0]		No_Gamma_Blu_Dly0;
reg		[7:0]		No_Gamma_Grn_Dly0;
reg		[7:0]		No_Gamma_Red_Dly0;

reg 	[23:0]  	BLOCK_FONT_RGB_OUT;
reg 	[23:0]  	MEM_FONT_RGB_OUT;
reg 	[23:0]  	TOSFONT_FONT_RGB_OUT;

///////////////////////////////////
// Assign
///////////////////////////////////
assign	VID_DE_o     	= VID_DE_RESYNC[5] & Mstr_Ctrl_Turn_Off_Sync_i;
assign 	VID_HSYNC_o  	= VID_HSYNC_RESYNC[5] & Mstr_Ctrl_Turn_Off_Sync_i;
assign	VID_VSYNC_o  	= VID_VSYNC_RESYNC[5] & Mstr_Ctrl_Turn_Off_Sync_i;

DDR_Pixel_Out	DDR_Pixel_Buffer (
	.datain_h ( GAMMA_RGB_RESYNC2[11:0] ),
	.datain_l ( GAMMA_RGB_RESYNC2[23:12] ),
	.outclock ( Video_Clk_i ),
	.dataout ( VID_PIXEL_o )
);

wire  [7:0] DataOut_GAMMA_B;
wire  [7:0] DataOut_GAMMA_G;
wire  [7:0] DataOut_GAMMA_R;
wire 		Gamma_Write_Condition;
wire  [7:0]	MEMTEXT_Blue;
wire  [7:0]	MEMTEXT_Green;
wire  [7:0]	MEMTEXT_Red;

wire  [7:0]	TOSGRAPH_Blue;
wire  [7:0]	TOSGRAPH_Green;
wire  [7:0]	TOSGRAPH_Red;


always @ (posedge Video_Clk_i) begin
	GAMMA_RGB_RESYNC0 <= GAMMA_RGB;
	GAMMA_RGB_RESYNC1 <= GAMMA_RGB_RESYNC0;
	GAMMA_RGB_RESYNC2 <= GAMMA_RGB_RESYNC1;	
	
	VID_HSYNC_RESYNC[0]  <= HSync_Pol_Select_i ? HSync_i : !HSync_i;
	VID_HSYNC_RESYNC[1]  <= VID_HSYNC_RESYNC[0];
	VID_HSYNC_RESYNC[2]  <= VID_HSYNC_RESYNC[1];
	VID_HSYNC_RESYNC[3]  <= VID_HSYNC_RESYNC[2];	
	VID_HSYNC_RESYNC[4]  <= VID_HSYNC_RESYNC[3];	
	VID_HSYNC_RESYNC[5]  <= VID_HSYNC_RESYNC[4];		
	
	VID_VSYNC_RESYNC[0]  <= VSync_Pol_Select_i ? VSync_i : !VSync_i;
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

assign MEMTEXT_Blue 	= MEMText_RGB_i[7:0];
assign MEMTEXT_Green 	= MEMText_RGB_i[15:8];
assign MEMTEXT_Red 		= MEMText_RGB_i[23:16];

assign TOSGRAPH_Blue 	= TOSGRAPH_RGB_i[7:0];
assign TOSGRAPH_Green 	= TOSGRAPH_RGB_i[15:8];
assign TOSGRAPH_Red 	= TOSGRAPH_RGB_i[23:16];

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

assign DataOut_GAMMA_B_o = { DataOut_GAMMA_B, DataOut_GAMMA_B, DataOut_GAMMA_B, DataOut_GAMMA_B };
assign DataOut_GAMMA_G_o = { DataOut_GAMMA_G, DataOut_GAMMA_G, DataOut_GAMMA_G, DataOut_GAMMA_G };
assign DataOut_GAMMA_R_o = { DataOut_GAMMA_R, DataOut_GAMMA_R, DataOut_GAMMA_R, DataOut_GAMMA_R };

// Text_Overlay_Enable_i
// FONT_Mono_i (when pixel is on) 1 = Foreground, 0 = Background
// TextClrBGisZero_i ->  1 = the background Color is 0, 0 = The background choice is anything but 0  
// Mstr_Ctrl_FONT_Show_BG_in_Overlay_i -> When 1 you get the overlay on top of graphics, you keep the background, save where the BG is 0
// Enable_Transparent_BGZero = TextClrBGisZero_i & Mstr_Ctrl_FONT_Show_BG_in_Overlay_i;


//TOSGRAPH
always @ (*) begin
    casex ( {Mstr_Ctrl_Text_Mode_Overlay_i, Mstr_Ctrl_FONT_Show_BG_in_Overlay_i, TextClrBGisZero_i, ( FONT_Mono_i & FONT_Active_Area_i)} )
    // No Overlay
    4'b0xxx: begin TOSFONT_FONT_RGB_OUT <= { TOSGRAPH_Red, 	TOSGRAPH_Green, 		TOSGRAPH_Blue }; end
    // Normal Overlay
    4'b10x0: begin TOSFONT_FONT_RGB_OUT <= { TOSGRAPH_Red, 	TOSGRAPH_Green, 		TOSGRAPH_Blue }; end
    4'b10x1: begin TOSFONT_FONT_RGB_OUT <= { FONT_Red_i, FONT_Green_i, FONT_Blue_i }; end
    // Super Overlay BG == 0 
    4'b110x: begin TOSFONT_FONT_RGB_OUT <= { FONT_Red_i, FONT_Green_i, FONT_Blue_i }; end
    4'b1110: begin TOSFONT_FONT_RGB_OUT <= { TOSGRAPH_Red, 	TOSGRAPH_Green, 		TOSGRAPH_Blue }; end
    4'b1111: begin TOSFONT_FONT_RGB_OUT <= { FONT_Red_i, FONT_Green_i, FONT_Blue_i }; end
//    default: begin end
    endcase
end

// FONT_Mono_i = 0 -> BACKGROUND
// FONT_Mono_i = 1 -> FOREGROUND
// TextClrBGisZero_i = 0 -> The Background color Index is > 0
// TextClrBGisZero_i = 1 -> The BAckground Color Index is 0
// BLOCK TEXT Choices
always @ (*) begin
    casex ( {Mstr_Ctrl_Text_Mode_Overlay_i, Mstr_Ctrl_FONT_Show_BG_in_Overlay_i, TextClrBGisZero_i, ( FONT_Mono_i & FONT_Active_Area_i)} )
    // No Overlay
    4'b0xxx: begin BLOCK_FONT_RGB_OUT <= { VGE_Red_i, VGE_Green_i, VGE_Blue_i }; end
    // Normal Overlay
    4'b10x0: begin BLOCK_FONT_RGB_OUT <= { VGE_Red_i, VGE_Green_i, VGE_Blue_i }; end
    4'b10x1: begin BLOCK_FONT_RGB_OUT <= { FONT_Red_i, FONT_Green_i, FONT_Blue_i }; end
    // Super Overlay BG == 0 
    4'b110x: begin BLOCK_FONT_RGB_OUT <= { FONT_Red_i, FONT_Green_i, FONT_Blue_i }; end
    4'b1110: begin BLOCK_FONT_RGB_OUT <= { VGE_Red_i, VGE_Green_i, VGE_Blue_i }; end
    4'b1111: begin BLOCK_FONT_RGB_OUT <= { FONT_Red_i, FONT_Green_i, FONT_Blue_i }; end
//    default: begin end
    endcase
end
// Mstr_Ctrl_MemText_Enable_i,
// Mstr_Ctrl_MemText_ShowBG_i,
// MEMText_Mono_Font_Out_i,
// MEMText_Mono_Cursor_Out_i,
// MEMText_ClrBGisZero_i,
// MEMTEXT BLOCK
always @ (*) begin
    casex ( {Mstr_Ctrl_Text_Mode_Overlay_i, Mstr_Ctrl_FONT_Show_BG_in_Overlay_i, MEMText_ClrBGisZero_i, MEMText_Mono_Font_Out_i} )
    // No Overlay
    4'b0xxx: begin MEM_FONT_RGB_OUT <= { VGE_Red_i, VGE_Green_i, VGE_Blue_i }; end
    // Normal Overlay
    4'b10x0: begin MEM_FONT_RGB_OUT <= { VGE_Red_i, VGE_Green_i, VGE_Blue_i }; end
    4'b10x1: begin MEM_FONT_RGB_OUT <= { MEMTEXT_Red, MEMTEXT_Green, MEMTEXT_Blue }; end
    // Super Overlay BG == 0 
    4'b110x: begin MEM_FONT_RGB_OUT <= { MEMTEXT_Red, MEMTEXT_Green, MEMTEXT_Blue }; end
    4'b1110: begin MEM_FONT_RGB_OUT <= { VGE_Red_i, VGE_Green_i, VGE_Blue_i }; end
    4'b1111: begin MEM_FONT_RGB_OUT <= { MEMTEXT_Red, MEMTEXT_Green, MEMTEXT_Blue }; end
//    default: begin end
    endcase
end

// Traditional System Graphics + Block Text System
// 1 Clock Latency Here
always @ ( posedge Video_Clk_i ) begin
	if (Border_Horizontal_i | Border_Vertical_i ) begin
		RGB <= { Border_Red_i, Border_Green_i, Border_Blue_i };
	end
	else begin
		casex ({Mstr_Ctrl_TOS_Graph_Enable_i,  Mstr_Ctrl_MemText_Enable_i, Mstr_Ctrl_Graphic_Mode_Enable_i, FONT_Active_Area_i, Mstr_Ctrl_Text_Mode_Enable_i  })
			// When Memory Text Mode is OFF (Default and Legacy)
			5'b0_0000: begin RGB <=  { Border_Red_i, 	Border_Green_i,		Border_Blue_i }; 	end	// No Graphics Assets On
			5'b0_0010: begin RGB <=  { 8'h00, 	8'h00,		8'h00 }; 							end	// No Graphics Assets On			
			5'b0_0011: begin RGB <=  { FONT_Red_i, 	FONT_Green_i, 		FONT_Blue_i   }; 		end	// Internal Text Mode Only
			5'b0_01x0: begin RGB <=  { VGE_Red_i,		VGE_Green_i,		VGE_Blue_i }; 		end	// Graphic Mode Only
			5'b0_01x1: begin RGB <=  BLOCK_FONT_RGB_OUT;										end // Graphics with Text Overlay
			// When Memory Text Mode is ON
			5'b0_10x0: begin RGB <=  { Border_Red_i, 	Border_Green_i,		Border_Blue_i }; 	end	// Only the Memory Text Mode
			5'b0_10x1: begin RGB <=  { MEMTEXT_Red, 	MEMTEXT_Green, 		MEMTEXT_Blue   }; 	end	// Mem Internal Text Mode + Mem Text Mode
			5'b0_11x0: begin RGB <=  { VGE_Red_i,		VGE_Green_i,		VGE_Blue_i }; 		end // MemText Mode Overlay + Graphics Mode
			5'b0_11x1: begin RGB <=  MEM_FONT_RGB_OUT; 											end 
			// When the TOSGRAPH is on, there is no Overlay
			5'b1_xxx0: begin RGB <= { TOSGRAPH_Red, 	TOSGRAPH_Green, 		TOSGRAPH_Blue   }; 	end	
			5'b1_xxx1: begin RGB <=  TOSFONT_FONT_RGB_OUT; 	end		
			//default: begin 	RGB <= 24'h808080; end
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

assign   GAMMA_RGB = Mstr_Ctrl_GAMMA_Enable_i ? {Pixel_Gamma_R_Out, Pixel_Gamma_G_Out, Pixel_Gamma_B_Out} : {No_Gamma_Red_Dly0, No_Gamma_Grn_Dly0, No_Gamma_Blu_Dly0};
//assign   GAMMA_RGB = {No_Gamma_Red_Dly0, No_Gamma_Grn_Dly0, No_Gamma_Blu_Dly0};

endmodule

/*
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
*/

