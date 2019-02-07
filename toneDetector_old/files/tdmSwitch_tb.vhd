----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:40:01 02/26/2015 
-- Design Name: 
-- Module Name:    tdmSwitch_tb - tdmSwitch_tb 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.toneDetectorPackage.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tdmSwitch_tb is
port
(
	RST												: in std_logic;
	-- CLK												: in std_logic;	

	CLK_8KHz									: in std_logic;
	clk_tdm										: in std_logic;



	-- OUT_FRAME									: out PCM_TYPE;
	OUT_FRAME									: out ARRAY_NUMCH_PCMTYPE;
	CHANNEL_ID								: out natural range 0 to NUM_CH-1

);


end tdmSwitch_tb;

architecture tdmSwitch_tb of tdmSwitch_tb is
	
	-- constant maxCounter_CLK_8KHz		: natural :=  (CLOCK_PERIOD_8KH/CLOCK_PERIOD)/2;
	-- signal CLK_8KHz									: std_logic;
	-- signal counter_CLK_8KHz					: natural range 1 to maxCounter_CLK_8KHz;

	-- constant maxCounter_clk_tdm			: natural := (CLOCK_PERIOD_TDM/CLOCK_PERIOD)/2;
	-- signal clk_tdm									: std_logic;
	-- signal counter_clk_tdm					: natural range 1 to maxCounter_clk_tdm;


	signal timeSlots					: ARRAY_NUMCH_PCMTYPE;

	signal CHANNEL_ID_s				: natural range 0 to NUM_CH-1;


begin

--*******************************************
--*					Tdm clocks generation				  	*
--*******************************************
-- clk_gen_8KHz : process
-- begin
-- 	CLK_8KHz <= '0';
--   wait for CLOCK_PERIOD_8KH/2;

--   CLK_8KHz <= '1';
--   wait for CLOCK_PERIOD_8KH/2; 
-- end process;

-- clk_gen_8KHz : process(CLK)
-- begin
-- 	if (RST = '1') then
-- 		CLK_8KHz <= '0';
-- 		counter_CLK_8KHz <= 1;


-- 	elsif (CLK'event and CLK='1') then
-- 		if (counter_CLK_8KHz = maxCounter_CLK_8KHz) then
-- 			CLK_8KHz <= not CLK_8KHz;
-- 			counter_CLK_8KHz <= 1;

-- 		else
-- 			counter_CLK_8KHz <= counter_CLK_8KHz+1;

-- 		end if;
-- 	end if;		
-- end process;


-- clk_gen_tdm: process(CLK)
-- begin
-- 	if (RST = '1') then
-- 		clk_tdm <= '0';
-- 		counter_clk_tdm <= 1;


-- 	elsif (CLK'event and CLK='1') then
-- 		if (counter_clk_tdm = maxCounter_clk_tdm) then
-- 			clk_tdm <= not clk_tdm;
-- 			counter_clk_tdm <= 1;

-- 		else
-- 			counter_clk_tdm <= counter_clk_tdm+1;

-- 		end if;
-- 	end if;		

-- end process;




-- clk_gen_tdm: process
-- begin
-- 	clk_tdm <= '0';
--   wait for CLOCK_PERIOD_TDM/2;

--   clk_tdm <= '1';
--   wait for CLOCK_PERIOD_TDM/2; 
-- end process;
--*******************************************
--*******************************************

fileInstances: for i in 0 to NUM_CH-1 generate
	fileReader: entity work.readFile(readFile)
	generic map( channel_index => i)
	port map
	(
		RST			=> RST,
		CLK			=> CLK_8KHz,
	
		FRAME		=> timeSlots(i)
	);
end generate fileInstances;


-- inc_ch_id: process (clk_tdm,RST)
-- begin
-- 	if (clk_tdm'event and clk_tdm='1') then
-- 		if (RST = '1') then
-- 			CHANNEL_ID_s <= 0;			

-- 		else
-- 			if (CHANNEL_ID_s < NUM_CH-1) then
-- 				CHANNEL_ID_s <= CHANNEL_ID_s + 1;		

-- 			else 
-- 				CHANNEL_ID_s <= 0;

-- 			end if;
-- 		end if;
-- 	end if;
-- end process;


-- 	CHANNEL_ID <= CHANNEL_ID_s;
	-- OUT_FRAME <= timeSlots(CHANNEL_ID_s);

	OUT_FRAME <= timeSlots;


	

end tdmSwitch_tb;

