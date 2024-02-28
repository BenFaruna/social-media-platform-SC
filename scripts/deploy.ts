import { ethers } from "hardhat";

async function main() {

  const socialMediaFactory = await ethers.deployContract("SocialMediaFactory");

  await socialMediaFactory.waitForDeployment();

  const createSocialMediaTx = await socialMediaFactory.createSocialMedia("Admin");
  createSocialMediaTx.wait();

  console.log(
    `SocialMediaFactory deployed to ${socialMediaFactory.target}\n
    SocialMedia deployed to ${await socialMediaFactory.getLastSocialMedia()}\n`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
