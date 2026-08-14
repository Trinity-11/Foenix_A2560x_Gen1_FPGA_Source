`timescale 1ns / 1ps
module Unity(
input		wire				CPU_Clk_i,
input		wire				RST_i,
input 	wire	[23:0]	CPU_A_i,
input 	wire	[7:0]		CPU_D_i,
input 	wire				CPU_R_Wn_i,
input		wire				CS_Unity_i,
output 	wire 	[7:0]		CPU_D_o,

// IDE Interface
output	reg 				IDE_CS0n_o,
output	wire				IDE_CS1n_o,
output	reg 	[2:0] 	IDE_A_o,
input		wire				IDE_INTRQ_i,
input		wire				IDE_IORDY_i,
output	reg				IDE_RDn_o,
output	reg				IDE_WRn_o,
input		wire	[15:0] 	IDE_D_Input_i,
output	wire	[15:0] 	IDE_D_Output_o,
output	reg				IDE_D_OutputEnable_o,
output 	wire 				IDE_DATA_OEn_o,
output 	reg				IDE_DATA_DIR_o,

output	wire				IDE_RESETn_o
);
/*
wire [7:0] Probe;
wire [23:0] Source;
assign Probe = 0;

	Sources_Probes SP0 (
		.probe  ( Probe ),  //  probes.probe
		.source ( Source )  // sources.source
	);

wire 	[71:0]		CS;
wire					Trigger_In;

assign Trigger_In = CS_Unity_i & (CPU_A_i == Source);
// IDE
assign CS[15:00] 	= IDE_D_Input_i;
assign CS[31:16] 	= IDE_D_Output_o;
assign CS[34:32] 	= IDE_A_o;
assign CS[35] 		= IDE_CS0n_o;
assign CS[36] 		= IDE_RDn_o;
assign CS[37] 		= IDE_WRn_o;
assign CS[38]		= Condition0;
assign CS[39] 		= Condition1;
assign CS[40]		= Condition2;
assign CS[41]		= IDE_D_OutputEnable_o;
assign CS[42]		= IDE_DATA_OEn_o;
assign CS[43]		= IDE_DATA_DIR_o;
assign CS[51:44]	= CPU_A_i[7:0];
assign CS[59:52] 	= CPU_D_i;
assign CS[67:60]  = CPU_D_o;
assign CS[68]  	= CPU_R_Wn_i;
assign CS[69]		= CS_Unity_i;
assign CS[70]		= 1'b0;
assign CS[71] 		= 1'b0;

ChipScope u0 (
	.acq_data_in    (CS),    //        tap.acq_data_in
	.acq_trigger_in (Trigger_In), //           .acq_trigger_in
	.acq_clk        (!CPU_Clk_i),        //    acq_clk.clk
	.trigger_in     (Trigger_In)      // trigger_in.trigger_in
);
*/


reg	[7:0]		DataPortWriten_Hi;
reg	[7:0]		DataPortWriten_Lo;
reg 				IO_UNITY_CSn_Dly;
reg	[1:0]		WRn;
reg	[1:0]		RDn;
reg	[15:0] 	IDE_Data_Read;

wire	[15:0]	IDE_Data_Port_i;
//wire 				Enable;

wire	Unity_CSn;
//assign Unity_CSn = !CS_Unity_i;

assign IDE_DATA_OEn_o = 1'b0;
assign IDE_CS1n_o = 1'b1;
assign IDE_RESETn_o = !RST_i;
//assign IDE_DATA_DIR_o = !CPU_R_Wn_i & CS_Unity_i;	// 1 = Write, 0 = Read
//assign Enable = !(!CPU_R_Wn_i | !CS_Unity_i);
//assign IDE_D_OutputEnable_o = !(CPU_R_Wn_i | Unity_CSn);
//assign IDE_A_o[2:0] = (CPU_A_i[3]) ? 3'b000 : CPU_A_i[2:0];

//assign IDE_CS0n_o = IO_UNITY_CSn_Dly ;
//assign IDE_WRn_o = CPU_A_i[3] ? (Unity_CSn | WRn[1] | !CPU_A_i[0]) : (Unity_CSn | WRn[1]);
//assign IDE_RDn_o = CPU_A_i[3] ? (Unity_CSn | RDn[1] | CPU_A_i[0]) : (Unity_CSn | RDn[1]) ;
assign CPU_D_o = CPU_A_i[3] ? (CPU_A_i[0] ? IDE_Data_Read[15:8] : IDE_Data_Read[7:0]) : IDE_Data_Read[7:0];

/*
always @ (negedge CPU_Clk_i)
begin
	if (RST_i) begin
		WRn[1:0] <= 2'b11;
		RDn[1:0] <= 2'b11;
		IO_UNITY_CSn_Dly <= 1'b1;
	end
	else begin
			IO_UNITY_CSn_Dly <= Unity_CSn;
			WRn[0] <= ( CPU_R_Wn_i | IO_UNITY_CSn_Dly );
			RDn[0] <= (!CPU_R_Wn_i | IO_UNITY_CSn_Dly ); 
			WRn[1] <= WRn[0];
			RDn[1] <= RDn[0];
	end
end
*/
//IO_BUS_R_Wn ? IO_UNITY_CSn : (IO_UNITY_CSn | !IO_BUS_A[0]);
// Register the Data Input when the Read Strobe goes High
//always @ (negedge CPU_Clk_i)
//begin
//	if (RDn[1:0] == 2'b01)
//		IDE_Data_Read <= IDE_D_Input_i;
//end

always @ (negedge CPU_Clk_i)
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
				
always @ (negedge CPU_Clk_i) begin
	CS_Unity_EDGE	<= CS_Unity_i;
end			

wire Condition0;
wire Condition1;
wire Condition2;

assign Condition0 = (( { CS_Unity_EDGE, CS_Unity_i} == 2'b01 ) & !CPU_A_i[3] );
assign Condition1 = ( CS_Unity_i & CPU_A_i[3] & CPU_A_i[0] & !CPU_R_Wn_i );
assign Condition2 = (( { CS_Unity_EDGE, CS_Unity_i} == 2'b01 ) & CPU_A_i[3] & !CPU_A_i[0] & CPU_R_Wn_i );


always @ (negedge CPU_Clk_i) begin
	if ( RST_i ) begin
		StateMachine 			<= IDLE;
		IDE_CS0n_o				<= 1'b1;
		IDE_A_o					<= 3'b000;
		IDE_RDn_o				<= 1'b1;
		IDE_WRn_o				<= 1'b1;
		IDE_DATA_DIR_o			<= 1'b0;
		IDE_D_OutputEnable_o <= 1'b0;
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
				IDE_RDn_o   			<= 1'b1;
				IDE_WRn_o 				<= 1'b1;
				IDE_DATA_DIR_o 		<= 1'b0;
				IDE_D_OutputEnable_o <= 1'b0;	// Keep it in Read Mode
				StateMachine <= IDLE;			
			end
		
		end
		
		// CS Valid Here - Tick 0
		ST0: begin 
		// When writing from CPU to IDE, the Second byte coming from CPU should be valid here
			if (CPU_R_Wn_i) begin
				IDE_DATA_DIR_o	<= 1'b0;
				IDE_D_OutputEnable_o <= 1'b0;	
				StateMachine <= RD0;		
			end
			else begin
				IDE_DATA_DIR_o	<= 1'b1;
				IDE_D_OutputEnable_o <= 1'b1;
				StateMachine <= WR0;					
			end
		end 
		
		//////
		/// READ CYCLE
		//////
		// The Read And Chip Select are valid Here
		RD0: begin 
			IDE_RDn_o    <= 1'b0;		
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
			IDE_RDn_o    <= 1'b1;			
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
			IDE_WRn_o  	<= 1'b0;
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
			IDE_WRn_o  <= 1'b1;		
			StateMachine <= WR5;		
		end
		
		// CS Valid Here - Tick 6		
		WR5: begin 
			IDE_D_OutputEnable_o <= 1'b0;	
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


endmodule

