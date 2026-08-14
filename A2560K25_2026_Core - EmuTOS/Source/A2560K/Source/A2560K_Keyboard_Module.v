module A2560K_Keyboard_Module(


input		wire				CPU_Clk_i,
input		wire				RST_i,
input		wire	[31:0]	iBUS_A_i,
input		wire				iBUS_A_Valid_i,
input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]	iBUS_D16_i,
input		wire	[31:0]	iBUS_D32_i,
input		wire	[1:0]		iBUS_D_Siz_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i, 
input		wire				iBUS_RWn_i,
input		wire				CS_A2560K_KB_i,
input		wire				CS_MAUS_RGB_i,
output	reg	[31:0]	iBUS_Keyboard_D_o,

output	wire				A2560K_Keyboard_IRQ_o,
// Keyboard
// SPI Interface
input		wire				KBD_CSn_i,
input		wire				KBD_CLK_i,
output	wire				KBD_MISO_o,
input		wire				KBD_MOSI_i,
output	wire				KBD_INTn_o, 

// Matrix RGB LED
output	wire				MTX_CLK_o,
output	wire				MTX_LATCH_o,
output	wire				MTX_SERIAL_IN_o,

input		wire				SOF_i,
// Status RGB LED
output	wire				STS_CLK_o,
output	wire				STS_LATCH_o,
output	wire				STS_SERIAL_IN_o,

input		wire	[11:0] 	KBD_RGB_Value_i

//input		wire					SOF_i,

//input		wire	[7:0]			Led0_R_i,
//input		wire	[7:0]			Led0_G_i,
//input		wire	[7:0]			Led0_B_i,

//input		wire	[7:0]			Led1_R_i,
//input		wire	[7:0]			Led1_G_i,
//input		wire	[7:0]			Led1_B_i,

//input		wire	[7:0]			Led2_R_i,
//input		wire	[7:0]			Led2_G_i,
//input		wire	[7:0]			Led2_B_i,

//input		wire	[7:0]			Led3_R_i,
//input		wire	[7:0]			Led3_G_i,
//input		wire	[7:0]			Led3_B_i


);


reg [2:0] Active_Led;
reg [3:0] Active_Led_Slide;
reg [2:0] Active_Led_Color;
reg [7:0] PWM_Counter;

always @ (*) begin
		
		case (Active_Led)
		3'b000: begin 
		Active_Led_Color <= KBD_RGB_Value_i[2:0];
		Active_Led_Slide <= 4'b0001;
		end
		
		3'b010: begin 
		Active_Led_Color <= KBD_RGB_Value_i[5:3];		
		Active_Led_Slide <= 4'b0010;		
		end
		
		
		3'b100: begin
		Active_Led_Color <= KBD_RGB_Value_i[8:6];		
		Active_Led_Slide <= 4'b0100;		
		end
		
		
		3'b110: begin 
		Active_Led_Color <= KBD_RGB_Value_i[11:9];		
		Active_Led_Slide <= 4'b1000;
		end
		
		default: begin
			Active_Led_Color <= 3'b000;		
			Active_Led_Slide <= 4'b0000;		
		end
		endcase

end

Keyboard_RGB_Matrix_Module KBD_LED_RGB(

	.Clk_i( CPU_Clk_i ),
	.Rst_i( RST_i ),
	.iBUS_A_i( iBUS_A_i ),
	.iBUS_A_Valid_i( iBUS_A_Valid_i ),
	.iBUS_D8_i( iBUS_D8_i  ),
	.iBUS_D16_i( iBUS_D16_i ),
	.iBUS_D32_i( iBUS_D32_i ),
	.iBUS_D_Siz_i( iBUS_D_Siz_i ),
	.iBUS_RWn_i( iBUS_RWn_i ),
	.iBUS_BE_i( iBUS_BE_i ),
	.iBUS_WE_i( iBUS_WE_i ), 	
	.CS_MAUS_RGB_i( CS_MAUS_RGB_i ), 
	

	.SOF_i( SOF_i ), 
	
	.MTX_CLK_o( MTX_CLK_o ),
	.MTX_LATCH_o( MTX_LATCH_o ),
	.MTX_SERIAL_IN_o( MTX_SERIAL_IN_o )


);

// Keyboard
assign STS_CLK_o 			= STS_Clock_Out;
assign STS_LATCH_o 		= STS_Latch_Out;
assign STS_SERIAL_IN_o 	= STS_Value_2_Slide[7];

//assign iBUS_Keyboard_D_o = 16'h0000;
/*
wire [15:0] Source;
wire [31:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);
*/

reg [15:0] TimeCount;

