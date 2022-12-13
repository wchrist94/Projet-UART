library IEEE;
use IEEE.std_logic_1164.all;

entity RxUnit is
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    read             : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    Ferr, OErr, DRdy : out std_logic);
end RxUnit;

architecture RxUnit_arch of RxUnit is

	type t_etat is (attente, decalage, reception, analyse);
	signal etat : t_etat;

begin
	
	process(clk,reset)
	
		variable cpt_tmpclk : natural;
	
	begin
	
		if (reset = '0') then
			
		elsif (rising_edge(enable)) then
		
			case etat is
			
				when attente =>
				
					if (rxd = '0') then
						
						etat <= decalage;
						cpt_tmpclk := 7;
						
					end if;
					
				when decalage =>
					
					if (cpt_tmpclk = 0) then
					
						etat <= reception;
						
					else
					
						cpt_tmpclk := cpt_tmpclk - 1;
					
					end if;
					
				when reception =>
				
					
					
				end case;
		
		end if;
	
	
	end process;
	
end RxUnit_arch;
