--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:02:30 10/13/2013
-- Design Name:   
-- Module Name:   F:/13/GroundSystem/code/V2/ground_pro_all/crc_tb.vhd
-- Project Name:  ground_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: crc
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
 
ENTITY crc_tb IS
END crc_tb;
 
ARCHITECTURE behavior OF crc_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT crc
    PORT(
         data_in : IN  std_logic_vector(15 downto 0);
         crc_en : IN  std_logic;
         rst_n : IN  std_logic;
         clk : IN  std_logic;
         crc_out : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal crc_en : std_logic := '0';
   signal rst_n : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal crc_out : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: crc PORT MAP (
          data_in => data_in,
          crc_en => crc_en,
          rst_n => rst_n,
          clk => clk,
          crc_out => crc_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst_n <= '0';
      wait for 100 ns;	
      rst_n <= '1';
      wait for clk_period*10;
      crc_en <= '1';
		data_in <= x"07f0";
      -- insert stimulus here 

      wait;
   end process;

END;
