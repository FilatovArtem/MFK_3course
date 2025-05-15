module max_argmax #(parameter WIDTH = 8, parameter SIZE = 2)
(
    input [(2**SIZE)*WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_max,
    output [SIZE-1:0] argmax
);

    wire [WIDTH-1:0] values [0:(2**(SIZE+1))-2];
    wire [SIZE-1:0] indices [0:(2**(SIZE+1))-2];
    
    genvar i;
    generate
        for (i = 0; i < 2**SIZE; i = i + 1) begin : input_values
            assign values[i + (2**SIZE) - 1] = data_in[WIDTH * (i + 1) - 1:WIDTH * i];
            assign indices[i + (2**SIZE) - 1] = i[SIZE - 1:0];
        end
    endgenerate
    
    genvar level, j;
    generate
        for (level = 0; level < SIZE; level = level + 1) begin
            for (j = 0; j < 2**(SIZE - level - 1); j = j + 1) begin
                localparam integer left_idx = (2**(SIZE - level )) - 1 + 2 * j;
                localparam integer right_idx = (2**(SIZE - level )) - 1 + 2 * j + 1;
                localparam integer parent_idx = (2**(SIZE - level -1)) - 1 + j;

                assign values[parent_idx] = (values[left_idx] >= values[right_idx]) ? 
                                            values[left_idx] : values[right_idx];
                
                assign indices[parent_idx] = (values[left_idx] > values[right_idx]) ? 
                                             indices[left_idx] : indices[right_idx];
            end
        end
    endgenerate
    
    assign data_max = values[0];
    assign argmax = indices[0];

endmodule 