//reg STS_Serial_Out;
reg STS_Latch_Out;
reg STS_Clock_Out;
reg [7:0] STS_Value_2_Slide_Copy;
reg [7:0] STS_Value_2_Slide;
reg [2:0] SM_Status;
reg [3:0] STS_Counter;

always @ (posedge CPU_Clk_i) begin

	if ( RST_i ) begin
		STS_Clock_Out  <= 1'b0;
		STS_Latch_Out  <= 1'b0;
		STS_Value_2_Slide <= 8'h00;
		SM_Status <= 3'b000;
	end
	else begin
	
		case (SM_Status)
		
		3'b000: begin 
			STS_Value_2_Slide <= { Active_Led_Color[2], Active_Led_Color[0], Active_Led_Color[1], 1'b0, Active_Led_Slide };
			STS_Clock_Out  <= 1'b0;				
			STS_Counter <= 4'h7;
			SM_Status <= 3'b001;
			TimeCount <= 16'd19530;
		end
		
		//Clock Low Here
		3'b001: begin 
			STS_Clock_Out 	<= 1'b1;			
			SM_Status 		<= 3'b010;		
		end		
		
		//Clock HIGH Here
		3'b010: begin 
			STS_Clock_Out  <= 1'b0;			
			if (STS_Counter) begin 
				STS_Counter				<= STS_Counter - 4'b0001;
				STS_Value_2_Slide  	<= STS_Value_2_Slide << 1'b1;
				SM_Status 				<= 3'b001;
			end 
			else begin
				SM_Status 				<= 3'b011;
			
			end
		end		
		//Shift
		3'b011: begin 
			SM_Status 		<= 3'b100;
			STS_Latch_Out  <= 1'b1;
		end		
		
		3'b100: begin
			SM_Status 		<= 3'b101;
			STS_Latch_Out  <= 1'b0;
		end
		
		3'b101: begin
			SM_Status 		<= 3'b110;
		end
		
		// Count
		3'b110: begin
			if (TimeCount) begin
				TimeCount <= TimeCount - 16'h0001;
			end
			else begin
				Active_Led  <= Active_Led + 3'b001;
				PWM_Counter <= PWM_Counter + 8'h01;
			 SM_Status 		<= 3'b000;			
			end
		end
		
		default: begin
			SM_Status 		<= 3'b000;
		end

		
		
		endcase
	
	end
end

// KEYBOARD Routine
assign KBD_MISO_o = KBD_CLK_SLIP;
assign KBD_INTn_o = 1'b1;	//Active Low

//reg	[2:0]		KBD_CSn_RESYNC;
//reg	[2:0]		KBD_CLK_RESYNC;
//reg	[2:0]		KBD_MOSI_RESYNC;

//reg	KBD_CSn_EDGE;
//reg	KBD_CLK_EDGE;
//reg 	KBD_MOSI_EDGE;
reg CS_A2560K_KB_i_EDGE;
wire CS_FIFO_ACCESS;
assign CS_FIFO_ACCESS = CS_A2560K_KB_i & ( iBUS_D_Siz_i == 2'b00 ) & (iBUS_A_i[2:0] == 3'b000);

always @ (posedge CPU_Clk_i) begin
	CS_A2560K_KB_i_EDGE <= CS_FIFO_ACCESS; //CS_A2560K_KB_i & ( iBUS_BE_i[1] | iBUS_BE_i[0]) & !iBUS_RWn_i
end

wire empty_sig;
wire full_sig;
wire [7:0] usedw_sig;

always @ ( * ) begin
	if ( iBUS_A_i[2] ) 
		begin 
			iBUS_Keyboard_D_o = 32'h0001_0000; 
		end
	else
		begin 
			iBUS_Keyboard_D_o = { empty_sig, full_sig, 6'b00_0000, usedw_sig, KeyboardCodeFIFO_o}; 
		end
end

wire [15:0] KeyboardCodeFIFO_o;


assign A2560K_Keyboard_IRQ_o = !empty_sig | full_sig;


A2560K_KB_FIFO16	A2560K_KB_FIFO16_inst (
	.aclr ( RST_i ), 
	.clock ( CPU_Clk_i ),
	.data ( MOs_DATA ),
	.rdreq ( { CS_A2560K_KB_i_EDGE, CS_FIFO_ACCESS } == 2'b01 ),
	.wrreq ( MOs_DATA_Wr_Slip[2] ), // Rising Edge of CS
	.empty ( empty_sig ),
	.full ( full_sig ),
	.q ( KeyboardCodeFIFO_o ),
	.usedw ( usedw_sig )
);

/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

assign TinyTrigger1 		= ({KBD_CSn_SLIP,KBD_CSn_RESYNC[1]} == 2'b01) ? 1'b1 : 1'b0;

assign TinyTP1[16:0] 	= {1'b0, BitData[15:0]};
assign TinyTP1[17]		= KBD_CSn_i;
assign TinyTP1[18] 		= KBD_CLK_i;
assign TinyTP1[19] 		= KBD_MOSI_i;
assign TinyTP1[20]		= MOs_DATA_Wr_Slip[2];
assign TinyTP1[47:32] 	= MOs_DATA;
assign TinyTP1[52:48] 	= MOs_DATA_Wr_Slip;
assign TinyTP1[60:53] 	= usedw_sig;
assign TinyTP1[61] 		= empty_sig;
assign TinyTP1[64:62] 	= SM_KEY;
assign TinyTP1[65]      = A2560K_Keyboard_IRQ_o;

TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (CPU_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/

reg [1:0] KBD_CSn_RESYNC;
reg [1:0] KBD_CLK_RESYNC;
reg [1:0] KBD_MOSI_RESYNC;

reg		KBD_CSn_SLIP;
reg		KBD_CLK_SLIP;
reg		KBD_MOSI_SLIP;

always @ (posedge CPU_Clk_i) begin
		KBD_CSn_RESYNC[0] <= KBD_CSn_i;
		KBD_CSn_RESYNC[1] <= KBD_CSn_RESYNC[0];

		KBD_CLK_RESYNC[0] <= KBD_CLK_i;
		KBD_CLK_RESYNC[1] <= KBD_CLK_RESYNC[0];
		
		KBD_MOSI_RESYNC[0] <= KBD_MOSI_i;
		KBD_MOSI_RESYNC[1] <= KBD_MOSI_RESYNC[0];
end

always @ (posedge CPU_Clk_i) begin
		if (KBD_CSn_RESYNC[0] == KBD_CSn_RESYNC[1])
			KBD_CSn_SLIP <= KBD_CSn_RESYNC[1];
			
		if (KBD_CLK_RESYNC[0] == KBD_CLK_RESYNC[1])
			KBD_CLK_SLIP <= KBD_CLK_RESYNC[1];
	
		if (KBD_MOSI_RESYNC[0] == KBD_MOSI_RESYNC[1])
			KBD_MOSI_SLIP <= KBD_MOSI_RESYNC[1];
end

reg	[2:0]		SM_KEY;

localparam 	IDLE	= 3'b000,
				ST0	= 3'b001,
				ST1	= 3'b010,
				ST2	= 3'b011,
				ST3	= 3'b100,
				ST4	= 3'b101,
				ST5	= 3'b110,
				ST6	= 3'b111;
				
reg 	[15:0] 	BitData;
reg 	[4:0] 	BitCount;
reg 	[15:0] 	MOs_DATA;
reg 	[2:0] 	MOs_DATA_Wr_Slip;

always @ (posedge CPU_Clk_i) begin
	if ( RST_i ) begin
		BitCount <= 5'b0_0000;
		BitData  <= 16'h00000;
		MOs_DATA <= 16'h0000;
		MOs_DATA_Wr_Slip <= 3'b000;
		SM_KEY	<= IDLE;
	end
	else begin
	
		MOs_DATA_Wr_Slip <= MOs_DATA_Wr_Slip << 1'b1;
	
		case (SM_KEY)
		
		IDLE: begin 
			if ( KBD_CSn_SLIP ) begin
				SM_KEY <= IDLE;			
			end
			else begin
				SM_KEY 	<= ST0;
				BitCount <= 5'b0_0000;
				BitData	<= 16'h0000;
			end
		end
		
		// Wait for Clock to high
		ST0: begin 
			SM_KEY <= ST1;
		end
		
		ST1: begin 
			
			if ( KBD_CLK_SLIP ) begin
				SM_KEY <= ST2;
			end 
			else begin
				SM_KEY <= ST0;			
			end			
			
		end
		
		ST2: begin 
			BitData 	<= {BitData[14:0], KBD_MOSI_SLIP};
			BitCount <= BitCount + 5'b0_0001;		
			SM_KEY <= ST3;
		end
		
		// for Clock to go low
		ST3: begin 
			if ( KBD_CLK_SLIP ) begin
				SM_KEY <= ST3;
			end
			else begin			
				SM_KEY <= ST4;
			end
		end
		
		ST4: begin 
			if ( BitCount < 5'd16 ) begin
				SM_KEY <= ST0;
			end
			else begin
				SM_KEY <= ST5;
			end
		end
		
		ST5: begin 
			if ( KBD_CSn_SLIP ) begin
				MOs_DATA <= BitData;
				MOs_DATA_Wr_Slip <= 3'b001;				
				SM_KEY <= IDLE;
			end
			else begin
				SM_KEY <= ST5;
			end
		end
		
		default: begin
				SM_KEY <= IDLE;
		end

		endcase
	
	end
end






endmodule

/*
reg 	[15:0] 	Value_Received_Resync[0:2];
reg	[2:0] 	KBD_CSn_EDGE;
reg 	[15:0] 	MOs_DATA;
reg 	[4:0] 	MOs_DATA_Wr_Slip;

always @ (posedge CPU_Clk_i) begin
	if ( RST_i ) begin
		KBD_CSn_EDGE <= 3'b000;
		Value_Received_Resync[0] <= 16'h0000;
		Value_Received_Resync[1] <= 16'h0000;
		Value_Received_Resync[2] <= 16'h0000;	
	end
	else begin

		Value_Received_Resync[0] <= MOs_DATA;
		Value_Received_Resync[1] <= Value_Received_Resync[0];
		
		if ( Value_Received_Resync[1] == Value_Received_Resync[0] ) begin
			Value_Received_Resync[2] <= Value_Received_Resync[1];
		end
	
		KBD_CSn_EDGE[0] <= KBD_CSn_i;
		KBD_CSn_EDGE[1] <= KBD_CSn_EDGE[0];
		
		if ( KBD_CSn_EDGE[1] == KBD_CSn_EDGE[0] ) begin
			KBD_CSn_EDGE[2] <= KBD_CSn_EDGE[1];
		end
	
	

	end
	
end

always @ (posedge CPU_Clk_i) begin
	if ( RST_i ) begin
		MOs_DATA <= 16'h0000;
		MOs_DATA_Wr_Slip <= 5'b0_0000;

	end
	else begin
			
		MOs_DATA_Wr_Slip <= MOs_DATA_Wr_Slip << 1'b1;
		
		if (KBD_CSn_EDGE[2:1] == 2'b01) begin
			MOs_DATA <= Value_Received[16:1];
			MOs_DATA_Wr_Slip <= 5'b0_0001;
		end
	end
end
*/
/*
initial Value_Received = 0;

always @ (negedge KBD_CLK_i) begin
	Value_Received <= {Value_Received[15:0], KBD_MOSI_i} << 1'b1;
end

assign Probe[16:1] = Value_Received;
*/
/*
//reg STS_Serial_Out;
reg STS_Latch_Out;
reg STS_Clock_Out;
reg [7:0] STS_Value_2_Slide_Copy;
reg [7:0] STS_Value_2_Slide;
reg [2:0] SM_Status;
reg [3:0] STS_Counter;

always @ (posedge CPU_Clk_i) begin

	if ( RST_i ) begin
		STS_Clock_Out  <= 1'b0;
		STS_Latch_Out  <= 1'b0;
		STS_Value_2_Slide <= 8'h00;
		SM_Status <= 3'b000;
	end
	else begin
	
		case (SM_Status)
		
		3'b000: begin 
			if (STS_Value_2_Slide_Copy != Source) begin
				STS_Value_2_Slide_Copy <= Source;
				STS_Value_2_Slide <= Source;
				STS_Clock_Out  <= 1'b0;				
				STS_Counter <= 4'h7;
				SM_Status <= 3'b001;
			end
			else begin
				SM_Status <= 3'b000;
			end
		
		end
		
		//Clock Low Here
		3'b001: begin 
			STS_Clock_Out 	<= 1'b1;			
			SM_Status 		<= 3'b010;		
		end		
		
		//Clock HIGH Here
		3'b010: begin 
			STS_Clock_Out  <= 1'b0;			
			if (STS_Counter) begin 
				STS_Counter				<= STS_Counter - 4'b0001;
				STS_Value_2_Slide  	<= STS_Value_2_Slide << 1'b1;
				SM_Status 				<= 3'b001;
			end 
			else begin
				SM_Status 				<= 3'b011;
			
			end
		end		
		
		//Shift
		3'b011: begin 
			SM_Status 		<= 3'b100;
			STS_Latch_Out  <= 1'b1;
		end		
		
		3'b100: begin
			SM_Status 		<= 3'b101;
			STS_Latch_Out  <= 1'b0;
		end
		
		3'b101: begin
			SM_Status 		<= 3'b000;
		end
		
		default: begin
			SM_Status 		<= 3'b000;
		end

		
		
		endcase
	
	end
end

*/