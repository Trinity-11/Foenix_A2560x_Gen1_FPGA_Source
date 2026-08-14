module GABE_CS_And_Dout (

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
input		wire				iBUS_CS_GABE_i,

// Data Out Inputs
// Data Path from the different Block
input		wire	[31:0]	DataOut_LPC_Interface_i,		//x1
input		wire	[31:0]	DataOut_Math_Fixed_i,			//x4
input		wire	[31:0]	DataOut_Math_Float_i,			//x1
input		wire	[31:0]	DataOut_Interrupt_Ctrl_i,		//x1
input		wire	[31:0]	DataOut_Timer_i,					//x1
input		wire	[31:0]	DataOut_SDCARD_CTRL_i,			//x1
input		wire	[31:0]	DataOut_IDE_ETH_DPS_i,				//x3
input		wire	[31:0]	DataOut_Joystick_i,				//x1
input		wire	[31:0]	DataOut_RTC_i,		
input		wire	[31:0]	DataOut_GABE_Config_i,			//x1
input		wire	[31:0]	DataOut_A2560K_KB_i,

output	wire				CS_LPC_o,					// LPC
output	wire				CS_MATH_FIXED_o,		// Math Block
output	wire				CS_MATH_FLOAT_o,  		// Data Come through here - Internal Registers
output	wire				CS_Interrupt_Ctrl_o,		// Interrupt Controller
output	wire				CS_Timer_o,					// Timer Block
output	wire				CS_SDCard_o,				// SDCard Controller
output	wire				CS_IDE_o,					// IDE Controller
output	wire				CS_NIC_o,					// Network Interface Controller
output	wire				CS_Joystick_o,				// Joystick
output	wire				CS_RTC_o,
output	wire				CS_GABE_Config_o,			// GABE Control Registers
output	wire				CS_A2560K_KB_o,
output	wire				CS_MAUS_RGB_o,		

output	reg		[31:0]		DataOut_o,

output	wire				Wait_SDCard_TA_o
);

//$00C0_0000 - $00C1_FFFF - GABE Registers (SuperIO/Math Block/SDCard/IDE/Ethernet/SDMA)assign CS_UNSIGNED_MULT_o 		= ( CPU_A_i[23:3]  == 21'b0000_0000_0000_0001_0000_0) & Valid_Address;	// $00:0100..$00:0107
//assign 	CS_GABE    		= ( Internal_Address[23:17] == 7'b1100_000 ) & ( UserData  | SuperData ); //$C0

