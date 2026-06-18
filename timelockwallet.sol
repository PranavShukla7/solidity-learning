// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TimelockWallet {

    address public owner;

    uint256 public delay = 1 days;

    struct Transaction {
        address to;
        uint256 value;
        uint256 executeAfter;
        bool executed;
        bool cancelled;
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

    event TransactionCancelled(
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
                    delay,
                executed: false,
                cancelled: false
            })
        );

        emit TransactionQueued(
            txId,
            _to,
            _value,
            block.timestamp +
            delay
        );
    }

    function setDelay(
        uint256 _delay
    )
        public
        onlyOwner
    {
        delay = _delay;
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

        if (txn.cancelled) {
            revert InvalidTransaction();
        }

        if (
            block.timestamp <
            txn.executeAfter
        ) {
            revert TooEarly();
        }

        txn.executed = true;

        (bool success, ) =
            txn.to.call{
                value: txn.value
            }("");

        if (!success) {
            revert TransferFailed();
        }

        emit TransactionExecuted(
            _txId
        );
    }

    function getTransactionCount()
        public
        view
        returns(uint256)
    {
        return transactions.length;
    }

    function getTransaction(
        uint256 _txId
    )
        public
        view
        returns(
            address,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        Transaction memory txn =
            transactions[_txId];

        return (
            txn.to,
            txn.value,
            txn.executeAfter,
            txn.executed,
            txn.cancelled
        );
    }
}
