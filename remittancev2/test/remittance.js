const Remittance = artifacts.require("./Remittance.sol");

contract('Remittance', function(accounts){
  var remittance;

  beforeEach (function() {
    return Remittance.deployed()
    .then(function(instance){
      remittance = instance;
    });
  });


    it("should return remainder to owner", function(done){
      splitter.split(web3.eth.accounts[1], web3.eth.accounts[1], {
        value: 101,
        from: web3.eth.accounts[0]
      }).then(function(result){
        return splitter.getBalance.call(web3.eth.accounts[0]);
      }).then(function(balance){
        assert.equal(balance, 1);
        done();
      });
    });


  it("Should have a deadline", function() {
    assert.strictEqual (maxDeadline, 0, "Deadline was not set");
  });
});
/*
  it(“should have a deadline”, function(){
  	return contract.deadline({from: owner})
  	.then(function(_deadline) {
  	assert.equal(_deadline).toString(10), expectedDeadline, “Deadline is incorrect”);
  	});
  });


it("should do something and something else", function() {
    var instance;
    // You *need to return* the whole Promise chain
    return MyContract.deployed()
        .then(_instance => {
            instance = _instance;
            return instance.doSomething.call(arg1, { from: accounts[0] });
        })
        .then(success => {
            assert.isTrue(success, "failed to do something");
            return instance.doSomething(arg1, { from: accounts[0] });
        })
        .then(txInfo => {
            return instance.getSomethingElse.call();
        })
        .then(resultValue => {
            assert.equal(resultValue.toString(10), "3", "there should be exactly 3 things at this stage");
            // Do not return anything on the last callback or it will believe there is an error.
        });

        //Add a test that calls split() and compares the before and after balances of Bob and Carol*/
