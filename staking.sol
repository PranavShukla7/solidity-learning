// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Staking {

    struct StakeInfo {
        uint256 amount;
        uint256 lastUpdated;
    }

    mapping(address => StakeInfo) public stakes;

    uint256 public rewardRate;

    error ZeroAmount();
    error NoStakeFound();
    error TransferFailed();

    event Staked(
        address indexed user,
        uint256 amount
    );

    event RewardsClaimed(
        address indexed user,
        uint256 reward
    );

    event Withdrawn(
        address indexed user,
        uint256 amount,
        uint256 reward
    );

    constructor(uint256 _rewardRate) {
        rewardRate = _rewardRate;
    }

    receive() external payable {}

    function stake() external payable {
        if (msg.value == 0) {
            revert ZeroAmount();
        }

        StakeInfo storage user =
            stakes[msg.sender];

        user.amount += msg.value;
        user.lastUpdated =
            block.timestamp;

        emit Staked(
            msg.sender,
            msg.value
        );
    }

    function calculateRewards(
        address _user
    )
        public
        view
        returns (uint256)
    {
        StakeInfo memory user =
            stakes[_user];

        if (user.amount == 0) {
            return 0;
        }

        uint256 duration =
            block.timestamp -
            user.lastUpdated;

        return (
            user.amount *
            rewardRate *
            duration
        ) / 1 days;
    }

    function claimRewards()
        public
    {
        StakeInfo storage user =
            stakes[msg.sender];

        if (user.amount == 0) {
            revert NoStakeFound();
        }

        uint256 reward =
            calculateRewards(
                msg.sender
            );

        user.lastUpdated =
            block.timestamp;

        (bool success, ) =
            payable(msg.sender)
                .call{
                    value: reward
                }("");

        if (!success) {
            revert TransferFailed();
        }

        emit RewardsClaimed(
            msg.sender,
            reward
        );
    }

    function withdraw()
        public
    {
        StakeInfo storage user =
            stakes[msg.sender];

        if (user.amount == 0) {
            revert NoStakeFound();
        }

        uint256 reward =
            calculateRewards(
                msg.sender
            );

        uint256 amount =
            user.amount;

        user.amount = 0;
        user.lastUpdated = 0;

        (bool success, ) =
            payable(msg.sender)
                .call{
                    value:
                        amount +
                        reward
                }("");

        if (!success) {
            revert TransferFailed();
        }

        emit Withdrawn(
            msg.sender,
            amount,
            reward
        );
    }

    function getStakeInfo(
        address _user
    )
        public
        view
        returns (
            uint256 amount,
            uint256 lastUpdated,
            uint256 pendingRewards
        )
    {
        StakeInfo memory user =
            stakes[_user];

        return (
            user.amount,
            user.lastUpdated,
            calculateRewards(_user)
        );
    } 
}