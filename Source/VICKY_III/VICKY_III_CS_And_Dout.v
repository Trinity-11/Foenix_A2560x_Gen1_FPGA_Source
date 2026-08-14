module VICKY_III_CS_And_Dout (

// CPU Interface
input	wire					CPU_Clk_i,
input	wire		[31:0]		iBUS_A_i,
input	wire					iBUS_A_Valid_i,
input	wire		[7:0]		iBUS_D8_i,
input	wire		[15:0]		iBUS_D16_i,
input	wire		[31:0]		iBUS_D32_i,
input	wire		[1:0]		iBUS_D_Siz_i,
input	wire					iBUS_D_Valid_i,
input	wire					iBUS_RWn_i,
input	wire		[3:0]		iBUS_BE_i,

input	wire					iBUS_CS_VICKY_A_i,		//C4
input	wire					iBUS_CS_VICKY_MEM_A_i,	//C6 Block Text Mem
input	wire					iBUS_CS_VICKY_B_i,		//C8
input	wire					iBUS_CS_VICKY_MEM_B_i,	//CA Block Text Mem
// Channel A
output	wire					CS_TextMemory_A_o,
output	wire					CS_ColorMemory_A_o, 
output	wire					CS_BF_CLUT_A_o,
output	wire					CS_BG_CLUT_A_o,
output	wire					CS_VICKY_REG_A_o,
output	wire					CS_Mouse_Ptr_A_Graphics_o,
output	wire					CS_Mouse_Ptr_A_Registers_o,
output	wire					CS_FONT_A_o,
// General 
output	wire					CS_GAMMA_B_A_o,
output	wire					CS_GAMMA_G_A_o,
output	wire					CS_GAMMA_R_A_o,
// Data Coming in
input	wire		[31:0]		TextMemory_A_Dout_i,
input	wire		[31:0]		ColorMemory_A_Dout_i,
input	wire		[31:0]		VICKYIII_Reg_A_Dout_i,
input	wire		[31:0]   	MousePtr_Reg_A_Dout_i,
// General
input	wire		[31:0]		GAMMA_B_A_Dout_i,
input	wire		[31:0]		GAMMA_G_A_Dout_i,
input	wire		[31:0]		GAMMA_R_A_Dout_i,
// Channel B
output	wire					CS_TextMemory_B_o,
output	wire					CS_ColorMemory_B_o,
output	wire					CS_BF_CLUT_B_o,
output	wire					CS_BG_CLUT_B_o,
output	wire					CS_VICKY_REG_B_o,
// VGE
output	wire					CS_Bitmap_B_Registers_o,
output	wire					CS_Tile0_B_Registers_o,
output	wire					CS_Tile1_B_Registers_o,
output	wire					CS_Collisions_B_Registers_o,
output	wire					CS_Mouse_Ptr_B_Graphics_o,
output	wire					CS_Mouse_Ptr_B_Registers_o,
output	wire					CS_Sprites_B_Registers_o,
output	wire					CS_LUT0_B_o,
output	wire					CS_FONT_B_o,
output  wire	   				CS_MEMTEXT_o,
output 	wire	   				CS_MEMTEXT_LUT_o,
output 	wire	   				CS_MEMTEXT_FONT_o,
output  wire	   				CS_EMUTOS_GRAPH_o,
// General 
output	wire					CS_GAMMA_B_B_o,
output	wire					CS_GAMMA_G_B_o,
output	wire					CS_GAMMA_R_B_o,
// Data Coming in
input	wire		[31:0]		TextMemory_B_Dout_i,
input	wire		[31:0]		ColorMemory_B_Dout_i,
input	wire		[31:0]		VICKYIII_Reg_B_Dout_i,
input 	wire   		[31:0]		DataOut_EMUTOS_Graph_i,	
input  	wire    	[31:0]		DataOut_MEMTEXT_i,
input  	wire   		[31:0]		DataOut_MEMTEXT_LUT_i,
input  	wire    	[31:0]		DataOut_MEMTEXT_FONT_i,
// VGE
input	wire		[31:0]		DataOut_B_LUT_i,
input	wire		[31:0]		DataOut_B_VideoMemory_i,
input	wire		[31:0]		DataOut_B_Bitmap_Regs_i,
input	wire		[31:0]		DataOut_B_Tile0_Regs_i,
input	wire		[31:0]		DataOut_B_Tile1_Regs_i,
input	wire		[31:0]		DataOut_B_Collisions_Regs_i,
input	wire		[31:0]  	DataOut_B_Mouse_Regs_i,
input	wire		[31:0]		DataOut_B_Sprites_Regs_i,
// General
input	wire		[31:0]		GAMMA_B_B_Dout_i,
input	wire		[31:0]		GAMMA_G_B_Dout_i,
input	wire		[31:0]		GAMMA_R_B_Dout_i,
//Data out to CPU
output	reg		[31:0]	DataOut_o
);

