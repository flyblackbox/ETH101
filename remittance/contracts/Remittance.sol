pragma solidity ^0.4.6;

contract Remitance is Owner {
    uint fee;
    uint feeBalance;
    bytes32 keyHash;

    //Establish the owner, the fee, and the starting balance
    function Remittance() {
        feeBalance = 0;
    }

    //Restrict some functions to the contract owner
    modifier isCarol() {
        if (msg.sender == owner) _;
    }

    //Create a struct to keep track of participants and critical details
    struct TransactionStruct {
        address origin;     //Who sent Carol the money?
        uint amount;        //How much was sent?
        unit fee;           //What was the fee at the time the transfer was sent?
        uint deadlineBlock; //When did the transfer have to be withdrawn by?
    }

    //Keep track of all remittance in a map
    mapping(bytes32 => TransactionStruct) remittanceBook;

    event LogSetFees(uint newFee);
    event LogSend(address origin, address destination, uint deadlineBlock);
    event LogCollection(bytes32 keyHash);
    event LogFeeWithraw(uint withrawAmount);
    event LogRefund(bytes32 keyHash);
    event LogKillSwitch();

    //Carol must set a fee after deployment, no fee is set by default. Can be changed.
    function setFee(uint newFee)
        public
        isCarol()
        returns(bool) {
        fee = newFee;
        LogSetFees(newFee);
        return true;
    }

    //Receive two passwords as inputs, hash them, and then has their hashes to create a keyHash
    function setSecureKeyHash(bytes32 firstPassword, bytes32 secondPassword) {
        keyHash = keccak256(firstPassword, secondPassword);
    }

    //Send ETH to Carol to convert for Bob.
    function sendToCarol(uint deadline, bytes32 firstPassword, bytes32 secondPassword)
        public
        payable{

            setSecureKeyHash(firstPassword, secondPassword);
            //Require the transaction to have a value, greater than the fee set.
            require(msg.value > fee);
            //Only allow one transfer at a time
            require(remittanceBook[keyHash].amount = 0); //Otherwise, new password must be set.
            remittanceBook[keyHash] = TransactionStruct({
                                        origin: msg.sender,
                                        amount: msg.value - fee,
                                        fee: fee,
                                        deadlineBlock: block.number + deadline,
                                        });

            feeBalance += fee;
            LogSend(msg.sender, deadline, keyHash);
    }


    //Carol can see how many fees she has collected
    function checkAccumulatedFees()
        public
        constant
        isCarol()
        returns(uint){
        return feeBalance;
    }
}

    //Only Carol can withdraw the fees collected
    function withdrawAccumulatedFees()
        public
        isCarol(){
          owner.transfer(feeBalance);
          LogFeeWithdraw(feeBalance);
          feeBalance = 0;
    }

    function checkRemitanceBalance(bytes32 firstPassword, bytes32 secondPassword)
        public
        constant
        returns(uint){
            setSecureKeyHash(firstPassword, secondPassword);
            return remittanceBook[keyHash].amount;
    }

    function collect(bytes32 firstPassword, bytes32 secondPassword)
        public
        isCarol(){
        setSecureKeyHash(firstPassword, secondPassword);

        require(remittanceBook[keyHash].amount > 0);

        carol.send(remittanceBook[keyHash].amount);
        remittanceBook[keyHash].amount = 0;
        LogCollection(keyHash);
    }

    //Refund owner if ether isn't claimed before deadline
    function refund(bytes32 firstPassword, bytes32 secondPassword)
        public{
        setSecureKeyHash(firstPassword, secondPassword);

        require(remittanceBook[keyHash].amount > 0);
        require(remittanceBook[keyHash].origin == msg.sender;
        require(block.number > remittanceBook[keyHash].deadlineBlock);
        msg.sender.transfer(remittanceBook[keyHash].amount);
        remittanceBook[keyHash].amount = 0;
        LogRefund(keyHash);
    }

    //Only the owner can terminate the contract
    function killSwitch()
        public
        isOwner {
        LogKillSwitch();
        selfdestruct(owner);
    }

}
