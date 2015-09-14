----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:52:58 10/28/2014 
-- Design Name: 
-- Module Name:    DPS_control - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity DPS_control is
 port(
		sys_clk_80M        : in  std_logic;--80MHz
		sys_clk_250M      : in  std_logic;--250MHz
      sys_rst_n       		 : in  std_logic;
	  
	  exp_running				:  in std_logic;--80M clock domain
	  Alice_H_Bob_L			:  in std_logic;--80M clock domain
	  gps_pulse    			:  in std_logic;--80M clock domain
	  
	  single_mode 			:  in std_logic;--80M clock domain
	  
	  GPS_period_cnt			: in	std_logic_vector(31 downto 0);--bit 31: 1 use intenal gps; 0 use external gps
	  
	  DPS_send_PM_dly_cnt			: in	std_logic_vector(7 downto 0);
	  DPS_send_AM_dly_cnt			: in	std_logic_vector(7 downto 0);
	  DPS_syn_dly_cnt			: in	std_logic_vector(11 downto 0);
	  DPS_round_cnt			: in	std_logic_vector(15 downto 0);
	  DPS_chopper_cnt			: in	std_logic_vector(3 downto 0);
	  syn_pulse_cnt			: out	std_logic_vector(31 downto 0);
	  
	  set_send_enable_cnt	: in	std_logic_vector(31 downto 0);--for Alice
	  set_send_disable_cnt	: in	std_logic_vector(31 downto 0);--for Alice
	  set_chopper_enable_cnt: in	std_logic_vector(31 downto 0);--for Bob
	  set_chopper_disable_cnt: in	std_logic_vector(31 downto 0);--for Bob
	  
	  APD_tdc_en				:  out std_logic;--80M clock domain
	  exp_running_250M		:  out std_logic;--250M clock domain
	  GPS_pulse_int			:  out std_logic;--80M clock domain
	  GPS_pulse_int_active	:  out std_logic;--80M clock domain
	  send_enable_250M		:  out std_logic;--250M clock domain
	  send_enable_80M			:  out std_logic;--250M clock domain
	  
	  chopper_ctrl				:  out std_logic;--80M clock domain
	  chopper_ctrl_80M		:  out std_logic;--80M clock domain
--	  send_en_AM_p				:  out std_logic;--250M clock domain
--	  send_en_AM_n				:  out std_logic;--250M clock domain
	  syn_light_ext			:  in std_logic;--250M clock domain
	  syn_light					:  out std_logic;--250M clock domain
	  send_en_AM				:  out std_logic;--250M clock domain
	  send_en					:  out std_logic--250M clock domain
 
	 );
end DPS_control;

architecture Behavioral of DPS_control is
	 signal  syn_light_80m_reg					: std_logic;--80M clock domain
	 signal  syn_light_80m_reg_d1				: std_logic;--80M clock domain
	 signal  syn_light_80m_reg_d2				: std_logic;--80M clock domain
	 signal  exp_running_250m_sig				: std_logic;--250M clock domain
	 signal  Alice_H_Bob_L_250m				: std_logic;--250M clock domain
	 signal  single_mode_250m 					: std_logic;--250M clock domain
	  
	 signal  GPS_period_cnt_250m				: std_logic_vector(31 downto 0);--bit 31: 1 use intenal gps; 0 use external gps
	  
	 signal  DPS_send_PM_dly_cnt_250m		: std_logic_vector(7 downto 0);
	 signal  DPS_send_AM_dly_cnt_250m		: std_logic_vector(7 downto 0);
	 signal  DPS_syn_dly_cnt_250m				: std_logic_vector(11 downto 0);
	 signal  DPS_round_cnt_250m				: std_logic_vector(15 downto 0);
	 signal  DPS_chopper_cnt_250m				: std_logic_vector(3 downto 0);
	  
	 signal  set_send_enable_cnt_250m		: std_logic_vector(31 downto 0);--for Alice
	 signal  set_send_disable_cnt_250m		: std_logic_vector(31 downto 0);--for Alice
	 signal  set_chopper_enable_cnt_250m	: std_logic_vector(31 downto 0);--for Bob
	 signal  set_chopper_disable_cnt_250m	: std_logic_vector(31 downto 0);--for Bob
	  

	signal exp_running_reg 	: std_logic;
	signal exp_running_d1 : std_logic;
	
	signal chopper_ctrl_reg	: std_logic;
	signal chopper_ctrl_cnt	: std_logic_vector(3 downto 0);
	signal chopper_time_cnt	: std_logic_vector(30 downto 0);
	
	signal syn_light_ext_250m	: std_logic;
	signal syn_light_reg			: std_logic;
	signal syn_light_cnt			: std_logic_vector(15 downto 0);
	
	signal send_enable	 			: std_logic;
	
	signal send_en_AM_reg 			: std_logic;
	signal send_en_PM_reg 			: std_logic;
	signal pm_steady_enable			: std_logic;
	
	signal chopper_ctrl_reg_d1			: std_logic;
	signal is_send_first_syn			: std_logic;
	signal is_send_first_syn_r			: std_logic;
	signal is_send_first_syn_d1		: std_logic;
	signal detect_first_syn_en			: std_logic;
	
	signal DPS_round_cnt_AM		: std_logic_vector(15 downto 0);
	signal DPS_round_cnt_AM_sub64	: std_logic_vector(15 downto 0);--send enable last 128*2ns = 1/250M * 64
	
	signal DPS_round_cnt_PM		: std_logic_vector(15 downto 0);
	signal DPS_round_cnt_PM_sub64	: std_logic_vector(15 downto 0);--send enable last 128*2ns = 1/250M * 64
	
	
	signal gps_count32			: std_logic_vector(30 downto 0):=(others => '0');--gps period control count
	signal syn_pulse_cnt_reg	: std_logic_vector(31 downto 0):=(others => '0');--һ��ʵ����ͬ���źŵĸ���
	
	
