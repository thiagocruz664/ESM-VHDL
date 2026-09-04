library ieee;
use ieee.std_logic_1164.all;

entity tb_uc is
end entity;

architecture behavior of tb_uc is
    signal instruction_full : std_logic_vector(15 downto 0) := (others => '0');
    signal alu_cc           : std_ulogic_vector(2 downto 0) := "000";
    signal we, mux1_sel, mux2_sel, mux3_sel, mux4_sel, acc_we : std_logic;
    signal alu_control      : std_logic_vector(1 downto 0);
begin
    uut: entity work.control_unit
        port map (
            instruction => instruction_full, alu_cc => alu_cc, we => we,
            alu_control => alu_control, mux1_sel => mux1_sel, mux2_sel => mux2_sel,
            mux3_sel => mux3_sel, mux4_sel => mux4_sel, acc_we => acc_we
        );

    stim_proc: process
    begin
        -- Test 1: ALU Opcode 000
        instruction_full <= "0000000000000000"; alu_cc <= "000"; wait for 10 ns;
        -- Test 2: ALU Opcode 001
        instruction_full <= "0010000000000000"; wait for 10 ns;
        -- Test 3: ALU Opcode 010 (bit 12=0) -> Evalúa MUX2_sel en '1'
        instruction_full <= "0100000000000000"; wait for 10 ns;
        -- Test 4: ALU Opcode 010 (bit 12=1) -> Evalúa MUX2_sel en '0'
        instruction_full <= "0101000000000000"; wait for 10 ns;
        -- Test 5: Load (011, bit 12=0) -> Evalúa MUX4_sel y acc_we
        instruction_full <= "0110000000000000"; wait for 10 ns;
        -- Test 6: Store (011, bit 12=1) -> Evalúa we
        instruction_full <= "0111000000000000"; wait for 10 ns;
        -- Test 7: Branch (100) -> Coincidencia, MUX1_sel en '1'
        instruction_full <= "1000010000000000"; alu_cc <= "010"; wait for 10 ns;
        -- Test 8: Branch (100) -> Fallo, MUX1_sel vuelve a '0'
        instruction_full <= "1000010000000000"; alu_cc <= "001"; wait for 10 ns;
        wait;
    end process;
end architecture;
