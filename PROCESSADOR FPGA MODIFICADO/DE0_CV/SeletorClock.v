module SeletorClock (
		input clock,
		input reset,
		input [3:0] sel,
		input clock_1hz,
		input clock_10hz,
		input clock_100hz,
		input clock_1khz,
		input clock_10khz,
		input clock_100khz,
		input clock_1mhz,
		input clock_12mhz,
		output reg clock_saida
	);

	always @(posedge clock or posedge reset) begin
		if(reset) begin
			clock_saida <= 1'b0;
		end
		else begin
			case(sel)
				4'h0: clock_saida <= clock_1hz;
				4'h1: clock_saida <= clock_10hz;
				4'h2: clock_saida <= clock_100hz;
				4'h3: clock_saida <= clock_1khz;
				4'h4: clock_saida <= clock_10khz;
				4'h5: clock_saida <= clock_100khz;
				4'h6: clock_saida <= clock_1mhz;
				4'h7: clock_saida <= clock_12mhz;
				4'h8: clock_saida <= clock;
				default: clock_saida <= 1'b0;
			endcase
		end
	end

endmodule 