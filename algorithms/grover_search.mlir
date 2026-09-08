module {
  func.func @grover_search() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit

    // superposition
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.barrier

    // === Iteration 1 ===
    // Oracle: phase flip |101>
    // flip q1, CZ(q0,q2) applies -1 to |11>, unflip q1
    dqc.x %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.ccx %q0, %q1, %q2 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)
    dqc.barrier

    // Diffuser
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)
    dqc.x %q2 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.ccx %q0, %q1, %q2 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)
    dqc.x %q2 : (!dqc.qubit)
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.barrier

    // === Iteration 2 ===
    dqc.x %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.ccx %q0, %q1, %q2 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)
    dqc.barrier

    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)
    dqc.x %q2 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.ccx %q0, %q1, %q2 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)
    dqc.x %q2 : (!dqc.qubit)
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.barrier

    %c0 = dqc.measure %q0 : (!dqc.qubit) -> !dqc.cbit
    %c1 = dqc.measure %q1 : (!dqc.qubit) -> !dqc.cbit
    %c2 = dqc.measure %q2 : (!dqc.qubit) -> !dqc.cbit

    return
  }
}
