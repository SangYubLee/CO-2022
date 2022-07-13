// imm_generator.v

module imm_generator #(
  parameter DATA_WIDTH = 32
)(
  input [31:0] instruction,

  output reg [DATA_WIDTH-1:0] sextimm
);

wire [6:0] opcode;
assign opcode = instruction[6:0];

always @(*) begin
  case (opcode)
    //////////////////////////////////////////////////////////////////////////
    // TODO : Generate sextimm using instruction
    7'b0010011: sextimm[31:0] <= { {20{instruction[31]}}, instruction[31:20] }; //ex) addi
    7'b0000011: sextimm[31:0] <= { {20{instruction[31]}}, instruction[31:20] }; //ex)lb, lhu
    7'b0100011: sextimm[31:0] <= { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };//  ex)sb
    7'b1100011: sextimm[31:0] <= { {20{instruction[31]}}, instruction[31], instruction[7],instruction[30:25],instruction[11:8]};// B-type       ex)beq
    7'b1101111: sextimm[31:0] <= { {12{instruction[31]}}, instruction[31], instruction[19:12],instruction[20],instruction[30:21] };// UJ-type       ex)jar
    7'b1100111: sextimm[31:0] <= { {12{instruction[31]}}, instruction[31], instruction[19:12],instruction[20],instruction[30:21] };// UJ-type, jump ex)jalr
    //////////////////////////////////////////////////////////////////////////
    default:    sextimm = 32'h0000_0000;
  endcase
end


endmodule
