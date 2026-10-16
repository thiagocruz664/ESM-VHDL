library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity alu is
    port (
        a_alu, b_alu : in std_logic_vector(15 downto 0);
        control      : in std_logic_vector(1 downto 0);
        salida_alu   : out std_logic_vector(15 downto 0);
        flags        : out std_ulogic_vector(2 downto 0) -- nzp
    );
end entity;

architecture func of alu is
    signal mux_entradas : entradas;
    signal resultado    : std_logic_vector(15 downto 0);
begin
    g_add : entity work.adder
        port map(a => a_alu, b => b_alu, s => mux_entradas(0));

    g_and : entity work.and_gate
        port map(a => a_alu, b => b_alu, x => mux_entradas(1));

    g_nota : entity work.not_gate
        port map(a => a_alu, x => mux_entradas(2));

    g_notb : entity work.not_gate
        port map(a => b_alu, x => mux_entradas(3));

    g_mux : entity work.mux
        port map(
            entradas => mux_entradas,
            salida   => resultado,
            s        => control
        );
    
    salida_alu <= resultado;

    process(resultado)
    begin
        if is_x(resultado) then
            flags <= "000";
        elsif signed(resultado) > 0 then
            flags <= "001"; -- P
        elsif signed(resultado) < 0 then
            flags <= "100"; -- N
        else
            flags <= "010"; -- Z
        end if;
    end process;
end architecture;