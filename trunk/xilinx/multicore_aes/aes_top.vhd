----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:52:38 03/28/2010 
-- Design Name: 
-- Module Name:    aes_top - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library WORK;
use WORK.aes_pkg.ALL;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity aes_top is
    Port ( 
				RESET_I : in STD_LOGIC;
				CLK_I : in STD_LOGIC;
				CE_I : in STD_LOGIC;
				
				KEY_SIZE_I : in std_logic_vector(1 downto 0);
				KEY_I : in  STD_LOGIC_VECTOR (7 downto 0);
				KEY_VALID_I : in  STD_LOGIC;
				
				ENC_DATA_I : in  STD_LOGIC_VECTOR (7 downto 0);
				ENC_DATA_VALID_I : in  STD_LOGIC;
				ENC_READY_O : out  STD_LOGIC;
				ENC_DATA_O : out  STD_LOGIC_VECTOR (7 downto 0);
				ENC_DATA_VALID_O : out  STD_LOGIC;
				
				DEC_DATA_I : in  STD_LOGIC_VECTOR (7 downto 0);
				DEC_VALID_I : in  STD_LOGIC;
				DEC_READY_O : out  STD_LOGIC;
				DEC_DATA_O : out  STD_LOGIC_VECTOR (7 downto 0);
				DEC_DATA_VALID_0 : out  STD_LOGIC);
end aes_top;

architecture Behavioral of aes_top is
	constant	NUM_ENC : integer := 1;
	constant	NUM_DEC : integer := 1;
begin
	signal	i_KEY_SIZE : integer range 0 to 2;
	
	type		enc_byte_array is array (NUM_ENC-1 downto 0) of std_logic_vector(7 downto 0);
	signal	enc_data_in : enc_byte_array;
	signal	enc_data_out : enc_byte_array;
	
	type		enc_bit_array is std_logic_vector(NUM_ENC-1 downto 0);
	signal	enc_valid_in : enc_bit_array;
	signal	enc_valid_out : enc_bit_array;
	signal	enc_key_ready : enc_bit_array;
	signal	enc_busy : enc_bit_array;
	signal	enc_busy_check : enc_bit_array;
	signal  	cur_enc_in : integer range 0 to NUM_ENC-1;
	signal  	cur_enc_out : integer range 0 to NUM_ENC-1;
	
	type		dec_byte_array is array (NUM_DEC-1 downto 0) of std_logic_vector(7 downto 0);
	signal	dec_data_in : dec_byte_array;
	signal	dec_data_out : dec_byte_array;
	
	type		dec_bit_array is std_logic_vector(NUM_DEC-1 downto 0);
	signal	dec_valid_in : dec_bit_array;
	signal	dec_valid_out : dec_bit_array;
	signal	dec_key_ready : dec_bit_array;	
	signal	dec_busy : dec_bit_array;
	signal	dec_busy_check : dec_bit_array;
	signal	curr_dec : integer range 0 to NUM_DEC-1;
	
	EncGen : for k in NUM_ENC - 1 downto 0 generate
	begin
		enc_gen: aes_enc
			generic map (
				KEY_SIZE	=> i_KEY_SIZE
				)
			port map	(
				DATA_I => enc_data_in[k],
				VALID_DATA_I => enc_valid_in(k),
				KEY_I => KEY_I,
				VALID_KEY_I => VALID_KEY_I,
				RESET_I => RESET_I,
				CLK_I => CLK_I,
				CE_I => CE_I,
				KEY_READY_O => enc_key_ready(k),
				VALID_O => enc_valid_out(k),
				DATA_O => enc_data_out[k]
			);
	end
	
	DecGen : for k in NUM_DEC - 1 downto 0 generate
	begin
		dec_gen: aes_dec
			generic map (
				KEY_SIZE	=> i_KEY_SIZE
				)
			port map	(
				DATA_I => dec_data_in[k],
				VALID_DATA_I => dec_valid_in(k),
				KEY_I => KEY_I,
				VALID_KEY_I => VALID_KEY_I,
				RESET_I => RESET_I,
				CLK_I => CLK_I,
				CE_I => CE_I,
				KEY_READY_O => dec_key_ready(k),
				VALID_O => dec_valid_out(k),
				DATA_O => dec_data_out[k]
			);
	end
	clk_proc : process (RESET_I, CLK_I)
	begin
		if( RESET_I = '1' ) then
			enc_busy_check <= (others => '1');
			dec_busy_check <= (others => '1');
			n_enc_busy <= (others => '0');
			
		elsif rising_edge(CLK_I) then
			enc_busy <= n_enc_busy;
			got_new_enc <= n_got_new_enc;			
			enc_data_in(cur_enc_in) <= ENC_DATA_I;
			enc_valid_in(cur_enc_in) <= ENC_VALID_I;
			ENC_DATA_O <= enc_data_out(cur_enc_out);
			ENC_VALID_O <= enc_valid_out(cur_enc_out);
			
		end if;
	end process;
		
	
	i_KEY_SIZE <= 	0 when KEY_SIZE_I = "00" else
						1 when KEY_SIZE_I = "01" else
						2;
						
	ENC_READY_O <= '1' when (enc_key_ready = enc_check and not(enc_busy = enc_busy_check)) 
						else '0';
	DEC_READY_O <= '1' when (dec_key_ready = dec_check and not(dec_busy = dec_busy_check)) 
						else '0';
	
	enc_process : process (enc_busy, got_new_enc)
	begin
		BusyGen : for k in NUM_ENC - 1 downto 0 generate
		begin
			if( enc_busy(k) = '0' and got_new_enc = '1' ) then
				n_enc_busy(k) <= '1';
				n_got_new_enc <= 0;
				cur_enc <= k;
			end if;			
		end
	end process;
	
end Behavioral;

