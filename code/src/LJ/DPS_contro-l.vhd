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
--	  exp_stopping				:  in std_logic;--80M clock domain
	  gps_pulse    			:  in std_logic;--80M clock domain
	  
	  GPS_period_cnt			: in	std_logic_vector(31 downto 0);--bit 31: 1 use intenal gps; 0 use external gps
	  
	  DPS_send_PM_dly_cnt			: in	std_logic_vector(7 downto 0);
	  DPS_send_AM_dly_cnt			: in	std_logic_vector(7 downto 0);
	  DPS_syn_dly_cnt			: in	std_logic_vector(11 downto 0);
	  DPS_round_cnt			: in	std_logic_vector(15 downto 0);
	  DPS_chopper_cnt			: in	std_logic_vector(3 downto 0);
	  
	  GPS_pulse_int			:  out std_logic;--80M clock domain
	  GPS_pulse_int_active	:  out std_logic;--80M clock domain
	  PPG_start					:  out std_logic;--250M clock domain
	  syn_light					:  out std_logic;--250M clock domain
	  chopper_ctrl				:  out std_logic;--250M clock domain
	  chopper_ctrl_80M		:  out std_logic;--80M clock domain
--	  send_en_AM_p				:  out std_logic;--250M clock domain
--	  send_en_AM_n				:  out std_logic;--250M clock domain
	  send_en_AM				:  out std_logic;--250M clock domain
	  send_en					:  out std_logic--250M clock domain
 
	 );
end DPS_control;

architecture Behavioral of DPS_control is
--	signal exp_stopping_reg 	: std_logic;
	signal exp_running_reg 	: std_logic;
	signal exp_running_reg1 : std_logic;
--	signal exp_running_lch 	: std_logic;
--	signal exp_run				: std_logic;
	
	signal gps_pulse_reg 	: std_logic;
	signal gps_pulse_reg1 	: std_logic;
	signal gps_pulse_r 		: std_logic;
	
	signal chopper_ctrl_add	: std_logic;
	signal chopper_ctrl_reg	: std_logic;
	signal chopper_ctrl_d1	: std_logic;
	signal chopper_ctrl_80M_reg	: std_logic;
	signal chopper_ctrl_cnt	: std_logic_vector(3 downto 0);
	signal DPS_chopper_cnt_reg	: std_logic_vector(3 downto 0);
	
	signal syn_light_sig			: std_logic;
	signal PPG_start_1			: std_logic;
	signal syn_light_cnt			: std_logic_vector(15 downto 0);
--	signal DPS_syn_dly_cnt_reg1: std_logic_vector(11 downto 0);
	signal DPS_syn_dly_cnt_reg	: std_logic_vector(11 downto 0);
--	signal DPS_syn_dly_cnt_add7: std_logic_vector(11 downto 0);
	
	signal DPS_send_PM_dly_cnt_reg: std_logic_vector(7 downto 0);
	signal DPS_send_AM_dly_cnt_reg: std_logic_vector(7 downto 0);
	
--	signal send_en_AM 			: std_logic;
	signal send_en_AM_reg 			: std_logic;
	signal send_en_PM_reg 			: std_logic;
	
	signal DPS_round_cnt_reg	: std_logic_vector(15 downto 0);
	
	signal DPS_round_cnt_AM		: std_logic_vector(15 downto 0);
	signal DPS_round_cnt_AM_sub64	: std_logic_vector(15 downto 0);--send enable last 128*2ns = 1/250M * 64
	
	signal DPS_round_cnt_PM		: std_logic_vector(15 downto 0);
	signal DPS_round_cnt_PM_sub64	: std_logic_vector(15 downto 0);--send enable last 128*2ns = 1/250M * 64
	
	
	signal gps_count32			: std_logic_vector(30 downto 0):=(others => '0');--gps period control count
	
	
begin
  --generate 250MHz send enable
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			exp_running_reg1	<= '0';
			exp_running_reg	<= '0';
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				exp_running_reg1	<= exp_running; --80MHz to 250MHz
				exp_running_reg	<= exp_running_reg1;
			end if;
		end if;
  end process;
  
