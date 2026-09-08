module {
  func.func @superdense_coding() {
    %alice = dqc.alloc_qubit : !dqc.qubit
    %bob   = dqc.alloc_qubit : !dqc.qubit

    // Step 1: Create entangled Bell pair between Alice & Bob
    dqc.h %alice : (!dqc.qubit)
    dqc.cnot %alice, %bob : (!dqc.qubit, !dqc.qubit)

    // Step 2: Alice encodes 2 classical bits (e.g., "11")
    // Bit 1 = 1 -> apply Z; Bit 0 = 1 -> apply X
    dqc.z %alice : (!dqc.qubit)
    dqc.x %alice : (!dqc.qubit)

    // Step 3: Bob decodes Alice's transmission
    dqc.cnot %alice, %bob : (!dqc.qubit, !dqc.qubit)
    dqc.h %alice : (!dqc.qubit)

    // Bob measures both qubits -> reads exactly |11>
    %c0 = dqc.measure %alice : (!dqc.qubit) -> !dqc.cbit
    %c1 = dqc.measure %bob   : (!dqc.qubit) -> !dqc.cbit

    return
  }
}
