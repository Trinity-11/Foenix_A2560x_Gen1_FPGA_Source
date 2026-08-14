`timescale 1 ns / 1 ns
module VMEM2CPU_Interface (
input 	wire					rst_i,				// This is async Reset
// CPU Signals Interface
input 	wire					Bus_Clk_i,
input 	wire	[23:0]		Bus_A_i,
input		wire  [7:0]			Bus_D_i,
output 	reg	[7:0]			Bus_D_o,
input		wire					Bus_RW_i,
input		wire					CS_VMEM_2_CPU_i,

output 	wire					VMEM_2_CPU_ResetFiFo_o,
input 	wire	[9:0]			VMEM_2_CPU_FIFO_Count_i,
input		wire  				VMEM_2_CPU_FIFO_Empty_i,
input		wire  [7:0]			VMEM_2_CPU_Data_i,

output	wire					VMEM_2_CPU_Interrupt_o
);

always @ (*) begin
	case( Bus_A_i[1:0] )
		2'b00: begin Bus_D_o = VMEM2PC_Ctrl_Reg; 										end
		2'b01: begin Bus_D_o = VMEM_2_CPU_Data_i; 									end
		2'b10: begin Bus_D_o = VMEM_2_CPU_FIFO_Count_i[7:0]; 						end
		2'b11: begin Bus_D_o = {VMEM_2_CPU_FIFO_Empty_i, 5'b000_00, VMEM_2_CPU_FIFO_Count_i[9:8]}; 	end
	endcase
end

reg [7:0] VMEM2PC_Ctrl_Reg;

assign VMEM_2_CPU_ResetFiFo_o = VMEM2PC_Ctrl_Reg[0];


reg [3:0] Interrupt_Slip;
reg VMEM_2_CPU_FIFO_Empty_EDGE;

assign VMEM_2_CPU_Interrupt_o = Interrupt_Slip[3];

always @ (posedge Bus_Clk_i) begin
	if (rst_i) begin
		Interrupt_Slip <= 4'b0000;
	end
	else begin
		VMEM_2_CPU_FIFO_Empty_EDGE <= VMEM_2_CPU_FIFO_Empty_i;
		Interrupt_Slip <= Interrupt_Slip << 1'b1;
		if (( {VMEM_2_CPU_FIFO_Empty_EDGE, VMEM_2_CPU_FIFO_Empty_i} == 2'b10 ) && VMEM2PC_Ctrl_Reg[1] ) begin
				Interrupt_Slip <= 4'b1111;
		end
	end
end


// Writing Part
always @ (negedge Bus_Clk_i) begin
	if (rst_i)
	begin
	// Multiplier A
		VMEM2PC_Ctrl_Reg <= 8'h00;
	end
	else	begin
		if (CS_VMEM_2_CPU_i & !Bus_RW_i) begin
			if (Bus_A_i[3:0] == 4'b0000)
				VMEM2PC_Ctrl_Reg <= Bus_D_i;
		end
	end
end


endmodule
