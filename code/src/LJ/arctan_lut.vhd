----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:20:01 11/26/2014 
-- Design Name: 
-- Module Name:    arctan_lut - Behavioral 
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
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library ieee; 
use ieee.std_logic_1164.all; 
--use ieee.std_logic_arith.all; 
--use ieee.std_logic_signed.all; 
 use ieee.std_logic_unsigned.all;
entity atan_lut is 
	port(
		sys_clk 	: in std_logic;  -- 时钟 
		sys_rst 	: in std_logic; -- 复位 
		start 	: in std_logic; -- 开始信号 
		
		tan_adj_voltage		: in std_logic_vector(11 downto 0);--offset_voltage
		offset_voltage		: in std_logic_vector(11 downto 0);--offset_voltage
		half_wave_voltage	: in std_logic_vector(11 downto 0);--half_wave_voltage
		chnl_cnt_reg0_out	: in std_logic_vector(9 downto 0);--apd 1 count 0
		chnl_cnt_reg1_out	: in std_logic_vector(9 downto 0);--apd 2 count 0
		chnl_cnt_reg2_out	: in std_logic_vector(9 downto 0);--apd 1 count 1
		chnl_cnt_reg3_out	: in std_logic_vector(9 downto 0);--apd 2 count 1
		chnl_cnt_reg4_out	: in std_logic_vector(9 downto 0);--apd 1 count 2
		chnl_cnt_reg5_out	: in std_logic_vector(9 downto 0);--apd 2 count 2
		chnl_cnt_reg6_out	: in std_logic_vector(9 downto 0);--apd 1 count 3
		chnl_cnt_reg7_out	: in std_logic_vector(9 downto 0);--apd 2 count 3

--		count1	: in std_logic_vector(9 downto 0); --纯小数
--		count2	: in std_logic_vector(9 downto 0); --纯小数
--		count3	: in std_logic_vector(9 downto 0); --纯小数
--		count4	: in std_logic_vector(9 downto 0); --纯小数
	-----128 lut?-------------------------------------	
		--lut_wr_en: in std_logic; -- LUT查找表写使能 
		lut_ram_rd_addr	: out std_logic_vector(9 downto 0); 
		lut_ram_rd_data	: in std_logic_vector(15 downto 0); 
		------lut_ram 128------------------------
		lut_ram_128_addr : in STD_LOGIC_vector(6 downto 0);
		lut_ram_128_data : out STD_LOGIC_vector(11 downto 0); 
	
	-----tan ram  reference-------------------------------------
		use_8apd     : in std_logic;
		use_4apd     : in std_logic;
		result_ok: out std_logic; 
		DAC_set_addr   : out std_logic_vector(6 downto 0);
		DAC_set_result : out std_logic_vector(11 downto 0)
	); 
end entity; 
 
architecture Behavioral of atan_lut is 
	-- 除法器 
	------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
component divider_10
	port (
	clk: in std_logic;
	rfd: out std_logic;
	dividend: in std_logic_vector(19 downto 0);
	divisor: in std_logic_vector(19 downto 0);
	quotient: out std_logic_vector(19 downto 0);
	fractional: out std_logic_vector(9 downto 0));
end component;

------ End COMPONENT Declaration ------------
----------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
----------- 
COMPONENT lut_ram_128
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	 clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
  );
END COMPONENT;
--COMPONENT lut_ram
--  PORT (
--    clka : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--    clkb : IN STD_LOGIC;
--    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
--    doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
--  );
--  COMPONENT lut_ram
--  PORT (
--    clka : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
--    clkb : IN STD_LOGIC;
--    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
--    doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
--  );
--END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------
	signal count1 : std_logic_vector(9 downto 0) := "0111110100";
	signal count2 : std_logic_vector(9 downto 0) := "1111101000";
	signal count3 : std_logic_vector(9 downto 0) := "0011111010";
	signal count4 : std_logic_vector(9 downto 0)	:= "0111110100";
	
	signal rfd : std_logic;  -- ready for data 
	signal start_rising : std_logic;  
	signal start_1d : std_logic;  
	signal dividend: std_logic_vector(19 downto 0);
	signal divisor : std_logic_vector(19 downto 0);
	signal quotient: std_logic_vector(19 downto 0);
	signal fractional: std_logic_vector(9 downto 0);
	signal tan_x_quotient_add1: std_logic_vector(9 downto 0);
	signal tan_x_quotient_sub1: std_logic_vector(9 downto 0);
	
	signal sign_of_sin : std_logic;  -- sin x的符号 
	signal sign_of_cos : std_logic;  -- cos x的符号  
	signal sin_x : std_logic_vector(9 downto 0); -------确认 9 or 10   
	signal cos_x : std_logic_vector(9 downto 0);
	
	signal tan_x_large_1 : std_logic;  -- tan x 大于1  
	signal tan_x_quotient : std_logic_vector(9 downto 0);
	signal tan_x_fractional : std_logic_vector(9 downto 0);
