`timescale 1ns/1ps
`define CLK_PERIOD 20

module aes_top_tb;

wire reset, clk, ce;
reg l_reset, l_clk, l_ce;

wire [1:0] key_size;
reg[1:0] l_key_size;
wire[7:0] key;
reg [7:0] l_key;
wire key_valid;
reg l_key_valid;

wire [7:0] enc_data_i, enc_data_o;
reg [7:0] l_enc_data_i;
wire enc_ready, enc_valid_i, enc_valid_o;
reg l_enc_valid_i;

wire [7:0] dec_data_i, dec_data_o;
reg [7:0] l_dec_data_i;
wire dec_ready, dec_valid_i, dec_valid_o;
reg l_dec_valid_i;

assign clk = l_clk;
assign reset = l_reset;
assign ce = l_ce;
assign key = l_key;
assign key_size = l_key_size;
assign key_valid = l_key_valid;
assign enc_data_i = l_enc_data_i;
assign enc_valid_i = l_enc_valid_i;
assign dec_data_i = l_dec_data_i;
assign dec_valid_i = l_dec_valid_i;

reg[4:0] enc_input_num, enc_output_num = 0;
reg[31:0][127:0] enc_input_data;
reg[255:0] key_data;
int key_size_int;

aes_top dut (
	.CLK_I(clk),
	.RESET_I(reset),
	.CE_I(ce),
	.KEY_SIZE_I(key_size),
	.KEY_I(key),
	.KEY_VALID_I(key_valid),
	.ENC_DATA_I(enc_data_i),
	.ENC_VALID_I(enc_valid_i),
	.ENC_READY_O(enc_ready),
	.ENC_DATA_O(enc_data_o),
	.ENC_VALID_O(enc_valid_o),
	.DEC_DATA_I(dec_data_i),
	.DEC_VALID_I(dec_valid_i),
	.DEC_READY_O(dec_ready),
	.DEC_DATA_O(dec_data_o),
	.DEC_VALID_O(dec_valid_o)
);

initial begin
	l_reset <= 1;
	l_ce <= 1;
	l_key_size <= 0;
	l_key <= 0;
	l_key_valid <= 0;
	l_enc_data_i <= 0;
	l_enc_valid_i <= 0;
	l_dec_data_i <= 0;
	l_dec_valid_i <= 0;
	enc_input_num = 0;
	enc_output_num = 0;
	#100;
	l_reset <= 0;
	#200;
	fork
		monitor_enc_out();
	join_none

	run_test();
	$finish();
end

initial begin
	l_clk <= 0;
	forever begin
		#(`CLK_PERIOD/2) l_clk <= ~l_clk;
	end	
end	

task run_test();
	setup_key(128, 128'hE8E9EAEBEDEEEFF0F2F3F4F5F7F8F9FA);
	enc_data(128'h014BAF2278A69D331D5180103643E99A);
	//dec_data();
	#10us;
endtask

task setup_key(int size = 128, logic[255:0] key = 'X);
	@(negedge clk);
	key_data = 0;
	key_size_int = size;

	if( size == 128 ) l_key_size <= 2'b00;
	else if( size == 192 ) l_key_size <= 2'b01;
	else l_key_size <= 2'b10;
	l_key_valid <= 1;
	for( int i=1; i<=(size/8); i++ ) begin		
		l_key = (^key === 'X) ? $random() : key[i*8-1 -: 8];
		key_data[i*8-1 -: 8] = l_key;
		@(negedge clk);
	end
	l_key_valid <= 0;	
endtask

task enc_data(logic[255:0] data = 'X);
	wait( enc_ready == 1 );
	repeat(5)@(negedge clk);
	l_enc_valid_i <= 1;
	for( int i=1; i<=16; i++ ) begin		
		l_enc_data_i = (^data === 'X) ? $random() : data[i*8-1 -: 8];
		enc_input_data[enc_input_num][i*8-1 -: 8] = l_enc_data_i;
		@(negedge clk);
	end
	enc_input_num++;
	l_enc_valid_i <= 0;	
endtask

task dec_data(logic[255:0] data = 'X);
	wait( dec_ready == 1 );
	@(negedge clk);
	l_dec_valid_i <= 1;
	for( int i=1; i<=16; i++ ) begin		
		l_dec_data_i = (^data === 'X) ? $random() : data[i*8-1 -: 8];
		@(negedge clk);
	end
	l_dec_valid_i <= 0;	
endtask

task monitor_enc_out();
	reg[127:0] enc_out;
	forever begin
		wait(enc_valid_o == 1);
		for( int i=1; i<=16; i++ ) begin
			@(posedge clk);
			enc_out[i*8-1 -: 8] = enc_data_o;
		end
		
		$display("%0d - %0d bit key:  %0h", $time, key_size_int, key_data);
		$display("Enc Data Input:  %32h", enc_input_data[enc_output_num++]);
		$display("Enc Data Output: %32h", enc_out);
	end
endtask

endmodule
