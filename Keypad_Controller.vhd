library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Keypad_Controller is
    Port (	
        Clk: in  std_logic;	 
	     iRows :in std_logic_vector(4 downto 0);
	     Cols  : buffer std_logic_vector(3 downto 0);		  
		  OutputData : out std_logic_vector(4 downto 0);
		  clockEN5ms_out: out STD_LOGIC;
		  pulse_5ms  : buffer std_logic;
		  pulse_20ns : out std_logic		  
    );
end entity Keypad_Controller;

architecture Behaviorial of Keypad_Controller is

    constant cnt_max: integer := 250000; -- Maximum value for the counter
	 signal clockEN5ms:  std_logic;  -- 5ms enable clock
	 signal Clk_cnt: integer range 0 to cnt_max; -- Counter for generating a 5ms clock
	 type state_type is (StateA, StateB, StateC, StateD);
	 signal state : state_type:=StateA; -- State variable
    signal IsKeyPressed: std_logic; -- Signal to detect if any key is pressed
	 signal keypress : std_logic; 
	 signal nkeypress : std_logic;
	 signal reg1 : std_logic;
	 signal reg2 : std_logic;



begin

    -- Detect if any key is pressed
IsKeyPressed <= not (iRows(0) and iRows(1) and iRows(2) and iRows(3) and iRows(4));
	  -- Generate a 5ms clock signal
  process(Clk) 
  begin 
    if rising_edge(clk) then 
	    if (Clk_cnt = 249999) then 
		         Clk_cnt <= 0;
					clockEN5ms <= '1'; -- Enable a 5ms clock every 250,000 cycles
					  else 
					Clk_cnt <= Clk_cnt + 1;
					clockEN5ms <= '0'; -- Disable the 5ms clock
   end if; 
  end if; 
 end process;	 
		-- Debouncing Process 
	process(clk) 
	begin
		if rising_edge(clk) and clockEN5ms = '1' then
		keypress <= IsKeyPressed;
		nkeypress <= keypress;
		pulse_5ms <= keypress and not nkeypress; -- Generate a 5ms pulse on keypress
		end if;
	end process;	
		
	process(clk) 
	begin
		if rising_edge(clk) then
		reg1 <= pulse_5ms;
		reg2 <= reg1;
		pulse_20ns <= reg1 and not reg2; -- Generate a 20ns pulse on keypress
		end if;
	end process;		
	
	-- State Transition Process
	process(clk,state)
   begin	
		if rising_edge(clk) and clockEN5ms = '1' then
			if IsKeyPressed = '0' then 
			-- State transition on keypress/ Always Scanning for Column Values until one is found and a State is determined
				case state is
					when StateA => state <= StateB; 
					when StateB => state <= StateC; 
					when StateC => state <= StateD; 
					when StateD => state <= StateA; 
					when others	=> state <= StateA;	
				end case;
			end if;
		end if;
   end process;	
	-- Update Columns based on the current state/ Determine what state value represents the certain column vaule
	
	process(state)
	begin
	case state is 
	when StateA => Cols <= "1110"; -- Activate columns for StateA
	when StateB => Cols <= "1101"; -- Activate columns for StateB
	when StateC => Cols <= "1011"; -- Activate columns for StateB
	when StateD => Cols <= "0111"; -- Activate columns for StateB
	when others => Cols <= "1111";
   end case;
   end process;	
 -- Output Data based on the current state and row input
    -- When a state is determined it will then scan through the row values of the column selected to find the certain row that was pressed
    -- This process also takes the data from the column and row to output a 5 bit data that we call OutputData
	

	process(state, iRows)
	begin 
	case state is 
	when StateA => 
		case iRows is --Row and Column are Good 
      when "11110" => OutputData <= "01010"; --A
      when "11101" => OutputData <= "00001"; --1 
      when "11011" => OutputData <= "00100"; --4
      when "10111" => OutputData <= "00111"; --7
      when "01111" => OutputData <= "00000"; --0
      when others  => OutputData <= "11111";		
		end case;
	when StateB => 
		case iRows is --Row and Column are Good
      when "11110" => OutputData <= "01011"; --B 
      when "11101" => OutputData <= "00010"; --2 
      when "11011" => OutputData <= "00101"; --5
      when "10111" => OutputData <= "01000"; --8 
		when "01111" => OutputData <= "10010"; --H 
      when others  => OutputData <= "11111";		
		end case;		
	when StateC => 
		case iRows is --Row and Column are Good
	   when "11110" => OutputData <= "01100"; --C
      when "11101" => OutputData <= "00011"; --3 
      when "11011" => OutputData <= "00110"; --6
      when "10111" => OutputData <= "01001"; --9
      when "01111" => OutputData <= "10001"; --L
      when others  => OutputData <= "11111";		
		end case; 
	when StateD => 
		case iRows is --Row and Column are Good
	   when "11110" => OutputData <= "01101"; --D 
      when "11101" => OutputData <= "01110"; --E 
      when "11011" => OutputData <= "01111"; --F 
      when "10111" => OutputData <= "10000"; --Shift 
      when others  => OutputData <= "11111";		
		end case; 
 
	end case;
end process;
clockEN5ms_out <= clockEN5ms;

end architecture Behaviorial;
