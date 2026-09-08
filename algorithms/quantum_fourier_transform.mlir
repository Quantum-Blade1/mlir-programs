module {
  func.func @distributed_qft() {

    // Step 1: create 4 qubits to work with (like setting up 4 blank variables)
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit

    // Step 2: input state — flip 2 qubits from 0 to 1
    // (gives us a real starting point instead of all zeros)
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q2 : (!dqc.qubit)

    // Step 3: QFT layer 0
    // this is the core math — mixing q0 with every other qubit
    // through a Hadamard + a series of controlled rotations
    dqc.h %q0 : (!dqc.qubit)
    dqc.cnot %q1, %q0 : (!dqc.qubit, !dqc.qubit)   // mix q1 into q0
    dqc.rz %q0 0.7854 : (!dqc.qubit)                // rotate q0
    dqc.cnot %q2, %q0 : (!dqc.qubit, !dqc.qubit)   // mix q2 into q0
    dqc.rz %q0 0.3927 : (!dqc.qubit)
    dqc.cnot %q3, %q0 : (!dqc.qubit, !dqc.qubit)   // mix q3 into q0
    dqc.rz %q0 0.1963 : (!dqc.qubit)

    // Step 4: QFT layer 1 — same idea, now centered on q1
    dqc.h %q1 : (!dqc.qubit)
    dqc.cnot %q2, %q1 : (!dqc.qubit, !dqc.qubit)   // mix q2 into q1
    dqc.rz %q1 0.7854 : (!dqc.qubit)
    dqc.cnot %q3, %q1 : (!dqc.qubit, !dqc.qubit)   // mix q3 into q1
    dqc.rz %q1 0.3927 : (!dqc.qubit)

    // Step 5: QFT layer 2 — same idea, now centered on q2
    dqc.h %q2 : (!dqc.qubit)
    dqc.cnot %q3, %q2 : (!dqc.qubit, !dqc.qubit)   // mix q3 into q2
    dqc.rz %q2 0.7854 : (!dqc.qubit)

    // Step 6: QFT layer 3 — last qubit just gets its own rotation
    dqc.h %q3 : (!dqc.qubit)

    // Step 7: bit reversal
    // QFT always scrambles qubit order on the way out —
    // these two swaps just put everything back in the correct order
    dqc.swap %q0, %q3 : (!dqc.qubit, !dqc.qubit)
    dqc.swap %q1, %q2 : (!dqc.qubit, !dqc.qubit)

    // Step 8: read out the final answer from each qubit
    %c0 = dqc.measure %q0 : (!dqc.qubit) -> !dqc.cbit
    %c1 = dqc.measure %q1 : (!dqc.qubit) -> !dqc.cbit
    %c2 = dqc.measure %q2 : (!dqc.qubit) -> !dqc.cbit
    %c3 = dqc.measure %q3 : (!dqc.qubit) -> !dqc.cbit

    return
  }
}

// Note: nothing above mentions 2 processors, entanglement, or teleportation.
// This is a completely ordinary quantum circuit written for ONE chip.
// The DQC compiler is what automatically splits it across QPUs and
// inserts all the teleportation logic — you never write that part by hand.