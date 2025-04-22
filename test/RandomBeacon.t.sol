// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;

import "../contracts/RandomBeacon.sol";
import "../contracts/Verifier.sol";

contract RandomBeaconTest {
    RandomBeacon beacon;
    Verifier verifier;
    
    constructor() public {
        // Deploy the verifier contract directly
        verifier = new Verifier();
        beacon = new RandomBeacon(address(verifier));
    }
    
    // TODO: Replace with actual proof data from the circuit
    function testRandomGeneration() public {
        // IMPORTANT: This test will fail until real proof data is provided
        // The following values are placeholders and will not pass verification
        uint[2] memory a = [uint(1), 2];
        uint[2][2] memory b = [[uint(3), 4], [uint(5), 6]];
        uint[2] memory c = [uint(7), 8];
        uint[5] memory inputs = [uint(9), 10, 11, 12, 13];
        
        // Generate random number using the proof
        bytes32 result = beacon.generateRandom(a, b, c, inputs);
        
        // Verify the result matches the VRF output from public inputs
        require(result == bytes32(inputs[3]), "VRF output mismatch");
    }
    
    // TODO: Replace with actual proof data from the circuit
    function testReusedCommitment() public {
        // IMPORTANT: This test will fail until real proof data is provided
        // The following values are placeholders and will not pass verification
        uint[2] memory a = [uint(1), 2];
        uint[2][2] memory b = [[uint(3), 4], [uint(5), 6]];
        uint[2] memory c = [uint(7), 8];
        uint[5] memory inputs = [uint(9), 10, 11, 12, 13];
        
        // First call should succeed
        beacon.generateRandom(a, b, c, inputs);
        
        // Second call with same commitment should fail
        bool failed;
        try beacon.generateRandom(a, b, c, inputs) {
            failed = false;
        } catch {
            failed = true;
        }
        require(failed, "Should revert on reused commitment");
    }
} 