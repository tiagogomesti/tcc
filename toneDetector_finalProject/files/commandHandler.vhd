----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Tiago Gomes Castro
-- 
-- Create Date:    16:02:45 01/17/2015 
-- Design Name: 
-- Module Name:    commandHandler - Behavioral 
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


entity commandHandler is
port
(
	RESET								: in std_logic;
	CLK									: in std_logic;

	CMD_RX_DATA					: in unsigned (WORD_SIZE-1 downto 0);
	CMD_WORD_INDEX			: in integer range 0 to CMD_BUF_SIZE-1;
	WRITE_CMD_BUFFER		: in std_logic;

	CMD_RX							: in std_logic;
	CMD_RX_ACK					: out std_logic;

	DATA_MEM						: out unsigned (WORD_SIZE-1 downto 0);
	ADDRESS_MEM					: out natural range 0 to TS_IN_PARAM_SIZE-1;
	-- ADDRESS_MEM					: out unsigned (WORD_SIZE-1 downto 0);
	WRITE_MEM						: out std_logic;	

	REQ_MEM							: out std_logic;
	ACK_REQ_MEM					: in std_logic;

	WRITE_END						:	out std_logic
);
end commandHandler;

architecture commandHandler of commandHandler is
	type STATE is (	S0, 
									WAIT_CMD, RECEIVE_CMD,
									REQ_TS_PARAM, WRITE_TS_PARAM, WRITE_TS_PARAM_END, 
									RLS_CMD_BUFFER
									
								);


	signal NEXT_STATE, CURRENT_STATE : STATE;

	signal cnt_words_cmd 		: natural range 0 to CMD_BUF_SIZE-1 := 1;
	-- signal WR_ENABLE_S	 		: std_logic;
	signal CMD_WORD_INDEX_S	: integer range 0 to CMD_BUF_SIZE-1 := 0;

	

	signal offset_tsParam		: natural range 0 to TS_IN_PARAM_SIZE-1 := 0;
	-- signal CMD_BUFFER				: CMD_BUFFER_TYPE;
	signal DATA_MEM_S				: unsigned (WORD_SIZE-1 downto 0);
	signal RLS_CMD_BUFFER_S	: std_logic;

begin

--======================================================--
--======================================================--
cmdBuffer: entity work.cmd_buffer(Behavioral)						--
port map
(
	RESET 					=> RESET,
	CLOCK 					=> CLK,

	RLS_CMD_BUFFER	=> RLS_CMD_BUFFER_S,

	WR_ENABLE 			=> WRITE_CMD_BUFFER,
	DATA_IN 				=> CMD_RX_DATA,
	DATA_OUT 				=> DATA_MEM_S,
	ADDR						=> CMD_WORD_INDEX_S
);	
--======================================================--
--======================================================--

