----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:20:35 02/26/2015 
-- Design Name: 
-- Module Name:    tdmSwitch - tdmSwitch 
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


entity tdmSwitch is
port
(
	-- RST												: in std_logic;
	-- CLK												: in std_logic;	

	IN_FRAME									: in ARRAY_NUMCH_PCMTYPE;
	-- CHANNEL_ID								: in natural range 0 to NUM_CH-1;

	FRAME_DEMUX								: out ARRAY_NUMCH_PCMTYPE
);
end tdmSwitch;

architecture tdmSwitch of tdmSwitch is

begin
	
-- process (RST, CLK, IN_FRAME, CHANNEL_ID) 
	
	FRAME_DEMUX <= IN_FRAME;

-- begin
-- 	if(CLK'event and CLK='1') then
-- 		if (RST='1') then
-- 			FRAME_DEMUX <= (others => x"ea80");

-- 		else
				





	


end tdmSwitch;

