module Overlay_Alpha_Compute (
input           clk,
input           rst,
input   [7:0]   Background_In_R,
input   [7:0]   Background_In_G,
input   [7:0]   Background_In_B,
input   [7:0]   Foreground_In_R,
input   [7:0]   Foreground_In_G,
input   [7:0]   Foreground_In_B,
input   [7:0]   Alpha_In,
output  [7:0]   Combined_Out_R,
output  [7:0]   Combined_Out_G,
output  [7:0]   Combined_Out_B
);

wire    [15:0] Mult_R0_Results_Out;
wire    [15:0] Mult_G0_Results_Out;
wire    [15:0] Mult_B0_Results_Out;
wire    [15:0] Mult_R1_Results_Out;
wire    [15:0] Mult_G1_Results_Out;
wire    [15:0] Mult_B1_Results_Out;

wire [7:0] InverseAlpha;
assign InverseAlpha = Alpha_In ^ 8'hFF;

// Calculate Transparency for Background (the Live Image)
Alpha_Multiplication ComputeUnitA (
    .Clock( clk ), 
    .ClkEn( 1'b1 ), 
    .Aclr( rst ), 
    .DataA( Background_In_R ), 
    .DataB( InverseAlpha ), 
    .Result( Mult_R0_Results_Out )
);
    
Alpha_Multiplication ComputeUnitB (
    .Clock( clk ), 
    .ClkEn( 1'b1 ), 
    .Aclr( rst ), 
    .DataA( Background_In_G ), 
    .DataB( InverseAlpha ),     
    .Result( Mult_G0_Results_Out )
);

Alpha_Multiplication ComputeUnitC (
    .Clock( clk ), 
    .ClkEn( 1'b1 ), 
    .Aclr( rst ), 
    .DataA( Background_In_B ), 
    .DataB( InverseAlpha ),     
    .Result( Mult_B0_Results_Out )
);

// Calculate Transparency for Foreground (the Overlay)
Alpha_Multiplication ComputeUnitD (
    .Clock( clk ), 
    .ClkEn( 1'b1 ), 
    .Aclr( rst ), 
    .DataA( Foreground_In_R ), 
    .DataB( Alpha_In ),     // Compute the Inverse
    .Result( Mult_R1_Results_Out )
);
    
Alpha_Multiplication ComputeUnitE (
    .Clock( clk ), 
    .ClkEn( 1'b1 ), 
    .Aclr( rst ), 
    .DataA( Foreground_In_G ), 
    .DataB( Alpha_In ),     // Compute the Inverse
    .Result( Mult_G1_Results_Out )
);

Alpha_Multiplication ComputeUnitF (
    .Clock( clk ), 
    .ClkEn( 1'b1 ), 
    .Aclr( rst ), 
    .DataA( Foreground_In_B ), 
    .DataB( Alpha_In ),     // Compute the Inverse
    .Result( Mult_B1_Results_Out )
);



assign Combined_Out_R = Mult_R0_Results_Out[15:8] + Mult_R1_Results_Out[15:8];
assign Combined_Out_G = Mult_G0_Results_Out[15:8] + Mult_G1_Results_Out[15:8];
assign Combined_Out_B = Mult_B0_Results_Out[15:8] + Mult_B1_Results_Out[15:8];

endmodule