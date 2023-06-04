pragma solidity ^0.8.18;

// paybleが定義されたfunctionやaddressのみetherを受け取ることができる
contract Payable{
  address payable public owner;

  constructor() payable{
    owner = payable(msg.sender);
  }

  function deposit() public payable{}

  function withdraw() public{
    uint amount = address(this).balance;

    (bool success, ) = owner.call(value: amount)("");
    require(sucess, "failed to send Ether");
  }

  function transfer(address payable _to, uint _amount) public{
    (bool sucess, ) = _to.call(value: amount)(");
    require(sucess, "failed to send Ether");
  }
}