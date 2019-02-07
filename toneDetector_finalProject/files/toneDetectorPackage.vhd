library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;


package toneDetectorPackage is

--*******************************************
--*						CONSTANTES INDEPENDETES			  *
--*******************************************
---------------------------------------------
--*								Mensagens	  	  				  *
---------------------------------------------
constant TS_PROC_SUCCESS:					unsigned	:= x"aa";
constant TS_PROC_TIME_OUT_PULSE:	unsigned	:= x"ff";
constant TS_PROC_TIME_OUT_PAUSE:	unsigned	:= x"fe";


---------------------------------------------
--*						Detectores de Tons 				  	*
---------------------------------------------
	constant NUM_CH_DET:						natural 	:=   8;
	constant NUM_CH:								natural 	:=   NUM_CH_DET;
	constant NUM_TONE_DET:					natural 	:=   5;
	constant NUM_TONE_PAR:					natural 	:=   6; -- Parâmetros CONF_TONE_DET
	constant NUM_PAR:								natural 	:=  12; -- Parâmetros TS_IN_PARAM

	constant DT_STATE0:							unsigned	:= x"0";
	constant DT_STATE1:							unsigned	:= x"1";
	constant DT_STATE2:							unsigned	:= x"2";
	constant DT_STATE3:							unsigned	:= x"3";
	
---------------------------------------------
--*								Clocks				 				  	*
---------------------------------------------
	constant CLOCK_PERIOD:					time := 12.5 ns;	
	constant CLOCK_PERIOD_8KH:			time := 125  us;	
	constant CLOCK_PERIOD_TDM:			time := CLOCK_PERIOD_8KH/NUM_CH_DET;

	constant CYCLES_HOLD_INT_CLK_8Hz:	natural := 10;




---------------------------------------------
--*								Tamanhos	  	  				  *
---------------------------------------------
	constant WORD_SIZE: 						natural := 	16; -- Tamanho da palavra
	constant HALF_WORD_SIZE:				natural :=   8;
	constant ACCUMULATOR_SIZE:			natural :=	2*WORD_SIZE;
	constant NATURAL_8BITS:					natural := 255; 
	constant LENGTH_HEADER_WAV:			natural := 	22;
	constant CMD_BUF_SIZE: 					natural := 	 7; -- 32; -- Tamanho do Buffer de Recepção de comando
	constant MSG_BUF_SIZE: 					natural := 	32;
	constant POT_RAIA_SIZE:					natural :=   2;
	constant MSG_SIZE_TMP: 					natural := 128;
	constant MAX_MSG_LEN:						natural :=  18;
	constant PCM_SIZE:							natural :=  16; --8;
	constant LINEAR_SIZE:						natural :=  16;
	constant CHANNEL_ID_SIZE:				natural :=   3;
	constant TS_IN_PARAM_SIZE:			natural	:= NUM_CH*NUM_PAR;


---------------------------------------------
--*			Valores Limites para Detecção	  	  *
---------------------------------------------
	constant LEVEL:									natural := 880;
	constant TONE_LEVEL:						natural :=  32;
	constant CNT_TONE:							natural := 	80;	
	constant TIME_OUT_PULSE:				natural := 250;
	constant TIME_OUT_PAUSE:   			natural := 200;


--*******************************************
--*						CONSTANTES DEPENDETES			    *
--*******************************************	
		
