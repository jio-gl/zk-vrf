// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.11;

/// @title IZKVRF
/// @notice Interface for the ZK-VRF system using EdDSA signatures in zk-SNARK
interface IZKVRF {
    /// @notice Request a random value for a given input
    /// @param input The input to generate randomness for
    /// @return requestId Unique identifier for this randomness request
    function requestRandomness(bytes32 input) external returns (uint256 requestId);

    /// @notice Submit a proof for a randomness request
    /// @param requestId The ID of the randomness request
    /// @param proof The zk-SNARK proof
    /// @param publicInputs The public inputs to the circuit
    function submitProof(uint256 requestId, bytes calldata proof, uint256[] calldata publicInputs) external;

    /// @notice Get the random value for a completed request
    /// @param requestId The ID of the randomness request
    /// @return The generated random value
    function getRandomValue(uint256 requestId) external view returns (bytes32);
} 