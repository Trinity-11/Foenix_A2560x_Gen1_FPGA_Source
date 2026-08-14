`timescale 1ns/1ns
module VideoRamAccessModule (
input		wire				Reset_i,
input		wire				VideoModeReset_i,

input		wire				EngineClk100Mhz_i,
input		wire				EngineClk200Mhz_i,

input		wire	[35:0]	VGE_Command_i,
input		wire				VGE_Command_Write_i,
output	wire				VGE_Command_Full_o,

input		wire	[31:0]	VGE_DATA_2_WRITE_i,
input		wire				VGE_DATA_2_WRITE_Write_i,
output	wire				VGE_DATA_2_WRITE_Full_o,

output	wire	[31:0]	VGE_DATA_2_READ_o,
input		wire				VGE_DATA_2_READ_Read_i,
output	wire				VGE_DATA_2_READ_Empty_o,
output   wire	[7:0]		VGE_DATA_2_READ_Count_o,

output	wire	[19:0]	VGE_Addy_o,	// 1Mx32
input		wire	[31:0]	VGE_VidMem_Data_i,
output	wire	[31:0]	VGE_VidMem_Data_o,
output	wire				VGE_VidMem_Readn_o,
output   wire	[3:0]		VGE_VidMem_Writen_o,





output	wire	[15:0]	VideoRamAccessModuleDebug_o
);


localparam 		Mode_Bitmap0_Read 	= 4'b0000,
					Mode_Bitmap1_Read 	= 4'b0000,
					Mode_Collision_Read 	= 4'b0000,					
					Mode_Tile_Map_Read 	= 4'b0010,
					Mode_Tile_Data_Read 	= 4'b0010,
					Mode_Sprites_Read   	= 4'b0011,
					Mode_MemRead	= 3'b100,
					Mode_MemWrite  = 3'b101,
					Mode_DMA_Read	= 3'b110,
					Mode_DMA_Write = 3'b111;


// Resolution 
// 864 x 664 (32 + 800 + 32) / (32 + 600 + 32) Tile Resolution (54 x 42)
// 464 x 364 (32 + 400 + 32) / (32 + 300 + 32) Tile Resolution (29 x 23)
// 704 x 544 (32 + 640 + 32) / (32 + 480 + 32) Tile Resolution (44 x 34)
// 384 x 284 (32 + 320 + 32) / (32 + 240 + 32) Tile Resolution (24 x 18) 
wire	[35:0]		VGE_CMD;
reg					VGE_CMD_Read;
wire					VGE_CMD_Empty;

wire	[31:0]		VGE_DATA2WRITE;
reg					VGE_DATA2WRITE_Read;
wire					VGE_DATA2WRITE_Empty;

wire	[31:0]		VGE_DATA2READ;
reg					VGE_DATA2READ_Write;
wire					VGE_DATA2READ_Full;


assign VGE_VidMem_Data_o = VGE_DATA2WRITE[31:0];

assign VGE_DATA2READ[31:0] = VGE_VidMem_Data_i;

assign VGE_Addy_o[19:0] = CMD_TSF_ADDY[21:2];

assign VGE_VidMem_Readn_o = VRAM_READ_i;
assign VGE_VidMem_Writen_o[3:0] = VRAM_WRITE_i[3:0];

//wire Trigger_Write;

	
VRam_FIFO_CMD36	VGE_COMMAND (
	.aclr ( Reset_i || VideoModeReset_i ),
	.clock ( EngineClk200Mhz_i ),
	.data ( VGE_Command_i ),
	.rdreq ( VGE_CMD_Read ),
	.wrreq ( VGE_Command_Write_i ),
	.empty ( VGE_CMD_Empty ),
	.full ( VGE_Command_Full_o ),
	.q ( VGE_CMD ),
	.usedw (  )
	);	

VRam_FIFO_Input	VGE_2_VMEM (
	.aclr(Reset_i || VideoModeReset_i ),
	.clock ( EngineClk200Mhz_i ),	
	// To SRAM
	.rdreq ( VGE_DATA2WRITE_Read ),
	.empty ( VGE_DATA2WRITE_Empty ),
	.usedw(),
	.q ( VGE_DATA2WRITE ),
// To VGE
	.wrreq ( VGE_DATA_2_WRITE_Write_i ),
	.data ( VGE_DATA_2_WRITE_i ),	
	.full ( VGE_DATA_2_WRITE_Full_o )
	);
	
VRam_FIFO_Input	VMEM_2_VGE (
	.aclr(Reset_i || VideoModeReset_i || (StateMachine == PROCESS_CMD) ),
	.clock ( EngineClk200Mhz_i ),		
	// To VGE
	.rdreq ( VGE_DATA_2_READ_Read_i ),
	.empty ( VGE_DATA_2_READ_Empty_o ),
	.usedw( VGE_DATA_2_READ_Count_o ),	
	.q ( VGE_DATA_2_READ_o ),	
	// From SRAM
	.wrreq ( VGE_DATA2READ_Write ),	
	.data ( VGE_DATA2READ ),	
	.full (  )
	);

	
localparam		IDLE 					= 5'b0_0000,
					READ_CMD				= 5'b0_0001,
					CMD_LATENCY			= 5'b0_0010,
					PROCESS_CMD			= 5'b0_0011,
					
					READMEM2FIFO		= 5'b0_1000,
					READMEM2FIFO_0		= 5'b0_1001,
					READMEM2FIFO_1		= 5'b0_1010,
					READMEM2FIFO_2		= 5'b0_1011,
					READMEM2FIFO_3		= 5'b0_1100,
					READMEM2FIFO_4		= 5'b0_1101,
					READMEM2FIFO_5		= 5'b0_1110,					
					
					WRITEMEM2FIFO		= 5'b1_0000,
					WRITEMEM2FIFO_0	= 5'b1_0001,
					WRITEMEM2FIFO_1	= 5'b1_0010,
					WRITEMEM2FIFO_2	= 5'b1_0011,
					WRITEMEM2FIFO_3	= 5'b1_0100,
					
					
					ENDOFPROCESS		= 5'b1_1111;
	
// VGE_CMD
// VGE_CMD [21:00] Address - Pointer from Were on 4 Bytes Boundary. [21:0]	// From 00:0000..3F:0000
// VGE_CMD [31:22] Count (in Bytes) - How Many Words I need to Fetch from Memory [9:0]
// VGE_CMD [32] 	Read_Write
// VGE_CMD [35:33] CMD

// 

//assign VideoRamAccessModuleDebug_o[4:0] = StateMachine;
//assign VideoRamAccessModuleDebug_o[5] = VRAM_READ_i;
//assign VideoRamAccessModuleDebug_o[9:6] = VRAM_WRITE_i;
//assign VideoRamAccessModuleDebug_o[10] = VGE_CMD_Empty;
//assign VideoRamAccessModuleDebug_o[11] = VGE_CMD_Read;
//assign VideoRamAccessModuleDebug_o[12] = VGE_DATA2READ_Write;
//assign VideoRamAccessModuleDebug_o[15:13] = CMD_TSF_SIZE[2:0];
assign VideoRamAccessModuleDebug_o[4:0] = StateMachine;
assign VideoRamAccessModuleDebug_o[5] = 1'b0;
assign VideoRamAccessModuleDebug_o[6] = VRAM_READ_i;
assign VideoRamAccessModuleDebug_o[7] = VGE_DATA2READ_Write;
assign VideoRamAccessModuleDebug_o[15:8] = CMD_TSF_SIZE;

reg	[4:0]		StateMachine;

reg					VRAM_READ_i;
reg	[3:0]			VRAM_WRITE_i;


reg	[21:0]		CMD_TSF_ADDY;	// 4Megs (Max)
reg	[21:0]		CMD_TSF_ADDY_DST;	// 4Megs (Max)
reg	[7:0]			CMD_TSF_SIZE;	// 1K Bytes (256 Words)
reg	[1:0]			CMD_TSF_MODE;	// Many Modes (but let's starts with 





initial
begin
	VRAM_READ_i = 1'b1;
	VRAM_WRITE_i = 4'b1111;
	StateMachine = IDLE;
end


always @ (posedge EngineClk200Mhz_i)
begin
	if (Reset_i || VideoModeReset_i) begin
		StateMachine			<= IDLE;
		VGE_CMD_Read 			<= 1'b0;
		VGE_DATA2WRITE_Read 	<= 1'b0;
		VGE_DATA2READ_Write 	<= 1'b0;
		CMD_TSF_ADDY 			<= 22'h00_0000;
		CMD_TSF_SIZE			<= 8'h00;
		VRAM_READ_i 			<= 1'b1;
		VRAM_WRITE_i 			<= 4'b1111;
	end
	else begin
	
		case (StateMachine)
		
			IDLE: begin
				if (VGE_CMD_Empty == 1'b0) begin
					VGE_CMD_Read <= 1'b1;	// Get the Command
					StateMachine <= READ_CMD;
				end
				else begin
					VGE_CMD_Read <= 1'b0;	// Get the Command
					StateMachine <= IDLE;
				end
			end

			// The Request to Read is Valid here
			READ_CMD: begin
				StateMachine <= CMD_LATENCY;
				VGE_CMD_Read <= 1'b0;	// Get the Command				
			end
			
			// Wait 1 Clock for Latency
			CMD_LATENCY: begin
				StateMachine <= PROCESS_CMD;			
			end
			
			// Command Output is Valid
			PROCESS_CMD: begin
				CMD_TSF_ADDY <= {VGE_CMD[21:2], 2'b00};	// Store the Address (it is in byte by the way)
				//CMD_TSF_SIZE <= (VGE_CMD[31:22] < 10'h05) ?  8'h00 : (VGE_CMD[31:24] - ((VGE_CMD[23:22] == 2'b00) ? 8'h01 : 8'h00));	// Store the Count (it is in byte also)	
				CMD_TSF_SIZE <= VGE_CMD[31:24];	// Store the Count (it is in byte also)	

				if (VGE_CMD[32])	begin	// Let's stick with READ and Write
				// Write
					StateMachine <= READMEM2FIFO;
					VRAM_WRITE_i 			<= 4'b1111;					
				end
				else begin
				// Read
					//StateMachine <= WRITEMEM2FIFO;
					StateMachine <= WRITEMEM2FIFO_3;
					VRAM_READ_i <= 1'b0; 
					VGE_DATA2READ_Write <= 1'b0;
				end
			end
			
			
			///////////////////////////////////////////////////
			// Write Data to VRAM
			///////////////////////////////////////////////////			
			// Data to be Written to Memory
			// Wait for the Write FiFo to have data valid
			// Let's do only 8 bit Write now
			READMEM2FIFO: begin
				if (VGE_DATA2WRITE_Empty == 1'b0) begin
					VGE_DATA2WRITE_Read <= 1'b1;
					StateMachine <= READMEM2FIFO_0;					
				end 
				else begin
					VRAM_WRITE_i <= 4'b1111;
					StateMachine <= READMEM2FIFO;			
				end
			end
			READMEM2FIFO_0: begin 
					VGE_DATA2WRITE_Read <= 1'b0;					
				StateMachine <= READMEM2FIFO_1;
			end
			
			// FIFO Latency
			READMEM2FIFO_1: begin
				case (CMD_TSF_ADDY[1:0])
					2'b00: VRAM_WRITE_i <= 4'b1110;
					2'b01: VRAM_WRITE_i <= 4'b1101;
					2'b10: VRAM_WRITE_i <= 4'b1011;
					2'b11: VRAM_WRITE_i <= 4'b0111;
					default: VRAM_WRITE_i <= 4'b1111;
				endcase
				StateMachine <= READMEM2FIFO_2;
			end

			// Data is being Writen here
			READMEM2FIFO_2: begin
				VRAM_WRITE_i <= 4'b1111;
				StateMachine <= READMEM2FIFO_3;
			end
			
			READMEM2FIFO_3: begin
				StateMachine <= ENDOFPROCESS;
			end
			
//			READMEM2FIFO_4: begin
//			end

//			READMEM2FIFO_5: begin
//			
//				StateMachine <= READMEM2FIFO_5;	
//			end
			
			///////////////////////////////////////////////////
			// Read Data from VRAM
			///////////////////////////////////////////////////
			// 1 Clock Latency for the VRAM to give out its valid Data
			//0x10
			WRITEMEM2FIFO: begin
					VGE_DATA2READ_Write <= 1'b1;
					if ( CMD_TSF_SIZE ) begin
						CMD_TSF_SIZE <= CMD_TSF_SIZE - 8'h01;
						StateMachine <= WRITEMEM2FIFO_2;
					end
					else begin
						VRAM_READ_i <= 1'b1;	// We are done;
						StateMachine <= WRITEMEM2FIFO_1;				
					end
			end
			
			//the Write in the FIFO takes place here.
			//0x11
			WRITEMEM2FIFO_0: begin
				VGE_DATA2READ_Write <= 1'b1;
				if ( CMD_TSF_SIZE == 8'h01 )  begin
					VRAM_READ_i <= 1'b1;	// We are done;
					StateMachine <= WRITEMEM2FIFO_1;
				end
				else begin
					CMD_TSF_SIZE <= CMD_TSF_SIZE - 8'h01;
					StateMachine <= WRITEMEM2FIFO_2;				
				end	

			end
			
			//0x12
			WRITEMEM2FIFO_1: begin
				VGE_DATA2READ_Write <= 1'b0;							
				StateMachine <= IDLE;
			end
			
			//0x13
			WRITEMEM2FIFO_2: begin
			VGE_DATA2READ_Write <= 1'b0;				
				if ( CMD_TSF_SIZE )  begin
					StateMachine <= WRITEMEM2FIFO_0;
				end
				else begin
					VRAM_READ_i <= 1'b1;	// We are done;
					StateMachine <= WRITEMEM2FIFO_1;				
				end
			end
			
			// 1 Delay for Read_i
			WRITEMEM2FIFO_3: begin
				StateMachine <= WRITEMEM2FIFO;
			end
	
			
			ENDOFPROCESS: begin
				StateMachine <= IDLE;			
			
			end
			
			
			default: begin
				StateMachine <= IDLE;					
			
			end
		
		
		endcase
		
		
		if (VRAM_READ_i == 1'b0) begin
			CMD_TSF_ADDY <= CMD_TSF_ADDY + 22'h00_0004;	// Increment 4 Bytes at the time
		end
	end
end









endmodule


