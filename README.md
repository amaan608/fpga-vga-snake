# FPGA Hardware Snake Game

A standalone, hardware-level implementation of the classic Snake arcade game written completely from scratch in **Verilog HDL** and synthesized using **Xilinx Vivado**. The entire system runs natively on the hardware gates of a **Xilinx Nexys A7-100T FPGA board**, interfacing directly with a monitor via VGA protocol and outputting real-time player data to on-board 7-segment displays.

## Key Technical Features

* **Modular Hardware Architecture:** Fully decoupled, production-grade design separating the game brain, video rendering, input purification, and display driver modules.
* **Custom VGA Controller:** Built a video synchronization engine from scratch using a derived `25MHz` pixel clock to generate precise timing signals ($H_{sync}$, $V_{sync}$) for standard `640x480 @ 60Hz` display rendering.
* **FSM-Driven Game Engine:** Designed a robust 3-state Finite State Machine (`INIT`, `PLAY`, `GAME_OVER`) managing snake direction coordinates, dynamic speed-scaling acceleration mechanics, and collision grids.
* **Pseudo-Random Spatial Generation:** Integrated a 12-bit **Linear Feedback Shift Register (LFSR)** utilizing specialized polynomial taps to randomize apple coordinate generation seamlessly upon consumption.
* **7-Segment Display Multiplexing:** Engineered an asynchronous, time-multiplexed display driver running at a `760Hz` refresh rate to translate internal binary registers into human-readable real-time scores (`0` indexed for apples eaten).
* **Input Glitch Isolation:** Implemented custom multi-stage synchronous **hardware debouncers** to clean up mechanical switch bounces from the physical push-buttons.

---

## Hardware Specifications & Constraints

* **Target Board:** Xilinx Nexys A7-100T
* **Master Clock:** 100 MHz (Divided down to 25 MHz for VGA and calibrated frequencies for game progression ticks)
* **Display Interface:** VGA (4-bit per color channel, 12-bit RGB depth)
* **Peripherals Utilized:** * Directional Push Buttons (Up, Down, Left, Right)
    * Center Button (System Reset / Return to Start Screen)
    * Common Anode 7-Segment Displays (Score Display Module)

---

## Module Architecture Breakdown

The project repository is cleanly organized into the following behavioral and structural HDL modules:

1.  `top.v` — The structural top-level wrapper mapping physical board I/O pins and interconnecting internal module nets.
2.  `snake_engine.v` — The main algorithmic core containing coordinate shift registers, array management for the snake body tracking, and wall/self-collision algorithms.
3.  `vga_controller.v` — Generates exact blanking intervals, front/back porches, and structural screen scan coordinates ($X, Y$).
4.  `scoreboard.v` — The 7-segment LED multiplexer and binary-to-BCD converter driving the active-low common anode displays.
5.  `debouncer.v` — Digital logic low-pass filter preventing spurious multi-triggering from physical tactile buttons.
6.  `lfsr.v` — Hardware pseudo-random number generator for uniform grid-based coordinate scattering.

---

## Technical Environment

* **Language:** Verilog HDL
* **Toolchain:** Xilinx Vivado Design Suite
* **Verification:** Behavioral Simulation & Hardware In-Circuit Testing