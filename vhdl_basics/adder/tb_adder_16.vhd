library ieee;
use ieee.std_logic_1164.all;

entity tb_adder is
end tb_adder;

architecture sim of tb_adder is
    signal a,b,s : std_logic_vector (15 downto 0);
begin
    uut: entity work.adder
        port map (
            a => a,
            b => b,
            s => s
        );
    
    process
    begin
        a <= x"0000"; b <= x"000A";
		wait for 10 ps;

        a <= x"000A"; b <= x"FFFF";
		wait for 10 ps;

        a <= x"000A"; b <= x"000A";
		wait for 10 ps;

        a <= x"A0A0"; b <= x"A333";
		wait for 10 ps;

		wait;
    end process;
end architecture;