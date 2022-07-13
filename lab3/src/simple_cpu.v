// simple_cpu.v
// a pipelined RISC-V microarchitecture (RV32I)

///////////////////////////////////////////////////////////////////////////////////////////
//// [*] In simple_cpu.v you should connect the correct wires to the correct ports
////     - All modules are given so there is no need to make new modules
////       (it does not mean you do not need to instantiate new modules)
////     - However, you may have to fix or add in / out ports for some modules
////     - In addition, you are still free to instantiate simple modules like multiplexers,
////       adders, etc.
///////////////////////////////////////////////////////////////////////////////////////////

module simple_cpu
#(parameter DATA_WIDTH = 32)(
  input clk,
  input rstn
);

///////////////////////////////////////////////////////////////////////////////
// TODO:  Declare all wires / registers that are needed
///////////////////////////////////////////////////////////////////////////////
// e.g., wire [DATA_WIDTH-1:0] if_pc_plus_4;
// 1) Pipeline registers (wires to / from pipeline register modules)
// 2) In / Out ports for other modules
// 3) Additional wires for multiplexers or other mdoules you instantiate

wire [DATA_WIDTH-1:0] if_PC, id_PC, ex_PC, mem_PC;
wire [DATA_WIDTH-1:0] if_pc_plus_4, id_pc_plus_4, ex_pc_plus_4, mem_pc_plus_4, wb_pc_plus_4;
wire [DATA_WIDTH-1:0] if_instruction, id_instruction;
wire [DATA_WIDTH-1:0] ex_pc_target, mem_pc_target;

// Register file unit
wire [4:0] id_rs1, ex_rs1;
wire [4:0] id_rs2, ex_rs2;
wire [4:0] id_rd, ex_rd, mem_rd, wb_rd;
wire [4:0] writereg;
wire [31:0] id_readdata1, ex_readdata1;
wire [31:0] id_readdata2, ex_readdata2;
wire wen;

// data2writereg
wire [DATA_WIDTH-1:0] writedata2reg, writedata2mem;
wire [DATA_WIDTH-1:0] mem_alu_result_or_uimm, mem_writedata2reg, wb_writedata2reg;


// Immediate generator unit
wire [DATA_WIDTH-1:0] id_sextimm, ex_sextimm;

// Control unit
wire [6:0] id_opcode;
wire [6:0] id_funct7, ex_funct7;
wire [2:0] id_funct3, ex_funct3, mem_funct3;
wire id_branch, ex_branch, mem_branch;
wire id_memread, ex_memread, mem_memread;
wire id_memtoreg, ex_memtoreg, mem_memtoreg, wb_memtoreg;
wire [1:0] id_aluop, ex_aluop;
wire id_memwrite, ex_memwrite;
wire id_alusrc, ex_alusrc;
wire id_regwrite, ex_regwrite, mem_regwrite, wb_regwrite;
wire [1:0] id_jump, ex_jump, mem_jump, wb_jump;
wire ex_taken, mem_taken;
wire [1:0] id_upper_imm, ex_upper_imm;

// Hazard detection unit
wire flush;
wire stall;

// Forwarding unit
wire [31:0] forwarded_A;
wire [1:0] fwd_a;
wire [31:0] forwarded_B;
wire [1:0] fwd_b;

// Data memory unit
wire [DATA_WIDTH-1:0] mem_readdata, wb_readdata;

// ALU unit
wire [31:0] ex_alu_result;
wire [3:0] alu_func;
wire alu_check;

// upper imm unit
wire [31:0] pc_plus_imm12;

// Branch Hardware unit
wire [DATA_WIDTH-1:0] branch_target;
wire [DATA_WIDTH-1:0] nextPC_mux_out;
wire if_hit, id_hit, ex_hit, mem_hit;
wire if_pred, id_pred, ex_pred, mem_pred;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// MUX
wire [31:0] alu_in_b;         //select rs2 or sextimm
mux_2x1 m_rs2_or_imm_mux_2x1(
  .select(ex_alusrc),
  .in1(forwarded_B),
  .in2(ex_sextimm),

  .out(alu_in_b)
);
wire [31:0] pc_or_rs1;     //select jal(pc+imm) or jalr(rs1+imm)
mux_2x1 m_jal_or_jalr_mux_2x1(
  .select(ex_jump[0]),
  .in1(ex_PC),          //jal
  .in2(forwarded_A),    //jalr

  .out(pc_or_rs1)
);
mux_2x1 m_mem_regwrite_data_mux_2x1(
  .select(mem_jump[1]),
  .in1(mem_alu_result_or_uimm),
  .in2(mem_pc_plus_4),

  .out(mem_writedata2reg)
);
mux_2x1 m_wb_regwrite_data_mux_2x1(
  .select(wb_memtoreg),
  .in1(wb_writedata2reg),
  .in2(wb_readdata),

  .out(writedata2reg)
);

