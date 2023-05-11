# Tiny_Risc-V_ECE389

## Description
This project impliments a CPU on an FPGA using Quartus Verilog. The intruction set is based off of Christopher Batten's Tiny risc-V design: https://www.csl.cornell.edu/courses/ece5745/handouts/ece5745-tinyrv-isa.txt

This design followed the TinyRV2 ISA, which is a subset of risc-V that contains enough instructions to run basic programs. This functionallity includes add, subract, multiply, shift, logical comparisons, jumps, branches, and load and store to memory.

### basic_CPU
main file containing the verilog files below.

cpu_ctrl.v: contains the logic to decode the instruction

ALU.v: contains logic for any math operations

reg_file.v: contains 32 registers with 32 bits of storage each

display.v: Takes in a 4 bit number and converts it to its corresponding 7-segment hex value (0-F)

main_memory: memory for SW and LW

program_store: memory for the program to run


### instructions.txt
Contains output pin encoding, as well as a breakdown of two basic programs. The first program runs through each instruction to ensure they are working properly. The second program performs factorial(n) using a recursive function call. 

### program.txt
Contains the two programs converted to decimal, which allows them to be copied and pasted into program.mif.
