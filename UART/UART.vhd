library IEEE;
use IEEE.std_logic_1164.all;

entity UARTunit is
  port (
    clk, reset : in  std_logic;
    cs, rd, wr : in  std_logic;
    RxD        : in  std_logic;
    TxD        : out std_logic;
    IntR, IntT : out std_logic;         
    addr       : in  std_logic_vector(1 downto 0);
    data_in    : in  std_logic_vector(7 downto 0);
    data_out   : out std_logic_vector(7 downto 0));
end UARTunit;


architecture UARTunit_arch of UARTunit is

  -- a completer avec l'interface des differents composants
  -- de l'UART
  
  COMPONENT ctrlUnit Port(
		clk, reset       : in  std_logic;
      rd, cs           : in  std_logic;
      DRdy, FErr, OErr : in  std_logic;
      BufE, RegE       : in  std_logic;
      IntR             : out std_logic;
      IntT             : out std_logic;
      ctrlReg          : out std_logic_vector(7 downto 0)
	);
	END COMPONENT;
  
  COMPONENT echoUnit Port(
      clk, reset : in  std_logic;
      cs, rd, wr : out  std_logic;
      IntR       : in std_logic;         -- interruption de réception
      IntT       : in std_logic;         -- interruption d'émission
      addr       : out  std_logic_vector(1 downto 0);
      data_in    : in  std_logic_vector(7 downto 0);
      data_out   : out std_logic_vector(7 downto 0)
	);
	END COMPONENT;
	
	COMPONENT TxUnit Port(
		 clk, reset : in std_logic;
		 enable : in std_logic;
		 ld : in std_logic;
		 txd : out std_logic;
		 regE : out std_logic;
		 bufE : out std_logic;
		 data : in std_logic_vector(7 downto 0)
	);
	END COMPONENT;
	
	COMPONENT clkUnit  Port(
		clk, reset : in  std_logic;
		enableTX   : out std_logic;
		enableRX   : out std_logic);
	END COMPONENT;

  signal lecture, ecriture : std_logic;
  signal donnees_recues : std_logic_vector(7 downto 0);
  signal registre_controle : std_logic_vector(7 downto 0);

  -- a completer par les signaux internes manquants
  
  signal enableRX1, enableTX1 : std_logic;
  signal bufE1, regE1, DRdy1, FErr1, OErr1 : std_logic;
  signal intT1, intR1 : std_logic;

  begin  -- UARTunit_arch

    lecture <= '1' when cs = '0' and rd = '0' else '0';
    ecriture <= '1' when cs = '0' and wr = '0' else '0';
    data_out <= donnees_recues when lecture = '1' and addr = "00"
                else registre_controle when lecture = '1' and addr = "01"
                else "00000000";
  
    -- a completer par la connexion des differents composants
	 
	 Inst_clkUnit : clkUnit PORT MAP(
		clk => clk,
		reset => reset,
		enableTX => enableTX1,
		enableRX => enableRX1
	);
	
	Inst_TxUnit : TxUnit PORT MAP(
		clk => clk,
		reset => reset,
		enable => enableTX1,
		ld => ecriture,
		txd => TxD,
		regE => regE1,
		bufE => bufE1,
		data => data_in
	);
	
	Inst_echoUnit : echoUnit PORT MAP(
		clk => clk,
		reset => reset,
		cs => cs,
		rd => rd,
		wr => wr,
		intT => intT1,
		intR => intR1,
		addr => addr,
		data_in => data_in,
		data_out => data_out
	);
	
	Inst_ctrlUnit : ctrlUnit PORT MAP(
		clk => clk,
		reset => resetn,
		rd => rd,
		cs => cs,
		DRdy => DRdy1,
		FErr => FErr1,
		OErr => OErr1,
		bufE => bufE1,
		regE => regE1,
		intR => intT1,
		intT => intR1,
		ctrlReg => registre_controle
	);

  end UARTunit_arch;