// mux for forwarding
mux_3x1 m_forwardA_mux_3x1(
  .select(fwd_a),
  .in1(ex_readdata1),
  .in2(mem_writedata2reg),
  .in3(writedata2reg),

  .out(forwarded_A)
);
mux_3x1 m_forwardB_mux_3x1(
  .select(fwd_b),
  .in1(ex_readdata2),
  .in2(mem_writedata2reg),
  .in3(writedata2reg),

  .out(forwarded_B)
);

// mux for upper imm
wire [31:0] alu_result_or_uimm;
mux_3x1 m_upperimm_mux_3x1(
  .select(ex_upper_imm),
  .in1(ex_alu_result),
  .in2(ex_sextimm << 12),
  .in3(pc_plus_imm12),

  .out(alu_result_or_uimm)
);

//maskmode, sext
reg [1:0] maskmode;
reg sext;
always @(*) begin
  case(mem_funct3)
  3'b000: begin               //b
    maskmode = 2'b00;
    sext = 1'b0;
    end
  3'b001: begin               //h
    maskmode = 2'b01;
    sext = 1'b0;
    end
  3'b010: begin               //w
    maskmode = 2'b10;
    sext = 1'b0;
    end
  3'b100: begin               //unsigned b
    maskmode = 2'b00;
    sext = 1'b1; 
    end  
  3'b101: begin               //unsigned h
    maskmode = 2'b01;
    sext = 1'b1; 
    end  
  default: begin
    maskmode = 2'b00;
    sext = 1'b0;
  end
  endcase
end

///////////////////////////////////////////////////////////////////////////////
// Instruction Fetch (IF)
///////////////////////////////////////////////////////////////////////////////

reg [DATA_WIDTH-1:0] PC;    // program counter (32 bits)
wire [DATA_WIDTH-1:0] NEXT_PC;


