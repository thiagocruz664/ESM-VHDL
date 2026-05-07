library ieee;
use ieee.std_logic_1164.all;

entity tb_not is
end entity;

architecture sim of tb_not is
	signal a, x : std_logic;
begin
	uut: entity work.not_gate
		port map (
			a => a,
			x => x
		);
	process
	begin
		a <= '0';
		wait for 10 ns;

		a <= '1';
		wait for 10 ns;

		a <= '0';
		wait;
	end process;
end architecture;
