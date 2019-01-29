## Methods
```
event DeviceAdd(
    address _rawbot_address,
    address _sender,
    address _contract
)
```

Event emitted by the contract when a device is added

```getRawbotAddress()```
Returns the authentic rawbot contract address

```
addDevice(
    bytes32 _device_serial_number,
    bytes32 _device_name,
    bytes32 _owner_name,
    bytes32 _country,
    bytes32 _location,
    uint256 _latitude,
    uint256 _longitude,
    uint256 _altitude,
    uint256 _accuracy
)
```
Function executed to add a device to the device manager contract

```
getDeviceInformation(address device_address)
```
Returns
```
{
    bytes32 serial_number,
    bytes32 name,
    address owner,
    bytes32 owner_name,
    bytes32 country,
    bytes32 location,
    uint256 latitude,
    uint256 longitude,
    uint256 altitude,
    uint256 accuracy
}
```

Return device properties
```
getDeviceSerialNumber(address device_address)
getDeviceName(address device_address)
getDeviceOwner(address device_address)
getDeviceOwnerName(address device_address)
getDeviceCountry(address device_address)
getDeviceLocation(address device_address)
getDeviceLatitude(address device_address)
getDeviceLongitude(address device_address)
getDevicAltitude(address device_address)
getDeviceAccuracy(address device_address)
getDeviceBalance(address device_address)
```