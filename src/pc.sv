module program_counter(
    input logic clk,
    input logic reset,
    input logic [31:0] next,
    output logic [31:0] pc
);

always_ff @(posedge clk) begin
    if(!reset) begin
        pc <= 32'h0;
    end
    else begin
        pc <= next;
    end
end

endmodule