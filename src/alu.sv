module alu(
    input logic [31:0] operand_a, 
    input logic [31:0] operand_b, 
    input logic [4:0] alu_cntrl, 

    output logic [31:0] alu_res, 
    output logic zero
);
    always_comb begin
        case (alu_cntrl)
            4'd0 : alu_res = operand_a + operand_b; // ADD
            4'd1 : alu_res = operand_a - operand_b; // SUB
            4'd2 : alu_res = operand_a << operand_b[4:0]; //SLL
            4'd3 : alu_res = operand_a >> operand_b[4;0] //SRL
            4'd4 : alu_res = ($signed(operand_a) < $signed(operand_b)) ? 1 : 0; // LST
            4'd5 : alu_res = (operand_a < operand_b) ? 1 : 0; // LSTU
            4'd6 : alu_res = operand_a ^ operand_b // XOR
            4'd7 : alu_res = $signed(operand_a) >>> operand_b[4:0]; // SRA
            4'd8 : alu_res = operand_a | operand_b; //OR
            4'd9 : alu_res = operand_a & operand_b; // AND
            default : alu_res = 32'b0;           
        endcase
    end

    assign zero = (alu_res == 32'b0);
    
endmodule