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
		RQ				: in		STD_LOGIC;	--DDS読み書きリクエスト信号(0でリクエスト)
		R_OR_W		: in		STD_LOGIC;	--読み書き識別信号(0(ボタンを押す)で読み出し，1で書き込み)
		IO_RESET		: out		STD_LOGIC;	--9(1でリセット)
		RESET			: out		STD_LOGIC;	--10(1でリセット)
		SDO      	: in  	STD_LOGIC;	--13
		SDIO 			: inout  STD_LOGIC;	--14
      SCLK 			: inout 	STD_LOGIC;	--15(シリアルクロック 1MHz)
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
			--CLK_INNER	: out std_logic;
			SCLK			: out std_logic
		);
	end component;

	component dds_communication
		port(
			SCLK			: in		std_logic;								--シリアル通信用クロック信号(25MHz)
			RST			: in		std_logic;								--リセット信号
			RQ				: in		std_logic;								--リクエスト信号(1でリクエスト)
			R_OR_W		: in		std_logic;								--読み書き識別信号(0で読み出し，1で書き込み)
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
	
	--inner signal
	type state_t is (IDLE, DDS_REQUEST, PC_REQUEST, STANDBY);
	signal state		: state_t := IDLE;
	signal clk_rs232c	: std_logic;	--RS232C用クロック(16MHz)

	signal rq_dds		: std_logic := '0';	--DDS読み書きリクエスト信号(serial.vhdとdds_communication.vhdでのリクエスト信号は反転しているので注意)
	signal rq_pc		: std_logic := '0';	--PC送信リクエスト信号
	--signal r_or_w		: std_logic;	--読み書き識別信号(0で読み出し，1で書き込み)
	signal ac_reg		: std_logic_vector(4 downto 0)	:= "00110";
	signal dsend		: std_logic_vector(63 downto 0)	:= "0000000000000000000101110100010111010001011101000110101100010000";
	signal dget			: std_logic_vector(63 downto 0)	:= (others => '0');
	signal busy_dds	: std_logic;
	signal busy_pc		: std_logic;
	signal data_inner	: std_logic_vector(63 downto 0)	:= (others => '0');
	
	--clock
	signal clk_inner_slow	: std_logic;
	signal SCLK_slow			: std_logic;
	signal cnt1					: std_logic_vector(24 downto 0) := (others => '0');
	
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
			DGET			=> dget,
			BUSY			=> busy_dds,
			TXD			=> TXD
		);
	--25bit 1000000000000000000000000
	--13bit 1000000000000
--	process(SCLK_slow) begin
--		if rising_edge(SCLK_slow) then
--			cnt1 <= cnt1 + '1';
--			if(cnt1 >= "1000000000000000000000000") then
--				SCLK <= '1';
--			else 
--				SCLK <= '0';
--			end if;
--		end if;
--	end process;


	data_inner <= dget;
	
	process(SCLK, RST, RQ) begin
		IO_RESET	<= '0';
		RESET		<= '0';
		if(RST = '0') then
			IO_RESET		<= '1';
			RESET			<= '1';
			SYNC_IN		<= '0';
			PSEL			<= "000";
			--TXD <= '0';
			
		elsif (falling_edge(SCLK)) then
			case state is
				when IDLE =>
					if(RQ = '0') then
						state <= DDS_REQUEST;
					end if;
				
				when DDS_REQUEST =>
					if(RQ = '1') then
						rq_dds <= '1';
						state <= PC_REQUEST;
					end if;
				
				when PC_REQUEST =>
					if (busy_dds = '0') then
						rq_dds <= '0';
						if(R_OR_W = '0') then
							rq_pc <= '1';
							state <= STANDBY;
						else
							state <= IDLE;
						end if;		
					end if;
					
				when STANDBY =>
					rq_pc <= '0';
					state <= IDLE;
				
				when others => null;
			end case;
		end if;
	end process;
end RTL;