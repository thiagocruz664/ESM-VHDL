library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; --Se importa para el uso de vectores

package data_types is
    type entradas is array (0 to 3) of std_logic_vector(15 downto 0);
end package;

--Aca hay que definir nuevamente lo que se va a usar para entity ya que package entity y architecture 
--son modulos separados, y hay que definir para cada uno lo que se va a ocupar
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; --Se importa para el uso de vectores
use work.data_types.all;

entity mux is
    port (
        s : in std_logic_vector (1 downto 0);
        entradas : in entradas;
        salida : out std_logic_vector (15 downto 0) 
    );
end entity;

architecture logic_flow of mux is
    begin
        salida <= entradas(0) when(s(0)='0' and s(1)='0') else
                    entradas(1) when(s(0)='1' and s(1)='0') else
                    entradas(2) when(s(0)='0' and s(1)='1') else
                    entradas(3);
end architecture;
