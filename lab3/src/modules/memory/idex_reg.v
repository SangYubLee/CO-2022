// idex_reg.v
// This module is the ID/EX pipeline register.


module idex_reg #(
  parameter DATA_WIDTH = 32
)(
  // TODO: Add flush or stall signal if it is needed

  //////////////////////////////////////
  // Inputs
  //////////////////////////////////////
  input clk,
  input flush,
  input stall,

  input id_pred,
  input id_hit,
  input [DATA_WIDTH-1:0] id_PC,
  input [DATA_WIDTH-1:0] id_pc_plus_4,

  // ex control
  input [1:0] id_jump,
  input id_branch,
  input [1:0] id_aluop,
  input id_alusrc,
  // mem control
  input id_memread,
  input id_memwrite,
  // wb control
  input id_memtoreg,
  input id_regwrite,
  // upper imm control
  input [1:0] id_upper_imm,

  input [DATA_WIDTH-1:0] id_sextimm,
  input [6:0] id_funct7,
  input [2:0] id_funct3,
  input [DATA_WIDTH-1:0] id_readdata1,
  input [DATA_WIDTH-1:0] id_readdata2,
  input [4:0] id_rs1,
  input [4:0] id_rs2,
  input [4:0] id_rd,

  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////
  output ex_pred,
  output ex_hit,
  output [DATA_WIDTH-1:0] ex_PC,
  output [DATA_WIDTH-1:0] ex_pc_plus_4,

  // ex control
  output ex_branch,
  output [1:0] ex_aluop,
  output ex_alusrc,
  output [1:0] ex_jump,
  // mem control
  output ex_memread,
  output ex_memwrite,
  // wb control
  output ex_memtoreg,
  output ex_regwrite,
  // upper imm control
  output [1:0] ex_upper_imm,

  output [DATA_WIDTH-1:0] ex_sextimm,
  output [6:0] ex_funct7,
  output [2:0] ex_funct3,
  output [DATA_WIDTH-1:0] ex_readdata1,
  output [DATA_WIDTH-1:0] ex_readdata2,
  output [4:0] ex_rs1,
  output [4:0] ex_rs2,
  output [4:0] ex_rd
);

// TODO: Implement ID/EX pipeline register module

reg pred;
reg hit;
reg [DATA_WIDTH-1:0] PC;
reg [DATA_WIDTH-1:0] pc_plus_4;

reg [1:0] jump;
reg branch;
reg [1:0] aluop;
reg alusrc;
reg memread;
reg memwrite;
reg memtoreg;
reg regwrite;
reg [1:0] upper_imm;

reg [DATA_WIDTH-1:0] sextimm;
reg [6:0] funct7;
reg [2:0] funct3;
reg [DATA_WIDTH-1:0] readdata1;
reg [DATA_WIDTH-1:0] readdata2;
reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;

always @(posedge clk) begin
  if (flush) begin
    pred <= 1'b0;
    hit <= 1'b0;
    PC <= 32'h00000000;
    pc_plus_4 <= 32'h0000_0000;

    jump <= 1'b0;
    branch <= 1'b0;
    aluop <= 1'b0;
    alusrc <= 1'b0;
    memread <= 1'b0;
    memwrite <= 1'b0;
    memtoreg <= 1'b0;
    regwrite <= 1'b0;
    upper_imm <= 2'b00;

    sextimm <= 32'h00000000;
    funct7 <= 7'b0000000;
    funct3 <= 3'b000;
    readdata1 <= 32'h00000000;
    readdata2 <= 32'h00000000;
    rs1 <= 5'b00000;
    rs2 <= 5'b00000;
    rd <= 5'b00000;
  end
  else if (stall) begin
    PC <= PC;
    pc_plus_4 <= pc_plus_4;

    jump <= 1'b0;
    branch <= 1'b0;
    aluop <= 1'b0;
    alusrc <= 1'b0;
    memread <= 1'b0;
    memwrite <= 1'b0;
    memtoreg <= 1'b0;
    regwrite <= 1'b0;
    upper_imm <= 2'b00;

    sextimm <= sextimm;
    funct7 <= funct7;
    funct3 <= funct3;
    readdata1 <= readdata1;
    readdata2 <= readdata2;
    rs1 <= rs1;
    rs2 <= rs2;
    rd <= rd;
  end
  else begin
    pred <= id_pred;
    hit <= id_hit;
    PC <= id_PC;
    pc_plus_4 <= id_pc_plus_4;

    jump <= id_jump;
    branch <= id_branch;
    aluop <= id_aluop;
    alusrc <= id_alusrc;
    memread <= id_memread;
    memwrite <= id_memwrite;
    memtoreg <= id_memtoreg;
    regwrite <= id_regwrite;
    upper_imm <= id_upper_imm;

    sextimm <= id_sextimm;
    funct7 <= id_funct7;
    funct3 <= id_funct3;
    readdata1 <= id_readdata1;
    readdata2 <= id_readdata2;
    rs1 <= id_rs1;
    rs2 <= id_rs2;
    rd <= id_rd;
  end
end

assign ex_pred = pred;
assign ex_hit = hit;
assign ex_PC = PC;
assign ex_pc_plus_4 = pc_plus_4;

assign ex_jump = jump;
assign ex_branch = branch;
assign ex_aluop = aluop;
assign ex_alusrc = alusrc;
assign ex_memread = memread;
assign ex_memwrite = memwrite;
assign ex_memtoreg = memtoreg;
assign ex_regwrite = regwrite;
assign ex_upper_imm = upper_imm;

assign ex_sextimm = sextimm;
assign ex_funct7 = funct7;
assign ex_funct3 = funct3;
assign ex_readdata1 = readdata1;
assign ex_readdata2 = readdata2;
assign ex_rs1 = rs1;
assign ex_rs2 = rs2;
assign ex_rd = rd;

endmodule
