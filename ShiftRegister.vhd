library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ShiftRegister is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
		  shift_times: INTEGER range 0 to 4;
        clock_pulse_5ms : in STD_LOGIC; -- 5ms clock pulse
        clock_en_5ms : in STD_LOGIC; -- Clock enable of 5ms
        data_in : in STD_LOGIC_VECTOR (3 downto 0);
        data_out : out STD_LOGIC_VECTOR (15 downto 0)
    );
end ShiftRegister;

architecture Behavioral of ShiftRegister is
    signal temp_reg : STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
    signal shift_count : INTEGER range 0 to 4 := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            temp_reg <= (others => '0');
            shift_count <= 0;
        elsif rising_edge(clk) and clock_pulse_5ms = '1' and clock_en_5ms = '1' then
            if shift_count <= shift_times then
                temp_reg <= temp_reg(11 downto 0) & data_in;
                shift_count <= shift_count + 1;
            else
                temp_reg <= (others => '0');
                shift_count <= 0;
            end if;
        end if;
    end process;

    data_out <= temp_reg;

end Behavioral;
