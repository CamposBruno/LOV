// SPDX-License-Identifier: MIT
pragma solidity 0.6.9;

import "./LoveCommissioner.sol";

contract LOVWedding  {

    LOVComissioner public lovComissioner;

    mapping (address => address) public marriageProcess;
    mapping (address => address) public partners;
    mapping (address => uint8) public divorceProcess;
    mapping (address => address) public widowerProcess;
    mapping (address => address) public widowers;

    event Pronounce(address partnerOne, address partnerTwo, address comissioner);
    event FileForDivorce(address partner);
    event FileForMarriage(address sender, address partner);
    event GiveUpMarriage(address sender, address partner);
    event GiveUpDivorce(address partner);
    event Divorced(address partnerOne, address partnerTwo, address comissioner);
    event ApplyForWidower(address partner, address deceased);
    event DeclareWidower(address partner, address deceased, address comissioner);

    constructor (LOVComissioner _lovComissioner) public {
        require(address(_lovComissioner) != address(0), "Invalid Address");
        lovComissioner = _lovComissioner;
    }

    modifier onlyComissioner() {
        require(lovComissioner.getComissioner(msg.sender) > 0, "Only comissioners allowed to execute this transaction");
        _;
    }

    modifier onlyMarried() {
        require(partners[msg.sender] != address(0), "Sender is not married");
        _;
    }

    function fileForMarriage(address partner) public {
        require(partners[msg.sender] == address(0), "Sender is already married");
        require(partners[partner] == address(0), "Partner is already married");
        require(marriageProcess[msg.sender] == address(0), "Sender is already filed for marriage");
        marriageProcess[msg.sender] = partner;
        emit FileForMarriage(msg.sender, partner);
    }

    function giveUpMarriage(address partner) public {
        require(partners[msg.sender] == address(0), "Sender is already married");
        require(marriageProcess[msg.sender] == partner, "Sender is not filled to marry this partner");
        marriageProcess[msg.sender] = address(0);
        emit GiveUpMarriage(msg.sender, partner);
    }

    function pronounce(address partnerOne, address partnerTwo) public onlyComissioner {
        require(partnerOne != msg.sender, "Partners cannot pronounce own wedding");
        require(partnerTwo != msg.sender, "Partners cannot pronounce own wedding");
        require(partners[partnerOne] == address(0), "Partner One is already married");
        require(partners[partnerTwo] == address(0), "Partner Two is already married");
        require(marriageProcess[partnerOne] == partnerTwo, "Partner One did not file marriage process to partner Two");
        require(marriageProcess[partnerTwo] == partnerOne, "Partner Two did not file marriage process to partner One");
        // marry the couple
        partners[partnerOne] = partnerTwo;
        partners[partnerTwo] = partnerOne;
        // end marriage process
        marriageProcess[partnerOne] = address(0);
        marriageProcess[partnerTwo] = address(0);
        // spend coin from comissioner
        lovComissioner.spend(msg.sender, 1);

        emit Pronounce(partnerOne, partnerTwo, msg.sender);
    }

    function fileForDivorce() public onlyMarried {
        divorceProcess[msg.sender] = 1;
        emit FileForDivorce(msg.sender);
    }

    function giveUpDivorce() public onlyMarried {
        require(divorceProcess[msg.sender] == 1, "Sender did not file for divorce");
        divorceProcess[msg.sender] = 0;
        emit GiveUpDivorce(msg.sender);
    }

    function divorce(address partnerOne, address partnerTwo) public onlyComissioner {
        require(partnerOne != msg.sender, "Partners cannot end own wedding");
        require(partnerTwo != msg.sender, "Partners cannot end own wedding");
        require(divorceProcess[partnerOne] == 1, "Partner one did not file for divorce");
        require(divorceProcess[partnerTwo] == 1, "Partner two did not file for divorce");
        partners[partnerOne] = address(0);
        partners[partnerTwo] = address(0);
        lovComissioner.spend(msg.sender, 1);
        emit Divorced(partnerOne, partnerTwo, msg.sender);
    }

    function applyForWidower(address deceased) public onlyMarried {
        require(partners[msg.sender] == deceased, "Sender is not married to the deceased");
        require(partners[deceased] == msg.sender, "Sender is not married to the deceased");
        widowerProcess[msg.sender] = deceased;

        emit ApplyForWidower(msg.sender, deceased);
    }

    function declareWidower (address partner, address deceased) public onlyComissioner {
        require(widowerProcess[partner] == address(0), "Partner did not filled for widower");
        require(widowerProcess[partner] == deceased, "Partner did not filled for widower of this deceased");
        widowers[partner] = deceased;
        partners[partner] = address(0);

        lovComissioner.spend(msg.sender, 100);

        emit DeclareWidower(partner, deceased, msg.sender);
    }
}