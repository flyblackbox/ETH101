const Splitter = artifacts.require("./Splitter.sol");


contract('Splitter', function(accounts){
  var splitter;

  beforeEach (function() {
    return Splitter.deployed().then(function(instance){splitter = instance});
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
});
