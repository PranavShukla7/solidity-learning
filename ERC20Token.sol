//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MyToken{
    string public name = "Pranav Token";
    string public symbol = "PTK";
    uint8 public decimals = 18;

    uint256 public totalSupply;

    address public owner;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event Mint(
        address indexed to,
        uint256 amount
    );

    event Burn(
        address indexed from,
        uint256 amount
    );

    error NotOwner();
    error InsufficientBalance();
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }
    constructor() {
        owner = msg.sender;
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        totalSupply += _amount;
        balances[_to] += _amount;

        emit Mint(_to, _amount);

        emit Transfer(address(0), _to, _amount);
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);

        return true;
    }

    function burn(uint256 _amount) public {
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }

        balances[msg.sender] -= _amount;
        totalSupply -= _amount;

        emit Burn(msg.sender, _amount);

        emit Transfer(msg.sender, address(0), _amount);
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowances[msg.sender][_spender] = _amount;
        return true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        if (balances[_from] < _amount) {
            revert InsufficientBalance();
        }
        if (allowances[_from][msg.sender] < _amount) {
            revert InsufficientBalance();
        }

        balances[_from] -= _amount;
        balances[_to] += _amount;
        allowances[_from][msg.sender] -= _amount;

        emit Transfer(_from, _to, _amount);

        return true;
    }
}