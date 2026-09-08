module {
  func.func @cross_toffoli() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit
    %q4 = dqc.alloc_qubit : !dqc.qubit
    %q5 = dqc.alloc_qubit : !dqc.qubit
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q3 : (!dqc.qubit)
    // controls on different QPUs, target on yet another
    dqc.ccx %q0, %q3, %q5 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    // local toffoli for comparison
    dqc.ccx %q0, %q1, %q2 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    %c0 = dqc.measure %q0 : (!dqc.qubit) -> !dqc.cbit
    %c1 = dqc.measure %q1 : (!dqc.qubit) -> !dqc.cbit
    %c2 = dqc.measure %q2 : (!dqc.qubit) -> !dqc.cbit
    %c3 = dqc.measure %q3 : (!dqc.qubit) -> !dqc.cbit
    %c4 = dqc.measure %q4 : (!dqc.qubit) -> !dqc.cbit
    %c5 = dqc.measure %q5 : (!dqc.qubit) -> !dqc.cbit
    return
  }
}
