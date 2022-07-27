-- *************************************************
-- JOGO Atropele a Bolinha 
-- INSTRU��ES:
-- As teclas W e S movimentam o Sapo
-- para cima e para baixo.
-- As teclas A e D movimentam o Sapo 
-- para esquerda e direita.
-- *************************************************
library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY notepad IS

	PORT(
		clkvideo, clk, reset  : IN	STD_LOGIC;		
		videoflag	: out std_LOGIC;
		vga_pos		: out STD_LOGIC_VECTOR(15 downto 0);
		vga_char		: out STD_LOGIC_VECTOR(15 downto 0);
		
		key			: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0)	-- teclado
		
		);

END  notepad ;

ARCHITECTURE a OF notepad IS

	-- Escreve na tela
	SIGNAL VIDEOE      : STD_LOGIC_VECTOR(7 DOWNTO 0);
	-- Contador de tempo

	-- Sapo
	SIGNAL SAPOPOS   : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL SAPOPOSA  : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL SAPOCHAR  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SAPOCOR   : STD_LOGIC_VECTOR(3 DOWNTO 0);

	-- Bolinha
	SIGNAL BOLAPOS     : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL BOLAPOSA    : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL BOLACHAR    : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL BOLACOR     : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL INCBOLA     : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SINAL	    : STD_LOGIC;

	--Delay do Sapo
	SIGNAL DELAY1      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	--Delay da Bolinha
	SIGNAL DELAY2      : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL SAPOESTADO : STD_LOGIC_VECTOR(7 DOWNTO 0);
	--Estados da Bolinha
	SIGNAL B_ESTADO    : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN

