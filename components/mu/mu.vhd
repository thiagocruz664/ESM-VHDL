library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; --Se importa para el uso de vectores
use work.data_types.all;

entity mu is
    port (
        a1 : in std_ulogic_vector(2 downto 0);
        a2 : in std_ulogic_vector(2 downto 0);
        wd2 : in std_ulogic_vector(2 downto 0);
        clk : in std_logic;
        we : in std_logic;
        rd1 : out std_logic_vector(15 downto 0);
        rd2 : out std_logic_vector(15 downto 0)
    );
end entity;

architecture func of mu is

    type ram_type is array (0 to 65535) of std_logic_vector(15 downto 0);

    signal ram : ram_type := (
        --se inicializa todo en cero, aca se deberia agregar todo lo que son protocolos de traps
        others => (others => '0')
    );
begin
    process
    begin
        if rising_edge(clk) then
            rd1 <= ram(to_integer(a1));
            if we = '1' then
                ram(to_integer(a2)) <= wd2;
            else
                rd2 <= ram(to_integer(a2));
            end if;
        end if;
    end process;
end architecture;