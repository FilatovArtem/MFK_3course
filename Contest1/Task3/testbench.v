`timescale 1ns / 1ps

module tb_au;

  parameter WIDTH_1 = 4;
  parameter WIDTH_2 = 4;

  reg  [WIDTH_1-1:0] x_int, y_int;
  reg  [WIDTH_2-1:0] x_frac, y_frac;
  reg  operation;
  wire zero, overflow;
  wire [WIDTH_1-1:0] result_int;
  wire [WIDTH_2-1:0] result_frac;

  real x_val, y_val, expected, result;
  integer i, j, k;

  au #(WIDTH_1, WIDTH_2) dut (
    .x_int(x_int), .x_frac(x_frac),
    .y_int(y_int), .y_frac(y_frac),
    .operation(operation),
    .zero(zero), .overflow(overflow),
    .result_int(result_int), .result_frac(result_frac)
  );

  function real to_real(input [WIDTH_1-1:0] int_part, input [WIDTH_2-1:0] frac_part);
    to_real = int_part + frac_part / (1.0 * (1 << WIDTH_2));
  endfunction

  initial begin
    $display("=== RUNNING AUTOMATED TESTBENCH ===");

    for (i = 0; i <= 15; i = i + 5) begin
      for (j = 0; j <= 15; j = j + 5) begin
        for (k = 0; k <= 1; k = k + 1) begin
          x_int = i[3:0]; x_frac = j[3:0];
          y_int = 15 - i[3:0]; y_frac = 15 - j[3:0];
          operation = k;

          #1; // wait one delta

          x_val = to_real(x_int, x_frac);
          y_val = to_real(y_int, y_frac);

          if (operation == 0)
            expected = x_val + y_val;
          else
            expected = x_val * y_val;

          result = to_real(result_int, result_frac);

          $display("x = %0.2f, y = %0.2f, op = %s => result = %0.2f | expect = %0.2f | zero = %b | overflow = %b",
                   x_val, y_val, operation ? "MUL" : "ADD", result, expected, zero, overflow);
        end
      end
    end

    $display("=== TESTBENCH COMPLETE ===");
    $finish;
  end

endmodule

