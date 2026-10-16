library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mu is
    port (
        a1, a2, wd2       : in  std_logic_vector(15 downto 0);
        clk, we           : in  std_logic;
        rd1, rd2          : out std_logic_vector(15 downto 0);
        
        -- Interfaz Avalon Streaming (Conexión al mSGDMA)
        dma_data          : in  std_logic_vector(15 downto 0);
        dma_valid         : in  std_logic;
        dma_startofpacket : in  std_logic;
        dma_ready         : out std_logic
    );
end entity;

architecture func of mu is
    type ram_type is array (0 to 65535) of std_logic_vector(15 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    signal addr_b_reg : unsigned(15 downto 0) := (others => '0');
begin
    dma_ready <= '1';

    process(clk)
    begin
        if rising_edge(clk) then
            -- Lectura síncrona RD1
            rd1 <= ram(to_integer(unsigned(a1)));

            -- Bloque de escritura/lectura con prioridad
            if dma_valid = '1' then
                -- Prioridad 1: Carga de programa vía DMA
                if dma_startofpacket = '1' then
                    ram(0)     <= dma_data;
                    addr_b_reg <= to_unsigned(1, 16);
                else
                    ram(to_integer(addr_b_reg)) <= dma_data;
                    if addr_b_reg < 65535 then
                        addr_b_reg <= addr_b_reg + 1;
                    else
                        addr_b_reg <= (others => '0');
                    end if;
                end if;
            elsif we = '1' then
                -- Prioridad 2: Escritura de CPU (ST) o Teclado
                ram(to_integer(unsigned(a2))) <= wd2;
            else
                -- Prioridad 3: Lectura síncrona RD2
                rd2 <= ram(to_integer(unsigned(a2)));
            end if;
        end if;
    end process;
end architecture;