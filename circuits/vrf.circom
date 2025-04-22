pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/eddsaposeidon.circom";

template VRF() {
    // Public inputs
    signal input Ax;          // Public key x coordinate
    signal input Ay;          // Public key y coordinate
    signal input R8x;         // R8 point x coordinate
    signal input R8y;         // R8 point y coordinate
    signal input S;           // Signature scalar
    signal input M;           // Message as field element

    // Outputs
    signal output out[254];   // VRF output in bits

    // EdDSA Poseidon verifier component
    component verifier = EdDSAPoseidonVerifier();
    
    // Connect inputs to verifier
    verifier.enabled <== 1;
    verifier.Ax <== Ax;
    verifier.Ay <== Ay;
    verifier.R8x <== R8x;
    verifier.R8y <== R8y;
    verifier.S <== S;
    verifier.M <== M;

    // Calculate VRF output using Poseidon hash
    component poseidon = Poseidon(3);
    
    // Hash R8x and S together
    poseidon.inputs[0] <== R8x;  // Use x-coordinate
    poseidon.inputs[1] <== S;
    poseidon.inputs[2] <== 0;  // Padding
    
    // Convert hash output to bits
    component num2bits = Num2Bits(254);
    num2bits.in <== poseidon.out;
    
    // Set outputs
    for (var i = 0; i < 254; i++) {
        out[i] <== num2bits.out[i];
    }
}

component main = VRF(); 