library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; --Se importa para el uso de vectores

entity adder is
    port (
        a : in std_logic_vector (15 downto 0);
        b : in std_logic_vector (15 downto 0);
        s : out std_logic_vector (15 downto 0)
    );
end adder;

architecture func of adder is
    begin
        s <= std_logic_vector(unsigned(a) + unsigned(b));
        -- Esto en la FPGA se mapea como un adder mas moderno
        -- Look-Up Tables para la logica
        -- Carry chains dedicadas
        -- Si se quieciera hacer un adder de libro, hay que definir un full adder y conectar 16 de esos (mucho quilombo)
end func;