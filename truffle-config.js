/*
 * NB: since truffle-hdwallet-provider 0.0.5 you must wrap HDWallet providers in a 
 * function when declaring them. Failure to do so will cause commands to hang. ex:
 * ```
 * mainnet: {
 *     provider: function() { 
 *       return new HDWalletProvider(mnemonic, 'https://mainnet.infura.io/<infura-key>') 
 *     },
 *     network_id: '1',
 *     gas: 4500000,
 *     gasPrice: ,
 *   },
 */

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
};

var HDWalletProvider = require("truffle-hdwallet-provider");

module.exports = {
    optimizer: {
        enabled: true,
        runs: 200
    },
    mocha: {
        enableTimeouts: true
    },
    networks: {
        development: {
            host: "127.0.0.1",
            port: 8545,
            network_id: "*" // Match any network id
        },
        ropsten: {
            provider: () => new HDWalletProvider("naive ride judge carry summer fury cruel negative sugar female system hunt", "https://ropsten.infura.io/S8sXDq6KGrjLO4ckZK2X"),
            network_id: 3,
            gas: 47e5,
            gasPrice: 40e9
        }
    }
};