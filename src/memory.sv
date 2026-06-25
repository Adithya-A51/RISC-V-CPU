module memory(
    input logic clk, 
    input logic we, 
    input logic address, 
    input logic data,

    output logic out_data

);
    logic [31:0] mem[0:1023];

    initial begin
        for(int i = 0;i<1024;i++) begin
            mem[i] = 32'b0;
        end 
    end

    assign out_data = mem[address[31:2]]

    always_ff @(posedge clk) begin
        if (we) begin
            mem[address[31:2]] <= data;
        end
    end
    
endmodule