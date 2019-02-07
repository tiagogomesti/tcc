----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:59:18 02/18/2015 
-- Design Name: 
-- Module Name:    command_tb - Behavioral 
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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.toneDetectorPackage.all;



entity command_tb is
port
(
	RESET								: in std_logic;
	CLK									: in std_logic;

	CMD_TRIGGER					: in std_logic;
	WAIT_CMD						: out std_logic;

	TIMESLOT						: in natural range 0 to NUM_CH-1;
	MAX_MIN_PULSE				: in unsigned (WORD_SIZE-1 downto 0);
	MAX_MIN_PAUSE				: in unsigned (WORD_SIZE-1 downto 0);
	ATTENUATION_CADENCE	: in unsigned (WORD_SIZE-1 downto 0);
	THRESHOLD						: in unsigned (WORD_SIZE-1 downto 0);
	COEFF1							: in unsigned (WORD_SIZE-1 downto 0);
	COEFF2							: in unsigned (WORD_SIZE-1 downto 0);

	CMD_TX_DATA					: out unsigned (WORD_SIZE-1 downto 0);
	CMD_WORD_INDEX			: out integer range 0 to 6;
	WRITE_CMD_BUFFER		: out	std_logic;
	CMD_TX							: out std_logic;
	CMD_TX_ACK					: in std_logic
);

end command_tb;

architecture Behavioral of command_tb is

begin


	process 
	begin

	WAIT_CMD <= '1';	
	

	wait until CMD_TRIGGER = '1';
	
	WAIT_CMD <= '0';	
	wait for CLOCK_PERIOD;

	cmd_write_proc_tb(RESET, CLK,
										TIMESLOT,							
										MAX_MIN_PULSE, MAX_MIN_PAUSE,				
										ATTENUATION_CADENCE, THRESHOLD,						
										COEFF1,	COEFF2,								
										CMD_TX_DATA,				
										CMD_WORD_INDEX,		
										WRITE_CMD_BUFFER,
										CMD_TX,						
										CMD_TX_ACK);


	WAIT_CMD <= '1';	

end process;



end Behavioral;


	-- cmd_write_proc_tb(1,
	-- 									PABX_TONE,
	-- 									RESET,
	-- 									CLK,
	-- 									CMD_TX_DATA,				
	-- 									CMD_WORD_INDEX,		
	-- 									WRITE_CMD_BUFFER	,
	-- 									CMD_TX,						
	-- 									CMD_TX_ACK);

	-- cmd_write_proc_tb(2,
	-- 									FAX_TONE,
	-- 									RESET,
	-- 									CLK,
	-- 									CMD_TX_DATA,				
	-- 									CMD_WORD_INDEX,		
	-- 									WRITE_CMD_BUFFER	,
	-- 									CMD_TX,						
	-- 									CMD_TX_ACK);

	-- cmd_write_proc_tb(3,
	-- 									BUSY_TONE,
	-- 									RESET,
	-- 									CLK,
	-- 									CMD_TX_DATA,				
	-- 									CMD_WORD_INDEX,		
	-- 									WRITE_CMD_BUFFER	,
	-- 									CMD_TX,						
	-- 									CMD_TX_ACK);

	-- cmd_write_proc_tb(4,
	-- 									DIAL_TONE,
	-- 									RESET,
	-- 									CLK,
	-- 									CMD_TX_DATA,				
	-- 									CMD_WORD_INDEX,		
	-- 									WRITE_CMD_BUFFER	,
	-- 									CMD_TX,						
	-- 									CMD_TX_ACK);

	-- cmd_write_proc_tb(5,
	-- 									SPECIAL_TONE,
	-- 									RESET,
	-- 									CLK,
	-- 									CMD_TX_DATA,				
	-- 									CMD_WORD_INDEX,		
	-- 									WRITE_CMD_BUFFER	,
	-- 									CMD_TX,						
	-- 									CMD_TX_ACK);

	-- cmd_write_proc_tb(6,
	-- 									FAX_TONE,
	-- 									RESET,
	-- 									CLK,
	-- 									CMD_TX_DATA,				
	-- 									CMD_WORD_INDEX,		
	-- 									WRITE_CMD_BUFFER	,
	-- 									CMD_TX,						
	-- 									CMD_TX_ACK);

	-- 	cmd_write_proc_tb(7,
	-- 									BUSY_TONE,
	-- 									RESET,
	-- 									CLK,
	-- 									CMD_TX_DATA,				
	-- 									CMD_WORD_INDEX,		
	-- 									WRITE_CMD_BUFFER	,
	-- 									CMD_TX,						
	-- 									CMD_TX_ACK);

		-- CMD_TX <= '1'; 

		-- wait until CMD_TX_ACK = '1';

		-- wait for CLOCK_PERIOD;

		-- CMD_WORD_INDEX <= 0;
		-- wait for CLOCK_PERIOD;
		-- CMD_TX_DATA	<= x"0000";
		-- WRITE_CMD_BUFFER <= '1';

		-- CMD_WORD_INDEX <= 1;
		-- wait for CLOCK_PERIOD;
		-- -- CMD_TX_DATA	<= x"0025";
		-- CMD_TX_DATA	<= x"0005";


		-- CMD_WORD_INDEX <= 2;
		-- wait for CLOCK_PERIOD;
		-- CMD_TX_DATA	<= x"0000";

		-- CMD_WORD_INDEX <= 3;
		-- wait for CLOCK_PERIOD;
		-- CMD_TX_DATA	<= x"0300";

		-- CMD_WORD_INDEX <= 4;
		-- wait for CLOCK_PERIOD;
		-- CMD_TX_DATA	<= x"0015";

		-- CMD_WORD_INDEX <= 5;
		-- wait for CLOCK_PERIOD;
		-- CMD_TX_DATA	<= x"7942";

		-- CMD_WORD_INDEX <= 6;
		-- wait for CLOCK_PERIOD;
		-- CMD_TX_DATA	<= x"789a";

		-- wait for CLOCK_PERIOD;

		-- WRITE_CMD_BUFFER <= '0';
		-- CMD_TX <= '0';


		-- wait for CLOCK_PERIOD;
		-- wait for CLOCK_PERIOD;


