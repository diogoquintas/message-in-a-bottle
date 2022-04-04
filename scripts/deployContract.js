const deploy = require("./deploy");

async function main() {
  await deploy({
    name: "TextCapsule",
    args: process.env.RENDER_ADDRESS,
    factoryOptions: {
      libraries: {
        Dates: process.env.DATES_ADDRESS,
      },
    },
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