--	signal tan_y_quotient : std_logic_vector(9 downto 0);
--	signal tan_y_fractional : std_logic_vector(9 downto 0);
	
	signal final_fractional: std_logic_vector(9 downto 0);
	signal artan_pitov: std_logic_vector(8 downto 0);
   
--	signal lut_ram_rd_addr : std_logic_vector(9 downto 0); -- 
--	signal lut_ram_rd_data : std_logic_vector(11 downto 0); --  
	signal dac_ft		: std_logic_vector(2 downto 0);
	signal lut_ram_128_addra		: std_logic_vector(6 downto 0);
--	signal lut_wr_en :std_logic; --test wire
	
	signal lut_ram_128_wen :std_logic;
	signal lut_ram_128_dina :std_logic_vector(11 downto 0) ;
--	signal lut_ram_128_douta :std_logic_vector(11 downto 0) ;
	signal result_ok_reg :std_logic;
	signal DAC_set_result_ram :std_logic_vector(11 downto 0) ;
	--signal reg0_and_reg1 : std_logic_vector(10 downto 0) := "00000000000" ; -- := 连续使用	
	signal cnt : integer range 0 to 511; 
--signal cnt : std_logic_vector(8 downto 0);
begin 
 
-- 端口映射 
-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
divider_10_inst : divider_10
		port map (
			clk => sys_clk,
			rfd => rfd,
			dividend => dividend,
			divisor => divisor,
			quotient => quotient,
			fractional => fractional
		);
-- INST_TAG_END ------ End INSTANTIATION Template ------------ 
 
-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
Inst_lut_ram_128 : lut_ram_128
  PORT MAP (
    clka 	=> sys_clk,
    wea(0)		=> lut_ram_128_wen,
    addra 	=> lut_ram_128_addra,
    dina 	=> lut_ram_128_dina,
--    douta	=> lut_ram_128_douta,
    clkb 	=> sys_clk,
	 addrb 	=> lut_ram_128_addr,
    doutb	=> lut_ram_128_data
  );
  
--Inst_lut_ram : lut_ram
--  PORT MAP (
--    clka => sys_clk,
--    wea(0) => lut_wr_en, --wea 类型
--    addra => "0000000000",
--    dina => "000000000000",
--    clkb => sys_clk,
--    addrb => lut_ram_rd_addr,
--    doutb => lut_ram_rd_data
--  );	 
	---one beat delay
start_rising_process : process(sys_clk,sys_rst)
begin
	if(sys_rst = '1') then
		start_1d	<=	'0';
	elsif rising_edge(sys_clk) then
		start_1d	<=	start;
--	else 
--		start_1d   <= start_1d;
	end if;
end process;

start_rising  <=  (not start_1d) and start;

cnt_process :process(sys_clk, sys_rst) 
	begin
	if(sys_rst = '1') then
		cnt	<= 500;
	elsif rising_edge(sys_clk) then 
		if(start_rising = '1') then
				--cnt	<= cnt + '1';
				cnt	<= 0;
		--elsif(cnt < 100) then
		elsif(cnt < 310) then
				cnt	<= cnt + 1;
		else
				cnt  <= cnt;
		end if;
	end if;
