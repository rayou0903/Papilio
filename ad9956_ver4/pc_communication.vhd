----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:39:54 12/09/2020 
-- Design Name: 
-- Module Name:    pc_communication - Behavioral 
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

entity pc_communication is
	Port ( 
		CLK			: in		STD_LOGIC;
		CLK_INNER	: in		STD_LOGIC;
		RST			: in		STD_LOGIC;
		RQ				: in		STD_LOGIC;
		TXD			: out		STD_LOGIC;
		DATA			: inout	STD_LOGIC_VECTOR (55 downto 0);
		BUSY			: inout	STD_LOGIC
	);
end pc_communication;

architecture Behavioral of pc_communication is
	component pc_transmitter
		port(
			CLK			: in		std_logic;								--クロック信号(RS232C用 100MHz)
			CLK_INNER	: in		std_logic;								--クロック信号(内部クロック200MHz)
			RST			: in		std_logic;								--リセット信号
			WR_EN			: in		std_logic;								--リクエスト信号(1でリクエスト)
			TXD			: out		std_logic;								--送信信号
			DSEND			: in		std_logic_vector(7 downto 0);		--送受信データ
			SET_EN		: inout	std_logic								--セット可能信号(IDLE状態:0, BUSY状態:1)
		);
	end component;

	--inner signal
	type state_t is (IDLE, STANDBY, REQUEST);
	signal state			: state_t := IDLE;
	signal dsend			: std_logic_vector(7 downto 0) := "00000000";
	signal wr_rq			: std_logic := '0';
	signal bit_pointer	: integer := 55;

begin
	pc_tr : pc_transmitter
		port map(
			CLK			=> CLK,
			CLK_INNER	=> CLK_INNER,
			RST			=> RST,
			WR_EN			=> wr_rq,
			TXD			=> TXD,
			DSEND			=> dsend,
			SET_EN		=> BUSY
		);
		
	process(CLK_INNER, RST, RQ) begin
		if(RST = '0') then
			dsend			<= "00000000";
			wr_rq			<= '0';
			bit_pointer	<= 55;
			
		elsif rising_edge(CLK_INNER) then
			case state is
				when IDLE =>
					if(RQ = '1') then
						state <= STANDBY;
					end if;
				
				when STANDBY =>
					if(BUSY = '0') then
						if(DATA(bit_pointer) = '0') then
								dsend <= "00110000";
						elsif(DATA(bit_pointer) = '1') then
								dsend <= "00110001";
						end if;
						wr_rq <= '1';
						state <= REQUEST;
					end if;
				
				when REQUEST =>
					bit_pointer <= bit_pointer - 1;
					wr_rq <= '0';
					if (bit_pointer = 0) then
						bit_pointer <= 55;
						state <= IDLE;
					else
						state <= STANDBY;
					end if;
				
				when others => null;
			end case;
		end if;
	end process;
end Behavioral;

