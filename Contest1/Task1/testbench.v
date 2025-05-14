// Testbench for m_a module
`timescale 1ns/1ps

module testbench;
    // Inputs as registers
    reg x1, x2, x3;
    
    // Outputs as wires
    wire z1, z2;
    
    // Instantiate the Unit Under Test (UUT)
    m_a uut (
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .z1(z1),
        .z2(z2)
    );
    
    // Expected outputs based on comments in m_a.v
    // z1 = 10011101 (active for 000, 011, 100, 101, 110)
    // z2 = 00010111 (active for 011, 101, 110, 111)
    
    // Variables for test verification
    reg expected_z1, expected_z2;
    integer errors = 0;
    
    // Initialize inputs
    initial begin
        $display("Starting testbench for m_a module");
        $display("Time|x1 x2 x3|z1 z2|Expected z1 z2|Status");
        $display("--------------------------------------------------------");
        
        // Test all 8 possible input combinations
        {x1, x2, x3} = 3'b000; #10; verify_outputs();
        {x1, x2, x3} = 3'b001; #10; verify_outputs();
        {x1, x2, x3} = 3'b010; #10; verify_outputs();
        {x1, x2, x3} = 3'b011; #10; verify_outputs();
        {x1, x2, x3} = 3'b100; #10; verify_outputs();
        {x1, x2, x3} = 3'b101; #10; verify_outputs();
        {x1, x2, x3} = 3'b110; #10; verify_outputs();
        {x1, x2, x3} = 3'b111; #10; verify_outputs();
        
        // Summary
        if (errors == 0)
            $display("\nAll tests PASSED!");
        else
            $display("\n%d test(s) FAILED!", errors);
            
        $finish;
    end
    
    // Task to verify outputs against expected values
    task verify_outputs;
        begin
            // Determine expected outputs based on input combination
            case ({x1, x2, x3})
                3'b000: begin expected_z1 = 0; expected_z2 = 0; end
                3'b001: begin expected_z1 = 1; expected_z2 = 0; end
                3'b010: begin expected_z1 = 1; expected_z2 = 0; end
                3'b011: begin expected_z1 = 0; expected_z2 = 1; end
                3'b100: begin expected_z1 = 1; expected_z2 = 0; end
                3'b101: begin expected_z1 = 1; expected_z2 = 1; end
                3'b110: begin expected_z1 = 0; expected_z2 = 1; end
                3'b111: begin expected_z1 = 1; expected_z2 = 1; end
                default: begin expected_z1 = 1'bx; expected_z2 = 1'bx; end
            endcase
            
            // Check if outputs match expected values
            if (z1 !== expected_z1 || z2 !== expected_z2) begin
                $display("%3t|%b  %b  %b| %b  %b|    %b    %b    |FAIL", $time, x1, x2, x3, z1, z2, expected_z1, expected_z2);
                errors = errors + 1;
            end else begin
                $display("%3t|%b  %b  %b| %b  %b|    %b    %b    |PASS", $time, x1, x2, x3, z1, z2, expected_z1, expected_z2);
            end
        end
    endtask
    
endmodule

