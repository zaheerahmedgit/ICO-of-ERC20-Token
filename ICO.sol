// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./ERC20Token.sol";

contract ICO is Block{
    address public manager;
    address payable public deposit;
    uint tokenPrice = 0.3 ether;
    uint public cap = 100 ether;
    uint public raisedAmount;
    uint public icoStart = block.timestamp;
    uint public icoEnd = block.timestamp+3600;
    uint public tokenTradeTime = icoEnd+3600;
    uint public maxInvest = 10 ether;
    uint public minInvest = 0.1 ether;

    enum State{beforeStart, afterEnd, runnig, halted}

    State public icoState;

    event Invest(address investor, uint value, uint tokens);

    constructor(address payable _deposit) Block(){
        deposit = _deposit;
        manager = msg.sender;
        icoState = State.beforeStart;
    }
    modifier onlyManager(){
        require(msg.sender==manager, "tum manager nhy ho");
        _;
    }
    function halt() public onlyManager{
        icoState = State.halted;
    }
    function resume() public onlyManager{
        icoState = State.runnig;
    }
    function changeDepositAddr(address payable newDeposit) public onlyManager{
        deposit = newDeposit;
    }
    function getState() public view returns(State){
        if(icoState== State.halted){
            return State.halted;
        }else if(block.timestamp < icoStart){
            return State.beforeStart;
        }else if(block.timestamp>=icoStart && block.timestamp<icoEnd){
            return State.runnig;
        }else{
            return State.afterEnd;
        }
    }
    function invest() payable public {
        icoState = getState();
        require(icoState==State.runnig, "ICO ruk gaya hai bhai");
        require(msg.value>=minInvest && msg.value<=maxInvest, "Undefined amount");
        raisedAmount+=msg.value;

        require(raisedAmount<=cap);
        uint tokens = msg.value/tokenPrice;
        balances[msg.sender]+=tokens;
        balances[founder]-=tokens;
        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);
    }
    function burn() public returns(bool){
        icoState = getState();
        require(icoState== State.afterEnd, "ICO abi chal rha hai bhai");
        balances[founder] = 0;
    }
    function transfer(address to, uint tokens) public override returns(bool success){
        require(block.timestamp>tokenTradeTime, "trade time end ho gya hai bhai sab");
        super.transfer(to, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public override returns(bool success) {
        require(block.timestamp>tokenTradeTime, "time khtm bro");
        super.transferFrom(from, to, tokens);
        return true;
    }
    receive() external payable {
        invest();
    }
    
}