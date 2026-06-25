module immediate_generator(
    input logic [11:0] imm_i,      
    input logic [11:0] imm_s,      
    input logic [12:0] imm_b,      
    input logic [19:0] imm_u,     
    input logic [20:0] imm_j,
    input logic [2:0] sel,

    output logic [31:0] imm_out
);
    always_comb begin
        case (sel)
            3'b000: imm_out = {{20{imm_i[11]}}, imm_i}; 
            3'b001: imm_out = {{20{imm_s[11]}}, imm_s}; 
            3'b010: imm_out = {{19{imm_b[12]}}, imm_b}; 
            3'b011: imm_out = {imm_u, 12'b0};           
            3'b100: imm_out = {{11{imm_j[20]}}, imm_j}; 
            default: imm_out = 32'b0;
        
        endcase
    end
endmodule