begin

--1 ��80M�ź�ͬ����250M
  exp_running_250M	<= exp_running_250M_sig;
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			exp_running_250m_sig			<= '0';
			Alice_H_Bob_L_250m			<= '0';
			single_mode_250m 				<= '0';
			syn_light_ext_250m			<= '0';
			
			GPS_period_cnt_250m			<= (others => '0');
			
--			DPS_send_PM_dly_cnt_250m	<= (others => '0');
			DPS_send_AM_dly_cnt_250m	<= (others => '0');
			DPS_syn_dly_cnt_250m			<= (others => '0');
			DPS_round_cnt_250m			<= (others => '0');
			DPS_chopper_cnt_250m			<= (others => '0');
			
			set_send_enable_cnt_250m		<= (others => '0');
			set_send_disable_cnt_250m		<= (others => '0');
			set_chopper_enable_cnt_250m	<= (others => '0');	
			set_chopper_disable_cnt_250m	<= (others => '0');
			
			DPS_round_cnt_AM	<= x"0000";--100us is sys_clk_250M clock cycle
			DPS_round_cnt_PM	<= x"0000";--100us is sys_clk_250M clock cycle
			DPS_round_cnt_AM_sub64	<= (others => '0');
			DPS_round_cnt_PM_sub64	<= (others => '0');
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				exp_running_250m_sig			<= exp_running;
				Alice_H_Bob_L_250m			<= Alice_H_Bob_L;
				single_mode_250m 				<= single_mode;
				GPS_period_cnt_250m			<= GPS_period_cnt;
				syn_light_ext_250m			<= syn_light_ext;
				
--				DPS_send_PM_dly_cnt_250m	<= DPS_send_PM_dly_cnt;--x"FF";
				DPS_send_AM_dly_cnt_250m	<= DPS_send_AM_dly_cnt;--x"FF";
				DPS_syn_dly_cnt_250m			<= DPS_syn_dly_cnt;
				DPS_round_cnt_250m			<= DPS_round_cnt;--x"61A7";
				
				DPS_round_cnt_AM			<= DPS_round_cnt_250m - DPS_send_AM_dly_cnt_250m;
				DPS_round_cnt_PM			<= DPS_round_cnt_250m - 1000;
				
				DPS_round_cnt_AM_sub64	<= DPS_round_cnt_AM - 2000;
				DPS_round_cnt_PM_sub64	<= DPS_round_cnt_PM - 64;--total is 128 pulse one clock cycle is 2 pulse 
				
				set_send_enable_cnt_250m		<= set_send_enable_cnt;
				set_send_disable_cnt_250m		<= set_send_disable_cnt;
				set_chopper_enable_cnt_250m	<= set_chopper_enable_cnt;
				set_chopper_disable_cnt_250m	<= set_chopper_disable_cnt;
			end if;
		end if;
  end process;
