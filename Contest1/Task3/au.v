module au #(parameter WIDTH_1 = 4, parameter WIDTH_2 = 4)
(
    input [WIDTH_1-1:0] x_int, y_int,
    input [WIDTH_2-1:0] x_frac, y_frac,
    input operation,
    output zero,
    output overflow,
    output [WIDTH_1-1:0] result_int,
    output [WIDTH_2-1:0] result_frac
);

    wire [WIDTH_1+WIDTH_2-1:0] x_combined = {x_int, x_frac};
    wire [WIDTH_1+WIDTH_2-1:0] y_combined = {y_int, y_frac};
  
    wire [2*(WIDTH_1+WIDTH_2)-1:0] product_full = x_combined * y_combined;
    wire [WIDTH_1+WIDTH_2:0] sum_full = x_combined + y_combined;

    wire [WIDTH_1+WIDTH_2-1:0] result_fixed =
        operation ? product_full[2*(WIDTH_1+WIDTH_2)-2 -: (WIDTH_1+WIDTH_2)] :
            sum_full[WIDTH_1+WIDTH_2-1:0];

    assign zero = (result_fixed == 0);
    assign overflow = operation ?
        |product_full[2*(WIDTH_1+WIDTH_2)-1 -: (WIDTH_1+WIDTH_2 - WIDTH_1)] :
        sum_full[WIDTH_1+WIDTH_2];

    assign result_int = result_fixed[WIDTH_1+WIDTH_2-1:WIDTH_2];
    assign result_frac = result_fixed[WIDTH_2-1:0];

endmodule

