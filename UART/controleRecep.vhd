library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controleRecep is
    port (
        clk : in std_logic;
        reset : in std_logic;
        read : in std_logic;
        tmpclk : in std_logic;
        tmprxd : in std_logic;
        Ferr : out std_logic;
        OErr : out std_logic;
        DRdy : out std_logic;
        data : out std_logic_vector (7 downto 0)
    );
end controleRecep;

architecture behavorial of controleRecep is

    type t_etat is (debut, reception,reception_bis, verification_bit_p, verification_fin);
    signal etat : t_etat;

begin

    process (clk,reset)

        variable data_aux : std_logic_vector (7 downto 0);
        variable bit_courant : natural;
        variable bit_p : std_logic;
        variable IndicateurOerr : std_logic;

    begin

        if (reset = '0') then
            IndicateurOerr := '0';
            Ferr <= '0';
            OErr <= '0';
            DRdy <= '0';
            data_aux := (others => '0');
            bit_courant := 7;
            bit_p := '0';
            data <= (others => '0');
            etat <= debut;

        elsif (rising_edge(clk)) then

            case etat is

                when debut =>

                    IndicateurOerr := '0';
                    Ferr <= '0';
                    OErr <= '0';
                    DRdy <= '0';

                    if (tmpclk = '1') then

                        data_aux := (others => '0');
                        bit_p := '0';
                        bit_courant := 7;
                        data <= (others => '0');
                        etat <= reception;

                    end if;
                
                when reception =>

                    if (tmpclk = '1') then

                        data_aux(bit_courant) := tmprxd;
                        bit_p := bit_p xor data_aux(bit_courant);
                        bit_courant := bit_courant - 1;
                        etat <= reception_bis;
                    
                    end if;

                when reception_bis =>

                    if (tmpclk = '1') then

                        data_aux(bit_courant) := tmprxd;
                        bit_p := bit_p xor data_aux(bit_courant);

                        if (bit_courant = 0) then

                            etat <= verification_bit_p;
                        
                        else

                            bit_courant := bit_courant - 1;
                        
                        end if;

                    end if;

                when verification_bit_p =>

                    if (tmpclk = '1') then

                        if (tmprxd /= bit_p) then

                            Ferr <= '1';
                            etat <= debut;
                        else
                            etat <= verification_fin;

                        end if;

                        

                    end if;

                when verification_fin =>

                    if (tmpclk = '1') then

                        if (tmprxd = '0') then

                            Ferr <= '1';
                            DRdy <= '0';
                            etat <= debut;

                        else
                            DRdy <= '1';
                            if (read = '0' and IndicateurOerr = '0') then
                                OErr <= '1';
                                IndicateurOerr := '1';
                            elsif (read = '0' and IndicateurOerr = '1') then
                                OErr <= '0';
                                etat <= debut;
                            else
                                data <= data_aux;
                                etat <= debut;
                            end if;
                        end if;
                    
                    end if;
                end case;
            
            end if;

        end process;

end behavorial;


                        


