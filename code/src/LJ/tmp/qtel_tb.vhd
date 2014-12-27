--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:32:15 07/01/2014
-- Design Name:   
-- Module Name:   F:/SP/ground system/FPGA/ground_pro_all_outinLVDSCLK-160MHZdcm160Mhz_count_fix/ground_pro_all_outinLVDSCLK/qtel_tb.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: qtel
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
 
ENTITY qtel_tb IS
END qtel_tb;
 
ARCHITECTURE behavior OF qtel_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
	 	COMPONENT qtel
	PORT(
		sys_clk_160M : IN std_logic;
		sys_rst_n : IN std_logic;
		tdc_qtel_hit : IN std_logic_vector(8 downto 0);
		cpldif_qtel_addr : IN std_logic_vector(7 downto 0);
		cpldif_qtel_wr_en : IN std_logic;
		cpldif_qtel_rd_en : IN std_logic;
		cpldif_qtel_wr_data : IN std_logic_vector(31 downto 0);          
		qtel_cpldif_rd_data : OUT std_logic_vector(31 downto 0);
		qtel_counter_match : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
 
--    COMPONENT qtel
--    PORT(
--         sys_clk_160M : IN  std_logic;
--         sys_rst_n : IN  std_logic;
--         --qtel_clk_80M : IN  std_logic;
--         tdc_qtel_hit : IN  std_logic_vector(8 downto 0);
--         cpldif_qtel_addr : IN  std_logic_vector(7 downto 0);
--         cpldif_qtel_wr_en : IN  std_logic;
--         cpldif_qtel_rd_en : IN  std_logic;
--         cpldif_qtel_wr_data : IN  std_logic_vector(31 downto 0);
--         qtel_cpldif_rd_data : OUT  std_logic_vector(31 downto 0)
--        );
--    END COMPONENT;
    

   --Inputs
   signal sys_clk_160M : std_logic := '0';
   signal sys_rst_n : std_logic := '0';
  -- signal modu_qtel_clk_80M : std_logic := '0';
   signal tdc_qtel_hit : std_logic_vector(8 downto 0) := (others => '0');
   signal cpldif_qtel_addr : std_logic_vector(7 downto 0) := (others => '0');
   signal cpldif_qtel_wr_en : std_logic := '0';
   signal cpldif_qtel_rd_en : std_logic := '0';
   signal cpldif_qtel_wr_data : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal qtel_cpldif_rd_data : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
    signal qtel_clk_80M : std_logic := '0';
    signal qtel_counter_match : std_logic_vector(7 downto 0);
   constant qtel_clk_80M_period : time := 12.5 ns;
	 constant sys_clk_160M_period : time := 6.25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: qtel PORT MAP (
          sys_clk_160M => sys_clk_160M,
          sys_rst_n => sys_rst_n,
          tdc_qtel_hit => tdc_qtel_hit,
          cpldif_qtel_addr => cpldif_qtel_addr,
          cpldif_qtel_wr_en => cpldif_qtel_wr_en,
          cpldif_qtel_rd_en => cpldif_qtel_rd_en,
          cpldif_qtel_wr_data => cpldif_qtel_wr_data,
          qtel_cpldif_rd_data => qtel_cpldif_rd_data,
			 qtel_counter_match =>  qtel_counter_match
        );
   -- Clock process definitions
   clk_160M_process :process
   begin
		sys_clk_160M <= '0';
		wait for sys_clk_160M_period/2;
		sys_clk_160M <= '1';
		wait for sys_clk_160M_period/2;
   end process;
	   tdc_qtel_hit(0) <= qtel_clk_80M;
    --Clock process definitions
   qtel_clk_80M_process :process
   begin
		qtel_clk_80M <= '0';
		wait for qtel_clk_80M_period/2;
		qtel_clk_80M <= '1';
		wait for qtel_clk_80M_period/2;
   end process;
   rst_process : process 
	begin
		sys_rst_n <='0';
		wait for 100 ns;
		sys_rst_n <='1';
		wait;
	end process;
	
	


   -- Stimulus process
   stim_proc: process

      procedure register_wr ( 
						         --	wr_en : in std_logic;
									addr : in std_logic_vector(7 downto 0);
									data_in : in std_logic_vector(31 downto 0 )
									) is begin
			wait until rising_edge(sys_clk_160M);
			cpldif_qtel_addr	<=	addr;
			cpldif_qtel_wr_data	<=	data_in;
			wait for sys_clk_160M_period*2;
			cpldif_qtel_wr_en	<=	'1';
			wait for sys_clk_160M_period;
			cpldif_qtel_wr_en	<=	'0';
	   end register_wr;
		
	   begin		
	   wait until sys_rst_n ='1';
		wait for sys_clk_160M_period*10;
		register_wr(X"7D",X"00000001"); --
		wait for sys_clk_160M_period*10;
		register_wr(X"7B",X"0000000B"); --
		wait for sys_clk_160M_period*10;
		register_wr(X"7C",X"00000002"); --
		wait for sys_clk_160M_period*10;
		
	--	wait until (sys_clk_160M'event and sys_clk_160M = '1');
		
		wait until rising_edge(qtel_clk_80M );
		wait for qtel_clk_80M_period/4;
		tdc_qtel_hit(8 downto 1) <= "00000011";
		wait for 20ns;
		tdc_qtel_hit(8 downto 1) <= "00000000";
		wait for 50ns;
		
		wait until rising_edge(qtel_clk_80M );
		wait for qtel_clk_80M_period/2;
		tdc_qtel_hit(8 downto 1) <= "00000010";
		wait for 20ns;
		tdc_qtel_hit(8 downto 1) <= "00000000";
		wait for 50ns; 
		
		wait until rising_edge(qtel_clk_80M );
		wait for qtel_clk_80M_period/4;
		tdc_qtel_hit(8 downto 1) <= "00000011";
		wait for 20ns;
		tdc_qtel_hit(8 downto 1) <= "00000000";
		wait for 50ns;
		
		
   end process;

END;
