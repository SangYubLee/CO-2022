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

  // wb control
  input mem_memtoreg,
  input mem_regwrite,
  
  input [DATA_WIDTH-1:0] mem_readdata,
  input [DATA_WIDTH-1:0] mem_writedata2reg,
  input [4:0] mem_rd,
  
  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////

  // wb control
  output wb_memtoreg,
  output wb_regwrite,
  
  output [DATA_WIDTH-1:0] wb_readdata,
  output [DATA_WIDTH-1:0] wb_writedata2reg,
  output [4:0] wb_rd
);

// TODO: Implement MEM/WB pipeline register module

reg memtoreg;
reg regwrite;
reg [DATA_WIDTH-1:0] readdata;
reg [DATA_WIDTH-1:0] writedata;
reg [4:0] rd;

always @(posedge clk) begin
  memtoreg <= mem_memtoreg;
  regwrite <= mem_regwrite;
  readdata <= mem_readdata;
  writedata <= mem_writedata2reg;
  rd <= mem_rd;
end


assign wb_memtoreg = memtoreg;
assign wb_regwrite = regwrite;
assign wb_readdata = readdata;
assign wb_writedata2reg = writedata;
assign wb_rd = rd;

endmodule
