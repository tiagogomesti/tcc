----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:22:08 10/13/2014 
-- Design Name: 
-- Module Name:    signalProcessor - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM; 
--use UNISIM.VComponents.all;

entity signalProcessor is
port
(
	RST												: in std_logic;
	CLK												: in std_logic;

	CLK_8KHz									: in std_logic;

	RX_BUFFER									: in ARRAY_NUMCH_PCMTYPE;

	DATA_MEM_OUT							: out unsigned (WORD_SIZE-1 downto 0);
	DATA_MEM_IN								: in unsigned (WORD_SIZE-1 downto 0);
	ADDRESS_MEM								: out integer range 0 to TS_IN_PARAM_SIZE-1;
	WR_MEM										: out std_logic;	

	HALT											: out std_logic;
	
	RLS_TIME_SLOT_PROC				: out std_logic;
	RLS_TIME_SLOT_INDEX_PROC	: out integer range 0 to NUM_CH-1;
	-- RLS_TIME_SLOT_ACK_PROC		: in std_logic;	

	MSG_DATA									: out unsigned (WORD_SIZE-1 downto 0);
	MSG_TX										: out std_logic;
	-- MSG_ACK_TX								: in std_logic;

	MSG_BUF_FULL							: in std_logic
);
end signalProcessor;

architecture signalProcessorUniqueProcess of signalProcessor is
	type		STATE is (S0,
										GET_TS,
										GET_TS_INC,
										PROCESSING_TS,
										GORTZEL_COEFF1,
										-- GORTZEL_COEFF2,
										POWER_COEFF1,
										POWER_COEFF2,
										VERIFICATION,
										SET_TS,
										SEND_MSG,
										NEXT_PORT,
										HALT_PROC
										);
	signal	NEXT_STATE, CURRENT_STATE : STATE;

	signal ts_word_counter_s				: natural range 0 to NUM_PAR;
	signal ts_param_buf_s						: ARRAY_NUM_PAR_WORD;	
	signal port_proc_s							: natural range 0 to NUM_CH-1;

	signal proc_trigger_s						: std_logic;
	signal proc_trigger_reset_s			: std_logic;

	-- signal rx_frame_s								: signed (WORD_SIZE-1 downto 0);
	-- signal POT1_s, POT2_s						: signed (WORD_SIZE-1 downto 0);
	signal POT1_s, POT2_s						: signed (WORD_SIZE downto 0);

	signal TIME_OUT_MSG_s						: unsigned(7 downto 0);



begin



