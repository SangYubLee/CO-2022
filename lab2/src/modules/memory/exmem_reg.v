//exmem_reg.v


module exmem_reg #(
  parameter DATA_WIDTH = 32
)(
  // TODO: Add flush or stall signal if it is needed

  //////////////////////////////////////
  // Inputs
  //////////////////////////////////////
  input clk,

  input flush,
  input [DATA_WIDTH-1:0] ex_pc_plus_4,
  input [DATA_WIDTH-1:0] ex_pc_target,
  input ex_taken,

  // mem control
  input ex_memread,
  input ex_memwrite,

  // wb control
  input [1:0] ex_jump,
  input ex_memtoreg,
  input ex_regwrite,
  
  input [DATA_WIDTH-1:0] ex_alu_result,
  input [DATA_WIDTH-1:0] ex_writedata,
  input [2:0] ex_funct3,
  input [4:0] ex_rd,
  
  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////
  output [DATA_WIDTH-1:0] mem_pc_plus_4,
  output [DATA_WIDTH-1:0] mem_pc_target,
  output mem_taken,

  // mem control
  output mem_memread,
  output mem_memwrite,

  // wb control
  output [1:0] mem_jump,
  output mem_memtoreg,
  output mem_regwrite,
  
  output [DATA_WIDTH-1:0] mem_alu_result,
  output [DATA_WIDTH-1:0] mem_writedata,
  output [2:0] mem_funct3,
  output [4:0] mem_rd
);

// TODO: Implement EX / MEM pipeline register module


reg [DATA_WIDTH-1:0] pc_plus_4;
reg [DATA_WIDTH-1:0] pc_target;
reg taken;
reg memread;
reg memwrite;
reg [1:0] jump;
reg memtoreg;
reg regwrite;
reg [DATA_WIDTH-1:0] alu_result;
reg [DATA_WIDTH-1:0] writedata;
reg [2:0] funct3;
reg [4:0] rd;

always @(posedge clk) begin
  if (flush) begin
    pc_target <= 32'h00000000;
    taken <= 1'b0;
    memread <= 1'b0;
    memwrite <= 1'b0;
    jump <= 1'b0;
    memtoreg <= 1'b0;
    regwrite <= 1'b0;
    alu_result <= 32'h0000_0000;
    writedata <= 32'h0000_0000;
    funct3 <= 3'b000;
    rd <= 5'b00000;
    pc_plus_4 <= 32'h0000_0000;
  end
  else begin
    pc_target <= ex_pc_target;
    taken <= ex_taken;
    memread <= ex_memread;
    memwrite <= ex_memwrite;
    jump <= ex_jump;
    memtoreg <= ex_memtoreg;
    regwrite <= ex_regwrite;
    alu_result <= ex_alu_result;
    writedata <= ex_writedata;
    funct3 <= ex_funct3;
    rd <= ex_rd;
    pc_plus_4 <= ex_pc_plus_4;
  end
end


assign mem_pc_plus_4 = pc_plus_4;
assign mem_pc_target = pc_target;
assign mem_taken = taken;

assign mem_memread = memread;
assign mem_memwrite = memwrite;

assign mem_jump = jump;
assign mem_memtoreg = memtoreg;
assign mem_regwrite = regwrite;

assign mem_alu_result = alu_result;
assign mem_writedata = writedata;
assign mem_funct3 = funct3;
assign mem_rd = rd;

endmodule
