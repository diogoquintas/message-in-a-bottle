const deploy = require("./deploy");

async function main() {
  const render = await deploy({
    name: "TextCapsuleRender",
  });
  const main = await deploy({
    name: "TextCapsule",
    args: render.address,
  });

  console.log("Addresses:", {
    render: render.address,
    main: main.address,
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
