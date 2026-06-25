module branch(
    input  logic [31:0] operand_a,    
    input  logic [31:0] operand_b,    
    input  logic [2:0]  branch_ctrl,  
    
    output logic branch_taken  
);

    always_comb begin
        case (branch_ctrl)
            3'b000: branch_taken = (operand_a == operand_b);                             // BEQ  
            3'b001: branch_taken = (operand_a != operand_b);                             // BNE  
            
            // Signed comparisons
            3'b100: branch_taken = ($signed(operand_a) <  $signed(operand_b));           // BLT  
            3'b101: branch_taken = ($signed(operand_a) >= $signed(operand_b));           // BGE  
            
            // Unsigned comparisons
            3'b110: branch_taken = (operand_a <  operand_b);                             // BLTU 
            3'b111: branch_taken = (operand_a >= operand_b);                             // BGEU 
            
            default: branch_taken = 1'b0;                                       
        endcase
    end

endmodule