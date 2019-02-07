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


use STD.textio.all; --Dont forget to include this library for file operations.



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

--*******************************************--
--*        Sinais para rotina de teste      *--
--*******************************************--
  -- ioFrameControl_s(port)(0) -> open and read file
  -- ioFrameControl_s(port)(1) -> close the file
  -- signal ioFrameControl_s : ioFrameControlType := (others => "00");

  signal initial_time_ports : time_NumPorts;

  signal in_FrameControl_s  : std_logic_vector(0 to NUM_CH-1) := (others => '0');
  signal out_FrameControl_s : std_logic_vector(0 to NUM_CH-1) := (others => '0');



  signal ioFrameNumFile_s : ioFrameNumFileType := (others => 0);


  type wordFileType is file of character;
    file fileParams_f : wordFileType open read_mode is ".\\in_files\\fileParams.bin";  


  
  signal num_files_s                    : natural;
  signal num_files_const_s              : natural;
  signal flag_busy_port_s               : std_logic;
  signal port_busy_cmd_s                : natural range 0 to NUM_CH-1;



  type CMD_INSERT_STATE is (S0_CMD,
                            WAIT_FLAG_SEND_CMD,
                            SEND_CMD_END,
                            AUDIO_CONNECTION_0,
                            AUDIO_CONNECTION_1
                            );
  signal CURRENT_STATE_CMD, NEXT_STATE_CMD : CMD_INSERT_STATE;


  signal msg_buf_s                      : WORD;
  signal flag_release_port_s            : std_logic;
  signal port_release_msg_s             : natural range 0 to NUM_CH-1;

  type RCV_MSG_VALIDATE_STATE is( S0_MSG,
                                  WAIT_RX_MSG,
                                  PROCESS_MSG_0,
                                  PROCESS_MSG_1
                                );
  signal CURRENT_STATE_MSG, NEXT_STATE_MSG : RCV_MSG_VALIDATE_STATE;

  signal file_connection_s              : natural := 0;
  signal port_connection_s              : natural range 0 to NUM_CH-1;

  signal ports_free_s                   : std_logic_vector (0 to NUM_CH-1);

  signal cmd_trigger_s                  : std_logic;
  signal wait_cmd_s                     : std_logic;

  signal timeslot_s                     : natural range 0 to NUM_CH-1;
  signal max_min_pulse_s                : unsigned (WORD_SIZE-1 downto 0);
  signal max_min_pause_s                : unsigned (WORD_SIZE-1 downto 0);
  signal attenuation_cadence_s          : unsigned (WORD_SIZE-1 downto 0);
  signal threshold_s                    : unsigned (WORD_SIZE-1 downto 0);
  signal coeff1_s                       : unsigned (WORD_SIZE-1 downto 0);
  signal coeff2_s                       : unsigned (WORD_SIZE-1 downto 0);



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

  MSG_TX          => TONE_DET_MSG_TX_S,
  MSG_TX_DATA     => TONE_DET_MSG_TX_DATA_S,
  MSG_TX_ACK      => TONE_DET_MSG_TX_ACK_S,

  TDM_FRAME       => TONE_DET_TDM_FRAME_S,
  CHANNEL_ID      => TONE_DET_CHANNEL_ID_S
);

command_tb: entity work.command_tb(Behavioral)
port map
(
  RESET               => GLOBAL_RESET,
  CLK                 => GLOBAL_CLOCK,

  CMD_TRIGGER         => cmd_trigger_s,
  WAIT_CMD            => wait_cmd_s,

  TIMESLOT            => timeslot_s,
  MAX_MIN_PULSE       => max_min_pulse_s,
  MAX_MIN_PAUSE       => max_min_pause_s,
  ATTENUATION_CADENCE => attenuation_cadence_s,
  THRESHOLD           => threshold_s,
  COEFF1              => coeff1_s,
  COEFF2              => coeff2_s,

  CMD_TX_DATA         => TONE_DET_CMD_RX_DATA_S,
  CMD_WORD_INDEX      => CMD_WORD_INDEX_S,
  WRITE_CMD_BUFFER    => WRITE_CMD_BUFFER_S,  
  CMD_TX              => TONE_DET_CMD_RX_S,
  CMD_TX_ACK          => TONE_DET_CMD_RX_ACK_S
);

