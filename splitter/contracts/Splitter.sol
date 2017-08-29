pragma solidity ^0.4.4;


contract Splitter {

    address public owner;
    mapping(address => uint) balance;

//Establish the owner of the contract upon instantiation
    function Splitter() {
        owner = msg.sender;
    }

//Restrict functions to be used by the owner only
    modifier isOwner() {
        if (msg.sender == owner) _;
    }

//Setup event logs
    event LogSplit(address sender, address receiver1, address receiver2, uint amount, string _msg);
    event LogWithdrawn(address to, bool success, string _msg);
    event LogKillSwitch(string _msg);

//Create a payable function that splits value sent between two different accounts
    function split(address receiver1, address receiver2)
        public
        payable
        returns(bool) {

//Require value being sent to the function, and the existence of two addresses input by the owner
        require(msg.value > 0);
        require(receiver1 != 0 && receiver2 !=0);

//Split the value in half, and distribute it to each address
        balance[receiver1] += msg.value / 2;
        balance[receiver2] += msg.value / 2;

//Return the remainder to the owner
        if(msg.value % 2 == 1){
            balance[owner] += 1;
        }

        LogSplit(msg.sender, receiver1, receiver2, msg.value, "There has been a split");

        return true;
    }

//Let the public find the balance of the contract
    function getBalance(address rec)
        public
        constant
        returns(uint) {
        return balance[rec];
    }



    function withdraw()
        public
        returns(bool) {

//Check the balance of the person trying to withdraw
        uint amount = balance[msg.sender];

        require(amount > 0);

//should this balance be set to 0 before or after the transfer?
        balance[msg.sender] = 0;
        msg.sender.transfer(amount);
        LogWithdrawn(msg.sender, true, "Owner has withdrawn");

      return true;

    }


    function killSwitch()
        public
        isOwner {
                    LogKillSwitch("The contract is killed");
        suicide(owner);
    }

}
/*
contract Owned{
  function Owned{
//If I move the owner stuff here, how do I link it back to the other contract?
  }
}
