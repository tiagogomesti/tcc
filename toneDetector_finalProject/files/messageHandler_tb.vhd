--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:33:56 10/05/2015
-- Design Name:   
-- Module Name:   C:/Users/Tiago Gomes/OneDrive/Tcc/toneDetector/messageHandler_tb.vhd
-- Project Name:  toneDetector
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: messageHandler
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.toneDetectorPackage.all;


 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
entity messageHandler_tb IS
port
(
  CLOCK         : in std_logic;
  RESET         : in std_logic;

  MSG_RX        : in  std_logic;
  MSG_RX_DATA   : in  unsigned (WORD_SIZE-1 downto 0);
  MSG_RX_ACK    : out std_logic

);

end messageHandler_tb;

architecture messageHandler_tb of messageHandler_tb is 
  type STATE is(
    S0, 
    WAIT_RX, 
    INC_CNT
  );
  signal CURRENT_STATE, NEXT_STATE  : STATE;

  constant BUF_SIZE     : natural := 128;

  type MSG_BUFFER_TEST is array (0 to BUF_SIZE-1) of WORD;
  

  signal msg_buf_s      : MSG_BUFFER_TEST;
  signal buf_cnt_s      : natural range 0 to BUF_SIZE-1;       
  signal delay_process  : std_logic := '0';       



 
begin

-- delay_process <= '1' after 60 ms;
delay_process <= '1';



CURRENT_STATE <= NEXT_STATE;

process (CLOCK, RESET)
begin
  if (CLOCK'event and CLOCK='1') then
    if (RESET='1') then
      MSG_RX_ACK <= '0';
      msg_buf_s  <= (others => x"0000");
      buf_cnt_s  <= 0;
      NEXT_STATE <= S0;

    else
      case CURRENT_STATE is
      
        when S0 =>
          MSG_RX_ACK <= '0';
          msg_buf_s  <= (others => x"0000");
          buf_cnt_s  <= 0;
          NEXT_STATE <= WAIT_RX;

        when WAIT_RX =>
          if (MSG_RX='1' and delay_process='1') then
            msg_buf_s(buf_cnt_s) <= MSG_RX_DATA;
            MSG_RX_ACK <= '1';
            NEXT_STATE <= INC_CNT;

          else
            NEXT_STATE <= WAIT_RX;
            
          end if ;

        when INC_CNT =>
          buf_cnt_s  <= buf_cnt_s+1;
          MSG_RX_ACK <= '0';
          NEXT_STATE <= WAIT_RX;      
      
      end case;      
    end if;    
  end if ;
end process;


end messageHandler_tb;
