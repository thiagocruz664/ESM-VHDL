library ieee;
use ieee.std_logic_1164.all;

entity not_gate is
	port (
		a : in std_logic_vector (15 downto 0);
		x : out std_logic_vector (15 downto 0)
	);
end entity;

architecture func of not_gate is
begin
	x <= not a;
end architecture;
