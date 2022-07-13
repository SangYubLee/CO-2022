// gshare.v

/* The Gshare predictor consists of the global branch history register (BHR)
 * and a pattern history table (PHT). Note that PC[1:0] is not used for
 * indexing.
 */

module gshare #(
  parameter DATA_WIDTH = 32,
  parameter COUNTER_WIDTH = 2,
  parameter NUM_ENTRIES = 256
) (
  input clk,
  input rstn,

  // update interface
  input update,
  input actually_taken,
  input [DATA_WIDTH-1:0] resolved_pc,

  // access interface
  input [DATA_WIDTH-1:0] pc,

  output reg pred
);

// TODO: Implement gshare branch predictor
reg [7:0] BHR;
reg [1:0] PHT[0:NUM_ENTRIES-1];

wire [7:0] update_idx;
wire [7:0] access_idx;
assign update_idx = (BHR)^(resolved_pc[9:2]);
assign access_idx = (BHR)^(pc[9:2]);


integer i;
always @(posedge clk) begin
  if (rstn == 1'b0) begin                         //initialize
    BHR <= 8'b00000000;
    for (i=0 ; i<NUM_ENTRIES ; i++) PHT[i] <= 2'b01;
  end
  else begin
    if (update) begin
      if (actually_taken) begin
        PHT[update_idx] <= (PHT[update_idx] == 2'b11) ? PHT[update_idx] : (PHT[update_idx] + 1);
        BHR <= (BHR << 1) + 1;
      end
      else begin
        PHT[update_idx] <= (PHT[update_idx] == 2'b00) ? PHT[update_idx] : (PHT[update_idx] - 1);
        BHR <= BHR << 1;
      end
    end
  end
end

always @(*) begin
  if( PHT[access_idx][1] == 1'b1 ) begin
      pred = 1'b1;     //predict T
    end
    else begin
      pred = 1'b0;      //predict NT
    end
end



endmodule
