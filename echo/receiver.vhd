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
		CLK    : in  STD_LOGIC;								--�N���b�N�M��
		RST    : in  STD_LOGIC;								--���Z�b�g�M��
		RXD    : in  STD_LOGIC;								--��M�M��
		DREC   : out STD_LOGIC_VECTOR (7 downto 0);	--��M�f�[�^(8bit)
		GET_EN : out STD_LOGIC								--��M�\�M��(IDLE���:1, BUSY���:0)
	);
end receiver;

architecture Behavioral of receiver is
	-- rs232c_receiver
	 component rs232c_receiver
		port(
			CLK    : in  std_logic;								--�N���b�N�M��
			RST    : in  std_logic;								--���Z�b�g�M��
			RXD    : in  std_logic;								--��M�M��
			DREC   : out std_logic_vector(7 downto 0);	--��M�f�[�^(8bit)
			GET_EN : out std_logic								--��M�\�M��(IDLE���:1, BUSY���:0)
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