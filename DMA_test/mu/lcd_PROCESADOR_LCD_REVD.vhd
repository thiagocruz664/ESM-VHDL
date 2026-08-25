----------------------------------------
----------PROCESADOR LCD----------------
----------¡NO MODIFICAR!----------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity PROCESADOR_LCD_REVD is

GENERIC(
			FPGA_CLK : INTEGER := 50_000_000;
			NUM_INST : INTEGER := 1
);

PORT(CLK 				: IN  STD_LOGIC;
	  VECTOR_MEM 		: IN  STD_LOGIC_VECTOR(8  DOWNTO 0);
	  C1A,C2A,C3A,C4A : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);
	  C5A,C6A,C7A,C8A : IN  STD_LOGIC_VECTOR(39 DOWNTO 0);       	
	  RS 					: OUT STD_LOGIC;
	  RW 					: OUT STD_LOGIC;
	  ENA 				: OUT STD_LOGIC;
	  BD_LCD 			: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);			         
	  DATA 				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	  DIR_MEM 			: OUT INTEGER RANGE 0 TO NUM_INST
	);

end PROCESADOR_LCD_REVD;

architecture Behavioral of PROCESADOR_LCD_REVD is

CONSTANT MAX_DELAY 			  : INTEGER := (FPGA_CLK/16);		 -- Delay de 62.5 milisegundos
CONSTANT ESCALA_ENABLE 		  : integer := (FPGA_CLK/1_000);  -- 700us
CONSTANT ESCALA_CICLO_ENABLE : integer := (FPGA_CLK/10_000); -- 100us
CONSTANT OFFSET_ENABLE		  : INTEGER := (FPGA_CLK/10_000); -- 100us

signal salto 		   : std_logic := '0';
signal avanzar 	   : std_logic := '0';
signal ok_enable 	   : std_logic := '0';
signal enable_fin	   : std_logic := '0';
signal data_s 		   : std_logic_vector(8  downto 0) := (others => '0');
signal vec_ram 	   : std_logic_vector(7  downto 0) := (others => '0');
signal vec_l_ram 	   : std_logic_vector(7  downto 0) := (others => '0');
signal vec_c_char    : std_logic_vector(39 downto 0) := (others => '0');
signal edo 			   : integer range 0 to 100 := 0;
signal dir_mem_s 	   : integer range 0 to NUM_INST := 0;
signal edo_enable    : integer range 0 to 2 := 0;
signal max_enable	   : integer range 0 to escala_enable := 0;
signal conta_enable  : integer range 0 to escala_enable := 0;
signal ciclo_enable  : integer range 0 to escala_enable := 0;
signal conta_delay   : integer range 0 to MAX_DELAY  := 0;
signal dir_salto_mem : integer range 0 to NUM_INST := 0;

begin

