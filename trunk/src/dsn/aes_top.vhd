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
--use IEEE.NUMERIC_STD.ALL;
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
				ENC_VALID_I : in  STD_LOGIC;
				ENC_READY_O : out  STD_LOGIC;
				ENC_DATA_O : out  STD_LOGIC_VECTOR (7 downto 0);
				ENC_VALID_O : out  STD_LOGIC;
				
				DEC_DATA_I : in  STD_LOGIC_VECTOR (7 downto 0);
				DEC_VALID_I : in  STD_LOGIC;
				DEC_READY_O : out  STD_LOGIC;
				DEC_DATA_O : out  STD_LOGIC_VECTOR (7 downto 0);
				DEC_VALID_O : out  STD_LOGIC);
end aes_top;

architecture Behavioral of aes_top is
	
	component aes_enc
   	port
                  (
                  KEY_SIZE             :  in    integer range 0 to 2 := 0;            -- 0-128; 1-192; 2-256
                  DATA_I               :  in    std_logic_vector(7 downto 0);
                  VALID_DATA_I         :  in    std_logic;
                  KEY_I                :  in    std_logic_vector(7 downto 0);
                  VALID_KEY_I          :  in    std_logic;
                  RESET_I              :  in    std_logic;
                  CLK_I                :  in    std_logic;
                  CE_I                 :  in    std_logic;

                  KEY_READY_O          :  out   std_logic;

                  VALID_O              :  out   std_logic;
                  DATA_O               :  out   std_logic_vector(7 downto 0)
                  );

	end component;
	
	component aes_dec is
   	port
                  (
                  KEY_SIZE             :  in    integer range 0 to 2 := 2;            -- 0-128; 1-192; 2-256
                  DATA_I               :  in    std_logic_vector(7 downto 0);
                  VALID_DATA_I         :  in    std_logic;
                  KEY_I                :  in    std_logic_vector(7 downto 0);
                  VALID_KEY_I          :  in    std_logic;
                  RESET_I              :  in    std_logic;
                  CLK_I                :  in    std_logic;
                  CE_I                 :  in    std_logic;

                  KEY_READY_O          :  out   std_logic;

                  VALID_O              :  out   std_logic;
                  DATA_O               :  out   std_logic_vector(7 downto 0)
                  );

	end component;
	

	constant	NUM_ENC : integer := 11;
	constant	NUM_DEC : integer := 11;

	
	
	type		enc_byte_array is array (NUM_ENC-1 downto 0) of std_logic_vector(7 downto 0);
	type		enc_bit_array is array (NUM_ENC-1 downto 0) of std_logic;
	type		dec_byte_array is array (NUM_DEC-1 downto 0) of std_logic_vector(7 downto 0);
	type		dec_bit_array is array (NUM_DEC-1 downto 0) of std_logic;
	type		byte_shifter is array (1 downto 0) of std_logic_vector(7 downto 0);
	
	signal	i_KEY_SIZE : integer range 0 to 2;
	
	signal	enc_data_in : enc_byte_array;
	signal	enc_data_out : enc_byte_array;
	

	signal	enc_valid_in : enc_bit_array;
	signal	enc_valid_out, last_enc_valid_out : enc_bit_array;
	signal	enc_key_ready : enc_bit_array;
	signal	n_enc_busy, enc_busy : enc_bit_array;
	signal	enc_check : enc_bit_array;
	signal 	cur_enc_in : integer range 0 to NUM_ENC-1;
	signal 	cur_enc_out : integer range 0 to NUM_ENC-1;
	signal	last_ENC_VALID_I : std_logic_vector(1 downto 0);
	signal	last_ENC_DATA_I : byte_shifter;
	signal	n_got_new_enc, got_new_enc : std_logic;
	
	
	signal	dec_data_in : dec_byte_array;
	signal	dec_data_out : dec_byte_array;
	
	
	signal	dec_valid_in : dec_bit_array;
	signal	dec_valid_out, last_dec_valid_out : dec_bit_array;
	signal	dec_key_ready : dec_bit_array;	
	signal	n_dec_busy, dec_busy : dec_bit_array;
	signal	dec_check : dec_bit_array;
	signal	cur_dec_in : integer range 0 to NUM_DEC-1;
	signal	cur_dec_out : integer range 0 to NUM_DEC-1;
	signal	last_DEC_VALID_I : std_logic_vector(1 downto 0);
	signal	last_DEC_DATA_I : byte_shifter;
	signal	n_got_new_dec, got_new_dec : std_logic;

