----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:15:09 12/22/2013 
-- Design Name: 
-- Module Name:    ran_sync - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ran_sync is
--generic(
--		RND_Base_Addr : std_logic_vector(7 downto 0) := X"2F";
--		RND_High_Addr : std_logic_vector(7 downto 0) := X"3F"
--	);
	port(
		sys_clk_80M				:	in	std_logic; --system clock,80MHz
		sys_rst_n				:	in	std_logic; --system reset,high active
		--Random interface
		Rnd_tdc_do_delay     :  in   	std_logic;--rnd delay according to fpga pin
		rnd_tdc_do_flag		:	in	 	std_logic;--a new random number be generated (one pluse)
		rnd_tdc_edge_flag		:	in	 	std_logic;--random number is different with before
		T_rndedge				: 	in  	std_logic_vector(31 downto 0); --1 to 0 or 0 to 1  time window
		--carrychian interface
		tdc_wr					: 	in 	std_logic; --carrychain ready
	   tdc_inidata				: 	in 	std_logic_vector(36 downto 0); --the data form TDC module
		--output to fifo
		rnd_data_va				:	out	std_logic_vector(1 downto 0); -- random syn data
		ChnlFifoWrite			:	out 	std_logic;
	   ChnlFifoDataOut		: 	out 	std_logic_vector(36 downto 0)
	);
end ran_sync;

architecture Behavioral of ran_sync is
		signal rnd_current_cnt		:	std_logic_vector(6 downto 0);
		signal rnd_data_va_temp		:	std_logic_vector(1 downto 0);
begin
--rnd_current_cnt for T rndedge--------------------------
---------------------------------------------------------
rnd_count : process(sys_clk_80M,sys_rst_n) begin
	if(sys_rst_n = '0') then
		rnd_current_cnt <= (others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(rnd_tdc_do_flag = '1') then
			rnd_current_cnt <=(others => '0');
		else
			rnd_current_cnt <= rnd_current_cnt + '1';
		end if;
	end if;
end process;
---------------------------------------------------------
--rnd_current_cnt for T_rndedge--------------------------
---------------------------------------------------------
--current_count : process(rnd_current_cnt,tdc_wr,Rnd_tdc_do_delay,rnd_tdc_edge_flag) begin
--	if(tdc_wr = '1') then
--		if(rnd_current_cnt < T_rndedge and rnd_tdc_edge_flag = '1') then
--			rnd_data_va_temp <= "01";
--		else
--			rnd_data_va_temp(0) <= Rnd_tdc_do_delay;
--			rnd_data_va_temp(1) <= Rnd_tdc_do_delay;
--		end if;
--	else
--		rnd_data_va_temp <= rnd_data_va_temp;
--	end if;
--end process;
current_count : process(sys_clk_80M,sys_rst_n) begin
	if(sys_rst_n = '0') then
		rnd_data_va <= "00";
	elsif rising_edge(sys_clk_80M) then
		if(tdc_wr = '1') then
			if(rnd_current_cnt < T_rndedge and rnd_tdc_edge_flag = '1') then
				rnd_data_va <= "01";
			else
				rnd_data_va(0) <= Rnd_tdc_do_delay;
				rnd_data_va(1) <= Rnd_tdc_do_delay;
			end if;
		end if;
	end if;
end process;
---------------------------------------------------------
--output for fifo----------------------------------------
---------------------------------------------------------
out_fifo : process(sys_clk_80M,sys_rst_n) begin
	if(sys_rst_n = '0') then
		ChnlFifoWrite <= '0';
		ChnlFifoDataOut <= (others =>'0');
		--rnd_data_va <= "00";
	elsif rising_edge(sys_clk_80M) then
		ChnlFifoWrite <= tdc_wr;
		ChnlFifoDataOut <= tdc_inidata;
		--rnd_data_va <= rnd_data_va_temp;
	end if;
end process;
end Behavioral;

