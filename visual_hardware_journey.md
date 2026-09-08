# What Your Machine Does When Running DQC: A Visual Journey

A diagram-first explanation of how your computer hardware (CPU, RAM, Caches, and Display) compiles and executes quantum programs.

---

## The 30-Second Big Picture

```mermaid
flowchart TD
    User(["You type: dqc bell_state.mlir & press Enter"]) --> Step1
    
    subgraph Step1 ["Step 1: Your CPU Compiles the Quantum Logic"]
        direction LR
        S1_1["MLIR File on SSD"] --> S1_2["5 DQC Passes in CPU Cache"] --> S1_3["LLVM Machine Code"]
    end
    
    Step1 --> Step2
    
    subgraph Step2 ["Step 2: Reserving Memory (Your RAM)"]
        direction LR
        S2_1["dqc_init(2)"] --> S2_2["Allocates 64 Bytes in RAM"] --> S2_3["Fits in 1 CPU Cache Line!"]
    end
    
    Step2 --> Step3
    
    subgraph Step3 ["Step 3: Calculating Quantum Superposition (ALU & SIMD)"]
        direction LR
        S3_1["Hadamard Gate"] --> S3_2["Bitmasking: Pair State 0 & 1"] --> S3_3["SIMD Multiply by 0.7071"]
    end
    
    Step3 --> Step4
    
    subgraph Step4 ["Step 4: Simulating Distributed Teleportation (TeleGate)"]
        direction LR
        S4_1["Virtual QPU 0"] <== "2 Classical Bits + EPR Pair" ==> S4_2["Virtual QPU 1"]
    end
    
    Step4 --> Step5
    
    subgraph Step5 ["Step 5: Lighting Up Your Screen Pixels"]
        direction LR
        S5_1["Compute Probabilities (50% |00>, 50% |11>)"] --> S5_2["macOS Syscall write()"] --> S5_3["Terminal Pixels Drawn"]
    end
```

---

## Step 1: Loading from SSD into Your CPU Caches

```mermaid
sequenceDiagram
    autonumber
    actor You as Terminal User
    participant SSD as Physical SSD
    participant RAM as System RAM
    participant CPU as Apple Silicon / Intel CPU
    
    You->>CPU: Run "dqc bell_state.mlir"
    CPU->>SSD: Read text file
    SSD->>RAM: Copy bytes to RAM buffer
    RAM->>CPU: Load file into L1/L2 Instruction Cache
    Note over CPU: DQC runs Pass 1 to 5 directly inside fast CPU Caches!
```

---

## Step 2: The 5 Compiler Passes Inside Your CPU

```mermaid
flowchart TD
    In["bell_state.mlir (Source text in memory)"] --> P1
    
    subgraph P1 ["Pass 1: Qubit Partitioning"]
        direction TB
        P1_A["Count 2-qubit gates"] --> P1_B["Assign Qubit 0 -> Virtual Chip 0\nAssign Qubit 1 -> Virtual Chip 1"]
    end
    
    P1 --> P2
    
    subgraph P2 ["Pass 2: TeleGate Synthesis"]
        direction TB
        P2_A["Detect CNOT crosses chips"] --> P2_B["Replace CNOT with:\n1. dqc.epr_alloc\n2. dqc.telegate"]
    end
    
    P2 --> P3
    
    subgraph P3 ["Pass 3: Greedy Reordering"]
        direction TB
        P3_A["Scan instruction list"] --> P3_B["HOIST epr_alloc to very top\n(Pre-stage entanglement early!)"]
    end
    
    P3 --> P4
    
    subgraph P4 ["Pass 4: MPI Lowering"]
        direction TB
        P4_A["Convert abstract teleportation to:\nmpi.distribute_epr\nmpi.telegate_sequence"]
    end
    
    P4 --> P5
    
    subgraph P5 ["Pass 5: LLVM Lowering & Machine Code"]
        direction TB
        P5_A["Convert to LLVM IR calls:\n@dqc_init, @dqc_h, @dqc_dump_state"] --> P5_B["Clang generates native ARM64/x86 binary bytes"]
    end
    
    P5 --> Out["Native Machine Executable (Ready to run!)"]
```

---

## Step 3: What Gets Allocated in Your Mac's RAM

For 2 qubits, there are $2^2 = 4$ possible states. Each complex number requires 16 bytes:

```mermaid
classDiagram
    class CPU_Cache_Line_64_Bytes {
        +Index 00 : Real = 1.0000 | Imag = 0.0000 (16 Bytes)
        +Index 01 : Real = 0.0000 | Imag = 0.0000 (16 Bytes)
        +Index 10 : Real = 0.0000 | Imag = 0.0000 (16 Bytes)
        +Index 11 : Real = 0.0000 | Imag = 0.0000 (16 Bytes)
    }
    note for CPU_Cache_Line_64_Bytes "Total size = 64 bytes.\nExactly fits inside ONE single CPU Cache Line in L1 Cache!"
```

```mermaid
flowchart LR
    subgraph RAM_State_Initial ["State in Memory at Start (dqc_init)"]
        S0["|00> : 100% (1.0000)"]
        S1["|01> :   0% (0.0000)"]
        S2["|10> :   0% (0.0000)"]
        S3["|11> :   0% (0.0000)"]
    end
```

