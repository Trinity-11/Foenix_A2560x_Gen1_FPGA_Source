module A2560M_WIFI_Interface (
input		wire				Reset_i,
input       wire                Serial_Clk_24Mhz_i, 
input		wire				CPU_Clk_i,
input 	    wire	[31:0]		iBUS_A_i,
input		wire				iBUS_A_Valid_i,
input		wire	[7:0]		iBUS_D8_i,			// Byte Transaction
input		wire	[15:0]		iBUS_D16_i,			// Short Transaction
input		wire	[31:0]		iBUS_D32_i,			// Long	Transaction
input		wire	[1:0]		iBUS_D_Siz_i,		// Size
input		wire				iBUS_RWn_i,
input		wire	[3:0]		iBUS_BE_i,
input		wire				iBUS_WE_i, 
input		wire				CS_WIFI_UART_i,
output		reg		[31:0]		iBUS_D_WIFI32_o,
// WIFI Signals
input       wire                WIFI_Serial_RxD_i,
output      wire                WIFI_Serial_TxD_o,
output      wire                WIFI_Rx_IRQn_o
);

// iBUS_D_Siz_i 
// 0 0 - 32bits
// 0 1 - 8bits
// 1 0 - 16bits
// 1 1 - Line Access (32bits) Fetches 4 Values in Burst


wire Reset_24Mhz;
reg [2:0]   Reset_i_ReSync;
always @ ( posedge Serial_Clk_24Mhz_i ) begin
    Reset_i_ReSync[0] <= Reset_i;
    Reset_i_ReSync[1] <= Reset_i_ReSync[0];
    if ( Reset_i_ReSync[1] == Reset_i_ReSync[0] )
        Reset_i_ReSync[2] <= Reset_i_ReSync[1];
end
assign Reset_24Mhz = Reset_i_ReSync[2];

wire 	[7:0] 		Rx_Data_In;
wire 	[7:0]		Tx_Data_Out;
wire       			Rx_Data_Rdy;
reg     [7:0]       WIFI_Control_Register;
reg        			CS_WIFI_FIFO_read;
reg 				Tx_FIFO_Read_Strobe;
reg 				Tx_Data_Out_Trig;
reg     [2:0]       SM_WIFI;
reg 	[7:0] 		iBUS_D_WIFI8;
reg 	[15:0] 		iBUS_D_WIFI16;

localparam 		IDLE = 3'd0,
				LATENCY = 3'd1,
				TXD0 = 3'd2,
				TXD_WAIT0 = 3'd4;
wire                Rx_empty;
wire 	   			Tx_empty;
wire   				Tx_Data_Out_Done;
wire 	[10:0]		WIFI_UART_RxD_FIFO_RD_Count;
wire    [10:0]		WIFI_UART_RxD_FIFO_WR_Count;
wire 	[10:0]		WIFI_UART_TxD_FIFO_RD_Count;
wire    [10:0]		WIFI_UART_TxD_FIFO_WR_Count;
wire    [7:0]       FIFO_CPU_D_o;
reg 	[7:0] 		FIFO_Control_Register_24MHz[0:2];
wire 	[7:0] 		FIFO_CTRL_Reg_24Mhz;

///////// WRITE SECTION //////////////
// Kintex 7
/*
MIDI_UART_TXD_FIFO WIFI_TxD_FIFO (
  .rst( Reset_24Mhz | FIFO_CTRL_Reg_24Mhz[3] ),                      // input wire rst
  .wr_clk(CPU_Clk_i),                // input wire wr_clk
  .rd_clk(Serial_Clk_24Mhz_i),                // input wire rd_clk
  .din( iBUS_D8_i ),                      // input wire [7 : 0] din
  .wr_en( (iBUS_A_i[2:0] == 3'b001) & CS_WIFI_UART_i & (iBUS_D_Siz_i == 2'b01) & !iBUS_RWn_i & iBUS_WE_i ),                  // input wire wr_en
  .rd_en( Tx_FIFO_Read_Strobe ),                  // input wire rd_en
  .dout( Tx_Data_Out ),                    // output wire [7 : 0] dout
  .full( ),                    // output wire full
  .empty( Tx_empty ),                  // output wire empty
  .rd_data_count( ),  // output wire [10 : 0] rd_data_count
  .wr_data_count(WIFI_UART_TxD_FIFO_WR_Count),  // output wire [10 : 0] wr_data_count
  .wr_rst_busy(),      // output wire wr_rst_busy
  .rd_rst_busy()      // output wire rd_rst_busy
);
*/
// Cyclone III
MIDI_UART_TXD_FIFO	WIFI_TxD_FIFO (
	.aclr ( Reset_24Mhz | FIFO_CTRL_Reg_24Mhz[3] ),
	.data ( iBUS_D8_i ),
	.rdclk ( Serial_Clk_24Mhz_i ),
	.rdreq ( Tx_FIFO_Read_Strobe ),
	.wrclk ( CPU_Clk_i ),
	.wrreq (  (iBUS_A_i[2:0] == 3'b001) & CS_WIFI_UART_i & (iBUS_D_Siz_i == 2'b01) & !iBUS_RWn_i & iBUS_WE_i ),
	.q ( Tx_Data_Out ),
	.rdempty ( Tx_empty ),
	.rdusedw (  ),
	.wrfull (  ),
	.wrusedw ( WIFI_UART_TxD_FIFO_WR_Count )
	);


