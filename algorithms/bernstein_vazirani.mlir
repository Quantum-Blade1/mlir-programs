module {
  func.func @bernstein_vazirani() {
    // 4 query qubits + 1 ancilla qubit
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit
    %anc = dqc.alloc_qubit : !dqc.qubit

    // Ancilla to |-> state
    dqc.x %anc : (!dqc.qubit)
    dqc.h %anc : (!dqc.qubit)

    // Query qubits to superposition |+>
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.h %q3 : (!dqc.qubit)

    // Oracle for hidden string s = 1011
    // (CNOT on qubits where bit is 1: q0, q1, q3)
    dqc.cnot %q0, %anc : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q1, %anc : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q3, %anc : (!dqc.qubit, !dqc.qubit)

    // Interference step: Hadamard on query qubits
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.h %q3 : (!dqc.qubit)

    return
  }
}
