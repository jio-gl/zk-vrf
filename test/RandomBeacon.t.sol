// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/RandomBeacon.sol";
import "../contracts/Verifier.sol";

contract RandomBeaconTest is Test {
    RandomBeacon beacon;
    Verifier verifier;
    
    // Test data will be loaded from proof.json and public.json
    struct Proof {
        uint[2] a;
        uint[2][2] b;
        uint[2] c;
    }
    
    struct PublicInputs {
        uint[5] inputs;
    }
    
    function setUp() public {
        // Deploy the verifier contract directly
        verifier = new Verifier();
        beacon = new RandomBeacon(address(verifier));
    }
    
    function testRandomGeneration() public {
        // Load proof and public inputs from files
        string memory proofJson = vm.readFile("proof.json");
        string memory publicJson = vm.readFile("public.json");
        
        Proof memory proof = abi.decode(vm.parseJson(proofJson), (Proof));
        PublicInputs memory publicInputs = abi.decode(vm.parseJson(publicJson), (PublicInputs));
        
        // Generate random number using the proof
        bytes32 result = beacon.generateRandom(
            proof.a,
            proof.b,
            proof.c,
            publicInputs.inputs
        );
        
        // Verify the result matches the VRF output from public inputs
        assertEq(result, bytes32(publicInputs.inputs[3]), "VRF output mismatch");
    }
    
    function testReusedCommitment() public {
        // Load proof and public inputs
        string memory proofJson = vm.readFile("proof.json");
        string memory publicJson = vm.readFile("public.json");
        
        Proof memory proof = abi.decode(vm.parseJson(proofJson), (Proof));
        PublicInputs memory publicInputs = abi.decode(vm.parseJson(publicJson), (PublicInputs));
        
        // First call should succeed
        beacon.generateRandom(
            proof.a,
            proof.b,
            proof.c,
            publicInputs.inputs
        );
        
        // Second call with same commitment should fail
        vm.expectRevert("Commitment reused");
        beacon.generateRandom(
            proof.a,
            proof.b,
            proof.c,
            publicInputs.inputs
        );
    }
} 