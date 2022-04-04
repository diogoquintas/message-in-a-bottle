const deploy = require("./deploy");

async function main() {
  await deploy({
    name: "TextCapsuleRender",
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
