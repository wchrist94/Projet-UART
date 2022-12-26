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

	component compteur16 is
		port (
			enable : in std_logic;
			reset  : in std_logic;
			rxd	   : in std_logic;
			tmpclk : out std_logic;
			tmprxd : out std_logic
		);
	end component;

	component controleRecep is
		port (
			clk 	: in std_logic;
			reset : in std_logic;
			tmpclk: in std_logic;
			tmprxd: in std_logic;
			read  : in std_logic;
			Ferr  : out std_logic;
			OErr  : out std_logic;
			DRdy  : out std_logic;
			data  : out std_logic_vector(7 downto 0)
		);
	end component;

	signal tmpclk_bis : std_logic;
	signal tmprxd_bis : std_logic;

begin
	
	Inst_compteur16 : compteur16 PORT MAP (
		enable => enable,
		reset => reset,
		rxd => rxd,
		tmpclk => tmpclk_bis,
		tmprxd => tmprxd_bis
	);

	Inst_controleRecep : controleRecep PORT MAP (
		clk => clk,
		reset => reset,
		read => read,
		tmpclk => tmpclk_bis,
		tmprxd => tmprxd_bis,
		Ferr => Ferr,
		OErr => OErr,
		DRdy => DRdy,
		data => data
	);
	
end RxUnit_arch;
