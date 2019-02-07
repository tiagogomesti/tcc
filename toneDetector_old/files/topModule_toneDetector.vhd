----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:41:14 10/13/2014 
-- Design Name: 
-- Module Name:    topModule_toneDetector - Behavioral 
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.toneDetectorPackage.all;



entity topModule_toneDetector is
end topModule_toneDetector;

architecture topModule_toneDetector of topModule_toneDetector is
  signal GLOBAL_RESET                 : std_logic;
  signal GLOBAL_CLOCK                 : std_logic;

  signal TONE_DET_CMD_RX_DATA_S       : unsigned (WORD_SIZE-1 downto 0);
  signal CMD_WORD_INDEX_S             : integer range 0 to 6;
  signal WRITE_CMD_BUFFER_S           : std_logic;
  signal TONE_DET_CMD_RX_S            : std_logic;
  signal TONE_DET_CMD_RX_ACK_S        : std_logic;

  signal TONE_DET_MSG_TX_DATA_S       : unsigned (WORD_SIZE-1 downto 0);
  signal TONE_DET_MSG_TX_S            : std_logic;
  signal TONE_DET_MSG_TX_ACK_S        : std_logic;

  signal TONE_DET_TDM_FRAME_S         : ARRAY_NUMCH_PCMTYPE;
  signal TONE_DET_CHANNEL_ID_S        : natural range 0 to NUM_CH-1;

--********************************************
-- Falta colocar o sinais do testBench....   *
--********************************************
  constant maxCounter_CLK_8KHz    : natural :=  (CLOCK_PERIOD_8KH/CLOCK_PERIOD)/2;
  signal CLK_8KHz                 : std_logic := '1';
  signal counter_CLK_8KHz         : natural range 1 to maxCounter_CLK_8KHz := 1;

  constant maxCounter_clk_tdm     : natural := (CLOCK_PERIOD_TDM/CLOCK_PERIOD)/2;
  signal clk_tdm                  : std_logic := '0';
  signal counter_clk_tdm          : natural range 1 to maxCounter_clk_tdm := 1;

begin

--==========================================================--
--=               Reset and Clock generation               =--
--==========================================================--
  resetGeneration: process
  begin
    GLOBAL_RESET <= '1';
    wait for 3*CLOCK_PERIOD;

    GLOBAL_RESET <= '0';

    wait;
  end process;

--==========================================================--
  clockGeneration: process
  begin

    GLOBAL_CLOCK <= '0';
    wait for CLOCK_PERIOD/2;

    GLOBAL_CLOCK <= '1';
    wait for CLOCK_PERIOD/2;    
    
  end process;
--==========================================================--
--==========================================================--


clk_gen_8KHz : process(GLOBAL_CLOCK)
begin
  if (GLOBAL_CLOCK'event and GLOBAL_CLOCK='1') then
    if (counter_CLK_8KHz = maxCounter_CLK_8KHz) then
      CLK_8KHz <= not CLK_8KHz;
      counter_CLK_8KHz <= 1;

    else
      counter_CLK_8KHz <= counter_CLK_8KHz+1;

    end if;
  end if;   
end process;


clk_gen_tdm: process(GLOBAL_CLOCK)
begin
  if (GLOBAL_CLOCK'event and GLOBAL_CLOCK='1') then
    if (counter_clk_tdm = maxCounter_clk_tdm) then
      clk_tdm <= not clk_tdm;
      counter_clk_tdm <= 1;

    else
      counter_clk_tdm <= counter_clk_tdm+1;

    end if;
  end if;   

end process;













  toneDetector: entity work.toneDetector(toneDetector)
  port map
  (
    RESET           => GLOBAL_RESET,
    CLK             => GLOBAL_CLOCK,

    CLK_8KHz         => CLK_8KHz,

    CMD_RX_DATA     => TONE_DET_CMD_RX_DATA_S,
    CMD_WORD_INDEX  => CMD_WORD_INDEX_S,
    WRITE_CMD_BUFFER=> WRITE_CMD_BUFFER_S,
    CMD_RX          => TONE_DET_CMD_RX_S,
    CMD_RX_ACK      => TONE_DET_CMD_RX_ACK_S,

    MSG_TX_DATA     => TONE_DET_MSG_TX_DATA_S,
    MSG_TX          => TONE_DET_MSG_TX_S,
    MSG_TX_ACK      => TONE_DET_MSG_TX_ACK_S,

    TDM_FRAME       => TONE_DET_TDM_FRAME_S,
    CHANNEL_ID      => TONE_DET_CHANNEL_ID_S
  );

  
  command_tb: entity work.command_tb(Behavioral)
  port map
  (
    RESET               => GLOBAL_RESET,
    CLK                 => GLOBAL_CLOCK,

    CMD_TX_DATA         => TONE_DET_CMD_RX_DATA_S,
    CMD_WORD_INDEX      => CMD_WORD_INDEX_S,
    WRITE_CMD_BUFFER    => WRITE_CMD_BUFFER_S,  
    CMD_TX              => TONE_DET_CMD_RX_S,
    CMD_TX_ACK          => TONE_DET_CMD_RX_ACK_S
  );

  tdmSwitch_tb: entity work.tdmSwitch_tb(tdmSwitch_tb)
  port map
  (
    RST                 => GLOBAL_RESET,
    -- CLK                 => GLOBAL_CLOCK,

    CLK_8KHz            => CLK_8KHz,
    clk_tdm             => clk_tdm,

    OUT_FRAME           => TONE_DET_TDM_FRAME_S,
    CHANNEL_ID          => TONE_DET_CHANNEL_ID_S

    -- OUT_FRAME_ALL       => 
  );
  


end topModule_toneDetector;











