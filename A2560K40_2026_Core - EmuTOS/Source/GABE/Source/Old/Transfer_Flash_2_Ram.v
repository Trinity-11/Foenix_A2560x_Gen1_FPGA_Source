

module Transfer_Flash_2_Ram(

input		wire				Clk_i,
input		wire				Rst_i,
//input		wire				VICKY_RDYn,			// Signal from Vicky to annonce that system is ready
input		wire				MemorySize2M_4M_i,		// 0 = 2MByte, 1 = 4MByte
output	wire	[23:0]	Bus_A_o,
output	reg				BUS_CS_EPROM0n_o,
output	reg				BUS_CS_RAM0n_o,
output	reg				BUS_CS_RAM1n_o,
output	reg				BUS_OEn_o,
output	reg				BUS_R_Wn_o,
input		wire	[7:0]		Bus_D_i,
output	reg	[7:0]		Bus_D_o,
output	reg				TransferDone,
output   reg	[3:0]		StateMachine
);


reg	[3:0]		StateStateMachine;

localparam		IDLE 				= 4'b0000,
					READ_FLASH0		= 4'b0001,
					READ_FLASH1		= 4'b0011,
					READ_FLASH2		= 4'b0010,
					WRITE_RAM0		= 4'b0110,
					WRITE_RAM1		= 4'b0111,
					WRITE_RAM2		= 4'b0101,
					TRANSFER_DONE	= 4'b0100,
					TRANSFER_VECT	= 4'b1100;
					
reg	[23:0] Flash_Addy;
reg	[23:0] Ram_Addy;
reg	BUS_CS_DEVRAMn_o;

// 2Meg RAM Code
//assign Bus_A_o = Mux ? Ram_Addy : Flash_Addy;
//assign BUS_CS_RAM0n_o = BUS_CS_DEVRAMn_o;
//assign BUS_CS_RAM1n_o = 1'b1;


reg	Mux;
assign Bus_A_o = Mux ? Ram_Addy : Flash_Addy;


reg	ChipMux;
//assign BUS_CS_RAM0n_o = ChipMux ? BUS_CS_DEVRAMn_o : 1'b1;
//assign BUS_CS_RAM1n_o = ChipMux ? 1'b1 : BUS_CS_DEVRAMn_o;


always @ (*) begin
	case ({ MemorySize2M_4M_i, ChipMux})
	2'b00: begin // 2M Code - FLASH Transfered in RAM0
				BUS_CS_RAM0n_o = BUS_CS_DEVRAMn_o; 
				BUS_CS_RAM1n_o = 1'b1; 
			end
	
	2'b01: begin // 64K VECTOR Transfer in RAM0
				BUS_CS_RAM0n_o = BUS_CS_DEVRAMn_o; 
				BUS_CS_RAM1n_o = 1'b1;
			end
	
	2'b10: begin //4M Code - FLASH Transfered in RAM1
				BUS_CS_RAM0n_o = 1'b1; 
				BUS_CS_RAM1n_o = BUS_CS_DEVRAMn_o;
			end
			
	2'b11: begin // 64K VECTOR Transfer in RAM0
				BUS_CS_RAM0n_o = BUS_CS_DEVRAMn_o; 
				BUS_CS_RAM1n_o = 1'b1;	
			end
	endcase
end


initial begin
		TransferDone		= 1'b0;
		BUS_CS_EPROM0n_o 	= 1'b1;
		BUS_CS_DEVRAMn_o	= 1'b1;
		BUS_OEn_o			= 1'b1;
		BUS_R_Wn_o			= 1'b1;
		ChipMux				= 1'b0;
end
/*
reg	[1:0] VICKY_RDYn_RESYNC;

always @ (posedge Clk_i)
begin
	VICKY_RDYn_RESYNC[0] <= VICKY_RDYn;
	VICKY_RDYn_RESYNC[1] <= VICKY_RDYn_RESYNC[0];
end
*/
reg [23:0]	Transfer_Size;

always @ (posedge Clk_i)
begin
	if (Rst_i) begin
		TransferDone		<= 1'b0;
		BUS_CS_EPROM0n_o 	<= 1'b1;
		BUS_CS_DEVRAMn_o	<= 1'b1;
		BUS_OEn_o			<= 1'b1;
		BUS_R_Wn_o			<= 1'b1;
		Mux					<= 1'b0;
		Flash_Addy			<= 24'h000000;
		Ram_Addy				<= 24'h180000;
		Transfer_Size		<= 24'h080000; // 512K Transfer	
		ChipMux				<= 1'b0;
		StateMachine		<= IDLE;
	end
	else begin
	
		case (StateMachine)
		
		IDLE: begin
//			if ({VICKY_RDYn_RESYNC[1],VICKY_RDYn_RESYNC[0]} == 2'b10) begin
				TransferDone		<= 1'b0;
				Mux					<= 1'b0;	
				ChipMux				<= 1'b0;
				Flash_Addy			<= 24'h000000;
				Ram_Addy				<= 24'h180000;
				Transfer_Size		<= 24'h080000; // 512K Transfer
				StateMachine		<= READ_FLASH0;
				StateStateMachine <= TRANSFER_VECT;
//			end
		end
		
		READ_FLASH0: begin
			BUS_CS_EPROM0n_o 	<= 1'b0;
			BUS_OEn_o			<= 1'b0;
			BUS_CS_DEVRAMn_o	<= 1'b1;
			BUS_R_Wn_o			<= 1'b1;
			StateMachine		<= READ_FLASH1;
		end
		
		READ_FLASH1: begin
			BUS_CS_EPROM0n_o 	<= 1'b1;
			BUS_OEn_o			<= 1'b1;
			Mux					<= 1'b1;			
			Bus_D_o				<= Bus_D_i;
			StateMachine		<= READ_FLASH2;		
		end
		
		READ_FLASH2: begin
			BUS_CS_DEVRAMn_o	<= 1'b0;
			BUS_R_Wn_o			<= 1'b0;
			StateMachine		<= WRITE_RAM0;
		end
		
		WRITE_RAM0: begin
			BUS_CS_DEVRAMn_o	<= 1'b1;
			BUS_R_Wn_o			<= 1'b1;
			StateMachine		<= WRITE_RAM1;		
		end
		
		WRITE_RAM1: begin
			Flash_Addy			<= Flash_Addy + 1'b1;
			Ram_Addy				<= Ram_Addy + 1'b1;
			Mux					<= 1'b0;			
			StateMachine		<= WRITE_RAM2;		
		end
		
		WRITE_RAM2: begin
			if (Flash_Addy < Transfer_Size) begin
				StateMachine		<= READ_FLASH0;
					
			end
			else begin
				ChipMux				<= 1'b1;				
				StateMachine		<= StateStateMachine;				
			end
		end
		
		TRANSFER_DONE: begin
				TransferDone		<= 1'b1;		
				StateMachine		<= TRANSFER_DONE;
		end
		
		TRANSFER_VECT: begin
				Flash_Addy			<= 24'h000000;
				Ram_Addy				<= 24'h000000;
				Transfer_Size		<= 24'h010000; // 512K Transfer
				StateMachine		<= READ_FLASH0;
				StateStateMachine <= TRANSFER_DONE;	
		end
		
		default: begin
			StateMachine		<= TRANSFER_DONE;		
		
		end

		endcase;
	end
end



endmodule

//				Flash_Addy			<= 24'h00FF00;
//				Ram_Addy				<= 24'h00FF00;
//				Transfer_Size		<= 24'h000100; // 256 Bytes Transfer Only
//				StateMachine		<= READ_FLASH0;
//				StateStateMachine <= TRANSFER_DONE;		