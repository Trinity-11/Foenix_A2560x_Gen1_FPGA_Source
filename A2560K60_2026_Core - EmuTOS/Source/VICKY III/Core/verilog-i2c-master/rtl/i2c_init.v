/*

Copyright (c) 2015-2017 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * I2C init
 */
module i2c_init (
    input  wire        clk,
    input  wire        rst,
    /*
     * I2C master interface
     */
    output wire [6:0]  cmd_address,
    output wire        cmd_start,
    output wire        cmd_read,
    output wire        cmd_write,
    output wire        cmd_write_multiple,
    output wire        cmd_stop,
    output wire        cmd_valid,
    input  wire        cmd_ready,

    output wire [7:0]  data_out,
    output wire        data_out_valid,
    input  wire        data_out_ready,
    output wire        data_out_last,

    /*
     * Status
     */
    output wire        busy,

    /*
     * Configuration
     */
    input  wire        start
);

/*

Generic module for I2C bus initialization.  Good for use when multiple devices
on an I2C bus must be initialized on system start without intervention of a
general-purpose processor.

Copy this file and change init_data and INIT_DATA_LEN as needed.

This module can be used in two modes: simple device initalization, or multiple
device initialization.  In multiple device mode, the same initialization sequence
can be performed on multiple different device addresses.  

To use single device mode, only use the start write to address and write data commands.
The module will generate the I2C commands in sequential order.  Terminate the list
with a 0 entry.  

To use the multiple device mode, use the start data and start address block commands
to set up lists of initialization data and device addresses.  The module enters
multiple device mode upon seeing a start data block command.  The module stores the
offset of the start of the data block and then skips ahead until it reaches a start
address block command.  The module will store the offset to the address block and
read the first address in the block.  Then it will jump back to the data block
and execute it, substituting the stored address for each current address write
command.  Upon reaching the start address block command, the module will read out the
next address and start again at the top of the data block.  If the module encounters
a start data block command while looking for an address, then it will store a new data
offset and then look for a start address block command.  Terminate the list with a 0
entry.  Normal address commands will operate normally inside a data block.

Commands:

00 0000000 : stop
00 0000001 : exit multiple device mode
00 0000011 : start write to current address
00 0001000 : start address block
00 0001001 : start data block
00 1000001 : send I2C stop
01 aaaaaaa : start write to address
1 dddddddd : write 8-bit data

Examples

write 0x11223344 to register 0x0004 on device at 0x50

01 1010000  start write to 0x50
1 00000000  write address 0x0004
1 00000100
1 00010001  write data 0x11223344
1 00100010
1 00110011
1 01000100
0 00000000  stop

write 0x11223344 to register 0x0004 on devices at 0x50, 0x51, 0x52, and 0x53

00 0001001  start data block
00 0000011  start write to current address
1 00000000  write address 0x0004
1 00000100
1 00010001  write data 0x11223344
1 00100010
1 00110011
1 01000100
00 0001000  start address block
01 1010000  address 0x50
01 1010001  address 0x51
01 1010010  address 0x52
01 1010011  address 0x53
00 0000000  stop

*/

// init_data ROM
localparam INIT_DATA_LEN = 128;

reg [8:0] init_data [INIT_DATA_LEN-1:0];

