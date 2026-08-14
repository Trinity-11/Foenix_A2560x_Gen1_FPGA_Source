
`timescale 1ns / 1ps
module InitClockAndVideo(
input		wire		Bus_Clk_i,
input		wire		Reset_i,
input		wire		scl_i,
output 	wire 		scl_o,
output 	wire 		scl_t,
input 	wire		sda_i,
output 	wire 		sda_o,
output 	wire 		sda_t
);

wire	[6:0]		cmd_address;
wire				cmd_start;
wire				cmd_read;
wire				cmd_write;
wire				cmd_write_multiple;
wire				cmd_stop;
wire				cmd_valid;
wire				cmd_ready;
wire	[7:0]		data_out;
wire				data_out_valid;
wire				data_out_ready;
wire				data_out_last;
wire				busy0;
wire				busy1;
wire				bus_control;
wire				bus_active;
wire				missed_ack;
wire	[7:0]		CounterOut;
wire				rst;			


reg	[1:0]		Reset_i_SYNC;

always @ (posedge Bus_Clk_i)
begin
	Reset_i_SYNC[0] <= Reset_i;
	Reset_i_SYNC[1] <= Reset_i_SYNC[0];
end

wire Reset_Synced;
assign Reset_Synced = Reset_i_SYNC[1];

reg	[15:0]	Slip;

always @ (posedge Bus_Clk_i)
begin
	if (Reset_Synced) begin
		Slip 	<= 16'hFFFF;
	end
	else begin
		Slip <= Slip << 1'b1;
	end
end


i2c_init Init_Block(
    .clk( Bus_Clk_i ),
    .rst( Reset_Synced ),
    /*
     * I2C master interface
     */
    .cmd_address( cmd_address ),			//output [6:0]
    .cmd_start( cmd_start ),				//output
    .cmd_read( cmd_read ),				//output
    .cmd_write( cmd_write ),				//output
    .cmd_write_multiple( cmd_write_multiple ),	//output
    .cmd_stop( cmd_stop ),				//output
    .cmd_valid( cmd_valid ),				//output
    .cmd_ready( cmd_ready ),				// Input

    .data_out( data_out ),				//output [7:0]
    .data_out_valid( data_out_valid ),		//output
    .data_out_ready( data_out_ready ),		// Input
    .data_out_last( data_out_last ),		//output

    /*
     * Status
     */
    .busy( busy0 ),		//output

    /*
     * Configuration
     */
    .start(Slip[15])		// Input
);

i2c_master MasterI2C_Block(
    .clk( Bus_Clk_i ),
    .rst( Reset_Synced ),
    /*
     * Host interface
     */
    .cmd_address( cmd_address ),			// Input [6:0]
    .cmd_start( cmd_start ),			// Input
    .cmd_read( cmd_read ),				// Input
    .cmd_write( cmd_write ),			// Input
    .cmd_write_multiple( cmd_write_multiple ),// Input
    .cmd_stop( cmd_stop ),				// Input
    .cmd_valid( cmd_valid ),			// Input
    .cmd_ready( cmd_ready ),			// Output

    .data_in( data_out ),				// Input [7:0]
    .data_in_valid( data_out_valid ),		// Input
    .data_in_ready( data_out_ready ),		// Output
    .data_in_last( data_out_last ),		// Input

    .data_out(  ),				// Output [7:0]
    .data_out_valid(  ),		// Output
    .data_out_ready( 1'b1 ),		// Input
    .data_out_last(  ),		// Output

    /*
     * I2C interface
     */
    .scl_i( scl_i ),	// Input
    .scl_o( scl_o ),	// Output
    .scl_t( scl_t ),	// Output
    .sda_i( sda_i ),	// Input
    .sda_o( sda_o ),	// Output
    .sda_t( sda_t ),	// Output

    /*
     * Status
     */
    .busy( busy1 ),					// Output
    .bus_control( bus_control ),			// Output
    .bus_active( bus_active ),			// Output
    .missed_ack( missed_ack ),			// Output

    /*
     * Configuration
     */
    .prescale( 16'd50),				// Input [15:0]			
    .stop_on_idle( 1'b0 )			// Input
);


endmodule

