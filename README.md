# SRAM-Based Programmable Counter

This repository contains the project for designing an SRAM-based programmable 8-bit counter with an arbitrary sequence running on a one Hz clock using the Altera DE2-115 board. Below is a detailed outline of the hardware, system design, and operational modes.

## Parts List

1. Altera DE2-115 Board
2. Breadboard
3. 19-Key Keypad

## System Design

### SRAM Addressing

- **Memory Size**: The DE2-115 board's 2 MByte fast asynchronous SRAM requires 20 bits for 1MByte memory locations of 16-bit width.
- **Address Range**: The counter sequence is restricted to a length of 256, utilizing addresses from 0x00000 to 0x000FF. Simplified addressing range: 0x00 to 0xFF.
- **Memory Organization**: Each address location (0x00 to 0xFF) stores a 16-bit value representing the counter sequence.

### Counter Operation

- **Frequency**: The counter increments at a frequency of one Hz, controlled by the clock signal.
- **Byte Selection**: Upper byte (UB) and lower byte (LB) signals determine access to the upper or lower byte of the 16-bit counter data.
- **Read/Write Interface**: Implements a memory read and write interface to access the SRAM, incorporating a clock signal to control the counter's progression.

## System Specifications and Operational Modes

### Initialization and Default Sequence

- **Power-On Reset**: Initializes the SRAM content by loading a default data sequence from a 256 x 16-bit ROM using the memory initialization file "sine.mif".
- **Reset Button (KEY0)**: Reloads the default sequence into the SRAM.

### Default Operation Mode

- **Pause Mode**: The system defaults to pause mode upon entering the operation mode. 
- **Display**: The 7-segment displays (HEX3-HEX0) showcase the SRAM content at address 0x00, while HEX5 and HEX4 display the address itself.

### Manual Control

- **Keypad Connection**: Manual control of the counter via a keypad connected to the DE2-115 board through a 40-pin ribbon cable and a breadboard.

### System Controls and Modes

#### Operational Mode

- **Run/Pause Toggle**: Pressing the "H" key toggles between run and pause modes.
  - **Run Mode**: Cycles through SRAM addresses in the forward direction, displaying SRAM contents at one-second intervals.
  - **Pause Mode**: Halts and continues displaying the current SRAM address and its data.
- **Counter Direction**: Pressing the "L" key toggles the counter direction between forward and backward.
- **Mode Toggle**: Pressing the "Shift" key toggles between Operational mode (LEDG0 on) and Programming mode (LEDG0 off).

#### Programming Mode

- **SRAM Address/Data Setup**: Pressing the "H" key toggles between the SRAM address setup and the SRAM data modes.
  - **SRAM Address Setup Mode**: 
    - Keypad inputs (0-9, A-F) display their HEX values on HEX4.
    - Successive key presses shift displayed values to HEX5, forming an 8-bit number representing an SRAM address.
  - **SRAM Data Mode**: 
    - Keypad inputs (0-9, A-F) display their HEX values on HEX0.
    - Successive key presses shift displayed values to HEX1, HEX2, and finally to HEX3, forming a 16-bit binary number.
- **Load Data**: Pressing the "L" key loads the 4-digit HEX data displayed on HEX3 to HEX0 into the SRAM memory address indicated by HEX5 and HEX4.
- **Return to Operational Mode**: A "Shift" key press in programming mode toggles back to the operational mode’s pause mode, where HEX3-HEX0 display the SRAM content at address 0x00, shown on HEX5 and HEX4.

## Display Naming Convention

The system utilizes six 7-segment displays on the DE2-115 board named HEX5 to HEX0 for displaying addresses and data.

---

Please take a look at the project concept diagram included in the repository for an idea of how each component connects and interacts.
