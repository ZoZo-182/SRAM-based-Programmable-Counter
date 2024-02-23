library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
		port (
		iClk		: in std_logic;
      		KEY0 		: in STD_LOGIC; 

		-- SRAM
		disp_DATAOUT    : buffer std_logic_vector(15 downto 0);
		SRAM_IO 	: INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);	
		SRAM_addr2SRAM	: OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
		SRAM_ce 	: OUT STD_LOGIC;
		SRAM_ub 	: OUT STD_LOGIC;
		SRAM_lb		: OUT STD_LOGIC;
		SRAM_we 	: OUT STD_LOGIC;
		SRAM_oe 	: OUT STD_LOGIC;
			
		--to seven segment
		HEX0_sig        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);		-- Seven Segment Digit 0
      		HEX1_sig        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);		-- Seven Segment Digit 1
      		HEX2_sig        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);		-- Seven Segment Digit 2
     		HEX3_sig        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);		-- Seven Segment Digit 3
      		HEX4_sig        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);		-- Seven Segment Digit 4
      		HEX5_sig        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);		-- Seven Segment Digit 5
		OP_or_PROG	: OUT STD_LOGIC; -- LED
			
		--from keypad
		iRows		:in std_logic_vector(4 downto 0);
		Cols		: buffer std_logic_vector(3 downto 0));
