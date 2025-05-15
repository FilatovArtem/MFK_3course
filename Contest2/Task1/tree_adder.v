module tree_adder #(parameter WIDTH = 8, parameter SIZE = 4)
(
    input  wire [SIZE*WIDTH-1:0] data_in,
    output wire [WIDTH-1:0] data_out
);
    generate
        if (SIZE == 1) begin
            assign data_out = data_in[WIDTH-1:0];
        end else begin
            localparam HALF_SIZE = SIZE / 2;

            wire [WIDTH-1:0] sum_left;
            wire [WIDTH-1:0] sum_right;

            wire [HALF_SIZE*WIDTH-1:0] left_half = data_in[SIZE*WIDTH-1 : HALF_SIZE*WIDTH];
            wire [HALF_SIZE*WIDTH-1:0] right_half = data_in[HALF_SIZE*WIDTH-1 : 0];

            tree_adder #(.WIDTH(WIDTH), .SIZE(HALF_SIZE)) adder_left (
                .data_in(left_half),
                .data_out(sum_left)
            );

            tree_adder #(.WIDTH(WIDTH), .SIZE(HALF_SIZE)) adder_right (
                .data_in(right_half),
                .data_out(sum_right)
            );

            assign data_out = sum_left + sum_right;
        end
    endgenerate

endmodule