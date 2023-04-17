module controller(
	input logic clk,
	input logic reset,
	input logic [6:0] op,
	input logic [2:0] funct3,
	input logic funct7b5,
	input logic [3:0] Flags,
	output logic [2:0] ImmSrc,
	output logic [1:0] ALUSrcA, ALUSrcB,
	output logic [1:0] ResultSrc,
	output logic AdrSrc,
	output logic [3:0] ALUControl,
	output logic IRWrite, PCWrite,
	output logic RegWrite, MemWrite,
	output logic LoadType, 
	output logic StoreType, 
	output logic PCTargetSrc,
	output logic mem_en,
	output logic [1:0] mem_data_length); 
	
	logic [1:0] ALUOp;
	logic Branch, PCUpdate;
	logic branchtaken; // added for other branches

	// Main FSM
	mainfsm fsm(
		clk, 
		reset, 
		op,
		ALUSrcA, 
		ALUSrcB, 
		ResultSrc, 
		AdrSrc,
		IRWrite, 
		PCUpdate, 
		RegWrite, 
		MemWrite,
		ALUOp, 
		Branch);

	// ALU Decoder
	aludec ad(
		op[5], 
		funct3, 
		funct7b5, 
		ALUOp, 
		ALUControl);

	// Instruction Decoder
	instrdec id(
		op, 
		ImmSrc);

	// Branch logic
	lsu lsu(
		funct3, 
		LoadType, 
		StoreType);

	bu branchunit(
		Branch, 
		Flags, 
		funct3, 
		branchtaken); // added for bne,	blt, etc.

	assign PCWrite = branchtaken | PCUpdate;
	
	assign mem_en = MemWrite | !MemWrite;
	assign mem_data_length = 2'b00; 
	
	
endmodule