////////////////////////////////////////////////////
/// CHANNEL A - REGISTERS
////////////////////////////////////////////////////
//	$00C4_0000 - $00C5_FFFF - VICKY Registers Channel A
// Channel A Registers
assign CS_VICKY_REG_A_o				= ( iBUS_A_i[16:7] == 10'b0_0000_0000_0) & iBUS_CS_VICKY_A_i;					// $FEC40000..$FEC4007F	- Control Registers
assign CS_Mouse_Ptr_A_Graphics_o	= ( iBUS_A_i[16:10] == 7'b0_0000_01) & iBUS_CS_VICKY_A_i;				// $FEC40400..$FEC40BFF	- Mouser Pointer graphics 16x16 ARGB x2
assign CS_Mouse_Ptr_A_Registers_o	= ( iBUS_A_i[16:8] ==  9'b0_0000_1100) & iBUS_CS_VICKY_A_i;				// $FEC40C00..$FEC40CFF	- Mouser Pointer Registers
assign CS_GAMMA_B_A_o 				= ( iBUS_A_i[16:8] ==  9'b0_0100_0000) & iBUS_CS_VICKY_A_i;						// $FEC44000..$FEC440FF	- GAMMA Blue
assign CS_GAMMA_G_A_o 				= ( iBUS_A_i[16:8] ==  9'b0_0100_0001) & iBUS_CS_VICKY_A_i;						// $FEC44100..$FEC441FF	- GAMMA Green
assign CS_GAMMA_R_A_o 				= ( iBUS_A_i[16:8] ==  9'b0_0100_0010) & iBUS_CS_VICKY_A_i;						// $FEC44200..$FEC442FF	- GAMMA Red
assign CS_FONT_A_o					= ( iBUS_A_i[16:12] ==  5'b0_1000) & iBUS_CS_VICKY_A_i;							// $FEC48000..$FEC48FFF	- FONT MEMORY
// Channel A TEXT MEM 
assign CS_TextMemory_A_o 			= (iBUS_A_i[16:14] == 3'b0_00) & iBUS_CS_VICKY_MEM_A_i;			 				//$FEC60000 - $FEC63FFF
assign CS_ColorMemory_A_o 			= (iBUS_A_i[16:14] == 3'b0_10) & iBUS_CS_VICKY_MEM_A_i;   		 				//$FEC68000 - $FEC6BFFF
assign CS_BF_CLUT_A_o				= (iBUS_A_i[16:06] == 11'b0_1100_0100_00) & iBUS_CS_VICKY_MEM_A_i;  			//$FEC6C400 - $FEC6C43F
assign CS_BG_CLUT_A_o      			= (iBUS_A_i[16:06] == 11'b0_1100_0100_01) & iBUS_CS_VICKY_MEM_A_i; 			//$FEC6C440 - $FEC6C47F

wire [7:0] CS_Combined_A;

assign CS_Combined_A 	= ( { CS_BG_CLUT_A_o,
										CS_BF_CLUT_A_o,
										CS_ColorMemory_A_o,
										CS_TextMemory_A_o,
										CS_GAMMA_R_A_o,
										CS_GAMMA_G_A_o,
										CS_GAMMA_B_A_o,
										CS_VICKY_REG_A_o });

reg [31:0]	DataOut_A;

always @ (*) begin
	case (CS_Combined_A)
		8'b0000_0000: begin DataOut_A = 32'hDEAD_BEEF;				end
		8'b0000_0001: begin DataOut_A = VICKYIII_Reg_A_Dout_i; 		end
		8'b0000_0010: begin DataOut_A = GAMMA_B_A_Dout_i; 			end
		8'b0000_0100: begin DataOut_A = GAMMA_G_B_Dout_i;			end
		8'b0000_1000: begin DataOut_A = GAMMA_R_B_Dout_i; 			end
		8'b0001_0000: begin DataOut_A = TextMemory_A_Dout_i; 		end
		8'b0010_0000: begin DataOut_A = ColorMemory_A_Dout_i; 		end
		8'b0100_0000: begin DataOut_A = 32'h2222_0000;				end
		8'b1000_0000: begin DataOut_A = 32'h1111_AAAA;  			end
		default: begin DataOut_A = 32'hFEED_B00B; end
	endcase
end

////////////////////////////////////////////////////
/// CHANNEL B - REGISTERS
////////////////////////////////////////////////////
//	$FEC8_0000 - $FEC9_FFFF - VICKY Registers Channel B
assign CS_VICKY_REG_B_o					= ( iBUS_A_i[16:7] == 10'b0_0000_0000_0) & iBUS_CS_VICKY_B_i;	// $FEC80000..$FEC8007F	- Control Registers
assign CS_Bitmap_B_Registers_o 			= ( iBUS_A_i[16:8] ==  9'b0_0000_0001) & iBUS_CS_VICKY_B_i;		// $FEC80100..$FEC801FF	- Bitmap Control Registers
assign CS_Tile0_B_Registers_o 			= ( iBUS_A_i[16:7] == 10'b0_0000_0010_0) & iBUS_CS_VICKY_B_i;	// $FEC80200..$FEC8027F	- TileMap Control Registers
assign CS_Tile1_B_Registers_o 			= ( iBUS_A_i[16:7] == 10'b0_0000_0010_1) & iBUS_CS_VICKY_B_i;	// $FEC80280..$FEC802FF	- TileSet Control Registers
assign CS_Collisions_B_Registers_o 		= ( iBUS_A_i[16:8] ==  9'b0_0000_0011) & iBUS_CS_VICKY_B_i;		// $FEC80300..$FEC803FF	- Collision Control Registers
assign CS_Mouse_Ptr_B_Graphics_o		= ( iBUS_A_i[16:10] == 7'b0_0000_01) & iBUS_CS_VICKY_B_i;		// $FEC80400..$FEC80BFF	- Mouser Pointer graphics 16x16 ARGB x2
assign CS_Mouse_Ptr_B_Registers_o		= ( iBUS_A_i[16:8] ==  9'b0_0000_1100) & iBUS_CS_VICKY_B_i;		// $FEC80C00..$FEC80CFF	- Mouser Pointer Registers

assign CS_Sprites_B_Registers_o 		= ( iBUS_A_i[16:12] == 5'b0_0001) & iBUS_CS_VICKY_B_i;			// $FEC81000..$FEC81FFF	- Sprites Registers
assign CS_LUT0_B_o 						= ( iBUS_A_i[16:13] == 4'b0_001) & iBUS_CS_VICKY_B_i;			// $FEC82000..$FEC83FFF	- LUT
assign CS_GAMMA_B_B_o 					= ( iBUS_A_i[16:8]  == 9'b0_0100_0000) & iBUS_CS_VICKY_B_i;		// $FEC84000..$FEC840FF	- GAMMA Blue
assign CS_GAMMA_G_B_o 					= ( iBUS_A_i[16:8] 	== 9'b0_0100_0001) & iBUS_CS_VICKY_B_i;		// $FEC84100..$FEC841FF	- GAMMA Green
assign CS_GAMMA_R_B_o 					= ( iBUS_A_i[16:8] 	== 9'b0_0100_0010) & iBUS_CS_VICKY_B_i;		// $FEC84200..$FEC842FF	- GAMMA Red
assign CS_FONT_B_o						= ( iBUS_A_i[16:12] == 5'b0_1000) & iBUS_CS_VICKY_B_i;			// $FEC88000..$FEC88FFF	- FONT MEMORY
// New Elements
assign CS_EMUTOS_GRAPH_o  				= ( iBUS_A_i[16:12] == 5'b1_0111) & iBUS_CS_VICKY_B_i;			// $FEC97000..$FEC97FFF - (4K) - EMUTOS Graphics
assign CS_MEMTEXT_o						= ( iBUS_A_i[16:12] == 5'b1_1000) & iBUS_CS_VICKY_B_i;			// $FEC98000..$FEC98FFF - (4K) - MEMTEXT Control Registers
assign CS_MEMTEXT_LUT_o					= ( iBUS_A_i[16:12] == 5'b1_1001) & iBUS_CS_VICKY_B_i;			// $FEC99000..$FEC99FFF - (4K) - MEMTEXT LUT TABLES
assign CS_MEMTEXT_FONT_o 				= ( iBUS_A_i[16:13] == 4'b1_101) & iBUS_CS_VICKY_B_i;			// $FEC9A000..$FEC9BFFF - (4K) - MEMTEXT FONT MEMORY


//	$00CA_0000 - $00CB_FFFF - VICKY TEXT MODE Internal Memory and CLUT
// Channel B
assign CS_TextMemory_B_o 		= (iBUS_A_i[16:14] == 3'b000) & iBUS_CS_VICKY_MEM_B_i;									//$FECA0000 - $FECA3FFF
assign CS_ColorMemory_B_o 		= (iBUS_A_i[16:14] == 3'b010) & iBUS_CS_VICKY_MEM_B_i;   								//$FECA8000 - $FECABFFF
assign CS_BF_CLUT_B_o			= (iBUS_A_i[16:06] == 11'b0_1100_0100_00) & iBUS_CS_VICKY_MEM_B_i;  					//$FECAC400 - $FECAC43F
assign CS_BG_CLUT_B_o      		= (iBUS_A_i[16:06] == 11'b0_1100_0100_01) & iBUS_CS_VICKY_MEM_B_i; 					//$FECAC440 - $FECAC47F

wire [8:0] CS_Combined_B;

assign CS_Combined_B 	= ( { CS_BG_CLUT_B_o, CS_BF_CLUT_B_o, CS_ColorMemory_B_o, CS_TextMemory_B_o, CS_MEMTEXT_FONT_o, CS_MEMTEXT_LUT_o, CS_MEMTEXT_o, CS_EMUTOS_GRAPH_o, CS_VICKY_REG_B_o });

reg [31:0]	DataOut_B;

always @ (*) begin
	case (CS_Combined_B)
		9'b0_0000_0000: begin DataOut_B = 32'hDEAD_BEEF;				end
		9'b0_0000_0001: begin DataOut_B = VICKYIII_Reg_B_Dout_i; 		end
		9'b0_0000_0010: begin DataOut_B = DataOut_EMUTOS_Graph_i; 		end
		9'b0_0000_0100: begin DataOut_B = DataOut_MEMTEXT_i;			end
		9'b0_0000_1000: begin DataOut_B = DataOut_MEMTEXT_LUT_i;		end
		9'b0_0001_0000: begin DataOut_B = DataOut_MEMTEXT_FONT_i;		end
		9'b0_0010_0000: begin DataOut_B = TextMemory_B_Dout_i;			end
		9'b0_0100_0000: begin DataOut_B = ColorMemory_B_Dout_i;			end
		9'b0_1000_0000: begin DataOut_B = 32'h2222_3333;				end
		9'b1_0000_0000: begin DataOut_B = 32'h6666_4444; 				end
		default: begin DataOut_B = 32'hDEAD_BEEF; end
	endcase
end

always @ ( * ) begin
	case ({iBUS_CS_VICKY_MEM_B_i, iBUS_CS_VICKY_B_i, iBUS_CS_VICKY_MEM_A_i, iBUS_CS_VICKY_A_i })
		4'b0001: begin DataOut_o = DataOut_A; end
		4'b0010: begin DataOut_o = DataOut_A; end
		4'b0100: begin DataOut_o = DataOut_B; end
		4'b1000: begin DataOut_o = DataOut_B; end
		default: begin DataOut_o = 32'hAAAA_AAAA; end
	endcase
end



endmodule

/*
// Control and Media
assign CS_GABE_Config_o			= ( iBUS_A_i[16:7] == 10'b0_0000_0000_0) & iBUS_CS_GABE_i;						// $00C00000..$00C0007F	- Control Registers
assign CS_RTC_o					= ( iBUS_A_i[16:7] == 10'b0_0000_0000_1) & iBUS_CS_GABE_i;						// $00C00000..$00C0008F	- Control Registers
assign CS_Interrupt_Ctrl_o		= ( iBUS_A_i[16:8] == 9'b0_0000_0001) & iBUS_CS_GABE_i;						// $00C00100..$00C001FF - Interrupt Controllers
assign CS_Timer_o					= ( iBUS_A_i[16:8] == 9'b0_0000_0010) & iBUS_CS_GABE_i;						// $00C00200..$00C002FF - Timer Block
assign CS_SDCard_o				= ( iBUS_A_i[16:8] == 9'b0_0000_0011) & iBUS_CS_GABE_i;						// $00C00300..$00C003FF - SD Card Controller
assign CS_IDE_o					= ( iBUS_A_i[16:8] == 9'b0_0000_0100) & iBUS_CS_GABE_i;						// $00C00400..$00C004FF - IDE
assign CS_Joystick_o				= ( iBUS_A_i[16:8] == 9'b0_0000_0101) & iBUS_CS_GABE_i;						// $00C00500..$00C005FF - JOYSTICK/JOYPAD

assign CS_NIC_o					= ( iBUS_A_i[16:9] == 8'b0_0000_011) & iBUS_CS_GABE_i;						// $00C00600..$00C007FF - NIC
// LPC Block
assign CS_LPC_o               = (iBUS_A_i[16:10] == 7'b0_0010_00) & iBUS_CS_GABE_i;							// $00C02000..$00C023FF - LPC 
// Math Block
assign CS_UNSIGNED_MULT_o		= ( iBUS_A_i[16:5]  == 12'b0_0011_0000_000) & iBUS_CS_GABE_i;				// $00C03000..$00C0301F	- 32 x 32 Unsigned 
assign CS_SIGNED_MULT_o 		= ( iBUS_A_i[16:5]  == 12'b0_0011_0000_001) & iBUS_CS_GABE_i;				// $00C03020..$00C0303F - 32 x 32 Signed
assign CS_UNSIGNED_DIV_o 		= ( iBUS_A_i[16:5]  == 12'b0_0011_0000_010) & iBUS_CS_GABE_i;				// $00C03040..$00C0305F - 32 x 32 Unsigned
assign CS_SIGNED_DIV_o 			= ( iBUS_A_i[16:5]  == 12'b0_0011_0000_011) & iBUS_CS_GABE_i;				// $00C03060..$00C0307F - 32 x 32 Signed

assign CS_MATH_FLOAT_o  		= ( iBUS_A_i[16:7]  == 8'b0_0100_000) & iBUS_CS_GABE_i; 						// $00C04000..$00C041FF - Float Module 
*/