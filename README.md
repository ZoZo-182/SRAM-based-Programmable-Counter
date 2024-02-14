# SRAM-based-Programmable-Counter
This project involves designing an 8-bit counter with programmable sequences using the DE2-115 board's SRAM. The counter operates on a one Hz clock signal, reading values from memory and advancing through them accordingly. It features byte selection for read/write operations and abides by addressing constraints within the available memory space.

SRAM Addressing
The SRAM address requires 20 bits for 1MByte memory locations of 16-bit width. However, for the sake of simplicity and time constraints, the counter sequence is restricted to a length of 256, utilizing addresses from 0x00000 to 0x000FF. Therefore, the addressing range used will be 0x00 to 0xFF, with higher-order address bits assumed as 0s.

Memory Organization
The SRAM will store the 16-bit counter sequence. Each address location (0x00 to 0xFF) will hold a 16-bit value representing the sequence.

Counter Operation
The counter will increment at a frequency of one Hz, controlled by the clock signal. It will read the next value from memory according to the clock ticks, advancing through the stored sequence.

Byte Selection
The design will incorporate the ability to choose the upper byte (UB) and lower byte (LB) for read/write operations. UB and LB signals will determine whether to access the upper or lower byte of the 16-bit counter data.

Design Considerations
Implement a memory read and write interface to access the SRAM.
Incorporate a clock signal to control the counter's progression through memory.
Develop logic to enable the incrementing of the counter based on the clock signal.
Integrate control signals (UB, LB) for selecting the upper and lower byte during read/write operations.
Implementation
The design will involve interfacing the SRAM with the counter logic, incorporating clock-driven sequencing and addressing to fetch the next value in the counter sequence from memory locations 0x00 to 0xFF, with the flexibility to access the upper or lower bytes based on specified control signals. The implementation will abide by the limitations of the address range and the available memory space on the DE2-115 board's SRAM.

For detailed information on the implementation, refer to the project documentation and source code.
