module {
  func.func @quantum_error_correction() {
    // 3 data qubits (repetition code) + 2 syndrome ancillas + 1 parity flag
    %d0 = dqc.alloc_qubit : !dqc.qubit
    %d1 = dqc.alloc_qubit : !dqc.qubit
    %d2 = dqc.alloc_qubit : !dqc.qubit
    %syn0 = dqc.alloc_qubit : !dqc.qubit
    %syn1 = dqc.alloc_qubit : !dqc.qubit
    %flag = dqc.alloc_qubit : !dqc.qubit

    // encode logical |1> -> |111>
    dqc.x %d0 : (!dqc.qubit)
    dqc.cnot %d0, %d1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %d0, %d2 : (!dqc.qubit, !dqc.qubit)

    // simulate bit-flip noise on d1
    dqc.x %d1 : (!dqc.qubit)

    // syndrome measurement: check parity between d0,d1 and d1,d2
    dqc.cnot %d0, %syn0 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %d1, %syn0 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %d1, %syn1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %d2, %syn1 : (!dqc.qubit, !dqc.qubit)

    // syndrome (1,1) uniquely identifies d1 corrupted -> flip back via CCX
    dqc.ccx %syn0, %syn1, %d1 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)

    // check logical state restored
    dqc.ccx %d0, %d1, %flag : (!dqc.qubit, !dqc.qubit, !dqc.qubit)

    return
  }
}
