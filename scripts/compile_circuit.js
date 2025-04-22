const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

async function compile() {
  try {
    // Create build directory if it doesn't exist
    if (!fs.existsSync("build")) {
      fs.mkdirSync("build", { recursive: true });
    }

    // Check if power of tau file exists
    if (!fs.existsSync("pot14_final.ptau")) {
      console.log("Power of tau file not found. Running setup...");
      execSync("npm run setup", { stdio: "inherit" });
    }

    // Compile the VRF circuit
    console.log("Compiling VRF circuit...");
    execSync(
      `circom circuits/vrf.circom --r1cs --wasm --sym --c --output build -l ${path.resolve(__dirname, "../node_modules/circomlib/circuits")}`,
      { stdio: "inherit" }
    );

    // Generate the proving key
    console.log("Generating proving key...");
    execSync(
      `snarkjs groth16 setup build/vrf.r1cs pot14_final.ptau build/vrf.zkey`,
      { stdio: "inherit" }
    );

    // Export the verification key
    console.log("Exporting verification key...");
    execSync(
      `snarkjs zkey export verificationkey build/vrf.zkey build/verification_key.json`,
      { stdio: "inherit" }
    );

    // Generate the Solidity verifier
    console.log("Generating Solidity verifier...");
    execSync(
      `snarkjs zkey export solidityverifier build/vrf.zkey build/verifier.sol`,
      { stdio: "inherit" }
    );

    // Copy verifier contract to contracts directory
    console.log("Copying verifier contract to contracts directory...");
    fs.mkdirSync("contracts", { recursive: true });
    fs.copyFileSync("build/verifier.sol", "contracts/Verifier.sol");

    console.log("✅ Circuit compilation completed successfully");
  } catch (error) {
    console.error("❌ Error compiling circuit:", error.message);
    process.exit(1);
  }
}

compile(); 