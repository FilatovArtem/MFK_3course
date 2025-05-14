module m_a(x1, x2, x3, z1, z2);
    input x1, x2, x3;
    output z1, z2;

    wire nx1, nx2, nx3;

    not u1(nx1, x1),
         u2(nx2, x2),
         u3(nx3, x3);

    wire t1, t2, t3, t4, t5, t6, t7, t8;
    and a1(t1, nx1, nx2, nx3),  // 000
        a2(t2, nx1, nx2, x3),   // 001
        a3(t3, nx1, x2, nx3),   // 010
        a4(t4, nx1, x2, x3),    // 011
        a5(t5, x1, nx2, nx3),   // 100
        a6(t6, x1, nx2, x3),    // 101
        a7(t7, x1, x2, nx3),    // 110
        a8(t8, x1, x2, x3);     // 111

    or o1(z1, t2, t3, t5, t6, t8),  // z1=01101101 
       o2(z2, t4, t6, t7, t8);      // z2 = 00010111
endmodule
