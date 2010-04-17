onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -radix hexadecimal /aes_top_tb/clk
add wave -noupdate -format Logic -radix hexadecimal /aes_top_tb/reset
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/key_size
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/key
add wave -noupdate -format Logic -radix hexadecimal /aes_top_tb/key_valid
add wave -noupdate -format Logic -radix hexadecimal /aes_top_tb/enc_ready
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/enc_data_i
add wave -noupdate -format Logic -radix hexadecimal /aes_top_tb/enc_valid_i
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/enc_data_o
add wave -noupdate -format Logic -radix hexadecimal /aes_top_tb/enc_valid_o
add wave -noupdate -format Logic -radix hexadecimal /aes_top_tb/dec_ready
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/dec_data_i
add wave -noupdate -format Logic -radix hexadecimal /aes_top_tb/dec_valid_i
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/dec_data_o
add wave -noupdate -format Logic -radix hexadecimal /aes_top_tb/dec_valid_o
add wave -noupdate -format Literal /aes_top_tb/dut/cur_enc_in
add wave -noupdate -format Literal /aes_top_tb/dut/cur_enc_out
add wave -noupdate -format Literal /aes_top_tb/dut/n_enc_busy
add wave -noupdate -format Literal /aes_top_tb/dut/enc_busy
add wave -noupdate -format Literal /aes_top_tb/dut/enc_valid_in
add wave -noupdate -format Literal /aes_top_tb/dut/enc_valid_out
add wave -noupdate -format Logic /aes_top_tb/dut/n_got_new_enc
add wave -noupdate -format Logic /aes_top_tb/dut/got_new_enc
add wave -noupdate -format Logic /aes_top_tb/dut/enc_valid_i
add wave -noupdate -format Logic /aes_top_tb/dut/last_enc_valid_i
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/dut/encgen__0/enc_gen/data_i
add wave -noupdate -format Logic /aes_top_tb/dut/encgen__0/enc_gen/valid_data_i
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/dut/encgen__0/enc_gen/kexp0/key_expan0
add wave -noupdate -format Literal /aes_top_tb/dut/encgen__0/enc_gen/data_o
add wave -noupdate -format Literal /aes_top_tb/dut/encgen__0/enc_gen/i_round
add wave -noupdate -format Literal -radix unsigned /aes_top_tb/dut/encgen__0/enc_gen/v_calculation_cntr
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/dut/encgen__0/enc_gen/v_data_column
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/dut/encgen__0/enc_gen/v_key_column
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/dut/encgen__0/enc_gen/v_ram_in0
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/dut/encgen__0/enc_gen/t_state_ram0
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/dut/encgen__0/enc_gen/state_table1
add wave -noupdate -format Logic /aes_top_tb/dut/encgen__0/enc_gen/get_key
add wave -noupdate -format Literal -radix hexadecimal /aes_top_tb/dut/encgen__0/enc_gen/v_key_numb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3650000 ps} 0} {{Cursor 2} {5590000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {3149701 ps} {3907962 ps}
