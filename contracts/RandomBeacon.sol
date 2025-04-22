// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IZKVRF.sol";

/**
 * @title Zero-Knowledge Verifiable Random Function Beacon
 * @dev Implements a VRF using zk-SNARKs for generating verifiable random numbers
 * with EdDSA signatures. Maintains a nullifier set to prevent commitment reuse.
 */
interface IVerifier {
    /**
     * @notice Verifies a zk-SNARK proof
     * @param a G1 point of the proof
     * @param b G2 point of the proof
     * @param c G1 point of the proof
     * @param input Public inputs to the circuit:
     *              [0] EdDSA public key x-coordinate
     *              [1] EdDSA public key y-coordinate
     *              [2] Message hash
     *              [3] Context identifier
     *              [4] VRF output commitment
     * @return bool True if proof is valid, false otherwise
     */
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[5] memory input
    ) external view returns (bool);
}

contract RandomBeacon is IZKVRF {
    /// @notice zk-SNARK verifier contract address
    IVerifier public immutable verifier;
    
    /// @notice Tracks used commitments to prevent reuse
    mapping(bytes32 => bool) public nullifiers;

    /// @notice Tracks randomness requests
    mapping(uint256 => bytes32) public randomnessRequests;
    
    /// @notice Counter for generating unique request IDs
    uint256 private _requestCounter;

    /**
     * @dev Deploys the RandomBeacon with a specific verifier
     * @param _verifier Address of the zk-SNARK verifier contract
     */
    constructor(address _verifier) {
        verifier = IVerifier(_verifier);
    }

    /**
     * @notice Request a random value for a given input
     * @param input The input to generate randomness for
     * @return requestId Unique identifier for this randomness request
     */
    function requestRandomness(bytes32 input) external override returns (uint256) {
        uint256 requestId = _requestCounter++;
        randomnessRequests[requestId] = input;
        return requestId;
    }

    /**
     * @notice Submit a proof for a randomness request
     * @param requestId The ID of the randomness request
     * @param proof The zk-SNARK proof
     * @param publicInputs The public inputs to the circuit
     */
    function submitProof(
        uint256 requestId,
        bytes calldata proof,
        uint256[] calldata publicInputs
    ) external override {
        require(publicInputs.length == 5, "Invalid public inputs length");
        require(proof.length >= 192, "Invalid proof length"); // 3 * 64 bytes (32 bytes per coordinate)
        
        // Convert proof bytes to Groth16 format
        // Each point is represented as 64 bytes (32 bytes per coordinate)
        uint[2] memory a;
        uint[2][2] memory b;
        uint[2] memory c;
        
        // Decode point A (G1 point)
        assembly {
            let proofPtr := add(proof.offset, 0)
            
            // Load point A (G1 point)
            mstore(a, calldataload(proofPtr))
            mstore(add(a, 32), calldataload(add(proofPtr, 32)))
            
            // Load point B (G2 point)
            mstore(b, calldataload(add(proofPtr, 64)))
            mstore(add(b, 32), calldataload(add(proofPtr, 96)))
            mstore(add(b, 64), calldataload(add(proofPtr, 128)))
            mstore(add(b, 96), calldataload(add(proofPtr, 160)))
            
            // Load point C (G1 point)
            mstore(c, calldataload(add(proofPtr, 192)))
            mstore(add(c, 32), calldataload(add(proofPtr, 224)))
        }
        
        // Convert publicInputs to fixed-size array
        uint[5] memory fixedInputs;
        for(uint i = 0; i < 5; i++) {
            fixedInputs[i] = publicInputs[i];
        }
        
        // Verify the proof
        require(verifier.verifyProof(a, b, c, fixedInputs), "Invalid proof");
        
        // Store the result
        bytes32 comm = bytes32(publicInputs[4]);
        require(!nullifiers[comm], "Commitment reused");
        nullifiers[comm] = true;
        randomnessRequests[requestId] = bytes32(publicInputs[3]);
    }

    /**
     * @notice Get the random value for a completed request
     * @param requestId The ID of the randomness request
     * @return The generated random value
     */
    function getRandomValue(uint256 requestId) external view override returns (bytes32) {
        bytes32 value = randomnessRequests[requestId];
        require(value != bytes32(0), "Request not found or not completed");
        return value;
    }

    /**
     * @notice Generates a new verifiable random number (legacy function)
     * @dev Uses zk-SNARK proof to verify VRF computation correctness
     * @param a Groth16 proof part A
     * @param b Groth16 proof part B
     * @param c Groth16 proof part C
     * @param input Public inputs to the circuit
     * @return vrfOutput The generated verifiable random number
     */
    function generateRandom(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[5] memory input
    ) public returns (bytes32) {
        bytes32 comm = bytes32(input[4]);
        
        // Ensure commitment hasn't been used
        require(!nullifiers[comm], "Commitment reused");
        
        // Verify zk-SNARK proof validity
        require(verifier.verifyProof(a, b, c, input), "Invalid proof");

        // Record commitment and return VRF output
        nullifiers[comm] = true;
        return bytes32(input[3]); // Return vrf_out from public inputs
    }
} 