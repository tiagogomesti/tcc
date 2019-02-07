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

	-- ioFrameControl						: in ioFrameControlType;
	in_FrameControl					: in std_logic_vector(0 to NUM_CH-1);
	out_FrameControl				: in std_logic_vector(0 to NUM_CH-1);

	ioFrameNumFile	 					: in ioFrameNumFileType;

	-- OUT_FRAME									: out PCM_TYPE;
	OUT_FRAME									: out ARRAY_NUMCH_PCMTYPE;
	CHANNEL_ID								: out natural range 0 to NUM_CH-1

	

);


end tdmSwitch_tb;

architecture tdmSwitch_tb of tdmSwitch_tb is
	
	signal timeSlots					: ARRAY_NUMCH_PCMTYPE;
	signal CHANNEL_ID_s				: natural range 0 to NUM_CH-1;

begin


fileInstances: for i in 0 to NUM_CH-1 generate
	fileReader: entity work.readFile(readFileValidation)
	generic map( channel_index => i)
	port map
	(
		RST					=> RST,
		CLK					=> CLK_8KHz,

		start_read	=> in_FrameControl(i),
		stop_read		=> out_FrameControl(i),

		numFile			=> ioFrameNumFile(i),
	
		FRAME				=> timeSlots(i)
	);
end generate fileInstances;

OUT_FRAME <= timeSlots;


	

end tdmSwitch_tb;

