module testbench;
    parameter WIDTH = 8;
    parameter SIZE = 3; // 8 входных чисел
    
    reg [(2**SIZE)*WIDTH-1:0] data_in;
    wire [WIDTH-1:0] data_max;
    wire [SIZE-1:0] argmax;
    
    // Инстанцирование тестируемого модуля
    max_argmax #(
        .WIDTH(WIDTH),
        .SIZE(SIZE)
    ) dut (
        .data_in(data_in),
        .data_max(data_max),
        .argmax(argmax)
    );
    
    // Вспомогательные переменные для входных данных
    reg [WIDTH-1:0] values[0:(2**SIZE)-1];
    
    // Переменные для проверки результатов
    reg [WIDTH-1:0] expected_max;
    reg [SIZE-1:0] expected_index;
    
    // Функция для нахождения ожидаемого максимума и его индекса
    task compute_expected_result;
        integer i;
        begin
            expected_max = values[0];
            expected_index = 0;
            
            for (i = 1; i < 2**SIZE; i = i + 1) begin
                // Если текущее значение больше максимума - обновляем максимум
                if (values[i] > expected_max) begin
                    expected_max = values[i];
                    expected_index = i;
                end
                // Если текущее значение равно максимуму - обновляем только индекс
                // В соответствии с условием: при равенстве берём последний индекс
                else if (values[i] == expected_max) begin
                    expected_index = i;
                end
            end
        end
    endtask
    
    // Функция для вывода значений и проверки результатов
    task print_and_verify_result;
        integer i;
        reg test_pass;
        begin
            $display("Входные значения:");
            for (i = 0; i < 2**SIZE; i = i + 1) begin
                $display("values[%0d] = %0d", i, values[i]);
            end
            
            compute_expected_result();
            
            $display("Ожидаемый результат: максимум = %0d, индекс = %0d", expected_max, expected_index);
            $display("Полученный результат: максимум = %0d, индекс = %0d", data_max, argmax);
            
            test_pass = (expected_max == data_max) && (expected_index == argmax);
            if (test_pass)
                $display("ТЕСТ ПРОЙДЕН ✓");
            else
                $display("ТЕСТ НЕ ПРОЙДЕН ✗");
                
            $display("------------------------");
        end
    endtask
    
    // Функция для заполнения data_in из массива values
    task fill_data_in;
        integer i;
        begin
            data_in = 0;
            for (i = 0; i < 2**SIZE; i = i + 1) begin
                data_in[WIDTH*(i+1)-1 -: WIDTH] = values[i];
            end
        end
    endtask
    
    initial begin
        // Тест 1: простая последовательность
        $display("Тест 1: Простая последовательность (возрастающая)");
        values[0] = 10; values[1] = 20; values[2] = 30; values[3] = 40;
        values[4] = 50; values[5] = 60; values[6] = 70; values[7] = 80;
        fill_data_in();
        #10;
        print_and_verify_result();
        
        // Тест 2: убывающая последовательность
        $display("Тест 2: Убывающая последовательность");
        values[0] = 80; values[1] = 70; values[2] = 60; values[3] = 50;
        values[4] = 40; values[5] = 30; values[6] = 20; values[7] = 10;
        fill_data_in();
        #10;
        print_and_verify_result();
        
        // Тест 3: случай с несколькими равными максимальными значениями
        $display("Тест 3: Несколько равных максимальных значений");
        values[0] = 50; values[1] = 30; values[2] = 80; values[3] = 20;
        values[4] = 80; values[5] = 10; values[6] = 80; values[7] = 40;
        fill_data_in();
        #10;
        print_and_verify_result();
        
        // Тест 4: равные максимумы в других позициях
        $display("Тест 4: Равные максимумы в разных позициях");
        values[0] = 80; values[1] = 30; values[2] = 40; values[3] = 80;
        values[4] = 50; values[5] = 80; values[6] = 10; values[7] = 20;
        fill_data_in();
        #10;
        print_and_verify_result();
        
        // Тест 5: максимум в начале
        $display("Тест 5: Максимум в начале");
        values[0] = 90; values[1] = 50; values[2] = 30; values[3] = 40;
        values[4] = 20; values[5] = 60; values[6] = 10; values[7] = 80;
        fill_data_in();
        #10;
        print_and_verify_result();
        
        // Тест 6: максимум в конце
        $display("Тест 6: Максимум в конце");
        values[0] = 50; values[1] = 20; values[2] = 30; values[3] = 40;
        values[4] = 70; values[5] = 60; values[6] = 10; values[7] = 90;
        fill_data_in();
        #10;
        print_and_verify_result();
        
        // Тест 7: все значения равны
        $display("Тест 7: Все значения равны");
        values[0] = 42; values[1] = 42; values[2] = 42; values[3] = 42;
        values[4] = 42; values[5] = 42; values[6] = 42; values[7] = 42;
        fill_data_in();
        #10;
        print_and_verify_result();
        
        // Тест 8: экстремальные значения (граничные случаи)
        $display("Тест 8: Экстремальные значения");
        values[0] = 0;   values[1] = 255; values[2] = 0;   values[3] = 128;
        values[4] = 255; values[5] = 0;   values[6] = 255; values[7] = 1;
        fill_data_in();
        #10;
        print_and_verify_result();
        
        // Тест 9: максимум в середине
        $display("Тест 9: Максимум в середине");
        values[0] = 10; values[1] = 20; values[2] = 30; values[3] = 99;
        values[4] = 50; values[5] = 60; values[6] = 70; values[7] = 80;
        fill_data_in();
        #10;
        print_and_verify_result();
        
        // Тест 10: чередующиеся значения
        $display("Тест 10: Чередующиеся значения");
        values[0] = 10; values[1] = 80; values[2] = 10; values[3] = 80;
        values[4] = 10; values[5] = 80; values[6] = 10; values[7] = 80;
        fill_data_in();
        #10;
        print_and_verify_result();
        
        $finish;
    end
endmodule
