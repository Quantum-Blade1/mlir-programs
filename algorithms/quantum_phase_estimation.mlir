module {
  func.func @quantum_phase_estimation() {
    // 5-bit counting register + 1 target eigenstate qubit
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit
    %q4 = dqc.alloc_qubit : !dqc.qubit
    %psi = dqc.alloc_qubit : !dqc.qubit

    // prepare eigenstate |1>
    dqc.x %psi : (!dqc.qubit)

    // superposition across counting register
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.h %q3 : (!dqc.qubit)
    dqc.h %q4 : (!dqc.qubit)

    // controlled phase kickback (encoding theta = 1/8)
    dqc.cz %q2, %psi : (!dqc.qubit, !dqc.qubit)

    // inverse QFT to extract phase back into computational basis
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.h %q3 : (!dqc.qubit)
    dqc.h %q4 : (!dqc.qubit)

    %c0 = dqc.measure %q0 : (!dqc.qubit) -> !dqc.cbit
    %c1 = dqc.measure %q1 : (!dqc.qubit) -> !dqc.cbit
    %c2 = dqc.measure %q2 : (!dqc.qubit) -> !dqc.cbit
    %c3 = dqc.measure %q3 : (!dqc.qubit) -> !dqc.cbit
    %c4 = dqc.measure %q4 : (!dqc.qubit) -> !dqc.cbit

    return
  }
}
