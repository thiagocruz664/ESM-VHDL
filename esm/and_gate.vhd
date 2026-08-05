library ieee;
use ieee.std_logic_1164.all;

entity and_gate is
	port (
		a : in std_logic_vector (15 downto 0);
		b : in std_logic_vector (15 downto 0);
		x : out std_logic_vector (15 downto 0)
	);
end entity;

architecture func of and_gate is
begin
	x <= a and b;
end architecture;
