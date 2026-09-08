# How DQC Executes Quantum Programs on Physical Computer Hardware

**Compiler Infrastructure:** DQC (Distributed Quantum Compiler)  
**Target Architecture:** Modern Microprocessors (Apple Silicon ARM64 / Intel & AMD x86_64)  
**Author & Paper:** Krish Kumar Sharma (*"DQC: An MLIR-Based Compiler Infrastructure for Distributed Quantum Circuit Execution"*, [Quantum-Blade1/dqc1](https://github.com/Quantum-Blade1/dqc1))

---

## 1. Executive Summary & Hardware Overview

Quantum computing algorithms are formulated mathematically as unitary transformations acting on quantum statevectors in complex Hilbert space $\mathbb{C}^{2^n}$. However, when executing a program compiled by **DQC** on classical computer hardware, physical quantum particles do not exist on the motherboard.

Instead, the **DQC compiler pipeline** compiles high-level MLIR dialects (`dqc`, `mpi`, `llvm`) down to native machine code instructions. The CPU, system memory (RAM), vector registers (SIMD/NEON/AVX), and cache hierarchy act in concert to simulate the exact laws of quantum mechanics—including superposition, phase interference, entanglement, and quantum gate teleportation—using discrete numerical linear algebra and bitwise indexing.

```mermaid
flowchart TD
    subgraph Compilation_Stage ["1. DQC Ahead-Of-Time Compilation"]
        A[".mlir Source File\n(dqc.alloc_qubit, dqc.h, dqc.cnot)"] --> B["DQC Optimization Pipeline\n(Passes 1 - 5)"]
        B --> C["LLVM IR Code (.ll)\n(@dqc_init, @dqc_h, @dqc_telegate)"]
        C --> D["Native Clang Compiler & Linker"]
        D --> E["Executable Mach-O / ELF Binary"]
    end

    subgraph Hardware_Stage ["2. Physical Hardware Execution"]
        E --> F["OS Process Loader & Virtual Memory"]
        F --> G["L1 / L2 Instruction Caches"]
        G --> H["CPU Out-Of-Order Execution Core"]
        H <--> I["Physical RAM: 2^n Complex Statevector"]
        H <--> J["FPU & SIMD Vector Registers (NEON/AVX)"]
        H --> K["Mach Kernel Syscalls & Terminal Display"]
    end
```

---

## 2. Operating System Process Loading & Memory Mapping

When an executable compiled by DQC is launched (e.g., `./my_circuit_bin`), the operating system kernel (macOS Mach-O loader or Linux ELF loader) creates a new virtual address space for the process.

```mermaid
flowchart LR
    subgraph Process_Address_Space ["Process Virtual Memory Map (64-bit)"]
        direction TB
        Stack["Stack Region\nLocal variables, function frames, caller registers"]
        Heap["Heap Region (Dynamic Allocation)\nStatevector: calloc(2^n * 16 bytes)\nEPR Table & QPU Partition Metadata"]
        BSS["BSS & Data Segment\nGlobal constants, simulator status flags"]
        Text["Text Segment (.text)\nCompiled Machine Code Instructions (ARM64/x86_64)"]
    end
    
    Loader["Kernel execve() Loader"] --> Text
    Heap --> RAM["Physical Memory (RAM Pages via MMU)"]
    Stack --> CPU_SP["CPU Stack Pointer (SP / RSP)"]
```

1. **Text Segment (`.text`):** Houses the compiled machine code instructions for your quantum circuit and runtime functions (`dqc_init`, `dqc_h`, `dqc_telegate_sequence`, `dqc_dump_state`).
2. **Stack Segment:** Allocates activation frames for each C function call and passes parameters via hardware registers (`X0-X7` on ARM64, `RDI/RSI/RDX` on x86_64).
3. **Heap Segment:** Houses the dynamically allocated statevector. The function `dqc_init(n)` calls `malloc` or `calloc` to allocate contiguous virtual memory for $2^n$ complex amplitudes.
4. **Memory Management Unit (MMU):** Maps virtual memory pages to physical DDR4/DDR5/LPDDR5 unified RAM chips via multi-level page tables.

---

## 3. CPU Core Architecture & Instruction Pipeline

The physical CPU core is composed of specialized silicon sub-blocks designed to fetch, decode, execute, and retire instructions at gigahertz frequencies.

```mermaid
flowchart TD
    subgraph CPU_Core ["Physical CPU Core Architecture"]
        direction TB
        IF["Instruction Fetch (L1-I Cache)"] --> ID["Instruction Decoder & Branch Predictor"]
        ID --> ROB["Reorder Buffer & Register Renaming"]
        ROB --> RS["Reservation Stations (Scheduler)"]
        
        RS --> ALU["Integer ALU\nBitwise Masking: AND, OR, XOR, Shifts"]
        RS --> AGU["Address Generation Unit (AGU)\nCalculates Statevector Array Offsets"]
        RS --> SIMD["SIMD / Vector Floating Point Unit\nComplex Multiplication & Fused Multiply-Add"]
        
        ALU --> L1D["L1 Data Cache (32KB - 64KB)"]
        AGU --> L1D
        SIMD --> L1D
    end
```

During quantum circuit simulation, the CPU executes two distinct classes of workloads:
- **Integer ALU Operations:** Rapid bit-twiddling (shifts, bitwise XOR, AND masks) to determine which amplitude pairs in memory correspond to quantum basis states whose $k$-th qubit is $|0\rangle$ versus $|1\rangle$.
- **SIMD Floating Point Operations:** Applying $2 \times 2$ unitary matrix kernels (such as Hadamard or Phase rotation) across the identified amplitude pairs using single-instruction multiple-data (SIMD) vector registers.

---

## 4. Statevector Representation in Physical RAM

An ideal $n$-qubit quantum system exists in a normalized superposition of $2^n$ basis states:

$$|\psi\rangle = \sum_{k=0}^{2^n-1} c_k |k\rangle, \quad c_k \in \mathbb{C}, \quad \sum_{k=0}^{2^n-1} |c_k|^2 = 1$$

In physical memory, each complex coefficient $c_k = a_k + i \cdot b_k$ is represented as a contiguous pair of IEEE 754 double-precision floating-point numbers:
- **Real Component ($\text{Re}$):** 64 bits (8 bytes)
- **Imaginary Component ($\text{Im}$):** 64 bits (8 bytes)
- **Total per Amplitude:** 128 bits (16 bytes)

```mermaid
classDiagram
    class StateVectorRAM {
        +DoubleComplex c0 : |00...00> [Real: 8B | Imag: 8B]
        +DoubleComplex c1 : |00...01> [Real: 8B | Imag: 8B]
        +DoubleComplex c2 : |00...10> [Real: 8B | Imag: 8B]
        +DoubleComplex c3 : |00...11> [Real: 8B | Imag: 8B]
        +DoubleComplex c_k : |k>       [Real: 8B | Imag: 8B]
        +DoubleComplex c_last : |11...11> [Real: 8B | Imag: 8B]
    }
    note for StateVectorRAM "Contiguous memory buffer allocated in heap\nTotal Size = 2^n * 16 Bytes"
```

### Memory Footprint Scaling Across Circuit Sizes
| Qubits ($n$) | Total Basis States ($2^n$) | Memory Required | Cache / Memory Hierarchy Level |
| :--- | :--- | :--- | :--- |
| **2** | 4 | 64 Bytes | Fits in a single L1 Data Cache Line |
| **4** | 16 | 256 Bytes | Fits comfortably inside L1 Data Cache |
| **8** | 256 | 4 Kilobytes | Fits in L1 Data Cache |
| **12** | 4,096 | 64 Kilobytes | Fits in L2 Cache |
| **16** | 65,536 | 1 Megabyte | Fits in L2 / L3 Shared Cache |
| **20** | 1,048,576 | 16 Megabytes | Fits in L3 / System Level Cache (SLC) |
| **24** | 16,777,216 | 256 Megabytes | Main System RAM (DDR5 / LPDDR5) |
| **28** | 268,435,456 | 4 Gigabytes | High-Capacity Host RAM |
| **30** | 1,073,741,824 | 16 Gigabytes | Workstation / Server Class Host RAM |

For the 2-qubit and 4-qubit circuits compiled by DQC, the entire quantum statevector occupies between 64 and 256 bytes, allowing the entire simulation to remain permanently pinned inside the ultra-fast L1 Data Cache (latency $\approx 1-3$ clock cycles).

---

## 5. Cache Hierarchy & Memory Traffic During Gate Execution

When executing quantum gates across thousands of basis states, memory access patterns dominate performance.

```mermaid
flowchart TD
    subgraph Memory_Hierarchy ["Cache & Memory Subsystem"]
        direction TB
        L1["L1 Data Cache (Ultra Fast: ~1-3 cycles, 64-byte line)"]
        L2["L2 Dedicated Cache (~10-15 cycles, 512KB - 4MB)"]
        L3["L3 / System Level Cache (~30-50 cycles, 16MB - 32MB)"]
        DRAM["Main Memory DDR5 / Unified RAM (~100-200 cycles)"]
        
        L1 <--> L2
        L2 <--> L3
        L3 <--> DRAM
    end

    subgraph Access_Pattern ["Stride Access Pattern"]
        direction TB
        G0["Gate on Qubit 0: Stride = 1 (Contiguous adjacent elements)\nPeak L1 Cache Line Utilization"]
        Gk["Gate on Qubit k: Stride = 2^k (Elements spaced apart)\nRequires Prefetching & Cache Line Management"]
    end

    Access_Pattern --> Memory_Hierarchy
```

1. **Targeting Lower Qubits (e.g., Qubit 0):** Paired basis states $|i0\rangle$ and $|i1\rangle$ are physically adjacent in memory (stride $= 1$). A single 64-byte cache line brings 4 full amplitudes into the CPU simultaneously, yielding maximum cache efficiency.
2. **Targeting Higher Qubits (e.g., Qubit $k$):** Paired basis states are separated by a stride of $2^k$. When $2^k$ exceeds the cache line size, hardware stream prefetchers anticipate subsequent cache line requests to hide DRAM latency.

---

## 6. How Unitary Gates Execute on CPU SIMD Registers

Applying a single-qubit quantum gate represented by a $2 \times 2$ unitary matrix:

$$U = \begin{pmatrix} u_{00} & u_{01} \\ u_{10} & u_{11} \end{pmatrix}$$

transforms paired amplitudes according to:

$$\begin{pmatrix} c_0' \\ c_1' \end{pmatrix} = \begin{pmatrix} u_{00} & u_{01} \\ u_{10} & u_{11} \end{pmatrix} \begin{pmatrix} c_0 \\ c_1 \end{pmatrix}$$

```mermaid
sequenceDiagram
    autonumber
    participant RAM as L1 Data Cache / RAM
    participant Reg as SIMD Registers (V0, V1)
    participant FPU as Vector ALU / FPU
    
    RAM->>Reg: Load c_0 [Re, Im] into Vector Register V0
    RAM->>Reg: Load c_1 [Re, Im] into Vector Register V1
    Note over Reg,FPU: Broadcast matrix constants u_00, u_01 into V2, V3
    FPU->>Reg: Compute c_0_new = u_00 * c_0 + u_01 * c_1
    FPU->>Reg: Compute c_1_new = u_10 * c_0 + u_11 * c_1
    Reg->>RAM: Write updated c_0_new, c_1_new back to Cache
```

On Apple Silicon (ARM64), this is accelerated by **ARM NEON 128-bit vector instructions** (`FMLA`, `FMUL`, `FADD`). On x86_64, it utilizes **Intel AVX2 / AVX-512** registers (`YMM0-YMM15` or `ZMM0-ZMM31`).

### Detailed Mathematical Complex Multiplication on CPU
Each multiplication of complex amplitudes $(a + ib) \cdot (u_r + iu_i)$ requires 4 physical floating-point multiplications and 2 floating-point additions:
$$\text{Re}_{\text{result}} = a \cdot u_r - b \cdot u_i$$
$$\text{Im}_{\text{result}} = a \cdot u_i + b \cdot u_r$$
Modern CPUs execute this using Fused Multiply-Add (FMA) instructions in a single pipeline clock cycle.

---

## 7. The Bitwise Index Pairing Algorithm

To identify which basis states to transform without checking all combinations, DQC's runtime uses bitwise arithmetic:

```mermaid
flowchart TD
    Start["Begin Loop: step = 1 << target_qubit"] --> Outer["Outer Loop: block step from 0 to 2^n with increment 2 * step"]
    Outer --> Inner["Inner Loop: i from 0 to step - 1"]
    Inner --> Index0["Calculate index0 = block + i (Bit at target is 0)"]
    Index0 --> Index1["Calculate index1 = index0 + step (Bit at target is 1)"]
    Index1 --> Transform["Apply 2x2 Matrix to (statevector[index0], statevector[index1])"]
    Transform --> CheckInner{"Inner Loop Complete?"}
    CheckInner -- No --> Inner
    CheckInner -- Yes --> CheckOuter{"Outer Loop Complete?"}
    CheckOuter -- No --> Outer
    CheckOuter -- Yes --> Finish["Gate Application Finished"]
```

Because bitwise shifting `1 << target` and bitwise OR execute in a single CPU clock cycle, this pairing algorithm runs at near wire-speed.

---

## 8. Multi-Qubit Controlled Gates & Toffoli Index Matching

For multi-qubit gates such as CNOT ($CX$) and Toffoli ($CCX$), the transformation is conditional upon the control bits being active ($|1\rangle$).

```mermaid
flowchart TD
    subgraph Toffoli_Evaluation ["Toffoli (CCX) Execution on Hardware"]
        direction TB
        A["Loop Index i from 0 to 2^n - 1"] --> B["Extract Control Bit 1: (i >> ctrl1) & 1"]
        B --> C["Extract Control Bit 2: (i >> ctrl2) & 1"]
        C --> D{"Both Control Bits == 1?"}
        D -- Yes --> E["Pair state i with target flipped: j = i ^ (1 << target)"]
        E --> F["If i < j: Swap amplitudes (statevector[i], statevector[j])"]
        D -- No --> G["Skip state: Identity operation applied"]
        F --> H["Increment Loop Index"]
        G --> H
    end
```

By computing `j = i ^ (1 << target)`, the CPU instantly flips the target qubit's bit without conditional branches, avoiding branch mispredictions in the CPU pipeline.

---

## 9. Arbitrary Phase Rotations and Floating-Point Trigonometry

For rotation gates like $R_z(\theta)$, $R_x(\theta)$, and $R_y(\theta)$, DQC computes trigonometric values using hardware FPU transcendents:

$$R_z(\theta) = \begin{pmatrix} e^{-i\theta/2} & 0 \\ 0 & e^{i\theta/2} \end{pmatrix} = \begin{pmatrix} \cos(\theta/2) - i\sin(\theta/2) & 0 \\ 0 & \cos(\theta/2) + i\sin(\theta/2) \end{pmatrix}$$

```mermaid
flowchart LR
    Angle["Angle Parameter theta (f64)"] --> FPU_Trig["CPU Hardware FPU (FSINCOS / vsin_f64)"]
    FPU_Trig --> Real_Part["cos(theta / 2.0) -> Re Register"]
    FPU_Trig --> Imag_Part["sin(theta / 2.0) -> Im Register"]
    Real_Part --> Kernel["Complex Phase Multiplier Kernel"]
    Imag_Part --> Kernel
    Kernel --> Update["Multiply Target Amplitudes in Statevector"]
```

The CPU computes $\cos(\theta/2)$ and $\sin(\theta/2)$ once per gate invocation, stores them in vector registers, and broadcasts them across all amplitudes.

---

## 10. Virtual Multi-QPU Simulation & TeleGate Execution

Even when executing on a single computer, DQC faithfully simulates **distributed quantum computing across multiple physical QPUs**.

```mermaid
flowchart LR
    subgraph Physical_Memory ["Unified System Memory Space"]
        subgraph QPU0_Region ["Virtual QPU 0 State Partition"]
            Q0["Local Qubits: {q0, q2}"]
            EPR_Local["EPR Buffer 0 (Pre-staged Bell State)"]
        end

        subgraph QPU1_Region ["Virtual QPU 1 State Partition"]
            Q1["Local Qubits: {q1, q3}"]
            EPR_Remote["EPR Buffer 1 (Pre-staged Bell State)"]
        end
    end

    subgraph TeleGate_Flow ["TeleGate Execution Protocol (EJPP)"]
        direction TB
        Step1["1. Local Bell Measurement (QPU 0)"]
        Step2["2. Classical Bit Communication (c0, c1 via MPI)"]
        Step3["3. Remote Pauli Correction (X^c1 Z^c0 on QPU 1)"]
    end

    EPR_Local -. Entanglement Channel .- EPR_Remote
    Q0 --> Step1
    Step1 --> Step2
    Step2 --> Step3
    Step3 --> Q1
```

1. **Partition Table:** DQC tracks which QPU owns each qubit index using the partition metadata established in Pass 1.
2. **EPR Pair Distribution:** When `dqc_distribute_epr(0, 1, handle)` is called, the runtime simulates shared entanglement between node 0 and node 1.
3. **TeleGate Execution:** When `dqc_telegate_sequence` executes, the simulator:
   - Performs a local Bell measurement on the control qubit and local EPR half.
   - Simulates message passing of the two classical measurement bits (`c0, c1`).
   - Applies conditional Pauli-$X$ and Pauli-$Z$ gates on the target qubit residing on the remote QPU partition.

---

## 11. Distributed Hardware Interconnect Simulation

In real-world deployment across clusters, DQC maps its MPI dialect operations to physical high-performance networks:

```mermaid
flowchart TD
    subgraph Cluster_Node_0 ["Cluster Node 0 (QPU Host 0)"]
        Core0["Host CPU / QPU Controller"]
        NIC0["InfiniBand / RoCE NIC (RDMA)"]
        Q_Source["Entangled Photon Source (EPR Generator)"]
    end

    subgraph Cluster_Node_1 ["Cluster Node 1 (QPU Host 1)"]
        Core1["Host CPU / QPU Controller"]
        NIC1["InfiniBand / RoCE NIC (RDMA)"]
        Q_Detector["Photonic Bell State Detector"]
    end

    Core0 <--> NIC0
    Core1 <--> NIC1
    NIC0 <== "Classical MPI Network (Sub-microsecond Latency)" ==> NIC1
    Q_Source -. "Optical Fiber Quantum Channel (EPR Pairs)" .-> Q_Detector
```

During local simulation, DQC replaces the physical optical fibers and InfiniBand network cards with high-speed memory buffers and POSIX IPC primitives, verifying logical correctness before hardware deployment.

---

## 12. Quantum Measurement & Born Rule State Collapse

Measurement bridges the quantum realm and the classical realm. When `dqc_measure` is called:

```mermaid
flowchart TD
    A["Statevector Amplitudes in Memory"] --> B["Compute Cumulative Probability Distribution\nP(k) = Re(c_k)^2 + Im(c_k)^2"]
    B --> C["Hardware True RNG / PRNG (CPU RdRand / arc4random)"]
    C --> D["Sample Random Uniform Real r in [0.0, 1.0)"]
    D --> E["Locate Collapsed State |k> where Cumulative P exceeds r"]
    E --> F["Extract Classical Measurement Bit: (k >> target_qubit) & 1"]
    F --> G["Wavefunction Collapse: Set amplitude c_k to 1.0, zero all other c_j"]
    G --> H["Renormalize Statevector & Return Classical Bit to CPU Register"]
```

Physical computers generate the stochastic behavior of quantum mechanics by coupling the analytical probability distribution $\sum |c_k|^2 = 1$ with the CPU's on-die hardware random number generator.

---

## 13. State Reconstruction for Multi-Shot Sampling

When physical quantum computers execute circuits, they run thousands of repetitive "shots" to construct probability histograms. In DQC's statevector simulation:

```mermaid
flowchart LR
    Full_State["Complete Statevector in RAM (All 2^n Amplitudes)"] --> Mode_Check{"Execution Mode"}
    Mode_Check -- Exact State Dump --> Analytic["Compute Exact |c_k|^2 (No Statistical Sampling Noise)"]
    Mode_Check -- Shot-Based Sampling --> MonteCarlo["Monte Carlo Sampling: Draw N shots from Cumulative Distribution"]
    Analytic --> Output["Print High-Precision Probability Table"]
    MonteCarlo --> Output
```

Because DQC retains the analytical statevector in memory, it can compute both exact probabilities and simulated noisy shot distributions instantly.

---

## 14. Console Output Rendering via Terminal Syscalls

Finally, when `dqc_dump_state()` prints the state histogram, execution transitions through the operating system layers to reach your physical display.

```mermaid
sequenceDiagram
    autonumber
    participant App as dqc_dump_state()
    participant Libc as Libc (snprintf / fwrite)
    participant Kernel as macOS Mach Kernel (sys_write)
    participant Term as Terminal App (Metal / GPU)
    participant Screen as Physical OLED / Retina Display
    
    App->>App: Scan statevector: filter amplitudes with P > 0.001
    App->>App: Compute ASCII Bar Length: bars = (int)(P * 40.0)
    App->>Libc: Format String: "|00>  ████████████████████  50.0%"
    Libc->>Kernel: Invoke system call: write(stdout_fd, buffer, len)
    Kernel->>Term: Deliver text buffer to Terminal pseudo-terminal (PTY)
    Term->>Term: Convert characters to UTF-8 glyphs (Unicode Block 2588)
    Term->>Screen: Render textured pixels via Metal GPU pipeline to Retina display
```

---

## 15. Complete Hardware Resource Mapping Summary

| Hardware Subsystem | Classical Function | Dedicated Role in DQC Quantum Execution |
| :--- | :--- | :--- |
| **CPU ALU** | Integer arithmetic | Bitwise masking (`1 << q`), loop strides, basis pairing |
| **CPU SIMD (NEON/AVX)** | Vector calculations | $2 \times 2$ Complex unitary matrix multiplication |
| **FPU Registers** | Floating-point math | Real & Imaginary amplitude transformations |
| **L1 Data Cache** | Low-latency memory | Pins the entire active quantum statevector (up to 8 qubits) |
| **L2 / L3 Caches** | Shared memory buffer | Holds larger statevectors and intermediate EPR communication tables |
| **Unified System RAM** | Main memory storage | Backs $2^n$ statevector buffers for large circuits |
| **Hardware TRNG / PRNG** | Random entropy | Simulates Born-rule quantum measurement state collapse |
| **GPU / Display Engine** | Framebuffer display | Renders ASCII probability bar charts to your terminal screen |

---

## 16. Step-by-Step Hardware State Trace: Creating a Bell Pair

To understand how hardware coordinates these components during execution, consider the 2-qubit Bell circuit compiled from `my_circuit.mlir`:

```mlir
dqc.h %q0 : (!dqc.qubit)
dqc.cnot %q0, %q1 : (!dqc.qubit, !dqc.qubit)
```

### Initial State after `dqc_init(2)`:
The CPU allocates 64 bytes in RAM and initializes index 0 to $1.0 + 0.0i$, and indices 1, 2, 3 to $0.0 + 0.0i$:
- `state[0] (|00>) = 1.0000 + 0.0000i`
- `state[1] (|01>) = 0.0000 + 0.0000i`
- `state[2] (|10>) = 0.0000 + 0.0000i`
- `state[3] (|11>) = 0.0000 + 0.0000i`

### Step 1: Applying Hadamard Gate `dqc_h(%q0)`
- Bitmask for Qubit 0: `mask = 1 << 0 = 1`.
- Pairing: (Index 0 with Index 1), (Index 2 with Index 3).
- Computation:
  $$\text{state}[0]' = \frac{1}{\sqrt{2}} (\text{state}[0] + \text{state}[1]) = \frac{1}{\sqrt{2}} (1.0 + 0.0) \approx +0.7071$$
  $$\text{state}[1]' = \frac{1}{\sqrt{2}} (\text{state}[0] - \text{state}[1]) = \frac{1}{\sqrt{2}} (1.0 - 0.0) \approx +0.7071$$
- Intermediate State: $\frac{1}{\sqrt{2}}(|00\rangle + |01\rangle)$.

### Step 2: Applying CNOT Gate `dqc_cnot(%q0, %q1)`
- Control Qubit: 0; Target Qubit: 1.
- Bitmask: Target mask `1 << 1 = 2`.
- Iteration:
  - State $|00\rangle$ (control bit is 0): Untouched.
  - State $|01\rangle$ (control bit is 1): Swap amplitude with $|01 \oplus 10\rangle = |11\rangle$.
- Resulting Amplitudes:
  - `state[0] (|00>) = +0.7071`
  - `state[1] (|01>) = +0.0000`
  - `state[2] (|10>) = +0.0000`
  - `state[3] (|11>) = +0.7071`
- Final Quantum State: Maximally entangled Bell state $\frac{1}{\sqrt{2}}(|00\rangle + |11\rangle)$.

```mermaid
flowchart TD
    Init["Initial State: |00> (100% in state[0])"] --> Had["Execute dqc_h(q0)\nApplies (1/√2)[1, 1; 1, -1] matrix\nAmplitudes split: state[0] = 0.7071, state[1] = 0.7071"]
    Had --> CNOT["Execute dqc_cnot(q0, q1)\nIdentifies control bit active on state[1]\nSwaps amplitude from index 1 to index 3"]
    CNOT --> Final["Final Statevector:\n|00>: 50% (+0.7071)\n|11>: 50% (+0.7071)\nPerfect Entanglement Achieved!"]
```

---

## 17. The Memory Bandwidth Wall & Roofline Model

When scaling quantum simulation on classical microprocessors, the primary performance limiter is not floating-point compute capacity (FLOPS), but **Memory Bus Bandwidth (Bytes/sec)**.

```mermaid
flowchart LR
    Compute_Bound["Compute Bound Regime (High Arithmetic Intensity)\nSmall circuits (n <= 12): Entire statevector pinned in L1/L2 cache\nThroughput limited only by SIMD FMA clock cycles"]
    Memory_Bound["Memory Bound Regime (Low Arithmetic Intensity)\nLarge circuits (n >= 24): Statevector spills into DRAM\nThroughput limited by DDR5 bus bandwidth (~60-100 GB/s)"]
    
    Threshold["Knee Point: Cache capacity exceeded\nForces cache line evictions and DRAM stalls"]
    
    Compute_Bound --> Threshold --> Memory_Bound
```

Because a single-qubit gate performs only 6 floating-point operations per 32 bytes transferred from memory (arithmetic intensity $\approx 0.1875$ FLOP/byte), simulation quickly becomes memory bandwidth bound when the statevector exceeds the CPU's on-die L3 cache.

---

## 18. Multi-Threading & Cache Partitioning Strategies

For circuits exceeding 12 qubits, DQC runtime can parallelize the outer index loops across all physical CPU cores using thread pools:

```mermaid
flowchart TD
    Total_Statevector["Total Statevector in RAM (2^n Amplitudes)"] --> Slicer["Loop Slicer: Partition Outer Loop by Core Count"]
    Slicer --> Core0["Core 0 (Thread 0): Process Amplitudes [0 .. 2^(n-2)-1]"]
    Slicer --> Core1["Core 1 (Thread 1): Process Amplitudes [2^(n-2) .. 2^(n-1)-1]"]
    Slicer --> Core2["Core 2 (Thread 2): Process Amplitudes [2^(n-1) .. 3*2^(n-2)-1]"]
    Slicer --> Core3["Core 3 (Thread 3): Process Amplitudes [3*2^(n-2) .. 2^n - 1]"]
    
    Core0 --> Barrier["Thread Synchronization Barrier\nEnsure all amplitudes updated before next gate"]
    Core1 --> Barrier
    Core2 --> Barrier
    Core3 --> Barrier
    Barrier --> NextGate["Proceed to Next Circuit Gate"]
```

By ensuring that each thread works on contiguous chunks of memory, cache invalidation traffic across CPU core buses is minimized.

---

## 19. Hardware Profiling & Assembly Instruction Trace

On an Apple Silicon Mac (ARM64), a single compiled gate invocation lowers to the following high-performance assembly pattern:

```assembly
; ARM64 Assembly Pattern for Complex Unitary Multiplication
ldp     q0, q1, [x19, x8]      ; Load 2 complex amplitudes (v0 = [a_re, a_im], v1 = [b_re, b_im])
fmul    v2.2d, v0.2d, v4.2d    ; Real component multiplication: a_re * u00_re
fmls    v2.2d, v1.2d, v5.2d    ; Fused multiply-subtract: - b_im * u00_im
fmla    v3.2d, v0.2d, v5.2d    ; Imaginary component: + a_im * u00_re
fmla    v3.2d, v1.2d, v4.2d    ; Fused multiply-add: + b_re * u00_im
stp     q2, q3, [x19, x8]      ; Store updated complex amplitudes back to cache line
add     x8, x8, #32            ; Advance byte offset by 32 bytes (2 complex amplitudes)
```

This assembly sequence demonstrates why DQC generates native executable code: by utilizing SIMD registers directly, it bypasses interpreted runtime overhead and executes near the theoretical silicon speed limit of your hardware.

---

## 20. Conclusion: From Classical Simulation to Real QPU Hardware

The exact same MLIR compiler pipeline that simulates distributed quantum circuits on your Mac's CPU is designed to target physical multi-QPU control hardware:

```mermaid
flowchart LR
    DQC_Pipeline["DQC Compiler Pipeline"] --> Target_Select{"Target Architecture"}
    Target_Select -- Local Classical Machine --> Native_Bin["Mach-O / ELF Native Binary\n(Statevector Linear Algebra on CPU/RAM)"]
    Target_Select -- Distributed Cluster --> MPI_Cluster["MPI Distributed Simulation Cluster\n(Distributed Host Nodes over RoCE/Infiniband)"]
    Target_Select -- Physical Hardware --> Control_Pulses["Arbitrary Waveform Generators (AWG)\nMicrowave & Photonic Control Pulses to QPUs"]
```

By compiling end-to-end from high-level quantum dialect down to executable LLVM IR, **DQC** provides the foundational software infrastructure that links tomorrow's distributed quantum algorithms to today's microprocessors and future quantum supercomputing clusters.
