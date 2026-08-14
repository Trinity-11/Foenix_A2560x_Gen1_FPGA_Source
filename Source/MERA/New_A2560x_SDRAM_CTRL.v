/**
 * simple controller for ISSI IS42S16160G-7 SDRAM found in De0 Nano
 *  16Mbit x 16 data bit bus (32 megabytes)
 *  Default options
 *    133Mhz
 *    CAS 3
 *
 *  Very simple host interface
 *     * No burst support
 *     * haddr - address for reading and wriging 16 bits of data
 *     * data_input - data for writing, latched in when wr_enable is highz0
 *     * data_output - data for reading, comes available sometime
 *       *few clocks* after rd_enable and address is presented on bus
 *     * rst_n - start init ram process
 *     * rd_enable - read enable, on SYS_4xClk_i posedge haddr will be latched in,
 *       after *few clocks* data will be available on the data_output port
 *     * wr_enable - write enable, on SYS_4xClk_i posedge haddr and data_input will
 *       be latched in, after *few clocks* data will be written to sdram
 *
 * Theory
 *  This simple host interface has a busy signal to tell you when you are
 *  not able to issue commands.
 */

/* Internal Parameters */
parameter ROW_WIDTH = 13;       // A[12:0] == 13 Addy Lines
parameter COL_WIDTH = 9;        // A[8:0]   = 9 Addy Lines
parameter BANK_WIDTH = 2;       // Bank = 2 Addy Lines

parameter SDRADDR_WIDTH = ROW_WIDTH > COL_WIDTH ? ROW_WIDTH : COL_WIDTH;
parameter HADDR_WIDTH = BANK_WIDTH + ROW_WIDTH + COL_WIDTH;

module New_A2560x_SDRAM_CTRL (
    /* HOST INTERFACE */
input                                   Reset_i,

input     wire                          SYS_2xClk_i,            // 66Mhz
input     wire                          SYS_4xClk_i,            // 133Mhz

input     wire                          CPU_Dead_Cycle_i,         // 1 = VDA & VPA == 2'b00
input     wire                          CPU_Accessing_SDRAM_i,    // 1 = CPU is Accessing the SDRAM
// Write Interface
input     wire    [HADDR_WIDTH-1:0]     wr_addr,
input     wire    [31:0]                wr_data,
input     wire                          wr_enable,
input     wire   [3:0]                  wr_byte_enable,
// Read Interface
input     wire   [HADDR_WIDTH-1:0]      rd_addr,
output    wire   [31:0]                 rd_data,
input     wire                          rd_enable,
output    wire                          rd_ready,
// Busy Output
output    reg                          	busy,

output 	 wire  	[31:0]					 SDRAM_Data32_i,
output 	 wire  	[31:0]					 SDRAM_Data32_o,
output 	 wire    [4:0]						 SDRAM_Debug_SM_o,

// SDRAM Interface
output    wire   [SDRADDR_WIDTH-1:0]    addr,
output    wire   [BANK_WIDTH-1:0]       bank_addr,
inout     wire   [31:0]                 data,
output    wire                          clock_enable,
output    wire                          cs_n,
output    wire                          ras_n,
output    wire                          cas_n,
output    wire                          we_n,
output    wire   [3:0]                  data_mask_o
//output    wire                          data_mask_low,
//output    wire                          data_mask_high
);


/*
Row address: A0..A12. 
Column address: A0..A8. 
A10 is sampled during a precharge command to determine if all banks are to be precharged or bank selected by BS0, BS1. 
*/
// The Data will be MASKED when the DQM = 1
// The Data will be WRITTEN When the DQM = 0


parameter CLK_FREQUENCY = 133;  // Mhz
parameter REFRESH_TIME =  32;   // ms     (how often we need to refresh)
parameter REFRESH_COUNT = 8192; // cycles (how many refreshes required per refresh time)

