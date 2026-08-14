`timescale 1 ns / 1 ns

module LPC_Config_Block
(
input		wire				LPC_Clk,
input		wire				Reset_i,
// Inputs
input		wire	[31:0]	LPC_Data_Out,
input		wire				LPC_Ack,
input		wire				LPC_Err,
// Outputs
output	reg	[15:0] 	LPC_Address,
output	reg	[7:0]		LPC_Data_In,
output	reg				LPC_Write,
output	reg				LPC_Strobe,
// Status
output	reg				PCI_Reset,
output	reg				Config_Done_o,
output 	wire	[4:0]		ChipScope
);

reg	[7:0]		Address_Pointer;
reg	[7:0]		Data_Pointer;
reg				Read_Write_pointer;

reg	[4:0]		StateMachine;
reg	[4:0]		StateStateMachine;
reg	[4:0]		StateStateStateMachine;

reg	[2:0]		Logic_Device_State;
reg	[31:0]	CONFIG;
//reg	[23:0]	ResetCounter = 24'h000000;
assign ChipScope = StateMachine;


localparam 	MiniIDLE 				= 2'b00,
				MiniReset_Low_Count	= 2'b01,
				MiniReset_Hi_Count	= 2'b10,
				Done_Reset				= 3'b11;
reg[1:0]	MiniSM;		
reg [23:0] RstCounter;

always @ (posedge LPC_Clk) begin
	if ( Reset_i ) begin
		MiniSM <= MiniIDLE;
	
	end
	else begin
		case( MiniSM )
		
		MiniIDLE: begin 
			RstCounter <= 24'h325AA0;
			PCI_Reset <= 1'b0;
			MiniSM <= MiniReset_Low_Count;	
		end 
	
		MiniReset_Low_Count: begin
			if ( RstCounter ) begin 
				RstCounter <= RstCounter - 24'h000001;
			end
			else begin
				PCI_Reset <= 1'b1;
				RstCounter <= 24'hFC0000;
				MiniSM <= MiniReset_Hi_Count;
			end 
		end 
	
		MiniReset_Hi_Count: begin 
			if ( RstCounter ) begin 
				RstCounter <= RstCounter - 24'h000001;
			end
			else begin
				MiniSM <= Done_Reset;
			end 
		end 
	
		Done_Reset: begin 
			MiniSM <= Done_Reset;
		end 
	
		endcase
	end
end



// Internal Mini States
localparam  	LD 	= 3'b000,
					BA_H	= 3'b001,
					BA_L  = 3'b010,
					INT0	= 3'b011,
					INT1  = 3'b100,
					INT2  = 3'b101,					
					EN		= 3'b110;
// State Machine
localparam 	IDLE 						= 5'b00000,
				// Config each Logical Device power them on
				LOGIC_DEVICE_00		= 5'b00001,
				LOGIC_DEVICE_03 		= 5'b00010,
				LOGIC_DEVICE_04 		= 5'b00011,
				LOGIC_DEVICE_05 		= 5'b00100,
				LOGIC_DEVICE_07		= 5'b00101,
				LOGIC_DEVICE_09 		= 5'b00110,
				LOGIC_DEVICE_0A 		= 5'b00111,
				LOGIC_DEVICE_0B 		= 5'b01000,
				LOAD_DEVICE_ID		   = 5'b01001,
				POWER_ON					= 5'b01010,
				INIT_CONFIG				= 5'b01011,
				FINISH_CONFIG			= 5'b01100,
				WRITE_CONFIG			= 5'b01101,
				// Read/Write Config Pointer
				BEGIN_2E_TRANSFER		= 5'b01110,
				WAIT_END_0x2E			= 5'b01111,
				BEGIN_2F_TRANSFER		= 5'b10000,
				WAIT_END_0x2F			= 5'b10001,
				//Register Write After Config
				WRITE_GPIO61			= 5'b10010,
				WRITE_GPIO_WAIT61		= 5'b10011,
				WRITE_GPIO5D			= 5'b10100,
				WRITE_GPIO_WAIT5D		= 5'b10101,
				// Reset LPC State
				//RESET_LOW				= 5'b10110,
				//RESET_HIGH				= 5'b10111,
				
				CONFIG_DONE				= 5'b11000;
				

initial begin

			StateMachine			= IDLE;
			StateStateMachine		= IDLE;
			StateStateStateMachine = IDLE;
			CONFIG					= 24'h000000;
			//PCI_Reset				= 1'b0;
			LPC_Write  				= 1'b0;
			LPC_Strobe				= 1'b0;
			LPC_Data_In				= 8'h00;
			Address_Pointer		= 8'h00;
			Data_Pointer			= 8'h00;
			Logic_Device_State 	= 3'b00;
			Config_Done_o			= 1'b0;
end				
				

always @ (posedge LPC_Clk) begin

	if (Reset_i) begin
			StateMachine			<= IDLE;
			StateStateMachine		<= IDLE;
			StateStateStateMachine <= IDLE;
			CONFIG					<= 24'h000000;
			LPC_Write  				<= 1'b0;
			LPC_Strobe				<= 1'b0;
			LPC_Data_In				<= 8'h00;
			Address_Pointer		<= 8'h00;
			Data_Pointer			<= 8'h00;
			Logic_Device_State 	<= 3'b00;
			Config_Done_o				<= 1'b0;
	end
	else
	begin

		case (StateMachine)
		
			IDLE: begin
				Config_Done_o			<= 1'b0;				
				if ( Done_Reset == MiniSM ) begin 
					StateMachine 	<= INIT_CONFIG;
				end 
			end
			
			// FDC
			LOGIC_DEVICE_00: begin
				CONFIG <= {8'h06,16'h03F0,8'h00};
				Read_Write_pointer <= 1'b1;
				StateStateStateMachine <= LOGIC_DEVICE_03;
				StateMachine <= WRITE_CONFIG;
			end

			// Parallel Port
			LOGIC_DEVICE_03: begin
				CONFIG <= {8'h07,16'h0378,8'h03};
				Read_Write_pointer <= 1'b1;
				StateStateStateMachine <= LOGIC_DEVICE_04;
				StateMachine <= WRITE_CONFIG;	
			end
			
			// Serial Port 1
			LOGIC_DEVICE_04: begin
				CONFIG <= {8'h04,16'h03F8,8'h04};
				Read_Write_pointer <= 1'b1;
				StateStateStateMachine <= LOGIC_DEVICE_05;
				StateMachine <= WRITE_CONFIG;				
			end

			// Serial Port 2
			LOGIC_DEVICE_05: begin
				CONFIG <= {8'h03,16'h02F8,8'h05};
				Read_Write_pointer <= 1'b1;
				StateStateStateMachine <= LOGIC_DEVICE_07;
				StateMachine <= WRITE_CONFIG;				
			end

			// Keyboard
			LOGIC_DEVICE_07: begin
				CONFIG <= {8'h01, 16'h0060,8'h07};
				Read_Write_pointer <= 1'b1;
				StateStateStateMachine <= LOGIC_DEVICE_09;
				StateMachine <= WRITE_CONFIG;						
			end
			
			//Game Port
			LOGIC_DEVICE_09: begin
				CONFIG <= {8'h00, 16'h0200,8'h09};
				Read_Write_pointer <= 1'b1;
				StateStateStateMachine <= LOGIC_DEVICE_0A;
				StateMachine <= WRITE_CONFIG;				
			end
			
			//PME
			LOGIC_DEVICE_0A: begin
				CONFIG <= {8'h00, 16'h0100,8'h0A};
				Read_Write_pointer <= 1'b1;
				StateStateStateMachine <= LOGIC_DEVICE_0B;
				StateMachine <= WRITE_CONFIG;				
			end
			
			//MPU-401
			LOGIC_DEVICE_0B: begin
				CONFIG <= {8'h05,16'h0330,8'h0B};
				Read_Write_pointer <= 1'b1;
				StateStateStateMachine <= LOAD_DEVICE_ID;
				StateMachine <= WRITE_CONFIG;				
			end
			
			LOAD_DEVICE_ID: begin
				Address_Pointer 			<= 8'h20;
				Read_Write_pointer 		<= 1'b0;
				StateMachine 				<= BEGIN_2E_TRANSFER;
				StateStateMachine 		<= POWER_ON;			
			end
			
			// Turn On the Power of each Logic Device
			POWER_ON: begin
				Address_Pointer 			<= 8'h22;
				Data_Pointer				<= 8'hff;
				Read_Write_pointer 		<= 1'b1;
				StateMachine 				<= BEGIN_2E_TRANSFER;
				StateStateMachine 		<= FINISH_CONFIG;				
			
			end
			
			/// CONFIG  STARTS HERE
			// Write 55 to 0xFE
			INIT_CONFIG: begin
					Address_Pointer 		<= 8'h55;
					StateMachine 			<= BEGIN_2E_TRANSFER;
					StateStateMachine 	<= LOGIC_DEVICE_00;
					Logic_Device_State	<= LD;
			end
			
			/// CONFIG FINISHES HERE:
			FINISH_CONFIG: begin
					Address_Pointer 		<= 8'hAA;
					StateMachine 			<= BEGIN_2E_TRANSFER;
					StateStateMachine 	<= WRITE_GPIO61;
			end
			
			WRITE_CONFIG: begin
				case (Logic_Device_State)
					LD: begin 
						Address_Pointer <= 8'h07; 
						Data_Pointer <= CONFIG[7:0]; 
						Logic_Device_State <= BA_H;
						StateStateMachine <= WRITE_CONFIG; 
					end
					
					BA_H: begin 
						Address_Pointer <= 8'h60; 
						Data_Pointer <= CONFIG[23:16];  
						Logic_Device_State <= BA_L;
					end

					BA_L: begin 
						Address_Pointer <= 8'h61; 
						Data_Pointer <= CONFIG[15:8]; 
						Logic_Device_State <= INT0;
					end
						
					INT0: begin
						Address_Pointer <= 8'h70; 
						Data_Pointer <= CONFIG[31:24];
						if (CONFIG[7:0] == 8'h07)
							Logic_Device_State <= INT1;
						else begin
							if (CONFIG[7:0] == 8'h03) begin
									Logic_Device_State <= INT2;
							end
							else begin
								Logic_Device_State <= EN;
							end
						
						end
							
					end
					// Setup the Second Interrupt for the Mouse.
					INT1: begin
						Address_Pointer <= 8'h72; 
						Data_Pointer <= 8'h02; 
						Logic_Device_State <= EN;
					end
					
					INT2: begin
						Address_Pointer <= 8'hF0; 
						Data_Pointer <= 8'h3A; 
						Logic_Device_State <= EN;					
					end
						

					EN:  begin 
						Address_Pointer <= 8'h30; 
						Data_Pointer <= 8'h01;
						Logic_Device_State <= 2'b00;
						StateStateMachine <= StateStateStateMachine; 
					end
						
					default: 
						Logic_Device_State <= LD;
				
				endcase;
				StateMachine <= BEGIN_2E_TRANSFER;
			end
			
			BEGIN_2E_TRANSFER: begin
				LPC_Address		<= { 8'b00000000, 8'h2E };
				LPC_Data_In		<= Address_Pointer;
				LPC_Write  		<= 1'b1;
				LPC_Strobe		<= 1'b1;
				StateMachine 	<= WAIT_END_0x2E;
			end
			
			WAIT_END_0x2E: begin
				if (LPC_Ack) begin
					LPC_Strobe		<= 1'b0;
					if ((Address_Pointer == 8'h55) || (Address_Pointer == 8'hAA))
						StateMachine 	<= StateStateMachine;
					else
						StateMachine 	<= BEGIN_2F_TRANSFER;	

				end
				else
					StateMachine 	<= WAIT_END_0x2E;	
			end
			
			BEGIN_2F_TRANSFER: begin
				LPC_Address		<= { 8'b00000000, 8'h2F };
				LPC_Data_In		<= Data_Pointer;
				LPC_Write  		<= Read_Write_pointer;
				LPC_Strobe		<= 1'b1;
				StateMachine 	<= WAIT_END_0x2F;
			end			
			
			WAIT_END_0x2F: begin
				if (LPC_Ack) begin
					StateMachine 	<= StateStateMachine;	
					LPC_Strobe		<= 1'b0;
				end
				else
					StateMachine 	<= WAIT_END_0x2F;	
			end

			
			// Write Cycles After the COnfig is Over
			WRITE_GPIO61: begin
				LPC_Address		<= { 16'h0147 };
				LPC_Data_In		<= 8'h84;
				LPC_Write  		<= 1'b1;
				LPC_Strobe		<= 1'b1;
				StateMachine 	<= WRITE_GPIO_WAIT61;
			end
			
			WRITE_GPIO_WAIT61: begin
				if (LPC_Ack) begin
					StateMachine 	<= WRITE_GPIO5D;	
					LPC_Strobe		<= 1'b0;
				end
				else
					StateMachine 	<= WRITE_GPIO_WAIT61;	
			end			

			WRITE_GPIO5D: begin
				LPC_Address		<= { 16'h015D };
				LPC_Data_In		<= 8'h01;
				LPC_Write  		<= 1'b1;
				LPC_Strobe		<= 1'b1;
				StateMachine 	<= WRITE_GPIO_WAIT5D;
			end
			
			WRITE_GPIO_WAIT5D: begin
				if (LPC_Ack) begin
					StateMachine 	<= CONFIG_DONE;	
					LPC_Strobe		<= 1'b0;
				end
				else
					StateMachine 	<= WRITE_GPIO_WAIT5D;	
			end
				
			
			CONFIG_DONE: begin
					Config_Done_o	<= 1'b1;
					StateMachine 	<= CONFIG_DONE;			
			
			end
			
			default: begin
				StateMachine 	<= IDLE;
			end
		
		endcase
	
	end
end



endmodule

