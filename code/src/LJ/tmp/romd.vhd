----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:22:57 11/26/2014 
-- Design Name: 
-- Module Name:    romd - Behavioral 
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
 
ENTITY romd IS 
	PORT 
	( 
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0); 
		clock		: IN STD_LOGIC ; 
		q		: OUT STD_LOGIC_VECTOR (17 DOWNTO 0) 
	); 
END romd; 
 
 
ARCHITECTURE SYN OF romd IS 
 
	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (17 DOWNTO 0); 
 
 
 
	COMPONENT altsyncram 
	GENERIC ( 
		clock_enable_input_a		: STRING; 
		clock_enable_output_a		: STRING; 
		init_file		: STRING; 
		intended_device_family		: STRING; 
		lpm_hint		: STRING; 
		lpm_type		: STRING; 
		numwords_a		: NATURAL; 
		operation_mode		: STRING; 
		outdata_aclr_a		: STRING; 
		outdata_reg_a		: STRING; 
		widthad_a		: NATURAL; 
		width_a		: NATURAL; 
		width_byteena_a		: NATURAL 
	); 
	PORT ( 
			clock0	: IN STD_LOGIC ; 
			address_a	: IN STD_LOGIC_VECTOR (6 DOWNTO 0); 
			q_a	: OUT STD_LOGIC_VECTOR (17 DOWNTO 0) 
	); 
	END COMPONENT; 
 
BEGIN 
	q    <= sub_wire0(17 DOWNTO 0); 
 
	altsyncram_component : altsyncram 
	GENERIC MAP ( 
		clock_enable_input_a => "BYPASS", 
		clock_enable_output_a => "BYPASS", 
		init_file => "romd.hex", 
		intended_device_family => "Stratix II", 
		lpm_hint => "ENABLE_RUNTIME_MOD=NO", 
		lpm_type => "altsyncram", 
		numwords_a => 128, 
		operation_mode => "ROM", 
		outdata_aclr_a => "NONE", 
		outdata_reg_a => "UNREGISTERED", 
		widthad_a => 7, 
		width_a => 18, 
		width_byteena_a => 1 
	) 
	PORT MAP ( 
		clock0 => clock, 
		address_a => address, 
		q_a => sub_wire0 
	); 
 
 
 
END SYN; 
 
-- ============================================================ 
-- CNX file retrieval info 
-- ============================================================ 
-- Retrieval info: PRIVATE: ADDRESSSTALL_A NUMERIC "0" 
-- Retrieval info: PRIVATE: AclrAddr NUMERIC "0" 
-- Retrieval info: PRIVATE: AclrByte NUMERIC "0" 
-- Retrieval info: PRIVATE: AclrOutput NUMERIC "0" 
-- Retrieval info: PRIVATE: BYTE_ENABLE NUMERIC "0" 
-- Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "9" 
-- Retrieval info: PRIVATE: BlankMemory NUMERIC "0" 
-- Retrieval info: PRIVATE: CLOCK_ENABLE_INPUT_A NUMERIC "0" 
-- Retrieval info: PRIVATE: CLOCK_ENABLE_OUTPUT_A NUMERIC "0" 
-- Retrieval info: PRIVATE: Clken NUMERIC "0" 
-- Retrieval info: PRIVATE: IMPLEMENT_IN_LES NUMERIC "0" 
-- Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_A" 
-- Retrieval info: PRIVATE: INIT_TO_SIM_X NUMERIC "0" 
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix II" 
-- Retrieval info: PRIVATE: JTAG_ENABLED NUMERIC "0" 
-- Retrieval info: PRIVATE: JTAG_ID STRING "NONE" 
-- Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0" 
-- Retrieval info: PRIVATE: MIFfilename STRING "romd.hex" 
-- Retrieval info: PRIVATE: NUMWORDS_A NUMERIC "128" 
-- Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0" 
-- Retrieval info: PRIVATE: RegAddr NUMERIC "1" 
-- Retrieval info: PRIVATE: RegOutput NUMERIC "0" 
-- Retrieval info: PRIVATE: SingleClock NUMERIC "1" 
-- Retrieval info: PRIVATE: UseDQRAM NUMERIC "0" 
-- Retrieval info: PRIVATE: WidthAddr NUMERIC "7" 
-- Retrieval info: PRIVATE: WidthData NUMERIC "18" 
-- Retrieval info: CONSTANT: CLOCK_ENABLE_INPUT_A STRING "BYPASS" 
-- Retrieval info: CONSTANT: CLOCK_ENABLE_OUTPUT_A STRING "BYPASS" 
-- Retrieval info: CONSTANT: INIT_FILE STRING "romd.hex" 
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Stratix II" 
-- Retrieval info: CONSTANT: LPM_HINT STRING "ENABLE_RUNTIME_MOD=NO" 
-- Retrieval info: CONSTANT: LPM_TYPE STRING "altsyncram" 
-- Retrieval info: CONSTANT: NUMWORDS_A NUMERIC "128" 
-- Retrieval info: CONSTANT: OPERATION_MODE STRING "ROM" 
-- Retrieval info: CONSTANT: OUTDATA_ACLR_A STRING "NONE" 
-- Retrieval info: CONSTANT: OUTDATA_REG_A STRING "UNREGISTERED" 
-- Retrieval info: CONSTANT: WIDTHAD_A NUMERIC "7" 
-- Retrieval info: CONSTANT: WIDTH_A NUMERIC "18" 
-- Retrieval info: CONSTANT: WIDTH_BYTEENA_A NUMERIC "1" 
-- Retrieval info: USED_PORT: address 0 0 7 0 INPUT NODEFVAL address[6..0] 
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock 
-- Retrieval info: USED_PORT: q 0 0 18 0 OUTPUT NODEFVAL q[17..0] 
-- Retrieval info: CONNECT: @address_a 0 0 7 0 address 0 0 7 0 
-- Retrieval info: CONNECT: q 0 0 18 0 @q_a 0 0 18 0 
-- Retrieval info: CONNECT: @clock0 0 0 0 0 clock 0 0 0 0 
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all 
-- Retrieval info: GEN_FILE: TYPE_NORMAL romd.vhd TRUE 
-- Retrieval info: GEN_FILE: TYPE_NORMAL romd.inc FALSE 
-- Retrieval info: GEN_FILE: TYPE_NORMAL romd.cmp FALSE 
-- Retrieval info: GEN_FILE: TYPE_NORMAL romd.bsf FALSE 
-- Retrieval info: GEN_FILE: TYPE_NORMAL romd_inst.vhd FALSE 

