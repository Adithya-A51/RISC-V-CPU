module register (
    input logic clk, 
    input logic we,
    input logic [4:0] rs1, 
    input logic [4:0] rs2, 
    input logic [4:0] rd, 
    input logic [31:0] rd_data,

    output logic [31:0] rs1_data, 
    output logic [31:0] rs2_data
);

    logic [31:0] registers [0:31];

    assign rs1_data = (rs1 == 5'b0) ? 32'b0 : registers[rs1];
    assign rs2_data = (rs2 == 5'b0) ? 32'b0 : registers[rs2];

    always_ff @(posedge clk) begin
        if (we && rd != 5'b0) begin
            registers[rd] <= rd_data;
        end
        
    end

endmodule

