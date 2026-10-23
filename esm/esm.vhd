library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity esm is
    port (
        clk     : in  std_logic; -- Conectar al clk_cpu dividido (12.5 MHz)
        reset   : in  std_logic; -- Activo en bajo (asociado a KEY(0))
        -- Interfaz hacia el adaptador de memoria en el Top
        rd1     : in  std_logic_vector(15 downto 0); -- Instrucción leída de a1 (PC)
        rd2     : in  std_logic_vector(15 downto 0); -- Dato leído de a2 (memoria)
        a1      : out std_logic_vector(15 downto 0); -- Dirección de instrucción (PC)
        a2      : out std_logic_vector(15 downto 0); -- Dirección de datos (offset_adder)
        wd2     : out std_logic_vector(15 downto 0); -- Dato a escribir en memoria (acc_reg)
        we      : out std_logic                      -- Habilitación de escritura
    );
end entity;

architecture rtl of esm is
    signal a_alu_in, b_alu_in, alu_out : std_logic_vector(15 downto 0);
    signal alu_control : std_logic_vector(1 downto 0);
    signal alu_flags   : std_ulogic_vector(2 downto 0);
    signal cc_reg      : std_ulogic_vector(2 downto 0) := "010";
    
    signal we_uc    : std_logic;
    signal mux1_sel : std_logic;
    signal mux2_sel : std_logic;
    signal mux3_sel : std_logic;
    signal mux4_sel : std_logic;
    signal acc_we   : std_logic;
    signal acc_reg  : std_logic_vector(15 downto 0) := (others => '0');
    signal acc_next : std_logic_vector(15 downto 0) := (others => '0');
    signal pc_reg           : std_logic_vector(15 downto 0) := (others => '0');
    signal pc_plus_1        : std_logic_vector(15 downto 0) := (others => '0');
    signal offset_adder_out : std_logic_vector(15 downto 0) := (others => '0');
    signal ext12            : std_logic_vector(15 downto 0);
    signal ext10            : std_logic_vector(15 downto 0);
    signal mux3_out         : std_logic_vector(15 downto 0);

begin
    -- Extensiones de signo para los campos inmediatos
    ext12 <= std_logic_vector(resize(signed(rd1(11 downto 0)), 16));
    ext10 <= std_logic_vector(resize(signed(rd1(9 downto 0)), 16));

    pc_plus_1        <= std_logic_vector(unsigned(pc_reg) + 1);
    mux3_out         <= ext10 when mux3_sel = '1' else ext12;
    offset_adder_out <= std_logic_vector(signed(pc_plus_1) + signed(mux3_out));

    a_alu_in <= ext12 when mux2_sel = '1' else rd2;
    b_alu_in <= acc_reg;
    acc_next <= rd2 when mux4_sel = '1' else alu_out;

    -- Conexión de los buses de la arquitectura hacia el exterior (Top)
    a1  <= pc_reg;
    a2  <= offset_adder_out;
    wd2 <= acc_reg;
    we  <= we_uc;

    g_alu : entity work.alu
        port map(
            a_alu      => a_alu_in,
            b_alu      => b_alu_in,
            control    => alu_control,
            salida_alu => alu_out,
            flags      => alu_flags
        );  
    uc : entity work.control_unit
        port map(
            instruction => rd1,
            alu_cc      => cc_reg,
            we          => we_uc,
            alu_control => alu_control,
            mux1_sel    => mux1_sel,
            mux2_sel    => mux2_sel,
            mux3_sel    => mux3_sel,
            mux4_sel    => mux4_sel,
            acc_we      => acc_we
        );
    
    process(clk, reset)
    begin
        if reset = '0' then
            pc_reg  <= (others => '0');
            acc_reg <= (others => '0');
            cc_reg  <= "010"; -- Z=1 por defecto
        elsif rising_edge(clk) then
            -- Actualización del PC (MUX1 de salto/secuencia)
            if mux1_sel = '1' then
                pc_reg <= offset_adder_out;
            else
                pc_reg <= pc_plus_1;
            end if;

            -- Actualización del Acumulador y registro de banderas NZP (cc_reg)
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
    end process;
end architecture;