// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract Token {
    
    struct TokenNeeds {
        string name;
        string symbol;
        uint8 decimal;
    }

    TokenNeeds public token;
    uint public totalSupply;
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    // Events (important for tracking transactions)
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint8 _decimal, uint _totalSupply) {
        token.name = _name;
        token.symbol = _symbol;
        token.decimal = _decimal;
        totalSupply = _totalSupply * (10 ** _decimal);
        
        // Give all tokens to contract creator
        balances[msg.sender] = totalSupply;
    }

    // Getter functions
    function getterName() public view returns (string memory) {
        return token.name;
    }
    
    function getterSymbol() public view returns (string memory) {
        return token.symbol;
    }
    
    function getterDecimal() public view returns (uint8) {
        return token.decimal;
    }
    
    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }

    // Check balance of an address
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    // Transfer tokens from your account to another
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Cannot send to zero address");
        require(balances[msg.sender] >= _value, "Insufficient balance");
        
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approve someone to spend tokens on your behalf
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Cannot approve zero address");
        
        allowance[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer tokens from one account to another (must be approved first)
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0), "Cannot transfer from zero address");
        require(_to != address(0), "Cannot transfer to zero address");
        require(balances[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        
        balances[_from] -= _value;
        balances[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
}