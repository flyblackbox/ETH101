pragma solidity ^0.4.6;

contract Owner() {
  function Owner() {
      owner = tx.origin;
  }
}

contract Remitance(uint fee) {

    address owner;
    uint fee;
    uint feeBalance;
    bytes32 keyHash;

//Establish the owner, the fee, and the starting balance
    function Remittance(uint feeAmount) {
        owner = Owner.owner;
        fee = feeAmount;
        feeBalance = 0;
    }

//Create a struct to keep track of participants and critical details
    struct TransactionStruct {
        address origin; // Alice
        address destination; // Carol
        uint amount;
        uint deadlineBlock;
        //bool hasDeadline; Assume a deadline
    }

    mapping(bytes32 => TransactionStruct) remittanceBook;

    event LogSetFees(uint newFee);
    event LogWithdrawFees(uint balance);
    event LogSend(address origin, address destination, uint deadlineBlock, bytes32 keyHash);
    event LogCollect(bytes32 keyHash);
    event LogRefund(bytes32 keyHash);
    event LogKillSwitch();

//Restrict functions to the contract owner
    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function send(address destination, uint deadline)
        public
        payable
        returns(bool) {
    //Require the transaction to have a value, greater than the fee set.
            require(msg.value > fee);

            require(!remittanceBook[keyHash].amount = 0);
            remittanceBook[keyHash] = TransactionStruct({
                                        origin: msg.sender,
                                        destination: destination,
                                        amount: msg.value - fee,
                                        deadlineBlock: block.number + deadline,
                    //Deadline assumed  hasDeadline: deadline > 0,
                                        });

            feeBalance += fee;
            LogSend(msg.sender, dest, deadline, keyHash);

            return true;
    }

//Set the fee upon deployment, or change while live via public function
    function setFee(uint newFee)
        public
        restricted
        returns(bool) {
        fee = newFee;
        LogSetFees(newFee, "A new fee is set");
        return true;
    }

//Receive two passwords as inputs, hash them, and then has their hashes to create a keyHash
    function setPasswords(bytes32 firstPassword, bytes32 secondPassword) {
        keyHash = keccak256(firstPassword, secondPassword);
    }


//The public can see how much the owner has left in the contract to be collected
    function checkAccumulatedFees()
        public
        constant
        returns(uint){
        return feeBalance;
    }
}

//Only the owner can withdraw the fees collected
    function withdrawAccumulatedFees()
        public
        restricted
        returns(bool) {
		uint amount = feeBalance;

//If this is not the owner, revert. Otherwise send, reset the fee balance and log.
  		if(!owner.send(amount)) revert();

      feeBalance = 0;
      LogWithdrawFees(amount);
      return true;
    }

    function checkRemitanceBalance(bytes32 firstPassword, bytes32 secondPassword)
        constant
        returns(uint){
            keyHash = keccak256(firstPassword, secondPassword);
            return remittanceBook[keyHash].amount;
    }

    function collect(bytes32 firstPassword, bytes32 secondPassword)
        public
        returns(bool){

        keyHash = keccak256(firstPassword, secondPassword);

        require(remittanceBook[keyHash].destination == msg.sender &&
                remittanceBook[keyHash].amount > 0 &&
                );

        remittanceBook[keyHash].amount = 0;
    //if(!msg.sender.send(remitanceBook[keyHash].amount)) revert(); prefer transfer below?
    msg.sender.transfer(remittanceBook[keyHash].amount);

    LogCollect(keyHash);
    return true;

//Refund owner if ether isn't claimed
    function refund()
        returns(bool){

//Require
        require(remittanceBook[keyHash].origin == msg.sender &&
                remittanceBook[keyHash].amount > 0 &&
                );

      //Deadline is assumed  if(remittanceBook[keyHash].hasDeadline){}
        require(block.number > remittanceBook[keyHash].deadlineBlock);
		remittanceBook[keyHash].amount = 0;
//prefer transfer below? Instead of: if(!msg.sender.send(remitanceBook[keyHash].amount)) revert();
		msg.sender.transfer(remittanceBook[keyHash].amount);
		LogRefund(keyHash);
		return true;
    }

    function killSwitch()
        public
        restricted {
        LogKillSwitch();
        selfdestruct(owner);
    }

}
