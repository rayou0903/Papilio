--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:45:59 12/05/2020
-- Design Name:   
-- Module Name:   C:/Users/rayou/Papilio/ad9956/dds_com_test.vhd
-- Project Name:  ad9956
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dds_communication
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY dds_com_test IS
END dds_com_test;
 
ARCHITECTURE behavior OF dds_com_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dds_communication
    PORT(
         CLK : IN  std_logic;
			SCLK : IN std_logic;
         RST : IN  std_logic;
         RQ : IN  std_logic;
         R_OR_W : IN  std_logic;
         AC_REG : IN  std_logic_vector(3 downto 0);
         DSEND : IN  std_logic_vector(55 downto 0);
         SDIO : INOUT  std_logic;
         CS : OUT  std_logic;
         IO_UPDATE : OUT  std_logic;
         DGET : OUT  std_logic_vector(55 downto 0);
         BUSY : OUT  std_logic
        );
    END COMPONENT;

   --Inputs
   signal CLK : std_logic := '0';
	signal SCLK : std_logic := '0';
   signal RST : std_logic := '1';
   signal RQ : std_logic := '0';
   signal R_OR_W : std_logic := '1';
   signal AC_REG : std_logic_vector(3 downto 0) := "1010";	--(others => '0');
   signal DSEND : std_logic_vector(55 downto 0) := "10100010001110000100000011000110000101001000010000000101";	--(others => '0');

	--BiDirs
   signal SDIO : std_logic := 'Z';

 	--Outputs
   signal CS : std_logic;
   signal IO_UPDATE : std_logic;
   signal DGET : std_logic_vector(55 downto 0);
   signal BUSY : std_logic;
	
	--signal sdio_inner : std_logic := 'Z';
	signal data : std_logic_vector(55 downto 0) := "10001011000000011100100000000000001100001110001001000001";
	signal n		: integer := 55;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dds_communication PORT MAP (
          CLK => CLK,
			 SCLK => SCLK,
          RST => RST,
          RQ => RQ,
          R_OR_W => R_OR_W,
          AC_REG => AC_REG,
          DSEND => DSEND,
          SDIO => SDIO,
          CS => CS,
          IO_UPDATE => IO_UPDATE,
          DGET => DGET,
          BUSY => BUSY
        );
		  
	--クロック(200MHz)
	process begin
		CLK <= '0';
		wait for 5 ns;
		CLK <= '1';
		wait for 5 ns;
	end process;
	
	--クロック(25MHz)
	process begin
		CLK <= '0';
		wait for 20 ns;
		CLK <= '1';
		wait for 20 ns;
	end process;
	
	--SDIO <= sdio_inner;
	
	RST	<= '0' after 20 ns, '1' after 30 ns;
	RQ		<= '1' after 40 ns, '0' after 50 ns, '1' after 5300 ns, '0' after 5310 ns;
	R_OR_W <= '0' after 5300 ns;
	SDIO	<= '1' after 5940 ns, 
				'0' after 6020 ns,
				'1' after 6100 ns,
				'0' after 6180 ns,
				'1' after 6260 ns,
				'1' after 6340 ns,
				'0' after 6420 ns,
				'1' after 6500 ns,
				'1' after 6580 ns,
				'0' after 6660 ns,
				'0' after 6740 ns,
				'0' after 6820 ns,
				'1' after 6900 ns,
				'1' after 6980 ns,
				'1' after 7060 ns,
				'1' after 7140 ns,
				'0' after 7220 ns,
				'1' after 7300 ns,
				'1' after 7380 ns,
				'0' after 7460 ns,
				'1' after 7540 ns,
				'1' after 7620 ns,
				'0' after 7700 ns,
				'0' after 7780 ns,
				'0' after 7860 ns,
				'0' after 7940 ns,
				'1' after 8020 ns,
				'0' after 8100 ns,
				'1' after 8180 ns,
				'0' after 8260 ns,
				'1' after 8340 ns,
				'1' after 8420 ns,
				'0' after 8500 ns,
				'1' after 8580 ns,
				'0' after 8660 ns,
				'1' after 8740 ns,
				'0' after 8820 ns,
				'1' after 8900 ns,
				'0' after 8980 ns,
				'1' after 9060 ns,
				'0' after 9140 ns,
				'1' after 9220 ns,
				'0' after 9300 ns,
				'1' after 9380 ns,
				'0' after 9460 ns,
				'1' after 9540 ns,
				'0' after 9620 ns,
				'0' after 9700 ns,
				'1' after 9780 ns,
				'0' after 9860 ns,
				'1' after 9940 ns,
				'0' after 10020 ns,
				'1' after 10100 ns,
				'0' after 10180 ns,
				'1' after 10260 ns,
				'1' after 10340 ns;

				
--	process begin
--		wait for 800 ns;
--		SDIO <= data(n);
--		loop
--			n <= n - 1;
--			wait for 80 ns;
--		end loop;
--	end process;
	
END;