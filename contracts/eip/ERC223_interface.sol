pragma solidity ^0.4.11;

contract ERC223Interface {
    uint public totalSupply;

    function balanceOf(address who) constant returns (uint);

    function transfer(address to, uint value);

    function transfer(address to, uint value, bytes data);

    event Transfer(address indexed from, address indexed to, uint value, bytes data);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
