library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_esm is
end entity;

architecture behavior of tb_esm is
    signal clk               : std_logic := '0';
    signal enable            : std_logic := '0';
    signal dma_data          : std_logic_vector(15 downto 0) := (others => '0');
    signal dma_valid         : std_logic := '0';
    signal dma_startofpacket : std_logic := '0';
    signal dma_ready         : std_logic;

    type prog_array is array (0 to 8) of std_logic_vector(15 downto 0);
    constant prog_ejemplo1 : prog_array := (
        0 => "0100000000000101", -- NOTA X
        1 => "0111000000000100", -- ST X
        2 => "0100000000000100", -- NOTA Y
        3 => "0010000000000010", -- AND X
        4 => "0101000000000000", -- NOTB
        5 => "0111000000000010", -- ST R
        6 => std_logic_vector(to_unsigned(10, 16)), -- X = 10
        7 => std_logic_vector(to_unsigned(18, 16)), -- Y = 18
        8 => std_logic_vector(to_unsigned(0, 16))   -- R = 0
    );
begin
    uut: entity work.esm
        port map (
            clk               => clk,
            enable            => enable,
            dma_data          => dma_data,
            dma_valid         => dma_valid,
            dma_startofpacket => dma_startofpacket,
            dma_ready         => dma_ready
        );

    -- Reloj de 10 ns (40 ciclos = 400 ns)
    clk_process: process
    begin
        for i in 1 to 40 loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Proceso que simula al mSGDMA cargando la RAM y luego activa el CPU
    stim_proc: process
    begin
        -- 1. Carga vía DMA (9 palabras)
        for i in 0 to 8 loop
            dma_valid <= '1';
            dma_data  <= prog_ejemplo1(i);
            if i = 0 then
                dma_startofpacket <= '1';
            else
                dma_startofpacket <= '0';
            end if;
            wait for 10 ns;
        end loop;

        -- 2. Fin del DMA y arranque del procesador ESM
        dma_valid         <= '0';
        dma_startofpacket <= '0';
        enable            <= '1';
        wait;
    end process;
end architecture;