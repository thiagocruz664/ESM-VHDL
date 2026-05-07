library ieee;
use ieee.std_logic_1164.all;

entity and_gate is
	port (
		a : in std_logic;
		b : in std_logic;
		x : out std_logic
	);
end entity;

architecture func of and_gate is
begin
	x <= a and b;
end architecture;