offset_tsParam_process: process (CLK, RESET) 
begin
	if (CLK'event and CLK='1') then
		if (RESET='1') then
			offset_tsParam <= 0;

		elsif (CURRENT_STATE = REQ_TS_PARAM ) then
			offset_tsParam 		<= NUM_PAR*to_integer(DATA_MEM_S);	

		else
			offset_tsParam		<= offset_tsParam;					

		end if;
	end if;
end process;


process (CLK, RESET)
begin
	if ( CLK'event and CLK = '1') then
		if (RESET = '1') then
			cnt_words_cmd 		<= 1;

		elsif (CURRENT_STATE = WRITE_TS_PARAM) then
			if (ACK_REQ_MEM='1') then
				if (cnt_words_cmd <= CMD_BUF_SIZE-1) then
					cnt_words_cmd <= cnt_words_cmd + 1;

				else
					cnt_words_cmd <= 1;

				end if;

			else
				cnt_words_cmd <= 1;

			end if;
		end if;
	end if;
end process;






--==========================================================--
--=									State Machine Engine									 =--
--==========================================================--
process (CLK)
begin
	if(CLK'event and CLK='1') then

		if(RESET='1') then
			CURRENT_STATE <= S0;

		else
			CURRENT_STATE <= NEXT_STATE;
		
		end if;
	end if;
	
end process;


--==========================================================--
--=						State Machine's Next State Logic						 =--
--==========================================================--
nextState: process(CURRENT_STATE,CMD_RX,cnt_words_cmd, ACK_REQ_MEM)

begin

	case CURRENT_STATE is

--===========================================--		
		when S0 =>
			NEXT_STATE <= WAIT_CMD;


--===========================================--				
		when WAIT_CMD =>
			if (CMD_RX = '1') then
				NEXT_STATE <= RECEIVE_CMD;

			else
				NEXT_STATE <= WAIT_CMD;
			end if;


--===========================================--	
		when RECEIVE_CMD =>
			if (CMD_RX = '1') then
				NEXT_STATE <= RECEIVE_CMD;
			else
				NEXT_STATE <= REQ_TS_PARAM;				
			end if ;


--===========================================--	
		when REQ_TS_PARAM =>
			if (ACK_REQ_MEM = '1') then
				NEXT_STATE <= WRITE_TS_PARAM;

			else
				NEXT_STATE <= REQ_TS_PARAM;

			end if;



--===========================================--	
		when WRITE_TS_PARAM =>
			if (cnt_words_cmd <= CMD_BUF_SIZE-1) then
				NEXT_STATE <= WRITE_TS_PARAM;

			-- Decidir ações a serem tomadas se acontecer um timeout 
			-- na escrita do comando
			-- elsif ACK_REQ_MEM = '0'

			else
				NEXT_STATE <= WRITE_TS_PARAM_END;
				
			end if ;


--===========================================--	
		when WRITE_TS_PARAM_END =>
			NEXT_STATE <= RLS_CMD_BUFFER;


--===========================================--	
		when RLS_CMD_BUFFER => 
			NEXT_STATE <= S0;




	
		-- when others =>
	
	end case ;

end process;


--==========================================================--
--= 							State Machine's Actions									 =--
--==========================================================--
stateAction: process(CURRENT_STATE, CMD_RX, CMD_WORD_INDEX,
										 DATA_MEM_S, ACK_REQ_MEM, cnt_words_cmd,
										 offset_tsParam)


	-- variable temp 				: unsigned( 2*WORD_SIZE-1 downto 0 );
	variable cnt_words_cmd_var	: integer range 0 to CMD_BUF_SIZE-1;

begin
--===========================================--	
	CMD_RX_ACK 					<= '0';												 --
	ADDRESS_MEM 				<=  0 ;					 --
	WRITE_MEM 					<= '0';											 --
	REQ_MEM							<= '0';											 --
	WRITE_END						<= '0';											 --
	-- cnt_words_cmd				<=  1 ; 
	RLS_CMD_BUFFER_S		<= '0';
	CMD_WORD_INDEX_S		<=  0 ;
	-- offset_tsParam			<=  0 ;
	DATA_MEM						<= (others => '0');
--===========================================--


	case CURRENT_STATE is
		when S0 =>
			CMD_RX_ACK 					<= '0';
			
			ADDRESS_MEM 				<=  0 ;
			WRITE_MEM 					<= '0';			
			REQ_MEM							<= '0';
			WRITE_END						<= '0';
			-- cnt_words_cmd				<=  1 ;			
			RLS_CMD_BUFFER_S		<= '0';
			CMD_WORD_INDEX_S		<=  0 ;
			-- offset_tsParam			<=  0 ;
			DATA_MEM						<= (others => '0');

--===========================================--	
		when WAIT_CMD =>
			if (CMD_RX = '1') then
				CMD_RX_ACK <= '1';				
			end if ;

--===========================================--	
		when RECEIVE_CMD =>
			CMD_RX_ACK <= '1';
			CMD_WORD_INDEX_S <= CMD_WORD_INDEX;


--===========================================--	
		when REQ_TS_PARAM =>
			REQ_MEM 					<= '1';
			CMD_WORD_INDEX_S 	<= 0;
			-- offset_tsParam 		<= NUM_PAR*to_integer(DATA_MEM_S);


--===========================================--	
		when WRITE_TS_PARAM =>
			REQ_MEM 							<= '1';

			if (ACK_REQ_MEM='1') then
				if (cnt_words_cmd <= CMD_BUF_SIZE-1) then

					CMD_WORD_INDEX_S 	<= cnt_words_cmd;
					DATA_MEM					<= DATA_MEM_S;
					ADDRESS_MEM 			<= offset_tsParam + cnt_words_cmd;
					WRITE_MEM					<= '1';
					
					-- cnt_words_cmd 		<= cnt_words_cmd + 1;
				end if;

			end if;
			-- offset_tsParam 		<= NUM_PAR*to_integer(DATA_MEM_S);

			-- Decidir ações a serem tomadas se acontecer um timeout 
			-- na escrita do comando
			-- elsif ACK_REQ_MEM = '0'

--===========================================--	
		when WRITE_TS_PARAM_END =>
			DATA_MEM					<= x"0000";
			ADDRESS_MEM 			<= offset_tsParam;
			WRITE_MEM					<= '1';


--===========================================--	
		when RLS_CMD_BUFFER =>
			RLS_CMD_BUFFER_S <= '1';
			WRITE_END <= '1';

	end case ;





end process;

end commandHandler;









