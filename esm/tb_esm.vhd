library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_esm is
end entity;

architecture behavior of tb_esm is
    signal clk_50mhz : std_logic := '0';
    signal reset     : std_logic := '0';
    
    -- Señales entre el adaptador simulado y el ESM
    signal esm_a1    : std_logic_vector(15 downto 0);
    signal esm_a2    : std_logic_vector(15 downto 0);
    signal esm_rd1   : std_logic_vector(15 downto 0);
    signal esm_rd2   : std_logic_vector(15 downto 0);
    signal esm_wd2   : std_logic_vector(15 downto 0);
    signal esm_we    : std_logic;

    -- Señales del adaptador síncrono
    signal clk_cpu   : std_logic := '0';
    signal sub_step  : unsigned(1 downto 0) := "00";
    
    -- Memoria RAM precargada con el Ejemplo 1 y BR incondicional correcto[cite: 26, 28]
    type ram_type is array (0 to 9) of std_logic_vector(15 downto 0);
    signal sim_ram : ram_type := (
        0 => "0100000000000110", -- NOTA X (PC=0 -> 0 + 1 + 6 = 7)[cite: 28]
        1 => "0111000000000101", -- ST X   (PC=1 -> 1 + 1 + 5 = 7)[cite: 28]
        2 => "0100000000000101", -- NOTA Y (PC=2 -> 2 + 1 + 5 = 8)[cite: 28]
        3 => "0010000000000011", -- AND X  (PC=3 -> 3 + 1 + 3 = 7)[cite: 28]
        4 => "0101000000000000", -- NOTB   (PC=4)[cite: 28]
        5 => "0111000000000011", -- ST R   (PC=5 -> 5 + 1 + 3 = 9)[cite: 28]
        6 => "1001111111111111", -- BR $ (Salto incondicional NZP=111, offset=-1)[cite: 26]
        7 => std_logic_vector(to_unsigned(10, 16)), -- X = 10[cite: 28]
        8 => std_logic_vector(to_unsigned(18, 16)), -- Y = 18[cite: 28]
        9 => std_logic_vector(to_unsigned(0, 16)),  -- R = 0[cite: 28]
        others => (others => '0')
    );
    
    signal ram_address  : std_logic_vector(15 downto 0);
    signal ram_readdata : std_logic_vector(15 downto 0);
    signal ram_write    : std_logic;
begin
    -- Instanciación del procesador esm monociclo puro
    uut: entity work.esm
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

    -- Generación del reloj principal de 50 MHz de la placa
    clk_process: process
    begin
        for i in 1 to 200 loop
            clk_50mhz <= '0';
            wait for 5 ns;
            clk_50mhz <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Adaptador síncrono de 4 pasos
    process(clk_50mhz, reset)
    begin
        if reset = '0' then
            sub_step    <= "00";
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
                when "00" =>
                    ram_address <= esm_a1; -- 1. Presentamos la dirección del PC (a1)
                when "01" =>
                    esm_rd1     <= ram_readdata; -- 2. Capturamos la instrucción leída
                    ram_address <= esm_a2;       -- 3. Presentamos de una vez a2
                when "10" =>
                    esm_rd2     <= ram_readdata; -- 4. Capturamos el dato de a2
                    ram_write   <= esm_we;       --    Activamos escritura si es ST
                when "11" =>
                    clk_cpu     <= '1';          --    Disparamos el ciclo del CPU
                when others =>
                    null;
            end case;
        end if;
    end process;

    -- Modelo de memoria RAM combinacional para simulación estable en GHDL
    ram_readdata <= sim_ram(to_integer(unsigned(ram_address)));

    process(clk_50mhz)
    begin
        if rising_edge(clk_50mhz) then
            if ram_write = '1' then
                sim_ram(to_integer(unsigned(ram_address))) <= esm_wd2;
            end if;
        end if;
    end process;

    -- Control de Reset sincronizado
    stim_proc: process
    begin
        reset <= '0';
        wait until falling_edge(clk_50mhz);
        wait until falling_edge(clk_50mhz);
        reset <= '1';
        wait;
    end process;
end architecture;