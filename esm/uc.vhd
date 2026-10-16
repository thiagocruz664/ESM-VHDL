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
        acc_we      : out std_logic
    );
end entity;

architecture bhv of control_unit is
    signal opcode       : std_logic_vector(2 downto 0);
    signal branch_match : std_logic;
begin
    opcode <= instruction(15 downto 13);
    
    -- Fig. 5: N=bit 12, Z=bit 11, P=bit 10
    branch_match <= (instruction(12) and alu_cc(2)) or 
                    (instruction(11) and alu_cc(1)) or 
                    (instruction(10) and alu_cc(0));

    -- MEM WE: solo en ST (opcode 011 y bit 12 = 1)
    we <= '1' when opcode = "011" and instruction(12) = '1' else '0';
    
    -- ALUControl: 00=ADD, 01=AND, 10=NOTA (bit 12=0), 11=NOTB (bit 12=1)
    alu_control <= "00" when opcode = "000" else
                   "01" when opcode = "001" else
                   "10" when opcode = "010" and instruction(12) = '0' else
                   "11" when opcode = "010" and instruction(12) = '1' else
                   "00";
                   
    -- MUX1: 1 cuando es BR (100) y coincide NZP
    mux1_sel <= '1' when opcode = "100" and branch_match = '1' else '0';
    
    -- MUX2 (Entrada A de ALU): 1 para imm12 (ADD/AND con bit 12=1), 0 para Memoria (RD2)
    mux2_sel <= '1' when (opcode = "000" or opcode = "001") and instruction(12) = '1' else '0';
    
    -- MUX3 (Offset sumador): 1 para PCoffset10 (BR), 0 para PCoffset12 (resto)
    mux3_sel <= '1' when opcode = "100" else '0'; 
    
    -- MUX4 (Entrada Acumulador): 1 para LD (Memoria), 0 para salida de ALU
    mux4_sel <= '1' when opcode = "011" and instruction(12) = '0' else '0';
    
    -- Escritura en Acumulador (todas las que tienen + en el paper: ADD, AND, NOT, LD)
    acc_we <= '1' when (opcode = "000" or opcode = "001" or opcode = "010" or 
                       (opcode = "011" and instruction(12) = '0')) else '0';
end architecture;