begin	

	EncGen : for k in NUM_ENC - 1 downto 0 generate
	begin
		enc_gen: aes_enc
			port map	(
				KEY_SIZE	=> i_KEY_SIZE,
				DATA_I => enc_data_in(k),
				VALID_DATA_I => enc_valid_in(k),
				KEY_I => KEY_I,
				VALID_KEY_I => KEY_VALID_I,
				RESET_I => RESET_I,
				CLK_I => CLK_I,
				CE_I => CE_I,
				KEY_READY_O => enc_key_ready(k),
				VALID_O => enc_valid_out(k),
				DATA_O => enc_data_out(k)
			);
	end generate;
	
	DecGen : for k in NUM_DEC - 1 downto 0 generate
	begin
		dec_gen: aes_dec
			port map	(
				KEY_SIZE	=> i_KEY_SIZE,
				DATA_I => dec_data_in(k),
				VALID_DATA_I => dec_valid_in(k),
				KEY_I => KEY_I,
				VALID_KEY_I => KEY_VALID_I,
				RESET_I => RESET_I,
				CLK_I => CLK_I,
				CE_I => CE_I,
				KEY_READY_O => dec_key_ready(k),
				VALID_O => dec_valid_out(k),
				DATA_O => dec_data_out(k)
			);
	end generate;
	
	clk_proc : process (RESET_I, CLK_I)
	begin
		if( RESET_I = '1' ) then
			enc_check <= (others => '1');
			dec_check <= (others => '1');
			
			enc_busy <= (others => '0');
			got_new_enc <= '0';
			last_ENC_VALID_I <= (others => '0');
			last_ENC_DATA_I <= (others => (others => '0'));
			
			dec_busy <= (others => '0');
			got_new_dec <= '0';
			last_DEC_VALID_I <= (others => '0');
			last_DEC_DATA_I <= (others => (others => '0'));
		elsif rising_edge(CLK_I) then
			enc_busy <= n_enc_busy;
			got_new_enc <= n_got_new_enc;			
			last_ENC_VALID_I <= last_ENC_VALID_I(0) & ENC_VALID_I;
			last_ENC_DATA_I <= last_ENC_DATA_I(0) & ENC_DATA_I;
			last_enc_valid_out <= enc_valid_out;
			
			dec_busy <= n_dec_busy;
			got_new_dec <= n_got_new_dec;			
			last_DEC_VALID_I <= last_DEC_VALID_I(0) & DEC_VALID_I;
			last_DEC_DATA_I <= last_DEC_DATA_I(0) & DEC_DATA_I;
			last_dec_valid_out <= dec_valid_out;
		end if;
	end process;
		
	
	i_KEY_SIZE <= 	0 when KEY_SIZE_I = "00" else
			1 when KEY_SIZE_I = "01" else
			2;
						
	ENC_READY_O <= '1' when (enc_key_ready = enc_check and not(enc_busy = enc_check)) 
						else '0';
	DEC_READY_O <= '1' when (dec_key_ready = dec_check and not(dec_busy = dec_check)) 
						else '0';
	ENC_DATA_O <= enc_data_out(cur_enc_out);
	ENC_VALID_O <= enc_valid_out(cur_enc_out);
	
	DEC_DATA_O <= dec_data_out(cur_dec_out);
	DEC_VALID_O <= dec_valid_out(cur_dec_out);


	n_got_new_enc <= '1' when last_ENC_VALID_I = "01" else '0';
	
	EncInGen : for k in NUM_ENC - 1 downto 0 generate
	begin
		enc_data_in(k) <= last_ENC_DATA_I(1) when k = cur_enc_in else (others => '0');
		enc_valid_in(k) <= last_ENC_VALID_I(1) when k = cur_enc_in else '0';		
		dec_data_in(k) <= last_DEC_DATA_I(1) when k = cur_dec_in else (others => '0');
		dec_valid_in(k) <= last_DEC_VALID_I(1) when k = cur_dec_in else '0';		
	end generate;
	
	enc_process : process (enc_busy, got_new_enc, enc_valid_out, last_enc_valid_out)
	begin
		for k in 0 to NUM_ENC-1 loop 	
			if( k = 0 ) then
				if( enc_busy(k) = '0' and got_new_enc = '1' ) then				
					n_enc_busy(k) <= '1';
					cur_enc_in <= 0;				
				elsif( enc_valid_out(k) = '0' and last_enc_valid_out(k) = '1' ) then
					n_enc_busy(k) <= '0';
				else
					n_enc_busy(k) <= enc_busy(k);
				end if;	
			else
				if( enc_busy(k downto 0) = '0' & enc_check(k-1 downto 0) and got_new_enc = '1' ) then		
					n_enc_busy(k) <= '1';
					cur_enc_in <= k;				
				elsif( enc_valid_out(k) = '0' and last_enc_valid_out(k) = '1' ) then
					n_enc_busy(k) <= '0';
				else
					n_enc_busy(k) <= enc_busy(k);
				end if;					
			end if;

			if( enc_valid_out(k) = '1' ) then
				cur_enc_out <= k;
			end if;
		end loop;
	end process;
	
	n_got_new_dec <= '1' when last_DEC_VALID_I = "01" else '0';
	
	dec_process : process (dec_busy, got_new_dec, dec_valid_out, last_dec_valid_out)
	begin
		for k in 0 to NUM_DEC-1 loop 	
			if( k = 0 ) then
				if( dec_busy(k) = '0' and got_new_dec = '1' ) then				
					n_dec_busy(k) <= '1';
					cur_dec_in <= 0;				
				elsif( dec_valid_out(k) = '0' and last_dec_valid_out(k) = '1' ) then
					n_dec_busy(k) <= '0';
				else
					n_dec_busy(k) <= dec_busy(k);
				end if;	
			else
				if( dec_busy(k downto 0) = '0' & dec_check(k-1 downto 0) and got_new_dec = '1' ) then		
					n_dec_busy(k) <= '1';
					cur_dec_in <= k;				
				elsif( dec_valid_out(k) = '0' and last_dec_valid_out(k) = '1' ) then
					n_dec_busy(k) <= '0';
				else
					n_dec_busy(k) <= dec_busy(k);
				end if;					
			end if;

			if( dec_valid_out(k) = '1' ) then
				cur_dec_out <= k;
			end if;
		end loop;
	end process;
end Behavioral;

