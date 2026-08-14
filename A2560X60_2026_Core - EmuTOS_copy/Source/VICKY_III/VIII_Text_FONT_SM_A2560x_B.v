`timescale 1ns / 1ps
module VIII_Text_FONT_SM_A2560x_B #(
//---------------------------Parameters----------------------------------------
parameter	FONTSIZE_X =			8,		//Width of input/output data
parameter	FONTSIZE_Y =			8,
parameter   X_COUNT_WIDTH =   11,	// Visible Resolution of the Video Coming In (X)
parameter   Y_COUNT_WIDTH =   11	// Visible Resolution of the Video Coming In (Z)
)(
//Clock and reset
input		wire 				video_clk,
input		wire 				video_rst,

input		wire				TextMode_Enable_i,

input		wire				FONT_Block_Enable,
input		wire	[5:0]		FONT_Height_Constant,
input		wire	[1:0]		FONT_Bank,
input		wire	[1:0]		VideoMode_i,
input		wire				VideoMode_Double_i,

input		wire	[1:0]		Vsync_EDGE,
input		wire	[1:0]		de_EDGE,
input		wire				Horizontal_Precharge,

// Text Box Active Signals
input		wire				Vertical_Active,
input		wire				Horizontal_Active,

// 1 Pulse Start Of Frame (8 Pixel Long)
input		wire				SOF_i,

// Text Box - Text Memory Pointer & Data
input		wire	[7:0]		Text_Pointer_Offset_i,
input		wire	[7:0]		ASCII_Text_Data,
output		wire	[14:0]		ASCII_Text_Addy,

//output	wire	[31:0]	CMD_Req_o,
//output	reg				CMD_Req_Write_o,
//input		wire				CMD_Req_Wr_Stat_Full_i,


output		wire				Pixel_Out,

// FONT Memory Address and Data.
input		wire	[7:0]		Font_Line_Data,
output 		wire	[11:0]		Font_Line_Addy,

input		wire	[15:0]		Cursor_X_Input_i,
input		wire	[15:0]		Cursor_Y_Input_i,
input		wire 	[7:0]		Cursor_Control_Reg_i,
input		wire	[7:0]		Cursor_Character_Reg_i
);

wire 					clk;
wire 					rst;
wire 	[15:0] 			ASCII_Text_Addy_Ptr;



reg 	[7:0]		SOF_Counter;
reg		[7:0] 		FlashRate;
reg					FlashOnOFF;
// FONT State Machine
reg		[4:0]		StateMachine;
reg		[4:0]		Height_Pointer;

reg		[7:0]		Pixel_Line_In_Block;	// 2 Pixels
reg		[7:0]		X_Char_Count;	// Max 256
reg		[7:0]		Y_Char_Count;	// Max 120 (8x8) 60 (8x16)
reg		[4:0]		Wait_Counter;
reg		[3:0]		Mini_StateMachine;
reg					ColorReq;
reg					Double_Line;
reg		[7:0]		X_Char_Count_Limit;
reg		[7:0]		Y_Char_Count_Limit;
reg		[7:0]		ASCII_Text_Data_Cursor;

always @ (*)
begin
	if ( VideoMode_i[0] ) begin 
		// 1280x1024@60 with 8x16		
		X_Char_Count_Limit = 8'd160;		
		Y_Char_Count_Limit = 8'd64; 
	end
	else begin 
		// 1280x960@60 with 8x16		
		X_Char_Count_Limit = 8'd160;		
		Y_Char_Count_Limit = 8'd60; 
	end 
end



always @ (*)
begin
	if ((X_Char_Count == Cursor_X_Input_i[7:0]) && (Y_Char_Count == Cursor_Y_Input_i[7:0]) && FlashOnOFF && Cursor_Control_Reg_i[0])
		ASCII_Text_Data_Cursor = Cursor_Character_Reg_i[7:0];
	else
	   ASCII_Text_Data_Cursor = ASCII_Text_Data;
end
//assign ASCII_Text_Data_Cursor = ((X_Char_Count == Cursor_X_Input_40) && (Y_Char_Count == Cursor_Y_Input_40)) ? 8'hA0 : ASCII_Text_Data;


// ASSIGNMENTS
assign 	clk 		 			= video_clk;
assign 	rst 		 			= video_rst;
assign 	Pixel_Out 				= Pixel_Line_In_Block[7];
//assign 	Font_Line_Addy 		= (FONT_Height_Constant == 6'h08) ? { FONT_Bank[1:0], ASCII_Text_Data_Cursor, Height_Pointer[2:0]} : { FONT_Bank[1], ASCII_Text_Data_Cursor, Height_Pointer[3:0]};
//assign 	Font_Line_Addy 		= { Cursor_Control_Reg_i[4:3], ASCII_Text_Data_Cursor, Height_Pointer[2:0]};
//assign 	ASCII_Text_Addy  	= { Y_Char_Count[5:0], X_Char_Count[6:0] } + Text_Pointer_Offset_i;	// [6 + 7] + 8;

assign 	Font_Line_Addy 		= { ASCII_Text_Data_Cursor, Height_Pointer[3:0] };	// 8x16 only
assign 	ASCII_Text_Addy  	= ASCII_Text_Addy_Ptr[14:0] +  {6'b00_0000, X_Char_Count[7:0]};



TextAddy_Mult	TextAddy_Mult_inst (
	.dataa ( Y_Char_Count ),
	.datab ( X_Char_Count_Limit ),
	.result ( ASCII_Text_Addy_Ptr )
	);


//assign	Real_Mem_Loc		= (24'h000000 + ASCII_Text_Addy);
//assign 	CMD_Req_o  			= {9'h040, ColorReq, Real_Mem_Loc[21:0]};	// 4 burst of 32 Bytes @ Base address of the line;
//reg 	[Y_COUNT_WIDTH-1:0]		LineCount_Bis;

localparam		IDLE 						=	5'b00000,
					CHARGE_ASCII_LINE		= 	5'b00001,
					NEW_LINE_PREPARE		=	5'b00010,
					SET_ADDY_XYPOSITION		=	5'b00011,
					WAIT_MEM_LATENCY0		=	5'b00100,
					WAIT_MEM_LATENCY1		=	5'b00101,
					WAIT_MEM_LATENCY2		=	5'b00110,
					WAIT_MEM_LATENCY3		=	5'b00111,
					WAIT_MEM_LATENCY4		=	5'b01000,
					WAIT_MEM_LATENCY5		=	5'b01001,
					WAIT_MEM_LATENCY6		=	5'b01010,
					LOAD_SERIAL_REGISTER	=  	5'b01011,
					INCREMENT_X_POSITION 	=  	5'b01100,
					CHECK_X_POSITION		=  	5'b01101,
					CHANGE_HEIGHT			=  	5'b01110,
					CHECK_Y_POSITION		=  	5'b01111,
					MEM_CMD_REQUEST0     	=  	5'b10000,
					MEM_CMD_REQUEST1     	=  	5'b10001,
					MEM_CMD_REQUEST2    	=  	5'b10010,
					MEM_CMD_REQUEST3     	=  	5'b10011,
					MEM_CMD_REQUEST4     	=  	5'b10100;

reg [1:0]	Precharge_EDGE;
always @(posedge clk)
begin
		Precharge_EDGE[0] <= Horizontal_Precharge;
		Precharge_EDGE[1]	<= Precharge_EDGE[0];
end

always @(negedge clk)
begin
	if (rst)
		Pixel_Line_In_Block		<= 8'h00;	// Actual Vertical (offset) Line Number on the Screen (max 256 Lines)
	else begin
		// Serializer
		if (Horizontal_Active)
			Pixel_Line_In_Block <= Pixel_Line_In_Block << 1'b1;
		else
			Pixel_Line_In_Block		<= 8'h00;
		
		if (StateMachine == LOAD_SERIAL_REGISTER)
			Pixel_Line_In_Block[7:0] 	<=	Font_Line_Data;
	end
end

// Dot Clock Realm
always @(posedge rst or posedge clk)
begin
	if (rst) 
	begin
		StateMachine 				<= IDLE;
		Height_Pointer				<= 5'h00;		// Font Vertical Line Counter
		X_Char_Count				<= 8'h00;
		Y_Char_Count				<= 8'h00;
//		CMD_Req_Write_o			<= 1'b0;
	end
	else begin


		case(StateMachine)

		// Let's begin the preparation when a new Frame Begins
		IDLE:
		begin
			// Falling Edge
//			if ( Vsync_EDGE == 2'b01 ) begin		// Bit Zero is the Enable Bit
			if (( Vsync_EDGE == 2'b01 ? 1'b1 : 1'b0 ) && TextMode_Enable_i) begin		// Bit Zero is the Enable Bit			
				StateMachine 		<= MEM_CMD_REQUEST0;
			end
			else begin
				Double_Line			<= 1'b0;
				X_Char_Count		<= 8'h00; 
				Y_Char_Count		<= 8'h00;
				Height_Pointer		<= 5'h00;		//This is the Line Pointer for the FONT memory. The combination of Actual_ASCII + Height_Pointer makes up the Address for FONT
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
			X_Char_Count	<= X_Char_Count + 8'h01;
			StateMachine 	<= CHECK_X_POSITION;
		end
		// 1
		CHECK_X_POSITION:
		begin
			if (X_Char_Count 	<  X_Char_Count_Limit)
				StateMachine 	<= WAIT_MEM_LATENCY1;
			else begin
				X_Char_Count	<=	8'h00;

				if (VideoMode_Double_i & !Double_Line) begin
				
						Double_Line <= 1'b1;
				end
				else begin
						Height_Pointer <= Height_Pointer + 5'h01;
						Double_Line <= 1'b0;
				end
			
				StateMachine 	<= CHANGE_HEIGHT;

			end
		end
		// 2
		CHANGE_HEIGHT:
		begin
			if (Height_Pointer < FONT_Height_Constant) begin
				StateMachine 	<= NEW_LINE_PREPARE;					
			end
			else begin
				Height_Pointer	<= 5'h00;
				Y_Char_Count <= Y_Char_Count + 8'h01;				
				StateMachine <= CHECK_Y_POSITION;			
			end
		end
		
		CHECK_Y_POSITION:
		begin
			if (Y_Char_Count < Y_Char_Count_Limit) begin
				StateMachine 	<= MEM_CMD_REQUEST0;
			end
			else
				StateMachine 	<= IDLE;		
		end
		
		MEM_CMD_REQUEST0:
		begin

				StateMachine 	<= MEM_CMD_REQUEST1;
		end
		
		MEM_CMD_REQUEST1:
		begin
//				ColorReq <= 1'b1;	// Post a New Command for Color As well				
				StateMachine 	<= MEM_CMD_REQUEST2;
		end

		MEM_CMD_REQUEST2:
		begin
	
				StateMachine 	<= MEM_CMD_REQUEST3;
		end
		
		MEM_CMD_REQUEST3:
		begin
//				CMD_Req_Write_o <= 1'b0;
//				ColorReq <= 1'b0;	// Post a New Command for Color As well					
				StateMachine 	<= NEW_LINE_PREPARE;
		end

		default:
		begin
			StateMachine		<= IDLE;
		end
		endcase
	end
end


reg	[1:0]	SOF_EDGE;

always @(posedge rst or posedge clk)
begin
	if (rst) 
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

always @(posedge rst or posedge clk)
begin
	if (rst) 
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

endmodule

