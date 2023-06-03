// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract A{
  event Log(string message);
  function foo() public virtual{
    emit Log("A.foo called");
    console.log("A.foo called");
  }

  function bar() public virtual{
    console.log("A.bar called");
  }
}

contract B is A{
  function foo() public virtual override{
    console.log("B.forr called");
    A.foo();
  }

  function bar() public virtual override{
    console.log("B.bar called");
    super.bar();
  }
}

contract C is A{
  function foo() public virtual override{
    console.log("C.forr called");
    A.foo();
  }

  function bar() public virtual override{
    console.log("C.bar called");
    super.bar();
  }
}

contract D is B, C{
  function foo() public override(B, C){
    super.foo();
  }

  function bar() public override(B, C){
    super.bar();
  }
}