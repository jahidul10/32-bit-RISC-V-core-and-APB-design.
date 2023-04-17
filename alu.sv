module alu(
	input logic [31:0] a,
	input logic [31:0] b,
	input logic [3:0] alucontrol, // expanded to 4 bits for sra	
	output logic [31:0] result,
	output logic [3:0] flags); // added for blt and other branches
	logic [31:0] condinvb, sum;
	logic v, c, n, z; // flags: overflow, carry out, negative, zero
	logic cout; // carry out of adder
	logic isAdd; // true if is an add operation
	logic isSub; // true if is a subtract operation
	assign flags = {v, c, n, z};
	assign condinvb = alucontrol[0] ? ~b : b;
	assign {cout, sum} = a + condinvb + alucontrol[0];
	assign isAddSub = ~alucontrol[3] & ~alucontrol[2] & ~alucontrol[1] | ~alucontrol[3] & ~alucontrol[1] & alucontrol[0];
	always @(*) begin 
		case (alucontrol)
			4'b0000: result = sum; // add
			4'b0001: result = sum; // subtract
			4'b0010: result = a & b; // and
			4'b0011: result = a | b; // or
			4'b0100: result = a ^ b; // xor
			4'b0101: result = sum[31] ^ v; // slt
			4'b0110: result = a << b[4:0]; // sll
			4'b0111: result = a >> b[4:0]; // srl
			4'b1000: result = $signed(a) >>> b[4:0]; // sra
			default: result = 32'bx;
		endcase
	end 
	// added for blt and other branches
	assign z = (result == 32'b0);
	assign n = result[31];
	assign c = cout & isAddSub;
	assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
endmodule
