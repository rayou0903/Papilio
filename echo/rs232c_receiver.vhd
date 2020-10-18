----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:50:29 10/01/2020 
-- Design Name: 
-- Module Name:    rs232c_receiver - Behavioral 
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

entity rs232c_receiver is
	Port ( 
		CLK    : in  STD_LOGIC;							--クロック信号(clk_rs232c)
        RST    : in  STD_LOGIC;							--リセット信号
        RXD    : in  STD_LOGIC;							--RXD信号
        DREC   : out STD_LOGIC_VECTOR (7 downto 0);		--受信データ(8bit)
        GET_EN : out STD_LOGIC							--受信可能信号(IDLE状態:1, BUSY状態:0)
	);
end rs232c_receiver;

architecture Behavioral of rs232c_receiver is
	type state_t is (IDLE, START, GET);					--状態遷移
	signal state      : state_t := IDLE;
	signal drec_inner : std_logic_vector(7 downto 0);	--DRECの内部
	signal clk_cnt    : integer := 0;					--クロックカウンタ
	signal bit_cnt    : integer := 0;					--ビットカウンタ
	 
begin
    DREC <= drec_inner;
    process(CLK, RST) begin
	     if(RST = '0') then
		    GET_EN     <= '1';
		    drec_inner <= "11111111";
			clk_cnt    <= 0;
			bit_cnt    <= 0;
		    state      <= IDLE;
		      
        elsif falling_edge (CLK) then
		    case state is
				when IDLE =>
			    	GET_EN <= '1';	
			    	if(RXD = '0') then	--RXD='0'を検出
						clk_cnt <= clk_cnt + 1;
					end if;
					 
					if(clk_cnt = 3 and RXD = '0') then	--3クロック目でRXD='0'ならSTARTに遷移
					    GET_EN  <= '0';
						clk_cnt <= 0;
						state   <= START;
					end if; 
				
				when START =>
				    clk_cnt <= clk_cnt + 1;
					if(clk_cnt = 7) then	--ビットカウントが7になったときGETに遷移する
					    drec_inner <= RXD & drec_inner(7 downto 1);	--右シフト
					    clk_cnt <= 0;
						state   <= GET;
					end if;
				
				when GET =>
				    clk_cnt <= clk_cnt + 1;
					if(clk_cnt = 7) then		--クロックカウンタが7のとき
					    if(bit_cnt = 7) then	--ビットカウンタが7のときIDLEに遷移							    GET_EN <= '1';	
                     		clk_cnt <= 0;
					    	bit_cnt <= 0;
						    state <= IDLE;
						else
						    drec_inner <= RXD & drec_inner(7 downto 1);  --右シフト
						    clk_cnt <= 0;
					        bit_cnt <= bit_cnt + 1;
                		end if;						  
					end if;
				
				when others => null;
			end case;
		end if;
    end process;
end Behavioral;