wire [DATA_WIDTH-1:0] recoveryPC;
mux_4x1 m_recoveryPC_mux_4x1(
  .select({ (mem_pred && mem_hit), (mem_jump == 2'b11) }),
  .in1(mem_pc_target),
  .in2(mem_pc_target),
  .in3(mem_pc_plus_4),
  .in4(mem_pc_target),

  .out(recoveryPC)
);
mux_4x1 m_nextPC_mux_4x1(
  .select({ (flush), (if_pred && if_hit) }),
  .in1(if_pc_plus_4),
  .in2(branch_target),
  .in3(recoveryPC),
  .in4(recoveryPC),

  .out(nextPC_mux_out)
);

/* m_branch_HW */
branch_hardware m_branch_HW(
  .clk(clk),
  .rstn(rstn),

  // update interface
  .instruction(if_instruction),

  .update_predictor(mem_branch),
  .update_btb(mem_taken || mem_jump[1]),
  .actually_taken(mem_taken),
  .resolved_pc(mem_PC),
  .resolved_pc_target(mem_pc_target),  // actual target address when the branch is resolved.

  // access interface
  .pc(PC),

  .hit(if_hit),          // btb hit or not
  .pred(if_pred),         // predicted taken or not
  .branch_target(branch_target)
);

/* m_next_pc_adder */
adder m_pc_plus_4_adder(
  .in_a   (PC),
  .in_b   (32'h0000_0004),

  .result (if_pc_plus_4)
);

always @(posedge clk) begin
  if (rstn == 1'b0) begin
    PC <= 32'h00000000;
  end
  else if (stall) PC <= PC;
  else begin
    PC <= NEXT_PC;
  end
end

/* instruction: read current instruction from inst mem */
instruction_memory m_instruction_memory(
  .address    (PC),

  .instruction(if_instruction)
);

/* forward to IF/ID stage registers */
ifid_reg m_ifid_reg(
  // TODO: Add flush or stall signal if it is needed
  .clk            (clk),
  .flush          (flush),
  .stall          (stall),
  .if_pred        (if_pred),
  .if_hit         (if_hit),
  .if_PC          (PC),
  .if_pc_plus_4   (if_pc_plus_4),
  .if_instruction (if_instruction),

  .id_pred        (id_pred),
  .id_hit         (id_hit),
  .id_PC          (id_PC),
  .id_pc_plus_4   (id_pc_plus_4),
  .id_instruction (id_instruction)
);

//////////////////////////////////////////////////////////////////////////////////
// Instruction Decode (ID)
//////////////////////////////////////////////////////////////////////////////////

//assign
assign id_opcode = id_instruction[6:0];
assign id_funct7 = id_instruction[31:25];
assign id_funct3 = id_instruction[14:12];
assign id_rs1 = id_instruction[19:15];
assign id_rs2 = id_instruction[24:20];
assign id_rd  = id_instruction[11:7];

/* m_hazard: hazard detection unit */
hazard m_hazard(
  // TODO: implement hazard detection unit & do wiring
  .ex_PC          (ex_PC),
  .mem_pc_target  (mem_pc_target),
  .mem_hit        (mem_hit),
  .mem_pred       (mem_pred),
  .mem_taken      (mem_taken),
  .mem_jump       (mem_jump),

  .id_opcode      (id_opcode),
  .ex_memread     (ex_memread),
  .id_rs1         (id_rs1),
  .id_rs2         (id_rs2),
  .ex_rd          (ex_rd),

  .flush          (flush),
  .stall          (stall)
);

/* m_control: control unit */
control m_control(
  .opcode     (id_opcode),

  .jump       (id_jump),
  .branch     (id_branch),
  .alu_op     (id_aluop),
  .alu_src    (id_alusrc),
  .mem_read   (id_memread),
  .mem_to_reg (id_memtoreg),
  .mem_write  (id_memwrite),
  .reg_write  (id_regwrite),
  .upper_imm  (id_upper_imm)
);

/* m_imm_generator: immediate generator */
immediate_generator m_immediate_generator(
  .instruction(id_instruction),

  .sextimm    (id_sextimm)
);

/* m_register_file: register file */
register_file m_register_file(
  .clk        (clk),
  .readreg1   (id_rs1),
  .readreg2   (id_rs2),
  .writereg   (writereg),
  .wen        (wen),
  .writedata  (writedata2reg),
 
  .readdata1  (id_readdata1),
  .readdata2  (id_readdata2)
);
 
/* forward to ID/EX stage registers */
idex_reg m_idex_reg(
  // TODO: Add flush or stall signal if it is needed
  .clk          (clk),
  .flush        (flush),
  .stall        (stall),
  .id_pred      (id_pred),
  .id_hit       (id_hit),
  .id_PC        (id_PC),
  .id_pc_plus_4 (id_pc_plus_4),

  .id_jump      (id_jump),
  .id_branch    (id_branch),
  .id_aluop     (id_aluop),
  .id_alusrc    (id_alusrc),
  .id_memread   (id_memread),
  .id_memwrite  (id_memwrite),
  .id_memtoreg  (id_memtoreg),
  .id_regwrite  (id_regwrite),
  .id_upper_imm (id_upper_imm),

  .id_sextimm   (id_sextimm),
  .id_funct7    (id_funct7),
  .id_funct3    (id_funct3),
  .id_readdata1 (id_readdata1),
  .id_readdata2 (id_readdata2),
  .id_rs1       (id_rs1),
  .id_rs2       (id_rs2),
  .id_rd        (id_rd),


  .ex_pred      (ex_pred),
  .ex_hit       (ex_hit),
  .ex_PC        (ex_PC),
  .ex_pc_plus_4 (ex_pc_plus_4),

  .ex_jump      (ex_jump),
  .ex_branch    (ex_branch),
  .ex_aluop     (ex_aluop),
  .ex_alusrc    (ex_alusrc),
  .ex_memread   (ex_memread),
  .ex_memwrite  (ex_memwrite),
  .ex_memtoreg  (ex_memtoreg),
  .ex_regwrite  (ex_regwrite),
  .ex_upper_imm (ex_upper_imm),

  .ex_sextimm   (ex_sextimm),
  .ex_funct7    (ex_funct7),
  .ex_funct3    (ex_funct3),
  .ex_readdata1 (ex_readdata1),
  .ex_readdata2 (ex_readdata2),
  .ex_rs1       (ex_rs1),
  .ex_rs2       (ex_rs2),
  .ex_rd        (ex_rd)
);

//////////////////////////////////////////////////////////////////////////////////
// Execute (EX) 
//////////////////////////////////////////////////////////////////////////////////

/* m_upper_imm_adder: PC + (imm << 12) for auipc */
adder m_upper_imm_adder(
  .in_a   (ex_PC),
  .in_b   (ex_sextimm << 12),

  .result (pc_plus_imm12)
);

/* m_branch_target_adder: PC + imm for branch address */
adder m_branch_target_adder(
  .in_a   (pc_or_rs1),
  .in_b   (ex_sextimm << 1),

  .result (ex_pc_target)
);

/* m_branch_control : checks T/NT */
branch_control m_branch_control(
  .branch (ex_branch),
  .check  (alu_check),

  .taken  (ex_taken)
);

/* alu control : generates alu_func signal */
alu_control m_alu_control(
  .alu_op   (ex_aluop),
  .funct7   (ex_funct7),
  .funct3   (ex_funct3),

  .alu_func (alu_func)
);

/* m_alu */
alu m_alu(
  .alu_func (alu_func),
  .in_a     (forwarded_A),
  .in_b     (alu_in_b), 

  .result   (ex_alu_result),
  .check    (alu_check)
);

forwarding m_forwarding(
  // TODO: implement forwarding unit & do wiring
  .ex_rs1       (ex_rs1),
  .ex_rs2       (ex_rs2),

  .mem_rd       (mem_rd),
  .wb_rd        (wb_rd),

  .mem_regwrite (mem_regwrite),
  .wb_regwrite  (wb_regwrite),

  .fwd_a        (fwd_a),
  .fwd_b        (fwd_b)
);

/* forward to EX/MEM stage registers */
exmem_reg m_exmem_reg(
  // TODO: Add flush or stall signal if it is needed
  .clk                (clk),
  .flush              (flush),
  
  .ex_pred            (ex_pred),
  .ex_hit             (ex_hit),
  .ex_PC              (ex_PC),
  .ex_pc_plus_4       (ex_pc_plus_4),
  .ex_pc_target       (ex_pc_target),
  .ex_taken           (ex_taken), 
  .ex_jump            (ex_jump),
  .ex_branch          (ex_branch),
  .ex_memread         (ex_memread),
  .ex_memwrite        (ex_memwrite),
  .ex_memtoreg        (ex_memtoreg),
  .ex_regwrite        (ex_regwrite),

  .ex_alu_result      (alu_result_or_uimm),
  .ex_writedata2mem   (forwarded_B),
  .ex_funct3          (ex_funct3),
  .ex_rd              (ex_rd),
  
  .mem_pred           (mem_pred),
  .mem_hit            (mem_hit),
  .mem_PC             (mem_PC),
  .mem_pc_plus_4      (mem_pc_plus_4),
  .mem_pc_target      (mem_pc_target),
  .mem_taken          (mem_taken), 
  .mem_jump           (mem_jump),
  .mem_branch         (mem_branch),
  .mem_memread        (mem_memread),
  .mem_memwrite       (mem_memwrite),
  .mem_memtoreg       (mem_memtoreg),
  .mem_regwrite       (mem_regwrite),
  .mem_alu_result_or_uimm     (mem_alu_result_or_uimm),
  .mem_writedata2mem  (writedata2mem),
  .mem_funct3         (mem_funct3),
  .mem_rd             (mem_rd)
);

//////////////////////////////////////////////////////////////////////////////////
// Memory (MEM) 
//////////////////////////////////////////////////////////////////////////////////

/* m_data_memory : main memory module */
data_memory m_data_memory(
  .clk         (clk),
  .address     (mem_alu_result_or_uimm),
  .write_data  (writedata2mem),
  .mem_read    (mem_memread),
  .mem_write   (mem_memwrite),
  .maskmode    (maskmode),
  .sext        (sext),

  .read_data   (mem_readdata)
);

/* forward to MEM/WB stage registers */
memwb_reg m_memwb_reg(
  // TODO: Add flush or stall signal if it is needed
  .clk                (clk),

  .mem_memtoreg       (mem_memtoreg),
  .mem_regwrite       (mem_regwrite),
  .mem_readdata       (mem_readdata),
  .mem_writedata2reg  (mem_writedata2reg),
  .mem_rd             (mem_rd),

  .wb_memtoreg        (wb_memtoreg),
  .wb_regwrite        (wb_regwrite),
  .wb_readdata        (wb_readdata),
  .wb_writedata2reg   (wb_writedata2reg),
  .wb_rd              (wb_rd)
);

assign NEXT_PC = nextPC_mux_out;

//////////////////////////////////////////////////////////////////////////////////
// Write Back (WB) 
//////////////////////////////////////////////////////////////////////////////////

assign wen = wb_regwrite;
assign writereg = wb_rd;

////////////////////////////////////////////////////////////////////////////////
// Hardware Counters
////////////////////////////////////////////////////////////////////////////////
wire [31:0] CORE_CYCLE;
hardware_counter m_core_cycle(
  .clk(clk),
  .rstn(rstn),
  .cond(1'b1),

  .counter(CORE_CYCLE)
);
wire [31:0] NUM_COND_BRANCHES;
hardware_counter m_num_cond_branches(
  .clk(clk),
  .rstn(rstn),
  .cond(mem_branch),

  .counter(NUM_COND_BRANCHES)
);
wire [31:0] NUM_UNCOND_BRANCHES;
hardware_counter m_num_uncond_branches(
  .clk(clk),
  .rstn(rstn),
  .cond(mem_jump[1]),

  .counter(NUM_UNCOND_BRANCHES)
);
wire [31:0] BP_CORRECT;
hardware_counter m_bp_correct(
  .clk(clk),
  .rstn(rstn),
  .cond(mem_branch && (!flush)),

  .counter(BP_CORRECT)
);
wire [31:0] BP_INCORRECT;
hardware_counter m_bp_incorrect(
  .clk(clk),
  .rstn(rstn),
  .cond(mem_branch && flush),

  .counter(BP_INCORRECT)
);


endmodule
