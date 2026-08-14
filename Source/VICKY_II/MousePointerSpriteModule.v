`timescale 1 ns / 1 ns
module MousePointerSpriteModule
(

input 		wire					rst_i,				// This is async Reset
// CPU Signals Interface
input 		wire					Bus_Clk_i,
input 		wire	[23:0]			Bus_A_i,
input		wire					Bus_A_Valid_i,
input		wire					Bus_RW_i,
input		wire	[3:0]			Bus_BE_i,
input		wire					Bus_WE_i, 
input		wire	[7:0]			Bus_D8_i,
input		wire	[15:0]			Bus_D16_i,
input		wire	[31:0]			Bus_D32_i,
input		wire	[1:0]			Bus_D_Siz_i,
output 		reg		[31:0]			Bus_D_o,

input		wire					Mouse_Pointer_Mem_CS_i,
input		wire					Mouse_Pointer_Reg_CS_i,
input		wire					SOF_i,

input		wire					VideoClk_i,
input		wire					VideoRst_i,
input		wire					VideoModeReset_i,
input		wire	[1:0]			Mstr_Ctrl_Video_Mode_CPU_i,
input 		wire					Mstr_Ctrl_Doubling_Pixel_i,
input		wire					VSync_i,
input		wire					HSync_i,
input		wire					HBlanking_i,				// Begins 2 clocks before the actual Blanking
input		wire					VBlanking_i,				// 
input		wire					DE_i,
input		wire	[11:0]			HLineCount_i,
input		wire	[11:0]			HPixelCount_i,
input 		wire	[15:0]			HBLANK_START_i, 			//1
input 		wire	[15:0]			HBLANK_STOP_i,				//256
input		wire	[15:0]			Limit_Resolution_X_i,		//640/320/800/400
input		wire	[15:0]			Limit_Resolution_Y_i,		//480/240/600/300

output	wire	[31:0]		Pointer_RGB_o
);

wire	[15:0]	Limit_Resolution_X_Less_Pointer_Size;
wire	[15:0]	Limit_Resolution_Y_Less_Pointer_Size;

assign Limit_Resolution_X_Less_Pointer_Size = Limit_Resolution_X - 16'h0010;
assign Limit_Resolution_Y_Less_Pointer_Size = Mstr_Ctrl_Doubling_Pixel_i ? (Limit_Resolution_Y - 16'h0020) : (Limit_Resolution_Y - 16'h0010);

wire 	[15:0]	Limit_Resolution_X;
wire 	[15:0]	Limit_Resolution_Y;

assign Limit_Resolution_X = Mstr_Ctrl_Doubling_Pixel_i ? {1'b0, Limit_Resolution_X_i[15:1]} : Limit_Resolution_X_i;
assign Limit_Resolution_Y = Limit_Resolution_Y_i;


reg	[5:0]		Size_X;
reg	[5:0]		Size_Y;

wire  [31:0] PixelChoiceOut;

wire	[15:0]	Adjusted_LineCount;
wire	[15:0]	Adjusted_PixelCount;

reg	[15:0]	MOUSE_PTR_X_POS;
reg	[15:0]	MOUSE_PTR_Y_POS;

reg	[1:0]		SOF_i_EDGE;

reg				VideoClk_MousePointerChoice;

// Mouse_Y_Final = Official Position of the Mouse (upper Left Corner)
// Mouse_X_Final = Official Position of the Mouse (upper left Corner)

reg	[15:0]	Local_Pixel_Counter;
reg	[15:0]	Local_Pixel_Counter_Lat;
reg	[15:0]	Local_Line_Counter;

localparam ColorMixerLatency = 16'h0002;	// Substract 2 more clock to compensate for the Clocks taken in the Color Mixer at the end
//localparam ColorMixerLatencyBis = 16'h0004;	// Substract 2 more clock to compensate for the Clocks taken in the Color Mixer at the end
wire 	[15:0] 	ColorMixerLatencyBis;
assign ColorMixerLatencyBis = Mstr_Ctrl_Doubling_Pixel_i ? 16'h0004 : 16'h0003;


wire	Local_HBlank_Latenced_0Clk;
wire 	Local_HBlank_Latenced_2Clk;
assign Local_HBlank_Latenced_0Clk = (HPixelCount_i > HBLANK_START_i - ColorMixerLatency) & ( (HPixelCount_i <=  HBLANK_STOP_i - ColorMixerLatency));
assign Local_HBlank_Latenced_2Clk = (HPixelCount_i > (HBLANK_START_i - ColorMixerLatencyBis) & ( HPixelCount_i <=  (HBLANK_STOP_i - ColorMixerLatencyBis)));
/*
// Local Creation of the Blanking signal to match the mouse pipeline system
always @ (posedge VideoClk_i) begin
	if ( VideoModeReset_i ) begin
		Local_HBlank_Latenced_2Clk	<= 1'b0;
		Local_HBlank_Latenced_0Clk <= 1'b0;
	end
	else begin
		// Count from 0 to 1055
		if (HPixelCount_i >= (HBLANK_STOP_i - 16'h0001) begin
			Local_HBlank_Latenced_2Clk <= 1'b0;
			Local_HBlank_Latenced_0Clk <= 1'b0;			
		end

		if (HPixelCount_i == (HBLANK_START_i))
			Local_HBlank_Latenced_0Clk <= 1'b1;	
		
		if (HPixelCount_i == (HBLANK_START_i - 16'h0002))
			Local_HBlank_Latenced_2Clk <= 1'b1;		
			

	end
end
*/
// Pixel Number Visible - 0 Clock Latency
always @ (posedge VideoClk_i)
begin
	if (Local_HBlank_Latenced_0Clk) begin
		Local_Pixel_Counter <= Local_Pixel_Counter + 16'h0001;
	end
	else begin
		Local_Pixel_Counter <= 16'h0000;
	end
end

// Pixel Number Visible - 2 Clock Latency
always @ (posedge VideoClk_i)
begin
	if (Local_HBlank_Latenced_2Clk) begin
		Local_Pixel_Counter_Lat <= Local_Pixel_Counter_Lat + 16'h0001;
	end
	else begin
		Local_Pixel_Counter_Lat <= 16'h0000;
	end
end

reg	HBlanking_Dly_EDGE;
// Line Number Visible
always @ (posedge VideoClk_i) 
begin
	HBlanking_Dly_EDGE <= Local_HBlank_Latenced_2Clk;

	if (VBlanking_i) begin
		if ({ HBlanking_Dly_EDGE, Local_HBlank_Latenced_2Clk } == 2'b10) begin
			Local_Line_Counter <= Local_Line_Counter + 16'h0001;
		end
	end
	else begin
		Local_Line_Counter <= 16'h0000;
	end
end

//reg VideoModeChoice;

// Let's Enforce the Limits
always @ (posedge VideoClk_i)
begin
	if (VideoModeReset_i  || VideoRst_i) begin
		MOUSE_PTR_X_POS <= 16'h0000;
		MOUSE_PTR_Y_POS <= 16'h0000;
		//Official_Coord_Y0 <= 16'h0000;
		//Official_Coord_Y1 <= 16'h0000;		
	end
	else begin
		SOF_i_EDGE[0] <= SOF_i;
		SOF_i_EDGE[1] <= SOF_i_EDGE[0];

		// Waiting for a Start of Frame Make the Position Official
		if (Vsync_EDGE[1:0] == 2'b01) begin
			MOUSE_PTR_X_POS 	<= Mouse_X_Final_META2;			
			MOUSE_PTR_Y_POS     <= Mouse_Y_Final_META2;
			
			// Let's Check the Value of Final X
			if (Mouse_X_Final_META2 > Limit_Resolution_X) begin
				//Official_Coord_X0 <= Limit_Resolution_X_i;
				//Official_Coord_X1	<= Limit_Resolution_X_i;
				Size_X				<= 6'b00_0000;
			end
			else begin
				if (Mouse_X_Final_META2 > Limit_Resolution_X_Less_Pointer_Size) begin
					Size_X <= ( Limit_Resolution_X - Mouse_X_Final_META2 );
				end
				else begin
					Size_X				<= 6'b01_0000;
				end
				//Official_Coord_X0 <= Mouse_X_Final_META2;
				//Official_Coord_X1	<= Official_Coord_X0 + 16'h0010;				
			end
			
			
			// Let's Check the Value of Y to see if crosses the boundaries
			if (Mouse_Y_Final_META2 >= Limit_Resolution_Y) begin
				Size_Y 				<= 6'b00_0000;
			end
			else begin
				if (Mouse_Y_Final_META2 > Limit_Resolution_Y_Less_Pointer_Size) begin
					Size_Y <= ( Limit_Resolution_Y - Mouse_Y_Final_META2 );
				end
				else begin
					if (Mstr_Ctrl_Doubling_Pixel_i)
						Size_Y 				<= 6'b10_0000;
					else
						Size_Y 				<= 6'b01_0000;
				end			
			end	

			VideoClk_MousePointerChoice <= MOUSEPTR_REG[0][1];
		end
	end
end


reg	[15:0]	Official_Coord_X0;
reg	[15:0]	Official_Coord_Y0;
reg	[15:0]	Official_Coord_X1;
reg	[15:0]	Official_Coord_Y1;

always @ (posedge VideoClk_i)
begin
	if (VideoRst_i || VideoModeReset_i) begin
		Official_Coord_X0 <= 16'h0000;
		Official_Coord_Y0 <= 16'h0000;
		Official_Coord_X1 <= 16'h0000;
		Official_Coord_Y1 <= 16'h0000;
	end
	else begin
			Official_Coord_X0 <= (MOUSE_PTR_X_POS > Limit_Resolution_X) ? ( Limit_Resolution_X - 16'h0001) : MOUSE_PTR_X_POS;
			Official_Coord_X1 <= (MOUSE_PTR_X_POS > Limit_Resolution_X) ? ( Limit_Resolution_X - 16'h0001) : ( MOUSE_PTR_X_POS + Size_X );
			Official_Coord_Y0 <= (MOUSE_PTR_Y_POS > Limit_Resolution_Y) ? ( Limit_Resolution_Y - 16'h0001) : MOUSE_PTR_Y_POS;
			Official_Coord_Y1 <= (MOUSE_PTR_Y_POS > Limit_Resolution_Y) ? ( Limit_Resolution_Y - 16'h0001) : ( MOUSE_PTR_Y_POS + Size_Y );	
	
	end
end




//assign Official_Coord_X0 = (MOUSE_PTR_X_POS > Limit_Resolution_X) ? ( Limit_Resolution_X - 16'h0001) : MOUSE_PTR_X_POS;
//assign Official_Coord_X1 = (MOUSE_PTR_X_POS > Limit_Resolution_X) ? ( Limit_Resolution_X - 16'h0001) : ( MOUSE_PTR_X_POS + Size_X );
//assign Official_Coord_Y0 = (MOUSE_PTR_Y_POS > Limit_Resolution_Y) ? ( Limit_Resolution_Y - 16'h0001) : MOUSE_PTR_Y_POS;
//assign Official_Coord_Y1 = (MOUSE_PTR_Y_POS > Limit_Resolution_Y) ? ( Limit_Resolution_Y - 16'h0001) : ( MOUSE_PTR_Y_POS + Size_Y );


wire 	Vertical_Active;
wire	Horizontal_Active;
wire	Horizontal_Active_Lat;

reg	[5:0]	Mouse_Pointer_X_Counter;
reg	[5:0]	Mouse_Pointer_Y_Counter;

assign	Horizontal_Active_Lat 	= (Local_Pixel_Counter_Lat >= Official_Coord_X0) & (Local_Pixel_Counter_Lat < Official_Coord_X1) & Local_HBlank_Latenced_2Clk & VBlanking_i;

assign	Horizontal_Active 		= (Local_Pixel_Counter >= Official_Coord_X0) & (Local_Pixel_Counter < Official_Coord_X1) & Local_HBlank_Latenced_0Clk & VBlanking_i;

assign	Vertical_Active   		= (Local_Line_Counter >= Official_Coord_Y0) & (Local_Line_Counter < Official_Coord_Y1 );	// HLineCount is divided when LowResmode is enabled

reg 	[1:0] Vsync_EDGE;
reg	[1:0]	de_EDGE;

// Let's Enforce the Limits
always @ (posedge VideoClk_i)
begin
		Vsync_EDGE[0] <= VSync_i;
		Vsync_EDGE[1] <= Vsync_EDGE[0];

		de_EDGE[0] <= DE_i;
		de_EDGE[1] <= de_EDGE[0];
end

reg	[2:0]	StateMachine;

localparam		IDLE = 		3'b000,
					STATE_1 = 	3'b001,
					STATE_2 = 	3'b010,
					STATE_3 = 	3'b011,
					STATE_4 = 	3'b100,
					STATE_5 = 	3'b100;

					
//reg LineTwice;					
// This is the Process to Transfer Line Pixels in Output RGB Pixel Line
always @ (posedge VideoClk_i)
begin
	if (VideoRst_i || VideoModeReset_i) begin
		StateMachine <= IDLE;
      Mouse_Pointer_X_Counter     <= 6'b00_0000;
      Mouse_Pointer_Y_Counter     <= 6'b00_0000;     
		//LineTwice					  <= 1'b0;
	end
	else begin
	
		case (StateMachine)
		
        // Let's begin the preparation when a new Frame Begins
        IDLE:
        begin
			if ((Vsync_EDGE[1:0] == 2'b10) && MOUSEPTR_REG[0][0] && ( Size_Y )) begin
				StateMachine        <= STATE_1;
				Mouse_Pointer_X_Counter     <= 6'b00_0000;
				Mouse_Pointer_Y_Counter     <= 6'b00_0000;
				//LineTwice					<= 1'b0;
			end
        end

	
        STATE_1:
        begin
				if (Horizontal_Active_Lat & Vertical_Active) begin
					Mouse_Pointer_X_Counter <= Mouse_Pointer_X_Counter + 6'b00_0001;
					StateMachine    <= STATE_2;
				end
					else
						StateMachine    <= STATE_1;
        end
		  
        STATE_2: 
        begin
			if (Mouse_Pointer_X_Counter < Size_X) begin
				Mouse_Pointer_X_Counter <= Mouse_Pointer_X_Counter + 6'b00_0001;
				StateMachine    <= STATE_2;
			end
			else begin
				Mouse_Pointer_X_Counter <= 6'b00_0000;
				Mouse_Pointer_Y_Counter <= Mouse_Pointer_Y_Counter + 6'b00_0001;				
				//if ( VideoModeChoice ) begin
				//	if (LineTwice) begin
				//		Mouse_Pointer_Y_Counter <= Mouse_Pointer_Y_Counter + 6'b00_0001;
				//		LineTwice <= 1'b0;					
				//	end
				//	else begin
				//		LineTwice <= 1'b1;
				//	end
				//end
				//else begin
				//		Mouse_Pointer_Y_Counter <= Mouse_Pointer_Y_Counter + 6'b00_0001;	
				//end
				StateMachine    <= STATE_3;
            end
        end

        STATE_3:
        begin
			if (Mouse_Pointer_Y_Counter < Size_Y)
            StateMachine    <= STATE_4;
			else
				StateMachine    <= IDLE;
        end

        // Wait One Clock Cycle to Get Valid Output from FONT Graphic Memory
        STATE_4:
        begin
            if (de_EDGE[1:0] == 2'b10) begin    // wait for the Line to end
                    StateMachine    <= STATE_1;
            end
        end		  
		
		default: begin
			StateMachine <= IDLE;
		end
		
		
		endcase
	end
end


/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger1 = (Horizontal_Active & Vertical_Active);

assign TinyTP1[8:0]  	= {VideoClk_MousePointerChoice, Mstr_Ctrl_Doubling_Pixel_i ? Mouse_Pointer_Y_Counter[4:1] : Mouse_Pointer_Y_Counter[3:0], Mouse_Pointer_X_Counter[3:0]};
assign TinyTP1[47:16] 	= PixelChoiceOut;
assign TinyTP1[48]   	= Horizontal_Active;
assign TinyTP1[49]		= Vertical_Active;




TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (VideoClk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/
MousePointerSprite MousePointerMem (
	.data( Bus_D32_i ),
	.rdaddress( {VideoClk_MousePointerChoice, Mstr_Ctrl_Doubling_Pixel_i ? Mouse_Pointer_Y_Counter[4:1] : Mouse_Pointer_Y_Counter[3:0], Mouse_Pointer_X_Counter[3:0]} ),				// Address Counter
	.rdclock( VideoClk_i ),
	.wraddress(  {!Bus_A_i[10],Bus_A_i[9:2]} ),
	.wrclock( Bus_Clk_i ),
	.wren( Mouse_Pointer_Mem_CS_i & !Bus_RW_i & ( Bus_D_Siz_i[1:0] == 2'b00 ) & Bus_WE_i ),
	.q( PixelChoiceOut )
);

assign Pointer_RGB_o = (Horizontal_Active & Vertical_Active) ? PixelChoiceOut :32'h00_00_00_00; //the A2560K has Color Now

/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger1 = Mouse_Pointer_Mem_CS_i & !Bus_RW_i & Bus_BE_i[1] & Bus_BE_i[0];

assign TinyTP1[15:0]  	= Bus_D16_i;
assign TinyTP1[26:16] 	= Bus_A_i[10:0];
assign TinyTP1[27]   	= Mouse_Pointer_Mem_CS_i & !Bus_RW_i & Bus_BE_i[1] & Bus_BE_i[0];
assign TinyTP1[28]		= Vertical_Active;
assign TinyTP1[39:30]	= {!Bus_A_i[10],Bus_A_i[9:1]};

TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (Bus_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/
////
//Register Block of 16Bytes
////
reg [15:0]		MOUSEPTR_REG[0:7];


// Writing Part
always @ (posedge Bus_Clk_i)
begin
	if (rst_i)
	begin
		MOUSEPTR_REG[0] <= 16'h0000;		// MOUSE_PTR_CTRL_REG
		MOUSEPTR_REG[1] <= 16'h0000;		// MOUSE_PTR_X_POS
		MOUSEPTR_REG[2] <= 16'h0000;		// MOUSE_PTR_Y_POS
		MOUSEPTR_REG[3] <= 16'h0000;		// 
		MOUSEPTR_REG[4] <= 16'h0000;		// 
		MOUSEPTR_REG[5] <= 16'h0000;		// 
		MOUSEPTR_REG[6] <= 16'h0000;		// 
		MOUSEPTR_REG[7] <= 16'h0000;		// 
	end
	else
	begin
		if (Mouse_Pointer_Reg_CS_i && !Bus_RW_i && ( Bus_D_Siz_i[1:0] == 2'b10 ) & Bus_WE_i)
			MOUSEPTR_REG[Bus_A_i[3:1]] <= Bus_D16_i;
	end
end

always @ (*)
begin
	case(Bus_A_i[3:2])
		2'b00: Bus_D_o = { 16'h0000, MOUSEPTR_REG[0] };		// MOUSE_PTR_CTRL_REG_L
		2'b01: Bus_D_o = { Mouse_Y_Final[15:0], Mouse_X_Final[15:0] };
		2'b10: Bus_D_o = { MOUSEPTR_REG[5] , 16'h0000 };
		2'b11: Bus_D_o = { MOUSEPTR_REG[7] , MOUSEPTR_REG[6] };
	endcase
end

reg [15:0] Mouse_X_Final_META0;
reg [15:0] Mouse_X_Final_META1;
reg [15:0] Mouse_X_Final_META2;

reg [15:0] Mouse_Y_Final_META0;
reg [15:0] Mouse_Y_Final_META1;
reg [15:0] Mouse_Y_Final_META2;
//Mstr_Ctrl_Video_Mode_14Mhz_i
always @ (posedge VideoClk_i) 
begin
	Mouse_X_Final_META0 <= Mouse_X_Final;
	Mouse_X_Final_META1 <= Mouse_X_Final_META0;
	if (Mouse_X_Final_META1 == Mouse_X_Final_META0)
		Mouse_X_Final_META2 <= Mouse_X_Final_META1;

	Mouse_Y_Final_META0 <= Mouse_Y_Final;
	Mouse_Y_Final_META1 <= Mouse_Y_Final_META0;	
	if (Mouse_Y_Final_META1 == Mouse_Y_Final_META0)
		Mouse_Y_Final_META2 <= Mouse_Y_Final_META1;
end


reg [15:0]	Mouse_X;
reg [15:0]	Mouse_Y;

reg [15:0]	Mouse_X_Final;
reg [15:0]	Mouse_Y_Final;


localparam 	IDLE_ST 		= 	3'b000,
				State0	= 	3'b001,
				State1	= 	3'b010,
				State2	= 	3'b011,
				State3	= 	3'b100,
				State4	= 	3'b101,
				State5	=  3'b110;

reg	[2:0]	Mouse_state;
reg	[15:0] Limit_Resolution_X_14Mhz;
reg	[15:0] Limit_Resolution_Y_14Mhz;

/*
always @ (*) begin
	case(Mstr_Ctrl_Video_Mode_14Mhz_i[1:0])
		2'b00: begin Limit_Resolution_X_14Mhz = 16'd640; Limit_Resolution_Y_14Mhz = 16'd480; end
		2'b01: begin Limit_Resolution_X_14Mhz = 16'd320; Limit_Resolution_Y_14Mhz = 16'd240; end
		2'b10: begin Limit_Resolution_X_14Mhz = 16'd800; Limit_Resolution_Y_14Mhz = 16'd600; end
		2'b11: begin Limit_Resolution_X_14Mhz = 16'd400; Limit_Resolution_Y_14Mhz = 16'd300; end
	endcase
end
*/

always @ (*) begin
	case(Mstr_Ctrl_Video_Mode_CPU_i[1:0])
		2'b00: begin Limit_Resolution_X_14Mhz = 16'd1280; Limit_Resolution_Y_14Mhz = 16'd960; end
		2'b01: begin Limit_Resolution_X_14Mhz = 16'd1280; Limit_Resolution_Y_14Mhz = 16'd1024; end
		2'b10: begin Limit_Resolution_X_14Mhz = 16'd1280; Limit_Resolution_Y_14Mhz = 16'd960;  end
		2'b11: begin Limit_Resolution_X_14Mhz = 16'd1280; Limit_Resolution_Y_14Mhz = 16'd1024; end
	endcase
end


always @ (posedge Bus_Clk_i)
begin
	if (rst_i) begin
		Mouse_state <= IDLE_ST;
		
	end
	else begin
	
		case(Mouse_state)
		
		// Wait for the First Byte to be written (b0)
		IDLE_ST: begin
			if (Mouse_Pointer_Reg_CS_i && !Bus_RW_i && (Bus_A_i[3:1] == 3'b101))
				Mouse_state <= State0;
			else
				Mouse_state <= IDLE_ST;		
		end
		
		// Wait for the Second Byte to be Written (b1)
		State0: begin
			if (Mouse_Pointer_Reg_CS_i && !Bus_RW_i && (Bus_A_i[3:1] == 3'b110))
				Mouse_state <= State1;
			else
				Mouse_state <= State0;				
		
		end
		
		// Finally, this is the last byte from the Mouse Packet (b2)
		State1: begin
			if (Mouse_Pointer_Reg_CS_i && !Bus_RW_i && (Bus_A_i[3:1] == 3'b111))
				Mouse_state <= State2;
			else
				Mouse_state <= State1;			
		end
		
		// Let's Compute the Results
		State2: begin
		// Compute X
			if (MOUSEPTR_REG[5][4]) begin
				Mouse_X <= Mouse_X - (9'h100 - MOUSEPTR_REG[6][7:0]);
			end
			else begin
				Mouse_X <= Mouse_X + MOUSEPTR_REG[6][7:0];
			end
				Mouse_state <= State3;				
		end
		
		State3: begin
		// Compute Y
			if (MOUSEPTR_REG[5][5]) begin
				Mouse_Y <= Mouse_Y + (9'h100 - MOUSEPTR_REG[7][7:0]);
			end
			else begin
				Mouse_Y <= Mouse_Y - MOUSEPTR_REG[7][7:0];
			end
				Mouse_state <= State4;					
		end
		
		State4: begin
		if (Mouse_X[15]) begin // X is negative
			Mouse_X <= 16'h0000;
			end
		else begin
				if (Mouse_X > Limit_Resolution_X_14Mhz)
				Mouse_X <= (Limit_Resolution_X_14Mhz - 16'h0001);
		end
		
		if (Mouse_Y[15]) begin // X is negative
			Mouse_Y <= 16'h0000;
			end
		else begin
				if (Mouse_Y > Limit_Resolution_Y_14Mhz)
				Mouse_Y <= (Limit_Resolution_Y_14Mhz - 16'h0001);
		end
		
		Mouse_state <= State5;
		end
		
		State5:
		begin
			Mouse_X_Final <= {4'b0000, Mouse_X[11:0]};		
			Mouse_Y_Final <= {4'b0000, Mouse_Y[11:0]};
		Mouse_state <= IDLE_ST;	
		
		end
		
		default: begin
			Mouse_state <= IDLE_ST;
		end
		
		endcase
	
	
	end

end

/*
wire	[63:0]	 Chipscope;
wire				Trigger;

assign Chipscope[15:0] 	= Mouse_X;
assign Chipscope[31:16] = Mouse_Y;
assign Chipscope[39:32] = MOUSEPTR_REG[6];
assign Chipscope[47:40] = MOUSEPTR_REG[7];
assign Chipscope[55:48] = MOUSEPTR_REG[8];
assign Chipscope[58:56] = Mouse_state;
assign Chipscope[59] = Horizontal_Active;
assign Chipscope[60] = Vertical_Active;
assign Chipscope[61] = 1'b0;
assign Chipscope[62] = 1'b0;
assign Chipscope[63] = 1'b0;

assign Trigger = (Mouse_state == State4) ? 1'b1 : 1'b0;

ChipScope IntelChipScope(
		.acq_clk(!Bus_Clk_i),        //    acq_clk.clk
		.acq_data_in(Chipscope),    //        tap.acq_data_in
		.acq_trigger_in(Trigger), //           .acq_trigger_in
		.trigger_in(Trigger)      // trigger_in.trigger_in
	);
*/

endmodule
