const chai = require("chai");
const { Scalar } = require("ffjavascript");
const buildEddsa = require("circomlibjs").buildEddsa;
const buildBabyjub = require("circomlibjs").buildBabyjub;

const assert = chai.assert;

// Helper functions from official tests
const fromHexString = hexString =>
  new Uint8Array(hexString.match(/.{1,2}/g).map(byte => parseInt(byte, 16)));

describe("EdDSA MiMC Input/Output Comparison", function () {
    let eddsa;
    let babyJub;
    let F;

    this.timeout(100000);

    before(async () => {
        eddsa = await buildEddsa();
        babyJub = await buildBabyjub();
        F = babyJub.F;
    });

    it("Compare EdDSA MiMC inputs and outputs", async () => {
        // Use the same private key as in the official test
        const prvKey = Buffer.from("0001020304050607080900010203040506070809000102030405060708090001", "hex");
        const pubKey = eddsa.prv2pub(prvKey);

        console.log("\nPublic Key Components:");
        console.log("Ax:", F.toString(pubKey[0]));
        console.log("Ay:", F.toString(pubKey[1]));

        // Use the same message as in the official test
        const msgBuf = fromHexString("000102030405060708090000");
        const msg = eddsa.babyJub.F.e(Scalar.fromRprLE(msgBuf, 0));
        
        console.log("\nMessage:");
        console.log("Raw Buffer:", Buffer.from(msgBuf).toString('hex'));
        console.log("As Field Element:", F.toString(msg));

        // Sign the message using MiMC
        const signature = eddsa.signMiMC(prvKey, msg);

        console.log("\nSignature Components:");
        console.log("R8x:", F.toString(signature.R8[0]));
        console.log("R8y:", F.toString(signature.R8[1]));
        console.log("S:", signature.S.toString());

        // Verify the signature
        const isValid = eddsa.verifyMiMC(msg, signature, pubKey);
        console.log("\nSignature Valid:", isValid);

        // Print values in format ready for circuit input
        console.log("\nCircuit Input Format:");
        const circuitInput = {
            Ax: F.toString(pubKey[0]),
            Ay: F.toString(pubKey[1]),
            R8x: F.toString(signature.R8[0]),
            R8y: F.toString(signature.R8[1]),
            S: signature.S.toString(),
            M: F.toString(msg)
        };
        console.log(circuitInput);

        // Add assertions to match official test values
        assert(F.eq(pubKey[0], F.e("13277427435165878497778222415993513565335242147425444199013288855685581939618")));
        assert(F.eq(pubKey[1], F.e("13622229784656158136036771217484571176836296686641868549125388198837476602820")));
        assert(F.eq(signature.R8[0], F.e("11384336176656855268977457483345535180380036354188103142384839473266348197733")));
        assert(F.eq(signature.R8[1], F.e("15383486972088797283337779941324724402501462225528836549661220478783371668959")));
        assert(Scalar.eq(signature.S, Scalar.e("2523202440825208709475937830811065542425109372212752003460238913256192595070")));
    });
}); 