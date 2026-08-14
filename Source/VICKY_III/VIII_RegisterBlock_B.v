
`timescale 1 ns / 1 ns
module VIII_RegisterBlock_B# (
parameter	CHIP_NUMBER 		= 32'h0009_5179,
parameter	CHIP_VERSION 		= 16'h0000,
parameter 	CHIP_SUBVERSION 	= 16'h0001
)
(
input 		wire				rst_i,				// This is async Reset
input		wire				Reset_VideoClkOut,
input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,
// CPU Signals Interface
input 		wire				iBUS_1xClk_i,
input 		wire				iBUS_2xClk_i,
input 		wire	[31:0]		BUS_A_i,

input		wire				BUS_A_Valid_i,

input		wire	[7:0]		BUS_D8_i,
input		wire	[15:0]		BUS_D16_i,
input		wire	[31:0]		BUS_D32_i,
input		wire	[1:0]		BUS_D_Siz_i,

output 		reg		[31:0]		BUS_D_o,
input		wire				BUS_RW_i,
input		wire	[3:0]		BUS_BE_i,
input		wire				BUS_WE_i,
input		wire				CS_Vicky_Registers_i,
//
input		wire				VideoClk_i,
input		wire				SOF_i,

input		wire				DIPSwitch_GAMMA_i,
input		wire				DIPSwitch_HiRes_i,


// Cursor Register
output		reg		[15:0]		Cursor_X_Position_o,
output   	reg		[15:0]		Cursor_Y_Position_o,
output		reg		[7:0]		Cursor_Control_Reg_o,
output		reg		[7:0]		Cursor_Character_Reg_o,
output		reg		[7:0]		Cursor_Color_Reg_o,
// FONT Parameters
output		wire	[7:0]		FONT_Container_Size_X_o,
output		wire	[7:0]		FONT_Container_Size_Y_o,
output		wire	[7:0]		FONT_Size_X_o,
output		wire	[7:0]		FONT_Size_Y_o,
output		wire	[7:0]		FONT_Horizontal_Num_Char_o,
output		wire	[7:0]		FONT_Vertical_Num_Line_o,

// Border Control
output		wire	[23:0]		Border_Color_Reg_o,
output		reg		[7:0]		Reg_Text_Ptr_Offset_o,
output		wire				Border_Enable_o,
output		wire	[2:0]		Border_X_Scroll_o,
output		wire	[5:0]		Border_X_Size_o,
output		wire	[5:0]		Border_Y_Size_o,
// Background Color
output		wire	[7:0]		Background_Blue_o,
output		wire	[7:0]		Background_Green_o,
output		wire	[7:0]		Background_Red_o,
// Vicky Master Control
output		wire				Mstr_Ctrl_Text_Mode_Enable_o,
output		wire				Mstr_Ctrl_Text_Mode_Overlay_o,
output		wire				Mstr_Ctrl_Graphic_Mode_Enable_o,

output		wire			    Mstr_Ctrl_Bitmap_Enable_o,
output		wire				Mstr_Ctrl_TileMap_Enable_o,
output		wire				Mstr_Ctrl_Sprite_Enable_o,

output		wire				Mstr_Ctrl_Disable_Video_o,
output		wire				Mstr_Ctrl_GAMMA_Enable_o,
output		wire				Mstr_Ctrl_Turn_Off_Sync_o,
output    	wire   				Mstr_Ctrl_MemText_Enable_o,
output 		wire  				Mstr_Ctrl_MemText_ShowBG_o,
output      wire   				Mstr_Ctrl_FONT_Show_BG_in_Overlay_o,
// New Registers
output   	wire   				Mstr_Ctrl_TOS_Graph_Enable_o,
output   	wire   	[1:0]		Mstr_Ctrl_TOS_Graph_Mode_o,

output		wire	[1:0]		Mstr_Ctrl_Video_Mode_o,

output		wire  	[1:0]		Mstr_Ctrl_Video_Mode_CPU_o,
output	    wire    [1:0]		Mstr_Ctrl_Pixel_Division_o,	// 00 - 1280x960, // 01-640x480 // 10-320x240
output		wire	[1:0]		Mstr_Ctrl_Video_Mode_100MhzReSynced_o,
output		wire	[1:0]		Mstr_Ctrl_Pixel_Division_100MhzResynced_o,

// New registers Output for Game Engine
output 		wire   				Mstr_Ctrl_Game_GUI_Mode_o,
output	    wire				Mstr_Ctrl_Game_Layer0_Enable_o,
output	    wire				Mstr_Ctrl_Game_Layer0_Type_o,
output	    wire				Mstr_Ctrl_Game_Layer1_Enable_o,
output	    wire				Mstr_Ctrl_Game_Layer1_Type_o,
output	    wire				Mstr_Ctrl_Game_Layer2_Enable_o,
output	    wire				Mstr_Ctrl_Game_Layer2_Type_o,
output	    wire				Mstr_Ctrl_Game_Layer3_Enable_o,
output	    wire				Mstr_Ctrl_Game_Layer3_Type_o,

output		wire	[15:0]		LineInterrupt_Reg0_o,
output		wire	[15:0]		LineInterrupt_Reg1_o,
output		wire	[15:0]		LineInterrupt_Reg2_o,
output		wire	[15:0]		LineInterrupt_Reg3_o
);
/*
wire [7:0] Source;
wire [31:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);

assign Probe = Source[0] ? Border_CTRL_H_Reg_VidClk[2] : Border_CTRL_L_Reg_VidClk[2];
*/
// This is the Block that the CPU can interact with for Read back mostly.
// The Transfer of the Data from one Clock Domain to another is done in the Proper Block.

reg [31:0]		VICKY_MASTER_REG[0:15];


// Writing Part
always @ (posedge iBUS_1xClk_i)
begin
	if (rst_i)
	begin
		VICKY_MASTER_REG[0] 	<= 32'h0000_0001;		// VKY Master Ctrl Reg 0
		VICKY_MASTER_REG[1] 	<= 32'h0010_1001;		// Border Control Reg 0
		VICKY_MASTER_REG[2] 	<= 32'h0020_3060;		// Border Control Reg 2
		VICKY_MASTER_REG[3] 	<= 32'h0000_0000;		// Background Control Reg 1 / Background Control Reg 0
		VICKY_MASTER_REG[4] 	<= 32'h0000_0000;		// Cursor Control Reg 1 / Cursor Control Reg 0 
		VICKY_MASTER_REG[5] 	<= 32'h0000_0000;		// Cursor Control Reg 3 / Cursor Control Reg 2
		VICKY_MASTER_REG[6] 	<= 32'h0000_0000;		// Line Interrupt Control Reg 1 / Line Interrupt Control Reg 0	
		VICKY_MASTER_REG[7] 	<= 32'h0000_0000;		// Line Interrupt Control Reg 3 / Line Interrupt Control Reg 2
		
		VICKY_MASTER_REG[8] 	<= 32'h1008_1008;		// FONT Manager - Font Container Size and FONT Size
		VICKY_MASTER_REG[9] 	<= 32'h0000_1E50;		// FONT - Horizontal # of Character, Vertical # FONT Line
		VICKY_MASTER_REG[10] 	<= 32'h0000_0000;
		VICKY_MASTER_REG[11] 	<= 32'h0000_0000;
		VICKY_MASTER_REG[12]	<= 32'h0000_0000;
		VICKY_MASTER_REG[13]	<= 32'h0000_0000;
		VICKY_MASTER_REG[14] 	<= 32'h0000_0000;
		VICKY_MASTER_REG[15] 	<= 32'h0000_0000;
	end
	else
	begin
		if (CS_Vicky_Registers_i && !BUS_RW_i && (BUS_D_Siz_i[1:0] == 2'b00) && BUS_WE_i)
			VICKY_MASTER_REG[BUS_A_i[5:2]] <= BUS_D32_i;
	end
end

//{ VICKY_MASTER_REG[2][7:5], DIPSwitch_HiRes_i, DIPSwitch_GAMMA_i, VICKY_MASTER_REG[2][2:0]} ;		// Global X Offset 

always @ (*)
begin
	case(BUS_A_i[5:2])
		4'b0000: BUS_D_o = { 1'b1, DIPSwitch_HiRes_i, DIPSwitch_GAMMA_i, VICKY_MASTER_REG[0][28:0] };
		4'b0001: BUS_D_o = VICKY_MASTER_REG[1];
		4'b0010: BUS_D_o = VICKY_MASTER_REG[2];
		4'b0011: BUS_D_o = VICKY_MASTER_REG[3];
		4'b0100: BUS_D_o = VICKY_MASTER_REG[4];
		4'b0101: BUS_D_o = VICKY_MASTER_REG[5];
		4'b0110: BUS_D_o = VICKY_MASTER_REG[6];
		4'b0111: BUS_D_o = VICKY_MASTER_REG[7];
		4'b1000: BUS_D_o = VICKY_MASTER_REG[8];
		4'b1001: BUS_D_o = VICKY_MASTER_REG[9];
		4'b1010: BUS_D_o = VICKY_MASTER_REG[10];
		4'b1011: BUS_D_o = VICKY_MASTER_REG[11];
		4'b1100: BUS_D_o = VICKY_MASTER_REG[12];
		4'b1101: BUS_D_o = VICKY_MASTER_REG[13];
		4'b1110: BUS_D_o = {CHIP_VERSION,  CHIP_SUBVERSION};
		4'b1111: BUS_D_o = CHIP_NUMBER[31:0];
	endcase
end

reg [1:0]	SOF_EDGE;

always @(posedge Reset_VideoClkOut or posedge VideoClk_i)
begin
	if (Reset_VideoClkOut) 
	begin
		SOF_EDGE <= 2'b00;
	end
	else begin
		SOF_EDGE[0] <= SOF_i;
		SOF_EDGE[1] <= SOF_EDGE[0];
	end
end

assign LineInterrupt_Reg0_o = Line_Interrupt_CTRL_0_Reg_VidClk[2];
assign LineInterrupt_Reg1_o = Line_Interrupt_CTRL_1_Reg_VidClk[2];
assign LineInterrupt_Reg2_o = Line_Interrupt_CTRL_2_Reg_VidClk[2];
assign LineInterrupt_Reg3_o = Line_Interrupt_CTRL_3_Reg_VidClk[2];

////////////////////
////// 200Mhz Clock Domain Resync
////////////////////
reg [31:0]	BG_Control_Reg_200Mhz[0:2]; // Background Control Register 32bits
always @ (posedge EngineClk200Mhz_i) begin
		BG_Control_Reg_200Mhz[0][31:0] <= {VICKY_MASTER_REG[3]};
		BG_Control_Reg_200Mhz[1][31:0] <= BG_Control_Reg_200Mhz[0][31:0];
		if (BG_Control_Reg_200Mhz[0][31:0] == BG_Control_Reg_200Mhz[1][31:0]) 
			BG_Control_Reg_200Mhz[2][31:0] <= BG_Control_Reg_200Mhz[1][31:0];		
end

assign Background_Blue_o = BG_Control_Reg_200Mhz[2][7:0];
assign Background_Green_o = BG_Control_Reg_200Mhz[2][15:8];
assign Background_Red_o = BG_Control_Reg_200Mhz[2][23:16];

////////////////////
////// Video Clock Domain Resync
////////////////////
reg 	[31:0] Master_Control_Reg_VidClk[0:2]; // Master Control Register 32bits
reg 	[31:0] Border_CTRL_L_Reg_VidClk[0:2]; // Background Control Register 32bits
reg 	[31:0] Border_CTRL_H_Reg_VidClk[0:2]; // Background Control Register 32bits
reg 	[31:0] Cursor_CTRL_L_Reg_VidClk[0:2]; // Cursor Control Register (L) 32bits
reg 	[31:0] Cursor_CTRL_H_Reg_VidClk[0:2]; // Cursor Control Register (L) 32bits
reg		[31:0] FONT_CTRL_L_Reg_VidClk[0:2];
reg		[31:0] FONT_CTRL_H_Reg_VidClk[0:2];
reg 	[15:0] Line_Interrupt_CTRL_0_Reg_VidClk[0:2];
reg 	[15:0] Line_Interrupt_CTRL_1_Reg_VidClk[0:2];
reg 	[15:0] Line_Interrupt_CTRL_2_Reg_VidClk[0:2];
reg 	[15:0] Line_Interrupt_CTRL_3_Reg_VidClk[0:2];

always @ (posedge VideoClk_i) begin
		// Master Control Register
		Master_Control_Reg_VidClk[0][31:0] <= VICKY_MASTER_REG[0];
		Master_Control_Reg_VidClk[1][31:0] <= Master_Control_Reg_VidClk[0][31:0];
		if (Master_Control_Reg_VidClk[0][31:0] == Master_Control_Reg_VidClk[1][31:0])
			Master_Control_Reg_VidClk[2][31:0] <= Master_Control_Reg_VidClk[1][31:0];

		// BORDER COLORS L
		Border_CTRL_L_Reg_VidClk[0][31:0] <= VICKY_MASTER_REG[1];
		Border_CTRL_L_Reg_VidClk[1][31:0] <= Border_CTRL_L_Reg_VidClk[0][31:0];
		if (Border_CTRL_L_Reg_VidClk[0][31:0] == Border_CTRL_L_Reg_VidClk[1][31:0])
			Border_CTRL_L_Reg_VidClk[2][31:0] <= Border_CTRL_L_Reg_VidClk[1][31:0];
			
		// BORDER COLORS H
		Border_CTRL_H_Reg_VidClk[0][31:0] <= VICKY_MASTER_REG[2];
		Border_CTRL_H_Reg_VidClk[1][31:0] <= Border_CTRL_H_Reg_VidClk[0][31:0];
		if (Border_CTRL_H_Reg_VidClk[0][31:0] == Border_CTRL_H_Reg_VidClk[1][31:0])
			Border_CTRL_H_Reg_VidClk[2][31:0] <= Border_CTRL_H_Reg_VidClk[1][31:0];

		// Cursor L
		Cursor_CTRL_L_Reg_VidClk[0][31:0] <= VICKY_MASTER_REG[4];
		Cursor_CTRL_L_Reg_VidClk[1][31:0] <= Cursor_CTRL_L_Reg_VidClk[0][31:0];
		if (Cursor_CTRL_L_Reg_VidClk[0][31:0] == Cursor_CTRL_L_Reg_VidClk[1][31:0])
			Cursor_CTRL_L_Reg_VidClk[2][31:0] <= Cursor_CTRL_L_Reg_VidClk[1][31:0];

		// Cursor H
		Cursor_CTRL_H_Reg_VidClk[0][31:0] <= VICKY_MASTER_REG[5];
		Cursor_CTRL_H_Reg_VidClk[1][31:0] <= Cursor_CTRL_H_Reg_VidClk[0][31:0];
		if (Cursor_CTRL_H_Reg_VidClk[0][31:0] == Cursor_CTRL_H_Reg_VidClk[1][31:0])
			Cursor_CTRL_H_Reg_VidClk[2][31:0] <= Cursor_CTRL_H_Reg_VidClk[1][31:0];

		// Line Interrupt Ctrl 0
		Line_Interrupt_CTRL_0_Reg_VidClk[0][15:0] <= VICKY_MASTER_REG[6][15:0];
		Line_Interrupt_CTRL_0_Reg_VidClk[1][15:0] <= Line_Interrupt_CTRL_0_Reg_VidClk[0][15:0];
		if (Line_Interrupt_CTRL_0_Reg_VidClk[0][15:0] == Line_Interrupt_CTRL_0_Reg_VidClk[1][15:0])
			Line_Interrupt_CTRL_0_Reg_VidClk[2][15:0] <= Line_Interrupt_CTRL_0_Reg_VidClk[1][15:0];
		// Line Interrupt Ctrl 1
		Line_Interrupt_CTRL_1_Reg_VidClk[0][15:0] <= VICKY_MASTER_REG[6][31:16];
		Line_Interrupt_CTRL_1_Reg_VidClk[1][15:0] <= Line_Interrupt_CTRL_1_Reg_VidClk[0][15:0];
		if (Line_Interrupt_CTRL_1_Reg_VidClk[0][15:0] == Line_Interrupt_CTRL_1_Reg_VidClk[1][15:0])
			Line_Interrupt_CTRL_1_Reg_VidClk[2][15:0] <= Line_Interrupt_CTRL_1_Reg_VidClk[1][15:0];
		// Line Interrupt Ctrl 2
		Line_Interrupt_CTRL_2_Reg_VidClk[0][15:0] <= VICKY_MASTER_REG[7][15:0];
		Line_Interrupt_CTRL_2_Reg_VidClk[1][15:0] <= Line_Interrupt_CTRL_2_Reg_VidClk[0][15:0];
		if (Line_Interrupt_CTRL_2_Reg_VidClk[0][15:0] == Line_Interrupt_CTRL_2_Reg_VidClk[1][15:0])
			Line_Interrupt_CTRL_2_Reg_VidClk[2][15:0] <= Line_Interrupt_CTRL_2_Reg_VidClk[1][15:0];
		// Line Interrupt Ctrl 3
		Line_Interrupt_CTRL_3_Reg_VidClk[0][15:0] <= VICKY_MASTER_REG[7][31:16];
		Line_Interrupt_CTRL_3_Reg_VidClk[1][15:0] <= Line_Interrupt_CTRL_3_Reg_VidClk[0][15:0];
		if (Line_Interrupt_CTRL_3_Reg_VidClk[0][15:0] == Line_Interrupt_CTRL_3_Reg_VidClk[1][15:0])
			Line_Interrupt_CTRL_3_Reg_VidClk[2][15:0] <= Line_Interrupt_CTRL_3_Reg_VidClk[1][15:0];
			
		// FONT Manager
		FONT_CTRL_L_Reg_VidClk[0][31:0] <= VICKY_MASTER_REG[8];
		FONT_CTRL_L_Reg_VidClk[1][31:0] <= FONT_CTRL_L_Reg_VidClk[0][31:0];
		if (FONT_CTRL_L_Reg_VidClk[0][31:0] == FONT_CTRL_L_Reg_VidClk[1][31:0])
			FONT_CTRL_L_Reg_VidClk[2][31:0] <= FONT_CTRL_L_Reg_VidClk[1][31:0];
		
		// FONT Manager
		FONT_CTRL_H_Reg_VidClk[0][31:0] <= VICKY_MASTER_REG[9];
		FONT_CTRL_H_Reg_VidClk[1][31:0] <= FONT_CTRL_H_Reg_VidClk[0][31:0];
		if (FONT_CTRL_H_Reg_VidClk[0][31:0] == FONT_CTRL_H_Reg_VidClk[1][31:0])
			FONT_CTRL_H_Reg_VidClk[2][31:0] <= FONT_CTRL_H_Reg_VidClk[1][31:0];		
end

////////////////////
////// 100Mhz Clock Domain Resync
////////////////////
reg	[3:0]	ReSync_VideoMode[0:2];
reg	[2:0]	ReSync_DisableVideo;
reg	[2:0]	ReSync_Bitmap_Enable;
reg	[2:0]	ReSync_TileMap_Enable;
reg	[2:0]	ReSync_Sprite_Enable;

always @ (posedge EngineClk100Mhz_i)
begin
	// Game Mode - Bitmap Enable
	ReSync_Bitmap_Enable[0] <= VICKY_MASTER_REG[0][3];
	ReSync_Bitmap_Enable[1] <= ReSync_Bitmap_Enable[0];
	if ( ReSync_Bitmap_Enable[1] == ReSync_Bitmap_Enable[0] ) 
		ReSync_Bitmap_Enable[2] <= ReSync_Bitmap_Enable[1];
	// Game Mode Tile Enable
	ReSync_TileMap_Enable[0] <= VICKY_MASTER_REG[0][4];
	ReSync_TileMap_Enable[1] <= ReSync_TileMap_Enable[0];
	if ( ReSync_TileMap_Enable[1] == ReSync_TileMap_Enable[0] )
		ReSync_TileMap_Enable[2] <= ReSync_TileMap_Enable[1];
	// Game Mode Sprite Enable
	ReSync_Sprite_Enable[0] <= VICKY_MASTER_REG[0][5];
	ReSync_Sprite_Enable[1] <= ReSync_Sprite_Enable[0];
	if ( ReSync_Sprite_Enable[1] == ReSync_Sprite_Enable[0] )
		 ReSync_Sprite_Enable[2] <=  ReSync_Sprite_Enable[1];
	// ReSync Disable Video (turn off the Engine from Fetching data)
	ReSync_DisableVideo[0] <= VICKY_MASTER_REG[0][7];
	ReSync_DisableVideo[1] <= ReSync_DisableVideo[0];
	if (ReSync_DisableVideo[1] == ReSync_DisableVideo[0])
		ReSync_DisableVideo[2] <= ReSync_DisableVideo[1];

	ReSync_VideoMode[0][3:0]<= VICKY_MASTER_REG[0][11:8];
	ReSync_VideoMode[1][3:0]<= ReSync_VideoMode[0][3:0];
	if ( ReSync_VideoMode[1][3:0]  == ReSync_VideoMode[0][3:0] )
		ReSync_VideoMode[2][3:0] <= ReSync_VideoMode[1][3:0];
end

wire Mstr_Ctrl_GAMMA_int_extern;

// Video Clock Synced
assign Mstr_Ctrl_Text_Mode_Enable_o 			= Master_Control_Reg_VidClk[2][0];		// VICKY_MASTER_REG[0][0];
assign Mstr_Ctrl_Text_Mode_Overlay_o 			= Master_Control_Reg_VidClk[2][1];		// VICKY_MASTER_REG[0][1];
// CPU Clock Synced
assign Mstr_Ctrl_Graphic_Mode_Enable_o 			= VICKY_MASTER_REG[0][2];  				// Graphics Mode On
assign Mstr_Ctrl_Bitmap_Enable_o 				= ReSync_Bitmap_Enable[2];				// VICKY_MASTER_REG[0][3];
assign Mstr_Ctrl_TileMap_Enable_o 				= ReSync_TileMap_Enable[2];				// VICKY_MASTER_REG[0][4];
assign Mstr_Ctrl_Sprite_Enable_o 				= ReSync_Sprite_Enable[2];				// VICKY_MASTER_REG[0][5];
assign Mstr_Ctrl_GAMMA_Enable_o 				= Mstr_Ctrl_GAMMA_int_extern ? Master_Control_Reg_VidClk[2][6] : DIPSwitch_GAMMA_i; 	//Master_Control_Reg_VidClk[2][17] : DIPSwitch_GAMMA_i;
assign Mstr_Ctrl_Disable_Video_o 				= ReSync_DisableVideo[2];				// VICKY_MASTER_REG[0][7];
assign Mstr_Ctrl_Video_Mode_o[1:0] 				= Master_Control_Reg_VidClk[2][9:8]; 	// Video Clock Synced
assign Mstr_Ctrl_Video_Mode_CPU_o 				= VICKY_MASTER_REG[0][9:8];
assign Mstr_Ctrl_Pixel_Division_o				= VICKY_MASTER_REG[0][11:10];			// 00: Full Resolution, 01: divided by 2, 10: divided by 4
assign Mstr_Ctrl_Turn_Off_Sync_o 				= !Master_Control_Reg_VidClk[2][12];	// Turn-Off Sync to get the Monitor to Sleep
assign Mstr_Ctrl_FONT_Show_BG_in_Overlay_o  	= Master_Control_Reg_VidClk[2][13];	 	// Overlay with BG See-through
assign Mstr_Ctrl_MemText_Enable_o 				= Master_Control_Reg_VidClk[2][14] & !Master_Control_Reg_VidClk[2][20]; 	// Memtext Mode ON <<<<< NEW
assign Mstr_Ctrl_MemText_ShowBG_o				= Master_Control_Reg_VidClk[2][15]; 	// Memtext Mode BG See-Through <<<< NEW (Not tested)
assign Mstr_Ctrl_Game_GUI_Mode_o				= VICKY_MASTER_REG[0][16];				// GUI = 0, GAME = 1 ????
assign Mstr_Ctrl_GAMMA_int_extern 				= VICKY_MASTER_REG[0][17];		// 0 = DipSwitch, 1 = Register Choice
// Nothing Yet @ VICKY_MASTER_REG[0][18];
// Nothing Yet @ VICKY_MASTER_REG[0][19];
assign Mstr_Ctrl_TOS_Graph_Enable_o				=  VICKY_MASTER_REG[0][20] & !VICKY_MASTER_REG[0][14];				// Enable EMUTOS Bitmap Mode (Mutually Exclusive with memtext)
assign Mstr_Ctrl_TOS_Graph_Mode_o				=  VICKY_MASTER_REG[0][22:21];			// Mode 00: 1bpp, 01: 2bpp, 10: 4bpp
// Nothing Yet @ VICKY_MASTER_REG[0][23];
assign Mstr_Ctrl_Game_Layer0_Enable_o			= VICKY_MASTER_REG[0][24];				// Game Engine Layer0 Enable
assign Mstr_Ctrl_Game_Layer0_Type_o				= VICKY_MASTER_REG[0][25];				// Game Engine Layer0 Type (0 = Bitmap, 1 = TileMap)
assign Mstr_Ctrl_Game_Layer1_Enable_o			= VICKY_MASTER_REG[0][26];				// Game Engine Layer1 Enable
assign Mstr_Ctrl_Game_Layer1_Type_o				= VICKY_MASTER_REG[0][27];				// Game Engine Layer1 Type (0 = Bitmap, 1 = TileMap)
assign Mstr_Ctrl_Game_Layer2_Enable_o			= VICKY_MASTER_REG[0][28];				// Game Engine Layer2 Enable
assign Mstr_Ctrl_Game_Layer2_Type_o				= VICKY_MASTER_REG[0][29];				// Game Engine Layer2 Type (0 = Bitmap, 1 = TileMap)
assign Mstr_Ctrl_Game_Layer3_Enable_o			= VICKY_MASTER_REG[0][30];				// Game Engine Layer3 Enable
assign Mstr_Ctrl_Game_Layer3_Type_o				= VICKY_MASTER_REG[0][31];				// Game Engine Layer3 Type (0 = Bitmap, 1 = TileMap)

// 108Mhz ReSynced
assign Mstr_Ctrl_Video_Mode_100MhzReSynced_o[1:0] 		= ReSync_VideoMode[2][1:0]; 
assign Mstr_Ctrl_Pixel_Division_100MhzResynced_o[1:0]   = ReSync_VideoMode[2][3:2];

// Border Registers
assign Border_Color_Reg_o 						= Border_CTRL_H_Reg_VidClk[2][23:0];
assign Border_Enable_o 							= Border_CTRL_L_Reg_VidClk[2][0];
assign Border_X_Scroll_o 						= Border_CTRL_L_Reg_VidClk[2][6:4];
assign Border_X_Size_o 							= Border_CTRL_L_Reg_VidClk[2][13:8];
assign Border_Y_Size_o 							= Border_CTRL_L_Reg_VidClk[2][21:16];
// FONT Registers
assign FONT_Container_Size_X_o = FONT_CTRL_L_Reg_VidClk[2][7:0];
assign FONT_Container_Size_Y_o = FONT_CTRL_L_Reg_VidClk[2][15:8];
assign FONT_Size_X_o = FONT_CTRL_L_Reg_VidClk[2][23:16];
assign FONT_Size_Y_o = FONT_CTRL_L_Reg_VidClk[2][31:24];

assign FONT_Horizontal_Num_Char_o = FONT_CTRL_H_Reg_VidClk[2][7:0];
assign FONT_Vertical_Num_Line_o = FONT_CTRL_H_Reg_VidClk[2][15:8];

always @ (posedge VideoClk_i)
begin
	if (SOF_EDGE[1:0] == 2'b01) begin
		// Cursor
		Cursor_X_Position_o 		<= Cursor_CTRL_H_Reg_VidClk[2][15:0];
		Cursor_Y_Position_o 		<=	Cursor_CTRL_H_Reg_VidClk[2][31:16];
		Cursor_Control_Reg_o 	<= Cursor_CTRL_L_Reg_VidClk[2][7:0];
		Reg_Text_Ptr_Offset_o 	<= Cursor_CTRL_L_Reg_VidClk[2][15:8];
		Cursor_Character_Reg_o 	<= Cursor_CTRL_L_Reg_VidClk[2][23:16];
		Cursor_Color_Reg_o 		<= Cursor_CTRL_L_Reg_VidClk[2][31:24];
	end
end



endmodule

