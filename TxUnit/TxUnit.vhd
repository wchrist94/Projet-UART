library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;
    enable : in std_logic;
    ld : in std_logic;
    txd : out std_logic;
    regE : out std_logic;
    bufE : out std_logic;
    data : in std_logic_vector(7 downto 0));
end TxUnit;

architecture behavorial of TxUnit is

	type t_etat is (attente, debut_envoi, envoi_data, envoi_xor, fin_envoi);
	signal etat : t_etat;
	
	signal BufferT : std_logic_vector(7 downto 0);
	signal RegisterT : std_logic_vector(7 downto 0);
	signal bitP : std_logic;

begin
	process (clk, reset)
	
		variable compt: natural;
	begin
	
	if (reset = '0') then
	
		BufferT <= (others => '0');
		RegisterT <= (others => '0');
		t_etat <= repos;
		txd <= '1';
		bufE <= '1';
		regE <= '1';
		
	elsif (rising_edge(clk) and enable = '1') then
		case etat is

			when attente =>
		
				-- Réception d'une demande d'émission
				if (ld = '1') then
					BufferT <= data; -- chargement de la donnée stockée dans data dans le tampon
					bufE <= '0';
					etat <= debut_envoi;
					cpt := 8;
					bitP := 0;
				
			end if;
			
			when debut_envoi =>
			
				-- Envoi du bit start
				txd <= '0';
				
			when envoi_data =>
				
				if (cpt = 0) then
					etat <= envoi_xor;
				else
					cpt := cpt - 1;
					txd <= RegisterT(cpt);
					bitP := bitP xor RegisterT(cpt);
				end if;
				
			when envoi_xor =>
				txd <= bitP;
				
				
		end case;
	end if;
		
		
end process;
end behavorial;