// SYS_4xClk_i / refresh =  SYS_4xClk_i / sec
//                , sec / refbatch
//                , ref / refbatch
localparam CYCLES_BETWEEN_REFRESH = ( CLK_FREQUENCY
                                      * 1_000
                                      * REFRESH_TIME
                                    ) / REFRESH_COUNT;

// STATES - State
localparam IDLE      = 5'b00000;

localparam INIT_NOP1 = 5'b01000,
           INIT_PRE1 = 5'b01001,
           INIT_NOP1_1=5'b00101,
           INIT_REF1 = 5'b01010,
           INIT_NOP2 = 5'b01011,
           INIT_REF2 = 5'b01100,
           INIT_NOP3 = 5'b01101,
           INIT_LOAD = 5'b01110,
           INIT_NOP4 = 5'b01111;

localparam REF_PRE  =  5'b0_0001,
           REF_NOP1 =  5'b0_0010,
           REF_REF  =  5'b0_0011,
           REF_NOP2 =  5'b0_0100;

localparam READ_ACT  = 5'b1_0000,
           READ_NOP1 = 5'b1_0001,
           READ_CAS  = 5'b1_0010,
           READ_NOP2 = 5'b1_0011,
           READ_READ = 5'b1_0100;

localparam WRIT_ACT  = 5'b1_1000,
           WRIT_NOP1 = 5'b1_1001,
           WRIT_CAS  = 5'b1_1010,
           WRIT_NOP2 = 5'b1_1011;

// Commands              CCRCWBBA
//                       ESSSE100
localparam CMD_PALL = 8'b10010001,
           CMD_REF  = 8'b10001000,
           CMD_NOP  = 8'b10111000,
           CMD_MRS  = 8'b1000000x,
           CMD_BACT = 8'b10011xxx,
           CMD_READ = 8'b10101xx1,
           CMD_WRIT = 8'b10100xx1;

/* Interface Definition */
/* HOST INTERFACE */
//input  [HADDR_WIDTH-1:0]   wr_addr;
//input  [15:0]              wr_data;
//input                      wr_enable;

//input  [HADDR_WIDTH-1:0]   rd_addr;
//output [15:0]              rd_data;
//input                      rd_enable;
//output                     rd_ready;

//output                     busy;
//input                      rst_n;
//input                      SYS_4xClk_i;

/* SDRAM SIDE */
//output [SDRADDR_WIDTH-1:0] addr;
//output [BANK_WIDTH-1:0]    bank_addr;
//inout  [15:0]              data;
//output                     clock_enable;
//output                     cs_n;
//output                     ras_n;
//output                     cas_n;
//output                     we_n;
//output                     data_mask_low;
//output                     data_mask_high;

/* I/O Registers */

reg  [HADDR_WIDTH-1:0]    haddr_r;
reg  [31:0]                wr_data_r;
reg  [31:0]                rd_data_r;
reg  [3:0]                data_mask_r;

reg [SDRADDR_WIDTH-1:0]   addr_r;
reg [BANK_WIDTH-1:0]      bank_addr_r;
reg                       rd_ready_r;

wire [31:0]                data_output;

assign data_mask_o    = data_mask_r;

assign rd_data        = rd_data_r;
//assign rd_data = data;

/* Internal Wiring */
reg [3:0] state_cnt;
reg [9:0] refresh_cnt;

reg [7:0] command;
reg [4:0] state;

// TODO output addr[6:4] when programming mode register

reg [7:0] command_nxt;
reg [3:0] state_cnt_nxt;
reg [4:0] next;

