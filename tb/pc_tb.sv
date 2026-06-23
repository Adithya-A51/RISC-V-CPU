`timescale 1ns/1ps

module program_counter_tb;

    // Testbench signals
    logic        clk;
    logic        rst_n;
    logic [31:0] pc_next;
    logic [31:0] pc;

    // Instantiate the Device Under Test (DUT)
    program_counter dut (
        .clk(clk),
        .reset(rst_n),
        .next(pc_next),
        .pc(pc)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // 1. Tell Icarus Verilog to dump waveforms into the sim folder
        $dumpfile("sim/dump.vcd");
        $dumpvars(0, program_counter_tb);

        // 2. Initialize signals and assert reset
        clk = 0;
        rst_n = 0;
        pc_next = 32'h00000000;

        // 3. Release reset after 10ns
        #10 rst_n = 1;

        // 4. Simulate standard sequential execution (PC + 4)
        #10 pc_next = 32'h00000004;
        #10 pc_next = 32'h00000008;
        #10 pc_next = 32'h0000000C;

        // 5. Simulate a branch or jump to a new address
        #10 pc_next = 32'h00000400;
        #10 pc_next = 32'h00000404;

        // End simulation
        #20 $finish;
    end

endmodule