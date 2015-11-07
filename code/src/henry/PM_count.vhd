----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:43:09 11/27/2014 
-- Design Name: 
-- Module Name:    count_phase - Behavioral 
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

use ieee.std_logic_unsigned.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PM_count is
generic(
		tdc_chl_num		:	integer := 2
	);--修改寄存器

port(
	-- fix by herry make sys_clk_80M to sys_clk_160M
	   sys_clk_80M		:	in	std_logic;--system clock,80MHz
		sys_rst_n		:	in	std_logic;--system reset,low active
		fifo_rst			:	in	std_logic;--system reset,low active
		---apd interface
		apd_fpga_hit	: 	in	std_logic_vector(tdc_chl_num-1 downto 0);--apd pulse input
		---tdc module
		---confirm
		--tdc_count_time_value	:	in	std_logic_vector(31 downto 0);
		---from dac-----------------------------------
		dac_finish   :	in	std_logic;
		pm_data_store_en	: in std_logic;
		---count out to alt
		offset_voltage		: in std_logic_vector(11 downto 0);--offset_voltage
		half_wave_voltage	: in std_logic_vector(11 downto 0);--half_wave_voltage
		use_8apd     : in std_logic;
		use_4apd     : in std_logic;
		wait_start	 :	in 	std_logic;
		wait_count 	 : in 	std_logic_vector(19 downto 0);
		wait_dac_cnt : in 	std_logic_vector(7 downto 0);
		wait_finish	 :	out 	std_logic;
		
		chnl_cnt_reg0_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg1_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg2_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg3_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg4_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg5_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg6_out	: out std_logic_vector(9 downto 0);
		chnl_cnt_reg7_out	: out std_logic_vector(9 downto 0);
		
--		chnl_cnt_reg8_out	: out std_logic_vector(9 downto 0);
--		chnl_cnt_reg9_out	: out std_logic_vector(9 downto 0);
		
		alg_data_wr			: out	std_logic;
		alg_data_wr_data	: out	std_logic_vector(47 downto 0);
		---------
		lut_ram_128_vld  : in std_logic;
		lut_ram_128_addr : in STD_LOGIC_vector(6 downto 0);
		lut_ram_128_data : in STD_LOGIC_vector(15 downto 0);
		
		----alg result------
		chopper_ctrl 		: in std_logic;
		result_ok 		: in std_logic;
		one_time_end		: in std_logic;
		DAC_set_addr   : in std_logic_vector(6 downto 0);
		DAC_set_result : in std_logic_vector(11 downto 0);
		min_set_result_en : out std_logic;
		min_set_result : out std_logic_vector(15 downto 0);
		DAC_set_data 	: in std_logic_vector(11 downto 0)
	);
end PM_count;

architecture Behavioral of PM_count is
type MultiChnlCountType is array(0 to tdc_chl_num-1) of std_logic_vector(9 downto 0); ----总结
signal apd_cnt_reg   : MultiChnlCountType;
signal apd_cnt_reg_mux : std_logic_vector(9 downto 0);
signal apd0_cnt_reg_0   : std_logic_vector(9 downto 0);
signal apd1_cnt_reg_0   : std_logic_vector(9 downto 0);
signal apd0_cnt_reg_1   : std_logic_vector(9 downto 0);
signal apd1_cnt_reg_1   : std_logic_vector(9 downto 0);
--constant  msecond		: std_logic_vector(19 downto 0) := X"13880";  --*12.5=1ms
--constant  usecned 	: std_logic_vector(11 downto 0) := X"320";   --*12.5=10us
signal stable_cnt		: std_logic_vector(19 downto 0) ;
signal min_cnt			: std_logic_vector(11 downto 0) ;
signal min_cnt0		: std_logic_vector(11 downto 0) ;
signal min_cnt1		: std_logic_vector(11 downto 0) ;
signal apd0_cnt_reg_sum : std_logic_vector(11 downto 0) ;
signal apd1_cnt_reg_sum : std_logic_vector(11 downto 0) ;
signal dac0_set_data_pre: std_logic_vector(11 downto 0) ;
signal dac1_set_data_pre: std_logic_vector(11 downto 0) ;
signal min_dac			: std_logic_vector(11 downto 0) ;
signal min_dac0		: std_logic_vector(11 downto 0) ;
signal min_dac1		: std_logic_vector(11 downto 0) ;
signal dac_state		: std_logic_vector(3 downto 0) ;
--signal count_en_1d		: std_logic;
--signal count_en_rising		: std_logic;
--signal dac_finish_1d		: std_logic;
--signal Dac_finish_rising		: std_logic;
signal one_time_end_d1		: std_logic;
signal wait_finish_reg		: std_logic;
signal wait_finish_d1		: std_logic;

