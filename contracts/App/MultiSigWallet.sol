// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// confirm: 確認
// revoke: 取り消す
// execute: 実行

contract MultiSigWallet{
  event Deposit(address indexed sender, uint amount, uint balance);
  event SubmitTransaction(
    address indexed owner,
    uint indexed txIndex,
    address indexed to,
    uint value,
    bytes data
  );
  event ConfirmTransaction(address indexed owner, uint indexed txIndex);
  event RevokeConfirmation(address indexed owner, uint indexed txIndex);
  event ExecuteTransaction(address indexed owner, uint indexed txIndex);

  address[] public owners;
  mapping(address => bool) public isOwner;
  uint public numConfirmationsRequired;

  struct Transaction{
    address to;
    uint value;
    bytes data;
    bool executed;
    uint numConfirmations;
  }

  mapping(uint => mapping(address => bool)) public isConfirmed;

  Transaction[] public transactions;

  modifier onlyOwner(){
    require(isOwner[msg.sender], "not owner");
    _;
  }

  modifier txExists(uint _txIndex){
    require(_txIndex < transactions.length, "tx does not exist");
    _;
  }

  modifier notExecuted(uint _txIndex){
    require(!transactions[_txIndex].executed, "tx already executed");
    _;
  }

  modifier notConfirmed(uint _txIndex){
    require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
    _;
  }

  constructor(address[] memory _owners, uint256 _numConfirmationsRequired){
    require(_owners.length > 0, "owners require");
    require(_numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length, "invalid number of required confirmation");

    for(uint256 i; i<_owners.length; i++){
      address owner = _owners[i];
      require(owner != address(0), "invalid address 0");
      require(!isOwner[owner], "already add address");
      owners.push(owner);
      isOwner[owner] = true;
    }

    numConfirmationsRequired = _numConfirmationsRequired;
  }

  receive() external payable{
    emit Deposit(msg.sender, msg.value, address(this).balance);
  }

  // txnの登録
  function submitTransaction(address _to, uint256 _amount, bytes memory _data) public onlyOwner{
    uint256 _txIndex = transactions.length;

    transactions.push(Transaction({
      to: _to,
      value: _amount,
      data: _data,
      executed: false,
      numConfirmations: 0
    }));
    
    emit SubmitTransaction(msg.sender, _txIndex, _to, _amount, _data);
  }
  // txnの確認
  function confirmTransaction(uint256 _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex){
    isConfirmed[_txIndex][msg.sender] = true;
    transactions[_txIndex].numConfirmations += 1;

    emit ConfirmTransaction(msg.sender, _txIndex);
  }
  // txnの実行 
  function executeTransaction(uint256 _txIndex) public onlyOwner txExists(_txIndex)  notExecuted(_txIndex) {
    Transaction storage transaction = transactions[_txIndex];
    require(transaction.numConfirmations >= numConfirmationsRequired, "Not enough confirmation");
    transaction.executed = true;

    (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
    emit ExecuteTransaction(msg.sender, _txIndex);
  }
  // 確認の取り消し
  function revokeConfirmation(uint256 _txIndex) public onlyOwner txExists(_txIndex) notExecuted(_txIndex){
    require(isConfirmed[_txIndex][msg.sender], "Not already confirmed");
    isConfirmed[_txIndex][msg.sender] = false;
    Transaction storage transaction = transactions[_txIndex];
    transaction.numConfirmations -= 1;

    emit RevokeConfirmation(msg.sender, _txIndex);
  }

  function getOwners() public view returns(address[] memory){
    return owners;
  }

  function getTransactionCount()public view returns(uint256){
    return transactions.length;
  }

  function getTransaction(uint256 _txIndex) public view txExists(_txIndex) returns(address, uint, bytes memory, bool, uint){
    Transaction memory txn = transactions[_txIndex];

    return(txn.to, txn.value, txn.data, txn.executed, txn.numConfirmations);
  }


  function execute(address payable contractAddress, uint256 value, bytes memory data ) public {

    (bool success, bytes memory data2) = contractAddress.call{value: value}(data);
  }
}

contract TestContract{
  uint public i;

  function callMe(uint j) public{
    i += j;
  }

  function getData() public pure returns(bytes memory){
    return abi.encodeWithSignature("callMe(uint256)", 123);
  }

  function getI() public view returns(uint){
    return i;
  }
}