---

## Step 4: Executing Hadamard Gate `dqc.h` (ALU & SIMD Working)

Your CPU does not use physics; it uses **bitwise tricks + vector multiplications**:

```mermaid
flowchart TD
    H_Gate["Execute dqc_h(qubit 0)"] --> Bitmask
    
    subgraph Bitmask ["Integer ALU: Fast Bitmasking"]
        B1["mask = 1 << 0 = 1"]
        B2["Pair states: (0 with 1) and (2 with 3)"]
        B1 --> B2
    end
    
    Bitmask --> SIMD_Math
    
    subgraph SIMD_Math ["SIMD Vector Registers: Multiply by 1/√2 (0.7071)"]
        M1["New Amplitude 0 = (1.0 + 0.0) * 0.7071 = +0.7071"]
        M2["New Amplitude 1 = (1.0 - 0.0) * 0.7071 = +0.7071"]
    end
    
    SIMD_Math --> Result
    
    subgraph Result ["Updated Statevector in L1 Cache"]
        R0["|00> = 0.7071 (50% probability)"]
        R1["|01> = 0.7071 (50% probability)"]
    end
```

---

## Step 5: Distributed TeleGate Between Virtual Chips

How your computer pretends to have two separate physical quantum chips:

```mermaid
sequenceDiagram
    autonumber
    participant Chip0 as Virtual QPU 0 (Owns Qubit 0)
    participant Channel as Simulated Quantum Channel
    participant Chip1 as Virtual QPU 1 (Owns Qubit 1)
    
    Channel->>Chip0: EPR Pair Half A
    Channel->>Chip1: EPR Pair Half B
    Note over Chip0: Local Bell Measurement on Qubit 0 + EPR Half A
    Chip0->>Chip1: Transmit 2 Classical Bits (c0, c1)
    Note over Chip1: Apply Pauli Correction (X if c1==1, Z if c0==1)
    Note over Chip0,Chip1: Result: Qubit 0 and Qubit 1 are now entangled!
```

```mermaid
flowchart LR
    subgraph Final_Memory_State ["Memory Amplitudes After TeleGate"]
        A0["|00> : 50% (+0.7071)"]
        A1["|01> :  0% (+0.0000)"]
        A2["|10> :  0% (+0.0000)"]
        A3["|11> : 50% (+0.7071)"]
    end
    note["Perfect Bell State: 1/√2 (|00> + |11>)"] --- Final_Memory_State
```

---

## Step 6: Measurement & Born Rule (Hardware Random Number Generator)

```mermaid
flowchart TD
    State["Amplitudes in Memory:\n|00> (50%) and |11> (50%)"] --> Prob["Compute Probabilities: P = Real^2 + Imag^2"]
    Prob --> RNG["Hardware RNG generates random number r in [0.0, 1.0)"]
    RNG --> Check{"Is r < 0.50 ?"}
    Check -- Yes --> Coll0["State Collapses to |00>\nAmplitudes reset: |00>=1.0, |11>=0.0"]
    Check -- No --> Coll1["State Collapses to |11>\nAmplitudes reset: |00>=0.0, |11>=1.0"]
    Coll0 --> Done["Return Classical Measurement Bit"]
    Coll1 --> Done
```

---

## Step 7: How the Histogram Reaches Your Eyeballs

```mermaid
flowchart LR
    subgraph Runtime ["1. DQC Runtime"]
        Calc["Compute percentage: 50.0%"] --> Bars["Generate string:\n|00>  ████████████████████  50.0%\n|11>  ████████████████████  50.0%"]
    end

    subgraph OS_Kernel ["2. macOS Kernel"]
        Sys["sys_write(stdout, buffer)"]
    end

    subgraph Display ["3. Terminal & Hardware Screen"]
        GPU["Apple Metal GPU Pipeline"] --> Pixels["Retina Display Pixels Lit Up!"]
    end

    Bars --> Sys
    Sys --> GPU
    GPU --> Pixels
```

---

## Hardware Component Role Cheat-Sheet

```mermaid
flowchart TD
    Root["Your Mac's Hardware Architecture"]
    
    Root --> CPU_ALU["CPU Integer ALU"]
    CPU_ALU --> A1["Calculates qubit bitmasks: 1 &lt;&lt; qubit"]
    CPU_ALU --> A2["Pairs basis states for gate applications"]
    
    Root --> SIMD["SIMD / Vector Units"]
    SIMD --> S1["Multiplies amplitudes by unitary matrices"]
    SIMD --> S2["Fused Multiply-Add FMA in 1 clock cycle"]
    
    Root --> L1["L1 Data Cache"]
    L1 --> L1_1["Holds entire 64-byte statevector"]
    L1 --> L1_2["Latency: 1 to 3 clock cycles"]
    
    Root --> RAM["System RAM"]
    RAM --> R1["Stores process instructions and heap buffer"]
    
    Root --> RNG["Hardware RNG"]
    RNG --> RN1["Generates entropy for Born-rule state collapse"]
    
    Root --> GPU["macOS Kernel & GPU"]
    GPU --> G1["Paints ASCII text to screen pixels via Metal"]
```

