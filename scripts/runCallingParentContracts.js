const main = async() => {
  const ContractAFactory = await hre.ethers.getContractFactory("A");
  const ContractA = await ContractAFactory.deploy();

  const ContractBFactory = await hre.ethers.getContractFactory("B");
  const ContractB = await ContractBFactory.deploy();

  const ContractCFactory = await hre.ethers.getContractFactory("C");
  const ContractC = await ContractCFactory.deploy();

  const ContractDFactory = await hre.ethers.getContractFactory("D");
  const ContractD = await ContractDFactory.deploy();
  
  console.log(' B ');
  await ContractB.foo();
  await ContractB.bar();

  console.log(' C ');
  await ContractC.foo();
  await ContractC.bar();

  console.log(' D ');
  await ContractD.foo();
  // C.forr called
  // A.foo called
  await ContractD.bar();
  // C.bar called
  // B.bar called
  // A.bar called
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