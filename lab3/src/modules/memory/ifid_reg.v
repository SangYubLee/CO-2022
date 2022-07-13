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

  input if_pred,
  input if_hit,
  
  input [DATA_WIDTH-1:0] if_PC,
  input [DATA_WIDTH-1:0] if_pc_plus_4,
  input [DATA_WIDTH-1:0] if_instruction,

  //////////////////////////////////////
  // Outputs
  //////////////////////////////////////

  output id_pred,
  output id_hit,
  output [DATA_WIDTH-1:0] id_PC,
  output [DATA_WIDTH-1:0] id_pc_plus_4,
  output [DATA_WIDTH-1:0] id_instruction
);

// TODO: Implement IF/ID pipeline register module

reg pred;
reg hit;
reg [DATA_WIDTH-1:0] PC;
reg [DATA_WIDTH-1:0] pc_plus_4;
reg [DATA_WIDTH-1:0] instruction;

always @(posedge clk) begin
    if (flush) begin
      PC <= 32'h0000_0000;
      pc_plus_4 <= 32'h0000_0000;
      instruction <= 32'h0000_0000;
      pred <= 1'b0;
      hit <= 1'b0;
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
      pred <= if_pred;
      hit <= if_hit;
    end
end

assign id_pred = pred;
assign id_hit = hit;
assign id_PC = PC;
assign id_pc_plus_4 = pc_plus_4;
assign id_instruction = instruction;

endmodule
