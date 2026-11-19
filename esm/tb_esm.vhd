library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_esm is
end entity;

architecture behavior of tb_esm is
    signal clk_50mhz : std_logic := '0';
    signal reset     : std_logic := '0';

    -- Señales entre el adaptador y el ESM
    signal esm_a1    : std_logic_vector(15 downto 0);
    signal esm_a2    : std_logic_vector(15 downto 0);
    signal esm_rd1   : std_logic_vector(15 downto 0) := (others => '0');
    signal esm_rd2   : std_logic_vector(15 downto 0) := (others => '0');
    signal esm_wd2   : std_logic_vector(15 downto 0);
    signal esm_we    : std_logic;

    -- Adaptador síncrono de 8 pasos (50 MHz -> 6.25 MHz CPU)
    signal clk_cpu   : std_logic := '0';
    signal sub_step  : unsigned(2 downto 0) := "000";

    -- RAM precargada con Ejemplo 1 del paper (OR entre X=10 e Y=18 -> R=26 = 0x001A)
    type ram_type is array (0 to 15) of std_logic_vector(15 downto 0);
    signal sim_ram : ram_type := (
        0 => "0100000000000110", -- 0x4006: NOTA X (0 + 1 + 6 = 7)
        1 => "0111000000000101", -- 0x7005: ST X   (1 + 1 + 5 = 7)
        2 => "0100000000000101", -- 0x4005: NOTA Y (2 + 1 + 5 = 8)
        3 => "0010000000000011", -- 0x2003: AND X  (3 + 1 + 3 = 7)
        4 => "0101000000000000", -- 0x5000: NOTB
        5 => "0111000000000011", -- 0x7003: ST R   (5 + 1 + 3 = 9)
        6 => "1001111111111111", -- 0x9FFF: BR $   (NZP=111, offset=-1 -> PC=6)
        7 => std_logic_vector(to_unsigned(10, 16)), -- X = 10 (0x000A)
        8 => std_logic_vector(to_unsigned(18, 16)), -- Y = 18 (0x0012)
        9 => std_logic_vector(to_unsigned(0, 16)),  -- R = 0  (debe terminar en 0x001A)
        others => (others => '0')
    );

    signal ram_address  : std_logic_vector(15 downto 0) := (others => '0');
    signal ram_readdata : std_logic_vector(15 downto 0) := (others => '0');
    signal ram_write    : std_logic := '0';
begin
    uut : entity work.esm
        port map (
            clk   => clk_cpu,
            reset => reset,
            rd1   => esm_rd1,
            rd2   => esm_rd2,
            a1    => esm_a1,
            a2    => esm_a2,
            wd2   => esm_wd2,
            we    => esm_we
        );

    -- Reloj de 50 MHz (período 20 ns), 100 ciclos = 12 ciclos de CPU
    clk_process : process
    begin
        for i in 1 to 100 loop
            clk_50mhz <= '0';
            wait for 10 ns;
            clk_50mhz <= '1';
            wait for 10 ns;
        end loop;

        -- Verificación automática al terminar
        assert sim_ram(9) = x"001A"
            report "FALLO: R (sim_ram(9)) no es 0x001A (26), valor actual = " &
                   integer'image(to_integer(unsigned(sim_ram(9))))
            severity error;
        assert sim_ram(9) /= x"001A"
            report "EXITO: R (sim_ram(9)) = 26 (0x001A) y PC = " &
                   integer'image(to_integer(unsigned(esm_a1)))
            severity note;
        wait;
    end process;

    -- Adaptador síncrono de 8 pasos (compatible con BRAM síncrona de 1 ciclo)
    process(clk_50mhz, reset)
    begin
        if reset = '0' then
            sub_step    <= "000";
            clk_cpu     <= '0';
            esm_rd1     <= (others => '0');
            esm_rd2     <= (others => '0');
            ram_address <= (others => '0');
            ram_write   <= '0';
        elsif rising_edge(clk_50mhz) then
            sub_step  <= sub_step + 1;
            clk_cpu   <= '0';
            ram_write <= '0';

            case sub_step is
                when "000" =>
                    ram_address <= esm_a1;       -- 1. Presentar PC
                when "001" =>
                    null;                        -- 2. Esperar latencia de lectura BRAM
                when "010" =>
                    esm_rd1     <= ram_readdata; -- 3. Capturar instrucción (asienta a2 y we)
                when "011" =>
                    ram_address <= esm_a2;       -- 4. Presentar dirección de dato
                    ram_write   <= esm_we;       --    Activar escritura si es ST
                when "100" =>
                    null;                        -- 5. La BRAM lee/escribe en a2
                when "101" =>
                    esm_rd2     <= ram_readdata; -- 6. Capturar dato (asienta ALU/acc_next)
                when "110" =>
                    clk_cpu     <= '1';          -- 7. Flanco de reloj al CPU
                when "111" =>
                    clk_cpu     <= '0';          -- 8. Fin de ciclo
                when others =>
                    null;
            end case;
        end if;
    end process;

    -- Modelo de BRAM síncrona (igual que s2mem en Quartus/Qsys)
    process(clk_50mhz)
        variable idx : integer;
    begin
        if rising_edge(clk_50mhz) then
            idx := to_integer(unsigned(ram_address));
            if idx <= 15 then
                if ram_write = '1' then
                    sim_ram(idx) <= esm_wd2;
                end if;
                ram_readdata <= sim_ram(idx);
            else
                ram_readdata <= (others => '0');
            end if;
        end if;
    end process;

    -- Reset inicial
    stim_proc : process
    begin
        reset <= '0';
        wait until falling_edge(clk_50mhz);
        wait until falling_edge(clk_50mhz);
        reset <= '1';
        wait;
    end process;
end architecture;