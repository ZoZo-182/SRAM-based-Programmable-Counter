library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SystemModule is
    Port( 
           clk : in STD_LOGIC;        --clock_50
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
           display_out6 : out STD_LOGIC_VECTOR (6 downto 0));         --connect to sixth 7seg LED
end SystemModule;

architecture Behavioral of SystemModule is
    component HexTo7Seg
        Port ( hex_digit : in STD_LOGIC_VECTOR (3 downto 0);
               seg : out STD_LOGIC_VECTOR (6 downto 0));
    end component;

    signal seg_data_prog1,seg_data_prog2,seg_data_prog3,seg_data_prog4,seg_addr_prog1,seg_addr_prog2: STD_LOGIC_VECTOR (6 downto 0);
    signal seg_data_oper1,seg_data_oper2,seg_data_oper3,seg_data_oper4,seg_addr_oper1,seg_addr_oper2: STD_LOGIC_VECTOR (6 downto 0);


begin

    -- Instance for programming data
    HexTo7Seg_prog_data1: HexTo7Seg Port Map (hex_digit => in_data_prog1,seg => seg_data_prog1);
    HexTo7Seg_prog_data2: HexTo7Seg Port Map (hex_digit => in_data_prog2,seg => seg_data_prog2);
    HexTo7Seg_prog_data3: HexTo7Seg Port Map (hex_digit => in_data_prog3,seg => seg_data_prog3);
    HexTo7Seg_prog_data4: HexTo7Seg Port Map (hex_digit => in_data_prog4,seg => seg_data_prog4);
    -- Instance for programming address
    HexTo7Seg_prog_addr1: HexTo7Seg Port Map (hex_digit => in_addr_prog1,seg => seg_addr_prog1);
    HexTo7Seg_prog_addr2: HexTo7Seg Port Map (hex_digit => in_addr_prog2,seg => seg_addr_prog2);




    -- Instance for operating data
    HexTo7Seg_oper_data1: HexTo7Seg Port Map (hex_digit => in_data_oper1,seg => seg_data_oper1);
    HexTo7Seg_oper_data2: HexTo7Seg Port Map (hex_digit => in_data_oper2,seg => seg_data_oper2);
    HexTo7Seg_oper_data3: HexTo7Seg Port Map (hex_digit => in_data_oper3,seg => seg_data_oper3);
    HexTo7Seg_oper_data4: HexTo7Seg Port Map (hex_digit => in_data_oper4,seg => seg_data_oper4);
    -- Instance for operating address
    HexTo7Seg_oper_addr1: HexTo7Seg Port Map (hex_digit => in_addr_oper1,seg => seg_addr_oper1);
    HexTo7Seg_oper_addr2: HexTo7Seg Port Map (hex_digit => in_addr_oper2,seg => seg_addr_oper2);


    process(clk)
    begin
        if rising_edge(clk) then
            if state(3) = '1' then --if state is program mode
                -- Mapping the output of the HexTo7Seg component to the display outputs
                    display_out1 <= seg_data_prog1;
                     display_out2 <= seg_data_prog2;
                     display_out3 <= seg_data_prog3;
                     display_out4<= seg_data_prog4;
                     display_out5<= seg_addr_prog1;
                    display_out6<= seg_addr_prog2;
            end if;
             if  state(2) = '1' then --if state is operation mode mode
                     display_out1 <= seg_data_oper1;
                     display_out2 <= seg_data_oper2;
                     display_out3 <= seg_data_oper3;
                     display_out4<= seg_data_oper4;
                     display_out5<= seg_addr_oper1;
                    display_out6<= seg_addr_oper2;
            end if;
        end if;
    end process;

end Behavioral;
