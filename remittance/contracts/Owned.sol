pragma solidity ^0.4.6;

contract Owned {
  address public owner;
  event LogNewOwner (address oldOwner, address newOwner);

  function Owned() {
    owner = msg.sender;
  }

  modifier onlyOwner {
    if(msg.sender != owner) revert();
    _;
  }

  function changeOwner (address newOwner)
    onlyOwner
    returns(bool success){
      if (newOwner == 0) revert();
      LogNewOwner(owner, newOwner);
      owner = newOwner;
      return true;
    }



}
