library ieee;
use ieee.std_logic_1164.all;

entity tb_ag is
end entity;

architecture sim of tb_ag is
	signal a, b, x_and, x_or, x_not : std_logic;
begin
	and_gate: entity work.and_gate
		port map (
			a => a,
			b => b,
			x => x_and
		);
	or_gate: entity work.or_gate
		port map (
			a => a,
			b => b,
			x => x_or
		);
	not_gate: entity work.not_gate
		port map (
			a => a,
			x => x_not
		);

	process
	begin
	    a <= '0'; b <= '0';
	    wait for 10 ns;

	    a <= '0'; b <= '1';
	    wait for 10 ns;

	    a <= '1'; b <= '0';
	    wait for 10 ns;

	    a <= '1'; b <= '1';
	    wait for 10 ns;

		a <= '0'; b <= '0'; --esta ultima linea es porque si no registra un cambio el vcd para 10ns, ignorando el wait previo
	    wait;
	end process;

end architecture;
