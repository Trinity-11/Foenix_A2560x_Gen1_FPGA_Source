module RGB_LED_Driver_Module (

input		wire				Clk40Mhz_i,
input		wire				Reset_i,
input		wire				SOF_i,
input		wire	[23:0]	RGB_Value_i,

output	wire				RGB_POWER_LED_o

);

// THe overall period to send 1 bit is 1.25us - 50 Clock Cycle
// to create a 0 - you need 12 Clock high, 36 Clock Low
// to Create a 1 - you need 36 clock high, 12 clock low
// Reset 80 Clock
/*
localparam 		ZerobitHigh = 8'h9,
					ZerobitLow	= 8'h37,
					OnebitHigh  = 8'h37,
					OnebitLow	= 8'h9;
*/

/*
reg Clk40Mhz_i;
always @ (posedge Clk80Mhz_i) begin
	Clk40Mhz_i <= ~Clk40Mhz_i;
end
*/

reg [3:0] SOF_RESYNC;

always @ ( posedge Clk40Mhz_i ) begin
	SOF_RESYNC[0] <= SOF_i;
	SOF_RESYNC[1] <= SOF_RESYNC[0];
	if (SOF_RESYNC[0] == SOF_RESYNC[1] )
		SOF_RESYNC[2] <= SOF_RESYNC[1];
		
		SOF_RESYNC[3] <= SOF_RESYNC[2];
end


reg	[7:0]		Bit2Transmit;

//reg	[7:0]		BitHighCount;
//reg	[7:0]		BitLowCount;
//reg	[3:0]		RGBLightingSM;

reg	[15:0]	Reset_Code_Counter;
reg	[23:0]	RGB_Value_Copy;
reg	[23:0]	RGB_Value_Slide;
reg				bitsteam_out;

//assign RGB_POWER_LED_o = (SmallSM == 2'b10) ? 1'b0 : bitsteam_out;
assign RGB_POWER_LED_o = bitsteam_out;

/*
localparam		IDLE 			= 4'b0000,
					ST0			= 4'b0001,
					Send_Hi		= 4'b0010,
					Send_Lo		= 4'b0011,
					Send_1_Hi	= 4'b0100,
					Send_1_Lo	= 4'b0101,
					ST5			= 4'b0110,
					ST6			= 4'b0111,
					RESET_CODE	= 4'b1000;
*/
wire bit2process;
assign bit2process = RGB_Value_Slide[23];					

reg [7:0] Count;

reg [23:0] RGB_Value_ReSync[0:2];

always @ ( posedge Clk40Mhz_i ) begin
			RGB_Value_ReSync[0] <= RGB_Value_i;
			RGB_Value_ReSync[1] <= RGB_Value_ReSync[0];
			if ( RGB_Value_ReSync[0] == RGB_Value_ReSync[1] ) begin
				RGB_Value_ReSync[2] <= RGB_Value_ReSync[1];
			end
