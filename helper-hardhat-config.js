const networkConfig = {
  31337: {
    name: "localhost",
  },
  1:{
    name : "mainnet",
  },
  4: {
    name: "rinkeby",
  },
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
  networkConfig,
  developmentChains,
}
