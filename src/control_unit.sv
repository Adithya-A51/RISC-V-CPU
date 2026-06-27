module control_unit (
    input  logic [4:0] opcode,      
    input  logic [2:0] funct3,     
    input  logic funct7,   
    output logic reg_write,   // 1 = Write to Register File
    output logic [2:0] imm_sel,     // 0=I, 1=S, 2=B, 3=U, 4=J
    output logic alu_src,     // 0 = rs2_data, 1 = Immediate
    output logic mem_write,   // 1 = Write to Data Memory
    output logic [1:0] result_src,  // 00 = ALU, 01 = Data Memory, 10 = PC+4
    output logic branch,      // 1 = Branch Instruction
    output logic jump,        // 1 = Jump Instruction (JAL/JALR)
    output logic [3:0] alu_ctrl     // 4-bit control for the ALU
);

    logic [1:0] alu_op; // Internal signal to link Main Decoder to ALU Decoder

    // --------------------------------------------------------
    // MAIN DECODER
    // --------------------------------------------------------
    always_comb begin
        // Default assignments to prevent implied latches (Critical for FPGA!)
        reg_write  = 1'b0;
        imm_sel    = 3'b000;
        alu_src    = 1'b0;
        mem_write  = 1'b0;
        result_src = 2'b00;
        branch     = 1'b0;
        jump       = 1'b0;
        alu_op     = 2'b00; 

        case (opcode)
            // R-Type (e.g., add, sub, and)
            5'b01100: begin
                reg_write  = 1'b1;
                alu_src    = 1'b0;      // ALU uses rs2_data
                result_src = 2'b00;     // Write back ALU result
                alu_op     = 2'b10;     // Tell ALU Decoder to look at funct3/7
            end

            // I-Type ALU (e.g., addi, andi)
            5'b00100: begin
                reg_write  = 1'b1;
                imm_sel    = 3'b000;    // Select I-type immediate
                alu_src    = 1'b1;      // ALU uses Immediate
                result_src = 2'b00;     // Write back ALU result
                alu_op     = 2'b10;     // Tell ALU Decoder to look at funct3/7
            end

            // I-Type Load (e.g., lw)
            5'b00000: begin
                reg_write  = 1'b1;
                imm_sel    = 3'b000;    // Select I-type immediate (Offset)
                alu_src    = 1'b1;      // ALU uses Immediate
                result_src = 2'b01;     // Write back Data Memory result!
                alu_op     = 2'b00;     // ALU must ADD base + offset
            end

            // S-Type Store (e.g., sw)
            5'b01000: begin
                imm_sel    = 3'b001;    // Select S-type immediate (Offset)
                alu_src    = 1'b1;      // ALU uses Immediate
                mem_write  = 1'b1;      // Turn on memory write
                alu_op     = 2'b00;     // ALU must ADD base + offset
            end

            // B-Type Branch (e.g., beq, blt)
            5'b11000: begin
                imm_sel    = 3'b010;    // Select B-type immediate
                branch     = 1'b1;      // Let the top-level know we might branch
                alu_op     = 2'b01;     // Subtraction/Comparison
            end

            // J-Type Jump (JAL)
            5'b11011: begin
                reg_write  = 1'b1;      // Jump and Link saves PC+4 to register
                imm_sel    = 3'b100;    // Select J-type immediate
                result_src = 2'b10;     // Write back PC+4
                jump       = 1'b1;      // Tell PC to jump
            end
            
            default: ; // Use defaults
        endcase
    end

    
    always_comb begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0000; 
            2'b01: alu_ctrl = 4'b0001; 
            2'b10: begin 
                case (funct3)
                    3'b000: begin
                        if (opcode == 5'b01100 && funct7) 
                            alu_ctrl = 4'b0001; // SUB
                        else 
                            alu_ctrl = 4'b0000; // ADD
                    end
                    3'b001: alu_ctrl = 4'b0010; // SLL
                    3'b010: alu_ctrl = 4'b0100; // SLT
                    3'b011: alu_ctrl = 4'b0101; // SLTU
                    3'b100: alu_ctrl = 4'b0110; // XOR
                    3'b101: begin
                        if (funct7) alu_ctrl = 4'b0111; // SRA
                        else          alu_ctrl = 4'b0011; // SRL
                    end
                    3'b110: alu_ctrl = 4'b1000; // OR
                    3'b111: alu_ctrl = 4'b1001; // AND
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            
            default: alu_ctrl = 4'b0000;
        endcase
    end

endmodule