proc_trigger: process (RST, CLK_8KHz, proc_trigger_reset_s)
begin
	if (proc_trigger_reset_s = '1') then
		proc_trigger_s  <= '0';

	else
		if (CLK_8KHz'event and CLK_8KHz='1') then
			if (RST='1') then
				proc_trigger_s  <= '0';

			else
				proc_trigger_s  <= '1';

			end if;
		end if;
	end if;
end process;


CURRENT_STATE <= NEXT_STATE;



main_process:process (CLK,RST)

	variable ts_word_counter_v		: natural range 0 to NUM_PAR-1 := 0;
	variable rx_frame_v						: signed (WORD_SIZE-1 downto 0);

	-- variable aux_int_V						: integer range 0 to 10‬;	
	-- variable aux_int_V						: integer range -32768 to 32767‬;	

	variable A_ACC_v							: signed (ACCUMULATOR_SIZE-1 downto 0);
	variable B_ACC_v							: signed (ACCUMULATOR_SIZE-1 downto 0);
	variable POT1, POT2						: signed  (WORD_SIZE-1 downto 0);

	
	variable state_v							: unsigned (3 downto 0);
	variable flag_msg_sent_v			: unsigned (7 downto 4);
	variable counter_of_samples_v : unsigned (15 downto 8);
	variable min_pulse_v					: unsigned (7 downto 0);
	variable max_pulse_v					: unsigned (15 downto 8);
	variable min_pause_v					: unsigned (7 downto 0);
	variable max_pause_v					: unsigned (15 downto 8);
	variable cadence_v						: unsigned (3 downto 0);
	variable cnt_cadence_v				: unsigned (7 downto 4);
	variable attenuation_v				: natural range 0 to NATURAL_8BITS;
	variable threshold_v					: signed (15 downto 0);
	variable coeff1_v							: signed (15 downto 0);
	variable coeff2_v							: signed (15 downto 0);
	variable sample_1_coeff_1_v		: signed (15 downto 0);
	variable sample_2_coeff_1_v		: signed (15 downto 0);
	variable sample_1_coeff_2_v		: signed (15 downto 0);
	variable sample_2_coeff_2_v		: signed (15 downto 0);
	variable cnt_pause_v					: unsigned (7 downto 0);
	variable cnt_pulse_v					: unsigned (15 downto 8);

	variable tone_level_v					: signed (15 downto 0);
	variable previous_sample_v		: signed (15 downto 0);

begin
if (CLK'event and CLK='1') then
	if (RST='1') then
		ts_word_counter_s						<= 0;
		ts_param_buf_s							<= (others => x"0000");
		port_proc_s									<= 0;

		DATA_MEM_OUT								<= (others => '0');
		ADDRESS_MEM									<= 0;
		WR_MEM											<= '0';
		HALT												<= '0';
		RLS_TIME_SLOT_PROC					<= '0';
		RLS_TIME_SLOT_INDEX_PROC		<= 0;
		MSG_DATA										<= (others => '0');
		MSG_TX											<= '0';

		POT1_s											<= (others => '0');
		POT2_s											<= (others => '0');
		-- rx_frame_s									<= (others => '0');

		NEXT_STATE <= S0;

	else
		case CURRENT_STATE is
--********************************--
--            S0 state            --
--********************************--

			when S0 => 
				ts_word_counter_s						<= 0;
				ts_param_buf_s							<= (others => x"0000");
				port_proc_s									<= 0;

				DATA_MEM_OUT								<= (others => '0');
				ADDRESS_MEM									<= 0;
				WR_MEM											<= '0';
				HALT												<= '0';
				RLS_TIME_SLOT_PROC					<= '0';
				RLS_TIME_SLOT_INDEX_PROC		<= 0;
				MSG_DATA										<= (others => '0');
				MSG_TX											<= '0';

				proc_trigger_reset_s <= '0';

				POT1_s											<= (others => '0');
				POT2_s											<= (others => '0');


				-- rx_frame_s									<= (others => '0');
				NEXT_STATE <= GET_TS;

--********************************--
--          GET_TS state          --
--********************************--

			when GET_TS =>
				WR_MEM <= '0';

				if (ts_word_counter_s >= NUM_PAR) then 	
					NEXT_STATE	<= PROCESSING_TS;
					ts_word_counter_s <= 0;

				elsif ( (ts_word_counter_s = 1) and ( ts_param_buf_s(0) = x"ffff") ) then
					NEXT_STATE 			<= NEXT_PORT;
					ts_word_counter_s <= 0;

					
				else
					ts_word_counter_v 									:= ts_word_counter_s;
					ADDRESS_MEM 												<= port_proc_s*NUM_PAR + ts_word_counter_v;
					NEXT_STATE 													<= GET_TS_INC;
				
				end if;			

--********************************--
--       GET_TS_INC state         --
--********************************--

			when GET_TS_INC =>
					ts_param_buf_s(ts_word_counter_v)		<= DATA_MEM_IN;		
					ts_word_counter_s 									<= ts_word_counter_s+1;

					NEXT_STATE 													<= GET_TS;



--********************************--
--      PROCESSING_TS state       --
--********************************--

			when PROCESSING_TS =>
				NEXT_STATE 	<= SET_TS;

				state_v							 	:= ts_param_buf_s(0)(3 downto 0);
				flag_msg_sent_v			 	:= ts_param_buf_s(0)(7 downto 4);

				attenuation_v					:= to_integer(ts_param_buf_s(3)(15 downto 8));

				tone_level_v					:= signed(ts_param_buf_s(7)(15 downto 0));
				previous_sample_v			:= signed(ts_param_buf_s(8)(15 downto 0));

				rx_frame_v 						:= signed(RX_BUFFER(port_proc_s));



--------------------------------------------------
--  					 				STATE 0 					        --
--------------------------------------------------
				if (state_v = DT_STATE0) then

					if ( to_integer(tone_level_v) < TONE_LEVEL ) then
						tone_level_v	:= tone_level_v+1;
						rx_frame_v := abs(rx_frame_v);

						if ( previous_sample_v < rx_frame_v) then
							previous_sample_v := rx_frame_v;
							
						else
							previous_sample_v := previous_sample_v;
							
						end if;

						state_v						 := DT_STATE0;
						sample_1_coeff_1_v := tone_level_v;
						sample_2_coeff_1_v := previous_sample_v;

					else
						if( previous_sample_v >= LEVEL) then
							state_v := DT_STATE1;

						else
							state_v := DT_STATE0; 	

						end if;
										
						sample_1_coeff_1_v := (others => '0');
						sample_2_coeff_1_v := (others => '0');
								
					end if;

					ts_param_buf_s(7)(15 downto 0) 	<= unsigned(sample_1_coeff_1_v);
					ts_param_buf_s(8)(15 downto 0) 	<= unsigned(sample_2_coeff_1_v);


--------------------------------------------------
--  					   STATE 1 or STATE2			        --
--------------------------------------------------
				elsif (state_v=DT_STATE1 or state_v=DT_STATE2) then
					----------------------------------
					--    Attenuation of sample     --
					----------------------------------					
					rx_frame_v( (15-attenuation_v-1) downto 0) := rx_frame_v(15 downto attenuation_v+1);

					if (rx_frame_v(15) = '1') then
						rx_frame_v(15 downto (15-attenuation_v)) := (others => '1');

					else
						rx_frame_v(15 downto (15-attenuation_v)) := (others => '0');

					end if;

					-- rx_frame_s <= rx_frame_v;					

					NEXT_STATE <= GORTZEL_COEFF1;


--------------------------------------------------
--  					 				STATE 3 					        --
--------------------------------------------------						
				else --state_v = DT_STATE3
					if (flag_msg_sent_v = x"1") then
						RLS_TIME_SLOT_PROC				<= '1';
						RLS_TIME_SLOT_INDEX_PROC	<= port_proc_s;
						NEXT_STATE 	<= NEXT_PORT;
						

					else
						if (MSG_BUF_FULL = '0') then
							MSG_TX		<= '1';
							-- MSG_DATA(15 downto 8) <= TS_PROC_SUCCESS;
							-- MSG_DATA( 7 downto 0) <= to_unsigned(port_proc_s, 8);						
							-- flag_msg_sent_v := x"1";	

							TIME_OUT_MSG_s	<= TS_PROC_SUCCESS;						
							NEXT_STATE			<= SEND_MSG;

						else 
							MSG_TX		<= '0';
							flag_msg_sent_v := x"0";	
							NEXT_STATE 	<= SET_TS;

						end if;
					end if;	
				end if;

				ts_param_buf_s(0)(3 downto 0) 	<= state_v;
				ts_param_buf_s(0)(7 downto 4) 	<= flag_msg_sent_v;
				-- ts_param_buf_s(7)(15 downto 0) 	<= unsigned(sample_1_coeff_1_v);
				-- ts_param_buf_s(8)(15 downto 0) 	<= unsigned(sample_2_coeff_1_v);
									

			
--********************************--
--     GORTZEL_COEFF1 state       --
--********************************--
			when GORTZEL_COEFF1 =>
				coeff1_v							:= signed(ts_param_buf_s( 5)(15 downto 0));
				sample_1_coeff_1_v		:= signed(ts_param_buf_s( 7)(15 downto 0));
				sample_2_coeff_1_v		:= signed(ts_param_buf_s( 8)(15 downto 0));

				-- --------------------------------
				-- -- Goertzel for Coeff1      --
				-- --------------------------------
				A_ACC_v := coeff1_v*sample_1_coeff_1_v;
				A_ACC_v(31 downto 2) := A_ACC_v(29 downto 0);
				A_ACC_v(1 downto 0) := (others => '0');

				B_ACC_v := rx_frame_v - sample_2_coeff_1_v + x"00000000";
				B_ACC_v(31 downto 16) := B_ACC_v(15 downto 0);
				B_ACC_v(15 downto 0) := (others => '0');

				sample_2_coeff_1_v := sample_1_coeff_1_v;
				A_ACC_v := A_ACC_v+B_ACC_v;
				sample_1_coeff_1_v := A_ACC_v(31 downto 16);

				-- NEXT_STATE <= GORTZEL_COEFF2;

				-- rx_frame_s <= rx_frame_s;

				ts_param_buf_s(7)(15 downto 0) 	<= unsigned(sample_1_coeff_1_v);
				ts_param_buf_s(8)(15 downto 0) 	<= unsigned(sample_2_coeff_1_v);

--********************************--
--     GORTZEL_COEFF2 state       --
--********************************--
			-- when GORTZEL_COEFF2 =>
				counter_of_samples_v  := ts_param_buf_s(0)(15 downto 8);
				coeff2_v							:= signed(ts_param_buf_s( 6)(15 downto 0));
				sample_1_coeff_2_v		:= signed(ts_param_buf_s( 9)(15 downto 0));
				sample_2_coeff_2_v		:= signed(ts_param_buf_s(10)(15 downto 0));


			----------------------------------
			--     Goertzel for Coeff2      --
			----------------------------------	
				A_ACC_v := coeff2_v*sample_1_coeff_2_v;           -- 1
				A_ACC_v(31 downto 2) := A_ACC_v(29 downto 0);           -- 2
				A_ACC_v(1 downto 0) := (others => '0');           -- 3

				B_ACC_v := rx_frame_v - sample_2_coeff_2_v + x"00000000";           -- 4
				B_ACC_v(31 downto 16) := B_ACC_v(15 downto 0);           -- 5
				B_ACC_v(15 downto 0) := (others => '0');           -- 6

				sample_2_coeff_2_v := sample_1_coeff_2_v;           -- 7
				A_ACC_v := A_ACC_v+B_ACC_v;           -- 8
				sample_1_coeff_2_v := A_ACC_v(31 downto 16);           -- 9

				counter_of_samples_v := counter_of_samples_v+1;

				if (counter_of_samples_v < CNT_TONE) then
						NEXT_STATE <= SET_TS;

				else					
					counter_of_samples_v := (others => '0');
					NEXT_STATE <= POWER_COEFF1;

				end if;					

				ts_param_buf_s(0)(15 downto 8) 	<= counter_of_samples_v;
				ts_param_buf_s(9)(15 downto 0) 	<= unsigned(sample_1_coeff_2_v);
				ts_param_buf_s(10)(15 downto 0) <= unsigned(sample_2_coeff_2_v);




--********************************--
-- 	    POWER_COEFF1 state        --
--********************************--
			when POWER_COEFF1 =>
				coeff1_v							:= signed(ts_param_buf_s( 5)(15 downto 0));
				sample_1_coeff_1_v		:= signed(ts_param_buf_s( 7)(15 downto 0));
				sample_2_coeff_1_v		:= signed(ts_param_buf_s( 8)(15 downto 0));

				----------------------------------
				--       Power for Coeff1       --
				----------------------------------
				A_ACC_v := sample_1_coeff_1_v*sample_1_coeff_1_v; -- 1
				B_ACC_v := sample_2_coeff_1_v*sample_2_coeff_1_v; -- 2

				A_ACC_v := A_ACC_v+B_ACC_v; -- 3

				B_ACC_v := coeff1_v*sample_1_coeff_1_v; -- 4
				B_ACC_v := sample_2_coeff_1_v*B_ACC_v(31 downto 16); -- 5
				B_ACC_v(31 downto 1) := B_ACC_v(30 downto 0); -- 6
				B_ACC_v(0) := '0';

				A_ACC_v 	:= A_ACC_v-B_ACC_v;		 -- 7
				POT1_s(WORD_SIZE-1 downto 0)  	<= A_ACC_v(31 downto 16); -- 8
				POT1_s(WORD_SIZE) <= '0';


				NEXT_STATE <= POWER_COEFF2;

--********************************--
-- 	    POWER_COEFF2 state        --
--********************************--		
			when POWER_COEFF2 =>
				coeff2_v							:= signed(ts_param_buf_s( 6)(15 downto 0));
				sample_1_coeff_2_v		:= signed(ts_param_buf_s( 9)(15 downto 0));
				sample_2_coeff_2_v		:= signed(ts_param_buf_s(10)(15 downto 0));

				----------------------------------
				--       Power for Coeff2       --
				----------------------------------

				A_ACC_v := sample_1_coeff_2_v*sample_1_coeff_2_v;
				B_ACC_v := sample_2_coeff_2_v*sample_2_coeff_2_v;

				A_ACC_v := A_ACC_v+B_ACC_v;

				B_ACC_v := coeff2_v*sample_1_coeff_2_v;
				B_ACC_v := sample_2_coeff_2_v*B_ACC_v(31 downto 16);
				B_ACC_v(31 downto 1) := B_ACC_v(30 downto 0);
				B_ACC_v(0) := '0';

				A_ACC_v := A_ACC_v-B_ACC_v;		
				POT2_s(WORD_SIZE-1 downto 0)  <= A_ACC_v(31 downto 16);
				POT2_s(WORD_SIZE) <= '0';


				NEXT_STATE <= VERIFICATION;

--********************************--
-- 	    VERIFICATION state        --
--********************************--
			when VERIFICATION =>
				state_v							 	:= ts_param_buf_s(0)(3 downto 0);
				flag_msg_sent_v			 	:= ts_param_buf_s(0)(7 downto 4);
				min_pulse_v					 	:= ts_param_buf_s(1)(7 downto 0);
				max_pulse_v					 	:= ts_param_buf_s(1)(15 downto 8);
				min_pause_v					 	:= ts_param_buf_s(2)(7 downto 0);
				max_pause_v					 	:= ts_param_buf_s(2)(15 downto 8);
				cadence_v						 	:= ts_param_buf_s(3)(3 downto 0);
				cnt_cadence_v				 	:= ts_param_buf_s(3)(7 downto 4);
				threshold_v					 	:= signed(ts_param_buf_s( 4)(15 downto 0));
				cnt_pause_v					 	:= ts_param_buf_s(11)(7 downto 0);
				cnt_pulse_v					 	:= ts_param_buf_s(11)(15 downto 8);
				sample_1_coeff_1_v		:= signed(ts_param_buf_s( 7)(15 downto 0));
				sample_2_coeff_1_v		:= signed(ts_param_buf_s( 8)(15 downto 0));
				sample_1_coeff_2_v		:= signed(ts_param_buf_s( 9)(15 downto 0));
				sample_2_coeff_2_v		:= signed(ts_param_buf_s(10)(15 downto 0));

				NEXT_STATE <= SET_TS;

				if (state_v = DT_STATE1) then
					if (POT1_s>=threshold_v or POT2_s>=threshold_v) then
						if (cnt_pulse_v < TIME_OUT_PULSE) then
							cnt_pulse_v := cnt_pulse_v+1;

							if (min_pause_v = x"00") then			-- is a continuous tone
								if (cnt_pulse_v = min_pulse_v) then
									state_v := DT_STATE3;

								else
									state_v := DT_STATE1;

								end if;

							else
								state_v := DT_STATE1;

							end if;

						else
							counter_of_samples_v 	:= (others => '0');
							cnt_cadence_v 				:= (others => '0');
							cnt_pulse_v						:= (others => '0');
							cnt_pause_v						:= (others => '0');
							sample_1_coeff_1_v		:= (others => '0');
							sample_2_coeff_1_v		:= (others => '0');
							sample_1_coeff_2_v		:= (others => '0');
							sample_2_coeff_2_v		:= (others => '0');

							MSG_TX								<= '1';
							state_v 							:= DT_STATE0;

							TIME_OUT_MSG_s				<= TS_PROC_TIME_OUT_PULSE;

							NEXT_STATE						<= SEND_MSG;

						end if;

					else
						cnt_pause_v := x"01";
						state_v := DT_STATE2;

					end if;


				else -- DT_STATE2
					if (POT1_s<threshold_v and POT2_s<threshold_v) then      -- PAUSE
						if (cnt_pause_v < TIME_OUT_PAUSE) then
							cnt_pause_v := cnt_pause_v+1;

							if (max_pause_v = x"00") then
								if (cnt_pause_v > min_pause_v) then
									state_v := DT_STATE3;

								else
									state_v := DT_STATE2;								

								end if ;

							else
								state_v := DT_STATE2;
								
							end if ;
						
						else
							counter_of_samples_v 	:= (others => '0');
							cnt_cadence_v 				:= (others => '0');
							cnt_pulse_v						:= (others => '0');
							cnt_pause_v						:= (others => '0');
							sample_1_coeff_1_v		:= (others => '0');
							sample_2_coeff_1_v		:= (others => '0');
							sample_1_coeff_2_v		:= (others => '0');
							sample_2_coeff_2_v		:= (others => '0');

							MSG_TX								<= '1';
							state_v 							:= DT_STATE0;

							TIME_OUT_MSG_s				<= TS_PROC_TIME_OUT_PAUSE;

							NEXT_STATE						<= SEND_MSG;

						end if;


					else -- PULSE
						if (cadence_v > x"0") then
							if (cnt_pulse_v>min_pulse_v and cnt_pulse_v<max_pulse_v and
										cnt_pause_v>min_pause_v and cnt_pause_v<max_pause_v) then

								cnt_cadence_v := cnt_cadence_v+1;
								if (cnt_cadence_v > cadence_v) then
									state_v := DT_STATE3;

								else
									cnt_pulse_v := x"01";
									cnt_pause_v := x"00";
									state_v			:= DT_STATE1;
									
								end if ;

							else
								cnt_cadence_v := x"0";
								cnt_pulse_v 	:= x"01";
								cnt_pause_v 	:= x"00";
								state_v				:= DT_STATE1;

								
							end if ;

						else 		-- NOT CADENCE
							if (cnt_pulse_v>min_pulse_v and cnt_pulse_v<max_pulse_v and
										cnt_pause_v>min_pause_v and cnt_pause_v<max_pause_v) then

								state_v := DT_STATE3;

							else
								cnt_pulse_v 	:= x"01";
								cnt_pause_v 	:= x"00";
								state_v				:= DT_STATE1;
								
							end if ;							
						end if ;						
					end if ;
				end if;
				
				sample_1_coeff_1_v := (others => '0');
				sample_2_coeff_1_v := (others => '0');
				sample_1_coeff_2_v := (others => '0');
				sample_2_coeff_2_v := (others => '0');

				ts_param_buf_s(0)(3 downto 0) 	<= state_v;
				ts_param_buf_s(0)(7 downto 4) 	<= flag_msg_sent_v;
				ts_param_buf_s(3)(7 downto 4) 	<= cnt_cadence_v;
				ts_param_buf_s(7)(15 downto 0) 	<= unsigned(sample_1_coeff_1_v);
				ts_param_buf_s(8)(15 downto 0) 	<= unsigned(sample_2_coeff_1_v);
				ts_param_buf_s(9)(15 downto 0) 	<= unsigned(sample_1_coeff_2_v);
				ts_param_buf_s(10)(15 downto 0) <= unsigned(sample_2_coeff_2_v);
				ts_param_buf_s(11)(7 downto 0) 	<= cnt_pause_v;
				ts_param_buf_s(11)(15 downto 8) <= cnt_pulse_v;


--********************************--
--          SET_TS state          --
--********************************--
			when SET_TS =>
				WR_MEM <= '1';

				if (ts_word_counter_s >= NUM_PAR) then 	
					ts_word_counter_s <= 0;
					NEXT_STATE <= NEXT_PORT;	
				else
					ts_word_counter_v := ts_word_counter_s;
					ADDRESS_MEM <= port_proc_s*NUM_PAR + ts_word_counter_v;
					DATA_MEM_OUT <= ts_param_buf_s(ts_word_counter_v);

					ts_word_counter_s <= ts_word_counter_s+1;

					NEXT_STATE <= SET_TS;
					
				end if;	


--********************************--
--         SEND_MSG state         --
--********************************--
			when SEND_MSG =>
				MSG_DATA(15 downto 8) 		<= TIME_OUT_MSG_s;
				MSG_DATA( 7 downto 0) 		<= to_unsigned(port_proc_s, 8);						
				MSG_TX										<= '0';
				flag_msg_sent_v 					:= x"1";	

				RLS_TIME_SLOT_PROC				<= '1';
				RLS_TIME_SLOT_INDEX_PROC	<= port_proc_s;

				NEXT_STATE 	<= NEXT_PORT;					

				ts_param_buf_s(0)(7 downto 4) 	<= flag_msg_sent_v;

		
--********************************--
--        NEXT_PORT state         --
--********************************--

			when NEXT_PORT => 
				RLS_TIME_SLOT_PROC <= '0';
				ts_word_counter_s <= 0;
				ts_param_buf_s 	<= (others => x"0000");
				

				if (port_proc_s >= (NUM_CH-1) ) then
					port_proc_s <= 0;
					NEXT_STATE <= HALT_PROC;

				else 
					port_proc_s 				<= port_proc_s+1;
					NEXT_STATE 					<= GET_TS;

				end if;

--********************************--
--        HALT_PROC state         --
--********************************--

			when OTHERS => 		-- HALT_PROC
				if (proc_trigger_s = '1') then
					proc_trigger_reset_s <= '1';
					NEXT_STATE <= S0;


				else
					NEXT_STATE <= HALT_PROC;
					HALT <= '1';

				end if;



			-- when others =>
			-- 	--

		end case;
	end if;	
end if;

end process;

	
end signalProcessorUniqueProcess;




-- 						--    Original architecture    -- 


-- architecture signalProcessor of signalProcessor is
-- 	type		STATE is (S0,
-- 										GET_TS,
-- 										GET_TS_INC,
-- 										PROCESSING_TS,
-- 										SET_TS,
-- 										NEXT_PORT,
-- 										HALT_PROC
-- 										);
-- 	signal	NEXT_STATE, CURRENT_STATE : STATE;

-- 	signal ts_word_counter_s				: natural range 0 to NUM_PAR;
-- 	signal ts_param_buf_s						: ARRAY_NUM_PAR_WORD;	
-- 	signal port_proc_s							: natural range 0 to NUM_CH-1;

-- -- process (CLK, RST)
-- -- begin
-- -- 	if (CLK'event and CLK='1') then
-- -- 		if (RST='1') then
-- -- 			CURRENT_STATE <= S0;

-- -- 		else
-- -- 			CURRENT_STATE <= NEXT_STATE;
-- -- 		end if;
-- -- 	end if;



-- begin

-- --==========================================================--
-- --=									State Machine Engine									 =--
-- --==========================================================--
-- process (CLK, RST)
-- begin
-- 	if (CLK'event and CLK='1') then
-- 		if (RST='1') then
-- 			CURRENT_STATE <= S0;

-- 		else
-- 			CURRENT_STATE <= NEXT_STATE;	

-- 		end if;
-- 	end if;
-- end process;


-- --==========================================================--
-- --=						State Machine's Next State Logic						 =--
-- --==========================================================--
-- process(CURRENT_STATE,ts_word_counter_s, ts_param_buf_s, port_proc_s, CLK_8KHz)

-- begin
-- 	case CURRENT_STATE is
-- 		when S0 =>
-- 			NEXT_STATE <= GET_TS;

-- 		when GET_TS =>
-- 			if (ts_word_counter_s >= NUM_PAR) then 
-- 				NEXT_STATE <= PROCESSING_TS;				

-- 			elsif ( (ts_word_counter_s = 1) 
-- 							and ( ts_param_buf_s(0) = x"ffff") ) then
-- 				NEXT_STATE <= NEXT_PORT;

-- 			else
-- 				NEXT_STATE <= GET_TS_INC;
				
-- 			end if;

-- 		when GET_TS_INC =>
-- 			NEXT_STATE <= GET_TS;


-- 		when PROCESSING_TS =>
-- 			NEXT_STATE <= SET_TS; 

-- 		when SET_TS =>
-- 			if (ts_word_counter_s >= NUM_PAR) then 
-- 				NEXT_STATE <= NEXT_PORT;				

-- 			else
-- 				NEXT_STATE <= SET_TS;

-- 			end if;

-- 		when NEXT_PORT => 
-- 			if (port_proc_s >= (NUM_CH-1) ) then
-- 				NEXT_STATE <= HALT_PROC;

-- 			else 
-- 				NEXT_STATE <= GET_TS;
				
-- 			end if;

					
-- 		when OTHERS =>			-- HALT_PROC
-- 			if (CLK_8KHz = '1') then
-- 				NEXT_STATE <= S0;

-- 			else
-- 				NEXT_STATE <= HALT_PROC;

-- 			end if;

-- 	end case;
-- end process;


-- --==========================================================--
-- --= 							State Machine's Actions									 =--
-- --==========================================================--
-- process(CURRENT_STATE, 
-- 				ts_word_counter_s, port_proc_s, 
-- 				DATA_MEM_IN,
-- 				RX_BUFFER
-- 				,ts_param_buf_s
-- 				)



-- 	variable ts_word_counter_v		: natural range 0 to NUM_PAR-1 := 0;
-- 	variable rx_frame_v						: signed (WORD_SIZE-1 downto 0);

-- -- state0 variables --
-- 	-- variable tone_level_v					: unsigned(WORD_SIZE-1 downto 0);
-- 	-- variable previous_sample_v		: unsigned(WORD_SIZE-1 downto 0);


-- 	variable coeff_v_signed				: signed (WORD_SIZE-1 downto 0);
-- 	variable sample_1_v_signed		: signed (WORD_SIZE-1 downto 0);
-- 	variable sample_2_v_signed		: signed (WORD_SIZE-1 downto 0);

-- 	-- variable aux_world_v					: WORD;
	
-- 	variable state_v							: unsigned := ts_param_buf_s(0)(3 downto 0);
-- 	variable flag_msg_sent_v			: unsigned := ts_param_buf_s(0)(7 downto 4);
-- 	variable counter_of_samples_v : unsigned := ts_param_buf_s(0)(15 downto 8);
-- 	variable min_pulse_v					: unsigned := ts_param_buf_s(1)(7 downto 0);
-- 	variable max_pulse_v					: unsigned := ts_param_buf_s(1)(15 downto 8);
-- 	variable min_pause_v					: unsigned := ts_param_buf_s(2)(7 downto 0);
-- 	variable max_pause_v					: unsigned := ts_param_buf_s(2)(15 downto 8);
-- 	variable cadence_v						: unsigned := ts_param_buf_s(3)(3 downto 0);
-- 	variable cnt_cadence_v				: unsigned := ts_param_buf_s(3)(7 downto 4);
-- 	variable attenuation_v				: unsigned := ts_param_buf_s(3)(15 downto 8);
-- 	variable threshold_v					: unsigned := ts_param_buf_s(4)(15 downto 0);
-- 	variable coeff1_v							: unsigned := ts_param_buf_s(5)(15 downto 0);
-- 	variable coeff2_v							: unsigned := ts_param_buf_s(6)(15 downto 0);
-- 	variable sample_1_coeff_1_v		: unsigned := ts_param_buf_s(7)(15 downto 0);
-- 	variable sample_2_coeff_1_v		: unsigned := ts_param_buf_s(8)(15 downto 0);
-- 	variable sample_1_coeff_2_v		: unsigned := ts_param_buf_s(9)(15 downto 0);
-- 	variable sample_2_coeff_2_v		: unsigned := ts_param_buf_s(10)(15 downto 0);
-- 	variable cnt_pause_v					: unsigned := ts_param_buf_s(11)(7 downto 0);
-- 	variable cnt_pulse_v					: unsigned := ts_param_buf_s(11)(15 downto 8);

-- begin
	
-- 	ts_word_counter_s						<= 0;
-- 	ts_param_buf_s							<= (others => x"0000");
-- 	port_proc_s									<= 0;

-- 	DATA_MEM_OUT								<= (others => '0');
-- 	ADDRESS_MEM									<= 0;
-- 	WR_MEM											<= '0';
-- 	HALT												<= '0';
-- 	RLS_TIME_SLOT_PROC					<= '0';
-- 	RLS_TIME_SLOT_INDEX_PROC		<= 0;
-- 	MSG_DATA										<= (others => '0');
-- 	MSG_TX											<= '0';

-- 	case CURRENT_STATE is
-- 		when S0 => 
-- 			DATA_MEM_OUT								<= (others => '0');
-- 			ADDRESS_MEM									<= 0;
-- 			WR_MEM											<= '0';
-- 			HALT												<= '0';
-- 			RLS_TIME_SLOT_PROC					<= '0';
-- 			RLS_TIME_SLOT_INDEX_PROC		<= 0;
-- 			MSG_DATA										<= (others => '0');
-- 			MSG_TX											<= '0';

-- 		when GET_TS =>
-- 			WR_MEM <= '0';

-- 			if (ts_word_counter_s >= NUM_PAR) then 	
-- 				--  start the processing
-- 			else
-- 				ts_word_counter_v := ts_word_counter_s;
-- 				ADDRESS_MEM <= port_proc_s*NUM_PAR + ts_word_counter_v;
-- 				ts_param_buf_s(ts_word_counter_v) <= DATA_MEM_IN;		

-- 				-- ts_word_counter_s <= ts_word_counter_s+1;
-- 				ts_word_counter_s <= ts_word_counter_s;
					
-- 			end if;			

-- 		when GET_TS_INC =>
-- 			ts_word_counter_s <= ts_word_counter_s+1;



-- 		when PROCESSING_TS =>
-- 			if (state_v = DT_STATE0) then
-- 				-- sample_1_v_signed :=  to_saigned( to_integer(sample_1_coeff_1_v), WORD_SIZE-1);
-- 				if ( sample_1_coeff_1_v < TONE_LEVEL) then
-- 					sample_1_coeff_1_v := sample_1_coeff_1_v+1;
-- 					rx_frame_v := abs( to_signed(to_integer(RX_BUFFER(port_proc_s)), WORD_SIZE) );

-- 					if (to_signed(to_integer(sample_2_coeff_1_v), WORD_SIZE) < rx_frame_v) then
-- 						sample_2_coeff_1_v := to_unsigned( to_integer(rx_frame_v), WORD_SIZE);

-- 						ts_param_buf_s(0)(3 downto 0) <= state_v;
-- 						ts_param_buf_s(7)(15 downto 0) <= sample_1_coeff_1_v;
-- 						ts_param_buf_s(8)(15 downto 0) <= sample_2_coeff_1_v;

-- 						state_v				:= (others => '0');
-- 						sample_1_coeff_1_v	:= (others => '0');
-- 						sample_2_coeff_1_v	:= (others => '0');

-- 					else
-- 						ts_param_buf_s(0)(3 downto 0) <= state_v;
-- 						ts_param_buf_s(7)(15 downto 0) <= sample_1_coeff_1_v;
-- 						ts_param_buf_s(8)(15 downto 0) <= sample_2_coeff_1_v;

-- 						state_v							:= (others => '0');
-- 						sample_1_coeff_1_v	:= (others => '0');
-- 						sample_2_coeff_1_v	:= (others => '0');
						
-- 					end if;

-- 				else
-- 					if( sample_2_coeff_1_v >= LEVEL) then
-- 						state_v := "0001";

-- 					else
-- 						state_v := "0000"; 						
-- 					end if;
					
-- 					sample_1_coeff_1_v := (others => '0');
-- 					sample_2_coeff_1_v := (others => '0');								

-- 					ts_param_buf_s(0)(3 downto 0) <= state_v;
-- 					ts_param_buf_s(7)(15 downto 0) <= sample_1_coeff_1_v;
-- 					ts_param_buf_s(8)(15 downto 0) <= sample_2_coeff_1_v;

-- 					ts_word_counter_s <= 0;
				
-- 				end if;


-- 			elsif (state_v = DT_STATE1) then





-- 			elsif (state_v = DT_STATE2) then
				
-- 			else --state_v = DT_STATE3

				

-- 			end if;
-- 		when SET_TS =>
-- 			WR_MEM <= '1';

-- 			if (ts_word_counter_s >= NUM_PAR) then 	
-- 				ts_word_counter_s <= 0;
-- 			else
-- 				ts_word_counter_v := ts_word_counter_s;
-- 				ADDRESS_MEM <= port_proc_s*NUM_PAR + ts_word_counter_v;
-- 				DATA_MEM_OUT <= ts_param_buf_s(ts_word_counter_v);

-- 				ts_word_counter_s <= ts_word_counter_s+1;
				
-- 			end if;	

			
-- 		when NEXT_PORT => 
-- 			if (port_proc_s >= (NUM_CH-1) ) then
-- 				port_proc_s <= 0;

-- 			else 
-- 				port_proc_s <= port_proc_s+1;

-- 			end if;

-- 		when OTHERS => 		-- HALT_PROC
-- 			HALT <= '1';


-- 	end case;
-- end process;
	
-- 	-- OUT_DATA_MEM 						<= PROCESSOR_DATA_MEM_IN;				
-- 	-- PROCESSOR_DATA_MEM_OUT 	<= IN_DATA_MEM;
-- 	-- ADDRESS_MEM 						<= PROCESSOR_ADDRESS_MEM;
-- 	-- WR_MEM 									<= PROCESSOR_WR_MEM;
	




-- end signalProcessor;