initial begin
	// Channel A
	// Reg: 0x21 -> 0x09
	init_data[0]  = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[1]  = {1'b1, 8'h21}; 	// write address 0x21
	init_data[2]  = {1'b1, 8'h09}; 	// 0x05
	//init_data[3] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x20 -> 0x80
	init_data[3]  = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[4]  = {1'b1, 8'h20}; 	// write address 0x20
	init_data[5]  = {1'b1, 8'h81}; 	// 0x80
	//init_data[7] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1E -> 0xC8
	init_data[6]  = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[7]  = {1'b1, 8'h1E}; 	// write address 0x1E
	init_data[8]  = {1'b1, 8'hC8}; 	// 0xC8
	//init_data[11] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1E -> 0xC0
	init_data[9]  = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[10] = {1'b1, 8'h1E}; 	// write address 0x1E
	init_data[11] = {1'b1, 8'hC0}; 	// 0xC0
	//init_data[15] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x20 -> 0x00
	init_data[12] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[13] = {1'b1, 8'h20}; 	// write address 0x20 
	init_data[14] = {1'b1, 8'h00}; 	// 0x00
	//init_data[19] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x33 -> 0x08
	init_data[15] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[16] = {1'b1, 8'h33}; 	// write address 0x33
	init_data[17] = {1'b1, 8'h08}; 	// 0x08
	//init_data[23] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x34 -> 0x16
	init_data[18] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[19] = {1'b1, 8'h34}; 	// write address 0x34
	init_data[20] = {1'b1, 8'h16}; 	// 0x16
	//init_data[27] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x36 -> 0x60
	init_data[21] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[22] = {1'b1, 8'h36}; 	// write address 0x36
	init_data[23] = {1'b1, 8'h60}; 	// 0x60
	//init_data[31] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x48 -> 0x18
	init_data[24] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[25] = {1'b1, 8'h48}; 	// write address 0x48
	init_data[26] = {1'b1, 8'h18}; 	// 0x18 -- 0x19 Color Bar
	//init_data[35] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x49 -> 0xC0
	init_data[27] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[28] = {1'b1, 8'h49}; 	// write address 0x49
	init_data[29] = {1'b1, 8'hC0}; 	// 0xC0
	//init_data[39] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1F -> 0x98
	init_data[30] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[31] = {1'b1, 8'h1F}; 	// write address 0x1F
	init_data[32] = {1'b1, 8'h80}; 	// 0x98
	//init_data[43] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1C -> 0x04
   init_data[33] = {2'b01,7'h76}; // start write to address 0x76
   init_data[34] = {1'b1, 8'h1C}; // write address 0x1C
   init_data[35] = {1'b1, 8'h04}; // 0x04
	//init_data[47] = {2'b00, 7'b1000001}; // I2C Stop
   init_data[36] = {2'b01,7'h76}; // start write to address 0x76
   init_data[37] = {1'b1, 8'h1D}; // write address 0x1D
   init_data[38] = {1'b1, 8'h48}; // 0x48 default
	// Channel B
	init_data[39] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[40] = {1'b1, 8'h21}; 	// write address 0x21
	init_data[41] = {1'b1, 8'h09}; 	// 0x05
	//init_data[3] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x20 -> 0x80
	init_data[42] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[43] = {1'b1, 8'h20}; 	// write address 0x20
	init_data[44] = {1'b1, 8'h81}; 	// 0x80
	//init_data[7] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1E -> 0xC8
	init_data[45] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[46] = {1'b1, 8'h1E}; 	// write address 0x1E
	init_data[47] = {1'b1, 8'hC8}; 	// 0xC8
	//init_data[11] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1E -> 0xC0
	init_data[48] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[49] = {1'b1, 8'h1E}; 	// write address 0x1E
	init_data[50] = {1'b1, 8'hC0}; 	// 0xC0
	//init_data[15] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x20 -> 0x00
	init_data[51] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[52] = {1'b1, 8'h20}; 	// write address 0x20 
	init_data[53] = {1'b1, 8'h00}; 	// 0x00
	//init_data[19] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x33 -> 0x08
	init_data[54] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[55] = {1'b1, 8'h33}; 	// write address 0x33
	init_data[56] = {1'b1, 8'h08}; 	// 0x08
	//init_data[23] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x34 -> 0x16
	init_data[57] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[58] = {1'b1, 8'h34}; 	// write address 0x34
	init_data[59] = {1'b1, 8'h16}; 	// 0x16
	//init_data[27] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x36 -> 0x60
	init_data[60] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[61] = {1'b1, 8'h36}; 	// write address 0x36
	init_data[62] = {1'b1, 8'h60}; 	// 0x60
	//init_data[31] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x48 -> 0x18
	init_data[63] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[64] = {1'b1, 8'h48}; 	// write address 0x48
	init_data[65] = {1'b1, 8'h18}; 	// 0x18 -- 0x19 Color Bar
	//init_data[35] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x49 -> 0xC0
	init_data[66] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[67] = {1'b1, 8'h49}; 	// write address 0x49
	init_data[68] = {1'b1, 8'hC0}; 	// 0xC0
	//init_data[39] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1F -> 0x98
	init_data[69] = {2'b01,7'h75}; 	// start write to address 0x76
	init_data[70] = {1'b1, 8'h1F}; 	// write address 0x1F
	init_data[71] = {1'b1, 8'h80}; 	// 0x98
	//init_data[43] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1C -> 0x04
   init_data[72] = {2'b01,7'h75}; // start write to address 0x76
   init_data[73] = {1'b1, 8'h1C}; // write address 0x1C
   init_data[74] = {1'b1, 8'h04}; // 0x04
	//init_data[47] = {2'b00, 7'b1000001}; // I2C Stop
   init_data[75] = {2'b01,7'h75}; // start write to address 0x76
   init_data[76] = {1'b1, 8'h1D}; // write address 0x1D
   init_data[77] = {1'b1, 8'h48}; // 0x48 default
	
   init_data[78]  = 9'd0; // exit mode	
   init_data[79]  = 9'd0; // exit mode
   init_data[80]  = 9'd0; // exit mode	
   init_data[81]  = 9'd0; // exit mode
   init_data[82]  = 9'd0; // exit mode	
   init_data[83]  = 9'd0; // exit mode
   init_data[84]  = 9'd0; // exit mode	
   init_data[85]  = 9'd0; // exit mode
   init_data[86]  = 9'd0; // exit mode	
   init_data[87]  = 9'd0; // exit mode
   init_data[88]  = 9'd0; // exit mode	
   init_data[89]  = 9'd0; // exit mode
   init_data[90]  = 9'd0; // exit mode	
   init_data[91]  = 9'd0; // exit mode
   init_data[92]  = 9'd0; // exit mode	
   init_data[93]  = 9'd0; // exit mode
   init_data[94]  = 9'd0; // exit mode	
   init_data[95]  = 9'd0; // exit mode
   init_data[96]  = 9'd0; // exit mode	
   init_data[97]  = 9'd0; // exit mode
   init_data[98]  = 9'd0; // exit mode	
   init_data[99]  = 9'd0; // exit mode
   init_data[100] = 9'd0; // exit mode	
   init_data[101] = 9'd0; // exit mode
   init_data[102] = 9'd0; // exit mode	
   init_data[103] = 9'd0; // exit mode
   init_data[104] = 9'd0; // exit mode	
   init_data[105] = 9'd0; // exit mode
   init_data[106] = 9'd0; // exit mode	
   init_data[107] = 9'd0; // exit mode
   init_data[108] = 9'd0; // exit mode	
   init_data[109] = 9'd0; // exit mode	
   init_data[110] = 9'd0; // exit mode	
   init_data[111] = 9'd0; // exit mode
   init_data[112] = 9'd0; // exit mode	
   init_data[113] = 9'd0; // exit mode
   init_data[114] = 9'd0; // exit mode	
   init_data[115] = 9'd0; // exit mode
   init_data[116] = 9'd0; // exit mode	
   init_data[117] = 9'd0; // exit mode
   init_data[118] = 9'd0; // exit mode	
   init_data[119] = 9'd0; // exit mode
   init_data[120] = 9'd0; // exit mode	
   init_data[121] = 9'd0; // exit mode
   init_data[122] = 9'd0; // exit mode	
   init_data[123] = 9'd0; // exit mode
   init_data[124] = 9'd0; // exit mode	
   init_data[125] = 9'd0; // exit mode
   init_data[126] = 9'd0; // exit mode	
   init_data[127] = 9'd0; // exit mode

