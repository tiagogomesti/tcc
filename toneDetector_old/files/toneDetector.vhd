----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:17:31 10/13/2014 
-- Design Name: 
-- Module Name:    toneDetector - Behavioral 
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
-- use IEEE.std_logic_arith.all;
use work.toneDetectorPackage.all;

use IEEE.NUMERIC_STD.ALL;

entity toneDetector is
port
(	
	RESET								: in std_logic;
	CLK									: in std_logic;

	CLK_8KHz							: in std_logic;

	CMD_RX_DATA					: in unsigned (WORD_SIZE-1 downto 0);
	CMD_WORD_INDEX			: in integer range 0 to 6;
	WRITE_CMD_BUFFER		: in std_logic;
	CMD_RX							: in std_logic;
	CMD_RX_ACK					: out std_logic;

	MSG_TX_DATA					: out unsigned (WORD_SIZE-1 downto 0);
	MSG_TX							: out std_logic;
	MSG_TX_ACK					: in std_logic;	

	TDM_FRAME						: in ARRAY_NUMCH_PCMTYPE;
	CHANNEL_ID					: in natural range 0 to NUM_CH-1
);
end toneDetector;

architecture toneDetector of toneDetector is
	signal CMD_DATA_MEM_S							: unsigned (WORD_SIZE-1 downto 0);
	signal CMD_ADDRESS_MEM_S					: natural range 0 to TS_IN_PARAM_SIZE-1;
	-- signal CMD_ADDRESS_MEM_S				: unsigned (WORD_SIZE-1 downto 0);
	signal CMD_WRITE_MEM_S						: std_logic;
	-- signal CMD_WRITE_MEM_ACK_S				: std_logic;
	-- signal CMD_OP_MEM_S								: std_logic;
	signal CMD_REQ_MEM_S							: std_logic;
	signal CMD_ACK_REQ_MEM_S					: std_logic;
	signal CMD_WRITE_END_S						: std_logic;

	signal RX_BUFFER_S								: ARRAY_NUMCH_PCMTYPE;
	signal PROCESSOR_DATA_MEM_OUT_S		: unsigned (WORD_SIZE-1 downto 0);
	signal PROCESSOR_DATA_MEM_IN_S		: unsigned (WORD_SIZE-1 downto 0);
	signal PROCESSOR_ADDRESS_MEM_S		: integer range 0 to TS_IN_PARAM_SIZE-1;
	signal PROCESSOR_WR_MEM_S					: std_logic;
	-- signal PROCESSOR_WR_MEM_ACK_S			: std_logic;
	-- signal PROCESSOR_OP_MEM_S					: std_logic;
	signal PROCESSOR_HALT_S						: std_logic;
	-- signal PROCESSOR_HALT_ACK_S				: std_logic;

	signal PROCESSOR_MSG_DATA_S				: unsigned (WORD_SIZE-1 downto 0);
	signal PROCESSOR_MSG_TX_S					: std_logic;
	signal PROCESSOR_MSG_ACK_S				: std_logic;

	signal IN_MEMORY_DATA_MEM_S				: unsigned (WORD_SIZE-1 downto 0);		
	signal OUT_MEMORY_DATA_MEM_S			: unsigned (WORD_SIZE-1 downto 0);
	signal MEMORY_ADDRESS_MEM_S				: integer range 0 to TS_IN_PARAM_SIZE-1;	
	signal MEMORY_WR_MEM_S						: std_logic; 
	-- signal MEMORY_WR_MEM_ACK_S				: std_logic;
	-- signal MEMORY_OP_MEM_S						: std_logic;

	signal RLS_TIME_SLOT_PROC_S				: std_logic;
	signal RLS_TIME_SLOT_INDEX_PROC_S	: integer range 0 to NUM_CH-1;
	signal RLS_TIME_SLOT_ACK_PROC_S		: std_logic;

	signal RLS_TIME_SLOT_S						: std_logic;
	signal RLS_TIME_SLOT_INDEX_S			: integer range 0 to NUM_CH-1;
	signal RLS_TIME_SLOT_ACK_S				: std_logic;


begin

commandHandler: entity work.commandHandler(commandHandler)
port map
(
	RESET						=> RESET,		-- ok			
	CLK							=> CLK,			-- ok

	CMD_RX_DATA			=> CMD_RX_DATA, -- ok
	CMD_WORD_INDEX	=> CMD_WORD_INDEX,-- ok
	WRITE_CMD_BUFFER=> WRITE_CMD_BUFFER,
	CMD_RX					=> CMD_RX,-- ok
	CMD_RX_ACK			=> CMD_RX_ACK,-- ok

	DATA_MEM				=> CMD_DATA_MEM_S,   -- ok
	ADDRESS_MEM			=> CMD_ADDRESS_MEM_S,    -- ok
	WRITE_MEM				=> CMD_WRITE_MEM_S,	   -- ok

	REQ_MEM					=> CMD_REQ_MEM_S,   -- ok
	ACK_REQ_MEM			=> CMD_ACK_REQ_MEM_S,   -- ok

	WRITE_END				=> CMD_WRITE_END_S   -- oks
);	


