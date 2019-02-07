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
	constant ALARM_MSG: 						natural := 	11;
	constant RCV_NOT_FOUND:					natural :=	 2;
	constant MSG_BUFF_FULL:					natural := 	 3;


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
	constant MSG_BUF_SIZE: 					natural := 128;
	constant POT_RAIA_SIZE:					natural :=   2;
	constant MSG_SIZE_TMP: 					natural := 128;
	constant MSG_TMP_BUF_SIZE:			natural := 128;
	constant MAX_MSG_LEN:						natural :=  18;
	constant PCM_SIZE:							natural :=  16; --8;
	constant LINEAR_SIZE:						natural :=  16;
	constant CHANNEL_ID_SIZE:				natural :=   3;
	constant TS_IN_PARAM_SIZE:			natural	:= NUM_CH*NUM_PAR;


---------------------------------------------
--*							ID dos Tons	  	  				  *
---------------------------------------------
	constant ID_DET_DIAL:						natural :=   0;
	constant ID_DET_FAX:     				natural :=   3;
	constant ID_DET_SPEC: 					natural :=   6;
	constant ID_DET_BUSY:						natural :=   9;     
	constant ID_DET_PABX_DIAL:			natural :=  12;

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
	type MSG_BUFFER_TEMP_TYPE is array (0 to MSG_TMP_BUF_SIZE-1) of WORD;

	-- type ARRAY_NUMCH_DT_STATE is array (0 to NUM_CH-1) of DT_STATE;
	type ARRAY_NUMCH_NUM_PAR is array (0 to NUM_CH-1) of natural range 0 to NUM_CH-1;
	type ARRAY_NUM_PAR_WORD is array (0 to NUM_PAR-1) of WORD;






	

end toneDetectorPackage;

package body toneDetectorPackage is

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end toneDetectorPackage;
