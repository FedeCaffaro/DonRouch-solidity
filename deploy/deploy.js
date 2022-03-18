const { getNamedAccounts, deployments, network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../deploy-helpers/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments
  const { deployer,secondDeployer } = await getNamedAccounts()
  log("----------------------------------------------------")
  log("Deploying DonRouch and waiting for confirmations...")
  let blockConfirmations = 0
  if (network.name != "localhost" && network.name != "hardhat") {
    blockConfirmations = 6
  }
  const paymentProcessor = await deploy("DonRouch", {
    from: deployer,
    args: ["https://samotclub.mypinata.cloud/ipfs/QmeLn1Vx2FLMQypLPqQfohYqEt4kJnUx5DUpc3pmwGU85w/{id}.json","DonRouch","DR"],
    log: true,
    // we need to wait if on a live network so we can verify properly
    // waitConfirmations: blockConfirmations,
  })
  log(`DonRouch deployed at ${paymentProcessor.address}`)

  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    await verify(paymentProcessor.address, ["https://samotclub.mypinata.cloud/ipfs/QmeLn1Vx2FLMQypLPqQfohYqEt4kJnUx5DUpc3pmwGU85w/{id}.json","DonRouch","DR"])
  }
}

module.exports.tags = ["all", "paymentProcessor"]
