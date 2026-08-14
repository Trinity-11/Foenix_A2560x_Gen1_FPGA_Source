`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/01/2025 11:41:26 PM
// Design Name: 
// Module Name: MEMText_FONT_StateMachine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MEMText_FONT_StateMachine(
//Clock and reset
input		wire 				video_clk_i,
input		wire 				video_rst_i,

input		wire				TextMode_Enable_i,

input		wire	[7:0]		FONT_Height_Constant_i,
input		wire	[7:0]		FONT_Vertical_Num_Lines_i,
input		wire	[7:0]		FONT_Horizontal_Num_Chars_i,
input		wire				VideoMode_Double_i,

input		wire	[1:0]		Vsync_EDGE_i,
input		wire				Horizontal_Precharge_i,
// Text Box Active Signals
input		wire				Horizontal_Active_i,
// 1 Pulse Start Of Frame (8 Pixel Long)
input		wire				SOF_i,
// Text Box - Text Memory Pointer & Data
input		wire	[7:0]		ASCII_Text_Data_i,      // Text Char
input       wire    [7:0]       ASCII_Attr_Data_i,      // Text Attributes
output	    wire	[8:0]	    ASCII_Text_Addy_o,      //	Page[0] : 128 Character [6:0]
output		wire				Mono_Font_Output_o,		// Char Graph Stream
output      wire   				Mono_Cursor_Output_o,	// Char Graph Stream
output      wire  				Mono_Cursor_Active_o,	// Enable Graph Stream
// FONT Memory Address and Data.
input		wire	[7:0]		Font_Line_Data_i,
output 	    wire	[12:0]	    Font_Line_Addy_o,
input		wire	[15:0]	    Cursor_X_Input_i,
input		wire	[15:0]	    Cursor_Y_Input_i,
output      wire    [3:0]       Cursor_Height_Pointer_o,
input       wire    [7:0]       Cursor_Graph_Data_i,

input		wire 	[7:0]		Cursor_Control_Reg_i
);

localparam		    IDLE 					= 5'b00000,
					CHARGE_ASCII_LINE		= 5'b00001,
					NEW_LINE_PREPARE		= 5'b00011,
					SET_ADDY_XYPOSITION	    = 5'b00010,
					WAIT_MEM_LATENCY0		= 5'b00110,
					WAIT_MEM_LATENCY1		= 5'b00111,
					WAIT_MEM_LATENCY2		= 5'b00101,
					WAIT_MEM_LATENCY3		= 5'b00100,
					WAIT_MEM_LATENCY4		= 5'b01100,
					WAIT_MEM_LATENCY5		= 5'b01101,
					WAIT_MEM_LATENCY6		= 5'b01111,
					LOAD_SERIAL_REGISTER	= 5'b01110,
					INCREMENT_X_POSITION    = 5'b01010,
					CHECK_X_POSITION		= 5'b01011,
					CHANGE_HEIGHT			= 5'b01001,
					CHECK_Y_POSITION		= 5'b01000,
					MEM_CMD_REQUEST0        = 5'b11000,
					MEM_CMD_REQUEST1        = 5'b11001,
					MEM_CMD_REQUEST2        = 5'b11011,
					MEM_CMD_REQUEST3        = 5'b11010,
					MEM_CMD_REQUEST4        = 5'b11110;


//wire    [15:0]      ASCII_Text_Addy_Ptr;
wire                FONT_Size; // 0 - 8x8, 1 - 8x16
reg 	[7:0]		SOF_Counter;
reg 	[7:0]		SOF_CounterText;
reg		[7:0] 	    FlashRate;
reg		[7:0] 	    FlashRateText;
reg					FlashOnOFF;
reg					FlashOnOFFText;
// FONT State Machine
reg		[4:0]		StateMachine;
reg		[7:0]		Height_Pointer;
reg		[7:0]		Pixel_Line_In_Block;	// 2 Pixels
reg   	[7:0]		Cursor_Line_In_Block;	
reg		[7:0]		X_Char_Count;	// Max 256
reg		[7:0]		Y_Char_Count;	// Max 60 (8x8) 30 (8x16)
reg		[4:0]		Wait_Counter;
reg		[3:0]		Mini_StateMachine;
reg					ColorReq;
reg					Double_Line;
reg	    [7:0]		ASCII_Text_Data_Cursor;
reg	    [1:0]	    SOF_EDGE;
reg     [1:0]	    Precharge_EDGE;
reg					PageRead;


// Font_Line_Addy = {2'b00, 8'h00, 3'b000} (CBM 8x8)  BANK, ASCII, LINE (2KBytes)
// Font_Line_Addy = {2'b01, 8'h00, 3'b000} (EMPTY)    BANK, ASCII, LINE (2KBytes)
// Font_Line_Addy = {1'b1, 8'h00, 4'b0000} (CBM 8x16) BANK, ASCII, LINE (4KBytes)
reg	[7:0]	Cursor_Graph_Latency;
// THis simulate the Character coming out of the DP Memory (1 Clock Latency)
always @ ( posedge video_clk_i) begin 
	Cursor_Graph_Latency <= Cursor_Graph_Data_i;
end 
assign Cursor_Height_Pointer_o = Height_Pointer[3:0];
assign Mono_Cursor_Active_o = (X_Char_Count == Cursor_X_Input_i[7:0]) & (Y_Char_Count == Cursor_Y_Input_i[5:0]) & ( FlashOnOFF | Cursor_Control_Reg_i[3] ) & Cursor_Control_Reg_i[0];
// ASSIGNMENTS
assign  FONT_Size           	= Cursor_Control_Reg_i[6];
assign 	Mono_Font_Output_o		= Pixel_Line_In_Block[7];
assign  Mono_Cursor_Output_o	= Cursor_Line_In_Block[7]; // Graphic
                                //  8x16 Characters                 //8x8
                                // {1'bx, 8'bxxxx_xxxx, 4'bxxxx} : { 2'bxx, 8'hxxxx_xxxx, 3'bxxx }
assign 	Font_Line_Addy_o 	    = FONT_Size ? { ASCII_Attr_Data_i[1], ASCII_Text_Data_i, Height_Pointer[3:0]} : { ASCII_Attr_Data_i[1:0], ASCII_Text_Data_i, Height_Pointer[2:0]};
assign 	ASCII_Text_Addy_o  	    = {PageRead, X_Char_Count[7:0]};
// Simple 8x8 Multiplication, let's see how the compiler will synthesise it!
//assign ASCII_Text_Addy_Ptr[15:0] = Y_Char_Count[7:0] * FONT_Horizontal_Num_Chars_i[7:0];
always @(posedge video_clk_i)
begin
		Precharge_EDGE[0] <= Horizontal_Precharge_i;
		Precharge_EDGE[1]	<= Precharge_EDGE[0];
end


/// Delay the Attribute for Immediate Change for the Output of the LUT
reg [7:0]	ASCII_Attr_Data_DLY;
always @(negedge video_clk_i)
begin
	ASCII_Attr_Data_DLY <= ASCII_Attr_Data_i;
end 
reg Pixel_Line_In_Block_Dly;
// Cursor
always @(negedge video_clk_i)
begin
	if (video_rst_i)
		Pixel_Line_In_Block		<= 8'h00;	// Actual Vertical (offset) Line Number on the Screen (max 256 Lines)
	else begin
		if (StateMachine == LOAD_SERIAL_REGISTER) begin
			Pixel_Line_In_Block[7:0] 	<=	(( ASCII_Attr_Data_DLY[4] ) | ( FlashOnOFFText & ASCII_Attr_Data_DLY[5] )) ? ( Font_Line_Data_i ^ 8'hFF) : Font_Line_Data_i;
		end
		else begin
			if (Horizontal_Active_i)
				Pixel_Line_In_Block <= Pixel_Line_In_Block << 1'b1;
			else
				Pixel_Line_In_Block		<= 8'h00;		
			end
	end
end
// Cursor
always @(negedge video_clk_i)
begin
	if (video_rst_i)
		Cursor_Line_In_Block		<= 8'h00;	// Actual Vertical (offset) Line Number on the Screen (max 256 Lines)
	else begin
		if ((StateMachine == LOAD_SERIAL_REGISTER) && Mono_Cursor_Active_o ) begin
			Cursor_Line_In_Block[7:0] <= Cursor_Graph_Latency;
		end
		else begin
			if (Horizontal_Active_i)
				Cursor_Line_In_Block  <= Cursor_Line_In_Block << 1'b1;
			else
				Cursor_Line_In_Block	<= 8'h00;		
			end
	end
end
// Dot Clock Realm
always @(posedge video_rst_i or posedge video_clk_i)
begin
	if (video_rst_i) 
	begin
		StateMachine 				<= IDLE;
		Height_Pointer				<= 8'h00;		// Font Vertical Line Counter
		X_Char_Count				<= 8'h00;
		Y_Char_Count				<= 8'h00;
		PageRead					<= 1'b0;		// 1 Bit Flip Line Memorey when done
	end
	else begin


		case(StateMachine)
		// Let's begin the preparation when a new Frame Begins
		IDLE:
		begin
			if (( Vsync_EDGE_i[1:0] == 2'b01 ) && TextMode_Enable_i) begin		// Bit Zero is the Enable Bit			
				StateMachine 		<= MEM_CMD_REQUEST0;
			end
			else begin
				Double_Line			<= 1'b0;
				X_Char_Count		<= 8'h00; 
				Y_Char_Count		<= 8'h00;
				Height_Pointer		<= 8'h00;		//This is the Line Pointer for the FONT memory. The combination of Actual_ASCII + Height_Pointer makes up the Address for FONT
				StateMachine 		<= IDLE;
			end
		end
		
		// Let's Reset Everything and Prepare to read First Character off the Text Memory
		NEW_LINE_PREPARE:
		begin
			if (Precharge_EDGE[1:0] == 2'b01) begin
				StateMachine 				<= SET_ADDY_XYPOSITION;	// Go Wait 1 Clock Cycle For Read Latency
			end
		end

		// Take Into Consideration the Value of X and Y
		// 1
		SET_ADDY_XYPOSITION:
		begin
			StateMachine 					<= WAIT_MEM_LATENCY0;	// Go Wait 1 Clock Cycle For Read Latency		
		end
		// 2
		WAIT_MEM_LATENCY0:
		begin
			StateMachine 					<= WAIT_MEM_LATENCY1;	// Go Wait 1 Clock Cycle For Read Latency			
		end
		// 3
		WAIT_MEM_LATENCY1:
		begin
			StateMachine 					<= WAIT_MEM_LATENCY2;	// Go Wait 1 Clock Cycle For Read Latency						
		end
		// 4
		WAIT_MEM_LATENCY2:
		begin
			StateMachine 					<= WAIT_MEM_LATENCY3;	// Go Wait 1 Clock Cycle For Read Latency						
		end			
		// 5
		WAIT_MEM_LATENCY3:
		begin
			StateMachine 					<= WAIT_MEM_LATENCY4;	// Go Wait 1 Clock Cycle For Read Latency						
		end
		// 6
		WAIT_MEM_LATENCY4:
		begin
			StateMachine 					<= WAIT_MEM_LATENCY5;	// Go Wait 1 Clock Cycle For Read Latency						
		end
		// 7
		WAIT_MEM_LATENCY5:
		begin
			StateMachine 					<= LOAD_SERIAL_REGISTER;	// Go Wait 1 Clock Cycle For Read Latency						
		end
		
		WAIT_MEM_LATENCY6:
		begin
			StateMachine 					<= LOAD_SERIAL_REGISTER;	// Go Wait 1 Clock Cycle For Read Latency						
		end
		// 0
		LOAD_SERIAL_REGISTER:
		begin
			StateMachine 					<= INCREMENT_X_POSITION;	// Go Wait 1 Clock Cycle For Read Latency	
		end
		
		INCREMENT_X_POSITION:
		begin
			X_Char_Count	<= X_Char_Count + 7'h01;
			StateMachine 	<= CHECK_X_POSITION;
		end
		// 1
		CHECK_X_POSITION:
		begin
			if (X_Char_Count 	<  FONT_Horizontal_Num_Chars_i)
				StateMachine 	<= WAIT_MEM_LATENCY1;
			else begin
				X_Char_Count	<=	7'h00;

				if (VideoMode_Double_i & !Double_Line) begin
				
						Double_Line <= 1'b1;
				end
				else begin
						Height_Pointer <= Height_Pointer + 8'h01;
						Double_Line <= 1'b0;
				end
				StateMachine 	<= CHANGE_HEIGHT;
			end
		end
		// 2
		CHANGE_HEIGHT:
		begin
			if (Height_Pointer < FONT_Height_Constant_i) begin
				StateMachine 	<= NEW_LINE_PREPARE;					
			end
			else begin
				PageRead <= PageRead ^ 1'b1;
				Height_Pointer	<= 8'h00;
				Y_Char_Count <= Y_Char_Count + 8'h01;				
				StateMachine <= CHECK_Y_POSITION;			
			end
		end
		
		CHECK_Y_POSITION:
		begin
			if (Y_Char_Count < FONT_Vertical_Num_Lines_i) begin
				StateMachine 	<= MEM_CMD_REQUEST0;
			end
			else begin 
				StateMachine 	<= IDLE;
			end 

		end
		
		MEM_CMD_REQUEST0:
		begin
				StateMachine 	<= MEM_CMD_REQUEST1;
		end
		
		MEM_CMD_REQUEST1:
		begin				
				StateMachine 	<= MEM_CMD_REQUEST2;
		end

		MEM_CMD_REQUEST2:
		begin
	
				StateMachine 	<= MEM_CMD_REQUEST3;
		end
		
		MEM_CMD_REQUEST3:
		begin			
				StateMachine 	<= NEW_LINE_PREPARE;
		end

		default:
		begin
			StateMachine		<= IDLE;
		end
		endcase
	end
end



always @(posedge video_rst_i or posedge video_clk_i)
begin
	if (video_rst_i) 
	begin
		SOF_EDGE <= 2'b00;
	end
	else begin
		SOF_EDGE[0] <= SOF_i;
		SOF_EDGE[1] <= SOF_EDGE[0];
	end
end

always @ (*)
begin
	case (Cursor_Control_Reg_i[2:1])
		2'b00: FlashRate = 8'd60;
		2'b01: FlashRate = 8'd30;
		2'b10: FlashRate = 8'd15; 
		2'b11: FlashRate = 8'd12;
		default: FlashRate = 8'd60;
	endcase
end

always @(posedge video_rst_i or posedge video_clk_i)
begin
	if (video_rst_i) 
	begin
		SOF_Counter <= 8'h00;
		FlashOnOFF	<= 1'b0;
	end
	else begin
		
		if (SOF_EDGE[1:0] == 2'b01) begin
			SOF_Counter <= SOF_Counter + 1'b1;
		end

		
		if (SOF_Counter == FlashRate) begin
				FlashOnOFF <= FlashOnOFF ^ 1'b1;
				SOF_Counter <= 8'h00;			
		end
			else begin
				if (SOF_Counter > FlashRate) 
						SOF_Counter <= 8'h00;
			end

	end
end

/// MEMTEXT VERSION
always @ (*)
begin
	case (Cursor_Control_Reg_i[5:4])
		2'b00: FlashRateText = 8'd60;
		2'b01: FlashRateText = 8'd30;
		2'b10: FlashRateText = 8'd15; 
		2'b11: FlashRateText = 8'd12;
		default: FlashRateText = 8'd60;
	endcase
end

always @(posedge video_rst_i or posedge video_clk_i)
begin
	if (video_rst_i) 
	begin
		SOF_CounterText <= 8'h00;
		FlashOnOFFText	<= 1'b0;
	end
	else begin
		
		if (SOF_EDGE[1:0] == 2'b01) begin
			SOF_CounterText <= SOF_CounterText + 1'b1;
		end
		
		if (SOF_CounterText == FlashRateText) begin
				FlashOnOFFText <= FlashOnOFFText ^ 1'b1;
				SOF_CounterText <= 8'h00;			
		end
			else begin
				if (SOF_CounterText > FlashRateText) 
						SOF_CounterText <= 8'h00;
			end

	end
end


endmodule