-- memoryControlAccess: entity work.memoryControlAccess(memoryControlAccessNoStateMachine)
memoryControlAccess: entity work.memoryControlAccess(memoryControlAccess)
port map
(
	CLK											=> CLK,
	RST											=> RESET,

	CMD_DATA_MEM						=> CMD_DATA_MEM_S,   -- ok
	CMD_ADDRESS_MEM					=> CMD_ADDRESS_MEM_S,   -- ok
	CMD_WRITE_MEM						=> CMD_WRITE_MEM_S,	   -- ok

	CMD_REQ_MEM							=> CMD_REQ_MEM_S,   -- ok
	CMD_ACK_REQ_MEM					=> CMD_ACK_REQ_MEM_S,   -- ok

	CMD_WRITE_END						=> CMD_WRITE_END_S,	-- ok

	PROCESSOR_DATA_MEM_IN 	=> PROCESSOR_DATA_MEM_OUT_S,   -- ok
	PROCESSOR_DATA_MEM_OUT	=> PROCESSOR_DATA_MEM_IN_S,-- ok
	PROCESSOR_ADDRESS_MEM		=> PROCESSOR_ADDRESS_MEM_S,-- ok
	PROCESSOR_WR_MEM				=> PROCESSOR_WR_MEM_S,-- ok

	HALT_PROCESSOR					=> PROCESSOR_HALT_S,-- ok
	-- HALT_ACK								=> PROCESSOR_HALT_ACK_S,

	OUT_DATA_MEM						=> IN_MEMORY_DATA_MEM_S,
	IN_DATA_MEM							=> OUT_MEMORY_DATA_MEM_S,
	ADDRESS_MEM							=> MEMORY_ADDRESS_MEM_S,
	WR_MEM									=> MEMORY_WR_MEM_S,

	RLS_TIME_SLOT_PROC				=> RLS_TIME_SLOT_PROC_S,
	RLS_TIME_SLOT_INDEX_PROC	=> RLS_TIME_SLOT_INDEX_PROC_S,
	RLS_TIME_SLOT_ACK_PROC		=> RLS_TIME_SLOT_ACK_PROC_S,

	RLS_TIME_SLOT						=> RLS_TIME_SLOT_S,
	RLS_TIME_SLOT_INDEX			=> RLS_TIME_SLOT_INDEX_S,
	RLS_TIME_SLOT_ACK				=> RLS_TIME_SLOT_ACK_S
);




signalProcessor: entity work.signalProcessor(signalProcessorUniqueProcess)
port map
(
	RST												=> RESET,
	CLK												=> CLK,

	CLK_8KHz									=> CLK_8KHz,

	RX_BUFFER									=> RX_BUFFER_S,

	DATA_MEM_OUT							=> PROCESSOR_DATA_MEM_OUT_S,
	DATA_MEM_IN								=> PROCESSOR_DATA_MEM_IN_S,
	ADDRESS_MEM								=> PROCESSOR_ADDRESS_MEM_S,
	WR_MEM										=> PROCESSOR_WR_MEM_S,	

	HALT											=> PROCESSOR_HALT_S,
	
	RLS_TIME_SLOT_PROC				=> RLS_TIME_SLOT_PROC_S,
	RLS_TIME_SLOT_INDEX_PROC	=> RLS_TIME_SLOT_INDEX_PROC_S,
	RLS_TIME_SLOT_ACK_PROC		=> RLS_TIME_SLOT_ACK_PROC_S,

	MSG_DATA									=> PROCESSOR_MSG_DATA_S,
	MSG_TX										=> PROCESSOR_MSG_TX_S,
	MSG_ACK_TX								=> PROCESSOR_MSG_ACK_S
);

tdmSwitch: entity work.tdmSwitch(tdmSwitch)
port map
(
	RST												=> RESET,
	CLK												=> CLK,
	
	IN_FRAME									=> TDM_FRAME,
	CHANNEL_ID								=> CHANNEL_ID,
	
	FRAME_DEMUX								=> RX_BUFFER_S
);




messageHandler: entity work.messageHandler(messageHandler)
port map
(
	RST									=> RESET,
	CLOCK								=> CLK,

	MSG_RX_DATA					=> PROCESSOR_MSG_DATA_S,
	MSG_RX							=> PROCESSOR_MSG_TX_S,
	MSG_RX_ACK					=> PROCESSOR_MSG_ACK_S,

	MSG_TX_DATA					=> MSG_TX_DATA,
	MSG_TX							=> MSG_TX,
	MSG_TX_ACK					=> MSG_TX_ACK
);

tsParam_memory: entity work.tsParam_memory(tsParam_memory)
port map
(
	RESET 							=> RESET,
	CLOCK 							=> CLK,

	RLS_TIME_SLOT				=> RLS_TIME_SLOT_S,
	RLS_TIME_SLOT_INDEX	=> RLS_TIME_SLOT_INDEX_S,
	RLS_TIME_SLOT_ACK		=> RLS_TIME_SLOT_ACK_S,

	WR_ENABLE 					=> MEMORY_WR_MEM_S,
	DATA_IN 						=> IN_MEMORY_DATA_MEM_S,
	DATA_OUT 						=> OUT_MEMORY_DATA_MEM_S,
	ADDR								=> MEMORY_ADDRESS_MEM_S
);

end toneDetector;







	






