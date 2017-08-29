module.exports = {
  networks: {
    development: { // This one is optional and reduces the scope for failing fast
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    "net42": {
      host: "localhost",
      port: 8545,
      network_id: 42
    },
    "ropsten": {
      host: "localhost",
      port: 8545,
      network_id: 3
    }
  }
};
