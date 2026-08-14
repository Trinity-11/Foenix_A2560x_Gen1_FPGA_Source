
`timescale 1 ns / 1 ns
module A2560X_CODEC (

input		wire				BUS_Rst_i,
input		wire				BUS_Clk_i,
input		wire				Clk_358MHz_i,

input		wire	[31:0]	iBUS_A_i,
input		wire				iBUS_A_Valid_i,

input		wire	[7:0]		iBUS_D8_i,
input		wire	[15:0]	iBUS_D16_i,
input		wire	[31:0]	iBUS_D32_i,
input		wire	[1:0]		iBUS_D_Siz_i,

input		wire				iBUS_RWn_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i, 
input		wire				CS_CODEC_i,

output	wire			   BTX_CODEC_CL_o,
output	wire			   BTX_CODEC_DI_o,
output	wire			   BTX_CODEC_CE_o,

output	wire	[15:0]	CODEC_Ready_o			// Bit Indicate that Transfer is done
);


/*
wire [71:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = strobe_i & (address_i[7:0] == 8'h10);
assign TinyTrigger1 = CS_CODEC_i && !iBUS_RWn_i && (iBUS_D_Siz_i[1:0] == 2'b10) && (iBUS_A_i[1:0] == 2'b00) && iBUS_WE_i ;

assign TinyTP1[23:0]  	= iBUS_A_i;
assign TinyTP1[39:24] 	= iBUS_D16_i;
assign TinyTP1[55:40]   = CODEC_Ready_o;
assign TinyTP1[56]		= CS_CODEC_i;
assign TinyTP1[57] 		= BTX_CODEC_CL_o;
assign TinyTP1[58]		= BTX_CODEC_DI_o;
assign TinyTP1[59]		= BTX_CODEC_CE_o;
assign TinyTP1[60]		= 1'b0;
assign TinyTP1[61]		= 1'b0;
assign TinyTP1[62] 		= 1'b0;
assign TinyTP1[63] 		= 1'b0;


assign TinyTP1[71:64] = Bit2Serialize;

TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (BUS_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);
*/
/*
wire ClockDivided3Mhz;
reg [2:0] ClkDivide8;

assign ClockDivided3Mhz = ClkDivide8[2];

always @ (posedge BUS_Clk_i)
begin
	ClkDivide8 <= ClkDivide8 + 3'b001;
end
*/
/*
reg [1:0] REG_BSY_ReSync;

always @ (posedge BUS_Clk_i)
begin
	REG_BSY_ReSync[1] <= REG_BSY[35];
	REG_BSY_ReSync[0] <= REG_BSY_ReSync[1];
end
*/

//assign CODEC_Ready_o = { REG_BSY[35], 15'b000_0000_0000_0000 };
assign CODEC_Ready_o = {Busy, 15'b000_0000_0000_0000 };

/*
reg	[15:0]		CR;

always @ (posedge BUS_Clk_i)
begin
	if (BUS_Rst_i) begin
		CR[15:0] <= 16'b0000_0000_0000_0000;
	end
	else begin
	
		Slider <= Slider << 1'b1;
	
		if (CS_CODEC_i && !iBUS_RWn_i && (iBUS_D_Siz_i[1:0] == 2'b10) && (iBUS_A_i[1:0] == 2'b00) && iBUS_WE_i) begin
			CR[15:0] <= iBUS_D16_i[15:0];
			Slider <= 8'hFF;			
		end

		//if (CS_CODEC_i && !iBUS_RWn_i && (iBUS_BE_i[1:0] == 2'b11) && (iBUS_A_i[1:0] == 2'b10)) begin

		//end
		
	end
end

reg	[35:0]	REG_CE;
reg	[35:0]	REG_CL;
reg	[35:0]	REG_DI;
reg	[35:0]	REG_BSY;

initial begin
		REG_DI  = 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_CL  = 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_CE  = 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_BSY = 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
end


assign BTX_CODEC_CL_o = REG_CL[35];
assign BTX_CODEC_DI_o = REG_DI[35];
assign BTX_CODEC_CE_o = !REG_CE[35];

reg	[7:0] Slider;


localparam			IDLE 		= 3'b000,
						LOAD		= 3'b001,
						WAIT		= 3'b010,
						END		= 3'b011;

always @ (posedge ClockDivided3Mhz)
begin
	if (BUS_Rst_i) begin
		REG_DI  <= 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_CL  <= 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_CE  <= 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		REG_BSY <= 36'b0000_0000_0000_0000_0000_0000_0000_0000_0000;
		
	end
	else begin
		if (Slider[5:2] == 4'b1111) begin
			REG_BSY <= 36'b1111_1111_1111_1111_1111_1111_1111_1111_1111;		
			REG_CE  <= 36'b0000_0000_0000_0000_0000_0000_0000_0000_0010;
			REG_CL  <= 36'b0001_0101_0101_0101_0101_0101_0101_0101_0100;
			REG_DI  <= {2'b00, 	CR[15], CR[15], CR[14], CR[14], CR[13], CR[13], CR[12], CR[12], CR[11], CR[11], CR[10], CR[10], CR[9], CR[9], CR[8], CR[8],
										CR[7],  CR[7], CR[6], CR[6], CR[5], CR[5], CR[4], CR[4], CR[3], CR[3], CR[2], CR[2], CR[1], CR[1], CR[0], CR[0], 2'b00};	
		end
		else begin
			REG_DI  <= REG_DI  << 1'b1;
			REG_CL  <= REG_CL  << 1'b1;
			REG_CE  <= REG_CE  << 1'b1;
			REG_BSY <= REG_BSY << 1'b1;			
		end
	end
end
*/
// NEW STATE MACHINE
assign BTX_CODEC_CL_o = 	CL;
assign BTX_CODEC_DI_o = 	Data2Send[17];
assign BTX_CODEC_CE_o = 	!CE;


reg [3:0] 	CODEC_SM;
reg [3:0]	CODEC_SM_SM;

localparam 	IDLE  = 	4'b0000,
				ST0	= 	4'b0001,
				ST1	= 	4'b0010,
				ST2	= 	4'b0011,
				ST3	= 	4'b0100,				
				ST4	= 	4'b0101,
				ST5	= 	4'b0110,
				ST6	= 	4'b0111,
				ST7	= 	4'b1000,
				DELAY = 	4'b1001;

reg	Busy;
reg	CE;
reg	CL;
reg	DI;
reg	[17:0]	Data2Send;		
reg	[7:0]		Delay2Lapse;
reg	[7:0]		Bit2Serialize;


always @ (posedge BUS_Clk_i) begin
	if ( BUS_Rst_i ) begin
		CODEC_SM <= IDLE;
		Busy		<= 1'b0;
		CE			<= 1'b0;
		CL			<= 1'b0;
	end
	else begin
	
		case( CODEC_SM )
		
		IDLE: begin
			if (CS_CODEC_i && !iBUS_RWn_i && (iBUS_D_Siz_i[1:0] == 2'b10) && (iBUS_A_i[1:0] == 2'b00) && iBUS_WE_i) begin
				Data2Send[17:0] <= {1'b0, iBUS_D16_i[15:0], 1'b0};
				Busy		<= 1'b1;
				Delay2Lapse <= 8'h07;
				Bit2Serialize <= 8'd16;
				CODEC_SM <= DELAY;	// Go Waste 1 8 Clock Cycles
				CODEC_SM_SM <= ST0;
			end
			else begin
				CODEC_SM <= IDLE;			
			end
		end		
		
		// 
		ST0: begin 
			if ( Bit2Serialize ) begin
					Bit2Serialize <= Bit2Serialize - 8'h01;
					CODEC_SM <= ST1;					
			end
			else begin
					CODEC_SM <= ST4;
			end
			Data2Send <= Data2Send << 1'b1;			
			CL	<= 1'b0;			
		end

		// Clock is Low 0 - Here
		ST1: begin 
			Delay2Lapse <= 8'h01;	// 2 Clocks in Delay
			CODEC_SM <= DELAY;	// Go Waste 1 8 Clock Cycles
			CODEC_SM_SM <= ST2;
		end
	
		// Clock is Low 3 - Here
		ST2: begin 
			CL	<= 1'b1;
			CODEC_SM <= ST3;		
		end

		// Clock is Hi 0 Here			
		ST3: begin 
			Delay2Lapse <= 8'h01;
			CODEC_SM <= DELAY;	// Go Waste 2 Clock Cycles
			CODEC_SM_SM <= ST0;	// Return to Bit 2 Serialize so it can be shifte	
		end
		
		ST4: begin 
			Delay2Lapse <= 8'h02;	// 2 Clocks in Delay
			CODEC_SM <= DELAY;	// Go Waste 1 8 Clock Cycles
			CODEC_SM_SM <= ST5;		
		end
		
		ST5: begin 
			CE <= 1'b1;
			CODEC_SM <= ST6;			
		end
		
		ST6: begin
			Delay2Lapse <= 8'h02;	// 2 Clocks in Delay
			CODEC_SM <= DELAY;	// Go Waste 1 8 Clock Cycles
			CODEC_SM_SM <= ST7;		
		end
		

		ST7: begin 
			CE <= 1'b0;
			Busy <= 1'b0;
			CODEC_SM <= IDLE;
		end
		
	
		DELAY: begin 
			if ( Delay2Lapse ) begin
				Delay2Lapse <= Delay2Lapse - 8'h01;
			end
			else begin
				CODEC_SM <= CODEC_SM_SM;
			end
		end
		
		
		
		
		endcase
	
	end

end


endmodule

