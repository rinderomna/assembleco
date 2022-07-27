library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity keyviewer is
	port(
		clk: in std_logic;
		reset: in std_logic;
		key: in std_logic_vector(7 downto 0);
		videochar: out std_logic_vector(15 downto 0);
		videopos: out std_logic_vector(15 downto 0);
		videodraw: out std_logic
	);
end keyviewer;

architecture behav of keyviewer is
begin

	process(clk, reset)
	variable state: std_logic_vector(3 downto 0);
	begin
		if(reset = '1') then
			state := x"0";
			videodraw <= '0';
		elsif(clk'event and clk = '1') then
			if(key /= x"FF") then
				case state is
					when x"0" =>
						videopos <= x"002D";
						videochar(7 downto 0) <= key;
						videochar(11 downto 8) <= x"3";
						videochar(15 downto 12) <= x"1";
						videodraw <= '1';
						state := x"1";
					when others =>
						videopos <= x"002D";
						videochar(7 downto 0) <= key;
						videochar(11 downto 8) <= x"3";
						videochar(15 downto 12) <= x"1";
						videodraw <= '0';
						state := x"0";
				end case;
			end if;
		end if;
	end process;

end behav;