--2 ���п����źŵĲ���������250M
--a �������ؼ�����
  ---generate internal gps pulse 
  process (sys_clk_250M)
	begin  
		if (sys_clk_250M'event and sys_clk_250M = '1') then
			if (exp_running_250m_sig = '1') then--ʵ���в��ܼ���
				if(is_send_first_syn_r = '1') then---ÿһ��round�����������˵�һ��ͬ�������壬�򽫽��ն˼�������1��
					if(single_mode_250m = '1') then--��ģʽ�� ͬ��������Chopper�����ط���
						chopper_time_cnt	<= set_chopper_enable_cnt_250m(30 downto 0);
					else--�ǵ�ģʽ�� ͬ��������send enable�����غ�DPS_syn_dly_cnt_250m����
						--chopper_time_cnt	<= set_send_enable_cnt_250m(30 downto 0) + DPS_syn_dly_cnt_250m;
					end if;
				else
					if(chopper_time_cnt < GPS_period_cnt_250m(30 downto 0)) then
						chopper_time_cnt	<= chopper_time_cnt + 1;
					else
						chopper_time_cnt	<= (others => '0');
					end if;
				end if;
			else
				chopper_time_cnt	<= (others => '0');
			end if;
		end if;
	end process;
--b �������ؼ���������Chopper�ź��뷢��ʹ���ź�
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			chopper_ctrl_reg		<= '0';
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				if(chopper_time_cnt >= set_chopper_enable_cnt_250m and chopper_time_cnt < set_chopper_disable_cnt_250m) then
					chopper_ctrl_reg		<= '1';
				else
					chopper_ctrl_reg		<= '0';
				end if;
			end if;
		end if;
  end process;
  
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			send_enable		<= '0';
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				if(chopper_time_cnt >= set_send_enable_cnt_250m and chopper_time_cnt < set_send_disable_cnt_250m) then
					send_enable		<= '1';
				else
					send_enable		<= '0';
				end if;
			end if;
		end if;
  end process;
  
 --�������ն˼�����ͬ��ʹ���ź�
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			detect_first_syn_en		<= '0';
			is_send_first_syn			<= '0';
			is_send_first_syn_r		<= '0';
			is_send_first_syn_d1		<= '0';
			chopper_ctrl_reg_d1		<= '0';
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
			--�����ڵ�ģʽʱ��ʹ���ⲿͬ���ź��������ؼ��
			--�����ڷǵ�ģʽʱ��ʹ��Chopper�½��غ�ĵ�һ��ͬ���ź��������ؼ��
				chopper_ctrl_reg_d1		<= chopper_ctrl_reg;
				is_send_first_syn			<= (detect_first_syn_en and syn_light_ext_250m and (not single_mode_250m)) or (syn_light_ext_250m and single_mode_250m);
				is_send_first_syn_d1		<= is_send_first_syn;
				is_send_first_syn_r		<= is_send_first_syn and (not is_send_first_syn_d1)  and (not Alice_H_Bob_L_250m);--rising edge
				if(chopper_ctrl_reg = '1' and chopper_ctrl_reg_d1 = '0') then
					detect_first_syn_en		<= '1';
				else
					if(syn_light_ext = '1') then
						detect_first_syn_en		<= '0';
					else
						null;
					end if;
				end if;
			end if;
		end if;
  end process;

   GPS_pulse_int <= '0';
	GPS_pulse_int_active	<= GPS_period_cnt(31);
	
	----------------------------------------------------------------------------
	---250M clock
	----------------------------------------------------------------------------
	 ---Alice generate syn light 250M clock
	 --����ͬ���źż�����
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			syn_light_cnt		<= (others => '1');
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				if(exp_running_250m_sig = '1') then
					if(syn_light_cnt < DPS_round_cnt_250m) then
						syn_light_cnt	<= syn_light_cnt + 1;
					else
						if(send_enable = '1') then
							syn_light_cnt	<= (others => '0');	
						end if;		
					end if;
				else
					syn_light_cnt	<= (others => '1');
				end if;
			end if;
		end if;
  end process;
  
  --syn light has 16 sys_clk_250M clock width
  process(syn_light_cnt, DPS_syn_dly_cnt_250m, send_enable, single_mode_250m, chopper_ctrl_reg) 
  begin --��ģʽ��Chopper�ź���Ϊͬ���ź�
		if(single_mode_250m = '1') then
			syn_light_reg	<= chopper_ctrl_reg; 
			--�ǵ�ģʽ�¸���ͬ�����������ͬ���ź�
		elsif(syn_light_cnt(15 downto 4) = DPS_syn_dly_cnt_250m and send_enable = '1') then
			syn_light_reg	<= '1';
		else
			syn_light_reg	<= '0';
		end if;
  end process;
  ---����AMʹ���źţ�AMʹ��ʱ�����PMʹ��ʱ�䣬����˽��ն˾���Ч
  process(syn_light_cnt, DPS_round_cnt_AM, DPS_round_cnt_AM_sub64) 
  begin 
		if(syn_light_cnt < DPS_round_cnt_AM and syn_light_cnt >= DPS_round_cnt_AM_sub64) then
			send_en_AM_reg	<= '1'; 
		else
			send_en_AM_reg	<= '0';
		end if;
  end process;
  --����PMʹ���źţ�1��ʹ�ܳ���128��ʱ��, ֻ�ڷ������Ч
  process(syn_light_cnt, DPS_round_cnt_PM, DPS_round_cnt_PM_sub64, Alice_H_Bob_L_250m) 
  begin 
		if(syn_light_cnt <= DPS_round_cnt_PM and syn_light_cnt > DPS_round_cnt_PM_sub64 and Alice_H_Bob_L_250m = '1') then
			send_en_PM_reg	<= '1'; 
		else
			send_en_PM_reg	<= '0';
		end if;
  end process;
  
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			syn_light				<= '0';
			send_en					<= '0';
			send_en_AM				<= '0';
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				syn_light				<= syn_light_reg;
				send_en					<= send_en_PM_reg;
				send_en_AM				<= send_en_AM_reg;
			end if;
		end if;
  end process;
	send_enable_250M	<= send_enable;--����ʹ���źţ����ڸ��ٴ��нӿڿ���500M�źŵ������ʽ
	
--3 �����ź�ͬ����80M
  
  process(sys_clk_80M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			APD_tdc_en			<= '0';
			send_enable_80M	<= '0';
		else
			if(sys_clk_80M'event and sys_clk_80M = '1') then
				APD_tdc_en			<= send_en_AM_reg;--AM�ź���Чʱ���PM��Чʱ���ʹ�ø��źſ��ƽ��ն�APD�ź�ʱ���������
				send_enable_80M	<= send_enable;--����ʹ�ܣ����ź����ڷ���˿���AM DAC��ѹ����ʹ��
			end if;
		end if;
  end process;
  
  
  process(sys_clk_80M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			chopper_ctrl		<= '0';
		else
			if(sys_clk_80M'event and sys_clk_80M = '1') then
				if(Alice_H_Bob_L = '1') then--�������Ҫ Chopper �������������ػ��½��ؿ���AM DAC��ѹ����
					chopper_ctrl		<= chopper_ctrl_reg;
					chopper_ctrl_80m	<= '0';
				else
					chopper_ctrl		<= chopper_ctrl_reg;
					chopper_ctrl_80m	<= chopper_ctrl_reg;---Bob do not need this signal
				end if;
			end if;
		end if;
  end process;
  process(sys_clk_80M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			exp_running_d1				<= '0';
			exp_running_reg			<= '0';
			syn_light_80m_reg			<= '0';
			syn_light_80m_reg_d1		<= '0';
			syn_light_80m_reg_d2		<= '0';
			syn_pulse_cnt_reg	<= (others => '0');
		else
			if(sys_clk_80M'event and sys_clk_80M = '1') then
				syn_light_80m_reg		<= syn_light_reg;
				syn_light_80m_reg_d1	<= syn_light_80m_reg;
				syn_light_80m_reg_d2	<= syn_light_80m_reg_d1;
				exp_running_reg	<= exp_running;
				exp_running_d1		<= exp_running_reg;
				if(exp_running_reg = '1' and exp_running_d1 = '0') then--�������Ҫ Chopper �������������ػ��½��ؿ���AM DAC��ѹ����
					syn_pulse_cnt_reg	<= (others => '0');--when start of exp, clear syn pulse count to 0				
				else
					if(syn_light_80m_reg_d2 = '0' and syn_light_80m_reg_d1 = '1') then---rising edge of syn_light
						syn_pulse_cnt_reg		<= syn_pulse_cnt_reg+1;
					end if;
				end if;
			end if;
		end if;
  end process;
  
  syn_pulse_cnt	<= syn_pulse_cnt_reg;
  
end Behavioral;

