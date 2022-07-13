// branch_hardware.v

/* This module comprises a branch predictor and a branch target buffer.
 * Our CPU will use the branch target address only when BTB is hit.
 */

module branch_hardware #(
  parameter DATA_WIDTH = 32,
  parameter COUNTER_WIDTH = 2,
  parameter NUM_ENTRIES = 256 // 2^8
) (
  input clk,
  input rstn,

  // update interface
  input [DATA_WIDTH-1:0] instruction,

  input update_predictor,
  input update_btb,
  input actually_taken,
  input [DATA_WIDTH-1:0] resolved_pc,
  input [DATA_WIDTH-1:0] resolved_pc_target,  // actual target address when the branch is resolved.

  // access interface
  input [DATA_WIDTH-1:0] pc,

  output reg hit,          // btb hit or not
  output reg pred,         // predicted taken or not
  output reg [DATA_WIDTH-1:0] branch_target  // branch target address for a hit
);

// TODO: Instantiate a branch predictor and a BTB.

/* gshare.v */
wire _pred;
gshare m_gshare(
  .clk(clk),
  .rstn(rstn),
  
  .update(update_predictor),
  .actually_taken(actually_taken),
  .resolved_pc(resolved_pc),
  
  .pc(pc),

  .pred(_pred)
);

/* branch_target_buffer.v */
wire _hit;
wire [DATA_WIDTH-1:0] _branch_target;
branch_target_buffer m_BTB(
  .clk(clk),
  .rstn(rstn),

  .update(update_btb),
  .resolved_pc(resolved_pc),
  .resolved_pc_target(resolved_pc_target),

  .pc(pc),

  .hit(_hit),
  .target_address(_branch_target)
);


always @(*) begin
  if (instruction[6:0] == 7'b1100011) begin
    pred = _pred;
    hit = _hit;
    branch_target = _branch_target;
  end
  else if (instruction[6:0] == 7'b1101111 || instruction[6:0] == 7'b1100111) begin
    pred = 1'b1;
    hit = _hit;
    branch_target = _branch_target;
  end
  else begin
    pred = 1'b0;
    hit = 1'b0;
  end
end


endmodule
