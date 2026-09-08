module {
  func.func @w_state_8qubit() {
    // 8-qubit W-state: (|00000001> + |00000010> + ... + |10000000>) / sqrt(8)
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit
    %q4 = dqc.alloc_qubit : !dqc.qubit
    %q5 = dqc.alloc_qubit : !dqc.qubit
    %q6 = dqc.alloc_qubit : !dqc.qubit
    %q7 = dqc.alloc_qubit : !dqc.qubit

    // single excitation in q0
    dqc.x %q0 : (!dqc.qubit)

    // distribute excitation across remaining 7 qubits
    dqc.ry %q1 1.5708 : (!dqc.qubit)
    dqc.cnot %q0, %q1 : (!dqc.qubit, !dqc.qubit)

    dqc.ry %q2 1.5708 : (!dqc.qubit)
    dqc.cnot %q1, %q2 : (!dqc.qubit, !dqc.qubit)

    dqc.ry %q3 1.5708 : (!dqc.qubit)
    dqc.cnot %q2, %q3 : (!dqc.qubit, !dqc.qubit)

    dqc.ry %q4 1.5708 : (!dqc.qubit)
    dqc.cnot %q3, %q4 : (!dqc.qubit, !dqc.qubit)

    dqc.ry %q5 1.5708 : (!dqc.qubit)
    dqc.cnot %q4, %q5 : (!dqc.qubit, !dqc.qubit)

    dqc.ry %q6 1.5708 : (!dqc.qubit)
    dqc.cnot %q5, %q6 : (!dqc.qubit, !dqc.qubit)

    dqc.ry %q7 1.5708 : (!dqc.qubit)
    dqc.cnot %q6, %q7 : (!dqc.qubit, !dqc.qubit)

    return
  }
}
