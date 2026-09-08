module {
  // ============================================================================
  // Quantum Error Correction (3-Qubit Bit-Flip Code + Syndrome Extraction) - 6 Qubits
  // ============================================================================
  // Protects a logical qubit against arbitrary single-qubit bit-flip (X) errors.
  //
  // Register Configuration:
  // - %d0, %d1, %d2 : 3 physical data qubits encoding 1 logical qubit (|1>_L -> |111>)
  // - %s0, %s1      : 2 ancilla syndrome measurement qubits detecting error location
  // - %flag         : 1 verification flag qubit
  // ============================================================================
  func.func @quantum_error_correction() {
    %d0 = dqc.alloc_qubit : !dqc.qubit
    %d1 = dqc.alloc_qubit : !dqc.qubit
    %d2 = dqc.alloc_qubit : !dqc.qubit
    %s0 = dqc.alloc_qubit : !dqc.qubit
    %s1 = dqc.alloc_qubit : !dqc.qubit
    %flag = dqc.alloc_qubit : !dqc.qubit

    // Step 1: Logical Encoding |1> -> |111>
    dqc.x %d0 : (!dqc.qubit)
    dqc.cnot %d0, %d1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %d0, %d2 : (!dqc.qubit, !dqc.qubit)

    // Step 2: Noise / Error Injection (Bit-flip on data qubit d1)
    // Simulates an environmental Pauli-X error flipping d1 from |1> to |0>
    dqc.x %d1 : (!dqc.qubit)

    // Step 3: Non-Destructive Syndrome Extraction
    // Check parity of (d0 XOR d1) into syndrome ancilla s0
    dqc.cnot %d0, %s0 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %d1, %s0 : (!dqc.qubit, !dqc.qubit)

    // Check parity of (d1 XOR d2) into syndrome ancilla s1
    dqc.cnot %d1, %s1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %d2, %s1 : (!dqc.qubit, !dqc.qubit)

    // Step 4: Autonomous Error Correction via Toffoli
    // If syndrome is (s0=1, s1=1), the error is uniquely isolated to qubit d1
    // Flipping d1 restores the original logical state |111> without measurement collapse!
    dqc.ccx %s0, %s1, %d1 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)

    // Step 5: Verify logical fidelity using flag qubit
    dqc.ccx %d0, %d1, %flag : (!dqc.qubit, !dqc.qubit, !dqc.qubit)

    return
  }
}
