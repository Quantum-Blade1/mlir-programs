module {
  func.func @draper_qft_adder() {
    // 3-bit adder: regA (3) + regB (3) + carry (1) = 7 qubits
    %a0 = dqc.alloc_qubit : !dqc.qubit
    %a1 = dqc.alloc_qubit : !dqc.qubit
    %a2 = dqc.alloc_qubit : !dqc.qubit
    %b0 = dqc.alloc_qubit : !dqc.qubit
    %b1 = dqc.alloc_qubit : !dqc.qubit
    %b2 = dqc.alloc_qubit : !dqc.qubit
    %cout = dqc.alloc_qubit : !dqc.qubit

    // A = 3 (011), B = 2 (010)
    dqc.x %a0 : (!dqc.qubit)
    dqc.x %a1 : (!dqc.qubit)
    dqc.x %b1 : (!dqc.qubit)

    // phase additions from B into A
    dqc.cnot %b1, %a0 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %b1, %a1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %b0, %a0 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %b2, %a2 : (!dqc.qubit, !dqc.qubit)

    // carry generation
    dqc.ccx %a0, %a1, %cout : (!dqc.qubit, !dqc.qubit, !dqc.qubit)

    %res0 = dqc.measure %a0 : (!dqc.qubit) -> !dqc.cbit
    %res1 = dqc.measure %a1 : (!dqc.qubit) -> !dqc.cbit
    %res2 = dqc.measure %a2 : (!dqc.qubit) -> !dqc.cbit
    %c = dqc.measure %cout : (!dqc.qubit) -> !dqc.cbit

    return
  }
}
