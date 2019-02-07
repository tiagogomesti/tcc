----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:20:31 01/20/2015 
-- Design Name: 
-- Module Name:    memoryControlAccess - Behavioral 
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
use work.toneDetectorPackage.all;
use IEEE.NUMERIC_STD.ALL;
-- use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memoryControlAccess is
port
(
	CLK												: in std_logic;
	RST												: in std_logic;

-- command handler interface
	CMD_DATA_MEM							: in unsigned (WORD_SIZE-1 downto 0);
	CMD_ADDRESS_MEM						: in natural range 0 to TS_IN_PARAM_SIZE-1;
	CMD_WRITE_MEM							: in std_logic;	

	CMD_REQ_MEM								: in std_logic;
	CMD_ACK_REQ_MEM						: out std_logic;

	CMD_WRITE_END							: in std_logic;

-- processor interface
	PROCESSOR_DATA_MEM_IN 		: in unsigned (WORD_SIZE-1 downto 0);
	PROCESSOR_DATA_MEM_OUT		: out unsigned (WORD_SIZE-1 downto 0);
	PROCESSOR_ADDRESS_MEM			: in integer range 0 to TS_IN_PARAM_SIZE-1;
	PROCESSOR_WR_MEM					: in std_logic;
	
	HALT_PROCESSOR						: in std_logic;
	
	RLS_TIME_SLOT_PROC				: in std_logic;
	RLS_TIME_SLOT_INDEX_PROC	: in integer range 0 to NUM_CH-1;
	RLS_TIME_SLOT_ACK_PROC		: out std_logic;
	
-- Memory interface
	OUT_DATA_MEM							: out unsigned (WORD_SIZE-1 downto 0);
	IN_DATA_MEM								: in unsigned (WORD_SIZE-1 downto 0);
	ADDRESS_MEM								: out integer range 0 to TS_IN_PARAM_SIZE-1;
	WR_MEM										: out std_logic;

	RLS_TIME_SLOT							: out std_logic;
	RLS_TIME_SLOT_INDEX				: out integer range 0 to NUM_CH-1;
	RLS_TIME_SLOT_ACK					: in std_logic
);
end memoryControlAccess;

architecture memoryControlAccessNoStateMachine of memoryControlAccess is
begin
	PROCESSOR_DATA_MEM_OUT	<= IN_DATA_MEM;
	RLS_TIME_SLOT						<= RLS_TIME_SLOT_PROC;
	RLS_TIME_SLOT_INDEX			<= RLS_TIME_SLOT_INDEX_PROC;
	RLS_TIME_SLOT_ACK_PROC	<= RLS_TIME_SLOT_ACK;



