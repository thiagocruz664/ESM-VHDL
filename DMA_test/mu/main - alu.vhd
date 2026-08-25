library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE WORK.COMANDOS_LCD_REVD.ALL;
--use work.alu.all;

entity ALU_VHDL is
    GENERIC(
        FPGA_CLK : INTEGER := 50_000_000 -- 50 MHz, Debe coincidir con la frecuencia del reloj del FPGA que se use
    ); 
    PORT(CLK: IN STD_LOGIC;
    --------------- PUERTOS PARA LCD ---------------
		VO          : OUT STD_LOGIC := '1';
		RS          : OUT STD_LOGIC;
		RW          : OUT STD_LOGIC;
		ENA         : OUT STD_LOGIC;
		DATA_LCD    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		BLK         : OUT STD_LOGIC := '0';
		BLA         : OUT STD_LOGIC := '1';

    --------------- PUERTOS PARA TECLADO ---------------
		L           : in std_logic_vector(0 to 3);
		C           : out std_logic_vector(0 to 3);
		
    --------------- OTROS PUERTOS ---------------
		led_debug   : out std_logic_vector(7 downto 0);
		ex_bttn     : in std_logic := '0'
    );
end ALU_VHDL;

architecture Behavioral of ALU_VHDL is
    CONSTANT NUM_INSTRUCCIONES : INTEGER := 20; 	--INDICAR EL NUMERO DE INSTRUCCIONES PARA LA LCD

    ------------------------------ SEÑALES PARA LCD ------------------------------
    component PROCESADOR_LCD_REVD is
        GENERIC(
			FPGA_CLK : INTEGER := 50_000_000;
			NUM_INST : INTEGER := 1
        );
        PORT( CLK           : IN  STD_LOGIC;
            VECTOR_MEM      : IN  STD_LOGIC_VECTOR(8  DOWNTO 0);
            C1A,C2A,C3A,C4A : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);
            C5A,C6A,C7A,C8A : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);
            RS              : OUT STD_LOGIC;
            RW              : OUT STD_LOGIC;
            ENA             : OUT STD_LOGIC;
            BD_LCD          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            DATA            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            DIR_MEM         : OUT INTEGER RANGE 0 TO NUM_INSTRUCCIONES
        );
    end component PROCESADOR_LCD_REVD;
    component CARACTERES_ESPECIALES_REVD is
        PORT(C1,C2,C3,C4    : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
            C5,C6,C7,C8     : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)
        );
    end component CARACTERES_ESPECIALES_REVD;

    CONSTANT CHAR1 : INTEGER := 1;
    CONSTANT CHAR2 : INTEGER := 2;
    CONSTANT CHAR3 : INTEGER := 3;
    CONSTANT CHAR4 : INTEGER := 4;
    CONSTANT CHAR5 : INTEGER := 5;
    CONSTANT CHAR6 : INTEGER := 6;
    CONSTANT CHAR7 : INTEGER := 7;
    CONSTANT CHAR8 : INTEGER := 8;

    type ram is array (0 to  NUM_INSTRUCCIONES) of std_logic_vector(8 downto 0);
    signal INST : ram := (others => (others => '0'));

    signal blcd 			  : std_logic_vector(7 downto 0):= (others => '0');																									
    signal vector_mem 	  : STD_LOGIC_VECTOR(8  DOWNTO 0) := (others => '0');
    signal c1s,c2s,c3s,c4s : std_logic_vector(39 downto 0) := (others => '0');
    signal c5s,c6s,c7s,c8s : std_logic_vector(39 downto 0) := (others => '0');
    signal dir_mem 		  : integer range 0 to NUM_INSTRUCCIONES := 0;

    ------------------------------ SEÑALES PARA TECLADO ------------------------------
    signal counter   : integer range 0 to 24999 := 0; -- Este contador define el tiempo que dura cada estado del teclado (25ms)
    type state_type is (COL1W,COL1L,COL2W,COL2L,COL3W,COL3L,COL4W,COL4L,WAIT_STATE,CONFIRM_STATE);
	    signal state : state_type := COL1W;

	 signal digit_hexa_s : std_logic_vector (3 downto 0) := (others => '0');
	 signal num_hexa : std_logic_vector(15 downto 0) := (others => '0');

    ------------------------------ SEÑALES PARA ALU Y ASCII ------------------------------
    signal flags : std_logic_vector(2 downto 0);
	 signal alu_out     : std_logic_vector(15 downto 0);
    signal acumulador : std_logic_vector(15 downto 0) := (others => '0');
	
	 type t_num_ascii is array (0 to 3) of std_logic_vector (7 downto 0);
	    signal num_ascii : t_num_ascii := (others => "00110000");
	    signal acumulador_ascii : t_num_ascii := (others => "00110000");
    
    --FUNCION PARA TRANSFORMAR DE HEXADECIMA/BINARIO A ASCCI
    function hex_to_ascii(hex : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable n : integer;
        begin
            n := to_integer(unsigned(hex));
            if n < 10 then return std_logic_vector(to_unsigned(n + 16#30#,8));
            else return std_logic_vector(to_unsigned(n - 10 + 16#41#,8));
            end if;
	 end function;
	 
	 ------------------------------ OTRAS SEÑALES ------------------------------
	 signal ex_bttn_prev : std_logic := '0';
begin
    ------------------- COMPONENTES PARA LCD ------------------------
    u1: PROCESADOR_LCD_REVD
        GENERIC map( FPGA_CLK => FPGA_CLK,
            NUM_INST => NUM_INSTRUCCIONES )
        PORT map( CLK,
            VECTOR_MEM,
            C1S,C2S,C3S,C4S,C5S,C6S,C7S,C8S,
            RS,RW,ENA,BLCD,
            DATA_LCD, DIR_MEM );
    U2 : CARACTERES_ESPECIALES_REVD
        PORT MAP( C1S,C2S,C3S,C4S,C5S,C6S,C7S,C8S );
    VECTOR_MEM <= INST(DIR_MEM);

    ------------------- COMPONENTE ALU ------------------------
    alu: entity work.alu
        port map(
            a_alu => num_hexa(13)&num_hexa(13)&num_hexa(13 downto 0),
            b_alu => acumulador,
            salida_alu => alu_out,
            alu_control => num_hexa(15 downto 14),
            alu_flags => flags
        );
    

------------------------------------------------------------------------
------------------------ INICIO CODIGO LCD -----------------------------
 	INST(0) <= LCD_INI("00"); 		-- INICIALIZAMOS LCD, CURSOR A HOME, CURSOR ON, PARPADEO ON.
	INST(1) <= POS(1,2);
        INST(2) <= CHAR(MA);				
        INST(3) <= CHAR_ASCII(X"3A");
	INST(4) <= POS(1,10);
        INST(5) <= CHAR(MB);				
        INST(6) <= CHAR_ASCII(X"3A");
	INST(7) <= BUCLE_INI(1);
        INST(8) <= POS(1,4);
            INST(9) <= CHAR_ASCII(num_ascii(3));
            INST(10) <= CHAR_ASCII(num_ascii(2));
            INST(11) <= CHAR_ASCII(num_ascii(1));
            INST(12) <= CHAR_ASCII(num_ascii(0));
        INST(13) <= POS(1,12);
            INST(14) <= CHAR_ASCII(acumulador_ascii(3));
            INST(15) <= CHAR_ASCII(acumulador_ascii(2));
            INST(16) <= CHAR_ASCII(acumulador_ascii(1));
            INST(17) <= CHAR_ASCII(acumulador_ascii(0));
	INST(18) <= BUCLE_FIN(1);
	INST(19) <= CODIGO_FIN(1);
-------------------------- FIN CODIGO LCD ------------------------------
------------------------------------------------------------------------

----------------------------------------------------------------------------
------------------------ INICIO CODIGO TECLADO -----------------------------
	process(clk) begin
		if rising_edge(clk) then
			if counter = 24999 then
				counter <= 0;
				case state is
					when COL1W =>
						C <= "0111";
						state <= COL1L;
					when COL1L =>
						if    L(0)='0' then digit_hexa_s <= "0001"; state <= WAIT_STATE; -- 1
						elsif L(1)='0' then digit_hexa_s <= "0100"; state <= WAIT_STATE; -- 4
						elsif L(2)='0' then digit_hexa_s <= "0111"; state <= WAIT_STATE; -- 7
						elsif L(3)='0' then digit_hexa_s <= "1110"; state <= WAIT_STATE; -- E (*)
						else state <= COL2W;
						end if;
					when COL2W =>
						C <= "1011";
						state <= COL2L;
					when COL2L =>
						if    L(0)='0' then digit_hexa_s <= "0010"; state <= WAIT_STATE; -- 2
						elsif L(1)='0' then digit_hexa_s <= "0101"; state <= WAIT_STATE; -- 5
						elsif L(2)='0' then digit_hexa_s <= "1000"; state <= WAIT_STATE; -- 8
						elsif L(3)='0' then digit_hexa_s <= "0000"; state <= WAIT_STATE; -- 0
						else state <= COL3W;
						end if;
					when COL3W =>
						C <= "1101";
						state <= COL3L;
					when COL3L => 
						if    L(0)='0' then digit_hexa_s <= "0011"; state <= WAIT_STATE; -- 3
						elsif L(1)='0' then digit_hexa_s <= "0110"; state <= WAIT_STATE; -- 6
						elsif L(2)='0' then digit_hexa_s <= "1001"; state <= WAIT_STATE; -- 9
						elsif L(3)='0' then digit_hexa_s <= "1111"; state <= WAIT_STATE; -- F (#)
						else state <= COL4W;
						end if;
					when COL4W =>
						C <= "1110";
						state <= COL4L;
					when COL4L =>
						if    L(0)='0' then digit_hexa_s <= "1010"; state <= WAIT_STATE; -- A
						elsif L(1)='0' then digit_hexa_s <= "1011"; state <= WAIT_STATE; -- B
						elsif L(2)='0' then digit_hexa_s <= "1100"; state <= WAIT_STATE; -- C
						elsif L(3)='0' then digit_hexa_s <= "1101"; state <= WAIT_STATE; -- D
						else state <= COL1W;
						end if;
					when WAIT_STATE =>
						if L(0)='1' and L(1)='1' and L(2)='1' and L(3)='1' then
							led_debug(3 downto 0) <= digit_hexa_s;
							num_hexa <= num_hexa(11 downto 0)&digit_hexa_s;
							state <= CONFIRM_STATE;
						end if;
					when CONFIRM_STATE =>
						led_debug(4) <= '1';
						num_ascii(3) <= hex_to_ascii(num_hexa(15 downto 12));
						num_ascii(2) <= hex_to_ascii(num_hexa(11 downto 8));
						num_ascii(1) <= hex_to_ascii(num_hexa(7 downto 4));
						num_ascii(0) <= hex_to_ascii(num_hexa(3 downto 0));
						state <= COL1W;
				end case;
			else
				counter <= counter + 1;
			end if;
		end if;
	end process;
-------------------------- FIN CODIGO TECLADO ------------------------------
----------------------------------------------------------------------------

------------------------------------------------------------------------------
------------------------ INICIO CODIGO EJECUCION -----------------------------
	process(clk) begin
		if rising_edge(clk) then
			ex_bttn_prev <= ex_bttn;
			if ex_bttn_prev = '1' and ex_bttn = '0' then
				acumulador <= alu_out;
				led_debug(7 downto 5) <= flags;
			end if;
		end if;
	end process;
	
	process(clk) begin
		if rising_edge(clk) then
			acumulador_ascii(3) <= hex_to_ascii(acumulador(15 downto 12));
			acumulador_ascii(2) <= hex_to_ascii(acumulador(11 downto 8));
			acumulador_ascii(1) <= hex_to_ascii(acumulador(7 downto 4));
			acumulador_ascii(0) <= hex_to_ascii(acumulador(3 downto 0));
		end if;
	end process;
-------------------------- FIN CODIGO EJECUCION ------------------------------
------------------------------------------------------------------------------

end Behavioral;