----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:05:49 02/04/2015 
-- Design Name: 
-- Module Name:    cmd_buffer - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cmd_buffer is
Port
( 
	RESET 					: in  STD_LOGIC;
  CLOCK 					: in  STD_LOGIC;

  RLS_CMD_BUFFER	: in STD_LOGIC;

  WR_ENABLE 			: in  STD_LOGIC;
  DATA_IN 				: in  unsigned (WORD_SIZE-1 downto 0);
  DATA_OUT 				: out  unsigned (WORD_SIZE-1 downto 0);
  ADDR						: in integer range 0 to 6
);


end cmd_buffer;

architecture Behavioral of cmd_buffer is
	signal CMD_BUFFER			: CMD_BUFFER_TYPE;

begin


process (CLOCK)
	begin
		if (CLOCK'event and CLOCK='1') then

			if ( RESET = '1' or RLS_CMD_BUFFER='1') then
				CMD_BUFFER <= (others => x"5555");		

			elsif (WR_ENABLE = '1') then
				CMD_BUFFER(ADDR) <= DATA_IN;				
			end if ;

		end if;
	end process;

	DATA_OUT <= CMD_BUFFER(ADDR);
end Behavioral;

