library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_types.all;

entity esm is
    port (
        clk : in std_logic
    );
end entity;

architecture func of esm is
    -- Señales de la ALU
    signal a_alu_in, b_alu_in, alu_out : std_logic_vector(15 downto 0);
    signal alu_cc : std_ulogic_vector(2 downto 0);
    signal alu_control : std_logic_vector(1 downto 0);
    
    -- Señales de memoria y control
    signal instruction : std_logic_vector(15 downto 0);
    signal mem_data_out : std_logic_vector(15 downto 0);
    signal we, mux1_sel, mux2_sel, mux3_sel, mux4_sel : std_logic;
    signal acc_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal acc_we : std_logic;
    
    -- Señales del Contador de Programa
    signal pc_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal pc_target : std_logic_vector(15 downto 0);

begin
    g_alu : entity work.alu
        port map(
            a_alu      => a_alu_in,
            b_alu      => b_alu_in,
            control    => alu_control,
            salida_alu => alu_out,
            flags      => alu_cc
        );

    mu : entity work.mu
        port map(
            a1  => pc_reg,
            rd1 => instruction,
            a2  => alu_out,
            wd2 => a_alu_in,
            clk => clk,
            we  => we,
            rd2 => mem_data_out
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
            mux4_sel    => mux4_sel,
	    acc_we	=> acc_we
        );
	
    --Proceso para el PC
    process(clk)
    begin
        if rising_edge(clk) then
            if mux1_sel = '1' then
               pc_reg <= pc_target;
            else
               pc_reg <= std_logic_vector(unsigned(pc_reg) + 1);
            end if;
        end if;
    end process;

   process(clk)
   begin
      if rising_edge(clk) then
        if acc_we = '1' then
            acc_reg <= alu_out; 
        end if;
      end if;
   end process;

end architecture;