signal apd_fpga_hit_1d		: std_logic_vector(1 downto 0);
signal apd_fpga_hit_2d		: std_logic_vector(1 downto 0); 
signal hit_cnt_en				: std_logic_vector(1 downto 0); 

signal lut_ram_128_cnt		: std_logic_vector(19 downto 0); 

signal 		chnl_cnt_reg0	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg1	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg2	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg3	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg4	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg5	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg6	:  std_logic_vector(9 downto 0);
signal 		chnl_cnt_reg7	:  std_logic_vector(9 downto 0);
		
--signal 		chnl_cnt_reg8	:  std_logic_vector(9 downto 0);
--signal 		chnl_cnt_reg9	:  std_logic_vector(9 downto 0);

begin
chnl_cnt_reg0_out <= chnl_cnt_reg0;
chnl_cnt_reg1_out <= chnl_cnt_reg1;
chnl_cnt_reg2_out <= chnl_cnt_reg2;
chnl_cnt_reg3_out <= chnl_cnt_reg3;
chnl_cnt_reg4_out <= chnl_cnt_reg4;
chnl_cnt_reg5_out <= chnl_cnt_reg5;
chnl_cnt_reg6_out <= chnl_cnt_reg6;
chnl_cnt_reg7_out <= chnl_cnt_reg7;
----chnl_cnt_reg8_out <= chnl_cnt_reg8;
----chnl_cnt_reg9_out <= chnl_cnt_reg9;

---******* detect rising of the 'Dac_finish' ***
---one beat delay
--dly_dac_finish_pro : process(sys_clk_80M,sys_rst_n)
--begin
--	if(sys_rst_n = '0') then
--		Dac_finish_1d	<=	'0';
--	elsif rising_edge(sys_clk_80M) then
--		Dac_finish_1d	<=	Dac_finish;
--	end if;
--end process;
--Dac_finish_rising  <=  (not Dac_finish_1d) and Dac_finish;
--PM 稳定时间 设置PM 一段时间后使能 count--------------------------
--------------DAC stable_time--------------------
-----------after the Dac_finish is rising ------------------ 
stable_time: process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0' ) then-------------
		stable_cnt	<=	(others =>'0');--(others => '0')   
	elsif rising_edge(sys_clk_80M) then
		if(wait_start = '1') then
			stable_cnt	<=	wait_count;
		else
			if(stable_cnt > 0)then 
				stable_cnt	<=	stable_cnt - '1';
			else
				null;
			end if;
		end if;
	end if;
end process;
wait_finish_pro: process(sys_clk_80M,sys_rst_n)
begin
if(sys_rst_n = '0' ) then-------------
	wait_finish_reg	<=	'0';    
	wait_finish			<=	'0';    ----dedicated, change must be careful
	wait_finish_d1		<=	'0';    ----dedicated, change must be careful
elsif rising_edge(sys_clk_80M) then
	wait_finish		<= wait_finish_reg;
	wait_finish_d1	<= wait_finish_reg;
	if(stable_cnt = 1)then 
		wait_finish_reg	<=	'1';
	else
		wait_finish_reg	<=	'0';
	end if;
end if;
end process;

process(sys_clk_80M,sys_rst_n, fifo_rst)
begin
if(sys_rst_n = '0' or fifo_rst = '1' ) then-------------
	lut_ram_128_cnt	<=	(others => '0');    
elsif rising_edge(sys_clk_80M) then
	if(lut_ram_128_vld = '1')then 
		lut_ram_128_cnt	<=	lut_ram_128_cnt + 1;
	end if;
end if;
end process;
---******* detect rising of the 'apd_fpga_hit' ***
---two beat delay
delay_hit : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		apd_fpga_hit_1d	<=	(others => '0');
		apd_fpga_hit_2d	<=	(others => '0');
--		apd_cnt_reg_mux	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then
		apd_fpga_hit_1d	<=	apd_fpga_hit;
		apd_fpga_hit_2d	<=	apd_fpga_hit_1d;
--		if(use_4apd = '1') then
--			apd_cnt_reg_mux	<= apd_cnt_reg(0);
--		else	---default is APD 2
--			apd_cnt_reg_mux	<= apd_cnt_reg(1);
--		end if;
	end if;
end process;

