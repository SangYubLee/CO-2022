// hazard.v

// This module determines if pipeline stalls or flushing are required

// TODO: declare propoer input and output ports and implement the
// hazard detection unit

module hazard (
    input mem_taken,
    input mem_jump,

    input [6:0] id_opcode,
    input ex_memread,
    input [4:0] id_rs1,
    input [4:0] id_rs2,
    input [4:0] ex_rd,


    output reg flush,
    output reg stall
);

always @(*) begin
    
    if ((mem_taken == 1'b1) || (mem_jump == 1'b1)) flush <= 1'b1;
    else flush <= 1'b0;

    stall <= 1'b0;

    if (flush == 1'b0) begin
        if (ex_memread == 1'b1) begin       //load inst?
            if (id_rs1 == ex_rd) begin      //use rs1
                if (id_opcode != 7'b1101111) begin  //use rs1? -> all inst except jal
                    stall <= 1'b1;
                end
            end
            else if (id_rs2 == ex_rd) begin //use rs2
                if ((id_opcode == 7'b0110011) || (id_opcode == 7'b0100011) || (id_opcode == 7'b1100011)) begin
                    stall <= 1'b1;
                end
            end
        end
    end
end

endmodule
