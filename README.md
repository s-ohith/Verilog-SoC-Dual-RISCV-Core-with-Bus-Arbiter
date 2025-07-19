# 🔧 Verilog Dual-Core RISC-V System-on-Chip (SoC)

This project implements a **multi-core RISC-V System-on-Chip (SoC)** in **SystemVerilog**, featuring:
- Two independent **RISC-V CPU cores**
- A **shared APB peripheral bus**
- A **custom round-robin bus arbiter**
- Memory-mapped access to **SPI**, **I2C**, and **USART** peripherals
- A comprehensive **testbench** to simulate and verify end-to-end functionality

---

## 📑 Table of Contents
- [🧠 Project Overview](#-project-overview)
- [⚙️ Architecture and Design Concepts](#️-architecture-and-design-concepts)
  - [Dual-Core RISC-V Architecture](#dual-core-risc-v-architecture)
  - [APB Peripheral Subsystem](#apb-peripheral-subsystem)
  - [Memory-Mapped I/O (MMIO)](#memory-mapped-io-mmio)
  - [Bus Arbitration and Interconnect](#bus-arbitration-and-interconnect)
- [📁 File Structure](#-file-structure)
- [▶️ How to Run the Simulation](#️-how-to-run-the-simulation)
- [🔬 Features to Explore in Simulation](#-features-to-explore-in-simulation)
- [📜 License](#-license)
- [📬 Contact](#-contact)

---

## 🧠 Project Overview
![Uploading image.png…]()


This repository contains a complete and synthesizable SoC designed in Verilog, showcasing a **dual-core RISC-V processor architecture** that runs **two separate programs** concurrently. These cores share access to a **common set of peripherals**—SPI, I2C, and USART—via a **custom bus arbiter** that implements a **round-robin priority mechanism**.

This project is designed to demonstrate:

- Multi-core processor design
- Shared resource management
- Memory-mapped peripheral communication
- SoC simulation and verification flow

It is suitable for **educational purposes**, **SoC verification practice**, and **understanding digital design concepts** in real-world scenarios.

---

## ⚙️ Architecture and Design Concepts

### 🧩 Dual-Core RISC-V Architecture

- **Cores**: `riscv_core` and `riscv2core`
- Each has its own **instruction memory**.
- Each runs a **completely separate program** (independent PC, ALU, register file).
- Both share a **common APB bus** for accessing peripherals.

> This setup mimics real-world multi-core systems, where cores execute different tasks but synchronize through shared memory/peripherals.

---

### 🧩 APB Peripheral Subsystem

- **Module**: `soc_top`
- Connected to the cores via the **Advanced Peripheral Bus (APB)**.
- Uses **address decoding logic** to enable peripherals.

#### 📦 Included Peripherals
- `spi_apb_slave` + `spi_driver` — SPI Master
- `i2c_apb_slave` + `i2c_driver` — I2C Master
- `usart_apb_slave` + `usart_driver` — Serial communication

Each peripheral supports **basic transmission** and responds to **read/write transactions** issued via MMIO.

---

### 🧩 Memory-Mapped I/O (MMIO)

- Cores interact with peripherals via **standard load (`lw`) and store (`sw`) instructions**.
- **Peripheral registers** are mapped into specific memory ranges.
- No special instructions are needed—just **memory reads/writes** to specific addresses.

#### 🔄 Flow:
1. Core issues a `sw` or `lw` instruction.
2. Address falls into peripheral range.
3. Interconnect routes the access to the APB bus.
4. Peripheral receives the transaction and processes it.

---

### 🧩 Bus Arbitration and Interconnect

- Both cores **share the APB bus**, so a **round-robin arbiter** ensures **fair and conflict-free access**.
- **Priority toggles** between cores after each successful access.

#### 🚦 Arbiter Logic:
- Start: Core 1 has priority.
- After Core 1 uses the bus → priority → Core 2.
- If priority core is idle, the other core gets access.
- **Multiplexer-based interconnect** routes selected core's address/data lines to the APB interface.

---

## 📁 File Structure

| File | Description |
|------|-------------|
| `dual_core_soc.sv` | Top-level module: instantiates cores, interconnect, arbiter, and peripheral subsystem |
| `riscv_core.sv` & `riscv2core.sv` | Two independent RISC-V CPU cores |
| `soc_top.sv` | Peripheral subsystem wrapper with APB address decoder |
| `spi_apb_slave.sv`, `i2c_apb_slave.sv`, `usart_apb_slave.sv` | APB interface logic for each protocol |
| `spi_driver.sv`, `i2c_driver.sv`, `usart_driver.sv` | Protocol-level control logic (state machines) |
| `dual_core_soc_tb.sv` | Testbench to run full SoC simulation |
| `README.md` | Project documentation |
| `.gitignore` | Git exclusions for Vivado-generated files |
| `scripts/create_project.tcl` | Vivado project recreation script (optional) |

---

## ▶️ How to Run the Simulation

### ✅ Requirements:
- Any Verilog simulator (Vivado XSim, ModelSim, Verilator)

### 📌 Steps:

1. **Clone the Repository**
   ```bash
   git clone https://github.com/s-ohith/Verilog-SoC-Dual-RISCV-Core-with-Bus-Arbiter.git
   cd Verilog-SoC-Dual-RISCV-Core-with-Bus-Arbiter
<img width="1869" height="869" alt="image" src="https://github.com/user-attachments/assets/c8457c5c-27ba-4dbc-b833-b069420f3101" />
<img width="1855" height="852" alt="image" src="https://github.com/user-attachments/assets/5ad0e830-3bd7-4d4a-b80d-1ee5c3e2e5ce" />

## 🖥️ Sample Output

```text
[INFO] Memory-Mapped Dual-Core SoC Testbench Started
[INFO] Memory Map & Test Blocks:
[INFO]   0x00000000 - 0x10000000 -> USART (Base: 0x200) -> test_usart_peripheral()
[INFO]   0x10000001 - 0x20000000 -> SPI   (Base: 0x000) -> test_spi_peripheral()
[INFO]   0x20000001 - 0x30000000 -> I2C   (Base: 0x100) -> test_i2c_peripheral()
[INFO]   Above 0x30000000        -> USART (Default)    -> test_usart_peripheral()
[INFO] Core priority alternates every 4 cycles

[TEST] Starting USART Transaction - ALU: 0x00000001
=== CYCLE 0 ===
Priority Core: CORE1
Primary   - ALU: 0x00000001, RS1: 0x00
Secondary - ALU: 0x00000000, RS1: 0x0b
Peripheral: USART (ALU: 0x00000001 <= 0x10000000) - Test Block: test_usart_peripheral()

Time: 125000 ns | Read from 0x204 = 0x0
Time: 125000 ns | USART Transaction Complete!
Mapped PADDR: 0x200, PWDATA: 0x00000003
STATUS: Peripheral transaction in progress...
