library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calculadora is 
    port(

        number : in std_logic_vector(7 downto 0);
        input_n : in std_logic;
        opr : in std_logic_vector(1 downto 0);
        input_opr : in std_logic;
        reset : in std_logic;
        clk : in std_logic;
		  HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(7 downto 0)

    );
end calculadora;

architecture behavior of calculadora is

	component convLeds is
		port (
		num : in integer range 0 to 10;
		HEX : out std_logic_vector (7 downto 0));
	end component;
    
	type pilhaN is array (natural range <>) of integer range -999 to 999;
	signal Pilha : pilhaN (0 to 10);
	signal unid, dec, cent, init : integer range 0 to 10 := 10; -- numero para os displays 

begin


	x1 : convLeds port map(num => unid, HEX => HEX0);
	x2 : convLeds port map(num => dec, HEX => HEX1);
	x3 : convLeds port map(num => cent, HEX => HEX2);
	
	
    process (clk,reset,input_n,input_opr) is
		variable cnt : integer range -1 to 10 := - 1;
        begin
            if rising_edge(clk) then

                if rising_edge(input_n) then
                    Pilha(cnt+1) <= to_integer(unsigned(number)); --converter o número da entrada para decimal
							cnt := cnt + 1;
                end if;
                if rising_edge(input_opr) then
                    case opr is
                        when "00" =>
                        Pilha(cnt-1) <= (Pilha(cnt)*Pilha(cnt-1));
                        when "01" =>  
                        Pilha(cnt-1) <=(Pilha(cnt)/Pilha(cnt-1));
                        when "10" =>
                        Pilha(cnt-1) <=(Pilha(cnt)+Pilha(cnt-1));
                        when "11" =>
                        Pilha(cnt-1) <= (Pilha(cnt)-Pilha(cnt-1));
                    end case;
						cnt := cnt - 1;
						init <=1;
					
                end if;
                if rising_edge(reset) then
                    -- limpa as posições da pilha
						for i in 0 to 10 loop 
						  Pilha(i) <= 0;
						end loop;
						init <= 0;
						unid <= 0;
						dec <= 10;
						cent <= 10;
						cnt := -1;
						HEX3 <= "11111111"; -- DESLIGA O HEX3
                end if;
            end if;
				if(init = 1 ) then
					init <= 0;
					if(Pilha(cnt)<0) then --instancia display negativos

					  if(Pilha(cnt)<-99) then
						cent <= Pilha(cnt)/(-100);
						dec <= (Pilha(cnt)*(-1)-(Pilha(cnt)/(-100))*100)/10;
					  elsif (Pilha(cnt)< -9) then
						cent <= 10; --deliga o HEX2
						dec <= Pilha(cnt)/(-10);
					  else
						cent <= 10; --deliga o HEX2
						dec <= 10; --deliga o HEX1
					  end if;

					  HEX3 <= "10111111"; --coloca o sinal -
					  unid <= Pilha(cnt)*(-1) mod 10;

					else --instância display positivo

					  if(Pilha(cnt)>99) then
						cent <= Pilha(cnt)/100;
						dec <= (Pilha(cnt)-(Pilha(cnt)/100)*100)/10;
					  elsif(Pilha(cnt)>9) then
						cent <= 10; --deliga o HEX2
						dec <= Pilha(cnt)/10;
					  else
						cent <= 10; --deliga o HEX2
						dec <= 10; --deliga o HEX1
					  end if;

					  unid <= Pilha(cnt) mod 10;
					  HEX3 <= "11111111";
					end if;

				end if;
			end process;
    
end behavior;



