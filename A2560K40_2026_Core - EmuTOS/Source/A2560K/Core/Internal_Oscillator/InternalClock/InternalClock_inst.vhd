	component InternalClock is
		port (
			oscena : in  std_logic := 'X'; -- oscena
			clkout : out std_logic         -- clk
		);
	end component InternalClock;

	u0 : component InternalClock
		port map (
			oscena => CONNECTED_TO_oscena, -- oscena.oscena
			clkout => CONNECTED_TO_clkout  -- clkout.clk
		);

