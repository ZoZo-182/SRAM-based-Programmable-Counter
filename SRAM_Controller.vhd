library ieee;
use ieee.std_logic_1164.all;
entity SRAM_controller is
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
end SRAM_controller;
		
architecture arch of SRAM_controller is
	type state_type is (idle, r1, r2, w1, w2);
	signal state_reg, state_next: state_type;
	signal DATAin_reg, DATAin_next: std_logic_vector(15 downto 0);
	signal DATAout_reg, DATAout_next: std_logic_vector(15 downto 0);
	signal addr_reg, addr_next: std_logic_vector(7 downto 0);
	signal we_buf, oe_buf, ten_buf: std_logic;
	signal we_reg, oe_reg, ten_reg: std_logic;
	
	
	begin
	process(clk, reset)
		begin
			if (reset = '1') then
				state_reg <= idle;
				addr_reg <= (others => '0');
				DATAin_reg <= (others =>'0');
				DATAout_reg <= (others => '0');
				ten_reg <= '0';
				we_reg <= '1';
				oe_reg <= '1';
			elsif (rising_edge(clk)) then
				state_reg <= state_next;
				addr_reg <= addr_next;
				DATAin_reg <= DATAin_next;
				DATAout_reg <= DATAout_next;
				ten_reg <= ten_buf;
				we_reg <= we_buf;
				oe_reg <= oe_buf;
			end if;
	end process;

	process(state_reg, pulse, R_W, IO, addr, DATAin,
		DATAin_reg, DATAout_reg, addr_reg)
	begin
		addr_next <= addr_reg;
		DATAin_next <= DATAin_reg;
		DATAout_next <= DATAout_reg;
		ready <= '0';
		case state_reg is
				when idle =>
					DoesWORK <="0000";
					if (pulse = '0') then
					state_next <= idle;
					DoesWORK <="0101";
					else
					DoesWORK <="1001";
					addr_next <= addr;
						if (R_W= '0') then -- write
						DoesWORK <="1010";
						state_next <= w1;
						DATAin_next <= DATAin;
						else --READ
						DoesWORK <="1011";
							state_next <= r1;
						end if;
					end if;
					ready <= '1';
				when w1 =>
					DoesWORK <="0001";
					state_next <= w2;
				when w2 =>
					DoesWORK <="0011";
					state_next <= idle;
				when r1 =>
					DoesWORK <="0111";
					state_next <= r2;
				when r2 =>
					DoesWORK <="1111";
					DATAout_next <= IO;
					state_next <= idle;
			end case;
	end process;
		

	process(state_next)
		begin
			ten_buf<='1';
			we_buf <= '1';
			oe_buf <= '1';
			case state_next is
				when idle =>
				when w1 =>	
				ten_buf <= '1';
				we_buf <= '0';
				when w2 =>	
				ten_buf <= '1';
				we_buf <= '1';
				when r1 =>
				ten_buf <= '0';
				oe_buf <= '0';
				when r2 =>
				ten_buf <= '0';
				oe_buf <= '1'; --'0'
			end case; 
	end process;
	DATAout<=DATAout_next;
	weOUT <= we_reg;
	oeOUT <= oe_reg;
	Addr2SRAM <= "000000000000"&addr_reg;
	ceOUT <= '0'; --LB UB?????
	IO <= DATAin_reg when ten_reg = '1'
		else (others => 'Z');
		
end arch;
		
		
