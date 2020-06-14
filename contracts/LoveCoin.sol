// SPDX-License-Identifier: MIT
pragma solidity 0.6.9;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract LOVToken is ERC20, Ownable {

    uint public rate;
    mapping (address => uint8) public minters;

    event AddMinter(address minter);
    event RemoveMinter(address minter);
    event SetRate(uint rate);

    constructor() ERC20("LoveCoin", "LOV") public  {
        setRate(10);
        addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(minters[msg.sender] == 1, "Only allowed minters can mint");
        _;
    }

    function setRate(uint _rate) public onlyOwner {
        require(_rate > 0, "Rate cannot be zero");
        rate = _rate;

        emit SetRate(_rate);
    }

    function getRate() public view returns(uint) {
        return rate;
    }

    function addMinter(address _minter) public onlyOwner {
        minters[_minter] = 1;
        emit AddMinter(_minter);
    }

    function removeMinter(address _minter) public onlyOwner {
        minters[_minter] = 0;
        emit RemoveMinter(_minter);
    }

    function mint(address account, uint256 amount) public onlyMinter {
        super._mint(account, amount);
    }

}