module branch_control
(
  // current pc
  input branch,
  input check,

  output reg taken 
);

///////////////////////////////////////////////////////////////////////////////
// TODO : You need to do something!
always @(*) begin
  taken = branch & check;
end
//////////////////////////////////////////////////////////////////////////////

endmodule
