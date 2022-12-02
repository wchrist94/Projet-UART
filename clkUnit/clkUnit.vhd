library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
  
 port (
   clk, reset : in  std_logic;
   enableTX   : out std_logic;
   enableRX   : out std_logic);
    
end clkUnit;

architecture behavorial of clkUnit is

	constant facteur : natural := 16; -- Facteur entre enableTX et enableRX
	
begin

process (clk, reset)
	-- compteur qui permet d'appliquer le facteur 16
	variable cpt : integer range 0 to facteur-1 := 0;
  begin 
	 enableRX <= clk; -- enableRX a la même fréquence que clk
	 
	 -- Reset des valeurs
    if reset = '0' then
      enableTX <= '0';
      enableRX <= '0';
		
    elsif rising_edge(clk) then
		-- Gestion de l'attente de 16 top de clk avant un top de enableTX
      if(cpt = facteur - 1) then
        cpt := 0;
      else
        cpt := cpt + 1;
      end if;
		
		-- Au seizième top de clk on a un top de enableTX
      if cpt = 0 then
			enableTX<= '1';
		-- Front descendant au procahin front montant de clk
      else
			enableTX <= '0';
      end if;
    end if;
	 
  end process;

end behavorial;
