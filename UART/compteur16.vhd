library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity compteur16 is
    port (
        enable : in std_logic;
        reset  : in std_logic;
        rxd    : in std_logic;
        tmpclk : out std_logic;
        tmprxd : out std_logic
    );
end compteur16;

architecture structural of compteur16 is

    type t_etat is (debut, compter8, compter16, fin);
    signal etat : t_etat;

begin

    process (enable, reset)
        variable compt_iter : natural;
        variable compt_bit  : natural;

    begin

        if (reset = '0') then
            -- Reset
            compt_bit := 0;
            compt_iter := 0;
            etat <= debut;
            tmpclk <= '0';
            tmprxd <= '1';

        elsif (rising_edge(enable)) then

            case etat is

                when debut =>

                    if (rxd = '0') then
                        -- On attend le premier bit de start
                        compt_iter := 0;
                        compt_bit := 0;
                        tmpclk <= '0';
                        tmprxd <= '1';
                        etat <= compter8;
                    
                    end if;

                when compter8 =>
                -- On compte 8 pour arriver au milieu du bit de start

                    if (compt_iter = 7) then
                        -- On a compté 8 itérations, donc on est au milieu du bit de start
                        tmpclk <= '1';
                        tmprxd <= rxd;
                        compt_bit := compt_bit + 1;
                        compt_iter := 0;
                        etat <= compter16;

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
                            etat <= fin;

                        else
                            -- Sinon on continue
                            compt_bit := compt_bit + 1;
                            compt_iter := 0;
                            tmpclk <= '1';
                            tmprxd <= rxd;
                            etat <= compter16;
									 
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
                    etat <= debut;
                
                end case;

            end if;
    
    end process;

end structural;
                    

