const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const { Scalar } = require("ffjavascript");

const buildEddsa = require("circomlibjs").buildEddsa;
const buildBabyjub = require("circomlibjs").buildBabyjub;
const buildPoseidon = require("circomlibjs").buildPoseidon;

const assert = chai.assert;

// Helper functions from official tests
const fromHexString = hexString =>
  new Uint8Array(hexString.match(/.{1,2}/g).map(byte => parseInt(byte, 16)));

describe("VRF test", function () {
    let circuit;
    let eddsa;
    let babyJub;
    let F;
    let poseidonInstance;

    this.timeout(100000);

    before(async () => {
        eddsa = await buildEddsa();
        babyJub = await buildBabyjub();
        F = babyJub.F;
        poseidonInstance = await buildPoseidon();

        circuit = await wasm_tester(path.join(__dirname, "..", "circuits", "vrf.circom"));
    });

    it("Verify valid VRF proof with official test values", async () => {
        // Use the same private key as in the official test
        const prvKey = Buffer.from("0001020304050607080900010203040506070809000102030405060708090001", "hex");
        const pubKey = eddsa.prv2pub(prvKey);

        // Use the same message as in the official test
        const msgBuf = fromHexString("000102030405060708090000");
        const msg = eddsa.babyJub.F.e(Scalar.fromRprLE(msgBuf, 0));

        // Sign the message using Poseidon
        const signature = eddsa.signPoseidon(prvKey, msg);
        
        // Generate test input matching circuit signal names
        const input = {
            Ax: F.toString(pubKey[0]),
            Ay: F.toString(pubKey[1]),
            R8x: F.toString(signature.R8[0]),
            R8y: F.toString(signature.R8[1]),
            S: signature.S.toString(),
            M: F.toString(msg)
        };
        
        // Calculate witness
        const w = await circuit.calculateWitness(input, true);
        
        // Check constraints
        await circuit.checkConstraints(w);
    });

    it("Detect invalid VRF proof", async () => {
        // Use the same private key as in the official test
        const prvKey = Buffer.from("0001020304050607080900010203040506070809000102030405060708090001", "hex");
        const pubKey = eddsa.prv2pub(prvKey);

        // Use the same message as in the official test
        const msgBuf = fromHexString("000102030405060708090000");
        const msg = eddsa.babyJub.F.e(Scalar.fromRprLE(msgBuf, 0));

        // Sign the message using Poseidon
        const signature = eddsa.signPoseidon(prvKey, msg);
        
        // Modify R8x to make it invalid
        const invalidR8x = F.add(signature.R8[0], F.e(1));
        
        // Generate test input matching circuit signal names
        const input = {
            Ax: F.toString(pubKey[0]),
            Ay: F.toString(pubKey[1]),
            R8x: F.toString(invalidR8x),
            R8y: F.toString(signature.R8[1]),
            S: signature.S.toString(),
            M: F.toString(msg)
        };
        
        try {
            // Calculate witness with invalid R8x
            const w = await circuit.calculateWitness(input, true);
            assert(false, "Should have failed with invalid R8x");
        } catch(err) {
            assert(err.message.includes("Assert Failed"));
        }
    });
}); 