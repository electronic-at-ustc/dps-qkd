----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:22:15 11/26/2014 
-- Design Name: 
-- Module Name:    lut_core - Behavioral 
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

-- There is one thing I feel interesting: 
--   I know the code will be finished one hour later, 
--   but what I'm facing now is only a blank page, 
--   and what I have to do is typing on and on 
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
 
entity lut_core is 
	port( 
		clk : in std_logic;		-- 输入时钟 
		reset_n : in std_logic;		-- 异步复位 
		start : in std_logic;		--起始信号 
		input : in std_logic_vector(17 downto 0);		--输入 
		result : out std_logic_vector(15 downto 0);	--输出 
		rslt_ok : out std_logic);		--计算完成 
end entity; 
 
architecture rtl of lut_core is 
	-- X表 
	component romx IS 
	PORT 
	( 
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0); 
		clock		: IN STD_LOGIC ; 
		q		: OUT STD_LOGIC_VECTOR (17 DOWNTO 0) 
	); 
	end component romx; 
	-- Y表 
	component romy IS 
	PORT 
	( 
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0); 
		clock		: IN STD_LOGIC ; 
		q		: OUT STD_LOGIC_VECTOR (17 DOWNTO 0) 
	); 
	end component romy; 
	-- D表 
	component romd IS 
	PORT 
	( 
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0); 
		clock		: IN STD_LOGIC ; 
		q		: OUT STD_LOGIC_VECTOR (17 DOWNTO 0) 
	); 
	end component romd; 
	 
	type mstate is (s_idle,ss0,ss1,ss2,sc0,sc1,sc2,sc3,sc4); -- 定义状态机 
	constant ROMASIZE : integer range 0 to 15 := 7;		--表的地址位宽 
	constant XPOINTPOS : integer range 0 to 31 := 9;  --q_romx小数点位置 
	constant YPOINTPOS : integer range 0 to 31 := 17;  --q_romy小数点位置 
	constant DPOINTPOS : integer range 0 to 31 := 17;  --q_romd小数点位置 
	constant DDPOINTPOS : integer range 0 to 31 := XPOINTPOS; 
	constant helppos : std_logic_vector(DDPOINTPOS+DPOINTPOS-YPOINTPOS downto 0) := (DDPOINTPOS+DPOINTPOS-YPOINTPOS=>'1',others=>'0'); 
-- DDPOINTPOS + DPOINTPOS> YPOINTPOS 
-- RPOINTPOS = DPOINTPOS + DDPOINTPOS 
	signal state : mstate; --声明状态机 
	signal addr : std_logic_vector(ROMASIZE - 1 downto 0); --基地址 
	signal daddr : std_logic_vector(ROMASIZE - 1 downto 0); --地址增量 
	signal paddr : std_logic_vector(ROMASIZE - 1 downto 0); --ROM实际地址 
	signal q_romx0 : std_logic_vector(17 downto 0);  
	signal q_romx : std_logic_vector(17 downto 0); --ROMX的输出 
	signal q_romy : std_logic_vector(17 downto 0); --ROMY的输出 
	signal q_romd : std_logic_vector(17 downto 0); --ROMD的输出 
	signal flag : std_logic;  
	signal dd0 : std_logic_vector(17 downto 0); 
	signal dd1 : std_logic_vector(17 downto 0); 
	signal ty : std_logic_vector(35 downto 0); --36位结果 
begin 
 
----端口映射 
rx:romx 
	PORT map 
	( 
		address => paddr, 
		clock	=> clk, 
		q	=> q_romx); 
ry:romy 
	PORT map 
	( 
		address => paddr, 
		clock	=> clk, 
		q	=> q_romy); 
rd:romd 
	PORT map 
	( 
		address => paddr, 
		clock	=> clk, 
		q	=> q_romd); 
	 
	result <= ty(26 downto 11);  --结果取ty高有效位 
	process(clk,reset_n) 
	begin 
		if reset_n = '0' then  ----复位 
			rslt_ok <= '0'; 
			state <= s_idle; 
			daddr <= (others => '0'); 
			addr <= (others => '0'); 
			paddr <= (others => '0'); 
			q_romx0 <= (others => '0'); 
			flag <= '0'; 
			dd0 <= (others => '0'); 
			dd1 <= (others => '0'); 
			ty <= (others => '0'); 
		else 
			if clk'event and clk = '1' then  --时钟上升沿触发以下部分 
				rslt_ok <= '0'; 
				case state is  --状态机状态译码 
					when s_idle => 
						if start = '1' then  --收到start 
							addr <= (others => '0'); 
							daddr <= conv_std_logic_vector(2**(ROMASIZE - 1),ROMASIZE); 
							paddr <= conv_std_logic_vector(2**(ROMASIZE - 1),ROMASIZE); 
							state <= ss0;  --进入状态ss0 
						end if; 
					when ss0 => --等一个周期 
						state <= ss1; 
					when ss1 =>  
						if daddr /= conv_std_logic_vector(1,ROMASIZE) then 
							daddr <= '0' & daddr(ROMASIZE - 1 downto 1); 
							if input > q_romx then  --input大于X表中的值 
								addr <= paddr; 
								paddr <= paddr + ('0' & daddr(ROMASIZE - 1 downto 1)); 
							else  --input小于等于X表中的值 
								paddr <= addr + ('0' & daddr(ROMASIZE - 1 downto 1)); 
							end if; 
							state <= ss0;  --循环 
						else  --循环结束 
							q_romx0 <= q_romx; 
							if input > q_romx then 
								flag <= '0'; 
								paddr <= paddr + 1; --input大于ROMX的值，则向上查找 
								addr <= paddr; 
							else 
								flag <= '1'; 
								paddr <= addr; 
							end if; 
							state <= ss2; 
						end if; 
					when ss2 => 
						state <= sc0; 
					when sc0 => 
						if flag = '0' then 
							dd0 <= input - q_romx0; 
							dd1 <= q_romx - input; 
						else 
							dd0 <= input - q_romx; 
							dd1 <= q_romx0 - input; 
						end if; 
						--dd0=input-x(m) 
						--dd1=x(m+1)-input 
						state <= sc1; 
					when sc1 => 
						if dd1 > dd0 then  --dd0大，则用m+1计算result 
							if flag = '0' then 
								paddr <= addr; 
							end if; 
							flag <= '0'; 
						else							 --dd1大，则用m计算result 
							if flag = '1' then 
								paddr <= paddr + 1; 
							end if; 
							dd0 <= dd1; 
							flag <= '1'; 
						end if; 
						state <= sc2; 
					when sc2 => 
						state <= sc3; 
					when sc3 => 
						ty <= dd0 * q_romd;		--ty=DD*d(m) 
						state <= sc4; 
					when sc4 => 
						if flag = '0' then 
							ty <= q_romy*helppos + ty;	--ty=y(m)+ty; 
						else 
							ty <= q_romy*helppos - ty; 
						end if; 
						addr <= (others => '0'); 
						rslt_ok <= '1'; 
						state <= s_idle; 
					when others => 
						state <= s_idle; 
				end case; 
			end if; 
		end if; 
	end process; 
end rtl;

