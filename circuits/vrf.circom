pragma circom 2.1.0;

include "node_modules/circomlib/circuits/eddsa.circom";
include "node_modules/circomlib/circuits/poseidon.circom";

template VRF() {
    // Public inputs
    signal input pk[2];
    signal input M;
    signal input ctx;
    signal input vrf_out;
    signal input comm;
    
    // Private inputs
    signal input sk;
    signal input R[2];
    signal input S;
    
    // EdDSA verification
    component verifier = EdDSAMiMCVerifier();
    verifier.enabled <== 1;
    verifier.Ax <== pk[0];
    verifier.Ay <== pk[1];
    verifier.R8x <== R[0];
    verifier.R8y <== R[1];
    verifier.S <== S;
    verifier.M <== M + ctx; // M' = M || ctx
    
    // VRF output calculation
    component hash = Poseidon(3);
    hash.inputs[0] <== R[0];
    hash.inputs[1] <== R[1];
    hash.inputs[2] <== S;
    vrf_out <== hash.out;
    
    // Commitment
    component commHash = Poseidon(2);
    commHash.inputs[0] <== vrf_out;
    commHash.inputs[1] <== ctx;
    comm <== commHash.out;
    
    // Public key consistency
    component pkVerifier = EdDSAMiMCKeyVerifier();
    pkVerifier.enabled <== 1;
    pkVerifier.Ax <== pk[0];
    pkVerifier.Ay <== pk[1];
    pkVerifier.S <== sk;
}

component main = VRF(); 