---------------------------------------------
--*						SubTipos, Tipos...	  	  	  *
---------------------------------------------

	-- Vetores
	subtype WORD is unsigned(WORD_SIZE-1 downto 0);

	subtype ARRAY_NUMCH is std_logic_vector(0 to NUM_CH-1);
	subtype PCM_TYPE is unsigned(PCM_SIZE-1 downto 0);
	subtype CHANNEL_ID_LOGIC_VECTOR is unsigned(CHANNEL_ID_SIZE-1 downto 0);
	subtype LINEAR_TYPE is std_logic_vector(LINEAR_SIZE-1 downto 0);	
	-- type    DT_STATE is (DT_STATE0, DT_STATE1, DT_STATE2, DT_STATE3);
	-- subtype ARRAY_NUMCH_PCMTYPE is std_logic_vector(0 to WORD_SIZE*PCM_SIZE-1);

	-- Arrays
	type ARRAY_NUMCH_WORD is array (0 to NUM_CH-1) of WORD;
	type ARRAY_NUMCH_PCMTYPE is array (0 to NUM_CH-1) of PCM_TYPE;
	-- type ARRAY_NUMCH_PCMTYPE is array (0 to NUM_CH-1) of PCM_TYPE;

	type CMD_BUFFER_TYPE is array (0 to CMD_BUF_SIZE-1) of WORD;
	type CONF_TONE_DET_TYPE is array (0 to NUM_TONE_PAR) of WORD;
	type TS_IN_PARAM_TYPE is array (0 to TS_IN_PARAM_SIZE-1) of WORD;
	type POT_RAIA_TYPE is array (0 to POT_RAIA_SIZE-1) of WORD;
	type MSG_BUFFER_TYPE is array (0 to MSG_BUF_SIZE-1) of WORD;

	-- type ARRAY_NUMCH_DT_STATE is array (0 to NUM_CH-1) of DT_STATE;
	type ARRAY_NUMCH_NUM_PAR is array (0 to NUM_CH-1) of natural range 0 to NUM_CH-1;
	type ARRAY_NUM_PAR_WORD is array (0 to NUM_PAR-1) of WORD;




--*******************************************
--*						ARRAY PARA TESTES   			    *
--*******************************************	
	constant DIAL_TONE				: natural := 0; 
	constant FAX_TONE					: natural := 1;
	constant SPECIAL_TONE			: natural := 2;
	constant BUSY_TONE				: natural := 3;
	constant PABX_TONE				: natural := 4;

	type time_NumPorts			is array (0 to NUM_CH-1) of time;

	type ioFrameControlType is array (0 to NUM_CH-1) of unsigned(1 downto 0);
	type ioFrameNumFileType	is array (0 to NUM_CH-1) of natural;


	constant numParamTEST					: natural := CMD_BUF_SIZE-1;
	type array_numParamTEST is array (0 to numParamTEST-1) of WORD;

	constant NumToneTests					: natural := 5;

	type array_NumToneTests_array_numParamTEST is array (0 to NumToneTests-1) of array_numParamTEST;


	constant LUT_TONE_PARAM				: array_NumToneTests_array_numParamTEST
							:=(
									(x"0025", x"0000", x"0300", x"0015", x"7942", x"789a"), -- DIAL TONE
									(x"9628", x"0064", x"0300", x"0050", x"5321", x"5321"), -- FAX TONE
									(x"0c08", x"0702", x"0300", x"0015", x"7bfa", x"7b76"), -- SPECIAL TONE
									(x"3214", x"3214", x"0302", x"0015", x"7942", x"789a"), -- BUSY TONE
									(x"000a", x"0000", x"0300", x"0015", x"7942", x"789a")  -- PABX TONE
								);


	procedure cmd_write_proc_tb(
			signal RESET								: in std_logic;
			signal CLK									: in std_logic;

			signal TIMESLOT							: in natural range 0 to NUM_CH-1;
			signal MAX_MIN_PULSE				: in unsigned (WORD_SIZE-1 downto 0);
			signal MAX_MIN_PAUSE				: in unsigned (WORD_SIZE-1 downto 0);
			signal ATTENUATION_CADENCE	: in unsigned (WORD_SIZE-1 downto 0);
			signal THRESHOLD						: in unsigned (WORD_SIZE-1 downto 0);
			signal COEFF1								: in unsigned (WORD_SIZE-1 downto 0);
			signal COEFF2								: in unsigned (WORD_SIZE-1 downto 0);

			signal CMD_TX_DATA					: out unsigned (WORD_SIZE-1 downto 0);
			signal CMD_WORD_INDEX				: out integer range 0 to 6;
			signal WRITE_CMD_BUFFER			: out	std_logic;
			signal CMD_TX								: out std_logic;
			signal CMD_TX_ACK						: in std_logic	
		);

	