rising_gen : for i in 0 to tdc_chl_num-1 generate
rising_pro : process(sys_clk_80M)
begin
	if rising_edge(sys_clk_80M) then
		hit_cnt_en(i)	<=	apd_fpga_hit_1d(i) and (not apd_fpga_hit_2d(i));
	end if;
end process;
end generate;

apd_cnt_gen : for i in 0 to tdc_chl_num-1 generate
	apd_cnt_pro : process(sys_clk_80M,sys_rst_n)
	begin
		if(sys_rst_n = '0') then
			apd_cnt_reg(i)		<=	(others => '0');
		elsif rising_edge(sys_clk_80M) then	
			if(wait_start = '1') then --start count
				apd_cnt_reg(i)		<=	(others => '0');
			else
				if(hit_cnt_en(i) = '1' and apd_cnt_reg(i) < 1023) then --hit enable and hit count < 1023
					apd_cnt_reg(i)	<=	apd_cnt_reg(i) + '1';
				end if;
			end if;
		end if;
	end process;
end generate;

latch_cnt_pro : process(sys_clk_80M,sys_rst_n) begin
	if(sys_rst_n = '0') then
		chnl_cnt_reg0	<=	(others => '0');
		chnl_cnt_reg1	<=	(others => '0');
		chnl_cnt_reg2	<=	(others => '0');
		chnl_cnt_reg3	<=	(others => '0');
		chnl_cnt_reg4	<=	(others => '0');
		chnl_cnt_reg5	<=	(others => '0');
		chnl_cnt_reg6	<=	(others => '0');
		chnl_cnt_reg7	<=	(others => '0');
--		chnl_cnt_reg8	<=	(others => '0');
--		chnl_cnt_reg9	<=	(others => '0');
	elsif rising_edge(sys_clk_80M) then
			if(wait_finish_reg = '1') then
				if(wait_dac_cnt = 1) then
					chnl_cnt_reg0	<=	apd_cnt_reg(0);
					chnl_cnt_reg1	<=	apd_cnt_reg(1);
				elsif(wait_dac_cnt = 2)then
					chnl_cnt_reg2	<=	apd_cnt_reg(0);
					chnl_cnt_reg3	<=	apd_cnt_reg(1);
				elsif(wait_dac_cnt = 3)then
					chnl_cnt_reg4	<=	apd_cnt_reg(0);
					chnl_cnt_reg5	<=	apd_cnt_reg(1);
				elsif(wait_dac_cnt = 4)then
					chnl_cnt_reg6	<=	apd_cnt_reg(0);
					chnl_cnt_reg7	<=	apd_cnt_reg(1);
--				elsif(wait_dac_cnt = 5)then
--					chnl_cnt_reg8	<=	apd_cnt_reg(0);
--					chnl_cnt_reg9	<=	apd_cnt_reg(1);
				end if;
			end if;
	end if;
end process;

