module {
  // ============================================================================
  // Variational Quantum Eigensolver (VQE) Molecular Chemistry Ansatz - 6 Qubits
  // ============================================================================
  // Implements a Hardware-Efficient Parameterized Quantum Circuit (PQC)
  // used in quantum chemistry to compute ground state energies of molecules
  // (e.g., LiH, BeH2) on NISQ and distributed quantum architectures.
  //
  // Topology: 6 qubits in a closed ring-entanglement topology with alternating
  // single-qubit parameterized rotation layers (Ry, Rz) and entangling CNOT couplers.
  // ============================================================================
  func.func @vqe_chemistry_ansatz() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit
    %q4 = dqc.alloc_qubit : !dqc.qubit
    %q5 = dqc.alloc_qubit : !dqc.qubit

    // Step 1: Initialize Hartree-Fock electron configuration |110000>
    // (Simulating 2 active valence electrons occupying 6 spatial-spin orbitals)
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)

    // Step 2: Layer 1 - Parameterized Ry Rotations (Orbital mixing angles)
    dqc.ry %q0 0.5236 : (!dqc.qubit) // theta0 = pi/6
    dqc.ry %q1 0.7854 : (!dqc.qubit) // theta1 = pi/4
    dqc.ry %q2 0.3927 : (!dqc.qubit) // theta2 = pi/8
    dqc.ry %q3 0.5236 : (!dqc.qubit) // theta3 = pi/6
    dqc.ry %q4 0.7854 : (!dqc.qubit) // theta4 = pi/4
    dqc.ry %q5 0.3927 : (!dqc.qubit) // theta5 = pi/8

    // Step 3: Layer 1 - Parameterized Rz Rotations (Relative quantum phases)
    dqc.rz %q0 1.0472 : (!dqc.qubit) // phi0 = pi/3
    dqc.rz %q1 0.5236 : (!dqc.qubit) // phi1 = pi/6
    dqc.rz %q2 0.7854 : (!dqc.qubit) // phi2 = pi/4
    dqc.rz %q3 1.0472 : (!dqc.qubit) // phi3 = pi/3
    dqc.rz %q4 0.5236 : (!dqc.qubit) // phi4 = pi/6
    dqc.rz %q5 0.7854 : (!dqc.qubit) // phi5 = pi/4

    // Step 4: Entangling CNOT Ladder with Periodic Boundary Condition (Ring Coupler)
    dqc.cnot %q0, %q1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q1, %q2 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q2, %q3 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q3, %q4 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q4, %q5 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q5, %q0 : (!dqc.qubit, !dqc.qubit)

    // Step 5: Layer 2 - Variational Ry Refinement
    dqc.ry %q0 0.3927 : (!dqc.qubit)
    dqc.ry %q1 0.5236 : (!dqc.qubit)
    dqc.ry %q2 0.7854 : (!dqc.qubit)
    dqc.ry %q3 0.3927 : (!dqc.qubit)
    dqc.ry %q4 0.5236 : (!dqc.qubit)
    dqc.ry %q5 0.7854 : (!dqc.qubit)

    return
  }
}
