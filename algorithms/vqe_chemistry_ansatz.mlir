module {
  func.func @vqe_chemistry_ansatz() {
    // 6-qubit hardware-efficient ansatz for molecular ground state (e.g. LiH)
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit
    %q4 = dqc.alloc_qubit : !dqc.qubit
    %q5 = dqc.alloc_qubit : !dqc.qubit

    // reference state |110000> (2 electrons across 6 spin-orbitals)
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)

    // parameterized single-qubit rotations
    dqc.ry %q0 0.5236 : (!dqc.qubit)
    dqc.ry %q1 0.7854 : (!dqc.qubit)
    dqc.ry %q2 0.3927 : (!dqc.qubit)
    dqc.ry %q3 0.5236 : (!dqc.qubit)
    dqc.ry %q4 0.7854 : (!dqc.qubit)
    dqc.ry %q5 0.3927 : (!dqc.qubit)

    dqc.rz %q0 1.0472 : (!dqc.qubit)
    dqc.rz %q1 0.5236 : (!dqc.qubit)
    dqc.rz %q2 0.7854 : (!dqc.qubit)
    dqc.rz %q3 1.0472 : (!dqc.qubit)
    dqc.rz %q4 0.5236 : (!dqc.qubit)
    dqc.rz %q5 0.7854 : (!dqc.qubit)

    // entangling ring couplers
    dqc.cnot %q0, %q1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q1, %q2 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q2, %q3 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q3, %q4 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q4, %q5 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q5, %q0 : (!dqc.qubit, !dqc.qubit)

    // second variational layer
    dqc.ry %q0 0.3927 : (!dqc.qubit)
    dqc.ry %q1 0.5236 : (!dqc.qubit)
    dqc.ry %q2 0.7854 : (!dqc.qubit)
    dqc.ry %q3 0.3927 : (!dqc.qubit)
    dqc.ry %q4 0.5236 : (!dqc.qubit)
    dqc.ry %q5 0.7854 : (!dqc.qubit)

    return
  }
}
