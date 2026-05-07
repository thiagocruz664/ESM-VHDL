library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; --Se importa para el uso de vectores
use work.data_types.all;

entity tb_alu is
end entity;

architecture func of alu is
    signal a,b,s : std_logic_vector(15 downto 0); 
    signal control : std_logic_vector(1 downto 0);
begin
    uut : entity work.alu
        port map(
            a_alu => a,
            b_alu => b,
            salida_alu => s,
            alu_control => control
        );
    
    process
    begin
        a <= x"000A"; b <= x"00A0"; 

        control <= "00";
		wait for 10 ps;

        control <= "01";
		wait for 10 ps;

        control <= "10";
		wait for 10 ps;


        a <= x"0A00"; b <= x"AA00";

        control <= "00";
		wait for 10 ps;

        control <= "01";
		wait for 10 ps;

        control <= "10";
		wait for 10 ps;

        control <= "00";
		wait;
    end process;

end architecture;