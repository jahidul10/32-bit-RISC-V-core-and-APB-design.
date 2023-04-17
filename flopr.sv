module flopr #(parameter WIDTH = 8)(
			input logic clk, reset,
			input logic [WIDTH-1:0] d,
			output logic [WIDTH-1:0] q);

			always_ff @(posedge clk, negedge reset) begin 
				if (!reset) 
					q <= 0;
				else
					q <= d;
			end 

endmodule
