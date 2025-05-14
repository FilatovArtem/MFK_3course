module tb_mux64_4_2;
  reg [63:0] y0, y1, y2, y3;
  reg [1:0] x;
  wire [63:0] z;
  reg [63:0] expected;
  integer i, sel;

  mux64_4_2 dut(z, y0, y1, y2, y3, x);

  task clear_all_inputs;
    begin
      y0 = 64'd0;
      y1 = 64'd0;
      y2 = 64'd0;
      y3 = 64'd0;
    end
  endtask

  task set_single_bit(input integer bit_idx, input integer select);
    begin
      clear_all_inputs();
      case (select)
        0: y0[bit_idx] = 1'b1;
        1: y1[bit_idx] = 1'b1;
        2: y2[bit_idx] = 1'b1;
        3: y3[bit_idx] = 1'b1;
      endcase
      x = select[1:0];
    end
  endtask

  task check_single_bit(input integer bit_idx, input integer select);
    begin
      set_single_bit(bit_idx, select);
      #1;
      expected = 64'd0;
      expected[bit_idx] = 1'b1;

      if (z !== expected) begin
        $display("❌ FAIL at select=%b bit=%0d: z=%h expected=%h", select[1:0], bit_idx, z, expected);
      end else begin
        $display("✅ PASS at select=%b bit=%0d", select[1:0], bit_idx);
      end
    end
  endtask

  initial begin
    $display("🔍 Starting full bitwise verification of mux64_4_2...");
    for (sel = 0; sel < 4; sel = sel + 1) begin
      for (i = 0; i < 64; i = i + 1) begin
        check_single_bit(i, sel);
      end
    end
    $display("✅ All checks completed.");
    $finish;
  end
endmodule

