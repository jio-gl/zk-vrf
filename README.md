# ZK-VRF with EdDSA in zk-SNARK

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Foundry](https://img.shields.io/badge/Built%20with-Foundry-FF6943.svg)](https://getfoundry.sh)

A Zero-Knowledge Verifiable Random Function implementation using EdDSA signatures in zk-SNARK circuits.

## Features

- 🛡️ zk-SNARK-based VRF with EdDSA signatures
- 🔗 EVM-compatible smart contract integration
- 🧪 Comprehensive test coverage
- 📊 Gas optimization and constraint profiling

## Installation

1. Install dependencies:
```bash
npm install
forge install
```

2. Install circom & snarkjs:
```bash
npm install -g circom snarkjs
```

## Usage

1. Compile the circuit:
```bash
circom circuits/vrf.circom --r1cs --wasm --sym
```

2. Generate proofs:
```bash
snarkjs groth16 setup vrf.r1cs pot12_final.ptau circuit.zkey
```

3. Run tests:
```bash
forge test
```

## Security

⚠️ **Warning**: This is experimental software. Use at your own risk. 

Security considerations:
- Proper ZKP trusted setup ceremony
- Private key management
- Nullifier set maintenance

## License

MIT 