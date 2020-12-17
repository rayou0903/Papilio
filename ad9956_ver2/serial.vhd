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
		CLK 			: in  	STD_LOGIC;	--入力クロック信号(32MHz)
		RST 			: in  	STD_LOGIC;	--Papilioリセット信号(0でリセット，タクトスイッチで制御)
		RQ				: in		STD_LOGIC;	--DDS読み書きリクエスト信号(0でリクエスト，タクトスイッチで制御)
		R_OR_W		: in		STD_LOGIC;	--読み書き識別信号(0(ボタンを押す)で読み出し，1で書き込み，タクトスイッチで制御，とりあえず使用しない)
		IO_RESET		: out		STD_LOGIC;	--9(1でリセット)
		RESET			: out		STD_LOGIC;	--10(1でリセット)
		SDO      	: in  	STD_LOGIC;	--13
		SDIO 			: inout  STD_LOGIC;	--14
      SCLK 			: inout 	STD_LOGIC;	--15(シリアル通信用クロック信号 1MHz)
      CS 			: out  	STD_LOGIC;	--16(0で通信可能)
      SYNC_IN		: out		STD_LOGIC;	--19(使用しない)
		IO_UPDATE	: out		STD_LOGIC;	--20(1で更新)
		PSEL			: inout	STD_LOGIC_VECTOR(2 downto 0);	--Profile Select(21 to 23)
		TXD			: out		STD_LOGIC	--rs232c用(とりあえずledで代用，送信完了すると1になる)
      );
end serial;

architecture RTL of serial is
	--Clock Generator
	component clk_generator
		port(
			CLK_IN		: in  std_logic;	--入力クロック信号(32MHz)
			SCLK			: out std_logic	--シリアル通信用クロック信号(1MHz)
		);
	end component;

	component dds_communication
		port(
			SCLK			: in		std_logic;								--シリアル通信用クロック信号(1MHz)
			RST			: in		std_logic;								--リセット信号
			RQ				: in		std_logic;								--リクエスト信号(1でリクエスト)
			R_OR_W		: in		std_logic;								--読み書き識別信号(0で読み出し，1で書き込み，とりあえず使用しない)
			AC_REG		: in		std_logic_vector(4 downto 0);		--アクセスレジスタ
			DSEND			: in		std_logic_vector(63 downto 0);	--送信データ
			SDIO			: inout	std_logic;								--通信信号
			CS				: out		std_logic;								--チップセレクト信号(0で通信可能)
			IO_UPDATE	: out		std_logic;								--データ更新信号(1で更新)
			DGET			: out		std_logic_vector(63 downto 0);	--受信データ
			BUSY			: out		std_logic;								--ビジー信号(1でビジー状態)
			TXD			: out		std_logic
		);
	end component;
	
	
	-- state transition
	type state_t is (IDLE, DDS_REQUEST, PC_REQUEST, STANDBY);
	signal state : state_t := IDLE;
	
	--inner signal
	signal rq_dds		: std_logic := '0';	--DDS読み書きリクエスト信号(serial.vhdとdds_communication.vhdでのリクエスト信号は反転しているので注意)
	signal rq_pc		: std_logic := '0';	--PC送信リクエスト信号
	signal dsend		: std_logic_vector(63 downto 0)	:= (others => '0');
	signal busy_dds	: std_logic;
	
	--send data
	signal ac_reg		: std_logic_vector(4 downto 0)	:= "00110";
	signal pcr0			: std_logic_vector(63 downto 0)	:= "0000000000000000000000011101110010100000000111011100101100100000";
	signal pcr1			: std_logic_vector(63 downto 0)	:= "0000000000000000000000111011100101000000001110111001001001011000";
	signal pcr2			: std_logic_vector(63 downto 0)	:= "0000000000000000000001011001010111100000010110010101110101111000";
	signal pcr3			: std_logic_vector(63 downto 0)	:= "0000000000000000000001110111001010000000011101110010100010011000";
	signal pcr4			: std_logic_vector(63 downto 0)	:= "0000000000000000000010010100111100100000100101001111011110100000";
	signal pcr5			: std_logic_vector(63 downto 0)	:= "0000000000000000000010110010101111000000101100101100001011000000";
	signal pcr6			: std_logic_vector(63 downto 0)	:= "0000000000000000000011010000100001100000110100001000110111100000";
	signal pcr7			: std_logic_vector(63 downto 0)	:= "0000000000000000000011101110010100000000111011100101100100000000";
	
	--clock
	signal clk_inner_slow	: std_logic;
	signal SCLK_slow			: std_logic;
	signal cnt					: std_logic_vector(21 downto 0) := (others => '0');
	signal cnt1					: std_logic_vector(12 downto 0) := (others => '0');
	
