module testbench;
    // Параметры тестбенча
    parameter WIDTH = 8;
    parameter FEATURES = 2;
    parameter C_WIDTH = 2; // 4 класса
    
    // Входы и выходы модуля
    reg [FEATURES*WIDTH-1:0] features;
    reg [(2**C_WIDTH)*FEATURES*WIDTH-1:0] weights;
    wire [WIDTH-1:0] r_value;
    wire [C_WIDTH-1:0] r_class;
    
    // Вспомогательные массивы для хранения данных
    reg [WIDTH-1:0] feature_values[0:FEATURES-1];
    reg [WIDTH-1:0] weight_values[0:(2**C_WIDTH)*FEATURES-1];
    
    // Инстанцирование тестируемого модуля
    linear_classifier #(
        .WIDTH(WIDTH),
        .FEATURES(FEATURES),
        .C_WIDTH(C_WIDTH)
    ) dut (
        .features(features),
        .weights(weights),
        .r_value(r_value),
        .r_class(r_class)
    );
    
    // Функция для заполнения шины features из массива
    task fill_features;
        integer i;
        begin
            features = 0;
            for (i = 0; i < FEATURES; i = i + 1) begin
                features = features | (feature_values[i] << (i*WIDTH));
            end
        end
    endtask
    
    // Функция для заполнения шины weights из массива
    task fill_weights;
        integer c, f, idx;
        begin
            weights = 0;
            for (c = 0; c < 2**C_WIDTH; c = c + 1) begin
                for (f = 0; f < FEATURES; f = f + 1) begin
                    idx = c*FEATURES + f;
                    weights = weights | (weight_values[idx] << (idx*WIDTH));
                end
            end
        end
    endtask
    
    // Функция для вывода входных и выходных данных
    task print_results;
        integer c, f;
        integer sum, max_sum, max_class;
        begin
            $display("Входные признаки:");
            for (f = 0; f < FEATURES; f = f + 1) begin
                $display("  Признак[%0d] = %0d", f, feature_values[f]);
            end
            
            $display("Веса:");
            for (c = 0; c < 2**C_WIDTH; c = c + 1) begin
                $display("  Класс %0d:", c);
                for (f = 0; f < FEATURES; f = f + 1) begin
                    $display("    Вес[%0d] = %0d", f, weight_values[c*FEATURES+f]);
                end
            end
            
            // Вычисляем вручную суммы для каждого класса для сравнения
            max_sum = 0;
            max_class = 0;
            
            for (c = 0; c < 2**C_WIDTH; c = c + 1) begin
                sum = 0;
                for (f = 0; f < FEATURES; f = f + 1) begin
                    sum = sum + feature_values[f] * weight_values[c*FEATURES+f];
                end
                $display("  Сумма для класса %0d = %0d", c, sum);
                
                if (c == 0 || sum > max_sum) begin
                    max_sum = sum;
                    max_class = c;
                end
            end
            
            $display("Ожидаемый результат: класс %0d, значение %0d", max_class, max_sum);
            $display("Полученный результат: класс %0d, значение %0d", r_class, r_value);
            $display("------------------------");
        end
    endtask
    
    initial begin
        // Тест 1: Простой случай с 2 признаками и 4 классами
        $display("Тест 1: Простой случай");
        
        // Устанавливаем значения признаков
        feature_values[0] = 10;
        feature_values[1] = 5;
        
        // Устанавливаем веса для всех классов
        // Класс 0
        weight_values[0*FEATURES+0] = 1;
        weight_values[0*FEATURES+1] = 2;
        // Класс 1
        weight_values[1*FEATURES+0] = 3;
        weight_values[1*FEATURES+1] = 4;
        // Класс 2
        weight_values[2*FEATURES+0] = 2;
        weight_values[2*FEATURES+1] = 1;
        // Класс 3
        weight_values[3*FEATURES+0] = 1;
        weight_values[3*FEATURES+1] = 1;
        
        // Заполняем входные шины
        fill_features();
        fill_weights();
        
        // Ждем выполнения вычислений и выводим результаты
        #10;
        print_results();
        
        // Тест 2: Другой набор данных
        $display("Тест 2: Другой набор данных");
        
        // Устанавливаем значения признаков
        feature_values[0] = 8;
        feature_values[1] = 12;
        
        // Устанавливаем веса для всех классов
        // Класс 0
        weight_values[0*FEATURES+0] = 5;
        weight_values[0*FEATURES+1] = 2;
        // Класс 1
        weight_values[1*FEATURES+0] = 1;
        weight_values[1*FEATURES+1] = 1;
        // Класс 2
        weight_values[2*FEATURES+0] = 2;
        weight_values[2*FEATURES+1] = 3;
        // Класс 3
        weight_values[3*FEATURES+0] = 0;
        weight_values[3*FEATURES+1] = 5;
        
        // Заполняем входные шины
        fill_features();
        fill_weights();
        
        // Ждем выполнения вычислений и выводим результаты
        #10;
        print_results();
        
        // Тест 3: Случай с одинаковыми максимальными значениями
        $display("Тест 3: Одинаковые максимальные значения");
        
        // Устанавливаем значения признаков
        feature_values[0] = 5;
        feature_values[1] = 5;
        
        // Устанавливаем веса для всех классов
        // Класс 0
        weight_values[0*FEATURES+0] = 2;
        weight_values[0*FEATURES+1] = 4;
        // Класс 1
        weight_values[1*FEATURES+0] = 3;
        weight_values[1*FEATURES+1] = 3;
        // Класс 2
        weight_values[2*FEATURES+0] = 4;
        weight_values[2*FEATURES+1] = 2;
        // Класс 3
        weight_values[3*FEATURES+0] = 3;
        weight_values[3*FEATURES+1] = 3;
        
        // Заполняем входные шины
        fill_features();
        fill_weights();
        
        // Ждем выполнения вычислений и выводим результаты
        #10;
        print_results();
        
        $finish;
    end
endmodule
