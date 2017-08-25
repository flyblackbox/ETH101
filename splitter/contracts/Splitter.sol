pragma solidity ^0.4.6;

contract Splitter {

    address owner;

    mapping(address => uint) balance;

    modifier isOwner() {
        if (msg.sender == owner) _;
    }


    function Splitter() {
        owner = msg.sender;
    }

    event LogSplit(address sender, address rec1, address rec2, uint amount, string _msg);
    event LogWithdraw(address to, bool success, string _msg);
    event LogKillSwitch(string _msg);

    function split(address rec1, address rec2)
        public
        payable
        returns(bool) {

        require(msg.value > 0);

        balance[rec1] += msg.value / 2;
        balance[rec2] += msg.value / 2;

        if(msg.value % 2 == 1){
            balance[owner] += 1;
        }

        LogSplit(msg.sender, rec1, rec2, msg.value, "There has been a split");

        return true;
    }


    function getBalance(address rec)
        public
        constant
        returns(uint) {
        return balance[rec];
    }


    function withdraw()
        public
        returns(bool) {

        uint amount = balance[msg.sender];

        require(amount > 0);
        balance[msg.sender] = 0;
        msg.sender.transfer(amount);
        LogWithdraw(msg.sender, true, "Owner has withdrawn");

      return true;

    }


    function killSwitch()
        public
        isOwner {
                    LogKillSwitch("The contract is killed");
        suicide(owner);
    }

}
