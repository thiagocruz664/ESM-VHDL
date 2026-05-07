library ieee;
use ieee.std_logic_1164.all;

entity not_gate is
	port (
		a : in std_logic;
		x : out std_logic
	);
end entity;

architecture func of not_gate is
begin
	x <= not a;
end architecture;
