module {
  // ============================================================================
  // Discrete-Time Quantum Walk (DTQW) on an 8-Vertex 3D Hypercube - 8 Qubits
  // ============================================================================
  // Simulates a quantum random walker traversing the vertices of a 3D cube.
  // Quantum walks spread quadratically faster than classical random walks
  // (ballistic propagation O(t) vs classical diffusion O(sqrt(t))).
  //
  // Configuration:
  // - %c0, %c1     : 2 coin qubits determining walk direction (X, Y, Z axes)
  // - %x, %y, %z   : 3 position coordinates defining current vertex in {0,1}^3
  // - %a0, %a1, %a2: 3 path-entanglement ancillas recording interference history
  // Total: 8 Qubits
  // ============================================================================
  func.func @quantum_random_walk() {
    %c0 = dqc.alloc_qubit : !dqc.qubit
    %c1 = dqc.alloc_qubit : !dqc.qubit
    %x  = dqc.alloc_qubit : !dqc.qubit
    %y  = dqc.alloc_qubit : !dqc.qubit
    %z  = dqc.alloc_qubit : !dqc.qubit
    %a0 = dqc.alloc_qubit : !dqc.qubit
    %a1 = dqc.alloc_qubit : !dqc.qubit
    %a2 = dqc.alloc_qubit : !dqc.qubit

    // Step 1: Coin Flip Operator
    // Hadamard gates put the quantum coin into equal superposition of directions
    dqc.h %c0 : (!dqc.qubit)
    dqc.h %c1 : (!dqc.qubit)

    // Step 2: Conditional Shift Operator along Hypercube Edges
    // Transition in X-dimension if coin state is |00>
    dqc.x %c0 : (!dqc.qubit)
    dqc.x %c1 : (!dqc.qubit)
    dqc.ccx %c0, %c1, %x : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.x %c0 : (!dqc.qubit)
    dqc.x %c1 : (!dqc.qubit)

    // Transition in Y-dimension if coin state is |01>
    dqc.x %c1 : (!dqc.qubit)
    dqc.ccx %c0, %c1, %y : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.x %c1 : (!dqc.qubit)

    // Transition in Z-dimension if coin state is |10>
    dqc.x %c0 : (!dqc.qubit)
    dqc.ccx %c0, %c1, %z : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.x %c0 : (!dqc.qubit)

    // Step 3: Entangle position coordinates with path ancillas to track interference
    dqc.cnot %x, %a0 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %y, %a1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %z, %a2 : (!dqc.qubit, !dqc.qubit)

    return
  }
}
