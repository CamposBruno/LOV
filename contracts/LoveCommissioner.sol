// SPDX-License-Identifier: MIT
pragma solidity 0.6.9;

import "./LoveCoin.sol";
import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract LOVComissioner is Ownable {

    using SafeMath for uint256;

    LOVToken public lovToken;

    mapping (address => uint256) public comissioners;
    mapping (address => uint8) public spenders;

    event Deposit(address from, uint amount);
    event Withdraw(address to, uint amount);
    event Enlist(address comissioner);
    event Spend(address from, uint amount);
    event AddSpender(address from);
    event RemoveSpender(address from);

    constructor (LOVToken _lovToken) public {
        require(address(_lovToken) != address(0), "Invalid Address");
        lovToken = _lovToken;
    }

    modifier onlySpender() {
        require(spenders[msg.sender] == 1, "Not allowed to spend");
        _;
    }

    function  getComissioner(address _comissioner) public view returns ( uint256 )  {
        return comissioners[_comissioner];
    }

    function enlist() public payable {
        require(comissioners[msg.sender] == 0, "Comissioner already enlisted");
        deposit();        
        emit Enlist(msg.sender);
    }

    function deposit() public payable {
        uint amount = msg.value * lovToken.getRate();
        lovToken.mint(msg.sender, amount);
        comissioners[msg.sender] = comissioners[msg.sender].add(amount);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw (uint amount) public onlyOwner {
        require(address(this).balance >= amount, "Not enough balance");
        msg.sender.transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function addSpender(address _spender) public onlyOwner {
        spenders[_spender] = 1;
        emit AddSpender(_spender);
    }

    function removeSpender(address _spender) public onlyOwner {
        spenders[_spender] = 0;
        emit RemoveSpender(_spender);
    }

    function spend (address _comissioner, uint amount) public onlySpender {
        require(comissioners[_comissioner] >= amount, "Comissioner has not enough coins to spend");
        comissioners[_comissioner] = comissioners[_comissioner].sub(amount);
        emit Spend(_comissioner, amount);
    }
    
    fallback () external payable {
        require(msg.data.length == 0);
        emit Deposit(msg.sender, msg.value);
    }
    
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

}