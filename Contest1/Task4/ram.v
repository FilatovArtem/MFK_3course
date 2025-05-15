module ram #(parameter DATA_WIDTH = 8, ADDR_WIDTH = 4)(
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire [ADDR_WIDTH-1:0] address,
    input  wire clock,
    input  wire write_enable,
    output wire [DATA_WIDTH-1:0] data_out
);

    reg [DATA_WIDTH-1:0] memory [0:(1<<ADDR_WIDTH)-1];

    always @(posedge clock) begin
        if (write_enable)
            memory[address] <= data_in;
    end

    assign data_out = memory[address]; // тут важен именно assign, чтобы не было задержки в 1 такт между чтением и записью

endmodule
