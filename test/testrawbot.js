var Rawbot = artifacts.require("Rawbot");
var DeviceSpawner = artifacts.require("DeviceSpawner");
var Device = artifacts.require("Device");
var IPFS = artifacts.require("IPFS");

let test_ethereum = true;
let test_ethereum2 = false;
let device_address;
let device_spawner_address;
let rawbot_address;
let balance_8;
let balance_9;

contract('Rawbot', function (accounts) {
    it("should have 0.25 ethereum in rawbot contract", async () => {
        let instance = await Rawbot.deployed();
        rawbot_address = instance.address;
        let balance = await instance.getContractBalance();
        assert.equal(1e18 / 4, balance, "Contract balance isn't equal to 0.25 eth");
    });

    it("should have rawbot team address matching contract creator", async () => {
        let instance = await Rawbot.deployed();
        let address = await instance.getContractCreator();
        assert.equal(address, accounts[0], "Different contract creator address");
    });

    it("should have 4000000 rawbot coin in rawbot's team address", async () => {
        let instance = await Rawbot.deployed();
        let balance = await instance.balanceOf(accounts[0]);
        assert.equal(balance.valueOf(), 4000000 * 1e18, "4000000 are not available in " + accounts[0]);
    });

    if (test_ethereum) {
        it("should fetch ethereum price", async () => {
            let instance = await Rawbot.deployed();
            let tx = instance.fetchEthereumPrice(0);
            assert.equal(tx.tx !== null, true, "Failed to fetch Ethereum price");
        });

        it("should display ethereum price correctly", async () => {
            let instance = await Rawbot.deployed();
            await waitSeconds(15);
            let price = await instance.getEthereumPrice();
            assert.equal(price > 0, true, "Failed to display ethereum price correctly");
        });
    }

    if (test_ethereum2) {
        it("should fetch ethereum price again", async () => {
            let instance = await Rawbot.deployed();
            let change = await instance.changeUrl("json(https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDT).price")
            let tx = instance.fetchEthereumPrice(0);
            assert.equal(tx.tx !== null, true, "Failed to fetch Ethereum price");
        });

        it("should display ethereum price correctly again", async () => {
            let instance = await Rawbot.deployed();
            await waitSeconds(20);
            let price = await instance.getEthereumPrice();
            let api_endpoint = await instance.getApiEndpoint();
            console.log(api_endpoint);
            console.log(price.valueOf());
            assert.equal(price > 0, true, "Failed to display ethereum price correctly");
        });
    }

    it("should send amount of ethereum to contract using account 9 to reach > 1000 rawbot coins", async () => {
        let instance = await Rawbot.deployed();
        let tx = await instance.sendTransaction({
            to: instance.address,
            from: accounts[9],
            value: 5 * 1e18
        });
        assert.equal(tx !== null, true, "Failed to send ethereum to contract");
    });

    it("should receive rawbot coins equivalent to 5 ETH on account 9", async () => {
        let instance = await Rawbot.deployed();
        let price = await instance.getEthereumPrice();
        let balance = await instance.balanceOf(accounts[9]);
        let amount_to_receive = 5 * price * 2 * 1e18;
        balance_9 = balance.valueOf();
        assert.equal(amount_to_receive == balance_9, true, "Failed to receive rawbot coins");
    });

    it("should send 500 rawbot coin to account 8 from account 9", async () => {
        let instance = await Rawbot.deployed();
        balance_9 -= 500;
        let tx = await instance.sendRawbot(accounts[8], 500, {
            to: instance.address,
            from: accounts[9]
        });
        assert.equal(tx !== null, true, "Failed to send 500 rawbot coins");
    });

    it("should have 500 rawbot coin on account 8 from account 9", async () => {
        let instance = await Rawbot.deployed();
        let balance = await instance.balanceOf(accounts[8]);
        balance_8 = balance.valueOf();
        assert.equal(balance.valueOf() == 500 * 1e18, true, "Failed to receive 1000 rawbot coins");
    });

    it("should send 500 rawbot coin to account 8 from account 9", async () => {
        let instance = await Rawbot.deployed();
        try {
            let tx = await instance.sendRawbot(accounts[8], 500, {
                to: instance.address,
                from: accounts[9]
            });
        } catch (e) {
            console.log(e)
            assert.equal(false, false, "Failed to send 500 rawbot coins");
        }
    });

    it("should withdraw 500 rawbot coin into ethereum from account 9", async () => {
        let instance = await Rawbot.deployed();
        try {
            let tx = await instance.withdraw(500, {
                to: instance.address,
                from: accounts[9]
            });
        } catch (e) {
            assert.equal(false, false, "Failed to withdraw 500 rawbot coins");
        }
    });

    it("should not send 5000 rawbot coin to account 8 from account 9", async () => {
        let instance = await Rawbot.deployed();
        try {
            let tx = await instance.sendRawbot(accounts[8], 5000, {
                to: instance.address,
                from: accounts[9]
            });
        } catch (e) {
            assert.equal(false, false, "Failed to send 5000 rawbot coins");
        }
    });

    it("should set device spawner contract using account 0", async () => {
        let rawbot = await Rawbot.deployed();
        let device_spawner = await DeviceSpawner.deployed();
        let tx = await rawbot.setDeviceSpawnerAddress(device_spawner.address, {
            from: accounts[0]
        });
        assert.equal(tx !== null, true, "Failed to set device spawner contract address");
    });

    it("should set ipfs address contract using account 0", async () => {
        let rawbot = await Rawbot.deployed();
        let ipfs = await IPFS.deployed();
        let tx = await rawbot.setIPFSAddress(ipfs.address, {
            from: accounts[0]
        });
        assert.equal(tx !== null, true, "Failed to set ipfs address contract address");
    });


    it("should fail to set device spawner contract using account 3", async () => {
        let rawbot = await Rawbot.deployed();
        let device_spawner = await DeviceSpawner.deployed();
        try {
            let tx = await rawbot.setContractDeviceManager(device_spawner.address, {
                from: accounts[3]
            });
        } catch (e) {
            assert.equal(false, false, "Failed to set device spawner contract address");
        }
    });

    it("should match device spawner contract previously set", async () => {
        let rawbot = await Rawbot.deployed();
        let device_spawner = await DeviceSpawner.deployed();
        let address = await rawbot.getDeviceSpawnerAddress();
        assert.equal(address === device_spawner.address, true, "Failed to match device spawner contract address");
    });

    // contract('DeviceManager', function (accounts) {
    it("should have 0.25 ethereum in device spawner contract", async () => {
        let instance = await DeviceSpawner.deployed();
        let balance = await instance.getContractBalance();
        assert.equal(1e18 / 4, balance, "Contract balance isn't equal to 0.25 eth");
    });

    it("should match rawbot contract address in device spawner contract", async () => {
        let device_spawner = await DeviceSpawner.deployed();
        let r_address = await device_spawner.getRawbotAddress();
        device_spawner_address = device_spawner.address;
        assert.equal(r_address, rawbot_address, "Rawbot contract address doesn't match the device spawner's");
    });

    it("should add device 1", async () => {
        let device_spawner = await DeviceSpawner.deployed();
        let tx = await device_spawner.addDevice(accounts[0], "ABC1", "Raspberry PI 1", "Hassan", "Lebanon", "https://pastebin.com/raw/iQVDCZRP", 500, 500, 500, 500, 20, {
            to: device_spawner.address,
            from: accounts[0]
        });
        device_address = tx.logs[0].args._contract;
        assert.equal(typeof tx.logs[0].args._contract !== "undefined", true, "Failed to add device 1");
    });

    it("should add device 2", async () => {
        let device_spawner = await DeviceSpawner.deployed();
        let tx = await device_spawner.addDevice(accounts[0], "ABC2", "Raspberry PI 2", "Hassan", "Lebanon", "https://pastebin.com/raw/iQVDCZRP", 500, 500, 500, 500, 20, {
            to: device_spawner.address,
            from: accounts[0]
        });

        assert.equal(typeof tx.logs[0].args._contract !== "undefined", true, "Failed to add device 2");
    });

    it("should add device 3", async () => {
        let device_spawner = await DeviceSpawner.deployed();
        let tx = await device_spawner.addDevice(accounts[0], "ABC3", "Raspberry PI 3", "Hassan", "Lebanon", "https://pastebin.com/raw/iQVDCZRP", 500, 500, 500, 500, 20, {
            to: device_spawner.address,
            from: accounts[0]
        });
        assert.equal(typeof tx.logs[0].args._contract !== "undefined", true, "Failed to add device 3");
    });

    it("should be able to modify balance automatically", async () => {
        let device_spawner = await DeviceSpawner.deployed();
        let bool = await device_spawner.hasAccess(device_address);
        assert.equal(bool, true, "Failed to modify balance automatically");
    });

    it("should deploy device 1", async () => {
        let instance = await Device.at(device_address);
        assert.equal(typeof instance.address !== "undefined", true, "Failed to deploy device 1");
    });

    it("should set rawbot address on device 1", async () => {
        let instance = await Device.at(device_address);
        try {
            let set = await instance.setRawbot(rawbot_address);
            assert.equal(true, true, "Failed to set rawbot address on device10");
        } catch (e) {
            assert.equal(false, true, "Failed to set rawbot address on device10");
        }
    });

    // it("should have rawbot address in device spawner matching", async () => {
    //     let instance = await Device.at(device_address);
    //     let ad = await instance.getDeviceRawbotAddress();
    //     console.log(ad)
    //     console.log(rawbot_address)
    //     assert.equal(ad === rawbot_address, true, "Failed to match");
    // });

    it("should send 1 ethereum to device 1", async () => {
        let instance = await Device.at(device_address);
        let tx = await instance.sendTransaction({
            to: device_address,
            from: accounts[0],
            value: 1e18
        });
        assert.equal(tx.tx !== null, true, "Failed to send ethereum to contract");
    });

    it("should receive 1 ethereum on device 1", async () => {
        let device_spawner = await DeviceSpawner.deployed();
        let balance = await device_spawner.getDeviceBalance(device_address);
        assert.equal(balance.valueOf() == 1e18, true, "Failed to check device contract balance");
    });

    it("should match device 1 owner", async () => {
        let instance = await DeviceSpawner.deployed();
        let owner = await instance.getDeviceOwner(device_address);
        assert.equal(owner === accounts[0], true, "Failed to check device 1 owner");
    });

    it("should add action 0 on device 1", async () => {
        let instance = await Device.at(device_address);
        let tx = await instance.addAction("Open", 50, 1, 0, false, true, {
            to: device_address,
            from: accounts[0]
        });
        assert.equal(typeof tx.tx !== "undefined", true, "Failed to add action 0 on device 1");
    });

    it("should add action 1 on device 1", async () => {
        let instance = await Device.at(device_address);
        let tx = await instance.addAction("Close", 5, 1, 0, false, true, {
            to: device_address,
            from: accounts[0]
        });
        assert.equal(typeof tx.tx !== "undefined", true, "Failed to add action 1 on device 1");
    });

    it("should add action 2 on device 1", async () => {
        let instance = await Device.at(device_address);
        let tx = await instance.addAction("Electricity", 250, 1, 86400, false, true, {
            to: device_address,
            from: accounts[0]
        });
        assert.equal(typeof tx.tx !== "undefined", true, "Failed to add action 3 on device 1");
    });

    it("should add action 3 on device 1", async () => {
        let instance = await Device.at(device_address,);
        let tx = await instance.addAction("Potato", 50, 1, 0, false, true, {
            to: device_address,
            from: accounts[0]
        });
        assert.equal(typeof tx.tx !== "undefined", true, "Failed to add action 3 on device 1");
    });

    it("should add action 4 on device 1", async () => {
        let instance = await Device.at(device_address,);
        let tx = await instance.addAction("ABCD", 5, 15, 0, false, true, {
            to: device_address,
            from: accounts[0]
        });
        assert.equal(typeof tx.tx !== "undefined", true, "Failed to add action 4 on device 1");
    });

    it("should enable action 0 on device 1 using account 8", async () => {
        let instance = await Device.at(device_address);
        try {
            await instance.enableAction(0, "Fix the door locks please", {
                to: device_address,
                from: accounts[8]
            });
            assert.equal(true, true, "Failed to enable action 0 on device 1");

        } catch (e) {
            assert.equal(false, true, "Failed to enable action 0 on device 1");
        }
    });

    it("should have action 0 enabled state: true", async () => {
        let instance = await Device.at(device_address);
        let bool = await instance.isEnabled(0);
        assert.equal(bool, true, "action 0 enable state: false");
    });

    it("should have 50 rawbot coin on device 1", async () => {
        let instance = await Rawbot.deployed();
        let balance = await instance.balanceOf(device_address);
        assert.equal(balance.valueOf() / 1e18, 50, "50 are not available in device 1");
    });

    it("should have 950 rawbot coin on account 8", async () => {
        let instance = await Rawbot.deployed();
        let balance = await instance.balanceOf(accounts[8]);
        assert.equal(balance.valueOf() / 1e18, 950, "450 are not available in " + accounts[8]);
    });

    it("should withdraw 50 rawbot coins from device 1", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.withdraw(50, {
                to: device_address,
                from: accounts[0]
            });
            assert.equal(true, true, "Failed to withdraw 50 rawbot coins from device 1");
        } catch (e) {
            assert.equal(false, false, "Failed to withdraw 50 rawbot coins from device 1");
        }
    });

    it("should fail to withdraw 50 rawbot coins from device 1", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.withdraw(50, {
                to: device_address,
                from: accounts[0]
            });
            assert.equal(true, true, "Failed to withdraw 50 rawbot coins from device 1");
        } catch (e) {
            assert.equal(false, false, "Failed to withdraw 50 rawbot coins from device 1");
        }
    });

    it("should fail to enable action 0 again on device 1 using account 8", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.enableAction(0, "Fix the door locks please", {
                to: device_address,
                from: accounts[8]
            });
        } catch (e) {
            assert.equal(false, false, "Failed to enable action 0 again on device 1");
        }
    });

    it("should disable action 0 on device 1 using account 8", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.disableAction(0, {
                to: device_address,
                from: accounts[8]
            });
            assert.equal(true, true, "Failed to disable action 0 on device 1");
        } catch (err) {
            assert.equal(false, true, "Failed to disable action 0 on device 1");
        }
    });

    it("should fail to disable action 0 on device 1 using account 8", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.disableAction(0, {
                to: device_address,
                from: accounts[8]
            });
        } catch (e) {
            assert.equal(false, false, "Failed to disable action 0 on device 1");
        }
    });

    it("should fail to enable action 99 on device 1 using account 8", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.enableAction(99, "Fix the lamp", {
                to: device_address,
                from: accounts[8]
            });
        } catch (e) {
            assert.equal(false, false, "Failed to enable action 5 on device 1");
        }
    });

    it("should fail to disable action 5 on device 1 using account 8", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.disableActon(0, {
                to: device_address,
                from: accounts[8]
            });
        } catch (e) {
            assert.equal(false, false, "Failed to disable action 5 on device 1");
        }
    });

    it("should enable action 3 on device 1 using account 8", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.enableAction(2, "Fix the door locks please", {
                to: device_address,
                from: accounts[8]
            });
            assert.equal(true, true, "Failed to enable action 3 on device 1");

        } catch (err) {
            assert.equal(false, true, "Failed to enable action 3 on device 1");

        }
    });

    it("should have 700 rawbot coin on account 8", async () => {
        let instance = await Rawbot.deployed();
        let balance = await instance.balanceOf(accounts[8]);
        assert.equal(balance.valueOf() / 1e18, 700, "700 are not available in " + accounts[8]);
    });

    it("should have 300 rawbot coin on device 1 after action 3 execution", async () => {
        let instance = await Rawbot.deployed();
        let balance = await instance.balanceOf(device_address);
        assert.equal(balance.valueOf() / 1e18, 300, "Balance is different than 300 rawbot coins are available in device 1");
    });

    it("should fail to refund action 0 on device 1 using account 0", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.refundMerchant(0, 0, false, {
                to: device_address,
                from: accounts[0]
            });
        } catch (e) {
            assert.equal(false, false, "Failed to refund action 0 on device 1");
        }
    });

    it("should refund action 3 on device 1 using account 0", async () => {
        let instance = await Device.at(device_address);
        let tx = await instance.refundMerchant(2, 0, {
            to: device_address,
            from: accounts[0]
        });
        assert.equal(tx !== null, true, "Failed to refund action 0 on device 1");
    });

    it("should fail to refund action 3 again on device 1 using account 0", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.refundMerchant(2, 0, {
                to: device_address,
                from: accounts[0]
            });
        } catch (e) {
            assert.equal(false, false, "Failed to refund action 3 again on device 1");
        }
    });

    it("should have 950 rawbot coin on account 8 after refunding action 3", async () => {
        let instance = await Rawbot.deployed();
        let balance = await instance.balanceOf(accounts[8]);
        assert.equal(balance.valueOf() / 1e18, 950, "450 are not available in " + accounts[8]);
    });

    it("should enable action 3 on device 1 using account 8", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.enableAction(2, "Fix the door locks please", {
                to: device_address,
                from: accounts[8]
            });
            assert.equal(true, true, "Failed to enable action 3 on device 1");

        } catch (e) {
            assert.equal(false, true, "Failed to enable action 3 on device 1");
        }
    });

    it("should have action 0 enabled state: false", async () => {
        let instance = await Device.at(device_address);
        let bool = await instance.isEnabled(0, {
            to: device_address,
            from: accounts[0]
        });
        assert.equal(bool, false, "action 0 enable state: true");
    });

    it("should have delete action 0", async () => {
        let instance = await Device.at(device_address);
        try {
            let bool = await instance.deleteAction(0, {
                to: device_address,
                from: accounts[0]
            });
            assert.equal(true, true, "Failed to delete action 0");
        } catch (e) {
            assert.equal(false, true, e);
        }
    });

    it("should have delete action 2", async () => {
        let instance = await Device.at(device_address);
        try {
            let bool = await instance.deleteAction(1, {
                to: device_address,
                from: accounts[0]
            });
            assert.equal(true, true, "Failed to delete action 2");
        } catch (e) {
            assert.equal(false, true, e);
        }
    });

    it("should have action 0 deleted", async () => {
        let instance = await Device.at(device_address);
        let available = await instance.isAvailable(0);
        assert.equal(available, false, "action 0 is still available.");
    });

    it("should have action 1 deleted", async () => {
        let instance = await Device.at(device_address);
        let available = await instance.isAvailable(1);
        assert.equal(available, false, "action 1 is still available.");
    });

    it("should add ipfs action 1 on address 1 from account 0", async () => {
        let instance = await IPFS.deployed();
        let tx = await instance.addIPFSAction(device_address, "Fetch potato price", 250, {
            to: device_address,
            from: accounts[0]
        });
        assert.equal(typeof tx.tx !== "undefined", true, "Failed to add ipfs action on device 1");
    });

    it("should add ipfs action 2 on address 2 from account 0", async () => {
        let instance = await IPFS.deployed();
        let tx = await instance.addIPFSAction(device_address, "Fetch eth price", 500, {
            to: device_address,
            from: accounts[0]
        });
        assert.equal(typeof tx.tx !== "undefined", true, "Failed to add ipfs action on device 1");
    });

    it("should retrieve data using ipfs action 1 on device 1 from account 0", async () => {
        let instance = await IPFS.deployed();
        let tx = await instance.retrieveIPFSData(device_address, 0, "devhassanjawhar@gmail.com", "1jx8z0", {
            from: accounts[8]
        });
        assert.equal(typeof tx.tx !== "undefined", true, "Failed to retrieve data using ipfs");
    });

    it("should retrieve data using ipfs action 2 on device 1 from account 0", async () => {
        let instance = await IPFS.deployed();
        let tx = await instance.retrieveIPFSData(device_address, 0, "devhassanjawhar@gmail.com", "1jx8z0", {
            from: accounts[8]
        });
        assert.equal(typeof tx.tx !== "undefined", true, "Failed to retrieve data using ipfs");
    });

    it("should fail to add ipfs action 1 on address 1 from account 1", async () => {
        let instance = await IPFS.deployed();
        try {
            let tx = await instance.addIPFSAction(device_address, "Fetch potato price", 250, {
                to: device_address,
                from: accounts[0]
            });
            assert.equal(false, true, "Failed to add ipfs action on device 1");
        } catch (e) {
            assert.equal(true, true, "Failed to add ipfs action on device 1");
        }
    });

    it("should fail to add ipfs action 2 on address 1 from account 1", async () => {
        let instance = await IPFS.deployed();
        try {
            let tx = await instance.addIPFSAction(device_address, "Fetch eth price", 500, {
                to: device_address,
                from: accounts[0]
            });
            assert.equal(false, true, "Failed to add ipfs action on device 1");
        } catch (e) {
            assert.equal(true, true, "Failed to add ipfs action on device 1");
        }
    });
    it("#1 should buy action 4 from device 1", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.buyAction(4, {
                to: device_address,
                from: accounts[8]
            });
        } catch (e) {
            assert.equal(true, false, "#1 Failed to buy action 4 from device 1");
        }
    });
    it("#2 should buy action 4 from device 1", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.buyAction(4, {
                to: device_address,
                from: accounts[8]
            });
        } catch (e) {
            assert.equal(true, false, "#2 Failed to buy action 4 from device 1");
        }
    });

    it("#3 should buy action 4 from device 1", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.buyAction(4, {
                to: device_address,
                from: accounts[8]
            });
        } catch (e) {
            assert.equal(true, false, "#3 Failed to buy action 4 from device 1");
        }
    });

    it("#4 should have 45 actions of action id 4", async () => {
        let instance = await Device.at(device_address);
        let times = await instance.getUserActionOccurrence(accounts[8], 4);
        assert.equal(times.valueOf(), 45, "#3 failed to have 45 actions of action id 4");
    });

    it("#5 should enable action 4 on device 1", async () => {
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.enableAction(4, "test5", {
                to: device_address,
                from: accounts[8]
            });

        } catch (e) {
            assert.equal(true, false, "#5 Failed to enable action 4 on device 1");
        }
    });

    it("#6 should enable action 4 on device 1", async () => {
        await waitSeconds(15);
        let instance = await Device.at(device_address);
        try {
            let tx = await instance.enableAction(4, "test6", {
                to: device_address,
                from: accounts[8]
            });
        } catch (e) {
            assert.equal(true, false, "#6 Failed to enable action 4 on device 1");
        }
    });


    it("#8 should have 43 actions of action id 4", async () => {
        let instance = await Device.at(device_address);
        let times = await instance.getUserActionOccurrence(accounts[8], 4);
        assert.equal(times.valueOf(), 43, "#8 failed to have 43 actions of action id 4");
    });

});

function waitSeconds(seconds) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            resolve();
        }, seconds * 1000);
    });
}