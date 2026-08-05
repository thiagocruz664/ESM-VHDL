library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; --Se importa para el uso de vectores
use work.data_types.all;

entity alu is
    port (
        a_alu,b_alu : in std_logic_vector(15 downto 0);
        control : in std_logic_vector(1 downto 0);
        salida_alu : out std_logic_vector(15 downto 0);
        flags : out std_ulogic_vector(2 downto 0) --nzp
    );
end entity;

architecture func of alu is
    signal mux_entradas : entradas;
    signal resultado : std_logic_vector(15 downto 0);
begin
    g_add : entity work.adder
        port map(
            a => a_alu,
            b => b_alu,
            s => mux_entradas(0)
        );

    g_and : entity work.and_gate
        port map(
            a => a_alu,
            b => b_alu,
            x => mux_entradas(1)
        );

    g_not : entity work.not_gate
        port map(
            a => a_alu,
            x => mux_entradas(2)
        );

    g_mux : entity work.mux
        port map(
            entradas(0) => mux_entradas(0),
            entradas(1) => mux_entradas(1),
            entradas(2) => mux_entradas(2),
            entradas(3) => (others => '0'),
            salida => resultado,
            s => control
        );
    
    salida_alu <= resultado;

    process(resultado)
    begin
        if is_x(resultado) then --Esto esta aca solo pq al inicio puede haber alguna señal indefinida lo cual rompe signed
            flags <= "000";
        elsif signed(resultado) > 0 then
            flags <= "001";
        elsif signed(resultado) < 0 then
            flags <= "100";
        else
            flags <= "010";
        end if;
    end process;
end architecture;