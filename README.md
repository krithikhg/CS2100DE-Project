# CS2100DE RISC-V CPU

We implemented a RISC-V CPU, with 5-stage pipelining. The CPU runs on the Nexys4 FPGA board. We also wrote a simple 1D Pong game that runs on the FPGA, using the switches and the 7-segment display, that runs on the CPU. The game is written in C, then compiled to RISC-V Assembly and assembled so that it runs natively on the CPU implemented.

---

## CPU features

The CPU supports all RISC-V Base instructions, except lb, lh, sb, sh (i.e. only loading and storing of words is supported) and ecall/ebreak (there is no OS running).

The CPU features 5-stage pipelining as previously mentioned, allowing us to run it at the full 100MHz clock speed using the onboard clock signal. The CPU also features branch flushing, which allows the next 2 stale instructions to be flushed if a branch or jump is taken. Programmers do not need to manually add in nops to account for control hazards.

However, we have not implemented data forwarding and load-use stalling, hence nops still need to be inserted at compile time to handle data hazards. 

CPU communicates with I/O devices such as the LEDs, push buttons, dip switches and 7-segment display using Memory Mapped I/O (MMIO). 

Refer to [Pipelined_processor.pdf](./Pipelined_processor.pdf) for an overview of the CPU design.

## Pong Game

A two-player reaction game implemented in C (`pong.c`) and compiled to RISC-V assembly (`pong.asm`), running directly on the CPU. Ball starts in the middle of the row of 7-segment display digits, and moves left/right. Each player must flip their switch (either up/down as long as there is a state change from previous) when the ball reaches the digit closest to them to bounce it back to the other player. If the switch is flipped too early, the player loses, and if the switch is flipped too late the player also loses. LEDs on the player's side light up to indicate they have won. Press the reset button to play again. 

## More Information

### Supported Instructions

**R-type:** `add`, `sub`, `sll`, `slt`, `sltu`, `xor`, `srl`, `sra`, `or`, `and`

**I-type (ALU):** `addi`, `slli`, `slti`, `sltiu`, `xori`, `srli`, `srai`, `ori`, `andi`

**I-type (Load):** `lw`

**S-type:** `sw`

**B-type (Branch):** `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`

**J-type:** `jal`, `jalr`

**U-type:** `lui`, `auipc`

### Key Modules

- **`RISCV_MMC.sv`** — Top-level CPU; wires all pipeline stages together
- **`Decoder.sv`** — Control unit; decodes opcode/funct3/funct7 into control signals
- **`ALU.sv`** — 32-bit ALU with 10 operations and 3-bit flag output
- **`RegFile.sv`** — 32×32 register file; synchronous write, asynchronous read
- **`Extend.sv`** — Immediate sign-extender for I/S/B/U/J formats
- **`PC_Logic.sv`** — Evaluates branch conditions and selects next PC source
- **`ProgramCounter.sv`** — 32-bit program counter with synchronous reset
- **`Adder.sv`** — 32-bit adder used for PC increment and branch target
- **`SevenSegDecoder.sv`** — Multiplexed 8-digit 7-segment driver
- **`Top_MMC.sv`** — FPGA top module; integrates CPU, memories, and all MMIO peripherals