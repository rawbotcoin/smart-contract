var Rawbot = artifacts.require("./Rawbot.sol");
var DeviceSpawner = artifacts.require("./DeviceSpawner.sol");
var IPFS = artifacts.require("./IPFS.sol");

module.exports = function (deployer, network, accounts) {
    deployer.deploy(Rawbot, {
            from: accounts[0],
            value: 1e18 / 4
        })
        .then(function () {
            return deployer.deploy(DeviceSpawner, Rawbot.address, {
                    from: accounts[0],
                    value: 1e18 / 4
                })
                .then(function () {
                    return deployer.deploy(IPFS, Rawbot.address, DeviceSpawner.address, {
                        from: accounts[0],
                        value: 1e18 / 4
                    });
                });
        })
};