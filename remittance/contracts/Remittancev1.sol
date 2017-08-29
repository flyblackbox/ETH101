pragma solidity ^0.4.6;

contract Remitance {

    address owner;
    uint fee;
    uint feeBalance;

    struct TransactionStruct {
        address origin; // Alice
        address destination; // Carol
        uint amount;
        uint deadlineBlock;
        bool hasDeadline;
        bool exists;
    }

    mapping(bytes32 => TransactionStruct) remitanceBook;

    event LogSetFees(uint newFee, string _msg);
    event LogWithdrawFees(uint balance, string _msg);
    event LogSend(address origin, address destination, uint deadlineBlock, bytes32 keyHash, string _msg);
    event LogCollect(bytes32 keyHash, string _msg);
    event LogRefund(bytes32 keyHash, string _msg);
    event LogKillSwitch(string _msg);

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function Remitance(uint feeAmount) {
        owner = msg.sender;
        fee = feeAmount;
        feeBalance = 0;
    }

    function setFee(uint newFee)
        public
        restricted
        returns(bool) {
        fee = newFee;
        LogSetFees(newFee, "A new fee is set");
        return true;
    }

    function checkAccumulatedFees()
        public
        constant
        returns(uint){
        return feeBalance;
    }

    function withdrawAccumulatedFees()
        public
        restricted
        returns(bool) {

		uint amount = feeBalance;
		feeBalance = 0;

		LogWithdrawFees(amount, "Fees have been withdrawn");

		if(!owner.send(amount)) revert();
        return true;
    }

    function send(address dest, uint deadline, bytes32 pwd1Hash, bytes32 pwd2Hash)
        public
        payable
        returns(bool) {

            require(msg.value > fee);

            bytes32 keyHash = calculateCombinedHash(pwd1Hash, pwd2Hash);

            require(!remitanceBook[keyHash].exists);

            remitanceBook[keyHash] = TransactionStruct({
                                        origin: msg.sender,
                                        destination: dest,
                                        amount: msg.value - fee,
                                        deadlineBlock: block.number + deadline,
                                        hasDeadline: deadline > 0,
                                        exists: true
                                        });

            feeBalance += fee;
            LogSend(msg.sender, dest, deadline, keyHash, "Transaction initiated");

            return true;
    }

    function calculateCombinedHash(bytes32 pwd1Hash, bytes32 pwd2Hash)
        constant
        returns(bytes32) {
        return keccak256(pwd1Hash, pwd2Hash);
    }

    function checkRemitanceBalance(bytes32 pwd1Hash, bytes32 pwd2Hash)
        constant
        returns(uint){
            bytes32 keyHash = calculateCombinedHash(pwd1Hash, pwd2Hash);
            return remitanceBook[keyHash].amount;
    }

    function collect(bytes32 pwd1Hash, bytes32 pwd2Hash)
        public
        returns(bool){

        bytes32 keyHash = calculateCombinedHash(pwd1Hash, pwd2Hash);

        require(remitanceBook[keyHash].destination == msg.sender &&
                remitanceBook[keyHash].amount > 0 &&
                remitanceBook[keyHash].exists
                );

        remitanceBook[keyHash].amount = 0;
		//if(!msg.sender.send(remitanceBook[keyHash].amount)) revert(); prefer transfer below?
		msg.sender.transfer(remitanceBook[keyHash].amount);

		LogCollect(keyHash, "Fee collected");
		return true;
    }

    function refund(bytes32 pwd1Hash, bytes32 pwd2Hash)
        returns(bool){

        bytes32 keyHash = calculateCombinedHash(pwd1Hash, pwd2Hash);

        require(remitanceBook[keyHash].origin == msg.sender &&
                remitanceBook[keyHash].amount > 0 &&
                remitanceBook[keyHash].exists
                );

        if(remitanceBook[keyHash].hasDeadline){
            require(block.number > remitanceBook[keyHash].deadlineBlock);
        }

		remitanceBook[keyHash].amount = 0;


		//if(!msg.sender.send(remitanceBook[keyHash].amount)) revert(); prefer transfer below?
		msg.sender.transfer(remitanceBook[keyHash].amount);

		LogRefund(keyHash, "Refund complete");
		return true;
    }


    function killSwitch()
        public
        restricted {
        LogKillSwitch("Contract killed");
        selfdestruct(owner);
    }

}
