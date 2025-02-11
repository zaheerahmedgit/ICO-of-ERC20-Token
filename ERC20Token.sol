// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ERC20Interface {
function totalSupply() external view returns (uint);
function balanceOf(address tokenOwner) external view returns (uint balance);
function transfer(address to, uint tokens) external returns (bool success);

function allowance(address tokenOwner, address spender) external view returns (uint remaining);
function approve(address spender, uint tokens) external returns (bool success);
function transferFrom(address from, address to, uint tokens) external returns (bool success);

event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Block is ERC20Interface{
    string public name = "Block";
    string public symbol = "BLT";
    uint public decimal;
    uint public override totalSupply; //this functions belongs to interface so I am overriding this
    address public founder;

    mapping(address=>uint) public balances;
    mapping(address=>mapping(address=>uint)) allowed;

    constructor(){
        totalSupply = 1000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }
    
    //function to determine balance of owner
    function balanceOf(address tokenOwner) public view override returns(uint balance){
        return balances[tokenOwner]; //mapping used
    } 
    
    //function to transfer tokens to an address
    function transfer(address to, uint tokens) public override returns(bool success){
        require(balances[msg.sender]>=tokens, "account mn balance hi nahi hai bro");
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public override returns(bool success){
        require(balances[msg.sender]>=tokens);
        require(tokens>0);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view override returns(uint noOfTokens){
        return allowed[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint tokens) public override returns(bool success){
        require(allowed[from][to]>=tokens,"bahi allow hi nahi hai tujhy");
        require(balances[from]>=tokens, "balance kam hai bhai account mn");
        balances[from]-=tokens;
        balances[to]+=tokens;
         emit Transfer(msg.sender, to, tokens);
        return true;
    }
}