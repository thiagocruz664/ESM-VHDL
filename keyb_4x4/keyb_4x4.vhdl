library ieee;
use ieee.std_logic_1164.all;

entity keyb_4x4 is
	port(
		L1,L2,L3,L4 : in std_logic;
		C : out std_logic_vector(0 to 3);
		digit_hexa: out std_logic_vector(3 downto 0);
		clk: in std_logic
		);
end entity;

architecture func of keyb_4x4 is
	type state_type is (COL1W,COL1L,COL2W,COL2L,COL3W,COL3L,COL4W,COL4L,WAIT_STATE);
	signal state : state_type := COL1W;
	signal counter   : integer range 0 to 24999 := 0;
begin
	process(clk) begin
		if rising_edge(clk) then
			if counter = 24999 then
				counter <= 0;
				case state is
					when COL1W =>
						C <= "0111";
						state <= COL1L;
					when COL1L =>
						if    L1='0' then digit_hexa <= "0001"; state <= WAIT_STATE; -- 1
						elsif L2='0' then digit_hexa <= "0100"; state <= WAIT_STATE; -- 4
						elsif L3='0' then digit_hexa <= "0111"; state <= WAIT_STATE; -- 7
						elsif L4='0' then digit_hexa <= "1110"; state <= WAIT_STATE; -- E (*)
						else state <= COL2W;
						end if;
					when COL2W =>
						C <= "1011";
						state <= COL2L;
					when COL2L =>
						if    L1='0' then digit_hexa <= "0010"; state <= WAIT_STATE; -- 2
						elsif L2='0' then digit_hexa <= "0101"; state <= WAIT_STATE; -- 5
						elsif L3='0' then digit_hexa <= "1000"; state <= WAIT_STATE; -- 8
						elsif L4='0' then digit_hexa <= "0000"; state <= WAIT_STATE; -- 0
						else state <= COL3W;
						end if;
					when COL3W =>
						C <= "1101";
						state <= COL3L;
					when COL3L => 
						if    L1='0' then digit_hexa <= "0011"; state <= WAIT_STATE; -- 3
						elsif L2='0' then digit_hexa <= "0110"; state <= WAIT_STATE; -- 6
						elsif L3='0' then digit_hexa <= "1001"; state <= WAIT_STATE; -- 9
						elsif L4='0' then digit_hexa <= "1111"; state <= WAIT_STATE; -- F (#)
						else state <= COL4W;
						end if;
					when COL4W =>
						C <= "1110";
						state <= COL4L;
					when COL4L =>
						if    L1='0' then digit_hexa <= "1010"; state <= WAIT_STATE; -- A
						elsif L2='0' then digit_hexa <= "1011"; state <= WAIT_STATE; -- B
						elsif L3='0' then digit_hexa <= "1100"; state <= WAIT_STATE; -- C
						elsif L4='0' then digit_hexa <= "1101"; state <= WAIT_STATE; -- D
						else state <= COL1W;
						end if;
					when WAIT_STATE =>
						if L1='1' and L2='1' and L3='1' and L4='1' then
							state <= COL1W;
						end if;
				end case;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;
end architecture;