end
/*
wire [8:0] Source;
wire [32:0] Probe;

SourceAndProbe SOURCE68K (
	.source (Source), // sources.source
	.probe  (Probe)   //  probes.probe
);


assign Probe = RGB_Value_Copy;
*/
/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger1 = (SmallSM == 2'b01);

assign TinyTP1[23:0]  	= RGB_Value_ReSync[2];
assign TinyTP1[47:24] 	= RGB_Value_Slide;
assign TinyTP1[55:48]   = Count;
assign TinyTP1[63:56]	= Bit2Transmit;
assign TinyTP1[64] 		= bitsteam_out;
assign TinyTP1[66:65]   = SmallSM;



TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (Clk40Mhz_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/
reg [1:0] SmallSM;


always @ (posedge Clk40Mhz_i) begin
	if ( Reset_i ) begin
			Count <= 8'h00;
			bitsteam_out <= 1'b0;
			Bit2Transmit <= 8'h00;
			Reset_Code_Counter <= 16'h0000;
			RGB_Value_Slide <= 24'h00_00_00;
			SmallSM <= 2'b00;
	end
	else begin
	
		if ((( bit2process ) && (Count == 24)) || ((!bit2process) && (Count == 12)))
			bitsteam_out <= 1'b0;	
	
	
		case (SmallSM)
		2'b00: begin 
			if ( {SOF_RESYNC[3], SOF_RESYNC[2]} == 2'b01 ) begin
				RGB_Value_Slide 	<= {RGB_Value_ReSync[2][15:8], RGB_Value_ReSync[2][23:16], RGB_Value_ReSync[2][7:0]};
				Count <= 8'h00;
				bitsteam_out <= 1'b1;				
				Bit2Transmit <= 8'h00;
				SmallSM <= 2'b01;				
			end
			else begin
				SmallSM <= 2'b00;
			end
		end
			
		2'b01: begin 
			if ( Bit2Transmit < 8'd24) begin
				if (Count < 8'd49 ) begin
					Count <= Count + 8'h01;
				end
				else begin
					Count <= 8'h00;
					bitsteam_out <= 1'b1;					
					Bit2Transmit <= Bit2Transmit + 1'b1;
					RGB_Value_Slide <= RGB_Value_Slide << 1'b1;
				end
			end
			else begin
				Reset_Code_Counter <= 16'h0000;			
				bitsteam_out <= 1'b0;		
				SmallSM <= 2'b10;
			end
		end
		
		2'b10: begin 
				if ( Reset_Code_Counter < 16'd3200 ) begin
					Reset_Code_Counter <= Reset_Code_Counter + 16'h0001;
				end
				else begin
					bitsteam_out <= 1'b0;
					SmallSM <= 2'b00;				
				end	
		end
		
		
		2'b11: begin 
				SmallSM <= 2'b00;		
		end
		endcase
	end
end

/*
always @ (posedge Clk40Mhz_i) begin
	if ( Reset_i ) begin
		RGBLightingSM 	<= IDLE;
		BitHighCount	<= 8'b0000_0000;
		BitLowCount		<= 8'b0000_0000;
		Bit2Transmit	<= 8'b0000_0000;
		bitsteam_out	<= 1'b1;
		Bit2Transmit	<= 8'h00;
	end
	else begin
	
		case( RGBLightingSM )
			IDLE: begin 
				if ( RGB_Value_i != RGB_Value_Copy) begin
					RGB_Value_Copy <= RGB_Value_i;
					RGB_Value_Slide <= RGB_Value_i;
					RGBLightingSM <= ST0;					
				end
				else begin
					bitsteam_out	<= 1'b1;				
					Bit2Transmit <= 8'h00;
					RGBLightingSM <= IDLE;				
				end
			end
			
			// Read bit Phase
			ST0: begin
				if ( bit2process ) begin
					BitHighCount 	<= OnebitHigh;
					BitLowCount		<= OnebitLow;
				end
				else begin
					BitHighCount 	<= ZerobitHigh;
					BitLowCount		<= ZerobitLow;
				end
				RGBLightingSM <= Send_Hi;				
			end
			
			// Send 0 - High Phase
			Send_Hi: begin 
				if ( BitHighCount ) begin
					BitHighCount <= BitHighCount - 8'h01;
				end
				else begin
					bitsteam_out	<= 1'b0;
					RGBLightingSM <= Send_Lo;
				end
			end
			
			// Send 0 - Low Phase
			Send_Lo: begin 
				if ( BitLowCount ) begin
					BitLowCount <= BitLowCount - 8'h01;
				end
				else begin
					// If we get here, we are done with sending that bit - let's go shift
					RGBLightingSM 	<= ST5;
				end		
			end
			
			// Shift and move on
			ST5: begin 
				if (Bit2Transmit < 8'd24) begin
					Bit2Transmit <= Bit2Transmit + 8'h01;
					RGB_Value_Slide <= RGB_Value_Slide << 1'b1;
					bitsteam_out	<= 1'b1;
					RGBLightingSM <= ST0;		
				end
				else begin
					Reset_Code_Counter <= 16'd3200;
					RGBLightingSM <= RESET_CODE;
				end
			end
			
	
			RESET_CODE: begin
				if (Reset_Code_Counter) begin
					Reset_Code_Counter <= Reset_Code_Counter - 16'd1;
				end
				else begin
					RGBLightingSM 	<= IDLE;	
				end
			end
			
			default: begin
				RGBLightingSM 	<= IDLE;				
			end
		
		endcase
	end
end
*/


endmodule
