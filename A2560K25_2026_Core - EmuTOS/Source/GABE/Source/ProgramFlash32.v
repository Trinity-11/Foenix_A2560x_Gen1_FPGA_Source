module ProgramFlash32 (

input		wire				Clk_i,
input		wire				Rst_i,
input		wire				Erase_Flash_i,
input		wire				Program_Flash_i,
// RAM Interface
input		wire	[31:0]	Ram_Pointer_Addy_i,		// This is the Pointer where the Data will be.
input		wire	[31:0]	Org_Flash_Address_i,

input		wire	[31:0]	Mem_Pointer_Data_i,
output	wire	[31:0]	Mem_Pointer_Data_o,
output	wire	[31:0]	Mem_Pointer_Addy_o,
output	wire				Mem_Pointer_RD_WRn_o,
output	wire				Mem_Pointer_OEn_o,
output	wire				Flash_WRn_o,
output	wire				Flash_CS_Hi_o,
output	wire				Flash_CS_Lo_o,
output	wire				Flash_OEn_o,
output	wire				RAM_CSn_o,

output	wire				Process_Done_o,
output	wire	[5:0]		StateMachine_Debug_o			
);

assign StateMachine_Debug_o = StateMachine;
reg	[31:0] 	Data_Output;
reg	[31:0]	DATA2WRITE;
reg	[31:0]	Addy_Output;
reg				Poll_Status_Lo;
reg				Poll_Status_Hi;
reg				DirectFlashAddy;
reg	[18:0]		ByteCounter;
reg				ExternBufferDrive;

assign Flash_CS_o				= Flash_CS;
//assign Flash_CS_o					= Flash_CS;
assign Flash_OEn_o 				= Flash_OEn;
assign Flash_WRn_o 				= Flash_WRn;

assign RAM_CSn_o 				= RAM_CS;
assign Mem_Pointer_OEn_o		= RAM_OEn;
assign Mem_Pointer_RD_WRn_o   = ExternBufferDrive;	// This line is used for the RAM, so the OEn is really the one that counts.
assign Mem_Pointer_Addy_o  	= Addy_Output;
assign Mem_Pointer_Data_o  	= Data_Output;

// Byte Write
localparam		WRITE_ADDY0 = 32'h0000_5555,
               WRITE_ADDY1 = 32'h0000_2AAA,
				   WRITE_ADDY2 = 32'h0000_5555;
					
localparam		ERASE_ADDY0 = 32'h0000_5555,
               ERASE_ADDY1 = 32'h0000_2AAA,
				   ERASE_ADDY2 = 32'h0000_5555,
					ERASE_ADDY3 = 32'h0000_5555,
               ERASE_ADDY4 = 32'h0000_2AAA,
				   ERASE_ADDY5 = 32'h0000_5555;					

// Byte Write					
localparam		WRITE_DATA0 = 32'h00AA_00AA,
					WRITE_DATA1 = 32'h0055_0055,
					WRITE_DATA2 = 32'h00A0_00A0;

// Full Erase					
localparam		ERASE_DATA0 = 32'h00AA_00AA,
					ERASE_DATA1 = 32'h0055_0055,
					ERASE_DATA2 = 32'h0080_0080,
					ERASE_DATA3 = 32'h00AA_00AA,
					ERASE_DATA4 = 32'h0055_0055,
					ERASE_DATA5 = 32'h0010_0010;
					
					
