library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; --Se importa para el uso de vectores
use ieee.numeric_std.all;

entity mem_u is
    port (
        a1, a2, wd2 : in std_logic_vector(15 downto 0);
        clk, we : in std_logic;
        rd1, rd2 : out std_logic_vector(15 downto 0);
			
			-- Interfaz Avalon Streaming (Conexión al mSGDMA)
        dma_data          : in  std_logic_vector(15 downto 0); -- Viene del mSGDMA (asi_data)
        dma_valid         : in  std_logic;                     -- Viene del mSGDMA (asi_valid)
        dma_startofpacket : in  std_logic;                     -- Viene del mSGDMA (asi_startofpacket)
        dma_ready         : out std_logic
	 );
end entity;

architecture func_mem_u of mem_u is

    type ram_type is array (0 to 65535) of std_logic_vector(15 downto 0);

    signal mem_ram : ram_type := (
        --se inicializa todo en cero, aca se deberia agregar todo lo que son protocolos de traps
        others => (others => '0')
    );
	 
	 -- Dirección interna automatizada para la paginación del DMA
    signal addr_b_reg : unsigned(15 downto 0) := (others => '0');
begin
	dma_ready <= '1'; --Siempre recibe datos
    process(clk)
    begin
        if rising_edge(clk) then
            rd1 <= mem_ram(to_integer(unsigned(a1)));
            if we = '1' then
                mem_ram(to_integer(unsigned(a2))) <= wd2;
            else
                rd2 <= mem_ram(to_integer(unsigned(a2)));
            end if;
				 -- Si el mSGDMA presenta un dato válido...
				 if (dma_valid = '1') then
					  
					  -- CONTROL DE AUTO-RESET: Si es el inicio de una nueva ráfaga,
					  -- forzamos la escritura en la dirección 0x0000 y reiniciamos el contador.
					  if (dma_startofpacket = '1') then
							mem_ram(0) <= dma_data;
							addr_b_reg <= to_unsigned(1, 16); -- El siguiente irá a la dirección 1
					  else
							-- Flujo normal: escribe en la posición actual e incrementa
							mem_ram(to_integer(addr_b_reg)) <= dma_data;
							
							-- Control para evitar desbordamiento de la RAM (0 a 65535)
							if addr_b_reg < 65535 then
								 addr_b_reg <= addr_b_reg + 1;
							else
								 addr_b_reg <= (others => '0'); -- Seguridad: vuelve a 0 si se pasa del límite
							end if;
					  end if;    
				end if;
		  end if;
    end process;
end architecture;