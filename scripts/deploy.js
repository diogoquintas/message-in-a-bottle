const { ethers, network } = require("hardhat");
const promptjs = require("prompt");

promptjs.message = "> ";
promptjs.delimiter = "";

async function deploy({ name, args, factoryOptions }) {
  let prompt;

  promptjs.start();

  const contractFactory = await ethers.getContractFactory(name, factoryOptions);

  let gasPrice = await ethers.provider.getGasPrice();

  if (network.name !== "rinkeby") {
    const gasInGwei = Math.round(
      Number(ethers.utils.formatUnits(gasPrice, "gwei"))
    );

    prompt = await promptjs.get([
      {
        properties: {
          gasPrice: {
            type: "integer",
            required: true,
            description: "Enter a gas price (gwei)",
            default: gasInGwei,
          },
        },
      },
    ]);

    gasPrice = ethers.utils.parseUnits(prompt.gasPrice.toString(), "gwei");
  }

  const deploymentGas = await contractFactory.signer.estimateGas(
    contractFactory.getDeployTransaction.apply(
      contractFactory,
      args ? [args, { gasPrice }] : [{ gasPrice }]
    )
  );
  const deploymentCost = deploymentGas.mul(gasPrice);

  console.log(
    `Estimated cost to deploy ${name}: ${ethers.utils.formatUnits(
      deploymentCost,
      "ether"
    )} ETH`
  );

  if (network.name !== "rinkeby") {
    prompt = await promptjs.get([
      {
        properties: {
          confirm: {
            type: "string",
            description: 'Type "DEPLOY" to confirm:',
          },
        },
      },
    ]);

    if (prompt.confirm !== "DEPLOY") {
      console.log("Exiting");
      return;
    }
  }

  console.log("Deploying...");

  const deployedContract = await contractFactory.deploy.apply(
    contractFactory,
    args ? [args, { gasPrice }] : [{ gasPrice }]
  );

  await deployedContract.deployed();

  console.log(`${name} contract deployed to ${deployedContract.address}`);

  return deployedContract;
}

module.exports = deploy;
