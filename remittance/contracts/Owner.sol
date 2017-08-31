pragma solidity ^0.4.6;


contract Owner {
  address owner;
  function Owner() {
      owner = msg.sender
  }
}
