readme_en_content = """# CRYPTO_SOC: Integrated Hardware Cryptographic System-on-Chip for Smart City Applications

The CRYPTO_SOC project is a comprehensive cryptographic hardware system designed and developed for the Urban Integrated Circuit Design Competition. The system integrates asymmetric encryption cores, Post-Quantum Cryptography (PQC), high-performance symmetric encryption, and a hardware true random number generator, providing an all-encompassing security solution for edge devices and central hubs within smart city infrastructures.

## Core Features

1. Post-Quantum Cryptography (PQC): Integrates the BIKE KEM Core (Bit-Flipping Key Encapsulation Mechanism) utilizing the SHAKE256 hash function, fully prepared to counteract security threats from quantum computing.
2. Advanced Digital Signature: Integrates the Elliptic Curve-based Ed25519 Core paired with the SHAKE128 hash function for robust authentication and data integrity verification.
3. Symmetric Encryption and Stream Security: Features the AES_CBC core supporting both Encryption and Decryption modes, operating synchronously with the password cryptographic encoder.
4. Pure Hardware Security: A True Random Number Generator (TRNG) supplies highly chaotic Initialization Vectors (IV) and Seed keys directly from hardware entropy sources.
5. Hardware Resource Optimization: Implements a Unified Keccak Core shared between both SHAKE128 and SHAKE256 hash functions to minimize the hardware area footprint on the chip.

## Overall System Architecture

The central control system utilizes a multiplexer (MUX) to separate operational configurations based on the incoming data stream mode.
