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
    
    // Функция для вывода значений
    task print_result;
        integer i;
        begin
            $display("Входные значения:");
            for (i = 0; i < 2**SIZE; i = i + 1) begin
                $display("values[%0d] = %0d", i, values[i]);
            end
            $display("Максимум: %0d, индекс: %0d", data_max, argmax);
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
        $display("Тест 1: Простая последовательность");
        values[0] = 10; values[1] = 20; values[2] = 30; values[3] = 40;
        values[4] = 50; values[5] = 60; values[6] = 70; values[7] = 80;
        fill_data_in();
        #10;
        print_result();
        
        // Тест 2: случай равных максимальных значений
        $display("Тест 2: Равные максимальные значения");
        values[0] = 50; values[1] = 30; values[2] = 80; values[3] = 20;
        values[4] = 80; values[5] = 10; values[6] = 80; values[7] = 40;
        fill_data_in();
        #10;
        print_result();
        
        // Тест 3: максимум в начале
        $display("Тест 3: Максимум в начале");
        values[0] = 90; values[1] = 50; values[2] = 30; values[3] = 40;
        values[4] = 20; values[5] = 60; values[6] = 10; values[7] = 80;
        fill_data_in();
        #10;
        print_result();
        
        // Тест 4: максимум в конце
        $display("Тест 4: Максимум в конце");
        values[0] = 50; values[1] = 20; values[2] = 30; values[3] = 40;
        values[4] = 70; values[5] = 60; values[6] = 10; values[7] = 90;
        fill_data_in();
        #10;
        print_result();
        
        // Тест 5: все значения равны
        $display("Тест 5: Все значения равны");
        values[0] = 42; values[1] = 42; values[2] = 42; values[3] = 42;
        values[4] = 42; values[5] = 42; values[6] = 42; values[7] = 42;
        fill_data_in();
        #10;
        print_result();
        
        $finish;
    end
endmodule
