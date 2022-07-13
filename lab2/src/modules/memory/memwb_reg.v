// memwb_reg.v
// This module is the MEM/WB pipeline register.


module memwb_reg #(
  parameter DATA_WIDTH = 32
)(
  // TODO: Add flush or stall signal if it is needed

  //////////////////////////////////////
  // Inputs
  //////////////////////////////////////
  input clk,

  input [DATA_WIDTH-1:0] mem_pc_plus_4,

  // wb control
  input [1:0] mem_jump,
  input mem_memtoreg,
  input mem_regwrite,
  
  input [DATA_WIDTH-1:0] mem_readdata,
  input [DATA_WIDTH-1:0] mem_alu_result,
  input [4:0] mem_rd,
  
  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////
  output [DATA_WIDTH-1:0] wb_pc_plus_4,

  // wb control
  output [1:0] wb_jump,
  output wb_memtoreg,
  output wb_regwrite,
  
  output [DATA_WIDTH-1:0] wb_readdata,
  output [DATA_WIDTH-1:0] wb_alu_result,
  output [4:0] wb_rd
);

// TODO: Implement MEM/WB pipeline register module

reg [DATA_WIDTH-1:0] pc_plus_4;
reg [1:0] jump;
reg memtoreg;
reg regwrite;
reg [DATA_WIDTH-1:0] readdata;
reg [DATA_WIDTH-1:0] alu_result;
reg [4:0] rd;

always @(posedge clk) begin
  jump <= mem_jump;
  memtoreg <= mem_memtoreg;
  regwrite <= mem_regwrite;
  readdata <= mem_readdata;
  alu_result <= mem_alu_result;
  rd <= mem_rd;
  pc_plus_4 <= mem_pc_plus_4;
end


assign wb_pc_plus_4 = pc_plus_4;
assign wb_jump = jump;
assign wb_memtoreg = memtoreg;
assign wb_regwrite = regwrite;
assign wb_readdata = readdata;
assign wb_alu_result = alu_result;
assign wb_rd = rd;

endmodule