// WRITE SECTION
Serial_WIFI_Tx WIFI_TxD_Serial_Out(
	.Serial_Clk_i( Serial_Clk_24Mhz_i ),
	.Serial_Reset_i( Tx_FIFO_Read_Strobe ),
	.Tx_o( WIFI_Serial_TxD_o ),
	.Data_In_i( Tx_Data_Out ),
	.Data_In_Transmit_i( Tx_Data_Out_Trig ),
	.Data_Sent_Strobe_o( Tx_Data_Out_Done ),
	.Slow_Mode_i( ~FIFO_CTRL_Reg_24Mhz[0] )
);

always @ ( posedge Serial_Clk_24Mhz_i) begin 
	if ( Reset_24Mhz | FIFO_CTRL_Reg_24Mhz[3] ) begin 
		SM_WIFI <= IDLE;
		Tx_FIFO_Read_Strobe <= 1'b0; 
	end 
	else begin
		case ( SM_WIFI )
		IDLE: begin 
			if ( Tx_empty == 1'b0 ) begin // Not Empty 
				Tx_FIFO_Read_Strobe <= 1'b1; 	// GO read Byte 
				SM_WIFI <= LATENCY;
			end
			else begin 
		        SM_WIFI <= IDLE;
			end 
		end 

		LATENCY: begin 
			Tx_FIFO_Read_Strobe <= 1'b0; 	// GO read Byte 
			SM_WIFI <= TXD0;
		end 
	
		// Data Valid Here 
		TXD0: begin 
			Tx_Data_Out_Trig <= 1'b1; 		// Next Clock Data Will be Ready 
			SM_WIFI <= TXD_WAIT0;
		end 

		TXD_WAIT0: begin 
			Tx_Data_Out_Trig <= 1'b0; 		// Next Clock Data Will be Ready 			
			if ( Tx_Data_Out_Done ) begin 
				SM_WIFI <= IDLE;
			end 
			else begin 
				SM_WIFI <= TXD_WAIT0;
			end 

		end 

		default: begin
			SM_WIFI <= IDLE;
		end 
	
		endcase
	end 
end 

/////////// READ SECTION
// READ SECTION 
always @ (posedge CPU_Clk_i) begin
    if ( Reset_i ) begin 
	    CS_WIFI_FIFO_read <= 1'b0;
        WIFI_Control_Register <= 8'h00;
    end
    else begin 
        CS_WIFI_FIFO_read <= ((iBUS_A_i[2:0] == 3'b001) & CS_WIFI_UART_i & iBUS_RWn_i & (iBUS_D_Siz_i == 2'b01));
   
        if (CS_WIFI_UART_i && !iBUS_RWn_i && (iBUS_A_i[2:0] == 3'b000) && iBUS_WE_i) begin 
            WIFI_Control_Register <= iBUS_D8_i;
        end 
    end
end

// Clock Domain Change
always @ (posedge Serial_Clk_24Mhz_i) begin 
	FIFO_Control_Register_24MHz[0] <= WIFI_Control_Register;
	FIFO_Control_Register_24MHz[1] <= FIFO_Control_Register_24MHz[0];
	if (FIFO_Control_Register_24MHz[1] == FIFO_Control_Register_24MHz[0])
		FIFO_Control_Register_24MHz[2] <= FIFO_Control_Register_24MHz[1];
end

assign FIFO_CTRL_Reg_24Mhz = FIFO_Control_Register_24MHz[2];


Serial_WIFI_Rx WIFI_RxD_Serial_In( 
	.Serial_Clk_i( Serial_Clk_24Mhz_i ),
	.Serial_Reset_i( Reset_24Mhz | FIFO_CTRL_Reg_24Mhz[3] ),
	.Rx_i( WIFI_Serial_RxD_i ),		    // Int
	.Data_Out_o( Rx_Data_In ),			// Data Value
	.Data_Rdy_o( Rx_Data_Rdy ),			// Data Value Strobe 
    .Slow_Mode_i( ~FIFO_CTRL_Reg_24Mhz[0] )
);
/*
// AMD/Xilinx Artix/kintex 7
MIDI_UART_RXD_FIFO WIFI_RxD_FIFO (
  .rst( Reset_24Mhz | FIFO_CTRL_Reg_24Mhz[3] ),                      // input wire rst
  .wr_clk(Serial_Clk_24Mhz_i),                // input wire wr_clk
  .rd_clk( CPU_Clk_i ),                // input wire rd_clk
  .din( Rx_Data_In ),                      // input wire [7 : 0] din
  .wr_en( Rx_Data_Rdy ),                  // input wire wr_en
  .rd_en({CS_WIFI_FIFO_read, ((iBUS_A_i[2:0] == 3'b001) & CS_WIFI_UART_i & iBUS_RWn_i & (iBUS_D_Siz_i == 2'b01)) } == 2'b01 ),                  // input wire rd_en
  .dout( FIFO_CPU_D_o ),                    // output wire [7 : 0] dout
  .full(),                    // output wire full
  .empty( Rx_empty ),                  // output wire empty
  .rd_data_count( WIFI_UART_RxD_FIFO_RD_Count ),  // output wire [10 : 0] rd_data_count
  .wr_data_count( ),  // output wire [10 : 0] wr_data_count
  .wr_rst_busy(),      // output wire wr_rst_busy
  .rd_rst_busy()      // output wire rd_rst_busy
);
*/

MIDI_UART_RXD_FIFO	MIDI_UART_RXD_FIFO_inst (
	.aclr ( Reset_24Mhz | FIFO_CTRL_Reg_24Mhz[3] ),
	.data ( Rx_Data_In ),
	.rdclk ( CPU_Clk_i ),
	.rdreq ( {CS_WIFI_FIFO_read, ((iBUS_A_i[2:0] == 3'b001) & CS_WIFI_UART_i & iBUS_RWn_i & (iBUS_D_Siz_i == 2'b01)) } == 2'b01 ),
	.wrclk ( Serial_Clk_24Mhz_i ),
	.wrreq ( Rx_Data_Rdy ),
	.q ( FIFO_CPU_D_o ),
	.rdempty ( Rx_empty ),
	.rdusedw ( WIFI_UART_RxD_FIFO_RD_Count ),
	.wrfull (  ),
	.wrusedw (  )
	);


assign WIFI_Rx_IRQn_o = Rx_empty;

// Big Endian Byte Read
always @ (*) begin 
    case( iBUS_A_i[2:0] )
        3'b000: iBUS_D_WIFI8 = {4'b0000, WIFI_Control_Register[3], Tx_empty, Rx_empty, WIFI_Control_Register[0]};
		3'b001: iBUS_D_WIFI8 = {4'b0000, WIFI_Control_Register[3], Tx_empty, Rx_empty, WIFI_Control_Register[0]};		
        3'b010: iBUS_D_WIFI8 = FIFO_CPU_D_o;
		3'b011: iBUS_D_WIFI8 = FIFO_CPU_D_o;
        3'b100: iBUS_D_WIFI8 = {5'b0_0000, WIFI_UART_RxD_FIFO_RD_Count[10:8]}; 
        3'b101: iBUS_D_WIFI8 = WIFI_UART_RxD_FIFO_RD_Count[7:0];
        3'b110: iBUS_D_WIFI8 = {5'b0_0000, WIFI_UART_TxD_FIFO_WR_Count[10:8]};
        3'b111: iBUS_D_WIFI8 = WIFI_UART_TxD_FIFO_WR_Count[7:0];
        default: iBUS_D_WIFI8 = 8'h55;
    endcase
