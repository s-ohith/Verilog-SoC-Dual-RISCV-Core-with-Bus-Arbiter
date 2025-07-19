Verilog Dual-Core RISC-V System-on-Chip (SoC)
1. Project Overview
This repository contains the complete Verilog source code for a functional System-on-Chip (SoC) built around a dual-core RISC-V processor architecture. The primary goal of this project is to demonstrate a multi-core system where two independent CPUs can run separate programs while sharing a common set of hardware peripherals.

The SoC features a robust bus architecture with a custom-designed arbiter to manage concurrent access to an APB (Advanced Peripheral Bus) subsystem. This subsystem includes standard communication peripherals: SPI, I2C, and USART. The project is fully synthesizable and comes with a comprehensive testbench that verifies the entire system, from core instruction execution to final peripheral output.

This project serves as a practical example of key concepts in modern digital design, including multi-core processing, bus arbitration, memory-mapped I/O, and peripheral integration.

2. Core Concepts and Architecture
The SoC is built on several fundamental digital design concepts that work together to create a functional multi-core system.

a. Dual-Core RISC-V Architecture
The heart of the SoC is its two independent RISC-V CPU cores, riscv_core and riscv2core.

Independent Execution: Each core has its own internal instruction memory, allowing it to fetch and execute a separate program completely independently of the other core.

Shared Resources: While the cores run separate instruction streams, they share access to the data bus, which connects them to the peripheral subsystem. This creates a scenario where both cores might need to use a peripheral at the same time, necessitating an arbitration scheme.

b. APB Peripheral Subsystem
All peripherals are grouped into a single subsystem (soc_top) that is connected to the main system via a standard APB (Advanced Peripheral Bus). This is a common industry practice that simplifies the design.

Address Decoding: The soc_top module contains an address decoder. When a transaction arrives on the APB, the decoder reads the address and generates a select signal (PSEL) for the correct peripheral.

Included Peripherals:

SPI (Serial Peripheral Interface): A master-only SPI module for high-speed serial communication.

I2C (Inter-Integrated Circuit): A master-only I2C module for two-wire serial communication.

USART (Universal Synchronous/Asynchronous Receiver-Transmitter): For standard serial communication.

c. Memory-Mapped I/O (MMIO)
The RISC-V cores do not have special instructions like WRITE_TO_SPI. Instead, they communicate with peripherals using a technique called Memory-Mapped I/O.

The Concept: Specific memory addresses are assigned to the control and data registers of each peripheral. From the core's perspective, talking to a peripheral is identical to writing to or reading from memory.

Execution Flow:

The core executes a standard sw (store word) or lw (load word) instruction.

The core's ALU calculates the target memory address.

The SoC's interconnect logic examines this address. If it falls within the pre-defined range for peripherals, the request is "hijacked" and routed to the APB bus instead of main memory.

The peripheral receives the transaction and performs the requested action.

d. Bus Arbitration and Interconnect (The Priority Mechanism)
This is the most critical component in a multi-core design. Since both cores share one APB bus, a mechanism is needed to resolve conflicts.

Request Detection: The arbiter continuously monitors the output of both cores. In this design, a request is signaled when a core generates a non-zero alu_result_out.

Round-Robin Priority: To ensure fairness, a simple and effective round-robin arbitration scheme is used.

After reset, Core 1 is given priority.

If Core 1 is granted access to the bus, priority immediately switches to Core 2 for the next cycle.

If Core 2 is granted access, priority switches back to Core 1.

If the core with priority is not making a request, the arbiter will grant access to the other core if it is making a request.

Interconnect (Mux): Once the arbiter grants access to a core, the interconnect acts as a large multiplexer. It takes the relevant outputs from the granted core (alu_result_out and reg_data1_out) and routes them to the APB bus's PWDATA and PADDR inputs, respectively.

3. File Structure and Key Modules
dual_core_soc.sv: The top-level module. This file instantiates the two cores and the peripheral subsystem and contains the bus arbiter and interconnect logic.

riscv_core.sv / riscv2core.sv: The two independent RISC-V CPU core modules.

soc_top.sv: The APB peripheral subsystem. It instantiates all the slave modules and handles address decoding.

spi_apb_slave.sv, i2c_apb_slave.sv, usart_apb_slave.sv: These modules are the "glue" logic that connects the APB bus to the underlying driver logic.

spi_driver.sv, i2c_driver.sv, usart_driver.sv: These are the state machines that implement the actual logic for each communication protocol.

dual_core_soc_tb.sv: The main testbench. This file instantiates the entire SoC, loads programs into the cores, and monitors the peripheral outputs to verify correct operation.

4. How to Run the Simulation
To compile and run this project, you will need a Verilog simulator (e.g., Vivado XSim, ModelSim, Verilator).

Create a New Project: In your simulator, create a new project and add all the Verilog (.sv) source files from this repository.

Set the Top Module: Configure your simulation settings to use dual_core_soc_tb.sv as the top-level module for the simulation.

Compile: Compile all the source files.

Run Simulation: Launch the simulation. The testbench is self-contained and will perform the following steps automatically:

It will use hierarchical paths to load a simple program into the internal instruction memory of each core.

Core 1 will be programmed to write a specific data byte to the SPI peripheral.

Core 2 will be programmed to write a different data byte to the USART peripheral.

The testbench will then apply and release the reset signal.

Observe the Output:

Waveform Viewer: Add the signals from the dual_core_soc and the testbench to your waveform viewer. You will be able to see the cores executing instructions, the arbiter granting access, and the APB transactions occurring.

Simulation Console: The testbench includes monitor tasks that act as virtual receivers for the SPI and USART peripherals. When a core successfully transmits a byte, a message will be printed to the console confirming that the data was received correctly.

This process provides a complete, end-to-end verification of the entire SoC design.
