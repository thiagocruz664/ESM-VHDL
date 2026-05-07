
library ieee;
use ieee.std_logic_1164.all;

entity tb_or is
end entity;

architecture sim of tb_or is
	signal a, b, x : std_logic;
begin
	-- Unit Under Test
	-- work.and_gate importa la unidad ya instanciada
	uut: entity work.or_gate
		port map ( --se linkean las señales del tb con las de and_gate
			a => a,
			b => b,
			x => x
		);

	process --Bloque de ejecucion secuencial
	begin
		a <= '0'; b <= '0';
		wait for 10 ns;

		a <= '0'; b <= '1';
		wait for 10 ns;

		a <= '1'; b <= '0';
		wait for 10 ns;

		a <= '1'; b <= '1';
		wait for 10 ns;

		a <= '0'; b <= '0';
		wait;
    end process;
end architecture;