-- messageHandle_tb: entity work.messageHandler_tb(messageHandler_tb)
-- port map
-- (
--   CLOCK               => GLOBAL_CLOCK,
--   RESET               => GLOBAL_RESET,

--   MSG_RX              => TONE_DET_MSG_TX_S,
--   MSG_RX_DATA         => TONE_DET_MSG_TX_DATA_S,
--   MSG_RX_ACK          => TONE_DET_MSG_TX_ACK_S
-- );




tdmSwitch_tb: entity work.tdmSwitch_tb(tdmSwitch_tb)
port map
(
  RST                 => GLOBAL_RESET,
  -- CLK                 => GLOBAL_CLOCK,

  CLK_8KHz            => CLK_8KHz,
  clk_tdm             => clk_tdm,

  -- ioFrameControl      => ioFrameControl_s,
  in_FrameControl     => in_FrameControl_s,
  out_FrameControl    => out_FrameControl_s,
  ioFrameNumFile      => ioFrameNumFile_s,

  OUT_FRAME           => TONE_DET_TDM_FRAME_S,
  CHANNEL_ID          => TONE_DET_CHANNEL_ID_S

  -- OUT_FRAME_ALL       => 
  );

--********************************************************************************--
-- Process responsável por inserir o comando e fazer a conexão do áudio na porta  --
--********************************************************************************--
CURRENT_STATE_CMD <= NEXT_STATE_CMD;
toneDetectorCmdInsert : process (GLOBAL_RESET, GLOBAL_CLOCK) 
  variable ports_state_aux_v  : natural range 0 to NUM_CH-1;
  variable ports_state_free_flag : std_logic;

  variable file_char_v   : character;
  variable file_int_v    : integer;

  variable num_files_v   : unsigned (15 downto 0);
  
  variable cmd_word_aux_v: unsigned (15 downto 0);


