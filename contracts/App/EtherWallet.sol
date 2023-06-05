// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract EtherWallet{
  address payable public owner;
  
  constructor(){
    owner = payable(msg.sender);
  }

  receive() external payable{}

  function withdrow(uint _amount) external{
    require(msg.sender == owner, 'caller is not owner');
    payable(msg.sender).transfer(_amount);
  }

  function getBalalance() external view returns(uint){
    return address(this).balance;
  }


}