--  process(sys_clk_250M, sys_rst_n) 
--  begin 
--		if(sys_rst_n = '0') then
--			exp_running_lch	<= '0';
--		else
--			if(sys_clk_250M'event and sys_clk_250M = '1') then
--				if(exp_running_reg = '1') then
--					exp_running_lch	<= '1';
--				else
--					if(exp_stopping_reg = '1') then
--						exp_running_lch	<= '0';
--					end if;
--				end if;
--			end if;
--		end if;
--  end process;
  
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			gps_pulse_reg	<= '0';
			gps_pulse_reg1	<= '0';
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				gps_pulse_reg	<= gps_pulse; --80MHz to 250MHz
				gps_pulse_reg1	<= gps_pulse_reg; --delay 1 clock
			end if;
		end if;
  end process;
  gps_pulse_r	<= (not gps_pulse_reg1) and gps_pulse_reg; 
  
--  process(sys_clk_250M, sys_rst_n) 
--  begin 
--		if(sys_rst_n = '0') then
--			exp_run		<= '0';
--		else
--			if(sys_clk_250M'event and sys_clk_250M = '1') then
--				if(exp_running_lch = '1' and gps_pulse_r = '1') then
--					exp_run	<= '1';
--				else
--					if(exp_running_lch = '0' and gps_pulse_r = '1') then
--						exp_run	<= '0';
--					end if;
--				end if;
--			end if;
--		end if;
--  end process;
  
  --generate chopper 
  process(exp_running_reg1, gps_pulse_r, exp_running_reg) 
  begin 
		if(exp_running_reg1 = '1' and gps_pulse_r = '1' and exp_running_reg = '0') then
			chopper_ctrl_add	<= '1'; --first GPS
		else
			if(exp_running_reg = '1' and gps_pulse_r = '1' ) then
				chopper_ctrl_add	<= '1';
			else
				chopper_ctrl_add	<= '0';
			end if;
		end if;
  end process;
  
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			chopper_ctrl_cnt		<= (others => '1');
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				if(exp_running_reg = '1') then
					if(chopper_ctrl_add = '1') then
						if(chopper_ctrl_cnt < DPS_chopper_cnt_reg) then
							chopper_ctrl_cnt	<= chopper_ctrl_cnt + 1;
						else
							chopper_ctrl_cnt		<= (others => '0');
						end if;
					end if;
				else
					chopper_ctrl_cnt		<= (others => '0');
				end if;
			end if;
		end if;
  end process;

  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			chopper_ctrl_reg			<= '1';
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				if(exp_running_reg = '1') then
					if(chopper_ctrl_add = '1' and chopper_ctrl_cnt = DPS_chopper_cnt_reg) then
						chopper_ctrl_reg			<= not chopper_ctrl_reg;
					end if;
				else
					chopper_ctrl_reg			<= '0';
				end if;
			end if;
		end if;
  end process;
  chopper_ctrl	<= chopper_ctrl_reg;
	
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			chopper_ctrl_d1		<= '0';
--			exp_run_d1				<= '0';
--			exp_run_d2				<= '0';
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				chopper_ctrl_d1		<= chopper_ctrl_reg;
--				exp_run_d1				<= exp_run;
--				exp_run_d2				<= exp_run_d1;
			end if;
		end if;
  end process;
  
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			syn_light_cnt		<= (others => '1');
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				if(exp_running_reg = '1') then
					if(chopper_ctrl_d1 = '1' and chopper_ctrl_reg = '0') then--falling edge chopper_ctrl low can send pulse
						syn_light_cnt		<= (others => '0');
					else
						if(chopper_ctrl_reg = '0') then
							if(syn_light_cnt < DPS_round_cnt_reg) then
								syn_light_cnt	<= syn_light_cnt + 1;
							else
								syn_light_cnt	<= (others => '0');
							end if;
						else
							syn_light_cnt	<= (others => '0');
						end if;
					end if;
				else
					syn_light_cnt		<= (others => '1');
				end if;
			end if;
		end if;
  end process;
  
  ---syn light has 16 sys_clk_250M clock width
  process(syn_light_cnt, DPS_syn_dly_cnt_reg) 
  begin 
		if(syn_light_cnt(15 downto 4) = DPS_syn_dly_cnt_reg ) then
			syn_light_sig	<= '1'; 
		else
			syn_light_sig	<= '0';
		end if;
  end process;
  
  process(syn_light_cnt) 
  begin 
		if(syn_light_cnt > 20) then
			PPG_start_1	<= '1'; 
		else
			PPG_start_1	<= '0';
		end if;
  end process;
  
  process(syn_light_cnt, DPS_round_cnt_AM, DPS_round_cnt_AM_sub64) 
  begin 
		if(syn_light_cnt <= DPS_round_cnt_AM and syn_light_cnt > DPS_round_cnt_AM_sub64) then
			send_en_AM_reg	<= '1'; 
		else
			send_en_AM_reg	<= '0';
		end if;
  end process;
  
  process(syn_light_cnt, DPS_round_cnt_PM, DPS_round_cnt_PM_sub64) 
  begin 
		if(syn_light_cnt <= DPS_round_cnt_PM and syn_light_cnt > DPS_round_cnt_PM_sub64) then
			send_en_PM_reg	<= '1'; 
		else
			send_en_PM_reg	<= '0';
		end if;
  end process;
  
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			PPG_start				<= '0';
			syn_light				<= '0';
			send_en					<= '0';
			send_en_AM				<= '0';
--			exp_stopping_reg		<= '0';
			DPS_send_PM_dly_cnt_reg	<= (others => '0');
			DPS_send_AM_dly_cnt_reg	<= (others => '0');
--			DPS_syn_dly_cnt_reg1	<= (others => '0');
			DPS_syn_dly_cnt_reg	<= (others => '0');
--			DPS_syn_dly_cnt_add7	<= (others => '0');
			DPS_round_cnt_AM	<= x"0000";--100us is sys_clk_250M clock cycle
			DPS_round_cnt_PM	<= x"0000";--100us is sys_clk_250M clock cycle
			DPS_round_cnt_reg		<= (others => '0');
			DPS_round_cnt_AM_sub64	<= (others => '0');
			DPS_round_cnt_PM_sub64	<= (others => '0');
			DPS_chopper_cnt_reg	<= (others => '0');
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
--				exp_stopping_reg		<= exp_stopping;
				PPG_start				<= PPG_start_1;
				syn_light				<= syn_light_sig;
				send_en					<= send_en_PM_reg;
				send_en_AM				<= send_en_AM_reg;
				DPS_send_PM_dly_cnt_reg	<= DPS_send_PM_dly_cnt;--x"FF";
				DPS_send_AM_dly_cnt_reg	<= DPS_send_AM_dly_cnt;--x"FF";
				DPS_chopper_cnt_reg	<= DPS_chopper_cnt;--x"FF";
				DPS_syn_dly_cnt_reg	<= DPS_syn_dly_cnt;
--				DPS_syn_dly_cnt_reg	<= DPS_syn_dly_cnt_reg1;
--				DPS_syn_dly_cnt_add7	<= DPS_syn_dly_cnt_reg1 + 7;
				DPS_round_cnt_reg		<= DPS_round_cnt;--x"61A7";
				
				DPS_round_cnt_AM		<= DPS_round_cnt_reg - DPS_send_AM_dly_cnt_reg;
				DPS_round_cnt_PM		<= DPS_round_cnt_reg - DPS_send_PM_dly_cnt_reg;
				
				DPS_round_cnt_AM_sub64	<= DPS_round_cnt_AM - 64;
				DPS_round_cnt_PM_sub64	<= DPS_round_cnt_PM - 64;--total is 128 pulse one clock cycle is 2 pulse 
			end if;
		end if;
  end process;
  
  
  process(sys_clk_250M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			chopper_ctrl_80M_reg		<= '0';
		else
			if(sys_clk_250M'event and sys_clk_250M = '1') then
				chopper_ctrl_80M_reg		<= chopper_ctrl_reg;
			end if;
		end if;
  end process;
  process(sys_clk_80M, sys_rst_n) 
  begin 
		if(sys_rst_n = '0') then
			chopper_ctrl_80M		<= '0';
		else
			if(sys_clk_80M'event and sys_clk_80M = '1') then
				chopper_ctrl_80M		<= chopper_ctrl_80M_reg;
			end if;
		end if;
  end process;
  
  process (sys_clk_80M)
	begin  
		if (sys_clk_80M'event and sys_clk_80M = '1') then
			if (gps_count32 > GPS_period_cnt(30 downto 0)) then
				gps_count32	<= (others => '0');
			else
				gps_count32	<= gps_count32 + 1;
			end if;
		end if;
	end process;
  
  process (sys_clk_80M)
	begin  
   if (sys_clk_80M'event and sys_clk_80M = '1') then
		if (gps_count32 < 100) then
			GPS_pulse_int <= '1';
		else
			GPS_pulse_int <= '0';
		end if;
   end if;
	end process;
	
--	AM1_OBUFDS_inst : OBUFDS
--   generic map (
--      IOSTANDARD => "DEFAULT")
--   port map (
--      O => send_en_AM_p,     -- Diff_p output (connect directly to top-level port)
--      OB => send_en_AM_n,   -- Diff_n output (connect directly to top-level port)
--      I => send_en_AM      -- Buffer input 
--   );
	
	GPS_pulse_int_active	<= GPS_period_cnt(31);
  
end Behavioral;

