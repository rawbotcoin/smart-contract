pragma solidity ^0.4.24;

import "./DeviceSpawner.sol";
import "./Rawbot.sol";
import "./lib/Owned.sol";

contract IPFS is Owned {

    event AddIPFSAction (
        address indexed device_address,
        uint256 indexed ipfs_index,
        bytes32 name,
        uint256 price
    );

    event ExecuteIPFSAction (
        uint256 indexed ipfs_action_index,
        uint256 ipfs_action_logs_index,
        address indexed device,
        address indexed user,
        bytes32 email,
        bytes32 name,
        uint256 price,
        bytes32 pub_key,
        uint256 time
    );

    Rawbot private rawbot;
    DeviceSpawner private device_spawner;
    address private rawbot_address;
    address private device_spawner_address;

    mapping(address => uint256) ipfs_action_index;
    mapping(address => uint256) ipfs_action_index_history;

    mapping(address => mapping(uint256 => string)) ipfs_results;
    mapping(address => mapping(uint256 => IPFSAction)) ipfs_actions;

    struct IPFSAction {
        bytes32 name;
        uint256 price;
        bool available;
    }

    constructor(address __rawbot_address, address __device_spawner_address) public payable {
        rawbot_address = __rawbot_address;
        device_spawner_address = __device_spawner_address;
        rawbot = Rawbot(__rawbot_address);
        device_spawner = DeviceSpawner(__device_spawner_address);
    }

    modifier deviceOnly () {
        require(device_spawner.hasAccess(msg.sender) == true, "Device contract doesn't have access.");
        _;
    }

    modifier deviceControllerOnly (address device_address) {
        require(
            device_spawner.getDeviceOwner(device_address) == msg.sender
            || device_spawner.getDeviceManager(device_address) == msg.sender, "Device owner doesn't match."
            );
        _;
    }

    function addIPFSAction(address device_address, bytes32 name, uint256 price) public deviceControllerOnly(msg.sender) returns (bool success) {
        uint256 __ipfs_index = ipfs_action_index[device_address];
        ipfs_actions[device_address][__ipfs_index] = IPFSAction(name, price * 1e18, true);
        emit AddIPFSAction(
            device_address,
            ipfs_action_index[device_address],
            name,
            price * 1e18
        );
        ipfs_action_index[device_address]++;
        return true;
    }

    function retrieveIPFSData(address device_address, uint256 hash_index, bytes32 email, bytes32 pub_key) public returns (bool success) {
        require(ipfs_actions[device_address][hash_index].available == true, "Failed to retrieve IPFS data");
        rawbot.modifyBalance(msg.sender, device_address, ipfs_actions[device_address][hash_index].price);
        emit ExecuteIPFSAction(
            hash_index,
            ipfs_action_index_history[device_address],
            device_address,
            msg.sender,
            email,
            ipfs_actions[device_address][hash_index].name,
            ipfs_actions[device_address][hash_index].price,
            pub_key,
            now
        );
        ipfs_action_index_history[device_address]++;
        return true;
    }

    function addIPFSResult(address device_address, uint256 action_log_index, string hash_string) public deviceOnly returns (bool success){
        ipfs_results[device_address][action_log_index] = hash_string;
        return true;
    }

    function getIPFSResult(address device_address, uint256 action_log_index) public view returns (string hash_string){
        return ipfs_results[device_address][action_log_index];
    }

    function getIPFSAction(address device_address, uint256 ipfs_action_id) public view returns (bytes32 action_name, uint256 price){
        IPFSAction action = ipfs_actions[device_address][ipfs_action_id];
        return (action.name, action.price);
    }

    function getTotalHashes(address device_address) public view returns (uint256 total_hashes){
        return ipfs_action_index[device_address];
    }

    function setRawbot(address __rawbot_address) public onlyOwner returns (bool success) {
        rawbot_address = __rawbot_address;
        rawbot = Rawbot(__rawbot_address);
        return true;
    }

    function setDeviceSpawner(address __device_spawner_address) public onlyOwner returns (bool success) {
        device_spawner_address = __device_spawner_address;
        device_spawner = DeviceSpawner(__device_spawner_address);
        return true;
    }

    function getRawbotAddress() public view returns (address __rawbot_address) {
        return rawbot_address;
    }

    function getDeviceSpawnerAddress() public view returns (address __device_spawner_address) {
        return device_spawner_address;
    }
}