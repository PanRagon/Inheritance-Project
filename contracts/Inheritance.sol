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
    bool ended = false;
    uint256 weeklyPayout;
    uint256 valueToWithdraw;
    uint256 contractStart;
    uint256 lastTimeStamp;
    uint256 startDate;

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

    modifier _notEnded() {
        require(ended == false, "The inheritance has already ended");
        _;
    }

    constructor() public payable {
        owner = msg.sender;
        value = msg.value;
    }

    function addFunds() public _ownerOnly _notStarted payable {
        value += msg.value;
    }

    function setTimeline(uint lengthInWeeks) public  _notStarted {
        timeline = lengthInWeeks * 1 weeks;
    }

    function setBeneficiary(address _beneficiary) public _notStarted _ownerOnly {
        beneficiary = _beneficiary;
    }

    function setStartDate(uint256 _startDate) public _notStarted _ownerOnly {
        startDate = _startDate;
    }

    function getBalanceOfContract() public _notEnded _ownerOnly _beneficiaryOnly view returns (uint256) {
        return value;
    }

    function getBalanceAvailableForWithdrawal() public _notEnded _beneficiaryOnly view returns (uint256) {
        return valueToWithdraw;
    }

    function calculateWeeklyPayout() internal {
        weeklyPayout = SafeMath.div(value, timeline);
    }

    function startInheritance() public _notStarted _ownerOnly {
        started = true;
        calculateWeeklyPayout();
        lastTimeStamp = block.timestamp;
    }

    function withdraw(uint256 amount) public _beneficiaryOnly _notEnded payable {
        updateValueToWithdraw();
        require(amount < valueToWithdraw, "There isn't enough Ether available to withdraw yet");
        SafeMath.sub(value, amount);
        SafeMath.sub(valueToWithdraw, amount);
        msg.sender.transfer(amount);
    }

    function updateValueToWithdraw() public _notEnded {
        bool updated = false;
        endInheritanceContract;
        while(updated == false) {
            if(block.timestamp - 1 weeks >= lastTimeStamp) {
                valueToWithdraw += weeklyPayout;
                lastTimeStamp += 1 weeks;
            } else updated = true;
        }
    }

    function endInheritanceContract() internal {
        if(value == 0) {
            ended = true;
        }
    }

}