end process;
	
	-------------lut_ram_addr--------------
	result_ok	<= result_ok_reg;
	DAC_set_addr <= lut_ram_128_addra;
	DAC_set_result <= DAC_set_result_ram;
	lut_ram_128_wen	<= result_ok_reg;
	lut_ram_128_dina	<= DAC_set_result_ram;
	process(sys_clk, sys_rst) 
	begin
	if(sys_rst = '1') then
		lut_ram_128_addra	<= (others => '0');
	elsif sys_clk'event and sys_clk = '1' then 
		if(lut_ram_128_wen = '1') then
				lut_ram_128_addra	<= lut_ram_128_addra+1; --if（wen）
		else
				lut_ram_128_addra  <= lut_ram_128_addra;
		end if;
	end if;
	end process;
	----1------
	--判断count3， count1大小
	--判断count4， count2大小
	process(count3, count1) begin
		if(count3 > count1) then--sin x is +
			sign_of_sin	<= '1';
		else
			sign_of_sin	<= '0';
		end if;
	end process;
	
	process(count4, count2) begin
		if(count4 > count2) then--sin x is +
			sign_of_cos	<= '1';
		else
			sign_of_cos	<= '0';
		end if;
	end process;
	
	----2------
	--计算sin x = abs(count3 - count1)
	--计算cos x = abs(count4 - count2)
	process(sys_clk, sys_rst) begin
		if(sys_rst = '1') then
			sin_x	<= (others => '0');
		elsif sys_clk'event and sys_clk = '1' then 
				if(sign_of_sin = '1') then--sin x is +
					sin_x	<= count3 - count1;
				else
					sin_x	<= count1 - count3;
				end if;
		end if;
	end process;
	
	process(sys_clk, sys_rst) begin
		if(sys_rst = '1') then
			cos_x	<= (others => '0');
		elsif sys_clk'event and sys_clk = '1' then 
				if(sign_of_cos = '1') then--sin x is +
					cos_x	<= count4 - count2;
				else
					cos_x	<= count2 - count4;
				end if;
		end if;
	end process;
	
	----3------
	--计算tan x = sin x / cos x
	--判断tan x 大小，
	process(sys_clk, sys_rst) begin
		if(sys_rst = '1') then
			tan_x_large_1	<= '0';
		elsif sys_clk'event and sys_clk = '1' then 
				if(sin_x > cos_x) then--tan x is large than 1
					tan_x_large_1	<= '1';
				else
					tan_x_large_1	<= '0';
				end if;
		end if;
	end process;
	--等待除法器OK
	process(sys_clk, sys_rst) begin
		if(sys_rst = '1') then
			count1	<= (others => '0');
			count2	<= (others => '0');
			count3	<= (others => '0');
			count4	<= (others => '0');
		elsif sys_clk'event and sys_clk = '1' then 
				if (use_8apd = '1' and use_4apd = '0') then
					if(cnt = 48)  then--select divido
						count1	<= fractional;
					elsif(cnt = 98) then
						count2   <= fractional;
					elsif(cnt = 148) then
						count3   <= fractional;
					elsif(cnt = 198) then
						count4   <= fractional;
					end if;
				ELSIF (use_8apd = '0' and use_4apd = '1') then
						count1 <= chnl_cnt_reg0_out;
						count2 <= chnl_cnt_reg2_out;
						count3 <= chnl_cnt_reg4_out;
						count4 <= chnl_cnt_reg6_out;
				elsif (use_8apd = '0' and use_4apd = '0') then
						count1 <= chnl_cnt_reg1_out;
						count2 <= chnl_cnt_reg3_out;
						count3 <= chnl_cnt_reg5_out;
						count4 <= chnl_cnt_reg7_out;
				end if;
		end if;
	end process;
	
	process(sys_clk, sys_rst) begin
		if(sys_rst = '1') then
			tan_x_quotient	<= (others => '0');
			tan_x_fractional	<= (others => '0');
		elsif sys_clk'event and sys_clk = '1' then 
				if(cnt = 248) then--select dividor
					tan_x_quotient	<= quotient(9 downto 0);
					tan_x_fractional	<= fractional;
				end if;
		end if;
	end process;
	
	----4------
	--如果tan x大于1，计算 tan_y = (tan_x - 1)/(1+tan_x)
	process(sys_clk, sys_rst) begin
		if(sys_rst = '1') then
			tan_x_quotient_add1	<= (others => '0');
			tan_x_quotient_sub1	<= (others => '0');
		elsif sys_clk'event and sys_clk = '1' then 
				if(cnt = 249 and tan_x_large_1 = '1') then--select dividor
					tan_x_quotient_add1	<= tan_x_quotient + 1;
					tan_x_quotient_sub1	<= tan_x_quotient - 1;
				end if;
		end if;
	end process;
	--等待除法器OK
	--reg0_and_reg1 <= chnl_cnt_reg0_out+chnl_cnt_reg1_out;
	process(sys_clk, sys_rst) begin
		if(sys_rst = '1') then
			dividend	<= (others => '0');
			diviSor		<= (others => '0');
		elsif sys_clk'event and sys_clk = '1' then 
				if(cnt = 4) then--select dividor
					dividend	<= "0000000000" & chnl_cnt_reg0_out; 
					diviSor		<= "000000000" & (('0'&chnl_cnt_reg0_out)+('0'&chnl_cnt_reg1_out));
				elsif (cnt = 50) then--select dividor
					dividend	<= "0000000000" & chnl_cnt_reg2_out; 
					diviSor		<= "000000000" & (('0'&chnl_cnt_reg2_out)+('0'&chnl_cnt_reg3_out));
				elsif (cnt = 100) then--select dividor
					dividend	<= "0000000000" & chnl_cnt_reg4_out; 
					diviSor		<= "000000000" & (('0'&chnl_cnt_reg4_out)+('0'&chnl_cnt_reg5_out));
				elsif (cnt = 150) then--select dividor
					dividend	<= "0000000000" & chnl_cnt_reg6_out; 
					diviSor		<= "000000000" & (('0'&chnl_cnt_reg6_out)+('0'&chnl_cnt_reg7_out));
				elsif(cnt = 200) then--select dividor
					
					dividend	<= "0000000000" & sin_x; --为什么是20位位宽
					diviSor		<= "0000000000" & cos_x;
				elsif(cnt = 250) then--select dividor
						dividend	<= tan_x_quotient_sub1 & tan_x_fractional; ----整数 部分10位 小数部分 10位
						diviSor		<= tan_x_quotient_add1 & tan_x_fractional;
				else
						null;
				end if;
		end if;
	end process;
	
	----5------
	--如果tan x大于1 根据 y 查找lut ram
	--如果tan x小于1 根据 tan x 查找lut ram
	process(sys_clk, sys_rst) begin
		if(sys_rst = '1') then
			final_fractional	<= (others => '0');
		elsif sys_clk'event and sys_clk = '1' then 
				if(cnt = 295) then--select fractional
					if(tan_x_large_1 = '1') then--tan x is 45 + alpha
						final_fractional	<= fractional;
					else--tan x is alpha
						final_fractional	<= tan_x_fractional;
					end if;
				end if;
		end if;
	end process;
