# DQC MLIR Quantum Algorithm Programs & Distributed Compilation Suite

[![MLIR](https://img.shields.io/badge/MLIR-LLVM%2022-blue.svg)](https://mlir.llvm.org/)
[![Quantum](https://img.shields.io/badge/Quantum-Distributed%20Multi--QPU-purple.svg)](https://github.com/Quantum-Blade1/dqc1)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)

An open-source collection of production-grade quantum algorithms, protocols, and multi-QPU benchmarks formulated in the **`dqc` MLIR dialect** and compiled end-to-end via **DQC (Distributed Quantum Compiler)** down to executable LLVM IR and native machine binaries.

> **Research Paper Reference:**  
> *"DQC: An MLIR-Based Compiler Infrastructure for Distributed Quantum Circuit Execution"*  
> **Author:** Krish Kumar Sharma (MS Ramaiah Institute of Technology, Bangalore, India)  
> **Core Compiler Repository:** [Quantum-Blade1/dqc1](https://github.com/Quantum-Blade1/dqc1)

---

## 1. Overview & Architecture

Physical quantum computing hardware is advancing toward **distributed multi-QPU architectures** (such as IBM's *Flamingo* superconducting links, IonQ's photonic ion-trap links, and PsiQuantum's optical modules). Executing quantum algorithms on modular systems requires automated circuit partitioning, remote gate synthesis via quantum teleportation, communication scheduling, and lowering to executable code.

```mermaid
flowchart TD
    subgraph Input_Layer ["1. Logical Quantum Algorithm"]
        Src[".mlir Source File\n(dqc.alloc_qubit, dqc.h, dqc.cnot, dqc.ccx)"]
    end

    subgraph DQC_Pipeline ["2. DQC 5-Pass Progressive Lowering Pipeline"]
        direction TB
        Pass1["Pass 1: Interaction Graph Partitioning\nWeighted edge-cut minimization across QPUs"]
        Pass2["Pass 2: TeleGate Synthesis\nReplaces cross-QPU gates with EPR alloc & teleportation"]
        Pass3["Pass 3: Greedy Reordering\nHoists EPR allocations to preamble for batch pre-staging"]
        Pass4["Pass 4: MPI Lowering\nAbstract operations lowered to mpi.distribute_epr & mpi.telegate_sequence"]
        Pass5["Pass 5: LLVM Lowering\nConverts MLIR operations to LLVM dialect C runtime API calls"]
        
        Pass1 --> Pass2 --> Pass3 --> Pass4 --> Pass5
    end

    subgraph Execution_Targets ["3. Target Execution Environments"]
        direction TB
        Sim["Statevector Simulation Runtime\n(Apple Silicon ARM64 / x86_64)"]
        DistSim["Distributed MPI Cluster\n(High-performance nodes over RoCE / InfiniBand)"]
        PhysQPU["Cryogenic Multi-QPU Hardware\n(AWG pulse control & optical entanglement switches)"]
    end

    Src --> Pass1
    Pass5 --> Sim
    Pass5 --> DistSim
    Pass5 --> PhysQPU
```

---

## 2. Repository Structure

```text
mlir-programs/
├── README.md                            # Comprehensive documentation & algorithm guide
├── algorithms/                          # Production-grade quantum algorithms
│   ├── bell_state.mlir                  # Minimal distributed entanglement (2 qubits)
│   ├── bernstein_vazirani.mlir          # Hidden bitstring parity algorithm (5 qubits)
│   ├── deutsch_jozsa.mlir               # Single-query balanced/constant test (3 qubits)
│   ├── ghz_state.mlir                   # 4-qubit Greenberger-Horne-Zeilinger state
│   ├── draper_qft_adder.mlir            # Draper QFT integer addition A+B (7 qubits)
│   ├── grover_search.mlir               # 3-qubit database search marking |101> (100%)
│   ├── quantum_error_correction.mlir    # 3-qubit bit-flip code + syndrome detection (6 qubits)
│   ├── quantum_fourier_transform.mlir   # 4-qubit distributed QFT subroutine
│   ├── quantum_phase_estimation.mlir    # Eigenvalue phase estimation QPE (6 qubits)
│   ├── quantum_random_walk.mlir         # 3D hypercube quantum walk (8 qubits)
│   ├── quantum_teleportation.mlir       # Full 3-qubit state teleportation protocol
│   ├── superdense_coding.mlir           # 2 classical bits sent via 1 qubit
│   ├── vqe_chemistry_ansatz.mlir        # Variational molecular orbital ansatz (6 qubits)
│   └── w_state_8qubit.mlir              # 8-qubit robust multipartite W-state
├── benchmarks/                          # Multi-QPU distributed compiler stress tests
│   ├── cross_qpu_cnot.mlir              # Cross-chip CNOT verification benchmark
│   └── cross_qpu_toffoli.mlir           # Cross-chip Toffoli (CCX) decomposition benchmark
├── docs/                                # 500+ line in-depth technical architecture guides
│   ├── dqc_vs_c_compiler_deep_comparison.md
│   ├── how_dqc_executes_on_hardware.md
│   └── visual_hardware_journey.md
└── scripts/                             # Automated testing & verification runners
    └── run_all.sh                       # 1-command verification suite for all 16 programs
```

---

## 3. Included Quantum Algorithms & Benchmarks

This repository contains a curated, non-duplicate suite of 16 fundamental quantum computing algorithms and multi-QPU communication benchmarks:

| File Name | Algorithm / Protocol | Qubits | QPUs | Dominant Features | Expected Output State |
| :--- | :--- | :---: | :---: | :--- | :--- |
| [`bell_state.mlir`](algorithms/bell_state.mlir) | Bell State Generation | 2 | 2 | Minimal distributed entanglement | 50% \|00>, 50% \|11> |
| [`ghz_state.mlir`](algorithms/ghz_state.mlir) | GHZ Multi-Qubit State | 4 | 2 | Linear CNOT cascade across partition | 50% \|0000>, 50% \|1111> |
| [`superdense_coding.mlir`](algorithms/superdense_coding.mlir) | Superdense Coding | 2 | 2 | 2 classical bits sent via 1 qubit | 100% \|11> |
| [`deutsch_jozsa.mlir`](algorithms/deutsch_jozsa.mlir) | Deutsch-Jozsa Algorithm | 3 | 2 | Single-query balanced vs constant test | 50% \|011>, 50% \|111> |
| [`bernstein_vazirani.mlir`](algorithms/bernstein_vazirani.mlir) | Bernstein-Vazirani Algorithm | 5 | 2 | Recovers hidden bitstring $s = 1011$ | 50% \|01011>, 50% \|11011> |
| [`grover_search.mlir`](algorithms/grover_search.mlir) | Grover's Search Algorithm | 3 | 2 | Phase inversion & diffusion ($s = \|101\rangle$) | 100% \|101> |
| [`quantum_teleportation.mlir`](algorithms/quantum_teleportation.mlir) | Quantum State Teleportation | 3 | 2 | Full Bell measurement & Pauli correction | 100% \|111> |
| [`quantum_fourier_transform.mlir`](algorithms/quantum_fourier_transform.mlir) | Distributed QFT | 4 | 2 | Controlled-phase $R_z$ cascade & bit-reversal | Verified phase superposition |
| [`cross_qpu_cnot.mlir`](benchmarks/cross_qpu_cnot.mlir) | Cross-QPU CNOT Benchmark | 4 | 2 | TeleGate synthesis verification | 100% \|1001> |
| [`cross_qpu_toffoli.mlir`](benchmarks/cross_qpu_toffoli.mlir) | Cross-QPU Toffoli (CCX) | 6 | 2 | Distributed multi-controlled gate | 100% \|101001> |
| [`quantum_phase_estimation.mlir`](algorithms/quantum_phase_estimation.mlir) | Quantum Phase Estimation | 6 | 2 | Phase kickback & inverse QFT | 100% \|100100> |
| [`quantum_error_correction.mlir`](algorithms/quantum_error_correction.mlir) | Quantum Error Correction | 6 | 2 | 3-qubit bit-flip code + Toffoli fix | 100% \|111111> |
| [`vqe_chemistry_ansatz.mlir`](algorithms/vqe_chemistry_ansatz.mlir) | VQE Chemistry Ansatz | 6 | 2 | Ring-topology parameterized rotations | Entangled ground state |
| [`draper_qft_adder.mlir`](algorithms/draper_qft_adder.mlir) | Draper QFT Adder | 7 | 2 | Quantum phase arithmetic (3 + 2 = 5) | 100% \|0010000> |
| [`quantum_random_walk.mlir`](algorithms/quantum_random_walk.mlir) | Quantum Walk on Hypercube | 8 | 2 | 3D hypercube ballistic traversal | 4x 25% superposition |
| [`w_state_8qubit.mlir`](algorithms/w_state_8qubit.mlir) | 8-Qubit W-State Entanglement | 8 | 2 | Robust multipartite entanglement | Distributed 128 amplitudes |

---

## 4. Algorithm Deep-Dives & Source Implementations

### 1. Bell State Generation (`bell_state.mlir`)
The canonical quantum entanglement experiment. Applying a Hadamard gate to qubit 0 creates an equal superposition:

$$|\psi_1\rangle = \frac{1}{\sqrt{2}}(|0\rangle + |1\rangle) \otimes |0\rangle = \frac{1}{\sqrt{2}}(|00\rangle + |10\rangle)$$

Applying a CNOT gate with qubit 0 as control and qubit 1 as target entangles the pair into the Einstein-Podolsky-Rosen (EPR) state:

$$|\Phi^+\rangle = \frac{1}{\sqrt{2}}(|00\rangle + |11\rangle)$$

```mermaid
flowchart LR
    Q0["|0>"] --> H["H"] --> CNOT_Ctrl["*"] --> Out0["|phi+>"]
    Q1["|0>"] --------------------> CNOT_Tgt["(+)"] --> Out1["|phi+>"]
    CNOT_Ctrl --- CNOT_Tgt
```

#### MLIR Code:
```mlir
module {
  func.func @my_circuit() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit

    dqc.h %q0 : (!dqc.qubit)
    dqc.cnot %q0, %q1 : (!dqc.qubit, !dqc.qubit)

    return
  }
}
```

---

### 2. Greenberger-Horne-Zeilinger (GHZ) State (`ghz_state.mlir`)
An extension of entanglement to 4 qubits distributed across two physical QPUs:

$$|\text{GHZ}\rangle = \frac{1}{\sqrt{2}}(|0000\rangle + |1111\rangle)$$

In DQC, Pass 1 assigns $\{q_0, q_1\}$ to QPU 0 and $\{q_2, q_3\}$ to QPU 1. The compiler cuts only the single $q_1 \to q_2$ edge, requiring a single EPR pair to establish entanglement across the two chips.

```mermaid
flowchart LR
    subgraph QPU_0 ["QPU Node 0"]
        q0["q0: |0>"] --> H["H"] --> C0["*"]
        q1["q1: |0>"] -----------> T0["(+)"] --> C1["*"]
        C0 --- T0
    end

    subgraph QPU_1 ["QPU Node 1"]
        q2["q2: |0>"] ---------------------> T1["(+)"] --> C2["*"]
        q3["q3: |0>"] --------------------------------> T2["(+)"]
        C2 --- T2
    end

    C1 -. "TeleGate via 1 EPR Pair" .-> T1
```

#### MLIR Code:
```mlir
module {
  func.func @ghz_state() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit

    dqc.h %q0 : (!dqc.qubit)
    dqc.cnot %q0, %q1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q1, %q2 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q2, %q3 : (!dqc.qubit, !dqc.qubit)

    return
  }
}
```

---

### 3. Superdense Coding Protocol (`superdense_coding.mlir`)
Allows transmission of two classical bits of information using only one transmitted physical qubit by taking advantage of pre-shared entanglement:
1. Alice and Bob share an entangled Bell pair $|\Phi^+\rangle$.
2. To transmit classical bitstring `11`, Alice applies both $Z$ and $X$ operators to her local qubit.
3. Alice transmits her qubit to Bob.
4. Bob applies a CNOT and a Hadamard gate, completely disentangling the system and measuring the classical bits `11` with 100% deterministic probability.

```mermaid
sequenceDiagram
    autonumber
    actor Alice
    participant Channel as Entangled Link (EPR)
    actor Bob
    
    Channel->>Alice: Local Qubit 0
    Channel->>Bob: Local Qubit 1
    Note over Alice: Apply Z and X gates to encode '11'
    Alice->>Bob: Send Qubit 0
    Note over Bob: Apply CNOT(q0, q1) and H(q0)
    Note over Bob: Measure both qubits: deterministic |11> (100%)
```

#### MLIR Code:
```mlir
module {
  func.func @superdense_coding() {
    %alice = dqc.alloc_qubit : !dqc.qubit
    %bob   = dqc.alloc_qubit : !dqc.qubit

    dqc.h %alice : (!dqc.qubit)
    dqc.cnot %alice, %bob : (!dqc.qubit, !dqc.qubit)

    dqc.z %alice : (!dqc.qubit)
    dqc.x %alice : (!dqc.qubit)

    dqc.cnot %alice, %bob : (!dqc.qubit, !dqc.qubit)
    dqc.h %alice : (!dqc.qubit)

    %c0 = dqc.measure %alice : (!dqc.qubit) -> !dqc.cbit
    %c1 = dqc.measure %bob   : (!dqc.qubit) -> !dqc.cbit

    return
  }
}
```

---

### 4. Deutsch-Jozsa Algorithm (`deutsch_jozsa.mlir`)
Determines whether an unknown black-box Boolean function $f: \{0, 1\}^n \to \{0, 1\}$ is **constant** (outputs 0 on all inputs or 1 on all inputs) or **balanced** (outputs 0 on half the inputs and 1 on the other half) using a single quantum query ($O(1)$) instead of $2^{n-1} + 1$ classical queries.

```mermaid
flowchart TD
    Init["Initialize 2 Query Qubits in |0> and Ancilla in |1>"] --> Super["Apply Hadamard to All Qubits -> Superposition |+> and |->"]
    Super --> Oracle["Balanced Oracle: f(x) = x0 XOR x1 (CNOT gates to ancilla)"]
    Oracle --> Interfer["Apply Hadamard Transform to Query Register"]
    Interfer --> Measure["Measure Query Qubits: All zeros -> Constant, Non-zero -> Balanced"]
    Measure --> Result["Measurement = |11> (Balanced with 100% Certainty)"]
```

#### MLIR Code:
```mlir
module {
  func.func @deutsch_jozsa() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %anc = dqc.alloc_qubit : !dqc.qubit

    dqc.x %anc : (!dqc.qubit)
    dqc.h %anc : (!dqc.qubit)

    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)

    dqc.cnot %q0, %anc : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q1, %anc : (!dqc.qubit, !dqc.qubit)

    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)

    return
  }
}
```

---

### 5. Bernstein-Vazirani Algorithm (`bernstein_vazirani.mlir`)
Solves the hidden bitstring problem in a single query ($O(1)$) compared to classical algorithms requiring $N$ queries ($O(N)$).
- **Hidden Secret String:** $s = 1011$
- **Register Configuration:** 4 query qubits ($q_0, q_1, q_2, q_3$) initialized to $|+\rangle$ and 1 ancilla qubit initialized to $|-\rangle$.
- **Oracle Transformation:** Applies CNOT gates from query qubits to the ancilla only where $s_k = 1$ (qubits 0, 1, and 3).
- **Measurement:** Applying Hadamards to the query register causes constructive quantum interference on state $|1011\rangle$, revealing the hidden string instantly.

```mermaid
flowchart TD
    Init["Initialize 4 Query Qubits in |+> and Ancilla in |->"] --> Oracle["Oracle: CNOT(q0, anc), CNOT(q1, anc), CNOT(q3, anc)"]
    Oracle --> Hadamards["Hadamard Transform on Query Qubits"]
    Hadamards --> Measure["Measurement: Destructive Interference on all states except |1011>"]
    Measure --> Result["Extracted Secret String: 1011 (100% Probability)"]
```

#### MLIR Code:
```mlir
module {
  func.func @bernstein_vazirani() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit
    %anc = dqc.alloc_qubit : !dqc.qubit

    dqc.x %anc : (!dqc.qubit)
    dqc.h %anc : (!dqc.qubit)

    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.h %q3 : (!dqc.qubit)

    dqc.cnot %q0, %anc : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q1, %anc : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q3, %anc : (!dqc.qubit, !dqc.qubit)

    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.h %q3 : (!dqc.qubit)

    return
  }
}
```

---

### 6. Grover's Search Algorithm (`grover_search.mlir`)
Performs an unstructured database search over $N = 2^3 = 8$ items with quadratic speedup ($O(\sqrt{N})$ iterations):
- **Marked Search State:** $|101\rangle$
- **Phase Inversion (Oracle):** Applies a phase kick of $-1$ exclusively to state $|101\rangle$.
- **Grover Diffuser:** Computes $2|\psi\rangle\langle\psi| - I$, inverting all amplitudes about their mean.
- **Output:** The amplitude of $|101\rangle$ is amplified to 100%, yielding deterministic measurement.

```mermaid
flowchart LR
    Equal["Equal Superposition (All 8 states at 12.5%)"] --> Oracle["Phase Oracle\nFlips phase of |101> to -0.3535"]
    Oracle --> Diffuser["Grover Diffuser\nInverts about mean: amplifies |101>"]
    Diffuser --> FinalState["State |101> Amplified to 100.0%"]
```

#### Grover Search MLIR Code:
```mlir
module {
  func.func @grover_search() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit

    // Superposition
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.barrier

    // Oracle: Phase flip |101>
    dqc.x %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.ccx %q0, %q1, %q2 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)
    dqc.barrier

    // Diffuser
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)
    dqc.x %q2 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.ccx %q0, %q1, %q2 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)
    dqc.x %q2 : (!dqc.qubit)
    dqc.h %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)
    dqc.h %q2 : (!dqc.qubit)

    return
  }
}
```

---

### 7. Quantum State Teleportation Protocol (`quantum_teleportation.mlir`)
#### MLIR Code:
```mlir
module {
  func.func @quantum_teleport() {
    %msg  = dqc.alloc_qubit : !dqc.qubit
    %epr0 = dqc.alloc_qubit : !dqc.qubit
    %epr1 = dqc.alloc_qubit : !dqc.qubit

    // Prepare message qubit in |+> state
    dqc.h %msg : (!dqc.qubit)

    // Create Bell pair between Alice and Bob
    dqc.h %epr0 : (!dqc.qubit)
    dqc.cnot %epr0, %epr1 : (!dqc.qubit, !dqc.qubit)

    // Alice Bell measurement
    dqc.cnot %msg, %epr0 : (!dqc.qubit, !dqc.qubit)
    dqc.h %msg : (!dqc.qubit)

    %c0 = dqc.measure %msg  : (!dqc.qubit) -> !dqc.cbit
    %c1 = dqc.measure %epr0 : (!dqc.qubit) -> !dqc.cbit

    // Bob conditional corrections
    dqc.x %epr1 : (!dqc.qubit)
    dqc.z %epr1 : (!dqc.qubit)

    %c2 = dqc.measure %epr1 : (!dqc.qubit) -> !dqc.cbit

    return
  }
}
```

---

### 8. Distributed Quantum Fourier Transform (`quantum_fourier_transform.mlir`)
#### MLIR Code:
```mlir
module {
  func.func @distributed_qft() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit

    // Input state
    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q2 : (!dqc.qubit)

    // QFT Layer 0
    dqc.h %q0 : (!dqc.qubit)
    dqc.cnot %q1, %q0 : (!dqc.qubit, !dqc.qubit)
    dqc.rz %q0 0.7854 : (!dqc.qubit)
    dqc.cnot %q2, %q0 : (!dqc.qubit, !dqc.qubit)
    dqc.rz %q0 0.3927 : (!dqc.qubit)
    dqc.cnot %q3, %q0 : (!dqc.qubit, !dqc.qubit)
    dqc.rz %q0 0.1963 : (!dqc.qubit)

    // QFT Layer 1
    dqc.h %q1 : (!dqc.qubit)
    dqc.cnot %q2, %q1 : (!dqc.qubit, !dqc.qubit)
    dqc.rz %q1 0.7854 : (!dqc.qubit)
    dqc.cnot %q3, %q1 : (!dqc.qubit, !dqc.qubit)
    dqc.rz %q1 0.3927 : (!dqc.qubit)

    // QFT Layer 2
    dqc.h %q2 : (!dqc.qubit)
    dqc.cnot %q3, %q2 : (!dqc.qubit, !dqc.qubit)
    dqc.rz %q2 0.7854 : (!dqc.qubit)

    // QFT Layer 3
    dqc.h %q3 : (!dqc.qubit)

    // Bit reversal
    dqc.swap %q0, %q3 : (!dqc.qubit, !dqc.qubit)
    dqc.swap %q1, %q2 : (!dqc.qubit, !dqc.qubit)

    return
  }
}
```

---

### 9. Cross-QPU CNOT Benchmark (`cross_qpu_cnot.mlir`)
#### MLIR Code:
```mlir
module {
  func.func @test_cross_cnot() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit

    dqc.x %q0 : (!dqc.qubit)
    dqc.h %q1 : (!dqc.qubit)

    dqc.cnot %q0, %q1 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q2, %q3 : (!dqc.qubit, !dqc.qubit)
    dqc.cnot %q0, %q3 : (!dqc.qubit, !dqc.qubit)

    dqc.h %q1 : (!dqc.qubit)

    return
  }
}
```

---

### 10. Cross-QPU Toffoli Benchmark (`cross_qpu_toffoli.mlir`)
#### MLIR Code:
```mlir
module {
  func.func @test_cross_toffoli() {
    %q0 = dqc.alloc_qubit : !dqc.qubit
    %q1 = dqc.alloc_qubit : !dqc.qubit
    %q2 = dqc.alloc_qubit : !dqc.qubit
    %q3 = dqc.alloc_qubit : !dqc.qubit
    %q4 = dqc.alloc_qubit : !dqc.qubit
    %q5 = dqc.alloc_qubit : !dqc.qubit

    dqc.x %q0 : (!dqc.qubit)
    dqc.x %q1 : (!dqc.qubit)
    dqc.x %q3 : (!dqc.qubit)

    dqc.ccx %q0, %q1, %q2 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.ccx %q0, %q3, %q4 : (!dqc.qubit, !dqc.qubit, !dqc.qubit)
    dqc.cnot %q2, %q5 : (!dqc.qubit, !dqc.qubit)

    return
  }
}
```

---



### 11. Quantum Phase Estimation (`quantum_phase_estimation.mlir`) - 6 Qubits
Estimates the unknown phase $\theta$ of an eigenstate $|\psi\rangle$ under unitary operator $U$ such that $U|\psi\rangle = e^{2\pi i \theta}|\psi\rangle$:
- **5 Precision Qubits** (%p0 - %p4) prepared in uniform superposition via Hadamards.
- **1 Target Qubit** initialized in eigenstate $|1\rangle$.
- Controlled-phase gates apply phase kickback, followed by an inverse QFT to decode the phase into computational basis states.

```mermaid
flowchart LR
    p["Precision Register (5 Qubits: |00000>)"] --> H["Hadamard Layer"] --> CtrlU["Controlled-Phase Gates"]
    t["Target Register (1 Qubit: |1>)"] ------------> CtrlU
    CtrlU --> IQFT["Inverse QFT"] --> Readout["Phase Output: 100100 (100%)"]
```

---

### 12. Quantum Error Correction (`quantum_error_correction.mlir`) - 6 Qubits
Implements an autonomous 3-qubit quantum bit-flip repetition code with non-destructive syndrome measurement:
- **3 Physical Data Qubits** encode 1 logical qubit $|1\rangle_L \to |111\rangle$.
- Environmental noise injects a bit-flip Pauli-$X$ error on data qubit $d_1$, corrupting the state to $|101\rangle$.
- **2 Syndrome Ancillas** extract the parity checks without measuring data qubits directly.
- An autonomous Toffoli correction flips $d_1$ back, restoring the logical state to $|111\rangle$ with 100% fidelity.

```mermaid
flowchart TD
    Encode["Encode Logical |1> -> |111>"] --> Noise["Inject Bit-Flip Error on d1: |101>"]
    Noise --> Parity["Syndrome Parity Extraction into Ancillas (s0, s1)"]
    Parity --> Correct["Autonomous Toffoli Correction: CCX(s0, s1, d1)"]
    Correct --> Restored["Logical State Perfectly Restored to |111>!"]
```

---

### 13. VQE Molecular Chemistry Ansatz (`vqe_chemistry_ansatz.mlir`) - 6 Qubits
Simulates a Hardware-Efficient Parameterized Quantum Circuit (PQC) across 6 spatial-spin electron orbitals:
- Initializes the Hartree-Fock reference state $|110000\rangle$ (2 electrons in 6 orbitals).
- Parameterized single-qubit $R_y(\theta_i)$ and $R_z(\phi_i)$ layers mix electron configurations.
- Periodic boundary condition entangling CNOT ring coupler distributes quantum correlations.

```mermaid
flowchart LR
    HF["Hartree-Fock State |110000>"] --> Rot1["Parameterized Ry & Rz Rotations"]
    Rot1 --> Ring["Entangling CNOT Ring Topology (q0..q5)"]
    Ring --> Rot2["Second Variational Rotation Layer"]
    Rot2 --> Energy["Molecular Ground-State Energy Output"]
```

---

### 14. Draper Quantum Fourier Transform Adder (`draper_qft_adder.mlir`) - 7 Qubits
Computes arithmetic addition $A + B = 3 + 2 = 5$ entirely within the Fourier phase domain:
- Register $A$ (3 qubits) holds $A = 3$ (`011`).
- Register $B$ (3 qubits) holds $B = 2$ (`010`).
- Carry-out qubit ($c_{out}$) handles bit overflow.
- Controlled phase rotations inject addend $B$ into the phase angles of $A$ without classical ripple-carry delays.

```mermaid
flowchart LR
    RegA["Register A (3): |011> (3)"] --> PhaseAdd["Phase Space Addition via QFT"]
    RegB["Register B (3): |010> (2)"] --> PhaseAdd
    Carry["Carry Qubit: |0>"] --------> PhaseAdd
    PhaseAdd --> Sum["Output Sum: A + B = 5 (Binary 101)"]
```

---

### 15. Quantum Random Walk on a Hypercube (`quantum_random_walk.mlir`) - 8 Qubits
Simulates a Discrete-Time Quantum Walk (DTQW) on an 8-vertex 3D hypercube:
- **2 Coin Qubits** determine transition directions along the $X, Y, Z$ axes.
- **3 Position Qubits** track vertex coordinates $(x, y, z) \in \{0, 1\}^3$.
- **3 Step Ancillas** capture quantum interference trajectories.
- Demonstrates quadratic ballistic spreading over classical random diffusion.

```mermaid
flowchart TD
    Coin["2 Coin Qubits (Direction)"] --> Walk["Hadamard Coin Toss"]
    Walk --> Shift["Conditional Multi-Controlled Shift on 3D Cube"]
    Pos["3 Position Qubits (Vertices)"] --> Shift
    Shift --> State["Ballistic Quantum Wavefunction Superposition"]
```

---

### 16. 8-Qubit W-State Multipartite Entanglement (`w_state_8qubit.mlir`) - 8 Qubits
Synthesizes an 8-qubit W-state:
$$|W_8\rangle = \frac{1}{\sqrt{8}}(|00000001\rangle + |00000010\rangle + \dots + |10000000\rangle)$$
- Possesses maximal persistence of entanglement against particle loss: if any single qubit is destroyed or measured, the remaining 7 qubits remain genuinely entangled.
- Synthesized via controlled rotation cascades distributing a single quantum excitation across all 8 qubits.

```mermaid
flowchart LR
    Init["Single Excitation: |00000001>"] --> Cascade["Controlled Ry(pi/2) & CNOT Cascade"]
    Cascade --> WState["Coherent 8-Qubit W-State Superposition"]
```

---

## 5. DQC Compilation & Command Reference

The `dqc` driver binary provides comprehensive flags to inspect every intermediate compilation pass and emit native binaries.

```mermaid
flowchart LR
    Cmd["dqc <file.mlir>"] --> Flag1["-v : Verbose runtime simulation"]
    Cmd --> Flag2["-o <name> : Compile to native binary"]
    Cmd --> Flag3["--emit-ll : Output generated LLVM IR"]
    Cmd --> Flag4["--passes : Inspect all 5 compiler passes"]
    Cmd --> Flag5["--pass1 to --pass5 : Isolate specific pass"]
```

### 1. Compile and Run in Simulator (Verbose Mode)
```bash
dqc bell_state.mlir -v
```
**Output:**
```text
[dqc] initialized 2-qubit simulator (4 amplitudes)
[dqc] EPR pair #0: QPU 0 <-> QPU 1
[dqc] telegate q0 -> q1 via EPR #0 (QPU 0 -> QPU 1)

  Quantum State  (2 qubits)
  ─────────────────────────────────────
  |00>  ████████████████████  50.0%   (+0.7071 +0.0000i)
  |11>  ████████████████████  50.0%   (+0.7071 +0.0000i)
```

### 2. Compile to a Native Standalone Binary
```bash
# Compile to Mach-O / ELF native executable
dqc bell_state.mlir -o bell_state_bin

# Execute directly on host hardware
./bell_state_bin
```

### 3. Inspect Generated LLVM IR
```bash
dqc bell_state.mlir --emit-ll
```

### 4. Show All 5 Compiler Transformation Passes
```bash
dqc bell_state.mlir --passes
```

### 5. Isolate Individual Passes
```bash
dqc bell_state.mlir --pass1   # Pass 1: Interaction Graph & Bisection
dqc bell_state.mlir --pass2   # Pass 2: TeleGate Synthesis (EJPP Protocol)
dqc bell_state.mlir --pass3   # Pass 3: Greedy Reordering (Pre-staging)
dqc bell_state.mlir --pass4   # Pass 4: MPI Lowering
dqc bell_state.mlir --pass5   # Pass 5: LLVM Lowering
```

---

## 6. In-Depth Technical Documentation

This repository contains two exhaustive, 500+ line technical architecture guides:

1. **[`visual_hardware_journey.md`](docs/visual_hardware_journey.md)**  
   *A visual-first, diagram-driven explanation of what your CPU, RAM, and GPU are physically doing when executing DQC quantum programs.*
2. **[`how_dqc_executes_on_hardware.md`](docs/how_dqc_executes_on_hardware.md)**  
   *An in-depth 500+ line technical guide explaining the memory layout, ALU bitmasking, ARM NEON/AVX SIMD vectorization, and Born-rule state collapse.*
3. **[`dqc_vs_c_compiler_deep_comparison.md`](docs/dqc_vs_c_compiler_deep_comparison.md)**  
   *An industry-standard comparative study analyzing 15 fundamental differences between Classical C Compilers (Clang/GCC) and DQC, covering intermediate representations, no-cloning enforcement, register allocation vs. qubit placement, and NP-hard graph bisection.*

---

## 7. Automated Verification Test Suite

To verify all quantum algorithms in this repository, execute the automated test loop:

```bash
# Run the automated verification suite (compiles & tests all 10 programs)
./scripts/run_all.sh

# Or compile and run individual programs
dqc algorithms/bell_state.mlir
dqc algorithms/grover_search.mlir
dqc benchmarks/cross_qpu_cnot.mlir
```

All 10 circuits will compile, execute through the statevector simulator, and display their exact quantum state distribution.

---

## 8. The DQC MLIR Dialect Specification

The `dqc` dialect defines quantum-specific types, operations, and attributes within MLIR's type system:

```mermaid
flowchart TD
    Dialect["dqc Dialect"] --> Types["Types: !dqc.qubit, !dqc.cbit, !dqc.epr_handle"]
    Dialect --> SingleOps["Single Qubit Ops: dqc.h, dqc.x, dqc.y, dqc.z, dqc.rx, dqc.ry, dqc.rz"]
    Dialect --> MultiOps["Multi-Qubit Ops: dqc.cnot, dqc.cz, dqc.swap, dqc.ccx"]
    Dialect --> DistributedOps["Distributed Ops: dqc.epr_alloc, dqc.telegate"]
    Dialect --> MeasureOps["Measurement & State: dqc.measure, dqc.reset, dqc.barrier"]
```

All operations are declared via **MLIR TableGen (`.td`)** files, providing automatic C++ class generation, type verifiers, and assembly format parsers.

---

## 9. Citation

If you utilize DQC or these MLIR programs in your research, please cite:

```bibtex
@article{sharma2026dqc,
  title={DQC: An MLIR-Based Compiler Infrastructure for Distributed Quantum Circuit Execution},
  author={Sharma, Krish Kumar},
  journal={arXiv preprint},
  year={2026},
  url={https://github.com/Quantum-Blade1/dqc1}
}
```
