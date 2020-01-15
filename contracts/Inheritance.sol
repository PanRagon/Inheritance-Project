pragma solidity >=0.4.21 <0.7.0;

 import { SafeMath } from "../libraries/SafeMath.sol";

 contract Inheritance {
    using SafeMath for uint256;

     mapping (address => uint) balance;
    address owner;
    uint256 timeline;
    address beneficiary;
    uint256 value;
    bool started = false;
    uint256 weeklyPayout;
    uint256 valueToWithdraw;
    uint256 contractStart;

     modifier _ownerOnly() {
        require(msg.sender == owner, "Sender is not the owner of this contract");
        _;
    }

     modifier _beneficiaryOnly() {
        require(msg.sender == beneficiary, "Sender is not a beneficiary of this contract");
        _;
    }

     modifier _notStarted() {
        require(started == false, "The inheritance has already started");
        _;
    }

     constructor() public payable {
        owner = msg.sender;
        value = msg.value;
    }

     function addFunds() public _ownerOnly _notStarted payable {
        value += msg.value;
    }

     function setTimeline(uint lengthInWeeks) public {
        timeline = lengthInWeeks * 1 weeks;
    }

     function setBeneficiary(address _beneficiary) public _ownerOnly {
        beneficiary = _beneficiary;
    }

     function balanceOfContract() public _ownerOnly _beneficiaryOnly view returns (uint) {
        return value;
    }

     function calculateWeeklyPayout() internal {
        weeklyPayout = SafeMath.div(value, timeline);
    }

     function startInheritance() public _ownerOnly {
        started = true;
        calculateWeeklyPayout();
    }

     function withdraw(uint256 amount) public _beneficiaryOnly payable {
        require(amount < valueToWithdraw, "There isn't enough Ether available to withdraw yet");
        msg.sender.transfer(amount);
    }

 }