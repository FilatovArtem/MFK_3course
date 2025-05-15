module linear_classifier #(parameter WIDTH = 8, parameter FEATURES = 2, parameter C_WIDTH = 1)
(
    input [FEATURES * WIDTH - 1:0] features,
    input [(2**C_WIDTH) * FEATURES * WIDTH - 1:0] weights,
    output [WIDTH - 1:0] r_value,
    output [C_WIDTH - 1:0] r_class
);
    localparam CLASSES = 2**C_WIDTH;

    wire [WIDTH-1:0] products [0:CLASSES * FEATURES - 1];

    wire [WIDTH-1:0] class_sums [0:CLASSES - 1];

    genvar c, f;
    generate
        for (c = 0; c < CLASSES; c = c + 1) begin
            for (f = 0; f < FEATURES; f = f + 1) begin
                wire [WIDTH - 1:0] feature_value;
                assign feature_value = features[f * WIDTH +: WIDTH];

                wire [WIDTH - 1:0] weight_value;
                assign weight_value = weights[(c * FEATURES + f) * WIDTH +: WIDTH];

                assign products[c * FEATURES + f] = feature_value * weight_value;
            end

            wire [WIDTH * FEATURES - 1:0] sum_inputs;

            for (f = 0; f < FEATURES; f = f + 1) begin
                assign sum_inputs[f * WIDTH +: WIDTH] = products[c * FEATURES + f];
            end

            tree_adder #(
                .WIDTH(WIDTH),
                .SIZE(FEATURES)
            ) adder (
                .data_in(sum_inputs),
                .data_out(class_sums[c])
            );
        end
    endgenerate

    wire [CLASSES * WIDTH - 1:0] max_inputs;

    genvar i;
    generate
        for (i = 0; i < CLASSES; i = i + 1) begin
            assign max_inputs[i * WIDTH +: WIDTH] = class_sums[i];
        end
    endgenerate

    max_argmax #(
        .WIDTH(WIDTH),
        .SIZE(C_WIDTH)
    ) max_finder (
        .data_in(max_inputs),
        .data_max(r_value),
        .argmax(r_class)
    );

endmodule