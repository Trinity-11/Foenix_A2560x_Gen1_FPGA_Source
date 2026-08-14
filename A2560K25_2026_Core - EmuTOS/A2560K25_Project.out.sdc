## Generated SDC file "CFP95179X32.out.sdc"

## Copyright (C) 1991-2014 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.1.4 Build 182 03/12/2014 SJ Web Edition"

## DATE    "Sat Nov 22 00:59:02 2025"

##
## DEVICE  "EP3C120F780C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {OSC_CLK_14_318Mhz_i} -period 69.840 -waveform { 0.000 34.920 } [get_ports {OSC_CLK_14_318Mhz_i}]
create_clock -name {OSC_CLK_22_579Mhz_i} -period 44.288 -waveform { 0.000 22.144 } [get_ports {OSC_CLK_22_579Mhz_i}]
create_clock -name {OSC_CLK_24_576Mhz_i} -period 40.690 -waveform { 0.000 20.340 } [get_ports {OSC_CLK_24_576Mhz_i}]
create_clock -name {OSC_CLK_25_175Mhz_i} -period 39.720 -waveform { 0.000 19.860 } [get_ports {OSC_CLK_25_175Mhz_i}]
create_clock -name {OSC_CLK_33_333Mhz_i} -period 30.000 -waveform { 0.000 15.000 } [get_ports {OSC_CLK_33_333Mhz_i}]
create_clock -name {OSC_CLK_40_000Mhz_A_i} -period 25.000 -waveform { 0.000 12.500 } [get_ports {OSC_CLK_40_000Mhz_A_i}]
create_clock -name {OSC_CLK_40_000Mhz_B_i} -period 25.000 -waveform { 0.000 12.500 } [get_ports {OSC_CLK_40_000Mhz_B_i}]
create_clock -name {OSC_CLK_65_000Mhz_i} -period 15.384 -waveform { 0.000 7.692 } [get_ports {OSC_CLK_65_000Mhz_i}]
create_clock -name {OSC_CLK_80_000Mhz_i} -period 12.500 -waveform { 0.000 6.250 } [get_ports {OSC_CLK_80_000Mhz_i}]


