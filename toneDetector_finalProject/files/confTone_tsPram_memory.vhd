----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:47:04 01/21/2015 
-- Design Name: 
-- Module Name:    confTone_tsPram_memory - Behavioral 
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
-- use IEEE.std_logic_arith.all;
use work.toneDetectorPackage.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tsParam_memory is
port
( 
	RESET 							: in  STD_LOGIC;
  CLOCK 							: in  STD_LOGIC;

  RLS_TIME_SLOT				: in STD_LOGIC;
  RLS_TIME_SLOT_INDEX	: in integer range 0 to NUM_CH-1;
  -- RLS_TIME_SLOT_ACK		: out std_logic;

  WR_ENABLE 					: in  STD_LOGIC;
  DATA_IN 						: in  unsigned (WORD_SIZE-1 downto 0);
  DATA_OUT 						: out  unsigned (WORD_SIZE-1 downto 0);
  ADDR								: in integer range 0 to TS_IN_PARAM_SIZE-1
);
end tsParam_memory;

architecture tsParam_memory of tsParam_memory is
	signal TS_IN_PARAM					: TS_IN_PARAM_TYPE;
	signal CHNL									: integer range 0 to NUM_CH-1;



begin

	CHNL <= RLS_TIME_SLOT_INDEX;

-- process (CLOCK)
process (CLOCK,RESET)
begin
	if (CLOCK'event and CLOCK='1') then

		if (RESET = '1') then
			TS_IN_PARAM <= (others => x"0000");

			for i in 0 to NUM_CH-1 loop
				TS_IN_PARAM(i*NUM_PAR) <= x"ffff";				
			end loop ;


		elsif (RLS_TIME_SLOT='1') then		
			-- RLS_TIME_SLOT_ACK <= '1';

			TS_IN_PARAM( (CHNL*NUM_PAR)+1 
				to ( (CHNL+1)*NUM_PAR) - 1)  <= (others => x"0000");
			
			TS_IN_PARAM( CHNL*NUM_PAR ) <= x"ffff";

		elsif (WR_ENABLE='1') then
			TS_IN_PARAM(ADDR) <= DATA_IN;
		end if;

	end if;
end process;

DATA_OUT <= TS_IN_PARAM(ADDR);


end tsParam_memory;

