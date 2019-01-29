## Methods
```sendRawbot(address _address, uint256 value)```

Sends rawbot coins to a specific address

```withdraw(uint256 value)```

Withdraws rawbot coins (eth value)

```getContractDeviceManager()```

Returns device manager contract (authentic) address

```getAddresses()```

Returns an array of addresses that bought rawbot coins

```getExchangeLeftOf()```

Returns the amount of rawbot coins that can be exchanged coins

```getEthereumPrice()```

Returns the ethereum price

```getBalance(address _address)```

Returns the balance of a specific address in rawbot coins

```getContractCreator()```

Returns the address of the contract creator

```getContractBalance()```

Returns the balance of the contract in ethereum

```getApiEndpoint()```

Returns the current API endpoint

```getCurrentSupply()```

Returns the current supply available

```getCurrentSupplyMultiplier()```

Returns the current supply multiplier

```
event TransactionEvent(
        address _user,
        bytes32 _currency,
        bytes32 _type,
        uint256 _eth_price,
        uint256 _input,
        uint256 _output,
        uint256 _time
)
```
Event emitted by the contract when a transaction is executed