module mainfsm(
	input logic clk,
	input logic reset,
	input logic [6:0] op,
	output logic [1:0] ALUSrcA, ALUSrcB,
	output logic [1:0] ResultSrc,
	output logic AdrSrc,
	output logic IRWrite, PCUpdate,
	output logic RegWrite, MemWrite,
	output logic [1:0] ALUOp,
	output logic Branch);

	typedef enum logic [3:0] {
	FETCH, DECODE, MEMADR, MEMREAD, 
	MEMWB, MEMWRITE,
	EXECUTER, EXECUTEI, ALUWB,
	BEQ, JAL
	} statetype;

	statetype state, nextstate;
	logic [14:0] controls;

	// state register
	always @(posedge clk or negedge reset) begin
		if (!reset)
			state <= FETCH;
		else 	
			state <= nextstate;
	end 

	// next state logic
	always @(*)  begin
		case(state)
			FETCH: nextstate = DECODE;
			DECODE: casez(op)
				7'b0?00011: nextstate = MEMADR; // lw or sw
				7'b0110011: nextstate = EXECUTER; // R-type
				7'b0010011: nextstate = EXECUTEI; // addi
				7'b1100011: nextstate = BEQ; // beq
				7'b1101111: nextstate = JAL; // jal
				7'b1100111: nextstate = MEMADR;	//jalr
				7'b0010111: nextstate = ALUWB;	// auipc
				default: nextstate = FETCH;  // if there is any anomaly or any incomplete instruction
			endcase
			MEMADR: begin
				casez(op[6:5])
				2'b00:	nextstate = MEMREAD;	//memread
				2'b01:	nextstate = MEMWRITE;	//memwrite 
				2'b11:	nextstate = JAL;	// jalr 
				endcase
				end 
			MEMREAD:  nextstate = MEMWB;
			EXECUTER: nextstate = ALUWB;
			EXECUTEI: nextstate = ALUWB;
			JAL:      nextstate = ALUWB;
			default: nextstate = FETCH;
		endcase
	end

	// state-dependent output logic
	always @(*)  begin
		case(state)
			FETCH: 		controls = 15'b00_10_10_0_1100_00_0;
			DECODE: 	controls = 15'b01_01_00_0_0000_00_0;
			MEMADR: 	controls = 15'b10_01_00_0_0000_00_0;
			MEMREAD: 	controls = 15'b00_00_00_1_0000_00_0;
			MEMWRITE: 	controls = 15'b00_00_00_1_0001_00_0;
			MEMWB: 		controls = 15'b00_00_01_0_0010_00_0;
			EXECUTER:	controls = 15'b10_00_00_0_0000_10_0;
			EXECUTEI: 	controls = 15'b10_01_00_0_0000_10_0;
			ALUWB: 		controls = 15'b00_00_00_0_0010_00_0;
			BEQ: 		controls = 15'b10_00_00_0_0000_01_1;
			JAL: 		controls = 15'b01_10_00_0_0100_00_0;
			default: 	controls = 15'bxx_xx_xx_x_xxxx_xx_x;
		endcase
	end 

	assign {ALUSrcA, ALUSrcB, ResultSrc, AdrSrc, IRWrite, PCUpdate,	RegWrite,MemWrite, ALUOp, Branch} = controls;
endmodule 
