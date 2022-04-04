const deploy = require("./deploy");

async function main() {
  await deploy({ name: "Dates" });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
