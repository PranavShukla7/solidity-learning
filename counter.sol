//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract counter{
    uint256 public count;
    address public owner;

    event CountIncremented(uint256 newCount);
    event CountDecremented(uint256 newCount);

    error NotOwner();
    error CounterAlreadyZero();

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }
    constructor(){
        owner = msg.sender;
    }
    function increment() public onlyOwner {
        count++;
        emit CountIncremented(count);
    }
    function decrement() public onlyOwner{
        if(count == 0){
            revert CounterAlreadyZero();
        }
        count--;
        emit CountDecremented(count);
    }
    function reset() public onlyOwner {
        count = 0;
    }
}