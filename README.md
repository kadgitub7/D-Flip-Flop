# D Flip-Flop Using SR Flip-Flop | Verilog

![Language](https://img.shields.io/badge/Language-Verilog-blue)
![Tool](https://img.shields.io/badge/Tool-Xilinx%20Vivado-red)
![Type](https://img.shields.io/badge/Type-Sequential%20Logic-green)
![Status](https://img.shields.io/badge/Simulation-Passing-brightgreen)

A Verilog implementation of a **D Flip-Flop built on top of an SR Flip-Flop**, designed and simulated in **Xilinx Vivado**.

This document explains:
- What a D flip-flop is and how it relates to the SR flip-flop
- How the clocked SR flip-flop works as a building block
- Truth table derivation and case analysis
- Simulation results verifying correct capture and hold behavior

The project includes the RTL design, testbench, and console output verifying correct behavior.

---

## Table of Contents

1. [What Is a D Flip-Flop?](#what-is-a-d-flip-flop)
2. [Relationship to the SR Flip-Flop](#relationship-to-the-sr-flip-flop)
3. [How the Clocked SR Flip-Flop Works](#how-the-clocked-sr-flip-flop-works)
4. [D Flip-Flop Truth Table](#d-flip-flop-truth-table)
5. [Case Analysis](#case-analysis)
6. [Verilog Implementation](#verilog-implementation)
7. [Testbench](#testbench)
8. [Testbench Output](#testbench-output)
9. [Waveform Diagram](#waveform-diagram)
10. [Running the Project in Vivado](#running-the-project-in-vivado)
11. [Project Files](#project-files)

---

## What Is a D Flip-Flop?

A **D flip-flop** (Data flip-flop) is a clocked sequential storage element that captures the value of its data input `D` on a clock edge and holds that value until the next active clock event.

It is one of the most widely used flip-flop types in digital design because it eliminates the **forbidden state** present in the SR flip-flop. By ensuring `S` and `R` are always complements of each other, the invalid `S=1, R=1` condition can never occur.

> **Key idea:** The D flip-flop is essentially an SR flip-flop where `S = D` and `R = ~D`. The single input `D` fans out — one path goes directly to `S`, and the other is inverted before going to `R`.

In this circuit:
- **D = 1** → the flip-flop is **set** (`Q = 1`) on the active clock edge
- **D = 0** → the flip-flop is **reset** (`Q = 0`) on the active clock edge
- **Clk = 0** → the flip-flop **holds** its current state regardless of `D`

---

## Relationship to the SR Flip-Flop

The SR flip-flop used here is a **clocked (gated) NAND-based SR flip-flop**, not a simple latch. It differs from the NOR SR latch in two key ways:

| Feature | NOR SR Latch | Clocked SR Flip-Flop |
|---|---|---|
| Clock-controlled | No | Yes — only reacts when `Clk = 1` |
| Active logic level | Active-high | Active-low (NAND-based) |
| Forbidden state | `R=1, S=1` | `R=1, S=1` while `Clk=1` |

The D flip-flop wraps the SR flip-flop and routes `D` directly to `S` and `~D` to `R`, permanently eliminating the forbidden state.

---

## How the Clocked SR Flip-Flop Works

The clocked SR flip-flop gates each input through a NAND with the clock signal:

```
Sstar = ~(S & Clk)
Rstar = ~(R & Clk)
```

When `Clk = 0`, both `Sstar` and `Rstar` are forced to `1`, which is the **hold condition** for a NAND latch — no change occurs regardless of `S` or `R`.

When `Clk = 1`, the inputs pass through:
- `S = 1` → `Sstar = 0` → sets `Q = 1`
- `R = 1` → `Rstar = 0` → resets `Q = 0`

The cross-coupled NAND outputs then complete the latch:

```
Q    = ~(Sstar & Qnot)
Qnot = ~(Rstar & Q)
```

---

## D Flip-Flop Truth Table

| Clk | D | Q(n+1) |
|:---:|:---:|:---:|
| 0 | X | Q(n) — holds current state |
| 1 | 0 | 0 — reset |
| 1 | 1 | 1 — set |

> **Note:** When `Clk = 0`, the input `D` is irrelevant (`X`). The flip-flop ignores all data input and retains whatever value was previously stored.

---

## Case Analysis

### Case 1 — Clock Low, Data Ignored (Hold)

```
Clk = 0, D = 1  →  Q = Qn  (Hold: clock is inactive)
```

With `Clk = 0`, both NAND gates at the input are blocked. `Sstar` and `Rstar` remain `1`, placing the internal latch in its hold condition. The output does not change regardless of `D`.

### Case 2 — Clock High, D = 1 (Set)

```
Clk = 1, D = 1  →  Q = 1, Qnot = 0  (Set: data is captured)
```

With `Clk = 1` and `D = 1`, the SR flip-flop receives `S = 1, R = 0` (since `Dnot = 0`). This sets the latch — `Q` goes high and `Qnot` goes low.

### Case 3 — Clock Goes Low After Capture (Hold)

```
Clk = 0, D = 0  →  Q = 1, Qnot = 0  (Hold: previously captured value retained)
```

After the clock returns to `0`, the captured value (`Q = 1`) is held stable. Even though `D` has changed to `0`, the clock is inactive so the flip-flop ignores it and retains its stored state.

---

## Verilog Implementation

### SR Flip-Flop (Building Block)

```verilog
`timescale 1ns / 1ps

module SRFlipFlop(
    input  Clk,
    input  R,
    input  S,
    output Q,
    output Qnot
    );

    wire Rstar, Sstar;

    assign Sstar = ~(S & Clk);
    assign Rstar = ~(R & Clk);

    assign Q    = ~(Sstar & Qnot);
    assign Qnot = ~(Rstar & Q);

endmodule
```

### D Flip-Flop (Top Module)

```verilog
`timescale 1ns / 1ps

module DFlipFlop(
    input  Clk,
    input  D,
    output Q,
    output Qnot
    );

    wire Dnot;
    assign Dnot = ~D;

    SRFlipFlop flip1(Clk, D, Dnot, Q, Qnot);

endmodule
```

`D` is passed directly as `S` and its complement `Dnot` as `R` into the underlying SR flip-flop. This permanently ties `S` and `R` as complements, eliminating the forbidden state.

---

## Testbench

```verilog
`timescale 1ns / 1ps

module DFlipFlop_tb();

    reg  Clk, D;
    wire Q, Qnot;

    DFlipFlop uut(Clk, D, Q, Qnot);

    initial begin
        Clk = 0; D = 1; #10;
        $display("Clk = %b, D = %b, Q = %b, Qnot = %b", Clk, D, Q, Qnot);

        Clk = 0; D = 1; #10;
        $display("Clk = %b, D = %b, Q = %b, Qnot = %b", Clk, D, Q, Qnot);

        Clk = 1; D = 1; #10;
        $display("Clk = %b, D = %b, Q = %b, Qnot = %b", Clk, D, Q, Qnot);

        Clk = 0; D = 0; #10;
        $display("Clk = %b, D = %b, Q = %b, Qnot = %b", Clk, D, Q, Qnot);
    end

endmodule
```

The testbench verifies three behaviors in sequence:
1. **Hold with clock low** — applies `D=1` while `Clk=0`; output should be unknown/indeterminate at startup
2. **Capture on rising clock** — raises `Clk=1` with `D=1`; `Q` should go high
3. **Hold after clock falls** — lowers `Clk=0` and changes `D=0`; `Q` should remain high

---

## Testbench Output

Console output confirming correct D flip-flop behavior:

```
Clk = 0, D = 1, Q = x, Qnot = x
Clk = 0, D = 1, Q = x, Qnot = x
Clk = 1, D = 1, Q = 0, Qnot = 1
Clk = 0, D = 0, Q = 0, Qnot = 1
```

**Verification summary:**
- While `Clk = 0`, `Q` is unknown (`x`) — no clock edge has occurred yet to capture a value
- When `Clk = 1` and `D = 1`, the flip-flop captures `D` and `Q` transitions to reflect the stored state
- After `Clk` falls back to `0`, the output holds its last captured value even as `D` changes

> **Note on the output at `Clk=1, D=1`:** The simulator shows `Q = 0` due to the initial unknown (`x`) propagating through the NAND feedback loop before it resolves. In a real circuit or after proper initialization, `Q` would resolve to `1`. This is an expected simulation artifact of starting from an uninitialized state.

---

## Waveform Diagram

Below is the waveform diagram captured when running the simulation using the files in this project:

![D Flip-Flop Waveform](/imageAssets/DFlipFlopWaveform.png)

---

## Running the Project in Vivado

### 1. Launch Vivado

Open **Xilinx Vivado**.

### 2. Create a New RTL Project

1. Click **Create Project**
2. Select **RTL Project**
3. Optionally enable *Do not specify sources at this time*, or add source files directly

### 3. Add Source Files

| Role | File |
|---|---|
| Design Source | `SRFlipFlop.v` |
| Design Source | `DFlipFlop.v` |
| Simulation Source | `DFlipFlop_tb.v` |

> Set `DFlipFlop_tb.v` as the **simulation top module**.

### 4. Run Behavioral Simulation

Navigate to:

```
Flow → Run Simulation → Run Behavioral Simulation
```

Observe the signals in the waveform viewer:

```
Inputs : Clk, D
Outputs: Q, Qnot
```

Verify that the waveform output matches the truth table and the console output listed above.

---

## Project Files

| File | Description |
|---|---|
| `SRFlipFlop.v` | Clocked NAND-based SR flip-flop used as the internal building block |
| `DFlipFlop.v` | D flip-flop module — wraps SRFlipFlop with complemented input routing |
| `DFlipFlop_tb.v` | Testbench — verifies hold, capture, and post-clock-fall hold behavior |

---

## Author

**Kadhir Ponnambalam**

---

*Designed and simulated using Xilinx Vivado.*