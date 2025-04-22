# ZK-VRF with EdDSA in zk-SNARK (WIP!)


[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FF6943.svg)](https://getfoundry.sh)

This project implements a Verifiable Random Function (VRF) using EdDSA signatures in a zk-SNARK circuit. The implementation uses circom for circuit compilation and Foundry for smart contract testing.

## Prerequisites

- Node.js (v16+)
- Rust (for circom compilation)
- Foundry (for smart contract development)
- circom (built from source)

## Features

- 🛡️ zk-SNARK-based VRF with EdDSA signatures
- 🔗 EVM-compatible smart contract integration
- 🧪 Comprehensive test coverage
- 📊 Gas optimization and constraint profiling

## Design & Benefits

The ZK-VRF system combines EdDSA signatures with zk-SNARKs to create a verifiable random function that is both secure and efficient:

- **Privacy**: The VRF output is generated without revealing the private key or the randomness source
- **Verifiability**: Anyone can verify that the output was generated correctly using the public key
- **Uniqueness**: Each input produces a unique, deterministic output
- **Gas Efficiency**: zk-SNARKs provide compact proofs that are cheap to verify on-chain
- **Composability**: The system can be integrated with other ZK protocols and smart contracts

## Installation

1. Install Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Install circom from source:
```bash
# Install Rust if you haven't already
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Clone and build circom
git clone https://github.com/iden3/circom.git
cd circom
cargo build --release
cargo install --path circom
cd ..
```

3. Install project dependencies:
```bash
npm install
```

## Project Structure

- `circuits/`: Contains the circom circuit implementation
- `contracts/`: Contains the Solidity smart contracts
- `test/`: Contains the test files
- `scripts/`: Contains utility scripts for compilation and deployment

## Usage

1. Compile the circuit:
```bash
npm run compile
```

2. Run tests:
```bash
npm run test
```

3. Generate and verify proofs:
```bash
# Generate proof
npm run prove

# Verify proof
npm run verify
```

4. Deploy contracts:
```bash
npm run deploy
```

## Development

The project uses:
- circom v2.1.7 for circuit compilation
- Foundry for smart contract development and testing
- Hardhat for deployment

## Security

⚠️ **Warning**: This is experimental software. Use at your own risk. 

Security considerations:
- Proper ZKP trusted setup ceremony
- Private key management
- Nullifier set maintenance

## License

Apache 2.0 
