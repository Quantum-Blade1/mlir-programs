module {
  func.func @quantum_random_walk() {
    // 2 coin qubits + 3 position qubits (3D cube) + 3 step ancillas = 8 qubits
    %c0 = dqc.alloc_qubit : !dqc.qubit
    %c1 = dqc.alloc_qubit : !dqc.qubit
    %x  = dqc.alloc_qubit : !dqc.qubit
    %y  = dqc.alloc_qubit : !dqc.qubit
    %z  = dqc.alloc_qubit : !dqc.qubit
    %a0 = dqc.alloc_qubit : !dqc.qubit
    %a1 = dqc.alloc_qubit : !dqc.qubit
    %a2 = dqc.alloc_qubit : !dqc.qubit

    // coin toss
    dqc.h %c0 : (!dqc.qubit)
    dqc.h %c1 : (!dqc.qubit)

    // conditional shift in X (coin = 00)
    dqc.x %c0 : (!dqc.qubit)
    dqc.x %c1 : (!dqc.qubit)
    dqc.ccx %c0, %c1, %x : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.x %c0 : (!dqc.qubit)
    dqc.x %c1 : (!dqc.qubit)

    // conditional shift in Y (coin = 01)
    dqc.x %c1 : (!dqc.qubit)
    dqc.ccx %c0, %c1, %y : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.x %c1 : (!dqc.qubit)

    // conditional shift in Z (coin = 10)
    dqc.x %c0 : (!dqc.qubit)
    dqc.ccx %c0, %c1, %z : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.x %c0 : (!dqc.qubit)

    // record path history
    dqc.cnot %x, %a0 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %y, %a1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %z, %a2 : (!dqc.qubit, !dqc.qubit)

    return
  }
}
