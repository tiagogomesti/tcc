

-- library IEEE;
-- use IEEE.STD_LOGIC_1164.all;
-- use IEEE.NUMERIC_STD.ALL;
-- use work.toneDetectorPackage.all;

-- entity toneDetectorValidate_tb is
-- port(
-- 	RESET								: in std_logic;
-- 	CLK									: in std_logic;

-- -- Command Interface
-- 	CMD_TX_DATA					: out unsigned (WORD_SIZE-1 downto 0);
-- 	CMD_WORD_INDEX			: out integer range 0 to 6;
-- 	WRITE_CMD_BUFFER		: out	std_logic;
-- 	CMD_TX							: out std_logic;
-- 	CMD_TX_ACK					: in std_logic;

-- -- Tone Detector Interface
-- 	CLK_8KHz							: in std_logic;

-- 	CMD_RX_DATA					: in unsigned (WORD_SIZE-1 downto 0);
-- 	CMD_WORD_INDEX			: in integer range 0 to 6;
-- 	WRITE_CMD_BUFFER		: in std_logic;
-- 	CMD_RX							: in std_logic;
-- 	CMD_RX_ACK					: out std_logic;

-- 	MSG_TX_DATA					: out unsigned (WORD_SIZE-1 downto 0);
-- 	MSG_TX							: out std_logic;
-- 	MSG_TX_ACK					: in std_logic;	

-- 	TDM_FRAME						: in ARRAY_NUMCH_PCMTYPE;
-- 	CHANNEL_ID					: in natural range 0 to NUM_CH-1;

-- -- Message Interface
-- 	MSG_BUF_FULL				: out std_logic;

-- 	MSG_RX_DATA					: in unsigned (WORD_SIZE-1 downto 0);
-- 	MSG_RX							: in std_logic;

-- 	MSG_TX_DATA					: out unsigned (WORD_SIZE-1 downto 0);
-- 	MSG_TX							: out std_logic;
-- 	MSG_TX_ACK					: in std_logic;

-- -- Tdm Interface
-- 	IN_FRAME									: in ARRAY_NUMCH_PCMTYPE;
-- 	CHANNEL_ID								: in natural range 0 to NUM_CH-1;

-- 	FRAME_DEMUX								: out ARRAY_NUMCH_PCMTYPE
-- );


-- end entity ; -- toneDetectorValidate_tb


-- architecture toneDetectorValidate_tb of toneDetectorValidate_tb is

-- 	signal 

-- begin

-- end architecture ; -- toneDetectorValidate_tb






