assign {clock_enable, cs_n, ras_n, cas_n, we_n} = command[7:3];
// state[4] will be set if mode is read/write
assign bank_addr      = (state[4]) ? bank_addr_r : command[2:1];
assign addr           = (state[4] | state == INIT_LOAD) ? addr_r : { {SDRADDR_WIDTH-11{1'b0}}, command[0], 10'd0 };

//assign data = (state == WRIT_CAS) ? wr_data_r : 32'bz;
assign rd_ready = rd_ready_r;

assign SDRAM_Data32_i = data_in;
assign SDRAM_Data32_o = wr_data_r;
assign SDRAM_Debug_SM_o = state;
wire [31:0] data_in; 

// Bi-Dir BUS For ADDY
BIDIR_DATA32	SDRAM_DQIO (
	.datain ( wr_data_r ),
	.oe ( ((state == WRIT_CAS) | ( state == WRIT_NOP1 )) ? 32'hFFFF_FFFF : 32'h0000_0000 ),
	.dataio ( data ),
	.dataout ( data_in )
	);


// HOST INTERFACE
// all registered on posedge
always @ (posedge SYS_4xClk_i)
  if (Reset_i)
    begin
    state <= INIT_NOP1;
    command <= CMD_NOP;
    state_cnt <= 4'hf;

    haddr_r <= {HADDR_WIDTH{1'b0}};
    wr_data_r <= 32'd0;
    rd_data_r <= 32'd0;
    busy <= 1'b0;
    end
  else
    begin

    state <= next;
    command <= command_nxt;

    if (!state_cnt)
      state_cnt <= state_cnt_nxt;
    else
      state_cnt <= state_cnt - 1'b1;

    if (wr_enable)
      wr_data_r <= wr_data;

    if (state == READ_READ)
      begin
      rd_data_r <= data_in;
      //rd_data_r <= data;
      rd_ready_r <= 1'b1;
      end
    else
      rd_ready_r <= 1'b0;

    busy <= state[4];

    if (rd_enable)
      haddr_r <= rd_addr;
    else if (wr_enable)
      haddr_r <= wr_addr;

    end

// Handle refresh counter
always @ (posedge SYS_4xClk_i)
 if (Reset_i)
   refresh_cnt <= 10'b0;
 else
   if (state == REF_NOP2)
     refresh_cnt <= 10'b0;
   else
     refresh_cnt <= refresh_cnt + 1'b1;


/* Handle logic for sending addresses to SDRAM based on current state*/
      //{data_mask_low_r, data_mask_high_r} = 2'b00;
      //{data_mask_low_r, data_mask_high_r} = 2'b11;      
always @*
begin
    //if (state[4]) // When State[4] = 1, this is a write or read moment
		//data_mask_r = ~wr_byte_enable;
    //else
		//data_mask_r = 4'b1111; // When doing anything else then read or write, then just keep the MASK on

    if (we_n) // When State[4] = 1, this is a write or read moment
     data_mask_r = 4'b1111;
    else
     data_mask_r = ~wr_byte_enable[3:0]; // When doing anything else then read or write, then just keep the MASK on	  
	  
	  
   bank_addr_r = 2'b00;
   addr_r = {SDRADDR_WIDTH{1'b0}};

   if (state == READ_ACT | state == WRIT_ACT)
     begin
     bank_addr_r = haddr_r[HADDR_WIDTH-1:HADDR_WIDTH-(BANK_WIDTH)];
     addr_r = haddr_r[HADDR_WIDTH-(BANK_WIDTH+1):HADDR_WIDTH-(BANK_WIDTH+ROW_WIDTH)];
     end
   else if (state == READ_CAS | state == WRIT_CAS)
     begin
     // Send Column Address
     // Set bank to bank to precharge
     bank_addr_r = haddr_r[HADDR_WIDTH-1:HADDR_WIDTH-(BANK_WIDTH)];

     // Examples for math
     //               BANK  ROW    COL
     // HADDR_WIDTH   2 +   13 +   9   = 24
     // SDRADDR_WIDTH 13

     // Set CAS address to:
     //   0s,
     //   1 (A10 is always for auto precharge),
     //   0s,
     //   column address
     addr_r = {
               {SDRADDR_WIDTH-(11){1'b0}},
               1'b1,                       /* A10 */
               {10-COL_WIDTH{1'b0}},
               haddr_r[COL_WIDTH-1:0]
              };
     end
   else if (state == INIT_LOAD)
     begin
     // Program mode register during load cycle
     //                                       B  C  SB
     //                                       R  A  EUR
     //                                       S  S-3Q ST
     //                                       T  654L210
     addr_r = {{SDRADDR_WIDTH-10{1'b0}}, 10'b1000110000};
     end
end

// CPU_Dead_Cycle_i = 1 - No CPU Transaction (dead CPU Cycle)
// Next state logic
always @*
begin
   state_cnt_nxt = 4'd0;
   command_nxt = CMD_NOP;
   if (state == IDLE)
        // Monitor for refresh or hold
        //if ((refresh_cnt >= CYCLES_BETWEEN_REFRESH) & (( !CPU_Accessing_SDRAM_i ) | (CPU_Accessing_SDRAM_i & CPU_Dead_Cycle_i ) ))
        if ((refresh_cnt >= CYCLES_BETWEEN_REFRESH) & CPU_Dead_Cycle_i & !CPU_Accessing_SDRAM_i )		  
          begin
          next = REF_PRE;
          command_nxt = CMD_PALL;
          end
        else if (rd_enable)
          begin
          next = READ_ACT;
          command_nxt = CMD_BACT;
          end
        else if (wr_enable)
          begin
          next = WRIT_ACT;
          command_nxt = CMD_BACT;
          end
        else
          begin
          // HOLD
          next = IDLE;
          end
    else
      if (!state_cnt)
        case (state)
          // INIT ENGINE
          INIT_NOP1:
            begin
            next = INIT_PRE1;
            command_nxt = CMD_PALL;
            end
          INIT_PRE1:
            begin
            next = INIT_NOP1_1;
            end
          INIT_NOP1_1:
            begin
            next = INIT_REF1;
            command_nxt = CMD_REF;
            end
          INIT_REF1:
            begin
            next = INIT_NOP2;
            state_cnt_nxt = 4'd7;
            end
          INIT_NOP2:
            begin
            next = INIT_REF2;
            command_nxt = CMD_REF;
            end
          INIT_REF2:
            begin
            next = INIT_NOP3;
            state_cnt_nxt = 4'd7;
            end
          INIT_NOP3:
            begin
            next = INIT_LOAD;
            command_nxt = CMD_MRS;
            end
          INIT_LOAD:
            begin
            next = INIT_NOP4;
            state_cnt_nxt = 4'd1;
            end
          // INIT_NOP4: default - IDLE

          // REFRESH
          REF_PRE:
            begin
            next = REF_NOP1;
            end
          REF_NOP1:
            begin
            next = REF_REF;
            command_nxt = CMD_REF;
            end
          REF_REF:
            begin
            next = REF_NOP2;
            state_cnt_nxt = 4'd7;
            end
          // REF_NOP2: default - IDLE

          // WRITE
          WRIT_ACT:
            begin
            next = WRIT_NOP1;
            state_cnt_nxt = 4'd1;
            end
          WRIT_NOP1:
            begin
            next = WRIT_CAS;
            command_nxt = CMD_WRIT;
            end
          WRIT_CAS:
            begin
            next = WRIT_NOP2;
            state_cnt_nxt = 4'd1;
            end
          // WRIT_NOP2: default - IDLE

          // READ
          READ_ACT:
            begin
            next = READ_NOP1;
            state_cnt_nxt = 4'd1;
            end
          READ_NOP1:
            begin
            next = READ_CAS;
            command_nxt = CMD_READ;
            end
          READ_CAS:
            begin
            next = READ_NOP2;
            state_cnt_nxt = 4'd1;
            end
          READ_NOP2:
            begin
            next = READ_READ;
            end
          // READ_READ: default - IDLE

          default:
            begin
            next = IDLE;
            end
          endcase
      else
        begin
        // Counter Not Reached - HOLD
        next = state;
        command_nxt = command;
        end
end

endmodule
