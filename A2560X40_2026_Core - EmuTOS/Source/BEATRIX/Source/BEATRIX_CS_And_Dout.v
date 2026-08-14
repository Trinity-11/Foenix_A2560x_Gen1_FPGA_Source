module BEATRIX_CS_And_Dout (

// CPU Interface
input		wire				CPU_Clk_i,
input		wire				Reset_i,
input		wire	[31:0]	iBUS_A_i,
input		wire				iBUS_A_Valid_i,
output	wire				iBUS_D_Valid_o,
input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]	iBUS_D16_i,
input		wire	[31:0]	iBUS_D32_i,
input		wire	[1:0]		iBUS_D_Siz_i,
input		wire				iBUS_RWn_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_CS_BEATRIX_i,

// Data Out Inputs
// Data Path from the different Block
input		wire	[31:0]	DataOut_CPU2DAC44_i,
input		wire	[31:0]	DataOut_CPU2DAC48_i,
input		wire	[31:0]	DataOut_Int_OPN2_i,			//x1
input		wire	[31:0]	DataOut_Int_OPM_i,			//x1
input		wire	[31:0]	DataOut_Int_L_SID_i,				//x3
input		wire	[31:0]	DataOut_Int_R_SID_i,				//x3
input		wire	[31:0]	DataOut_CODEC_i,
input		wire	[31:0]	DataOut_BEATRIX_Config_i,			//x1

output	wire				CS_CPU_2_DAC44_o,
output	wire				CS_CPU_2_DAC48_o,
output	wire				CS_OPL3_o,					// 
output	wire				CS_Ext_OPN2_o,				//
output	wire				CS_Ext_OPM_o,				//
output	wire				CS_Ext_PSG_o,				//
output	wire				CS_Ext_L_SID_o,				// L, R, S
output	wire				CS_Ext_R_SID_o,
output	wire				CS_Int_OPN2_o,		  		//
output	wire				CS_Int_OPM_o,				//
output	wire				CS_Int_L_PSG_o,			// Left
output	wire				CS_Int_R_PSG_o,			// Right
output	wire				CS_Int_S_PSG_o,			// Both
output	wire				CS_Int_L_SID_o,				//
output	wire				CS_Int_R_SID_o,				//
output	wire				CS_Int_S_SID_o,				//
output	wire				CS_YM2149_L_o,
output	wire				CS_YM2149_R_o,
output	wire				CS_YM2149_S_o,
output	wire				CS_CODEC_o,					// 
output	wire				CS_BEATRIX_Config_o,		//

output	reg	[31:0]	DataOut_o
);

//$00C0_0000 - $00C1_FFFF - GABE Registers (SuperIO/Math Block/SDCard/IDE/Ethernet/SDMA)assign CS_UNSIGNED_MULT_o 		= ( CPU_A_i[23:3]  == 21'b0000_0000_0000_0001_0000_0) & Valid_Address;	// $00:0100..$00:0107
//assign 	CS_GABE    		= ( Internal_Address[23:17] == 7'b1100_000 ) & ( UserData  | SuperData ); //$C0

