const hre = require("hardhat");

async function main() {
  const Verifier = await hre.ethers.getContractFactory("Verifier");
  const verifier = await Verifier.deploy();
  
  const RandomBeacon = await hre.ethers.getContractFactory("RandomBeacon");
  const beacon = await RandomBeacon.deploy(verifier.address);
  
  console.log("Verifier deployed to:", verifier.address);
  console.log("RandomBeacon deployed to:", beacon.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); 