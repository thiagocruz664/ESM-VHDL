library ieee;
use ieee.std_logic_1164.all;
use work.data_types.all;

entity tb_mux is
end tb_mux;

architecture sim of tb_mux is
    signal tb_entradas : entradas;
    signal salida : std_logic_vector(15 downto 0);
    signal s : std_logic_vector(1 downto 0);
begin
    uut: entity work.mux
        port map (
            entradas => tb_entradas,
            salida => salida,
            s => s
        );
    
    process
    begin
        tb_entradas(0) <= x"000A"; tb_entradas(1) <= x"00A0"; 
        tb_entradas(2) <= x"0A00"; tb_entradas(3) <= x"A000";

        s <= "00";
		wait for 10 ps;

        s <= "01";
		wait for 10 ps;

        s <= "10";
		wait for 10 ps;

        s <= "11";
		wait for 10 ps;

        s <= "00";
		wait;
    end process;
end architecture;