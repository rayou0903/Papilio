----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:18:25 10/01/2020 
-- Design Name: 
-- Module Name:    top - Behavioral 
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

entity top is
	Port ( 
		CLK  : in    STD_LOGIC;							--入力クロック(32MHz)
		RST  : in    STD_LOGIC;							--リセット信号
		RXD  : in    STD_LOGIC;							--受信信号
		TXD  : out   STD_LOGIC;							--送信信号
		DATA : inout STD_LOGIC_VECTOR(7 downto 0)	--送受信データ
	);
end top;

architecture Behavioral of top is
	--clk_generator
	component clk_generator
		port(
			CLK_IN1    : in  std_logic;				--入力クロック(32MHz)
			CLK100     : out std_logic;				--FIFO用クロック(100MHz)
			CLK_RS232C : out std_logic					--通信用クロック(16MHz)
		);
    end component;
	 
	--receiver
	component receiver
		port(
			CLK    : in  std_logic;								--クロック信号
			RST    : in  std_logic;								--リセット信号
			RXD    : in  std_logic;								--受信信号
			DREC   : out std_logic_vector(7 downto 0);	--受信データ(8bit)
			GET_EN : out std_logic								--受信可能信号(IDLE状態:1, BUSY状態:0)
		);
	 end component;
	 
	--transmitter
	component transmitter
		port(
			CLK     : in  STD_LOGIC;					--クロック信号(rs232c 16MHz)
			WR_CLK  : in  STD_LOGIC;					--クロック信号(100MHz)
			RST     : in  STD_LOGIC;					--リセット信号
			DSEND   : in  STD_LOGIC_VECTOR(7 downto 0);	--送信データ(8bit)
			WR_EN   : in  STD_LOGIC;					--送信リクエスト(1で送信開始)
			TXD     : out STD_LOGIC;					--RS232CのTXD信号(シリアル)
			SET_EN  : inout STD_LOGIC					--セット可能信号(IDLE状態:1, BUSY状態:0)
		);
	end component;

	--内部信号
	type state_t is (IDLE, REQUEST);					--状態遷移
	signal state : state_t := idle;
	signal clk100     : std_logic;						--FIFO用クロック(100MHz)
	signal clk_rs232c : std_logic;						--通信用クロック(16MHz)
	signal busy       : std_logic := '1';				--受信可能信号(IDLE状態:1, BUSY状態:0)
	signal rq         : std_logic := '0';				--送信リクエスト

begin
	--CLOCK generator
	clk_gen : clk_generator
		port map(
			CLK_IN1    => CLK,
			CLK100     => clk100,
			CLK_RS232C => clk_rs232c
		);

	--receiver
	rc : receiver
		port map(
			CLK    => clk_rs232c,
			RST    => RST,
			RXD    => RXD,
			DREC   => DATA,
			GET_EN => busy
		);
		  
	--transmitter
	tr : transmitter
		port map(
			CLK     => clk_rs232c,
			WR_CLK  => clk100,
			RST     => RST,
			DSEND   => DATA,
			WR_EN => rq,
			TXD     => TXD,
			SET_EN  => open
		  );

	process(clk_rs232c) begin
		if rising_edge(clk_rs232c) then
			case (state) is
				when IDLE =>
					if busy = '1' then	--receiverがビジー状態でないとき、送信リクエストを送る
						rq <='1';
						state <= REQUEST;
					end if;

				when REQUEST =>			--リクエストを送信してから1クロックたったら、リクエストをやめる
					rq <= '0';
					if busy = '0' then	--receiverがビジー状態になったら、idleに遷移する
						state <= IDLE;
					end if;

				when others => null;
			end case;
		end if;
	end process;
end Behavioral;