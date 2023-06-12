const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers }  =require("hardhat")

describe("Multi-Sig wallet contract", () => {
  const deployFixture = async() => {
    const [owner, addr1, addr2, addr3, nonOwnerAddr] = await ethers.getSigners();
    const contractFactory = await ethers.getContractFactory("MultiSigWallet");
    const contract = await contractFactory.deploy(
      [owner.address, addr1.address, addr2.address],
      2
    );
    await contract.deployed();

    const data = ethers.utils.formatBytes32String("test#1")
    await contract.submitTransaction(addr1.address, 100, data);
    return {contract, owner, addr1, addr2, addr3, nonOwnerAddr};
  }

  describe(("submitTransaction()"), async() => {
    it("submitTransaction()", async() => {
      const { contract, addr1 } = await loadFixture(deployFixture);
  
      expect(await contract.getTransactionCount()).to.equal(1);
      await contract.submitTransaction(addr1.address, 100, 0);
  
      expect(await contract.getTransactionCount()).to.equal(2);
  
      const [to, value, , executed, numConfirmationsBefore] = await contract.getTransaction(0);
    })
  })

  describe(("confirmTransaction()"), async() => {
    it("通常処理", async() => {
      const { contract, addr1, addr2 } = await loadFixture(deployFixture);
  
      let [,,,, numConfirmations] = await contract.getTransaction(0);
      expect(numConfirmations).to.equal(0);
  
      await contract.confirmTransaction(0);
      [,,,, numConfirmations] = await contract.getTransaction(0);
      expect(numConfirmations).to.equal(1);

      await contract.connect(addr2).confirmTransaction(0);
      [,,,, numConfirmations] = await contract.getTransaction(0);
      expect(numConfirmations).to.equal(2);
    })

    it(("修飾子の確認"), async() => {
      const { contract, addr1, nonOwnerAddr }  = await loadFixture(deployFixture);

      await expect(contract.confirmTransaction(0)).not.to.be.revertedWith("tx already confirmed");
      await expect(contract.confirmTransaction(0)).to.be.revertedWith("tx already confirmed");

      await expect(contract.connect(nonOwnerAddr).confirmTransaction(0)).to.be.revertedWith("not owner");

      await expect(contract.confirmTransaction(1)).to.be.revertedWith("tx does not exist");
      
      // notExecutedの確認ができていない
    })
  })

  describe("revokeConfirmation", async() => {
    it("通常処理" , async() => {
      const { contract } = await loadFixture(deployFixture);

      await contract.confirmTransaction(0);
      const [,,,,numConfirmationsBefore] = await contract.getTransaction(0);
      expect(numConfirmationsBefore).to.equal(1);
      await contract.revokeConfirmation(0);
      const [,,,,numConfirmation] = await contract.getTransaction(0);
      expect(numConfirmation).to.equal(0);
    });
    it("isConfirmed", async() => {
      const { contract } = await loadFixture(deployFixture);

      await expect(contract.revokeConfirmation(0)).to.be.revertedWith("Not already confirmed");
    })

  })

  describe("executeTransaction", async() => {
    it("通常処理", async() => {
      const { contract, addr1 } = await loadFixture(deployFixture);

      await contract.confirmTransaction(0);
      await contract.connect(addr1).confirmTransaction(0);
      
      const [,,, executedBefore,] = await contract.getTransaction(0);
      expect(executedBefore).to.equal(false);
      await contract.executeTransaction(0);
      
      const [,,, executed, ] = await contract.getTransaction(0);
      expect(executed).to.equal(true);
    })
    it("numConfirmationsが2未満のとき", async() => {
      const { contract } = await loadFixture(deployFixture);

      await contract.confirmTransaction(0);
      await expect(contract.executeTransaction(0)).to.revertedWith("Not enough confirmation");
    })
  })

  describe("そのた実験", () => {
    const deployTestContractFixture = async() => {
      const testContractFactory = await ethers.getContractFactory("TestContract");
      const testContract = await testContractFactory.deploy();
      const testContractDeployed = await testContract.deployed();
      const testContractAddress = testContractDeployed.address;

      return { testContract, testContractAddress };
    }

    it("executeのdataに関数を渡す", async() => {
      const { contract } = await loadFixture(deployFixture);
      const { testContract, testContractAddress } = await loadFixture(deployTestContractFixture);

      console.log('testContractAddress: ', testContractAddress);
      
      let i = await testContract.getI();
      expect(i).to.equal(0);

      const data = testContract.interface.encodeFunctionData('callMe', [123]);

      const tx = await contract.execute(testContractAddress, 0, data);
      await tx.wait();

      i = await testContract.getI();
      expect(i).to.equal(123);
    })

    it("TransactionのdataにcallMe(uint256)を渡す", async() => {
      const { contract, addr1 } = await loadFixture(deployFixture);
      const { testContract, testContractAddress } = await loadFixture(deployTestContractFixture);
      const data = testContract.interface.encodeFunctionData('callMe', [779]);

      await contract.submitTransaction(testContractAddress, 0, data);
      await contract.confirmTransaction(1);
      await contract.connect(addr1).confirmTransaction(1);
      expect(await testContract.getI()).to.equal(0);
      await contract.executeTransaction(1);
      expect(await testContract.getI()).to.equal(779);
    })
  })

})