//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Storage {
    uint256 private number;
    string private message;
    address public owner;

    struct Profile{
        string name;
        uint256 age;
    }

    event NumberUpdated(uint256 newNumber);
    event MessageUpdated(string newMessage);
    event ProfileUpdated(string name, uint256 age);

    error NotOwner();

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }
    constructor() {
        owner = msg.sender;
    }

    function setNumber(uint256 _number) public onlyOwner{
        number = _number;

        emit NumberUpdated(_number);
    }
    function getNumber() public view returns (uint256) {
        return number;
    }
    function setMessage(string memory _message) public onlyOwner {
        message = _message;

        emit MessageUpdated(_message);
    }
    function getMessage() public view returns (string memory) {
        return message;
    }

    Profile private profile;

    function setProfile(string memory _name, uint256 _age) public onlyOwner{
        profile = Profile({
            name: _name,
            age: _age
        });
        emit ProfileUpdated(_name, _age);
    }
    function getProfile() public view returns (Profile memory) {
        return profile;
    }    
}