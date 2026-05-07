library ieee;
use ieee.std_logic_1164.all;

entity or_gate is
	port (
		a : in std_logic;
		b : in std_logic;
		x : out std_logic
	);
end entity;

architecture func of or_gate is
begin
	x <= a or b;
end architecture;
