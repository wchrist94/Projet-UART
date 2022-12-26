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

            compt_bit := 0;
            compt_iter := 0;
            etat <= debut;
            tmpclk <= '0';
            tmprxd <= '1';

        elsif (rising_edge(enable)) then

            case etat is

                when debut =>

                    if (rxd = '0') then

                        compt_iter := 0;
                        compt_bit := 0;
                        tmpclk <= '0';
                        tmprxd <= '1';
                        etat <= compter8;
                    
                    end if;

                when compter8 =>

                    if (compt_iter = 7) then

                        tmpclk <= '1';
                        tmprxd <= rxd;
                        compt_bit := compt_bit + 1;
                        compt_iter := 0;
                        etat <= compter16;

                    else

                        compt_iter := compt_iter + 1;
                        tmpclk <= '0';
                    
                    end if;

                when compter16 =>

                    if (compt_iter = 15) then

                        if (compt_bit = 11) then

                            tmpclk <= '0';
                            etat <= fin;

                        else

                            compt_bit := compt_bit + 1;
                            compt_iter := 0;
                            tmpclk <= '1';
                            tmprxd <= rxd;
                            etat <= compter16;
									 
						end if;

                    else

                        compt_iter := compt_iter + 1;
                        tmpclk <= '0';
                    
                    end if;
                
                when fin =>

                    tmpclk <= '0';
                    tmprxd <= rxd;
                    etat <= debut;
                
                end case;

            end if;
    
    end process;

end structural;


                    