begin
  if (GLOBAL_CLOCK'event and GLOBAL_CLOCK='1') then
    if (GLOBAL_RESET='1') then
      NEXT_STATE_CMD <= S0_CMD;

  else
    case CURRENT_STATE_CMD is
    
      when S0_CMD =>
        -- for i in 0 to NUM_CH-1 loop
        --   ioFrameControl_s(i)(0) <= '0';
        -- end loop;

        in_FrameControl_s <= (others => '0');

                -- ports_free_s          <= (others => '1');
        flag_busy_port_s       <= '0';
        port_busy_cmd_s        <= 0;
        cmd_trigger_s          <= '0';

        timeslot_s             <= 0;
        max_min_pulse_s        <= (others => '0');
        max_min_pause_s        <= (others => '0');
        attenuation_cadence_s  <= (others => '0');
        threshold_s            <= (others => '0');
        coeff1_s               <= (others => '0');
        coeff2_s               <= (others => '0');

        read (fileParams_f, file_char_v);
        file_int_v := character'pos(file_char_v);
        num_files_v(7 downto 0) := to_unsigned (file_int_v,8);

        read (fileParams_f, file_char_v);
        file_int_v := character'pos(file_char_v);
        num_files_v(15 downto 8) := to_unsigned (file_int_v,8);

        num_files_s       <= to_integer(num_files_v); -- quantidade de arquivos para simulação
        num_files_const_s <= to_integer(num_files_v); -- quantidade de arquivos para simulação

        NEXT_STATE_CMD <= WAIT_FLAG_SEND_CMD;

      when WAIT_FLAG_SEND_CMD =>
        ports_state_free_flag := '0';
        ports_state_aux_v := 0;

        -- for i in 0 to NUM_CH-1 loop
        for i in NUM_CH-1 downto 0 loop

          if (ports_free_s(i) = '1') then
            ports_state_aux_v := i;
            ports_state_free_flag := '1';

            
          end if;          
        end loop;

        if ( (ports_state_free_flag='1') and (wait_cmd_s='1') and (num_files_s>0) ) then

          timeslot_s <= ports_state_aux_v;

        --------------------------------------------------------------
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(15 downto 8) := to_unsigned (file_int_v,8);
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(7 downto 0) := to_unsigned (file_int_v,8);

          max_min_pulse_s         <= cmd_word_aux_v;

        --------------------------------------------------------------
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(15 downto 8) := to_unsigned (file_int_v,8);
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(7 downto 0) := to_unsigned (file_int_v,8);

          max_min_pause_s         <= cmd_word_aux_v;

        --------------------------------------------------------------          
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(7 downto 0) := to_unsigned (file_int_v,8);
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(15 downto 8) := to_unsigned (file_int_v,8);

          attenuation_cadence_s    <= cmd_word_aux_v;

        --------------------------------------------------------------          
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(7 downto 0) := to_unsigned (file_int_v,8);
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(15 downto 8) := to_unsigned (file_int_v,8);

          threshold_s               <= cmd_word_aux_v;        

        --------------------------------------------------------------          
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(7 downto 0) := to_unsigned (file_int_v,8);
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(15 downto 8) := to_unsigned (file_int_v,8);

          coeff1_s                   <= cmd_word_aux_v;           

        --------------------------------------------------------------          
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(7 downto 0) := to_unsigned (file_int_v,8);
          read (fileParams_f, file_char_v);
          file_int_v := character'pos(file_char_v);
          cmd_word_aux_v(15 downto 8) := to_unsigned (file_int_v,8);
          coeff2_s                    <= cmd_word_aux_v;
        --------------------------------------------------------------          

          ports_state_free_flag := '0';
          cmd_trigger_s <= '1';
          -- ports_free_s(ports_state_aux_v) <= '0';

          file_connection_s <= num_files_const_s - num_files_s;
          port_connection_s <= ports_state_aux_v;

          num_files_s <= num_files_s - 1;
          
          NEXT_STATE_CMD <= SEND_CMD_END;


        end if ;

        
      when SEND_CMD_END => 
        cmd_trigger_s <= '0';

        NEXT_STATE_CMD <= AUDIO_CONNECTION_0;

    
      when AUDIO_CONNECTION_0 => 
        -- ioFrameControl_s(port_connection_s)(0)  <= '1';
        in_FrameControl_s(port_connection_s)    <= '1';
        ioFrameNumFile_s(port_connection_s)     <= file_connection_s;

        port_busy_cmd_s <= port_connection_s;
        flag_busy_port_s <= '1';

        initial_time_ports(port_connection_s) <= now;

        NEXT_STATE_CMD <= AUDIO_CONNECTION_1;

        report "audio connect - port " & integer'IMAGE(port_connection_s) & " - file " & integer'IMAGE(file_connection_s);
        -- report integer'IMAGE(port_connection_s);
        -- report "\n";

      when AUDIO_CONNECTION_1 =>
        -- ioFrameControl_s(port_connection_s)(0)  <= '0';
        in_FrameControl_s(port_connection_s)    <= '0';

        flag_busy_port_s  <= '0';

        NEXT_STATE_CMD <= WAIT_FLAG_SEND_CMD;
   
    end case ;
  end if;
end if;
end process ; -- 


--********************************************************************************--
--*               Process responsável pelo gerenciamento das portas              *--
--********************************************************************************--
process(GLOBAL_RESET, GLOBAL_CLOCK) 
begin
  if (GLOBAL_CLOCK'event and GLOBAL_CLOCK='1') then
    if (GLOBAL_RESET='1') then
      ports_free_s <= (others => '1');
      
    else
      if (flag_release_port_s='1') then
        ports_free_s(port_release_msg_s) <= '1';

      elsif (flag_busy_port_s='1') then
        ports_free_s(port_busy_cmd_s) <= '0';
        
      end if ;

    end if ;
    

  end if ;

end process;






--********************************************************************************--
--                    Process responsável por receber as mensagens                --
--********************************************************************************--
CURRENT_STATE_MSG <= NEXT_STATE_MSG;
getMessagesProcess: process (GLOBAL_RESET, GLOBAL_CLOCK)
  variable port_msg_v           : natural range 0 to NUM_CH-1;
  variable type_msg_v           : natural range 0 to 255;
  variable line_v         : line;
  file     text_v         : text open write_mode is "simulation_result.txt";

  -- variable test_string_time_v      : string;
  variable test_time_v             : time;

begin
  -- file_open(text_v, "simulation_result.txt", write_mode);


  if(GLOBAL_CLOCK'event and GLOBAL_CLOCK='1') then
    if (GLOBAL_RESET='1') then
      TONE_DET_MSG_TX_ACK_S <= '0';
      msg_buf_s             <= (others => '0');
      
      port_release_msg_s    <= 0;
      flag_release_port_s   <= '0';

      -- for i in 0 to NUM_CH-1 loop
      --   ioFrameControl_s(i)(1) <= '0';
      -- end loop;

      out_FrameControl_s <= (others => '0');

      NEXT_STATE_MSG <= S0_MSG;

    else
      case CURRENT_STATE_MSG is
      
        when S0_MSG =>
          TONE_DET_MSG_TX_ACK_S <= '0';
          NEXT_STATE_MSG <= WAIT_RX_MSG;

        when WAIT_RX_MSG =>
          if (num_files_s = 0 and ports_free_s = x"ff") then
            assert false report "end of simulation" severity failure;
            
          end if ;

          if (TONE_DET_MSG_TX_S='1') then
            msg_buf_s <= TONE_DET_MSG_TX_DATA_S;
            TONE_DET_MSG_TX_ACK_S <= '1';
            NEXT_STATE_MSG <= PROCESS_MSG_0;

          else
            NEXT_STATE_MSG <= WAIT_RX_MSG;
            
          end if ;

        when PROCESS_MSG_0 =>
          TONE_DET_MSG_TX_ACK_S <= '0';

          port_msg_v := to_integer(msg_buf_s(7 downto 0));
          type_msg_v := to_integer(msg_buf_s(15 downto 8));

          -- ioFrameControl_s(port_msg_v)(1)  <= '1';
          out_FrameControl_s(port_msg_v)   <= '1';

          flag_release_port_s <= '1';
          port_release_msg_s  <= port_msg_v;

          write(line_v, port_msg_v);
          write(line_v, string'(";"));
          
          write(line_v, ioFrameNumFile_s(port_msg_v));
          write(line_v, string'(";"));

          write(line_v, type_msg_v);
          write(line_v, string'(";"));
          


          -- write(line_v, time'IMAGE(initial_time_ports(port_msg_v)));
          -- write(line_v, string'(";"));
          
          -- write(line_v, time'IMAGE(now));

          report "msgRcv - port " & integer'IMAGE(port_msg_v) & " - file " & integer'IMAGE(ioFrameNumFile_s(port_msg_v));
          

          writeline(text_v, line_v);
          
          NEXT_STATE_MSG <= PROCESS_MSG_1;  

        when PROCESS_MSG_1 =>
          flag_release_port_s <= '0';
          out_FrameControl_s(port_msg_v)   <= '0';

          NEXT_STATE_MSG <= WAIT_RX_MSG;


                
      end case;      
    end if;    
  end if ;
end process;
  

















































































































































end topModule_toneDetector;











