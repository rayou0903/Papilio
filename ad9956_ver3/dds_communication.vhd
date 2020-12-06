----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:26:10 12/05/2020 
-- Design Name: 
-- Module Name:    dds_communication - Behavioral 
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

entity dds_communication is
	Port ( 
		CLK			: in		STD_LOGIC;
		RST			: in		STD_LOGIC;
		RQ				: in		STD_LOGIC;
		R_OR_W		: in		STD_LOGIC;
		AC_REG		: in  	STD_LOGIC_VECTOR (3 downto 0);
		DSEND			: in		STD_LOGIC_VECTOR (55 downto 0);
		SDIO			: inout	STD_LOGIC;
		CS 			: out		STD_LOGIC;
		IO_UPDATE	: out		STD_LOGIC;
		DGET			: out		STD_LOGIC_VECTOR (55 downto 0);
		BUSY			: out		STD_LOGIC
	);
end dds_communication;

architecture Behavioral of dds_communication is
	--innner signal
	type state_t is (IDLE, INSTRUCTION, GET, SEND, UPDATE);
	signal state		: state_t := IDLE;
	signal sdio_inner : std_logic_vector(55 downto 0) := "00000000000000000000000000000000000000000000000000000000";
	signal data : std_logic_vector(55 downto 0) := "00000000000000000000000000000000000000000000000000000000";
	signal bit_cnt		: integer := 0;
	signal clk_cnt		: integer := 0;
	
begin
	--SDIO <= sdio_inner(55);
	process(CLK, RST) begin
		if(RST = '0') then
			CS				<= '1';
			IO_UPDATE 	<= '0';
			DGET			<= "00000000000000000000000000000000000000000000000000000000";
			BUSY			<= '0';
			sdio_inner <= "00000000000000000000000000000000000000000000000000000000";
			bit_cnt <= 0;
			clk_cnt <= 0;
			--SDIO <= 'Z';
			
		elsif falling_edge(CLK) then
			case state is
				when IDLE =>
					if(RQ = '1') then
						CS		<= '0';
						sdio_inner <= R_OR_W & "000" & AC_REG & (55-8 downto 0 => '0');
						
						BUSY	<= '1';
						state	<= INSTRUCTION;
					else
						CS		<= '1';
						sdio_inner <= "00000000000000000000000000000000000000000000000000000000";
						BUSY	<= '0';
						--SDIO <= 'Z';
					end if;
					
				when INSTRUCTION =>
					SDIO <= sdio_inner(55);
					if(bit_cnt = 7 and clk_cnt = 7) then
						--CS				<= '1';
						--IO_UPDATE 	<= '1';
						bit_cnt <= 0;		--ビットカウンタをリセット
						clk_cnt <= 0;		--クロックカウンタをリセット
						--状態遷移
						if(R_OR_W = '0') then
							--SDIO <= 'Z';
							state	<= GET;
						elsif(R_OR_W = '1') then
							state	<= SEND;
						else
							state <= IDLE;
						end if;
						
					elsif(clk_cnt = 7) then
						clk_cnt   <= 0;										--クロックカウンタをリセット
						bit_cnt   <= bit_cnt + 1;							--ビットカウンタを1増やす
						sdio_inner <= sdio_inner(54 downto 0) & '0';	--1ビット左シフト
					else
						clk_cnt   <= clk_cnt + 1;
					end if;
				
				when GET =>
					--SDIO <= 'Z';
					data(0) <= SDIO;
					if(bit_cnt = 55 and clk_cnt = 7) then
						CS				<= '1';
						IO_UPDATE 	<= '1';
						bit_cnt <= 0;		--ビットカウンタをリセット
						clk_cnt <= 0;		--クロックカウンタをリセット
						DGET <= data;
						state   <= IDLE;	--アイドル状態に遷移
					elsif(clk_cnt = 7) then
						clk_cnt	<= 0;									--クロックカウンタをリセット
						bit_cnt	<= bit_cnt + 1;					--ビットカウンタを1増やす
						--DGET		<= DGET(54 downto 0) & SDIO;
						data <= data(54 downto 0) & SDIO;	--1ビット左シフト
					else
						clk_cnt   <= clk_cnt + 1;
					end if;
					
				when SEND =>
					state	<= UPDATE;

				when UPDATE =>
					state	<= IDLE;

				when others => null;
			end case;
		end if;
	end process;
end Behavioral;