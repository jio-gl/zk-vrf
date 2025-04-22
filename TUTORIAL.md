# RandomBeacon Tutorial

This tutorial explains how to use the RandomBeacon contract, which implements a Verifiable Random Function (VRF) using zero-knowledge proofs and EdDSA signatures.

## Overview

The RandomBeacon contract provides a way to generate verifiable random numbers on-chain. It uses:
- EdDSA signatures for cryptographic operations
- zk-SNARKs for zero-knowledge proof verification
- A nullifier set to prevent commitment reuse

## Prerequisites

Before using the RandomBeacon, you need:
1. A compiled VRF circuit (using circom)
2. A deployed verifier contract for the VRF circuit
3. The necessary JavaScript libraries installed:
   ```bash
   npm install circomlibjs ffjavascript snarkjs
   ```

## Setup

1. Deploy the verifier contract first:
   ```javascript
   // Using Hardhat or Truffle
   const Verifier = await ethers.getContractFactory("Verifier");
   const verifier = await Verifier.deploy();
   await verifier.deployed();
   ```

2. Deploy the RandomBeacon contract:
   ```javascript
   const RandomBeacon = await ethers.getContractFactory("RandomBeacon");
   const randomBeacon = await RandomBeacon.deploy(verifier.address);
   await randomBeacon.deployed();
   ```

## Generating Random Numbers

To generate a verifiable random number, follow these steps:

1. Generate the VRF proof using the circuit:
   ```javascript
   // Using the generate_test_proof.js script
   const { execSync } = require("child_process");
   
   // Generate witness and proof
   execSync("node build/vrf_js/generate_witness.js build/vrf_js/vrf.wasm input.json witness.wtns");
   execSync("snarkjs groth16 prove build/vrf.zkey witness.wtns proof.json public.json");
   ```

2. Call the `generateRandom` function with the proof and inputs:
   ```javascript
   // Read proof and public inputs
   const proof = JSON.parse(fs.readFileSync("proof.json"));
   const publicInputs = JSON.parse(fs.readFileSync("public.json"));
   
   // Call the contract
   const tx = await randomBeacon.generateRandom(
     proof.pi_a,      // Proof part A
     proof.pi_b,      // Proof part B
     proof.pi_c,      // Proof part C
     publicInputs     // Public inputs array
   );
   
   // Wait for transaction confirmation
   const receipt = await tx.wait();
   
   // Get the random number from the event logs
   const event = receipt.events.find(e => e.event === "RandomGenerated");
   const randomNumber = event.args.vrfOutput;
   ```

## Important Notes

1. **Commitment Reuse**: Each commitment can only be used once. The contract maintains a nullifier set to track used commitments.

2. **Proof Verification**: The contract verifies the zk-SNARK proof before accepting the random number. Make sure your proof is valid and properly formatted.

3. **Public Inputs**: The contract expects 5 public inputs in this order:
   - `[0]`: EdDSA public key x-coordinate
   - `[1]`: EdDSA public key y-coordinate
   - `[2]`: Original message hash
   - `[3]`: Context identifier
   - `[4]`: VRF output commitment

4. **Gas Costs**: Generating random numbers requires significant gas due to the zk-SNARK verification. Ensure your transaction includes sufficient gas.

## Example Usage

Here's a complete example of generating a random number:

```javascript
const { ethers } = require("hardhat");
const fs = require("fs");
const { execSync } = require("child_process");

async function generateRandomNumber() {
  // 1. Generate the proof
  execSync("node build/vrf_js/generate_witness.js build/vrf_js/vrf.wasm input.json witness.wtns");
  execSync("snarkjs groth16 prove build/vrf.zkey witness.wtns proof.json public.json");
  
  // 2. Read proof and inputs
  const proof = JSON.parse(fs.readFileSync("proof.json"));
  const publicInputs = JSON.parse(fs.readFileSync("public.json"));
  
  // 3. Get contract instance
  const randomBeacon = await ethers.getContract("RandomBeacon");
  
  // 4. Generate random number
  const tx = await randomBeacon.generateRandom(
    proof.pi_a,
    proof.pi_b,
    proof.pi_c,
    publicInputs
  );
  
  const receipt = await tx.wait();
  const event = receipt.events.find(e => e.event === "RandomGenerated");
  return event.args.vrfOutput;
}
```

## Security Considerations

1. **Private Key Management**: Keep your EdDSA private key secure and never expose it.

2. **Commitment Uniqueness**: Ensure each commitment is unique to prevent replay attacks.

3. **Verifier Contract**: Use a trusted and audited verifier contract.

4. **Gas Limits**: Set appropriate gas limits for transactions involving proof verification.

## Troubleshooting

Common issues and solutions:

1. **"Commitment reused" error**: You're trying to use the same commitment twice. Generate a new proof with a unique commitment.

2. **"Invalid proof" error**: Your zk-SNARK proof is invalid. Check:
   - Proof generation process
   - Public input format
   - Circuit compilation
   - Verifier contract deployment

3. **Transaction reverts**: Ensure:
   - Sufficient gas
   - Correct proof format
   - Valid public inputs
   - Proper contract deployment

## Additional Resources

- [Circom Documentation](https://docs.circom.io/)
- [SnarkJS Documentation](https://github.com/iden3/snarkjs)
- [EdDSA Specification](https://ed25519.cr.yp.to/) 