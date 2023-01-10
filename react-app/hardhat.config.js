require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

task("verify", "Verify contract", async(taskArgs, hre) => {
  await hre.run("verify:verify", {
    address: "0xa0F92Df550E1E12452C250465E54fDF77B9cf64d"
  })
})

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  paths: {
    artifacts: './src/artifacts',
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    harmonyMainnet: {
      url: 'https://api.harmony.one',
      chainId: 1666600000
    }
  },
  etherscan: {
    apiKey: {
      harmony: ''
    }
  }
};