--=======================================--
--      		 1 - DIAL TONE               --
--=======================================--

-- 		CMD_TX <= '1'; 

-- 		wait until CMD_TX_ACK = '1';

-- 		wait for CLOCK_PERIOD;

-- 		CMD_WORD_INDEX <= 0;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0001";
-- 		WRITE_CMD_BUFFER <= '1';

-- 		CMD_WORD_INDEX <= 1;
-- 		wait for CLOCK_PERIOD;
-- 		-- CMD_TX_DATA	<= x"0025";
-- 		CMD_TX_DATA	<= x"0005";


-- 		CMD_WORD_INDEX <= 2;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0000";

-- 		CMD_WORD_INDEX <= 3;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0300";

-- 		CMD_WORD_INDEX <= 4;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0015";

-- 		CMD_WORD_INDEX <= 5;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"7942";

-- 		CMD_WORD_INDEX <= 6;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"789a";

-- 		CMD_TX <= '0';

-- 		wait for CLOCK_PERIOD;
-- 		wait for CLOCK_PERIOD;

-- --=======================================--
-- --      		 2 - DIAL TONE               --
-- --=======================================--

-- 		CMD_TX <= '1'; 

-- 		wait until CMD_TX_ACK = '1';

-- 		wait for CLOCK_PERIOD;

-- 		CMD_WORD_INDEX <= 0;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0002";
-- 		WRITE_CMD_BUFFER <= '1';

-- 		CMD_WORD_INDEX <= 1;
-- 		wait for CLOCK_PERIOD;
-- 		-- CMD_TX_DATA	<= x"0025";
-- 		CMD_TX_DATA	<= x"0005";


-- 		CMD_WORD_INDEX <= 2;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0000";

-- 		CMD_WORD_INDEX <= 3;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0300";

-- 		CMD_WORD_INDEX <= 4;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0015";

-- 		CMD_WORD_INDEX <= 5;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"7942";

-- 		CMD_WORD_INDEX <= 6;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"789a";

-- 		CMD_TX <= '0';

-- 		wait for CLOCK_PERIOD;
-- 		wait for CLOCK_PERIOD;

-- --=======================================--
-- --      		 3 - DIAL TONE               --
-- --=======================================--

-- 		CMD_TX <= '1'; 

-- 		wait until CMD_TX_ACK = '1';

-- 		wait for CLOCK_PERIOD;

-- 		CMD_WORD_INDEX <= 0;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0003";
-- 		WRITE_CMD_BUFFER <= '1';

-- 		CMD_WORD_INDEX <= 1;
-- 		wait for CLOCK_PERIOD;
-- 		-- CMD_TX_DATA	<= x"0025";
-- 		CMD_TX_DATA	<= x"0005";


-- 		CMD_WORD_INDEX <= 2;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0000";

-- 		CMD_WORD_INDEX <= 3;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0300";

-- 		CMD_WORD_INDEX <= 4;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0015";

-- 		CMD_WORD_INDEX <= 5;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"7942";

-- 		CMD_WORD_INDEX <= 6;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"789a";

-- 		CMD_TX <= '0';

-- 		wait for CLOCK_PERIOD;
-- 		wait for CLOCK_PERIOD;

-- --=======================================--
-- --      		 4 - DIAL TONE               --
-- --=======================================--

-- 		CMD_TX <= '1'; 

-- 		wait until CMD_TX_ACK = '1';

-- 		wait for CLOCK_PERIOD;

-- 		CMD_WORD_INDEX <= 0;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0004";
-- 		WRITE_CMD_BUFFER <= '1';

-- 		CMD_WORD_INDEX <= 1;
-- 		wait for CLOCK_PERIOD;
-- 		-- CMD_TX_DATA	<= x"0025";
-- 		CMD_TX_DATA	<= x"0005";


