library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity esm is
    port (
        pc,result : in std_logic_vector(15 downto 0)
    );
end entity;

architecture func of esm is
    signal a_alu_in, alu_out : std_logic_vector(15 downto 0);
    signal alu_cc : std_ulogic_vector(2 downto 0);
    signal alu_control : std_logic_vector(1 downto 0);

begin
    g_alu : entity work.alu
        port map(
            a_alu => a_alu_in,
            b_alu => result,
            salida_alu => alu_out,
            flags => alu_control
        );

    mu : entity work.mu
        port map(
            a1 => pc,
            rd1 => instruction,
	    a2 => (others => '0'),
	    wd2 => (others => '0'),
	    clk => '0',
	    we => '0',
	    rd2 => open,
        );
    uc : entity work.control_unit
    	port map(
            instruction => instruction,
            alu_cc      => alu_cc,
            we          => we,
            alu_control => alu_control,
            mux1_sel    => mux1_sel,
            mux2_sel    => mux2_sel,
            mux3_sel    => mux3_sel,
            mux4_sel    => mux4_sel
    );
    process
    begin
    end process;
end architecture;
