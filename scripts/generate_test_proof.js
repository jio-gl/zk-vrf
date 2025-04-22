const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");
const { Scalar, F1Field } = require("ffjavascript");
const { buildPoseidon } = require("circomlibjs");
const { buildBabyjub } = require("circomlibjs");
const { buildEddsa } = require("circomlibjs");

const Fr = new F1Field(Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617"));

function buffer2bits(buff) {
    const res = [];
    for (let i = 0; i < buff.length; i++) {
        for (let j = 7; j >= 0; j--) {
            res.push((buff[i] >> j) & 1);
        }
    }
    return res;
}

function buffer2bitsLE(buff) {
    const res = new Array(256).fill(0);
    for (let i = buff.length - 1; i >= 0; i--) {
        for (let j = 0; j < 8; j++) {
            res[i * 8 + j] = (buff[i] >> j) & 1;
        }
    }
    return res;
}

function uint8ArrayToBits(arr) {
    const bits = [];
    for (let i = 0; i < arr.length; i++) {
        for (let j = 0; j < 8; j++) {
            bits.push((arr[i] >> j) & 1);
        }
    }
    return bits;
}

function pointToBits(point) {
    const bits = new Array(256).fill(0);
    
    // Convert y-coordinate to bits (first 254 bits)
    const yBits = uint8ArrayToBits(point[1]);
    for (let i = 0; i < 254; i++) {
        bits[i] = yBits[i];
    }
    
    // bit 254 must be 0
    bits[254] = 0;
    
    // sign of x-coordinate in bit 255
    const xBits = uint8ArrayToBits(point[0]);
    bits[255] = xBits[0]; // Use LSB as sign bit
    
    return bits;
}

function scalarToBits(s) {
    const bits = new Array(256).fill(0);
    const n = BigInt(Fr.e(s).toString());
    for (let i = 0; i < 256; i++) {
        bits[i] = Number((n >> BigInt(i)) & 1n);
    }
    return bits;
}

function numberToBits(n, length) {
    const bits = [];
    const value = typeof n === 'bigint' ? n : BigInt(n.toString());
    
    for (let i = 0; i < length; i++) {
        // Work from most significant bit to least
        const bitPosition = BigInt(length - 1 - i);
        const mask = 1n << bitPosition;
        bits.push(Number((value & mask) ? 1n : 0n));
    }
    
    return bits;
}

async function main() {
    const babyJub = await buildBabyjub();
    const eddsa = await buildEddsa();
    const poseidon = await buildPoseidon();
    const F = babyJub.F;

    // Generate message (10 bytes = 80 bits)
    const msg = BigInt(123);
    const ctx = BigInt(456);
    const msgHash = poseidon.F.toString(poseidon([msg, ctx]));
    const msgBits = numberToBits(msgHash, 80);
    console.log("Message bits length:", msgBits.length);
    
    // Generate key pair
    const prvKey = Buffer.from("0001020304050607080900010203040506070809000102030405060708090001", "hex");
    const pubKey = eddsa.prv2pub(prvKey);
    console.log("Public key:", pubKey);
    
    // Sign message
    const signature = eddsa.signMiMC(prvKey, msgHash);
    console.log("Signature:", signature);
    
    // Verify signature
    const isValid = eddsa.verifyMiMC(msgHash, signature, pubKey);
    console.log("Signature valid:", isValid);
    
    // Convert field elements to strings to avoid BigInt issues
    const input = {
        msg: msgBits,
        A: [F.toObject(pubKey[0]).toString(), F.toObject(pubKey[1]).toString()],
        R8: [F.toObject(signature.R8[0]).toString(), F.toObject(signature.R8[1]).toString()],
        S: F.toObject(signature.S).toString()
    };
    
    // Write input to file
    fs.writeFileSync('input.json', JSON.stringify(input));
    
    // Generate witness and proof
    execSync('node build/vrf_js/generate_witness.js build/vrf_js/vrf.wasm input.json witness.wtns');
    execSync('snarkjs groth16 prove build/vrf.zkey witness.wtns proof.json public.json');
    execSync('snarkjs groth16 verify build/verification_key.json public.json proof.json');
}

main().then(() => {
    console.log("Done");
}).catch((err) => {
    console.error(err);
}); 