localparam		STATE_IDLE		  	= 5'b0_0000,
					STATE_ERASE_ST0  	= 5'b0_0001,
					STATE_ERASE_ST1  	= 5'b0_0011,
					STATE_ERASE_ST2  	= 5'b0_0010,
					STATE_ERASE_ST3  	= 5'b0_0110,
					STATE_ERASE_ST4  	= 5'b0_0111,
					STATE_ERASE_ST5  	= 5'b0_0101,
					STATE_ERASE_ST6  	= 5'b0_0100,
					STATE_WRITE_BT0  	= 5'b0_1100,
					STATE_WRITE_BT1  	= 5'b0_1101,
					STATE_WRITE_BT2  	= 5'b0_1111,
					STATE_WRITE_BT3  	= 5'b0_1110,
					STATE_WRITE_BT4  	= 5'b0_1010,
					STATE_POLL_ST0   	= 5'b0_1011,
					STATE_POLL_ST1   	= 5'b0_1001,
					STATE_POLL_ST2   	= 5'b0_1000,
					STATE_POLL_ST3   	= 5'b1_1000,
					STATE_POLL_ST4   	= 5'b1_1001,
					STATE_POLL_ST5   	= 5'b1_1011,
					STATE_WR_ST0     	= 5'b1_1010,
					STATE_WR_ST1     	= 5'b1_1110,
					STATE_WR_ST2  		= 5'b1_1111,
					STATE_READ_RAM0  	= 5'b1_1101,
					STATE_READ_RAM1  	= 5'b1_1100,
					STATE_READ_RAM2 	= 5'b1_0100,
					STATE_PRG_FLASH0	= 5'b1_0101,
					STATE_PRG_FLASH1	= 5'b1_0111,
					STATE_PRG_FLASH2	= 5'b1_0110,
					STATE_PRG_FLASH3	= 5'b1_0010,	
					STATE_WRITE_DLY0  = 5'b1_0011,
					STATE_WRITE_DLY1  = 5'b1_0001,
					STATE_DONE       	= 5'b1_0000;


reg				RAM_CS;
reg				RAM_OEn;

reg				Flash_WRn;
reg				Flash_CS;
reg				Flash_OEn;

initial
begin
	StateMachine = STATE_IDLE;
	
	Flash_WRn = 1'b1;
	Flash_CS = 1'b0;
	Flash_OEn = 1'b1;

	RAM_CS = 1'b0;
	RAM_OEn = 1'b1;
	
	ExternBufferDrive = 1'b1;  // Read - Data Buffer Tri-Stated
end

reg	[15:0]		CountDown;

reg	[3:0]		ProcessDone;

reg	[4:0]		StateMachine;
reg	[4:0]		StateStateMachine;

assign Process_Done_o = ProcessDone[3];

