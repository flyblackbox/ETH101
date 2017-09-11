var Owned = artifacts.require("../contracts/Owned.sol")
var Stoppable = artifacts.require("../contracts/Stoppable.sol");
var Remittance = artifacts.require("../contracts/Remittance.sol");


module.exports = function(deployer) {
  deployer.deploy(Owned);
  deployer.deploy(Stoppable);
  deployer.deploy(Remittance);
};
