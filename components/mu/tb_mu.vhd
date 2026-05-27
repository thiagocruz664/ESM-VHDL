library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; --Se importa para el uso de vectores

entity tb_mu is
end entity;

architecture sim of tb_mu is
    signal a1, a2, wd2 : std_logic_vector(15 downto 0);
    signal clk, we : std_logic;
    signal rd1, rd2 : std_logic_vector(15 downto 0);
begin
    uut : entity work.mu
        port map (
            a1 => a1, a2 => a2, wd2 => wd2,
            clk => clk, we => we,
            rd1 => rd1, rd2 => rd2
        );
    process
    begin
        clk <= '0';
        a1 <= x"000A"; a2 <= x"000A"; wd2 <= x"AAAA";
        we <= '1';
        wait for 10 ps;
        clk <= '1';
		wait for 10 ps;
        clk <= '0';
        a1 <= x"000A"; a2 <= x"000A"; wd2 <= x"BBBB";
        we <= '0';
        wait for 10 ps;
        clk <= '1';
		wait for 10 ps;
        clk <= '0';
        a1 <= x"000A"; a2 <= x"FF0A"; wd2 <= x"FFFF";
        we <= '1';
        wait for 10 ps;
        clk <= '1';
		wait for 10 ps;
        clk <= '0';
        a1 <= x"FF0A"; a2 <= x"0003"; wd2 <= x"1034";
        we <= '1';
        wait for 10 ps;
        clk <= '1';
		wait for 10 ps;
        clk <= '0';
        a1 <= x"0003"; a2 <= x"0003"; wd2 <= x"EEEE";
        we <= '0';
        wait for 10 ps;
        clk <= '1';
		wait for 10 ps;
        clk <= '0';
        wait;
    end process;
end architecture;