always @ (negedge Clk_i)					
begin
	if (Rst_i) begin
		StateMachine <= STATE_IDLE;
		Flash_WRn 	<= 1'b1; // Not Inverted Logic
		Flash_CS 	<= 1'b0;	// Inverted Logic
		Flash_OEn 	<= 1'b1; // Not Inverted Logic
	
		RAM_CS 		<= 1'b0;	// Inverted Logic
		RAM_OEn 		<= 1'b1; // Not Inverted Logic
		ExternBufferDrive <= 1'b1;
	end
	else begin
	
	ProcessDone <= ProcessDone << 1'b1;
	
	case( StateMachine )
	
		STATE_IDLE: begin
			if (Erase_Flash_i) begin
				StateMachine <= STATE_ERASE_ST0;
			end
			else begin
				if ( Program_Flash_i ) begin
					StateMachine <= STATE_PRG_FLASH0;
					ByteCounter	<= 19'b000_0000_0000_0000_0000;
				end
				else begin
					StateMachine <= STATE_IDLE;
					RAM_OEn		 <= 1'b1;
					RAM_CS		 <= 1'b0;
					ExternBufferDrive <= 1'b1;		// Read From External Bus from VICKY to CPU General BUS	
					Flash_WRn	 <= 1'b1;
					Flash_OEn 	 <= 1'b1;					
					Flash_CS	 	 <= 1'b0;
				end
			end
		end 
	
		///////////////////////////
		// ENTIRE FLASH ERASE
		///////////////////////////	
		STATE_ERASE_ST0: begin
			Addy_Output <=	{ERASE_ADDY0[29:0],2'b00}; //0x5555
			Data_Output <= ERASE_DATA0; //0xAA
			Flash_CS <= 1'b1;
			ExternBufferDrive <= 1'b0;		// Write to External Bus from VICKY to CPU General BUS
			StateMachine <= STATE_WR_ST0;			
			StateStateMachine <= STATE_ERASE_ST1;
		end

		STATE_ERASE_ST1: begin
			Addy_Output <=	{ERASE_ADDY1[29:0],2'b00}; //0x2AAA
			Data_Output <= ERASE_DATA1; //0x55
			StateMachine <= STATE_WR_ST0;			
			StateStateMachine <= STATE_ERASE_ST2;
		end
	
		STATE_ERASE_ST2: begin
			Addy_Output <=	{ERASE_ADDY2[29:0],2'b00}; //0x5555
			Data_Output <= ERASE_DATA2; //0x80
			StateMachine <= STATE_WR_ST0;			
			StateStateMachine <= STATE_ERASE_ST3;
		end
	
		STATE_ERASE_ST3: begin
			Addy_Output <=	{ERASE_ADDY3[29:0],2'b00}; //0x5555
			Data_Output <= ERASE_DATA3; //0xAA
			StateMachine <= STATE_WR_ST0;			
			StateStateMachine <= STATE_ERASE_ST4;
		end
	
		STATE_ERASE_ST4: begin
			Addy_Output <=	{ERASE_ADDY4[29:0],2'b00}; //0x2AAA
			Data_Output <= ERASE_DATA4; //0x55
			StateMachine <= STATE_WR_ST0;			
			StateStateMachine <= STATE_ERASE_ST5;	
		end
	
		STATE_ERASE_ST5: begin
			Addy_Output <=	{ERASE_ADDY5[29:0],2'b00}; //0x5555
			Data_Output <= ERASE_DATA5; //0x10
			StateMachine <= STATE_WR_ST0;			
			StateStateMachine <= STATE_ERASE_ST6;
		end

		STATE_ERASE_ST6: begin
			Flash_CS <= 1'b0;
			ExternBufferDrive <= 1'b1;		// Read From External Bus from VICKY to CPU General BUS	
			StateMachine <= STATE_POLL_ST0;
			StateStateMachine <= STATE_DONE;
		end
	
		///////////////////////////
		// FLASH WRITE BYTE
		///////////////////////////
		STATE_WRITE_BT0: begin
			Flash_CS <= 1'b1;
			ExternBufferDrive <= 1'b0; // Write to External Bus from VICKY to CPU General BUS
			Addy_Output <=	{WRITE_ADDY0[29:0],2'b00}; //0x5555
			Data_Output <= WRITE_DATA0; //0xAA
			StateMachine <= STATE_WR_ST0;			
			StateStateMachine <= STATE_WRITE_BT1;	
		end
	
		STATE_WRITE_BT1: begin
			Addy_Output <=	{WRITE_ADDY1[29:0],2'b00}; //0x2AAA
			Data_Output <= WRITE_DATA1; //0x55
			StateMachine <= STATE_WR_ST0;			
			StateStateMachine <= STATE_WRITE_BT2;	
		end
	
		STATE_WRITE_BT2: begin
			Addy_Output <=	{WRITE_ADDY2[29:0],2'b00}; //0x5555
			Data_Output <= WRITE_DATA2; //0x10
			StateMachine <= STATE_WR_ST0;			
			StateStateMachine <= STATE_WRITE_BT3;
		end
	
		STATE_WRITE_BT3: begin
			Addy_Output <=	(Org_Flash_Address_i + ByteCounter); //
			Data_Output <= DATA2WRITE;
			StateMachine <= STATE_WR_ST0;
			StateStateMachine <= STATE_WRITE_BT4;
		end
	
		// Go Poll for 7us For EveryByte Writen
		STATE_WRITE_BT4: begin
			Flash_CS <= 1'b0;
			ExternBufferDrive <= 1'b1; // Read From External Bus from VICKY to CPU General BUS
			StateMachine <= STATE_WRITE_DLY0;
			StateStateMachine <= STATE_PRG_FLASH2;		
		end
	
		///////////////////////////
		// POLLING Happens HERE
		///////////////////////////
		STATE_POLL_ST0: begin
			Addy_Output <=	32'hFFFF_FFFF;
			Flash_CS		<= 1'b1;
			StateMachine <= STATE_POLL_ST1;			
		end
	
		STATE_POLL_ST1: begin
			Flash_OEn	 <= 1'b0;
			StateMachine <= STATE_POLL_ST2;					
		end
	
		STATE_POLL_ST2: begin
			Poll_Status_Lo  <= Mem_Pointer_Data_i[7];
			Poll_Status_Hi  <= Mem_Pointer_Data_i[23];
			StateMachine <= STATE_POLL_ST3;
		end
	
		STATE_POLL_ST3: begin
			Flash_OEn	 <= 1'b1;		
			Flash_CS 	 <= 1'b0;
			StateMachine <= STATE_POLL_ST4;			
		end
	
		STATE_POLL_ST4: begin
			if (Poll_Status_Lo & Poll_Status_Hi)
				StateMachine <= STATE_POLL_ST5;
			else 
				StateMachine <= STATE_POLL_ST0;
		end
	
		// if we reached here, it is because the Polling is done.
		STATE_POLL_ST5: begin
				StateMachine <= StateStateMachine;
		end
	
		//////////////////////////////
		// Write Pulse
		//////////////////////////////
		STATE_WR_ST0: 	begin
			Flash_WRn <= 1'b0;
			StateMachine <= STATE_WR_ST1;
		end
	
		STATE_WR_ST1: begin
			Flash_WRn    <= 1'b1;
			StateMachine <= StateStateMachine;
		end
		
	
		//////////////////////////////
		// READ RAM BYTES
		//////////////////////////////
		STATE_READ_RAM0:	begin
			Addy_Output 	<=	( Ram_Pointer_Addy_i + ByteCounter ); 
			RAM_OEn			<= 1'b0;
			StateMachine 	<= STATE_READ_RAM1;
		end
	
		STATE_READ_RAM1:	begin
			DATA2WRITE		<= Mem_Pointer_Data_i;
			StateMachine 	<= STATE_READ_RAM2;			
		end
	
		STATE_READ_RAM2:	begin
			RAM_OEn		<= 1'b1;
			RAM_CS 		<= 1'b0;
			StateMachine <= StateStateMachine;
		end
	
		//////////////////////////////
		// PROGRAM FLASH STATES
		//////////////////////////////	
		// Read RAM
		STATE_PRG_FLASH0:	begin
			ExternBufferDrive <= 1'b1; // Read From External Bus from VICKY to CPU General BUS		
			RAM_CS <= 1'b1;
			StateMachine <= STATE_READ_RAM0;
			StateStateMachine <= STATE_PRG_FLASH1;
	
		end
		// Write BYTE
		STATE_PRG_FLASH1:	begin 
			Flash_CS <= 1'b1;		
			StateMachine <= STATE_WRITE_BT0;
		end
	
		// Increment Pointer1
		STATE_PRG_FLASH2:	begin
			ByteCounter <= ByteCounter + 19'b000_0000_0000_0000_0100;	// Increament by 4
			StateMachine <= STATE_PRG_FLASH3;			
		end
	
		STATE_PRG_FLASH3:	begin 
			if (ByteCounter)
				StateMachine <= STATE_PRG_FLASH0;
			else 
				StateMachine <= STATE_DONE;
		end

		//////////////////////////////
		// PROGRAM FLASH STATES
		//////////////////////////////	
			// Wait for 7us for the 16VF1601
		STATE_WRITE_DLY0: begin
			CountDown <= 16'd520;							//14M = 290, 20M = 414, 33M = 683, 40M = 828
			StateMachine <= STATE_WRITE_DLY1;		
		end

		STATE_WRITE_DLY1: begin
			if (CountDown)
				CountDown <= CountDown - 16'h0001;
			else
				StateMachine <= StateStateMachine;		
		
		end

	
		
		STATE_DONE: begin 
				ProcessDone <= 4'b1111;
				StateMachine <= STATE_IDLE;	
		end
	
	
		default: begin 
				StateMachine <= STATE_IDLE;		
		end
	
	endcase 
	
	end

end


endmodule
