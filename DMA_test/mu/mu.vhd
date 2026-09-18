library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_u is
    port (
        a1, a2, wd2 : in std_logic_vector(15 downto 0);
        clk, we : in std_logic;
        rd1, rd2 : out std_logic_vector(15 downto 0);
			
        -- Interfaz Avalon Streaming (Conexión al mSGDMA)
        dma_data          : in  std_logic_vector(15 downto 0); 
        dma_valid         : in  std_logic;                     
        dma_startofpacket : in  std_logic;                     
        dma_ready         : out std_logic
    );
end entity;

architecture func_mem_u of mem_u is
    type ram_type is array (0 to 65535) of std_logic_vector(15 downto 0);
		signal mem_ram : ram_type := (others => (others => '0'));
	 
    signal addr_b_reg : unsigned(15 downto 0) := (others => '0');
begin
    dma_ready <= '1'; -- Siempre listos

    process(clk)
    begin
        if rising_edge(clk) then
            -- LECTURA RD1
            rd1 <= mem_ram(to_integer(unsigned(a1)));
				
            -- UN SOLO BLOQUE DE ESCRITURA CON PRIORIDAD ESTABLECIDA
            if (dma_valid = '1') then
                -- Prioridad 1: Si el DMA manda datos, toma el control de las escrituras
                if (dma_startofpacket = '1') then
                    mem_ram(0) <= dma_data;
                    addr_b_reg <= to_unsigned(1, 16);
                else
                    mem_ram(to_integer(addr_b_reg)) <= dma_data;
                    if addr_b_reg < 65535 then
                        addr_b_reg <= addr_b_reg + 1;
                    else
                        addr_b_reg <= (others => '0');
                    end if;
                end if;
            elsif we = '1' then
                -- Prioridad 2: Si el DMA está inactivo, el teclado puede escribir
                mem_ram(to_integer(unsigned(a2))) <= wd2;
				else
					-- Prioridad 3: Si no hay ninguna escritura lee el dato de a2
					 rd2 <= mem_ram(to_integer(unsigned(a2)));
            end if;
        end if;
    end process;
end architecture;
