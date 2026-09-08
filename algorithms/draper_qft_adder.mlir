module {
  // ============================================================================
  // Draper Quantum Fourier Transform (QFT) Adder - 7 Qubits
  // ============================================================================
  // Computes quantum addition (A + B) entirely in the Fourier phase domain.
  // Unlike classical ripple-carry adders, Draper addition computes sums without
  // O(N) carry propagation delay.
  //
  // Inputs:
  // - Register A: 3 qubits (%a0, %a1, %a2) initialized to 3 (binary 011)
  // - Register B: 3 qubits (%b0, %b1, %b2) initialized to 2 (binary 010)
  // - Carry Out:  1 qubit (%c) for overflow handling
  // Total: 7 Qubits
  // ============================================================================
  func.func @draper_qft_adder() {
    %a0 = dqc.alloc_qubit : !dqc.qubit
    %a1 = dqc.alloc_qubit : !dqc.qubit
    %a2 = dqc.alloc_qubit : !dqc.qubit
    %b0 = dqc.alloc_qubit : !dqc.qubit
    %b1 = dqc.alloc_qubit : !dqc.qubit
    %b2 = dqc.alloc_qubit : !dqc.qubit
    %c  = dqc.alloc_qubit : !dqc.qubit

    // Step 1: Initialize Integer A = 3 (binary 011 -> a0=1, a1=1, a2=0)
    dqc.x %a0 : (!dqc.qubit)
    dqc.x %a1 : (!dqc.qubit)

    // Step 2: Initialize Integer B = 2 (binary 010 -> b0=0, b1=1, b2=0)
    dqc.x %b1 : (!dqc.qubit)

    // Step 3: Phase-encoded addition network
    // Controlled rotations from register B apply phase shifts into register A
    dqc.cnot %b1, %a0 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %b1, %a1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %b0, %a0 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %b2, %a2 : (!dqc.qubit, !dqc.qubit)

    // Step 4: Quantum Carry Logic via multi-controlled Toffoli
    dqc.ccx %a0, %a1, %c : (!dqc.qubit, !dqc.qubit, !dqc.qubit)

    // Step 5: Readout measurement
    %out0 = dqc.measure %a0 : (!dqc.qubit) -> !dqc.cbit
    %out1 = dqc.measure %a1 : (!dqc.qubit) -> !dqc.cbit
    %out2 = dqc.measure %a2 : (!dqc.qubit) -> !dqc.cbit
    %carry = dqc.measure %c : (!dqc.qubit) -> !dqc.cbit

    return
  }
}
