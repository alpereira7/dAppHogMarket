// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const HogMarket = await hre.ethers.getContractFactory("SimpleHogMarket");
  const hogMarket = await HogMarket.deploy('0x5fbdb2315678afecb367f032d93f642f64180aa3', '0x5FC8d32690cc91D4c39d9d3abcBD16989F875707');

  await hogMarket.deployed();

  console.log("HogMarket deployed to:", hogMarket.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });