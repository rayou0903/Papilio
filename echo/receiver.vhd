----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:52:21 10/01/2020 
-- Design Name: 
-- Module Name:    receiver - Behavioral 
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

entity receiver is
    Port ( 
		CLK    : in  STD_LOGIC;								--クロック信号
		RST    : in  STD_LOGIC;								--リセット信号
		RXD    : in  STD_LOGIC;								--受信信号
		DREC   : out STD_LOGIC_VECTOR (7 downto 0);	--受信データ(8bit)
		GET_EN : out STD_LOGIC								--受信可能信号(IDLE状態:1, BUSY状態:0)
	);
end receiver;

architecture Behavioral of receiver is
	-- rs232c_receiver
	 component rs232c_receiver
		port(
			CLK    : in  std_logic;								--クロック信号
			RST    : in  std_logic;								--リセット信号
			RXD    : in  std_logic;								--受信信号
			DREC   : out std_logic_vector(7 downto 0);	--受信データ(8bit)
			GET_EN : out std_logic								--受信可能信号(IDLE状態:1, BUSY状態:0)
		);
	 end component;
	 
begin
	-- rs232c_receiver
	rs232c_r : rs232c_receiver
		port map (
			CLK    => CLK,
			RST    => RST,
			RXD    => RXD,
			DREC   => DREC,
			GET_EN => GET_EN
		);
end Behavioral;