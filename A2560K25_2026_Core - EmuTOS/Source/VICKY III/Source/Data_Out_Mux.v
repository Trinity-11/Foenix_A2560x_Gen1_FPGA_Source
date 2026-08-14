`timescale 1 ns / 1 ns

module Data_Out_Mux (

input		wire				rst,
input		wire				Bus_Clk_i,

input		wire	[23:0]	Bus_A_i,
input		wire				Bus_RW_i,
input		wire				BUS_VPA_i,
input		wire				BUS_VDA_i,
input		wire				Bus_RDY_i,
output	wire				Bus_RDY_o,

// Data Path from the different Block
input		wire	[7:0]		DataOut_Register_Level_i,
input		wire	[7:0]		DataOut_Bitmap_Regs_i,
input		wire	[7:0] 	DataOut_Tile0_Regs_i,
input		wire	[7:0] 	DataOut_Tile1_Regs_i,
input		wire	[7:0] 	DataOut_Collisions_Regs_i,
input		wire	[7:0]		DataOut_VDMA_Controller_i,
input		wire	[7:0]		DataOut_SDMA_Controller_i,
input		wire	[7:0]		DataOut_Sprites_Regs_i,
input		wire	[7:0]		DataOut_Txt_Clr_FG_Plt_i,
input		wire	[7:0]		DataOut_Txt_Clr_BG_Plt_i,
input		wire	[7:0]		DataOut_Grphc_Clr_Plt0_i,
input		wire	[7:0]		DataOut_GAMMA_B_i,
input		wire	[7:0]		DataOut_GAMMA_G_i,
input		wire	[7:0]		DataOut_GAMMA_R_i,
input		wire	[7:0]		DataOut_TextMemory_i,
input		wire	[7:0]		DataOut_ColorMemory_i,
input		wire	[7:0]		DataOut_Font_Memory_i,
input		wire	[7:0]		DataOut_AttrMemory_i,
input		wire	[7:0]		DataOut_VideoMemory_i,
input		wire	[7:0]		DataOut_MousePointer_i,
input		wire	[7:0]		DataOut_Multiplier32x32_i,

// Write Strobe for every Dual-Port RAM in the system
output	wire				CS_VIDEO_RAM_o,
output	wire				CS_GAMMA_B_o,
output	wire				CS_GAMMA_G_o,
output	wire				CS_GAMMA_R_o,
output	wire 				CS_VID_Color_Char_o,
output	wire 				CS_VID_Text_Char_o,
output	wire				CS_FONT_Memory_o,
output	wire				CS_Grphc_Plt_0_o,
output	wire				CS_Txt_Background_Plt_o,
output	wire				CS_Txt_Foreground_Plt_o,
output	wire				CS_VDMA_Controller_o,
output	wire				CS_SDMA_Controller_o,
output	wire				CS_Sprites_Registers_o,
output	wire				CS_Tile0_Registers_o,
output	wire				CS_Tile1_Registers_o,
output	wire				CS_Collisions_Registers_o,
output	wire				CS_Bitmap_Registers_o,
output	wire				CS_Vicky_Registers_o,
output	wire				CS_MousePointerMem_o,
output	wire				CS_MousePointerReg_o,
output	wire				CS_MULTIPLIER32x32_o,
// BUS - Data Bus
output	wire				DataOut_Oe_o,
output	wire	[7:0]		DataOut_o
);


// Chip Select Internal Strobe (Active 1)
wire 		CS_VID_Color_Char;
wire 		CS_VID_Text_Char;
wire		CS_Txt_Background_Plt;
wire		CS_Txt_Foreground_Plt;
wire		CS_DMA_Controller;
wire		CS_Vicky_Registers;
wire		CS_Bitmap_Registers;
wire		CS_Sprites_Registers;
wire		CS_GAMMA_R;
wire		CS_GAMMA_G;
wire		CS_GAMMA_B;
wire		CS_VIDEO_RAM;
wire		CS_Tile_Registers;
wire		CS_MousePointerMem;
wire		CS_MousePointerReg;
wire		CS_FONT_Memory;
wire		CS_TileMAP0_Registers;
wire		CS_TileMAP1_Registers;
wire		CS_Collision_Registers;
wire		CS_LUT;
wire		CS_VDMA_Controller;
wire		CS_SDMA_Controller;
wire		CS_MULTIPLIER32x32;

assign	CS_VID_Color_Char_o 		= CS_VID_Color_Char;
assign	CS_VID_Text_Char_o 		= CS_VID_Text_Char;
assign	CS_Vicky_Registers_o 	= CS_Vicky_Registers;
assign	CS_Bitmap_Registers_o 	= CS_Bitmap_Registers;
assign	CS_Tile0_Registers_o 	= CS_TileMAP0_Registers;
assign   CS_Tile1_Registers_o		= CS_TileMAP1_Registers;
assign 	CS_Collisions_Registers_o	= CS_Collision_Registers;
assign	CS_VDMA_Controller_o 		= CS_VDMA_Controller;
assign   CS_SDMA_Controller_o		= CS_SDMA_Controller;

assign	CS_Sprites_Registers_o 	= CS_Sprites_Registers;
assign	CS_Txt_Foreground_Plt_o = CS_Txt_Foreground_Plt;
assign	CS_Txt_Background_Plt_o = CS_Txt_Background_Plt;
assign	CS_Grphc_Plt_0_o 			= CS_LUT;

assign 	CS_GAMMA_B_o     			= CS_GAMMA_B;
assign 	CS_GAMMA_G_o     			= CS_GAMMA_G;
assign 	CS_GAMMA_R_o     			= CS_GAMMA_R;
assign	CS_FONT_Memory_o 			= CS_FONT_Memory;
assign   CS_VIDEO_RAM_o				= CS_VIDEO_RAM;
assign 	CS_MousePointerMem_o		= CS_MousePointerMem;
assign	CS_MousePointerReg_o		= CS_MousePointerReg;

assign   CS_MULTIPLIER32x32_o		= CS_MULTIPLIER32x32;

wire	[19:0] CS_Combined;
wire			 CS_Ored;

reg [7:0] DataOut;

wire Valid_Address;
assign Valid_Address = BUS_VDA_i & !BUS_VPA_i;
assign CS_Vicky_Registers     =  (Bus_A_i[23:8]  == 16'b1010_1111_0000_0000) 			& Valid_Address;	// $AF:0000 - $AF:00FF (Internal Memory)
assign CS_Bitmap_Registers    =  (Bus_A_i[23:8]  == 16'b1010_1111_0000_0001) 			& Valid_Address;  // $AF:0100 - $AF:01FF (Internal Memory)
assign CS_TileMAP0_Registers  =  (Bus_A_i[23:7]  == 17'b1010_1111_0000_0010_0) 		& Valid_Address;  // $AF:0200 - $AF:027F (Internal Memory)
assign CS_TileMAP1_Registers  =  (Bus_A_i[23:7]  == 17'b1010_1111_0000_0010_1) 		& Valid_Address;  // $AF:0280 - $AF:02FF (Internal Memory)
assign CS_Collision_Registers =  (Bus_A_i[23:8]  == 16'b1010_1111_0000_0011)  		& Valid_Address;  // $AF:0300 - $AF:03FF (Internal Memory)
assign CS_VDMA_Controller    	=  (Bus_A_i[23:5]  == 19'b1010_1111_0000_0100_000)		& Valid_Address;  // $AF:0400 - $AF:041F (Internal Memory)
assign CS_SDMA_Controller     =  (Bus_A_i[23:5]  == 19'b1010_1111_0000_0100_001)		& Valid_Address;  // $AF:0420 - $AF:043F (Internal Memory)
assign CS_MousePointerMem     =  (Bus_A_i[23:9]  == 15'b1010_1111_0000_010) 			& Valid_Address;  // $AF:0500 - $AF:06FF (Internal Memory)
assign CS_MousePointerReg     =  (Bus_A_i[23:4]  == 20'b1010_1111_0000_0111_0000) 	& Valid_Address;  // $AF:0700 - $AF:070F (Internal Memory)
assign CS_Sprites_Registers   =  (Bus_A_i[23:10] == 14'b1010_1111_0000_11) 			& Valid_Address;  // $AF:0C00 - $AF:0DFF (Internal Memory) 128 x 8 Sprites


assign CS_MULTIPLIER32x32 		=  (Bus_A_i[23:4]  == 20'b1010_1111_0001_0100_0000) 	& Valid_Address; 			// $AF:1400..$AF:140F <- Registers
// GABE Decoding - Just here for reference
//assign CS_RTC_o				   = ( CPU_A_i[23:4]  == 20'b1010_1111_0000_1000_0000) & Valid_Address;		// $AF:0800..$AF:080F
// GABE Decoding - Just here for reference
//assign CS_LPC_o               = ( CPU_A_i[23:10] == 14'b1010_1111_0001_00) & Valid_Address;				// $AF:1000..$AF:13FF

//	$7F:1800 - $7F:1EFF - Reserved - NOT USED (To Be Defined)
assign CS_Txt_Foreground_Plt  =  (((Bus_A_i >= 24'hAF1F40) && (Bus_A_i < 24'hAF1F80)) ? 1'b1 : 1'b0 ) & Valid_Address; 	// $AF:1F00 - $AF:173F (Internal Memory)
assign CS_Txt_Background_Plt  =  (((Bus_A_i >= 24'hAF1F80) && (Bus_A_i < 24'hAF1FC0)) ? 1'b1 : 1'b0 ) & Valid_Address; 	// $AF:1F40 - $AF:1F7F (Internal Memory)
//	$7F:1F80 - $7F:1FFF - Reserved - NOT USED (To Be Defined)
assign CS_LUT						=  (Bus_A_i[23:13] == 11'b1010_1111_001) & Valid_Address; // $AF:2000 - $AF:23FF (Internal Memory)
assign CS_GAMMA_B					=  (Bus_A_i[23:8] == 16'b1010_1111_0100_0000) & Valid_Address; // $AF:4000 - $AF:40FF (External Memory)	256 Bytes
assign CS_GAMMA_G					=  (Bus_A_i[23:8] == 16'b1010_1111_0100_0001) & Valid_Address; // $AF:4100 - $AF:41FF (External Memory)  256 Bytes
assign CS_GAMMA_R					=  (Bus_A_i[23:8] == 16'b1010_1111_0100_0010) & Valid_Address; // $AF:4200 - $AF:42FF (External Memory)  256 Bytes
                                                                 //0_0000_0000_0000
assign CS_FONT_Memory			=  (Bus_A_i[23:12] == 12'b1010_1111_1000) & Valid_Address; // $AF:8000 - $AF:87FF (External Memory) 4KBytes
assign CS_VID_Text_Char			=  (Bus_A_i[23:13] == 11'b1010_1111_101) & Valid_Address; // $AF:A000 - $AF:BFFF (Internal Memory)  2KBytes
assign CS_VID_Color_Char		=  (Bus_A_i[23:13] == 11'b1010_1111_110) & Valid_Address; // $AF:C000 - $AF:DFFF (Internal Memory)  2KBytes
assign CS_VIDEO_RAM				=  ((Bus_A_i[23:20] == 4'b1011) | (Bus_A_i[23:20] == 4'b1100) | (Bus_A_i[23:20] == 4'b1101) |  (Bus_A_i[23:20] == 4'b1110)) & Valid_Address; //$B0:0000 - $EF:FFFF - 4Meg Range of Video Memory

/* GABE - Address Decoding - So there is no conflict
// New Devices
// New Devices
assign CS_RTC_o				   = ( CPU_A_i[23:4]  == 20'b1010_1111_0000_1000_0000) & Valid_Address;		// $AF:0800..$AF:080F
assign CS_LPC_o               = ( CPU_A_i[23:10] == 14'b1010_1111_0001_00) & Valid_Address;				// $AF:1000..$AF:13FF
// BEATRIX Old Registers
assign CS_MATH_FLOAT_o  		= ( CPU_A_i[23:9]  == 15'b1010_1111_1110_001) & Valid_Address; 			// $AF:E200..$AF:E2FF <- Registers
assign CS_FPGA_SID_o 			= ( CPU_A_i[23:8]  == 16'b1010_1111_1110_0100) & Valid_Address; 			// $AF:E400..$AF:E4FF <- Registers
assign CS_OPL3_o					= ( CPU_A_i[23:9]  == 15'b1010_1111_1110_011) & Valid_Address; 			// $AF:E600..$AF:E7FF <- Registers
assign CS_TRINITY_o     		= ( CPU_A_i[23:5]  == 19'b1010_1111_1110_1000_000) & Valid_Address; 		// $AF:E800..$AF:E81F <- TRINITY (E800 - Joystick/RNG, E810 - CH376S)
assign CS_CH376     				= ( CPU_A_i[23:4]  == 20'b1010_1111_1110_1000_0001) & Valid_Address; 	// $AF:E810..$AF:E81F <- TRINITY (E800 - Joystick/RNG, E810 - CH376S)
assign CS_UNITY_o					= ( CPU_A_i[23:4]  == 20'b1010_1111_1110_1000_0011) & Valid_Address; 	// $AF:E830..$AF:E83F <- UNITY Chipset (IDE Ctrl)
assign CS_BEAT_CTRL_o			= ( CPU_A_i[23:6]  == 18'b1010_1111_1110_1000_01) & Valid_Address;   	// $AF:E840..$AF:E87F <- Registers	//64

assign CS_INT_REG_o				= ( CPU_A_i[23:3]  == 21'b1010_1111_1110_1000_1000_0) & Valid_Address; 	// $AF:E880..$AF:E887 <- INTERNAL Registers

assign CS_CODEC_o					= ( CPU_A_i[23:8]  == 16'b1010_1111_1110_1001) & Valid_Address; 			// $AF:E900..$AF:E9FF <- CODEC
assign CS_SDCARD_CTRL_o 		= ( CPU_A_i[23:8]  == 16'b1010_1111_1110_1010) & Valid_Address; 			// $AF:EA00..$AF:EAFF <- SD Controller
//assign CS_LPC_DMA_CTRL_o 		= ( CPU_A_i[23:8]  == 16'b1010_1111_1110_1011) & Valid_Address; 			// $AF:EB00..$AF:EBFF <- Floppy DMA Controller
//assign CS_LPC_DMA_DP_o 			= ( CPU_A_i[23:9]  == 15'b1010_1111_1110_110) & Valid_Address; 			// $AF:EC00..$AF:EDFF <- Floppy DMA Controller
//assign CS_LPC_DMA_DP_o			= ( CPU_A_i[23:9]  == 15'b1010_1111_1110_111) & Valid_Address; 			// $AF:EE00..$AF:EFFF <- 512Bytes of Buffers for Floppy
assign CS_OPM_o      			= ( CPU_A_i[23:8]  == 16'b1010_1111_1111_0000) & Valid_Address; 			// $AF:F000..$AF:F0FF <- OPM 
assign CS_PSG_o					= ( CPU_A_i[23:8]  == 16'b1010_1111_1111_0001) & Valid_Address; 			// $AF:F100..$AF:F1FF <- PSG
assign CS_OPN2_o					= ( CPU_A_i[23:9]  == 15'b1010_1111_1111_001) & Valid_Address; 		   // $AF:F200..$AF:F3FF <- OPN2 
assign CS_FLASH_o					= ( CPU_A_i[23:19] == 5'b1111_1) & ( CPU_VDA_i | CPU_VPA_i);				// $F8:0000..$FF:FFFF
*/



assign CS_Combined = ( 	{CS_VIDEO_RAM ,
								CS_VID_Color_Char ,
								CS_VID_Text_Char ,
								CS_FONT_Memory ,
								CS_GAMMA_R ,
								CS_GAMMA_G ,
								CS_GAMMA_B ,
								CS_LUT ,
								CS_Txt_Background_Plt ,
								CS_Txt_Foreground_Plt ,
								CS_MousePointerReg,
								CS_Sprites_Registers,
								CS_MULTIPLIER32x32 , 
								CS_SDMA_Controller ,
								CS_VDMA_Controller ,
								CS_Collision_Registers,
								CS_TileMAP1_Registers,
								CS_TileMAP0_Registers,
								CS_Bitmap_Registers,
								CS_Vicky_Registers} );

assign CS_Ored = ( 		CS_VIDEO_RAM |
								CS_VID_Color_Char |
								CS_VID_Text_Char |
								CS_FONT_Memory | 
								CS_GAMMA_R | 
								CS_GAMMA_G | 
								CS_GAMMA_B |
								CS_LUT | 
								CS_Txt_Background_Plt |
								CS_Txt_Foreground_Plt |
								CS_MousePointerReg |
								CS_Sprites_Registers |
								CS_MULTIPLIER32x32 | 
								CS_SDMA_Controller | 
								CS_VDMA_Controller |
								CS_Collision_Registers |
								CS_TileMAP1_Registers |
								CS_TileMAP0_Registers |
								CS_Bitmap_Registers |
								CS_Vicky_Registers );

// if Any of the Selected Chip Select & Read Strobe is 1, let's open the gate!
//assign DataOut_Oe_o = Bus_RW_i & CS_Ored & Bus_Clk_i;
//assign DataOut_Oe_o = (Bus_RDY_i & Bus_RDY_i) ?  1'b1 : 1'b0;
//assign DataOut_Oe_o = LPC_Data_Out_Ready_i;

reg [2:0] 	rst_resync;

always @ (posedge Bus_Clk_i)
begin
		rst_resync[0] <= rst;
		rst_resync[1] <= rst_resync[0];
		rst_resync[2] <= rst_resync[1];
end

assign 	DataOut_o = DataOut;
assign 	DataOut_Oe_o = Bus_RW_i & CS_Ored & Bus_Clk_i;

always @ (*)
	case (CS_Combined)
		20'b0000_0000_0000_0000_0000: begin DataOut = 8'hFF; 							 end
		20'b0000_0000_0000_0000_0001: begin DataOut = DataOut_Register_Level_i;	 end
		20'b0000_0000_0000_0000_0010: begin DataOut = DataOut_Bitmap_Regs_i; 	 end
		20'b0000_0000_0000_0000_0100: begin DataOut = DataOut_Tile0_Regs_i; 		 end
		20'b0000_0000_0000_0000_1000: begin DataOut = DataOut_Tile1_Regs_i; 		 end
		20'b0000_0000_0000_0001_0000: begin DataOut = DataOut_Collisions_Regs_i; end
		20'b0000_0000_0000_0010_0000: begin DataOut = DataOut_VDMA_Controller_i; end
		20'b0000_0000_0000_0100_0000: begin DataOut = DataOut_SDMA_Controller_i; end	
		20'b0000_0000_0000_1000_0000: begin DataOut = DataOut_Multiplier32x32_i; end
		20'b0000_0000_0001_0000_0000: begin DataOut = DataOut_Sprites_Regs_i;	 end
		20'b0000_0000_0010_0000_0000: begin DataOut = DataOut_MousePointer_i; 	 end
		20'b0000_0000_0100_0000_0000: begin DataOut = DataOut_Txt_Clr_FG_Plt_i;  end
		20'b0000_0000_1000_0000_0000: begin DataOut = DataOut_Txt_Clr_BG_Plt_i;  end
		20'b0000_0001_0000_0000_0000: begin DataOut = DataOut_Grphc_Clr_Plt0_i;  end
		20'b0000_0010_0000_0000_0000: begin DataOut = DataOut_GAMMA_B_i; 			 end		
		20'b0000_0100_0000_0000_0000: begin DataOut = DataOut_GAMMA_G_i; 			 end
		20'b0000_1000_0000_0000_0000: begin DataOut = DataOut_GAMMA_R_i; 			 end
		20'b0001_0000_0000_0000_0000: begin DataOut = DataOut_Font_Memory_i; 	 end
		20'b0010_0000_0000_0000_0000: begin DataOut = DataOut_TextMemory_i; 		 end
		20'b0100_0000_0000_0000_0000: begin DataOut = DataOut_ColorMemory_i; 	 end
		20'b1000_0000_0000_0000_0000: begin DataOut = DataOut_VideoMemory_i; 	 end
		default: begin DataOut = 8'h00; end
endcase


wire 	DataOut_ColorMemory_RDY;
wire 	DataOut_TextMemory_RDY;
wire 	DataOut_Font_Memory_RDY;
wire 	DataOut_GAMMA_R_RDY;
wire 	DataOut_GAMMA_G_RDY;
wire 	DataOut_GAMMA_B_RDY;
wire  DataOut_Tile_Map_RDY;

reg 	CS_VID_Color_Char_DLY;
reg 	CS_VID_Text_Char_DLY;
reg   CS_FONT_Memory_DLY;
reg 	CS_GAMMA_R_DLY;
reg 	CS_GAMMA_G_DLY;
reg 	CS_GAMMA_B_DLY;


assign DataOut_ColorMemory_RDY = ( CS_VID_Color_Char & Bus_RW_i ) ? ( CS_VID_Color_Char & !CS_VID_Color_Char_DLY )  : 1'b0;
assign DataOut_TextMemory_RDY =  ( CS_VID_Text_Char  & Bus_RW_i ) ? ( CS_VID_Text_Char  & !CS_VID_Text_Char_DLY ) : 1'b0;
assign DataOut_Font_Memory_RDY = ( CS_FONT_Memory    & Bus_RW_i ) ? ( CS_FONT_Memory    & !CS_FONT_Memory_DLY ) : 1'b0;
assign DataOut_GAMMA_R_RDY = ( CS_GAMMA_R & Bus_RW_i ) ? (CS_GAMMA_R & !CS_GAMMA_R_DLY) : 1'b0;
assign DataOut_GAMMA_G_RDY = ( CS_GAMMA_G & Bus_RW_i ) ? (CS_GAMMA_G & !CS_GAMMA_G_DLY) : 1'b0;
assign DataOut_GAMMA_B_RDY = ( CS_GAMMA_B & Bus_RW_i ) ? (CS_GAMMA_B & !CS_GAMMA_B_DLY) : 1'b0;


always @ (negedge Bus_Clk_i) 
begin
	CS_VID_Color_Char_DLY <= CS_VID_Color_Char;
	CS_VID_Text_Char_DLY <= CS_VID_Text_Char;
	CS_FONT_Memory_DLY <= CS_FONT_Memory;
	CS_GAMMA_R_DLY <= CS_GAMMA_R;
	CS_GAMMA_G_DLY <= CS_GAMMA_G;
	CS_GAMMA_B_DLY <= CS_GAMMA_B;
end


assign Bus_RDY_o = (DataOut_ColorMemory_RDY | DataOut_TextMemory_RDY | DataOut_GAMMA_R_RDY | DataOut_GAMMA_G_RDY | DataOut_GAMMA_B_RDY | DataOut_Font_Memory_RDY );

// Generate Write Strobe for all the Different Dual Port Memory in Vicky
//assign WR_Vicky_Registers_o = ( CS_Vicky_Registers & !Bus_RW_i );
//assign WR_VID_SuperIO_o = ( CS_VID_SuperIO & !Bus_RW_i);
//assign WR_DMA_Controller_o = ( CS_DMA_Controller & !Bus_RW_i );
//assign WR_Txt_Foreground_Plt_o = ( CS_Txt_Foreground_Plt & !Bus_RW_i );
//assign WR_Txt_Background_Plt_o = ( CS_Txt_Background_Plt & !Bus_RW_i );
//assign WR_Grphc_Plt_0_o = ( CS_Grphc_Plt_0 & !Bus_RW_i );
//assign WR_Grphc_Plt_1_o = ( CS_Grphc_Plt_1 & !Bus_RW_i );
//assign WR_Grphc_Plt_2_o = ( CS_Grphc_Plt_2 & !Bus_RW_i );
///assign WR_Grphc_Plt_3_o = ( CS_Grphc_Plt_3 & !Bus_RW_i );
//assign WR_Grphc_Plt_4_o = ( CS_Grphc_Plt_4 & !Bus_RW_i );
//assign WR_Grphc_Plt_5_o = ( CS_Grphc_Plt_5 & !Bus_RW_i );
//assign WR_Grphc_Plt_6_o = ( CS_Grphc_Plt_6 & !Bus_RW_i );
//assign WR_Global_Gamma_o = ( CS_Global_Gamma & !Bus_RW_i );
//assign WR_VID_Text_Char_o = ( CS_VID_Text_Char & !Bus_RW_i );
//assign WR_VID_Color_Char_o = ( CS_VID_Color_Char & !Bus_RW_i );


/*
wire	[7:0]		PeekPoke;
wire	[63:0]	ChipScope;
wire				Trigger;

assign ChipScope[23:0] = Bus_A_i;
assign ChipScope[31:24] = DataOut_LPC_Interface_i;
assign ChipScope[39:32] = DataOut_o;
assign ChipScope[40] = Bus_RW_i;
assign ChipScope[41] = DataOut_Oe_o;
assign ChipScope[42] = LPC_Data_Out_Ready_i;
assign ChipScope[43] = CS_VID_SuperIO;
assign ChipScope[44] = 1'b0;
assign ChipScope[45] = Bus_RDY_i;
assign ChipScope[46] = 1'b0;
assign ChipScope[47] = 1'b0;
assign ChipScope[63:48] = CS_Combined;


assign Trigger = CS_Ored;
//assign Trigger = (Bus_A_i[23:0] == 24'h7F1064) ? 1'b1 : 1'b0;

	ChipScope u0 (
		.acq_clk        (!Bus_Clk_i),        //    acq_clk.clk
		.acq_data_in    (ChipScope),    //        tap.acq_data_in
		.acq_trigger_in (Trigger), //           .acq_trigger_in
		.trigger_in     (Trigger)      // trigger_in.trigger_in
	);
*/


endmodule


// assign CS_VID_SuperIO_o			=  (((Bus_A_i >= 24'h7F1000) && (Bus_A_i < 24'h7F1400)) ? 1'b1 : 1'b0) & !Bus_RW_i);	// $7F:1000 - $7F:13FF (Internal Memory)

// C256 FOENIX System Memory Map - September 23, 2018

//  CCC   222  55555  666        FFFFF  OOO  EEEEE N   N IIIII X   X       SSSSS Y   Y SSSSS       M   M EEEEE M   M       M   M  AAA  PPPP
// C   C 2   2 5     6   6       F     O   O E     NN  N   I   X   X       S     Y   Y S           MM MM E     MM MM       MM MM A   A P   P
// C        2  5     6           F     O   O E     NN  N   I    X X        S      YYY  S           MMMMM E     MMMMM       MMMMM A   A P   P
// C       2   5555  6666        FFFFF O   O EEEEE N N N   I    XXX        SSSSS   Y   SSSSS       M M M EEEEE M M M       M M M AAAAA PPPP
// C      2        5 6   6       F     O   O E	   N  NN   I    X X            S   Y       S       M M M E	   M M M       M M M A   A P
// C   C 2     5   5 6   6       F     O   O E	   N  NN   I   X   X           S   Y       S       M M M E	   M M M       M M M A   A P
//  CCC  22222  5555  666        F      OOO  EEEEE N   N IIIII X   X       SSSSS   Y   SSSSS       M M M EEEEE M M M       M M M A   A P

//	$00:0000 - $0F:FFFF - Static RAM (Code Memory)
// $00:0100 - GVN - UNSIGNED MULT - Operand A L (W)
// $00:0101 - GVN - UNSIGNED MULT - Operand A H (W)
// $00:0102 - GVN - UNSIGNED MULT - Operand B L (W)
// $00:0103 - GVN - UNSIGNED MULT - Operand B H (W)
// $00:0104 - GVN - UNSIGNED MULT - Result L (R)
// $00:0105 - GVN - UNSIGNED MULT - Result H (R)
// $00:0106 - GVN - SIGNED MULT - Operand A L (W)
// $00:0107 - GVN - SIGNED MULT - Operand A H (W)
// $00:0108 - GVN - SIGNED MULT - Operand B L (W)
// $00:0109 - GVN - SIGNED MULT - Operand B H (W)
// $00:010A - GVN - SIGNED MULT - Result L (R)
// $00:010B - GVN - SIGNED MULT - Result H (R)
//	$00:010C .. $00:010F NOT USED (RAM)
// $00:0110 - GVN - UNSIGNED DIVISION - Dividend A L (W) (A/W)
// $00:0111 - GVN - UNSIGNED DIVISION - Dividend A H (W)
// $00:0112 - GVN - UNSIGNED DIVISION - Divisor B L (W)
// $00:0113 - GVN - UNSIGNED DIVISION - Divisor B H (W)
// $00:0114 - GVN - UNSIGNED DIVISION - Result L (R)
// $00:0115 - GVN - UNSIGNED DIVISION - Result H (R)
// $00:0116 - GVN - SIGNED DIVISION - Dividend A L (W)
// $00:0117 - GVN - SIGNED DIVISION - Dividend A H (W)
// $00:0118 - GVN - SIGNED DIVISION - Divisor B L (W)
// $00:0119 - GVN - SIGNED DIVISION - Divisor B H (W)
// $00:011A - GVN - SIGNED DIVISION - Result L (R)
// $00:011B - GVN - SIGNED DIVISION - Result H (R)
//	$00:011C - $00:011F NOT USED (RAM)
//	$00:0120 - $00:01FF - GVN - INTERRUPT CONTROL & SYSTEM CONTROL
//	$10:0000 - $6F:FFFF - FREE SPACE (6M)) - EXPANSION CARD - RAM
//	$70:0000 - $77:FFFF - SYSTEM FLASH (512K) - Only First 128K Copied to RAM
//	$78:0000 - $7B:FFFF - USER FLASH (256K) Socket
//	$7C:0000 - $7D:FFFF - FREE SPACE (128K) - EXPANSION CARD I/O or FLASH/EPROM/ROM (Automatic Wait State Insertion)
//	$7E:0000 - $7E:FFFF - LEGACY C64 ROM PAGE (Automatic Wait State Insertion)


//	$7F:0000 - $7F:03FF - VICKY Base Registers* (Subject to Change)
// $7F:0400 - $7F:04FF - BEATRIX Base Registers
// $7F:0500 - $7F:057F - BTX - SID 1 (Rev A: L Channel, Rev B: Mono Voice 1 to 3)
// $7F:0580 - $7F:05FF - BTX - SID 2 (Rev A: R Channel, Rev B: Mono Voice 4 to 6)
// $7F:0600 - $7F:06FF - BTX - YM3812 L
// $7F:0700 - $7F:07FF - BTX - YM3812 R
// $7F:0800 - $7F:0BFF - RTC (see BQ4802L Datasheets for more details)
//	$7F:0C00 - $7F:0CFF - CIA1 (see WDC65C22 Datasheets for more details) (C64 KeyBoard)
//	$7F:0D00 - $7F:0DFF - CIA2 (see WDC65C22 Datasheets for more details) (USER I/O - EIC)
//	$7F:0E00 - $7F:0EFF - CART I/O1 (C64 Legacy)
// $7F:0F00 - $7F:0FFF - CART I/O2 (C64 Legacy)
// $7F:1000 - $7F:13FF - SUPER IO Devices  --- (TOTAL USAGE) ---
//	$7F:1060 - $7F:1064 - LOGIC DEVICE 7 - KEYBOARD
//	$7F:1100 - $7F:117F - LOGIC DEVICE A - PME (Runtime Registers) - Keyboard Code is here <<<
//	$7F:1200 - $7F:1200 - LOGIC DEVICE 9 - GAME PORT
//	$7F:12F8 - $7F:12FF - LOGIC DEVICE 5 - SERIAL 2
//	$7F:1330 - $7F:1331 - LOGIC DEVICE B - MPU-401
//	$7F:1378 - $7F:137F - LOGIC DEVICE 3 - PARALLEL PORT
//	$7F:13F0 - $7F:13F7 - LOGIC DEVICE 0 - FLOPPY CONTROLLER
//	$7F:13F8 - $7F:13FF - LOGIC DEVICE 4 - SERIAL 1
//	$7F:1400 - $7F:17FF - DMA Controller (To Be Developed)
//	$7F:1800 - $7F:1EFF - Reserved - NOT USED (To Be Defined)
// $7F:1F00 - $7F:1F3F - 16 Colors Text Mode Foreground Palette Definition
// $7F:1F40 - $7F:1F7F - 16 Color Text Mode Background Palette Definition
//	$7F:1F80 - $7F:1FFF - Reserved - NOT USED (To Be Defined)
// $7F:2000 - $7F:23FF - Palette 0 (1K) (Tiles or Sprite)
// $7F:2400 - $7F:27FF - Palette 1 (1K) (Tiles or Sprite)
// $7F:2800 - $7F:2BFF - Palette 2 (1K) (Tiles or Sprite)
// $7F:2C00 - $7F:2FFF - Palette 3 (1K) (Tiles or Sprite)
// $7F:3000 - $7F:33FF - Palette 4 (1K) (Tiles or Sprite)
// $7F:3400 - $7F:37FF - Palette 5 (1K) (Tiles or Sprite)
// $7F:3800 - $7F:3BFF - Palette 6 (1K) (Tiles or Sprite)
// $7F:3C00 - $7F:3FFF - Global Gamma Correction Palette (1K)
//	$7F:4000 - $7F:5FFF - FONT Memory Access (Not Sure if this is going to exist)
//	$7F:6000 - $7F:FFFF - Reserved - NOT USED (To Be Defined)
// $80:0000 - $FF:FFFF - MEDIA RAM - DDR (High Latency (12 Clock Cycles for each Access, Fast Burst Capability 200MB/Sec)