#**************************************************************
# Create Generated Clock
#**************************************************************
create_generated_clock -name {Clk24} -source [get_pins {PLL_SDCard_Debug_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 3 -divide_by 10 -master_clock {OSC_CLK_80_000Mhz_i} [get_pins {PLL_SDCard_Debug_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {Sys133Mhz} -source [get_pins {PLL_SDCard_Debug_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 5 -divide_by 4 -master_clock {OSC_CLK_80_000Mhz_i} [get_pins {PLL_SDCard_Debug_inst|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {Clk40VID_A} -source [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {OSC_CLK_40_000Mhz_A_i} [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {Clk20VID_A} -source [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 2 -master_clock {OSC_CLK_40_000Mhz_A_i} [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {Clk40VID_B} -source [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {OSC_CLK_40_000Mhz_A_i} [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {CLK358} -source [get_nets {OSC_CLK_14_318Mhz_i~input}] -divide_by 4 -master_clock {OSC_CLK_14_318Mhz_i} [get_registers {Clk3_58Mhz[1]}] 
create_generated_clock -name {Clk65VID_A} -source [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {OSC_CLK_65_000Mhz_i} [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {Clk33VID_A} -source [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 2 -master_clock {OSC_CLK_65_000Mhz_i} [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {Clk65VID_B} -source [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|inclk[1]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {OSC_CLK_65_000Mhz_i} [get_pins {VICKYIII_TOP_LEVEL|Channel_A_Top|VIDEO_PLL_A|altpll_component|auto_generated|pll1|clk[2]}] 

create_generated_clock -name {CLK66MHz} -source [get_nets {PLL_SDCard_Debug_inst|altpll_component|auto_generated|wire_pll1_clk[1]}] -divide_by 2 -master_clock {Sys133Mhz} [get_nets {MainCPU_Module|ClockDivide[0]}] 
create_generated_clock -name {CLK33MHz} -source [get_nets {PLL_SDCard_Debug_inst|altpll_component|auto_generated|wire_pll1_clk[1]}] -divide_by 4 -master_clock {Sys133Mhz} [get_nets {MainCPU_Module|ClockDivide[1]}] 
#create_generated_clock -name {CLK99MHz} -source [get_nets {PLL_SDCard_Debug_inst|altpll_component|auto_generated|wire_pll1_clk[3]}] -divide_by 2 -master_clock {Clk199Mhz} [get_registers {Clk099_B}] 
create_generated_clock -name {CLK108Mhz} -source [get_ports {OSC_CLK_40_000Mhz_B_i}] -duty_cycle 50.000 -multiply_by 1 -master_clock {OSC_CLK_40_000Mhz_B_i} [get_nets {PLL_40Mhz_108Mhz_inst|altpll_component|auto_generated|wire_pll1_clk[0]}] 

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {CLK33MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {CLK33MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {CLK66MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {CLK66MHz}]  0.030   
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {CLK358}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {CLK358}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {CLK358}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {CLK358}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {Clk20VID_A}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {Clk20VID_A}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {Clk40VID_A}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {Clk40VID_A}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {Clk24}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {Clk24}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_80_000Mhz_i}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_80_000Mhz_i}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_80_000Mhz_i}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_80_000Mhz_i}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_33_333Mhz_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_33_333Mhz_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_33_333Mhz_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_33_333Mhz_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_25_175Mhz_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_25_175Mhz_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_25_175Mhz_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_25_175Mhz_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_24_576Mhz_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_24_576Mhz_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_24_576Mhz_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_24_576Mhz_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_14_318Mhz_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_14_318Mhz_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_14_318Mhz_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_14_318Mhz_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_22_579Mhz_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_22_579Mhz_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_22_579Mhz_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_22_579Mhz_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {CLK33MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {CLK33MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {CLK66MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {CLK66MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {CLK358}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {CLK358}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {CLK358}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {CLK358}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {Clk20VID_A}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {Clk20VID_A}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {Clk40VID_A}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {Clk40VID_A}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {Clk24}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {Clk24}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_80_000Mhz_i}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_80_000Mhz_i}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_80_000Mhz_i}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_80_000Mhz_i}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_33_333Mhz_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_33_333Mhz_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_33_333Mhz_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_33_333Mhz_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_25_175Mhz_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_25_175Mhz_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_25_175Mhz_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_25_175Mhz_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_24_576Mhz_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_24_576Mhz_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_24_576Mhz_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_24_576Mhz_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_14_318Mhz_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_14_318Mhz_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_14_318Mhz_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_14_318Mhz_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_22_579Mhz_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_22_579Mhz_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_22_579Mhz_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_22_579Mhz_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK66MHz}] -rise_to [get_clocks {CLK33MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLK66MHz}] -fall_to [get_clocks {CLK33MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLK66MHz}] -rise_to [get_clocks {CLK66MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLK66MHz}] -fall_to [get_clocks {CLK66MHz}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLK66MHz}] -rise_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK66MHz}] -fall_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK66MHz}] -rise_to [get_clocks {CLK33MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLK66MHz}] -fall_to [get_clocks {CLK33MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLK66MHz}] -rise_to [get_clocks {CLK66MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLK66MHz}] -fall_to [get_clocks {CLK66MHz}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLK66MHz}] -rise_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK66MHz}] -fall_to [get_clocks {Sys133Mhz}]  0.020     
set_clock_uncertainty -rise_from [get_clocks {CLK358}] -rise_to [get_clocks {CLK33MHz}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK358}] -rise_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK358}] -fall_to [get_clocks {CLK33MHz}] -setup 0.090  
set_clock_uncertainty -rise_from [get_clocks {CLK358}] -fall_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK358}] -rise_to [get_clocks {CLK358}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLK358}] -fall_to [get_clocks {CLK358}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {CLK358}] -rise_to [get_clocks {OSC_CLK_14_318Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK358}] -fall_to [get_clocks {OSC_CLK_14_318Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK358}] -rise_to [get_clocks {CLK33MHz}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK358}] -rise_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK358}] -fall_to [get_clocks {CLK33MHz}] -setup 0.090  
set_clock_uncertainty -fall_from [get_clocks {CLK358}] -fall_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK358}] -rise_to [get_clocks {CLK358}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLK358}] -fall_to [get_clocks {CLK358}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {CLK358}] -rise_to [get_clocks {OSC_CLK_14_318Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK358}] -fall_to [get_clocks {OSC_CLK_14_318Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_B}] -rise_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_B}] -fall_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_B}] -rise_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_B}] -fall_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_B}] -rise_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_B}] -fall_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_B}] -rise_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_B}] -fall_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {Clk20VID_A}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {Clk20VID_A}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {Clk20VID_A}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {Clk20VID_A}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {Clk20VID_A}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {Clk20VID_A}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {Clk40VID_B}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {Clk20VID_A}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {Clk20VID_A}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {Clk40VID_A}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Sys133Mhz}] -rise_to [get_clocks {CLK66MHz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Sys133Mhz}] -fall_to [get_clocks {CLK66MHz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Sys133Mhz}] -rise_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Sys133Mhz}] -fall_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Sys133Mhz}] -rise_to [get_clocks {CLK66MHz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Sys133Mhz}] -fall_to [get_clocks {CLK66MHz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Sys133Mhz}] -rise_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Sys133Mhz}] -fall_to [get_clocks {Sys133Mhz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk24}] -rise_to [get_clocks {CLK33MHz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk24}] -fall_to [get_clocks {CLK33MHz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk24}] -rise_to [get_clocks {Clk24}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {Clk24}] -fall_to [get_clocks {Clk24}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk24}] -rise_to [get_clocks {CLK33MHz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk24}] -fall_to [get_clocks {CLK33MHz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk24}] -rise_to [get_clocks {Clk24}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {Clk24}] -fall_to [get_clocks {Clk24}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_80_000Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_80_000Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_80_000Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -setup 0.060  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_80_000Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_80_000Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_80_000Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -hold 0.090  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_80_000Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -setup 0.060  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_80_000Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -hold 0.090  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_33_333Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_33_333Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_33_333Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_33_333Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_33_333Mhz_i}] -rise_to [get_clocks {OSC_CLK_33_333Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_33_333Mhz_i}] -fall_to [get_clocks {OSC_CLK_33_333Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_33_333Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_33_333Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_33_333Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_33_333Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_33_333Mhz_i}] -rise_to [get_clocks {OSC_CLK_33_333Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_33_333Mhz_i}] -fall_to [get_clocks {OSC_CLK_33_333Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_25_175Mhz_i}] -rise_to [get_clocks {OSC_CLK_25_175Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_25_175Mhz_i}] -fall_to [get_clocks {OSC_CLK_25_175Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_25_175Mhz_i}] -rise_to [get_clocks {OSC_CLK_25_175Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_25_175Mhz_i}] -fall_to [get_clocks {OSC_CLK_25_175Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_24_576Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_24_576Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_24_576Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_24_576Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_24_576Mhz_i}] -rise_to [get_clocks {OSC_CLK_24_576Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_24_576Mhz_i}] -fall_to [get_clocks {OSC_CLK_24_576Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_24_576Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_24_576Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_24_576Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_24_576Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_24_576Mhz_i}] -rise_to [get_clocks {OSC_CLK_24_576Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_24_576Mhz_i}] -fall_to [get_clocks {OSC_CLK_24_576Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_14_318Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_14_318Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_14_318Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_14_318Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_14_318Mhz_i}] -rise_to [get_clocks {CLK358}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_14_318Mhz_i}] -fall_to [get_clocks {CLK358}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_14_318Mhz_i}] -rise_to [get_clocks {OSC_CLK_14_318Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_14_318Mhz_i}] -fall_to [get_clocks {OSC_CLK_14_318Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_14_318Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_14_318Mhz_i}] -rise_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_14_318Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -setup 0.080  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_14_318Mhz_i}] -fall_to [get_clocks {CLK33MHz}] -hold 0.110  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_14_318Mhz_i}] -rise_to [get_clocks {CLK358}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_14_318Mhz_i}] -fall_to [get_clocks {CLK358}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_14_318Mhz_i}] -rise_to [get_clocks {OSC_CLK_14_318Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_14_318Mhz_i}] -fall_to [get_clocks {OSC_CLK_14_318Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_22_579Mhz_i}] -rise_to [get_clocks {OSC_CLK_22_579Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_22_579Mhz_i}] -fall_to [get_clocks {OSC_CLK_22_579Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_22_579Mhz_i}] -rise_to [get_clocks {OSC_CLK_22_579Mhz_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_22_579Mhz_i}] -fall_to [get_clocks {OSC_CLK_22_579Mhz_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK108Mhz}] -rise_to [get_clocks {CLK108Mhz}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLK108Mhz}] -fall_to [get_clocks {CLK108Mhz}]  0.020   
set_clock_uncertainty -rise_from [get_clocks {CLK108Mhz}] -rise_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {CLK108Mhz}] -fall_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {CLK108Mhz}] -rise_to [get_clocks {CLK108Mhz}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLK108Mhz}] -fall_to [get_clocks {CLK108Mhz}]  0.020   
set_clock_uncertainty -fall_from [get_clocks {CLK108Mhz}] -rise_to [get_clocks {CLK33MHz}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {CLK108Mhz}] -fall_to [get_clocks {CLK33MHz}]  0.160   
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {CLK108Mhz}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {CLK108Mhz}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.110  
set_clock_uncertainty -rise_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {CLK108Mhz}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {CLK108Mhz}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.110  
set_clock_uncertainty -fall_from [get_clocks {CLK33MHz}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {Clk20VID_A}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {Clk40VID_A}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}] -hold 0.080  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_40_000Mhz_A_i}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {OSC_CLK_40_000Mhz_A_i}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_40_000Mhz_A_i}] -rise_to [get_clocks {OSC_CLK_40_000Mhz_A_i}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {OSC_CLK_40_000Mhz_A_i}] -fall_to [get_clocks {OSC_CLK_40_000Mhz_A_i}]  0.020   


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  2.000 [get_ports {CPU_A_io[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  2.000 [get_ports {CPU_D_io[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  2.000 [get_ports {LOCAL_MEM_SRAM_BEn_o[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  2.000 [get_ports {LOCAL_MEM_SRAM_CS0n_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  2.000 [get_ports {LOCAL_MEM_SRAM_CS1n_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  2.000 [get_ports {LOCAL_MEM_SRAM_OEn_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  2.000 [get_ports {LOCAL_MEM_SRAM_WEn_o}]

#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[0]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[1]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[2]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[3]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[4]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[5]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[6]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[7]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[8]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[9]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[10]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[11]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_A_o[12]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_BA0_o}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_BA1_o}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_CASn_o}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_CS0n_o}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_CKE_o}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_CLK_o}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQM_o[0]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQM_o[1]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQM_o[2]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQM_o[3]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_RASn_o}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_WEn_o}]

#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[0]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[1]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[2]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[3]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[4]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[5]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[6]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[7]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[8]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[9]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[10]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[11]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[12]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[13]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[14]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[15]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[16]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[17]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[18]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[19]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[20]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[21]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[22]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[23]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[24]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[25]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[26]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[27]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[28]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[29]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[30]}]
#set_output_delay -add_delay  -clock [get_clocks {Sys133Mhz}]  1.000 [get_ports {SYSRAM_DQ_io[31]}]


#66 - BUS A
set_output_delay -add_delay  -clock [get_clocks {CLK66MHz}]  1.500 [get_ports {VRAM_A_DQ_io[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK66MHz}]  1.500 [get_ports {VRAM_A_Addy_o[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK66MHz}]  1.500 [get_ports {VRAM_A_OEn_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK66MHz}]  1.500 [get_ports {VRAM_A_WEn_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK66MHz}]  1.500 [get_ports {VRAM_A_BEn_o[*]}]
#33 - BUS A
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  3.000 [get_ports {VRAM_A_DQ_io[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  3.000 [get_ports {VRAM_A_Addy_o[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  3.000 [get_ports {VRAM_A_OEn_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  3.000 [get_ports {VRAM_A_WEn_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  3.000 [get_ports {VRAM_A_BEn_o[*]}]

#66 - BUS B
set_output_delay -add_delay  -clock [get_clocks {CLK66MHz}]  1.500 [get_ports {VRAM_B_DQ_io[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK66MHz}]  1.500 [get_ports {VRAM_B_Addy_o[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK66MHz}]  1.500 [get_ports {VRAM_B_OEn_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK66MHz}]  1.500 [get_ports {VRAM_B_WEn_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK66MHz}]  1.500 [get_ports {VRAM_B_BEn_o[*]}]
#33 - BUS B
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  3.000 [get_ports {VRAM_B_DQ_io[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  3.000 [get_ports {VRAM_B_Addy_o[*]}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  3.000 [get_ports {VRAM_B_OEn_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  3.000 [get_ports {VRAM_B_WEn_o}]
set_output_delay -add_delay  -clock [get_clocks {CLK33MHz}]  3.000 [get_ports {VRAM_B_BEn_o[*]}]

#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -physically_exclusive -group [get_clocks {CLK33MHz}] -group [get_clocks {CLK66MHz}]

#**************************************************************
# Set False Path
#**************************************************************
#New New Stuff
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {CLK108Mhz}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {Sys133Mhz}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {CLK66MHz}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {OSC_CLK_80_000Mhz_i}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {OSC_CLK_24_576Mhz_i}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {OSC_CLK_40_000Mhz_A_i}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {OSC_CLK_14_318Mhz_i}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {OSC_CLK_22_579Mhz_i}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {OSC_CLK_25_175Mhz_i}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {CLK358}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {Clk40VID_A}]
set_false_path  -from  [get_clocks {CLK33MHz}]  -to  [get_clocks {Clk24}]
set_false_path  -from  [get_clocks {Clk40VID_A}]  -to  [get_clocks {CLK33MHz}]
set_false_path  -from  [get_clocks {Clk24}]  -to  [get_clocks {CLK66MHz}]
set_false_path  -from  [get_clocks {Clk24}]  -to  [get_clocks {CLK33MHz}]
set_false_path  -from  [get_clocks {CLK66MHz}]  -to  [get_clocks {Sys133Mhz}]
set_false_path  -from  [get_clocks {OSC_CLK_14_318Mhz_i}]  -to  [get_clocks {OSC_CLK_24_576Mhz_i}]
set_false_path -from [get_ports {COLD_RESETn_io}] 

#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_A_Top:Channel_A_Top|Vicky_Register_Block:Vicky_Reg_Blk_A|VICKY_MASTER_REG*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_A_Top:Channel_A_Top|Vicky_Register_Block:Vicky_Reg_Blk_A|Master_Control_Reg_VidClk*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_A_Top:Channel_A_Top|Vicky_Register_Block:Vicky_Reg_Blk_A|Border_CTRL_L_Reg_VidClk*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_A_Top:Channel_A_Top|Vicky_Register_Block:Vicky_Reg_Blk_A|Border_CTRL_H_Reg_VidClk*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_A_Top:Channel_A_Top|Vicky_Register_Block:Vicky_Reg_Blk_A|Cursor_CTRL_L_Reg_VidClk*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_A_Top:Channel_A_Top|Vicky_Register_Block:Vicky_Reg_Blk_A|Cursor_CTRL_H_Reg_VidClk*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|VICKY_MASTER_REG*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|Master_Control_Reg_VidClk*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|Border_CTRL_L_Reg_VidClk*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|Border_CTRL_H_Reg_VidClk*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|Cursor_CTRL_L_Reg_VidClk*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|Cursor_CTRL_H_Reg_VidClk*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|ReSync_VideoMode*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|ReSync_DisableVideo*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|ReSync_Bitmap_Enable*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|ReSync_TileMap_Enable*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|Vicky_Register_Block:Vicky_Reg_Blk_B|ReSync_Sprite_Enable*}] 
#set_false_path -from [get_keepers {BEATRIX_TOP:BEATRIX_TOP_LEVEL|CPU_Interface_2_AudioDAC:CPU_2_DAC48|Registers*}] 
#set_false_path -from [get_keepers {BEATRIX_TOP:BEATRIX_TOP_LEVEL|SoundChips2DAC_Interface:SOUNDCHIP_INTERFACE|sid_top:sid_6581_Left|sid_mixer:mix|mixed_out*}] 
#set_false_path -from [get_keepers {BEATRIX_TOP:BEATRIX_TOP_LEVEL|SoundChips2DAC_Interface:SOUNDCHIP_INTERFACE|sid_top:sid_6581_Right|sid_mixer:mix|mixed_out*}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[0][3]}] -to [get_keepers {VICKYIII_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[2][3]}]
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[0][3]}] -to [get_keepers {VICKYIII_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[2][2]}]
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[0][3]}] -to [get_keepers {VICKYIII_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[2][1]}]
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[1][3]}] -to [get_keepers {VICKYIII_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[2][3]}]
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[1][3]}] -to [get_keepers {VICKYIII_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[2][2]}]
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[1][3]}] -to [get_keepers {VICKYIII_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VGE_MasterController_Module:VGE_MasterCTRL_Module_B|BitMapRegisterFile:BM_Register_File|BITMAP_CTRL1_REG01_SYNC_200[2][1]}]
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_A_Top:Channel_A_Top|VideoTimingGenerator_A:VideoTimingGen_A|SOF_PULSE[7]}] -to [get_keepers {GABE_Top:GABE_TOP_LEVEL|INT_CONTROLLER:IRQ_CTRL32s|lirq0[0]}]
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_A_Top:Channel_A_Top|VideoTimingGenerator_A:VideoTimingGen_A|SOF_PULSE[7]}] -to [get_keepers {GABE_Top:GABE_TOP_LEVEL|A2560K_Keyboard_Module:A2560K_Keyboard|Keyboard_RGB_Matrix_Module:KBD_LED_RGB|SOF_Sync}]
#set_false_path -from [get_keepers {GABE_Top:GABE_TOP_LEVEL|GABE_CTRL_Reg:GABE_CTRL|SoftReset[31]}] 
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VICKY_III_Reset_Module:Channel_B_Reset|VideoModeReset}] -to [get_keepers {VICKYIII_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VICKY_III_Reset_Module:Channel_B_Reset|VideoModeReset_200Mhz_Meta[0]}]
#set_false_path -from [get_keepers {VICKYIII_NEW_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VICKY_III_Reset_Module:Channel_B_Reset|VideoModeReset}] -to [get_keepers {VICKYIII_TOP:VICKYIII_TOP_LEVEL|VICKY_III_Channel_B_NEW_Top:Channel_B_Top|VICKY_III_Reset_Module:Channel_B_Reset|VideoModeReset_100Mhz_Meta[0]}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

