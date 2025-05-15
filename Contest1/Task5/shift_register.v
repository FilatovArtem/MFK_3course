`timescale 1ns / 1ps

module shift_cell #(parameter WIDTH = 8)
(
    input  wire [WIDTH-1:0] d,
    input  wire clock,
    input  wire reset,
    output reg [WIDTH-1:0] q
);
    always @(posedge clock or posedge reset) begin
        if (reset)
            q <= {WIDTH{1'b0}};
        else
            q <= d;
    end
endmodule


module shift_register #(parameter WIDTH  = 8, parameter LENGTH = 4)
(
    input  wire [WIDTH-1:0] data_in,
    input  wire clock,
    input  wire reset,
    output wire [WIDTH-1:0] data_out
);

    wire [WIDTH-1:0] stage [0:LENGTH];

    assign stage[0] = data_in;
    assign data_out = stage[LENGTH];

    genvar i;
    generate
        for (i = 0; i < LENGTH; i = i + 1) begin : gen_shift
            shift_cell #(.WIDTH(WIDTH)) shift_cell (
                .d (stage[i]),
                .clock (clock),
                .reset (reset),
                .q (stage[i+1])
            );
        end
    endgenerate
endmodule