end

localparam [3:0]
    STATE_IDLE = 3'd0,
    STATE_RUN = 3'd1,
    STATE_TABLE_1 = 3'd2,
    STATE_TABLE_2 = 3'd3,
    STATE_TABLE_3 = 3'd4;

reg [4:0] state_reg = STATE_IDLE, state_next;

//parameter AW = $clog2(INIT_DATA_LEN);
parameter AW = 8;

reg [8:0] init_data_reg = 9'd0;

reg [AW-1:0] address_reg = {AW{1'b0}}, address_next;
reg [AW-1:0] address_ptr_reg = {AW{1'b0}}, address_ptr_next;
reg [AW-1:0] data_ptr_reg = {AW{1'b0}}, data_ptr_next;

reg [6:0] cur_address_reg = 7'd0, cur_address_next;

reg [6:0] cmd_address_reg = 7'd0, cmd_address_next;
reg cmd_start_reg = 1'b0, cmd_start_next;
reg cmd_write_reg = 1'b0, cmd_write_next;
reg cmd_stop_reg = 1'b0, cmd_stop_next;
reg cmd_valid_reg = 1'b0, cmd_valid_next;

reg [7:0] data_out_reg = 8'd0, data_out_next;
reg data_out_valid_reg = 1'b0, data_out_valid_next;

reg start_flag_reg = 1'b0, start_flag_next;

reg busy_reg = 1'b0;

assign cmd_address = cmd_address_reg;
assign cmd_start = cmd_start_reg;
assign cmd_read = 1'b0;
assign cmd_write = cmd_write_reg;
assign cmd_write_multiple = 1'b0;
assign cmd_stop = cmd_stop_reg;
assign cmd_valid = cmd_valid_reg;

assign data_out = data_out_reg;
assign data_out_valid = data_out_valid_reg;
assign data_out_last = 1'b1;

assign busy = busy_reg;

always @* begin
    state_next = STATE_IDLE;

    address_next = address_reg;
    address_ptr_next = address_ptr_reg;
    data_ptr_next = data_ptr_reg;

    cur_address_next = cur_address_reg;

    cmd_address_next = cmd_address_reg;
    cmd_start_next = cmd_start_reg & ~(cmd_valid & cmd_ready);
    cmd_write_next = cmd_write_reg & ~(cmd_valid & cmd_ready);
    cmd_stop_next = cmd_stop_reg & ~(cmd_valid & cmd_ready);
    cmd_valid_next = cmd_valid_reg & ~cmd_ready;

    data_out_next = data_out_reg;
    data_out_valid_next = data_out_valid_reg & ~data_out_ready;

    start_flag_next = start_flag_reg;

    if (cmd_valid | data_out_valid) begin
        // wait for output registers to clear
        state_next = state_reg;
    end else begin
        case (state_reg)
            STATE_IDLE: begin
                // wait for start signal
                if (~start_flag_reg & start) begin
                    address_next = {AW{1'b0}};
                    start_flag_next = 1'b1;
                    state_next = STATE_RUN;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
            STATE_RUN: begin
                // process commands
                if (init_data_reg[8] == 1'b1) begin
                    // write data
                    cmd_write_next = 1'b1;
                    cmd_stop_next = 1'b0;
                    cmd_valid_next = 1'b1;

                    data_out_next = init_data_reg[7:0];
                    data_out_valid_next = 1'b1;
                    
                    address_next = address_reg + 8'd1;
                    
                    state_next = STATE_RUN;
                end else if (init_data_reg[8:7] == 2'b01) begin
                    // write address
                    cmd_address_next = init_data_reg[6:0];
                    cmd_start_next = 1'b1;

                    address_next = address_reg + 8'd1;
                    
                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'b001000001) begin
                    // send stop
                    cmd_write_next = 1'b0;
                    cmd_start_next = 1'b0;
                    cmd_stop_next = 1'b1;
                    cmd_valid_next = 1'b1;

                    address_next = address_reg + 8'd1;

                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 8'd1;
                    address_next = address_reg + 8'd1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    cmd_start_next = 1'b0;
                    cmd_write_next = 1'b0;
                    cmd_stop_next = 1'b1;
                    cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 8'd1;
                    state_next = STATE_RUN;
                end
            end
            STATE_TABLE_1: begin
                // find address table start
                if (init_data_reg == 9'b000001000) begin
                    // address table start
                    address_ptr_next = address_reg + 8'd1;
                    address_next = address_reg + 8'd1;
                    state_next = STATE_TABLE_2;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 8'd1;
                    address_next = address_reg + 8'd1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 1) begin
                    // exit mode
                    address_next = address_reg + 8'd1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    cmd_start_next = 1'b0;
                    cmd_write_next = 1'b0;
                    cmd_stop_next = 1'b1;
                    cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 8'd1;
                    state_next = STATE_TABLE_1;
                end
            end
            STATE_TABLE_2: begin
                // find next address
                if (init_data_reg[8:7] == 2'b01) begin
                    // write address command
                    // store address and move to data table
                    cur_address_next = init_data_reg[6:0];
                    address_ptr_next = address_reg + 8'd1;
                    address_next = data_ptr_reg;
                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 8'd1;
                    address_next = address_reg + 8'd1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 9'd1) begin
                    // exit mode
                    address_next = address_reg + 8'd1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    cmd_start_next = 1'b0;
                    cmd_write_next = 1'b0;
                    cmd_stop_next = 1'b1;
                    cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 8'd1;
                    state_next = STATE_TABLE_2;
                end
            end
            STATE_TABLE_3: begin
                // process data table with selected address
                if (init_data_reg[8] == 1'b1) begin
                    // write data
                    cmd_write_next = 1'b1;
                    cmd_stop_next = 1'b0;
                    cmd_valid_next = 1'b1;

                    data_out_next = init_data_reg[7:0];
                    data_out_valid_next = 1'b1;

                    address_next = address_reg + 8'd1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg[8:7] == 2'b01) begin
                    // write address
                    cmd_address_next = init_data_reg[6:0];
                    cmd_start_next = 1'b1;

                    address_next = address_reg + 8'd1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b000000011) begin
                    // write current address
                    cmd_address_next = cur_address_reg;
                    cmd_start_next = 1'b1;

                    address_next = address_reg + 8'd1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b001000001) begin
                    // send stop
                    cmd_write_next = 1'b0;
                    cmd_start_next = 1'b0;
                    cmd_stop_next = 1'b1;
                    cmd_valid_next = 1'b1;

                    address_next = address_reg + 8'd1;

                    state_next = STATE_TABLE_3;
                end else if (init_data_reg == 9'b000001001) begin
                    // data table start
                    data_ptr_next = address_reg + 8'd1;
                    address_next = address_reg + 8'd1;
                    state_next = STATE_TABLE_1;
                end else if (init_data_reg == 9'b000001000) begin
                    // address table start
                    address_next = address_ptr_reg;
                    state_next = STATE_TABLE_2;
                end else if (init_data_reg == 9'd1) begin
                    // exit mode
                    address_next = address_reg + 8'd1;
                    state_next = STATE_RUN;
                end else if (init_data_reg == 9'd0) begin
                    // stop
                    cmd_start_next = 1'b0;
                    cmd_write_next = 1'b0;
                    cmd_stop_next = 1'b1;
                    cmd_valid_next = 1'b1;

                    state_next = STATE_IDLE;
                end else begin
                    // invalid command, skip
                    address_next = address_reg + 8'd1;
                    state_next = STATE_TABLE_3;
                end
            end
        endcase
    end
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;

        init_data_reg <= 9'd0;

        address_reg <= {AW{1'b0}};
        address_ptr_reg <= {AW{1'b0}};
        data_ptr_reg <= {AW{1'b0}};

        cur_address_reg <= 7'd0;

        cmd_valid_reg <= 1'b0;

        data_out_valid_reg <= 1'b0;

        start_flag_reg <= 1'b0;

        busy_reg <= 1'b0;
    end else begin
        state_reg <= state_next;

        // read init_data ROM
        init_data_reg <= init_data[address_next];

        address_reg <= address_next;
        address_ptr_reg <= address_ptr_next;
        data_ptr_reg <= data_ptr_next;

        cur_address_reg <= cur_address_next;

        cmd_valid_reg <= cmd_valid_next;

        data_out_valid_reg <= data_out_valid_next;

        start_flag_reg <= start & start_flag_next;

        busy_reg <= (state_reg != STATE_IDLE);
    end

    cmd_address_reg <= cmd_address_next;
    cmd_start_reg <= cmd_start_next;
    cmd_write_reg <= cmd_write_next;
    cmd_stop_reg <= cmd_stop_next;

    data_out_reg <= data_out_next;
end

endmodule

/*
    // single address
////////////////////////////////////
	//init_data[3] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x49 -> 0xC0
	init_data[0] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[1] = {1'b1, 8'h49}; 	// write address 0x49
	init_data[2] = {1'b1, 8'hC0}; 	// 0xC0
	// Reg: 0x21 -> 0x09
	init_data[3]  = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[4] = {1'b1, 8'h21}; 	// write address 0x21
	init_data[5] = {1'b1, 8'h09}; 	// 0x05	
	//init_data[7] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1E -> 0xC8
	init_data[6]  = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[7]  = {1'b1, 8'h1E}; 	// write address 0x1E
	init_data[8]  = {1'b1, 8'hC8}; 	// 0xC8
	//init_data[11] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1E -> 0xC0
	init_data[9]  = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[10] = {1'b1, 8'h1E}; 	// write address 0x1E
	init_data[11] = {1'b1, 8'hC0}; 	// 0xC0
	//init_data[15] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x20 -> 0x80
	init_data[12]  = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[13]  = {1'b1, 8'h20}; 	// write address 0x20
	init_data[14]  = {1'b1, 8'h00}; 	// 0x80
	//init_data[19] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x33 -> 0x08
	init_data[15] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[16] = {1'b1, 8'h33}; 	// write address 0x33
	init_data[17] = {1'b1, 8'h08}; 	// 0x08
	//init_data[23] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x34 -> 0x16
	init_data[18] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[19] = {1'b1, 8'h34}; 	// write address 0x34
	init_data[20] = {1'b1, 8'h16}; 	// 0x16
	//init_data[27] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x36 -> 0x60
	init_data[21] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[22] = {1'b1, 8'h36}; 	// write address 0x36
	init_data[23] = {1'b1, 8'h60}; 	// 0x60
	//init_data[31] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x48 -> 0x18
	init_data[24] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[25] = {1'b1, 8'h48}; 	// write address 0x48
	init_data[26] = {1'b1, 8'h18}; 	// 0x18 -- 0x19 Color Bar
	//init_data[35] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x20 -> 0x00
	init_data[27] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[28] = {1'b1, 8'h20}; 	// write address 0x20 
	init_data[29] = {1'b1, 8'h80}; 	// 0x80
	//init_data[39] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1F -> 0x98
	init_data[30] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[31] = {1'b1, 8'h1F}; 	// write address 0x1F
	init_data[32] = {1'b1, 8'h80}; 	// 0x98
	//init_data[43] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x1C -> 0x04
   init_data[33] = {2'b01,7'h76}; // start write to address 0x76
   init_data[34] = {1'b1, 8'h1C}; // write address 0x1C
   init_data[35] = {1'b1, 8'h04}; // 0x04
	
	// Reg: 0x1C -> 0x04
   init_data[36] = {2'b01,7'h76}; // start write to address 0x76
   init_data[37] = {1'b1, 8'h1D}; // write address 0x1D
   init_data[38] = {1'b1, 8'h08}; // 0x08	
	
		// Reg: 0x1C -> 0x04
   init_data[39] = {2'b01,7'h76}; // start write to address 0x76
   init_data[40] = {1'b1, 8'h14}; // write address 0x14
   init_data[41] = {1'b1, 8'h02}; // 0x03	
	//init_data[47] = {2'b00, 7'b1000001}; // I2C Stop
	// Reg: 0x20 -> 0x00
	init_data[42] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[43] = {1'b1, 8'h20}; 	// write address 0x20 
	init_data[44] = {1'b1, 8'h00}; 	// 0x80
   //init_data[42] = 9'd0; // stop
   //init_data[43] = 9'd0; // stop
   //init_data[44] = 9'd0; // stop	
	init_data[45] = {2'b01,7'h76}; 	// start write to address 0x76
	init_data[46] = {1'b1, 8'h56}; 	// write address 0x20 
	init_data[47] = {1'b1, 8'h00}; 	// 0x80
   init_data[48] = 9'd0; // stop
   init_data[49] = 9'd0; // stop
   init_data[50] = 9'd0; // stop
   init_data[51] = 9'd0; // stop
   init_data[52] = 9'd0; // stop
   init_data[53] = 9'd0; // stop
   init_data[54] = 9'd0; // stop
   init_data[55] = 9'd0; // stop
   init_data[56] = 9'd0; // stop
   init_data[57] = 9'd0; // stop
   init_data[58] = 9'd0; // stop
   init_data[59] = 9'd0; // stop
   init_data[60] = 9'd0; // stop
   init_data[61] = 9'd0; // stop
   init_data[62] = 9'd0; // stop
   init_data[63] = 9'd0; // stop	
*/