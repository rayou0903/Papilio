----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:02:55 12/09/2020 
-- Design Name: 
-- Module Name:    rs232c_transmitter - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rs232c_transmitter is
	Port (
		CLK     : in  		STD_LOGIC;						--クロック信号
		RST     : in  		STD_LOGIC;						--リセット信号
		DSEND   : in  		STD_LOGIC_VECTOR (7 downto 0);	--送信データ(8bit)
		SEND_RQ : in  		STD_LOGIC;						--送信リクエスト(送信開始時に1)
		TXD     : out		STD_LOGIC;						--RS232CのTXD信号(シリアル)
		SET_EN  : inout 	STD_LOGIC							--セット可能信号(0のときビジー状態)
	);
end rs232c_transmitter;

architecture Behavioral of rs232c_transmitter is
	type state_t is (IDLE, SEND);
	signal state       : state_t := idle;
	signal txd_inner   : std_logic_vector(9 downto 0) := "1111111111";
	signal bit_cnt     : integer := 0;
	signal clk_cnt     : integer := 0;
	 
begin
	TXD <= txd_inner(0);
	process(CLK, RST) begin
		if(RST = '0') then
			state     <= IDLE;
			SET_EN    <= '1';
			txd_inner <= "1111111111";
			bit_cnt   <= 0;
			clk_cnt   <= 0;
				
		elsif rising_edge(CLK) then
			case state is
				when IDLE =>
					if(SEND_RQ = '1') then
						SET_EN    <= '1';				--ビジー状態
						txd_inner <= '1' & DSEND & '0';	--ストップ&データ&スタート
						state     <= SEND;				--送信状態に遷移
					else
						txd_inner <= "1111111111";
						SET_EN    <= '0';
					end if;
					 
				when SEND =>
					if(bit_cnt = 9 and clk_cnt = 7) then
						SET_EN  <= '0';
						bit_cnt <= 0;		--ビットカウンタをリセット
						clk_cnt <= 0;		--クロックカウンタをリセット
						state   <= IDLE;	--アイドル状態に遷移
					elsif(clk_cnt = 7) then
						clk_cnt   <= 0;								--クロックカウンタをリセット
						bit_cnt   <= bit_cnt + 1;					--ビットカウンタを1増やす
						txd_inner <= '1' & txd_inner(9 downto 1);	--1ビット右シフト
					else
						clk_cnt   <= clk_cnt + 1;
					end if;
					 
				when others => null;
			end case;			
		end if;
	end process;
end Behavioral;