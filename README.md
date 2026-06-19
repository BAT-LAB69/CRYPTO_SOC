# CRYPTO_SOC: Advanced Cryptographic System-on-Chip

## Overview

This repository contains the RTL design and documentation for CRYPTO_SOC, a comprehensive Cryptographic System-on-Chip. This project is officially developed for the Urban Integrated Circuit Design Competition. 

The system integrates a True Random Number Generator (TRNG), SHAKE128/SHAKE256 hashing cores, Advanced Encryption Standard (AES-CBC), Ed25519 digital signatures, and BIKE Key Encapsulation Mechanism (KEM) to provide a robust, hardware-accelerated security subsystem.

## System Architecture

The core architecture routes inputs through a multiplexer (MUX) for operation mode selection. Based on the selected mode, the data flow diverges into either the Ed25519 core or the BIKE KEM core. Both distinct operational paths utilize a unified Keccak (SHAKE) module to handle all cryptographic hashing requests efficiently, minimizing hardware overhead.

## Data Flow and Buffer Management

The memory management and data flow are strictly controlled via a 4-buffer system. Each activation cycle generates data into two distinct buffers to ensure pipeline efficiency and prevent data collision.

### Buffer Allocation

* **Buffer 0 (256-bit):** Stores the output from the TRNG. Slices [127:0] are utilized as the Initialization Vector (IV) for the AES-CBC module.
* **Buffer 1 (256-bit):** Stores the output from the TRNG. Serves as the seed input for the SHAKE128 module.
* **Buffer 2 (256-bit):** Stores the output from the SHAKE128 module. Slices [127:0] are utilized as the 128-bit Key for the AES-CBC module.
* **Buffer 3 (256-bit):** Stores the output from the SHAKE128 module. Slices [255:0] are utilized as the 256-bit Key for the Ed25519 module.

## AES and SHAKE128 Integration Flow

The AES-CBC encryption and decryption process relies on dynamically generated keys and IVs to ensure high security:

1. **TRNG Output:** Generates the IV for AES directly into Buffer 0.
2. **Key Generation:** A 64-bit user password is fed into the SHAKE128 core. To increase cryptographic complexity, SHAKE128 hashes this password into a 128-bit key, which is then stored in Buffer 2.
3. **Data Encryption:** User input (Plaintext) is encrypted using the AES-CBC algorithm with the dynamically generated IV and Key. The resulting Ciphertext is then transmitted via Direct Memory Access (DMA).

## Module Specifications & Control Signals

* **AES Activation:** The AES module remains in an idle state and is only triggered via a physical button interface routed through the MUX module.
* **SHAKE128 Data Integrity:** To ensure data validity and integrity, the input signals of the SHAKE128 module are strictly gated by two control conditions: i_valid and i_last.
* **Synchronization:** An i_ack (acknowledge) signal is utilized across the system to confirm the successful reception of new data blocks.
* **Ed25519 Inputs:** The module requires a 256-bit key (sourced from Buffer 3) and a 256-bit Message input defined by the user environment.

## Simulation Results

The following log demonstrates the functional verification of the AES and SHAKE128 integrated flow during a 1000ns testbench run. The system successfully transitions modes, validates the SHAKE output, and executes AES encryption.

```text
# run 1000ns
Time:                    0 | Mode: 0 | Key: 00000000000000000000000000000000 | AES Out: 66e94bd4ef8a2c3b884cfa59ca342b2e
Time:               325000 | Mode: 1 | Key: 00000000000000000000000000000000 | AES Out: 66e94bd4ef8a2c3b884cfa59ca342b2e
SHAKE Output Valid! Generated Key: 00000000000000000000000000000000
Pressing Button to start AES Encryption...
Time:               405000 | Mode: 1 | Key: 1489b8afa13506c13ca9beb999a31ec5 | AES Out: 92cc662c07e66c66f9a5ebcbd7c9f3bc
Time:               445000 | Mode: 1 | Key: 00000000000000000000000000000000 | AES Out: 66e94bd4ef8a2c3b884cfa59ca342b2e
AES Ciphertext Result: 66e94bd4ef8a2c3b884cfa59ca342b2e
