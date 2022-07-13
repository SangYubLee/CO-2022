// forwarding.v

// This module determines if the values need to be forwarded to the EX stage.

// TODO: declare propoer input and output ports and implement the
// forwarding unit

module forwarding (
    input [4:0] ex_rs1,
    input [4:0] ex_rs2,

    input [4:0] mem_rd,
    input [4:0] wb_rd,

    input mem_regwrite,
    input wb_regwrite,

    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);


always @(*) begin
    if ((ex_rs1 != 0) && (ex_rs1 == mem_rd) && (mem_regwrite)) begin
        forward_a <= 2'b01;
    end
    else if ((ex_rs1 != 0) && (ex_rs1 == wb_rd) && (wb_regwrite)) begin
        forward_a <= 2'b10;
    end
    else begin
        forward_a <= 2'b00;
    end
    
    if ((ex_rs2 != 0) && (ex_rs2 == mem_rd) && (mem_regwrite)) begin
        forward_b <= 2'b01;
    end
    else if ((ex_rs2 != 0) && (ex_rs2 == wb_rd) && (wb_regwrite)) begin
        forward_b <= 2'b10;
    end
    else begin
        forward_b <= 2'b00;
    end
end

endmodule
