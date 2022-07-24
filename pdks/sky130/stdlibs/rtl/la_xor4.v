
module la_xor4(a, b, c, d, z);
  wire _0_;
  wire _1_;
  input a;
  input b;
  input c;
  input d;
  output z;
  sky130_fd_sc_hd__xor2_2 _2_ (
    .A(c),
    .B(d),
    .X(_0_)
  );
  sky130_fd_sc_hd__xnor2_2 _3_ (
    .A(b),
    .B(a),
    .Y(_1_)
  );
  sky130_fd_sc_hd__xnor2_2 _4_ (
    .A(_0_),
    .B(_1_),
    .Y(z)
  );
endmodule
