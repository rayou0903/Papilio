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
		CLK  : in    STD_LOGIC;							--���̓N���b�N(32MHz)
		RST  : in    STD_LOGIC;							--���Z�b�g�M��
		RXD  : in    STD_LOGIC;							--��M�M��
		TXD  : out   STD_LOGIC;							--���M�M��
		DATA : inout STD_LOGIC_VECTOR(7 downto 0)	--����M�f�[�^
	);
end top;

architecture Behavioral of top is
	--clk_generator
	component clk_generator
		port(
			CLK_IN1    : in  std_logic;				--���̓N���b�N(32MHz)
			CLK100     : out std_logic;				--FIFO�p�N���b�N(100MHz)
			CLK_RS232C : out std_logic					--�ʐM�p�N���b�N(16MHz)
		);
    end component;
	 
	--receiver
	component receiver
		port(
			CLK    : in  std_logic;								--�N���b�N�M��
			RST    : in  std_logic;								--���Z�b�g�M��
			RXD    : in  std_logic;								--��M�M��
			DREC   : out std_logic_vector(7 downto 0);	--��M�f�[�^(8bit)
			GET_EN : out std_logic								--��M�\�M��(IDLE���:1, BUSY���:0)
		);
	 end component;
	 
	--transmitter
	component transmitter
		port(
			CLK     : in  STD_LOGIC;					--�N���b�N�M��(rs232c 16MHz)
			WR_CLK  : in  STD_LOGIC;					--�N���b�N�M��(100MHz)
			RST     : in  STD_LOGIC;					--���Z�b�g�M��
			DSEND   : in  STD_LOGIC_VECTOR(7 downto 0);	--���M�f�[�^(8bit)
			WR_EN   : in  STD_LOGIC;					--���M���N�G�X�g(1�ő��M�J�n)
			TXD     : out STD_LOGIC;					--RS232C��TXD�M��(�V���A��)
			SET_EN  : inout STD_LOGIC					--�Z�b�g�\�M��(IDLE���:1, BUSY���:0)
		);
	end component;

	--�����M��
	type state_t is (IDLE, REQUEST);					--��ԑJ��
	signal state : state_t := idle;
	signal clk100     : std_logic;						--FIFO�p�N���b�N(100MHz)
	signal clk_rs232c : std_logic;						--�ʐM�p�N���b�N(16MHz)
	signal busy       : std_logic := '1';				--��M�\�M��(IDLE���:1, BUSY���:0)
	signal rq         : std_logic := '0';				--���M���N�G�X�g

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
					if busy = '1' then	--receiver���r�W�[��ԂłȂ��Ƃ��A���M���N�G�X�g�𑗂�
						rq <='1';
						state <= REQUEST;
					end if;

				when REQUEST =>			--���N�G�X�g�𑗐M���Ă���1�N���b�N��������A���N�G�X�g����߂�
					rq <= '0';
					if busy = '0' then	--receiver���r�W�[��ԂɂȂ�����Aidle�ɑJ�ڂ���
						state <= IDLE;
					end if;

				when others => null;
			end case;
		end if;
	end process;
end Behavioral;