-------------确认ram的形式 简单双端口ram ？ 完全双端口ram	
	process(sys_clk, sys_rst) begin
		if(sys_rst = '1') then
			lut_ram_rd_addr			<= (others => '0');
			artan_pitov					<= (others => '0');
		elsif sys_clk'event and sys_clk = '1' then 
				if(cnt = 296) then--select fractional
					lut_ram_rd_addr 	<= final_fractional;
				end if;
				
				artan_pitov					<=lut_ram_rd_data(8 downto 0);
--				if(cnt = 297)then
--					
--				end if;
		end if;
	end process;
	-------------确认 存储的tanx的形式 
	-------------是否是0-pi/4
	----6------
	--根据sin x, cos x的符号计算出比例值
	--sin x > 0 cos x > 0 tan_x_large_1 = 0
	--0 < x < pi/4
	--sin x > 0 cos x > 0 tan_x_large_1 = 1
	--0 < x < pi/4
	dac_ft <= sign_of_sin & sign_of_cos & tan_x_large_1;
	alt_result: process(sys_clk, sys_rst) begin
		if(sys_rst = '1') then
			DAC_set_result_ram   	<= (others => '0');
			result_ok_reg   <='0';
		elsif sys_clk'event and sys_clk = '1' then 
				if(cnt = 300) then
					case dac_ft is
						when"110" => result_ok_reg <= '1';					
										 DAC_set_result_ram <="000"&artan_pitov;
						when"010" => result_ok_reg <= '1';					
										 DAC_set_result_ram <="100"&artan_pitov;
						when"100" => result_ok_reg <= '1';					
										 DAC_set_result_ram <="010"&artan_pitov;
						when"000" => result_ok_reg <= '1';					
										 DAC_set_result_ram <="110"&artan_pitov;
						when"111" => result_ok_reg <= '1';					
										 DAC_set_result_ram <="001"&artan_pitov;
						when"011" => result_ok_reg <= '1';					
										 DAC_set_result_ram <="101"&artan_pitov;
						when"101" => result_ok_reg <= '1';					
										 DAC_set_result_ram <="011"&artan_pitov;
						when"001" => result_ok_reg <= '1';					
										 DAC_set_result_ram <="111"&artan_pitov;
						WHEN OTHERS => NULL;
					end case;
				else
					result_ok_reg   <='0';
				end if;
		end if;
	end process;
end Behavioral; 
	

