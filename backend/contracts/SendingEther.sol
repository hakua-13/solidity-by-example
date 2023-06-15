// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract ReceiveEther{
  // contractがetherを受け取る際に必要な関数
  // msg.dataが空の場合や、receive()が定義されていない場合 fallbacktが実行される
  receive() external payable{}
  fallback() external payable{}

  function getBalance() public view returns(uint){
    return address(this).balance;
  }
}

contract SendEther{
  function sendViaTransfer(address payable _to)public payable{
    _to.transfer(msg.value);
  }

  function sendViaSend(address payable _to) public payable{
    bool sent = _to.send(msg.value);
    require(sent, "Failed to send Ether");
  }

  function sendViaCall(address payable _to) public payable {
      (bool sent, bytes memory data) = _to.call{value: msg.value}("");
      require(sent, "Failed to send Ether");
  }
}