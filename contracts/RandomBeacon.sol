// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

contract RandomBeacon {
    /// @notice zk-SNARK verifier contract address
    IVerifier public immutable verifier;
    
    /// @notice Tracks used commitments to prevent reuse
    mapping(bytes32 => bool) public nullifiers;

    /**
     * @dev Deploys the RandomBeacon with a specific verifier
     * @param _verifier Address of the zk-SNARK verifier contract
     */
    constructor(address _verifier) {
        verifier = IVerifier(_verifier);
    }

    /**
     * @notice Generates a new verifiable random number
     * @dev Uses zk-SNARK proof to verify VRF computation correctness
     * @param a Groth16 proof part A
     * @param b Groth16 proof part B
     * @param c Groth16 proof part C
     * @param input Public inputs to the circuit:
     *              [0] pk_x - EdDSA public key x-coordinate
     *              [1] pk_y - EdDSA public key y-coordinate
     *              [2] M    - Original message hash
     *              [3] ctx  - Context identifier
     *              [4] comm - VRF output commitment
     * @return vrfOutput The generated verifiable random number
     * 
     * @custom:requirements 
     * - Commitment must not have been used before
     * - zk-SNARK proof must be valid
     * 
     * @custom:effects 
     * - Stores commitment in nullifiers mapping
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