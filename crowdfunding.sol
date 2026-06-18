// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Crowdfunding {

    address public owner;

    uint256 public goal;
    uint256 public deadline;

    uint256 public totalRaised;

    mapping(address => uint256)
        public contributions;

    error NotOwner();
    error CampaignEnded();
    error CampaignNotEnded();
    error GoalNotReached();
    error GoalReached();
    error NoContribution();
    error TransferFailed();

    event Contributed(
        address indexed contributor,
        uint256 amount
    );

    event FundsWithdrawn(
        uint256 amount
    );

    event Refunded(
        address indexed contributor,
        uint256 amount
    );

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    constructor(
        uint256 _goal,
        uint256 _duration
    ) {
        owner = msg.sender;

        goal = _goal;

        deadline =
            block.timestamp +
            _duration;
    }

    receive() external payable {
        contribute();
    }

    function contribute()
