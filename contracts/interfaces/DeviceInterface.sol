pragma solidity ^0.4.24;

contract DeviceInterface {

    event RefundEvent(
        uint256 _action_id,
        uint256 _action_price,
        uint256 _time,
        bool automatic
    );

    event ActionAdd(
        uint256 indexed id,
        string name,
        uint256 price
    );

    event ActionLogs(
        uint256 indexed id,
        address from,
        uint256 time,
        bool recurrent,
        bool enable
    );

    function addAction(string action_name, uint256 action_price, uint256 occurrences, uint256 duration, bool recurring, bool refundable) public returns (bool success);

    function setActionPrice(uint256 id, uint256 price) public returns (bool success);

    function setActionDuration(uint256 id, uint256 price) public returns (bool success);

    function setActionRecurring(uint256 id, bool recurring) public returns (bool success);

    function setActionRefundable(uint256 id, bool refundable) public returns (bool success);

    function setActionProperties(uint256 id, uint256 occurrences, uint256 duration, bool recurring, bool refundable) public returns (bool success);

    function buyAction(uint256 id) public returns (bool success);

    function enableAction(uint256 id, string comment) public returns (bool success);

    function disableAction(uint256 id) public returns (bool success);

    function deleteAction(uint256 id) public returns (bool success);

    function withdraw(uint256 value, address to) public returns (bool success);

    function calculateAmountToRefund(uint256 id) private view returns (uint256 amount);

    function refundMerchant(uint256 id, uint256 hid) public returns (bool success);

    function refundCustomer(uint256 id) public returns (bool success);

    function getRawbotAddress() public view returns (address _rawbot_address);

    function setRawbot(address __rawbot_address) public returns (bool success);

    function getUserActionOccurrence(address user, uint256 id) public view returns (uint256 amount);

    // function getDeviceSpawnerAddress() public view returns (address _device_spawner_address);
    // function addIPFSAction(string name, uint256 price) public returns (bool success);
    // function retrieveIPFSData(uint256 hash_index, string email, string pub_key) public returns (bool success);
    // function addIPFSResult(uint256 action_log_index, string hash_string) public returns (bool success);
    // function getIPFSResult(uint256 action_log_index) public view returns (string hash_string);
}
