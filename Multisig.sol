// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;

    uint256 public requiredApprovals;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        uint256 confirmations;
    }

    Transaction[] public transactions;

    mapping(uint256 => mapping(address => bool))
        public approved;

    error NotOwner();
    error AlreadyApproved();
    error AlreadyExecuted();
    error InvalidTransaction();
    error NotEnoughApprovals();
    error TransferFailed();
    error DuplicateOwner();
    error InvalidApprovals();

    event TransactionSubmitted(
        uint256 indexed txId,
        address indexed to,
        uint256 value
    );

    event TransactionApproved(
        uint256 indexed txId,
        address indexed owner
    );

    event TransactionExecuted(
        uint256 indexed txId
    );

    modifier onlyOwner() {
        if (!isOwner[msg.sender]) {
            revert NotOwner();
        }
        _;
    }

    constructor(address[] memory _owners,uint256 _requiredApprovals) {
        if (_requiredApprovals == 0 ||_requiredApprovals > _owners.length) {
            revert InvalidApprovals();
        }

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            if (isOwner[owner]) {
                revert DuplicateOwner();
            }

            isOwner[owner] = true;
            owners.push(owner);
        }

        requiredApprovals = _requiredApprovals;
    }

    receive() external payable {}

    function submitTransaction(address _to,uint256 _value) public onlyOwner{
        uint256 txId = transactions.length;

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                executed: false,
                confirmations: 0
            })
        );

        emit TransactionSubmitted(txId, _to, _value);
    }

    function approveTransaction(uint256 _txId) public onlyOwner{
        if (_txId >= transactions.length) {
            revert InvalidTransaction();
        }

        Transaction storage txn =
            transactions[_txId];

        if (txn.executed) {
            revert AlreadyExecuted();
        }

        if (approved[_txId][msg.sender]) {
            revert AlreadyApproved();
        }

        approved[_txId][msg.sender] = true;

        txn.confirmations++;

        emit TransactionApproved( _txId, msg.sender);
    }

    function executeTransaction(uint256 _txId) public onlyOwner{
        if (_txId >= transactions.length) {
            revert InvalidTransaction();
        }

        Transaction storage txn = transactions[_txId];

        if (txn.executed) {
            revert AlreadyExecuted();
        }

        if (txn.confirmations < requiredApprovals) {
            revert NotEnoughApprovals();
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

    function getTransactionCount() public view returns (uint256){
        return transactions.length;
    }

    function getTransaction(uint256 _txId) public view returns (address,uint256,bool,uint256){
        if (_txId >= transactions.length) {
            revert InvalidTransaction();
        }

        Transaction memory txn = transactions[_txId];

        return (
            txn.to,
            txn.value,
            txn.executed,
            txn.confirmations
        );
    }
}