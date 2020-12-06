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
   signal RST : std_logic := '1';
   signal RQ : std_logic := '0';
   signal R_OR_W : std_logic := '0';
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
		  
	--ƒNƒƒbƒN(200MHz)
	process begin
		CLK <= '0';
		wait for 5 ns;
		CLK <= '1';
		wait for 5 ns;
	end process;
	
	--SDIO <= sdio_inner;
	
	RST	<= '0' after 20 ns, '1' after 30 ns;
	RQ		<= '1' after 40 ns, '0' after 50 ns;
	SDIO	<= '1' after 800 ns, 
				'0' after 880 ns,
				'1' after 960 ns,
				'0' after 1040 ns,
				'1' after 1120 ns,
				'1' after 1200 ns,
				'0' after 1280 ns,
				'1' after 1360 ns,
				'0' after 1440 ns,
				'0' after 1520 ns,
				'0' after 1600 ns,
				'1' after 1680 ns,
				'1' after 1760 ns,
				'1' after 1840 ns,
				'0' after 1920 ns,
				'0' after 2000 ns,
				'0' after 2080 ns,
				'1' after 2160 ns,
				'1' after 2240 ns,
				'0' after 2320 ns,
				'0' after 2400 ns,
				'0' after 2480 ns,
				'1' after 2560 ns,
				'0' after 2640 ns,
				'0' after 2720 ns,
				'0' after 2800 ns,
				'0' after 2880 ns,
				'0' after 2960 ns,
				'0' after 3040 ns,
				'1' after 3120 ns,
				'1' after 3200 ns,
				'1' after 3280 ns,
				'1' after 3360 ns,
				'0' after 3440 ns,
				'1' after 3520 ns,
				'1' after 3600 ns,
				'0' after 3680 ns,
				'0' after 3760 ns,
				'0' after 3840 ns,
				'0' after 3920 ns,
				'1' after 4000 ns,
				'1' after 4080 ns,
				'0' after 4160 ns,
				'0' after 4240 ns,
				'0' after 4320 ns,
				'0' after 4400 ns,
				'0' after 4480 ns,
				'0' after 4560 ns,
				'0' after 4640 ns,
				'0' after 4720 ns,
				'1' after 4800 ns,
				'0' after 4880 ns,
				'0' after 4960 ns,
				'0' after 5040 ns,
				'1' after 5120 ns,
				'1' after 5200 ns;
				
--	process begin
--		wait for 800 ns;
--		SDIO <= data(n);
--		loop
--			n <= n - 1;
--			wait for 80 ns;
--		end loop;
--	end process;
	
END;
