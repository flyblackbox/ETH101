import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Splitter.sol";
const Splitter = artifacts.require("./Splitter.sol");


contract('Splitter', function(accounts){
  var contract;
  var goal = 1000;
  var duration = 10;
  var owner = accounts[0];


  beforeEach (function() {
    return Campaign.new(duration, goal, {from: owner})
    .then(function(instance){
      contract = instance;
    });
  });

  it("should X", function() {
    assert.strictEqual (true, true, "Something is wrong.");

  it(“should be owned by owner”, function(){
    return contract.owner({from: owner})
    .then(function(_owner) {
      assert.strictEqual(_owner, owner, “Contract is not owned by owner”);
    });
  });
});


/*
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

        //Add a test that calls split() and compares the before and after balances of Bob and Carol
});


    before("should run once before all in the scope", function() {});
    beforeEach("should run before each it() in the scope", function() {});

//test restrictons:
describe("testing user restriction", function() {
    beforeEach("deploy and prepare", function() {
        // Deploy a contract(s) and prepare it up
        // to the pass / fail point
    });

    it("test the failing user", function() {
        // Test something with the bad user
        // in as few steps as possible
    });

    it("test the good user", function() {
        // Test the VERY SAME steps,
        // with only difference being the good user
    });
});
*/
