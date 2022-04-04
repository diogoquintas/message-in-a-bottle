const { task } = require("hardhat/config");

require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("render", "Render an example").setAction(async (_, { ethers }) => {
  const Contract = await ethers.getContractFactory("TextCapsuleRender");
  const contract = await Contract.attach(process.env.RENDER_ADDRESS);

  const tx = await contract.render(0, [
    "What could MongooseCoin do to CryptoCoin?",
    "Brad Sherman",
    Math.round(Date.now() / 1000),
    0,
    Math.round(Date.now() / 1000),
  ]);

  console.log(tx);
});

task("test", "Render an example").setAction(async (_, { ethers }) => {
  const Contract = await ethers.getContractFactory("Sandbox");
  const contract = await Contract.attach(process.env.SANDBOX_ADDRESS);

  const tx = await contract.getBorders(process.env.PRIVATE_KEY);

  console.log(tx);
});

task("getYear", "Dates.getYear()")
  .addParam("year", "Year in seconds")
  .setAction(async ({ year }, { ethers }) => {
    const Contract = await ethers.getContractFactory("Dates");
    const contract = await Contract.attach(process.env.DATES_ADDRESS);

    const tx = await contract.getYear(year);

    console.log(tx);
  });

task("parseDate", "Dates.parseDate()")
  .addParam("date", "Date in seconds")
  .setAction(async ({ date }, { ethers }) => {
    const Contract = await ethers.getContractFactory("Dates");
    const contract = await Contract.attach(process.env.DATES_ADDRESS);

    const tx = await contract.parseDate(date);

    console.log(tx);
  });

task("setRender", "Set the address for render").setAction(
  async (_, { ethers }) => {
    const Contract = await ethers.getContractFactory("TextCapsule", {
      libraries: {
        Dates: process.env.DATES_ADDRESS,
      },
    });
    const contract = await Contract.attach(process.env.CONTRACT_ADDRESS);

    const tx = await contract.setMetadataAddress(process.env.RENDER_ADDRESS);

    await tx.wait();
  }
);

task("mint", "Mint a text").setAction(async (_, { ethers }) => {
  const Contract = await ethers.getContractFactory("TextCapsule");
  const contract = await Contract.attach(process.env.CONTRACT_ADDRESS);

  const returnDate = Math.round(Date.now() / 1000) + 31536000;
  const tx = await contract.mint(
    "corruptions is first of its kind in so many ways that its very difficult to describe in a tweet beyond tweeting corruptions is first of its kind in so many ways that its very difficult to describe in a tweet",
    "dom",
    returnDate
  );

  await tx.wait();

  const totalSupply = await contract.totalSupply();
  const tokenId = totalSupply.toNumber() - 1;

  console.log({ tokenId });

  const metadata = await contract.tokenURI(tokenId);

  console.log(metadata);
});

task("send", "Send a text").setAction(async (_, { ethers }) => {
  const Contract = await ethers.getContractFactory("TextCapsule");
  const contract = await Contract.attach(process.env.CONTRACT_ADDRESS);

  const returnDate = Math.round(Date.now() / 1000) - 315360000;
  const tokenId = 0;
  const tx = await contract.send(
    tokenId,
    returnDate,
    "We're no strangers to love. You know the rules and so do I. A full commitment's what I'm thinking of. You wouldn't get this from any other guy.",
    "Rick Astley"
  );

  await tx.wait();

  const metadata = await contract.tokenURI(tokenId);

  console.log(metadata);
});

task("metadata", "Get token metadata")
  .addParam("tokenId", "The tokenId")
  .setAction(async ({ tokenId }, { ethers }) => {
    const Contract = await ethers.getContractFactory("TextCapsule", {
      libraries: {
        Dates: process.env.DATES_ADDRESS,
      },
    });
    const contract = await Contract.attach(process.env.CONTRACT_ADDRESS);

    const metadata = await contract.tokenURI(tokenId);

    console.log(metadata);
  });

task("renderAddress", "Get the render address").setAction(
  async (_, { ethers }) => {
    const Contract = await ethers.getContractFactory("TextCapsule", {
      libraries: {
        Dates: process.env.DATES_ADDRESS,
      },
    });
    const contract = await Contract.attach(process.env.CONTRACT_ADDRESS);

    const address = await contract.renderAddress();

    console.log(address);
  }
);

task("totalSupply", "Get the total supply").setAction(async (_, { ethers }) => {
  const Contract = await ethers.getContractFactory("TextCapsule");
  const contract = await Contract.attach(process.env.CONTRACT_ADDRESS);

  const totalSupply = await contract.totalSupply();

  console.log(totalSupply.toNumber());
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