process(CLK)
begin
if rising_edge(clk) then
	if edo = 0 then
		conta_delay <= conta_delay+1;
		if conta_delay = MAX_DELAY then
			conta_delay <= 0;
			edo <= 1;
		end if;
	
	elsif edo = 1 then
		if VECTOR_MEM = "000000000" OR VECTOR_MEM = "111111111" THEN
			edo <= 100;--FIN DE CÓDIGO
		elsif VECTOR_MEM(8) = '0' then
			edo <= 30;--CHAR_ASCII
		else
			edo <= 2;--CUALQUIER OTRA INSTRUCCIÓN
		end if;
		  
	elsif edo = 2 then
		if 	VECTOR_MEM(7 downto 0) >= x"01" and VECTOR_MEM(7 downto 0) <= x"04" then
			edo <= 3;  -- INI_LCD
		elsif VECTOR_MEM(7 downto 0) >= x"09" and VECTOR_MEM(7 downto 0) <= x"41" then
			edo <= 23; -- CHAR
		elsif VECTOR_MEM(7 downto 0) >= x"50" and VECTOR_MEM(7 downto 0) <= x"77" then
			edo <= 27; -- POSICIÓN
		elsif VECTOR_MEM(7 downto 0) = x"7c" then
			edo <= 32; -- BUCLE_INI
		elsif VECTOR_MEM(7 downto 0) = x"7D" then
			edo <= 33; -- BUCLE_FIN
		elsif VECTOR_MEM(7 downto 0) >= X"7E" and VECTOR_MEM(7 downto 0) <= X"85" then
			edo <= 34; -- GUARDAR CARACTER 
		elsif VECTOR_MEM(7 downto 0) >= X"86" and VECTOR_MEM(7 downto 0) <= X"8D" then
			edo <= 55; -- LEER CARACTER
		elsif VECTOR_MEM(7 downto 0) = X"FE" or VECTOR_MEM(7 downto 0) = X"FD" then
			edo <= 58; -- LIMPIAR PANTALLA
		elsif VECTOR_MEM(7 downto 0) >= X"8E" or VECTOR_MEM(7 downto 0) <= X"97" then
			edo <= 60; -- INT_NUM
		else
			edo <= 100;
		end if;	
			
			
	-------------------------------------------------
	----------------Inicializar LCD------------------
	
	elsif edo = 3 then --SET
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "00110000";
		edo <= 4;
		
	elsif edo = 4 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 5;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 5 then
		conta_delay <= conta_delay+1;
		if conta_delay = MAX_DELAY/8 then
			conta_delay <= 0;
			edo <= 6;
		end if;
	
	elsif edo = 6 then --SET
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "00110000";
		edo <= 7;
		
	elsif edo =7  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 8;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 8 then
		conta_delay <= conta_delay+1;
		if conta_delay = MAX_DELAY/32 then
			conta_delay <= 0;
			edo <= 9;
		end if;
		
	elsif edo = 9 then --SET
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "00110000";
		edo <= 10;
		
	elsif edo = 10  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 11;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 11 then --FUNCTION SET (8 BITS, 2 LÍNEAS, 5X8)
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "00111000";
		edo <= 12;
		
	elsif edo = 12  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 13;
		else
			ok_enable <= '1';
		end if;	
	
	elsif edo = 13 then --DISPLAY OFF
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "00001000";
		edo <= 14;
		
	elsif edo = 14  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 15;
		else
			ok_enable <= '1';
		end if;	
		
	elsif edo = 15 then --DISPLAY CLEAR
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "00000001";
		edo <= 16;
		
	elsif edo = 16  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 17;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 17 then --ENTRY MODE SET
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "00000110";
		edo <= 18;
		
	elsif edo = 18  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 19;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 19 then --ADDRES RAM
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		DATA <= "10000000";
		edo <= 20;
		
	elsif edo = 20  then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 21;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 21 then --CURSOR_LCD
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 22;
		if VECTOR_MEM = '1'&x"01" then
			data <= "00001100";
		elsif VECTOR_MEM = '1'&x"02" then
			data <= "00001101"; 
		elsif VECTOR_MEM = '1'&x"03" then
			data <= "00001110";
		else
			data <= "00001111";
		end if;
		
	elsif edo = 22 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"01";
			AVANZAR <= '1';
			edo <= 99;
		else
			ok_enable <= '1';
		end if;	
	-------------------------------------------------
	-------------------------------------------------

	
	-------------------------------------------------
	-----------------------CHAR----------------------
	elsif edo = 23 then
		RS <= '1';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 25;
		if VECTOR_MEM >= '1'&x"09" and VECTOR_MEM <= '1'&x"22" then
			data_s <= VECTOR_MEM - ('0'&x"a8");
		elsif VECTOR_MEM >= '1'&x"23" and VECTOR_MEM <= '1'&x"3c" then
			data_s <= VECTOR_MEM - ('0'&x"e2");
		else
			data_s <= VECTOR_MEM - ('1'&x"0d");
		end if;	
		
	elsif edo = 25 then
		DATA <= data_s(7 downto 0);
		edo <= 26;
	
	elsif edo = 26 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"02";
			AVANZAR <= '1';
			edo <= 99;
		else
			ok_enable <= '1';
		end if;	
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	---------------------POSICIÓN--------------------
	elsif edo = 27 then
		RS <= '0';
		RW <= '0';
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 28;
		IF VECTOR_MEM >= '1'&X"50" AND VECTOR_MEM <= '1'&X"63" THEN
			data_s <= VECTOR_MEM - ('0'&X"D0");
		ELSIF VECTOR_MEM >= '1'&X"64" AND VECTOR_MEM <= '1'&X"77" THEN
			data_s <= VECTOR_MEM - ('0'&X"A4");
		END IF;
		
	elsif edo = 28 then
		DATA <= data_s(7 downto 0);
		edo <= 29;
	
	elsif edo = 29 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"03";
			AVANZAR <= '1';
			edo <= 99;
		else
			ok_enable <= '1';
		end if;	
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	------------------CHAR_ASCII---------------------
	elsif edo = 30 then
		RS <= '1';
		RW <= '0';
		DATA <= VECTOR_MEM(7 downto 0);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 31;
	
	elsif edo = 31 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"05";
			AVANZAR <= '1';
			edo <= 99;
		else
			ok_enable <= '1';
		end if;	
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	--------------------BUCLE INI--------------------
	elsif edo = 32 then
		dir_salto_mem <= dir_mem_s;
		BD_LCD <= x"06";
		AVANZAR <= '1';
		edo <= 99;
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	--------------------BUCLE FIN--------------------
	elsif edo = 33 then
		BD_LCD <= x"07";
		salto <= '1';
		edo <= 99;
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	----------------GUARDAR CARACTER-----------------
	elsif edo = 34 then
		if 	vector_mem(7 downto 0) = x"7e" then vec_ram <= x"40"; vec_c_char <= c1a;
		elsif vector_mem(7 downto 0) = x"7f" then vec_ram <= x"48"; vec_c_char <= c2a;
		elsif vector_mem(7 downto 0) = x"80" then vec_ram <= x"50"; vec_c_char <= c3a;
		elsif vector_mem(7 downto 0) = x"81" then vec_ram <= x"58"; vec_c_char <= c4a;
		elsif vector_mem(7 downto 0) = x"82" then vec_ram <= x"60"; vec_c_char <= c5a;
		elsif vector_mem(7 downto 0) = x"83" then vec_ram <= x"68"; vec_c_char <= c6a;
		elsif vector_mem(7 downto 0) = x"84" then vec_ram <= x"70"; vec_c_char <= c7a;
		elsif vector_mem(7 downto 0) = x"85" then vec_ram <= x"78"; vec_c_char <= c8a;
		end if;
		edo <= 35;
		
	elsif edo = 35 then	
		RS <= '0';
		RW <= '0';
		DATA <= vec_ram;
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 36;
		
	elsif edo = 36 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 37;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 37 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(39 DOWNTO 35);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 38;
		
	elsif edo = 38 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 39;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 39 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(34 DOWNTO 30);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 40;
		
	elsif edo = 40 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 41;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 41 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(29 DOWNTO 25);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 42;
		
	elsif edo = 42 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 43;
		else
			ok_enable <= '1';
		end if;
	
	elsif edo = 43 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(24 DOWNTO 20);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 44;
		
	elsif edo = 44 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 45;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 45 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(19 DOWNTO 15);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 46;
		
	elsif edo = 46 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 47;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 47 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(14 DOWNTO 10);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 48;
		
	elsif edo = 48 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 49;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 49 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(9 DOWNTO 5);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 50;
		
	elsif edo = 50 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 51;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 51 then	
		RS <= '1';
		RW <= '0';
		DATA <= "000"&VEC_C_CHAR(4 DOWNTO 0);
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 52;
		
	elsif edo = 52 then
		if enable_fin = '1' then
			ok_enable <= '0';
			edo <= 53;
		else
			ok_enable <= '1';
		end if;
		
	elsif edo = 53 then	
		RS <= '1';
		RW <= '0';
		DATA <= "00000010";
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 54;
		
	elsif edo = 54 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"09";
			AVANZAR <= '1';
			edo <= 99;
		else
			ok_enable <= '1';
		end if;
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	------------------LEER CARACTER------------------
	elsif edo = 55 then
		if 	vector_mem(7 downto 0) = x"86" then vec_l_ram <= x"00";
		elsif vector_mem(7 downto 0) = x"87" then vec_l_ram <= x"01";
		elsif vector_mem(7 downto 0) = x"88" then vec_l_ram <= x"02";
		elsif vector_mem(7 downto 0) = x"89" then vec_l_ram <= x"03";
		elsif vector_mem(7 downto 0) = x"8a" then vec_l_ram <= x"04";
		elsif vector_mem(7 downto 0) = x"8b" then vec_l_ram <= x"05";
		elsif vector_mem(7 downto 0) = x"8c" then vec_l_ram <= x"06";
		elsif vector_mem(7 downto 0) = x"8d" then vec_l_ram <= x"07";
		end if;
		edo <= 56;
		
	elsif edo = 56 then
		RS <= '1';
		RW <= '0';
		DATA <= VEC_L_RAM;
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 57;
		
	elsif edo = 57 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"0A";
			AVANZAR <= '1';
			edo <= 99;
		else
			ok_enable <= '1';
		end if;
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	----------------LIMPIAR PANTALLA-----------------
	elsif edo = 58 then
		if VECTOR_MEM(7 downto 0) = X"FE" then
			RS <= '0';
			RW <= '0';
			DATA <= "00000001";
			ciclo_enable <= ESCALA_CICLO_ENABLE;
			edo <= 59;
		else
			RS <= '0';
			RW <= '0';
			DATA <= "00000000";
			ciclo_enable <= ESCALA_CICLO_ENABLE;
			BD_LCD <= X"02";
			edo <= 99;
		end if;
		
	elsif edo = 59 then 
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"08";
			AVANZAR <= '1';
			edo <= 99;
		else
			ok_enable <= '1';
		end if;
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	---------------------INT_NUM---------------------
	elsif edo = 60 then
		RS <= '1';
		RW <= '0';
		DATA <= VECTOR_MEM(7 downto 0) - (X"5E");
		ciclo_enable <= ESCALA_CICLO_ENABLE;
		edo <= 61;
	
	elsif edo = 61 then
		if enable_fin = '1' then
			ok_enable <= '0';
			BD_LCD <= X"04";
			AVANZAR <= '1';
			edo <= 99;
		else
			ok_enable <= '1';
		end if;	
	-------------------------------------------------
	-------------------------------------------------
	
	
	-------------------------------------------------
	----------------LIMPIAR SEÑALES------------------
	elsif edo = 99 then
		BD_LCD <= X"00";
		AVANZAR <= '0';
		salto <= '0';
		edo <= 1;
	-------------------------------------------------
	-------------------------------------------------
		
	end if;