begin
	--Clock Generator
	clk_gen : clk_generator
		port map(
			CLK_IN		=> CLK,			--クロック信号(32MHz)
			SCLK			=> SCLK			--シリアルクロック(1MHz)
		);

	dds_com : dds_communication
		port map(
			SCLK			=> SCLK,
			RST			=> RST,
			RQ				=> rq_dds,
			R_OR_W		=> R_OR_W,
			AC_REG		=> ac_reg,
			DSEND			=> dsend,
			SDIO			=> SDIO,
			CS				=> CS,
			IO_UPDATE	=> IO_UPDATE,
			DGET			=> open,
			BUSY			=> busy_dds,
			TXD			=> TXD
		);
		
	--シミュレーション用低速クロック
	--25bit 1000000000000000000000000
	--13bit 1000000000000
--	process(SCLK_slow) begin
--		if rising_edge(SCLK_slow) then
--			cnt1 <= cnt1 + '1';
--			if(cnt1 >= "1000000000000") then
--				SCLK <= '1';
--			else 
--				SCLK <= '0';
--			end if;
--		end if;
--	end process;
	
	process(SCLK, RST, RQ) begin
		IO_RESET	<= '0';
		RESET		<= '0';
		
		--初期化(起動時必ず行う)
		if(RST = '0') then
			IO_RESET		<= '1';
			RESET			<= '1';
			SYNC_IN		<= '0';
			PSEL			<= "000";
			ac_reg		<= "00110";
			
		elsif rising_edge(SCLK) then
			case state is
				when IDLE =>
					dsend <= pcr0;
					cnt	<= cnt + 1;
					if(RQ = '0') then
						PSEL		<= "000";
						ac_reg	<= "00110";
						cnt		<= (others => '0');
						state		<= DDS_REQUEST;

					elsif(cnt = "1111111111111111111111") then
						if(PSEL = "110") then
							PSEL <= "000";
						else
							PSEL <= PSEL + 1;
						end if;
					end if;
				
				when DDS_REQUEST =>
					--dds_communication.vhdにリクエスト信号を送る
					--繰り返し送信するのを防ぐため，タクトスイッチを離した瞬間にリクエストを送るようにしている
					if(RQ = '1') then
						rq_dds <= '1';
						state <= PC_REQUEST;
					end if;
				
				when PC_REQUEST =>
					rq_dds <= '0';
					if (busy_dds = '0' and rq_dds = '0') then
						ac_reg <= ac_reg + 1;
						
						--送信データの更新(次回送信するデータ)
						if (ac_reg = "00110") then
							dsend <= pcr1;
						elsif (ac_reg = "00111") then
							dsend <= pcr2;
						elsif (ac_reg = "01000") then
							dsend <= pcr3;
						elsif (ac_reg = "01001") then
							dsend <= pcr4;
						elsif (ac_reg = "01010") then
							dsend <= pcr5;
						elsif (ac_reg = "01011") then
							dsend <= pcr6;
						elsif (ac_reg = "01100") then
							dsend <= pcr7;
						else
							dsend <= (others => '0');
						end if;
						
						--アクセスレジスタが0x0Eになったら書き込み完了
						if (ac_reg = "01101") then
							--読み出しデータをPC上に表示するとき,リクエスト信号を送る，書き込みでは，すべてIDLE状態に遷移する
							if(R_OR_W = '0') then
								rq_pc <= '1';
								state <= STANDBY;
							else
								state <= IDLE;
							end if;
						else
							state <= DDS_REQUEST;
						end if;
					end if;
					
				--読み出しデータをPC上に表示するときに使用する，今回は使用しない
				when STANDBY =>
					rq_pc <= '0';
					state <= IDLE;
				
				when others => null;
			end case;
		end if;
	end process;
end RTL;