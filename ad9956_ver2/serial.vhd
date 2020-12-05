----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:22:50 11/06/2020 
-- Design Name: 
-- Module Name:    serial - RTL 
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

entity serial is
	Port ( 
		CLK 			: in  	STD_LOGIC;	--クロック信号(32MHz)
		RST 			: in  	STD_LOGIC;	--Papilioリセット信号(0でリセット)
		WE				: in		STD_LOGIC;	--書き込み有効入力(0で書き込み開始)
		RE				: in		STD_LOGIC;	--読み込み有効入力(0で読み込み開始)
		IO_RESET		: out		STD_LOGIC;	--9(1でリセット)
		RESET			: out		STD_LOGIC;	--10(1でリセット)
		SDO      	: in  	STD_LOGIC;	--13
		SDIO 			: inout  STD_LOGIC;	--14
      SCLK 			: out  	STD_LOGIC;	--15(シリアルクロック 25MHz)
      CS 			: out  	STD_LOGIC;	--16(0で通信可能)
      SYNC_IN		: out		STD_LOGIC;	--19(保留)
		IO_UPDATE	: out		STD_LOGIC;	--20(1で更新)
		PSEL			: out		STD_LOGIC_VECTOR(2 downto 0);	--Profile Select(21 to 23)
		TXD			: out		STD_LOGIC	--rs232c用(とりあえずledで代用)
      );
end serial;

architecture RTL of serial is
	--Clock Generator
	component clk_generator
		port(
			CLK_IN		: in  std_logic;
			CLK_INNER	: out std_logic;
			CLK_OUT		: out std_logic
		);
	end component;
	
	component dds_transmitter
		port(
			CLK	: in		std_logic;	--内部クロック
			RST	: in		std_logic;	--リセット
			WE		: in		std_logic;	--書き込み有効入力(0で書き込み開始)
			PDATA	: in		std_logic_vector(63 downto 0);	--入力データ(パラレル)
			SDIO	: inout	std_logic;	--出力データ(シリアル)
			BUSY	: out		std_logic;	--ビジー出力(1がビジー状態)
			CS		: out		std_logic;
			IO_UPDATE : out std_logic
		);
	end component;
	
	component dds_receiver
		port(
			CLK	: in		STD_LOGIC;
			RST	: in		STD_LOGIC;
			RE		: in		STD_LOGIC;	--読み込み有効入力(0で読み込み開始)
			IDATA	: in		STD_LOGIC_VECTOR (7 downto 0);	--命令サイクル(8bit)
			SDIO	: inout	STD_LOGIC;
			BUSY	: out		STD_LOGIC;
			CS		: out		STD_LOGIC;
			PDATA	: out		STD_LOGIC_VECTOR
		);
	end component;
	
	--inner signal
	type state_t is (IDLE, TR_RQ, RC_RQ);
	signal state		: state_t := IDLE;
	signal clk_inner	: std_logic;	--内部クロック(200MHz)
	signal pdata		: std_logic_vector(63 downto 0) := "1000011000010000000000000000010111010001011101000101110100011000";	--64ビット
	signal ac_reg		: std_logic_vector(7 downto 0) := "00000110";	
	signal tr_busy		: std_logic;
	signal rc_busy		: std_logic;
	signal we_inner	: std_logic := '1';
	signal rc_inner	: std_logic := '1';
	signal get_data	: std_logic_vector(55 downto 0) := "00000000000000000000000000000000000000000000000000000000";
	--signal sclk_inner : std_logic;
	
begin
	--Clock Generator
	clk_gen : clk_generator
		port map(
			CLK_IN		=> CLK,			--クロック信号(32MHz)
			CLK_INNER	=> clk_inner,	--内部クロック(200MHz)
			CLK_OUT		=> SCLK			--シリアルクロック(25MHz)
		);
		
	dds_tr : dds_transmitter
		port map(
			CLK	=> clk_inner,
			RST	=> RST,
			WE		=> we_inner,
			PDATA	=> pdata,
			SDIO	=> SDIO,
			BUSY	=> tr_busy,
			CS		=> CS,
			IO_UPDATE => IO_UPDATE
		);
		
--	dds_rc : dds_receiver
--		port map(
--			CLK	=> clk_inner,
--			RST	=> RST,
--			RE		=> rc_inner,
--			IDATA	=> ac_reg,
--			SDIO	=> SDIO,
--			BUSY	=> rc_busy,
--			CS		=> CS,
--			PDATA => get_data
--		);

--	dds_com : dds_commutication
--		port map(
--			CLK	=> clk_inner,
--			RST	=> RST,
--			WE		=> we_inner,
--			PDATA	=> pdata,
--			SDIO	=> SDIO,
--			BUSY	=> tr_busy,
--			CS		=> CS,
--			IO_UPDATE => IO_UPDATE
--		);
	
	process(clk_inner, RST, WE, RE) begin
		IO_RESET	<= '0';
		RESET		<= '0';
		if(RST = '0') then
			IO_RESET		<= '1';
			RESET			<= '1';
			SYNC_IN		<= '0';
			PSEL			<= "000";
			
		elsif falling_edge(clk_inner) then
			case state is
				when IDLE =>
					we_inner <= '1';
					rc_inner <= '1';
					if (WE = '0') then
						we_inner <= '0';
						state <= TR_RQ;
					elsif (RE = '0') then
						rc_inner <= '0';
						state <= RC_RQ;
					end if;
				
				when TR_RQ =>
					we_inner <= '1';
					if (tr_busy = '0') then
						state <= IDLE;
					end if;
				
				when RC_RQ =>
					rc_inner <= '1';
					if (rc_busy = '0') then
						state <= IDLE;
					end if;
				
				when others => null;
			end case;
		end if;
	
	end process;
	
end RTL;

