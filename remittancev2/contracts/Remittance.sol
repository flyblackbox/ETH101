pragma solidity ^0.4.6;

import "./Stoppable.sol";

contract Remittance is Stoppable {
  uint maxDeadline;
  uint tipToCreator;

  //Establish the fee upon deploy with constructor
  function Remittance() {
    maxDeadline = 10;
    tipToCreator = 1; //I don't know how to define gasCostFrom deploy.. Can it be done dynamically?
  }

  //A struct to keep track of exchanges details
  struct Exchange{
    uint fee;                 //How much does this exchange charge?
    uint feeBalance;          //How much fees has this exchanged earned?
    bytes32 geoLocation;         //Where is this exchange physically located?
  }

  //All available exchanges mapped by their address (may have different physical locations and rates)
  mapping(address => Exchange) exchangeDirectory;


  //Log when a fee is set, value is sent, value is collected, fee is withdrawn, refund is made, contract is killed
  event LogSetFees(uint newFee);
  event LogSend(address origin, address destination, uint deadlineBlock, uint amount);
  event LogCollection(address collector, bytes32 keyHash);
  event LogFeeWithdraw(address withdrawer, uint withrawAmount);
  event LogRefund(address refundee, bytes32 amountRefunded);
  event LogKillSwitch();


  function becomeExchange (uint fee, bytes32 geoCoord)
    public{
      exchangeDirectory[msg.sender] = Exchange({
        fee: fee,
        feeBalance: 0,
        geoLocation: geoCoord
      });
  }

  //Exchanges can change their fee in order to compete for customers
  function changeExchangeFee(uint newFee)
  public
  returns(bool) {
    exchangeDirectory[msg.sender].fee = newFee;
    LogSetFees(newFee);
    return true;
  }

  //A struct to keep track of transaction details
  struct Transaction{
    uint amount;        //How much was sent?
    address exchangeAddress;  //What is the exchange address?
    address origin;     //Who sent the value?
    uint fee;           //What was the fee at the time the transfer was sent?
    uint deadlineBlock; //When does the transfer have to be withdrawn by?
  }

  //All transactions mapped by their keyHash (receiver address & passwords provided by sender hashed)
  mapping(bytes32 => Transaction) remittanceBook;

  //Send ETH to Exchange for receiver rendezvous
  //Require sender to provide the hash of a passwords and the exchange's address
  //Require sender to send one password to receiver by mail
  //Hashing must happen locally before being sent to contract
  //Front end will make this seemless for the sender's convenience
  //They just elect an exchange and add a password, hash client side
  function sendToExchange(address receivingExchange, bytes32 keyHash, uint deadline)
  public
  isRunning
  payable{
    //Transaction must:
    require(msg.value > 0);   //have a value
    require(msg.value > exchangeDirectory[receivingExchange].fee + tipToCreator); //value must outweigh the fee
    require(deadline <= block.number + maxDeadline); //have a deadline that does not exceed the deadline max
    require(remittanceBook[keyHash].exchangeAddress == 0); //not have the same passwords as any other
    //Create a new transaction struct and add it to the book of transactions
    remittanceBook[keyHash] = Transaction({
      origin: msg.sender,
      exchangeAddress: receivingExchange,
      amount: msg.value - exchangeDirectory[receivingExchange].fee - tipToCreator,
      fee: exchangeDirectory[receivingExchange].fee,
      deadlineBlock: block.number + deadline
      });

    //Add the fee to the exchanges balance
    exchangeDirectory[receivingExchange].feeBalance += exchangeDirectory[receivingExchange].fee;
    //Tip the creator of the contract less than gas cost of deploying
    owner.transfer(tipToCreator);
    LogSend(msg.sender, receivingExchange, deadline, msg.value);
    }

  event LogSend(address origin, address destination, uint deadlineBlock, uint amount);


    //Exchange can see how many fees they have collected
    function checkFees()
    public
    constant
    returns(uint){
      return exchangeDirectory[msg.sender].feeBalance;
    }

    //Exchange can withdraw the fees collected
    function withdrawFees()
    public
    isRunning{
      uint value = exchangeDirectory[msg.sender].feeBalance;
      exchangeDirectory[msg.sender].feeBalance = 0;
      msg.sender.transfer(value);
      LogFeeWithdraw(msg.sender, value);
    }

    //Anyone can check the balance of a remittance via the key hash
    //Only the sender has this, until recepient and exchange meet
    function checkRemitanceBalance(bytes32 keyHash)
    public
    constant
    returns(uint){
      return remittanceBook[keyHash].amount;
    }

    //Allow the exchanger to collect (must be with receiver for password)
    //They can now convert and hand to receiver
    //Enter the password into front end
    //Front end hashes the password and collector's address before call
    function collect(bytes32 keyHash)
    public{
      require(remittanceBook[keyHash].amount > 0);
      uint value = remittanceBook[keyHash].amount;
      remittanceBook[keyHash].amount = 0;
      msg.sender.transfer(value);
      LogCollection(msg.sender, keyHash);
    }

    //Refund owner if ether isn't claimed before deadline
    function refund(bytes32 keyHash)
    public{
      require(remittanceBook[keyHash].amount > 0);
      require(remittanceBook[keyHash].origin == msg.sender);
      require(block.number > remittanceBook[keyHash].deadlineBlock);
      uint value = remittanceBook[keyHash].amount;
      remittanceBook[keyHash].amount = 0;
      msg.sender.transfer(value);
      LogRefund(msg.sender, keyHash);
      }

    //Only the owner can terminate the contract
    function killSwitch()
    public
    onlyOwner {
      LogKillSwitch();
      selfdestruct(owner);
    }
  }
