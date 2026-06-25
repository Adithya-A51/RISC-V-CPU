module intstruction_decoder(
    input logic [31:0], 

    output logic [4:0]  opcode,
    output logic [4:0]  rd,
    output logic [2:0]  funct3,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [6:0]  funct7,

    output logic [11:0] i,      
    output logic [11:0] s,      
    output logic [12:0] b,      
    output logic [19:0] u,     
    output logic [20:0] j
);

    always_comb begin
        opcode = instruction[6:2]; 
        rd     = instruction[11:7];
        funct3 = instruction[14:12];
        rs1    = instruction[19:15];
        rs2    = instruction[24:20];
        funct7 = instruction[31:25];

        i  = instruction[31:20];
        s  = {instruction[31:25], instruction[11:7]};
        b  = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        u  = instruction[31:12];
        j  = {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
    end

endmodule