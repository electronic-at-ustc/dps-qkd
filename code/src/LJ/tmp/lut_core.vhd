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
		clk : in std_logic;		-- ����ʱ�� 
		reset_n : in std_logic;		-- �첽��λ 
		start : in std_logic;		--��ʼ�ź� 
		input : in std_logic_vector(17 downto 0);		--���� 
		result : out std_logic_vector(15 downto 0);	--��� 
		rslt_ok : out std_logic);		--������� 
end entity; 
 
architecture rtl of lut_core is 
	-- X�� 
	component romx IS 
	PORT 
	( 
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0); 
		clock		: IN STD_LOGIC ; 
		q		: OUT STD_LOGIC_VECTOR (17 DOWNTO 0) 
	); 
	end component romx; 
	-- Y�� 
	component romy IS 
	PORT 
	( 
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0); 
		clock		: IN STD_LOGIC ; 
		q		: OUT STD_LOGIC_VECTOR (17 DOWNTO 0) 
	); 
	end component romy; 
	-- D�� 
	component romd IS 
	PORT 
	( 
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0); 
		clock		: IN STD_LOGIC ; 
		q		: OUT STD_LOGIC_VECTOR (17 DOWNTO 0) 
	); 
	end component romd; 
	 
	type mstate is (s_idle,ss0,ss1,ss2,sc0,sc1,sc2,sc3,sc4); -- ����״̬�� 
	constant ROMASIZE : integer range 0 to 15 := 7;		--��ĵ�ַλ�� 
	constant XPOINTPOS : integer range 0 to 31 := 9;  --q_romxС����λ�� 
	constant YPOINTPOS : integer range 0 to 31 := 17;  --q_romyС����λ�� 
	constant DPOINTPOS : integer range 0 to 31 := 17;  --q_romdС����λ�� 
	constant DDPOINTPOS : integer range 0 to 31 := XPOINTPOS; 
	constant helppos : std_logic_vector(DDPOINTPOS+DPOINTPOS-YPOINTPOS downto 0) := (DDPOINTPOS+DPOINTPOS-YPOINTPOS=>'1',others=>'0'); 
-- DDPOINTPOS + DPOINTPOS> YPOINTPOS 
-- RPOINTPOS = DPOINTPOS + DDPOINTPOS 
	signal state : mstate; --����״̬�� 
	signal addr : std_logic_vector(ROMASIZE - 1 downto 0); --����ַ 
	signal daddr : std_logic_vector(ROMASIZE - 1 downto 0); --��ַ���� 
	signal paddr : std_logic_vector(ROMASIZE - 1 downto 0); --ROMʵ�ʵ�ַ 
	signal q_romx0 : std_logic_vector(17 downto 0);  
	signal q_romx : std_logic_vector(17 downto 0); --ROMX����� 
	signal q_romy : std_logic_vector(17 downto 0); --ROMY����� 
	signal q_romd : std_logic_vector(17 downto 0); --ROMD����� 
	signal flag : std_logic;  
	signal dd0 : std_logic_vector(17 downto 0); 
	signal dd1 : std_logic_vector(17 downto 0); 
	signal ty : std_logic_vector(35 downto 0); --36λ��� 
begin 
 
----�˿�ӳ�� 
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
	 
	result <= ty(26 downto 11);  --���ȡty����Чλ 
	process(clk,reset_n) 
	begin 
		if reset_n = '0' then  ----��λ 
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
			if clk'event and clk = '1' then  --ʱ�������ش������²��� 
				rslt_ok <= '0'; 
				case state is  --״̬��״̬���� 
					when s_idle => 
						if start = '1' then  --�յ�start 
							addr <= (others => '0'); 
							daddr <= conv_std_logic_vector(2**(ROMASIZE - 1),ROMASIZE); 
							paddr <= conv_std_logic_vector(2**(ROMASIZE - 1),ROMASIZE); 
							state <= ss0;  --����״̬ss0 
						end if; 
					when ss0 => --��һ������ 
						state <= ss1; 
					when ss1 =>  
						if daddr /= conv_std_logic_vector(1,ROMASIZE) then 
							daddr <= '0' & daddr(ROMASIZE - 1 downto 1); 
							if input > q_romx then  --input����X���е�ֵ 
								addr <= paddr; 
								paddr <= paddr + ('0' & daddr(ROMASIZE - 1 downto 1)); 
							else  --inputС�ڵ���X���е�ֵ 
								paddr <= addr + ('0' & daddr(ROMASIZE - 1 downto 1)); 
							end if; 
							state <= ss0;  --ѭ�� 
						else  --ѭ������ 
							q_romx0 <= q_romx; 
							if input > q_romx then 
								flag <= '0'; 
								paddr <= paddr + 1; --input����ROMX��ֵ�������ϲ��� 
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
						if dd1 > dd0 then  --dd0������m+1����result 
							if flag = '0' then 
								paddr <= addr; 
							end if; 
							flag <= '0'; 
						else							 --dd1������m����result 
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

