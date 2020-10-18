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
		CLK     : in  STD_LOGIC;							--�N���b�N�M��(rs232c 16MHz)
		WR_CLK  : in  STD_LOGIC;							--�N���b�N�M��(100MHz)
		RST     : in  STD_LOGIC;							--���Z�b�g�M��
		DSEND   : in  STD_LOGIC_VECTOR(7 downto 0);			--���M�f�[�^(8bit)
		WR_EN   : in  STD_LOGIC;							--���M���N�G�X�g(1�ő��M�J�n)
		TXD     : out STD_LOGIC;							--RS232C��TXD�M��(�V���A��)
		SET_EN  : inout STD_LOGIC							--�Z�b�g�\�M��(IDLE���:1, BUSY���:0)
	);
end transmitter;

architecture Behavioral of transmitter is
	--FIFO generator
	component fifo_trans
		port(
			WR_CLK : in  std_logic;                     --fifo�������ݗp�N���b�N(100MHz)
			RD_CLK : in  std_logic;                     --fofo�ǂݍ��ݗp�N���b�N(16MHz)
			RST    : in  std_logic;                     --���Z�b�g�M��
			WR_EN  : in  std_logic;                     --�������ݗL������(�L����1)
			RD_EN  : in  std_logic;                     --�ǂݍ��ݗL������(�L����1)
			DIN    : in  std_logic_vector(7 downto 0);  --�f�[�^����
			FULL   : out std_logic;                     --���^���M��(1�Ŗ��^��)
			EMPTY  : out std_logic;                     --��M��(1�ŋ�)
			DOUT   : out std_logic_vector(7 downto 0)   --�f�[�^�o��
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

	--�����M��
	type state_t is (IDLE, SEND, FIN);						--��ԑJ��
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
		  
	 --���Z�b�g�M���̔��](fifo��1�Ń��Z�b�g��������)
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