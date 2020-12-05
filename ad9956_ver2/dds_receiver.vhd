----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:53:56 12/05/2020 
-- Design Name: 
-- Module Name:    dds_receiver - Behavioral 
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

entity dds_receiver is
	Port ( 
		CLK	: in		STD_LOGIC;
		RST	: in		STD_LOGIC;
		RE		: in		STD_LOGIC;
		IDATA	: in		STD_LOGIC_VECTOR (7 downto 0);	--命令サイクル(8bit)
		SDIO	: inout	STD_LOGIC;
		BUSY	: out		STD_LOGIC;
		CS		: out		STD_LOGIC;
		PDATA	: out		STD_LOGIC_VECTOR (55 downto 0)
	);
end dds_receiver;

architecture Behavioral of dds_receiver is
	--innner signal
	type state_t is (IDLE, INSTRUCTION, TRANSFER);
	signal state		: state_t := IDLE;
	signal sdio_inner : std_logic_vector(7 downto 0) := "00000000";
	signal bit_cnt		: integer := 0;
	signal clk_cnt		: integer := 0;
	
begin
	SDIO <= sdio_inner(7);
	process(CLK, RST) begin
		if(RST = '0') then
			CS		<= '1';
			sdio_inner <= "00000000";
			BUSY	<= '0';
			
		elsif falling_edge(CLK) then
			case state is
				when IDLE =>
					if(RE = '0') then
						CS		<= '0';
						sdio_inner <= IDATA;
						BUSY	<= '1';
						state	<= INSTRUCTION;
					else
						sdio_inner <= "00000000";
						BUSY	<= '0';
					end if;
					
				when INSTRUCTION =>
					if(bit_cnt = 7 and clk_cnt = 7) then
						CS				<= '1';
						bit_cnt <= 0;		--ビットカウンタをリセット
						clk_cnt <= 0;		--クロックカウンタをリセット
						state   <= TRANSFER;	--アップデート状態に遷移
					elsif(clk_cnt = 7) then
						clk_cnt   <= 0;										--クロックカウンタをリセット
						bit_cnt   <= bit_cnt + 1;							--ビットカウンタを1増やす
						sdio_inner <= sdio_inner(6 downto 0) & '0';	--1ビット左シフト
					else
						clk_cnt   <= clk_cnt + 1;
					end if;
					
				when TRANSFER =>
					state	<= IDLE;
					
				when others => null;
			end case;
		end if;
	end process;

end Behavioral;

