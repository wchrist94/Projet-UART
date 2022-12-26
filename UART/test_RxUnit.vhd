LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_RxUnit IS
END test_RxUnit;
 
ARCHITECTURE behavior OF test_RxUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RxUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         read : IN  std_logic;
         rxd : IN  std_logic;
         data : OUT  std_logic_vector(7 downto 0);
         FErr : OUT  std_logic;
         OErr : OUT  std_logic;
         DRdy : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enable : std_logic := '0';
   signal rd : std_logic := '0';
   signal rxd : std_logic := '0';

 	--Outputs
   signal data : std_logic_vector(7 downto 0);
   signal FErr : std_logic;
   signal OErr : std_logic;
   signal DRdy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RxUnit PORT MAP (
          clk => clk,
          reset => reset,
          enable => enable,
          read => rd,
          rxd => rxd,
          data => data,
          FErr => FErr,
          OErr => OErr,
          DRdy => DRdy
        );

   -- Clock process definitions On met enable deux fois plus lent que la clk
   clk_process :process
   begin
		clk <= '0';
		enable <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
		enable <= '1';

		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		reset <= '0';
		rxd <= '0';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		reset <= '1';
		wait for clk_period*4;
		rxd <= '1';
		wait for clk_period*10;
		rxd <= '0';
		wait for clk_period*64;
		rxd <= '1';
		wait for clk_period*32;
		rxd <= '0';
		wait for clk_period*32;
		rxd <= '1';
		wait for clk_period*32;
		rxd <= '0';
		wait for clk_period*32;
		rxd <= '1';
		wait for clk_period*32;
		rxd <= '0';
		wait for clk_period*32;
		rxd <= '1';
		wait for clk_period*32;
		rxd <= '0';
		wait for clk_period*32;
		rxd <= '0'; -- Erreur dans le bit de stop.
		wait for clk_period*32;
		rxd <= '1';
		
		wait until DRdy = '1';
		wait until DRdy = '0';
		rd <= '1';
		wait for clk_period*2;
		rd <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;