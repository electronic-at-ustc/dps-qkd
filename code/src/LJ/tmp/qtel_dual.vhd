----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:22:01 07/24/2014 
-- Design Name: 
-- Module Name:    qtel_dual - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity qtel_dual is
generic(
		qtel_Base_Addr : std_logic_vector(7 downto 0) := X"7B";
		--qtel_High_Addr : std_logic_vector(7 downto 0) := X"7C";
		qtel_High_Addr : std_logic_vector(7 downto 0) := X"7D"
		
	);
	port(
		------ system clock and reset signal -------
	   sys_clk_160M 				: 	in	std_logic;
		sys_rst_n 					: 	in	std_logic;
		qtel_en_out					:	out std_logic;
		------ 80M clock and ----------------
		out_clk_80M					: 	in	std_logic;
		------------8 channel signal input ------
		tdc_qtel_hit				:	in 	std_logic_vector(15 downto 0);
		--apd_fpga_hit_p			: 	in	std_logic_vector(9 downto 1);
		--apd_fpga_hit_n			:	in	std_logic_vector(9 downto 1);
		------ cpld module ------
		cpldif_qtel_addr			:	in	std_logic_vector(7 downto 0);
		cpldif_qtel_wr_en			:	in	std_logic;
		cpldif_qtel_rd_en			:	in	std_logic;
		cpldif_qtel_wr_data		:	in	std_logic_vector(31 downto 0);
		qtel_cpldif_rd_data		:	out	std_logic_vector(31 downto 0);
		------ output to counter module ------
		qtel_counter_match		:	out	std_logic_vector(15 downto 0);
		---------TEST POINT------
		qtel_clk_80M_out				:	out std_logic;
		qtel_clk_80M_delay_out		:	out std_logic
	);
end qtel_dual;

architecture Behavioral of qtel_dual is
--COMPONENT multichnlTDC
--	generic(
--		tdc_basic_addr	:	std_logic_vector(7 downto 0) := X"10";
--		tdc_high_addr	:	std_logic_vector(7 downto 0) := X"14"
--	);
--	PORT(

	COMPONENT qtel is
	generic (
		qtel_Base_Addr : std_logic_vector(7 downto 0) := X"7B";
		--qtel_High_Addr : std_logic_vector(7 downto 0) := X"7C";
		qtel_High_Addr : std_logic_vector(7 downto 0) := X"7D"
	);
	PORT(
		sys_clk_160M : IN std_logic;
		sys_rst_n : IN std_logic;
		qtel_clk_80M : IN std_logic;
		tdc_qtel_hit : IN std_logic_vector(15 downto 0);
		cpldif_qtel_addr : IN std_logic_vector(7 downto 0);
		cpldif_qtel_wr_en : IN std_logic;
		cpldif_qtel_rd_en : IN std_logic;
		cpldif_qtel_wr_data : IN std_logic_vector(31 downto 0);          
		qtel_en_out : OUT std_logic;
		qtel_cpldif_rd_data : OUT std_logic_vector(31 downto 0);
		qtel_counter_match : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	
	COMPONENT qtel_clk
	PORT(
		out_clk_80M : IN std_logic;          
		qtel_clk_80M : OUT std_logic;
		qtel_clk_80M_delay : OUT std_logic
		);
	END COMPONENT;
	---------------------siganl------------------
	signal qtel_en				:	std_logic;
	signal qtel_clk_80M			:	std_logic;
	signal qtel_clk_80M_delay			:	std_logic;
--signal qtel_clk_80m 		:std_logic;
	signal qtel_en_delay 	:std_logic;
	signal qtel_counter_match1 			: 	std_logic_vector(7 downto 0);	
	signal qtel_counter_match_delay			: 	std_logic_vector(7 downto 0);
	signal qtel_cpldif_rd_data_delay 			: 	std_logic_vector(31 downto 0);


	signal cpldif_wr_data		:	std_logic_vector(31 downto 0);
	signal rd_data_reg 			: 	std_logic_vector(31 downto 0);
	signal wr_data_reg 			: 	std_logic_vector(31 downto 0);
	signal cpldif_addr 			: 	std_logic_vector(7 downto 0);
	signal cpldif_wr_en			:	std_logic;
	signal cpldif_rd_en			:	std_logic;

begin

Inst_qtel: qtel
generic map(
		QTEL_Base_Addr	=> qtel_Base_Addr,
		QTEL_High_Addr	=> qtel_High_Addr
	)
PORT MAP(
		sys_clk_160M => sys_clk_160M,
		sys_rst_n => sys_rst_n,
		qtel_en_out => qtel_en,
		qtel_clk_80M => qtel_clk_80M,
		tdc_qtel_hit => tdc_qtel_hit,
		cpldif_qtel_addr => cpldif_addr,
		cpldif_qtel_wr_en => cpldif_wr_en,
		cpldif_qtel_rd_en => cpldif_rd_en,
		cpldif_qtel_wr_data => cpldif_wr_data,
		qtel_cpldif_rd_data => qtel_cpldif_rd_data,
		qtel_counter_match =>  qtel_counter_match1
	);
	
Inst_qtel_delay: qtel
generic map(
		QTEL_Base_Addr	=> qtel_Base_Addr,
		QTEL_High_Addr	=> qtel_High_Addr
	)
PORT MAP(
		sys_clk_160M => sys_clk_160M,
		sys_rst_n => sys_rst_n,
		qtel_en_out =>qtel_en_delay ,
		qtel_clk_80M => qtel_clk_80M_delay,
		tdc_qtel_hit => tdc_qtel_hit,
		cpldif_qtel_addr => cpldif_addr,
		cpldif_qtel_wr_en => cpldif_wr_en,
		cpldif_qtel_rd_en => cpldif_rd_en,
		cpldif_qtel_wr_data => cpldif_wr_data,
		qtel_cpldif_rd_data => qtel_cpldif_rd_data_delay,
		qtel_counter_match =>  qtel_counter_match_delay
	);
	
Inst_qtel_clk: qtel_clk 
PORT MAP(
		out_clk_80M 	=> out_clk_80M,
		qtel_clk_80M 	=> qtel_clk_80M,
		qtel_clk_80M_delay => qtel_clk_80M_delay
	);
	
qtel_counter_match 			<= qtel_counter_match_delay & qtel_counter_match1;
qtel_clk_80M_out 				<=qtel_clk_80M;
qtel_clk_80M_delay_out 		<=qtel_clk_80M_delay;
qtel_en_out 					<= qtel_en;
end Behavioral;

