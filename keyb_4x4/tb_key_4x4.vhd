library ieee;
use ieee.std_logic_1164.all;

entity tb_keyb_4x4 is
end entity;

architecture sim of tb_keyb_4x4 is

    signal L1, L2, L3, L4 : std_logic := '1';
    signal C1, C2, C3, C4 : std_logic;
    signal digit_hexa     : std_logic_vector(3 downto 0);
    signal clk            : std_logic := '0';

begin

    uut : entity work.keyb_4x4
        port map (
            L1 => L1,
            L2 => L2,
            L3 => L3,
            L4 => L4,
            C(0) => C1,
            C(1) => C2,
            C(2) => C3,
            C(3) => C4,
            digit_hexa => digit_hexa,
            clk => clk
        );

    --------------------------------------------------------------------------
    -- Clock 50 MHz
    --------------------------------------------------------------------------
    clk <= not clk after 10 ns;

    --------------------------------------------------------------------------
    -- Estímulos
    --------------------------------------------------------------------------
    stim_proc : process
    begin

        -- Reposo
        L1 <= '1';
        L2 <= '1';
        L3 <= '1';
        L4 <= '1';

        wait for 5 ms;

        ------------------------------------------------------------------
        -- Simular tecla '5' (L2-C2)
        ------------------------------------------------------------------
        wait until C2 = '0';

        L2 <= '0';
        wait for 5 ms;
        L2 <= '1';

        wait for 5 ms;

        ------------------------------------------------------------------
        -- Simular tecla 'A' (L1-C4)
        ------------------------------------------------------------------
        wait until C4 = '0';

        L1 <= '0';
        wait for 5 ms;
        L1 <= '1';

        wait for 5 ms;

        ------------------------------------------------------------------
        -- Simular tecla '#' (L4-C3)
        ------------------------------------------------------------------
        wait until C3 = '0';

        L4 <= '0';
        wait for 5 ms;
        L4 <= '1';

        wait for 5 ms;

        report "Fin de simulacion";

        wait;

    end process;

end architecture;