end toneDetectorPackage;

package body toneDetectorPackage is

	procedure cmd_write_proc_tb(
			signal RESET								: in std_logic;
			signal CLK									: in std_logic;

			signal TIMESLOT							: in natural range 0 to NUM_CH-1;
			signal MAX_MIN_PULSE				: in unsigned (WORD_SIZE-1 downto 0);
			signal MAX_MIN_PAUSE				: in unsigned (WORD_SIZE-1 downto 0);
			signal ATTENUATION_CADENCE	: in unsigned (WORD_SIZE-1 downto 0);
			signal THRESHOLD						: in unsigned (WORD_SIZE-1 downto 0);
			signal COEFF1								: in unsigned (WORD_SIZE-1 downto 0);
			signal COEFF2								: in unsigned (WORD_SIZE-1 downto 0);

			signal CMD_TX_DATA					: out unsigned (WORD_SIZE-1 downto 0);
			signal CMD_WORD_INDEX				: out integer range 0 to 6;
			signal WRITE_CMD_BUFFER			: out	std_logic;
			signal CMD_TX								: out std_logic;
			signal CMD_TX_ACK						: in std_logic	) is
	begin

		CMD_TX <= '1'; 

--		wait until CMD_TX_ACK = '1';
--		wait for CLOCK_PERIOD;
--
--		CMD_WORD_INDEX <= 0;
--		wait for CLOCK_PERIOD;
--		-- CMD_TX_DATA	<= to_unsigned(port_ts,WORD_SIZE);
--		CMD_TX_DATA	<= to_unsigned(TIMESLOT,WORD_SIZE);
--		WRITE_CMD_BUFFER <= '1';
--
--		CMD_WORD_INDEX <= 1;
--		wait for CLOCK_PERIOD;
--		-- CMD_TX_DATA	<= LUT_TONE_PARAM(tone_id)(0);
--		CMD_TX_DATA	<= MAX_MIN_PULSE;
--
--
--		CMD_WORD_INDEX <= 2;
--		wait for CLOCK_PERIOD;
--		-- CMD_TX_DATA	<= LUT_TONE_PARAM(tone_id)(1);		
--		CMD_TX_DATA	<= MAX_MIN_PAUSE;
--
--		CMD_WORD_INDEX <= 3;
--		wait for CLOCK_PERIOD;
--		-- CMD_TX_DATA	<= LUT_TONE_PARAM(tone_id)(2);
--		CMD_TX_DATA	<= ATTENUATION_CADENCE;
--
--		CMD_WORD_INDEX <= 4;
--		wait for CLOCK_PERIOD;
--		-- CMD_TX_DATA	<= LUT_TONE_PARAM(tone_id)(3);
--		CMD_TX_DATA	<= THRESHOLD;
--		
--		CMD_WORD_INDEX <= 5;
--		wait for CLOCK_PERIOD;
--		-- CMD_TX_DATA	<= LUT_TONE_PARAM(tone_id)(4);
--		CMD_TX_DATA	<= COEFF1;
--		
--		CMD_WORD_INDEX <= 6;
--		wait for CLOCK_PERIOD;
--		-- CMD_TX_DATA	<= LUT_TONE_PARAM(tone_id)(5);
--		CMD_TX_DATA	<= COEFF2;
--		
--		wait for CLOCK_PERIOD;
--
--		WRITE_CMD_BUFFER <= '0';
--		CMD_TX <= '0';
--
--
--		wait for CLOCK_PERIOD;
--		wait for CLOCK_PERIOD;


	end cmd_write_proc_tb;


	


 
end toneDetectorPackage;
