`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2026 10:00:25 PM
// Design Name: 
// Module Name: MC680xx_BusArbiter
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


module MC680xx_BusArbiter(
input	    wire					Reset_i,
input		wire					Clk_133Mhz_i,
input	    wire					iBUS_Clk_i,
input       wire                    iBUS_2xClk_i,


// System Signals
input       wire                    MODE_060_040_i,
input       wire                    TSF_FLASH2RAM_i,
input       wire                    Dbg_Mode_On_i,
input       wire                    Drive_BGn_i,

output      reg    [1:0]           Channel_Select_o,
// CPU Signals 
input       wire                    CPU_BRn_i,
output	    wire							CPU_BGn_o,
output      wire                    CPU_BGRn_o,     //
input       wire                    CPU_BTTn_i,     // Monitoring
input       wire                    CPU_BBn_io,     // Monitoring

// Give Access to the Memory Text System
input		wire 					iBUS_MTXT_BRn_i,        //66Mhz Clocked
output		wire 					iBUS_MTXT_BGn_o,
// Give Access to the SDMA for internal Memory data movement
input		wire 					iBUS_SDMA_BRn_i,
output		wire 					iBUS_SDMA_BGn_o,
// Give Access to the VDMA Controller for inter memory transfer
input		wire 					iBUS_VDMA_BRn_i,
output		wire 					iBUS_VDMA_BGn_o,
// Give the live Access to the Debug Agent
input       wire                    iBUS_DEBUG_BRn_i,
output		wire 					iBUS_DEBUG_BGn_o,
//
output      reg                     iBUS_ExtBUS_Valid_o,
output      wire    [3:0]           Arbiter_Debug_SM_o
);


reg         CPU_BGn_DLY;
reg         iBUS_MTXT_BG;
reg         iBUS_SDMA_BG;
reg         iBUS_VDMA_BG; 
reg         iBUS_DEBUG_BG;
reg [3:0]   Arbiter_SM;

assign iBUS_MTXT_BGn_o  = !iBUS_MTXT_BG;
assign iBUS_SDMA_BGn_o  = !iBUS_SDMA_BG;
assign iBUS_VDMA_BGn_o  = !iBUS_VDMA_BG;
assign iBUS_DEBUG_BGn_o = !iBUS_DEBUG_BG;
assign CPU_BGRn_o 		= 1'b0;

always @ ( * ) begin 
    casex ( {!iBUS_MTXT_BGn_o, !iBUS_DEBUG_BGn_o, !iBUS_VDMA_BGn_o, !iBUS_SDMA_BGn_o} )
        4'b0000: begin Channel_Select_o = 2'b00; end  // Not Used
        4'b0001: begin Channel_Select_o = 2'b10; end  // SDMA Less Priority
        4'b001x: begin Channel_Select_o = 2'b11; end  // VDMA More Priority
        4'b01xx: begin Channel_Select_o = 2'b00; end  // VDMA More Priority        
        4'b1xxx: begin Channel_Select_o = 2'b00; end  // MemText Top Priority
        default: begin Channel_Select_o = 2'b00; end 
    endcase
end 

//always @ ( posedge iBUS_Clk_i ) begin
		//CPU_BGn_o_DLY <= CPU_BRn_i;
//end

// Bus Request/Bus Granted Management logic when only 1 Master is in place.
                                    // 060 : 040
assign CPU_BGn_o = MODE_060_040_i ? ( TSF_FLASH2RAM_i ? ( Drive_BGn_i ? 1'b0 : CPU_BGn_DLY  ) : 1'b1  ) : ( TSF_FLASH2RAM_i ? ( Dbg_Mode_On_i ? 1'b1 : CPU_BRn_i ) : 1'b1 );
/*
always @ ( * ) begin 
    if ( MODE_060_040_i ) begin 
        // MC68060
        if ( TSF_FLASH2RAM_i ) begin 
            if ( Drive_BGn_i ) begin
                CPU_BGn_o = 1'b0;
            end 
            else begin 
                CPU_BGn_o = CPU_BGn_DLY;  
            end 
        end 
        else begin 
                CPU_BGn_o = 1'b1;
        end
    end 
    else begin 
        // MC68040
        if ( TSF_FLASH2RAM_i ) begin 
            if ( Dbg_Mode_On_i ) 
                CPU_BGn_o = 1'b1;
            else 
                CPU_BGn_o = CPU_BRn_i;            
        end 
        else begin 
                CPU_BGn_o = 1'b1;
        end 
    end 
end 
*/
/*
`ifdef MC68040
assign CPU_BGn_o 		= TSF_FLASH2RAM_i ? (Dbg_Mode_On_i ? 1'b1 : CPU_BRn_i) : 1'b1;	// (MC68040 Mode)
`else 
//assign CPU_BGn_o 		= TSF_FLASH2RAM_o ? (Dbg_Mode_On_i ? 1'b1 : Drive_BGn  ? 1'b0 : CPU_BGn_o_DLY) : 1'b1; //( MC68060 Mode)
assign CPU_BGn_o 		= TSF_FLASH2RAM_i ? ( Drive_BGn_i  ? 1'b0 : CPU_BGn_o_DLY ) : 1'b1; //( MC68060 Mode)
`endif
*/

localparam 			ARBT_IDLE = 4'b0000,
					ARBT_CPU0  = 4'b0001,
					ARBT_CPU1  = 4'b0011,
					ARBT_CPU2  = 4'b0010,
					ARBT_MTXT0  = 4'b0110,
					ARBT_MTXT1  = 4'b0111,
					ARBT_MTXT2  = 4'b0101,
					ARBT_MTXT3  = 4'b0100,
					ARBT_SDMA0  = 4'b1100,
					ARBT_SDMA1  = 4'b1101,
					ARBT_SDMA2  = 4'b1111,
					ARBT_SDMA3 = 4'b1110,
					ARBT_VDMA0  = 4'b1010,
					ARBT_VDMA1  = 4'b1011,
					ARBT_VDMA2  = 4'b1001,
					ARBT_VDMA3  = 4'b1000;


always @ ( * ) begin 
    if (( Arbiter_SM == ARBT_MTXT2 ) || ( Arbiter_SM == ARBT_SDMA2 ) || ( Arbiter_SM == ARBT_VDMA2) ) 
        iBUS_ExtBUS_Valid_o = 1'b1;
    else 
        iBUS_ExtBUS_Valid_o = 1'b0;

end 

assign Arbiter_Debug_SM_o = Arbiter_SM;

initial begin 
        Arbiter_SM <= ARBT_IDLE;
        iBUS_MTXT_BG = 1'b0;
        iBUS_SDMA_BG = 1'b0;
        iBUS_VDMA_BG = 1'b0;
        iBUS_DEBUG_BG = 1'b0;        
        CPU_BGn_DLY = 1'b1;
end 

/*
            if ( CPU_BBn_io & CPU_BRn_i )   begin // Make absolu
                casex( {!iBUS_MTXT_BRn_i, !iBUS_SDMA_BRn_i, !iBUS_VDMA_BRn_i})
                    3'b1xx: begin Arbiter_SM <= ARBT_MTXT0; end  // Memtext is a second Most Important
                    3'b01x: begin Arbiter_SM <= ARBT_SDMA0; end  // SDMA is Third Most Important
                    3'b001: begin Arbiter_SM <= ARBT_VDMA0; end  // VDMA is the last (SRAM -> DDR3) Transfer
                    default: begin Arbiter_SM <= ARBT_IDLE; CPU_BGn_DLY <= 1'b1; end 
                endcase
            end
            else begin 
                CPU_BGn_DLY <= CPU_BRn_i; 
                Arbiter_SM <= ARBT_IDLE;
            end 

        // Wait till there is a new request from something else than the CPU requesting its own time.
        ARBT_IDLE: begin
            casex( { (!iBUS_MTXT_BRn_i & CPU_BBn_io), (!iBUS_SDMA_BRn_i & CPU_BBn_io), (!iBUS_VDMA_BRn_i & CPU_BBn_io)})
                3'b000: begin  Arbiter_SM <= ARBT_IDLE; CPU_BGn_DLY <= CPU_BRn_i; end
                3'b1xx: begin  Arbiter_SM <= ARBT_MTXT0; end  // Memtext is a second Most Important
                3'b01x: begin  Arbiter_SM <= ARBT_SDMA0; end  // SDMA is Third Most Important
                3'b001: begin  Arbiter_SM <= ARBT_VDMA0; end  // VDMA is the last (SRAM -> DDR3) Transfer
                default: begin Arbiter_SM <= ARBT_IDLE; CPU_BGn_DLY <= 1'b1; end 
            endcase
        end 

*/

always @ (posedge iBUS_2xClk_i) begin 
/*
    if ( Reset_i ) begin 
        Arbiter_SM <= ARBT_IDLE;
        iBUS_MTXT_BG <= 1'b0;
        iBUS_SDMA_BG <= 1'b0;
        iBUS_VDMA_BG <= 1'b0;
        CPU_BGn_DLY <= 1'b1;
    end 

*/
//    else begin 
        case( Arbiter_SM )

        ARBT_IDLE: begin
            if ( CPU_BBn_io & CPU_BRn_i )   begin // Make absolu
                casex( {!iBUS_MTXT_BRn_i, !iBUS_SDMA_BRn_i, !iBUS_VDMA_BRn_i})
                    3'b1xx: begin Arbiter_SM <= ARBT_MTXT0; end  // Memtext is a second Most Important
                    3'b01x: begin Arbiter_SM <= ARBT_SDMA0; end  // SDMA is Third Most Important
                    3'b001: begin Arbiter_SM <= ARBT_VDMA0; end  // VDMA is the last (SRAM -> DDR3) Transfer
                    default: begin Arbiter_SM <= ARBT_IDLE; CPU_BGn_DLY <= 1'b1; end 
                endcase
            end
            else begin 
                CPU_BGn_DLY <= CPU_BRn_i; 
                Arbiter_SM <= ARBT_IDLE;
            end 
        end

        // Normal operation - CPU
        ARBT_CPU0 : begin
            Arbiter_SM  <= ARBT_CPU1;
        end 

        ARBT_CPU1 : begin
            Arbiter_SM  <= ARBT_CPU2;
        end 

        ARBT_CPU2 : begin
            Arbiter_SM  <= ARBT_IDLE;
        end 

        // MemText Wants the BUS
        ARBT_MTXT0 : begin
		    CPU_BGn_DLY <= 1'b1;
            iBUS_MTXT_BG <= 1'b1;
            Arbiter_SM  <= ARBT_MTXT1;
        end 


        ARBT_MTXT1 : begin
            Arbiter_SM  <= ARBT_MTXT2;
        end 

        ARBT_MTXT2 : begin
            if (!iBUS_MTXT_BRn_i) begin 
                Arbiter_SM  <= ARBT_MTXT2;
            end 
            else begin 
                Arbiter_SM  <= ARBT_MTXT3;
                iBUS_MTXT_BG <= 1'b0;
            end 
        end 


        ARBT_MTXT3 : begin
                Arbiter_SM  <= ARBT_CPU0;
        end 

        // SDMA Wants the bus
        ARBT_SDMA0 : begin
		    CPU_BGn_DLY <= 1'b1;
            iBUS_SDMA_BG <= 1'b1;
            Arbiter_SM  <= ARBT_SDMA1;
        end 


        ARBT_SDMA1 : begin
            Arbiter_SM  <= ARBT_SDMA2;
        
        end 

        ARBT_SDMA2 : begin
            if (!iBUS_SDMA_BRn_i) begin 
                Arbiter_SM  <= ARBT_SDMA2;
            end 
            else begin 
                Arbiter_SM  <= ARBT_SDMA3;
                iBUS_SDMA_BG <= 1'b0;
            end 
        end 

        ARBT_SDMA3: begin
            Arbiter_SM  <= ARBT_CPU0;
        end

        // VDMA Wants the BUS
        ARBT_VDMA0: begin
		    CPU_BGn_DLY <= 1'b1;
            iBUS_VDMA_BG <= 1'b1;
            Arbiter_SM  <= ARBT_VDMA1;
        
        end 

        ARBT_VDMA1: begin
            Arbiter_SM  <= ARBT_VDMA2;
        end 

        ARBT_VDMA2: begin
            if (!iBUS_VDMA_BRn_i) begin 
                Arbiter_SM  <= ARBT_VDMA2;
            end 
            else begin 
                Arbiter_SM  <= ARBT_VDMA3;
                iBUS_VDMA_BG <= 1'b0;
            end 
        
        end 

        ARBT_VDMA3: begin
            Arbiter_SM  <= ARBT_CPU0;
        end 

        endcase

//    end 
end 


endmodule
