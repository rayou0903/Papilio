--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:35:24 10/01/2020
-- Design Name:   
-- Module Name:   C:/Users/rayou/Papilio/echo/top_test.vhd
-- Project Name:  echo
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top
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
 
ENTITY top_test IS
END top_test;
 
ARCHITECTURE behavior OF top_test IS 
	COMPONENT top
		PORT(
			CLK :  IN    std_logic;
			RST :  IN    std_logic;
			RXD :  IN    std_logic;
			TXD :  OUT   std_logic;
			DATA : INOUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
    
	--Inputs
	signal CLK : std_logic := '0';
	signal RST : std_logic := '0';
	signal RXD : std_logic := '0';

	--Outputs
	signal TXD : std_logic; 
	signal DATA : std_logic_vector(7 downto 0) := "11111111";

BEGIN
	uut: top PORT MAP (
		CLK  => CLK,
		RST  => RST,
		RXD  => RXD,
		TXD  => TXD,
		DATA => DATA
	);

	RST <= '1' after 500 ns;
	 
	--a
	RXD <= '1',
			 '0' after 1000 ns,  --スタートビット
			 '1' after 1500 ns,  --LSB
			 '0' after 2000 ns,
			 '0' after 2500 ns,
			 '0' after 3000 ns,
			 '0' after 3500 ns,
			 '1' after 4000 ns,
			 '1' after 4500 ns,
			 '0' after 5000 ns,  --MSB
			 '1' after 5500 ns,  --ストップビット
			  
	--b
			 '0' after 21000 ns,  --スタートビット
			 '0' after 21500 ns,  --LSB
			 '1' after 22000 ns,
			 '0' after 22500 ns,
			 '0' after 23000 ns,
			 '0' after 23500 ns,
			 '1' after 24000 ns,
			 '1' after 24500 ns,
			 '0' after 25000 ns,  --MSB
			 '1' after 25500 ns;  --ストップビット

	--クロック(32MHz)
	process begin
		CLK <= '1';
		wait for 15.625 ns;
		CLK <= '0';
		wait for 15.625 ns;
	end process;
	
END;