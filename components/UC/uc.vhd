library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    port (
        instruction : in  std_logic_vector(15 downto 0);
        alu_cc      : in  std_ulogic_vector(2 downto 0);
        
        we          : out std_logic;
        alu_control : out std_logic_vector(1 downto 0);
        mux1_sel    : out std_logic;
        mux2_sel    : out std_logic;
        mux3_sel    : out std_logic;
        mux4_sel    : out std_logic;
	acc_we : out std_logic
    );
end entity;

architecture bhv of control_unit is
    signal opcode : std_logic_vector(2 downto 0);
    signal branch_match : std_logic;
begin
    opcode <= instruction(15 downto 13);
    
    branch_match <= (instruction(11) and alu_cc(2)) or 
                    (instruction(10) and alu_cc(1)) or 
                    (instruction(9)  and alu_cc(0));

    we <= '1' when opcode = "011" and instruction(12) = '1' else '0';
    
    alu_control <= "01" when opcode = "001" else
                   "10" when opcode = "010" else
                   "00";
                   
    mux4_sel <= '1' when opcode = "011" and instruction(12) = '0' else '0';
    
    mux1_sel <= '1' when opcode = "100" and branch_match = '1' else '0';
    
    mux2_sel <= '0' when opcode = "010" and instruction(12) = '1' else '1';
    
    mux3_sel <= '1' when opcode = "100" else '0'; 
    
    acc_we <= '1' when (opcode = "000" or opcode = "001" or opcode = "010" or (opcode = "011" and instruction(12) = '0')) else '0';

end architecture;

