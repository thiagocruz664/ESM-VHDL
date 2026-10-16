library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity esm is
    port (
        clk               : in  std_logic;
        reset             : in  std_logic := '0';
        enable            : in  std_logic := '1'; -- '1': Corre CPU | '0': Pausa CPU y habilita Teclado/LCD

        -- Puertos para el DMA (pasan directo a mu)
        dma_data          : in  std_logic_vector(15 downto 0) := (others => '0');
        dma_valid         : in  std_logic := '0';
        dma_startofpacket : in  std_logic := '0';
        dma_ready         : out std_logic;

        -- Puertos para Teclado y LCD (activos cuando enable = '0')
        ext_a1            : in  std_logic_vector(15 downto 0) := (others => '0');
        ext_a2            : in  std_logic_vector(15 downto 0) := (others => '0');
        ext_wd2           : in  std_logic_vector(15 downto 0) := (others => '0');
        ext_we            : in  std_logic := '0';
        rd1_out           : out std_logic_vector(15 downto 0);
        rd2_out           : out std_logic_vector(15 downto 0);
        a1_out            : out std_logic_vector(15 downto 0);
        a2_out            : out std_logic_vector(15 downto 0)
    );
end entity;

architecture func of esm is
    -- Señales de la ALU y CC
    signal a_alu_in, b_alu_in, alu_out : std_logic_vector(15 downto 0);
    signal alu_flags   : std_ulogic_vector(2 downto 0);
    signal cc_reg      : std_ulogic_vector(2 downto 0) := "010";
    signal alu_control : std_logic_vector(1 downto 0);
    
    -- Señales de memoria y control
    signal instruction, mem_data_out : std_logic_vector(15 downto 0);
    signal mu_a1, mu_a2, mu_wd2      : std_logic_vector(15 downto 0);
    signal mu_we, we_uc, cpu_we      : std_logic;
    signal mux1_sel, mux2_sel, mux3_sel, mux4_sel, acc_we : std_logic;
    signal acc_reg, acc_next : std_logic_vector(15 downto 0) := (others => '0');
    
    -- Señales del Contador de Programa y sumadores
    signal pc_reg, pc_plus_1, offset_adder_out : std_logic_vector(15 downto 0) := (others => '0');
    signal ext12, ext10, mux3_out : std_logic_vector(15 downto 0);

    -- Fase para memoria síncrona (00: Fetch, 01: Read Data, 10: Execute/Write)
    signal phase : unsigned(1 downto 0) := "00";
begin
    ext12 <= std_logic_vector(resize(signed(instruction(11 downto 0)), 16));
    ext10 <= std_logic_vector(resize(signed(instruction(9 downto 0)), 16));

    pc_plus_1        <= std_logic_vector(unsigned(pc_reg) + 1);
    mux3_out         <= ext10 when mux3_sel = '1' else ext12;
    offset_adder_out <= std_logic_vector(signed(pc_plus_1) + signed(mux3_out));

    a_alu_in <= ext12 when mux2_sel = '1' else mem_data_out;
    b_alu_in <= acc_reg;
    acc_next <= mem_data_out when mux4_sel = '1' else alu_out;

    -- Escritura de la CPU solo en la Fase 2 ("10")
    cpu_we <= we_uc when (phase = "10" and enable = '1' and reset = '0' and dma_valid = '0') else '0';

    -- Multiplexación entre CPU (enable='1') y Teclado externo (enable='0')
    mu_a1  <= pc_reg           when enable = '1' else ext_a1;
    mu_a2  <= offset_adder_out when enable = '1' else ext_a2;
    mu_wd2 <= acc_reg          when enable = '1' else ext_wd2;
    mu_we  <= cpu_we           when enable = '1' else ext_we;

    -- Salidas de monitoreo hacia el LCD
    rd1_out <= instruction;
    rd2_out <= mem_data_out;
    a1_out  <= mu_a1;
    a2_out  <= mu_a2;

    g_alu : entity work.alu
        port map(
            a_alu      => a_alu_in,
            b_alu      => b_alu_in,
            control    => alu_control,
            salida_alu => alu_out,
            flags      => alu_flags
        );

    mu : entity work.mu
        port map(
            a1                => mu_a1,
            rd1               => instruction,
            a2                => mu_a2,
            wd2               => mu_wd2,
            clk               => clk,
            we                => mu_we,
            rd2               => mem_data_out,
            dma_data          => dma_data,
            dma_valid         => dma_valid,
            dma_startofpacket => dma_startofpacket,
            dma_ready         => dma_ready
        );
        
    uc : entity work.control_unit
        port map(
            instruction => instruction,
            alu_cc      => cc_reg,
            we          => we_uc,
            alu_control => alu_control,
            mux1_sel    => mux1_sel,
            mux2_sel    => mux2_sel,
            mux3_sel    => mux3_sel,
            mux4_sel    => mux4_sel,
            acc_we      => acc_we
        );
	
    process(clk)
    begin
        if rising_edge(clk) then
            -- Si hay reset manual o el DMA está cargando un programa, reiniciamos el CPU
            if reset = '1' or dma_valid = '1' then
                pc_reg  <= (others => '0');
                acc_reg <= (others => '0');
                cc_reg  <= "010";
                phase   <= "00";
            elsif enable = '1' then
                if phase = "00" then
                    phase <= "01"; -- Espera lectura síncrona de instrucción (RD1)
                elsif phase = "01" then
                    phase <= "10"; -- Espera lectura síncrona de operando en RAM (RD2)
                else
                    phase <= "00"; -- Fase de ejecución: actualiza PC, ACC y CC
                    if mux1_sel = '1' then
                        pc_reg <= offset_adder_out;
                    else
                        pc_reg <= pc_plus_1;
                    end if;

                    if acc_we = '1' then
                        acc_reg <= acc_next;
                        if signed(acc_next) > 0 then
                            cc_reg <= "001";
                        elsif signed(acc_next) < 0 then
                            cc_reg <= "100";
                        else
                            cc_reg <= "010";
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture;