pragma solidity ^0.4.24;

import "./Device.sol";
import "./Rawbot.sol";

contract DeviceSpawner {
    event DeviceAdd(
        address indexed _sender,
        address indexed _contract
    );

    address private rawbot_address;
    Rawbot private rawbot;

    mapping(uint256 => address) private devices;
    mapping(uint256 => address) private merchants;
    mapping(address => bool) private devices_access;

    uint256 private total_devices = 0;
    uint256 private total_merchants = 0;

    mapping(address => Merchant) private merchant;
    mapping(address => DeviceInfo) private infoOf;
    mapping(address => uint256) private total_devices_of;

    struct Merchant {
        mapping(uint256 => address) devices;
        bool available;
    }

    struct DeviceInfo {
        bytes32 serial_number;
        bytes32 name;
        address owner;
        bytes32 owner_name;
        address manager;
        bytes32 country;
        bytes32 location;
        uint256 latitude;
        uint256 longitude;
        uint256 altitude;
        uint256 accuracy;
        string json;
        bool available;
    }

    constructor(address _input_address) public payable {
        rawbot_address = _input_address;
        rawbot = Rawbot(_input_address);
    }

    function getRawbotAddress() public view returns (address _rawbot_address){
        return rawbot_address;
    }

    function addDevice(
        address _manager,
        bytes32 _device_serial_number,
        bytes32 _device_name,
        bytes32 _owner_name,
        bytes32 _country,
        bytes32 _location,
        uint256 _latitude,
        uint256 _longitude,
        uint256 _altitude,
        uint256 _accuracy,
        string json
    ) public returns (Device __spawned_device) {
        require(
            _manager != 0x0
            && _device_serial_number != 0x0
            && _device_name != 0x0
            && _owner_name != 0x0
            && _country != 0x0
            && _location != 0x0
            && _latitude > 0
            && _longitude > 0
            && _altitude >= 0
            && _accuracy >= 0
        );
        rawbot.modifyBalance(msg.sender, rawbot_address, 100 * 1e18);
        Device device = new Device(msg.sender, rawbot_address);
        infoOf[device] = DeviceInfo(
            _device_serial_number,
            _device_name,
            msg.sender,
            _owner_name,
            _manager,
            _country,
            _location,
            _latitude,
            _longitude,
            _altitude,
            _accuracy,
            json,
            true
        );

        emit DeviceAdd(msg.sender, device);
        return device;
    }

    function hasAccess(address _address) external view returns (bool __allowed){
        return infoOf[_address].available;
    }

    /**
        Device information
    **/

    function getContractBalance() public view returns (uint256 __balance){
        return address(this).balance;
    }

    function getDeviceOwner(address device_address) public view returns (address __device_owner) {
        return infoOf[device_address].owner;
    }

    function getDeviceManager(address device_address) public view returns (address __device_manager) {
        return infoOf[device_address].manager;
    }

    function getDeviceBalance(address device_address) public view returns (uint256 __device_balance){
        return address(device_address).balance;
    }

    function setDeviceManager(address device_address, address device_manager) public returns (bool success){
        require(getDeviceOwner(device_address) == msg.sender, "Msg sender isn't the owner.");
        infoOf[device_address].manager = device_manager;
        return true;
    }

    function getDeviceInformation(address device_address)
    public view
    returns (
        bytes32 serial_number,
        bytes32 name,
        address owner,
        bytes32 owner_name,
        bytes32 country,
        bytes32 location,
        uint256 latitude,
        uint256 longitude,
        uint256 altitude,
        uint256 accuracy,
        string json
    )
    {
        DeviceInfo info = infoOf[device_address];
        return (
        info.serial_number,
        info.name,
        info.owner,
        info.owner_name,
        info.country,
        info.location,
        info.latitude,
        info.longitude,
        info.altitude,
        info.accuracy,
        info.json
        );
    }
}