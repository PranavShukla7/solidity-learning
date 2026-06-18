// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TimelockWallet {

    address public owner;

    uint256 public constant DELAY = 1 days;

    struct Transaction {
        address to;
        uint256 value;
        uint256 executeAfter;
        bool executed;
    }

    Transaction[] public transactions;

    error NotOwner();
    error InvalidTransaction();
    error AlreadyExecuted();
    error TooEarly();
    error TransferFailed();

    event TransactionQueued(
        uint256 indexed txId,
        address indexed to,
        uint256 value,
        uint256 executeAfter
    );

    event TransactionExecuted(
        uint256 indexed txId
    );

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    function queueTransaction(
        address _to,
        uint256 _value
