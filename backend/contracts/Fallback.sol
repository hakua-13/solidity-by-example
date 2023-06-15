// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// 存在しない関数が呼び出されたとき、
// etherが直接送金されreceive関数が定義されていない、msg.dataが空でないときfallbackが実行されれる
// fallbackがtransferやsendで呼び出された場合 2300gasの制限を持つ

contract Fallback{
  event Log(string func, uint gas);

// 必ず external
  fallback() external payable{
    // gasLeft(): 残ガス数を返す
    emit Log("fallback", gasleft());
  }

  receive() external payable{
    emit Log("receive", gasleft());
  }
}
contract SendToFallBack{
  function tranferToFallback(address payable _to) public payable{
    _to.transfer(msg.value);
  }
  function callFallback(address payable _to) public payable{
    (bool success, ) = _to.call{value: msg.value}("");
    require(success, "Failed to send Ether"); 
  }
}


// fallbackの入出力でbytesを受け取ることもできる
contract FallbackInputOutput{
  address immutable target;

  constructor(address _target){
    target = _target;
  }

  fallback(bytes calldata data) external payable returns(bytes memory){
    (bool success, bytes memory res) = target.call{value: msg.value}(data);
    require(success, "Failed to send Ether");
    return res;
  }
}