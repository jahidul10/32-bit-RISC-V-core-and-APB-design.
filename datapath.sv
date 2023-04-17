module datapath(
	input logic clk, reset,
	input logic [2:0] ImmSrc,
	input logic [1:0] ALUSrcA, ALUSrcB,
	input logic [1:0] ResultSrc,
	input logic AdrSrc,
	input logic IRWrite, PCWrite,
	input logic RegWrite, MemWrite,
	input logic [3:0] alucontrol,
	input logic LoadType, StoreType,
	input logic PCTargetSrc,
	output logic [6:0] op,
	output logic [2:0] funct3,
	output logic funct7b5,
	output logic [3:0] Flags,
	output logic [31:0] Adr,
	input logic [31:0] ReadData,
	output logic [31:0] WriteData
	);

	logic [31:0] PC, OldPC, Instr, immext, ALUResult;
	logic [31:0] SrcA, SrcB, RD1, RD2, A;
	logic [31:0] Result, Data, ALUOut;
	
        
	// next PC logic
	flopenr #(32) pcreg(clk, reset, PCWrite, Result, PC);
	flopenr #(32) oldpcreg(clk, reset, IRWrite, PC, OldPC);

	// memory logic
	mux2 #(32) adrmux(PC, Result, AdrSrc, Adr);
	flopenr #(32) ir(clk, reset, IRWrite, ReadData, Instr);
	flopr #(32) datareg(clk, reset, ReadData, Data);
	
	// register file logic
	regfile rf(
		clk, reset,
		RegWrite, 
		Instr[19:15], 
		Instr[24:20],
		Instr[11:7], 
		Result, 
		RD1, 
		RD2);

	extend ext(
		Instr[31:7], 
		ImmSrc, 
		immext);

	flopr #(32) srcareg(clk, reset, RD1, A);
	flopr #(32) wdreg(clk, reset, RD2, WriteData);
	
	// ALU logic
	mux3 #(32) srcamux(PC, OldPC, A, ALUSrcA, SrcA);
	mux3 #(32) srcbmux(WriteData, immext, 32'd4, ALUSrcB, SrcB);
	alu alu(SrcA, SrcB, alucontrol, ALUResult, Flags);
	flopr #(32) aluoutreg(clk, reset, ALUResult, ALUOut);
	mux3 #(32) resmux(ALUOut, Data, ALUResult, ResultSrc, Result);

	// outputs to control unit
	assign op = Instr[6:0];
	assign funct3 = Instr[14:12];
	assign funct7b5 = Instr[30];
endmodule
