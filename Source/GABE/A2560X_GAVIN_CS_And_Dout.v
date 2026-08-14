module A2560X_GAVIN_CS_And_Dout (
// CPU Interface
input		wire				iBUS_1xClk_i,
input       wire    			iBUS_2xClk_i,
input		wire				Reset_i,
input		wire	[31:0]	    iBUS_A_i,
input		wire				iBUS_A_Valid_i,
output	    wire				iBUS_D_Valid_o,
input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]	    iBUS_D16_i,
input		wire	[31:0]	    iBUS_D32_i,
input		wire	[1:0]		iBUS_D_Siz_i,
input		wire				iBUS_RWn_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_CS_GAVIN_i,
// Data Out Inputs
// Data Path from the different Block
input		wire	[31:0]	    DataOut_LPC_Interface_i,		//x1
input		wire	[31:0]	    DataOut_Math_Fixed_i,			//x4
input		wire	[31:0]	    DataOut_Math_Float_i,			//x1
input		wire	[31:0]	    DataOut_Interrupt_Ctrl_i,		//x1
input		wire	[31:0]	    DataOut_Timer_i,				//x1
input		wire	[31:0]	    DataOut_SDCARD_CTRL_i,			//x1
input    	wire    [31:0]		DataOut_WizFi360_i,				//x1
input		wire	[31:0]	    DataOut_IDE_ETH_DPS_i,				//x3
input		wire	[31:0]	    DataOut_Trinity_i,				//x1
input		wire	[31:0]	    DataOut_RTC_i,		
input		wire	[31:0]	    DataOut_GABE_Config_i,			//x1
input       wire   	[31:0]		DataOut_VDMA_i,
input       wire   	[31:0]		DataOut_SDMA_i,

output	    wire				CS_LPC_o,					// LPC
output	    wire				CS_MATH_FIXED_o,		// Math Block
output	    wire				CS_MATH_FLOAT_o,  		// Data Come through here - Internal Registers
output	    wire				CS_Interrupt_Ctrl_o,		// Interrupt Controller
output	    wire				CS_Timer_o,					// Timer Block
output	    wire				CS_SDCard_o,				// SDCard Controller
output	    wire				CS_IDE_o,					// IDE Controller
output	    wire				CS_NIC_o,					// Network Interface Controller
output	    wire				CS_Trinity_o,				// Joystick
output	    wire				CS_RTC_o,
output      wire  				CS_WIZFI360_o, 				// WiFi360
output	    wire				CS_GABE_Config_o,			// GABE Control Registers
output		wire				CS_A2560K_KB_o,				// Just to keep compatibility
output		wire				CS_MAUS_RGB_o,
output      wire                CS_SDMA_o,
output 		wire   				CS_VDMA_o,

output	    reg	    [31:0]	    DataOut_o
);



//$00C0_0000 - $00C1_FFFF - GABE Registers (SuperIO/Math Block/SDCard/IDE/Ethernet/SDMA)assign CS_UNSIGNED_MULT_o 		= ( CPU_A_i[23:3]  == 21'b0000_0000_0000_0001_0000_0) & Valid_Address;	// $00:0100..$00:0107
//assign 	CS_GABE    		= ( Internal_Address[23:17] == 7'b1100_000 ) & ( UserData  | SuperData ); //$C0

