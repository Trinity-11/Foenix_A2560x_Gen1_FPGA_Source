`timescale 1ns / 1ps
module A2560X_Unity(
input		wire				CPU_Clk_i,
input		wire				IDE_Reset_i,
input		wire				RST_i,
input 		wire	[31:0]		CPU_A_i,
input		wire	[7:0]		CPU_D8_i,
input		wire	[15:0]		CPU_D16_i,
input		wire	[31:0]		CPU_D32_i,
input		wire	[1:0]		CPU_Siz_i,
input 		wire				CPU_R_Wn_i,
input		wire				CPU_A_Valid_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i,
output 		wire				Wait_Unity_TA_o,
output		wire				Wait_RTC_TA_o,
input		wire				CS_IDE_i,
input		wire				CS_ETH_i,
input		wire				CS_RTC_i,
input		wire				CS_TRINITY_i,		// Joystick

// DataOut
output 		reg 	[31:0]		iBUS_IDE_ETH_DPS_D_o,
output		wire	[31:0]		iBUS_RTC_D_o,
output		wire	[31:0]		iBUS_TRINITY_D_o,
// IO Bus
// IDE Interface
output		wire				IDE_CS0n_o,
output		wire				IDE_CS1n_o,
output		reg 	[7:0] 		IO_A_o,
output		reg					IO_RDn_o,
output		reg					IO_WRn_o,
inout		wire	[15:0]		IO_D_Input_io,
output 		wire 				IDE_DATA_OEn_o,
output 		reg					IDE_DATA_DIR_o,
output		wire				ETH_CSn_o,
output		reg					ETH_FIFO_SEL_o,
output		reg					RTC_CSn_o,
output		reg					TRINITY_CSn_o
);

/*
wire [143:0] TinyTP1;
wire 			TinyTrigger1;

//assign TinyTrigger1 = CS_IDE_i & ( CPU_A_i[3:0] == 4'b0000);
assign TinyTrigger1 		= CS_IDE_i;

assign TinyTP1[31:0]  	= CPU_A_i;
assign TinyTP1[47:32] 	= CPU_D16_i;
assign TinyTP1[55:48]   = CPU_D8_i;
assign TinyTP1[57:56]   = CPU_Siz_i;
assign TinyTP1[58]   	= CPU_R_Wn_i;
assign TinyTP1[59]   	= iBUS_WE_i;
assign TinyTP1[60]   	= CPU_A_Valid_i;
assign TinyTP1[61] 		= Wait_RTC_TA_o;
assign TinyTP1[62]		= TRINITY_CSn_o;
assign TinyTP1[95:64]   = iBUS_IDE_ETH_DPS_D_o;


assign TinyTP1[111:96]	= DataIn;
assign TinyTP1[127:112]	= DataOut;
assign TinyTP1[133:128]	= IO_A_o[5:0];
assign TinyTP1[134] 		= IO_RDn_o;
assign TinyTP1[135] 		= IO_WRn_o;
assign TinyTP1[136]		= IDE_CS0n_o;
assign TinyTP1[137]		= IDE_CS1n_o;
assign TinyTP1[138]		= IDE_DATA_OEn_o;
assign TinyTP1[139]		= IDE_DATA_DIR_o;
assign TinyTP1[143:140] = StateMachine;
TinyChipScope u1 (
	.acq_data_in    (TinyTP1),    //        tap.acq_data_in
	.acq_trigger_in (TinyTrigger1), //           .acq_trigger_in
	.acq_clk        (CPU_Clk_i),        //    acq_clk.clk
	.trigger_in     (TinyTrigger1)      // trigger_in.trigger_in
);

*/

assign IDE_DATA_OEn_o = IDE_CS0n_o & IDE_CS1n_o;
reg [15:0] DataOut;
wire [15:0] DataIn;

// Bi-Dir BUS For ADDY
BIDIR_DATA16	BIDIR_IOBUS (
	.datain ( DataOut ),
	.oe ( Local_DATA_OEn ? 16'hFFFF : 16'h0000 ),
	.dataio ( IO_D_Input_io ),
	.dataout ( DataIn )		// This is the Data Coming from the Exterial World and right now it is 16Bit Wide
);

/*
always @ ( * ) begin
	case ( {CS_ETH_i, CS_IDE_i} )
	2'b00: begin iBUS_IDE_ETH_DPS_D_o = 32'h0000_0000; end
	//2'b01: begin iBUS_IDE_ETH_DPS_D_o = ( CPU_A_i[3:1] == 3'b111 ) ? { DataIn[7:0], DataIn[15:8], DataIn[7:0], DataIn[15:8] } : { DataIn[7:0], DataIn[7:0], DataIn[7:0], DataIn[7:0] }; end
	2'b01: begin iBUS_IDE_ETH_DPS_D_o = { DataIn[7:0], DataIn[15:8], DataIn[7:0], DataIn[15:8] }; end
	//2'b01: begin iBUS_IDE_ETH_DPS_D_o = ( CPU_A_i[3:1] ) ? { DataIn[7:0], DataIn[7:0], DataIn[7:0], DataIn[7:0] } : { DataIn[15:0], DataIn[15:0] }; end
	//2'b10: begin iBUS_IDE_ETH_DPS_D_o = { DataIn[15:0], DataIn[15:0] }; end
	2'b10: begin iBUS_IDE_ETH_DPS_D_o = { DataIn[7:0], DataIn[15:8], DataIn[7:0], DataIn[15:8] }; end
	2'b11: begin iBUS_IDE_ETH_DPS_D_o = 32'h0000_0000; end
	endcase
end
*/
always @ ( posedge CPU_Clk_i ) begin
	iBUS_IDE_ETH_DPS_D_o <= { DataIn[7:0], DataIn[15:8], DataIn[7:0], DataIn[15:8] };
end

assign iBUS_RTC_D_o = { DataIn[7:0], DataIn[7:0], DataIn[7:0], DataIn[7:0] };
assign iBUS_TRINITY_D_o = {DataIn[15:0], DataIn[15:0]};

always @ (posedge CPU_Clk_i) begin
		if ( (StateMachine == ST0) || (StateMachine == ST1)) begin
			IO_A_o <= CS_IDE_i ? {5'b0_0000, CPU_A_i[3:1]} : CPU_A_i[7:0];
			ETH_FIFO_SEL_o <= CPU_A_i[8];
		end
		

end


//assign IO_A_o = CS_IDE_i ? {5'b0_0000, CPU_A_i[3:1]} : CPU_A_i[7:0];
//assign ETH_FIFO_SEL_o = CPU_A_i[8];

assign IDE_CS0n_o 		= IDE_CS0n;
assign IDE_CS1n_o 		= IDE_CS3n;
assign ETH_CSn_o			= ETH_CSn;


reg [7:0]	Unity_Wait_Slip;
//reg [15:0] 	IDE_Data_Read;
reg [3:0] 	StateMachine /* synthesis preserve noprune */; 
reg			ETH_CSn;
reg			IDE_CS0n;
reg			IDE_CS3n;
reg			Local_DATA_OEn;

localparam 	IDLE	= 4'b0000,
				ST0	= 4'b0001,
				ST1	= 4'b0011,
				RD0   = 4'b0010,
				RD1	= 4'b0110,
				RD2   = 4'b0111,
				RD3   = 4'b0101,
				RD4	= 4'b0100,
				RD5   = 4'b1100,
				WR0	= 4'b1101,
				WR1	= 4'b1111,
				WR2	= 4'b1110,
				WR3	= 4'b1010,
				WR4	= 4'b1011,
				WR5	= 4'b1001;
				
reg CS_Unity_EDGE;

reg [31:0]	Unity_Slide;
always @ ( posedge CPU_Clk_i ) begin
	if (RST_i) begin
			Unity_Slide <= 32'h0000_0000;
	end 
	else begin
		if (CS_IDE_i || CS_ETH_i ) begin
			Unity_Slide <= {Unity_Slide[30:0], CPU_A_Valid_i};
		end
		else begin
			Unity_Slide <= 32'h0000_0000;		
		end
	end
end


reg [31:0]	RTC_Slide;
always @ ( posedge CPU_Clk_i ) begin
	if (RST_i) begin
			RTC_Slide <= 32'h0000_0000;
	end 
	else begin
		if ( CS_RTC_i ) begin
			RTC_Slide <= {RTC_Slide[30:0], CPU_A_Valid_i};
		end
		else begin
			RTC_Slide <= 32'h0000_0000;		
		end
	end
end


reg [31:0]	JOY_Slide;
always @ ( posedge CPU_Clk_i ) begin
	if (RST_i) begin
			JOY_Slide <= 32'h0000_0000;
	end 
	else begin
		if ( CS_TRINITY_i ) begin
			JOY_Slide <= {JOY_Slide[30:0], CPU_A_Valid_i};
		end
		else begin
			JOY_Slide <= 32'h0000_0000;		
		end
	end
end


//assign Wait_LPC_TA_o = CPU_R_Wn_i ? Unity_Slide[6] : Unity_Slide[6];	// 
assign Wait_Unity_TA_o = Unity_Slide[10];	// 
assign Wait_RTC_TA_o = RTC_Slide[8] | JOY_Slide[6];
			
always @ (posedge CPU_Clk_i) begin
	CS_Unity_EDGE	<= (CS_IDE_i | CS_ETH_i | CS_RTC_i | CS_TRINITY_i);
end			

initial begin
		IDE_CS0n					= 1'b1;
		IDE_CS3n					= 1'b1;
		ETH_CSn					= 1'b1;
		RTC_CSn_o				= 1'b1;
		TRINITY_CSn_o			= 1'b1;
		IO_RDn_o				<= 1'b1;
		IO_WRn_o				<= 1'b1;		
end 

always @ (posedge CPU_Clk_i) begin
	if ( RST_i ) begin
		StateMachine 			<= IDLE;
		IDE_CS0n					<= 1'b1;
		IDE_CS3n					<= 1'b1;
		ETH_CSn					<= 1'b1;
		RTC_CSn_o				<= 1'b1;
		TRINITY_CSn_o			<= 1'b1;
		//IDE_A_o					<= 8'b0000_0000;
		IO_RDn_o					<= 1'b1;
		IO_WRn_o					<= 1'b1;
		IDE_DATA_DIR_o			<= 1'b0;
		Local_DATA_OEn 		<= 1'b0;
	end
	else begin
		//Unity_Wait_Slip <= Unity_Wait_Slip << 1'b1;
	
		case( StateMachine )
		
		IDLE: begin 
		// When Writing, there is already one byte Written
			if ( ({ CS_Unity_EDGE, (CS_IDE_i | CS_ETH_i | CS_RTC_i | CS_TRINITY_i)} == 2'b01) && CPU_A_Valid_i )  begin
				if (CS_IDE_i) begin

					if (CPU_A_i[4])
						IDE_CS3n <= 1'b0;
					else
						IDE_CS0n <= 1'b0;	// Enable the ChipSelect
					StateMachine <= ST0;						
				end
				
				if (CS_ETH_i) begin
					ETH_CSn 		<= 1'b0;
					StateMachine <= ST0;					
				end
				
				if ( CS_RTC_i ) begin
					RTC_CSn_o	<= 1'b0;
					StateMachine <= ST1;						
				end
				
				if ( CS_TRINITY_i ) begin 
					TRINITY_CSn_o <= 1'b0;				
					StateMachine <= ST1;					
				end
				
			end
			else begin
				IO_RDn_o   				<= 1'b1;
				IO_WRn_o 				<= 1'b1;
				IDE_DATA_DIR_o 		<= 1'b0;
				Local_DATA_OEn 		<= 1'b0;	// Keep it in Read Mode
				StateMachine <= IDLE;			
			end
		
		end
		
		// CS Valid Here - Tick 0
		ST0: begin 
		// When writing from CPU to IDE, the Second byte coming from CPU should be valid here
			if (CPU_R_Wn_i) begin
				IDE_DATA_DIR_o	<= 1'b0;
				Local_DATA_OEn <= 1'b0;	
				StateMachine <= RD0;		
			end
			else begin
				if ( ETH_CSn ) // Active Lo
					DataOut <= 	( CPU_A_i[3:1] ) ? { 8'h00, CPU_D8_i} : {CPU_D16_i[7:0], CPU_D16_i[15:8]}; // IDE CS is active here
				else begin
					DataOut <= {CPU_D16_i[7:0], CPU_D16_i[15:8]};
				end
					
				IDE_DATA_DIR_o	<= 1'b1;
				Local_DATA_OEn <= 1'b1;
				StateMachine <= WR0;					
			end
		end 
		
		// RTC & Trinity Transaction
		ST1: begin
			if (CPU_R_Wn_i) begin
				StateMachine <= RD0;	
				Local_DATA_OEn <= 1'b0;					
			end
			else begin
				if ( CS_RTC_i ) begin 	// if TRINITY_CSn_o = 1, the RTC is valid
					DataOut <= {8'h00, CPU_D8_i[7:0]};
				end 
				else begin 
					DataOut <= CPU_D16_i[15:0];
				end 
				Local_DATA_OEn <= 1'b1;					
				StateMachine <= WR0;		
			end
		end
		
		//////
		/// READ CYCLE
		//////
		// The Read And Chip Select are valid Here
		RD0: begin 
			IO_RDn_o    <= 1'b0;
			if ( CS_RTC_i )  begin
				StateMachine <= RD1;
			end
			else begin
				if ( CS_TRINITY_i ) begin
					StateMachine <= RD2;	
				end
				else begin
					StateMachine <= RD4;		
				end
			end
		end
		
		RD1: begin
			if ( RTC_Slide[6] ) begin
				IO_RDn_o    <= 1'b1;
				StateMachine <= RD5;
			end		
		end
	
		RD2: begin 
			if ( JOY_Slide[4] ) begin
				IO_RDn_o    <= 1'b1;
				StateMachine <= RD5;	
			end
		end
		
	
		RD4: begin 
			if ( Unity_Slide[8] ) begin
				IO_RDn_o    <= 1'b1;
				StateMachine <= RD5;
			end
		end
		
		RD5: begin 
			IDE_CS0n 	<= 1'b1;
			IDE_CS3n 	<= 1'b1;
			ETH_CSn  	<= 1'b1;
			RTC_CSn_o	<= 1'b1;
			TRINITY_CSn_o <= 1'b1;
			StateMachine <= IDLE;
		end
		
	
		//////
		/// WRITE CYCLE
		//////
		// The Read And Chip Select are valid Here
		// CS Valid Here - Tick 1		
		WR0: begin 
			IO_WRn_o  	<= 1'b0;
			if ( CS_RTC_i ) begin
				StateMachine <= WR1;
			end
			else begin
				if ( CS_TRINITY_i ) begin
					StateMachine <= WR2;			 
				end
				else begin
					StateMachine <= WR4;				 
				end
			end
		end
		
		WR1: begin 
			if ( RTC_Slide[6] ) begin
				IO_WRn_o  <= 1'b1;		
				StateMachine <= WR5;	
			end		
		end		
		
		WR2: begin 
			if ( JOY_Slide[4] ) begin
				IO_WRn_o  <= 1'b1;		
				StateMachine <= WR5;	
			end		
		end				

		WR4: begin 
			if ( Unity_Slide[8] ) begin
				IO_WRn_o  <= 1'b1;		
				StateMachine <= WR5;	
			end		
		end
		
		// CS Valid Here - Tick 6		
		WR5: begin 
			Local_DATA_OEn <= 1'b0;	
			IDE_DATA_DIR_o	<= 1'b0;
			IDE_CS0n <= 1'b1;
			IDE_CS3n <= 1'b1;
			ETH_CSn  <= 1'b1;
			RTC_CSn_o	<= 1'b1;		
			TRINITY_CSn_o	<= 1'b1;
			StateMachine <= IDLE;
		end
		
		default: begin 
			StateMachine <= IDLE;		
		end
		
		endcase
	end
end













/*
reg	[7:0]		DataPortWriten_Hi;
reg	[7:0]		DataPortWriten_Lo;
reg 				IO_UNITY_CSn_Dly;
reg	[1:0]		WRn;
reg	[1:0]		RDn;
reg	[15:0] 	IDE_Data_Read;

wire	[15:0]	IDE_Data_Port_i;
//wire 				Enable;

wire	Unity_CSn;
assign CPU_D_o = CPU_A_i[3] ? (CPU_A_i[0] ? IDE_Data_Read[15:8] : IDE_Data_Read[7:0]) : IDE_Data_Read[7:0];


always @ (posedge CPU_Clk_i)
begin
	if (CS_Unity_i) begin
		if ( CPU_A_i[3] ) begin
			if (CPU_A_i[0])
				DataPortWriten_Hi[7:0] <= CPU_D_i[7:0];	
			else
				DataPortWriten_Lo[7:0] <= CPU_D_i[7:0];
		end
		else begin
			DataPortWriten_Lo[7:0] <= CPU_D_i[7:0];
			DataPortWriten_Hi[7:0] <= 8'h00;
		end
	end
end

assign IDE_D_Output_o = { DataPortWriten_Hi, DataPortWriten_Lo};


reg [3:0] StateMachine;

localparam 	IDLE	= 4'b0000,
				ST0	= 4'b0001,

				RD0   = 4'b0010,
				RD1   = 4'b0011,
				RD2   = 4'b0100,
				RD3   = 4'b0101,
				RD4   = 4'b0110,
				RD5   = 4'b0111,
				RD6	= 4'b1000,

				WR0	= 4'b1001,				
				WR1	= 4'b1010,
				WR2	= 4'b1011,
				WR3	= 4'b1100,
				WR4	= 4'b1101,
				WR5	= 4'b1110,
				WR6	= 4'b1111;
				
reg CS_Unity_EDGE;	
				
always @ (posedge CPU_Clk_i) begin
	CS_Unity_EDGE	<= CS_Unity_i;
end			

wire Condition0;
wire Condition1;
wire Condition2;

assign Condition0 = (( { CS_Unity_EDGE, CS_Unity_i} == 2'b01 ) & !CPU_A_i[3] );
assign Condition1 = ( CS_Unity_i & CPU_A_i[3] & CPU_A_i[0] & !CPU_R_Wn_i );
assign Condition2 = (( { CS_Unity_EDGE, CS_Unity_i} == 2'b01 ) & CPU_A_i[3] & !CPU_A_i[0] & CPU_R_Wn_i );


always @ (posedge CPU_Clk_i) begin
	if ( RST_i ) begin
		StateMachine 			<= IDLE;
		IDE_CS0n_o				<= 1'b1;
		IDE_A_o					<= 3'b000;
		IO_RDn_o				<= 1'b1;
		IO_WRn_o				<= 1'b1;
		IDE_DATA_DIR_o			<= 1'b0;
		IDE_DATA_OEn_o <= 1'b0;
	end
	else begin
		case( StateMachine )
		
		IDLE: begin 
		// When Writing, there is already one byte Written
			if ( Condition0 || Condition1 || Condition2 )    begin
				StateMachine <= ST0;
				IDE_CS0n_o <= 1'b0;	// Enable the ChipSelect					
				IDE_A_o <= (CPU_A_i[3]) ? 3'b000 : CPU_A_i[2:0];
			end
			else begin
				IO_RDn_o   			<= 1'b1;
				IO_WRn_o 				<= 1'b1;
				IDE_DATA_DIR_o 		<= 1'b0;
				IDE_DATA_OEn_o <= 1'b0;	// Keep it in Read Mode
				StateMachine <= IDLE;			
			end
		
		end
		
		// CS Valid Here - Tick 0
		ST0: begin 
		// When writing from CPU to IDE, the Second byte coming from CPU should be valid here
			if (CPU_R_Wn_i) begin
				IDE_DATA_DIR_o	<= 1'b0;
				IDE_DATA_OEn_o <= 1'b0;	
				StateMachine <= RD0;		
			end
			else begin
				IDE_DATA_DIR_o	<= 1'b1;
				IDE_DATA_OEn_o <= 1'b1;
				StateMachine <= WR0;					
			end
		end 
		
		//////
		/// READ CYCLE
		//////
		// The Read And Chip Select are valid Here
		RD0: begin 
			IO_RDn_o    <= 1'b0;		
			StateMachine <= RD1;
		end
		
		//
		RD1: begin 
		// WRn Tick 0		
			IDE_Data_Read <= IDE_D_Input_i;	// Save Results				
			StateMachine <= RD2;
		end
		
		RD2: begin 
			StateMachine <= RD3;		
		end
		
		// 
		RD3: begin 
			StateMachine <= RD4;		
		end
		
		RD4: begin 
			IO_RDn_o    <= 1'b1;			
			StateMachine <= RD5;		
		end
		
		RD5: begin 
			IDE_CS0n_o <= 1'b1;		
			StateMachine <= IDLE;
		end
		
	
		//////
		/// WRITE CYCLE
		//////
		// The Read And Chip Select are valid Here
		// CS Valid Here - Tick 1		
		WR0: begin 
			StateMachine <= WR1;
			IO_WRn_o  	<= 1'b0;
			IDE_Data_Read <= IDE_D_Input_i;	// Save Results
		end
		
		// CS Valid Here - Tick 2
		// WRn Tick 0
		WR1: begin 
			StateMachine <= WR2;
		end
		
		// CS Valid Here - Tick 3		
		// WRn Tick 1		
		WR2: begin 
			StateMachine <= WR3;		
		end
		
		// CS Valid Here - Tick 4
		// WRn Tick 2		
		WR3: begin 
			StateMachine <= WR4;		
		end
		
		// CS Valid Here - Tick 5		
		// WRn Tick 3		
		WR4: begin 
			IO_WRn_o  <= 1'b1;		
			StateMachine <= WR5;		
		end
		
		// CS Valid Here - Tick 6		
		WR5: begin 
			IDE_DATA_OEn_o <= 1'b0;	
			IDE_DATA_DIR_o	<= 1'b0;
			IDE_CS0n_o <= 1'b1;		
			StateMachine <= IDLE;
		end
	
		
		
		default: begin 
			StateMachine <= IDLE;		
		end
		
		endcase
	end
end
*/

endmodule

