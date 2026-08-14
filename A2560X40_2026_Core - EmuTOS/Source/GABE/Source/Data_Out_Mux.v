`timescale 1 ns / 1 ns

module Data_Out_Mux (

input		wire				RST_i,
input		wire				CPU_Clk_i,
input		wire	[7:0]		CPU_D_i,
input		wire	[23:0]	CPU_A_i,
input		wire				CPU_RW_i,
input		wire				CPU_VPA_i,
input		wire				CPU_VDA_i,
input		wire				CPU_RDY_i,
input		wire				CPU_VPn_i,
// Data Path from the different Block
input		wire	[7:0]		DataOut_LPC_Interface_i,
input		wire	[7:0]		DataOut_MathModule_i,
input		wire	[7:0]		DataOut_Interrupt_Ctrl_i,
input		wire	[7:0]		DataOut_Timer_i,
input		wire	[7:0]		DataOut_CODEC_i,
input		wire	[7:0]		DataOut_Math_Float_i,
input		wire	[7:0]		DataOut_FPGA_SID_i,
input		wire	[7:0]		DataOut_OPL3_i,
input		wire	[7:0]		DataOut_OPN2_i,
input		wire	[7:0]		DataOut_OPM_i,
input		wire	[7:0]		DataOut_Trinity_i,
input		wire	[7:0]		DataOut_Unity_i,
input		wire	[7:0]		DataOut_INT_REG_i,
input		wire	[7:0]		DataOut_SDCARD_CTRL_i,
// Data Path from the different Block
input		wire	[7:0]		DataOut_Register_Level_i,
input		wire	[7:0]		DataOut_Bitmap_Regs_i,
input		wire	[7:0] 	DataOut_Tile0_Regs_i,
input		wire	[7:0] 	DataOut_Tile1_Regs_i,
input		wire	[7:0] 	DataOut_Collisions_Regs_i,
input		wire	[7:0]		DataOut_VDMA_Controller_i,
input		wire	[7:0]		DataOut_SDMA_Controller_i,
input		wire  [7:0]    DataOut_VMEM_2_CPU_i,
input		wire	[7:0]		DataOut_Sprites_Regs_i,
input		wire	[7:0]		DataOut_Txt_Clr_FG_Plt_i,
input		wire	[7:0]		DataOut_Txt_Clr_BG_Plt_i,
input		wire	[7:0]		DataOut_LUT_i,
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
input		wire	[7:0]		DataOut_SUPERIO_U_i,
input		wire	[7:0]		DataOut_DACS_U_i,

// Write Strobe for every Dual-Port RAM in the system
output	wire				CS_UNSIGNED_MULT_o,
output	wire				CS_SIGNED_MULT_o,
output	wire				CS_UNSIGNED_DIV_o,
output	wire				CS_SIGNED_DIV_o,
output	wire				CS_Interrupt_Ctrl_o,
output	wire				CS_Timer_o,
output	wire				CS_RAM0_o,
output	wire				CS_RAM1_o,
output	wire				CS_RTC_o,
output	wire				CS_LPC_o,
output	wire				CS_FLASH_o,
output	wire				CS_Inhibit_CS_RAM_o,

output	wire				CS_EXPANSION_o,

output	wire				CS_MATH_FLOAT_o,  // Data Come through here - Internal Registers
output	wire				CS_FPGA_SID_o,		// Data Come through here - Internal Registers
output	wire				CS_OPL3_o,			// 
output	wire				CS_OPN2_o,			// 
output	wire				CS_OPM_o,			// 
output	wire				CS_PSG_o,			// 
output	wire				CS_TRINITY_o,		// This is just Chip Select (Includes CH376S/Joystick/RNG )
output	wire				CS_UNITY_o,			// This is just Chip Select (IDE Controller)	
output	wire				CS_INT_REG_o,		// Data Come through here - Internal Registers
output	wire				CS_BEAT_CTRL_o,	// Data Come through here - Internal Registers
output	wire				CS_CODEC_o,			// Data Come through here - Internal Registers
output	wire				CS_SDCARD_CTRL_o, // Data Come through here - Internal Registers

output	wire				CS_SUPERIO_U_o,	// C256 Foenix U - Specifics $AF:1800
output	wire				CS_DACS_U_o,		// C256 Foenix U - Specifics $AF:1900
// VICKY II
// Write Strobe for every Dual-Port RAM in the system
output	wire				CS_VIDEO_RAM_o,
output	wire				CS_GAMMA_B_o,
output	wire				CS_GAMMA_G_o,
output	wire				CS_GAMMA_R_o,
output	wire 				CS_VID_Color_Char_o,
output	wire 				CS_VID_Text_Char_o,
output	wire				CS_FONT_Memory_o,
output	wire				CS_LUT_o,
output	wire				CS_Txt_Background_Plt_o,
output	wire				CS_Txt_Foreground_Plt_o,
output	wire				CS_VDMA_Controller_o,
output	wire				CS_SDMA_Controller_o,
output	wire				CS_VMEM_2_CPU_o, 
output	wire				CS_Sprites_Registers_o,
output	wire				CS_TileMAP0_Registers_o,
output	wire				CS_TileMAP1_Registers_o,
output	wire				CS_Collision_Registers_o,
output	wire				CS_Bitmap_Registers_o,
output	wire				CS_Vicky_Registers_o,
output	wire				CS_MousePointerMem_o,
output	wire				CS_MousePointerReg_o,
output	wire				CS_MULTIPLIER32x32_o,
	
// BUS - Data Bus
output	wire				DataOut_Oe_o,
output	wire	[7:0]		DataOut_o,
output	wire				Bus_Rdy_o
);

// Chip Select Internal Strobe (Active 1)
wire 				Valid_Address;
//wire	[39:0] 	CS_Combined;		// Overall 39 Slots
//wire			 	CS_Ored;

wire	[20:0] 	CS_Combined_0;		// Overall 39 Slots
wire			 	CS_Ored_0;

wire	[20:0] 	CS_Combined_1;		// Overall 39 Slots
wire			 	CS_Ored_1;


//wire				CS_CH376;
//wire				VectorPull;
//wire				FlashBoot_LowMem;
wire 				CS_32BITSIDNGEDADD;
reg	[7:0]		DataOut;
reg	[7:0]		DataOut_ADDSIGNED;

//wire			CS_Inhibit_CS_RAM_o;

//assign VectorPull = 			!CPU_VPn_i & (CPU_A_i[23:5]  == 19'b0000_0000_1111_1111_111); //$00:FFE0 - $00:FFFF - VECTOR PULL
//assign FlashBoot_LowMem = 	 CPU_VPn_i & (CPU_A_i[23:8]  == 16'b0000_0000_1111_1111);		//$00:FF00 - $00:FFFF - BOOT SECTOR

assign CS_Inhibit_CS_RAM_o = (CS_UNSIGNED_MULT_o | CS_SIGNED_MULT_o | CS_UNSIGNED_DIV_o | CS_SIGNED_DIV_o | CS_32BITSIDNGEDADD | CS_Interrupt_Ctrl_o | CS_Timer_o );
assign Valid_Address = CPU_VDA_i & !CPU_VPA_i;
// Chip Select Regision
assign CS_RAM0_o					=  (( CPU_A_i[23:21]  == 3'b000) & CPU_Clk_i & ( CPU_VDA_i | CPU_VPA_i));	// $00:0000..$1F:FFFF
assign CS_RAM1_o					=  (( CPU_A_i[23:21]  == 3'b001) & CPU_Clk_i & ( CPU_VDA_i | CPU_VPA_i));  // $20:0000..$3F:FFFF

assign CS_UNSIGNED_MULT_o 			= ( CPU_A_i[23:3]  == 21'b0000_0000_0000_0001_0000_0) & Valid_Address;	// $00:0100..$00:0107
assign CS_SIGNED_MULT_o 			= ( CPU_A_i[23:3]  == 21'b0000_0000_0000_0001_0000_1) & Valid_Address;	// $00:0108..$00:010F
assign CS_UNSIGNED_DIV_o 			= ( CPU_A_i[23:3]  == 21'b0000_0000_0000_0001_0001_0) & Valid_Address;	// $00:0110..$00:0117
assign CS_SIGNED_DIV_o 				= ( CPU_A_i[23:3]  == 21'b0000_0000_0000_0001_0001_1) & Valid_Address;	// $00:0118..$00:011F
assign CS_32BITSIDNGEDADD   		= ( CPU_A_i[23:4]  == 20'b0000_0000_0000_0001_0010) & Valid_Address;	   // $00:0120..$00:012F
assign CS_Interrupt_Ctrl_o			= ( CPU_A_i[23:5]  == 19'b0000_0000_0000_0001_010) & Valid_Address;		// $00:0140..$00:015F
assign CS_Timer_o             	= ( CPU_A_i[23:5]  == 19'b0000_0000_0000_0001_011) & Valid_Address;		// $00:0160..$00:017F
//
assign CS_EXPANSION_o         	= ( CPU_A_i[23:16]  == 8'b1010_1110);												// $AE:0000 - $AE:FFFF 
// New Devices
assign CS_Vicky_Registers_o     	= ( CPU_A_i[23:8]  == 16'b1010_1111_0000_0000) 			& Valid_Address;	// $AF:0000 - $AF:00FF (Internal Memory) (VKYII)
assign CS_Bitmap_Registers_o    	= ( CPU_A_i[23:8]  == 16'b1010_1111_0000_0001) 			& Valid_Address;  // $AF:0100 - $AF:01FF (Internal Memory) (VKYII)
assign CS_TileMAP0_Registers_o  	= ( CPU_A_i[23:7]  == 17'b1010_1111_0000_0010_0) 		& Valid_Address;  // $AF:0200 - $AF:027F (Internal Memory) (VKYII)
assign CS_TileMAP1_Registers_o  	= ( CPU_A_i[23:7]  == 17'b1010_1111_0000_0010_1) 		& Valid_Address;  // $AF:0280 - $AF:02FF (Internal Memory) (VKYII)
assign CS_Collision_Registers_o 	= ( CPU_A_i[23:8]  == 16'b1010_1111_0000_0011)  		& Valid_Address;  // $AF:0300 - $AF:03FF (Internal Memory) (VKYII)
assign CS_VDMA_Controller_o    	= ( CPU_A_i[23:5]  == 19'b1010_1111_0000_0100_000)		& Valid_Address;  // $AF:0400 - $AF:041F (Internal Memory) (VKYII)
assign CS_SDMA_Controller_o     	= ( CPU_A_i[23:5]  == 19'b1010_1111_0000_0100_001)		& Valid_Address;  // $AF:0420 - $AF:043F (Internal Memory) (VKYII)
assign CS_MousePointerMem_o     	= ( CPU_A_i[23:9]  == 15'b1010_1111_0000_010) 			& Valid_Address;  // $AF:0500 - $AF:06FF (Internal Memory) (VKYII)
assign CS_MousePointerReg_o     	= ( CPU_A_i[23:4]  == 20'b1010_1111_0000_0111_0000) 	& Valid_Address;  // $AF:0700 - $AF:070F (Internal Memory) (VKYII)
assign CS_RTC_o				   	= ( CPU_A_i[23:4]  == 20'b1010_1111_0000_1000_0000)   & Valid_Address;	// $AF:0800..$AF:080F (GABE) 
assign CS_VMEM_2_CPU_o           = ( CPU_A_i[23:4]  == 20'b1010_1111_0000_1001_0000)   & Valid_Address;	// $AF:0900..$AF:090F  (VKYII)
assign CS_Sprites_Registers_o   	= ( CPU_A_i[23:10] == 14'b1010_1111_0000_11) 			& Valid_Address;  // $AF:0C00 - $AF:0DFF (Internal Memory) 128 x 8 Sprites  (VKYII)
assign CS_LPC_o               	= ( CPU_A_i[23:10] == 14'b1010_1111_0001_00) & Valid_Address;				// $AF:1000..$AF:13FF
assign CS_MULTIPLIER32x32_o 		= ( CPU_A_i[23:4]  == 20'b1010_1111_0001_0100_0000) 	& Valid_Address; 	// $AF:1400..$AF:140F <- Registers

assign CS_SUPERIO_U_o			 	= ( CPU_A_i[23:8] == 16'b1010_1111_0001_1000) & Valid_Address;				// $AF:1800..$AF:18FF (That ought to include Keyboard/mouse/and SimpleUART)
assign CS_DACS_U_o			 		= ( CPU_A_i[23:8] == 16'b1010_1111_0001_1001) & Valid_Address;				// $AF:1900..$AF:19FF (That ought to include Keyboard/mouse/and SimpleUART)

assign CS_Txt_Foreground_Plt_o  	= (((CPU_A_i >= 24'hAF1F40) && (CPU_A_i < 24'hAF1F80)) ? 1'b1 : 1'b0 ) & Valid_Address; 	// $AF:1F00 - $AF:173F (Internal Memory)
assign CS_Txt_Background_Plt_o  	= (((CPU_A_i >= 24'hAF1F80) && (CPU_A_i < 24'hAF1FC0)) ? 1'b1 : 1'b0 ) & Valid_Address; 	// $AF:1F40 - $AF:1F7F (Internal Memory)
assign CS_LUT_o						= ( CPU_A_i[23:13] == 11'b1010_1111_001) 					& Valid_Address; 	// $AF:2000 - $AF:3FFF (Internal Memory) 8K
// We have some Space Here
assign CS_GAMMA_B_o					= ( CPU_A_i[23:8] == 16'b1010_1111_0100_0000) & Valid_Address; 			// $AF:4000 - $AF:40FF (External Memory)	256 Bytes
assign CS_GAMMA_G_o					= ( CPU_A_i[23:8] == 16'b1010_1111_0100_0001) & Valid_Address; 			// $AF:4100 - $AF:41FF (External Memory)  256 Bytes
assign CS_GAMMA_R_o					= ( CPU_A_i[23:8] == 16'b1010_1111_0100_0010) & Valid_Address; 			// $AF:4200 - $AF:42FF (External Memory)  256 Bytes
// We have some Space Here
assign CS_FONT_Memory_o				= ( CPU_A_i[23:12] == 12'b1010_1111_1000) & Valid_Address; 					// $AF:8000 - $AF:87FF (External Memory) 4KBytes
assign CS_VID_Text_Char_o			= ( CPU_A_i[23:13] == 11'b1010_1111_101) & Valid_Address; 					// $AF:A000 - $AF:BFFF (Internal Memory)  2KBytes
assign CS_VID_Color_Char_o			= ( CPU_A_i[23:13] == 11'b1010_1111_110) & Valid_Address; 					// $AF:C000 - $AF:DFFF (Internal Memory)  2KBytes\
assign CS_MATH_FLOAT_o  			= ( CPU_A_i[23:9]  == 15'b1010_1111_1110_001) & Valid_Address; 			// $AF:E200..$AF:E2FF <- Registers
assign CS_FPGA_SID_o 				= ( CPU_A_i[23:8]  == 16'b1010_1111_1110_0100) & Valid_Address; 			// $AF:E400..$AF:E4FF <- Registers
assign CS_OPL3_o						= ( CPU_A_i[23:9]  == 15'b1010_1111_1110_011) & Valid_Address; 			// $AF:E600..$AF:E7FF <- Registers
assign CS_TRINITY_o     			= ( CPU_A_i[23:5]  == 19'b1010_1111_1110_1000_000) & Valid_Address; 		// $AF:E800..$AF:E81F <- TRINITY (E800 - Joystick/RNG, E810 - CH376S)
assign CS_UNITY_o						= ( CPU_A_i[23:4]  == 20'b1010_1111_1110_1000_0011) & Valid_Address; 	// $AF:E830..$AF:E83F <- UNITY Chipset (IDE Ctrl)
assign CS_BEAT_CTRL_o				= ( CPU_A_i[23:6]  == 18'b1010_1111_1110_1000_01) & Valid_Address;   	// $AF:E840..$AF:E87F <- Registers	//64
assign CS_INT_REG_o					= ( CPU_A_i[23:4]  == 20'b1010_1111_1110_1000_1000) & Valid_Address; 	// $AF:E880..$AF:E887 <- INTERNAL Registers
assign CS_CODEC_o						= ( CPU_A_i[23:8]  == 16'b1010_1111_1110_1001) & Valid_Address; 			// $AF:E900..$AF:E9FF <- CODEC
assign CS_SDCARD_CTRL_o 			= ( CPU_A_i[23:8]  == 16'b1010_1111_1110_1010) & Valid_Address; 			// $AF:EA00..$AF:EAFF <- SD Controller
assign CS_OPM_o      				= ( CPU_A_i[23:8]  == 16'b1010_1111_1111_0000) & Valid_Address; 			// $AF:F000..$AF:F0FF <- OPM 
assign CS_PSG_o						= ( CPU_A_i[23:8]  == 16'b1010_1111_1111_0001) & Valid_Address; 			// $AF:F100..$AF:F1FF <- PSG
assign CS_OPN2_o						= ( CPU_A_i[23:9]  == 15'b1010_1111_1111_001) & Valid_Address; 		   // $AF:F200..$AF:F3FF <- OPN2 
assign CS_FLASH_o						= ( CPU_A_i[23:19] == 5'b1111_1) & ( CPU_VDA_i | CPU_VPA_i);				// $F8:0000..$FF:FFFF
assign CS_VIDEO_RAM_o				= ((CPU_A_i[23:20] == 4'b1011) | (CPU_A_i[23:20] == 4'b1100) | (CPU_A_i[23:20] == 4'b1101) |  (CPU_A_i[23:20] == 4'b1110)) & Valid_Address; //$B0:0000 - $EF:FFFF - 4Meg Range of Video Memory

assign CS_Ored_0 		= ( 	1'b0 						|
									CS_VIDEO_RAM_o 		|
									CS_OPN2_o 				|
									CS_OPM_o 				|
									CS_SDCARD_CTRL_o 		|
									CS_CODEC_o 				|
									CS_INT_REG_o 			|
									CS_BEAT_CTRL_o 		|
									CS_UNITY_o 				|
									CS_TRINITY_o 			|
									CS_OPL3_o 				|
									CS_FPGA_SID_o 			|
									CS_MATH_FLOAT_o		|
									CS_VID_Color_Char_o 	|
									CS_VID_Text_Char_o 	|
									CS_FONT_Memory_o 		|
									CS_GAMMA_R_o 			|
									CS_GAMMA_G_o 			|
									CS_GAMMA_B_o 			|
									CS_LUT_o 				|
									CS_Txt_Background_Plt_o 
							);
									
									
assign CS_Ored_1 		= ( 	CS_Txt_Foreground_Plt_o 	|
									CS_DACS_U_o						|
									CS_SUPERIO_U_o					| 
									CS_MULTIPLIER32x32_o 		|
									CS_LPC_o 						|
									CS_Sprites_Registers_o		|
									CS_VMEM_2_CPU_o            |
									CS_MousePointerReg_o 		|
									CS_SDMA_Controller_o 		|
									CS_VDMA_Controller_o 		|
									CS_Collision_Registers_o	|
									CS_TileMAP1_Registers_o		|
									CS_TileMAP0_Registers_o		|
									CS_Bitmap_Registers_o		|
									CS_Vicky_Registers_o			|
									CS_Timer_o						|
									CS_Interrupt_Ctrl_o			|
									CS_32BITSIDNGEDADD			|
									CS_SIGNED_DIV_o				|
									CS_UNSIGNED_DIV_o				|
									CS_SIGNED_MULT_o				|
									CS_UNSIGNED_MULT_o	
								);


									
									
// if Any of the Selected Chip Select & Read Strobe is 1, let's open the gate!
assign DataOut_Oe_o = CPU_RW_i & (CS_Ored_0 | CS_Ored_1) & CPU_Clk_i;
assign DataOut_o = DataOut;


always @ (*) begin
	case ( {CS_Ored_1, CS_Ored_0} )
		2'b01: begin DataOut = DataOut0; end
		2'b10: begin DataOut = DataOut1; end
	default: begin DataOut = 8'hAD; end
	
	endcase
end

reg	[7:0]		DataOut0;
reg	[7:0]		DataOut1;

assign CS_Combined_0 	= (  {CS_VIDEO_RAM_o,
									CS_OPN2_o,
									CS_OPM_o,									
									CS_SDCARD_CTRL_o,
									CS_CODEC_o,
									CS_INT_REG_o,
									CS_BEAT_CTRL_o,
									CS_UNITY_o,									
									CS_TRINITY_o,
									CS_OPL3_o,
									CS_FPGA_SID_o,
									CS_MATH_FLOAT_o,
									CS_VID_Color_Char_o ,
									CS_VID_Text_Char_o ,
									CS_FONT_Memory_o ,									
									CS_GAMMA_R_o ,
									CS_GAMMA_G_o ,
									CS_GAMMA_B_o ,
									CS_LUT_o, 
								   CS_Txt_Background_Plt_o,
								   CS_Txt_Foreground_Plt_o	});

always @ (*) begin
	case (CS_Combined_0)
		21'b0_0000_0000_0000_0000_0000: begin DataOut0 = 8'hDE; 								end
		21'b1_0000_0000_0000_0000_0000: begin DataOut0 = DataOut_VideoMemory_i; 		end
		21'b0_1000_0000_0000_0000_0000: begin DataOut0 = DataOut_OPN2_i; 					end
		21'b0_0100_0000_0000_0000_0000: begin DataOut0 = DataOut_OPM_i;					end
		21'b0_0010_0000_0000_0000_0000: begin DataOut0 = DataOut_SDCARD_CTRL_i; 		end
		21'b0_0001_0000_0000_0000_0000: begin DataOut0 = DataOut_CODEC_i; 				end
		21'b0_0000_1000_0000_0000_0000: begin DataOut0 = DataOut_INT_REG_i;			 	end
		21'b0_0000_0100_0000_0000_0000: begin DataOut0 = 8'h55;  							end	
		21'b0_0000_0010_0000_0000_0000: begin DataOut0 = DataOut_Unity_i;					end
		21'b0_0000_0001_0000_0000_0000: begin DataOut0 = DataOut_Trinity_i;				end
		21'b0_0000_0000_1000_0000_0000: begin DataOut0 = DataOut_OPL3_i; 					end
		21'b0_0000_0000_0100_0000_0000: begin DataOut0 = DataOut_FPGA_SID_i; 			end
		21'b0_0000_0000_0010_0000_0000: begin DataOut0 = DataOut_Math_Float_i; 			end
		21'b0_0000_0000_0001_0000_0000: begin DataOut0 = DataOut_ColorMemory_i; 		end
		21'b0_0000_0000_0000_1000_0000: begin DataOut0 = DataOut_TextMemory_i; 			end		
		21'b0_0000_0000_0000_0100_0000: begin DataOut0 = DataOut_Font_Memory_i; 		end	
		21'b0_0000_0000_0000_0010_0000: begin DataOut0 = DataOut_GAMMA_R_i;				end
		21'b0_0000_0000_0000_0001_0000: begin DataOut0 = DataOut_GAMMA_G_i;				end
		21'b0_0000_0000_0000_0000_1000: begin DataOut0 = DataOut_GAMMA_B_i;				end
		21'b0_0000_0000_0000_0000_0100: begin DataOut0 = DataOut_LUT_i; 					end
		21'b0_0000_0000_0000_0000_0010: begin DataOut0 = DataOut_Txt_Clr_BG_Plt_i;		end
		21'b0_0000_0000_0000_0000_0001: begin DataOut0 = DataOut_Txt_Clr_FG_Plt_i;		end
		default: begin DataOut0 = 8'hAD; end
	endcase
end

assign CS_Combined_1 = ( { CS_DACS_U_o,
									CS_SUPERIO_U_o,
									CS_MULTIPLIER32x32_o ,
									CS_LPC_o ,									
									CS_Sprites_Registers_o,	
									CS_VMEM_2_CPU_o, // - New
									CS_MousePointerReg_o ,									
									CS_SDMA_Controller_o ,
									CS_VDMA_Controller_o ,
									CS_Collision_Registers_o,
									CS_TileMAP1_Registers_o,
									CS_TileMAP0_Registers_o,
									CS_Bitmap_Registers_o,
									CS_Vicky_Registers_o, 								
									CS_Timer_o , 			 	// $00:0160
									CS_Interrupt_Ctrl_o ,
									CS_32BITSIDNGEDADD,
									CS_SIGNED_DIV_o ,
									CS_UNSIGNED_DIV_o ,
									CS_SIGNED_MULT_o ,
									CS_UNSIGNED_MULT_o});

always @ (*) begin
	case (CS_Combined_1)		
		21'b0_0000_0000_0000_0000_0000: begin DataOut1 = 8'hDE; end		
		21'b1_0000_0000_0000_0000_0000: begin DataOut1 = DataOut_DACS_U_i;				end
		21'b0_1000_0000_0000_0000_0000: begin DataOut1 = DataOut_SUPERIO_U_i; 			end
		21'b0_0100_0000_0000_0000_0000: begin DataOut1 = DataOut_Multiplier32x32_i; 	end		
		21'b0_0010_0000_0000_0000_0000: begin DataOut1 = DataOut_LPC_Interface_i;		end
		21'b0_0001_0000_0000_0000_0000: begin DataOut1 = DataOut_Sprites_Regs_i; 		end
		21'b0_0000_1000_0000_0000_0000: begin DataOut1 = DataOut_VMEM_2_CPU_i;			end
		21'b0_0000_0100_0000_0000_0000: begin DataOut1 = DataOut_MousePointer_i; 		end
		21'b0_0000_0010_0000_0000_0000: begin DataOut1 = DataOut_SDMA_Controller_i; 	end
		21'b0_0000_0001_0000_0000_0000: begin DataOut1 = DataOut_VDMA_Controller_i; 	end
		21'b0_0000_0000_1000_0000_0000: begin DataOut1 = DataOut_Collisions_Regs_i; 	end
		21'b0_0000_0000_0100_0000_0000: begin DataOut1 = DataOut_Tile1_Regs_i; 			end
		21'b0_0000_0000_0010_0000_0000: begin DataOut1 = DataOut_Tile0_Regs_i; 			end
		21'b0_0000_0000_0001_0000_0000: begin DataOut1 = DataOut_Bitmap_Regs_i; 		end
		21'b0_0000_0000_0000_1000_0000: begin DataOut1 = DataOut_Register_Level_i; 	end
		21'b0_0000_0000_0000_0100_0000: begin DataOut1 = DataOut_Timer_i; 				end
		21'b0_0000_0000_0000_0010_0000: begin DataOut1 = DataOut_Interrupt_Ctrl_i; 	end
		21'b0_0000_0000_0000_0001_0000: begin DataOut1 = DataOut_ADDSIGNED; 				end
		21'b0_0000_0000_0000_0000_1000: begin DataOut1 = DataOut_MathModule_i;			end
		21'b0_0000_0000_0000_0000_0100: begin DataOut1 = DataOut_MathModule_i; 			end
		21'b0_0000_0000_0000_0000_0010: begin DataOut1 = DataOut_MathModule_i; 			end
		21'b0_0000_0000_0000_0000_0001: begin DataOut1 = DataOut_MathModule_i; 			end
		default: begin DataOut1 = 8'hAD; end
	endcase
end


// Addition to the Math module
// 32 Bit Signed Add (Sub)
//
always @ (negedge CPU_Clk_i)
begin

	if (CS_32BITSIDNGEDADD & !CPU_RW_i)begin
		case (CPU_A_i[3:0])
			4'b0000: begin A[7:0]   <= CPU_D_i; end
			4'b0001: begin A[15:8]  <= CPU_D_i; end
			4'b0010: begin A[23:16] <= CPU_D_i; end
			4'b0011: begin A[31:24] <= CPU_D_i; end
			4'b0100: begin B[7:0]   <= CPU_D_i; end
			4'b0101: begin B[15:8]  <= CPU_D_i; end
			4'b0110: begin B[23:16] <= CPU_D_i; end
			4'b0111: begin B[31:24] <= CPU_D_i; end
		   default: begin end
		endcase
	end
end

reg signed [31:0] 	A;
reg signed [31:0] 	B;
wire signed [31:0] 	Results;

assign Results = (A + B);

always @ (*)
begin
	case(CPU_A_i[3:0])
		// Unsigned Mult
		4'b0000: DataOut_ADDSIGNED = A[7:0];
		4'b0001: DataOut_ADDSIGNED = A[15:8];
		4'b0010: DataOut_ADDSIGNED = A[23:16];
		4'b0011: DataOut_ADDSIGNED = A[31:24];
		4'b0100: DataOut_ADDSIGNED = B[7:0];
		4'b0101: DataOut_ADDSIGNED = B[15:8];
		4'b0110: DataOut_ADDSIGNED = B[23:16];
		4'b0111: DataOut_ADDSIGNED = B[31:24];
		4'b1000: DataOut_ADDSIGNED = Results[7:0];
		4'b1001: DataOut_ADDSIGNED = Results[15:8];
		4'b1010: DataOut_ADDSIGNED = Results[23:16];
		4'b1011: DataOut_ADDSIGNED = Results[31:24];
	default: DataOut_ADDSIGNED = 8'hFF;
	endcase
end

wire IDE_RDY;

assign Bus_Rdy_o =  IDE_RDY;

wire Condition0;
wire Condition1;
wire Condition2;

//8 Bits Access
assign	Condition0 = (CS_UNITY_o & !CPU_A_i[3]); // When A3 = 0, Read and Write will get 7 Wait States

//16 bits Access		 // A = 1
assign  	Condition1 = (CS_UNITY_o & CPU_A_i[3] & CPU_A_i[0] & !CPU_RW_i) | (CS_UNITY_o & CPU_A_i[3] & CPU_RW_i);

assign Condition2 = Condition0 | Condition1;

//READY LOGIC FOR RTC
reg	[15:0]	IDE_RDY_SLICE;
assign IDE_RDY = ( Condition2 ) ? !IDE_RDY_SLICE[7] : 1'b0;
always @ (posedge CPU_Clk_i) 
begin
		if ( Condition2 )
			IDE_RDY_SLICE <= (IDE_RDY_SLICE[15:0] | {14'b000, CS_UNITY_o }) << 1'b1;
		else
			IDE_RDY_SLICE <= 16'h0000;
end

endmodule


