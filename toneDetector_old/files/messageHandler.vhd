----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:05:49 01/17/2015 
-- Design Name: 
-- Module Name:    messageHandler - Behavioral 
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

entity messageHandler is
port
(
	RST									: in std_logic;
	CLOCK								: in std_logic;

	MSG_RX_DATA					: out unsigned (WORD_SIZE-1 downto 0);
	MSG_RX							: out std_logic;
	MSG_RX_ACK					: in std_logic;

	MSG_TX_DATA					: out unsigned (WORD_SIZE-1 downto 0);
	MSG_TX							: out std_logic;
	MSG_TX_ACK					: in std_logic
);
end messageHandler;

architecture messageHandler of messageHandler is

begin


end messageHandler;

