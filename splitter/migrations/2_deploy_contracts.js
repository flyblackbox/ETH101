var ConvertLib = artifacts.require("./ConvertLib.sol");
var MetaCoin = artifacts.require("./Splitter.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, Splitter);
  deployer.deploy(Splitter);
};