// Control and Media
assign CS_GABE_Config_o			= ( iBUS_A_i[16:6] == 11'b0_0000_0000_00) & iBUS_CS_GABE_i;					// $FEC00000..$FEC0003F	- Control Registers
assign CS_A2560K_KB_o			= ( iBUS_A_i[16:6] == 11'b0_0000_0000_01) & iBUS_CS_GABE_i;					// $FEC00040..$FEC0007F	- Control Registers
assign CS_RTC_o					= ( iBUS_A_i[16:7] == 10'b0_0000_0000_1) & iBUS_CS_GABE_i;					// $FEC00080..$FEC0008F	- Control Registers
assign CS_Interrupt_Ctrl_o		= ( iBUS_A_i[16:8] == 9'b0_0000_0001) & iBUS_CS_GABE_i;						// $FEC00100..$FEC001FF - Interrupt Controllers
assign CS_Timer_o				= ( iBUS_A_i[16:8] == 9'b0_0000_0010) & iBUS_CS_GABE_i;						// $FEC00200..$FEC002FF - Timer Block
assign CS_SDCard_o				= ( iBUS_A_i[16:8] == 9'b0_0000_0011) & iBUS_CS_GABE_i;						// $FEC00300..$FEC003FF - SD Card Controller
assign CS_IDE_o					= ( iBUS_A_i[16:8] == 9'b0_0000_0100) & iBUS_CS_GABE_i;						// $FEC00400..$FEC004FF - IDE
assign CS_Joystick_o			= ( iBUS_A_i[16:8] == 9'b0_0000_0101) & iBUS_CS_GABE_i;						// $FEC00500..$FEC005FF - JOYSTICK/JOYPAD
assign CS_NIC_o					= ( iBUS_A_i[16:9] == 8'b0_0000_011) & iBUS_CS_GABE_i;						// $FEC00600..$FEC007FF - NIC
assign CS_MAUS_RGB_o			= ( iBUS_A_i[16:9] == 8'b0_0001_000) & iBUS_CS_GABE_i;						// $FEC01000..$FEC011FF - Keyboard RGB Matrix
// LPC Block
assign CS_LPC_o               	= (iBUS_A_i[16:10] == 7'b0_0010_00) & iBUS_CS_GABE_i;							// $FEC02000..$FEC023FF - LPC 
// Math Block
assign CS_MATH_FIXED_o		   	= ( iBUS_A_i[16:7] == 10'b0_0011_0000_0) & iBUS_CS_GABE_i;				   // $FEC03000..$FEC0301F	- 32 x 32 Unsigned 
assign CS_MATH_FLOAT_o  		= ( iBUS_A_i[16:9] ==  8'b0_0100_000) & iBUS_CS_GABE_i; 						// $FEC04000..$FEC041FF - Float Module            

wire [11:0] CS_Combined;

assign CS_Combined 	= ( { CS_MATH_FLOAT_o, CS_MATH_FIXED_o, CS_LPC_o, CS_NIC_o, CS_Joystick_o, CS_IDE_o, CS_SDCard_o, CS_Timer_o, CS_Interrupt_Ctrl_o, CS_RTC_o, CS_A2560K_KB_o, CS_GABE_Config_o });

always @ (*) begin
	case (CS_Combined)
		12'b000000000000: begin DataOut_o = 32'hDEAD_BEEF; 								end
		12'b000000000001: begin DataOut_o = DataOut_GABE_Config_i; 						end
		12'b000000000010: begin DataOut_o = DataOut_A2560K_KB_i; 						end		
		12'b000000000100: begin DataOut_o = DataOut_RTC_i; 								end
		12'b000000001000: begin DataOut_o = DataOut_Interrupt_Ctrl_i;					end
		12'b000000010000: begin DataOut_o = DataOut_Timer_i; 								end
		12'b000000100000: begin DataOut_o = DataOut_SDCARD_CTRL_i; 						end
		12'b000001000000: begin DataOut_o = DataOut_IDE_ETH_DPS_i; 						end
		12'b000010000000: begin DataOut_o = DataOut_Joystick_i; 							end
		12'b000100000000: begin DataOut_o = DataOut_IDE_ETH_DPS_i; 						end
		12'b001000000000: begin DataOut_o = DataOut_LPC_Interface_i;					end
		12'b010000000000: begin DataOut_o = DataOut_Math_Fixed_i; 						end
		12'b100000000000: begin DataOut_o = DataOut_Math_Float_i; 						end
		default: begin DataOut_o = 32'hB00B_FEED; end
	endcase
end



assign iBUS_D_Valid_o = 1'b0;

reg [15:0]	SDCard_Slide;


always @ ( posedge CPU_Clk_i ) begin
	if (Reset_i) begin
		SDCard_Slide <= 16'h0000;
	
	end 
	else begin
		if ( CS_SDCard_o ) begin
			SDCard_Slide <= {SDCard_Slide[14:0], iBUS_A_Valid_i};
		end
		else begin
			SDCard_Slide <= 16'h0000;		
		end
	end
end

//assign Wait_SDCard_TA_o = iBUS_RWn_i ? SDCard_Slide[2] : SDCard_Slide[0];	// 

assign Wait_SDCard_TA_o = SDCard_Slide[2];	// 

// Wait State insertion for the SDCard Controller

/*
reg 	[1:0]	TinySM;
reg	[15:0] CountDownDTACK;


always @ (posedge CPU_Clk_i) begin
	if (Reset_i) begin
		CountDownDTACK	<= 16'h0000;
		TinySM			<= 2'b00;
	end
	else begin
		CountDownDTACK <= CountDownDTACK << 1'b1;
	
		case (TinySM) 
			2'b00: begin
				if (CS_SDCard_o & iBUS_RWn_i)  begin
						CountDownDTACK <= 16'hFFFE;					
					TinySM <= 2'b01;
				end
				else begin
					CountDownDTACK <= 16'h0000;
					TinySM <= 2'b00;				
				end
			end
		
			2'b01: begin 
				if (iBUS_D_Valid_o) begin
					TinySM <= 2'b01;				
				end
				else begin
					TinySM <= 2'b10;				
				end
			end
		
			2'b10: begin 
					TinySM <= 2'b11;
			end
		
			2'b11: begin 
					TinySM <= 2'b00;			
			end
		
		endcase
	
	end

end
*/
endmodule

