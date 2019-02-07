----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:04:10 02/26/2015 
-- Design Name: 
-- Module Name:    readFile - readFile 
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
-- use std.textio.all;



entity readFile is
generic 
(	channel_index							: integer range 0 to NUM_CH-1 );

port
(
	RST												: in std_logic;
	CLK												: in std_logic;	 -- 8 KHz

	start_read								:	in std_logic;
	stop_read									:	in std_logic;

	numFile										: in natural;

	FRAME											: out PCM_TYPE
);
end readFile;

architecture readFileValidation of readFile is
	type STATE is (WAIT_START_READ,
								 READING_FILE
								);

	signal CURRENT_STATE, NEXT_STATE		: STATE;



	constant timeSlot_string : string := ".\\in_files\\file_";
	constant wav_extension	: string := ".hex.wav";

	-- constant pathString: string := timeSlot_string & integer'image(numFile) & wav_extension;
	-- signal pathString: string ;


--=======================================================================--

	type wordFileType is file of character;
		file timeSlot : wordFileType ; --open read_mode is pathString;	

	signal readHeaderEnd: std_logic := '0';
	

--=======================================================================--
begin


CURRENT_STATE <= NEXT_STATE;
process(CLK,RST, start_read, stop_read)
	variable frame_char_v 	: character;
	variable frame_int_v 		: integer;

	-- variable pathString_v		: string := timeSlot_string & integer'image(numFile) & wav_extension;
	variable fstatus: FILE_OPEN_STATUS;


begin
	if (RST='1') then
		FRAME <= x"EA80";

		NEXT_STATE <= WAIT_START_READ;

	else
		-- FRAME <= x"EA80";

		case CURRENT_STATE is
			when WAIT_START_READ =>	
				if (start_read='0') then
					FRAME <= x"EA80";

					NEXT_STATE <= WAIT_START_READ;

				else
					-- if (readHeaderEnd = '0') then
						-- pathString_v := timeSlot_string & integer'image(numFile) & wav_extension;
						file_open(fstatus, timeSlot, timeSlot_string & integer'image(numFile) & wav_extension, read_mode );

						for i in 0 to LENGTH_HEADER_WAV-1 loop
							read(timeSlot, frame_char_v);
							read(timeSlot, frame_char_v);
						end loop;

						readHeaderEnd <= '1';		

					
					-- else
						FRAME <= x"EA80";
						NEXT_STATE <= READING_FILE;

					-- end if;
				end if;	

			when READING_FILE =>
				if (stop_read='1') then
					file_close(timeSlot);
					FRAME <= x"EA80";

					NEXT_STATE <= WAIT_START_READ;


				else
					-- if (start_read='1') then
					if (CLK'event and CLK='1') then		
						if (not endfile(timeSlot) ) then
							read(timeSlot, frame_char_v);
							frame_int_v := character'pos(frame_char_v);
							FRAME(7 downto 0) <= to_unsigned(frame_int_v,8);

							read(timeSlot, frame_char_v);
							frame_int_v := character'pos(frame_char_v);
							FRAME(15 downto 8) <= to_unsigned(frame_int_v,8);

						else
							FRAME <= x"EA80";
						
						end if;
						-- end if;

						NEXT_STATE <= READING_FILE;
						
					end if ;
				end if;			
		end case;
	end if;



	
end process ; -- 



	-- readProcess: process (CLK,RST, start_read, stop_read)
	-- 	variable frame_char_v 	: character;
	-- 	variable frame_int_v 		: integer;

	-- begin
	-- 	if (RST = '0') then
	-- 		if (CLK'event and CLK='1') then		
	-- 			if (not endfile(timeSlot) ) then
	-- 				read(timeSlot, frame_char_v);
	-- 				frame_int_v := character'pos(frame_char_v);
	-- 				FRAME(7 downto 0) <= to_unsigned(frame_int_v,8);

	-- 				read(timeSlot, frame_char_v);
	-- 				frame_int_v := character'pos(frame_char_v);
	-- 				FRAME(15 downto 8) <= to_unsigned(frame_int_v,8);

	-- 			else
	-- 				FRAME <= x"EA80";
				
	-- 			end if;
	-- 		end if;

	-- 	else
	-- 		FRAME <= x"EA80";
	-- 		if (readHeaderEnd = '0') then
	-- 			for i in 0 to LENGTH_HEADER_WAV-1 loop
	-- 				read(timeSlot, frame_char_v);
	-- 				read(timeSlot, frame_char_v);
	-- 			end loop;

	-- 			readHeaderEnd <= '1';				

	-- 		end if;


	-- 	end if;		
	-- end process;

end readFileValidation;



architecture readFile of readFile is

	constant num_char_of_index : integer := channel_index/10 + 1;
	-- constant timeSlot_string : string := "..\\in_files\\timeSlot_";
	-- constant timeSlot_string : string := "C:\\Users\\Tiago Gomes\\OneDrive\\Tcc\\toneDetector\\in_files\\timeSlot_";
	constant timeSlot_string : string := ".\\in_files\\timeSlot_";

	-- constant timeSlot_string : string := "timeSlot_";
	constant wav_extension	: string := ".wav";

	-- constant length_string : integer 
	-- 		:= num_char_of_index + timeSlot_string'length + wav_extension'length;
	
	constant pathString: string := timeSlot_string & integer'image(channel_index) & wav_extension;

--=======================================================================--

	type wordFileType is file of character;
		file timeSlot : wordFileType open read_mode is pathString;	

	signal readHeaderEnd: std_logic := '0';
	

--=======================================================================--
begin
	
	readProcess: process (CLK,RST)
		variable frame_char_v 	: character;
		variable frame_int_v 		: integer;

	begin
		if (RST = '0') then
			if (CLK'event and CLK='1') then		
				if (not endfile(timeSlot) ) then
					read(timeSlot, frame_char_v);
					frame_int_v := character'pos(frame_char_v);
					FRAME(7 downto 0) <= to_unsigned(frame_int_v,8);

					read(timeSlot, frame_char_v);
					frame_int_v := character'pos(frame_char_v);
					FRAME(15 downto 8) <= to_unsigned(frame_int_v,8);

				else
					FRAME <= x"EA80";
				
				end if;
			end if;

		else
			FRAME <= x"EA80";
			if (readHeaderEnd = '0') then
				for i in 0 to LENGTH_HEADER_WAV-1 loop
					read(timeSlot, frame_char_v);
					read(timeSlot, frame_char_v);
				end loop;

				readHeaderEnd <= '1';				

			end if;


		end if;		
	end process;

end readFile;