-----------register 8 count------------------
--		alg_data_wr			: out	std_logic;
--		alg_data_wr_data	: out	std_logic_vector(31 downto 0);
alt_out : process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		alg_data_wr					<= '0';
		alg_data_wr_data			<= (others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(wait_finish_reg = '1' and wait_dac_cnt /= 0) then ---10 counter
			alg_data_wr					<= '1';
			alg_data_wr_data			<=	x"F" & DAC_set_data & wait_dac_cnt & "00" & apd_cnt_reg(1) & "00" & apd_cnt_reg(0);
		else
			if(result_ok = '1') then
				alg_data_wr					<= '1';
				alg_data_wr_data			<=	x"A" & half_wave_voltage & offset_voltage & "0" & DAC_set_addr & DAC_set_result;
			else
				if(lut_ram_128_vld = '1') then
					alg_data_wr					<= '1';
					alg_data_wr_data			<=	x"B" & lut_ram_128_cnt & lut_ram_128_data(15) & lut_ram_128_addr  & lut_ram_128_data;
				else
					if(one_time_end_d1 = '1' and pm_data_store_en = '1') then
						alg_data_wr					<= '1';
						alg_data_wr_data			<=	x"C0" & dac_state & min_cnt & "0" & DAC_set_addr & x"0" & min_dac;
					else
						alg_data_wr					<= '0';
					end if;
				end if;
			end if;
		end if;
	end if;
end process;

min_set_result		<= dac_state & min_dac;
min_set_result_en	<= one_time_end_d1;
			
process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		min_dac				<= (others => '0');
		min_cnt				<= (others => '0');
		one_time_end_d1	<= '0';
		dac_state			<= x"0";
	elsif rising_edge(sys_clk_80M) then
		one_time_end_d1	<= one_time_end;
		if(use_8apd = '0') then
			if(use_4apd = '0') then
				min_cnt	<= min_cnt0;
				min_dac	<= min_dac0;
				dac_state<= x"1";
			else	---default is APD 2
				min_cnt	<= min_cnt1;
				min_dac	<= min_dac1;
			end if;
		else
			if(min_cnt0 < 3 and min_cnt1 < 3) then
				--当APD计数值小于3的时候，根据DAC的电压值进行筛选，优先选择正电压 其次选择负电压，同为正电压或负电压时，优先选择离0电压最近的DAC值
				if(min_dac0(11) = '1' and min_dac1(11) = '1') then
					--当前DAC值同为正时，选择值小的DAC
					if(min_dac0 < min_dac1) then
						min_cnt	<= min_cnt0;
						min_dac	<= min_dac0;
						dac_state<= x"1";
					else
						min_cnt	<= min_cnt1;
						min_dac	<= min_dac1;
						dac_state<= x"9";
					end if;
				elsif(min_dac0(11) = '0' and min_dac1(11) = '0') then
					--当前DAC值同为负时，选择值大的DAC
					if(min_dac0 > min_dac1) then
						min_cnt	<= min_cnt0;
						min_dac	<= min_dac0;
						dac_state<= x"2";
					else
						min_cnt	<= min_cnt1;
						min_dac	<= min_dac1;
						dac_state<= x"A";
					end if;
				elsif(min_dac0(11) = '1' and min_dac1(11) = '0') then
					--选择正电压，新的最小值为正的，旧的为负的
					min_cnt	<= min_cnt0;
					min_dac	<= min_dac0;
					dac_state<= x"3";
				else
					--选择正电压，旧的最小值为正的，新的为负的
					min_cnt	<= min_cnt1;
					min_dac	<= min_dac1;
					dac_state<= x"B";
				end if;
			else
				if(min_cnt0 <= min_dac1) then
					min_cnt	<= min_cnt0;
					min_dac	<= min_dac0;
					dac_state<= x"4";
				else
					min_cnt	<= min_cnt1;
					min_dac	<= min_dac1;
					dac_state<= x"C";
				end if;
			end if;
		end if;
	end if;
end process;
---APD计数处理，稳相一次的开始，清零最小计数
---稳相期间，每一个wait_finish的上升沿更新最小的APD计数及其DAC值

process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		min_cnt0				<= (others => '1');
		min_dac0				<= (others => '0');
		apd0_cnt_reg_0		<= (others => '0');
		apd0_cnt_reg_1		<= (others => '0');
		dac0_set_data_pre	<= (others => '0');
--		min_set_result_en	<= '0';
	elsif rising_edge(sys_clk_80M) then
--		min_set_result_en	<= one_time_end;
		if(wait_finish_d1 = '1' and wait_dac_cnt > 0 and chopper_ctrl = '1') then ---10 counter
			if((wait_dac_cnt > 4 and use_8apd = '0') or use_8apd = '1') then
				apd0_cnt_reg_0		<= apd_cnt_reg(0);
				apd0_cnt_reg_1		<= apd0_cnt_reg_0;
				dac0_set_data_pre	<= dac_set_data;
			end if;
			if((wait_dac_cnt > 7 and use_8apd = '1') or (wait_dac_cnt > 3 and use_8apd = '1')) then
				if(apd0_cnt_reg_sum < 3 and apd0_cnt_reg_sum < 3) then
				--当APD计数值小于3的时候，根据DAC的电压值进行筛选，优先选择正电压 其次选择负电压，同为正电压或负电压时，优先选择离0电压最近的DAC值
					if(dac0_set_data_pre(11) = '1' and min_dac0(11) = '1') then
						--当前DAC值同为正时，选择值小的DAC
						if(dac0_set_data_pre < min_dac0) then
							min_cnt0	<= apd0_cnt_reg_sum;
							min_dac0	<= dac0_set_data_pre;
						else
							null;
						end if;
					elsif(dac0_set_data_pre(11) = '0' and min_dac0(11) = '0') then
						--当前DAC值同为负时，选择值大的DAC
						if(dac0_set_data_pre > min_dac0) then
							min_cnt0	<= apd0_cnt_reg_sum;
							min_dac0	<= dac0_set_data_pre;
						else
							null;
						end if;
					elsif(dac0_set_data_pre(11) = '1' and min_dac0(11) = '0') then
						--选择正电压，新的最小值为正的，旧的为负的
						min_cnt0	<= apd0_cnt_reg_sum;
						min_dac0	<= dac0_set_data_pre;
					else
						--选择正电压，旧的最小值为正的，新的为负的
						null;
					end if;
				else
					if(apd0_cnt_reg_sum <= min_cnt0) then
						min_cnt0	<= apd0_cnt_reg_sum;
						min_dac0	<= dac0_set_data_pre;
					end if;
				end if;
			end if;
		elsif(one_time_end_d1 = '1') then
			min_cnt0			<= (others => '1');
		elsif(chopper_ctrl = '0') then
			min_cnt0				<= (others => '1');
			min_dac0				<= (others => '0');
			apd0_cnt_reg_0		<= (others => '0');
			apd0_cnt_reg_1		<= (others => '0');
			dac0_set_data_pre	<= (others => '0');
		end if;
	end if;
end process;

---对最近的三个计数做和
process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		apd0_cnt_reg_sum	<= (others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(wait_finish_reg = '1') then
			apd0_cnt_reg_sum 	<= ("00"&apd_cnt_reg(0)) + ("00"&apd0_cnt_reg_0) + ("00"&apd0_cnt_reg_1);
		end if;
	end if;
end process;

process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		min_cnt1				<= (others => '1');
		min_dac1				<= (others => '0');
		apd1_cnt_reg_0		<= (others => '0');
		apd1_cnt_reg_1		<= (others => '0');
		dac1_set_data_pre	<= (others => '0');
--		min_set_result_en	<= '0';
	elsif rising_edge(sys_clk_80M) then
--		min_set_result_en	<= one_time_end;
		if(wait_finish_d1 = '1' and wait_dac_cnt > 0 and chopper_ctrl = '1') then ---10 counter
			if((wait_dac_cnt > 4 and use_8apd = '0') or use_8apd = '1') then
				apd1_cnt_reg_0		<= apd_cnt_reg(1);
				apd1_cnt_reg_1		<= apd1_cnt_reg_0;
				dac1_set_data_pre	<= dac_set_data;
			end if;
			if((wait_dac_cnt > 7 and use_8apd = '1') or (wait_dac_cnt > 3 and use_8apd = '1')) then
				if(apd1_cnt_reg_sum < 3 and apd1_cnt_reg_sum < 3) then
				--当APD计数值小于3的时候，根据DAC的电压值进行筛选，优先选择正电压 其次选择负电压，同为正电压或负电压时，优先选择离0电压最近的DAC值
					if(dac1_set_data_pre(11) = '1' and min_dac1(11) = '1') then
						--当前DAC值同为正时，选择值小的DAC
						if(dac1_set_data_pre < min_dac1) then
							min_cnt1	<= apd1_cnt_reg_sum;
							min_dac1	<= dac1_set_data_pre;
						else
							null;
						end if;
					elsif(dac1_set_data_pre(11) = '0' and min_dac1(11) = '0') then
						--当前DAC值同为负时，选择值大的DAC
						if(dac1_set_data_pre > min_dac1) then
							min_cnt1	<= apd1_cnt_reg_sum;
							min_dac1	<= dac1_set_data_pre;
						else
							null;
						end if;
					elsif(dac1_set_data_pre(11) = '1' and min_dac1(11) = '0') then
						--选择正电压，新的最小值为正的，旧的为负的
						min_cnt1	<= apd1_cnt_reg_sum;
						min_dac1	<= dac1_set_data_pre;
					else
						--选择正电压，旧的最小值为正的，新的为负的
						null;
					end if;
				else
					if(apd1_cnt_reg_sum <= min_cnt1) then
						min_cnt1	<= apd1_cnt_reg_sum;
						min_dac1	<= dac1_set_data_pre;
					end if;
				end if;
			end if;
		elsif(one_time_end_d1 = '1') then
			min_cnt1			<= (others => '1');
		elsif(chopper_ctrl = '0') then
			min_cnt1				<= (others => '1');
			min_dac1				<= (others => '0');
			apd1_cnt_reg_0		<= (others => '0');
			apd1_cnt_reg_1		<= (others => '0');
			dac1_set_data_pre	<= (others => '0');
		end if;
	end if;
end process;

---对最近的三个计数做和
process(sys_clk_80M,sys_rst_n)
begin
	if(sys_rst_n = '0') then
		apd1_cnt_reg_sum	<= (others => '0');
	elsif rising_edge(sys_clk_80M) then
		if(wait_finish_reg = '1') then
			apd1_cnt_reg_sum 	<= ("00"&apd_cnt_reg(1)) + ("00"&apd1_cnt_reg_0) + ("00"&apd1_cnt_reg_1);
		end if;
	end if;
end process;

end Behavioral;
