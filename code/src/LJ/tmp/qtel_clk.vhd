----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:26:57 07/24/2014 
-- Design Name: 
-- Module Name:    qtel_clk - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity qtel_clk is
port(
	out_clk_80M					   : 	in		std_logic;
	qtel_clk_80M					: 	out	std_logic;
	qtel_clk_80M_delay			: 	out	std_logic
	);
end qtel_clk;

architecture Behavioral of qtel_clk is
component qtel_DCM
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  CLK_OUT2          : out    std_logic;
  -- Status and control signals
  RESET             : in     std_logic;
  LOCKED            : out    std_logic
 );
end component;

begin
Instance_qtel_DCM : qtel_DCM
  port map
   (-- Clock in ports
    CLK_IN1 => out_clk_80M,
    -- Clock out ports
    CLK_OUT1 => qtel_clk_80M,
    CLK_OUT2 => qtel_clk_80M_delay,
    -- Status and control signals
    RESET  => '0',
    LOCKED => open);

end Behavioral;

