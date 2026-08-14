module VICKY_III_Clock_Select(

input		wire			CPU_Clk_i,
input		wire			Reset_i,

output	wire			VClock_LTC6903_DIN_o,
output	wire			VClock_LTC6903_SCLK_o,
output	wire			VClock_LTC6903_A_CSn_o,
output	wire			VClock_LTC6903_B_CSn_o,

input		wire	[1:0]	Channel_A_Vid_Clk_Select_i,
input		wire	[1:0]	Channel_B_Vid_Clk_Select_i
);

/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

assign TinyTrigger1 = (VidClkSM != IDLE) ? 1'b1 : 1'b0;

assign TinyTP1[1:0]  	= Channel_A_Vid_Clk_Select_i;
assign TinyTP1[3:2] 		= Channel_B_Vid_Clk_Select_i;
assign TinyTP1[4] 		= VClock_LTC6903_SCLK_o;
assign TinyTP1[5]			= VClock_LTC6903_DIN_o;
assign TinyTP1[6]			= VClock_LTC6903_A_CSn_o;
assign TinyTP1[7]			= VClock_LTC6903_B_CSn_o;
assign TinyTP1[11:8] 		= bitcount;
assign TinyTP1[14:12]	= VidClkSM;
assign TinyTP1[31:16]   = Actual_Value_Slide;

TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (CPU_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/



/*
localparam	MODE25	 = {4'h0E, 10'h297, 2'b10 }, 
				MODE40	 = {4'h0F, 10'h131, 2'b10 },
				MODE65    = {4'h0F, 10'h3CF, 2'b10 };
*/
assign VClock_LTC6903_SCLK_o = CLK;
assign VClock_LTC6903_A_CSn_o = !CSA;
assign VClock_LTC6903_B_CSn_o = !CSB;
assign VClock_LTC6903_DIN_o = Actual_Value_Slide[15];


reg	[1:0]		Channel_A_Select_New;
reg	[1:0]		Channel_B_Select_New;

reg				CLK;
reg				CSA;
reg				CSB;

reg 	[2:0]		VidClkSM;
reg	[3:0]		bitcount;
reg 	[15:0]	Actual_Value_Slide;
reg	[15:0]	Value_A;
reg	[15:0]	Value_B;


always @ (*) begin
	case ( Channel_A_Vid_Clk_Select_i )
		2'b00: begin Value_A = {4'h0E, 10'h297, 2'b10 }; end
		2'b01: begin Value_A = {4'h0F, 10'h131, 2'b10 }; end
		2'b10: begin Value_A = {4'h0F, 10'h3CF, 2'b10 }; end
		2'b11: begin Value_A = {4'h0E, 10'h297, 2'b10 }; end
	endcase
end


always @ (*) begin
	case ( Channel_B_Vid_Clk_Select_i )
		2'b00: begin Value_B = {4'h0E, 10'h297, 2'b10 }; end
		2'b01: begin Value_B = {4'h0F, 10'h131, 2'b10 }; end
		2'b10: begin Value_B = {4'h0F, 10'h3CF, 2'b10 }; end
		2'b11: begin Value_B = {4'h0E, 10'h297, 2'b10 }; end
	endcase
end

localparam	IDLE 	= 3'b000,
				ST0	= 3'b001,
				ST1	= 3'b010,
				ST2	= 3'b011,
				ST3	= 3'b100,
				ST4	= 3'b101,
				ST5	= 3'b110;
/*			
initial begin
		Actual_Value_Slide	= 16'h0000;
		bitcount					= 4'b0000;
		CSA  						= 1'b0;
		CSB						= 1'b0;
		CLK						= 1'b1;
		Channel_A_Select_New = 2'b11;
		Channel_B_Select_New = 2'b11;		
		VidClkSM 				= IDLE;	
end				
*/
always @ ( posedge CPU_Clk_i ) begin
	if (Reset_i) begin
		Actual_Value_Slide	<= 16'h0000;
		bitcount					<= 4'b0000;
		CSA  						<= 1'b0;
		CSB						<= 1'b0;
		CLK						<= 1'b1;
		Channel_A_Select_New <= 2'b11;
		Channel_B_Select_New <= 2'b11;		
		VidClkSM 				<= IDLE;	
	end
	else begin
	
	
		case ( VidClkSM ) 
		
		IDLE: begin 
			if ( Channel_A_Select_New != Channel_A_Vid_Clk_Select_i) begin
				Channel_A_Select_New <= Channel_A_Vid_Clk_Select_i;
				Actual_Value_Slide <= Value_A; 
				CSA	<= 1'b1;
				VidClkSM <= ST0;
			end
				
			if ( Channel_B_Select_New != Channel_B_Vid_Clk_Select_i) begin
				Channel_B_Select_New	<= Channel_B_Vid_Clk_Select_i;
				Actual_Value_Slide <= Value_B;					
				CSB	<= 1'b1;
				VidClkSM <= ST0;				
			end
			bitcount <= 4'b1111;
		end
		
		
		ST0: begin
			CLK  <= 1'b0;
			VidClkSM <= ST1;
		end
		
		// Clock is high here
		ST1: begin 
			CLK  <= 1'b1;
			VidClkSM <= ST2;
		end
		
		// Clock is Low Here
		ST2: begin 
			CLK  <= 1'b0;
			Actual_Value_Slide <= Actual_Value_Slide << 1'b1;			
			if ( bitcount ) begin
				bitcount <= bitcount - 3'b001;
				VidClkSM <= ST1;				
			end
			else begin
				CSA	<= 1'b0;
				CSB	<= 1'b0;
				VidClkSM <= ST3;
			end
		end
		
		ST3: begin 
			CLK  <= 1'b1;		
			VidClkSM <= IDLE;		
		end
		
		default: begin
				VidClkSM <= IDLE;		
		end
		
		
		endcase
	
	end
end




endmodule

