module riscvmulti(
	input logic clk, reset,
	output logic MemWrite,
	output logic [31:0] Adr, WriteData,
	output logic mem_en,
	output logic [1:0] mem_data_length,
	input logic [31:0] ReadData);

	logic RegWrite, jump;
	logic [1:0] ResultSrc;
	logic [2:0] ImmSrc; // expand to 3-bits for auipc
	logic [3:0] ALUControl;
	logic PCWrite;
	logic IRWrite;
	logic [1:0] ALUSrcA;
	logic [1:0] ALUSrcB;
	logic AdrSrc;
	logic [3:0] Flags; // added for other branches
	logic [6:0] op;
	logic [2:0] funct3;
	logic funct7b5;
	logic LoadType; 
	logic StoreType; 
	logic PCTargetSrc; // added for jalr

	controller c(
		clk, 
		reset,
		op, 
		funct3, 
		funct7b5, 
		Flags,
		ImmSrc, 
		ALUSrcA, 
		ALUSrcB,
		ResultSrc, 
		AdrSrc, 
		ALUControl,
		IRWrite, 
		PCWrite, 
		RegWrite, 
		MemWrite,
		LoadType, 
		StoreType, 
		PCTargetSrc,
		mem_en,
		mem_data_length); 

	datapath dp(
		clk, 
		reset,
		ImmSrc, 
		ALUSrcA, 
		ALUSrcB,
		ResultSrc, 
		AdrSrc, 
		IRWrite, 
		PCWrite,
		RegWrite, 
		MemWrite, 
		ALUControl,
		LoadType, 
		StoreType, 
		PCTargetSrc,
		op, 
		funct3,
		funct7b5, 
		Flags, 
		Adr, 
		ReadData, 
		WriteData
		);
endmodule