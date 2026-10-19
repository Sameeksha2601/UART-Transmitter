# UART Transmitter and Receiver in Verilog

A digital design project implementing a Universal Asynchronous Receiver/Transmitter (UART) using Verilog HDL. The design includes separate transmitter and receiver modules integrated through a top-level module.

The project focuses on RTL design, finite-state machines, clock-cycle timing, serial communication, simulation, and logic synthesis.

## Features

- Verilog RTL implementation of UART transmitter and receiver.
- Separate TX and RX modules integrated using a top-level module.
- FSM-based control logic for serial data transmission and reception.
- Configurable clock cycles per bit using the `CLKS_PER_BIT` parameter.
- Baud-rate timing using counters.
- 8-bit data storage and serial data handling.
- Yosys synthesis and structural checks.

## Design Parameters

| Parameter | Value |
|---|---|
| System clock | 50 MHz design configuration |
| Clock cycles per bit | 5208 |
| Nominal baud rate | Approximately 9600 baud |
| Data width | 8 bits |
| RTL language | Verilog HDL |

The nominal baud rate is calculated as:

`Baud Rate = Clock Frequency / CLKS_PER_BIT`

For a 50 MHz clock and 5208 clock cycles per bit, the resulting baud rate is approximately 9600.61 baud.

## Project Structure

```text
.
├── uart_tx.v
├── uart_rx.v
├── uart_top.v
├── uart_tx_tb.v
├── uart_rx_tb.v
├── uart_top_tb.v
├── uart_synthesis_report.txt
├── uart_abc_report.txt
└── uart_mapped.json
```

The testbench and report filenames above should be adjusted to match the files actually present in the repository.

## Tools Used

- Verilog HDL
- Icarus Verilog — RTL simulation
- GTKWave — waveform inspection
- Yosys — logic synthesis and structural checks
- MSYS2 UCRT64 — development environment

## Synthesis

The top-level design was processed using Yosys with the following command:

```text
read_verilog uart_tx.v uart_rx.v uart_top.v
hierarchy -top uart_top
synth -top uart_top
stat
```

The synthesis log confirms that the TX, RX, and top-level modules were parsed, the parameterized design was elaborated with `CLKS_PER_BIT = 5208`, and the structural check reported zero problems.

The generated reports and mapped JSON netlist are included for further inspection.

## Learning Outcomes

- Designing synchronous digital circuits in Verilog.
- Implementing FSM-based control logic.
- Using counters to generate serial timing.
- Integrating multiple RTL modules.
- Simulating and debugging digital designs.
- Understanding RTL synthesis and mapped logic representations.

