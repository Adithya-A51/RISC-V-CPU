module cpu (
    input  logic clk,
    input  logic rst_n
);

    // --------------------------------------------------------
    // INTERNAL WIRES AND CHANNELS
    // --------------------------------------------------------
    
    // Fetch Stage Wires
    logic [31:0] pc;
    logic [31:0] pc_next;
    logic [31:0] pc_plus4;
    logic [31:0] pc_target;
    logic        pc_src;

    // Decode Stage Wires
    logic [31:0] instruction;
    logic [4:0]  opcode;
    logic [4:0]  rd;
    logic [2:0]  funct3;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [6:0]  funct7;
    
    logic [11:0] imm_i;
    logic [11:0] imm_s;
    logic [12:0] imm_b;
    logic [19:0] imm_u;
    logic [20:0] imm_j;
    logic [31:0] imm_out;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    // Control Unit Wires
    logic        reg_write;
    logic [2:0]  imm_sel;
    logic        alu_src;
    logic        mem_write;
    logic [1:0]  result_src;
    logic        branch;
    logic        jump;
    logic [3:0]  alu_ctrl;

    // Execute Stage Wires
    logic [31:0] src_b;
    logic [31:0] alu_result;
    logic        alu_zero;
    logic        branch_taken;

    // Memory Stage Wires
    logic [31:0] read_data;
    logic [31:0] result_data;

    // --------------------------------------------------------
    // HARDWARE COMBINATIONAL ROUTING (The Multiplexers)
    // --------------------------------------------------------
    
    // 1. Next PC Calculation
    assign pc_plus4  = pc + 4;
    assign pc_target = pc + imm_out;
    
    // The PC changes address if we hit a JUMP instruction, OR a BRANCH instruction that evaluates to true
    assign pc_src    = jump | (branch & branch_taken);
    assign pc_next   = pc_src ? pc_target : pc_plus4;

    // 2. ALU Source Multiplexer
    // Chooses whether operand B comes from Register File (rs2) or the Immediate Generator
    assign src_b     = alu_src ? imm_out : rs2_data;

    // 3. Write-Back Multiplexer
    // Chooses what data gets saved back into the destination register (rd)
    always_comb begin
        case (result_src)
            2'b00:   result_data = alu_result;  // Standard Math/Logic
            2'b01:   result_data = read_data;   // Loaded word from RAM
            2'b10:   result_data = pc_plus4;    // Return address for JAL/JALR
            default: result_data = alu_result;
        endcase
    end

    // --------------------------------------------------------
    // MODULE INSTANTIATIONS (Wiring the blocks together)
    // --------------------------------------------------------

    // Program Counter
    program_counter pc_inst (
        .clk     (clk),
        .reset   (rst_n),
        .next (pc_next),
        .pc      (pc)
    );

    // Instruction Memory (ROM)
    instruction_memory imem_inst (
        .pc          (pc),
        .instruction (instruction)
    );

    // Instruction Decoder
    instruction_decoder dec_inst (
        .instruction (instruction),
        .opcode      (opcode),
        .rd          (rd),
        .funct3      (funct3),
        .rs1         (rs1),
        .rs2         (rs2),
        .funct7      (funct7),
        .i       (imm_i),
        .s       (imm_s),
        .b       (imm_b),
        .u       (imm_u),
        .j       (imm_j)
    );

    // Control Unit
    control_unit cu_inst (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7   (funct7[5]), // Bit 30 of the instruction determines ADD/SUB and SRL/SRA
        .reg_write  (reg_write),
        .imm_sel    (imm_sel),
        .alu_src    (alu_src),
        .mem_write  (mem_write),
        .result_src (result_src),
        .branch     (branch),
        .jump       (jump),
        .alu_ctrl   (alu_ctrl)
    );

    // Register File
    register_file reg_inst (
        .clk      (clk),
        .we       (reg_write),
        .rs1 (rs1),
        .rs2 (rs2),
        .rd  (rd),
        .rd_data  (result_data),
        .rs1_data (rs1_data),
        .rs2_data (rs2_data)
    );

    // Immediate Generator
    immediate_generator imm_inst (
        .imm_i   (imm_i),
        .imm_s   (imm_s),
        .imm_b   (imm_b),
        .imm_u   (imm_u),
        .imm_j   (imm_j),
        .sel (imm_sel),
        .imm_out (imm_out)
    );

    // Arithmetic Logic Unit (ALU)
    alu alu_inst (
        .operand_a  (rs1_data),
        .operand_b  (src_b),
        .alu_cntrl   (alu_ctrl),
        .alu_res (alu_result),
        .zero       (alu_zero)
    );

    // Branch Evaluator Unit
    branch_unit branch_inst (
        .operand_a    (rs1_data),
        .operand_b    (rs2_data),
        .branch_ctrl  (funct3),
        .branch_taken (branch_taken)
    );

    // Data Memory (RAM)
    data_memory dmem_inst (
        .clk (clk),
        .we  (mem_write),
        .addr(alu_result),
        .wd  (rs2_data),
        .rd  (read_data)
    );

endmodule