library IEEE; 

use IEEE.STD_LOGIC_1164.ALL; 

use IEEE.STD_LOGIC_ARITH.ALL; 

use IEEE.STD_LOGIC_UNSIGNED.ALL; 

 

entity State_Machine is 

    Port ( clk : in STD_LOGIC; 
           clk_en : in STD_LOGIC; 
           rst : in STD_LOGIC; 
           keypad_data : in STD_LOGIC_VECTOR(4 downto 0); 
           data_valid_pulse : in STD_LOGIC; 
           counter : in STD_LOGIC_VECTOR(7 downto 0); 
           state : out STD_LOGIC_VECTOR(3 downto 0)); 
    end State_Machine; 

architecture Behavioral of State_Machine is 
	
    type states is (INIT, OP_UP_Pause, OP_UP, OP_DOWN, OP_DOWN_Pause, Prog_UP_DATA, Prog_UP_ADDress, Prog_DOWN_DATA, Prog_DOWN_ADDress); 
    signal current_state, next_state : states; 
    signal state_value : STD_LOGIC_VECTOR(3 downto 0);  
    signal counter_prev : STD_LOGIC_VECTOR(7 downto 0); 	 

begin 

    process(clk) 
    begin 
    if rising_edge(clk) then 
	 counter_prev <= counter;
	 end if;
	 end process;

    process(clk, rst, counter) 
    begin 

        if rst = '1' then 
            current_state <= INIT; 
       	elsif counter = X"00" and counter_prev = X"FF" then  
            current_state <= OP_UP_Pause; 
        elsif rising_edge(clk) and clk_en = '1' then 
		  
        case current_state is 

            when OP_UP_Pause => 
                if keypad_data = "10010" and data_valid_pulse = '1' then 
                    current_state <= OP_UP; 
                elsif keypad_data = "10000" and data_valid_pulse = '1' then 
                    current_state <= Prog_UP_ADDress; 
                elsif keypad_data = "10001" and data_valid_pulse = '1' then 
                    current_state <= OP_DOWN_Pause; 
                end if; 

            when OP_UP => 
                if keypad_data = "10010" and data_valid_pulse = '1' then 
                    current_state <= OP_UP_Pause; 
                elsif keypad_data = "10000" and data_valid_pulse = '1' then 
                    current_state <= Prog_UP_ADDress; 
                elsif keypad_data = "10001" and data_valid_pulse = '1' then 
                    current_state <= OP_DOWN; 
                end if; 

            when Prog_UP_ADDress => 
                if keypad_data = "10000" and data_valid_pulse = '1' then 
                    current_state <= OP_UP_Pause; 
                elsif keypad_data = "10010" and data_valid_pulse = '1' then 
                    current_state <= Prog_UP_DATA; 
                end if; 

            when Prog_UP_DATA => 
                if keypad_data = "10000" and data_valid_pulse = '1' then 
                    current_state <= OP_UP_Pause; 
                elsif keypad_data = "10010" and data_valid_pulse = '1' then 
                    current_state <= Prog_UP_ADDress; 
                end if; 
 
            when OP_DOWN_Pause => 
                if keypad_data = "10010" and data_valid_pulse = '1' then 
                    current_state <= OP_DOWN; 
                elsif keypad_data = "10000" and data_valid_pulse = '1' then 
                    current_state <= Prog_DOWN_ADDress; 
                elsif keypad_data = "10001" and data_valid_pulse = '1' then 
                    current_state <= OP_UP_PAUSE; 
                end if; 

            when OP_DOWN => 
                if keypad_data = "10010" and data_valid_pulse = '1' then 
                    current_state <= OP_DOWN_Pause; 
                elsif keypad_data = "10000" and data_valid_pulse = '1' then 
                    current_state <= Prog_DOWN_ADDress; 
                elsif keypad_data = "10001" and data_valid_pulse = '1' then 
                    current_state <= OP_UP; 
                end if; 
			
            when Prog_DOWN_ADDress => 
                if keypad_data = "10000" and data_valid_pulse = '1' then 
                    current_state <= OP_DOWN_Pause; 
                elsif keypad_data = "10010" and data_valid_pulse = '1' then 
                    current_state <= Prog_DOWN_DATA; 
                end if; 

            when Prog_DOWN_DATA => 
                if keypad_data = "10000" and data_valid_pulse = '1' then 
                    current_state <= OP_DOWN_Pause; 
                elsif keypad_data = "10010" and data_valid_pulse = '1' then 
                    current_state <= Prog_DOWN_ADDress; 
                end if; 

            when others => 
                current_state <= INIT;  -- Reset to INIT state if in an unknown state 

        end case; 
      end if;
    end process; 

 with current_state select 
    state_value <= "0011" when INIT, 
                   "0110" when OP_UP_Pause, 
                   "0111" when OP_UP, 
                   "0101" when OP_DOWN, 
                   "0100" when OP_DOWN_Pause, 
                   "1011" when Prog_UP_DATA, 
                   "1001" when Prog_UP_ADDress, 
                   "1010" when Prog_DOWN_DATA, 
                   "1000" when Prog_DOWN_ADDress, 
                   "0011" when others;  -- Default value for unknown states 
    state <= state_value;
 
end Behavioral; 
