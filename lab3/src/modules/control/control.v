// control.v

// The main control module takes as input the opcode field of an instruction
// (i.e., instruction[6:0]) and generates a set of control signals.

module control(
  input [6:0] opcode,

  output [1:0] jump,
  output branch,
  output mem_read,
  output mem_to_reg,
  output [1:0] alu_op,
  output mem_write,
  output alu_src,
  output reg_write,
  output [1:0] upper_imm
);

reg [11:0] controls;

// combinational logic
always @(*) begin
  case (opcode)
    7'b0110011: controls = 12'b00_000_10_001_00; // R-type

    //////////////////////////////////////////////////////////////////////////
    // TODO : Implement signals for other instruction types
    7'b0010011: controls = 12'b00_000_11_011_00; // I-type, ALU  ex)addi
    7'b0000011: controls = 12'b00_011_00_011_00; // I-type, load ex)lb, lhu
    7'b0100011: controls = 12'b00_000_00_110_00; // S-type       ex)sb
    7'b1100011: controls = 12'b00_10x_01_000_00; // B-type       ex)beq
    7'b1101111: controls = 12'b10_000_xx_001_00; // J-type       ex)jal
    7'b1100111: controls = 12'b11_000_xx_001_00; // I-type, jump ex)jalr
    7'b0110111: controls = 12'b00_000_xx_001_01; // U-type, lui
    7'b0010111: controls = 12'b00_000_xx_001_10; // U-type, auipc
    //////////////////////////////////////////////////////////////////////////

    default:    controls = 12'b00_000_00_000_00;
  endcase
end

assign {jump, branch, mem_read, mem_to_reg, alu_op, mem_write, alu_src, reg_write, upper_imm} = controls;

endmodule
