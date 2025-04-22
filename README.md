# ZK-VRF with EdDSA in zk-SNARK (⚠️WIP!)


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

## Solidity Interface

The ZK-VRF system exposes a simple interface for generating and verifying random values:

```solidity
interface IZKVRF {
    /// @notice Request a random value for a given input
    /// @param input The input to generate randomness for
    /// @return requestId Unique identifier for this randomness request
    function requestRandomness(bytes32 input) external returns (uint256 requestId);

    /// @notice Submit a proof for a randomness request
    /// @param requestId The ID of the randomness request
    /// @param proof The zk-SNARK proof in Groth16 format (256 bytes)
    /// @param publicInputs The public inputs to the circuit [pk_x, pk_y, msg, ctx, comm]
    function submitProof(uint256 requestId, bytes calldata proof, uint256[] calldata publicInputs) external;

    /// @notice Get the random value for a completed request
    /// @param requestId The ID of the randomness request
    /// @return The generated random value
    function getRandomValue(uint256 requestId) external view returns (bytes32);
}
```

The interface supports asynchronous randomness generation with request IDs. The proof must be provided in Groth16 format with the following structure:
- Point A (G1): 64 bytes
- Point B (G2): 128 bytes
- Point C (G1): 64 bytes

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

## License

Apache 2.0 