// Control and Media
assign CS_GABE_Config_o			= ( iBUS_A_i[16:6] == 11'b0_0000_0000_00) & iBUS_CS_GAVIN_i;	// $FEC00000..$FEC0003F	- Control Registers
assign CS_A2560K_KB_o			= ( iBUS_A_i[16:6] == 11'b0_0000_0000_01) & iBUS_CS_GAVIN_i;	// $FEC00040..$FEC0007F	- Control Registers
assign CS_RTC_o					= ( iBUS_A_i[16:7] == 10'b0_0000_0000_1) & iBUS_CS_GAVIN_i;		// $FEC00080..$FEC0008F	- Control Registers
assign CS_Interrupt_Ctrl_o		= ( iBUS_A_i[16:8] == 9'b0_0000_0001) & iBUS_CS_GAVIN_i;		// $FEC00100..$FEC001FF - Interrupt Controllers
assign CS_Timer_o				= ( iBUS_A_i[16:8] == 9'b0_0000_0010) & iBUS_CS_GAVIN_i;		// $FEC00200..$FEC002FF - Timer Block
assign CS_SDCard_o				= ( iBUS_A_i[16:8] == 9'b0_0000_0011) & iBUS_CS_GAVIN_i;		// $FEC00300..$FEC003FF - SD Card Controller
assign CS_IDE_o					= ( iBUS_A_i[16:8] == 9'b0_0000_0100) & iBUS_CS_GAVIN_i;		// $FEC00400..$FEC004FF - IDE
assign CS_Trinity_o				= ( iBUS_A_i[16:8] == 9'b0_0000_0101) & iBUS_CS_GAVIN_i;		// $FEC00500..$FEC005FF - JOYSTICK/JOYPAD
assign CS_NIC_o					= ( iBUS_A_i[16:9] == 8'b0_0000_011) & iBUS_CS_GAVIN_i;			// $FEC00600..$FEC007FF - NIC
assign CS_WIZFI360_o			= ( iBUS_A_i[16:9] 	== 8'b0_0000_100) & iBUS_CS_GAVIN_i;		// $FEC00800..$FEC009FF - WIZFI360
assign CS_MAUS_RGB_o			= ( iBUS_A_i[16:9] == 8'b0_0001_000) & iBUS_CS_GAVIN_i;			// $FEC01000..$FEC011FF - Keyboard RGB Matrix
// LPC Block
assign CS_LPC_o               = (iBUS_A_i[16:10] == 7'b0_0010_00) & iBUS_CS_GAVIN_i;			// $FEC02000..$FEC023FF - LPC 
// Math Block
assign CS_MATH_FIXED_o		   = ( iBUS_A_i[16:7] == 10'b0_0011_0000_0) & iBUS_CS_GAVIN_i;		// $FEC03000..$FEC0301F	- 32 x 32 Unsigned 
assign CS_MATH_FLOAT_o  		= ( iBUS_A_i[16:9] ==  8'b0_0100_000) & iBUS_CS_GAVIN_i; 		// $FEC04000..$FEC041FF - Float Module  
assign CS_VDMA_o   				= ( iBUS_A_i[16:12] == 5'b0_0110) & iBUS_CS_GAVIN_i;			// $FEC06000..$FEC06FFF - (4K)   - VDMA          
assign CS_SDMA_o				= ( iBUS_A_i[16:12] == 5'b0_1100) & iBUS_CS_GAVIN_i;			// $FEC0C000..$FEC0CFFF - (4K) - SDMA CONTROLLER

wire [8:0] CS_Combined_A;
wire CS_OR_A;
wire [9:0] CS_Combined_B;
wire CS_OR_B;
reg [31:0] DataOut_A;
reg [31:0] DataOut_B;

assign CS_Combined_A = ( { CS_NIC_o, CS_Trinity_o, CS_IDE_o, CS_SDCard_o, CS_Timer_o, CS_Interrupt_Ctrl_o, CS_RTC_o, CS_A2560K_KB_o, CS_GABE_Config_o });
assign CS_OR_A = (   CS_NIC_o | CS_Trinity_o | CS_IDE_o | CS_SDCard_o | CS_Timer_o | CS_Interrupt_Ctrl_o | CS_RTC_o | CS_A2560K_KB_o | CS_GABE_Config_o );

always @ ( posedge iBUS_2xClk_i) begin
	case (CS_Combined_A)
		9'b000_000_000: begin DataOut_A = 32'hDEAD_BEEF; 				end
		9'b000_000_001: begin DataOut_A = DataOut_GABE_Config_i; 		end		
		9'b000_000_010: begin DataOut_A = 32'hC000_0000; 				end
		9'b000_000_100: begin DataOut_A = DataOut_RTC_i; 				end
		9'b000_001_000: begin DataOut_A = DataOut_Interrupt_Ctrl_i;		end
		9'b000_010_000: begin DataOut_A = DataOut_Timer_i; 				end
		9'b000_100_000: begin DataOut_A = DataOut_SDCARD_CTRL_i; 		end
		9'b001_000_000: begin DataOut_A = DataOut_IDE_ETH_DPS_i; 		end
		9'b010_000_000: begin DataOut_A = DataOut_Trinity_i; 			end
		9'b100_000_000: begin DataOut_A = DataOut_IDE_ETH_DPS_i; 		end
		default: begin DataOut_A = 32'hB00B_FEED; 						end
	endcase
end

assign CS_Combined_B = ( { CS_SDMA_o, CS_VDMA_o, CS_MATH_FLOAT_o, CS_MATH_FIXED_o, CS_LPC_o, CS_WIZFI360_o});
assign CS_OR_B = (   CS_SDMA_o | CS_VDMA_o | CS_MATH_FLOAT_o | CS_MATH_FIXED_o | CS_LPC_o | CS_WIZFI360_o  );

always @ ( posedge iBUS_2xClk_i) begin
	case (CS_Combined_B)
		6'b00_0000: begin DataOut_B = 32'hDEAD_BEEF; 				end
		6'b00_0001: begin DataOut_B = DataOut_WizFi360_i;			end		
		6'b00_0010: begin DataOut_B = DataOut_LPC_Interface_i;		end
		6'b00_0100: begin DataOut_B = DataOut_Math_Fixed_i; 		end
		6'b00_1000: begin DataOut_B = DataOut_Math_Float_i; 		end
		6'b01_0000: begin DataOut_B = DataOut_VDMA_i;				end
		6'b10_0000: begin DataOut_B = DataOut_SDMA_i;     			end
		default: begin DataOut_B = 32'hB00B_FEED; 					end
	endcase
end

always @ (*) begin 
	case( { CS_OR_B, CS_OR_A} )
		2'b00: DataOut_o = 32'hB00B_FEED;
		2'b01: DataOut_o = DataOut_A;
		2'b10: DataOut_o = DataOut_B;
		2'b11: DataOut_o = 32'hB00B_FEED;
	endcase
end 

assign iBUS_D_Valid_o = 1'b0;


endmodule

