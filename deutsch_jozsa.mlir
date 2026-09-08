module {
  func.func @deutsch_jozsa() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %anc = dqc.alloc_qubit : !dqc.qubit

    // Ancilla in |-> state
    dqc.x %anc : (!dqc.qubit)
    dqc.h %anc : (!dqc.qubit)

    // Query qubits in superposition
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)

    // Balanced Oracle: f(x) = x0 XOR x1
    dqc.cnot %q0, %anc : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q1, %anc : (!dqc.qubit, !dqc.qubit)

    // Interference
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)

    return
  }
}
