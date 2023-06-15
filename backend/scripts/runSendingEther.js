const main = async() => {
  const [owner] = await hre.ethers.getSigners();
  const ReceiveContractFactory = await hre.ethers.getContractFactory('ReceiveEther');
  const ReceiveContract = await ReceiveContractFactory.deploy();
  const ReceiveContractDeploy = await ReceiveContract.deployed();

  const contractAddr = ReceiveContractDeploy.address;

  const hash = await owner.sendTransaction({
    to: contractAddr,
    value: 100
  })
  console.log(hash.hash);
}

const runMain = async() => {
  try{
    await main();
    process.exit(0);
  }catch(error){
    console.log(error);
    process.exit(1);
  }
}

runMain();