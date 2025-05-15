module testbench;
    // Параметры тестирования
    parameter ROWS = 2;
    parameter COLUMNS = 2;
    parameter WIDTH = 8;

    // Входные сигналы
    reg clock;
    reg reset;
    reg [ROWS*WIDTH-1:0] a;
    reg [COLUMNS*WIDTH-1:0] b;

    // Выходные сигналы
    wire [ROWS*COLUMNS*WIDTH-1:0] c;

    // Вспомогательные массивы для проверки
    reg [WIDTH-1:0] a_values[0:ROWS-1];
    reg [WIDTH-1:0] b_values[0:COLUMNS-1];
    reg [WIDTH-1:0] c_expected[0:ROWS-1][0:COLUMNS-1];
    reg [WIDTH-1:0] c_actual[0:ROWS-1][0:COLUMNS-1];

    // Счетчик пройденных и непройденных тестов
    integer tests_passed = 0;
    integer tests_failed = 0;

    // Инстанцирование тестируемого модуля
    systolic_array #(
        .ROWS(ROWS),
        .COLUMNS(COLUMNS),
        .WIDTH(WIDTH)
    ) dut (
        .clock(clock),
        .reset(reset),
        .a(a),
        .b(b),
        .c(c)
    );

    // Генерация тактового сигнала
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    // Вспомогательная задача для заполнения входных шин
    task fill_inputs;
        integer i;
        begin
            a = 0;
            b = 0;
            for (i = 0; i < ROWS; i = i + 1) begin
                a = a | (a_values[i] << (i*WIDTH));
            end
            for (i = 0; i < COLUMNS; i = i + 1) begin
                b = b | (b_values[i] << (i*WIDTH));
            end
        end
    endtask

    // Вспомогательная задача для извлечения выходных значений
    task extract_outputs;
        integer i, j;
        begin
            for (i = 0; i < ROWS; i = i + 1) begin
                for (j = 0; j < COLUMNS; j = j + 1) begin
                    c_actual[i][j] = c[(i*COLUMNS+j+1)*WIDTH-1 -: WIDTH];
                end
            end
        end
    endtask

    // Расчет ожидаемого результата матричного умножения
    task compute_expected;
        integer i, j;
        begin
            // Для систолического массива с векторным вводом a и b,
            // результат должен быть простым произведением элементов
            for (i = 0; i < ROWS; i = i + 1) begin
                for (j = 0; j < COLUMNS; j = j + 1) begin
                    // Произведение соответствующих элементов входных векторов
                    c_expected[i][j] = a_values[i] * b_values[j];
                end
            end
        end
    endtask

    // Вывод входных значений
    task print_inputs;
        input [4*64:1] test_name;
        integer i;
        begin
            $display("\n======= Тест: %s =======", test_name);
            $display("Вектор a:");
            for (i = 0; i < ROWS; i = i + 1) begin
                $display("  a[%0d] = %0d", i, a_values[i]);
            end

            $display("Вектор b:");
            for (i = 0; i < COLUMNS; i = i + 1) begin
                $display("  b[%0d] = %0d", i, b_values[i]);
            end
        end
    endtask

    // Вывод результатов
    task print_results;
        integer i, j;
        reg test_pass;
        begin
            $display("Ожидаемый результат:");
            for (i = 0; i < ROWS; i = i + 1) begin
                for (j = 0; j < COLUMNS; j = j + 1) begin
                    $display("  c[%0d][%0d] = %0d", i, j, c_expected[i][j]);
                end
            end

            $display("Фактический результат:");
            for (i = 0; i < ROWS; i = i + 1) begin
                for (j = 0; j < COLUMNS; j = j + 1) begin
                    $display("  c[%0d][%0d] = %0d", i, j, c_actual[i][j]);
                end
            end

            test_pass = 1;
            for (i = 0; i < ROWS; i = i + 1) begin
                for (j = 0; j < COLUMNS; j = j + 1) begin
                    if (c_expected[i][j] != c_actual[i][j]) begin
                        test_pass = 0;
                    end
                end
            end

            if (test_pass) begin
                $display("ТЕСТ ПРОЙДЕН ✓");
                tests_passed = tests_passed + 1;
            end else begin
                $display("ТЕСТ НЕ ПРОЙДЕН ✗");
                tests_failed = tests_failed + 1;
            end

            $display("------------------------");
        end
    endtask

    // Полный цикл тестирования
    task run_test;
        input [4*64:1] test_name;
        begin
            fill_inputs();
            compute_expected();
            print_inputs(test_name);

            @(posedge clock); // Подаем данные
            @(posedge clock); // Ждем обработки (латентность 1)
            extract_outputs();
            print_results();
        end
    endtask

    // Тестовые сценарии
    initial begin
        // Инициализация
        reset = 1;
        a = 0;
        b = 0;

        // Сброс системы
        @(posedge clock);
        reset = 0;
        @(posedge clock);
        reset = 1;
        @(posedge clock);

        // Тест 1: Все значения равны 1
        a_values[0] = 1; a_values[1] = 1;
        b_values[0] = 1; b_values[1] = 1;
        run_test("Vse_znacheniya_ravny_1");

        // Тест 2: Разные значения
        a_values[0] = 2; a_values[1] = 3;
        b_values[0] = 4; b_values[1] = 5;
        run_test("Raznye_znacheniya");

        // Тест 3: Нулевые значения в a
        a_values[0] = 0; a_values[1] = 0;
        b_values[0] = 4; b_values[1] = 5;
        run_test("Nulevye_znacheniya_v_a");

        // Тест 4: Нулевые значения в b
        a_values[0] = 2; a_values[1] = 3;
        b_values[0] = 0; b_values[1] = 0;
        run_test("Nulevye_znacheniya_v_b");

        // Тест 5: Граничные значения (максимальные для 8 бит)
        a_values[0] = 255; a_values[1] = 255;
        b_values[0] = 255; b_values[1] = 255;
        run_test("Granichnye_znacheniya_max");

        // Тест 6: Смешанные значения - нулевые и максимальные
        a_values[0] = 0; a_values[1] = 255;
        b_values[0] = 255; b_values[1] = 0;
        run_test("Smeshannye_znacheniya");

        // Тест 7: Значения, приводящие к переполнению
        a_values[0] = 200; a_values[1] = 100;
        b_values[0] = 100; b_values[1] = 200;
        run_test("Vozmozhnoe_perepolnenie");

        // Тест 8: Проверка последовательных вычислений (меняем только a)
        a_values[0] = 7; a_values[1] = 9;
        b_values[0] = 2; b_values[1] = 3;
        run_test("Posledovatelnoe_vychislenie_1");

        // Тест 9: Проверка последовательных вычислений (меняем только b)
        a_values[0] = 7; a_values[1] = 9;
        b_values[0] = 8; b_values[1] = 6;
        run_test("Posledovatelnoe_vychislenie_2");

        // Тест 10: Проверка сброса
        $display("\n======= Тест: Проверка сброса =======");
        reset = 0;
        @(posedge clock);
        extract_outputs();

        // Проверяем, что все значения обнулились
        for (integer i = 0; i < ROWS; i = i + 1) begin
            for (integer j = 0; j < COLUMNS; j = j + 1) begin
                c_expected[i][j] = 0;
            end
        end
        print_results();

        // Вывод общих результатов
        $display("\n======= Итоги тестирования =======");
        $display("Всего тестов: %0d", tests_passed + tests_failed);
        $display("Пройдено: %0d", tests_passed);
        $display("Не пройдено: %0d", tests_failed);
        if (tests_failed == 0)
            $display("Все тесты пройдены успешно! ✓");
        else
            $display("Есть проблемы в тестах! ✗");

        $finish;
    end

endmodule
