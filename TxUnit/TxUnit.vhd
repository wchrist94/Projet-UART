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

	type t_etat is (attente, transmission_data, debut_envoi, envoi_data, envoi_xor, fin_envoi);
	signal etat : t_etat;

	signal BufferT : std_logic_vector(7 downto 0);	  -- Tampon de transmission
	signal RegisterT : std_logic_vector(7 downto 0);  -- Registre de transmission
	signal bitP : std_logic;						  -- Signal qui sert de base au calcul du bit de parité et qui stockera sa valeur à la fin de l'envoi des données
	signal double : std_logic;						  -- Signal indiquant si le double load est possible 1 si oui 0 sinon					
begin

	process (clk, reset)
	
		variable cpt: natural; 	-- Compteur qui indiquera la position du bit en cours d'envoi

	begin
	
		if (reset = '0') then
		
			-- Réinitialisation de toutes les sorties
			BufferT <= (others => '0');
			RegisterT <= (others => '0');
			etat <= attente;
			txd <= '1';
			bufE <= '1';
			regE <= '1';
			double <= '1';
			
		elsif (rising_edge(clk)) then

			case etat is

				when attente =>
			
					-- Réception d'une demande d'emission
					if (ld = '1') then

						BufferT <= data; 	 		-- Chargement de la donne stocke dans data dans le tampon
						bufE <= '0';			    -- Tampon occupé
						etat <= transmission_data;  -- Passage dans l'état de transmission
						cpt := 8;				    -- Initialisation du compteur des 8 bits à envoyer		   
						double <= '0';				-- Double load impossible

					end if;

				when transmission_data =>

					RegisterT <= BufferT;			-- Chargement des données du tampon dans le registre d'envoi
					regE <= '0';					-- Registre d'envoi occupé
					bufE <= '1';					-- Tampon libre
					etat <= debut_envoi;			-- Passage dans l'état du début de l'envoi
					double <= '1';					-- Double load possible

				when debut_envoi =>

					if (enable = '1') then
						txd <= '0';						-- Envoi du bit start
						bitP <= '0';					-- Initialisation du bit de parité  0
						etat <= envoi_data;				-- Passage dans l'état d'envoi des données du registre d'envoi
					end if;

					-- Réception éventuelle d'une nouvelle demande d'emission avec le tampon vide
					if (ld = '1' and double = '1') then

						BufferT <= data;			-- Chargement de la nouvelle data dans le tampon
						bufE <= '0';				-- Buffer occupé
						double <= '0';				-- Double load impossible
					end if;
					
				when envoi_data =>
										
					if (enable = '1') then

						cpt := cpt - 1;						-- Décrémentation du compteur de bit envoyé
						txd <= RegisterT(cpt);				-- Envoi des données bit par bit en commençant par le bit de poids fort
						bitP <= bitP xor RegisterT(cpt);	-- Calcul du bit de parité en effectuant un xor bit par bit

						-- fin d'un envoi complet de data (8bits)
						if (cpt = 0) then

							etat <= envoi_xor; 			-- Passage dans l'état d'envoi du bit de parité
							cpt := 8;					-- Réinitialisation du compteur
						end if;

						

						-- Réception éventuelle d'une nouvelle demande d'emission avec le tampon vide
						if (ld = '1' and double = '1') then
						
							BufferT <= data;			-- Chargement de la nouvelle data dans le tampon
							bufE <= '0';				-- Buffer occupé
							double <= '0';				-- Double load impossible
						end if;
					
					end if;

				when envoi_xor =>

					-- Réception éventuelle d'une nouvelle demande d'emission avec le tampon vide
					if (ld = '1' and double = '1') then
					
						BufferT <= data;			-- Chargement de la nouvelle data dans le tampon
						bufE <= '0';				-- Buffer occupé
						double <= '0';				-- Double load impossible
						
					end if;

					if (enable = '1') then
						txd <= bitP;					-- Envoi du bit de parité
						etat <= fin_envoi;				-- Passage dans l'état marquant la fin de l'envoi
						regE <= '1';					-- Registre d'envoi libre
					end if;

				when fin_envoi =>

					-- Réception éventuelle d'une nouvelle demande d'emission avec le tampon vide
					if (ld = '1' and double = '1') then
					
						BufferT <= data;			-- Chargement de la nouvelle data dans le tampon
						bufE <= '0';				-- Buffer occupé
						double <= '0';				-- Double load impossible

					end if;

					if (enable = '1') then

						txd <= '1';						-- Envoi du bit de fin	
						
						if (double = '0') then

							etat <= transmission_data;	-- Passage dans l'état d'envoi des données si le tampon est plein (double load)

						else

							etat <= attente;			-- Retour dans l'état d'attente sinon

						end if;
					end if;

					
			end case;
		end if;
		
		
	end process;
end behavorial;
