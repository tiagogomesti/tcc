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

	MSG_BUF_FULL				: out std_logic;

	MSG_RX_DATA					: in unsigned (WORD_SIZE-1 downto 0);
	MSG_RX							: in std_logic;
	-- MSG_RX_ACK					: out std_logic;

	MSG_TX_DATA					: out unsigned (WORD_SIZE-1 downto 0);
	MSG_TX							: out std_logic;
	MSG_TX_ACK					: in std_logic
);
end messageHandler;


architecture messageHandlerUniqueProcess of messageHandler is
	signal msg_buf_s							: MSG_BUFFER_TYPE;
	signal msg_buf_full_rx_s			: std_logic;
	signal msg_buf_full_tx_s			: std_logic;
	signal msg_buf_full_s					: std_logic;
	
	type RX_STATE is( 
		S0,
		WAIT_RX,
		RECEIVE_DATA,
		INC_TAIL,
		WAIT_MSG_BUF_FREE_SPACE
		);
	signal RX_NEXT_STATE, RX_CURRENT_STATE : RX_STATE;

	signal buf_tail_s				: natural range 0 to MSG_BUF_SIZE-1;


	type TX_STATE is( 
		S0,
		WAIT_MSG,
		SEND_TX,
		INC_HEAD
		);
	signal TX_NEXT_STATE, TX_CURRENT_STATE	: TX_STATE;

	signal buf_head_s				: natural range 0 to MSG_BUF_SIZE-1;




begin

MSG_BUF_FULL <= msg_buf_full_s;


msg_buf_full_flag: process(CLOCK, RST)

