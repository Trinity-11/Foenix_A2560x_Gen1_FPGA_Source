

module Transfer_Flash_2_Ram(

input		wire				Clk_i,
input		wire				Rst_i,

output	reg	[31:0]	Bus_A_o,

output	reg				Flash_CS_o,
output	reg				Flash_OEn_o,

output	reg				RAM_CS_o,
output	reg				RAM_WRn_o,
output	reg				RAM_OEn_o,

output	reg				TransferDone,
output   reg	[3:0]		StateMachine
);


//reg	[3:0]		StateStateMachine;

localparam		IDLE 				= 4'b0000,
					LATENCY			= 4'b0001,
					READ_FLASH0		= 4'b0011,
					READ_FLASH1		= 4'b0010,
					READ_FLASH2		= 4'b0110,
					READ_FLASH3		= 4'b0111,
					READ_FLASH4		= 4'b0101,
					WRITE_RAM0		= 4'b0100,
					TRANSFER_DONE	= 4'b1100;

					
initial begin
		TransferDone		= 1'b0;

end



reg [23:0]	Transfer_Size;

always @ (posedge Clk_i)
begin
	if (Rst_i) begin
		TransferDone		<= 1'b0;
		Bus_A_o				<= 32'h0000_0000;
		Flash_CS_o			<= 1'b0;
		Flash_OEn_o			<= 1'b1;
		// RAM
		RAM_CS_o				<= 1'b0;
		RAM_WRn_o			<= 1'b1;
		RAM_OEn_o			<= 1'b1;

		StateMachine		<= IDLE;
	end
	else begin
	
		case (StateMachine)
		
		IDLE: begin
				TransferDone		<= 1'b0;
				StateMachine		<= LATENCY;
				Bus_A_o				<= 32'h0000_0000;
				Flash_CS_o 			<= 1'b1; // Enable Flash
				Flash_OEn_o			<= 1'b0;	// Enable FLash Output Enable
				RAM_CS_o				<= 1'b1;	// Enable RAM
				RAM_OEn_o			<= 1'b1; // Make sure the RAM has Output Enable as off
				RAM_WRn_o			<= 1'b1; // Turn Off Write
		end
		
		
		LATENCY: begin
			StateMachine		<= READ_FLASH0;		
		end
		
		READ_FLASH0: begin
			// All is enable here, save the RAM Write
			RAM_WRn_o			<= 1'b0; // Enable Write
			StateMachine		<= READ_FLASH1;
		end
		
		READ_FLASH1: begin
			StateMachine		<= READ_FLASH2;		
		end
		
		READ_FLASH2: begin
			StateMachine		<= READ_FLASH3;
		end
		
		READ_FLASH3: begin
			RAM_WRn_o			<= 1'b1; // Disable Write
			StateMachine		<= READ_FLASH4;
		end		
		
		READ_FLASH4: begin
			Bus_A_o				<= Bus_A_o + 32'h0000_0004;
			StateMachine		<= WRITE_RAM0;
		end
		
		WRITE_RAM0: begin
			if (Bus_A_o == 32'h0001_0000) begin
				StateMachine		<= TRANSFER_DONE;
				Flash_CS_o 			<= 1'b0; // Enable Flash
				Flash_OEn_o			<= 1'b1;	// Enable FLash Output Enable
				RAM_CS_o				<= 1'b0;	// Enable RAM
				RAM_OEn_o			<= 1'b1; // Make sure the RAM has Output Enable as off
				RAM_WRn_o			<= 1'b1; // Turn Off Write				
			end
			else begin
				StateMachine		<= READ_FLASH0;
			end
		end
		
		
		TRANSFER_DONE: begin
				TransferDone		<= 1'b1;		
				StateMachine		<= TRANSFER_DONE;
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