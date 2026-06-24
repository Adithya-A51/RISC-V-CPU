module instruction_fetch(
    input  logic [31:0] pc,
    output logic [31:0] instruction
);

    logic [31:0] memory [0:255];
    
    initial begin
        $readmemh("sim/program.hex", memory);
    end

    assign instruction = memory_array[pc[31:2]];
endmodule
