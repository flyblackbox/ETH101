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
