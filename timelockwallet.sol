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
    )
        public
        onlyOwner
    {
        uint256 txId =
            transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                executeAfter:
                    block.timestamp +
                    DELAY,
                executed: false
            })
        );

        emit TransactionQueued(
            txId,
            _to,
            _value,
            block.timestamp +
            DELAY
        );
    }

    function executeTransaction(
        uint256 _txId
    )
        public
        onlyOwner
    {
        if (
            _txId >=
            transactions.length
        ) {
            revert InvalidTransaction();
        }

        Transaction storage txn =
            transactions[_txId];

        if (txn.executed) {
            revert AlreadyExecuted();
        }

        if (
            block.timestamp <
            txn.executeAfter
