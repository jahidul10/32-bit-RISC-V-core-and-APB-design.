module aludec(
	input logic opb5,
	input logic [2:0] funct3,
	input logic funct7b5,
	input logic [1:0] ALUOp,
	output logic [3:0] ALUControl); // expand to 4 bits for sra

	logic RtypeSub;
	assign RtypeSub = funct7b5 & opb5; // TRUE for R-type subtract instruction

	always_comb
		case(ALUOp)
			2'b00: ALUControl = 4'b000; // addition
			2'b01: ALUControl = 4'b001; // subtraction
			default: case(funct3) // R-type or I-type ALU
					3'b000: begin 
						if (RtypeSub)
							ALUControl = 4'b0001; // sub
						else
							ALUControl = 4'b0000; // add, addi
					end 
					3'b001: ALUControl = 4'b0110; // sll, slli
					3'b010: ALUControl = 4'b0101; // slt, slti
					3'b100: ALUControl = 4'b0100; // xor, xori
					3'b101: begin 
						if (funct7b5)
							ALUControl = 4'b1000; // sra, srai
						else
							ALUControl = 4'b0111; // srl, srli
					end
					3'b110: ALUControl = 4'b0011; // or, ori
					3'b111: ALUControl = 4'b0010; // and, andi
					default: ALUControl = 4'bxxx; 
				endcase
		endcase
endmodule