end 

always @ (*) begin 
    case( iBUS_A_i[2:1] )
        2'b00: iBUS_D_WIFI16 =  {2{4'b0000, WIFI_Control_Register[3], Tx_empty, Rx_empty, WIFI_Control_Register[0]}};
		2'b01: iBUS_D_WIFI16 = {2{FIFO_CPU_D_o}};
        2'b10: iBUS_D_WIFI16 = {5'b0_0000, WIFI_UART_RxD_FIFO_RD_Count[10:0]};
        2'b11: iBUS_D_WIFI16 = {5'b0_0000, WIFI_UART_TxD_FIFO_WR_Count[10:0]};
        default: iBUS_D_WIFI16 = 16'hDEAD;
    endcase
end 

always @ (*) begin 
	case ( iBUS_D_Siz_i ) 
		2'b00: begin iBUS_D_WIFI32_o = 32'hDEADBEEF; end 
		2'b01: begin iBUS_D_WIFI32_o = {4{ iBUS_D_WIFI8}}; end 
		2'b10: begin iBUS_D_WIFI32_o = {2{ iBUS_D_WIFI16}}; end
		2'b11: begin iBUS_D_WIFI32_o = 32'hDEADBEEF; end
		default: begin iBUS_D_WIFI32_o = 32'hDEADBEEF; end
	endcase

end 


endmodule


