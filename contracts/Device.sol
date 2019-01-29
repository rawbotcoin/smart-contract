pragma solidity ^0.4.24;

import "./Rawbot.sol";
import "./lib/Oraclize.sol";
import "./interfaces/DeviceInterface.sol";

contract Device is usingOraclize, DeviceInterface {

    Rawbot private rawbot;
    address private rawbot_address;
    address private device_manager_address;

    struct Action {
        string name;
        uint256 price;
        mapping(uint256 => History) history;
        bool available;
    }

    struct History {
        address user;
        bool enable;
        bool refund;
        uint256 time;
        bool available;
    }

    /**
        Action
    */

    mapping(uint256 => uint256) action_duration;
    mapping(uint256 => uint256) action_occurrences;
    mapping(uint256 => bool) action_recurring;
    mapping(uint256 => bool) action_refundable;
    uint256 private action_index = 0;
    mapping(uint256 => uint256) action_history_length;
    mapping(uint256 => Action) private actions;

    mapping(address => mapping(uint256 => uint256)) user_action_occurrence;

    mapping(bytes32 => uint256) private query_ids;
    address private owner;

    constructor(address __owner, address __rawbot_address) public payable {
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        owner = __owner;
        rawbot = Rawbot(__rawbot_address);
        rawbot_address = __rawbot_address;
    }

    function() public payable {

    }

    modifier deviceOwner {
        require(owner == msg.sender, "Msg sender isn't the owner");
        _;
    }

    //"Open", 50
    function addAction(
        string name,
        uint256 price,
        uint256 occurrences,
        uint256 duration,
        bool recurring,
        bool refundable
    ) public deviceOwner returns (bool success) {
        require(price > 0, "Action price cannot be zero");
        actions[action_index] = Action(name, price * 1e18, true);
        action_duration[action_index] = duration;
        action_recurring[action_index] = recurring;
        action_refundable[action_index] = refundable;
        action_occurrences[action_index] = occurrences;
        emit ActionAdd(action_index, name, price);
        action_index++;
        return true;
    }

    /**
        Action setters
    **/

    function setActionPrice(uint256 id, uint256 price) public deviceOwner returns (bool success){
        actions[id].price = price;
        return true;
    }

    function setActionDuration(uint256 id, uint256 duration) public deviceOwner returns (bool success){
        action_duration[id] = duration;
        return true;
    }

    function setActionRecurring(uint256 id, bool recurring) public deviceOwner returns (bool success) {
        action_recurring[id] = recurring;
        return true;
    }

    function setActionRefundable(uint256 id, bool refundable) public deviceOwner returns (bool success){
        action_refundable[id] = refundable;
        return true;
    }

    function setActionProperties(
        uint256 id,
        uint256 occurrences,
        uint256 duration,
        bool recurring,
        bool refundable
    ) public deviceOwner returns (bool success) {
        action_occurrences[id] = occurrences;
        action_duration[id] = duration;
        action_recurring[id] = recurring;
        action_refundable[id] = refundable;
        return true;
    }

    function buyAction(uint256 id) public returns (bool success){
        rawbot.modifyBalance(msg.sender, address(this), actions[id].price);
        user_action_occurrence[msg.sender][id] += action_occurrences[id];
        return true;
    }

    function enableAction(uint256 id, string comment) public returns (bool success){
        require(
            actions[id].available == true
            && (action_history_length[id] == 0 || actions[id].history[action_history_length[id] - 1].enable == false)
            && (rawbot.getBalance(msg.sender) >= actions[id].price || user_action_occurrence[msg.sender][id] > 0)
            && address(this).balance > oraclize_getPrice("URL"),
            "Failed to enable action"
        );


        if (user_action_occurrence[msg.sender][id] > 0) {
            user_action_occurrence[msg.sender][id]--;
        } else {
            rawbot.modifyBalance(msg.sender, address(this), actions[id].price);

            if (action_occurrences[id] > 1) {
                user_action_occurrence[msg.sender][id] += action_occurrences[id] - 1;
            }
        }

        actions[id].history[action_history_length[id]] = History(msg.sender, true, false, now, true);
        emit ActionLogs(
            id,
            msg.sender,
            now,
            false,
            true
        );
        action_history_length[id]++;
        bytes32 query_id = oraclize_query(action_duration[id], "URL", "");
        query_ids[query_id] = id;
        return true;
    }

    function disableAction(uint256 id) public returns (bool success){
        require(
            actions[id].available == true
            && actions[id].history[action_history_length[id] - 1].enable == true
            && actions[id].history[action_history_length[id] - 1].user == msg.sender
        );

        actions[id].history[action_history_length[id]] = History(msg.sender, false, false, now, true);
        emit ActionLogs(
            id,
            msg.sender,
            now,
            false,
            false
        );
        action_history_length[id]++;
        return true;
    }

    function deleteAction(uint256 id) public deviceOwner returns (bool) {
        require(actions[id].available == true, "Failed to delete action");
        delete actions[id];
        delete action_history_length[id];
        return true;
    }

    function withdraw(uint256 value, address to) public deviceOwner returns (bool success) {
        rawbot.modifyBalance(address(this), to, value);
        return true;
    }

    function calculateAmountToRefund(uint256 id) private view returns (uint256 amount) {
        uint256 price = actions[id].price;
        uint256 duration = action_duration[id];
        uint256 duration_used = now - actions[id].history[action_history_length[id] - 1].time;
        return (duration_used * price) / duration;
    }

    //0, 0
    function refundMerchant(uint256 id, uint256 hid) public deviceOwner returns (bool success) {
        require(
            actions[id].available == true
            && action_refundable[id] == true
            && actions[id].history[hid].available == true
            && actions[id].history[hid].refund == false,
            "Refund merchant - failed to issue refund"
        );
        rawbot.modifyBalance(address(this), actions[id].history[hid].user, actions[id].price);
        actions[id].history[hid].enable = false;
        actions[id].history[hid].refund = true;
        emit RefundEvent(
            id,
            actions[id].price,
            now,
            false
        );
    }

    function refundCustomer(uint256 id) public returns (bool success){
        uint256 amount_to_refund = calculateAmountToRefund(id);
        History last_action = actions[id].history[action_history_length[id] - 1];
        require(
            actions[id].available == true
            && action_refundable[id] == true
            && msg.sender == last_action.user
            && last_action.available == true
            && last_action.enable == true,
            // && (action_duration[id] + last_action.time) - now > 0,
            "Failed to auto refund"
        );
        rawbot.modifyBalance(address(this), msg.sender, actions[id].price - amount_to_refund);
        last_action.enable = false;
        last_action.refund = true;
        emit RefundEvent(
            id,
            actions[id].price,
            now,
            false
        );
    }

    function __disableAction(uint256 id) private {
        History last_action = actions[id].history[action_history_length[id] - 1];
        actions[id].history[action_history_length[id]] = History(last_action.user, false, false, now, true);
        emit ActionLogs(
            id,
            msg.sender,
            now,
            true,
            false
        );
        action_history_length[id]++;
    }

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        uint256 id = query_ids[myid];
        bool should_query = false;
        address user = actions[id].history[action_history_length[id] - 1].user;
        if (action_recurring[id] == false) {
            __disableAction(id);
        } else {
            bool flag_one = false;
            if (user_action_occurrence[user][id] > 0) {
                user_action_occurrence[user][id]--;
                should_query = true;
                flag_one = true;
            }

            if (flag_one == true) {
                if (rawbot.getBalance(user) >= actions[id].price) {
                    rawbot.modifyBalance(user, address(this), actions[id].price);
                    should_query = true;
                }
            }
            if (should_query) {
                emit ActionLogs(
                    id,
                    user,
                    now,
                    true,
                    true
                );
                bytes32 query_id = oraclize_query(action_duration[id], "URL", "");
                query_ids[query_id] = id;
            } else {
                __disableAction(id);
            }
        }


        delete query_ids[myid];
    }

    function getRawbotAddress() public view returns (address _rawbot_address){
        return rawbot_address;
    }

    function setRawbot(address __rawbot_address) public deviceOwner returns (bool success){
        rawbot = Rawbot(__rawbot_address);
        rawbot_address = __rawbot_address;
        return true;
    }

    function getDeviceAction(uint256 id) public view returns (string name, uint256 price, uint256 occurrences, uint256 duration, bool recurring, bool refundable) {
        return (actions[id].name, actions[id].price, action_occurrences[id], action_duration[id], action_recurring[id], action_refundable[id]);
    }

    function getTotalActions() public view returns (uint256 total_actions){
        return action_index;
    }

    function getTotalActionsHistoryOf(uint256 action_id) public view returns (uint256 length){
        return action_history_length[action_id];
    }

    function isEnabled(uint256 action_id) public view returns (bool enabled) {
        return actions[action_id].history[action_history_length[action_id] - 1].enable;
    }

    function isAvailable(uint256 action_id) public view returns (bool available) {
        return actions[action_id].available;
    }

    function getUserActionOccurrence(address user, uint256 id) public view returns (uint256 amount){
        return user_action_occurrence[user][id];
    }
}

