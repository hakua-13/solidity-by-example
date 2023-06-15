const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers }  =require("hardhat")

describe(("IterableMapping"), () => {
  const deployFixture = async() => {

    const IterableMappingFactory = await ethers.getContractFactory("IterableMapping");
    const IterableMapping = await IterableMappingFactory.deploy();
    await IterableMapping.deployed();

    const [ owner, addr1 ] = await ethers.getSigners();
    const contractFactory = await ethers.getContractFactory("TestIterableMap", {
      libraries: {
        "IterableMapping": IterableMapping.address
      }
    });
    const contract = await contractFactory.deploy();
    await contract.deployed();

    return { contract, owner}
  }

  describe(("通常動作"), async() => {
    it("TestIterableMap", async() => {
      const { contract } = await loadFixture(deployFixture);

      const txn = await contract.testIterableMap();
    })
  })
})