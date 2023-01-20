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

	 type t_etat_compt is (debut, compter8, compter16, fin);
    signal etat_compt : t_etat_compt;
    type t_etat_recep is (debut, reception, verification_bit_p, verification_stop, fin);
    signal etat_recep : t_etat_recep;
	
	signal tmpclk : std_logic;
	signal tmprxd : std_logic;

begin
    -- Process du compteur
	compteur : process (enable, reset)
	
    variable compt_iter : natural;
   variable compt_bit  : natural;

    begin
        if (reset = '0') then
            -- Reset
            compt_bit := 0;
            compt_iter := 0;
            etat_compt <= debut;
            tmpclk <= '0';
            tmprxd <= '1';

        elsif (rising_edge(enable)) then

            case etat_compt is

                when debut =>

                    if (rxd = '0') then
                        -- On attend le premier bit de start
                        compt_iter := 0;
                        compt_bit := 0;
                        tmpclk <= '0';
                        tmprxd <= '1';
                        etat_compt <= compter8;
                    end if;
                when compter8 =>
                -- On compte 8 pour arriver au milieu du bit de start
                    if (compt_iter = 7) then
                        -- On a compté 8 itérations, donc on est au milieu du bit de start
                        tmpclk <= '1';
                        tmprxd <= rxd;
                        compt_bit := compt_bit + 1;
                        compt_iter := 0;
                        etat_compt <= compter16;
                    else
                        -- On incrémente le compteur d'itération
                        compt_iter := compt_iter + 1;
                        tmpclk <= '0';
                    
                    end if;
                when compter16 =>
                -- On compte 16 pour arriver au milieu du deuxième bit de data
                    if (compt_iter = 15) then
                        -- On a compté 16 itérations, donc on est au milieu d'un bit
                        if (compt_bit = 11) then
                            -- Si on a compté 12 bits, on a fini
                            tmpclk <= '0';
                            etat_compt <= fin;
                        else
                            -- Sinon on continue
                            compt_bit := compt_bit + 1;
                            compt_iter := 0;
                            tmpclk <= '1';
                            tmprxd <= rxd;
                            etat_compt <= compter16; 
						end if;
                    else
                    -- On incrémente le compteur d'itération
                        compt_iter := compt_iter + 1;
                        tmpclk <= '0';
                    end if;
                when fin =>
                    -- On a fini, on attend le prochain bit de start
                    tmpclk <= '0';
                    tmprxd <= rxd;
                    etat_compt <= debut;      
                end case;

            end if;
    
    end process compteur;
	-- Process du controle de la reception
	controle_recep : process(clk,reset)
	
	variable data_aux : std_logic_vector (7 downto 0);
        variable bit_courant : natural;
        variable bit_p : std_logic;
        variable IndicateurOerr : std_logic;

    begin
        -- Réinitialisation
        if (reset = '0') then
            IndicateurOerr := '0';
            Ferr <= '0';
            OErr <= '0';
            DRdy <= '0';
            data_aux := (others => '0');
            bit_courant := 7;
            bit_p := '0';
            data <= (others => '0');
            etat_recep <= debut;

        elsif (rising_edge(clk)) then

            case etat_recep is

                when debut =>
                    -- Retour au début on remet les valeurs à 0
                    IndicateurOerr := '0';
                    Ferr <= '0';
                    OErr <= '0';
                    DRdy <= '0';
                    if (tmpclk = '1') then
                        data_aux := (others => '0'); -- Initialisation de la data temporaire
                        bit_p := '0';                -- Initialisation du bit de parité
                        bit_courant := 7;            -- Initialisation du compteur de bit
                        data <= (others => '0');     -- Initialisation de la data
                        etat_recep <= reception;     -- Passage dans l'état de reception
                    end if;
                when reception =>
                    if (tmpclk = '1') then
                        data_aux(bit_courant) := tmprxd;            -- Réception des bits un à un sur ka data temporaire
                        bit_p := bit_p xor data_aux(bit_courant);   -- Calcul progressif du bit de parité
                        if (bit_courant = 0) then
                            -- Tous les bits de donnée ont été reçus, on pass à l'état suivant
                            etat_recep <= verification_bit_p;
                        else
                            -- On décrément de le bit courant si la donnée n'a pas totalement été reçue
                            bit_courant := bit_courant - 1;
                        end if;
                    end if;
                when verification_bit_p =>
                    if (tmpclk = '1') then
                        if (tmprxd /= bit_p) then
                            -- Le bit de parité est erroné on lève une erreur et on retourne au début
                            Ferr <= '1';
                            etat_recep <= debut;
                        else
                            -- Pas d'erreur de bit de parité on passe dans l'état suivant
                            etat_recep <= verification_stop;
                        end if;
                    end if;
                when verification_stop =>
                    if (tmpclk = '1') then
                        if (tmprxd = '0') then
                            -- Le bit de stop est erroné on retourne au début et o lève une erreur de type Ferr
                            Ferr <= '1';
                            etat_recep <= debut;
                        else
                            -- On charge la data temporaire dans la data dans le cas contraire, on indique qu'une lecture est possible et
                            -- on passe dans l'état suivant
                            DRdy <= '1';
							data <= data_aux;
							etat_recep <= fin;
						end if;
                    end if;
					  when fin =>
						 if (read = '0' and IndicateurOerr = '0') then
                                -- Si la donnée n'a pas été lue, on lève une erreur de type OErr
								OErr <= '1';
								IndicateurOerr := '1';
						  end if;
                          -- Retour dans l'état initial
                          etat_recep <= debut;
                end case;
            
            end if;

        end process controle_recep;

end RxUnit_arch;
