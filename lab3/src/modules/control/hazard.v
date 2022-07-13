// hazard.v

// This module determines if pipeline stalls or flushing are required

// TODO: declare propoer input and output ports and implement the
// hazard detection unit

module hazard (
    input [31:0] ex_PC,
    input [31:0] mem_pc_target,
    input mem_hit,
    input mem_pred,
    input mem_taken,
    input [1:0] mem_jump,

    input [6:0] id_opcode,
    input ex_memread,
    input [4:0] id_rs1,
    input [4:0] id_rs2,
    input [4:0] ex_rd,


    output reg flush,
    output reg stall
);

always @(*) begin

    if ((!mem_taken && !mem_jump[1]) && (mem_pred && mem_hit)) flush = 1'b1;
    else if ((mem_taken || mem_jump[1]) && !(mem_pred && mem_hit)) flush = 1'b1;
    else if ((mem_jump == 2'b11) && (mem_pred && mem_hit) && (mem_pc_target != ex_PC)) flush = 1'b1;
    else flush = 1'b0;

    if (flush == 1'b0) begin
        if (ex_memread == 1'b1) begin       //load inst?
            if (id_rs1 == ex_rd) begin      //use rs1
                if ((id_opcode != 7'b1101111) && (id_opcode != 7'b0110111) && (id_opcode != 7'b0010111)) begin
                    stall = 1'b1;
                end
                else stall = 1'b0;
            end
            else if (id_rs2 == ex_rd) begin //use rs2
                if ((id_opcode == 7'b0110011) || (id_opcode == 7'b0100011) || (id_opcode == 7'b1100011)) begin
                    stall = 1'b1;
                end
                else stall = 1'b0;
            end
            else stall = 1'b0;
        end
        else stall = 1'b0;
    end
    else stall = 1'b0;
end

endmodule
