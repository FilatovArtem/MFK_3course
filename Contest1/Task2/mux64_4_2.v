module mux1_4(output z, input y0, y1, y2, y3, input [1:0] x);
    wire n0, n1, n2, n3, nx0, nx1;
    not(nx0, x[0]);
    not(nx1, x[1]);
    and(n0, y0, nx1, nx0);
    and(n1, y1, nx1,  x[0]);
    and(n2, y2,  x[1], nx0);
    and(n3, y3,  x[1],  x[0]);
    or(z, n0, n1, n2, n3);
endmodule

module mux64_4_2(output [63:0] z, input [63:0] y0, y1, y2, y3, input [1:0] x);
    mux1_4 m[63:0](z, y0, y1, y2, y3, x);
endmodule

