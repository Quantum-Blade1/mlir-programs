module {
  func.func @quantum_teleport() {

    // === Qubits ===
    // %msg  : the qubit Alice wants to teleport (unknown state)
    // %epr0 : Alice's half of the Bell pair
    // %epr1 : Bob's half of the Bell pair

    %msg  = dqc.alloc_qubit : !dqc.qubit
    %epr0 = dqc.alloc_qubit : !dqc.qubit
    %epr1 = dqc.alloc_qubit : !dqc.qubit

    // === Prepare message qubit in |+> state ===
    // (this is the "unknown state" Alice wants to send)
    dqc.h %msg : (!dqc.qubit)

    // === Create Bell pair between Alice and Bob ===
    dqc.h %epr0 : (!dqc.qubit)
    dqc.cnot %epr0, %epr1 : (!dqc.qubit, !dqc.qubit)

    // === Alice's Bell measurement ===
    dqc.cnot %msg, %epr0 : (!dqc.qubit, !dqc.qubit)
    dqc.h %msg : (!dqc.qubit)

    // === Measure Alice's qubits ===
    %c0 = dqc.measure %msg  : (!dqc.qubit) -> !dqc.cbit
    %c1 = dqc.measure %epr0 : (!dqc.qubit) -> !dqc.cbit

    // === Bob's corrections (classically controlled) ===
    // In real teleportation: if c1==1 apply X, if c0==1 apply Z
    // Here we apply both unconditionally for compiler testing
    dqc.x %epr1 : (!dqc.qubit)
    dqc.z %epr1 : (!dqc.qubit)

    // === Measure Bob's qubit — should match original message ===
    %c2 = dqc.measure %epr1 : (!dqc.qubit) -> !dqc.cbit

    return
  }
}
