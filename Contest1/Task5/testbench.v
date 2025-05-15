`timescale 1ns / 1ps

module tb_shift_register;

  parameter WIDTH  = 8;
  parameter LENGTH = 4;
  parameter TOTAL_CYCLES = 12;

  reg  [WIDTH-1:0] data_in;
  reg              clock, reset;
  wire [WIDTH-1:0] data_out;

  shift_register #(
    .WIDTH(WIDTH),
    .LENGTH(LENGTH)
  ) dut (
    .data_in (data_in),
    .clock   (clock),
    .reset   (reset),
    .data_out(data_out)
  );

  reg [WIDTH-1:0] tb_pipe [0:LENGTH-1];
  reg [WIDTH-1:0] next_data;
  integer i, j;

  initial clock = 0;
  always #5 clock = ~clock;

  initial begin
    reset = 1;
    data_in = 0;
    next_data = 8'h01;

    // Очистка модельной цепочки
    for (j = 0; j < LENGTH; j = j + 1)
      tb_pipe[j] = 0;

    // Сброс
    @(posedge clock);
    @(posedge clock);
    reset = 0;

    $display("=== Проверка корректного сдвига ===");

    for (i = 0; i < TOTAL_CYCLES; i = i + 1) begin
      data_in = next_data;
      next_data = next_data + 8'h11;

      // Перед фронтом — заранее моделируем pipeline
      for (j = LENGTH-1; j > 0; j = j - 1)
        tb_pipe[j] = tb_pipe[j-1];
      tb_pipe[0] = data_in;

      @(posedge clock);

      // Теперь сравниваем
      if (data_out !== tb_pipe[LENGTH-1]) begin
        $display("ERROR @ cycle %0d: got %h, expected %h", 
                  i, data_out, tb_pipe[LENGTH-1]);
      end else begin
        $display(" PASS @ cycle %0d: data_out = %h", i, data_out);
      end
    end

    // Проверка сброса
    $display("=== Проверка сброса ===");
    reset = 1;
    @(posedge clock);
    if (data_out !== 0)
      $display("ERROR after reset: data_out = %h, expected 00", data_out);
    else
      $display(" PASS after reset: data_out = %h", data_out);

    $display("=== Тест завершён ===");
    $finish;
  end

endmodule
