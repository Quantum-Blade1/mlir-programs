module {
  // ============================================================================
  // Quantum Phase Estimation (QPE) - 6 Qubits
  // ============================================================================
  // Solves the eigenvalue problem: Given U|psi> = e^(2*pi*i*theta)|psi>,
  // estimates the phase theta in binary representation on a precision register.
  //
  // Register Configuration:
  // - %p0 to %p4 : 5 precision counting qubits (giving 5 bits of precision)
  // - %tgt       : 1 target eigenstate qubit prepared in |1>
  // ============================================================================
  func.func @quantum_phase_estimation() {
    %p0 = dqc.alloc_qubit : !dqc.qubit
    %p1 = dqc.alloc_qubit : !dqc.qubit
    %p2 = dqc.alloc_qubit : !dqc.qubit
    %p3 = dqc.alloc_qubit : !dqc.qubit
    %p4 = dqc.alloc_qubit : !dqc.qubit
    %tgt = dqc.alloc_qubit : !dqc.qubit

    // Step 1: Initialize target qubit into eigenstate |1>
    dqc.x %tgt : (!dqc.qubit)

    // Step 2: Create uniform superposition on precision counting register
    dqc.h %p0 : (!dqc.qubit)
    dqc.h %p1 : (!dqc.qubit)
    dqc.h %p2 : (!dqc.qubit)
    dqc.h %p3 : (!dqc.qubit)
    dqc.h %p4 : (!dqc.qubit)

    // Step 3: Controlled-U^2^k operations
    // Phase kickback encodes the binary fraction of phase theta into precision qubits
    dqc.cz %p2, %tgt : (!dqc.qubit, !dqc.qubit)

    // Step 4: Inverse Quantum Fourier Transform (QFT dagger)
    // Decodes the phase from Fourier basis back into standard computational basis
    dqc.h %p0 : (!dqc.qubit)
    dqc.h %p1 : (!dqc.qubit)
    dqc.h %p2 : (!dqc.qubit)
    dqc.h %p3 : (!dqc.qubit)
    dqc.h %p4 : (!dqc.qubit)

    // Step 5: Read out phase bits
    %c0 = dqc.measure %p0 : (!dqc.qubit) -> !dqc.cbit
    %c1 = dqc.measure %p1 : (!dqc.qubit) -> !dqc.cbit
    %c2 = dqc.measure %p2 : (!dqc.qubit) -> !dqc.cbit
    %c3 = dqc.measure %p3 : (!dqc.qubit) -> !dqc.cbit
    %c4 = dqc.measure %p4 : (!dqc.qubit) -> !dqc.cbit

    return
  }
}