-- Sapo
PROCESS (clk, reset)
	
	BEGIN
		
	IF RESET = '1' THEN
		SAPOCHAR <= "00000001";
		SAPOCOR <= "1010"; -- 1010 verde
		SAPOPOS <= x"0064";
		DELAY1 <= x"00000000";
		SAPOESTADO <= x"00";
		
	ELSIF (clk'event) and (clk = '1') THEN

		CASE SAPOESTADO IS
			WHEN x"00" => -- Estado movimenta Sapo segundo Teclado
			
				CASE key IS
					WHEN x"73" => -- (S) BAIXO
						IF (SAPOPOS < 1159) THEN   -- nao esta' na ultima linha
							SAPOPOS <= SAPOPOS + x"28";  -- SAPOPOS + 40
						END IF;
					WHEN x"77" => -- (W) CIMA
						IF (SAPOPOS > 39) THEN   -- nao esta' na primeira linha
							SAPOPOS <= SAPOPOS - x"28";  -- SAPOPOS - 40
						END IF;
					WHEN x"61" => -- (A) ESQUERDA
						IF (NOT((conv_integer(SAPOPOS) MOD 40) = 0)) THEN   -- nao esta' na extrema esquerda
							SAPOPOS <= SAPOPOS - x"01";  -- SAPOPOS - 1
						END IF;
					WHEN x"64" => -- (D) DIREITA
						IF (NOT((conv_integer(SAPOPOS) MOD 40) = 39)) THEN   -- nao esta' na extrema direita
							SAPOPOS <= SAPOPOS + x"01";  -- SAPOPOS + 1
						END IF;
					WHEN OTHERS =>
				END CASE;
				SAPOESTADO <= x"01";

			
			WHEN x"01" => -- Delay para movimentar Sapo
			 
				IF DELAY1 >= x"00000FFF" THEN
					DELAY1 <= x"00000000";
					SAPOESTADO <= x"00";
				ELSE
					DELAY1 <= DELAY1 + x"01";
				END IF;
				
			WHEN OTHERS =>
		END CASE;
	END IF;

END PROCESS;

-- Bolinha
PROCESS (clk, reset)

BEGIN
		
	IF RESET = '1' THEN
		BOLACHAR <= "00000010";
		BOLACOR <= "1001"; -- 1001 Vermelho
		BOLAPOS <= x"006E";
		INCBOLA <= x"29";
		SINAL <= '0';	
		DELAY2 <= x"00000000";
		B_ESTADO <= x"00";
		
	ELSIF (clk'event) and (clk = '1') THEN

				CASE B_ESTADO iS
					WHEN x"00" =>
						-- INCREMENTA A POS DA BOLA
							IF (SINAL = '0') THEN BOLAPOS <= BOLAPOS + INCBOLA;
							ELSE BOLAPOS <= BOLAPOS - INCBOLA; END IF;
							
							B_ESTADO <= x"01";
						
					WHEN x"01" => -- Bola esta' subindo e chegou na linha de cima : SINAL = 1
						IF (BOLAPOS < 40) THEN
							IF (INCBOLA = 41) THEN INCBOLA <= x"27"; SINAL <= '0'; END IF;
							IF (INCBOLA = 40) THEN INCBOLA <= x"28"; SINAL <= '0'; END IF;
							IF (INCBOLA = 39) THEN INCBOLA <= x"29"; SINAL <= '0'; END IF;
						end if;							

						B_ESTADO <= x"02";


					WHEN x"02" => -- Bola esta' descendo e chegou na linha de baixo : SINAL = 0
						IF (BOLAPOS > 1159) THEN
							IF (INCBOLA = 41) THEN INCBOLA <= x"27"; SINAL <= '1'; END IF;
							IF (INCBOLA = 40) THEN INCBOLA <= x"28"; SINAL <= '1'; END IF;
							IF (INCBOLA = 39) THEN INCBOLA <= x"29"; SINAL <= '1'; END IF;
						end if;

						B_ESTADO <= x"03";
	
					WHEN x"03" => -- Bola esta' indo para direita e chegou na extrema direita: SINAL = ? 
						IF ((conv_integer(BOLAPOS) MOD 40) = 39) THEN
							IF (INCBOLA = 39) THEN INCBOLA <= x"29"; SINAL <= '1'; END IF;
							IF (INCBOLA = 1) THEN INCBOLA <= x"01"; SINAL <= '1'; END IF;
							IF (INCBOLA = 41) THEN INCBOLA <= x"27"; SINAL <= '0'; END IF;
						end if;							

						B_ESTADO <= x"04";
	
					WHEN x"04" => -- Bola esta' indo para esquerda e chegou na extrema esquerda: SINAL = ? 
						IF ((conv_integer(BOLAPOS) MOD 40) = 0) THEN
							IF (INCBOLA = 39) THEN INCBOLA <= x"29"; SINAL <= '0'; END IF;
							IF (INCBOLA = 1) THEN INCBOLA <= x"01"; SINAL <= '0'; END IF;
							IF (INCBOLA = 41) THEN INCBOLA <= x"27"; SINAL <= '1'; END IF;
						end if;							

						B_ESTADO <= x"FF";

					WHEN x"FF" =>  -- Delay da Bola
			
						IF DELAY2 >= x"00000FFF" THEN 
							DELAY2 <= x"00000000";
							B_ESTADO <= x"00";
						ELSE
							DELAY2 <= DELAY2 + x"01";
						END IF;
			
	
	
					WHEN OTHERS =>
						B_ESTADO <= x"00";
					
				END CASE;
				

	END IF;
	
END PROCESS;

-- Escreve na Tela
PROCESS (clkvideo, reset)

BEGIN
	IF RESET = '1' THEN
		VIDEOE <= x"00";
		videoflag <= '0';
		SAPOPOSA <= x"0000";
		BolAPOSA <= x"0000";
	ELSIF (clkvideo'event) and (clkvideo = '1') THEN
		CASE VIDEOE IS
			WHEN x"00" => -- Apaga Bolinha
				if(BOLAPOSA = BOLAPOS) then
					VIDEOE <= x"04";
				else
										
						vga_char(15 downto 12) <= "0000";
						vga_char(11 downto 8) <= "0000";
						vga_char(7 downto 0) <= "00000000";
				
					vga_pos(15 downto 0)	<= BOLAPOSA;
					
					videoflag <= '1';
					VIDEOE <= x"01";
					
				end if;
			WHEN x"01" =>
				videoflag <= '0';
				VIDEOE <= x"02";
			WHEN x"02" => -- Desenha Bolinha
							
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= BOLACOR;
				vga_char(7 downto 0) <= BOLACHAR;
					
				
				vga_pos(15 downto 0)	<= BOLAPOS;
				
				BOLAPOSA <= BOLAPOS;   -- Pos Anterior = Pos Atual
				videoflag <= '1';
				VIDEOE <= x"03";
			WHEN x"03" =>
				videoflag <= '0';
				VIDEOE <= x"04";
			
			
			
			WHEN x"04" => -- Apaga Sapo
				if(SAPOPOSA = SAPOPOS) then
					VIDEOE <= x"00";
				else
									
					vga_char(15 downto 12) <= "0000";
					vga_char(11 downto 8) <= "0000";
					vga_char(7 downto 0) <= "00000000";
					
					vga_pos(15 downto 0)	<= SAPOPOSA;
					
					videoflag <= '1';
					VIDEOE <= x"05";
				end if;
			WHEN x"05" =>
				videoflag <= '0';
				VIDEOE <= x"06";
			WHEN x"06" => -- Desenha Sapo
				
				vga_char(15 downto 12) <= "0000";
				vga_char(11 downto 8) <= SAPOCOR;
				vga_char(7 downto 0) <= SAPOCHAR;
				
				vga_pos(15 downto 0)	<= SAPOPOS;
				
				SAPOPOSA <= SAPOPOS;
				videoflag <= '1';
				VIDEOE <= x"07";
			WHEN x"07" =>
				videoflag <= '0';
				VIDEOE <= x"00";
			
			WHEN OTHERS =>
				videoflag <= '0';
				VIDEOE <= x"00";	
		END CASE;
	END IF;
END PROCESS;
	
--PROCESS (videoflag, video_set)
--BEGIN
--  IF video_set = '1' THEN video_ready <= '0';
--  ELSIF videoflag'EVENT and videoflag = '1' THEN video_ready <= '1';
--  END IF;
--END PROCESS;

END a;
