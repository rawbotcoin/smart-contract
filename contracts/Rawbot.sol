pragma solidity ^0.4.24;

import "./lib/Oraclize.sol";
import "./lib/Owned.sol";
import "./DeviceSpawner.sol";
import "./eip/ERC223.sol";

contract Rawbot is Owned, ERC223, usingOraclize {

    address private _rawbot_team;
    address private ipfs_address;
    address[] private exchange_addresses;
    address private device_spawner_address;
    mapping(address => uint256) private pending;
    uint256 public initSupply;
    string private ETH_ENDPOINT = "json(https://bittrex.com/api/v1.1/public/getticker?market=USD-ETH).result.Last";

    event Burn(address user, uint256 amount);
    event OraclizeLog(string _description, uint256 _time);
    event TransactionEvent(
        address indexed _user,
        uint256 _eth_price,
        uint256 _input,
        uint256 _output,
        uint256 _time,
        uint256 _block_number
    );

    uint256 private ETH_PRICE = 0;
    uint256 private last_price_update = 0;
    uint256 private NEGATIVE_BALANCE_MAX = 20;
    uint private PAYMENT_STEP = 0;
    mapping(bytes32 => address) private queries_address;
    mapping(bytes32 => uint256) private queries_value;
    mapping(address => uint256) private negativeBalanceOf;
    /**
        Rawbot has 20,000,000 tokens.
        4,000,000 are held by the contract for the Rawbot team
        16,000,000 are circulating
    */
    constructor() ERC223(20000000, "Rawbot Test 1", 18, "TWR") public payable {
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        _rawbot_team = msg.sender;
        balances[msg.sender] = (totalSupply * 1) / 5;
        initSupply = totalSupply;
    }

    /**
        This method is used to receive Ethereum & transfer Raw coins in return to the user
        It adds them to transaction_exchanges mapping and executes all queued exchanges
        at the same time to avoid fetching Ethereum price at the same time
    */

    function() payable public {
        if (ETH_PRICE == 0 || now - last_price_update > 300) {
            _buyQuery(msg.sender, msg.value);
        } else {
            _buy(msg.sender, msg.value);
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= (_value * 1e18), "Not enough balance");
        balances[msg.sender] -= _value * 1e18;
        totalSupply -= _value * 1e18;
        emit Burn(msg.sender, _value * 1e18);
        return true;
    }

    function burnFrom(address _from, uint256 _value) private returns (bool success) {
        require(balances[_from] >= (_value * 1e18), "Not enough balance");
        balances[_from] -= _value * 1e18;
        totalSupply -= _value * 1e18;
        emit Burn(_from, _value * 1e18);
        return true;
    }

    function sendRawbot(address _address, uint256 value) public payable returns (bool) {
        require(balances[msg.sender] >= value * 1e18);
        balances[msg.sender] -= value * 1e18;
        balances[_address] += value * 1e18;
        return true;
    }

    /**
        This method is used to modify user's balance externally
        It can only be used by created Merchant contract addresses
    */

    function modifyBalance(address from, address to, uint256 amount) external {
        DeviceSpawner deviceSpawner = DeviceSpawner(device_spawner_address);
        require(deviceSpawner.hasAccess(msg.sender) == true || getIPFSAddress() == msg.sender || getDeviceSpawnerAddress() == msg.sender);
        require(balances[from] >= amount || (balances[from] < amount && amount - balances[from] <= 20));
        balances[from] -= amount;
        balances[to] += amount;
    }

    //https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDT -> .price
    //https://bittrex.com/api/v1.1/public/getticker?market=USD-ETH -> .result.Last
    /**
        'json(https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDT).price';
        'json(https://bittrex.com/api/v1.1/public/getticker?market=USD-ETH).result.Last';
    **/

    function changeUrl(string endpoint) public onlyOwner {
        ETH_ENDPOINT = endpoint;
    }

    /**
       This method is used to fetch the Ethereum price using Oraclize API
    */
    function fetchEthereumPrice(uint timing) public onlyOwner payable returns (bool) {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit OraclizeLog("Oraclize query was NOT sent, please add some ETH to cover for the query fee", now);
            return false;
        } else {
            emit OraclizeLog("Oraclize query was sent, standing by for the answer..", now);
            oraclize_query(timing, "URL", ETH_ENDPOINT);
            return true;
        }
    }


    function increaseSupply() public onlyOwner {
        initSupply = initSupply * 2;
        totalSupply += initSupply;
        balances[_rawbot_team] += (initSupply * 1) / 5;
        totalSupply -= (initSupply * 1) / 5;
    }

    /**
        This method is used to set the DeviceManager's address
        It's used to manipulate the modifyBalance function
    */
    function setDeviceSpawnerAddress(address _address) public onlyOwner returns (bool success){
        device_spawner_address = _address;
        return true;
    }

    /**
        This method returns the DeviceManager's address
    */
    function getDeviceSpawnerAddress() public view returns (address __device_spawner_address) {
        return device_spawner_address;
    }

    /**
       This method is used to set the DeviceManager's address
       It's used to manipulate the modifyBalance function
   */
    function setIPFSAddress(address __ipfs_address) public onlyOwner returns (bool success){
        ipfs_address = __ipfs_address;
        return true;
    }

    /**
        This method returns the DeviceManager's address
    */
    function getIPFSAddress() public view returns (address __ipfs_address) {
        return ipfs_address;
    }

    /**
        This method returns the exchange addresses
    */
    function getAddresses() public view returns (address[] __addresses) {
        return exchange_addresses;
    }

    /**
        This method returns the Ethereum price
    */
    function getEthereumPrice() public view returns (uint __eth_price) {
        return ETH_PRICE;
    }

    function getContractCreator() public view returns (address __rawbot_team){
        return _rawbot_team;
    }

    function getContractBalance() public view returns (uint256 __balance){
        return address(this).balance;
    }

    function getApiEndpoint() public view returns (string __api_endpoint){
        return ETH_ENDPOINT;
    }

    function getCurrentSupply() public view returns (uint256 __current_supply){
        return totalSupply;
    }

    function getCurrentSupplyMultiplier() public view returns (uint256 __current_supply_multiplier){
        return initSupply;
    }

    function getBalance(address user) external view returns (uint256 balance){
        return balances[user];
    }

    function _buyQuery(address _address, uint256 _value) private {
        bytes32 my_id = oraclize_query(0, "URL", ETH_ENDPOINT);
        queries_address[my_id] = _address;
        queries_value[my_id] = _value;
    }

    function _buy(address _address, uint256 _value) private {
        uint256 raw_amount = (_value * ETH_PRICE * 2);
        totalSupply -= raw_amount;
        balances[_address] += raw_amount;
        emit TransactionEvent(
            _address,
            ETH_PRICE,
            _value,
            raw_amount,
            now,
            block.number
        );
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) revert();
        ETH_PRICE = parseInt(result);
        emit OraclizeLog(result, now);
        last_price_update = now;
        _buy(queries_address[myid], queries_value[myid]);
        delete queries_address[myid];
        delete queries_value[myid];
    }
}