-- 		CMD_WORD_INDEX <= 2;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0000";

-- 		CMD_WORD_INDEX <= 3;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0300";

-- 		CMD_WORD_INDEX <= 4;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0015";

-- 		CMD_WORD_INDEX <= 5;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"7942";

-- 		CMD_WORD_INDEX <= 6;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"789a";

-- 		CMD_TX <= '0';

-- 		wait for CLOCK_PERIOD;
-- 		wait for CLOCK_PERIOD;


-- --=======================================--
-- --      		 5 - DIAL TONE               --
-- --=======================================--

-- 		CMD_TX <= '1'; 

-- 		wait until CMD_TX_ACK = '1';

-- 		wait for CLOCK_PERIOD;

-- 		CMD_WORD_INDEX <= 0;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0005";
-- 		WRITE_CMD_BUFFER <= '1';

-- 		CMD_WORD_INDEX <= 1;
-- 		wait for CLOCK_PERIOD;
-- 		-- CMD_TX_DATA	<= x"0025";
-- 		CMD_TX_DATA	<= x"0005";


-- 		CMD_WORD_INDEX <= 2;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0000";

-- 		CMD_WORD_INDEX <= 3;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0300";

-- 		CMD_WORD_INDEX <= 4;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0015";

-- 		CMD_WORD_INDEX <= 5;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"7942";

-- 		CMD_WORD_INDEX <= 6;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"789a";

-- 		CMD_TX <= '0';

-- 		wait for CLOCK_PERIOD;
-- 		wait for CLOCK_PERIOD;


-- --=======================================--
-- --      		 6 - DIAL TONE               --
-- --=======================================--

-- 		CMD_TX <= '1'; 

-- 		wait until CMD_TX_ACK = '1';

-- 		wait for CLOCK_PERIOD;

-- 		CMD_WORD_INDEX <= 0;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0006";
-- 		WRITE_CMD_BUFFER <= '1';

-- 		CMD_WORD_INDEX <= 1;
-- 		wait for CLOCK_PERIOD;
-- 		-- CMD_TX_DATA	<= x"0025";
-- 		CMD_TX_DATA	<= x"0005";


-- 		CMD_WORD_INDEX <= 2;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0000";

-- 		CMD_WORD_INDEX <= 3;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0300";

-- 		CMD_WORD_INDEX <= 4;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0015";

-- 		CMD_WORD_INDEX <= 5;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"7942";

-- 		CMD_WORD_INDEX <= 6;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"789a";

-- 		CMD_TX <= '0';

-- 		wait for CLOCK_PERIOD;
-- 		wait for CLOCK_PERIOD;


-- --=======================================--
-- --      		 7 - BUSY TONE               --
-- --=======================================--

-- 		CMD_TX <= '1'; 

-- 		wait until CMD_TX_ACK = '1';

-- 		wait for CLOCK_PERIOD;

-- 		CMD_WORD_INDEX <= 0;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0007";
-- 		WRITE_CMD_BUFFER <= '1';

-- 		CMD_WORD_INDEX <= 1;
-- 		wait for CLOCK_PERIOD;
-- 		-- CMD_TX_DATA	<= x"0025";
-- 		CMD_TX_DATA	<= x"3214";


-- 		CMD_WORD_INDEX <= 2;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"3214";

-- 		CMD_WORD_INDEX <= 3;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0302";

-- 		CMD_WORD_INDEX <= 4;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0015";

-- 		CMD_WORD_INDEX <= 5;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"7942";

-- 		CMD_WORD_INDEX <= 6;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"789a";

-- 		CMD_TX <= '0';

-- 		wait for CLOCK_PERIOD;
-- 		wait for CLOCK_PERIOD;



-- --=======================================--
-- --      		 7 - DIAL TONE               --
-- --=======================================--

-- 		CMD_TX <= '1'; 

-- 		wait until CMD_TX_ACK = '1';

-- 		wait for CLOCK_PERIOD;

-- 		CMD_WORD_INDEX <= 0;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0007";
-- 		WRITE_CMD_BUFFER <= '1';

-- 		CMD_WORD_INDEX <= 1;
-- 		wait for CLOCK_PERIOD;
-- 		-- CMD_TX_DATA	<= x"0025";
-- 		CMD_TX_DATA	<= x"0005";


-- 		CMD_WORD_INDEX <= 2;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0000";

-- 		CMD_WORD_INDEX <= 3;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0300";

-- 		CMD_WORD_INDEX <= 4;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"0015";

-- 		CMD_WORD_INDEX <= 5;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"7942";

-- 		CMD_WORD_INDEX <= 6;
-- 		wait for CLOCK_PERIOD;
-- 		CMD_TX_DATA	<= x"789a";

-- 		CMD_TX <= '0';

-- 		wait for CLOCK_PERIOD;
-- 		wait for CLOCK_PERIOD;



-- 		wait;


-- 	end process;



-- end Behavioral;

