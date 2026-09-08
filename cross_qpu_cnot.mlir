module {
  func.func @cross_cnot() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit
    // local ops on "QPU 0 side"
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    // local ops on "QPU 1 side"
    dqc.x %q2 : (!dqc.qubit)
    dqc.x %q3 : (!dqc.qubit)
    // cross-partition gate — must trigger teleportation insert
    dqc.cnot %q0, %q2 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q1, %q3 : (!dqc.qubit, !dqc.qubit)
    %c0 = dqc.measure %q0 : (!dqc.qubit) -> !dqc.cbit
    %c1 = dqc.measure %q1 : (!dqc.qubit) -> !dqc.cbit
    %c2 = dqc.measure %q2 : (!dqc.qubit) -> !dqc.cbit
    %c3 = dqc.measure %q3 : (!dqc.qubit) -> !dqc.cbit
    return
  }
}