process (CLK, RST)
begin	
	if (CLK'event and CLK='1') then
		if (RST='1') then
			OUT_DATA_MEM						<= (others => '0');
			ADDRESS_MEM							<= 0;
			WR_MEM									<= '0';
			CMD_ACK_REQ_MEM					<= '0';


		else
			if (HALT_PROCESSOR = '1' and CMD_WRITE_END = '0') then
				OUT_DATA_MEM					<= CMD_DATA_MEM;
				ADDRESS_MEM						<= CMD_ADDRESS_MEM;
				WR_MEM								<= CMD_WRITE_MEM;
				CMD_ACK_REQ_MEM				<= '1';
			
			else
				OUT_DATA_MEM					<= PROCESSOR_DATA_MEM_IN;
				ADDRESS_MEM						<= PROCESSOR_ADDRESS_MEM;
				WR_MEM								<= PROCESSOR_WR_MEM;
				CMD_ACK_REQ_MEM				<= '0';

			end if;
		end if;
	end if;
end process;






end memoryControlAccessNoStateMachine;



architecture memoryControlAccess of memoryControlAccess is
	type STATE is ( S0,
									PROCESSOR_TIME,
									CMD_TIME
								);

	signal NEXT_STATE, CURRENT_STATE : STATE;



begin
--==========================================================--
--=									State Machine Engine									 =--
--==========================================================--
process (CLK)
begin
	if (CLK'event and CLK='1') then
		if (RST='1') then
			CURRENT_STATE <= S0;
		
		else
			CURRENT_STATE <= NEXT_STATE;
		
		end if;
	end if;
			

end process;


--==========================================================--
--=						State Machine's Next State Logic						 =--
--==========================================================--
process(CURRENT_STATE, HALT_PROCESSOR, CMD_REQ_MEM,
				CMD_WRITE_END)
begin
	
	case CURRENT_STATE is 

		when S0 =>
			NEXT_STATE <= PROCESSOR_TIME;

		when PROCESSOR_TIME =>
			if (HALT_PROCESSOR = '1' and CMD_REQ_MEM='1') then
				NEXT_STATE <= CMD_TIME;

			else 
				NEXT_STATE <= PROCESSOR_TIME;

			end if;
				
		when CMD_TIME =>
			if (HALT_PROCESSOR = '1' and CMD_WRITE_END = '0') then
				NEXT_STATE <= CMD_TIME;

			else
				NEXT_STATE <= PROCESSOR_TIME;

			end if;

	end case;

end process;
--==========================================================--
--= 							State Machine's Actions									 =--
--==========================================================--
process(CURRENT_STATE, HALT_PROCESSOR, PROCESSOR_DATA_MEM_IN, 
				IN_DATA_MEM, PROCESSOR_ADDRESS_MEM, PROCESSOR_WR_MEM,
				RLS_TIME_SLOT_PROC, RLS_TIME_SLOT_INDEX_PROC,
				RLS_TIME_SLOT_ACK, CMD_REQ_MEM, CMD_WRITE_END, 
				CMD_DATA_MEM, CMD_ADDRESS_MEM, CMD_WRITE_MEM)

begin
		CMD_ACK_REQ_MEM					<= '0';
		PROCESSOR_DATA_MEM_OUT	<= x"0000";
		OUT_DATA_MEM						<= x"0000";
		ADDRESS_MEM							<= 0;
		WR_MEM									<= '0';
		RLS_TIME_SLOT_ACK_PROC	<= '0';
		RLS_TIME_SLOT						<= '0';
		RLS_TIME_SLOT_INDEX			<= 0;

	case CURRENT_STATE is


		when S0 =>
			CMD_ACK_REQ_MEM					<= '0';
			PROCESSOR_DATA_MEM_OUT	<= x"0000";
			OUT_DATA_MEM						<= x"0000";
			ADDRESS_MEM							<= 0;
			WR_MEM									<= '0';
			RLS_TIME_SLOT_ACK_PROC	<= '0';
			RLS_TIME_SLOT						<= '0';
			RLS_TIME_SLOT_INDEX			<= 0;

		when PROCESSOR_TIME => 
			if (HALT_PROCESSOR /= '1') then
				OUT_DATA_MEM 						<= PROCESSOR_DATA_MEM_IN;				
				PROCESSOR_DATA_MEM_OUT 	<= IN_DATA_MEM;
				ADDRESS_MEM 						<= PROCESSOR_ADDRESS_MEM;
				WR_MEM 									<= PROCESSOR_WR_MEM;

				RLS_TIME_SLOT						<= RLS_TIME_SLOT_PROC;
				RLS_TIME_SLOT_INDEX			<= RLS_TIME_SLOT_INDEX_PROC;
				RLS_TIME_SLOT_ACK_PROC	<= RLS_TIME_SLOT_ACK;

			elsif (CMD_REQ_MEM='1') then
				CMD_ACK_REQ_MEM <= '1';

			end if;


		when CMD_TIME =>
			CMD_ACK_REQ_MEM <= '1';
			if (HALT_PROCESSOR = '1' or CMD_WRITE_END = '0') then
				OUT_DATA_MEM <= CMD_DATA_MEM;
				ADDRESS_MEM <= CMD_ADDRESS_MEM;
				WR_MEM <= CMD_WRITE_MEM;
			end if;


	end case;
end process;


end memoryControlAccess;

