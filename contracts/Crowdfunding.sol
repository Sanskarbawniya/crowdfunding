//Crowdfunding project for GOG

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint256 public goalAmount;
    uint256 public totalFunds;
    uint256 public deadline;
    bool public goalReached;
    bool public fundsWithdrawn;

    mapping(address => uint256) public contributions;

    constructor(uint256 _goalAmount, uint256 _durationInDays) {
        owner = msg.sender;
        goalAmount = _goalAmount;
        deadline = block.timestamp + (_durationInDays * 1 days);
        goalReached = false;
        fundsWithdrawn = false;
    }

    // Function 1: Contribute to the campaign
    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign has ended");
        require(msg.value > 0, "Contribution must be greater than zero");

        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;

        if (totalFunds >= goalAmount) {
            goalReached = true;
        }
    }

    // Function 2: Withdraw funds (only owner, if goal reached)
    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw funds");
        require(goalReached, "Funding goal not reached yet");
        require(!fundsWithdrawn, "Funds already withdrawn");

        fundsWithdrawn = true;
        payable(owner).transfer(address(this).balance);
    }

    // Function 3: Refund contributors (if goal not reached and time ended)
    function refund() external {
        require(block.timestamp > deadline, "Campaign still active");
        require(!goalReached, "Goal was reached, cannot refund");

        uint256 amount = contributions[msg.sender];
        require(amount > 0, "No contributions found");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // Function 4: Check campaign status
    function getCampaignStatus() external view returns (string memory) {
        if (goalReached) {
            return "Goal reached successfully!";
        } else if (block.timestamp > deadline) {
            return "Campaign ended without reaching goal.";
        } else {
            return "Campaign is active.";
        }
    }

    // Function 5: Get contract balance
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