end if;
end process;


-------------------------------------------------
----------------GENERADOR ENABLE-----------------
process(clk)
begin
if rising_edge(clk) then
	if edo_enable = 0 then
		if ok_enable = '1' then
			edo_enable <= 1;
		end if;
		
	elsif edo_enable = 1 then
		conta_enable <= conta_enable+1;
		if conta_enable >= ESCALA_ENABLE then
			conta_enable <= 0;
			enable_fin <= '1';
			edo_enable <= 2;
		end if;
		
	elsif edo_enable = 2 then
		enable_fin <= '0';
		edo_enable <= 0;
		
	end if;
end if;
end process;

process(conta_enable, edo_enable, ciclo_enable)
begin
if conta_enable > ciclo_enable+OFFSET_ENABLE and  conta_enable < ciclo_enable+(OFFSET_ENABLE*2) and edo_enable = 1 then
	ENA <= '1';
else
	ENA <= '0';
end if;
end process;
-------------------------------------------------
-------------------------------------------------


-------------------------------------------------
-------------DIRECCIÓN DE MEMORIA----------------
process(clk)
begin
if rising_edge(clk) then
	if avanzar = '1' then
		dir_mem_s <= dir_mem_s+1;
	elsif salto = '1' then
		dir_mem_s <= dir_salto_mem;
	end if;
end if;
end process;

DIR_MEM <= dir_mem_s;
-------------------------------------------------
-------------------------------------------------

end Behavioral;