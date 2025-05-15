`timescale 1ns / 1ps

module ram_tb;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter DEPTH = 1 << ADDR_WIDTH;

    reg  [DATA_WIDTH-1:0] data_in;
    reg  [ADDR_WIDTH-1:0] address;
    reg  clock;
    reg  write_enable;
    wire [DATA_WIDTH-1:0] data_out;

    // Instantiate RAM
    ram #(DATA_WIDTH, ADDR_WIDTH) dut (
        .data_in(data_in),
        .address(address),
        .clock(clock),
        .write_enable(write_enable),
        .data_out(data_out)
    );

    reg [DATA_WIDTH-1:0] expected_mem [0:DEPTH-1];

    integer i;

    // Clock generation
    always #5 clock = ~clock;

    initial begin
        $display("=== TESTBENCH START ===");
        clock = 0;
        write_enable = 0;
        data_in = 0;
        address = 0;

        // Initialize expected memory with values
        for (i = 0; i < DEPTH; i = i + 1)
            expected_mem[i] = 8'h10 + i;  // 0x10..0x1F

        // === STEP 1: WRITE TO RAM ===
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge clock);
            address <= i;
            data_in <= expected_mem[i];
            write_enable <= 1;
        end

        @(posedge clock);
        write_enable <= 0;

        // === STEP 2: READ AND VERIFY ===
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(posedge clock);
            address <= i;
            #1;
            if (data_out !== expected_mem[i])
                $display("ERROR: addr=%0d, expected=%h, got=%h", i, expected_mem[i], data_out);
            else
                $display("PASS:  addr=%0d, data=%h", i, data_out);
        end

        $display("=== TESTBENCH END ===");
        $finish;
    end

endmodule
