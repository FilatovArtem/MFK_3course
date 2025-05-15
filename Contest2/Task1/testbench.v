`timescale 1ns / 1ps

module tree_adder_tb;

    // Параметры
    parameter WIDTH = 8;
    parameter MAX_SIZE = 4;  // Максимальное SIZE для теста

    // Сигналы
    reg [WIDTH*MAX_SIZE-1:0] data_in;
    wire [WIDTH-1:0] data_out;

    // Инстанцирование модуля tree_adder
    tree_adder #(
        .WIDTH(WIDTH),
        .SIZE(MAX_SIZE)
    ) dut (
        .data_in(data_in),
        .data_out(data_out)
    );

    // Тестовые данные
    initial begin
        // Тест 1: SIZE = 1
        $display("Testing SIZE = 1");
        data_in = {8'h05};  // Одно число: 5
        #10;
        if (data_out == 8'h05)
            $display("PASS: data_out = %h", data_out);
        else
            $display("FAIL: data_out = %h, expected 05", data_out);

        // Тест 2: SIZE = 2
        $display("Testing SIZE = 2");
        data_in = {8'h03, 8'h02};  // Числа: 3 и 2
        #10;
        if (data_out == 8'h05)  // 3 + 2 = 5
            $display("PASS: data_out = %h", data_out);
        else
            $display("FAIL: data_out = %h, expected 05", data_out);

        // Тест 3: SIZE = 4
        $display("Testing SIZE = 4");
        data_in = {8'h01, 8'h02, 8'h03, 8'h04};  // Числа: 1, 2, 3, 4
        #10;
        if (data_out == 8'h0A)  // 1 + 2 + 3 + 4 = 10 (0x0A)
            $display("PASS: data_out = %h", data_out);
        else
            $display("FAIL: data_out = %h, expected 0A", data_out);

        // Тест 4: SIZE = 4 с переполнением
        $display("Testing SIZE = 4 with overflow");
        data_in = {8'hFF, 8'hFF, 8'hFF, 8'hFF};  // Числа: 255, 255, 255, 255
        #10;
        if (data_out == 8'hFC)  // (255 + 255 + 255 + 255) mod 256 = 1020 mod 256 = 252 (0xFC)
            $display("PASS: data_out = %h", data_out);
        else
            $display("FAIL: data_out = %h, expected FC", data_out);

        // Завершение симуляции
        $finish;
    end

endmodule