// Control and Media
assign CS_BEATRIX_Config_o		= ( iBUS_A_i[16:8] == 9'b0_0000_0000) & iBUS_CS_BEATRIX_i;						// $FEC20000..$FEC200FF	- Control Registers
// PSG                                                                                                                  
assign CS_Ext_PSG_o				= ( iBUS_A_i[16:4] == 13'b0_0000_0001_0000) & iBUS_CS_BEATRIX_i;				// $FEC20100..$FEC2010F	- Extern PSG
assign CS_Int_L_PSG_o			= ( iBUS_A_i[16:4] == 13'b0_0000_0001_0001) & iBUS_CS_BEATRIX_i;				// $FEC20110..$FEC2011F	- Internal PSG - L Channel
assign CS_Int_R_PSG_o			= ( iBUS_A_i[16:4] == 13'b0_0000_0001_0010) & iBUS_CS_BEATRIX_i;				// $FEC20120..$FEC2012F	- Internal PSG - R Channel
assign CS_Int_S_PSG_o			= ( iBUS_A_i[16:4] == 13'b0_0000_0001_0011) & iBUS_CS_BEATRIX_i;				// $FEC20130..$FEC2013F	- Internal PSG - S Channel 
// External Devices                                                                                                     
assign CS_OPL3_o					= ( iBUS_A_i[16:9] == 8'b0_0000_001) & iBUS_CS_BEATRIX_i;						// $FEC20200..$FEC203FF - Extern OPL3
assign CS_Ext_OPN2_o				= ( iBUS_A_i[16:9] == 8'b0_0000_010) & iBUS_CS_BEATRIX_i;						// $FEC20400..$FEC205FF - Extern OPN2
assign CS_Ext_OPM_o				= ( iBUS_A_i[16:9] == 8'b0_0000_011) & iBUS_CS_BEATRIX_i;						// $FEC20600..$FEC207FF - Extern OPM
assign CS_Ext_L_SID_o			= ( iBUS_A_i[16:8] == 9'b0_0000_1000) & iBUS_CS_BEATRIX_i;						// $FEC20800..$FEC208FF - Extern Left SID
assign CS_Ext_R_SID_o			= ( iBUS_A_i[16:8] == 9'b0_0000_1001) & iBUS_CS_BEATRIX_i;						// $FEC20900..$FEC209FF - Extern Right SID
// Internal Devices                                                                                                     
assign CS_Int_OPN2_o				= ( iBUS_A_i[16:9] == 8'b0_0000_101) & iBUS_CS_BEATRIX_i;						// $FEC20A00..$FEC20BFF - Internal OPN2
assign CS_Int_OPM_o				= ( iBUS_A_i[16:9] == 8'b0_0000_110) & iBUS_CS_BEATRIX_i;						// $FEC20C00..$FEC20DFF - Internal OPM
assign CS_CODEC_o					= ( iBUS_A_i[16:9] == 8'b0_0000_111) & iBUS_CS_BEATRIX_i;						// $FEC20E00..$FEC20FFF - CODEC
                                                                                                                        
assign CS_Int_L_SID_o			= ( iBUS_A_i[16:9] == 8'b0_0001_000) & iBUS_CS_BEATRIX_i;						// $FEC21000..$FEC211FF - Internal SID Left
assign CS_Int_R_SID_o			= ( iBUS_A_i[16:9] == 8'b0_0001_001) & iBUS_CS_BEATRIX_i;						// $FEC21200..$FEC213FF - Internal SID Right
assign CS_Int_S_SID_o			= ( iBUS_A_i[16:9] == 8'b0_0001_010) & iBUS_CS_BEATRIX_i;						// $FEC21400..$FEC215FF - Internal SID Stereo
                                                                                                                        
assign CS_CPU_2_DAC48_o			= ( iBUS_A_i[16:8] == 9'b0_0010_0000) & iBUS_CS_BEATRIX_i;						// $FEC22000..$FEC220FF	- CPU 2 DAC - 48Khz
assign CS_CPU_2_DAC44_o			= ( iBUS_A_i[16:8] == 9'b0_0010_0001) & iBUS_CS_BEATRIX_i;						// $FEC22100..$FEC221FF	- CPU 2 DAC - 44Khz

assign CS_YM2149_L_o				= ( iBUS_A_i[16:9] == 8'b0_0011_000) & iBUS_CS_BEATRIX_i;						// $FEC23000..$FEC231FF - Internal YM2129 Left
assign CS_YM2149_R_o				= ( iBUS_A_i[16:9] == 8'b0_0011_001) & iBUS_CS_BEATRIX_i;						// $FEC23200..$FEC233FF - Internal YM2129 Right
assign CS_YM2149_S_o				= ( iBUS_A_i[16:9] == 8'b0_0011_010) & iBUS_CS_BEATRIX_i;						// $FEC23400..$FEC235FF - Internal YM2129 S Channel

wire [7:0] CS_Combined;

assign CS_Combined 	= ( { CS_CPU_2_DAC44_o, CS_CPU_2_DAC48_o, CS_Int_R_SID_o, CS_Int_L_SID_o, CS_CODEC_o, CS_Int_OPM_o, CS_Int_OPN2_o, CS_BEATRIX_Config_o });

always @ (*) begin
	case (CS_Combined)
		8'b0000_0000: begin DataOut_o = 32'hDEAD_BEEF; 						end
		8'b0000_0001: begin DataOut_o = DataOut_BEATRIX_Config_i; 	end
		8'b0000_0010: begin DataOut_o = DataOut_Int_OPN2_i; 			end
		8'b0000_0100: begin DataOut_o = DataOut_Int_OPM_i; 			end
		8'b0000_1000: begin DataOut_o = DataOut_CODEC_i; 				end		
		8'b0001_0000: begin DataOut_o = DataOut_Int_L_SID_i; 		end		
		8'b0010_0000: begin DataOut_o = DataOut_Int_R_SID_i; 		end
		8'b0100_0000: begin DataOut_o = DataOut_CPU2DAC48_i; 		end
		8'b1000_0000: begin DataOut_o = DataOut_CPU2DAC44_i; 		end
		default: begin DataOut_o = 32'hFEED_B00B; end
	endcase
end

assign iBUS_D_Valid_o = 1'b0;		// This is to extend DTACK Cycle


endmodule