end top_level;
-- components ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
architecture Structural of top_level is

	component btn_debounce_toggle is
	        GENERIC (
			CONSTANT CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF");  
		Port( 
			BTN_I 	 : in  STD_LOGIC;
        		CLK 	 : in  STD_LOGIC;
         		BTN_O 	 : out  STD_LOGIC;
         		TOGGLE_O : out  STD_LOGIC;
			PULSE_O  : out STD_LOGIC);
	end component;

	component Reset_Delay IS	
		PORT (
			SIGNAL iCLK     : IN std_logic;	
			SIGNAL oRESET 	: OUT std_logic);	
	end component;	

	component State_Machine is 
		Port ( 
			clk 	         : in STD_LOGIC; 
           		clk_en 		 : in STD_LOGIC; 
          		rst 		 : in STD_LOGIC; 
           		keypad_data  	 : in STD_LOGIC_VECTOR(4 downto 0); 
           		data_valid_pulse : in STD_LOGIC; 
          		state 		 : out STD_LOGIC_VECTOR(3 downto 0);
			counter 	 : in STD_LOGIC_VECTOR(7 downto 0)); 
	end component; 

	component univ_bin_counter is
		generic(N: integer := 8; N2: integer := 255; N1: integer := 0);
		port(
			clk, reset		: in std_logic;
			syn_clr, load, en, up	: in std_logic;
			clk_en 			: in std_logic := '1';			
			d			: in std_logic_vector(N-1 downto 0);
			max_tick, min_tick	: out std_logic;
			q			: out std_logic_vector(N-1 downto 0));
	end component;

	component Rom IS
		PORT(
			address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
	END component;

	component clk_enabler is
		 GENERIC (
			 CONSTANT cnt_max : integer := 49999999);      --  1.0 Hz 	
		 PORT(	
			clock		: in std_logic;	 
			clk_en		: out std_logic);
	end component;
	
	component SRAM_Controller is
		port(
			clk: in std_logic;
			reset: in std_logic;
			pulse: in std_logic; --needed to initate a memory operation. tells the SRAM controller it is ready 
			R_W: in std_logic; --read =1 and write =0
			addr: in std_logic_vector(7 downto 0);
			DATAin: in std_logic_vector(15 downto 0);
			
			DATAout: out std_logic_vector(15 downto 0);
			ready: out std_logic;	
			IO: inout std_logic_vector(15 downto 0);	--IN and OUT between SRAM and SRAM controller
			Addr2SRAM: out std_logic_vector(19 downto 0); -- addr but padded with X"000"
			ceOUT: out std_logic;	--tie to '0' in top level
			ub: out std_logic;	--tie to '0' in top level
			lb: out std_logic;	--tie to '0' in top level
			weOUT: out std_logic;
			DoesWORK: out std_logic_vector(3 downto 0);
			oeOUT: out std_logic);
	end component;	
	
	component SystemModule is
    Port ( clk : in STD_LOGIC;        --clock_50
            state: in STD_LOGIC_VECTOR(3 downto 0);        --QState 4 bits
           -- Inputs if programming mode
           in_data_prog1 : in STD_LOGIC_VECTOR (3 downto 0);         --keypad data for data??
           in_data_prog2 : in STD_LOGIC_VECTOR (3 downto 0);         --keypad data for data??
           in_data_prog3 : in STD_LOGIC_VECTOR (3 downto 0);         --keypad data for data??
           in_data_prog4 : in STD_LOGIC_VECTOR (3 downto 0);        --keypad data for data??
           in_addr_prog1 : in STD_LOGIC_VECTOR (3 downto 0);        --keypad data for address??
           in_addr_prog2 : in STD_LOGIC_VECTOR (3 downto 0);        --Keypad data for address??
            -- inputs if operating mode. 
           in_data_oper1 : in STD_LOGIC_VECTOR (3 downto 0);        --SRAM(3 downto 0)
           in_data_oper2 : in STD_LOGIC_VECTOR (3 downto 0);        --SRAM(7 downto 4)
           in_data_oper3 : in STD_LOGIC_VECTOR (3 downto 0);        --SRAM(11 downto 8)
           in_data_oper4 : in STD_LOGIC_VECTOR (3 downto 0);        --SRAM(15 downto 12)
           in_addr_oper1 : in STD_LOGIC_VECTOR (3 downto 0);        -- counter first 4 digits
           in_addr_oper2 : in STD_LOGIC_VECTOR (3 downto 0);        -- counter second 4 digits
           -- Outputs for seven-segment displays
           display_out1 : out STD_LOGIC_VECTOR (6 downto 0);        --connect to first 7seg LED
           display_out2 : out STD_LOGIC_VECTOR (6 downto 0);         --connect to sec 7seg LED
           display_out3 : out STD_LOGIC_VECTOR (6 downto 0);         --connect to third 7seg LED
           display_out4 : out STD_LOGIC_VECTOR (6 downto 0);         --connect to four 7seg LED
           display_out5 : out STD_LOGIC_VECTOR (6 downto 0);         --connect to fifth 7seg LED
           display_out6 : out STD_LOGIC_VECTOR (6 downto 0));        --connect to sixth 7seg LED
end component;

component ShiftRegister is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
	shift_times: INTEGER range 0 to 4;
        clock_pulse_5ms : in STD_LOGIC; -- 5ms clock pulse
        clock_en_5ms : in STD_LOGIC; -- Clock enable of 5ms
        data_in : in STD_LOGIC_VECTOR (3 downto 0);
        data_out : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component ShiftRegisterADDR is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
		  shift_times: INTEGER range 0 to 4;
        clock_pulse_5ms : in STD_LOGIC; -- 5ms clock pulse
        clock_en_5ms : in STD_LOGIC; -- Clock enable of 5ms
        data_in : in STD_LOGIC_VECTOR (3 downto 0);
        data_out : out STD_LOGIC_VECTOR (7 downto 0));
end component;


component Keypad_Controller is
    Port (	
        Clk: in  std_logic;	 
	     iRows :in std_logic_vector(4 downto 0);
	     Cols  : buffer std_logic_vector(3 downto 0);		  
		  OutputData : out std_logic_vector(4 downto 0);
		  clockEN5ms_out: out STD_LOGIC;
		  pulse_5ms  : buffer std_logic;
		  pulse_20ns : out std_logic);
end component;
			
-- signals ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--universal reset signals
	signal Counter_Reset        		: std_logic;
	signal reset_d				: std_logic;
	signal KEY0_db 				: std_logic;

	--clock enables
	signal clock_enable_60ns		: std_logic;
	signal clock_enable_1sec		: std_logic;
	signal clockEN5ms_sig,clockPulse5ms_sig,pulse_20ns_sig 	:  std_logic;
	signal clockEN5ms_sig_data,clockEN5ms_sig_addr		: std_logic;

	--univ counter and rom outputs 
	signal Qc				: std_logic_vector(7 downto 0); -- counter output
	signal Qr				: std_logic_vector(15 downto 0); -- Rom output

	--mux signals
	signal mux_select_clken			: std_logic_vector(1 downto 0);
	signal mux_output_clken			: std_logic;
	signal mux_select_up			: std_logic_vector(1 downto 0);
	signal mux_output_up			: std_logic;
	signal mux_select_en			: std_logic_vector(1 downto 0);
	signal mux_output_en			: std_logic;
	signal mux_select_pulse			: std_logic_vector(1 downto 0);
	signal mux_output_pulse			: std_logic;
	signal mux_select_RW			: std_logic_vector(1 downto 0);
	signal mux_output_RW			: std_logic;
	signal mux_select_datain		: std_logic_vector(1 downto 0);
	signal mux_output_datain		: std_logic_vector(15 downto 0);
	signal mux_output_addrin		: std_logic_vector(7 downto 0);
	signal Qstate				: std_logic_vector(3 downto 0);
	signal GLED_sig				: std_logic;

	signal OUTPUT_DATA_addrShift, OUTPUT_DATA_Datashift	: std_logic_vector(3 downto 0):= "0000";
	signal OUTPUT_DATA 			: std_logic_vector(4 downto 0);

	signal sig_ceOUT, sig_ub, sig_lb	: std_logic;
	
	signal AFTERSHIFT_DATA 			: std_LOGIC_VECTOR(15 downto 0);
	signal AFTERSHIFT_ADDR			: std_LOGIC_VECTOR(7 downto 0);

	signal SRAM_addr2SRAM_sig		: std_logic_vector(19 downto 0);
	
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	begin
		
	Counter_Reset <= not KEY0_db or reset_d; --universal reset logic
		
	SRAM_addr2SRAM<=SRAM_addr2SRAM_sig;
 
 	sig_ceOUT <='0';
	sig_lb <='0';
	sig_ub <='0';
	SRAM_lb<=sig_lb;
	SRAM_ub<=sig_ub;
	SRAM_ce<=sig_ceOUT;
	OP_or_PROG<=GLED_sig;

-- multiplexers ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		
	--rw mux
	mux_select_RW <= Qstate(3 downto 2);
	process(mux_select_RW,OUTPUT_DATA) 
	begin 
    		case mux_select_RW is
        		when "01" =>
		    		GLED_sig <= '1';
            	   		mux_output_RW <= '1'; --reading
        		when "10" =>
	            		GLED_sig<='0';
	   	    	 	if (OUTPUT_DATA = "10001") then
	    	 		mux_output_RW <= '0'; --write
	    	   	 	else
		        	mux_output_RW <= '1';
		            	end if;
        		when "00" =>
            	    		mux_output_RW <= '0'; -- write
			when others =>
                    		mux_output_RW <= '1'; --reading
       		end case;
	end process;
	
	--up mux
	mux_select_up <= Qstate(3 downto 2); -- select based on state(3) and state(2)
	process(mux_select_up, Qstate(1))
	begin
    		case mux_select_up is
        		when "00" | "01" =>
            			mux_output_up <= Qstate(1);
       			when others =>
            			mux_output_up <= '0';
   		end case;
	end process;
	
	--en mux
	mux_select_en <= Qstate(3 downto 2);
	process(mux_select_en, Qstate(0))
	begin
    		case mux_select_en is
        		when "00" | "01" =>
            			mux_output_en <= Qstate(0);
        		when others =>
            			mux_output_en <= '0';
    		end case;
	end process;
	
	--clock_en mux
	mux_select_clken <= Qstate(3 downto 2);
	process(mux_select_clken) 
	begin 
    		case mux_select_clken is
        		when "00" => --In initalization mode
           		 	mux_output_clken <= clock_enable_60ns; 
        		when "01" => -- In pogramming or operational mode
            			mux_output_clken <= clock_enable_1sec;
        		when others =>
            			mux_output_clken <= '0';
    		end case;
	end process;
	
	--pulse mux not used until connected to SRAM
	mux_select_pulse <= Qstate(3 downto 2);
	process(mux_select_pulse)
	begin 
    		case mux_select_pulse is
        		when "00" =>
            			mux_output_pulse <= clock_enable_60ns;
        		when "01" =>
            			mux_output_pulse <= clock_enable_1sec;
        		when "10" =>
            			mux_output_pulse <= pulse_20ns_sig; -- kp_pulse 
        		when others =>
            			mux_output_pulse <= '0';
    		end case;
	end process;
	
	--reading to SRAM from rom or keypad
	mux_select_datain <= Qstate(3 downto 2);
	process(mux_select_datain) 
	begin 
    		case mux_select_datain is
        		when "10" =>
				mux_output_addrin <=AFTERSHIFT_ADDR;
            			mux_output_datain <= AFTERSHIFT_DATA;
		   	when others =>
				mux_output_addrin <=Qc;
            			mux_output_datain <= Qr;
			
    		end case;
	end process;

	--output data shift depending on being in an programming address or data mode.
	process(OUTPUT_DATA)
	begin 
		if (OUTPUT_DATA(4) = '0') then
			if (Qstate(3 downto 1) = "101") then
				OUTPUT_DATA_Datashift <=OUTPUT_DATA(3 downto 0);
				clockEN5ms_sig_data<=clockEN5ms_sig;
			end if;
			if(Qstate(3 downto 1) = "100") then
				OUTPUT_DATA_addrShift <=OUTPUT_DATA(3 downto 0);
				clockEN5ms_sig_addr<=clockEN5ms_sig;
			end if;
		end if;
	end process;
	
-- Instantiations ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------		

			
	Inst_clk_Reset_Delay: Reset_Delay	
		port map(
			iCLK 		=> iClk,	
			oRESET    	=> reset_d);			

	Inst_clk_enabler1sec: clk_enabler
		generic map(
			cnt_max 	=> 49999999)
		port map( 
			clock 		=> iClk, 			--  from system clock
			clk_en 		=> clock_enable_1sec);
			
	Inst_clk_enabler60ns: clk_enabler
		generic map(
			cnt_max 	=> 2) -- 833333 or 3000
		port map( 
			clock 		=> iClk, 			
			clk_en 		=> clock_enable_60ns);	
			
	Inst_univ_bin_counter: univ_bin_counter
		generic map(N => 8, N2 => 255, N1 => 0)
		port map(
			clk 		=> iClk,
			reset 		=> Counter_Reset,
			syn_clr		=> '0', 
			load		=> '0', 
			en		=> mux_output_en, 
			up		=> mux_output_up, 
			clk_en 		=> mux_output_clken, 
			d		=> (others => '0'),
			max_tick	=> open, 
			min_tick 	=> open,
			q		=> Qc);

	inst_KEY0: btn_debounce_toggle
		GENERIC MAP( CNTR_MAX => X"FFFF") -- use X"FFFF" for implementation
		Port Map(
			BTN_I 		=> KEY0,
			CLK		=> iClk,
			BTN_O 		=> KEY0_db,
			TOGGLE_O	=> open,
			PULSE_O 	=> open);
			
		
	Inst_Rom: Rom
		Port Map(
			address 	=> Qc,
			clock 		=> iClk,
			q 		=> Qr);
		
	Inst_State_Machine: State_Machine
		port map(
			clk 		=> iClk,
          		clk_en 		=> clockEN5ms_sig,
          		rst 		=> Counter_Reset,
	          	keypad_data  	=> OUTPUT_DATA,
          		data_valid_pulse => clockEN5ms_sig, -- why clock en and not pulse 5ms/20ns?
          		state 		=> Qstate,
			counter 	=> Qc);

	Inst_SRAM_Controller: SRAM_Controller
		port map(
			clk 		=> iClk,
			reset	 	=> Counter_Reset,
			pulse 		=> mux_output_pulse,		
			R_W 		=> mux_output_RW, 			--hardwire to a switch, '0' for reading and '1' for writing
			addr 		=> mux_output_addrin,		--hardwire using switches in binary 0x00001
			DATAin 		=> mux_output_datain,	--hardwire using switches in binary 0x0003 
		
			DATAout		=> disp_DATAOUT, 
			
			ready 		=> open, --goes to SRAM?	
			IO 		=> SRAM_IO, --IN and OUT between SRAM and SRAM controller
			Addr2SRAM 	=> SRAM_addr2SRAM_sig,-- GOES TO SRAM addr but padded with X"000"
			ceOUT 		=> open, 	-- GOES to SRAM BUT SHOULD BE TIED TO 0
			ub 		=> open,		-- GOES to SRAM BUT SHOULD BE TIED TO 0
			lb 		=> open,		-- GOES to SRAM BUT SHOULD BE TIED TO 0
			weOUT 		=> SRAM_we,
			DoesWORK	=> open,
			oeOUT 		=> SRAM_oe);
	
	INST_SHIFTDATA: ShiftRegister 
   		Port map(
        		clk		=> iCLK,
        		reset		=> Counter_Reset,
		  	shift_times	=> 4,
       	 		clock_pulse_5ms	=> clockPulse5ms_sig,-- 5ms clock pulse from keypad
        		clock_en_5ms	=> clockEN5ms_sig_data, -- Clock enable of 5ms from keypad
        		data_in		=> OUTPUT_DATA_Datashift,  -- from keypad outputdata
        		data_out	=> AFTERSHIFT_DATA);

	INST_SHIFTADDR: ShiftRegisterADDR 
    		Port map(
       	 		clk		=>iCLK,
        		reset		=>Counter_Reset,
		  	shift_times	=> 2,
        		clock_pulse_5ms	=> clockPulse5ms_sig, -- 5ms clock pulse from keypad
        		clock_en_5ms	=> clockEN5ms_sig_addr,-- Clock enable of 5ms  from keypad
        		data_in		=> OUTPUT_DATA_addrShift, -- from keypad
       			data_out	=> AFTERSHIFT_ADDR);
		
	INST_7seg: SystemModule
		Port map ( clk =>iCLK,
            		state => Qstate,
          		-- Inputs if programming mode
           		in_data_prog1	=> AFTERSHIFT_DATA(3 downto 0),        --keypad data for data?? ones with a '0' in front
           		in_data_prog2	=> AFTERSHIFT_DATA(7 downto 4),              --keypad data for data??
           		in_data_prog3	=> AFTERSHIFT_DATA(11 downto 8),             --keypad data for data??
           		in_data_prog4	=> AFTERSHIFT_DATA(15 downto 12),             --keypad data for data??
		        in_addr_prog1	=> AFTERSHIFT_ADDR(3 downto 0),       --keypad data for address??
           		in_addr_prog2	=> AFTERSHIFT_ADDR(7 downto 4),      --Keypad data for address??
            		-- inputs if operating mode. 
           		in_data_oper1 	=> disp_DATAOUT(3 downto 0),       --SRAM(3 downto 0)
           		in_data_oper2  	=> disp_DATAOUT(7 downto 4),        --SRAM(7 downto 4)
           		in_data_oper3 	=> disp_DATAOUT(11 downto 8),       --SRAM(11 downto 8)
           		in_data_oper4  	=> disp_DATAOUT(15 downto 12),        --SRAM(15 downto 12)
           		in_addr_oper1  	=> SRAM_addr2SRAM_sig(3 downto 0),         -- counter first 4 digits
           		in_addr_oper2  	=> SRAM_addr2SRAM_sig(7 downto 4),        -- counter second 4 digits
           		-- Outputs for seven-segment displays
            		display_out1 	=>Hex0_sig,        --connect to first 7seg LED
            		display_out2 	=>Hex1_sig,        --connect to sec 7seg LED
            		display_out3 	=>Hex2_sig,        --connect to third 7seg LED
            		display_out4 	=>Hex3_sig,        --connect to four 7seg LED
            		display_out5 	=>Hex4_sig,        --connect to fifth 7seg LED
            		display_out6 	=>Hex5_sig);        --connect to sixth 7seg LED

	Inst_Keypad_Controller: Keypad_Controller 
    		Port map(	
        		Clk 		=> iCLK, 
	     		iRows 		=> iRows,
			Cols 		=> Cols,		  
		  	OutputData 	=> OUTPUT_DATA,
		  	pulse_5ms  	=> clockPulse5ms_sig,
		  	clockEN5ms_out 	=>clockEN5ms_sig,
		  	pulse_20ns 	=> pulse_20ns_sig);
	 
end Structural;
