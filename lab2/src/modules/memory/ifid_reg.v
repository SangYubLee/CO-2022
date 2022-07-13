// ifid_reg.v
// This module is the IF/ID pipeline register.


module ifid_reg #(
  parameter DATA_WIDTH = 32
)(
  // TODO: Add flush or stall signal if it is needed

  //////////////////////////////////////
  // Inputs
  //////////////////////////////////////
  input clk,
  input flush,
  input stall,
  
  input [DATA_WIDTH-1:0] if_PC,
  input [DATA_WIDTH-1:0] if_pc_plus_4,
  input [DATA_WIDTH-1:0] if_instruction,

  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////

  output [DATA_WIDTH-1:0] id_PC,
  output [DATA_WIDTH-1:0] id_pc_plus_4,
  output [DATA_WIDTH-1:0] id_instruction
);

// TODO: Implement IF/ID pipeline register module

reg [DATA_WIDTH-1:0] PC;
reg [DATA_WIDTH-1:0] pc_plus_4;
reg [DATA_WIDTH-1:0] instruction;

always @(posedge clk) begin
  if (if_PC == 32'h0000_0000) begin       //the very first starting cpu
    PC <= if_PC;
    pc_plus_4 <= if_pc_plus_4;
    instruction <= if_instruction;
  end
  else begin
    if (flush) begin
      PC <= 32'h0000_0000;
      pc_plus_4 <= 32'h0000_0000;
      instruction <= 32'h0000_0000;
    end
    else if (stall) begin
      PC <= PC;
      pc_plus_4 <= pc_plus_4;
      instruction <= instruction;
    end
    else begin
      PC <= if_PC;
      pc_plus_4 <= if_pc_plus_4;
      instruction <= if_instruction;
    end
  end
end

assign id_PC = PC;
assign id_pc_plus_4 = pc_plus_4;
assign id_instruction = instruction;

endmodule
