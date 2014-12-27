--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:45:07 12/22/2013
-- Design Name:   
-- Module Name:   F:/13/GroundSystem/code/V2/ground_pro_all/ran_syn_TH.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ran_sync
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY ran_syn_TH IS
END ran_syn_TH;
 
ARCHITECTURE behavior OF ran_syn_TH IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ran_sync
    PORT(
         sys_clk_80M : IN  std_logic;
         sys_rst_n : IN  std_logic;
         Rnd_tdc_do_delay : IN  std_logic;
         rnd_tdc_do_flag : IN  std_logic;
         rnd_tdc_edge_flag : IN  std_logic;
         T_rndedge : IN  std_logic_vector(31 downto 0);
         tdc_wr : IN  std_logic;
         tdc_inidata : IN  std_logic_vector(36 downto 0);
         rnd_data_va : OUT  std_logic_vector(1 downto 0);
         ChnlFifoWrite : OUT  std_logic;
         ChnlFifoDataOut : OUT  std_logic_vector(36 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal sys_clk_80M : std_logic := '0';
   signal sys_rst_n : std_logic := '0';
   signal Rnd_tdc_do_delay : std_logic := '0';
   signal rnd_tdc_do_flag : std_logic := '0';
   signal rnd_tdc_edge_flag : std_logic := '0';
   signal T_rndedge : std_logic_vector(31 downto 0) := (others => '0');
   signal tdc_wr : std_logic := '0';
   signal tdc_inidata : std_logic_vector(36 downto 0) := (others => '0');

 	--Outputs
   signal rnd_data_va : std_logic_vector(1 downto 0);
   signal ChnlFifoWrite : std_logic;
   signal ChnlFifoDataOut : std_logic_vector(36 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
  signal clk_mod : std_logic;
   
	constant clk_period : time := 12.5 ns; --80M
	constant clk_mod_period : time :=1000 ns;  -- 1M  
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ran_sync PORT MAP (
          sys_clk_80M => sys_clk_80M,
          sys_rst_n => sys_rst_n,
          Rnd_tdc_do_delay => Rnd_tdc_do_delay,
          rnd_tdc_do_flag => rnd_tdc_do_flag,
          rnd_tdc_edge_flag => rnd_tdc_edge_flag,
          T_rndedge => T_rndedge,
          tdc_wr => tdc_wr,
          tdc_inidata => tdc_inidata,
          rnd_data_va => rnd_data_va,
          ChnlFifoWrite => ChnlFifoWrite,
          ChnlFifoDataOut => ChnlFifoDataOut
        );

   -- Clock process definitions
   clk_process :process begin
		sys_clk_80M <= '0';
		wait for clk_period/2;
		sys_clk_80M <= '1';
		wait for clk_period/2;
   end process;
	-- mod clock
	clk_mod_process : process begin
		wait until sys_rst_n = '1';
		clk_mod <= '0';
		wait for clk_mod_period/2;
		clk_mod <= '1';
		wait for clk_mod_period/2;
   end process;
	-- sys_rst_n process definitions
   rst_process : process begin
		sys_rst_n <='0';
		wait for 100 ns;
		sys_rst_n <='1';
		wait;
	end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
		wait until sys_rst_n = '1';
		Rnd_tdc_do_delay <= '0';
		rnd_tdc_do_flag <= '0';
		rnd_tdc_edge_flag <= '0';
		wait for clk_period*4;
		T_rndedge <= X"00000007";
--		signal tdc_wr : std_logic := '0';
--   signal tdc_inidata : std_logic_vector(36 downto 0) := (others => '0');
--		signal Rnd_tdc_do_delay : std_logic := '0';
--   signal rnd_tdc_do_flag : std_logic := '0';
--   signal rnd_tdc_edge_flag : std_logic := '0';
--	constant clk_period : time := 12.5 ns; --80M
--	constant clk_mod_period : time :=1000 ns;  -- 1M
--for i in 0 to 3 loop
--			cpldif_dac_addr	<=	cpldif_dac_addr + '1';
--			wait for clk_period;
--			cpldif_dac_rd_en	<=	'1';
--			wait for clk_period;
--			cpldif_dac_rd_en	<=	'0';
--			wait for clk_period*5;
--		end loop;
		wait until rising_edge(clk_mod); -- transfer 1
		Rnd_tdc_do_delay <= '1';
		rnd_tdc_do_flag <= '1';
		rnd_tdc_edge_flag <= '1';
		wait for clk_period ;
		rnd_tdc_do_flag <= '0';
		for i in 0 to 8 loop
			wait until rising_edge(sys_clk_80M);
		end loop;
		--wait for clk_period*9;
		tdc_wr <= '1';
		tdc_inidata <= X"110000111" & '0';
		wait for clk_period ;
		tdc_wr <= '0';
		
      wait until rising_edge(clk_mod); -- transfer 1
		Rnd_tdc_do_delay <= '1';
		rnd_tdc_do_flag <= '1';
		rnd_tdc_edge_flag <= '0';
		wait for 12.5 ns;
		rnd_tdc_do_flag <= '0';  
		for i in 0 to 3 loop
			wait until rising_edge(sys_clk_80M);
		end loop;
		--wait for clk_period*4;
		tdc_wr <= '1';
		tdc_inidata <= X"110001111" & '0';
		wait for clk_period ;
		tdc_wr <= '0';
		
      wait until rising_edge(clk_mod); -- transfer 0
		Rnd_tdc_do_delay <= '0';
		rnd_tdc_do_flag <= '1';
		rnd_tdc_edge_flag <= '1';
		wait for 12.5 ns;
		rnd_tdc_do_flag <= '0';
		wait for clk_period*13;
		tdc_wr <= '1';
		tdc_inidata <= X"110100111" & '0';
		wait for clk_period ;
		tdc_wr <= '0';
		
		wait until rising_edge(clk_mod); -- transfer 1
		Rnd_tdc_do_delay <= '1';
		rnd_tdc_do_flag <= '1';
		rnd_tdc_edge_flag <= '1';
		wait for 12.5 ns;
		rnd_tdc_do_flag <= '0';
		wait for clk_period*20;
		tdc_wr <= '1';
		tdc_inidata <= X"100000110" & '0';
		wait for clk_period ;
		tdc_wr <= '0';
		
		wait until rising_edge(clk_mod); -- transfer 0
		Rnd_tdc_do_delay <= '0';
		rnd_tdc_do_flag <= '1';
		rnd_tdc_edge_flag <= '1';
		wait for 12.5 ns;
		rnd_tdc_do_flag <= '0';
		wait for clk_period*3;
		tdc_wr <= '1';
		tdc_inidata <= X"000000111" & '0';
		wait for clk_period ;
		tdc_wr <= '0';
		
		wait until rising_edge(clk_mod); -- transfer 1
		Rnd_tdc_do_delay <= '1';
		rnd_tdc_do_flag <= '1';
		rnd_tdc_edge_flag <= '1';
		wait for 12.5 ns;
		rnd_tdc_do_flag <= '0';
		wait for clk_period*17;
		tdc_wr <= '1';
		tdc_inidata <= X"110000000" & '0';
		wait for clk_period ;
		tdc_wr <= '0';
		
		wait until rising_edge(clk_mod); -- transfer 0
		Rnd_tdc_do_delay <= '0';
		rnd_tdc_do_flag <= '1';
		rnd_tdc_edge_flag <= '1';
		wait for 12.5 ns;
		rnd_tdc_do_flag <= '0';
		wait for clk_period*6;
		tdc_wr <= '1';
		tdc_inidata <= X"111111111" & '0';
		wait for clk_period ;
		tdc_wr <= '0';
		
		wait until rising_edge(clk_mod); -- transfer 0
		Rnd_tdc_do_delay <= '0';
		rnd_tdc_do_flag <= '1';
		rnd_tdc_edge_flag <= '0';
		wait for 12.5 ns;
		rnd_tdc_do_flag <= '0';
		wait for clk_period*10;
		tdc_wr <= '1';
		tdc_inidata <= X"110100111" & '0';
		wait for clk_period ;
		tdc_wr <= '0';
		
		
      -- insert stimulus here 

      wait;
   end process;

END;
