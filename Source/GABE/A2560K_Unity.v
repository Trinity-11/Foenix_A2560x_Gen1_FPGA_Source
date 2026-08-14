`timescale 1ns / 1ps
module A2560K_Unity(
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
output		wire				iBUS_D_Valid_o,
output 		wire				Wait_Unity_TA_o,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i, 
input		wire				CS_IDE_i,
input		wire				CS_ETH_i,
input		wire				CS_DP_i,

output 		wire 	[31:0]		iBUS_IDE_ETH_DPS_D_o,

// IDE Interface
output		wire				IDE_CS0n_o,
output		wire				IDE_CS1n_o,
output		wire 	[7:0] 		IDE_A_o,
output		reg					IDE_RDn_o,
output		reg					IDE_WRn_o,
inout		wire	[15:0]		IDE_D_Input_io,

output 		wire 				IDE_DATA_OEn_o,
output 		reg					IDE_DATA_DIR_o,

output		wire				IDE_RESETn_o,
output		wire				ETH_CSn_o,
output		wire				ETH_FIFO_SEL_o,
output		wire				ETH_RSTn_o
);

assign IDE_DATA_OEn_o = IDE_CS0n_o & IDE_CS1n_o;
reg [15:0] DataOut;
wire [15:0] DataIn;

// Bi-Dir BUS For ADDY
BIDIR_DATA16	BIDIR_IOBUS (
	.datain ( DataOut ),
	.oe ( Local_DATA_OEn ? 16'hFFFF : 16'h0000 ),
	.dataio ( IDE_D_Input_io ),
	.dataout ( DataIn )		// This is the Data Coming from the Exterial World and right now it is 16Bit Wide
);

assign iBUS_IDE_ETH_DPS_D_o = { DataIn[7:0], DataIn[15:8], DataIn[7:0], DataIn[15:8] };

assign IDE_A_o 			= CS_IDE_i ? {5'b0_0000, CPU_A_i[3:1]} : CPU_A_i[7:0];
assign ETH_FIFO_SEL_o 	= CPU_A_i[8];
assign IDE_CS0n_o 		= IDE_CS0n;
assign IDE_CS1n_o 		= IDE_CS3n;
assign IDE_RESETn_o		= !RST_i;
assign ETH_RSTn_o   	= !RST_i;
assign ETH_CSn_o		= ETH_CSn;


assign iBUS_D_Valid_o = 1'b0;

reg [7:0]	Unity_Wait_Slip;
//reg [15:0] 	IDE_Data_Read;
reg [2:0] 	StateMachine;
reg			ETH_CSn;
reg			IDE_CS0n;
reg			IDE_CS3n;
reg			Local_DATA_OEn;

localparam 	IDLE	= 3'b000,
				ST0	= 3'b001,
				RD0   = 3'b011,
				RD4   = 3'b010,
				RD5   = 3'b110,
				WR0	= 3'b111,
				WR4	= 3'b101,
				WR5	= 3'b100;
				
reg CS_Unity_EDGE;

reg [31:0]	Unity_Slide;


always @ ( posedge CPU_Clk_i ) begin
	if (RST_i) begin
			Unity_Slide <= 32'h0000_0000;
	end 
	else begin
		if (CS_IDE_i || CS_ETH_i) begin
			Unity_Slide <= {Unity_Slide[30:0], CPU_A_Valid_i};		// CPU_A_Valid_i = !TS
		end
		else begin
			Unity_Slide <= 32'h0000_0000;		
		end
	end
end

//assign Wait_LPC_TA_o = CPU_R_Wn_i ? Unity_Slide[6] : Unity_Slide[6];	// 
assign Wait_Unity_TA_o = Unity_Slide[8];	// 
	
/*	
always @ (posedge CPU_Clk_i) begin
	CS_Unity_EDGE	<= (CS_IDE_i | CS_ETH_i);
end			
*/

always @ (posedge CPU_Clk_i) begin
	if ( RST_i ) begin
		StateMachine 			<= IDLE;
		IDE_CS0n					<= 1'b1;
		IDE_CS3n					<= 1'b1;
		ETH_CSn					<= 1'b1;
		//IDE_A_o					<= 8'b0000_0000;
		IDE_RDn_o				<= 1'b1;
		IDE_WRn_o				<= 1'b1;
		IDE_DATA_DIR_o			<= 1'b0;
		Local_DATA_OEn 		<= 1'b0;
	end
	else begin
		//Unity_Wait_Slip <= Unity_Wait_Slip << 1'b1;
	
		case( StateMachine )
		
		IDLE: begin 
		// When Writing, there is already one byte Written
//			if (( { CS_Unity_EDGE, (CS_IDE_i ^ CS_ETH_i)} == 2'b01 ) && CPU_A_Valid_i )  begin
			if (( CS_IDE_i | CS_ETH_i ) && CPU_A_Valid_i )  begin			
				StateMachine <= ST0;
				
				if (CS_IDE_i) begin
					//IDE_A_o <= {4'b0000, CPU_A_i[3:1]} ;
					//ETH_FIFO_SEL_o <= 1'b0;
					if (CPU_A_i[4])
						IDE_CS3n <= 1'b0;
					else
						IDE_CS0n <= 1'b0;	// Enable the ChipSelect					
				end
				
				if (CS_ETH_i) begin
					ETH_CSn <= 1'b0;
				end

			end
			else begin
				IDE_RDn_o   			<= 1'b1;
				IDE_WRn_o 				<= 1'b1;
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
					//DataOut <= 	( CPU_A_i[3:1] ) ? { 8'h00, CPU_D8_i} : CPU_D16_i[15:0]; // IDE CS is active here
				else begin
					//DataOut <= 	CPU_D16_i[15:0];
					DataOut <= 	{CPU_D16_i[7:0], CPU_D16_i[15:8]};
				end
					
				IDE_DATA_DIR_o	<= 1'b1;
				Local_DATA_OEn <= 1'b1;
				StateMachine <= WR0;					
			end
		end 
		
		//////
		/// READ CYCLE
		//////
		// The Read And Chip Select are valid Here
		RD0: begin 
			IDE_RDn_o    <= 1'b0;		
			StateMachine <= RD4;
		end
	
		RD4: begin 
			if ( Unity_Slide[6] ) begin
				IDE_RDn_o    <= 1'b1;
				StateMachine <= RD5;
			end
		end
		
		RD5: begin 
			IDE_CS0n <= 1'b1;
			IDE_CS3n <= 1'b1;
			ETH_CSn  <= 1'b1;			
			StateMachine <= IDLE;
		end
		
	
		//////
		/// WRITE CYCLE
		//////
		// The Read And Chip Select are valid Here
		// CS Valid Here - Tick 1		
		WR0: begin 
			StateMachine <= WR4;
			IDE_WRn_o  	<= 1'b0;
		end
		

		WR4: begin 
			if ( Unity_Slide[6] ) begin
				IDE_WRn_o  <= 1'b1;		
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
			StateMachine <= IDLE;
		end
		
		default: begin 
			StateMachine <= IDLE;		
		end
		
		endcase
	end
end

endmodule

