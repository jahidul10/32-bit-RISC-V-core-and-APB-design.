module rv32i_top_tb #(parameter DATA_LENGTH = 32,ADDRESS_LENGTH = 11) ();
  

	int k;
	string line;
	int fd;


	logic instruction_load_start;
	logic clk;
	logic rst_n;
	logic core_select;

	logic [31:0] addr_in;
    logic [31:0] data_in;
	logic pselect;
	logic pwrite;
	logic pready;

	logic run_complete;
	logic [31:0] data_out;

	// variable for address writeout to memory through apb
	logic [ADDRESS_LENGTH -1:0] to_apb_address_out; 
	// variable for data writeout to memory through apb
	logic [DATA_LENGTH -1:0] to_apb_data_out;


	int j = 0;


	rv32i_pipelined_top #(DATA_LENGTH,ADDRESS_LENGTH) rv32i_pipelined_top(
		.clk(clk), 
		.rst_n(rst_n), 
		.core_select(core_select),
		.addr_in(addr_in),
		.data_in(data_in),
		.pselect(pselect),
		.pwrite(pwrite),
		.pready(pready),
		.data_out(data_out),
		.run_complete(run_complete),
		.instruction_load_start(instruction_load_start)
	);


	initial begin
		clk = 0;
		core_select = 0;
		rst_n = 1;
		pselect = 1'b0;
		pready = 1'b0;
		pwrite = 1'b0;
		addr_in = 32'b0;
		data_in = 32'b0;

		instruction_load_start =1'b0;

		reset_event();

	
		instruction_load_start = 1'b1;
		write_instructions();

		
		run_core();
		#10 $finish;
	end

	always @ (posedge clk) begin
        if (run_complete) begin
            #10;
            $finish;
        end
    end

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars;
		#30000 $finish();
	end

	always #5 clk = ~clk;

	task reset_event();
		// reset APB registers
		repeat(1) @(posedge clk);
		rst_n = 1'b0;
		repeat(2) @(posedge clk);
		rst_n = 1'b1;
	endtask

	task write_instructions();
		logic [DATA_LENGTH -1:0] mem [2047:0];
		$readmemh("prime_test.txt", mem);///pipelined_top

		line_number_detection();

		for (int i=0; i<=k; i++) begin
			to_apb_address_out = i;
			to_apb_data_out = mem[i];
			apb_write();
		end

		instruction_load_start = 1'b0;
	endtask


	task apb_write();
		addr_in = to_apb_address_out;

		data_in = to_apb_data_out;


		pselect = 1'b1;
		pwrite = 1'b1;
		pready = 1'b1;
		repeat(4) @(posedge clk);

		pselect = 1'b0;

	endtask


	task write_data();
		logic [DATA_LENGTH -1:0] mem [2047:0];
		$readmemh("pixel_exec.txt", mem);///pipelined_top

		line_number_detection_2();

		for (int i=660; i<=660+k*4; i=i+4) begin
			to_apb_address_out = i;
			to_apb_data_out = mem[0+j];
			j=j+1;
		end

		instruction_load_start = 1'b1;
	endtask



	task run_core();
		core_select = 1'b1;
		rst_n = 1'b0;
		repeat(2) @(posedge clk);
		rst_n = 1'b1;
		repeat(1) @(posedge clk);
	endtask

	task line_number_detection();

		k=0;
		fd=$fopen("prime_test.txt","r");
		
		while( !$feof(fd) ) begin
			integer code;
			code = $fgets(line,fd);
			k=k+1;
		end
		$fclose(fd);

	endtask

	task line_number_detection_2();

		k=0;
		fd=$fopen("./pipelined_top/TB/img_px.txt","r");
		
		while( !$feof(fd) ) begin
			integer code;
			code = $fgets(line,fd);
			k=k+1;
		end
		$fclose(fd);

	endtask
endmodule

