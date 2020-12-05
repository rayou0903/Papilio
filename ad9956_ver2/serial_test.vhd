--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:44:52 11/06/2020
-- Design Name:   
-- Module Name:   C:/Users/rayou/Papilio/ad9956/serial_test.vhd
-- Project Name:  ad9956
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: serial
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY serial_test IS
END serial_test;
 
ARCHITECTURE SIM OF serial_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT serial
		PORT(
		CLK 			: IN  	std_logic;	--クロック信号(32MHz)
		RST 			: IN  	std_logic;	--Papilioリセット信号
		WE				: IN		std_logic;	--書き込み有効入力
		RE				: in		STD_LOGIC;	--読み込み有効入力
		IO_RESET		: OUT		std_logic;	--9
		RESET			: OUT		std_logic;	--10
		SDO      	: IN  	std_logic;	--13
		SDIO 			: INOUT  std_logic;	--14
      SCLK 			: OUT  	std_logic;	--15
      CS 			: OUT  	std_logic;	--16
      SYNC_IN		: OUT		std_logic;	--19
		IO_UPDATE	: OUT		std_logic;	--20
		PSEL			: OUT		std_logic_vector(2 downto 0);	--Profile Select(21 to 23)
		TXD			: OUT		std_logic
		);
	END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '1';
	signal WE  : std_logic := '1';
	signal RE  : std_logic := '1';
	signal SDO : std_logic := '0';

	--BiDirs
   signal SDIO : std_logic;

 	--Outputs
	signal IO_RESET	: std_logic;
	signal RESET		: std_logic;
	signal SCLK			: std_logic;
	signal CS 			: std_logic;
	signal SYNC_IN		: std_logic;
	signal IO_UPDATE	: std_logic;
	signal PSEL			: std_logic_vector(2 downto 0);
	signal TXD			: std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	uut: serial PORT MAP (
          CLK			=> CLK,
          RST			=> RST,
			 WE			=> WE,
			 RE			=> RE,
			 IO_RESET	=> IO_RESET,
			 RESET		=> RESET,
			 SDO			=> SDO,
			 SDIO			=> SDIO,
          SCLK			=> SCLK,
          CS			=> CS,
          SYNC_IN		=> SYNC_IN,
			 IO_UPDATE	=> IO_UPDATE,
			 PSEL			=> PSEL,
			 TXD			=> TXD
        );

	--クロック(32MHz)
	process begin
		CLK <= '0';
		wait for 15.625 ns;
		CLK <= '1';
		wait for 15.625 ns;
	end process;

	RST	<= '0' after 20 ns, '1' after 25 ns;
	WE		<= '0' after 500 ns, '1' after 505 ns;
	RE		<=	'0' after 4000 ns, '1' after 4005 ns;

END;
