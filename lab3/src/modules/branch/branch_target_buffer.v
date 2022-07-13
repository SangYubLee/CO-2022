// branch_target_buffer.v

/* The branch target buffer (BTB) stores the branch target address for
 * a branch PC. Our BTB is essentially a direct-mapped cache.
 */

module branch_target_buffer #(
  parameter DATA_WIDTH = 32,
  parameter NUM_ENTRIES = 256
) (
  input clk,
  input rstn,

  // update interface
  input update,                              // when 'update' is true, we update the BTB entry
  input [DATA_WIDTH-1:0] resolved_pc,
  input [DATA_WIDTH-1:0] resolved_pc_target,

  // access interface
  input [DATA_WIDTH-1:0] pc,

  output reg hit,
  output reg [DATA_WIDTH-1:0] target_address
);

// TODO: Implement BTB
reg [54:0] BTB[0:NUM_ENTRIES-1];

wire [7:0] update_idx, access_idx;
wire [21:0] update_tag, access_tag;

assign update_idx = resolved_pc[9:2];
assign access_idx = pc[9:2];
assign update_tag = resolved_pc[31:10];
assign access_tag = pc[31:10];

integer i;
always @(posedge clk) begin 
  if (rstn == 1'b0) begin                         //initialize
    for (i=0 ; i<NUM_ENTRIES ; i++) BTB[i][32] <= 1'b0;
  end
  else begin                             //update
    if (update) begin
      BTB[update_idx][54:33] <= update_tag;
      BTB[update_idx][32] <= 1'b1;
      BTB[update_idx][31:0] <= resolved_pc_target;
    end
  end
end

always @(*) begin
  if ((BTB[access_idx][54:33] == access_tag) && (BTB[access_idx][32] == 1'b1)) begin   //access
    target_address = BTB[access_idx][31:0];
    hit = 1'b1;
  end
  else begin
    hit = 1'b0;
  end
end


endmodule