begin
	if(CLOCK'event and CLOCK='1') then
		if (RST='1')then
			msg_buf_full_s <= '0';
		
		else
			if (msg_buf_full_rx_s='0') then
				msg_buf_full_s <= '0';

			elsif (msg_buf_full_tx_s='1') then
				msg_buf_full_s <= '0';

			else
				msg_buf_full_s <= '1';		
				
			end if ;
		end if;
	end if;
end process;

--***************************************--
--* 				 RX MACHINE STATE						*--
--***************************************--

RX_CURRENT_STATE <= RX_NEXT_STATE;

rx_process: process(CLOCK, RST)
	variable buf_tail_v		: natural range 0 to MSG_BUF_SIZE-1;

begin
if (CLOCK'event and CLOCK='1') then
	if(RST='1') then
		buf_tail_s				<= 0;
		msg_buf_full_rx_s	<= '0';
		msg_buf_s					<= (others => x"0000");

		RX_NEXT_STATE <= S0;

	else
		case RX_CURRENT_STATE is
			when S0 =>
				msg_buf_s					<= (others => x"0000");
				buf_tail_s				<= 0;
				msg_buf_full_rx_s	<= '0';
				
				RX_NEXT_STATE <= WAIT_RX;

			when WAIT_RX =>
				if (MSG_RX = '1') then
					RX_NEXT_STATE <= RECEIVE_DATA;

				else
					RX_NEXT_STATE <= WAIT_RX;

				end if;

			when RECEIVE_DATA =>
				msg_buf_s(buf_tail_s) <= MSG_RX_DATA;

				RX_NEXT_STATE <= INC_TAIL;

			when INC_TAIL =>
				if (buf_tail_s < MSG_BUF_SIZE-1) then
					buf_tail_v := buf_tail_s+1;
					buf_tail_s <= buf_tail_s+1;

				else
					buf_tail_s <= 0;
					buf_tail_v := 0;
					
				end if ;

				if (buf_tail_v = buf_head_s) then
					msg_buf_full_rx_s <= '1';								
					RX_NEXT_STATE <= WAIT_MSG_BUF_FREE_SPACE; 

				else
					msg_buf_full_rx_s <= '0';
					RX_NEXT_STATE 		<= WAIT_RX;
					
				end if ;


			when WAIT_MSG_BUF_FREE_SPACE =>
				if (buf_tail_s = buf_head_s) then
					msg_buf_full_rx_s <= '1';				
					RX_NEXT_STATE 		<= WAIT_MSG_BUF_FREE_SPACE; 
					
				else
					msg_buf_full_rx_s <= '0';				
					RX_NEXT_STATE 		<= WAIT_RX;
								
				end if;
		end case;
	end if;
end if;
end process;


--***************************************--
--* 				 TX MACHINE STATE						*--
--***************************************--

TX_CURRENT_STATE <= TX_NEXT_STATE;

tx_process: process(CLOCK, RST)
	variable buf_head_v			: natural range 0 to MSG_BUF_SIZE-1;
begin
if (CLOCK'event and CLOCK='1') then
	if(RST='1') then
		MSG_TX							<= '0';
		MSG_TX_DATA					<=  x"0000";
		msg_buf_full_tx_s		<= '0';
		TX_NEXT_STATE 			<= S0;

	else
		case TX_CURRENT_STATE is
			when S0 =>
				MSG_TX				<= '0';
				MSG_TX_DATA		<=  x"0000";
				msg_buf_full_tx_s		<= '0';
				TX_NEXT_STATE <= WAIT_MSG;

			when WAIT_MSG =>
				msg_buf_full_tx_s <= '0';

				if ((buf_tail_s/=buf_head_s) or msg_buf_full_s='1') then
					TX_NEXT_STATE <= SEND_TX;

				else
					TX_NEXT_STATE <= WAIT_MSG;					

				end if ;

			
			when SEND_TX =>
				MSG_TX				<= '1';
				MSG_TX_DATA		<= msg_buf_s(buf_head_s);

				if (MSG_TX_ACK = '1') then
					MSG_TX				<= '0';
					TX_NEXT_STATE <= INC_HEAD;

				else
					TX_NEXT_STATE <= SEND_TX;					
					
				end if ;
			
			when INC_HEAD =>
				if (buf_head_s < MSG_BUF_SIZE-1) then
					buf_head_s	<= buf_head_s+1;

				else
					buf_head_s	<= 0;					
					
				end if ;

				if (msg_buf_full_rx_s ='1') then
					msg_buf_full_tx_s			<= '1';					
					
				end if ;
				

				TX_NEXT_STATE <= WAIT_MSG;

		end case;
	end if;
end if;

end process;
end messageHandlerUniqueProcess;




-- architecture messageHandler of messageHandler is
-- 	signal msg_buf_s							: MSG_BUFFER_TYPE;
	
-- 	type RX_STATE is( 
-- 		S0,
-- 		WAIT_RX,
-- 		RECEIVE_DATA,
-- 		INC_TAIL,
-- 		WAIT_MSG_BUF_FREE_SPACE
-- 		);
-- 	signal RX_NEXT_STATE, RX_CURRENT_STATE : RX_STATE;

-- 	signal buf_tail_s				: natural range 0 to MSG_BUF_SIZE-1;


-- 	type TX_STATE is( 
-- 		S0,
-- 		WAIT_MSG,
-- 		SEND_TX,
-- 		SEND_MSG,
-- 		INC_HEAD
-- 		);
-- 	signal TX_NEXT_STATE, TX_CURRENT_STATE	: TX_STATE;

-- 	signal buf_head_s				: natural range 0 to MSG_BUF_SIZE-1;




-- begin

-- --***************************************--
-- --* 				 RX MACHINE STATE						*--
-- --***************************************--
-- rx_process_engine: process (CLOCK, RST) 
-- begin
-- 	if (CLOCK'event and CLOCK='1') then
-- 		if (RST='1') then
-- 			RX_CURRENT_STATE <= S0;

-- 		else
-- 			RX_CURRENT_STATE <= RX_NEXT_STATE;
		
-- 		end if;
-- 	end if;
-- end process;

-- rx_process_nx_state: process(RX_CURRENT_STATE, MSG_RX, buf_tail_s, buf_head_s)
-- begin
-- 	case RX_CURRENT_STATE is
-- 		when S0 =>
-- 			RX_NEXT_STATE <= WAIT_RX;

-- 		when WAIT_RX =>
-- 			if (MSG_RX = '1') then
-- 				RX_NEXT_STATE <= RECEIVE_DATA;

-- 			else
-- 				RX_NEXT_STATE <= WAIT_RX;

-- 			end if;

-- 		when RECEIVE_DATA =>
-- 			RX_NEXT_STATE <= INC_TAIL;

-- 		when INC_TAIL =>
-- 			if ((buf_tail_s+1) = buf_head_s) then
-- 				RX_NEXT_STATE <= WAIT_MSG_BUF_FREE_SPACE; 

-- 			else
-- 				RX_NEXT_STATE <= WAIT_RX;
				
-- 			end if ;


-- 		when WAIT_MSG_BUF_FREE_SPACE =>
-- 			if (buf_tail_s = buf_head_s) then
-- 				RX_NEXT_STATE <= WAIT_MSG_BUF_FREE_SPACE; 
				
-- 			else
-- 				RX_NEXT_STATE <= WAIT_RX;
							
-- 			end if;
-- 	end case;
-- end process;

-- rx_process_actions: process(RX_CURRENT_STATE, MSG_RX, MSG_RX_DATA, buf_head_s, buf_tail_s)
-- variable buf_tail_v			:natural range 0 to MSG_BUF_SIZE-1;
-- begin
-- 	case RX_CURRENT_STATE is
-- 		when S0 =>
-- 			msg_buf_s			<= (others => x"0000");
-- 			buf_tail_s		<= 0;
-- 			MSG_BUF_FULL	<= '0';

-- 		when WAIT_RX =>
			

-- 		when RECEIVE_DATA =>
-- 			msg_buf_s(buf_tail_s) <= MSG_RX_DATA;


-- 		when INC_TAIL =>
-- 			if (buf_tail_s < MSG_BUF_SIZE-1) then
-- 				buf_tail_s <= buf_tail_s+1;

-- 			else
-- 				buf_tail_s <= 0;
				
-- 			end if ;

-- 			if ((buf_tail_s+1) = buf_head_s) then
-- 				MSG_BUF_FULL <= '1';

-- 			else
-- 				MSG_BUF_FULL <= '0';
				
-- 			end if;

-- 		when WAIT_MSG_BUF_FREE_SPACE =>
-- 			if (buf_tail_s = buf_head_s) then
-- 				MSG_BUF_FULL <= '1';

-- 			else
-- 				MSG_BUF_FULL <= '0';
				
-- 			end if;
-- 	end case;
-- end process;


-- --***************************************--
-- --* 				 TX MACHINE STATE						*--
-- --***************************************--


-- tx_process_engine : process(CLOCK, RST)
-- begin
-- 	if (CLOCK'event and CLOCK='1') then
-- 		if (RST='1') then
-- 			TX_CURRENT_STATE <= S0;

-- 		else
-- 			TX_CURRENT_STATE <= TX_NEXT_STATE;

-- 		end if;
-- 	end if;
-- end process ; -- tx_process_engine

-- tx_process_nx_state : process(TX_CURRENT_STATE)
-- begin
-- case TX_CURRENT_STATE is
-- 	when S0 =>
-- 		TX_NEXT_STATE <= WAIT_MSG;

-- 	when WAIT_MSG =>

	
-- 	when SEND_TX =>

	
-- 	when SEND_MSG =>

	
-- 	when INC_HEAD =>

-- end case;

	
-- end process ; -- tx_process_nx_state

		
-- tx_process_actions : process(TX_CURRENT_STATE)
-- begin
-- case TX_CURRENT_STATE is
-- 	when S0 =>
-- 		buf_head_s <= 0;

-- 	when WAIT_MSG =>
		




-- 	when SEND_TX =>


-- 	when SEND_MSG =>


-- 	when INC_HEAD =>




-- end case;

	
-- end process ; -- tx_process_actions





-- end messageHandler;






























