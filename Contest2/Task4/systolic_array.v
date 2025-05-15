module systolic_array #(parameter ROWS = 2, parameter COLUMNS = 2, parameter WIDTH = 8)
(
    input wire clock,
    input wire reset,
    input wire [ROWS * WIDTH - 1:0] a,
    input wire [COLUMNS * WIDTH - 1:0] b,
    output wire [ROWS * COLUMNS * WIDTH - 1:0] c
);

    reg [WIDTH - 1:0] a_reg [0:ROWS - 1][0:COLUMNS - 1];
    reg [WIDTH - 1:0] b_reg [0:ROWS - 1][0:COLUMNS - 1];
    reg [WIDTH - 1:0] c_reg [0:ROWS - 1][0:COLUMNS - 1];

    wire [WIDTH - 1:0] a_in [0:ROWS - 1];
    wire [WIDTH - 1:0] b_in [0:COLUMNS - 1];

    genvar i, j;
    generate
        for (i = 0; i < ROWS; i = i + 1) begin
            assign a_in[i] = a[(i+1)*WIDTH-1 -: WIDTH];
        end
        for (j = 0; j < COLUMNS; j = j + 1) begin
            assign b_in[j] = b[(j+1)*WIDTH-1 -: WIDTH];
        end
    endgenerate

    generate
        for (i = 0; i < ROWS; i = i + 1) begin
            for (j = 0; j < COLUMNS; j = j + 1) begin
                assign c[(i * COLUMNS + j + 1) * WIDTH - 1 -: WIDTH] = c_reg[i][j];
            end
        end
    endgenerate

    integer row, col;
    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            for (row = 0; row < ROWS; row = row + 1) begin
                for (col = 0; col < COLUMNS; col = col + 1) begin
                    a_reg[row][col] <= 0;
                    b_reg[row][col] <= 0;
                    c_reg[row][col] <= 0;
                end
            end
        end
        else begin
            for (row = 0; row < ROWS; row = row + 1) begin
                for (col = 0; col < COLUMNS; col = col + 1) begin
                    c_reg[row][col] <= a_in[row] * b_in[col];
                end
            end

            for (row = 0; row < ROWS; row = row + 1) begin
                for (col = 0; col < COLUMNS; col = col + 1) begin
                    a_reg[row][col] <= a_in[row];
                    b_reg[row][col] <= b_in[col];
                end
            end
        end
    end

endmodule