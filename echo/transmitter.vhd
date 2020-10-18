----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:16:05 10/01/2020 
-- Design Name: 
-- Module Name:    transmitter - Behavioral 
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

entity transmitter is
	Port ( 
		CLK     : in  STD_LOGIC;							--クロック信号(rs232c 16MHz)
		WR_CLK  : in  STD_LOGIC;							--クロック信号(100MHz)
		RST     : in  STD_LOGIC;							--リセット信号
		DSEND   : in  STD_LOGIC_VECTOR(7 downto 0);			--送信データ(8bit)
		WR_EN   : in  STD_LOGIC;							--送信リクエスト(1で送信開始)
		TXD     : out STD_LOGIC;							--RS232CのTXD信号(シリアル)
		SET_EN  : inout STD_LOGIC							--セット可能信号(IDLE状態:1, BUSY状態:0)
	);
end transmitter;

architecture Behavioral of transmitter is
	--FIFO generator
	component fifo_trans
		port(
			WR_CLK : in  std_logic;                     --fifo書き込み用クロック(100MHz)
			RD_CLK : in  std_logic;                     --fofo読み込み用クロック(16MHz)
			RST    : in  std_logic;                     --リセット信号
			WR_EN  : in  std_logic;                     --書き込み有効入力(有効時1)
			RD_EN  : in  std_logic;                     --読み込み有効入力(有効時1)
			DIN    : in  std_logic_vector(7 downto 0);  --データ入力
			FULL   : out std_logic;                     --満タン信号(1で満タン)
			EMPTY  : out std_logic;                     --空信号(1で空)
			DOUT   : out std_logic_vector(7 downto 0)   --データ出力
		);
	end component;
	
	--rs232c_transmitter
	component rs232c_transmitter
		port(
			CLK     : in  std_logic;
			RST     : in  std_logic;
			DSEND   : in  std_logic_vector(7 downto 0);
			SEND_RQ : in  std_logic;
			TXD     : out std_logic;
			SET_EN  : out std_logic
		);
	end component;

	--内部信号
	type state_t is (IDLE, SEND, FIN);						--状態遷移
	signal state       : state_t;
	signal send_rq     : std_logic := '0';
	signal dsend_fifo  : std_logic_vector(7 downto 0);
	signal busy_tr     : std_logic;
	signal rst_fifo    : std_logic := '0';
	signal rd_en       : std_logic := '0';
	signal empty       : std_logic;
	 
begin
    --FIFO generator
	fifo_tr : fifo_trans
		port map(
			WR_CLK => WR_CLK,
			RD_CLK => CLK,
			RST    => rst_fifo,
			WR_EN  => WR_EN,
			RD_EN  => rd_en,
			DIN    => DSEND,
			FULL   => SET_EN,
			EMPTY  => empty,
			DOUT   => dsend_fifo
		);

	--rs232c_transmitter
	rs232c_tr : rs232c_transmitter
		port map(
		    CLK		=> CLK,
			RST		=> RST,
			DSEND	=> dsend_fifo,
			SEND_RQ	=> send_rq,
			TXD		=> TXD,
			SET_EN	=> busy_tr
		);
		  
	 --リセット信号の反転(fifoは1でリセットがかかる)
	process(RST) begin
		if(RST = '1') then
			rst_fifo <= '0';
		elsif(RST = '0') then
			rst_fifo <= '1';
		end if;
	end process;
	 
	process(CLK) begin
		if rising_edge(CLK) then
			case state is
				when IDLE =>
					if (empty = '0') then
						rd_en <= '1';
						state <= SEND;
					else
						rd_en   <= '0';
						send_rq <= '0';
					end if;
					 
				when SEND =>
					send_rq <= '1';
					if busy_tr = '0' then
						rd_en	<= '0';
						send_rq	<= '0';
						state	<= IDLE;
					end if;
				
				when others => null;
			end case;
		end if;
	end process;
end Behavioral;