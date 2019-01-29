# Rawbot - ERC223 standard

[![N|Solid](http://rawbot.org/img/rawbot_logo_colored.png)](http://rawbot.org)

Rawbot is a framework, more precisely a collection of configurations/scripts/hacks with an underlying currency named RAW with the purpose of facilitating the implementation of payment gateways to activate digital services on a variety of IoT enabled devices such as Raspberry Pi, Arduino, Beagleboard, particle, drones, electric cars and more.

Rawbot utilizes RAW coin, an Ethereum guaranteed token that can be exchanged to ETH through a smart contract at any moment.

We have acquired experience in use cases from different Industries to address technical issues that may arise during the process on both client and merchant level, this experience will be invested in supporting users to achieve a seamless implementation.

## Instructions
```
$ npm install
$ npm install -g ethereum-bridge
$ npm install -g truffle
$ npm install -g ganache-cli
$ ganache-cli
$ ethereum-bridge -H localhost:8545 -a 1 --dev
$ truffle console --network development
$ truffle(development)> migrate
$ truffle(development)> test
```

## Documentation
- [Rawbot]
- [IPFS]
- [Device Spawner]
- [Device]

## Contact
  - [Website]
  - [Whitepaper]

[Website]: <http://rawbot.org>

[Whitepaper]: <http://rawbot.org/rawbot_whitepaper.pdf>

[Rawbot]: <https://github.com/rawbotcoin/rawbot/blob/master/documentation/rawbot.md>

[IPFS]: <https://github.com/rawbotcoin/rawbot/blob/master/documentation/ipfs.md>

[Device Spawner]: 
 <https://github.com/rawbotcoin/rawbot/blob/master/documentation/device_manager.md>

 [Device]: 
 <https://github.com/rawbotcoin/rawbot/blob/master/documentation/device.md>
